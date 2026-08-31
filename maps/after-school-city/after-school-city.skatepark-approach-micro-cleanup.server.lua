-- AFTER SCHOOL CITY — Skatepark Approach Micro Cleanup v0.8.7
-- Screenshot-driven final micro cleanup on top of verified V0.8.6 / Roblox v33.
-- Trims only the east approach endpoints of the legacy EW_Sidewalk_N / EW_Sidewalk_S
-- segments so they stop cleanly before the SkatePark footprint instead of riding over it.
-- EastWestRoad, SkateGround, Deck, gameplay, economy, persistence, monetization and dedication are read-only.

local Workspace = game:GetService("Workspace")

local VERSION = "0.8.7-skatepark-approach-micro-cleanup-1"
local SKATE_EDGE_MARGIN = 0.75
local MIN_SEGMENT = 2.0
local POSITION_EPSILON = 0.08

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V087 SkateparkApproach] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_RemainingRoadIntrusionCleanupPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V087 SkateparkApproach] AfterSchoolCity root missing")
    return
end

if root:FindFirstChild("V087_SkateparkApproachMicroCleanup") then
    return
end

local roads = root:FindFirstChild("RoadsAndPaths")
local districts = root:FindFirstChild("Districts")
local skate = districts and districts:FindFirstChild("SkatePark")
local skateGround = skate and skate:FindFirstChild("SkateGround")
local deck = skate and skate:FindFirstChild("Deck")
local road = roads and roads:FindFirstChild("EastWestRoad")
local v082 = root:FindFirstChild("V082_RoadSidewalkIntersectionCleanup")

if not road or not road:IsA("BasePart") or road.Material ~= Enum.Material.Asphalt then
    warn("[ASC V087 SkateparkApproach] protected EastWestRoad authority missing")
    return
end
if not skateGround or not skateGround:IsA("BasePart") then
    warn("[ASC V087 SkateparkApproach] SkateGround authority missing")
    return
end
if road.Size.X <= road.Size.Z or skateGround.Position.X <= road.Position.X then
    warn("[ASC V087 SkateparkApproach] unexpected skatepark / EastWestRoad orientation")
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
local groundSnapshot = {
    Parent = skateGround.Parent,
    CFrame = skateGround.CFrame,
    Size = skateGround.Size,
    Material = skateGround.Material,
    Color = skateGround.Color,
}
local deckSnapshot = deck and deck:IsA("BasePart") and {
    Parent = deck.Parent,
    CFrame = deck.CFrame,
    Size = deck.Size,
    Material = deck.Material,
    Color = deck.Color,
} or nil

local layer = Instance.new("Model")
layer.Name = "V087_SkateparkApproachMicroCleanup"
layer:SetAttribute("ASC_Layer", "SKATEPARK_APPROACH_MICRO_CLEANUP")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

-- The v0.2 SkateGround is the stable footprint authority. The sidewalk should end
-- just before its west edge; the asphalt itself remains untouched underneath later visual layers.
local skateWestEdge = skateGround.Position.X - skateGround.Size.X * 0.5
local sidewalkCutX = skateWestEdge - SKATE_EDGE_MARGIN

local TARGET_ORIGINS = {
    EW_Sidewalk_N = true,
    EW_Sidewalk_S = true,
}

local function isTargetSidewalk(p)
    if not p or not p:IsA("BasePart") then
        return false
    end
    local origin = p:GetAttribute("ASC_V082Origin")
    return TARGET_ORIGINS[origin] == true or TARGET_ORIGINS[p.Name] == true
end

