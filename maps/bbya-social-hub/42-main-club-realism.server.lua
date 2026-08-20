-- BBYA SOCIAL HUB — MAIN CLUB PREMIUM VENUE v2
-- Deterministic live geometry: no third-party runtime asset dependency and no placeholder NPC crowd.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD")
local floor1 = root:WaitForChild("Floor1Core", 20)
if not floor1 then
    warn("[BBYA MainClub] Floor1Core unavailable")
    return
end

local old = root:FindFirstChild("MainClubRealism")
if old then old:Destroy() end

local out = Instance.new("Model")
out.Name = "MainClubRealism"
out.Parent = root

local architecture = Instance.new("Folder")
architecture.Name = "Architecture"
architecture.Parent = out
local furniture = Instance.new("Folder")
furniture.Name = "Furniture"
furniture.Parent = out
local av = Instance.new("Folder")
av.Name = "AudioVisual"
av.Parent = out
local dressing = Instance.new("Folder")
dressing.Name = "Dressing"
dressing.Parent = out
local crowd = Instance.new("Folder")
crowd.Name = "PlayerDrivenCrowd"
crowd:SetAttribute("Mode", "NO_PLACEHOLDER_NPCS")
crowd.Parent = out

local C = {
    black = Color3.fromRGB(8, 8, 11),
    charcoal = Color3.fromRGB(20, 19, 24),
    graphite = Color3.fromRGB(35, 33, 39),
    metal = Color3.fromRGB(49, 47, 54),
    stone = Color3.fromRGB(45, 42, 48),
    fabric = Color3.fromRGB(35, 31, 39),
    fabric2 = Color3.fromRGB(62, 49, 61),
    glass = Color3.fromRGB(84, 92, 103),
    marble = Color3.fromRGB(108, 102, 110),
    pink = Color3.fromRGB(255, 38, 155),
    cyan = Color3.fromRGB(0, 205, 235),
    warm = Color3.fromRGB(255, 198, 144),
    white = Color3.fromRGB(236, 232, 239),
}

local function part(name, size, cf, color, material, transparency, parent, collide)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color or C.graphite
    p.Material = material or Enum.Material.SmoothPlastic
    p.Transparency = transparency or 0
    p.Anchored = true
    p.CanCollide = collide == true
    p.CanTouch = false
    p.CanQuery = true
    p.CastShadow = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or out
    return p
end

local function cylinder(name, size, cf, color, material, transparency, parent)
    local p = part(name, size, cf, color, material, transparency, parent, false)
    p.Shape = Enum.PartType.Cylinder
    return p
end

local function neon(name, size, cf, color, parent)
    local p = part(name, size, cf, color or C.pink, Enum.Material.Neon, 0, parent, false)
    p.CastShadow = false
    return p
end

local function pointLight(parent, color, brightness, range, shadows)
    local l = Instance.new("PointLight")
    l.Color = color
    l.Brightness = brightness
    l.Range = range
    l.Shadows = shadows == true
    l.Parent = parent
    return l
end

local function spotLight(parent, color, brightness, range, angle)
    local l = Instance.new("SpotLight")
    l.Face = Enum.NormalId.Bottom
    l.Color = color
    l.Brightness = brightness
    l.Range = range
    l.Angle = angle
    l.Shadows = true
    l.Parent = parent
    return l
end

local function model(name, parent)
    local m = Instance.new("Model")
    m.Name = name
    m.Parent = parent
    return m
end

-- Remove the old Tron-like dance grid and primitive stage light bars.
local danceZone = floor1:FindFirstChild("05_MainDanceFloor")
if danceZone then
    for _, obj in ipairs(danceZone:GetChildren()) do
        if obj.Name:match("^DanceStrip") then obj:Destroy() end
    end
end
local stageZone = floor1:FindFirstChild("07_StageLighting")
if stageZone then
    for _, obj in ipairs(stageZone:GetChildren()) do
        if obj.Name:match("^StageBar") then obj:Destroy() end
    end
end

