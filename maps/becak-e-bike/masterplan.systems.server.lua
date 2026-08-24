-- BECAK E-BIKE — masterplan systems v1.7
-- Weather, cargo, damage/repair, session challenge, story progression, and optimized gameplay cadence.
-- Ambient traffic is owned exclusively by traffic.npc.server.lua to avoid duplicate simulation.
local Players=game:GetService('Players')
local Workspace=game:GetService('Workspace')
local Lighting=game:GetService('Lighting')
local ReplicatedStorage=game:GetService('ReplicatedStorage')
local RunService=game:GetService('RunService')

local root=Workspace:WaitForChild('BecakEBike',20)
if not root then return end
local world=root:WaitForChild('Nusakarya',20)
local vehicles=root:WaitForChild('Vehicles',20)
local interactives=root:WaitForChild('Interactives',20)
local remotes=ReplicatedStorage:WaitForChild('BecakEBikeRemotes',20)
local economy=root:WaitForChild('EconomyTransaction',20)
if not world or not vehicles or not interactives or not remotes or not economy then return end
local toast=remotes:WaitForChild('Toast')

local oldSystems=root:FindFirstChild('MasterplanSystems')
if oldSystems then oldSystems:Destroy() end
local systems=Instance.new('Folder');systems.Name='MasterplanSystems';systems.Parent=root
local function part(parent,name,size,cf,color,material,collide)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=collide~=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Parent=parent;return p
end
local function prompt(parent,action,obj)
 local x=Instance.new('ProximityPrompt');x.ActionText=action;x.ObjectText=obj;x.HoldDuration=.35;x.MaxActivationDistance=12;x.RequiresLineOfSight=false;x.Parent=parent;return x
end
local function label(parent,text)
 local g=Instance.new('BillboardGui');g.Size=UDim2.fromOffset(230,60);g.StudsOffset=Vector3.new(0,4,0);g.AlwaysOnTop=true;g.Parent=parent
 local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=.2;t.BackgroundColor3=Color3.fromRGB(18,22,26);t.TextColor3=Color3.new(1,1,1);t.TextScaled=true;t.Font=Enum.Font.GothamBold;t.Text=text;t.Parent=g
end
local function playerBecak(player)
 for _,m in ipairs(vehicles:GetChildren()) do if m:GetAttribute('OwnerUserId')==player.UserId then return m end end
end
local function transact(player,amount,xp,reason)
 local ok,result=pcall(function() return economy:Invoke(player,amount,xp or 0,reason or '') end)
 return ok and result==true
end

-- Dynamic weather.
local weatherCycle={'CERAH','MENDUNG','HUJAN','CERAH','CERAH','HUJAN'}
local weatherIndex=1
local function setWeather(name)
 Workspace:SetAttribute('BecakWeather',name)
 if name=='CERAH' then Lighting.Brightness=2.6;Lighting.ExposureCompensation=.05
 elseif name=='MENDUNG' then Lighting.Brightness=1.65;Lighting.ExposureCompensation=-.15
 elseif name=='HUJAN' then Lighting.Brightness=1.25;Lighting.ExposureCompensation=-.3 end
 local a=Lighting:FindFirstChildOfClass('Atmosphere');if a then a.Density=name=='HUJAN' and .38 or (name=='MENDUNG' and .3 or .2);a.Haze=name=='HUJAN' and 2.4 or 1.1 end
 for _,plr in ipairs(Players:GetPlayers()) do toast:FireClient(plr,'Cuaca Nusakarya: '..name) end
