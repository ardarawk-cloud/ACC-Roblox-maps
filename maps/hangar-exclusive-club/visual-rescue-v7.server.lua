-- Hangar Exclusive Club — RUNTIME VISUAL LOCK v7
-- Evidence from live v6: player still saw a galaxy/star field and floating lights.
-- Force a deterministic enclosed aircraft-hangar interior for runtime QC.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local WIDTH = 360
local DEPTH = 280
local WALL_H = 88
local CROWN_H = 126
local BACK_Z = 92
local FRONT_Z = BACK_Z - DEPTH
local CENTER_Z = (BACK_Z + FRONT_Z) / 2

local function folder(parent, name)
    local old = parent:FindFirstChild(name)
    if old then old:Destroy() end
    local f = Instance.new("Folder")
    f.Name = name
    f.Parent = parent
    return f
end

local function part(parent, name, size, cf, color, material, collide, transparency)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = collide ~= false
    p.CastShadow = true
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material or Enum.Material.Metal
    p.Transparency = transparency or 0
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function neon(parent, name, size, cf, color)
    local p = part(parent, name, size, cf, color, Enum.Material.Neon, false, 0)
    p.CastShadow = false
    return p
end

-- Remove visible galaxy / celestial sky. The venue must read as an enclosed hangar.
for _, child in ipairs(Lighting:GetChildren()) do
    if child:IsA("Sky") then child:Destroy() end
end
local sky = Instance.new("Sky")
sky.Name = "HangarNoGalaxySky"
sky.StarCount = 0
sky.CelestialBodiesShown = false
sky.SkyboxBk = ""
sky.SkyboxDn = ""
sky.SkyboxFt = ""
sky.SkyboxLf = ""
sky.SkyboxRt = ""
sky.SkyboxUp = ""
sky.Parent = Lighting

Lighting.ClockTime = 20.0
Lighting.Brightness = 3.4
Lighting.ExposureCompensation = 0.85
Lighting.Ambient = Color3.fromRGB(92, 96, 110)
Lighting.OutdoorAmbient = Color3.fromRGB(46, 49, 60)
Lighting.EnvironmentDiffuseScale = 0.65
Lighting.EnvironmentSpecularScale = 1
Lighting.GlobalShadows = true

local map = Workspace:WaitForChild("Map")

-- Retire the misleading runtime-generated full mesh for this QC build.
-- It reported Ready on v6 but did not visually enclose the player.
local generated = map:FindFirstChild("FullMeshV2")
if generated then generated:Destroy() end
local oldRescue = map:FindFirstChild("HangarXLVisualRescue")
if oldRescue then oldRescue:Destroy() end

local architecture = map:FindFirstChild("Architecture")
if architecture then
    for _, child in ipairs(architecture:GetChildren()) do
        if child.Name:match("^Mesh_Hangar") or child.Name:match("^RoofTruss_") or child.Name == "Apron" then child:Destroy() end
    end
end
local vehicles = map:FindFirstChild("Vehicles")
if vehicles then
    for _, child in ipairs(vehicles:GetChildren()) do
        if child.Name:match("^Mesh_PrivateJet") or child.Name:match("^Mesh_Helicopter") then child:Destroy() end
    end
end
local furniture = map:FindFirstChild("Furniture")
if furniture then
    for _, child in ipairs(furniture:GetChildren()) do
        if child.Name == "Stage" or child.Name:match("^DJBooth") or child.Name:match("^Mesh_BarCounter") or child.Name:match("^Mesh_LeatherSofa_") or child.Name:match("^Mesh_MetalFencing_") then child:Destroy() end
    end
end

local root = folder(map, "HangarV7EnclosedInterior")
local shell = folder(root, "Architecture")
local club = folder(root, "Club")
local aircraft = folder(root, "Aircraft")
local lights = folder(root, "Lighting")

local steel = Color3.fromRGB(54, 58, 67)
local darkSteel = Color3.fromRGB(20, 23, 29)
local floorColor = Color3.fromRGB(67, 69, 74)

