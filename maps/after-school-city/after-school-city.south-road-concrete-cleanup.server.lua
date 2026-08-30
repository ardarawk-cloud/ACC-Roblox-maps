-- AFTER SCHOOL CITY — South Road Concrete Cleanup v0.8.3
-- Narrow screenshot-driven cleanup for the south Park / NorthSouthRoad overlap only.
-- Trims the exact low path / pale border slabs that visually intrude into drivable asphalt.
-- NorthSouthRoad geometry and the already-clean central intersection are read-only.
-- No orientation, gameplay, economy, persistence, monetization, or dedication authority.

local Workspace = game:GetService("Workspace")

local VERSION = "0.8.3-south-road-concrete-cleanup-1"
local ROAD_CLEAR_MARGIN = 1.5
local MIN_REMAINING_WIDTH = 2.0

local TARGETS = {
    WalkingPath = "WEST",
    LakeBorderN = "EAST",
    LakeBorderS = "EAST",
}

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V083 SouthRoadCleanup] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_RoadSidewalkIntersectionCleanupPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V083 SouthRoadCleanup] AfterSchoolCity root missing")
    return
end

if root:FindFirstChild("V083_SouthRoadConcreteCleanup") then
    return
end

local roadsFolder = root:FindFirstChild("RoadsAndPaths")
local districts = root:FindFirstChild("Districts")
local park = districts and districts:FindFirstChild("Park")
local road = roadsFolder and roadsFolder:FindFirstChild("NorthSouthRoad")

if not roadsFolder or not park or not road or not road:IsA("BasePart") then
    warn("[ASC V083 SouthRoadCleanup] south road authority objects missing")
    return
end

if road.Material ~= Enum.Material.Asphalt then
    warn("[ASC V083 SouthRoadCleanup] NorthSouthRoad is no longer Asphalt; refusing cleanup")
    return
end

-- Hard guard: this pass never owns road geometry. Snapshot the exact road state before touching Park.
local roadSnapshot = {
    Parent = road.Parent,
    CFrame = road.CFrame,
    Size = road.Size,
    Material = road.Material,
    Color = road.Color,
    Transparency = road.Transparency,
    CanCollide = road.CanCollide,
}

local layer = Instance.new("Model")
layer.Name = "V083_SouthRoadConcreteCleanup"
layer:SetAttribute("ASC_Layer", "SOUTH_ROAD_CONCRETE_CLEANUP")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

local roadMinX = road.Position.X - road.Size.X * 0.5
local roadMaxX = road.Position.X + road.Size.X * 0.5
local roadMinZ = road.Position.Z - road.Size.Z * 0.5
local roadMaxZ = road.Position.Z + road.Size.Z * 0.5

local function rangesOverlap(aMin, aMax, bMin, bMax)
    return aMax > bMin and aMin < bMax
end

local function overlapsRoadXZ(part)
    local minX = part.Position.X - part.Size.X * 0.5
    local maxX = part.Position.X + part.Size.X * 0.5
    local minZ = part.Position.Z - part.Size.Z * 0.5
    local maxZ = part.Position.Z + part.Size.Z * 0.5
    return rangesOverlap(minX, maxX, roadMinX, roadMaxX)
        and rangesOverlap(minZ, maxZ, roadMinZ, roadMaxZ)
end

local trimmed = 0
local alreadyClear = 0
local missing = 0
local rejected = 0

local function trimWest(part)
    local minX = part.Position.X - part.Size.X * 0.5
    local maxX = part.Position.X + part.Size.X * 0.5
    local safeMaxX = roadMinX - ROAD_CLEAR_MARGIN

    if maxX <= safeMaxX then
        return false, "already-clear"
    end

    local newWidth = safeMaxX - minX
    if newWidth < MIN_REMAINING_WIDTH then
        return false, "remaining-width-too-small"
    end

    local newCenterX = (minX + safeMaxX) * 0.5
    part.Size = Vector3.new(newWidth, part.Size.Y, part.Size.Z)
    part.CFrame = part.CFrame + Vector3.new(newCenterX - part.Position.X, 0, 0)
    return true, nil
