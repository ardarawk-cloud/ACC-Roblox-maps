-- BBYA SOCIAL HUB — REFERENCE ARCHITECTURE V7
-- Deterministic macro build based on the approved BBYA visual reference.
-- Scope: architecture, massing, circulation, major destination placement only.
-- This script deliberately avoids music/admin/monetization logic.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local WORLD = Workspace:FindFirstChild("BBYA_WORLD") or Instance.new("Folder")
WORLD.Name = "BBYA_WORLD"
WORLD.Parent = Workspace

local OLD = WORLD:FindFirstChild("ReferenceArchitectureV7")
if OLD then OLD:Destroy() end

local root = Instance.new("Folder")
root.Name = "ReferenceArchitectureV7"
root.Parent = WORLD

local C = {
    black = Color3.fromRGB(10, 10, 16),
    charcoal = Color3.fromRGB(24, 24, 32),
    stone = Color3.fromRGB(38, 36, 44),
    glass = Color3.fromRGB(62, 91, 120),
    pink = Color3.fromRGB(255, 43, 170),
    blue = Color3.fromRGB(28, 161, 255),
    cyan = Color3.fromRGB(44, 235, 255),
    purple = Color3.fromRGB(120, 55, 220),
    warm = Color3.fromRGB(255, 183, 92),
    water = Color3.fromRGB(32, 168, 224),
    wood = Color3.fromRGB(84, 58, 47),
    green = Color3.fromRGB(34, 99, 67),
}

