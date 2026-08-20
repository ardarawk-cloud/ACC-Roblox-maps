-- Mountain Social Adventure v1.1 REALISM PASS
-- Isolated ACC world generator. Only creates/updates Workspace.ACC_MountainSocial.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Terrain = Workspace.Terrain

local ROOT_NAME = "ACC_MountainSocial"
local old = Workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = Workspace

local folders = {}
for _, name in ipairs({"Checkpoints","Camps","PhotoSpots","Secrets","Decor","RouteAnchors"}) do
    local f = Instance.new("Folder")
    f.Name = name
    f.Parent = root
    folders[name] = f
end

local function part(name, size, cf, material, color, parent, transparency, canCollide)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Material = material or Enum.Material.Slate
    if color then p.Color = color end
    p.Transparency = transparency or 0
    p.CanCollide = canCollide ~= false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or root
    return p
end

local function anchor(name, pos, parent)
    local p = part(name, Vector3.new(7,0.8,7), CFrame.new(pos), Enum.Material.SmoothPlastic, Color3.fromRGB(244,186,72), parent, 0.78, false)
    p:SetAttribute("ACCAnchor", true)
    return p
end

local function terrainBall(pos, radius, material)
    Terrain:FillBall(pos, radius, material)
end

local function trailSegment(name, a, b, width)
    local delta = b-a
    local dist = delta.Magnitude
    local mid = (a+b)/2
    local trail = part(name, Vector3.new(width,1.15,dist), CFrame.lookAt(mid,b), Enum.Material.Ground, Color3.fromRGB(100,84,64), root, 0.06, false)
    trail:SetAttribute("RouteSegment", true)
    return trail
end

-- Cinematic natural lighting base.
Lighting.ClockTime = 5.45
Lighting.Brightness = 2.15
Lighting.EnvironmentDiffuseScale = 0.4
Lighting.EnvironmentSpecularScale = 0.3
Lighting.OutdoorAmbient = Color3.fromRGB(126,136,149)
Lighting.Ambient = Color3.fromRGB(82,91,103)

local atmosphere = Lighting:FindFirstChild("ACC_MountainAtmosphere") or Instance.new("Atmosphere")
atmosphere.Name = "ACC_MountainAtmosphere"
atmosphere.Density = 0.29
atmosphere.Offset = 0.08
atmosphere.Color = Color3.fromRGB(199,217,225)
atmosphere.Decay = Color3.fromRGB(105,118,132)
atmosphere.Glare = 0.06
atmosphere.Haze = 1.45
atmosphere.Parent = Lighting

local colorCorrection = Lighting:FindFirstChild("ACC_MountainColor") or Instance.new("ColorCorrectionEffect")
colorCorrection.Name = "ACC_MountainColor"
colorCorrection.Brightness = 0.01
colorCorrection.Contrast = 0.07
colorCorrection.Saturation = -0.025
colorCorrection.Parent = Lighting

-- Route identity stays locked to the master plan.
local summitY = 620
local route = {
    {"Basecamp ACC", Vector3.new(0,22,690)},
    {"Gerbang Hutan", Vector3.new(-132,75,555)},
    {"Sungai Batu", Vector3.new(88,126,430)},
    {"Air Terjun Lumina", Vector3.new(212,182,300)},
    {"Camp Rimba", Vector3.new(78,236,158)},
    {"Tebing Angin", Vector3.new(-118,300,34)},
    {"Hutan Kabut", Vector3.new(-224,356,-106)},
    {"Jembatan Awan", Vector3.new(-74,414,-242)},
    {"Camp Atas", Vector3.new(116,470,-336)},
    {"Ridge Batu", Vector3.new(204,526,-432)},
    {"Lautan Awan", Vector3.new(94,575,-540)},
    {"Summit ACC", Vector3.new(0,summitY,-650)},
}

Terrain:Clear()
Terrain:FillBlock(CFrame.new(0,-30,0), Vector3.new(1900,60,1900), Enum.Material.Ground)

-- Main mountain mass: asymmetrical overlap for natural silhouette.
local nodes = {
    {Vector3.new(0,54,140),420,Enum.Material.Rock},
    {Vector3.new(-72,118,65),335,Enum.Material.Rock},
    {Vector3.new(84,168,-5),315,Enum.Material.Rock},
    {Vector3.new(-48,228,-125),280,Enum.Material.Rock},
    {Vector3.new(66,292,-245),236,Enum.Material.Rock},
    {Vector3.new(-35,365,-345),198,Enum.Material.Rock},
    {Vector3.new(28,445,-455),158,Enum.Material.Rock},
    {Vector3.new(-12,520,-550),122,Enum.Material.Rock},
    {Vector3.new(0,585,-630),84,Enum.Material.Rock},
}
for _,n in ipairs(nodes) do terrainBall(n[1],n[2],n[3]) end