end

local function trimEast(part)
    local minX = part.Position.X - part.Size.X * 0.5
    local maxX = part.Position.X + part.Size.X * 0.5
    local safeMinX = roadMaxX + ROAD_CLEAR_MARGIN

    if minX >= safeMinX then
        return false, "already-clear"
    end

    local newWidth = maxX - safeMinX
    if newWidth < MIN_REMAINING_WIDTH then
        return false, "remaining-width-too-small"
    end

    local newCenterX = (safeMinX + maxX) * 0.5
    part.Size = Vector3.new(newWidth, part.Size.Y, part.Size.Z)
    part.CFrame = part.CFrame + Vector3.new(newCenterX - part.Position.X, 0, 0)
    return true, nil
end

for name, side in pairs(TARGETS) do
    local part = park:FindFirstChild(name)
    if not part or not part:IsA("BasePart") then
        missing += 1
        warn("[ASC V083 SouthRoadCleanup] target missing: " .. name)
    elseif not overlapsRoadXZ(part) then
        alreadyClear += 1
        part:SetAttribute("ASC_V083AlreadyClear", true)
    else
        local originalSize = part.Size
        local originalPosition = part.Position
        local changed, reason

        if side == "WEST" then
            changed, reason = trimWest(part)
        else
            changed, reason = trimEast(part)
        end

        if changed then
            trimmed += 1
            part:SetAttribute("ASC_V083Trimmed", true)
            part:SetAttribute("ASC_V083Side", side)
            part:SetAttribute("ASC_V083OriginalSizeX", originalSize.X)
            part:SetAttribute("ASC_V083OriginalPositionX", originalPosition.X)
            part.CanTouch = false
        elseif reason == "already-clear" then
            alreadyClear += 1
        else
            rejected += 1
            warn(string.format(
                "[ASC V083 SouthRoadCleanup] refused unsafe trim for %s (%s)",
                name,
                tostring(reason)
            ))
        end
    end
end

-- Exact acceptance check: none of the three owned Park targets may still overlap drivable asphalt.
local remainingOverlaps = 0
for name in pairs(TARGETS) do
    local part = park:FindFirstChild(name)
    if part and part:IsA("BasePart") and overlapsRoadXZ(part) then
        remainingOverlaps += 1
        warn("[ASC V083 SouthRoadCleanup] remaining road overlap: " .. name)
    end
end

-- Hard-lock verification: V0.8.3 must not mutate NorthSouthRoad in any way.
local roadUnchanged = road.Parent == roadSnapshot.Parent
    and road.CFrame == roadSnapshot.CFrame
    and road.Size == roadSnapshot.Size
    and road.Material == roadSnapshot.Material
    and road.Color == roadSnapshot.Color
    and road.Transparency == roadSnapshot.Transparency
    and road.CanCollide == roadSnapshot.CanCollide

if not roadUnchanged then
    warn("[ASC V083 SouthRoadCleanup] HARD LOCK FAILED: NorthSouthRoad changed unexpectedly")
    layer:Destroy()
    return
end

layer:SetAttribute("ASC_V083Targets", 3)
layer:SetAttribute("ASC_V083Trimmed", trimmed)
layer:SetAttribute("ASC_V083AlreadyClear", alreadyClear)
layer:SetAttribute("ASC_V083Missing", missing)
layer:SetAttribute("ASC_V083Rejected", rejected)
layer:SetAttribute("ASC_V083RemainingOverlaps", remainingOverlaps)
layer:SetAttribute("ASC_V083RoadUnchanged", true)

root:SetAttribute("ASC_SouthRoadConcreteCleanupV083", remainingOverlaps == 0 and rejected == 0)
root:SetAttribute("ASC_AsphaltSouthRoadPriority", true)
Workspace:SetAttribute("ASC_SouthRoadConcreteCleanupPass", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V0.8.3 south road concrete cleanup initialized; trimmed=%d clear=%d missing=%d rejected=%d remaining=%d roadUnchanged=true",
    trimmed,
    alreadyClear,
    missing,
    rejected,
    remainingOverlaps
))