-- DANCE FLOOR -----------------------------------------------------------------
local dance = model("PremiumDanceFloor", architecture)
local floor = part("PolishedFloor", Vector3.new(57.2, .12, 41.2), CFrame.new(3, .97, 11), Color3.fromRGB(24, 23, 29), Enum.Material.SmoothPlastic, 0, dance, true)
floor.Reflectance = .08
-- Recessed perimeter light: subtle, not a glowing grid.
neon("NorthEdge", Vector3.new(56.2, .035, .10), CFrame.new(3, 1.045, 31.35), C.pink, dance)
neon("SouthEdge", Vector3.new(56.2, .035, .10), CFrame.new(3, 1.045, -9.35), C.cyan, dance)
neon("WestEdge", Vector3.new(.10, .035, 40.6), CFrame.new(-25.1, 1.045, 11), C.cyan, dance)
neon("EastEdge", Vector3.new(.10, .035, 40.6), CFrame.new(31.1, 1.045, 11), C.pink, dance)

-- CEILING / TRUSS -------------------------------------------------------------
local ceiling = model("CeilingRig", architecture)
for _, z in ipairs({-3, 11, 25, 39}) do
    part("CrossBeam", Vector3.new(66, .42, .62), CFrame.new(2, 19.7, z), C.black, Enum.Material.Metal, 0, ceiling, false)
end
for _, x in ipairs({-24, 3, 30}) do
    part("LongBeam", Vector3.new(.62, .42, 52), CFrame.new(x, 19.68, 18), C.black, Enum.Material.Metal, 0, ceiling, false)
end
-- Acoustic ceiling baffles add depth and remove the empty-box feel.
for i, x in ipairs({-20,-12,-4,4,12,20,28}) do
    local z = 11 + ((i % 2 == 0) and 3 or -3)
    part("AcousticBaffle"..i, Vector3.new(5.8, .42, 11.5), CFrame.new(x, 18.85, z) * CFrame.Angles(0, math.rad((i%2==0) and 8 or -8), 0), Color3.fromRGB(26,23,29), Enum.Material.Fabric, 0, ceiling, false)
end
-- Professional downlights: warm base + restrained club accents.
local lightPoints = {
    {-18,-2,C.warm}, {-6,-2,C.pink}, {6,-2,C.warm}, {18,-2,C.cyan},
    {-18,12,C.cyan}, {-6,12,C.warm}, {6,12,C.pink}, {18,12,C.warm},
    {-18,26,C.warm}, {-6,26,C.cyan}, {6,26,C.warm}, {18,26,C.pink},
}
for i, v in ipairs(lightPoints) do
    local can = cylinder("CeilingCan"..i, Vector3.new(.34, 1.15, 1.15), CFrame.new(v[1]+3, 18.35, v[2]) * CFrame.Angles(0,0,math.rad(90)), C.black, Enum.Material.Metal, 0, ceiling)
    spotLight(can, v[3], v[3] == C.warm and 1.35 or .8, 31, 54)
end

-- STAGE -----------------------------------------------------------------------
local stage = model("PremiumStage", architecture)
-- Layered rear panels create depth instead of one flat black wall.
for i, x in ipairs({-21,-10.5,0,10.5,21}) do
    local depth = (i % 2 == 0) and .42 or .72
    part("StagePanel"..i, Vector3.new(9.4, 11.6, depth), CFrame.new(x+3, 8.8, 47.1), (i==3) and Color3.fromRGB(19,17,23) or C.charcoal, Enum.Material.Metal, 0, stage, false)
end
part("StagePortalTop", Vector3.new(55, .7, 1.1), CFrame.new(3, 14.7, 46.5), C.black, Enum.Material.Metal, 0, stage, false)
part("StagePortalLeft", Vector3.new(.8, 12, 1.1), CFrame.new(-24.6, 8.8, 46.5), C.black, Enum.Material.Metal, 0, stage, false)
part("StagePortalRight", Vector3.new(.8, 12, 1.1), CFrame.new(30.6, 8.8, 46.5), C.black, Enum.Material.Metal, 0, stage, false)
for i, x in ipairs({-17,-8.5,8.5,17}) do
    neon("RecessLight"..i, Vector3.new(.10, 7.4, .09), CFrame.new(x+3, 9.2, 46.65), (i%2==0) and C.cyan or C.pink, stage)
end

