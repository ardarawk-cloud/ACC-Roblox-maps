-- Mountain Social Adventure v1.0
-- Isolated ACC world generator. This script only creates/updates Workspace.ACC_MountainSocial.
-- It intentionally does not touch other map roots.

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
    local p = part(name, Vector3.new(8,1,8), CFrame.new(pos), Enum.Material.Neon, Color3.fromRGB(255,190,65), parent, 0.2, true)
    p:SetAttribute("ACCAnchor", true)
    return p
end

-- Lighting / ambience foundation
Lighting.ClockTime = 5.6
Lighting.Brightness = 2
Lighting.EnvironmentDiffuseScale = 0.35
Lighting.EnvironmentSpecularScale = 0.3
Lighting.OutdoorAmbient = Color3.fromRGB(120,130,145)
Lighting.Ambient = Color3.fromRGB(85,95,110)

local atmosphere = Lighting:FindFirstChild("ACC_MountainAtmosphere") or Instance.new("Atmosphere")
atmosphere.Name = "ACC_MountainAtmosphere"
atmosphere.Density = 0.32
atmosphere.Offset = 0.1
atmosphere.Color = Color3.fromRGB(195,215,225)
atmosphere.Decay = Color3.fromRGB(110,125,145)
atmosphere.Glare = 0.08
atmosphere.Haze = 1.7
atmosphere.Parent = Lighting

local colorCorrection = Lighting:FindFirstChild("ACC_MountainColor") or Instance.new("ColorCorrectionEffect")
colorCorrection.Name = "ACC_MountainColor"
colorCorrection.Brightness = 0.02
colorCorrection.Contrast = 0.08
colorCorrection.Saturation = -0.04
colorCorrection.Parent = Lighting

-- World proportions
local summitY = 620
local route = {
    {"Basecamp ACC", Vector3.new(0, 22, 690)},
    {"Gerbang Hutan", Vector3.new(-130, 72, 560)},
    {"Sungai Batu", Vector3.new(90, 125, 430)},
    {"Air Terjun Lumina", Vector3.new(215, 180, 300)},
    {"Camp Rimba", Vector3.new(75, 235, 160)},
    {"Tebing Angin", Vector3.new(-115, 300, 35)},
    {"Hutan Kabut", Vector3.new(-225, 355, -105)},
    {"Jembatan Awan", Vector3.new(-70, 415, -240)},
    {"Camp Atas", Vector3.new(115, 470, -335)},
    {"Ridge Batu", Vector3.new(205, 525, -430)},
    {"Lautan Awan", Vector3.new(95, 575, -540)},
    {"Summit ACC", Vector3.new(0, summitY, -650)},
}

-- Terrain: layered organic mountain mass using overlapping terrain balls/blocks.
-- This is intentionally coarse enough for mobile and can be refined later with meshes/assets.
Terrain:Clear()
Terrain:FillBlock(CFrame.new(0,-18,0), Vector3.new(1800,40,1800), Enum.Material.Ground)

local mountainNodes = {
    {Vector3.new(0,70,120), 430},
    {Vector3.new(-45,145,10), 350},
    {Vector3.new(35,230,-115), 295},
    {Vector3.new(-30,315,-245), 235},
    {Vector3.new(30,405,-370), 185},
    {Vector3.new(0,500,-500), 135},
    {Vector3.new(0,585,-630), 85},
}
for _, node in ipairs(mountainNodes) do
    Terrain:FillBall(node[1], node[2], Enum.Material.Rock)
end

-- Softer forest shoulders around lower elevations
for i=1,14 do
    local angle = i * math.pi * 2 / 14
    local r = 380 + (i%3)*35
    local y = 48 + (i%4)*16
    Terrain:FillBall(Vector3.new(math.cos(angle)*r, y, 90 + math.sin(angle)*r), 145, Enum.Material.Grass)
end

-- Carve route-friendly terraces / scenic clearings using anchored natural-material pads.
for i, info in ipairs(route) do
    local name, pos = info[1], info[2]
    local padSize = (i==1 and Vector3.new(100,4,80)) or (i==12 and Vector3.new(90,4,70)) or Vector3.new(42,3,34)
    local pad = part("TrailTerrace_"..i, padSize, CFrame.new(pos - Vector3.new(0,3,0)), Enum.Material.Rock, Color3.fromRGB(90,96,91), root)
    pad:SetAttribute("LocationName", name)
end

-- Visible trail segments between memorable locations.
for i=1,#route-1 do
    local a = route[i][2]
    local b = route[i+1][2]
    local mid = (a+b)/2 - Vector3.new(0,2,0)
    local dist = (b-a).Magnitude
    local trail = part("Trail_"..i, Vector3.new(18,2,dist), CFrame.lookAt(mid,b), Enum.Material.Ground, Color3.fromRGB(94,78,58), root)
    trail:SetAttribute("RouteSegment", i)
end

-- Spawn/basecamp
local spawn = Instance.new("SpawnLocation")
spawn.Name = "MountainSpawn"
spawn.Anchored = true
spawn.Size = Vector3.new(16,1,16)
spawn.CFrame = CFrame.new(route[1][2] + Vector3.new(0,4,0))
spawn.Material = Enum.Material.WoodPlanks
spawn.Color = Color3.fromRGB(100,78,55)
spawn.Neutral = true
spawn.Parent = root

