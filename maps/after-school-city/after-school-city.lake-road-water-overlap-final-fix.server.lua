-- AFTER SCHOOL CITY — Lake / Road Water Overlap Final Fix v0.8.5
-- Screenshot-driven final fix for Park/Lake water covering NorthSouthRoad.
-- Owns only the west edge of the exact Lake part. NorthSouthRoad is strictly read-only.
-- No intersection, orientation, centerline, gameplay, economy, persistence, monetization,
-- building, landscaping, or dedication authority.

local Workspace = game:GetService("Workspace")

local VERSION = "0.8.5-lake-road-water-overlap-final-fix-1"
local ROAD_CLEAR_MARGIN = 1.5
local MIN_REMAINING_LAKE_WIDTH = 8.0

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V085 LakeWaterFix] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_LakeRoadConcreteCrossingCleanupPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V085 LakeWaterFix] AfterSchoolCity root missing")
    return
end

if root:FindFirstChild("V085_LakeRoadWaterOverlapFinalFix") then
    return
end

local roadsFolder = root:FindFirstChild("RoadsAndPaths")
local districts = root:FindFirstChild("Districts")
local park = districts and districts:FindFirstChild("Park")
local road = roadsFolder and roadsFolder:FindFirstChild("NorthSouthRoad")
local lake = park and park:FindFirstChild("Lake")

if not roadsFolder or not park or not road or not lake then
    warn("[ASC V085 LakeWaterFix] exact authority objects missing")
    return
end
if not road:IsA("BasePart") or not lake:IsA("BasePart") then
    warn("[ASC V085 LakeWaterFix] road/lake are not BaseParts")
    return
end
if road.Material ~= Enum.Material.Asphalt then
    warn("[ASC V085 LakeWaterFix] NorthSouthRoad is no longer Asphalt; refusing fix")
    return
end
if lake.Material ~= Enum.Material.Glass then
    warn("[ASC V085 LakeWaterFix] Lake is no longer Glass; refusing fix")
    return
end

local worldX = Vector3.new(1, 0, 0)
local function isWorldXAligned(part)
    return math.abs(part.CFrame.RightVector:Dot(worldX)) >= 0.999
end

if not isWorldXAligned(road) or not isWorldXAligned(lake) then
    warn("[ASC V085 LakeWaterFix] source orientation drifted; refusing fix")
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

local originalLake = {
    CFrame = lake.CFrame,
    Size = lake.Size,
    Material = lake.Material,
    Color = lake.Color,
    Transparency = lake.Transparency,
    CanCollide = lake.CanCollide,
}

local function rangesOverlap(aMin, aMax, bMin, bMax)
    return aMax > bMin and aMin < bMax
end

local roadMinX = road.Position.X - road.Size.X * 0.5
local roadMaxX = road.Position.X + road.Size.X * 0.5
local roadMinZ = road.Position.Z - road.Size.Z * 0.5
local roadMaxZ = road.Position.Z + road.Size.Z * 0.5
local lakeMinX = lake.Position.X - lake.Size.X * 0.5
local lakeMaxX = lake.Position.X + lake.Size.X * 0.5
local lakeMinZ = lake.Position.Z - lake.Size.Z * 0.5
local lakeMaxZ = lake.Position.Z + lake.Size.Z * 0.5

if not rangesOverlap(lakeMinZ, lakeMaxZ, roadMinZ, roadMaxZ) then
    warn("[ASC V085 LakeWaterFix] Lake no longer intersects NorthSouthRoad Z corridor")
    return
end
if not rangesOverlap(lakeMinX, lakeMaxX, roadMinX, roadMaxX) then
    warn("[ASC V085 LakeWaterFix] Lake already clear of NorthSouthRoad X corridor")
    return
end

-- Screenshot/source contract: the lake belongs east of the road. Preserve its east edge
-- and trim only the west side until water starts beyond the protected asphalt corridor.
local safeLakeMinX = roadMaxX + ROAD_CLEAR_MARGIN
local newWidthX = lakeMaxX - safeLakeMinX
if newWidthX < MIN_REMAINING_LAKE_WIDTH then
    warn("[ASC V085 LakeWaterFix] remaining lake width would be unsafe; refusing fix")
    return
end
local newCenterX = (safeLakeMinX + lakeMaxX) * 0.5

local layer = Instance.new("Model")
layer.Name = "V085_LakeRoadWaterOverlapFinalFix"
layer:SetAttribute("ASC_Layer", "LAKE_ROAD_WATER_OVERLAP_FINAL_FIX")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

