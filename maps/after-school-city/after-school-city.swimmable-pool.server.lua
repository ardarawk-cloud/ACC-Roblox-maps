-- AFTER SCHOOL CITY — Native Swimmable Pool v0.8.8
-- Converts the cleaned Park/Lake footprint into a usable native Roblox swimming pool.
-- Uses Terrain Water so Humanoids enter the built-in Swimming state automatically.
-- Scope: Park/Lake presentation + a new self-contained pool layer only.
-- Protected roads, intersections, orientation, centerline, economy, persistence,
-- monetization and dedication remain read-only.

local Workspace = game:GetService("Workspace")

local VERSION = "0.8.8-native-swimmable-pool-1"
local WATER_INSET = 4.5
local WATER_DEPTH = 5.0
local WALL_THICKNESS = 2.0
local WALL_TOP_CLEARANCE = 0.35
local POSITION_EPSILON = 0.01

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V088 Pool] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_SkateparkApproachMicroCleanupPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V088 Pool] AfterSchoolCity root missing")
    return
end

if root:FindFirstChild("V088_SwimmablePool") then
    return
end

local districts = root:FindFirstChild("Districts")
local roads = root:FindFirstChild("RoadsAndPaths")
local park = districts and districts:FindFirstChild("Park")
local lake = park and park:FindFirstChild("Lake")
local road = roads and roads:FindFirstChild("NorthSouthRoad")
local terrain = Workspace:FindFirstChildOfClass("Terrain")

if not park or not lake or not lake:IsA("BasePart") then
    warn("[ASC V088 Pool] Park/Lake authority missing")
    return
end
if not road or not road:IsA("BasePart") or road.Material ~= Enum.Material.Asphalt then
    warn("[ASC V088 Pool] protected NorthSouthRoad authority missing")
    return
end
if not terrain then
    warn("[ASC V088 Pool] Workspace Terrain missing")
    return
end
if lake.Material ~= Enum.Material.Glass then
    warn("[ASC V088 Pool] Lake material drifted; refusing conversion")
    return
end
if lake:GetAttribute("ASC_V085Trimmed") ~= true then
    warn("[ASC V088 Pool] post-V0.8.5 lake geometry authority missing")
    return
end

local roadSnapshot = {
    Parent = road.Parent,
    CFrame = road.CFrame,
    Size = road.Size,
    Material = road.Material,
    Color = road.Color,
    Transparency = road.Transparency,
    CanCollide = road.CanCollide,
}
local lakeSnapshot = {
    Parent = lake.Parent,
    CFrame = lake.CFrame,
    Size = lake.Size,
    Material = lake.Material,
    Color = lake.Color,
}

local waterSizeX = lake.Size.X - WATER_INSET * 2
local waterSizeZ = lake.Size.Z - WATER_INSET * 2
if waterSizeX < 20 or waterSizeZ < 20 then
    warn("[ASC V088 Pool] cleaned Lake footprint too small for safe swim volume")
    return
end

local roadMaxX = road.Position.X + road.Size.X * 0.5
local lakeMinX = lake.Position.X - lake.Size.X * 0.5
local waterMinX = lake.Position.X - waterSizeX * 0.5
if waterMinX <= roadMaxX + 3.5 then
    warn("[ASC V088 Pool] water voxel safety margin to NorthSouthRoad is insufficient")
    return
end

local sourceSurfaceY = lake.Position.Y + lake.Size.Y * 0.5
local waterBottomY = sourceSurfaceY
local waterTopY = waterBottomY + WATER_DEPTH
local waterCenterY = (waterBottomY + waterTopY) * 0.5
local poolCenter = Vector3.new(lake.Position.X, waterCenterY, lake.Position.Z)

local layer = Instance.new("Model")
layer.Name = "V088_SwimmablePool"
layer:SetAttribute("ASC_Layer", "NATIVE_SWIMMABLE_POOL")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