-- Full floor and walls.
part(shell, "HangarFloor_XL", Vector3.new(WIDTH, 3, DEPTH), CFrame.new(0, -1.5, CENTER_Z), floorColor, Enum.Material.Concrete, true, 0)
part(shell, "BackWall_XL", Vector3.new(WIDTH, WALL_H, 5), CFrame.new(0, WALL_H/2, BACK_Z), steel, Enum.Material.Metal, true, 0)
part(shell, "LeftWall_XL", Vector3.new(5, WALL_H, DEPTH), CFrame.new(-WIDTH/2, WALL_H/2, CENTER_Z), steel, Enum.Material.Metal, true, 0)
part(shell, "RightWall_XL", Vector3.new(5, WALL_H, DEPTH), CFrame.new(WIDTH/2, WALL_H/2, CENTER_Z), steel, Enum.Material.Metal, true, 0)
part(shell, "FrontHeader_XL", Vector3.new(WIDTH, 20, 5), CFrame.new(0, WALL_H-10, FRONT_Z), steel, Enum.Material.Metal, true, 0)

-- Opaque segmented arched roof. No sky should be visible from the dance floor.
local roofBands = 24
for s = 0, roofBands - 1 do
    local t0 = s / roofBands
    local t1 = (s + 1) / roofBands
    local x0 = -WIDTH/2 + t0 * WIDTH
    local x1 = -WIDTH/2 + t1 * WIDTH
    local y0 = WALL_H + math.sin(t0 * math.pi) * (CROWN_H - WALL_H)
    local y1 = WALL_H + math.sin(t1 * math.pi) * (CROWN_H - WALL_H)
    local mid = Vector3.new((x0+x1)/2, (y0+y1)/2, CENTER_Z)
    local dx = x1-x0
    local dy = y1-y0
    local span = math.sqrt(dx*dx + dy*dy)
    local angle = math.atan2(dy, dx)
    part(shell, string.format("RoofPanel_%02d", s), Vector3.new(span + 3, 4, DEPTH + 8), CFrame.new(mid) * CFrame.Angles(0,0,angle), Color3.fromRGB(47,51,60), Enum.Material.Metal, true, 0)
end

-- Steel portal ribs under roof for clear hangar identity.
for i = 0, 12 do
    local z = FRONT_Z + 10 + (i/12)*(DEPTH-20)
    part(shell, "ColumnL_"..i, Vector3.new(5, WALL_H, 5), CFrame.new(-WIDTH/2+10, WALL_H/2, z), darkSteel, Enum.Material.Metal, false, 0)
    part(shell, "ColumnR_"..i, Vector3.new(5, WALL_H, 5), CFrame.new(WIDTH/2-10, WALL_H/2, z), darkSteel, Enum.Material.Metal, false, 0)
    for s = 0, 15 do
        local t0 = s/16
        local t1 = (s+1)/16
        local x0 = -WIDTH/2+10+t0*(WIDTH-20)
        local x1 = -WIDTH/2+10+t1*(WIDTH-20)
        local y0 = WALL_H + math.sin(t0*math.pi)*(CROWN_H-WALL_H)-5
        local y1 = WALL_H + math.sin(t1*math.pi)*(CROWN_H-WALL_H)-5
        local a = Vector3.new(x0,y0,z)
        local b = Vector3.new(x1,y1,z)
        local mid = (a+b)/2
        local len = (b-a).Magnitude
        part(shell, string.format("RoofRib_%02d_%02d", i, s), Vector3.new(4,4,len), CFrame.lookAt(mid,b), darkSteel, Enum.Material.Metal, false, 0)
    end
end

-- Main club layout.
part(club, "MainStage_XL", Vector3.new(116,6,34), CFrame.new(0,3,67), Color3.fromRGB(24,26,31), Enum.Material.Metal, true, 0)
part(club, "DJBooth_XL", Vector3.new(38,10,8), CFrame.new(0,9,58), Color3.fromRGB(14,16,20), Enum.Material.Metal, true, 0)
neon(club, "DJBoothEdge", Vector3.new(32,1.2,0.8), CFrame.new(0,10,53.6), Color3.fromRGB(0,225,255))

