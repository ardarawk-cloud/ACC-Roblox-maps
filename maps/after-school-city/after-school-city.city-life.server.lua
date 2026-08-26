-- AFTER SCHOOL CITY — City Life Pass v0.3
-- Densifies the School -> Downtown corridor and adds playable-looking detail to outer districts.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC CityLife] AfterSchoolCity root missing")
    return
end

if root:FindFirstChild("V03_CityLife") then
    return
end

local districts = root:WaitForChild("Districts", 10)
local roads = root:WaitForChild("RoadsAndPaths", 10)
local furniture = root:FindFirstChild("StreetFurniture") or root
local landscaping = root:FindFirstChild("Landscaping") or root

local layer = Instance.new("Model")
layer.Name = "V03_CityLife"
layer:SetAttribute("ASC_Layer", "CITY_LIFE")
layer:SetAttribute("ASC_Version", "0.3-city-life-pass-1")
layer.Parent = root

local C = {
    asphalt = Color3.fromRGB(48, 52, 60),
    sidewalk = Color3.fromRGB(198, 202, 208),
    curb = Color3.fromRGB(224, 226, 230),
    white = Color3.fromRGB(240, 242, 245),
    gold = Color3.fromRGB(242, 180, 65),
    blue = Color3.fromRGB(59, 102, 151),
    navy = Color3.fromRGB(34, 48, 72),
    metal = Color3.fromRGB(78, 84, 94),
    wood = Color3.fromRGB(130, 94, 65),
    green = Color3.fromRGB(74, 126, 74),
    hedge = Color3.fromRGB(66, 113, 68),
    concrete = Color3.fromRGB(180, 184, 190),
    red = Color3.fromRGB(185, 73, 65),
    teal = Color3.fromRGB(61, 127, 121),
}

local function part(parent, name, size, cf, color, material, transparency)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Color = color or C.white
    p.Material = material or Enum.Material.SmoothPlastic
    p.Transparency = transparency or 0
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function tree(parent, pos, scale)
    scale = scale or 1
    part(parent, "TreeTrunk", Vector3.new(2, 8 * scale, 2), CFrame.new(pos + Vector3.new(0, 4 * scale, 0)), Color3.fromRGB(101, 75, 52), Enum.Material.Wood)
    local crown = part(parent, "TreeCrown", Vector3.new(9 * scale, 9 * scale, 9 * scale), CFrame.new(pos + Vector3.new(0, 10 * scale, 0)), C.green, Enum.Material.Grass)
    crown.Shape = Enum.PartType.Ball
    crown.CanCollide = false
end

local function bench(parent, pos, yaw)
    local cf = CFrame.new(pos) * CFrame.Angles(0, math.rad(yaw or 0), 0)
    part(parent, "BenchSeat", Vector3.new(8, 0.6, 2.2), cf * CFrame.new(0, 2, 0), C.wood, Enum.Material.Wood)
    part(parent, "BenchBack", Vector3.new(8, 3, 0.5), cf * CFrame.new(0, 3.6, 1), C.wood, Enum.Material.Wood)
    part(parent, "BenchLegL", Vector3.new(0.5, 2, 0.5), cf * CFrame.new(-3, 1, 0), C.metal, Enum.Material.Metal)
    part(parent, "BenchLegR", Vector3.new(0.5, 2, 0.5), cf * CFrame.new(3, 1, 0), C.metal, Enum.Material.Metal)
end

local function planter(parent, pos)
    part(parent, "Planter", Vector3.new(7, 2, 4), CFrame.new(pos + Vector3.new(0, 1, 0)), Color3.fromRGB(117, 105, 88), Enum.Material.Concrete)
    local bush = part(parent, "PlanterBush", Vector3.new(5.8, 3, 3), CFrame.new(pos + Vector3.new(0, 3, 0)), C.hedge, Enum.Material.Grass)
    bush.Shape = Enum.PartType.Ball
    bush.CanCollide = false
end

local function lamp(parent, pos)
    part(parent, "LampPole", Vector3.new(0.7, 10, 0.7), CFrame.new(pos + Vector3.new(0, 5, 0)), C.metal, Enum.Material.Metal)
    local head = part(parent, "LampHead", Vector3.new(2.4, 0.6, 1.4), CFrame.new(pos + Vector3.new(0, 10.2, 0)), Color3.fromRGB(255, 229, 176), Enum.Material.Neon)
    head.CanCollide = false
    local light = Instance.new("PointLight")
    light.Brightness = 0.75
    light.Range = 18
    light.Color = Color3.fromRGB(255, 225, 175)
    light.Shadows = false
    light.Parent = head
