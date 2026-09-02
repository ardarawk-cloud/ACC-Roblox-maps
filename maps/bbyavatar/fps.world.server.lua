-- BBYAVATAR FPS world v0.3.0 — MAP FIRST / fail-safe urban battlefield
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Teams = game:GetService("Teams")

local BUILD = "FPS-PROTOTYPE-0.3.0"
local MAP_NAME = "FPS_URBAN_BLOCK"

local function part(name, size, cf, color, material, parent, collide)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.CanCollide = collide ~= false
    p.CanTouch = collide ~= false
    p.CanQuery = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Color = color or Color3.fromRGB(90,94,100)
    p.Material = material or Enum.Material.Concrete
    p.Parent = parent or Workspace
    return p
end

local function team(name, color)
    local t = Teams:FindFirstChild(name) or Instance.new("Team")
    t.Name = name
    t.TeamColor = color
    t.AutoAssignable = false
    t.Parent = Teams
    return t
end

local function spawn(name, position, teamColor, parent)
    local s = Instance.new("SpawnLocation")
    s.Name = name
    s.Size = Vector3.new(14,1,14)
    s.Position = position
    s.Anchored = true
    s.Neutral = false
    s.TeamColor = teamColor
    s.BrickColor = teamColor
    s.Material = Enum.Material.Metal
    s.Transparency = 0.1
    s.CanCollide = true
    s.Parent = parent or Workspace
    return s
end

local function safeSection(label, fn)
    local ok, err = pcall(fn)
    if not ok then
        warn("[ZONA PERANG MAP] "..label.." failed: "..tostring(err))
    end
end

-- Never wipe the whole Workspace. Only replace our generated battlefield.
local oldMap = Workspace:FindFirstChild(MAP_NAME)
if oldMap then oldMap:Destroy() end
for _, name in ipairs({"AlphaSpawn1","AlphaSpawn2","BravoSpawn1","BravoSpawn2","BBYAVATAR_FPS_BUILD"}) do
    local old = Workspace:FindFirstChild(name)
    if old then old:Destroy() end
end

Workspace.FallenPartsDestroyHeight = -150

local alpha = team("ALPHA", BrickColor.new("Bright blue"))
local bravo = team("BRAVO", BrickColor.new("Bright red"))

local map = Instance.new("Folder")
map.Name = MAP_NAME
map.Parent = Workspace

local C_GROUND = Color3.fromRGB(60,62,66)
local C_ROAD = Color3.fromRGB(42,44,48)
local C_CONCRETE = Color3.fromRGB(93,96,102)
local C_DARK = Color3.fromRGB(39,42,47)
local C_METAL = Color3.fromRGB(73,78,86)
local C_RUST = Color3.fromRGB(111,72,57)
local C_BLUE = Color3.fromRGB(72,142,210)
local C_RED = Color3.fromRGB(194,78,70)
local C_GLASS = Color3.fromRGB(122,151,172)
local C_YELLOW = Color3.fromRGB(202,178,92)

-- CRITICAL FAIL-SAFE FOUNDATION: these are built before any decorative section.
part("Ground", Vector3.new(520,8,420), CFrame.new(0,-4,0), C_GROUND, Enum.Material.Concrete, map, true)
part("NorthWall", Vector3.new(520,34,6), CFrame.new(0,13,-210), C_DARK, Enum.Material.Concrete, map, true)
part("SouthWall", Vector3.new(520,34,6), CFrame.new(0,13,210), C_DARK, Enum.Material.Concrete, map, true)
part("WestWall", Vector3.new(6,34,420), CFrame.new(-260,13,0), C_DARK, Enum.Material.Concrete, map, true)
part("EastWall", Vector3.new(6,34,420), CFrame.new(260,13,0), C_DARK, Enum.Material.Concrete, map, true)

spawn("AlphaSpawn1", Vector3.new(-220,0.6,-58), alpha.TeamColor, Workspace)
spawn("AlphaSpawn2", Vector3.new(-220,0.6,58), alpha.TeamColor, Workspace)
spawn("BravoSpawn1", Vector3.new(220,0.6,-58), bravo.TeamColor, Workspace)
spawn("BravoSpawn2", Vector3.new(220,0.6,58), bravo.TeamColor, Workspace)

part("AlphaSpawnDeck", Vector3.new(54,1,150), CFrame.new(-220,0.15,0), Color3.fromRGB(49,67,84), Enum.Material.Metal, map, true)
part("BravoSpawnDeck", Vector3.new(54,1,150), CFrame.new(220,0.15,0), Color3.fromRGB(82,52,52), Enum.Material.Metal, map, true)
part("AlphaSpawnShield", Vector3.new(8,18,150), CFrame.new(-190,9,0), Color3.fromRGB(48,61,75), Enum.Material.Concrete, map, true)
part("BravoSpawnShield", Vector3.new(8,18,150), CFrame.new(190,9,0), Color3.fromRGB(75,48,48), Enum.Material.Concrete, map, true)

