-- BECAK E-BIKE — world readability/performance QC v2.5
-- Keeps mobile rendering/query cost predictable as Nusakarya grows.
-- Decorative route/marker geometry stays visual-only; important gameplay parts remain untouched.
-- v2.0 adds burst-safe descendant batching and rate-limited telemetry for streaming/runtime growth.
-- v2.1 adds a delayed, non-destructive cargo resilience runtime audit.
-- v2.2 adds hard target identity + passenger proof-of-travel runtime audits.
-- v2.3 adds mobile safe-area/phone ownership + garage/economy safety runtime audits.
-- v2.4 synchronizes economy safety QC with Garage Safety v1.4 service-prompt debounce hardening.
-- v2.5 synchronizes mobile QC with Safe Area v1.35 visibility-aware fallback scheduling.

local Workspace=game:GetService('Workspace')
local root=Workspace:WaitForChild('BecakEBike',20)
if not root then return end

local EXPECTED_UNIVERSE_ID=10745325613
local EXPECTED_PLACE_ID=80994730522893

local tunedBillboards=setmetatable({}, {__mode='k'})
local tunedDecor=setmetatable({}, {__mode='k'})
local queued=setmetatable({}, {__mode='k'})
local queue={}
local billboardCount=0
local decorCount=0
local queueHead=1
local telemetryDirty=true
local workerRunning=false

local BATCH_SIZE=48
local BATCH_INTERVAL=.10
local TELEMETRY_INTERVAL=.25

