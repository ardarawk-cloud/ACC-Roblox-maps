-- BECAK E-BIKE Roblox runtime v1.0
-- Standalone namespace. Generates Nusakarya prototype, drivable e-becak, passenger/delivery loop,
-- battery/charging, economy, XP, upgrades, garage and persistent player data.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "BecakEBike"
local VERSION = "1.0.0"
local SAVE = DataStoreService:GetDataStore("BecakEBike_v1")

local DEFAULT = {
    Coins = 25000,
    XP = 0,
    Level = 1,
    Reputation = 5.0,
    Trips = 0,
    Distance = 0,
    MotorLevel = 1,
    BatteryLevel = 1,
    GarageLevel = 1,
}

local remoteFolder = ReplicatedStorage:FindFirstChild("BecakEBikeRemotes") or Instance.new("Folder")
remoteFolder.Name = "BecakEBikeRemotes"
remoteFolder.Parent = ReplicatedStorage
local stateEvent = remoteFolder:FindFirstChild("State") or Instance.new("RemoteEvent")
stateEvent.Name = "State"
stateEvent.Parent = remoteFolder
local toastEvent = remoteFolder:FindFirstChild("Toast") or Instance.new("RemoteEvent")
toastEvent.Name = "Toast"
toastEvent.Parent = remoteFolder

local old = Workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end
local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = Workspace

local world = Instance.new("Folder") world.Name = "Nusakarya" world.Parent = root
local vehicles = Instance.new("Folder") vehicles.Name = "Vehicles" vehicles.Parent = root
local passengers = Instance.new("Folder") passengers.Name = "Passengers" passengers.Parent = root
local interactives = Instance.new("Folder") interactives.Name = "Interactives" interactives.Parent = root

local playerData = {}
local activeTrips = {}
local playerVehicles = {}

local function copy(t)
    local o = {}
    for k,v in pairs(t) do o[k] = v end
    return o
end

local function part(parent, name, size, cf, color, material, collide)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.CanCollide = collide ~= false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color or Color3.fromRGB(180,180,180)
    p.Parent = parent
    return p
end

local function labelOn(partObj, text)
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(150, 38)
    gui.StudsOffset = Vector3.new(0, 4, 0)
    gui.AlwaysOnTop = false
    gui.MaxDistance = 48
    gui.LightInfluence = 0.3
    gui.Parent = partObj
    local t = Instance.new("TextLabel")
    t.Size = UDim2.fromScale(1,1)
    t.BackgroundTransparency = 0.18
    t.BackgroundColor3 = Color3.fromRGB(16,20,24)
    t.TextColor3 = Color3.new(1,1,1)
    t.TextScaled = false
    t.TextSize = 12
    t.TextWrapped = true
    t.Font = Enum.Font.GothamBold
    t.Text = text
    t.Parent = gui
    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,8)
    corner.Parent=t
end

local function promptOn(parent, action, objectText, hold)
    local pr = Instance.new("ProximityPrompt")
    pr.ActionText = action
    pr.ObjectText = objectText
    pr.HoldDuration = hold or 0.25
    pr.MaxActivationDistance = 12
    pr.RequiresLineOfSight = false
    pr.Parent = parent
    return pr
end

-- Lighting / atmosphere
Lighting.Brightness = 2.3
Lighting.ClockTime = 8.0
Lighting.GlobalShadows = true
Lighting.OutdoorAmbient = Color3.fromRGB(135,145,155)
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Density = 0.22
atmosphere.Haze = 1.2
atmosphere.Color = Color3.fromRGB(210,225,235)
atmosphere.Parent = Lighting

-- Base terrain using primitives, optimized for mobile.
part(world,"Ground",Vector3.new(1500,6,1500),CFrame.new(0,-3,0),Color3.fromRGB(72,116,68),Enum.Material.Grass,true)

