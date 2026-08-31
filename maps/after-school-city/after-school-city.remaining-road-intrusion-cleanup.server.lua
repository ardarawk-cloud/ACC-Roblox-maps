-- AFTER SCHOOL CITY — Remaining Road Intrusion Cleanup v0.8.6
-- Screenshot-driven precision cleanup on top of verified V0.8.5 / Roblox v32.
-- Exact owned defects only:
--   1) Downtown V04_DowntownBackAlley/ServiceWalk crossing NorthSouthRoad.
--   2) Downtown V04_DowntownBackAlley center LoadingPad at X≈road center.
--   3) PremiumExterior V060_ParkExterior/LakeEdgeWest rock strip left in NorthSouthRoad.
-- NorthSouthRoad is read-only. No gameplay/economy/persistence/monetization/dedication authority.

local Workspace = game:GetService("Workspace")

local VERSION = "0.8.6-remaining-road-intrusion-cleanup-1"
local ROAD_CLEAR_MARGIN = 1.5
local MIN_SEGMENT = 2.0

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V086 RemainingRoadIntrusionCleanup] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_LakeRoadWaterOverlapFinalFixPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V086 RemainingRoadIntrusionCleanup] AfterSchoolCity root missing")
    return
end

if root:FindFirstChild("V086_RemainingRoadIntrusionCleanup") then
    return
end

local roads = root:FindFirstChild("RoadsAndPaths")
local districts = root:FindFirstChild("Districts")
local road = roads and roads:FindFirstChild("NorthSouthRoad")
if not road or not road:IsA("BasePart") or road.Material ~= Enum.Material.Asphalt then
    warn("[ASC V086 RemainingRoadIntrusionCleanup] protected NorthSouthRoad authority missing")
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

local layer = Instance.new("Model")
layer.Name = "V086_RemainingRoadIntrusionCleanup"
layer:SetAttribute("ASC_Layer", "REMAINING_ROAD_INTRUSION_CLEANUP")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

local roadMinX = road.Position.X - road.Size.X * 0.5
local roadMaxX = road.Position.X + road.Size.X * 0.5
local roadMinZ = road.Position.Z - road.Size.Z * 0.5
local roadMaxZ = road.Position.Z + road.Size.Z * 0.5

local function rangesOverlap(aMin, aMax, bMin, bMax)
    return aMax > bMin and aMin < bMax
end

local function overlapsRoadXZ(p)
    local minX = p.Position.X - p.Size.X * 0.5
    local maxX = p.Position.X + p.Size.X * 0.5
    local minZ = p.Position.Z - p.Size.Z * 0.5
    local maxZ = p.Position.Z + p.Size.Z * 0.5
    return rangesOverlap(minX, maxX, roadMinX, roadMaxX)
        and rangesOverlap(minZ, maxZ, roadMinZ, roadMaxZ)
end

local serviceWalkSplit = 0
local loadingPadsRemoved = 0
local lakeEdgesRemoved = 0

-- =========================================================
-- A. DOWNTOWN BACK ALLEY — split exact ServiceWalk around asphalt.
-- Source authority: V04_DowntownBackAlley/ServiceWalk (220 x 0.55 x 6 at Z=-100).
-- =========================================================
local downtown = districts and districts:FindFirstChild("Downtown")
local alley = downtown and downtown:FindFirstChild("V04_DowntownBackAlley")
local serviceWalk = alley and alley:FindFirstChild("ServiceWalk")
if serviceWalk and serviceWalk:IsA("BasePart") and overlapsRoadXZ(serviceWalk) then
    local originalMinX = serviceWalk.Position.X - serviceWalk.Size.X * 0.5
    local originalMaxX = serviceWalk.Position.X + serviceWalk.Size.X * 0.5
    local safeWestMaxX = roadMinX - ROAD_CLEAR_MARGIN
    local safeEastMinX = roadMaxX + ROAD_CLEAR_MARGIN

    local westWidth = safeWestMaxX - originalMinX
    local eastWidth = originalMaxX - safeEastMinX

    if westWidth >= MIN_SEGMENT then
        local west = serviceWalk:Clone()
        west.Name = "ServiceWalkWest"
        west.Size = Vector3.new(westWidth, serviceWalk.Size.Y, serviceWalk.Size.Z)
        west.CFrame = serviceWalk.CFrame + Vector3.new(((originalMinX + safeWestMaxX) * 0.5) - serviceWalk.Position.X, 0, 0)
        west.CanTouch = false
        west:SetAttribute("ASC_V086ServiceWalkSegment", "WEST")
        west.Parent = alley
    end

    if eastWidth >= MIN_SEGMENT then
        local east = serviceWalk:Clone()
        east.Name = "ServiceWalkEast"
        east.Size = Vector3.new(eastWidth, serviceWalk.Size.Y, serviceWalk.Size.Z)
        east.CFrame = serviceWalk.CFrame + Vector3.new(((safeEastMinX + originalMaxX) * 0.5) - serviceWalk.Position.X, 0, 0)
        east.CanTouch = false
        east:SetAttribute("ASC_V086ServiceWalkSegment", "EAST")
        east.Parent = alley
    end

    serviceWalk:Destroy()
    serviceWalkSplit = 1