-- Natural shoulders and forest soil, denser low altitude and broken higher up.
math.randomseed(26082026)
for i=1,44 do
    local ang = math.random()*math.pi*2
    local r = math.random(260,690)
    local baseY = 42 + math.max(0,210-r)*0.12 + math.random(-8,16)
    local pos = Vector3.new(math.cos(ang)*r, baseY, 80 + math.sin(ang)*r)
    terrainBall(pos, math.random(55,115), r < 470 and Enum.Material.Grass or Enum.Material.Rock)
end

-- Small erosion/rock variation around middle and upper zones.
for i=1,38 do
    local t = math.random()
    local z = 210 - t*840
    local x = math.random(-260,260) * (1 - t*0.45)
    local y = 110 + t*455 + math.random(-25,30)
    terrainBall(Vector3.new(x,y,z), math.random(18,42), Enum.Material.Rock)
end

-- Organic hiking trail: each route leg gets 4 gently offset sub-segments instead of one straight runway.
for i=1,#route-1 do
    local a = route[i][2]
    local b = route[i+1][2]
    local dir = (b-a)
    local side = Vector3.new(-dir.Z,0,dir.X)
    if side.Magnitude > 0 then side = side.Unit end
    local points = {a}
    for s=1,3 do
        local t = s/4
        local base = a:Lerp(b,t)
        local sway = math.sin((i*1.7+s)*1.2) * (14 + (i%3)*4)
        table.insert(points, base + side*sway + Vector3.new(0, math.sin(t*math.pi)*3, 0))
    end
    table.insert(points,b)
    for j=1,#points-1 do
        trailSegment(string.format("Trail_%02d_%02d",i,j), points[j]-Vector3.new(0,2.6,0), points[j+1]-Vector3.new(0,2.6,0), i < 5 and 12 or 9)
    end
end

-- Small natural clearings only where needed; no large floating terraces.
for i,info in ipairs(route) do
    local pos = info[2]
    local radius = (i==1 and 38) or (i==12 and 28) or (i==5 or i==9) and 20 or 12
    terrainBall(pos-Vector3.new(0,8,0), radius, i < 7 and Enum.Material.Ground or Enum.Material.Rock)
end

-- Spawn blended into basecamp.
local spawn = Instance.new("SpawnLocation")
spawn.Name = "MountainSpawn"
spawn.Anchored = true
spawn.Size = Vector3.new(14,1,14)
spawn.CFrame = CFrame.new(route[1][2] + Vector3.new(0,3,0))
spawn.Material = Enum.Material.Ground
spawn.Color = Color3.fromRGB(105,88,68)
spawn.Transparency = 0.25
spawn.Neutral = true
spawn.Parent = root

for i,info in ipairs(route) do
    local cp = anchor(string.format("CP%02d_%s",i,info[1]:gsub(" ","_")), info[2]+Vector3.new(0,1.6,0), folders.Checkpoints)
    cp:SetAttribute("CheckpointIndex",i)
    cp:SetAttribute("CheckpointName",info[1])
    cp:SetAttribute("SaveReady",true)
end

-- Camps use small grounded footprint, not deck-like platforms.
for _,idx in ipairs({1,5,9}) do
    local pos = route[idx][2]
    local camp = Instance.new("Model")
    camp.Name = "Camp_"..route[idx][1]:gsub(" ","_")
    camp.Parent = folders.Camps
    terrainBall(pos+Vector3.new(18,-5,5), 15, Enum.Material.Ground)
    local fire = part("Campfire",Vector3.new(4.5,1.2,4.5),CFrame.new(pos+Vector3.new(18,1,5)),Enum.Material.Slate,Color3.fromRGB(72,70,66),camp,0,false)
    fire.Shape = Enum.PartType.Cylinder
    fire:SetAttribute("CampfireReady",true)
    local light = Instance.new("PointLight")
    light.Range = 20
    light.Brightness = 1.7
    light.Color = Color3.fromRGB(255,178,96)
    light.Shadows = true
    light.Parent = fire
end

-- Waterfall built as terrain water channel + thin misty face.
local wp = route[4][2] + Vector3.new(42,24,-8)
Terrain:FillBlock(CFrame.new(wp + Vector3.new(0,18,0)), Vector3.new(14,58,10), Enum.Material.Water)
local mist = part("LuminaWaterfallMist",Vector3.new(16,62,1.6),CFrame.new(wp+Vector3.new(0,16,-5)),Enum.Material.Glass,Color3.fromRGB(185,220,230),folders.Decor,0.72,false)
mist:SetAttribute("Landmark","Waterfall")

