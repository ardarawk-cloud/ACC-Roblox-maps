-- AFTER SCHOOL CITY — Road / Sidewalk Intersection Cleanup v0.8.2
-- Screenshot-driven asphalt-priority pass.
-- Splits legacy long sidewalk strips at every perpendicular asphalt-road crossing so concrete
-- remains on road edges instead of painting broad bars across drivable asphalt.
-- Asphalt road geometry is never moved, resized, recolored, hidden, or destroyed.
-- No orientation, gameplay, economy, persistence, clubs, monetization, or dedication authority.

local Workspace = game:GetService("Workspace")

local VERSION = "0.8.2-road-sidewalk-intersection-cleanup-1"
local CUT_MARGIN = 1.5
local MIN_SEGMENT = 2.0
local PERPENDICULAR_DOT_MAX = 0.45

local MAIN_SIDEWALK_NAMES = {
    NS_Sidewalk_W = true,
    NS_Sidewalk_E = true,
    EW_Sidewalk_N = true,
    EW_Sidewalk_S = true,
}

local GRID_SIDEWALK_NAMES = {
    SidewalkW = true,
    SidewalkE = true,
}

local ROAD_SURFACE_NAMES = {
    NorthSouthRoad = true,
    EastWestRoad = true,
    SchoolSportsRoad = true,
    SideStreet = true,
    CrossStreet = true,
}

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V082 SidewalkCleanup] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_RoadConcreteStripCleanupPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V082 SidewalkCleanup] AfterSchoolCity root missing")
    return
end

if root:FindFirstChild("V082_RoadSidewalkIntersectionCleanup") then
    return
end

local roadsFolder = root:FindFirstChild("RoadsAndPaths")
local streetLife = root:FindFirstChild("V04_StreetLife")
local grid = streetLife and streetLife:FindFirstChild("SecondaryStreetGrid")
if not roadsFolder or not grid then
    warn("[ASC V082 SidewalkCleanup] road authority containers missing")
    return
end

local layer = Instance.new("Model")
layer.Name = "V082_RoadSidewalkIntersectionCleanup"
layer:SetAttribute("ASC_Layer", "ROAD_SIDEWALK_INTERSECTION_CLEANUP")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

-- Return vectors that match local +X / +Z offsets used when rebuilding segments.
local function dominantHorizontalAxis(part)
    if part.Size.X >= part.Size.Z then
        return part.CFrame.RightVector, "X", part.Size.X, part.Size.Z
    end
    return -part.CFrame.LookVector, "Z", part.Size.Z, part.Size.X
end

local function projectedHalfExtent(part, axis)
    return math.abs(axis:Dot(part.CFrame.RightVector)) * part.Size.X * 0.5
        + math.abs(axis:Dot(part.CFrame.UpVector)) * part.Size.Y * 0.5
        + math.abs(axis:Dot(part.CFrame.LookVector)) * part.Size.Z * 0.5
end

local roadSurfaces = {}
for _, descendant in ipairs(root:GetDescendants()) do
    if descendant:IsA("BasePart")
        and descendant.Material == Enum.Material.Asphalt
        and ROAD_SURFACE_NAMES[descendant.Name] then
        table.insert(roadSurfaces, descendant)
    end
end

local sidewalkTargets = {}
for _, child in ipairs(roadsFolder:GetChildren()) do
    if child:IsA("BasePart") and MAIN_SIDEWALK_NAMES[child.Name] then
        table.insert(sidewalkTargets, child)
    end
end
for _, child in ipairs(grid:GetChildren()) do
    if child:IsA("BasePart") and GRID_SIDEWALK_NAMES[child.Name] then
        table.insert(sidewalkTargets, child)
    end
end

