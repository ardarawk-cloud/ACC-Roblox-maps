-- AFTER SCHOOL CITY — Road Centerline Clearance v0.5.3
-- Screenshot-driven deterministic fix for the legacy Downtown plaza/fountain blocking the main avenue.
-- Runs after V0.5.2 and clears the complete effective NorthSouthRoad centerline, not only the school apron.
-- Presentation/circulation only: no economy, persistence, monetization or gameplay authority.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC RoadCenterlineClearance] AfterSchoolCity root missing")
    return
end

local function waitForWorkspaceAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC RoadCenterlineClearance] completion attribute timeout: " .. name)
    return false
end

if not waitForWorkspaceAttribute("ASC_RuntimeHardCleanupPass", 45) then
    return
end

if root:FindFirstChild("V053_RoadCenterlineClearance") then
    return
end

local districts = root:WaitForChild("Districts", 10)
local downtown = districts:FindFirstChild("Downtown")

local layer = Instance.new("Model")
layer.Name = "V053_RoadCenterlineClearance"
layer:SetAttribute("ASC_Layer", "ROAD_CENTERLINE_CLEARANCE")
layer:SetAttribute("ASC_Version", "0.5.3-road-centerline-clearance-1")
layer.Parent = root

-- Effective main avenue from V0.4.7.
local ROAD_CENTER_CLEAR_HALF_X = 19
local ROAD_CENTER_Z_MIN = -267.5
local ROAD_CENTER_Z_MAX = 144.5
local OBSTRUCTION_TOP_MIN = 2.2
local OBSTRUCTION_BOTTOM_MAX = 18

-- Legacy v0.2 Downtown plaza/fountain was authored directly across X=0 / Z=56.
local DOWNTOWN_PLAZA_CENTER_Z = 56
local DOWNTOWN_PLAZA_DEPTH = 54
local DOWNTOWN_PLAZA_OUTER_HALF_X = 57.5
local ROAD_SIDEWALK_OUTER_X = 29
local SPLIT_PLAZA_WIDTH = DOWNTOWN_PLAZA_OUTER_HALF_X - ROAD_SIDEWALK_OUTER_X -- 28.5
local SPLIT_PLAZA_CENTER_X = (DOWNTOWN_PLAZA_OUTER_HALF_X + ROAD_SIDEWALK_OUTER_X) / 2 -- 43.25

local PLAZA_COLOR = Color3.fromRGB(203, 199, 188)

local function part(parent, name, size, cf, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material or Enum.Material.Concrete
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

-- =========================================================
-- A. REMOVE THE EXACT ROOT-CAUSE OBJECTS
-- The original Plaza spans X=-57.5..57.5 while road+sidewalk spans X=-29..29.
-- The original CentralFountain is centered at X=0/Z=56, directly on the avenue.
-- =========================================================
if downtown then
    local fountain = downtown:FindFirstChild("CentralFountain")
    if fountain then
        fountain:Destroy()
    end

    local legacyPlaza = downtown:FindFirstChild("Plaza")
    if legacyPlaza then
        legacyPlaza:Destroy()
    end

    local west = part(
        layer,
        "DowntownPlazaWest",
        Vector3.new(SPLIT_PLAZA_WIDTH, 0.8, DOWNTOWN_PLAZA_DEPTH),
        CFrame.new(-SPLIT_PLAZA_CENTER_X, 1.1, DOWNTOWN_PLAZA_CENTER_Z),
        PLAZA_COLOR,
        Enum.Material.Concrete
    )
    west.CanCollide = true
    west:SetAttribute("ASC_RoadClearanceChecked", true)

    local east = part(
        layer,
        "DowntownPlazaEast",
        Vector3.new(SPLIT_PLAZA_WIDTH, 0.8, DOWNTOWN_PLAZA_DEPTH),
        CFrame.new(SPLIT_PLAZA_CENTER_X, 1.1, DOWNTOWN_PLAZA_CENTER_Z),
        PLAZA_COLOR,
        Enum.Material.Concrete
    )
    east.CanCollide = true
    east:SetAttribute("ASC_RoadClearanceChecked", true)
end

-- =========================================================
-- B. FULL MAIN-ROAD CENTERLINE FAIL-SAFE
-- Uses world-axis AABB extents derived from the actual CFrame, so rotated or renamed
-- legacy parts cannot survive merely because their pivot is outside the corridor.
-- Low road/marking surfaces are preserved by vertical clearance and explicit names.
-- =========================================================
local safeNames = {
    CityGround = true,
    DowntownGround = true,
    NorthSouthRoad = true,
    EastWestRoad = true,
    NS_LaneDash = true,
    EW_LaneDash = true,
    CrosswalkStripe = true,
    CampusCrosswalkStripe = true,
    CampusCrosswalkStripeV047 = true,
    ParkingSurface = true,
}

local function halfExtentsXZ(basePart)
    local half = basePart.Size * 0.5
    local right = basePart.CFrame.RightVector
    local up = basePart.CFrame.UpVector
    local look = basePart.CFrame.LookVector
    local hx = math.abs(right.X) * half.X + math.abs(up.X) * half.Y + math.abs(look.X) * half.Z
    local hz = math.abs(right.Z) * half.X + math.abs(up.Z) * half.Y + math.abs(look.Z) * half.Z
    return hx, hz
end

local function intersectsMainRoadAABB(basePart)
    local hx, hz = halfExtentsXZ(basePart)
    local p = basePart.Position
    local xMin = p.X - hx
    local xMax = p.X + hx
    local zMin = p.Z - hz
    local zMax = p.Z + hz
    return xMax >= -ROAD_CENTER_CLEAR_HALF_X
        and xMin <= ROAD_CENTER_CLEAR_HALF_X
        and zMax >= ROAD_CENTER_Z_MIN
        and zMin <= ROAD_CENTER_Z_MAX
end

local roadGarbage = {}
for _, descendant in ipairs(root:GetDescendants()) do
    if descendant:IsA("BasePart")
        and not descendant:IsDescendantOf(layer)
        and not safeNames[descendant.Name]
        and intersectsMainRoadAABB(descendant) then
        local topY = descendant.Position.Y + descendant.Size.Y / 2
        local bottomY = descendant.Position.Y - descendant.Size.Y / 2
        local visibleOrSolid = descendant.CanCollide or descendant.Transparency < 0.95
        if visibleOrSolid and topY > OBSTRUCTION_TOP_MIN and bottomY < OBSTRUCTION_BOTTOM_MAX then
            table.insert(roadGarbage, descendant)
        end
    end
end

local removedCount = 0
for _, obj in ipairs(roadGarbage) do
    if obj.Parent then
        obj:Destroy()
        removedCount += 1
    end
end

root:SetAttribute("ASC_RoadCenterlineClearancePass", "0.5.3-road-centerline-clearance-1")
root:SetAttribute("ASC_DowntownPlazaSplitAroundRoad", true)
root:SetAttribute("ASC_CentralFountainRemovedFromRoad", true)
root:SetAttribute("ASC_MainRoadCenterlineHardClear", true)
root:SetAttribute("ASC_RoadCenterlineRemovedCount", removedCount)
Workspace:SetAttribute("ASC_RoadCenterlineClearancePass", "0.5.3-road-centerline-clearance-1")

print(string.format("[AFTER SCHOOL CITY] Road Centerline Clearance v0.5.3 initialized; removed=%d", removedCount))
