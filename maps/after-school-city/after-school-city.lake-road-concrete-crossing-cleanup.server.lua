-- AFTER SCHOOL CITY — Lake Road Concrete Crossing Final Cleanup v0.8.4
-- Screenshot-driven final cleanup for the two V03_ParkLife horizontal concrete paths.
-- Splits PathNorth and PathSouth at the protected NorthSouthRoad asphalt corridor.
-- NorthSouthRoad geometry is strictly read-only. No central-intersection, orientation,
-- gameplay, economy, persistence, monetization, or dedication authority.

local Workspace = game:GetService("Workspace")

local VERSION = "0.8.4-lake-road-concrete-crossing-final-cleanup-1"
local ROAD_CLEAR_MARGIN = 1.5
local MIN_SEGMENT_WIDTH = 2.0
local TARGET_NAMES = { "PathNorth", "PathSouth" }

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V084 LakeRoadCleanup] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_SouthRoadConcreteCleanupPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V084 LakeRoadCleanup] AfterSchoolCity root missing")
    return
end

if root:FindFirstChild("V084_LakeRoadConcreteCrossingCleanup") then
    return
end

local roadsFolder = root:FindFirstChild("RoadsAndPaths")
local districts = root:FindFirstChild("Districts")
local park = districts and districts:FindFirstChild("Park")
local road = roadsFolder and roadsFolder:FindFirstChild("NorthSouthRoad")
local parkLife = park and park:WaitForChild("V03_ParkLife", 20)

if not roadsFolder or not park or not parkLife or not road or not road:IsA("BasePart") then
    warn("[ASC V084 LakeRoadCleanup] lake road authority objects missing")
    return
end

if road.Material ~= Enum.Material.Asphalt then
    warn("[ASC V084 LakeRoadCleanup] NorthSouthRoad is no longer Asphalt; refusing cleanup")
    return
end

-- This cleanup is deliberately constrained to the axis-aligned source geometry seen in V0.8.3.
-- Refuse to mutate anything if source orientation has drifted.
local worldX = Vector3.new(1, 0, 0)
local function isWorldXAligned(part)
    return math.abs(part.CFrame.RightVector:Dot(worldX)) >= 0.999
end

if not isWorldXAligned(road) then
    warn("[ASC V084 LakeRoadCleanup] NorthSouthRoad orientation drifted; refusing cleanup")
    return
end

-- Hard guard: V0.8.4 never owns road geometry. Snapshot exact state before Park mutation.
local roadSnapshot = {
    Parent = road.Parent,
    CFrame = road.CFrame,
    Size = road.Size,
    Material = road.Material,
    Color = road.Color,
    Transparency = road.Transparency,
    CanCollide = road.CanCollide,
}

local roadMinX = road.Position.X - road.Size.X * 0.5
local roadMaxX = road.Position.X + road.Size.X * 0.5
local safeLeftMaxX = roadMinX - ROAD_CLEAR_MARGIN
local safeRightMinX = roadMaxX + ROAD_CLEAR_MARGIN

local function rangesOverlap(aMin, aMax, bMin, bMax)
    return aMax > bMin and aMin < bMax
end

local function roadZOverlap(part)
    local roadMinZ = road.Position.Z - road.Size.Z * 0.5
    local roadMaxZ = road.Position.Z + road.Size.Z * 0.5
    local partMinZ = part.Position.Z - part.Size.Z * 0.5
    local partMaxZ = part.Position.Z + part.Size.Z * 0.5
    return rangesOverlap(partMinZ, partMaxZ, roadMinZ, roadMaxZ)
end

-- Preflight both exact targets before changing either one. This prevents a partial cleanup
-- if a future source revision changes the expected Park loop structure.
local plans = {}
for _, name in ipairs(TARGET_NAMES) do
    local part = parkLife:FindFirstChild(name)
    if not part or not part:IsA("BasePart") then
        warn("[ASC V084 LakeRoadCleanup] exact target missing: " .. name)
        return
    end
    if part.Material ~= Enum.Material.Concrete then
        warn("[ASC V084 LakeRoadCleanup] exact target is no longer Concrete: " .. name)
        return
    end
    if not isWorldXAligned(part) then
        warn("[ASC V084 LakeRoadCleanup] exact target orientation drifted: " .. name)
        return
    end
    if not roadZOverlap(part) then
        warn("[ASC V084 LakeRoadCleanup] exact target no longer crosses NorthSouthRoad Z corridor: " .. name)
        return
    end

    local pathMinX = part.Position.X - part.Size.X * 0.5
    local pathMaxX = part.Position.X + part.Size.X * 0.5
    if not rangesOverlap(pathMinX, pathMaxX, roadMinX, roadMaxX) then
        warn("[ASC V084 LakeRoadCleanup] exact target already clear or source drifted: " .. name)
        return
    end

    local leftWidth = safeLeftMaxX - pathMinX
    local rightWidth = pathMaxX - safeRightMinX
    if leftWidth < MIN_SEGMENT_WIDTH or rightWidth < MIN_SEGMENT_WIDTH then
        warn("[ASC V084 LakeRoadCleanup] unsafe remaining segment width for " .. name)
        return
    end

    table.insert(plans, {
        part = part,
        name = name,
        originalSizeX = part.Size.X,
        originalPositionX = part.Position.X,
        leftWidth = leftWidth,
        leftCenterX = (pathMinX + safeLeftMaxX) * 0.5,
        rightWidth = rightWidth,
        rightCenterX = (safeRightMinX + pathMaxX) * 0.5,
    })