local function road(name, size, pos)
    local r = part(world,name,size,CFrame.new(pos.X,0.15,pos.Z),Color3.fromRGB(48,50,53),Enum.Material.Asphalt,true)
    if size.X > size.Z then
        for x = -size.X/2+30, size.X/2-30, 40 do
            part(world,name.."_Mark",Vector3.new(16,0.08,0.5),CFrame.new(pos.X+x,0.52,pos.Z),Color3.fromRGB(235,214,95),Enum.Material.Neon,false)
        end
    else
        for z = -size.Z/2+30, size.Z/2-30, 40 do
            part(world,name.."_Mark",Vector3.new(0.5,0.08,16),CFrame.new(pos.X,0.52,pos.Z+z),Color3.fromRGB(235,214,95),Enum.Material.Neon,false)
        end
    end
    return r
end

road("Jalan_Merdeka",Vector3.new(1100,0.6,42),Vector3.new(0,0,0))
road("Jalan_Nusantara",Vector3.new(42,0.6,1100),Vector3.new(0,0,0))
road("Jalan_Pasar",Vector3.new(750,0.6,34),Vector3.new(-170,0,300))
road("Jalan_Pantai",Vector3.new(750,0.6,34),Vector3.new(170,0,-300))
road("Jalan_Sekolah",Vector3.new(34,0.6,700),Vector3.new(-300,0,-150))
road("Jalan_Industri",Vector3.new(34,0.6,700),Vector3.new(300,0,150))

local districts = {
    {"KAMPUNG HARMONI", Vector3.new(-380,2,-360), Color3.fromRGB(70,155,90)},
    {"PASAR NUSANTARA", Vector3.new(-380,2,330), Color3.fromRGB(220,145,60)},
    {"PUSAT KOTA", Vector3.new(210,2,170), Color3.fromRGB(80,125,190)},
    {"KAWASAN SEKOLAH", Vector3.new(-330,2,-50), Color3.fromRGB(225,195,70)},
    {"PANTAI BAHARI", Vector3.new(350,2,-360), Color3.fromRGB(65,170,205)},
    {"TERMINAL RAYA", Vector3.new(430,2,0), Color3.fromRGB(120,105,150)},
    {"PERBUKITAN ASRI", Vector3.new(0,2,470), Color3.fromRGB(90,130,80)},
    {"KAWASAN INDUSTRI", Vector3.new(360,2,360), Color3.fromRGB(120,120,125)},
}
for _,d in ipairs(districts) do
    local marker = part(world,"District_"..d[1],Vector3.new(18,1,18),CFrame.new(d[2]),d[3],Enum.Material.Neon,false)
    marker.Transparency = 0.65
    labelOn(marker,d[1])
end

-- Building generator
local function building(name, pos, size, color, sign)
    local m = Instance.new("Model") m.Name=name m.Parent=world
    local body = part(m,"Body",size,CFrame.new(pos.X,size.Y/2,pos.Z),color,Enum.Material.Concrete,true)
    part(m,"Roof",Vector3.new(size.X+2,1,size.Z+2),body.CFrame*CFrame.new(0,size.Y/2+0.5,0),Color3.fromRGB(55,58,62),Enum.Material.Metal,true)
    if sign then labelOn(body,sign) end
    return m
end

for i=1,18 do
    local x = -520 + ((i-1)%6)*55
    local z = -500 + math.floor((i-1)/6)*70
    building("Rumah_"..i,Vector3.new(x,0,z),Vector3.new(34,22,30),Color3.fromRGB(220-(i%3)*12,190,150),nil)
end
for i=1,10 do
    building("RukoPasar_"..i,Vector3.new(-520+(i-1)*48,0,380),Vector3.new(38,24,34),Color3.fromRGB(215,165+(i%2)*20,105),i==5 and "PASAR NUSANTARA" or nil)
