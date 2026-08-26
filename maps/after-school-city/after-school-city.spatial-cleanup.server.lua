-- AFTER SCHOOL CITY — Spatial Cleanup Pass v0.4.1
-- Corrects layout collisions found in live v9 screenshots.
-- Placement-only pass: no economy, persistence, monetization, or gameplay authority.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC SpatialCleanup] AfterSchoolCity root missing")
    return
end

if root:FindFirstChild("V041_SpatialCleanup") then
    return
end

-- Wait for earlier visual layers so this pass can safely correct them.
root:WaitForChild("V04_StreetLife", 20)
local districts = root:WaitForChild("Districts", 10)
local roads = root:WaitForChild("RoadsAndPaths", 10)
local furniture = root:FindFirstChild("StreetFurniture") or root

local layer = Instance.new("Model")
layer.Name = "V041_SpatialCleanup"
layer:SetAttribute("ASC_Layer", "SPATIAL_CLEANUP")
layer:SetAttribute("ASC_Version", "0.4.1-spatial-cleanup-1")
layer.Parent = root

local C = {
    asphalt = Color3.fromRGB(57, 62, 70),
    sidewalk = Color3.fromRGB(194, 199, 205),
    white = Color3.fromRGB(239, 241, 244),
    dark = Color3.fromRGB(31, 35, 42),
    metal = Color3.fromRGB(79, 85, 94),
    wood = Color3.fromRGB(132, 96, 66),
    green = Color3.fromRGB(70, 124, 72),
    hedge = Color3.fromRGB(63, 108, 65),
    blue = Color3.fromRGB(59, 102, 151),
    yellow = Color3.fromRGB(225, 178, 61),
    glass = Color3.fromRGB(91, 139, 170),
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
    part(parent, "TreeTrunk", Vector3.new(1.8 * scale, 7 * scale, 1.8 * scale), CFrame.new(pos + Vector3.new(0, 3.5 * scale, 0)), Color3.fromRGB(101, 76, 53), Enum.Material.Wood)
    local crown = part(parent, "TreeCrown", Vector3.new(7.5 * scale, 7.5 * scale, 7.5 * scale), CFrame.new(pos + Vector3.new(0, 9 * scale, 0)), C.green, Enum.Material.Grass)
    crown.Shape = Enum.PartType.Ball
    crown.CanCollide = false
end

local function lamp(parent, pos)
    part(parent, "LampPole", Vector3.new(0.6, 9, 0.6), CFrame.new(pos + Vector3.new(0, 4.5, 0)), C.metal, Enum.Material.Metal)
    local head = part(parent, "LampHead", Vector3.new(2.2, 0.55, 1.3), CFrame.new(pos + Vector3.new(0, 9.2, 0)), Color3.fromRGB(255, 229, 176), Enum.Material.Neon)
    head.CanCollide = false
    local light = Instance.new("PointLight")
    light.Brightness = 0.45
    light.Range = 15
    light.Color = Color3.fromRGB(255, 225, 175)
    light.Shadows = false
    light.Parent = head
end

local function bench(parent, pos, yaw)
    local cf = CFrame.new(pos) * CFrame.Angles(0, math.rad(yaw or 0), 0)
    part(parent, "BenchSeat", Vector3.new(8, 0.6, 2.2), cf * CFrame.new(0, 2, 0), C.wood, Enum.Material.Wood)
    part(parent, "BenchBack", Vector3.new(8, 3, 0.5), cf * CFrame.new(0, 3.6, 1), C.wood, Enum.Material.Wood)
    part(parent, "BenchLegL", Vector3.new(0.5, 2, 0.5), cf * CFrame.new(-3, 1, 0), C.metal, Enum.Material.Metal)
    part(parent, "BenchLegR", Vector3.new(0.5, 2, 0.5), cf * CFrame.new(3, 1, 0), C.metal, Enum.Material.Metal)
end

local function parkingLot(parent, name, center, size)
    local m = Instance.new("Model")
    m.Name = name
    m:SetAttribute("ASC_ClearanceChecked", true)
    m.Parent = parent
    part(m, "ParkingSurface", Vector3.new(size.X, 0.5, size.Z), CFrame.new(center + Vector3.new(0, 1.15, 0)), C.asphalt, Enum.Material.Asphalt)
    for x = -size.X / 2 + 8, size.X / 2 - 8, 12 do
        local stripe = part(m, "ParkingStripe", Vector3.new(0.25, 0.05, math.max(10, size.Z - 8)), CFrame.new(center + Vector3.new(x, 1.43, 0)), C.white, Enum.Material.SmoothPlastic)
        stripe.CanCollide = false
    end
    return m
end

local function parkedCar(parent, name, pos, yaw, bodyColor)
    local m = Instance.new("Model")
    m.Name = name
    m:SetAttribute("ASC_Prop", "PARKED_VEHICLE")
    m:SetAttribute("ASC_ClearanceChecked", true)
    m.Parent = parent

    local cf = CFrame.new(pos) * CFrame.Angles(0, math.rad(yaw or 0), 0)
    part(m, "LowerBody", Vector3.new(9.5, 2.2, 17), cf * CFrame.new(0, 2.6, 0), bodyColor, Enum.Material.SmoothPlastic)
    part(m, "Cabin", Vector3.new(7.8, 3.2, 8.5), cf * CFrame.new(0, 5, -0.4), bodyColor:Lerp(C.white, 0.12), Enum.Material.SmoothPlastic)
    local windshield = part(m, "Windshield", Vector3.new(7, 2.3, 0.3), cf * CFrame.new(0, 5.4, 3.9), C.glass, Enum.Material.Glass, 0.18)
    windshield.CanCollide = false
    local rear = part(m, "RearWindow", Vector3.new(7, 2.1, 0.3), cf * CFrame.new(0, 5.4, -4.9), C.glass, Enum.Material.Glass, 0.18)
    rear.CanCollide = false

    for _, x in ipairs({-4.9, 4.9}) do
        for _, z in ipairs({-5.5, 5.5}) do
            local wheel = part(m, "Wheel", Vector3.new(2.1, 2.1, 1.2), cf * CFrame.new(x, 2, z) * CFrame.Angles(0, 0, math.rad(90)), C.dark, Enum.Material.Rubber)
            wheel.Shape = Enum.PartType.Cylinder
        end
    end
    return m
end

-- =========================================================
-- 1. SCHOOL / SPORTS CONNECTOR
-- The v0.4 road crossed into the school building footprint.
-- Keep only a short connector between the east edge of school and sports.
-- =========================================================
local schoolSportsRoad = roads:FindFirstChild("SchoolSportsRoad")
if schoolSportsRoad and schoolSportsRoad:IsA("BasePart") then
    schoolSportsRoad.Size = Vector3.new(52, 0.7, 24)
    schoolSportsRoad.CFrame = CFrame.new(135, 1.05, 210)
    schoolSportsRoad:SetAttribute("ASC_ClearanceChecked", true)
end

part(layer, "SchoolSportsWalkNorth", Vector3.new(52, 0.65, 6), CFrame.new(135, 1.2, 194), C.sidewalk, Enum.Material.Concrete)
part(layer, "SchoolSportsWalkSouth", Vector3.new(52, 0.65, 6), CFrame.new(135, 1.2, 226), C.sidewalk, Enum.Material.Concrete)

-- =========================================================
-- 2. SECONDARY GRID CLEANUP
-- Remove the second cross street at Z=132. It intersected the pre-existing
-- School-Downtown pocket plazas and compressed Student Row building setbacks.
-- =========================================================
local streetLife = root:FindFirstChild("V04_StreetLife")
if streetLife then
    local grid = streetLife:FindFirstChild("SecondaryStreetGrid")
    if grid then
        for _, child in ipairs(grid:GetChildren()) do
            if child:IsA("BasePart") and string.find(child.Name, "Cross") and child.Position.Z > 100 then
                child:Destroy()
            end
        end
    end

    local infill = streetLife:FindFirstChild("StudentRowInfill")
    if infill then
        -- These two kiosks were sitting in the main/cross-street envelopes.
        local bakery = infill:FindFirstChild("CornerBakery")
        if bakery then bakery:Destroy() end
        local tech = infill:FindFirstChild("CornerTech")
        if tech then tech:Destroy() end

        -- Give Student Row a real street-facing orientation and spacing.
        local placement = {
            StudentMiniMart = {z = 108, yaw = 90},
            StudyLounge = {z = 166, yaw = 90},
            CommunityLibrary = {z = 112, yaw = -90},
            YouthStudio = {z = 170, yaw = -90},
        }
        for name, spec in pairs(placement) do
            local model = infill:FindFirstChild(name)
            if model and model:IsA("Model") then
                local pivot = model:GetPivot()
                model:PivotTo(CFrame.new(pivot.Position.X, pivot.Position.Y, spec.z) * CFrame.Angles(0, math.rad(spec.yaw), 0))
                model:SetAttribute("ASC_StreetFacing", true)
                model:SetAttribute("ASC_ClearanceChecked", true)
            end
        end
    end

    -- Remove the original parking arrangement; it placed vehicles too close
    -- to storefront walls and one school tree penetrated a parked car.
    local oldParking = streetLife:FindFirstChild("ParkingAndVehicles")
    if oldParking then
        oldParking:Destroy()
    end
end

-- =========================================================
-- 3. REBUILD SCHOOL-DOWNTOWN PEDESTRIAN CORRIDOR
-- Keep props inside the two clear blocks between roads, never inside road bands.
-- =========================================================
local cityLife = root:FindFirstChild("V03_CityLife")
if cityLife then
    local oldCorridor = cityLife:FindFirstChild("SchoolDowntownCorridor")
    if oldCorridor then
        oldCorridor:Destroy()
    end
end

local corridor = Instance.new("Model")
corridor.Name = "V041_SchoolDowntownCorridor"
corridor:SetAttribute("ASC_ClearanceChecked", true)
corridor.Parent = layer

for _, z in ipairs({96, 162}) do
    part(corridor, "PocketPlazaW", Vector3.new(28, 0.6, 16), CFrame.new(-47, 1.2, z), C.sidewalk, Enum.Material.Concrete)
    part(corridor, "PocketPlazaE", Vector3.new(28, 0.6, 16), CFrame.new(47, 1.2, z), C.sidewalk, Enum.Material.Concrete)
    tree(corridor, Vector3.new(-66, 1.5, z), 0.7)
    tree(corridor, Vector3.new(66, 1.5, z), 0.7)
    lamp(corridor, Vector3.new(-31, 1.5, z))
    lamp(corridor, Vector3.new(31, 1.5, z))
    bench(corridor, Vector3.new(-47, 1.5, z), 90)
    bench(corridor, Vector3.new(47, 1.5, z), -90)
end

-- Short street-facing access pads for Student Row entrances.
for _, data in ipairs({
    {Vector3.new(-153, 1.2, 108), Vector3.new(12, 0.55, 9)},
    {Vector3.new(-153, 1.2, 166), Vector3.new(12, 0.55, 9)},
    {Vector3.new(153, 1.2, 112), Vector3.new(12, 0.55, 9)},
    {Vector3.new(153, 1.2, 170), Vector3.new(12, 0.55, 9)},
}) do
    part(corridor, "StudentRowAccess", data[2], CFrame.new(data[1]), C.sidewalk, Enum.Material.Concrete)
end

-- =========================================================
-- 4. PARKING / VEHICLE CLEARANCE REBUILD
-- Downtown lots move behind the service alley. School visitor parking moves
-- east of the right wing, clear of courtyard trees and the sports boundary.
-- =========================================================
local parking = Instance.new("Model")
parking.Name = "V041_ParkingAndVehicles"
parking:SetAttribute("ASC_ClearancePolicy", "BUILDING_6_TREE_10_VEHICLE_6")
parking.Parent = layer

parkingLot(parking, "WestDowntownParking", Vector3.new(-75, 0, -118), Vector3.new(64, 1, 22))
parkingLot(parking, "EastDowntownParking", Vector3.new(75, 0, -118), Vector3.new(64, 1, 22))
parkingLot(parking, "SchoolVisitorParking", Vector3.new(132, 0, 257), Vector3.new(44, 1, 28))

parkedCar(parking, "ParkedCar_1", Vector3.new(-90, 1.5, -118), 0, Color3.fromRGB(69, 107, 149))
parkedCar(parking, "ParkedCar_2", Vector3.new(-58, 1.5, -118), 0, Color3.fromRGB(185, 76, 67))
parkedCar(parking, "ParkedCar_3", Vector3.new(58, 1.5, -118), 0, Color3.fromRGB(213, 206, 190))
parkedCar(parking, "ParkedCar_4", Vector3.new(90, 1.5, -118), 0, Color3.fromRGB(83, 128, 104))
parkedCar(parking, "ParkedCar_5", Vector3.new(121, 1.5, 257), 0, Color3.fromRGB(108, 92, 130))
parkedCar(parking, "ParkedCar_6", Vector3.new(143, 1.5, 257), 0, Color3.fromRGB(204, 157, 64))

-- School bus: separate from the building wall, bike parking and bus shelter.
local bus = Instance.new("Model")
bus.Name = "SchoolBusParked"
bus:SetAttribute("ASC_Prop", "PARKED_SCHOOL_BUS")
bus:SetAttribute("ASC_ClearanceChecked", true)
bus.Parent = parking
local bcf = CFrame.new(-86, 2, 159) * CFrame.Angles(0, math.rad(90), 0)
part(bus, "BusBody", Vector3.new(11, 8, 30), bcf * CFrame.new(0, 4.8, 0), C.yellow, Enum.Material.SmoothPlastic)
part(bus, "BusRoof", Vector3.new(11.3, 1.2, 30.5), bcf * CFrame.new(0, 9.3, 0), C.white, Enum.Material.Metal)
for _, z in ipairs({-10, -3, 4, 11}) do
    local wl = part(bus, "BusWindowL", Vector3.new(0.4, 3, 4.6), bcf * CFrame.new(-5.7, 6.4, z), C.glass, Enum.Material.Glass, 0.18)
    wl.CanCollide = false
    local wr = part(bus, "BusWindowR", Vector3.new(0.4, 3, 4.6), bcf * CFrame.new(5.7, 6.4, z), C.glass, Enum.Material.Glass, 0.18)
    wr.CanCollide = false
end
for _, z in ipairs({-10, 10}) do
    for _, x in ipairs({-5.8, 5.8}) do
        local wheel = part(bus, "BusWheel", Vector3.new(2.8, 2.8, 1.4), bcf * CFrame.new(x, 2.4, z) * CFrame.Angles(0, 0, math.rad(90)), C.dark, Enum.Material.Rubber)
        wheel.Shape = Enum.PartType.Cylinder
    end
end

-- =========================================================
-- 5. REMOVE ROAD-EDGE CLUTTER THAT SAT INSIDE THE ASPHALT ENVELOPE
-- =========================================================
local streetFurnitureV04 = furniture:FindFirstChild("StreetFurnitureV04")
if streetFurnitureV04 then
    for _, obj in ipairs(streetFurnitureV04:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Hydrant" then
            obj:Destroy()
        end
    end
end

root:SetAttribute("ASC_SpatialCleanupPass", "0.4.1-spatial-cleanup-1")
root:SetAttribute("ASC_PlacementPolicy", "SETBACK_SIDEWALK_CURB_ROAD_CLEARANCE")
Workspace:SetAttribute("ASC_SpatialCleanupPass", "0.4.1-spatial-cleanup-1")
print("[AFTER SCHOOL CITY] Spatial Cleanup Pass v0.4.1 initialized")
