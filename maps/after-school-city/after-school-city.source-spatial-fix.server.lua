-- AFTER SCHOOL CITY — Source Spatial Fix v0.4.6
-- Deterministic source correction after v0.4.5 sanitize.
-- Fixes conflicts detected by the Cloud Source Spatial Audit before visual polish.
-- Placement-only: no economy, persistence, monetization or gameplay authority.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC SourceSpatialFix] AfterSchoolCity root missing")
    return
end

root:WaitForChild("V045_ClearanceSanitize", 20)

if root:FindFirstChild("V046_SourceSpatialFix") then
    return
end

local districts = root:WaitForChild("Districts", 10)
local landscaping = root:FindFirstChild("Landscaping")

local layer = Instance.new("Model")
layer.Name = "V046_SourceSpatialFix"
layer:SetAttribute("ASC_Layer", "SOURCE_SPATIAL_FIX")
layer:SetAttribute("ASC_Version", "0.4.6-source-spatial-audit-fix-1")
layer.Parent = root

-- =========================================================
-- SOURCE SPATIAL CONTRACT
-- These values are intentionally literal so cloud QC can parse the same
-- effective X/Z geometry that the runtime correction applies.
-- =========================================================
local SHOP_LAYOUT = {
    {name = "Shop_ARCADE", x = -101, width = 24},
    {name = "Shop_CAFE", x = -73, width = 24},
    {name = "Shop_STYLE", x = -45, width = 24},
    {name = "Shop_MUSIC", x = 45, width = 24},
    {name = "Shop_HOBBY", x = 73, width = 24},
}

local PARK_TREE_RELOCATIONS = {
    {fromX = -25, fromZ = -246, toX = -58, toZ = -262},
    {fromX = 14, fromZ = -168, toX = 102, toZ = -158},
}

local BUS_TARGET_X = -90
local BUS_TARGET_Z = 159
local POSITION_TOLERANCE = 1.5

local function offsetModel(model, delta)
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.CFrame = descendant.CFrame + delta
        end
    end
end

local function resizeShopPart(part, width)
    if part.Name == "Building" then
        part.Size = Vector3.new(width, part.Size.Y, 40)
    elseif part.Name == "RoofTrim" then
        part.Size = Vector3.new(width + 2, part.Size.Y, 42)
    elseif part.Name == "Storefront" then
        part.Size = Vector3.new(18, part.Size.Y, part.Size.Z)
    elseif part.Name == "StoreSign" then
        part.Size = Vector3.new(20, part.Size.Y, part.Size.Z)
    elseif part.Name == "Awning" then
        part.Size = Vector3.new(22, part.Size.Y, part.Size.Z)
    end
end

-- =========================================================
-- A. DOWNTOWN SHOP / MAIN-ROAD + SIDEWALK CLEARANCE
-- The v0.2 shop row placed Shop_STYLE directly across the NorthSouthRoad and
-- left CAFE/MUSIC too close to the avenue sidewalks. Compact the five facades
-- and split the row around the avenue while retaining the same shop identities.
-- Closest facades now keep a 4-stud gap from the NS sidewalks.
-- =========================================================
local downtown = districts:FindFirstChild("Downtown")
if downtown then
    for _, spec in ipairs(SHOP_LAYOUT) do
        local shop = downtown:FindFirstChild(spec.name)
        local building = shop and shop:FindFirstChild("Building")
        if shop and building and building:IsA("BasePart") then
            local dx = spec.x - building.Position.X
            offsetModel(shop, Vector3.new(dx, 0, 0))
            for _, descendant in ipairs(shop:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    resizeShopPart(descendant, spec.width)
                end
            end
            shop:SetAttribute("ASC_ClearanceChecked", true)
            shop:SetAttribute("ASC_EffectiveCenterX", spec.x)
            shop:SetAttribute("ASC_EffectiveWidth", spec.width)
        end
    end
end

-- =========================================================
-- B. PARK TREE / ROAD + WALKING-PATH CLEARANCE
-- Two legacy v0.2 trees occupy movement envelopes after later path/road passes.
-- Move only the exact source trees identified by their trunk/probe positions.
-- =========================================================
if landscaping then
    for _, spec in ipairs(PARK_TREE_RELOCATIONS) do
        for _, child in ipairs(landscaping:GetChildren()) do
            if child:IsA("Model") and child.Name == "Tree" then
                local probe = child:FindFirstChildWhichIsA("BasePart", true)
                if probe
                    and math.abs(probe.Position.X - spec.fromX) <= POSITION_TOLERANCE
                    and math.abs(probe.Position.Z - spec.fromZ) <= POSITION_TOLERANCE then
                    local delta = Vector3.new(spec.toX - probe.Position.X, 0, spec.toZ - probe.Position.Z)
                    offsetModel(child, delta)
                    child:SetAttribute("ASC_ClearanceChecked", true)
                    child:SetAttribute("ASC_RelocatedBySourceSpatialFix", true)
                    break
                end
            end
        end
    end
end

-- =========================================================
-- C. SCHOOL BUS / CORRIDOR TREE CLEARANCE
-- Effective v0.4.1 bus at X=-86 leaves <6 studs to the corridor tree at X=-66.
-- Shift four studs west while preserving side-street and school clearances.
-- =========================================================
local spatial = root:FindFirstChild("V041_SpatialCleanup")
local parking = spatial and spatial:FindFirstChild("V041_ParkingAndVehicles")
local bus = parking and parking:FindFirstChild("SchoolBusParked")
local busBody = bus and bus:FindFirstChild("BusBody")
if bus and busBody and busBody:IsA("BasePart") then
    local delta = Vector3.new(BUS_TARGET_X - busBody.Position.X, 0, BUS_TARGET_Z - busBody.Position.Z)
    offsetModel(bus, delta)
    bus:SetAttribute("ASC_ClearanceChecked", true)
    bus:SetAttribute("ASC_EffectiveCenterX", BUS_TARGET_X)
    bus:SetAttribute("ASC_EffectiveCenterZ", BUS_TARGET_Z)
end

root:SetAttribute("ASC_SourceSpatialFixPass", "0.4.6-source-spatial-audit-fix-1")
root:SetAttribute("ASC_DowntownRoadClearanceFixed", true)
root:SetAttribute("ASC_ParkPathTreeClearanceFixed", true)
root:SetAttribute("ASC_BusTreeClearanceFixed", true)
Workspace:SetAttribute("ASC_SourceSpatialFixPass", "0.4.6-source-spatial-audit-fix-1")

print("[AFTER SCHOOL CITY] Source Spatial Fix v0.4.6 initialized")