-- Main road grid: immediately gives the player a visible horizon and playable lanes.
part("MainRoadEW", Vector3.new(460,0.5,56), CFrame.new(0,0.3,0), C_ROAD, Enum.Material.Concrete, map, true)
part("MainRoadNS", Vector3.new(62,0.52,372), CFrame.new(0,0.32,0), C_ROAD, Enum.Material.Concrete, map, true)
part("NorthRoad", Vector3.new(460,0.48,40), CFrame.new(0,0.31,-132), C_ROAD, Enum.Material.Concrete, map, true)
part("SouthRoad", Vector3.new(460,0.48,40), CFrame.new(0,0.31,132), C_ROAD, Enum.Material.Concrete, map, true)
part("WestLane", Vector3.new(44,0.5,360), CFrame.new(-128,0.32,0), C_ROAD, Enum.Material.Concrete, map, true)
part("EastLane", Vector3.new(44,0.5,360), CFrame.new(128,0.32,0), C_ROAD, Enum.Material.Concrete, map, true)

safeSection("road markings", function()
    for x=-210,210,28 do
        part("RoadMarkEW", Vector3.new(12,0.08,0.8), CFrame.new(x,0.62,0), C_YELLOW, Enum.Material.SmoothPlastic, map, false)
    end
    for z=-176,176,28 do
        part("RoadMarkNS", Vector3.new(0.8,0.08,12), CFrame.new(0,0.64,z), C_YELLOW, Enum.Material.SmoothPlastic, map, false)
    end
end)

-- Central warehouse compound with real openings on all four sides.
part("WarehouseFloor", Vector3.new(124,1,104), CFrame.new(0,0.65,0), Color3.fromRGB(76,79,84), Enum.Material.Concrete, map, true)
part("WarehouseWallN_L", Vector3.new(48,24,5), CFrame.new(-38,12,-52), C_METAL, Enum.Material.Metal, map, true)
part("WarehouseWallN_R", Vector3.new(48,24,5), CFrame.new(38,12,-52), C_METAL, Enum.Material.Metal, map, true)
part("WarehouseWallS_L", Vector3.new(48,24,5), CFrame.new(-38,12,52), C_METAL, Enum.Material.Metal, map, true)
part("WarehouseWallS_R", Vector3.new(48,24,5), CFrame.new(38,12,52), C_METAL, Enum.Material.Metal, map, true)
part("WarehouseWallW_N", Vector3.new(5,24,38), CFrame.new(-62,12,-33), C_METAL, Enum.Material.Metal, map, true)
part("WarehouseWallW_S", Vector3.new(5,24,38), CFrame.new(-62,12,33), C_METAL, Enum.Material.Metal, map, true)
part("WarehouseWallE_N", Vector3.new(5,24,38), CFrame.new(62,12,-33), C_METAL, Enum.Material.Metal, map, true)
part("WarehouseWallE_S", Vector3.new(5,24,38), CFrame.new(62,12,33), C_METAL, Enum.Material.Metal, map, true)
part("WarehouseRoofL", Vector3.new(62,1.2,104), CFrame.new(-31,24.6,0), C_DARK, Enum.Material.Metal, map, true)
part("WarehouseRoofR", Vector3.new(62,1.2,104), CFrame.new(31,24.6,0), C_DARK, Enum.Material.Metal, map, true)
part("WarehouseBridge", Vector3.new(26,1.2,18), CFrame.new(0,10,0), C_METAL, Enum.Material.Metal, map, true)

-- Interior cover makes the middle lane usable instead of a flat box.
part("WarehouseCover_1", Vector3.new(18,6,6), CFrame.new(-28,3,-18), C_CONCRETE, Enum.Material.Concrete, map, true)
part("WarehouseCover_2", Vector3.new(18,6,6), CFrame.new(28,3,18), C_CONCRETE, Enum.Material.Concrete, map, true)
part("WarehouseCover_3", Vector3.new(7,6,18), CFrame.new(-16,3,24), C_CONCRETE, Enum.Material.Concrete, map, true)
part("WarehouseCover_4", Vector3.new(7,6,18), CFrame.new(16,3,-24), C_CONCRETE, Enum.Material.Concrete, map, true)

-- Four urban blocks around center.
local blocks = {
    {-118,-96,64,30,54}, {-118,96,58,24,58},
    {118,-96,60,27,58}, {118,96,68,32,52},
    {-198,-144,54,22,48}, {-198,144,62,29,44},
    {198,-144,58,25,44}, {198,144,54,22,48},
}
for i,b in ipairs(blocks) do
    local x,z,w,h,d = b[1],b[2],b[3],b[4],b[5]
    part("Office_"..i, Vector3.new(w,h,d), CFrame.new(x,h/2,z), i%2==0 and Color3.fromRGB(74,79,87) or Color3.fromRGB(82,86,92), Enum.Material.Concrete, map, true)
    part("OfficeRoof_"..i, Vector3.new(w+4,1,d+4), CFrame.new(x,h+0.5,z), C_DARK, Enum.Material.Metal, map, true)
    local glassX = x + (x < 0 and w/2+0.06 or -w/2-0.06)
    for dz=-d/3,d/3,d/3 do
        local win = part("OfficeWindow_"..i, Vector3.new(0.12,5,8), CFrame.new(glassX,math.min(11,h/2),z+dz), C_GLASS, Enum.Material.Neon, map, false)
        win.Transparency = 0.35
    end