end
building("Sekolah",Vector3.new(-420,0,-70),Vector3.new(120,38,72),Color3.fromRGB(230,225,185),"SEKOLAH NUSAKARYA")
building("RumahSakit",Vector3.new(150,0,250),Vector3.new(110,52,72),Color3.fromRGB(225,235,235),"RUMAH SAKIT")
building("Mall",Vector3.new(240,0,80),Vector3.new(130,55,95),Color3.fromRGB(180,190,205),"NUSAKARYA MALL")
building("Hotel",Vector3.new(380,0,-230),Vector3.new(85,70,65),Color3.fromRGB(205,190,165),"HOTEL BAHARI")
building("Terminal",Vector3.new(470,0,80),Vector3.new(135,28,90),Color3.fromRGB(145,150,155),"TERMINAL RAYA")
building("Factory",Vector3.new(420,0,410),Vector3.new(145,42,110),Color3.fromRGB(130,135,140),"NUSAKARYA LOGISTICS")

-- Beach strip
part(world,"Sand",Vector3.new(700,2,170),CFrame.new(230,-1,-560),Color3.fromRGB(224,204,145),Enum.Material.Sand,true)
part(world,"Sea",Vector3.new(900,2,250),CFrame.new(230,-1,-760),Color3.fromRGB(50,145,185),Enum.Material.SmoothPlastic,true).Transparency=0.15

local spawn = Instance.new("SpawnLocation")
spawn.Name="BecakSpawn"
spawn.Size=Vector3.new(12,1,12)
spawn.CFrame=CFrame.new(-80,1,-70)
spawn.Anchored=true
spawn.Neutral=true
spawn.Color=Color3.fromRGB(65,190,235)
spawn.Material=Enum.Material.Neon
spawn.Parent=world
labelOn(spawn,"BECAK E-BIKE HQ")

-- Interactive landmarks
local chargePad = part(interactives,"ChargingStation",Vector3.new(28,1,20),CFrame.new(-45,0.6,-85),Color3.fromRGB(60,190,220),Enum.Material.Neon,true)
labelOn(chargePad,"CHARGING")
local chargePrompt = promptOn(chargePad,"Charge Battery","E-Bike Charger",0.6)
local garagePad = part(interactives,"Garage",Vector3.new(32,1,22),CFrame.new(-115,0.6,-85),Color3.fromRGB(235,170,55),Enum.Material.Neon,true)
labelOn(garagePad,"GARASI PAK JAYA")
local garagePrompt = promptOn(garagePad,"Upgrade","Motor / Battery",0.6)

local destinations = {
    {name="Pasar Nusantara",pos=Vector3.new(-310,2,300)},
    {name="Sekolah Nusakarya",pos=Vector3.new(-300,2,-80)},
    {name="Rumah Sakit",pos=Vector3.new(100,2,250)},
    {name="Nusakarya Mall",pos=Vector3.new(170,2,80)},
    {name="Terminal Raya",pos=Vector3.new(390,2,60)},
    {name="Pantai Bahari",pos=Vector3.new(260,2,-350)},
    {name="Hotel Bahari",pos=Vector3.new(340,2,-220)},
    {name="Kawasan Industri",pos=Vector3.new(310,2,390)},
}
for _,d in ipairs(destinations) do
    local p=part(interactives,"Destination_"..d.name,Vector3.new(14,0.5,14),CFrame.new(d.pos),Color3.fromRGB(70,220,135),Enum.Material.Neon,false)
    p.Transparency=0.7
    p:SetAttribute("DestinationName",d.name)
end

local function levelFromXP(xp)
    return math.max(1, math.floor(math.sqrt(xp/100))+1)
end

local function batteryCapacity(data)
    return 100 + (data.BatteryLevel-1)*25
end

local function pushState(player)
    local d=playerData[player]
    if not d then return end
    local v=playerVehicles[player]
    local battery=v and v:GetAttribute("Battery") or batteryCapacity(d)
    local trip=activeTrips[player]
    stateEvent:FireClient(player,{
        coins=d.Coins,xp=d.XP,level=d.Level,reputation=d.Reputation,trips=d.Trips,
        motorLevel=d.MotorLevel,batteryLevel=d.BatteryLevel,battery=battery,
        batteryMax=batteryCapacity(d),trip=trip and trip.destination or nil,
        version=VERSION,
    })