end
setWeather(weatherCycle[weatherIndex])
task.spawn(function() while root.Parent do task.wait(180);weatherIndex=weatherIndex%#weatherCycle+1;setWeather(weatherCycle[weatherIndex]) end end)

-- Vehicle condition and collision damage v1.7.
-- Uses relative impact speed and ignores normal road contact so glancing/static-world touches do not over-penalize drivability.
local damageCooldown={}
local function isNormalDriveSurface(hit)
 if not hit then return false end
 if hit:GetAttribute('BecakDriveSurface') or hit:GetAttribute('BecakRoadSkin') or hit:GetAttribute('BecakCurbCut') then return true end
 return string.sub(hit.Name or '',1,6)=='Jalan_'
end
local function hookVehicle(model)
 if not model:IsA('Model') then return end
 task.defer(function()
  local chassis=model:WaitForChild('Chassis',10);if not chassis then return end
  if model:GetAttribute('Condition')==nil then model:SetAttribute('Condition',100) end
  chassis.Touched:Connect(function(hit)
   if not hit or hit:IsDescendantOf(model) or not hit.CanCollide or isNormalDriveSurface(hit) then return end
   local now=os.clock();if damageCooldown[model] and now-damageCooldown[model]<1.1 then return end
   local otherVelocity=hit.AssemblyLinearVelocity or Vector3.zero
   local impactSpeed=(chassis.AssemblyLinearVelocity-otherVelocity).Magnitude
   if impactSpeed<16 then return end
   damageCooldown[model]=now
   local condition=model:GetAttribute('Condition') or 100
   local loss=math.clamp(math.floor((impactSpeed-12)*.18),2,15)
   model:SetAttribute('Condition',math.max(0,condition-loss))
   model:SetAttribute('LastImpactSpeed',math.floor(impactSpeed+.5))
   model:SetAttribute('LastImpactDamage',loss)
   local ownerId=model:GetAttribute('OwnerUserId');local plr=ownerId and Players:GetPlayerByUserId(ownerId)
   if plr then toast:FireClient(plr,'Becak terbentur • kondisi -'..loss..'%') end
  end)
 end)
end
for _,v in ipairs(vehicles:GetChildren()) do hookVehicle(v) end
vehicles.ChildAdded:Connect(hookVehicle)

-- Repair shop.
local repair=part(interactives,'RepairShop',Vector3.new(28,1,20),CFrame.new(-155,.6,-85),Color3.fromRGB(205,85,65),Enum.Material.Neon,true)
label(repair,'BENGKEL • SERVIS')
local repairPrompt=prompt(repair,'Service Becak','Bengkel Pak Jaya')
repairPrompt.Triggered:Connect(function(player)
 local b=playerBecak(player);if not b then return end
 local hp=b:GetAttribute('Condition') or 100
 if hp>=99 then toast:FireClient(player,'Kondisi becak masih prima.') return end
 local cost=math.ceil((100-hp)*500)
 if not transact(player,-cost,0,'repair') then toast:FireClient(player,'Biaya servis Rp'..cost..'. Saldo belum cukup.') return end
 b:SetAttribute('Condition',100);toast:FireClient(player,'Servis selesai • kondisi kembali 100%.')
end)

-- Cargo / logistics jobs v1.6: route integrity + graceful vehicle-loss recovery.
local CARGO_VEHICLE_MISSING_TIMEOUT=45
local cargoFolder=Instance.new('Folder');cargoFolder.Name='CargoJobs';cargoFolder.Parent=systems
local cargoActive={}
local lastCargoDestination={}
local cargoPickupCooldown={}
local cargoPickup=part(cargoFolder,'CargoDepot',Vector3.new(30,1,22),CFrame.new(365,.6,430),Color3.fromRGB(210,145,55),Enum.Material.Neon,true)
label(cargoPickup,'CARGO DEPOT')
local cargoPrompt=prompt(cargoPickup,'Ambil Cargo','Nusakarya Logistics')
local cargoDrops={
 {name='Pasar Nusantara',pos=Vector3.new(-310,2,300)},
 {name='Terminal Raya',pos=Vector3.new(390,2,60)},
 {name='Hotel Bahari',pos=Vector3.new(340,2,-220)},
 {name='Sekolah Nusakarya',pos=Vector3.new(-300,2,-80)},
 {name='Pusat Kota',pos=Vector3.new(20,2,120)},
 {name='Pantai Bahari',pos=Vector3.new(75,2,-360)},
}
for i,d in ipairs(cargoDrops) do local x=part(cargoFolder,'CargoDrop_'..i,Vector3.new(13,.5,13),CFrame.new(d.pos),Color3.fromRGB(235,165,60),Enum.Material.Neon,false);x.Transparency=.55;x:SetAttribute('DropName',d.name) end
local function chooseCargoDrop(player)
 local previous=lastCargoDestination[player]
 local available={}
 for _,d in ipairs(cargoDrops) do if d.name~=previous then table.insert(available,d) end end
 local pool=#available>0 and available or cargoDrops
 return pool[math.random(1,#pool)]
end
local function cargoPayout(distance)
 return math.floor(math.clamp(22000+distance*55,30000,65000))
end
local function minimumCargoDuration(distance)
 -- Max upgraded motor is ~47 studs/s; this threshold is intentionally lenient but rejects instant teleports.
 return math.clamp(distance/75,4.5,18)
end
local function clearCargoState(player)
 player:SetAttribute('CargoDestination',nil)
 player:SetAttribute('CargoDistanceStuds',0)
 player:SetAttribute('CargoBaseReward',0)
 player:SetAttribute('CargoDrivenDistanceStuds',0)
 player:SetAttribute('CargoMinDurationSeconds',0)
 player:SetAttribute('CargoVehicleMissingSeconds',0)
end
local function cancelCargoForMissingVehicle(player)
 cargoActive[player]=nil
 cargoPickupCooldown[player]=os.clock()+2
 clearCargoState(player)
 toast:FireClient(player,'Cargo dibatalkan • Becak tidak tersedia terlalu lama. Ambil job baru di depot.')
end
cargoPrompt.Triggered:Connect(function(player)
 local now=os.clock()
 if (cargoPickupCooldown[player] or 0)>now then toast:FireClient(player,'Tunggu sebentar sebelum mengambil cargo berikutnya.') return end
 if cargoActive[player] then toast:FireClient(player,'Cargo aktif: '..cargoActive[player].name) return end
 local b=playerBecak(player);if not b or not b.PrimaryPart or (b.PrimaryPart.Position-cargoPickup.Position).Magnitude>30 then toast:FireClient(player,'Dekatkan Becak E-Bike ke Cargo Depot.') return end
 local d=chooseCargoDrop(player)
 local distance=(cargoPickup.Position-d.pos).Magnitude
 local reward=cargoPayout(distance)
 cargoActive[player]={name=d.name,pos=d.pos,startedAt=now,distance=distance,reward=reward,lastPos=b.PrimaryPart.Position,drivenDistance=0,lastIntegrityToast=0,vehicleMissingSince=nil}
 lastCargoDestination[player]=d.name
 player:SetAttribute('CargoDestination',d.name)
 player:SetAttribute('CargoDistanceStuds',math.floor(distance))
 player:SetAttribute('CargoBaseReward',reward)
 player:SetAttribute('CargoDrivenDistanceStuds',0)
 player:SetAttribute('CargoMinDurationSeconds',math.ceil(minimumCargoDuration(distance)))
 player:SetAttribute('CargoVehicleMissingSeconds',0)
 toast:FireClient(player,'Cargo dimuat • '..d.name..' • estimasi Rp'..reward)
end)

-- Session challenge and story progression based on persistent trip total.
local joinTrips={}
local lastProgressTrips={}
local function syncProgress(player)
 local total=player:GetAttribute('BecakTrips') or 0
 local chapter=1
 if total>=10 then chapter=2 end;if total>=25 then chapter=3 end;if total>=50 then chapter=4 end;if total>=100 then chapter=5 end
 player:SetAttribute('StoryChapter',chapter)
 local baseline=joinTrips[player] or total
 local sessionTrips=math.max(0,total-baseline);player:SetAttribute('SessionTrips',sessionTrips)
 if sessionTrips>=10 and not player:GetAttribute('Session10Claimed') then
  player:SetAttribute('Session10Claimed',true)
  if transact(player,50000,100,'session10') then toast:FireClient(player,'Tantangan 10 trip selesai • +Rp50.000 +100 XP') end
 end
 lastProgressTrips[player]=total
end

-- Gameplay maintenance loop. Traffic simulation lives only in traffic.npc.server.lua.
-- Run cargo completion + progression at 5 Hz.
local accum=0
RunService.Heartbeat:Connect(function(dt)
 accum+=dt;if accum<.2 then return end;accum=0
 for player,d in pairs(cargoActive) do
  if player.Parent then
   local b=playerBecak(player)
   if b and b.PrimaryPart then
    d.vehicleMissingSince=nil
    player:SetAttribute('CargoVehicleMissingSeconds',0)
    local pos=b.PrimaryPart.Position
    local last=d.lastPos or pos
    local step=(pos-last).Magnitude
    -- Normal max speed is below 50 studs/s. Ignore implausibly large 5 Hz position jumps from distance proof.
    if step<=18 then d.drivenDistance=(d.drivenDistance or 0)+step end
    d.lastPos=pos
    player:SetAttribute('CargoDrivenDistanceStuds',math.floor(d.drivenDistance or 0))
    if (pos-d.pos).Magnitude<25 then
     local duration=math.max(0,os.clock()-(d.startedAt or os.clock()))
     local enoughTime=duration>=minimumCargoDuration(d.distance or 0)
     local enoughTravel=(d.drivenDistance or 0)>=math.max(25,(d.distance or 0)*.55)
     if enoughTime and enoughTravel then
      cargoActive[player]=nil
      cargoPickupCooldown[player]=os.clock()+3
      clearCargoState(player)
      local xp=math.floor(math.clamp(30+(d.distance or 0)/16,35,90))
      if transact(player,d.reward or 35000,xp,'cargo') then
       player:SetAttribute('CargoJobs',(player:GetAttribute('CargoJobs') or 0)+1)
       player:SetAttribute('CargoLastReward',d.reward or 35000)
       player:SetAttribute('CargoLastDurationSeconds',math.floor(duration))
       player:SetAttribute('CargoLastDistanceStuds',math.floor(d.distance or 0))
       toast:FireClient(player,'Cargo terkirim ke '..d.name..' • +Rp'..(d.reward or 35000)..' +'..xp..' XP')
      end
     elseif os.clock()-(d.lastIntegrityToast or 0)>3 then
      d.lastIntegrityToast=os.clock()
      toast:FireClient(player,'Cargo belum tervalidasi • selesaikan rute dengan Becak E-Bike.')
     end
    end
   else
    local now=os.clock()
    d.vehicleMissingSince=d.vehicleMissingSince or now
    local missingFor=math.max(0,now-d.vehicleMissingSince)
    player:SetAttribute('CargoVehicleMissingSeconds',math.floor(missingFor))
    if missingFor>=CARGO_VEHICLE_MISSING_TIMEOUT then cancelCargoForMissingVehicle(player) end
   end
  end
 end
 for _,player in ipairs(Players:GetPlayers()) do
  local total=player:GetAttribute('BecakTrips') or 0
  if lastProgressTrips[player]~=total then syncProgress(player) end
 end
end)

local function setupPlayer(player)
 player:SetAttribute('DailyTripGoal',10)
 player:SetAttribute('CargoJobs',player:GetAttribute('CargoJobs') or 0)
 player:SetAttribute('CargoDistanceStuds',0)
 player:SetAttribute('CargoBaseReward',0)
 player:SetAttribute('CargoDrivenDistanceStuds',0)
 player:SetAttribute('CargoMinDurationSeconds',0)
 player:SetAttribute('CargoVehicleMissingSeconds',0)
 player:SetAttribute('CargoLastReward',player:GetAttribute('CargoLastReward') or 0)
 player:SetAttribute('CargoLastDurationSeconds',player:GetAttribute('CargoLastDurationSeconds') or 0)
 player:SetAttribute('CargoLastDistanceStuds',player:GetAttribute('CargoLastDistanceStuds') or 0)
 player:SetAttribute('Session10Claimed',false)
 task.delay(2,function() if player.Parent then local total=player:GetAttribute('BecakTrips') or 0;joinTrips[player]=total;syncProgress(player) end end)
 task.delay(4,function() if player.Parent then toast:FireClient(player,'Nusakarya aktif • penumpang • cargo • charging • bengkel • cuaca • upgrade') end end)
end
for _,player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player) joinTrips[player]=nil;lastProgressTrips[player]=nil;cargoActive[player]=nil;lastCargoDestination[player]=nil;cargoPickupCooldown[player]=nil end)

-- Preserve v1.5/v1.6 compatibility markers while exposing additive v1.7 damage/drivability hardening.
Workspace:SetAttribute('ACC_BecakMasterplanSystems','v1.5')
Workspace:SetAttribute('ACC_BecakMasterplanSystemsResilience','v1.6')
Workspace:SetAttribute('ACC_BecakMasterplanSystemsDamage','v1.7')
Workspace:SetAttribute('BecakLegacyTrafficDisabled','ON')
Workspace:SetAttribute('BecakSystemsTickHz',5)
Workspace:SetAttribute('BecakCargoDynamicPayout','ON')
Workspace:SetAttribute('BecakCargoDestinationCount',#cargoDrops)
Workspace:SetAttribute('BecakCargoNoImmediateRepeat','ON')
Workspace:SetAttribute('BecakCargoIntegrityValidation','ON')
Workspace:SetAttribute('BecakCargoMinimumTravelRatio',0.55)
Workspace:SetAttribute('BecakCargoTeleportJumpRejectStuds',18)
Workspace:SetAttribute('BecakCargoVehicleLossRecovery','ON')
Workspace:SetAttribute('BecakCargoVehicleMissingTimeoutSeconds',CARGO_VEHICLE_MISSING_TIMEOUT)
Workspace:SetAttribute('BecakCollisionDamageRelativeVelocity','ON')
Workspace:SetAttribute('BecakCollisionDamageSurfaceFilter','ON')
Workspace:SetAttribute('BecakCollisionDamageThresholdStuds',16)
print('[BECAK E-BIKE] masterplan systems v1.7 ready: safer collision damage + cargo integrity + vehicle-loss recovery + 5 Hz maintenance')