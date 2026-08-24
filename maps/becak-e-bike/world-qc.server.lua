-- BECAK E-BIKE — world readability/performance QC v2.1
-- Keeps mobile rendering/query cost predictable as Nusakarya grows.
-- Decorative route/marker geometry stays visual-only; important gameplay parts remain untouched.
-- v2.0 adds burst-safe descendant batching and rate-limited telemetry for streaming/runtime growth.
-- v2.1 adds a delayed, non-destructive cargo resilience runtime audit.

local Workspace=game:GetService('Workspace')
local root=Workspace:WaitForChild('BecakEBike',20)
if not root then return end

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
 for i=queueHead,#queue do
  fresh[#fresh+1]=queue[i]
 end
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

-- Initial load is deterministic and done once before live streaming starts.
for _,d in ipairs(root:GetDescendants()) do tune(d) end
publishTelemetry()

root.DescendantAdded:Connect(enqueue)

root.DescendantRemoving:Connect(function(d)
 queued[d]=nil
 if tunedBillboards[d] then
  tunedBillboards[d]=nil
  billboardCount=math.max(0,billboardCount-1)
  markTelemetryDirty()
 end
 if tunedDecor[d] then
  tunedDecor[d]=nil
  decorCount=math.max(0,decorCount-1)
  markTelemetryDirty()
 end
end)

task.spawn(function()
 while root.Parent do
  task.wait(TELEMETRY_INTERVAL)
  if telemetryDirty then publishTelemetry() end
 end
end)

-- Scripts start concurrently. Audit additive cargo v1.6 markers after systems initialization settles.
task.delay(3,function()
 if not root.Parent then return end
 local resilience=Workspace:GetAttribute('ACC_BecakMasterplanSystemsResilience')
 local recovery=Workspace:GetAttribute('BecakCargoVehicleLossRecovery')
 local timeout=tonumber(Workspace:GetAttribute('BecakCargoVehicleMissingTimeoutSeconds'))
 local integrity=Workspace:GetAttribute('BecakCargoIntegrityValidation')
 local pass=resilience=='v1.6' and recovery=='ON' and timeout==45 and integrity=='ON'
 Workspace:SetAttribute('BecakWorldQCCargoResilience',pass and 'PASS' or 'FAIL')
 Workspace:SetAttribute('BecakWorldQCCargoResilienceVersion',tostring(resilience or 'missing'))
 Workspace:SetAttribute('BecakWorldQCCargoTimeoutSeconds',timeout or -1)
 if not pass then warn('[BECAK E-BIKE][QC] cargo resilience audit FAIL',resilience,recovery,timeout,integrity) end
end)

-- Preserve the v2.0 compatibility marker and expose the additive v2.1 audit revision.
Workspace:SetAttribute('ACC_BecakWorldQC','v2.0')
Workspace:SetAttribute('ACC_BecakWorldQCEnhancement','v2.1')
Workspace:SetAttribute('BecakDecorativeCollision','OFF')
Workspace:SetAttribute('BecakDecorativeShadows','OFF')
Workspace:SetAttribute('BecakWorldQCLiveTelemetry','ON')
Workspace:SetAttribute('BecakWorldQCIdempotent','ON')
Workspace:SetAttribute('BecakWorldQCBatchedStreaming','ON')
Workspace:SetAttribute('BecakWorldQCBatchSize',BATCH_SIZE)
Workspace:SetAttribute('BecakWorldQCTelemetryHz',1/TELEMETRY_INTERVAL)
Workspace:SetAttribute('BecakWorldQCCargoResilience','PENDING')
publishTelemetry()
print('[BECAK E-BIKE] world QC v2.1 ready | batched streaming | cargo resilience audit | billboards',billboardCount,'decor',decorCount)