local function mergeCuts(cuts, halfLength)
    if #cuts == 0 then
        return cuts
    end
    table.sort(cuts, function(a, b)
        return a[1] < b[1]
    end)
    local merged = {}
    for _, cut in ipairs(cuts) do
        local a = math.max(-halfLength, cut[1])
        local b = math.min(halfLength, cut[2])
        if b > a then
            local last = merged[#merged]
            if last and a <= last[2] then
                last[2] = math.max(last[2], b)
            else
                table.insert(merged, {a, b})
            end
        end
    end
    return merged
end

local removedLegacy = 0
local segmentsCreated = 0
local intersectionsCut = 0
local untouched = 0

local function buildSegment(original, longAxisName, startOffset, endOffset, index)
    local length = endOffset - startOffset
    if length < MIN_SEGMENT then
        return
    end

    local segment = original:Clone()
    segment.Name = string.format("SidewalkSegment_%s_%02d", original.Name, index)
    segment:SetAttribute("ASC_V082Segment", true)
    segment:SetAttribute("ASC_V082Origin", original.Name)
    segment.CanTouch = false

    local centerOffset = (startOffset + endOffset) * 0.5
    if longAxisName == "X" then
        segment.Size = Vector3.new(length, original.Size.Y, original.Size.Z)
        segment.CFrame = original.CFrame * CFrame.new(centerOffset, 0, 0)
    else
        segment.Size = Vector3.new(original.Size.X, original.Size.Y, length)
        segment.CFrame = original.CFrame * CFrame.new(0, 0, centerOffset)
    end
    segment.Parent = layer
    segmentsCreated += 1
end

for _, sidewalk in ipairs(sidewalkTargets) do
    if sidewalk.Parent then
        local longVector, longAxisName, longLength, shortLength = dominantHorizontalAxis(sidewalk)
        local shortVector = longAxisName == "X" and -sidewalk.CFrame.LookVector or sidewalk.CFrame.RightVector
        local halfLength = longLength * 0.5
        local halfShort = shortLength * 0.5
        local cuts = {}

        for _, road in ipairs(roadSurfaces) do
            if road.Parent then
                local roadLongVector = dominantHorizontalAxis(road)
                local alignment = math.abs(longVector:Dot(roadLongVector))
                if alignment <= PERPENDICULAR_DOT_MAX then
                    local relative = road.Position - sidewalk.Position
                    local shortOffset = relative:Dot(shortVector)
                    local roadHalfAcross = projectedHalfExtent(road, shortVector)
                    if math.abs(shortOffset) < (roadHalfAcross + halfShort - 0.05) then
                        local centerAlong = relative:Dot(longVector)
                        local roadHalfAlong = projectedHalfExtent(road, longVector)
                        local cutA = centerAlong - roadHalfAlong - CUT_MARGIN
                        local cutB = centerAlong + roadHalfAlong + CUT_MARGIN
                        if cutB > -halfLength and cutA < halfLength then
                            table.insert(cuts, {cutA, cutB})
                        end
                    end
                end
            end
        end

        local merged = mergeCuts(cuts, halfLength)
        if #merged > 0 then
            local cursor = -halfLength
            local segmentIndex = 0
            for _, cut in ipairs(merged) do
                if cut[1] - cursor >= MIN_SEGMENT then
                    segmentIndex += 1
                    buildSegment(sidewalk, longAxisName, cursor, cut[1], segmentIndex)
                end
                cursor = math.max(cursor, cut[2])
                intersectionsCut += 1
            end
            if halfLength - cursor >= MIN_SEGMENT then
                segmentIndex += 1
                buildSegment(sidewalk, longAxisName, cursor, halfLength, segmentIndex)
            end
            sidewalk:Destroy()
            removedLegacy += 1
        else
            untouched += 1
        end
    end
end

-- Fail closed for the exact legacy strips that caused the screenshot bars: any remaining long
-- sidewalk target that still overlaps a perpendicular asphalt surface is hidden/non-colliding.
local failClosed = 0
for _, container in ipairs({roadsFolder, grid}) do
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("BasePart")
            and (MAIN_SIDEWALK_NAMES[child.Name] or GRID_SIDEWALK_NAMES[child.Name]) then
            local longVector, longAxisName, longLength, shortLength = dominantHorizontalAxis(child)
            local shortVector = longAxisName == "X" and -child.CFrame.LookVector or child.CFrame.RightVector
            for _, road in ipairs(roadSurfaces) do
                local roadLongVector = dominantHorizontalAxis(road)
                if math.abs(longVector:Dot(roadLongVector)) <= PERPENDICULAR_DOT_MAX then
                    local relative = road.Position - child.Position
                    local shortOffset = relative:Dot(shortVector)
                    local alongOffset = relative:Dot(longVector)
                    if math.abs(shortOffset) < projectedHalfExtent(road, shortVector) + shortLength * 0.5
                        and math.abs(alongOffset) < projectedHalfExtent(road, longVector) + longLength * 0.5 then
                        child.CanCollide = false
                        child.Transparency = 1
                        child:SetAttribute("ASC_V082FailClosed", true)
                        failClosed += 1
                        break
                    end
                end
            end
        end
    end
end

layer:SetAttribute("ASC_V082LegacySidewalksRemoved", removedLegacy)
layer:SetAttribute("ASC_V082SegmentsCreated", segmentsCreated)
layer:SetAttribute("ASC_V082IntersectionsCut", intersectionsCut)
layer:SetAttribute("ASC_V082UntouchedSidewalks", untouched)
layer:SetAttribute("ASC_V082FailClosedCount", failClosed)
root:SetAttribute("ASC_AsphaltIntersectionPriority", true)
root:SetAttribute("ASC_RoadSidewalkIntersectionCleanupV082", true)
Workspace:SetAttribute("ASC_RoadSidewalkIntersectionCleanupPass", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V0.8.2 sidewalk intersection cleanup initialized; removed=%d segments=%d cuts=%d untouched=%d failClosed=%d roads=%d",
    removedLegacy,
    segmentsCreated,
    intersectionsCut,
    untouched,
    failClosed,
    #roadSurfaces
))
