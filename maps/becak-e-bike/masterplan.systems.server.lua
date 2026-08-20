-- BECAK E-BIKE — masterplan systems v1.1
-- Adds weather, cargo jobs, repair, daily goals, story progression, simple ambient traffic.
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
if not world or not vehicles or not interactives or not remotes then return end
local toast=remotes:WaitForChild('Toast')

local systems=Instance.new('Folder') systems.Name='MasterplanSystems' systems.Parent=root
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
local function addMoney(player,amount)
 local stats=player:FindFirstChild('leaderstats');local v=stats and stats:FindFirstChild('Rupiah');if v then v.Value+=amount end
 player:SetAttribute('SessionBonus',(player:GetAttribute('SessionBonus') or 0)+amount)
end

-- Weather state. Server drives atmosphere/light; client can read Workspace attribute.
local weatherCycle={'CERAH','MENDUNG','HUJAN','CERAH','CERAH','HUJAN'}
local weatherIndex=1
local function setWeather(name)
 Workspace:SetAttribute('BecakWeather',name)
 if name=='CERAH' then Lighting.Brightness=2.6;Lighting.ExposureCompensation=.05
 elseif name=='MENDUNG' then Lighting.Brightness=1.65;Lighting.ExposureCompensation=-.15
 elseif name=='HUJAN' then Lighting.Brightness=1.25;Lighting.ExposureCompensation=-.3 end
 local a=Lighting:FindFirstChildOfClass('Atmosphere');if a then a.Density=name=='HUJAN' and .38 or (name=='MENDUNG' and .3 or .2);a.Haze=name=='HUJAN' and 2.4 or 1.1 end
 for _,p in ipairs(Players:GetPlayers()) do toast:FireClient(p,'Cuaca Nusakarya: '..name) end
