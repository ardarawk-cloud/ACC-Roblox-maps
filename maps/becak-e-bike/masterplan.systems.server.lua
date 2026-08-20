-- BECAK E-BIKE — masterplan systems v1.2
-- Weather, cargo, damage/repair, session challenge, story progression and ambient traffic.
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

-- Vehicle condition and collision damage.
local damageCooldown={}
local function hookVehicle(model)
 if not model:IsA('Model') then return end
 task.defer(function()
  local chassis=model:WaitForChild('Chassis',10);if not chassis then return end
  if model:GetAttribute('Condition')==nil then model:SetAttribute('Condition',100) end
  chassis.Touched:Connect(function(hit)
   if not hit or hit:IsDescendantOf(model) or not hit.CanCollide then return end
   local now=os.clock();if damageCooldown[model] and now-damageCooldown[model]<1.1 then return end
   local speed=chassis.AssemblyLinearVelocity.Magnitude;if speed<18 then return end
   damageCooldown[model]=now
   local condition=model:GetAttribute('Condition') or 100
   local loss=math.clamp(math.floor(speed*.22),3,18)
   model:SetAttribute('Condition',math.max(0,condition-loss))
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

-- Cargo / logistics jobs.
local cargoFolder=Instance.new('Folder');cargoFolder.Name='CargoJobs';cargoFolder.Parent=systems
local cargoActive={}
local cargoPickup=part(cargoFolder,'CargoDepot',Vector3.new(30,1,22),CFrame.new(365,.6,430),Color3.fromRGB(210,145,55),Enum.Material.Neon,true)
label(cargoPickup,'CARGO DEPOT')
local cargoPrompt=prompt(cargoPickup,'Ambil Cargo','Nusakarya Logistics')
local cargoDrops={
 {name='Pasar Nusantara',pos=Vector3.new(-310,2,300)},
 {name='Terminal Raya',pos=Vector3.new(390,2,60)},
 {name='Hotel Bahari',pos=Vector3.new(340,2,-220)},
 {name='Sekolah Nusakarya',pos=Vector3.new(-300,2,-80)},
}
for i,d in ipairs(cargoDrops) do local x=part(cargoFolder,'CargoDrop_'..i,Vector3.new(13,.5,13),CFrame.new(d.pos),Color3.fromRGB(235,165,60),Enum.Material.Neon,false);x.Transparency=.55;x:SetAttribute('DropName',d.name) end
cargoPrompt.Triggered:Connect(function(player)
 if cargoActive[player] then toast:FireClient(player,'Cargo aktif: '..cargoActive[player].name) return end
 local b=playerBecak(player);if not b or not b.PrimaryPart or (b.PrimaryPart.Position-cargoPickup.Position).Magnitude>30 then toast:FireClient(player,'Dekatkan Becak E-Bike ke Cargo Depot.') return end
 local d=cargoDrops[math.random(1,#cargoDrops)];cargoActive[player]=d;player:SetAttribute('CargoDestination',d.name);toast:FireClient(player,'Cargo dimuat • antar ke '..d.name..'.')
end)

-- Session challenge and story progression based on persistent trip total.
local joinTrips={}
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
end

-- Lightweight ambient traffic.
local traffic=Instance.new('Folder');traffic.Name='AmbientTraffic';traffic.Parent=systems
local cars={}
for i=1,12 do
 local body=part(traffic,'Traffic_'..i,Vector3.new(6,2.5,10),CFrame.new(-480+(i-1)*80,2,(i%2==0 and 10 or -10)),i%3==0 and Color3.fromRGB(65,105,175) or (i%3==1 and Color3.fromRGB(185,65,55) or Color3.fromRGB(185,185,180)),Enum.Material.Metal,false)
 cars[i]={part=body,t=(i-1)/12,axis=(i<=6 and 'x' or 'z'),dir=i%2==0 and 1 or -1}
end

local accum=0
RunService.Heartbeat:Connect(function(dt)
 accum+=dt;if accum<.08 then return end;local step=accum;accum=0
 for _,c in ipairs(cars) do
  c.t=(c.t+step*.018*c.dir)%1
  if c.axis=='x' then local x=-520+c.t*1040;c.part.CFrame=CFrame.new(x,2,c.dir>0 and 10 or -10)*CFrame.Angles(0,c.dir>0 and math.rad(90) or math.rad(-90),0)
  else local z=-520+c.t*1040;c.part.CFrame=CFrame.new(c.dir>0 and 10 or -10,2,z)*CFrame.Angles(0,c.dir>0 and 0 or math.pi,0) end
 end
 for player,d in pairs(cargoActive) do
  if player.Parent then
   local b=playerBecak(player)
   if b and b.PrimaryPart and (b.PrimaryPart.Position-d.pos).Magnitude<25 then
    cargoActive[player]=nil;player:SetAttribute('CargoDestination',nil)
    if transact(player,35000,45,'cargo') then player:SetAttribute('CargoJobs',(player:GetAttribute('CargoJobs') or 0)+1);toast:FireClient(player,'Cargo terkirim ke '..d.name..' • +Rp35.000 +45 XP') end
   end
  end
 end
 for _,player in ipairs(Players:GetPlayers()) do syncProgress(player) end
end)

local function setupPlayer(player)
 player:SetAttribute('DailyTripGoal',10);player:SetAttribute('CargoJobs',player:GetAttribute('CargoJobs') or 0);player:SetAttribute('Session10Claimed',false)
 task.delay(2,function() if player.Parent then local total=player:GetAttribute('BecakTrips') or 0;joinTrips[player]=total;syncProgress(player) end end)
 task.delay(4,function() if player.Parent then toast:FireClient(player,'Nusakarya aktif • penumpang • cargo • charging • bengkel • cuaca • upgrade') end end)
end
for _,player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player) joinTrips[player]=nil;cargoActive[player]=nil end)

Workspace:SetAttribute('ACC_BecakMasterplanSystems','v1.2')
print('[BECAK E-BIKE] masterplan systems v1.2 ready')