end

local function bikeRack(parent, pos, yaw)
    local cf = CFrame.new(pos) * CFrame.Angles(0, math.rad(yaw or 0), 0)
    for i = -2, 2 do
        part(parent, "BikeRack", Vector3.new(0.5, 3, 4), cf * CFrame.new(i * 2.2, 1.8, 0), C.metal, Enum.Material.Metal)
    end
end

-- =========================================================
-- SCHOOL -> DOWNTOWN PEDESTRIAN CORRIDOR
-- =========================================================
local corridor = Instance.new("Model")
corridor.Name = "SchoolDowntownCorridor"
corridor.Parent = layer

-- Pocket plazas on both sides of the road reduce the huge empty grass gap.
for _, z in ipairs({55, 92, 129, 166}) do
    part(corridor, "PocketPlazaW", Vector3.new(34, 0.65, 24), CFrame.new(-46, 1.2, z), C.sidewalk, Enum.Material.Concrete)
    part(corridor, "PocketPlazaE", Vector3.new(34, 0.65, 24), CFrame.new(46, 1.2, z), C.sidewalk, Enum.Material.Concrete)
    planter(corridor, Vector3.new(-56, 1.5, z))
    planter(corridor, Vector3.new(56, 1.5, z))
    if z == 92 or z == 166 then
        bench(corridor, Vector3.new(-38, 1.5, z), 90)
        bench(corridor, Vector3.new(38, 1.5, z), -90)
    end
end

-- Tree rhythm and lighting turn the main connector into a recognizable avenue.
for z = 50, 170, 30 do
    tree(corridor, Vector3.new(-66, 1.5, z), 0.72)
    tree(corridor, Vector3.new(66, 1.5, z), 0.72)
    lamp(corridor, Vector3.new(-31, 1.5, z + 8))
    lamp(corridor, Vector3.new(31, 1.5, z + 8))
end

bikeRack(corridor, Vector3.new(-46, 1.5, 129), 0)

local vending = part(corridor, "VendingMachine", Vector3.new(5, 8, 3), CFrame.new(49, 5.3, 92), C.blue, Enum.Material.Metal)
local vendingGlow = part(corridor, "VendingGlow", Vector3.new(3.6, 4.2, 0.2), CFrame.new(49, 6, 90.4), C.gold, Enum.Material.Neon)
vendingGlow.CanCollide = false
vending:SetAttribute("ASC_Prop", "VENDING_MACHINE")

-- Safety bollards at the school approach.
for _, x in ipairs({-13, -8, 8, 13}) do
    part(corridor, "SchoolBollard", Vector3.new(1, 3, 1), CFrame.new(x, 2.8, 176), C.metal, Enum.Material.Metal)
end

-- =========================================================
-- CITY PARK DETAIL
-- =========================================================
local park = districts:FindFirstChild("Park")
if park then
    local p = Instance.new("Model")
    p.Name = "V03_ParkLife"
    p.Parent = park

    -- Path loop around the lake edge.
    part(p, "PathNorth", Vector3.new(130, 0.55, 10), CFrame.new(15, 1.25, -248), C.sidewalk, Enum.Material.Concrete)
    part(p, "PathSouth", Vector3.new(130, 0.55, 10), CFrame.new(15, 1.25, -172), C.sidewalk, Enum.Material.Concrete)
    part(p, "PathWest", Vector3.new(10, 0.55, 66), CFrame.new(-50, 1.25, -210), C.sidewalk, Enum.Material.Concrete)
    part(p, "PathEast", Vector3.new(10, 0.55, 66), CFrame.new(80, 1.25, -210), C.sidewalk, Enum.Material.Concrete)

    -- Picnic corner.
    for _, pos in ipairs({Vector3.new(-82, 1.5, -232), Vector3.new(-82, 1.5, -190)}) do
        part(p, "PicnicTable", Vector3.new(9, 0.7, 5), CFrame.new(pos + Vector3.new(0, 3, 0)), C.wood, Enum.Material.Wood)
        part(p, "PicnicBenchA", Vector3.new(9, 0.6, 1.5), CFrame.new(pos + Vector3.new(0, 1.8, -4)), C.wood, Enum.Material.Wood)
        part(p, "PicnicBenchB", Vector3.new(9, 0.6, 1.5), CFrame.new(pos + Vector3.new(0, 1.8, 4)), C.wood, Enum.Material.Wood)
    end
    lamp(p, Vector3.new(-55, 1.5, -247))
    lamp(p, Vector3.new(80, 1.5, -247))
    lamp(p, Vector3.new(-55, 1.5, -173))
    lamp(p, Vector3.new(80, 1.5, -173))
