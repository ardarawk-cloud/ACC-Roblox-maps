-- BBYAVATAR FPS prototype world
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Teams = game:GetService("Teams")

local function clearWorld()
    for _, child in ipairs(Workspace:GetChildren()) do
        if not child:IsA("Terrain") then
            child:Destroy()
        end
    end
end

local function part(name, size, cf, color, material, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.CanCollide = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Color = color or Color3.fromRGB(90, 94, 100)
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

local function spawn(name, cf, brickColor, teamColor)
    local s = Instance.new("SpawnLocation")
    s.Name = name
    s.Size = Vector3.new(12, 1, 12)
    s.CFrame = cf
    s.Anchored = true
    s.Neutral = false
    s.TeamColor = teamColor
    s.BrickColor = brickColor
    s.Material = Enum.Material.Metal
    s.Transparency = 0.15
    s.Parent = Workspace
    return s
end

clearWorld()
Workspace.FallenPartsDestroyHeight = -120
Workspace.StreamingEnabled = true

Lighting.Technology = Enum.Technology.Future
Lighting.Brightness = 2.1
Lighting.ClockTime = 16.4
Lighting.EnvironmentDiffuseScale = 0.55
Lighting.EnvironmentSpecularScale = 0.75
Lighting.GlobalShadows = true
Lighting.OutdoorAmbient = Color3.fromRGB(105, 111, 122)
Lighting.Ambient = Color3.fromRGB(55, 60, 70)

local atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0.28
atmosphere.Offset = 0.2
atmosphere.Color = Color3.fromRGB(190, 198, 210)
atmosphere.Decay = Color3.fromRGB(90, 100, 116)
atmosphere.Glare = 0.12
atmosphere.Haze = 1.2
atmosphere.Parent = Lighting

local cc = Instance.new("ColorCorrectionEffect")
cc.Brightness = -0.02
cc.Contrast = 0.09
cc.Saturation = -0.12
cc.Parent = Lighting

local alpha = team("ALPHA", BrickColor.new("Bright blue"))
local bravo = team("BRAVO", BrickColor.new("Bright red"))

local map = Instance.new("Folder")
map.Name = "FPS_URBAN_BLOCK"
map.Parent = Workspace

part("Ground", Vector3.new(440, 4, 320), CFrame.new(0, -2, 0), Color3.fromRGB(56, 58, 60), Enum.Material.Asphalt, map)

-- perimeter
part("NorthWall", Vector3.new(440, 28, 4), CFrame.new(0, 12, -160), Color3.fromRGB(45, 47, 50), Enum.Material.Concrete, map)
part("SouthWall", Vector3.new(440, 28, 4), CFrame.new(0, 12, 160), Color3.fromRGB(45, 47, 50), Enum.Material.Concrete, map)
part("WestWall", Vector3.new(4, 28, 320), CFrame.new(-220, 12, 0), Color3.fromRGB(45, 47, 50), Enum.Material.Concrete, map)
part("EastWall", Vector3.new(4, 28, 320), CFrame.new(220, 12, 0), Color3.fromRGB(45, 47, 50), Enum.Material.Concrete, map)

-- roads and sidewalks
for _, z in ipairs({-92, 0, 92}) do
    part("Road_"..z, Vector3.new(430, 0.5, 42), CFrame.new(0, 0.05, z), Color3.fromRGB(43, 45, 47), Enum.Material.Asphalt, map)
end
for _, x in ipairs({-132, 0, 132}) do
    part("Lane_"..x, Vector3.new(42, 0.55, 310), CFrame.new(x, 0.08, 0), Color3.fromRGB(48, 50, 52), Enum.Material.Asphalt, map)
end

-- central warehouse
part("WarehouseFloor", Vector3.new(112, 1, 92), CFrame.new(0, 0.5, 0), Color3.fromRGB(72, 74, 78), Enum.Material.Concrete, map)
for _, data in ipairs({
    {Vector3.new(112, 22, 4), CFrame.new(0, 11, -46)},
    {Vector3.new(112, 22, 4), CFrame.new(0, 11, 46)},
    {Vector3.new(4, 22, 92), CFrame.new(-56, 11, 0)},
    {Vector3.new(4, 22, 92), CFrame.new(56, 11, 0)},
}) do
    part("WarehouseWall", data[1], data[2], Color3.fromRGB(82, 86, 92), Enum.Material.Metal, map)
end
-- openings through warehouse walls
for _, side in ipairs({-1,1}) do
    local x = 56 * side
    local door = part("WarehouseDoorFrame", Vector3.new(4.2, 8, 22), CFrame.new(x, 4, 0), Color3.fromRGB(40, 42, 46), Enum.Material.Metal, map)
    door.CanCollide = false
    door.Transparency = 1
end

-- cover rows
local coverPositions = {
    Vector3.new(-170, 3, -112), Vector3.new(-145, 3, -72), Vector3.new(-172, 3, 42), Vector3.new(-150, 3, 108),
    Vector3.new(170, 3, -112), Vector3.new(145, 3, -72), Vector3.new(172, 3, 42), Vector3.new(150, 3, 108),
    Vector3.new(-82, 3, -108), Vector3.new(82, 3, -108), Vector3.new(-84, 3, 108), Vector3.new(84, 3, 108),
    Vector3.new(-28, 3, -16), Vector3.new(28, 3, 18), Vector3.new(-24, 3, 26), Vector3.new(26, 3, -30),
}
for i, pos in ipairs(coverPositions) do
    local long = (i % 3 == 0)
    part("Cover_"..i, long and Vector3.new(20,6,5) or Vector3.new(9,6,12), CFrame.new(pos), Color3.fromRGB(92, 96, 102), Enum.Material.Metal, map)
end

-- container stacks
local function container(x, y, z, rot, color)
    local c = part("Container", Vector3.new(28, 8, 10), CFrame.new(x,y,z) * CFrame.Angles(0,math.rad(rot or 0),0), color, Enum.Material.Metal, map)
    for k=-1,1 do
        local rib = part("ContainerRib", Vector3.new(0.35,7.2,9.5), c.CFrame * CFrame.new(k*8,0,0), Color3.fromRGB(48,52,58), Enum.Material.Metal, map)
        rib.CanCollide = false
    end
end
container(-105,4,-62,0,Color3.fromRGB(88,105,116))
container(-105,12,-62,0,Color3.fromRGB(116,83,67))
container(108,4,64,0,Color3.fromRGB(101,108,77))
container(108,12,64,0,Color3.fromRGB(77,92,111))
container(-92,4,72,90,Color3.fromRGB(105,79,77))
container(92,4,-72,90,Color3.fromRGB(78,96,102))

-- elevated flank catwalks
for _, x in ipairs({-188,188}) do
    part("Catwalk", Vector3.new(16,1,170), CFrame.new(x,14,0), Color3.fromRGB(72,76,82), Enum.Material.DiamondPlate, map)
    for _, z in ipairs({-76,76}) do
        local ramp = part("Ramp", Vector3.new(16,1,68), CFrame.new(x,7,z) * CFrame.Angles(math.rad(z>0 and -12 or 12),0,0), Color3.fromRGB(70,74,80), Enum.Material.Metal, map)
        ramp.CanCollide = true
    end
end

-- simple office blocks
for _, x in ipairs({-102,102}) do
    for _, z in ipairs({-118,118}) do
        part("Office", Vector3.new(54,18,32), CFrame.new(x,9,z), Color3.fromRGB(74,78,85), Enum.Material.Concrete, map)
        part("OfficeRoof", Vector3.new(58,1,36), CFrame.new(x,18.5,z), Color3.fromRGB(42,45,50), Enum.Material.Metal, map)
    end
end

-- lamps
for _, x in ipairs({-180,-60,60,180}) do
    for _, z in ipairs({-135,135}) do
        local pole = part("LampPole", Vector3.new(1,18,1), CFrame.new(x,9,z), Color3.fromRGB(38,40,45), Enum.Material.Metal, map)
        local lamp = Instance.new("PointLight")
        lamp.Brightness = 1.2
        lamp.Range = 34
        lamp.Shadows = true
        lamp.Color = Color3.fromRGB(219,226,235)
        lamp.Parent = pole
    end
end

spawn("AlphaSpawn1", CFrame.new(-194,1.2,-45), BrickColor.new("Bright blue"), alpha.TeamColor)
spawn("AlphaSpawn2", CFrame.new(-194,1.2,45), BrickColor.new("Bright blue"), alpha.TeamColor)
spawn("BravoSpawn1", CFrame.new(194,1.2,-45), BrickColor.new("Bright red"), bravo.TeamColor)
spawn("BravoSpawn2", CFrame.new(194,1.2,45), BrickColor.new("Bright red"), bravo.TeamColor)

local marker = Instance.new("StringValue")
marker.Name = "BBYAVATAR_FPS_BUILD"
marker.Value = "FPS-PROTOTYPE-0.1"
marker.Parent = Workspace

print("[BBYAVATAR FPS] Urban Block world ready")