end

-- =========================================================
-- B. Remove only the center LoadingPad that sits in the NorthSouthRoad envelope.
-- Other loading pads at X=±45/±90 remain untouched.
-- =========================================================
if alley then
    for _, child in ipairs(alley:GetChildren()) do
        if child:IsA("BasePart")
            and child.Name == "LoadingPad"
            and math.abs(child.Position.X - road.Position.X) <= 1.0
            and overlapsRoadXZ(child) then
            child:Destroy()
            loadingPadsRemoved += 1
        end
    end
end

-- =========================================================
-- C. Remove only obsolete premium LakeEdgeWest.
-- V0.8.5 moved the real lake west edge beyond the protected road; the original
-- premium rock strip at X≈-1.5 is now stale decoration inside asphalt.
-- =========================================================
local premium = root:FindFirstChild("V060_PremiumExterior")
local parkExterior = premium and premium:FindFirstChild("V060_ParkExterior")
local lakeEdgeWest = parkExterior and parkExterior:FindFirstChild("LakeEdgeWest")
if lakeEdgeWest and lakeEdgeWest:IsA("BasePart") and overlapsRoadXZ(lakeEdgeWest) then
    lakeEdgeWest:Destroy()
    lakeEdgesRemoved = 1
end

-- Acceptance: no exact legacy target may still overlap the protected road.
local remainingExactOverlaps = 0
if alley then
    for _, child in ipairs(alley:GetChildren()) do
        if child:IsA("BasePart")
            and (child.Name == "ServiceWalk" or child.Name == "LoadingPad")
            and overlapsRoadXZ(child) then
            remainingExactOverlaps += 1
        end
    end
end
if parkExterior then
    local residualEdge = parkExterior:FindFirstChild("LakeEdgeWest")
    if residualEdge and residualEdge:IsA("BasePart") and overlapsRoadXZ(residualEdge) then
        remainingExactOverlaps += 1
    end
end

local roadUnchanged = road.Parent == roadSnapshot.Parent
    and road.CFrame == roadSnapshot.CFrame
    and road.Size == roadSnapshot.Size
    and road.Material == roadSnapshot.Material
    and road.Color == roadSnapshot.Color
    and road.Transparency == roadSnapshot.Transparency
    and road.CanCollide == roadSnapshot.CanCollide

if not roadUnchanged then
    warn("[ASC V086 RemainingRoadIntrusionCleanup] HARD LOCK FAILED: NorthSouthRoad changed unexpectedly")
    layer:Destroy()
    return
end

layer:SetAttribute("ASC_V086ServiceWalkSplit", serviceWalkSplit)
layer:SetAttribute("ASC_V086CenterLoadingPadsRemoved", loadingPadsRemoved)
layer:SetAttribute("ASC_V086LakeEdgeWestRemoved", lakeEdgesRemoved)
layer:SetAttribute("ASC_V086RemainingExactOverlaps", remainingExactOverlaps)
layer:SetAttribute("ASC_V086RoadUnchanged", true)

root:SetAttribute("ASC_RemainingRoadIntrusionCleanupV086", remainingExactOverlaps == 0)
root:SetAttribute("ASC_AsphaltExactIntrusionPriority", true)
Workspace:SetAttribute("ASC_RemainingRoadIntrusionCleanupPass", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V0.8.6 remaining road intrusion cleanup initialized; serviceWalkSplit=%d loadingPadsRemoved=%d lakeEdgeRemoved=%d remaining=%d roadUnchanged=true",
    serviceWalkSplit,
    loadingPadsRemoved,
    lakeEdgesRemoved,
    remainingExactOverlaps
))
