-- AFTER SCHOOL CITY — Door + Road Clearance v0.4.5
-- Screenshot-driven precision cleanup for the remaining school-door tree and residential-road hedge.
-- Placement-only: no economy, persistence, monetization or gameplay authority.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC ClearanceSanitize] AfterSchoolCity root missing")
    return
end

root:WaitForChild("V044_CirculationSanitize", 20)

if root:FindFirstChild("V045_ClearanceSanitize") then
    return
end

local districts = root:WaitForChild("Districts", 10)
local landscaping = root:FindFirstChild("Landscaping")

local layer = Instance.new("Model")
layer.Name = "V045_ClearanceSanitize"
layer:SetAttribute("ASC_Layer", "CLEARANCE_SANITIZE")
layer:SetAttribute("ASC_Version", "0.4.5-door-road-clearance-1")
layer.Parent = root

-- =========================================================
-- A. SCHOOL MAIN-DOOR TREE CLEARANCE
-- Live v13 confirms one legacy tree still stands directly in the actual
-- entrance path. The previous zone started at Z=236 while the main entrance
-- is around Z=225-231. Extend the no-tree zone inward to Z=214.
-- =========================================================
local function inSchoolDoorZone(pos)
    return pos.Z >= 214 and pos.Z <= 286 and math.abs(pos.X) <= 116
end

local function isTreeLikeName(name)
    local lower = string.lower(name)
    return lower == "tree"
        or lower == "safecampustree"
        or lower == "trunk"
        or lower == "crown"
        or string.find(lower, "tree", 1, true) ~= nil
end

if landscaping then
    for _, child in ipairs(landscaping:GetChildren()) do
        if child:IsA("Model") then
            local probe = child:FindFirstChildWhichIsA("BasePart", true)
            if probe and inSchoolDoorZone(probe.Position) and isTreeLikeName(child.Name) then
                child:Destroy()
            end
        elseif child:IsA("BasePart") and inSchoolDoorZone(child.Position) and isTreeLikeName(child.Name) then
            child:Destroy()
        end
    end
end

-- Defensive pass: remove only tree-like geometry from any older visual layer
-- inside the measured school entrance / front circulation envelope.
for _, descendant in ipairs(root:GetDescendants()) do
    if descendant:IsA("BasePart") and inSchoolDoorZone(descendant.Position) and isTreeLikeName(descendant.Name) then
        local parent = descendant.Parent
        if parent and parent:IsA("Model") and isTreeLikeName(parent.Name) then
            parent:Destroy()
        elseif descendant.Parent then
            descendant:Destroy()
        end
    end
end

-- =========================================================
-- B. RESIDENTIAL ROAD HEDGE CLEARANCE
-- V0.3 generated hedges at Z=-65,-49,-33,-17,-1,15,31,47,63.
-- The EastWestRoad occupies roughly Z=-20..20. V0.4.3 used <16 and missed
-- the Z=-17 hedge visible in live v13. Clear all residential hedges <=24.
-- =========================================================
local residential = districts:FindFirstChild("Residential")
if residential then
    local residentialLife = residential:FindFirstChild("V03_ResidentialLife")
    if residentialLife then
        for _, obj in ipairs(residentialLife:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == "Hedge" and math.abs(obj.Position.Z) <= 24 then
                obj:Destroy()
            end
        end
    end
end

root:SetAttribute("ASC_ClearanceSanitizePass", "0.4.5-door-road-clearance-1")
root:SetAttribute("ASC_SchoolDoorTreeClearanceFixed", true)
root:SetAttribute("ASC_ResidentialRoadHedgeClearanceFixed", true)
Workspace:SetAttribute("ASC_ClearanceSanitizePass", "0.4.5-door-road-clearance-1")

print("[AFTER SCHOOL CITY] Door + Road Clearance v0.4.5 initialized")
