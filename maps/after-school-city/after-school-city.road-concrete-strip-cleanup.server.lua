-- AFTER SCHOOL CITY — Road Concrete Strip Cleanup v0.8.1
-- Screenshot-driven cleanup for legacy 280-stud CrossSidewalk slabs that visually cover asphalt.
-- Removes only the broad legacy sidewalk strips from StreetLife and restores compact sidewalk
-- edge segments around the surviving Z=62 cross street. Road/asphalt geometry is not modified.
-- No orientation, gameplay, economy, persistence, clubs, monetization, or dedication authority.

local Workspace = game:GetService("Workspace")

local VERSION = "0.8.1-road-concrete-strip-cleanup-1"
local C = {
    sidewalk = Color3.fromRGB(194, 199, 205),
}

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V081 RoadCleanup] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_StudentRowInteriorSignFinalizePass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V081 RoadCleanup] AfterSchoolCity root missing")
    return
end

if root:FindFirstChild("V081_RoadConcreteStripCleanup") then
    return
end

local streetLife = root:FindFirstChild("V04_StreetLife")
local grid = streetLife and streetLife:FindFirstChild("SecondaryStreetGrid")
if not grid then
    warn("[ASC V081 RoadCleanup] SecondaryStreetGrid missing")
    return
end

local layer = Instance.new("Model")
layer.Name = "V081_RoadConcreteStripCleanup"
layer:SetAttribute("ASC_Layer", "ROAD_CONCRETE_STRIP_CLEANUP")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

local removed = 0
local segmentsAdded = 0

-- Remove all four legacy full-width concrete strips. Two at Z≈117/147 are orphaned
-- because their Z=132 cross street was removed in V0.4.1; the Z≈47/77 pair also
-- spans directly across the main and side-road asphalt, producing the screenshot defect.
local garbage = {}
for _, child in ipairs(grid:GetChildren()) do
    if child:IsA("BasePart")
        and (child.Name == "CrossSidewalkN" or child.Name == "CrossSidewalkS")
        and child.Size.X >= 200 then
        table.insert(garbage, child)
    end
end
for _, child in ipairs(garbage) do
    child:Destroy()
    removed += 1
end

local function sidewalkSegment(name, x, z)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    -- Segment spans from the outer edge of the main-road sidewalk (X≈30)
    -- to the inner edge of the side-road sidewalk (X≈105), never over asphalt.
    p.Size = Vector3.new(75, 0.55, 5.2)
    p.CFrame = CFrame.new(x, 1.2, z)
    p.Color = C.sidewalk
    p.Material = Enum.Material.Concrete
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.CanCollide = true
    p.CanTouch = false
    p:SetAttribute("ASC_V081RoadClearSidewalk", true)
    p.Parent = layer
    segmentsAdded += 1
end

-- Keep useful pedestrian edges only around the surviving CrossStreet at Z=62.
-- Four compact pieces replace the two old 280-stud slabs without covering road surface.
for _, z in ipairs({47, 77}) do
    sidewalkSegment("CrossStreetSidewalkWest", -67.5, z)
    sidewalkSegment("CrossStreetSidewalkEast", 67.5, z)
end

-- Fail closed: no legacy full-width CrossSidewalk may remain anywhere in StreetLife.
local residual = 0
for _, descendant in ipairs(streetLife:GetDescendants()) do
    if descendant:IsA("BasePart")
        and (descendant.Name == "CrossSidewalkN" or descendant.Name == "CrossSidewalkS")
        and descendant.Size.X >= 200 then
        residual += 1
        descendant:Destroy()
        removed += 1
    end
end

layer:SetAttribute("ASC_V081LegacyConcreteStripsRemoved", removed)
layer:SetAttribute("ASC_V081CompactSidewalkSegmentsAdded", segmentsAdded)
layer:SetAttribute("ASC_V081ResidualFullWidthStrips", residual)
root:SetAttribute("ASC_RoadConcreteStripCleanupV081", true)
root:SetAttribute("ASC_AsphaltVisualPriority", true)
Workspace:SetAttribute("ASC_RoadConcreteStripCleanupPass", VERSION)

print(string.format("[AFTER SCHOOL CITY] V0.8.1 road concrete cleanup initialized; removed=%d compactSegments=%d residual=%d", removed, segmentsAdded, residual))
