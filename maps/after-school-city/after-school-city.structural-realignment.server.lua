-- AFTER SCHOOL CITY — Structural Realignment v0.4.2
-- Fixes structural placement issues identified from owner live v10 screenshots.
-- Placement-only: no economy, persistence, monetization or gameplay authority.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC StructuralRealignment] AfterSchoolCity root missing")
    return
end

root:WaitForChild("V041_SpatialCleanup", 20)

if root:FindFirstChild("V042_StructuralRealignment") then
    return
end

local districts = root:WaitForChild("Districts", 10)
local roads = root:WaitForChild("RoadsAndPaths", 10)

local layer = Instance.new("Model")
layer.Name = "V042_StructuralRealignment"
layer:SetAttribute("ASC_Layer", "STRUCTURAL_REALIGNMENT")
layer:SetAttribute("ASC_Version", "0.4.2-structural-realignment-1")
layer.Parent = root

local C = {
    asphalt = Color3.fromRGB(48, 52, 60),
    sidewalk = Color3.fromRGB(198, 202, 208),
    white = Color3.fromRGB(240, 242, 245),
}

local function part(parent, name, size, cf, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Color = color or C.white
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

-- =========================================================
-- A. MAIN ROAD MUST END BEFORE THE SCHOOL BUILDING
-- The old NorthSouthRoad ran through MainBuilding at X=0 / Z≈202.
-- Preserve the city spine, but terminate it at the campus threshold.
-- =========================================================
local nsRoad = roads:FindFirstChild("NorthSouthRoad")
if nsRoad and nsRoad:IsA("BasePart") then
    nsRoad.Size = Vector3.new(40, 0.7, 438)
    nsRoad.CFrame = CFrame.new(0, 1.05, -48.5)
    nsRoad:SetAttribute("ASC_ClearanceChecked", true)
    nsRoad:SetAttribute("ASC_EndsBeforeSchool", true)
end

for _, name in ipairs({"NS_Sidewalk_W", "NS_Sidewalk_E"}) do
    local walk = roads:FindFirstChild(name)
    if walk and walk:IsA("BasePart") then
        walk.Size = Vector3.new(9, 0.8, 438)
        local x = (name == "NS_Sidewalk_W") and -24.5 or 24.5
        walk.CFrame = CFrame.new(x, 1.25, -48.5)
        walk:SetAttribute("ASC_ClearanceChecked", true)
    end
end

-- Remove lane dashes and old crosswalk stripes that continued into the school footprint.
for _, child in ipairs(roads:GetChildren()) do
    if child:IsA("BasePart") then
        if child.Name == "NS_LaneDash" and child.Position.Z > 165 then
            child:Destroy()
        elseif child.Name == "CrosswalkStripe" and child.Position.Z > 170 then
            child:Destroy()
        end
    end
end

-- Clean campus-threshold crosswalk at the end of the public street.
for i = -4, 4 do
    local stripe = part(layer, "CampusCrosswalkStripe", Vector3.new(1.8, 0.08, 10), CFrame.new(i * 3.3, 1.46, 164), C.white, Enum.Material.SmoothPlastic)
    stripe.CanCollide = false
end

-- =========================================================
-- B. SCHOOL FRONT WALK MUST STOP AT THE ENTRANCE, NOT RUN UNDER THE BUILDING
-- =========================================================
local school = districts:FindFirstChild("SchoolDistrict")
if school then
    local frontWalk = school:FindFirstChild("FrontWalk")
    if frontWalk and frontWalk:IsA("BasePart") then
        frontWalk.Size = Vector3.new(22, 0.8, 44)
        frontWalk.CFrame = CFrame.new(0, 1.1, 251)
        frontWalk:SetAttribute("ASC_ClearanceChecked", true)
        frontWalk:SetAttribute("ASC_StopsAtEntrance", true)
    end

    -- =====================================================
    -- C. CLUB HUB WAS SQUEEZED BETWEEN RIGHT WING + SPORTS COURT
    -- Move the whole club behind the right wing, inside the school campus.
    -- =====================================================
    local schoolLife = school:FindFirstChild("V03_SchoolLife")
    local club = schoolLife and schoolLife:FindFirstChild("ClubHub")
    if club and club:IsA("Model") then
        local delta = Vector3.new(-50, 0, -71)
        for _, descendant in ipairs(club:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.CFrame = descendant.CFrame + delta
            end
        end
        local connector = club:FindFirstChild("ConnectorWalk", true)
        if connector and connector:IsA("BasePart") then
            connector.Size = Vector3.new(18, 0.7, 13)
            connector.CFrame = CFrame.new(82, 1.35, 172.5)
        end
        club:SetAttribute("ASC_ClearanceChecked", true)
        club:SetAttribute("ASC_Placement", "BEHIND_RIGHT_WING")
    end

    -- Remove the old SPORTS sign plate that was created inside the right-wing footprint.
    if schoolLife then
        for _, descendant in ipairs(schoolLife:GetDescendants()) do
            if descendant:IsA("TextLabel") and string.find(descendant.Text, "SPORTS", 1, true) then
                local gui = descendant.Parent
                local plate = gui and gui.Parent
                if plate and plate:IsA("BasePart") then
                    plate:Destroy()
                end
                break
            end
        end
    end
end

root:SetAttribute("ASC_StructuralRealignmentPass", "0.4.2-structural-realignment-1")
root:SetAttribute("ASC_RoadBuildingOverlapFixed", true)
root:SetAttribute("ASC_ClubSportsClearanceFixed", true)
Workspace:SetAttribute("ASC_StructuralRealignmentPass", "0.4.2-structural-realignment-1")

print("[AFTER SCHOOL CITY] Structural Realignment v0.4.2 initialized")