end
setWeather(weatherCycle[weatherIndex])
task.spawn(function() while root.Parent do task.wait(180);weatherIndex=weatherIndex%#weatherCycle+1;setWeather(weatherCycle[weatherIndex]) end end)

-- Repair shop / vehicle condition
local repair=part(interactives,'RepairShop',Vector3.new(28,1,20),CFrame.new(-155,.6,-85),Color3.fromRGB(205,85,65),Enum.Material.Neon,true)
label(repair,'BENGKEL • SERVIS')
local repairPrompt=prompt(repair,'Service Becak','Bengkel Pak Jaya')
repairPrompt.Triggered:Connect(function(player)
 local b=playerBecak(player);if not b then return end
 local hp=b:GetAttribute('Condition') or 100
 if hp>=99 then toast:FireClient(player,'Kondisi becak masih prima.') return end
 local cost=math.ceil((100-hp)*500)
 local stats=player:FindFirstChild('leaderstats');local cash=stats and stats:FindFirstChild('Rupiah')
 if not cash or cash.Value<cost then toast:FireClient(player,'Biaya servis Rp'..cost..'. Saldo belum cukup.') return end
 cash.Value-=cost;b:SetAttribute('Condition',100);toast:FireClient(player,'Servis selesai. Kondisi 100%.')
end)

-- Cargo jobs
local cargoFolder=Instance.new('Folder') cargoFolder.Name='CargoJobs' cargoFolder.Parent=systems
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
local dropParts={}
for i,d in ipairs(cargoDrops) do local x=part(cargoFolder,'CargoDrop_'..i,Vector3.new(13,.5,13),CFrame.new(d.pos),Color3.fromRGB(235,165,60),Enum.Material.Neon,false);x.Transparency=.55;x:SetAttribute('DropName',d.name);dropParts[i]=x end
cargoPrompt.Triggered:Connect(function(player)
 if cargoActive[player] then toast:FireClient(player,'Cargo aktif: '..cargoActive[player].name) return end
 local b=playerBecak(player);if not b or not b.PrimaryPart or (b.PrimaryPart.Position-cargoPickup.Position).Magnitude>30 then toast:FireClient(player,'Dekatkan becak ke Cargo Depot.') return end
 local d=cargoDrops[math.random(1,#cargoDrops)];cargoActive[player]=d;player:SetAttribute('CargoDestination',d.name);toast:FireClient(player,'Cargo dimuat. Antar ke '..d.name..'.')
end)

-- Daily/session mission tracker, story chapter derived from completed trips.
local function syncProgress(player)
 local stats=player:FindFirstChild('leaderstats');local tripCount=player:GetAttribute('BecakTrips') or 0
 local chapter=1
 if tripCount>=10 then chapter=2 end;if tripCount>=25 then chapter=3 end;if tripCount>=50 then chapter=4 end;if tripCount>=100 then chapter=5 end
 player:SetAttribute('StoryChapter',chapter)
 if tripCount>=10 and not player:GetAttribute('Daily10Claimed') then player:SetAttribute('Daily10Claimed',true);addMoney(player,50000);toast:FireClient(player,'Misi harian selesai: 10 perjalanan • Bonus Rp50.000') end
end

-- Ambient traffic: visual low-cost vehicles on dedicated loops.
local traffic=Instance.new('Folder') traffic.Name='AmbientTraffic' traffic.Parent=systems
local cars={}
for i=1,12 do
 local body=part(traffic,'Traffic_'..i,Vector3.new(6,2.5,10),CFrame.new(-480+(i-1)*80,2,(i%2==0 and 10 or -10)),i%3==0 and Color3.fromRGB(65,105,175) or (i%3==1 and Color3.fromRGB(185,65,55) or Color3.fromRGB(185,185,180)),Enum.Material.Metal,false)
 cars[i]={part=body,t=(i-1)/12,axis=(i<=6 and 'x' or 'z'),dir=i%2==0 and 1 or -1}
end

local accum=0
RunService.Heartbeat:Connect(function(dt)
 accum+=dt
 if accum<.08 then return end
 local step=accum;accum=0
 for _,c in ipairs(cars) do
  c.t=(c.t+step*.018*c.dir)%1
  if c.axis=='x' then local x=-520+c.t*1040;c.part.CFrame=CFrame.new(x,2,c.dir>0 and 10 or -10)*CFrame.Angles(0,c.dir>0 and math.rad(90) or math.rad(-90),0)
  else local z=-520+c.t*1040;c.part.CFrame=CFrame.new(c.dir>0 and 10 or -10,2,z)*CFrame.Angles(0,c.dir>0 and 0 or math.pi,0) end
 end
 for player,d in pairs(cargoActive) do
  if player.Parent then
   local b=playerBecak(player)
   if b and b.PrimaryPart and (b.PrimaryPart.Position-d.pos).Magnitude<25 then
    cargoActive[player]=nil;player:SetAttribute('CargoDestination',nil);addMoney(player,35000);player:SetAttribute('CargoJobs',(player:GetAttribute('CargoJobs') or 0)+1);toast:FireClient(player,'Cargo terkirim ke '..d.name..' • +Rp35.000')
   end
  end
 end
 for _,player in ipairs(Players:GetPlayers()) do
  local stats=player:FindFirstChild('leaderstats');local trips=stats and stats:FindFirstChild('Trips')
  if trips then player:SetAttribute('BecakTrips',trips.Value) end
  syncProgress(player)
 end
end)

Players.PlayerAdded:Connect(function(player)
 player:SetAttribute('DailyTripGoal',10);player:SetAttribute('StoryChapter',1);player:SetAttribute('CargoJobs',0)
 task.delay(4,function() if player.Parent then toast:FireClient(player,'Masterplan aktif: penumpang • cargo • charging • bengkel • cuaca • upgrade') end end)
end)

Workspace:SetAttribute('ACC_BecakMasterplanSystems','v1.1')
print('[BECAK E-BIKE] masterplan systems v1.1 ready')
