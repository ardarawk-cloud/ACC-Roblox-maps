-- BBYA SOCIAL HUB — FLOOR 1 PREMIUM VENUE v3
-- Deterministic Roblox-native geometry. No runtime third-party asset dependency.
-- Goal: believable premium nightclub architecture, furniture, bar, stage, AV and lighting.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD")
local floor1 = root:WaitForChild("Floor1Core", 20)
if not floor1 then
    warn("[BBYA Floor1 Premium] Floor1Core unavailable")
    return
end

local old = root:FindFirstChild("MainClubRealism")
if old then old:Destroy() end

local out = Instance.new("Model")
out.Name = "MainClubRealism"
out:SetAttribute("Pass", "FLOOR1_PREMIUM_V3")
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

local C = {
    black = Color3.fromRGB(7, 7, 9),
    ink = Color3.fromRGB(13, 12, 16),
    charcoal = Color3.fromRGB(23, 22, 27),
    graphite = Color3.fromRGB(37, 35, 41),
    metal = Color3.fromRGB(54, 52, 59),
    stone = Color3.fromRGB(48, 45, 51),
    fabric = Color3.fromRGB(35, 31, 38),
    fabric2 = Color3.fromRGB(57, 45, 57),
    glass = Color3.fromRGB(75, 82, 91),
    marble = Color3.fromRGB(114, 108, 116),
    wood = Color3.fromRGB(82, 61, 49),
    pink = Color3.fromRGB(255, 39, 154),
    cyan = Color3.fromRGB(0, 200, 230),
    warm = Color3.fromRGB(255, 191, 132),
    amber = Color3.fromRGB(233, 159, 78),
    white = Color3.fromRGB(236, 233, 239),
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

local function cylinder(name, size, cf, color, material, transparency, parent, collide)
    local p = part(name, size, cf, color, material, transparency, parent, collide)
    p.Shape = Enum.PartType.Cylinder
    return p
end

local function neon(name, size, cf, color, parent, transparency)
    local p = part(name, size, cf, color or C.pink, Enum.Material.Neon, transparency or 0, parent, false)
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

local function spotLight(parent, face, color, brightness, range, angle, shadows)
    local l = Instance.new("SpotLight")
    l.Face = face or Enum.NormalId.Bottom
    l.Color = color
    l.Brightness = brightness
    l.Range = range
    l.Angle = angle
    l.Shadows = shadows == true
    l.Parent = parent
    return l
end

local function model(name, parent)
    local m = Instance.new("Model")
    m.Name = name
    m.Parent = parent
    return m
end

local function removeNamed(zoneName, names)
    local zone = floor1:FindFirstChild(zoneName)
    if not zone then return end
    for _, name in ipairs(names) do
        local obj = zone:FindFirstChild(name)
        if obj then obj:Destroy() end
    end
end

-- Strip primitive geometry replaced by this pass.
local danceZone = floor1:FindFirstChild("05_MainDanceFloor")
if danceZone then
    for _, obj in ipairs(danceZone:GetChildren()) do
        if obj.Name:match("^DanceStrip") or obj.Name == "DanceFloor" then obj:Destroy() end
    end
end
removeNamed("06_DJBooth", {"DJPlatform", "DJDesk", "DJDeskGlow"})
removeNamed("07_StageLighting", {"StageDeck", "StageBack"})
removeNamed("08_MainBar", {"BarFloor", "BarBack", "BarCounter", "BarCounterGlow"})

-- FLOOR + ARCHITECTURAL ZONING ------------------------------------------------
local shell = model("PremiumShell", architecture)
local dance = part("DanceFloor", Vector3.new(58, .16, 42), CFrame.new(3, 1.01, 11), Color3.fromRGB(22, 22, 27), Enum.Material.SmoothPlastic, 0, shell, true)
dance.Reflectance = .10

-- Subtle brass threshold strips read like intentional floor inlays rather than a Tron grid.
for i, z in ipairs({-8.8, 31.0}) do
    local strip = part("Threshold"..i, Vector3.new(56, .035, .07), CFrame.new(3, 1.105, z), C.amber, Enum.Material.Metal, 0, shell, false)
    strip.Reflectance = .22
end
for i, x in ipairs({-24.8, 30.8}) do
    part("SideInlay"..i, Vector3.new(.07, .035, 39.5), CFrame.new(x, 1.105, 11), C.metal, Enum.Material.Metal, 0, shell, false)
end

-- Side architectural walls: layered acoustic panels, pilasters and warm sconces.
local function wallBay(name, x, z, yaw, accent)
    local bay = model(name, architecture)
    local cf = CFrame.new(x, 7.0, z) * CFrame.Angles(0, math.rad(yaw), 0)
    part("Recess", Vector3.new(10.5, 11.4, .5), cf, C.ink, Enum.Material.Slate, 0, bay, false)
    part("Panel", Vector3.new(8.8, 9.5, .22), cf * CFrame.new(0,0,-.38), C.charcoal, Enum.Material.Fabric, 0, bay, false)
    for i=-2,2 do
        part("Rib"..i, Vector3.new(.11, 8.7, .18), cf * CFrame.new(i*1.65,0,-.55), C.metal, Enum.Material.Metal, 0, bay, false)
    end
    local sconce = cylinder("Sconce", Vector3.new(.35, .95, .95), cf * CFrame.new(0,1.1,-.68) * CFrame.Angles(0,0,math.rad(90)), C.black, Enum.Material.Metal, 0, bay, false)
    pointLight(sconce, accent or C.warm, .6, 10, true)
end

wallBay("WallBay_L1", -49.7, 4, 90, C.warm)
wallBay("WallBay_L2", -49.7, 22, 90, C.pink)
wallBay("WallBay_R1", 50.7, 4, -90, C.warm)
wallBay("WallBay_R2", 50.7, 25, -90, C.cyan)

-- Column cladding gives the room structural rhythm.
for i, spec in ipairs({{-27,-7},{-27,29},{33,-7},{33,29}}) do
    local x,z = spec[1],spec[2]
    part("ColumnCore"..i, Vector3.new(2.2, 18.5, 2.2), CFrame.new(x, 9.75, z), C.black, Enum.Material.Metal, 0, shell, false)
    part("ColumnFace"..i, Vector3.new(2.35, 11.0, .16), CFrame.new(x, 7.1, z-1.18), C.graphite, Enum.Material.Slate, 0, shell, false)
    local trim = neon("ColumnGlow"..i, Vector3.new(.055, 7.8, .06), CFrame.new(x, 7.2, z-1.29), (i%2==0) and C.cyan or C.pink, shell, .28)
    pointLight(trim, trim.Color, .18, 5, false)
end

-- CEILING ---------------------------------------------------------------------
local ceiling = model("CeilingArchitecture", architecture)
part("CeilingField", Vector3.new(84, .55, 54), CFrame.new(3, 20.6, 17), Color3.fromRGB(13,12,15), Enum.Material.Slate, 0, ceiling, false)

-- Coffered ceiling frame.
for _, z in ipairs({-5, 8, 21, 34, 45}) do
    part("CrossBeam"..z, Vector3.new(70, .85, .72), CFrame.new(3, 19.8, z), C.black, Enum.Material.Metal, 0, ceiling, false)
end
for _, x in ipairs({-26,-12,3,18,32}) do
    part("LongBeam"..x, Vector3.new(.72, .85, 52), CFrame.new(x, 19.8, 19), C.black, Enum.Material.Metal, 0, ceiling, false)
end

-- Hanging acoustic rafts add real ceiling depth.
for i, x in ipairs({-21,-11,-1,9,19,29}) do
    local z = (i%2==0) and 14 or 7
    part("AcousticRaft"..i, Vector3.new(7.2, .45, 10.8), CFrame.new(x, 18.7, z) * CFrame.Angles(0, math.rad((i%2==0) and 7 or -7), 0), Color3.fromRGB(27,24,29), Enum.Material.Fabric, 0, ceiling, false)
end

-- Central box-truss.
local truss = model("MainTruss", ceiling)
for _, z in ipairs({4, 18, 32}) do
    part("TrussCross"..z, Vector3.new(50,.32,.32), CFrame.new(3,17.7,z), C.metal, Enum.Material.Metal, 0, truss, false)
end
for _, x in ipairs({-20,26}) do
    part("TrussSide"..x, Vector3.new(.32,.32,29), CFrame.new(x,17.7,18), C.metal, Enum.Material.Metal, 0, truss, false)
end

-- Downlights and pendants: warm ambient, club colors only as accents.
local downlights = {
    {-19,-1,C.warm},{-7,-1,C.warm},{5,-1,C.pink},{17,-1,C.warm},{29,-1,C.cyan},
    {-19,13,C.warm},{-7,13,C.cyan},{5,13,C.warm},{17,13,C.pink},{29,13,C.warm},
    {-19,27,C.pink},{-7,27,C.warm},{5,27,C.cyan},{17,27,C.warm},{29,27,C.warm},
}
for i,v in ipairs(downlights) do
    local can = cylinder("Downlight"..i, Vector3.new(.42,1.05,1.05), CFrame.new(v[1],18.05,v[2])*CFrame.Angles(0,0,math.rad(90)), C.black, Enum.Material.Metal, 0, ceiling, false)
    spotLight(can, Enum.NormalId.Bottom, v[3], v[3] == C.warm and 1.15 or .58, 28, 48, true)
end

-- STAGE / LED ARCHITECTURE -----------------------------------------------------
local stage = model("PremiumStage", architecture)
part("StageDeck", Vector3.new(58, 2.1, 11.5), CFrame.new(3,2.05,43.0), C.charcoal, Enum.Material.Slate, 0, stage, true)
part("StageLip", Vector3.new(58,.55,.7), CFrame.new(3,3.15,37.35), C.black, Enum.Material.Metal, 0, stage, false)
local lip = neon("StageLipAccent", Vector3.new(48,.08,.08), CFrame.new(3,3.28,36.98), C.pink, stage, .18)
pointLight(lip, C.pink, .35, 10, false)

-- Multi-layer portal instead of one flat panel.
part("PortalBack", Vector3.new(58,14.0,1.0), CFrame.new(3,10.0,48.0), C.black, Enum.Material.Metal, 0, stage, false)
part("PortalTop", Vector3.new(58,1.1,2.1), CFrame.new(3,16.35,46.9), C.graphite, Enum.Material.Metal, 0, stage, false)
part("PortalLeft", Vector3.new(1.2,13.0,2.1), CFrame.new(-25,9.9,46.9), C.graphite, Enum.Material.Metal, 0, stage, false)
part("PortalRight", Vector3.new(1.2,13.0,2.1), CFrame.new(31,9.9,46.9), C.graphite, Enum.Material.Metal, 0, stage, false)

-- LED wall tiles with restrained texture/depth.
local led = model("LEDWall", stage)
for row=1,3 do
    for col=1,7 do
        local x = -18 + (col-1)*7
        local y = 6.2 + (row-1)*3.1
        local panel = part("Tile_"..row.."_"..col, Vector3.new(6.25,2.65,.18), CFrame.new(x+3,y,46.75), Color3.fromRGB(15,14,19), Enum.Material.Glass, .04, led, false)
        panel.Reflectance = .08
        local edgeColor = ((row+col)%5==0) and C.cyan or (((row+col)%4==0) and C.pink or C.graphite)
        part("TileTop_"..row.."_"..col, Vector3.new(5.7,.035,.05), CFrame.new(x+3,y+1.22,46.63), edgeColor, edgeColor == C.graphite and Enum.Material.Metal or Enum.Material.Neon, edgeColor == C.graphite and 0 or .35, led, false)
    end
end

-- Center BBYA logo as physical integrated display.
local logoPanel = part("LogoDisplay", Vector3.new(15.8,4.25,.16), CFrame.new(3,10.0,46.50), Color3.fromRGB(8,8,11), Enum.Material.Glass, .05, stage, false)
local gui = Instance.new("SurfaceGui")
gui.Face = Enum.NormalId.Front
gui.AlwaysOnTop = false
gui.LightInfluence = .4
gui.PixelsPerStud = 70
gui.Parent = logoPanel
local logo = Instance.new("TextLabel")
logo.BackgroundTransparency = 1
logo.Size = UDim2.fromScale(1,1)
logo.Text = "BBYA"
logo.TextColor3 = C.white
logo.Font = Enum.Font.GothamBlack
logo.TextScaled = true
logo.Parent = gui
local logoStroke = Instance.new("UIStroke")
logoStroke.Color = C.pink
logoStroke.Thickness = 2
logoStroke.Transparency = .18
logoStroke.Parent = logo

-- DJ BOOTH --------------------------------------------------------------------
local dj = model("DJBoothPremium", av)
part("DJPlatform", Vector3.new(23, .65, 8.5), CFrame.new(3,3.45,34.3), C.black, Enum.Material.Metal, 0, dj, true)

-- Faceted front gives a custom-built booth silhouette.
part("BoothCenter", Vector3.new(13.2,3.4,4.6), CFrame.new(3,5.0,31.7), C.ink, Enum.Material.Metal, 0, dj, true)
part("BoothWingL", Vector3.new(5.2,3.25,4.0), CFrame.new(-5.8,4.9,32.2)*CFrame.Angles(0,math.rad(-12),0), C.charcoal, Enum.Material.Metal, 0, dj, true)
part("BoothWingR", Vector3.new(5.2,3.25,4.0), CFrame.new(11.8,4.9,32.2)*CFrame.Angles(0,math.rad(12),0), C.charcoal, Enum.Material.Metal, 0, dj, true)
part("BoothTop", Vector3.new(20.5,.30,5.2), CFrame.new(3,6.76,31.7), C.marble, Enum.Material.Marble, 0, dj, false)
local boothAccent = neon("BoothAccent", Vector3.new(12.2,.07,.07), CFrame.new(3,5.65,29.35), C.pink, dj, .08)
pointLight(boothAccent, C.pink, .35, 8, false)

-- Detailed decks and mixer.
local gear = model("DJEquipment", dj)
part("Mixer", Vector3.new(4.0,.30,2.6), CFrame.new(3,7.05,31.8), C.black, Enum.Material.Metal, 0, gear, false)
for side,x in ipairs({-2.1,8.1}) do
    part("Deck"..side, Vector3.new(4.2,.30,3.1), CFrame.new(x,7.05,31.8), C.charcoal, Enum.Material.Metal, 0, gear, false)
    cylinder("Jog"..side, Vector3.new(.16,2.2,2.2), CFrame.new(x,7.29,31.8)*CFrame.Angles(0,0,math.rad(90)), C.metal, Enum.Material.Metal, 0, gear, false)
    neon("Display"..side, Vector3.new(1.05,.05,.52), CFrame.new(x+1.25,7.25,31.08), side==1 and C.cyan or C.pink, gear, .10)
end
for i=-4,4 do
    cylinder("Knob"..i, Vector3.new(.10,.16,.16), CFrame.new(3+i*.38,7.27,31.65)*CFrame.Angles(0,0,math.rad(90)), (i%3==0) and C.pink or C.cyan, Enum.Material.Neon, 0, gear, false)
end
-- Two compact DJ monitors.
for i,x in ipairs({-6.3,12.3}) do
    part("MonitorCab"..i, Vector3.new(3.0,2.6,2.3), CFrame.new(x,7.3,35.1)*CFrame.Angles(math.rad(-8),0,0), C.black, Enum.Material.Metal, 0, av, false)
    cylinder("MonitorDriver"..i, Vector3.new(.2,1.35,1.35), CFrame.new(x,7.3,33.9)*CFrame.Angles(0,math.rad(90),0), C.graphite, Enum.Material.SmoothPlastic, 0, av, false)
end

-- SPEAKER ARRAYS ---------------------------------------------------------------
local function speakerTower(name, x)
    local m = model(name, av)
    part("FlyFrame", Vector3.new(6.0,.35,3.5), CFrame.new(x,14.2,42.9), C.metal, Enum.Material.Metal, 0, m, false)
    for box=1,3 do
        local y = 11.7 - (box-1)*3.25
        part("Cabinet"..box, Vector3.new(5.8,2.95,3.2), CFrame.new(x,y,42.7)*CFrame.Angles(math.rad((box-2)*2),0,0), C.black, Enum.Material.Metal, 0, m, false)
        cylinder("DriverA"..box, Vector3.new(.22,1.35,1.35), CFrame.new(x-1.45,y,41.02)*CFrame.Angles(0,math.rad(90),0), Color3.fromRGB(29,28,32), Enum.Material.SmoothPlastic, 0, m, false)
        cylinder("DriverB"..box, Vector3.new(.22,1.35,1.35), CFrame.new(x+1.45,y,41.02)*CFrame.Angles(0,math.rad(90),0), Color3.fromRGB(29,28,32), Enum.Material.SmoothPlastic, 0, m, false)
    end
end
speakerTower("LineArray_L", -20.5)
speakerTower("LineArray_R", 26.5)

-- BAR -------------------------------------------------------------------------
local bar = model("MainBarPremium", furniture)
part("BarFloor", Vector3.new(22,.22,30), CFrame.new(42,.99,11), Color3.fromRGB(29,26,31), Enum.Material.Slate, 0, bar, true)
part("BackBarWall", Vector3.new(1.1,12.5,28), CFrame.new(51.2,7.0,11), C.ink, Enum.Material.Slate, 0, bar, false)

-- Counter carcass with stone top and wood front.
part("CounterBody", Vector3.new(4.3,3.25,25), CFrame.new(35.0,2.55,11), C.charcoal, Enum.Material.Metal, 0, bar, true)
part("CounterTop", Vector3.new(5.0,.32,25.6), CFrame.new(34.8,4.27,11), C.marble, Enum.Material.Marble, 0, bar, false)
for i=1,14 do
    local z = -1.0 + (i-1)*1.85
    part("WoodSlat"..i, Vector3.new(.16,2.55,1.22), CFrame.new(32.78,2.52,z), C.wood, Enum.Material.WoodPlanks, 0, bar, false)
end
local barUnder = neon("UnderBarWarm", Vector3.new(.07,.09,23.7), CFrame.new(32.66,1.28,11), C.warm, bar, .08)
pointLight(barUnder, C.warm, .48, 9, false)

-- Backbar illuminated niches.
for shelf,y in ipairs({3.4,6.3,9.2}) do
    part("Shelf"..shelf, Vector3.new(.65,.16,24.0), CFrame.new(50.48,y,11), C.black, Enum.Material.Metal, 0, bar, false)
    local light = neon("ShelfLight"..shelf, Vector3.new(.07,.07,22.8), CFrame.new(50.08,y-.06,11), shelf==2 and C.pink or C.warm, bar, .20)
    pointLight(light, light.Color, .22, 5, false)
end

local bottleColors = {
    Color3.fromRGB(179,123,65), Color3.fromRGB(68,113,94), Color3.fromRGB(105,82,126),
    Color3.fromRGB(194,158,80), Color3.fromRGB(123,69,68), Color3.fromRGB(68,104,130),
}
for row,y in ipairs({4.05,6.95,9.85}) do
    for i=1,12 do
        local z = .6 + (i-1)*1.9
        local color = bottleColors[((i+row-2)%#bottleColors)+1]
        local bottle = cylinder("Bottle_"..row.."_"..i, Vector3.new(.75,.30,.30), CFrame.new(49.95,y,z)*CFrame.Angles(0,0,math.rad(90)), color, Enum.Material.Glass, .05, dressing, false)
        bottle.Reflectance = .08
    end
end

-- Hanging bar pendants.
for i,z in ipairs({2.5,8.2,13.9,19.6}) do
    part("PendantCord"..i, Vector3.new(.06,3.0,.06), CFrame.new(41.5,16.1,z), C.black, Enum.Material.Metal, 0, bar, false)
    local shade = cylinder("Pendant"..i, Vector3.new(.65,1.25,1.25), CFrame.new(41.5,14.45,z)*CFrame.Angles(0,0,math.rad(90)), C.black, Enum.Material.Metal, 0, bar, false)
    pointLight(shade, C.warm, .85, 12, true)
end

local function stool(name, z)
    local m = model(name, furniture)
    cylinder("Base", Vector3.new(.15,1.9,1.9), CFrame.new(29.7,.18,z)*CFrame.Angles(0,0,math.rad(90)), C.black, Enum.Material.Metal, 0, m, false)
    cylinder("Stem", Vector3.new(2.15,.20,.20), CFrame.new(29.7,1.35,z)*CFrame.Angles(0,0,math.rad(90)), C.metal, Enum.Material.Metal, 0, m, false)
    cylinder("Seat", Vector3.new(.40,2.2,2.2), CFrame.new(29.7,2.58,z)*CFrame.Angles(0,0,math.rad(90)), C.fabric2, Enum.Material.Fabric, 0, m, false)
    cylinder("FootRing", Vector3.new(.08,1.3,1.3), CFrame.new(29.7,1.10,z)*CFrame.Angles(0,0,math.rad(90)), C.metal, Enum.Material.Metal, 0, m, false)
end
for i,z in ipairs({1,6,11,16,21}) do stool("BarStool_"..i,z) end

-- LOUNGE / VIP ----------------------------------------------------------------
local function sofa(name, pos, yaw, width, color)
    local m = model(name, furniture)
    local cf = CFrame.new(pos) * CFrame.Angles(0,math.rad(yaw),0)
    local w = width or 9
    part("Plinth", Vector3.new(w,.34,3.2), cf*CFrame.new(0,.45,0), C.black, Enum.Material.Metal, 0, m, false)
    part("Seat", Vector3.new(w-.6,1.0,3.3), cf*CFrame.new(0,1.15,0), color or C.fabric, Enum.Material.Fabric, 0, m, false)
    part("Back", Vector3.new(w-.55,2.65,.82), cf*CFrame.new(0,2.20,1.40), color or C.fabric, Enum.Material.Fabric, 0, m, false)
    part("ArmL", Vector3.new(.70,1.72,3.25), cf*CFrame.new(-(w/2-.35),1.52,0), C.fabric2, Enum.Material.Fabric, 0, m, false)
    part("ArmR", Vector3.new(.70,1.72,3.25), cf*CFrame.new((w/2-.35),1.52,0), C.fabric2, Enum.Material.Fabric, 0, m, false)
    local cushions = math.max(2,math.floor(w/3))
    for i=1,cushions do
        local x = -((cushions-1)*1.55)/2 + (i-1)*1.55
        part("Cushion"..i, Vector3.new(1.35,.38,1.25), cf*CFrame.new(x,1.75,.30)*CFrame.Angles(math.rad(-7),0,0), Color3.fromRGB(73,58,72), Enum.Material.Fabric, 0, m, false)
    end
end

local function tableRound(name,pos,diameter)
    local m = model(name,furniture)
    cylinder("Base", Vector3.new(.18,diameter*.60,diameter*.60), CFrame.new(pos.X,.20,pos.Z)*CFrame.Angles(0,0,math.rad(90)), C.black, Enum.Material.Metal, 0, m, false)
    cylinder("Stem", Vector3.new(1.25,.22,.22), CFrame.new(pos.X,1.0,pos.Z)*CFrame.Angles(0,0,math.rad(90)), C.metal, Enum.Material.Metal, 0, m, false)
    local top = cylinder("Top", Vector3.new(.15,diameter,diameter), CFrame.new(pos.X,1.68,pos.Z)*CFrame.Angles(0,0,math.rad(90)), C.glass, Enum.Material.Glass, .16, m, false)
    top.Reflectance=.12
end

-- Left lounge bays.
for i,z in ipairs({0,14,28}) do
    local bay = model("VIPBay_"..i,furniture)
    part("Platform", Vector3.new(17,.30,10.5), CFrame.new(-39,.98,z), Color3.fromRGB(29,27,32), Enum.Material.Slate, 0, bay, true)
    part("Rail", Vector3.new(.12,1.65,9.0), CFrame.new(-30.7,1.88,z), C.glass, Enum.Material.Glass, .40, bay, false)
    part("RailTop", Vector3.new(.18,.12,9.0), CFrame.new(-30.7,2.72,z), C.metal, Enum.Material.Metal, 0, bay, false)
    sofa("Sofa_"..i,Vector3.new(-44.3,1.1,z),-90,8.4,(i==2) and Color3.fromRGB(53,39,51) or C.fabric)
    tableRound("Table_"..i,Vector3.new(-35.7,.5,z),3.3)
end

-- Rear cocktail pockets near stage.
for i,pos in ipairs({Vector3.new(-15,.5,35),Vector3.new(-7,.5,37),Vector3.new(13,.5,37),Vector3.new(21,.5,35)}) do
    tableRound("RearCocktail_"..i,pos,2.6)
end

-- Decorative floor lamps beside VIP bays.
for i,spec in ipairs({{-47,7},{-47,21},{47,31}}) do
    local x,z = spec[1],spec[2]
    cylinder("LampBase"..i, Vector3.new(.16,1.25,1.25), CFrame.new(x,.18,z)*CFrame.Angles(0,0,math.rad(90)), C.black, Enum.Material.Metal, 0, dressing, false)
    part("LampStem"..i, Vector3.new(.16,5.3,.16), CFrame.new(x,2.85,z), C.metal, Enum.Material.Metal, 0, dressing, false)
    local shade = cylinder("LampShade"..i, Vector3.new(1.5,1.8,1.8), CFrame.new(x,5.55,z)*CFrame.Angles(0,0,math.rad(90)), Color3.fromRGB(45,37,42), Enum.Material.Fabric, 0, dressing, false)
    pointLight(shade,C.warm,.55,10,true)
end

-- PLANTERS --------------------------------------------------------------------
local function planter(name,pos)
    local m = model(name,dressing)
    cylinder("Pot",Vector3.new(1.55,2.6,2.6),CFrame.new(pos.X,1.3,pos.Z)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(30,29,33),Enum.Material.Slate,0,m,false)
    part("Stem",Vector3.new(.26,3.8,.26),CFrame.new(pos.X,3.9,pos.Z),Color3.fromRGB(49,65,53),Enum.Material.SmoothPlastic,0,m,false)
    for i=1,5 do
        local a=math.rad((i-1)*72)
        part("Leaf"..i,Vector3.new(.20,2.1,.65),CFrame.new(pos.X+math.cos(a)*.78,5.0,pos.Z+math.sin(a)*.78)*CFrame.Angles(math.rad(18),-a,0),Color3.fromRGB(52,78,59),Enum.Material.SmoothPlastic,0,m,false)
    end
end
planter("Planter_LFront",Vector3.new(-48,.5,-8))
planter("Planter_LRear",Vector3.new(-48,.5,36))
planter("Planter_RRear",Vector3.new(48,.5,34))

-- LIGHTING BASELINE -----------------------------------------------------------
-- Dark enough to feel like a club, bright enough to keep materials readable on mobile.
Lighting.Brightness = 1.55
Lighting.EnvironmentDiffuseScale = .34
Lighting.EnvironmentSpecularScale = .88
Lighting.ShadowSoftness = .32
Lighting.ExposureCompensation = -.20
Lighting.Ambient = Color3.fromRGB(30,27,34)
Lighting.OutdoorAmbient = Color3.fromRGB(20,18,25)

print("[BBYA] FLOOR 1 premium venue v3 loaded: architectural shell, coffered ceiling, custom stage/DJ, premium bar, VIP lounge and material-first lighting")