local logoPanel = part("StageLogoPanel", Vector3.new(15.5, 4.4, .16), CFrame.new(3, 9.2, 46.55), Color3.fromRGB(9,8,12), Enum.Material.Glass, .08, stage, false)
local sg = Instance.new("SurfaceGui")
sg.Face = Enum.NormalId.Front
sg.AlwaysOnTop = false
sg.LightInfluence = .25
sg.PixelsPerStud = 60
sg.Parent = logoPanel
local logo = Instance.new("TextLabel")
logo.BackgroundTransparency = 1
logo.Size = UDim2.fromScale(1,1)
logo.Text = "BBYA"
logo.TextColor3 = C.white
logo.Font = Enum.Font.GothamBlack
logo.TextScaled = true
logo.Parent = sg
local stroke = Instance.new("UIStroke")
stroke.Color = C.pink
stroke.Thickness = 2
stroke.Transparency = .15
stroke.Parent = logo

-- DJ BOOTH + EQUIPMENT ---------------------------------------------------------
local dj = model("DJBoothPremium", av)
part("BoothBody", Vector3.new(18.5, 3.4, 4.8), CFrame.new(0, 3.0, 31.0), C.black, Enum.Material.Metal, 0, dj, true)
part("BoothFrontInset", Vector3.new(15.8, 2.2, .18), CFrame.new(0, 3.05, 28.52), Color3.fromRGB(17,14,20), Enum.Material.Glass, .10, dj, false)
part("BoothTop", Vector3.new(19.1, .28, 5.25), CFrame.new(0, 4.82, 31), C.marble, Enum.Material.Marble, 0, dj, false)
neon("BoothUnderGlow", Vector3.new(15.8, .08, .08), CFrame.new(0, 4.36, 28.42), C.pink, dj)

local gear = model("DJEquipment", dj)
part("Mixer", Vector3.new(4.2, .34, 2.6), CFrame.new(0, 5.08, 31.1), C.charcoal, Enum.Material.Metal, 0, gear, false)
for side, x in ipairs({-5.0, 5.0}) do
    part("DeckBase"..side, Vector3.new(4.3, .34, 3.1), CFrame.new(x, 5.08, 31.1), C.charcoal, Enum.Material.Metal, 0, gear, false)
    cylinder("Platter"..side, Vector3.new(.18, 2.3, 2.3), CFrame.new(x, 5.30, 31.05) * CFrame.Angles(0,0,math.rad(90)), Color3.fromRGB(57,55,61), Enum.Material.Metal, 0, gear)
    neon("DeckDisplay"..side, Vector3.new(1.2, .07, .55), CFrame.new(x+1.2, 5.31, 30.4), side==1 and C.cyan or C.pink, gear)
end
for i=-4,4 do
    cylinder("MixerKnob"..i, Vector3.new(.13,.20,.20), CFrame.new(i*.42,5.34,31.1)*CFrame.Angles(0,0,math.rad(90)), (i%2==0) and C.cyan or C.pink, Enum.Material.Neon, 0, gear)
end

-- SPEAKER ARRAYS: deterministic housings and visible drivers.
local function speakerTower(name, x)
    local m = model(name, av)
    part("Cabinet", Vector3.new(5.4, 11.2, 3.2), CFrame.new(x, 7.8, 43.4), C.black, Enum.Material.Metal, 0, m, false)
    for i, y in ipairs({4.4,7.3,10.2}) do
        cylinder("Driver"..i, Vector3.new(.30, 2.55, 2.55), CFrame.new(x, y, 41.72) * CFrame.Angles(0,math.rad(90),0), Color3.fromRGB(25,24,28), Enum.Material.SmoothPlastic, 0, m)
        cylinder("DustCap"..i, Vector3.new(.34, .72, .72), CFrame.new(x, y, 41.53) * CFrame.Angles(0,math.rad(90),0), Color3.fromRGB(68,65,72), Enum.Material.Metal, 0, m)
    end
    neon("Status", Vector3.new(1.4,.08,.08), CFrame.new(x,12.75,41.72), x<0 and C.cyan or C.pink, m)
end
speakerTower("SpeakerArray_L", -22.5)
speakerTower("SpeakerArray_R", 22.5)