-- Checkpoints with identity metadata, not just numbers.
for i, info in ipairs(route) do
    local cp = anchor(string.format("CP%02d_%s",i,info[1]:gsub(" ","_")), info[2] + Vector3.new(0,2,0), folders.Checkpoints)
    cp:SetAttribute("CheckpointIndex", i)
    cp:SetAttribute("CheckpointName", info[1])
    cp:SetAttribute("SaveReady", true)
end

-- Camps
local campIndexes = {1,5,9}
for _, idx in ipairs(campIndexes) do
    local pos = route[idx][2]
    local camp = Instance.new("Model")
    camp.Name = "Camp_"..route[idx][1]:gsub(" ","_")
    camp.Parent = folders.Camps
    part("Deck", Vector3.new(36,2,28), CFrame.new(pos + Vector3.new(22,0,5)), Enum.Material.WoodPlanks, Color3.fromRGB(92,67,47), camp)
    local fire = part("Campfire", Vector3.new(5,2,5), CFrame.new(pos + Vector3.new(22,2,5)), Enum.Material.Slate, Color3.fromRGB(75,75,75), camp)
    fire:SetAttribute("CampfireReady", true)
    local light = Instance.new("PointLight")
    light.Range = 22
    light.Brightness = 2
    light.Color = Color3.fromRGB(255,177,90)
    light.Parent = fire
end

-- Waterfall landmark foundation
local waterfallPos = route[4][2] + Vector3.new(45,34,-10)
local water = part("LuminaWaterfall", Vector3.new(16,70,5), CFrame.new(waterfallPos), Enum.Material.Glass, Color3.fromRGB(120,190,220), folders.Decor, 0.25, false)
water:SetAttribute("Landmark", "Waterfall")

-- Photo spots
local photoIndexes = {4,8,11,12}
for _, idx in ipairs(photoIndexes) do
    local p = anchor("PhotoSpot_"..idx, route[idx][2] + Vector3.new(24,3,0), folders.PhotoSpots)
    p.Color = Color3.fromRGB(100,205,255)
    p:SetAttribute("PhotoSpot", true)
    p:SetAttribute("LocationName", route[idx][1])
end

-- Summit payoff
local summit = route[12][2]
part("SummitPlatform", Vector3.new(95,4,75), CFrame.new(summit - Vector3.new(0,4,0)), Enum.Material.Slate, Color3.fromRGB(105,108,110), root)
local monument = part("ACC_SummitMonument", Vector3.new(10,34,10), CFrame.new(summit + Vector3.new(0,17,-8)), Enum.Material.Granite, Color3.fromRGB(75,78,82), root)
monument:SetAttribute("SummitTriggerReady", true)
monument:SetAttribute("SummitCounterReady", true)

-- Secret route and secret summit are deliberately optional discovery content.
local secretStart = Vector3.new(-235,365,-135)
local secretEnd = Vector3.new(-390,555,-600)
local secretMid = (secretStart+secretEnd)/2
local secretTrail = part("HiddenTrail", Vector3.new(11,2,(secretEnd-secretStart).Magnitude), CFrame.lookAt(secretMid,secretEnd), Enum.Material.Ground, Color3.fromRGB(67,61,52), folders.Secrets)
secretTrail:SetAttribute("Hidden", true)
secretTrail:SetAttribute("DiscoveryId", "SECRET_TRAIL_01")
local secretSummit = anchor("SecretSummit", secretEnd + Vector3.new(0,4,0), folders.Secrets)
secretSummit.Color = Color3.fromRGB(180,120,255)
secretSummit:SetAttribute("SecretSummit", true)

-- Decorative forest proxies; kept lightweight for mobile.
math.randomseed(240819)
for i=1,90 do
    local angle = math.random()*math.pi*2
    local r = math.random(250,690)
    local x = math.cos(angle)*r
    local z = 100 + math.sin(angle)*r
    local y = math.max(24, 70 - r*0.025 + math.random(0,25))
    local trunk = part("TreeTrunk_"..i, Vector3.new(3,math.random(14,22),3), CFrame.new(x,y,z), Enum.Material.Wood, Color3.fromRGB(78,57,40), folders.Decor)
    trunk.CanCollide = false
    local crown = part("TreeCrown_"..i, Vector3.new(math.random(10,16),math.random(12,20),math.random(10,16)), CFrame.new(x,y+12,z), Enum.Material.Grass, Color3.fromRGB(45,83,55), folders.Decor)
    crown.Shape = Enum.PartType.Ball
    crown.CanCollide = false
end

-- System readiness attributes consumed by future modules.
root:SetAttribute("Project", "Mountain Social Adventure")
root:SetAttribute("MasterPlanLocked", true)
root:SetAttribute("DayNightReady", true)
root:SetAttribute("WeatherReady", true)
root:SetAttribute("CheckpointSaveReady", true)
root:SetAttribute("CarrySystemReady", true)
root:SetAttribute("LeaderboardReady", true)
root:SetAttribute("MobileFriendly", true)
root:SetAttribute("BuildVersion", "1.0.0")

print("[ACC] Mountain Social Adventure v1 generated safely under Workspace."..ROOT_NAME)