local function part(name, size, cf, color, material, transparency, canCollide, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.CanCollide = canCollide ~= false
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color or C.stone
    p.Transparency = transparency or 0
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or root
    return p
end

local function neon(name, size, cf, color, parent)
    local p = part(name, size, cf, color, Enum.Material.Neon, 0, false, parent)
    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = 1.2
    light.Range = 14
    light.Shadows = false
    light.Parent = p
    return p
end

local function sign(name, text, cf, size, color, parent)
    local b = part(name, size, cf, C.black, Enum.Material.SmoothPlastic, 0, false, parent)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 28
    gui.LightInfluence = 0
    gui.Parent = b
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Size = UDim2.fromScale(1, 1)
    t.Font = Enum.Font.GothamBlack
    t.Text = text
    t.TextScaled = true
    t.TextColor3 = color
    t.TextStrokeTransparency = 0.35
    t.Parent = gui
    return b
end

local function rail(name, cf, size, parent)
    return part(name, size, cf, C.glass, Enum.Material.Glass, 0.48, true, parent)
end

local function palm(name, pos, scale, parent)
    scale = scale or 1
    part(name .. "_Trunk", Vector3.new(1.5, 10, 1.5) * scale, CFrame.new(pos + Vector3.new(0, 5 * scale, 0)), Color3.fromRGB(84, 58, 40), Enum.Material.Wood, 0, true, parent)
    for i = 0, 5 do
        local a = math.rad(i * 60)
        part(name .. "_Leaf" .. i, Vector3.new(1.2, 0.3, 8) * scale,
            CFrame.new(pos + Vector3.new(0, 10.4 * scale, 0)) * CFrame.Angles(0, a, math.rad(-17)),
            C.green, Enum.Material.SmoothPlastic, 0, false, parent)
    end
end

-- Night baseline. Architectural build is intentionally readable before final lighting polish.
Lighting.ClockTime = 0.1
Lighting.Brightness = 1.8
Lighting.Ambient = Color3.fromRGB(24, 27, 48)
Lighting.OutdoorAmbient = Color3.fromRGB(10, 14, 30)

-- MASTER ENVELOPE: 180w x 220d, Ground=0, VIP=18, Rooftop=36.
local arrival = Instance.new("Folder"); arrival.Name = "A1_Arrival"; arrival.Parent = root
local facade = Instance.new("Folder"); facade.Name = "A2_Facade"; facade.Parent = root
local lobby = Instance.new("Folder"); lobby.Name = "A3_Lobby"; lobby.Parent = root
local club = Instance.new("Folder"); club.Name = "A4_MainClub"; club.Parent = root
local vip = Instance.new("Folder"); vip.Name = "C_VIP"; vip.Parent = root
local roof = Instance.new("Folder"); roof.Name = "D_Rooftop"; roof.Parent = root

-- A1 / ARRIVAL PLAZA
part("ArrivalPlaza", Vector3.new(172, 2, 64), CFrame.new(0, -1, 108), C.stone, Enum.Material.Slate, 0, true, arrival)
part("ArrivalAxis", Vector3.new(40, 0.3, 64), CFrame.new(0, 0.2, 108), Color3.fromRGB(28, 28, 38), Enum.Material.Marble, 0, true, arrival)
for _, x in ipairs({-72, -55, 55, 72}) do palm("Palm" .. x, Vector3.new(x, 0, 112), 1.15, arrival) end
for _, x in ipairs({-30, -15, 0, 15, 30}) do neon("Path" .. x, Vector3.new(10, .18, .8), CFrame.new(x, .2, 120), (x == 0) and C.pink or C.blue, arrival) end

-- A2 / ICONIC FAÇADE: strong central BBYA identity, stepped side masses, 40-stud clear entrance.
part("FacadeLeftMass", Vector3.new(60, 32, 12), CFrame.new(-60, 16, 76), C.black, Enum.Material.Slate, 0, true, facade)
part("FacadeRightMass", Vector3.new(60, 32, 12), CFrame.new(60, 16, 76), C.black, Enum.Material.Slate, 0, true, facade)
part("FacadeUpperBridge", Vector3.new(62, 7, 12), CFrame.new(0, 28.5, 76), C.black, Enum.Material.Metal, 0, true, facade)
part("FacadeLeftBlade", Vector3.new(5, 38, 14), CFrame.new(-34, 19, 74) * CFrame.Angles(0, math.rad(-7), 0), C.charcoal, Enum.Material.Metal, 0, true, facade)
part("FacadeRightBlade", Vector3.new(5, 38, 14), CFrame.new(34, 19, 74) * CFrame.Angles(0, math.rad(7), 0), C.charcoal, Enum.Material.Metal, 0, true, facade)
neon("FacadePinkLine", Vector3.new(118, .5, .5), CFrame.new(0, 31, 69.8), C.pink, facade)
neon("FacadeBlueLine", Vector3.new(150, .35, .35), CFrame.new(0, 17, 69.7), C.blue, facade)
sign("BBYA_MasterSign", "BBYA", CFrame.new(0, 33, 69.6), Vector3.new(60, 12, .6), C.pink, facade)
sign("BBYA_SubSign", "SOCIAL HUB • 24/7", CFrame.new(0, 24, 69.5), Vector3.new(43, 5, .5), C.cyan, facade)

-- A3 / LOBBY: direct sightline to club. Side service volumes leave 40-stud center clear.
part("LobbyFloor", Vector3.new(120, 2, 42), CFrame.new(0, 0, 52), C.black, Enum.Material.Marble, 0, true, lobby)
part("LobbyLeftService", Vector3.new(34, 18, 36), CFrame.new(-43, 9, 52), C.charcoal, Enum.Material.Slate, 0, true, lobby)
part("LobbyRightService", Vector3.new(34, 18, 36), CFrame.new(43, 9, 52), C.charcoal, Enum.Material.Slate, 0, true, lobby)
for _, x in ipairs({-58, 58}) do neon("LobbyVertical" .. x, Vector3.new(.5, 15, .5), CFrame.new(x, 9, 34), x < 0 and C.blue or C.pink, lobby) end
sign("LobbyDirection", "MAIN CLUB  ↑   •   VIP / ROOFTOP", CFrame.new(0, 11, 31), Vector3.new(44, 4, .5), C.cyan, lobby)

-- A4 / MAIN CLUB: open double-height hall, integrated rear stage, wrap mezzanines.
part("ClubFloor", Vector3.new(116, 2, 142), CFrame.new(0, 0, -20), C.black, Enum.Material.Marble, 0, true, club)
part("DanceFloor", Vector3.new(72, .5, 72), CFrame.new(0, 1.1, -12), Color3.fromRGB(24, 20, 37), Enum.Material.Glass, .08, true, club)
for i = -3, 3 do
    neon("DanceLineX" .. i, Vector3.new(.3, .15, 68), CFrame.new(i * 10, 1.4, -12), (i % 2 == 0) and C.pink or C.blue, club)
    neon("DanceLineZ" .. i, Vector3.new(68, .15, .3), CFrame.new(0, 1.4, -12 + i * 10), (i % 2 == 0) and C.blue or C.pink, club)
end

-- Integrated festival stage at rear.
part("StageBase", Vector3.new(84, 4, 24), CFrame.new(0, 2, -78), C.charcoal, Enum.Material.Metal, 0, true, club)
part("StageBack", Vector3.new(94, 26, 4), CFrame.new(0, 14, -88), C.black, Enum.Material.Metal, 0, true, club)
part("DJBooth", Vector3.new(30, 5, 8), CFrame.new(0, 6, -72), C.black, Enum.Material.Metal, 0, true, club)
sign("StageLogo", "♛ BBYA", CFrame.new(0, 17, -85.8), Vector3.new(48, 10, .6), C.pink, club)
for _, x in ipairs({-36, -18, 0, 18, 36}) do
    neon("StageLight" .. x, Vector3.new(7, .6, .6), CFrame.new(x, 23, -84), x % 36 == 0 and C.pink or C.blue, club)
end

-- Side balconies and rear bridge: reference-like layered club view.
part("VIPWestMezz", Vector3.new(28, 2, 112), CFrame.new(-72, 18, -14), C.stone, Enum.Material.Slate, 0, true, vip)
part("VIPEastMezz", Vector3.new(28, 2, 112), CFrame.new(72, 18, -14), C.stone, Enum.Material.Slate, 0, true, vip)
part("VIPFrontBridge", Vector3.new(116, 2, 18), CFrame.new(0, 18, 34), C.stone, Enum.Material.Slate, 0, true, vip)
part("VIPRearBridge", Vector3.new(116, 2, 18), CFrame.new(0, 18, -63), C.stone, Enum.Material.Slate, 0, true, vip)
rail("WestInnerRail", CFrame.new(-58, 22, -14), Vector3.new(1, 7, 110), vip)
rail("EastInnerRail", CFrame.new(58, 22, -14), Vector3.new(1, 7, 110), vip)
rail("FrontBridgeRail", CFrame.new(0, 22, 25), Vector3.new(112, 7, 1), vip)

-- Main bar is visually open to club but outside dance circulation.
part("MainBarDeck", Vector3.new(30, 2, 48), CFrame.new(-73, 0, 35), C.charcoal, Enum.Material.Slate, 0, true, club)
part("MainBarCounter", Vector3.new(24, 4, 6), CFrame.new(-73, 3, 25), C.black, Enum.Material.Marble, 0, true, club)
sign("MainBarSign", "BAR", CFrame.new(-73, 10, 22), Vector3.new(20, 4, .5), C.pink, club)

-- Queen private skybox: prominent rear-center, separated from normal flow.
local queen = Instance.new("Folder"); queen.Name = "C3_Queen"; queen.Parent = vip
part("QueenPlatform", Vector3.new(44, 2, 24), CFrame.new(0, 25, -56), C.black, Enum.Material.Marble, 0, true, queen)
part("QueenBackWall", Vector3.new(44, 16, 2), CFrame.new(0, 32, -67), C.black, Enum.Material.Slate, 0, true, queen)
rail("QueenFrontGlass", CFrame.new(0, 29, -44.5), Vector3.new(44, 7, 1), queen)
sign("QueenSign", "♛  BBYA QUEEN  ♛", CFrame.new(0, 35, -65.8), Vector3.new(34, 6, .5), C.pink, queen)
local throne = Instance.new("Seat")
throne.Name = "BBYA_QUEEN_THRONE"
throne.Size = Vector3.new(8, 3, 7)
throne.CFrame = CFrame.new(0, 28, -59)
throne.Anchored = true
throne.Material = Enum.Material.Fabric
throne.Color = Color3.fromRGB(79, 29, 85)
throne.Parent = queen

-- D / ROOFTOP: separate luxury resort mood with restrained neon.
part("RoofSlab", Vector3.new(176, 2, 150), CFrame.new(0, 36, -3), C.stone, Enum.Material.Slate, 0, true, roof)
-- Keep 16-stud central N/S spine open.
part("RoofArrival", Vector3.new(42, 1, 22), CFrame.new(0, 37.2, 54), Color3.fromRGB(66, 55, 49), Enum.Material.WoodPlanks, 0, true, roof)
sign("RoofWelcome", "ROOFTOP POOL PARTY", CFrame.new(0, 45, 42), Vector3.new(38, 5, .5), C.cyan, roof)

-- Pool rear-center.
part("PoolBasin", Vector3.new(78, 2, 42), CFrame.new(0, 38, -28), C.water, Enum.Material.Glass, .25, false, roof)
neon("InfinityEdge", Vector3.new(78, .35, .35), CFrame.new(0, 39.1, -49), C.cyan, roof)
rail("PoolRearGlass", CFrame.new(0, 41, -51), Vector3.new(90, 7, 1), roof)

-- Sky bar west, chill east.
part("SkyBarDeck", Vector3.new(40, 1, 34), CFrame.new(-61, 37.2, 12), C.wood, Enum.Material.WoodPlanks, 0, true, roof)
part("SkyBarCounter", Vector3.new(30, 4, 6), CFrame.new(-61, 40, 3), C.black, Enum.Material.Marble, 0, true, roof)
sign("SkyBarSign", "SKY BAR", CFrame.new(-61, 46, 0), Vector3.new(24, 4, .5), C.warm, roof)
part("RoofChillDeck", Vector3.new(40, 1, 34), CFrame.new(61, 37.2, 12), C.wood, Enum.Material.WoodPlanks, 0, true, roof)
sign("RoofChillSign", "CHILL LOUNGE", CFrame.new(61, 45, 0), Vector3.new(26, 4, .5), C.warm, roof)

-- Cabanas flank pool without blocking central spine.
for _, x in ipairs({-58, 58}) do
    for _, z in ipairs({-28, -7}) do
        part("CabanaDeck_" .. x .. "_" .. z, Vector3.new(28, 1, 18), CFrame.new(x, 37.4, z), C.wood, Enum.Material.WoodPlanks, 0, true, roof)
        part("CabanaRoof_" .. x .. "_" .. z, Vector3.new(28, 1, 18), CFrame.new(x, 47, z), C.charcoal, Enum.Material.Fabric, 0, false, roof)
        for _, dx in ipairs({-12, 12}) do
            for _, dz in ipairs({-7, 7}) do
                part("CabanaPost", Vector3.new(1, 10, 1), CFrame.new(x + dx, 42, z + dz), C.black, Enum.Material.Metal, 0, true, roof)
            end
        end
    end
end

-- Pool DJ at front of pool; keeps central arrival spine readable.
part("PoolDJDeck", Vector3.new(34, 3, 14), CFrame.new(0, 39, 26), C.black, Enum.Material.Metal, 0, true, roof)
sign("PoolDJSign", "BBYA POOL DJ", CFrame.new(0, 45, 19), Vector3.new(28, 4, .5), C.pink, roof)

-- Rooftop palms as framing, not circulation blockers.
for _, pos in ipairs({Vector3.new(-82,37,48), Vector3.new(82,37,48), Vector3.new(-82,37,-55), Vector3.new(82,37,-55)}) do
    palm("RoofPalm", pos, 1.05, roof)
end

-- Skyline silhouettes, intentionally low-cost and fictional.
local skyline = Instance.new("Folder"); skyline.Name = "Skyline"; skyline.Parent = root
for i = 1, 18 do
    local x = -190 + (i * 21)
    local h = 28 + ((i * 13) % 58)
    local z = -190 - ((i * 17) % 55)
    local tower = part("Tower" .. i, Vector3.new(12 + (i % 4) * 3, h, 12), CFrame.new(x, h/2, z), Color3.fromRGB(17, 21, 34), Enum.Material.SmoothPlastic, 0, false, skyline)
    neon("TowerTop" .. i, Vector3.new(tower.Size.X - 2, .25, .25), CFrame.new(x, h - 2, z + 6.1), (i % 2 == 0) and C.blue or C.pink, skyline)
end

-- Architectural debug anchors used for screenshot/QC references.
local markers = Instance.new("Folder"); markers.Name = "QC_Markers"; markers.Parent = root
local destinations = {
    {"A1", Vector3.new(0, 2, 120)}, {"A2", Vector3.new(0, 6, 76)}, {"A3", Vector3.new(0, 4, 52)},
    {"A4", Vector3.new(0, 4, -12)}, {"C1", Vector3.new(-72, 22, -10)}, {"C2", Vector3.new(72, 22, -10)},
    {"C3", Vector3.new(0, 30, -56)}, {"D1", Vector3.new(0, 41, 54)}, {"D2", Vector3.new(0, 41, -28)},
}
for _, item in ipairs(destinations) do
    local m = part("Marker_" .. item[1], Vector3.new(2, 2, 2), CFrame.new(item[2]), C.cyan, Enum.Material.Neon, .5, false, markers)
    m:SetAttribute("BBYACode", item[1])
end

root:SetAttribute("Build", "BBYA_REFERENCE_ARCH_V7")
root:SetAttribute("Phase", "A_ARCHITECTURE")
root:SetAttribute("Envelope", "180x220")
root:SetAttribute("GroundY", 0)
root:SetAttribute("VIPY", 18)
root:SetAttribute("RooftopY", 36)

print("[BBYA] ReferenceArchitectureV7 generated")