-- LOUNGE FURNITURE ------------------------------------------------------------
local function sofa(name, pos, yaw, width, fabricColor)
    local m = model(name, furniture)
    local cf = CFrame.new(pos) * CFrame.Angles(0, math.rad(yaw), 0)
    local w = width or 9
    part("Plinth", Vector3.new(w, .42, 3.0), cf * CFrame.new(0,.48,0), C.black, Enum.Material.Metal, 0, m, false)
    part("Seat", Vector3.new(w-.7, 1.0, 3.3), cf * CFrame.new(0,1.18,0), fabricColor or C.fabric, Enum.Material.Fabric, 0, m, false)
    part("Back", Vector3.new(w-.6, 2.6, .85), cf * CFrame.new(0,2.25,1.35), fabricColor or C.fabric, Enum.Material.Fabric, 0, m, false)
    part("ArmL", Vector3.new(.72, 1.7, 3.25), cf * CFrame.new(-(w/2-.35),1.55,0), C.fabric2, Enum.Material.Fabric, 0, m, false)
    part("ArmR", Vector3.new(.72, 1.7, 3.25), cf * CFrame.new((w/2-.35),1.55,0), C.fabric2, Enum.Material.Fabric, 0, m, false)
    -- Individual cushions break up the block silhouette.
    local count = math.max(2, math.floor(w/3))
    for i=1,count do
        local x = -((count-1)*1.45)/2 + (i-1)*1.45
        part("Cushion"..i, Vector3.new(1.25, .42, 1.35), cf * CFrame.new(x,1.78,.25) * CFrame.Angles(math.rad(-8),0,0), Color3.fromRGB(73,58,72), Enum.Material.Fabric, 0, m, false)
    end
    return m
end

local function tableRound(name, pos, diameter)
    local m = model(name, furniture)
    cylinder("Base", Vector3.new(.22, diameter*.62, diameter*.62), CFrame.new(pos.X,.22,pos.Z)*CFrame.Angles(0,0,math.rad(90)), C.black, Enum.Material.Metal, 0, m)
    cylinder("Stem", Vector3.new(1.25,.25,.25), CFrame.new(pos.X,1.0,pos.Z)*CFrame.Angles(0,0,math.rad(90)), C.metal, Enum.Material.Metal, 0, m)
    local top = cylinder("GlassTop", Vector3.new(.16,diameter,diameter), CFrame.new(pos.X,1.68,pos.Z)*CFrame.Angles(0,0,math.rad(90)), C.glass, Enum.Material.Glass, .18, m)
    top.Reflectance = .12
end

-- Raised left VIP bays face the dance floor.
for i, z in ipairs({0, 14, 28}) do
    local bay = model("VIPBay_L_"..i, furniture)
    part("Platform", Vector3.new(17,.32,10.5), CFrame.new(-39,.95,z), Color3.fromRGB(31,28,34), Enum.Material.Slate, 0, bay, true)
    sofa("Sofa_L_"..i, Vector3.new(-45,1.05,z), -90, 8.6, (i==2) and Color3.fromRGB(52,39,52) or C.fabric)
    tableRound("Table_L_"..i, Vector3.new(-35.5,.5,z), 3.3)
    neon("BayEdge", Vector3.new(.08,.08,8.5), CFrame.new(-30.7,1.16,z), (i%2==0) and C.cyan or C.pink, bay)
end

-- BAR UPGRADE -----------------------------------------------------------------
local bar = model("MainBarPremium", furniture)
part("CounterTop", Vector3.new(4.7,.26,24.8), CFrame.new(34.35,3.66,11), C.marble, Enum.Material.Marble, 0, bar, false)
-- Vertical slatted front with warm under-light.
for i, z in ipairs({0,3,6,9,12,15,18,21}) do
    local zz = -.5 + z
    part("FrontSlat"..i, Vector3.new(.18,2.3,1.55), CFrame.new(32.42,2.25,zz), Color3.fromRGB(73,59,54), Enum.Material.WoodPlanks, 0, bar, false)