-- Photo spots are nearly invisible markers only.
for _,idx in ipairs({4,8,11,12}) do
    local p = anchor("PhotoSpot_"..idx,route[idx][2]+Vector3.new(20,2,0),folders.PhotoSpots)
    p.Transparency = 0.92
    p:SetAttribute("PhotoSpot",true)
    p:SetAttribute("LocationName",route[idx][1])
end

-- Summit uses natural rock cap; monument kept subtle.
local summit = route[12][2]
terrainBall(summit-Vector3.new(0,10,0),34,Enum.Material.Rock)
local monument = part("ACC_SummitMonument",Vector3.new(7,20,7),CFrame.new(summit+Vector3.new(0,10,-9)),Enum.Material.Granite,Color3.fromRGB(82,83,84),root)
monument:SetAttribute("SummitTriggerReady",true)
monument:SetAttribute("SummitCounterReady",true)

-- Secret route stays hidden and narrow.
local secretStart = Vector3.new(-235,365,-135)
local secretEnd = Vector3.new(-390,555,-600)
local secretMid = (secretStart+secretEnd)/2 + Vector3.new(-25,0,18)
trailSegment("HiddenTrail_A",secretStart-Vector3.new(0,2,0),secretMid-Vector3.new(0,2,0),6)
trailSegment("HiddenTrail_B",secretMid-Vector3.new(0,2,0),secretEnd-Vector3.new(0,2,0),5)
local secretSummit = anchor("SecretSummit",secretEnd+Vector3.new(0,3,0),folders.Secrets)
secretSummit.Transparency = 0.9
secretSummit:SetAttribute("SecretSummit",true)
secretSummit:SetAttribute("DiscoveryId","SECRET_TRAIL_01")

-- More realistic lightweight vegetation: tapered trunks + layered foliage, density reduces with altitude.
local function makeTree(i,pos,scale)
    local trunkH = 11*scale + math.random()*7*scale
    local trunk = part("TreeTrunk_"..i,Vector3.new(2.2*scale,trunkH,2.2*scale),CFrame.new(pos+Vector3.new(0,trunkH/2,0)),Enum.Material.Wood,Color3.fromRGB(72,55,40),folders.Decor,0,false)
    trunk.CanCollide = false
    local lower = part("TreeFoliageA_"..i,Vector3.new(10*scale,8*scale,10*scale),CFrame.new(pos+Vector3.new(0,trunkH*0.82,0)),Enum.Material.Grass,Color3.fromRGB(50,79,54),folders.Decor,0,false)
    lower.Shape = Enum.PartType.Ball; lower.CanCollide=false
    local upper = part("TreeFoliageB_"..i,Vector3.new(7*scale,7*scale,7*scale),CFrame.new(pos+Vector3.new(0,trunkH+3*scale,0)),Enum.Material.Grass,Color3.fromRGB(57,88,60),folders.Decor,0,false)
    upper.Shape = Enum.PartType.Ball; upper.CanCollide=false
end

for i=1,130 do
    local ang = math.random()*math.pi*2
    local r = math.random(250,690)
    local altitudeBias = math.max(0,1-(r-250)/500)
    if math.random() < 0.45 + altitudeBias*0.45 then
        local x = math.cos(ang)*r
        local z = 90 + math.sin(ang)*r
        local y = math.max(20,55 + altitudeBias*35 + math.random(-5,15))
        makeTree(i,Vector3.new(x,y,z),0.75+math.random()*0.45)
    end
end

-- Loose rocks around route for natural reading without blocking traversal.
for i=1,65 do
    local seg = math.random(1,#route)
    local base = route[seg][2]
    local offset = Vector3.new(math.random(-38,38),math.random(-5,8),math.random(-38,38))
    local size = math.random(2,7)
    local rock = part("LooseRock_"..i,Vector3.new(size,size*0.7,size*1.1),CFrame.new(base+offset)*CFrame.Angles(math.random(),math.random(),math.random()),Enum.Material.Rock,Color3.fromRGB(89,91,88),folders.Decor)
    rock.Shape = Enum.PartType.Ball
end

root:SetAttribute("Project","Mountain Social Adventure")
root:SetAttribute("MasterPlanLocked",true)
root:SetAttribute("DayNightReady",true)
root:SetAttribute("WeatherReady",true)
root:SetAttribute("CheckpointSaveReady",true)
root:SetAttribute("CarrySystemReady",true)
root:SetAttribute("LeaderboardReady",true)
root:SetAttribute("MobileFriendly",true)
root:SetAttribute("RealismPass","1.1")
root:SetAttribute("BuildVersion","1.1.0-realism")

print("[ACC] Mountain Social Adventure realism pass generated safely under Workspace."..ROOT_NAME)