end

-- Container yards and hard cover.
local function container(name, x,y,z,rot,color)
    local cf = CFrame.new(x,y,z) * CFrame.Angles(0,math.rad(rot or 0),0)
    local c = part(name, Vector3.new(30,8,11), cf, color, Enum.Material.Metal, map, true)
    for k=-1,1 do
        part("ContainerRib", Vector3.new(0.35,7.4,10.2), cf*CFrame.new(k*9,0,0), C_DARK, Enum.Material.Metal, map, false)
    end
    return c
end
container("Container_A1",-92,4,-150,0,Color3.fromRGB(83,104,116))
container("Container_A2",-92,12,-150,0,C_RUST)
container("Container_A3",-148,4,70,90,Color3.fromRGB(88,98,75))
container("Container_B1",92,4,150,0,Color3.fromRGB(99,87,72))
container("Container_B2",92,12,150,0,Color3.fromRGB(74,90,108))
container("Container_B3",148,4,-70,90,Color3.fromRGB(105,75,72))

local coverPositions = {
    {-170,-90,0},{-165,-20,90},{-168,84,0},{-142,126,90},
    {170,90,0},{165,20,90},{168,-84,0},{142,-126,90},
    {-82,-78,0},{82,78,0},{-82,78,0},{82,-78,0},
    {-36,104,90},{36,-104,90},{-36,-104,90},{36,104,90},
}
for i,v in ipairs(coverPositions) do
    local cf = CFrame.new(v[1],2.5,v[2]) * CFrame.Angles(0,math.rad(v[3]),0)
    part("Cover_"..i, Vector3.new(14,5,4), cf, C_CONCRETE, Enum.Material.Concrete, map, true)
end

-- Side catwalks add recognizable vertical landmarks.
part("Catwalk_W", Vector3.new(14,1,118), CFrame.new(-172,12,0), C_METAL, Enum.Material.Metal, map, true)
part("Catwalk_E", Vector3.new(14,1,118), CFrame.new(172,12,0), C_METAL, Enum.Material.Metal, map, true)
part("CatwalkRamp_W1", Vector3.new(14,1,54), CFrame.new(-172,6,-82)*CFrame.Angles(math.rad(12),0,0), C_METAL, Enum.Material.Metal, map, true)
part("CatwalkRamp_W2", Vector3.new(14,1,54), CFrame.new(-172,6,82)*CFrame.Angles(math.rad(-12),0,0), C_METAL, Enum.Material.Metal, map, true)
part("CatwalkRamp_E1", Vector3.new(14,1,54), CFrame.new(172,6,-82)*CFrame.Angles(math.rad(12),0,0), C_METAL, Enum.Material.Metal, map, true)
part("CatwalkRamp_E2", Vector3.new(14,1,54), CFrame.new(172,6,82)*CFrame.Angles(math.rad(-12),0,0), C_METAL, Enum.Material.Metal, map, true)

-- Spawn-side landmarks and team color cues.
part("AlphaTower", Vector3.new(20,34,20), CFrame.new(-226,17,-150), Color3.fromRGB(52,67,82), Enum.Material.Concrete, map, true)
part("BravoTower", Vector3.new(20,34,20), CFrame.new(226,17,150), Color3.fromRGB(82,53,53), Enum.Material.Concrete, map, true)
part("AlphaBeacon", Vector3.new(4,18,4), CFrame.new(-226,43,-150), C_BLUE, Enum.Material.Neon, map, false)
part("BravoBeacon", Vector3.new(4,18,4), CFrame.new(226,43,150), C_RED, Enum.Material.Neon, map, false)

safeSection("lighting", function()
    Lighting.Brightness = 2.1
    Lighting.ClockTime = 15.6
    Lighting.GlobalShadows = true
    Lighting.Ambient = Color3.fromRGB(75,80,88)
    Lighting.OutdoorAmbient = Color3.fromRGB(118,126,138)
    Lighting.EnvironmentDiffuseScale = 0.65
    Lighting.EnvironmentSpecularScale = 0.72
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("Atmosphere") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") then
            effect:Destroy()
        end
    end
    local atmosphere = Instance.new("Atmosphere")
    atmosphere.Density = 0.22
    atmosphere.Offset = 0.12
    atmosphere.Color = Color3.fromRGB(198,205,214)
    atmosphere.Decay = Color3.fromRGB(105,115,128)
    atmosphere.Haze = 0.8
    atmosphere.Parent = Lighting
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Contrast = 0.08
    cc.Saturation = -0.08
    cc.Brightness = -0.01
    cc.Parent = Lighting
end)

local marker = Instance.new("StringValue")
marker.Name = "BBYAVATAR_FPS_BUILD"
marker.Value = BUILD
marker.Parent = Workspace

print("[ZONA PERANG MAP] "..BUILD.." ready — ground + urban battlefield guaranteed")