end

local layer = Instance.new("Model")
layer.Name = "V084_LakeRoadConcreteCrossingCleanup"
layer:SetAttribute("ASC_Layer", "LAKE_ROAD_CONCRETE_CROSSING_FINAL_CLEANUP")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

local createdSegments = 0
for _, plan in ipairs(plans) do
    local original = plan.part

    local west = original:Clone()
    west.Name = plan.name .. "_W"
    west.Size = Vector3.new(plan.leftWidth, original.Size.Y, original.Size.Z)
    west.CFrame = original.CFrame + Vector3.new(plan.leftCenterX - original.Position.X, 0, 0)
    west:SetAttribute("ASC_V084Split", true)
    west:SetAttribute("ASC_V084Side", "WEST")
    west:SetAttribute("ASC_V084SourceName", plan.name)
    west:SetAttribute("ASC_V084OriginalSizeX", plan.originalSizeX)
    west:SetAttribute("ASC_V084OriginalPositionX", plan.originalPositionX)
    west.CanTouch = false
    west.Parent = parkLife

    local east = original:Clone()
    east.Name = plan.name .. "_E"
    east.Size = Vector3.new(plan.rightWidth, original.Size.Y, original.Size.Z)
    east.CFrame = original.CFrame + Vector3.new(plan.rightCenterX - original.Position.X, 0, 0)
    east:SetAttribute("ASC_V084Split", true)
    east:SetAttribute("ASC_V084Side", "EAST")
    east:SetAttribute("ASC_V084SourceName", plan.name)
    east:SetAttribute("ASC_V084OriginalSizeX", plan.originalSizeX)
    east:SetAttribute("ASC_V084OriginalPositionX", plan.originalPositionX)
    east.CanTouch = false
    east.Parent = parkLife

    original:Destroy()
    createdSegments += 2
end

local function overlapsRoadXZ(part)
    local minX = part.Position.X - part.Size.X * 0.5
    local maxX = part.Position.X + part.Size.X * 0.5
    local minZ = part.Position.Z - part.Size.Z * 0.5
    local maxZ = part.Position.Z + part.Size.Z * 0.5
    local roadMinZ = road.Position.Z - road.Size.Z * 0.5
    local roadMaxZ = road.Position.Z + road.Size.Z * 0.5
    return rangesOverlap(minX, maxX, roadMinX, roadMaxX)
        and rangesOverlap(minZ, maxZ, roadMinZ, roadMaxZ)
end

-- Exact acceptance: originals are gone and all four replacement segments stop before asphalt.
local remainingOverlaps = 0
local missingSegments = 0
for _, name in ipairs(TARGET_NAMES) do
    if parkLife:FindFirstChild(name) then
        remainingOverlaps += 1
        warn("[ASC V084 LakeRoadCleanup] unsplit original remains: " .. name)
    end
    for _, suffix in ipairs({ "_W", "_E" }) do
        local segment = parkLife:FindFirstChild(name .. suffix)
        if not segment or not segment:IsA("BasePart") then
            missingSegments += 1
            warn("[ASC V084 LakeRoadCleanup] replacement segment missing: " .. name .. suffix)
        elseif overlapsRoadXZ(segment) then
            remainingOverlaps += 1
            warn("[ASC V084 LakeRoadCleanup] replacement still overlaps asphalt: " .. name .. suffix)
        end
    end
end

-- Hard-lock verification: NorthSouthRoad must remain byte-for-byte equivalent in owned properties.
local roadUnchanged = road.Parent == roadSnapshot.Parent
    and road.CFrame == roadSnapshot.CFrame
    and road.Size == roadSnapshot.Size
    and road.Material == roadSnapshot.Material
    and road.Color == roadSnapshot.Color
    and road.Transparency == roadSnapshot.Transparency
    and road.CanCollide == roadSnapshot.CanCollide

if not roadUnchanged then
    warn("[ASC V084 LakeRoadCleanup] HARD LOCK FAILED: NorthSouthRoad changed unexpectedly")
    layer:Destroy()
    return
end

local pass = createdSegments == 4 and missingSegments == 0 and remainingOverlaps == 0
layer:SetAttribute("ASC_V084Targets", 2)
layer:SetAttribute("ASC_V084CreatedSegments", createdSegments)
layer:SetAttribute("ASC_V084MissingSegments", missingSegments)
layer:SetAttribute("ASC_V084RemainingOverlaps", remainingOverlaps)
layer:SetAttribute("ASC_V084RoadClearMargin", ROAD_CLEAR_MARGIN)
layer:SetAttribute("ASC_V084RoadUnchanged", true)
layer:SetAttribute("ASC_V084Pass", pass)

root:SetAttribute("ASC_LakeRoadConcreteCrossingCleanupV084", pass)
root:SetAttribute("ASC_AsphaltLakeRoadPriority", true)
Workspace:SetAttribute("ASC_LakeRoadConcreteCrossingCleanupPass", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V0.8.4 lake road concrete crossing cleanup initialized; targets=2 segments=%d missing=%d remaining=%d roadUnchanged=true pass=%s",
    createdSegments,
    missingSegments,
    remainingOverlaps,
    tostring(pass)
))