end
local under = neon("BarUnderGlow", Vector3.new(.08,.08,22.8), CFrame.new(32.29,1.35,11), C.warm, bar)
pointLight(under, C.warm, .65, 8, false)
-- Bottle shelves on rear wall.
for shelf, y in ipairs({3.3,6.0,8.7}) do
    part("Shelf"..shelf, Vector3.new(.45,.16,23.0), CFrame.new(50.55,y,11), C.black, Enum.Material.Metal, 0, bar, false)
    local strip = neon("ShelfLight"..shelf, Vector3.new(.08,.07,22.2), CFrame.new(50.28,y-.02,11), shelf==2 and C.pink or C.warm, bar)
    pointLight(strip, strip.Color, .28, 5, false)
end
local bottleColors = {Color3.fromRGB(174,120,65), Color3.fromRGB(76,125,102), Color3.fromRGB(112,91,135), Color3.fromRGB(194,158,78)}
for row, y in ipairs({4.0,6.7,9.4}) do
    for i=1,11 do
        local z = 1.4 + (i-1)*1.9
        local col = bottleColors[((i+row-2)%#bottleColors)+1]
        cylinder("Bottle_"..row.."_"..i, Vector3.new(.78,.34,.34), CFrame.new(50.20,y,z)*CFrame.Angles(0,0,math.rad(90)), col, Enum.Material.Glass, .08, dressing)
    end
end

local function stool(name, z)
    local m = model(name, furniture)
    cylinder("Base", Vector3.new(.16,2.0,2.0), CFrame.new(29.8,.18,z)*CFrame.Angles(0,0,math.rad(90)), C.black, Enum.Material.Metal, 0, m)
    cylinder("Stem", Vector3.new(2.1,.20,.20), CFrame.new(29.8,1.3,z)*CFrame.Angles(0,0,math.rad(90)), C.metal, Enum.Material.Metal, 0, m)
    cylinder("Seat", Vector3.new(.38,2.3,2.3), CFrame.new(29.8,2.5,z)*CFrame.Angles(0,0,math.rad(90)), Color3.fromRGB(48,39,48), Enum.Material.Fabric, 0, m)
    cylinder("FootRing", Vector3.new(.10,1.25,1.25), CFrame.new(29.8,1.05,z)*CFrame.Angles(0,0,math.rad(90)), C.metal, Enum.Material.Metal, 0, m)
end
for i, z in ipairs({1,6,11,16,21}) do stool("BarStool_"..i, z) end

-- Small cocktail islands create natural social pockets without blocking circulation.
for i, pos in ipairs({Vector3.new(-18,.5,34), Vector3.new(-10,.5,37), Vector3.new(12,.5,37), Vector3.new(20,.5,34)}) do
    tableRound("RearCocktail_"..i, pos, 2.7)
end

-- Architectural planters soften the all-black interior without turning it into decoration clutter.
local function planter(name, pos)
    local m = model(name, dressing)
    cylinder("Pot", Vector3.new(1.55,2.6,2.6), CFrame.new(pos.X,1.3,pos.Z)*CFrame.Angles(0,0,math.rad(90)), Color3.fromRGB(31,29,34), Enum.Material.Slate, 0, m)
    part("Stem", Vector3.new(.28,4.0,.28), CFrame.new(pos.X,4.0,pos.Z), Color3.fromRGB(52,69,55), Enum.Material.SmoothPlastic, 0, m, false)
    for i=1,4 do
        local angle = math.rad((i-1)*90)
        part("Leaf"..i, Vector3.new(.22,2.3,.7), CFrame.new(pos.X+math.cos(angle)*.8,5.2,pos.Z+math.sin(angle)*.8) * CFrame.Angles(math.rad(20),-angle,0), Color3.fromRGB(54,82,62), Enum.Material.SmoothPlastic, 0, m, false)
    end
end
planter("Planter_L1", Vector3.new(-49,.5,37))
planter("Planter_L2", Vector3.new(-49,.5,-7))
planter("Planter_R1", Vector3.new(48,.5,28))

-- Venue lighting baseline: keep reflections and shadows readable on mobile.
Lighting.Brightness = 1.75
Lighting.EnvironmentDiffuseScale = .38
Lighting.EnvironmentSpecularScale = .92
Lighting.ShadowSoftness = .34
Lighting.ExposureCompensation = -.18

print("[BBYA] Main Club premium venue v2 loaded: deterministic architecture, lounge, bar, DJ rig, stage and AV; placeholder NPC crowd removed")