lake.Size = Vector3.new(newWidthX, lake.Size.Y, lake.Size.Z)
lake.CFrame = lake.CFrame + Vector3.new(newCenterX - lake.Position.X, 0, 0)
lake:SetAttribute("ASC_V085Trimmed", true)
lake:SetAttribute("ASC_V085OriginalSizeX", originalLake.Size.X)
lake:SetAttribute("ASC_V085OriginalPositionX", originalLake.CFrame.Position.X)
lake:SetAttribute("ASC_V085RoadClearMargin", ROAD_CLEAR_MARGIN)

local finalLakeMinX = lake.Position.X - lake.Size.X * 0.5
local finalLakeMaxX = lake.Position.X + lake.Size.X * 0.5
local finalLakeMinZ = lake.Position.Z - lake.Size.Z * 0.5
local finalLakeMaxZ = lake.Position.Z + lake.Size.Z * 0.5
local remainingRoadOverlap = rangesOverlap(finalLakeMinX, finalLakeMaxX, roadMinX, roadMaxX)
    and rangesOverlap(finalLakeMinZ, finalLakeMaxZ, roadMinZ, roadMaxZ)
local marginPass = finalLakeMinX >= safeLakeMinX - 0.001

local roadUnchanged = road.Parent == roadSnapshot.Parent
    and road.CFrame == roadSnapshot.CFrame
    and road.Size == roadSnapshot.Size
    and road.Material == roadSnapshot.Material
    and road.Color == roadSnapshot.Color
    and road.Transparency == roadSnapshot.Transparency
    and road.CanCollide == roadSnapshot.CanCollide

local lakeNonOwnedPropertiesPreserved = lake.Material == originalLake.Material
    and lake.Color == originalLake.Color
    and lake.Transparency == originalLake.Transparency
    and lake.CanCollide == originalLake.CanCollide
    and lake.Size.Y == originalLake.Size.Y
    and lake.Size.Z == originalLake.Size.Z
    and lake.Position.Y == originalLake.CFrame.Position.Y
    and lake.Position.Z == originalLake.CFrame.Position.Z

if not roadUnchanged then
    warn("[ASC V085 LakeWaterFix] HARD LOCK FAILED: NorthSouthRoad changed unexpectedly")
    layer:Destroy()
    return
end
if not lakeNonOwnedPropertiesPreserved then
    warn("[ASC V085 LakeWaterFix] HARD LOCK FAILED: non-owned Lake properties changed")
    layer:Destroy()
    return
end

local pass = (not remainingRoadOverlap) and marginPass and roadUnchanged and lakeNonOwnedPropertiesPreserved
layer:SetAttribute("ASC_V085OriginalLakeMinX", lakeMinX)
layer:SetAttribute("ASC_V085OriginalLakeMaxX", lakeMaxX)
layer:SetAttribute("ASC_V085FinalLakeMinX", finalLakeMinX)
layer:SetAttribute("ASC_V085FinalLakeMaxX", finalLakeMaxX)
layer:SetAttribute("ASC_V085RoadMinX", roadMinX)
layer:SetAttribute("ASC_V085RoadMaxX", roadMaxX)
layer:SetAttribute("ASC_V085RoadClearMargin", ROAD_CLEAR_MARGIN)
layer:SetAttribute("ASC_V085RemainingRoadOverlap", remainingRoadOverlap)
layer:SetAttribute("ASC_V085RoadUnchanged", roadUnchanged)
layer:SetAttribute("ASC_V085LakeNonOwnedPropertiesPreserved", lakeNonOwnedPropertiesPreserved)
layer:SetAttribute("ASC_V085Pass", pass)

root:SetAttribute("ASC_LakeRoadWaterOverlapFinalFixV085", pass)
root:SetAttribute("ASC_LakeWaterStopsAtRoadEdge", pass)
Workspace:SetAttribute("ASC_LakeRoadWaterOverlapFinalFixPass", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V0.8.5 lake/road water overlap final fix initialized; originalX=%.2f..%.2f finalX=%.2f..%.2f roadX=%.2f..%.2f margin=%.2f roadUnchanged=%s pass=%s",
    lakeMinX,
    lakeMaxX,
    finalLakeMinX,
    finalLakeMaxX,
    roadMinX,
    roadMaxX,
    ROAD_CLEAR_MARGIN,
    tostring(roadUnchanged),
    tostring(pass)
))