local function makePart(name, size, cframe, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cframe
    p.Color = color
    p.Material = material
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = layer
    return p
end

local concreteColor = Color3.fromRGB(210, 213, 216)
local copingColor = Color3.fromRGB(232, 234, 236)
local floorColor = Color3.fromRGB(111, 176, 194)
local metalColor = Color3.fromRGB(76, 82, 90)

-- Hide the legacy glass sheet but preserve its exact post-road-fix transform as authority.
lake.Transparency = 1
lake.CanCollide = false
lake.CanTouch = false
lake.CanQuery = false
lake.CastShadow = false
lake:SetAttribute("ASC_V088ConvertedToNativeWater", true)

-- Pool floor sits just below the Terrain Water volume, above the untouched ParkGround.
local floorY = waterBottomY - 0.18
local poolFloor = makePart(
    "PoolFloor",
    Vector3.new(waterSizeX, 0.3, waterSizeZ),
    CFrame.new(lake.Position.X, floorY, lake.Position.Z),
    floorColor,
    Enum.Material.SmoothPlastic
)
poolFloor.CanCollide = true

-- Retaining walls form a clean above-ground basin around the native water volume.
local wallBottomY = floorY - 0.15
local wallTopY = waterTopY + WALL_TOP_CLEARANCE
local wallHeight = wallTopY - wallBottomY
local wallCenterY = (wallBottomY + wallTopY) * 0.5
local halfX = waterSizeX * 0.5
local halfZ = waterSizeZ * 0.5

local westWallX = lake.Position.X - halfX - WALL_THICKNESS * 0.5
local eastWallX = lake.Position.X + halfX + WALL_THICKNESS * 0.5
local northWallZ = lake.Position.Z - halfZ - WALL_THICKNESS * 0.5
local southWallZ = lake.Position.Z + halfZ + WALL_THICKNESS * 0.5

makePart("PoolWallWest", Vector3.new(WALL_THICKNESS, wallHeight, waterSizeZ + WALL_THICKNESS * 2), CFrame.new(westWallX, wallCenterY, lake.Position.Z), concreteColor, Enum.Material.Concrete)
makePart("PoolWallEast", Vector3.new(WALL_THICKNESS, wallHeight, waterSizeZ + WALL_THICKNESS * 2), CFrame.new(eastWallX, wallCenterY, lake.Position.Z), concreteColor, Enum.Material.Concrete)
makePart("PoolWallNorth", Vector3.new(waterSizeX, wallHeight, WALL_THICKNESS), CFrame.new(lake.Position.X, wallCenterY, northWallZ), concreteColor, Enum.Material.Concrete)
makePart("PoolWallSouth", Vector3.new(waterSizeX, wallHeight, WALL_THICKNESS), CFrame.new(lake.Position.X, wallCenterY, southWallZ), concreteColor, Enum.Material.Concrete)

-- Narrow coping makes the top edge readable without covering the swim surface.
local copingY = wallTopY + 0.12
makePart("PoolCopingWest", Vector3.new(WALL_THICKNESS + 0.5, 0.35, waterSizeZ + WALL_THICKNESS * 2.5), CFrame.new(westWallX, copingY, lake.Position.Z), copingColor, Enum.Material.Concrete)
makePart("PoolCopingEast", Vector3.new(WALL_THICKNESS + 0.5, 0.35, waterSizeZ + WALL_THICKNESS * 2.5), CFrame.new(eastWallX, copingY, lake.Position.Z), copingColor, Enum.Material.Concrete)
makePart("PoolCopingNorth", Vector3.new(waterSizeX, 0.35, WALL_THICKNESS + 0.5), CFrame.new(lake.Position.X, copingY, northWallZ), copingColor, Enum.Material.Concrete)
makePart("PoolCopingSouth", Vector3.new(waterSizeX, 0.35, WALL_THICKNESS + 0.5), CFrame.new(lake.Position.X, copingY, southWallZ), copingColor, Enum.Material.Concrete)

-- Four compact exterior steps on the east side give reliable mobile access.
local stepWidth = 9.0
local stepDepth = 2.4
for i = 1, 4 do
    local h = i * 1.25
    local stepX = eastWallX + WALL_THICKNESS * 0.5 + stepDepth * (4.5 - i)
    local step = makePart(
        "PoolEntryStep" .. i,
        Vector3.new(stepDepth, h, stepWidth),
        CFrame.new(stepX, 1.0 + h * 0.5, lake.Position.Z),
        concreteColor,
        Enum.Material.Concrete
    )
    step.CanCollide = true
end

-- Climbable ladder inside the east wall helps players exit the pool on mobile.
local ladder = Instance.new("TrussPart")
ladder.Name = "PoolExitLadder"
ladder.Anchored = true
ladder.Size = Vector3.new(1.2, math.max(4, WATER_DEPTH - 0.3), 3.2)
ladder.CFrame = CFrame.new(eastWallX - WALL_THICKNESS * 0.65, waterBottomY + WATER_DEPTH * 0.5, lake.Position.Z)
ladder.Color = metalColor
ladder.Material = Enum.Material.Metal
ladder.Parent = layer

-- Native Terrain Water: this is what gives Roblox Humanoids real Swimming behavior.
terrain:FillBlock(
    CFrame.new(poolCenter),
    Vector3.new(waterSizeX, WATER_DEPTH, waterSizeZ),
    Enum.Material.Water
)

local roadUnchanged = road.Parent == roadSnapshot.Parent
    and road.CFrame == roadSnapshot.CFrame
    and road.Size == roadSnapshot.Size
    and road.Material == roadSnapshot.Material
    and road.Color == roadSnapshot.Color
    and road.Transparency == roadSnapshot.Transparency
    and road.CanCollide == roadSnapshot.CanCollide

local lakeTransformPreserved = lake.Parent == lakeSnapshot.Parent
    and lake.CFrame == lakeSnapshot.CFrame
    and lake.Size == lakeSnapshot.Size
    and lake.Material == lakeSnapshot.Material
    and lake.Color == lakeSnapshot.Color

if not roadUnchanged or not lakeTransformPreserved then
    warn("[ASC V088 Pool] HARD LOCK FAILED after pool creation")
    layer:SetAttribute("ASC_V088Pass", false)
    return
end

layer:SetAttribute("ASC_V088WaterSizeX", waterSizeX)
layer:SetAttribute("ASC_V088WaterSizeY", WATER_DEPTH)
layer:SetAttribute("ASC_V088WaterSizeZ", waterSizeZ)
layer:SetAttribute("ASC_V088WaterBottomY", waterBottomY)
layer:SetAttribute("ASC_V088WaterTopY", waterTopY)
layer:SetAttribute("ASC_V088WaterMinX", waterMinX)
layer:SetAttribute("ASC_V088RoadMaxX", roadMaxX)
layer:SetAttribute("ASC_V088NativeTerrainWater", true)
layer:SetAttribute("ASC_V088RoadUnchanged", true)
layer:SetAttribute("ASC_V088LakeTransformPreserved", true)
layer:SetAttribute("ASC_V088Pass", true)

root:SetAttribute("ASC_SwimmablePoolV088", true)
root:SetAttribute("ASC_ParkPoolUsesNativeSwimming", true)
Workspace:SetAttribute("ASC_SwimmablePoolPass", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V0.8.8 native swimmable pool initialized; water=%.2fx%.2fx%.2f topY=%.2f roadMargin=%.2f nativeSwimming=true",
    waterSizeX,
    WATER_DEPTH,
    waterSizeZ,
    waterTopY,
    waterMinX - roadMaxX
))
