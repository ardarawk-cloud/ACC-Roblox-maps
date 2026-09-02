-- ZONA PERANG world authority v0.3.1
-- RUNTIME_VISIBLE_MAP_V1: simple, deterministic geometry first. No full Workspace wipe.
local Workspace = game:GetService("Workspace")
local Teams = game:GetService("Teams")

local BUILD = "FPS-PROTOTYPE-0.3.1"
local MAP_NAME = "FPS_URBAN_BLOCK"

local function ensureTeam(name, brickColor)
    local t = Teams:FindFirstChild(name) or Instance.new("Team")
    t.Name = name
    t.TeamColor = brickColor
    t.AutoAssignable = false
    t.Parent = Teams
    return t
end

local function makePart(parent, name, size, position, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.CanCollide = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Color = color
    p.Material = material or Enum.Material.Concrete
    p.Parent = parent
    return p
end

local function makeSpawn(name, position, teamColor)
    local old = Workspace:FindFirstChild(name)
    if old then old:Destroy() end
    local s = Instance.new("SpawnLocation")
    s.Name = name
    s.Size = Vector3.new(14, 1, 14)
    s.Position = position
    s.Anchored = true
    s.CanCollide = true
    s.Neutral = false
    s.TeamColor = teamColor
    s.BrickColor = teamColor
    s.Transparency = 0.15
    s.Material = Enum.Material.Metal
    s.Parent = Workspace
    return s
end

local oldMap = Workspace:FindFirstChild(MAP_NAME)
if oldMap then oldMap:Destroy() end
local oldMarker = Workspace:FindFirstChild("BBYAVATAR_FPS_BUILD")
if oldMarker then oldMarker:Destroy() end

Workspace.FallenPartsDestroyHeight = -120

local alpha = ensureTeam("ALPHA", BrickColor.new("Bright blue"))
local bravo = ensureTeam("BRAVO", BrickColor.new("Bright red"))

local map = Instance.new("Folder")
map.Name = MAP_NAME
map.Parent = Workspace

local GROUND = Color3.fromRGB(69, 71, 76)
local ROAD = Color3.fromRGB(43, 45, 50)
local CONCRETE = Color3.fromRGB(98, 101, 108)
local DARK = Color3.fromRGB(38, 41, 47)
local METAL = Color3.fromRGB(72, 77, 85)
local BLUE = Color3.fromRGB(58, 133, 217)
local RED = Color3.fromRGB(204, 72, 66)
local YELLOW = Color3.fromRGB(221, 190, 76)
local RUST = Color3.fromRGB(126, 78, 57)
local GREEN = Color3.fromRGB(74, 101, 77)

-- FOUNDATION. This must exist before every decorative object.
makePart(map, "Ground", Vector3.new(520, 8, 420), Vector3.new(0, -4, 0), GROUND)
makePart(map, "NorthBoundary", Vector3.new(520, 24, 6), Vector3.new(0, 12, -210), DARK)
makePart(map, "SouthBoundary", Vector3.new(520, 24, 6), Vector3.new(0, 12, 210), DARK)
makePart(map, "WestBoundary", Vector3.new(6, 24, 420), Vector3.new(-260, 12, 0), DARK)
makePart(map, "EastBoundary", Vector3.new(6, 24, 420), Vector3.new(260, 12, 0), DARK)

-- Roads make the three combat lanes immediately readable.
makePart(map, "MainRoad", Vector3.new(470, 0.6, 56), Vector3.new(0, 0.35, 0), ROAD)
makePart(map, "NorthRoad", Vector3.new(470, 0.6, 44), Vector3.new(0, 0.36, -126), ROAD)
makePart(map, "SouthRoad", Vector3.new(470, 0.6, 44), Vector3.new(0, 0.36, 126), ROAD)
makePart(map, "CenterCrossRoad", Vector3.new(58, 0.65, 382), Vector3.new(0, 0.38, 0), ROAD)
makePart(map, "WestCrossRoad", Vector3.new(44, 0.65, 360), Vector3.new(-132, 0.39, 0), ROAD)
makePart(map, "EastCrossRoad", Vector3.new(44, 0.65, 360), Vector3.new(132, 0.39, 0), ROAD)

for x = -210, 210, 30 do
    local stripe = makePart(map, "RoadStripe", Vector3.new(13, 0.1, 1), Vector3.new(x, 0.72, 0), YELLOW, Enum.Material.SmoothPlastic)
    stripe.CanCollide = false
end
for z = -180, 180, 30 do
    local stripe = makePart(map, "CrossStripe", Vector3.new(1, 0.1, 13), Vector3.new(0, 0.74, z), YELLOW, Enum.Material.SmoothPlastic)
    stripe.CanCollide = false
end

-- Team bases. Covers are split so exits are never blocked.
makePart(map, "AlphaSpawnDeck", Vector3.new(54, 1, 154), Vector3.new(-222, 0.25, 0), Color3.fromRGB(49, 66, 86), Enum.Material.Metal)
makePart(map, "BravoSpawnDeck", Vector3.new(54, 1, 154), Vector3.new(222, 0.25, 0), Color3.fromRGB(87, 52, 52), Enum.Material.Metal)
makePart(map, "AlphaRearWall", Vector3.new(6, 18, 154), Vector3.new(-252, 9, 0), DARK)
makePart(map, "BravoRearWall", Vector3.new(6, 18, 154), Vector3.new(252, 9, 0), DARK)
makePart(map, "AlphaCoverNorth", Vector3.new(8, 10, 48), Vector3.new(-197, 5, -59), BLUE, Enum.Material.Metal)
makePart(map, "AlphaCoverSouth", Vector3.new(8, 10, 48), Vector3.new(-197, 5, 59), BLUE, Enum.Material.Metal)
makePart(map, "BravoCoverNorth", Vector3.new(8, 10, 48), Vector3.new(197, 5, -59), RED, Enum.Material.Metal)
makePart(map, "BravoCoverSouth", Vector3.new(8, 10, 48), Vector3.new(197, 5, 59), RED, Enum.Material.Metal)

makeSpawn("AlphaSpawn1", Vector3.new(-222, 1, -48), alpha.TeamColor)
makeSpawn("AlphaSpawn2", Vector3.new(-222, 1, 48), alpha.TeamColor)
makeSpawn("BravoSpawn1", Vector3.new(222, 1, -48), bravo.TeamColor)
makeSpawn("BravoSpawn2", Vector3.new(222, 1, 48), bravo.TeamColor)

-- Central warehouse with large real door openings on every side.
makePart(map, "WarehouseFloor", Vector3.new(126, 1, 106), Vector3.new(0, 0.65, 0), CONCRETE)
makePart(map, "WarehouseNorthLeft", Vector3.new(46, 22, 5), Vector3.new(-40, 11, -53), METAL, Enum.Material.Metal)
makePart(map, "WarehouseNorthRight", Vector3.new(46, 22, 5), Vector3.new(40, 11, -53), METAL, Enum.Material.Metal)
makePart(map, "WarehouseSouthLeft", Vector3.new(46, 22, 5), Vector3.new(-40, 11, 53), METAL, Enum.Material.Metal)
makePart(map, "WarehouseSouthRight", Vector3.new(46, 22, 5), Vector3.new(40, 11, 53), METAL, Enum.Material.Metal)
makePart(map, "WarehouseWestNorth", Vector3.new(5, 22, 36), Vector3.new(-63, 11, -35), METAL, Enum.Material.Metal)
makePart(map, "WarehouseWestSouth", Vector3.new(5, 22, 36), Vector3.new(-63, 11, 35), METAL, Enum.Material.Metal)
makePart(map, "WarehouseEastNorth", Vector3.new(5, 22, 36), Vector3.new(63, 11, -35), METAL, Enum.Material.Metal)
makePart(map, "WarehouseEastSouth", Vector3.new(5, 22, 36), Vector3.new(63, 11, 35), METAL, Enum.Material.Metal)
makePart(map, "WarehouseRoofLeft", Vector3.new(63, 1, 106), Vector3.new(-31.5, 22.5, 0), DARK, Enum.Material.Metal)
makePart(map, "WarehouseRoofRight", Vector3.new(63, 1, 106), Vector3.new(31.5, 22.5, 0), DARK, Enum.Material.Metal)
makePart(map, "WarehouseCenterTower", Vector3.new(18, 34, 18), Vector3.new(0, 17, 0), Color3.fromRGB(54, 58, 65), Enum.Material.Metal)
makePart(map, "WarehouseCoverA", Vector3.new(20, 6, 7), Vector3.new(-30, 3, -20), CONCRETE)
makePart(map, "WarehouseCoverB", Vector3.new(20, 6, 7), Vector3.new(30, 3, 20), CONCRETE)
makePart(map, "WarehouseCoverC", Vector3.new(7, 6, 20), Vector3.new(-20, 3, 26), CONCRETE)
makePart(map, "WarehouseCoverD", Vector3.new(7, 6, 20), Vector3.new(20, 3, -26), CONCRETE)

-- Urban building blocks around the warehouse.
local buildings = {
    {-118, -92, 58, 28, 52}, {-118, 92, 64, 34, 48},
    {118, -92, 64, 32, 50}, {118, 92, 58, 25, 54},
    {-202, -150, 48, 24, 44}, {-202, 150, 54, 30, 42},
    {202, -150, 54, 29, 42}, {202, 150, 48, 24, 44},
}
for i, b in ipairs(buildings) do
    local x, z, w, h, d = b[1], b[2], b[3], b[4], b[5]
    makePart(map, "Office_" .. i, Vector3.new(w, h, d), Vector3.new(x, h / 2, z), i % 2 == 0 and Color3.fromRGB(83, 87, 94) or Color3.fromRGB(91, 94, 100))
    makePart(map, "OfficeRoof_" .. i, Vector3.new(w + 4, 1, d + 4), Vector3.new(x, h + 0.5, z), DARK, Enum.Material.Metal)
end

-- Container yards / hard cover.
local containers = {
    {-95, 4, -155, RUST}, {-95, 12, -155, Color3.fromRGB(76, 97, 112)},
    {-150, 4, 72, GREEN}, {95, 4, 155, Color3.fromRGB(105, 89, 69)},
    {95, 12, 155, Color3.fromRGB(72, 89, 109)}, {150, 4, -72, RUST},
}
for i, c in ipairs(containers) do
    makePart(map, "Container_" .. i, Vector3.new(30, 8, 11), Vector3.new(c[1], c[2], c[3]), c[4], Enum.Material.Metal)
end

local covers = {
    {-170,-92},{-166,-24},{-168,86},{-145,126},
    {170,92},{166,24},{168,-86},{145,-126},
    {-82,-78},{82,78},{-82,78},{82,-78},
    {-42,118},{42,-118},{-42,-118},{42,118},
}
for i, c in ipairs(covers) do
    makePart(map, "Cover_" .. i, Vector3.new(14, 5, 5), Vector3.new(c[1], 2.5, c[2]), CONCRETE)
end

-- Tall landmarks ensure the battlefield is visible from either spawn immediately.
makePart(map, "AlphaTower", Vector3.new(18, 42, 18), Vector3.new(-228, 21, -150), Color3.fromRGB(50, 67, 86))
makePart(map, "BravoTower", Vector3.new(18, 42, 18), Vector3.new(228, 21, 150), Color3.fromRGB(86, 52, 52))
local alphaBeacon = makePart(map, "AlphaBeacon", Vector3.new(5, 20, 5), Vector3.new(-228, 52, -150), BLUE, Enum.Material.Neon)
alphaBeacon.CanCollide = false
local bravoBeacon = makePart(map, "BravoBeacon", Vector3.new(5, 20, 5), Vector3.new(228, 52, 150), RED, Enum.Material.Neon)
bravoBeacon.CanCollide = false

local marker = Instance.new("StringValue")
marker.Name = "BBYAVATAR_FPS_BUILD"
marker.Value = BUILD
marker.Parent = Workspace

map:SetAttribute("MapReady", true)
map:SetAttribute("Build", BUILD)
print("[ZONA PERANG] ZONA_MAP_READY_031 — visible urban battlefield created")