local function publishTelemetry()
 Workspace:SetAttribute('BecakWorldQCBillboards',billboardCount)
 Workspace:SetAttribute('BecakWorldQCDecorParts',decorCount)
 Workspace:SetAttribute('BecakWorldQCPending',math.max(0,#queue-queueHead+1))
 telemetryDirty=false
end

local function markTelemetryDirty()
 telemetryDirty=true
end

local function tuneBillboard(g)
 if not g:IsA('BillboardGui') then return end
 g.AlwaysOnTop=false
 if g.MaxDistance==0 or g.MaxDistance>72 then g.MaxDistance=60 end
 g.LightInfluence=.25
 local sx=math.min(g.Size.X.Offset>0 and g.Size.X.Offset or 150,160)
 local sy=math.min(g.Size.Y.Offset>0 and g.Size.Y.Offset or 40,44)
 g.Size=UDim2.fromOffset(sx,sy)
 for _,d in ipairs(g:GetDescendants()) do
  if d:IsA('TextLabel') then
   d.TextScaled=false
   d.TextSize=math.clamp(d.TextSize,10,13)
   d.TextWrapped=true
  end
 end
 if not tunedBillboards[g] then
  tunedBillboards[g]=true
  billboardCount+=1
  markTelemetryDirty()
 end
end

local function isDecorativeName(n)
 return string.find(n,'_Mark',1,true)
  or string.find(n,'District_',1,true)
  or string.find(n,'Destination_',1,true)
  or string.find(n,'CargoDrop_',1,true)
  or string.find(n,'NavMarker',1,true)
  or string.find(n,'RouteMarker',1,true)
end

local function tunePart(p)
 if not p:IsA('BasePart') then return end
 local n=p.Name
 local decorative=isDecorativeName(n)
 if decorative then
  p.CanCollide=false
  p.CanTouch=false
  p.CanQuery=false
  p.CastShadow=false
  if not tunedDecor[p] then
   tunedDecor[p]=true
   decorCount+=1
   markTelemetryDirty()
  end
 end
 if string.find(n,'Traffic_',1,true) then
  p.CanCollide=false
  p.CanTouch=false
  p.CanQuery=false
  p.CastShadow=false
 end
end

local function tune(d)
 if d:IsA('BillboardGui') then tuneBillboard(d) elseif d:IsA('BasePart') then tunePart(d) end
end

local function compactQueue()
 if queueHead<=256 then return end
 local fresh={}
 for i=queueHead,#queue do fresh[#fresh+1]=queue[i] end
 queue=fresh
 queueHead=1
end

local function runWorker()
 if workerRunning then return end
 workerRunning=true
 task.spawn(function()
  while queueHead<=#queue do
   local processed=0
   while queueHead<=#queue and processed<BATCH_SIZE do
    local d=queue[queueHead]
    queue[queueHead]=nil
    queueHead+=1
    processed+=1
    if d then
     queued[d]=nil
     if d:IsDescendantOf(root) then tune(d) end
    end
   end
   compactQueue()
   markTelemetryDirty()
   task.wait(BATCH_INTERVAL)
  end
  queue={}
  queueHead=1
  workerRunning=false
  markTelemetryDirty()
 end)
end

local function enqueue(d)
 if queued[d] then return end
 queued[d]=true
 queue[#queue+1]=d
 runWorker()
end

for _,d in ipairs(root:GetDescendants()) do tune(d) end
publishTelemetry()
root.DescendantAdded:Connect(enqueue)
root.DescendantRemoving:Connect(function(d)
 queued[d]=nil
 if tunedBillboards[d] then tunedBillboards[d]=nil;billboardCount=math.max(0,billboardCount-1);markTelemetryDirty() end
 if tunedDecor[d] then tunedDecor[d]=nil;decorCount=math.max(0,decorCount-1);markTelemetryDirty() end
end)

task.spawn(function()
 while root.Parent do
  task.wait(TELEMETRY_INTERVAL)
  if telemetryDirty then publishTelemetry() end
 end
end)

local function auditTargetIdentity()
 local universeOk=game.GameId==EXPECTED_UNIVERSE_ID
 local placeOk=game.PlaceId==EXPECTED_PLACE_ID
 local pass=universeOk and placeOk
 Workspace:SetAttribute('BecakWorldQCTargetIdentity',pass and 'PASS' or 'FAIL')
 Workspace:SetAttribute('BecakWorldQCUniverseId',game.GameId)
 Workspace:SetAttribute('BecakWorldQCPlaceId',game.PlaceId)
 if not pass then warn('[BECAK E-BIKE][QC] target identity FAIL',game.GameId,game.PlaceId,'expected',EXPECTED_UNIVERSE_ID,EXPECTED_PLACE_ID) end
 return pass
end

task.delay(3,function()
 if not root.Parent then return end
 local targetPass=auditTargetIdentity()

 local resilience=Workspace:GetAttribute('ACC_BecakMasterplanSystemsResilience')
 local recovery=Workspace:GetAttribute('BecakCargoVehicleLossRecovery')
 local timeout=tonumber(Workspace:GetAttribute('BecakCargoVehicleMissingTimeoutSeconds'))
 local cargoIntegrity=Workspace:GetAttribute('BecakCargoIntegrityValidation')
 local cargoPass=resilience=='v1.6' and recovery=='ON' and timeout==45 and cargoIntegrity=='ON'
 Workspace:SetAttribute('BecakWorldQCCargoResilience',cargoPass and 'PASS' or 'FAIL')
 Workspace:SetAttribute('BecakWorldQCCargoResilienceVersion',tostring(resilience or 'missing'))
 Workspace:SetAttribute('BecakWorldQCCargoTimeoutSeconds',timeout or -1)
 if not cargoPass then warn('[BECAK E-BIKE][QC] cargo resilience audit FAIL',resilience,recovery,timeout,cargoIntegrity) end

 local passengerVersion=Workspace:GetAttribute('ACC_BecakPassengerIntegrity')
 local passengerIntegrity=Workspace:GetAttribute('BecakPassengerIntegrityValidation')
 local minRatio=tonumber(Workspace:GetAttribute('BecakPassengerMinimumTravelRatio'))
 local minStuds=tonumber(Workspace:GetAttribute('BecakPassengerMinimumTravelStuds'))
 local jumpReject=tonumber(Workspace:GetAttribute('BecakPassengerTeleportJumpRejectStuds'))
 local passengerPass=passengerVersion=='v1.0' and passengerIntegrity=='ON' and minRatio==0.55 and minStuds==30 and jumpReject==18
 Workspace:SetAttribute('BecakWorldQCPassengerIntegrity',passengerPass and 'PASS' or 'FAIL')
 Workspace:SetAttribute('BecakWorldQCPassengerIntegrityVersion',tostring(passengerVersion or 'missing'))
 Workspace:SetAttribute('BecakWorldQCPassengerMinTravelRatio',minRatio or -1)
 Workspace:SetAttribute('BecakWorldQCPassengerMinTravelStuds',minStuds or -1)
 Workspace:SetAttribute('BecakWorldQCPassengerJumpRejectStuds',jumpReject or -1)
 if not passengerPass then warn('[BECAK E-BIKE][QC] passenger integrity audit FAIL',passengerVersion,passengerIntegrity,minRatio,minStuds,jumpReject) end

 local mobileVersion=Workspace:GetAttribute('ACC_BecakMobileSafeAreaEnhancement')
 local mobileUX=Workspace:GetAttribute('ACC_BecakMobileSafeAreaUX')
 local layoutOwner=Workspace:GetAttribute('BecakPhoneLayoutOwner')
 local framePolling=Workspace:GetAttribute('BecakMobileSafeAreaFramePolling')
 local pollHz=tonumber(Workspace:GetAttribute('BecakMobileSafeAreaPollHz'))
 local visibilityAware=Workspace:GetAttribute('BecakMobileSafeAreaVisibilityAware')
 local openFallback=tonumber(Workspace:GetAttribute('BecakMobileSafeAreaFallbackIntervalSeconds'))
 local closedFallback=tonumber(Workspace:GetAttribute('BecakMobileSafeAreaClosedFallbackSeconds'))
 local mobilePass=mobileVersion=='v1.35' and mobileUX=='v1.32' and layoutOwner=='SAFE_AREA' and framePolling=='OFF' and pollHz==2 and visibilityAware=='ON' and openFallback==0.5 and closedFallback==1.5
 Workspace:SetAttribute('BecakWorldQCMobileSafeArea',mobilePass and 'PASS' or 'FAIL')
 Workspace:SetAttribute('BecakWorldQCMobileSafeAreaVersion',tostring(mobileVersion or 'missing'))
 Workspace:SetAttribute('BecakWorldQCMobileLayoutOwner',tostring(layoutOwner or 'missing'))
 Workspace:SetAttribute('BecakWorldQCMobileClosedFallbackSeconds',closedFallback or -1)
 if not mobilePass then warn('[BECAK E-BIKE][QC] mobile safe-area audit FAIL',mobileVersion,mobileUX,layoutOwner,framePolling,pollHz,visibilityAware,openFallback,closedFallback) end

 local garageSafety=Workspace:GetAttribute('ACC_BecakGarageSafetyEnhancement')
 local debounce=Workspace:GetAttribute('BecakGaragePurchaseDebounce')
 local hold=Workspace:GetAttribute('BecakGarageMobileDeliberateHold')
 local serviceSafety=Workspace:GetAttribute('BecakServicePromptSafety')
 local serviceDebounce=Workspace:GetAttribute('BecakEconomyServicePromptDebounce')
 local serviceCooldown=tonumber(Workspace:GetAttribute('BecakEconomyServicePromptCooldownSeconds'))
 local hardenedCount=tonumber(Workspace:GetAttribute('BecakEconomyPromptHardenedCount'))
 local economyPass=garageSafety=='v1.4' and debounce=='ON' and hold=='ON' and serviceSafety=='ON' and serviceDebounce=='ON' and serviceCooldown==1 and hardenedCount==3
 Workspace:SetAttribute('BecakWorldQCEconomySafety',economyPass and 'PASS' or 'FAIL')
 Workspace:SetAttribute('BecakWorldQCEconomySafetyVersion',tostring(garageSafety or 'missing'))
 Workspace:SetAttribute('BecakWorldQCServicePromptCooldownSeconds',serviceCooldown or -1)
 Workspace:SetAttribute('BecakWorldQCHardenedServicePrompts',hardenedCount or -1)
 if not economyPass then warn('[BECAK E-BIKE][QC] economy safety audit FAIL',garageSafety,debounce,hold,serviceSafety,serviceDebounce,serviceCooldown,hardenedCount) end

 Workspace:SetAttribute('BecakWorldQCCoreSystems',(targetPass and cargoPass and passengerPass and mobilePass and economyPass) and 'PASS' or 'FAIL')
end)

Workspace:SetAttribute('ACC_BecakWorldQC','v2.0')
Workspace:SetAttribute('ACC_BecakWorldQCEnhancement','v2.5')
Workspace:SetAttribute('BecakDecorativeCollision','OFF')
Workspace:SetAttribute('BecakDecorativeShadows','OFF')
Workspace:SetAttribute('BecakWorldQCLiveTelemetry','ON')
Workspace:SetAttribute('BecakWorldQCIdempotent','ON')
Workspace:SetAttribute('BecakWorldQCBatchedStreaming','ON')
Workspace:SetAttribute('BecakWorldQCBatchSize',BATCH_SIZE)
Workspace:SetAttribute('BecakWorldQCTelemetryHz',1/TELEMETRY_INTERVAL)
Workspace:SetAttribute('BecakWorldQCTargetIdentity','PENDING')
Workspace:SetAttribute('BecakWorldQCCargoResilience','PENDING')
Workspace:SetAttribute('BecakWorldQCPassengerIntegrity','PENDING')
Workspace:SetAttribute('BecakWorldQCMobileSafeArea','PENDING')
Workspace:SetAttribute('BecakWorldQCEconomySafety','PENDING')
Workspace:SetAttribute('BecakWorldQCCoreSystems','PENDING')
publishTelemetry()
print('[BECAK E-BIKE] world QC v2.5 ready | target + passenger + cargo + mobile v1.35 + economy v1.4 audits | batched streaming | billboards',billboardCount,'decor',decorCount)