local function trimEastEndpoint(p)
    local minX = p.Position.X - p.Size.X * 0.5
    local maxX = p.Position.X + p.Size.X * 0.5
    if maxX <= sidewalkCutX + POSITION_EPSILON then
        return "UNCHANGED"
    end
    if minX >= sidewalkCutX - POSITION_EPSILON then
        p:Destroy()
        return "REMOVED"
    end

    local newSizeX = sidewalkCutX - minX
    if newSizeX < MIN_SEGMENT then
        p:Destroy()
        return "REMOVED"
    end

    local newCenterX = (minX + sidewalkCutX) * 0.5
    local rotation = p.CFrame - p.Position
    p.Size = Vector3.new(newSizeX, p.Size.Y, p.Size.Z)
    p.CFrame = CFrame.new(newCenterX, p.Position.Y, p.Position.Z) * rotation
    p:SetAttribute("ASC_V087SkateApproachTrimmed", true)
    return "TRIMMED"
end

local trimmed = 0
local removed = 0
local candidates = 0
local seen = {}

local function processContainer(container)
    if not container then
        return
    end
    for _, p in ipairs(container:GetChildren()) do
        if isTargetSidewalk(p) and not seen[p] then
            seen[p] = true
            candidates += 1
            local result = trimEastEndpoint(p)
            if result == "TRIMMED" then
                trimmed += 1
            elseif result == "REMOVED" then
                removed += 1
            end
        end
    end
end

-- V0.8.2 normally owns the segmented sidewalks. RoadsAndPaths fallback is retained
-- only for the exact legacy names in case a segment was not split at an earlier crossing.
processContainer(v082)
processContainer(roads)

local residual = 0
for p in pairs(seen) do
    if p.Parent and isTargetSidewalk(p) then
        local maxX = p.Position.X + p.Size.X * 0.5
        if maxX > sidewalkCutX + POSITION_EPSILON then
            residual += 1
        end
    end
end

local roadUnchanged = road.Parent == roadSnapshot.Parent
    and road.CFrame == roadSnapshot.CFrame
    and road.Size == roadSnapshot.Size
    and road.Material == roadSnapshot.Material
    and road.Color == roadSnapshot.Color
    and road.Transparency == roadSnapshot.Transparency
    and road.CanCollide == roadSnapshot.CanCollide
local groundUnchanged = skateGround.Parent == groundSnapshot.Parent
    and skateGround.CFrame == groundSnapshot.CFrame
    and skateGround.Size == groundSnapshot.Size
    and skateGround.Material == groundSnapshot.Material
    and skateGround.Color == groundSnapshot.Color
local deckUnchanged = true
if deckSnapshot then
    deckUnchanged = deck.Parent == deckSnapshot.Parent
        and deck.CFrame == deckSnapshot.CFrame
        and deck.Size == deckSnapshot.Size
        and deck.Material == deckSnapshot.Material
        and deck.Color == deckSnapshot.Color
end

if not roadUnchanged or not groundUnchanged or not deckUnchanged then
    warn("[ASC V087 SkateparkApproach] HARD LOCK FAILED: protected road/skate geometry changed")
    layer:Destroy()
    return
end

layer:SetAttribute("ASC_V087CandidateCount", candidates)
layer:SetAttribute("ASC_V087SidewalkSegmentsTrimmed", trimmed)
layer:SetAttribute("ASC_V087SidewalkSegmentsRemoved", removed)
layer:SetAttribute("ASC_V087ResidualOverhangs", residual)
layer:SetAttribute("ASC_V087SidewalkCutX", sidewalkCutX)
layer:SetAttribute("ASC_V087RoadUnchanged", true)
layer:SetAttribute("ASC_V087SkateGroundUnchanged", true)
layer:SetAttribute("ASC_V087DeckUnchanged", true)

root:SetAttribute("ASC_SkateparkApproachMicroCleanupV087", residual == 0)
root:SetAttribute("ASC_SkateparkApproachSidewalkStopsAtFootprint", residual == 0)
Workspace:SetAttribute("ASC_SkateparkApproachMicroCleanupPass", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V0.8.7 skatepark approach micro cleanup initialized; candidates=%d trimmed=%d removed=%d residual=%d cutX=%.2f protectedUnchanged=true",
    candidates,
    trimmed,
    removed,
    residual,
    sidewalkCutX
))