end

-- =========================================================
-- SKATE PARK DETAIL
-- =========================================================
local skate = districts:FindFirstChild("SkatePark")
if skate then
    local s = Instance.new("Model")
    s.Name = "V03_SkateLife"
    s.Parent = skate

    -- Extra banks/rails make the park read as an actual skate layout from above.
    part(s, "BankA", Vector3.new(28, 4, 18), CFrame.new(207, 3.2, 25) * CFrame.Angles(0, math.rad(18), 0), Color3.fromRGB(94, 99, 107), Enum.Material.Concrete)
    part(s, "BankB", Vector3.new(28, 4, 18), CFrame.new(263, 3.2, -25) * CFrame.Angles(0, math.rad(-18), 0), Color3.fromRGB(94, 99, 107), Enum.Material.Concrete)
    part(s, "ManualPad", Vector3.new(30, 2, 14), CFrame.new(235, 2.2, 30), C.concrete, Enum.Material.Concrete)
    for _, x in ipairs({215, 255}) do
        part(s, "LowRail", Vector3.new(22, 0.7, 0.7), CFrame.new(x, 3.2, -8), C.metal, Enum.Material.Metal)
        part(s, "RailPostL", Vector3.new(0.7, 2.5, 0.7), CFrame.new(x - 9, 2.1, -8), C.metal, Enum.Material.Metal)
        part(s, "RailPostR", Vector3.new(0.7, 2.5, 0.7), CFrame.new(x + 9, 2.1, -8), C.metal, Enum.Material.Metal)
    end
    bench(s, Vector3.new(235, 1.5, 58), 180)
end

-- =========================================================
-- SPORTS DETAIL
-- =========================================================
local sports = districts:FindFirstChild("SportsField")
if sports then
    local s = Instance.new("Model")
    s.Name = "V03_SportsLife"
    s.Parent = sports

    -- Low perimeter fence with open gate at the school-facing side.
    for x = 185, 285, 10 do
        if math.abs(x - 235) > 14 then
            part(s, "FenceNorth", Vector3.new(0.5, 7, 0.5), CFrame.new(x, 5, 164), C.metal, Enum.Material.Metal)
        end
        part(s, "FenceSouth", Vector3.new(0.5, 7, 0.5), CFrame.new(x, 5, 246), C.metal, Enum.Material.Metal)
    end
    part(s, "FenceRailNorth", Vector3.new(86, 0.5, 0.5), CFrame.new(235, 7.5, 164), C.metal, Enum.Material.Metal)
    part(s, "FenceRailSouth", Vector3.new(104, 0.5, 0.5), CFrame.new(235, 7.5, 246), C.metal, Enum.Material.Metal)

    bench(s, Vector3.new(196, 1.5, 253), 180)
    bench(s, Vector3.new(274, 1.5, 253), 180)
    part(s, "WaterCooler", Vector3.new(3.5, 6, 3.5), CFrame.new(293, 4.5, 252), C.teal, Enum.Material.SmoothPlastic)
end

-- =========================================================
-- RESIDENTIAL DETAIL
-- =========================================================
local residential = districts:FindFirstChild("Residential")
if residential then
    local r = Instance.new("Model")
    r.Name = "V03_ResidentialLife"
    r.Parent = residential

    for _, z in ipairs({-48, 0, 48}) do
        part(r, "Driveway", Vector3.new(22, 0.55, 18), CFrame.new(-188, 1.2, z), C.concrete, Enum.Material.Concrete)
        part(r, "MailboxPost", Vector3.new(0.8, 5, 0.8), CFrame.new(-198, 3.8, z + 11), C.metal, Enum.Material.Metal)
        part(r, "Mailbox", Vector3.new(4, 2.4, 2.5), CFrame.new(-198, 6.5, z + 11), C.navy, Enum.Material.Metal)
    end

    for z = -65, 65, 16 do
        local hedge = part(r, "Hedge", Vector3.new(8, 4, 4), CFrame.new(-174, 3.2, z), C.hedge, Enum.Material.Grass)
        hedge.CanCollide = false
    end
end

root:SetAttribute("ASC_CityLifePass", "0.3-city-life-pass-1")
Workspace:SetAttribute("ASC_CityLifePass", "0.3-city-life-pass-1")
print("[AFTER SCHOOL CITY] City Life Pass v0.3 initialized")