end

local function toast(player,text)
    toastEvent:FireClient(player,text)
end

local function savePlayer(player)
    local d=playerData[player]
    if not d then return end
    pcall(function() SAVE:SetAsync("u_"..player.UserId,d) end)
end

-- Drivable e-becak. VehicleSeat provides native desktop/mobile controls; server applies movement.
local function createBecak(player)
    if playerVehicles[player] then playerVehicles[player]:Destroy() end
    local d=playerData[player]
    local m=Instance.new("Model") m.Name="Becak_"..player.UserId m.Parent=vehicles
    m:SetAttribute("OwnerUserId",player.UserId)
    m:SetAttribute("Battery",batteryCapacity(d))
    m:SetAttribute("BatteryMax",batteryCapacity(d))
    local chassis=part(m,"Chassis",Vector3.new(6,1.2,10),CFrame.new(-80,2.6,-40),Color3.fromRGB(42,105,70),Enum.Material.Metal,true)
    chassis.Anchored=false
    chassis.CustomPhysicalProperties=PhysicalProperties.new(1.4,0.55,0.1,1,1)
    m.PrimaryPart=chassis
    local seat=Instance.new("VehicleSeat")
    seat.Name="DriverSeat" seat.Size=Vector3.new(3,1,3) seat.CFrame=chassis.CFrame*CFrame.new(0,1.4,2)
    seat.Color=Color3.fromRGB(40,45,48) seat.MaxSpeed=0 seat.Torque=0 seat.TurnSpeed=0 seat.Parent=m
    local weld=Instance.new("WeldConstraint") weld.Part0=chassis weld.Part1=seat weld.Parent=chassis
    local cabin=part(m,"PassengerCabin",Vector3.new(5.8,3.4,4.5),chassis.CFrame*CFrame.new(0,2.2,-2.1),Color3.fromRGB(55,135,85),Enum.Material.SmoothPlastic,false)
    cabin.Anchored=false
    local wc=Instance.new("WeldConstraint") wc.Part0=chassis wc.Part1=cabin wc.Parent=chassis
    local canopy=part(m,"Canopy",Vector3.new(6.2,0.5,5.0),chassis.CFrame*CFrame.new(0,4.2,-2.1),Color3.fromRGB(235,220,170),Enum.Material.Fabric,false)
    canopy.Anchored=false local wcan=Instance.new("WeldConstraint") wcan.Part0=chassis wcan.Part1=canopy wcan.Parent=chassis
    for _,x in ipairs({-2.7,2.7}) do
        local wheel=part(m,"FrontWheel",Vector3.new(1.1,4.2,4.2),chassis.CFrame*CFrame.new(x,-0.5,-3.1)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(24,25,26),Enum.Material.SmoothPlastic,false)
        wheel.Shape=Enum.PartType.Cylinder wheel.Anchored=false local ww=Instance.new("WeldConstraint") ww.Part0=chassis ww.Part1=wheel ww.Parent=chassis
    end
    local back=part(m,"RearWheel",Vector3.new(1.1,4.5,4.5),chassis.CFrame*CFrame.new(0,-0.5,3.5)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(24,25,26),Enum.Material.SmoothPlastic,false)
    back.Shape=Enum.PartType.Cylinder back.Anchored=false local wb=Instance.new("WeldConstraint") wb.Part0=chassis wb.Part1=back wb.Parent=chassis
    local vel=Instance.new("BodyVelocity") vel.MaxForce=Vector3.new(80000,0,80000) vel.P=6000 vel.Velocity=Vector3.zero vel.Parent=chassis
    local gyro=Instance.new("BodyGyro") gyro.MaxTorque=Vector3.new(0,150000,0) gyro.P=9000 gyro.D=600 gyro.CFrame=chassis.CFrame gyro.Parent=chassis
    playerVehicles[player]=m
    return m,seat,chassis,vel,gyro