local sign = neon(club, "HangarSign", Vector3.new(92,18,1), CFrame.new(0,53,89), Color3.fromRGB(235,239,247))
local sg = Instance.new("SurfaceGui")
sg.Face = Enum.NormalId.Front
sg.Parent = sign
local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(1,1)
label.BackgroundTransparency = 1
label.Text = "HANGAR\nEXCLUSIVE CLUB"
label.TextColor3 = Color3.fromRGB(16,18,23)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Parent = sg

for _, side in ipairs({-1,1}) do
    local x = side*132
    part(club, "VIPDeck_"..side, Vector3.new(54,4,76), CFrame.new(x,18,18), Color3.fromRGB(31,34,40), Enum.Material.Metal, true, 0)
    part(club, "VIPBack_"..side, Vector3.new(4,28,76), CFrame.new(x+side*27,31,18), Color3.fromRGB(35,38,45), Enum.Material.Metal, true, 0)
    part(club, "Bar_"..side, Vector3.new(52,7,13), CFrame.new(side*126,4,-48), Color3.fromRGB(63,49,40), Enum.Material.WoodPlanks, true, 0)
    neon(club, "BarGlow_"..side, Vector3.new(48,1,0.8), CFrame.new(side*126,5.4,-54.9), Color3.fromRGB(255,188,110))
end

local function jet(name, x, z, yaw)
    local m = Instance.new("Model")
    m.Name = name
    m.Parent = aircraft
    local cf = CFrame.new(x,10,z) * CFrame.Angles(0, math.rad(yaw), 0)
    part(m,"Fuselage",Vector3.new(15,14,86),cf,Color3.fromRGB(226,229,234),Enum.Material.Metal,false,0)
    part(m,"Wing",Vector3.new(76,2.4,20),cf*CFrame.new(0,-1,4),Color3.fromRGB(198,203,211),Enum.Material.Metal,false,0)
    part(m,"TailWing",Vector3.new(36,2,12),cf*CFrame.new(0,3,33),Color3.fromRGB(198,203,211),Enum.Material.Metal,false,0)
    part(m,"TailFin",Vector3.new(3,21,14),cf*CFrame.new(0,10,36),Color3.fromRGB(69,73,83),Enum.Material.Metal,false,0)
    part(m,"Cockpit",Vector3.new(12,7,13),cf*CFrame.new(0,4,-41),Color3.fromRGB(50,105,130),Enum.Material.Glass,false,0.18)
end
jet("Jet_A_XL", -98, 41, -7)
jet("Jet_B_XL", 98, 41, 7)

-- Industrial overhead white fill, plus colored stage lighting.
local rows = {-145,-95,-45,5,45}
local cols = {-135,-90,-45,0,45,90,135}
for ri,z in ipairs(rows) do
    for ci,x in ipairs(cols) do
        local fixture = part(lights,string.format("IndustrialLight_%02d_%02d",ri,ci),Vector3.new(7,1,5),CFrame.new(x,78,z),Color3.fromRGB(235,238,245),Enum.Material.Neon,false,0)
        fixture.CastShadow = false
        local pl = Instance.new("PointLight")
        pl.Color = Color3.fromRGB(225,232,245)
        pl.Brightness = 2.7
        pl.Range = 72
        pl.Shadows = false
        pl.Parent = fixture
    end
end

for i,x in ipairs({-80,-40,0,40,80}) do
    local fixture = part(lights,"StageSpot_"..i,Vector3.new(4,3,4),CFrame.new(x,64,18),Color3.fromRGB(30,32,36),Enum.Material.Metal,false,0)
    local sp = Instance.new("SpotLight")
    sp.Face = Enum.NormalId.Front
    sp.Angle = 80
    sp.Range = 130
    sp.Brightness = 6
    sp.Color = Color3.fromRGB(240,242,255)
    sp.Shadows = false
    sp.Parent = fixture
end

Workspace:SetAttribute("HangarRuntimeVisualMode", "V7_FORCED_ENCLOSED_AIRCRAFT_HANGAR")
Workspace:SetAttribute("HangarFullMeshReady", false)
Workspace:SetAttribute("HangarScaleClass", "AIRCRAFT_HANGAR_XL")
Workspace:SetAttribute("HangarGalaxyRemoved", true)
print("[HANGAR V7] enclosed aircraft hangar runtime built; galaxy removed", WIDTH, DEPTH, CROWN_H)