end

local vehicleControllers={}
local function registerVehicle(player)
    local m,seat,chassis,vel,gyro=createBecak(player)
    vehicleControllers[player]={model=m,seat=seat,chassis=chassis,vel=vel,gyro=gyro,heading=math.rad(180)}
end

-- Passenger nodes
local passengerSpawns={
    Vector3.new(-250,2,25),Vector3.new(-370,2,285),Vector3.new(-295,2,-130),Vector3.new(120,2,25),
    Vector3.new(250,2,210),Vector3.new(410,2,45),Vector3.new(280,2,-315),Vector3.new(-70,2,330),
}
local passengerNames={"Pak Budi","Bu Sari","Made","Rina","Pak Joko","Dewi","Agus","Komang"}
local function createPassenger(index,pos)
    local node=part(passengers,"Passenger_"..index,Vector3.new(3,5,3),CFrame.new(pos),Color3.fromRGB(245,185-(index%3)*20,95+(index%4)*25),Enum.Material.SmoothPlastic,false)
    node.Shape=Enum.PartType.Cylinder
    node.Transparency=0.82
    labelOn(node,passengerNames[index])
    local pr=promptOn(node,"Pick Up",passengerNames[index],0.2)
    pr.Triggered:Connect(function(player)
        if activeTrips[player] then toast(player,"Selesaikan perjalanan aktif dulu.") return end
        local v=playerVehicles[player]
        if not v or not v.PrimaryPart or (v.PrimaryPart.Position-node.Position).Magnitude>28 then
            toast(player,"Dekatkan Becak E-Bike ke penumpang.") return
        end
        local dest=destinations[math.random(1,#destinations)]
        activeTrips[player]={passenger=passengerNames[index],destination=dest.name,pos=dest.pos,start=v.PrimaryPart.Position}
        node.Transparency=1 pr.Enabled=false
        toast(player,passengerNames[index].." naik. Antar ke "..dest.name..".")
        pushState(player)
        task.delay(18,function() if node.Parent then node.Transparency=0.82 pr.Enabled=true end end)
    end)
end
for i,pos in ipairs(passengerSpawns) do createPassenger(i,pos) end

-- Charging / upgrades
chargePrompt.Triggered:Connect(function(player)
    local d=playerData[player] local v=playerVehicles[player]
    if not d or not v then return end
    local max=batteryCapacity(d) local current=v:GetAttribute("Battery") or max
    local missing=math.max(0,max-current)
    local cost=math.ceil(missing*80)
    if missing<1 then toast(player,"Baterai sudah penuh.") return end
    if d.Coins<cost then toast(player,"Saldo tidak cukup untuk charging.") return end
    d.Coins-=cost v:SetAttribute("Battery",max)
    toast(player,"Charging selesai. Biaya Rp"..cost)
    pushState(player)
end)

garagePrompt.Triggered:Connect(function(player)
    local d=playerData[player] if not d then return end
    local motorCost=100000*d.MotorLevel
    local batteryCost=150000*d.BatteryLevel
    if d.MotorLevel<=d.BatteryLevel and d.MotorLevel<4 then
        if d.Coins<motorCost then toast(player,"Upgrade motor butuh Rp"..motorCost) return end
        d.Coins-=motorCost d.MotorLevel+=1 toast(player,"Motor naik ke level "..d.MotorLevel)
    elseif d.BatteryLevel<4 then
        if d.Coins<batteryCost then toast(player,"Upgrade baterai butuh Rp"..batteryCost) return end
        d.Coins-=batteryCost d.BatteryLevel+=1
        local v=playerVehicles[player] if v then v:SetAttribute("BatteryMax",batteryCapacity(d)) v:SetAttribute("Battery",batteryCapacity(d)) end
        toast(player,"Baterai naik ke level "..d.BatteryLevel)
    else
        toast(player,"Upgrade prototype sudah maksimal.")
    end
    pushState(player)
end)

-- Vehicle physics / battery / trip completion
local tickAcc=0
RunService.Heartbeat:Connect(function(dt)
    tickAcc+=dt
    for player,c in pairs(vehicleControllers) do
        if player.Parent and c.model.Parent and c.chassis.Parent then
            local d=playerData[player]
            local battery=c.model:GetAttribute("Battery") or 0
            local occupied=c.seat.Occupant and Players:GetPlayerFromCharacter(c.seat.Occupant.Parent)==player
            local throttle=occupied and c.seat.ThrottleFloat or 0
            local steer=occupied and c.seat.SteerFloat or 0
            local speedBase=32+(d and (d.MotorLevel-1)*5 or 0)
            if battery<=0 then throttle=0 end
            local speed=throttle>=0 and throttle*speedBase or throttle*12
            c.heading += -steer * dt * (1.65 + math.abs(speed)/70)
            local look=Vector3.new(math.sin(c.heading),0,math.cos(c.heading))
            c.vel.Velocity=look*speed
            c.gyro.CFrame=CFrame.lookAt(c.chassis.Position,c.chassis.Position+look)
            if occupied and math.abs(speed)>1 then
                local drain=dt*math.abs(speed)*0.012
                c.model:SetAttribute("Battery",math.max(0,battery-drain))
                if d then d.Distance += dt*math.abs(speed)/280 end
            end
            if c.chassis.Position.Y < -20 then
                c.chassis.CFrame=CFrame.new(-80,4,-40)
                c.vel.Velocity=Vector3.zero
            end
            local trip=activeTrips[player]
            if trip and (c.chassis.Position-trip.pos).Magnitude<26 then
                local dist=(trip.start-c.chassis.Position).Magnitude
                local reward=math.floor(5000+dist*18)
                d.Coins+=reward d.XP+=math.floor(20+dist/60) d.Trips+=1 d.Level=levelFromXP(d.XP)
                activeTrips[player]=nil
                toast(player,"Trip selesai! +Rp"..reward.." • XP bertambah")
                pushState(player)
            end
        end
    end
    if tickAcc>1 then
        tickAcc=0
        for p in pairs(playerData) do pushState(p) end
        -- 24-minute day cycle
        Lighting.ClockTime=(Lighting.ClockTime+0.0167)%24
    end
end)

Players.PlayerAdded:Connect(function(player)
    local d=copy(DEFAULT)
    local ok,saved=pcall(function() return SAVE:GetAsync("u_"..player.UserId) end)
    if ok and type(saved)=="table" then for k,v in pairs(DEFAULT) do if saved[k]~=nil then d[k]=saved[k] end end end
    playerData[player]=d
    local stats=Instance.new("Folder") stats.Name="leaderstats" stats.Parent=player
    local coins=Instance.new("IntValue") coins.Name="Rupiah" coins.Value=d.Coins coins.Parent=stats
    local level=Instance.new("IntValue") level.Name="Level" level.Value=d.Level level.Parent=stats
    registerVehicle(player)
    task.delay(2,function() if player.Parent then toast(player,"Selamat datang di Nusakarya. Naik Becak E-Bike dan cari penumpang!") pushState(player) end end)
    task.spawn(function()
        while player.Parent do
            coins.Value=d.Coins level.Value=d.Level task.wait(2)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    savePlayer(player)
    if playerVehicles[player] then playerVehicles[player]:Destroy() end
    playerVehicles[player]=nil vehicleControllers[player]=nil activeTrips[player]=nil playerData[player]=nil
end)

game:BindToClose(function()
    for p in pairs(playerData) do savePlayer(p) end
end)

print("[BECAK E-BIKE] runtime v"..VERSION.." initialized | Universe 10745325613 | Place 80994730522893")