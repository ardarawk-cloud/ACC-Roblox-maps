-- AFTER SCHOOL CITY — Layout Correction Pass v0.4.3
-- Fixes remaining spatial collisions confirmed from owner live v11 screenshots.
-- Placement-only: no economy, persistence, monetization or gameplay authority.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC LayoutCorrection] AfterSchoolCity root missing")
    return
end

root:WaitForChild("V042_StructuralRealignment", 20)

if root:FindFirstChild("V043_LayoutCorrection") then
    return
end

local districts = root:WaitForChild("Districts", 10)
local landscaping = root:FindFirstChild("Landscaping")

local layer = Instance.new("Model")
layer.Name = "V043_LayoutCorrection"
layer:SetAttribute("ASC_Layer", "LAYOUT_CORRECTION")
layer:SetAttribute("ASC_Version", "0.4.3-layout-correction-1")
layer.Parent = root

local C = {
    sidewalk = Color3.fromRGB(198, 202, 208),
    grass = Color3.fromRGB(101, 132, 91),
    hedge = Color3.fromRGB(63, 108, 65),
    trunk = Color3.fromRGB(103, 78, 57),
    tree = Color3.fromRGB(66, 119, 72),
    dark = Color3.fromRGB(34, 48, 72),
}

local function part(parent, name, size, cf, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function safeTree(parent, pos, scale)
    scale = scale or 0.75
    local m = Instance.new("Model")
    m.Name = "SafeCampusTree"
    m:SetAttribute("ASC_ClearanceChecked", true)
    m.Parent = parent

    local trunk = part(m, "Trunk", Vector3.new(1.8 * scale, 7 * scale, 1.8 * scale), CFrame.new(pos + Vector3.new(0, 3.5 * scale, 0)), C.trunk, Enum.Material.Wood)
    trunk.CanCollide = true
    local crown = part(m, "Crown", Vector3.new(7.5 * scale, 7.5 * scale, 7.5 * scale), CFrame.new(pos + Vector3.new(0, 9 * scale, 0)), C.tree, Enum.Material.Grass)
    crown.Shape = Enum.PartType.Ball
    crown.CanCollide = false
end

-- =========================================================
-- A. SCHOOL LOCKER / TREE COLLISION
-- Legacy v0.2 courtyard trees were created before the v0.3 locker breezeway.
-- Remove only the four trees occupying the locker/club frontage and replace
-- them with two trees at campus-edge positions outside pedestrian structures.
-- =========================================================
if landscaping then
    for _, model in ipairs(landscaping:GetChildren()) do
        if model:IsA("Model") and model.Name == "Tree" then
            local probe = model:FindFirstChildWhichIsA("BasePart", true)
            if probe then
                local x = probe.Position.X
                local z = probe.Position.Z
                if z > 250 and z < 266 and math.abs(x) >= 50 and math.abs(x) <= 98 then
                    model:Destroy()
                end
            end
        end
    end

    safeTree(landscaping, Vector3.new(-103, 1.5, 274), 0.72)
    safeTree(landscaping, Vector3.new(103, 1.5, 274), 0.72)
end

-- =========================================================
-- B. RESIDENTIAL ROAD MUST NOT TERMINATE INTO A HOUSE
-- Townhouse_2 sits directly inside the EastWestRoad envelope at Z=0.
-- Remove the center house + matching driveway/mailbox and make the road end
-- at a small open residential entry court instead.
-- =========================================================
local residential = districts:FindFirstChild("Residential")
if residential then
    local centerHouse = residential:FindFirstChild("Townhouse_2")
    if centerHouse then
        centerHouse:Destroy()
    end

    local residentialLife = residential:FindFirstChild("V03_ResidentialLife")
    if residentialLife then
        for _, obj in ipairs(residentialLife:GetChildren()) do
            if obj:IsA("BasePart") and math.abs(obj.Position.Z) < 16 then
                if obj.Name == "Driveway" or obj.Name == "MailboxPost" or obj.Name == "Mailbox" or obj.Name == "Hedge" then
                    obj:Destroy()
                end
            end
        end
    end

    part(layer, "ResidentialEntryNorth", Vector3.new(72, 0.55, 11), CFrame.new(-235, 1.2, -28), C.sidewalk, Enum.Material.Concrete)
    part(layer, "ResidentialEntrySouth", Vector3.new(72, 0.55, 11), CFrame.new(-235, 1.2, 28), C.sidewalk, Enum.Material.Concrete)

    local hedgeN = part(layer, "ResidentialEntryHedgeN", Vector3.new(36, 3.4, 3), CFrame.new(-235, 3, -36), C.hedge, Enum.Material.Grass)
    hedgeN.CanCollide = false
    local hedgeS = part(layer, "ResidentialEntryHedgeS", Vector3.new(36, 3.4, 3), CFrame.new(-235, 3, 36), C.hedge, Enum.Material.Grass)
    hedgeS.CanCollide = false
end

-- =========================================================
-- C. YOUTH STUDIO / SPORTS FIELD COLLISION
-- The rotated YouthStudio footprint crosses into the west edge of SportsField.
-- Remove it for this precision pass rather than forcing another unsafe fit.
-- Also clear its orphan access pad / nearby street props from the sports edge.
-- =========================================================
local streetLife = root:FindFirstChild("V04_StreetLife")
if streetLife then
    local infill = streetLife:FindFirstChild("StudentRowInfill")
    if infill then
        local youth = infill:FindFirstChild("YouthStudio")
        if youth then
            youth:Destroy()
        end

        for _, obj in ipairs(infill:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Position.X > 145 and obj.Position.Z > 140 then
                if obj.Name == "PlanterBase" or obj.Name == "PlanterBush" then
                    obj:Destroy()
                end
            end
        end
    end
end

local spatial = root:FindFirstChild("V041_SpatialCleanup")
if spatial then
    local corridor = spatial:FindFirstChild("V041_SchoolDowntownCorridor")
    if corridor then
        for _, obj in ipairs(corridor:GetChildren()) do
            if obj:IsA("BasePart") and obj.Name == "StudentRowAccess" and obj.Position.X > 145 and obj.Position.Z > 150 then
                obj:Destroy()
            end
        end
    end
end

if landscaping then
    for _, obj in ipairs(landscaping:GetChildren()) do
        if obj:IsA("BasePart") and obj.Position.X > 145 and obj.Position.Z > 145 then
            if obj.Name == "StreetTreeTrunk" or obj.Name == "StreetTreeCrown" then
                obj:Destroy()
            end
        end
    end
end

-- Visual buffer between community row and school sports area.
part(layer, "SportsWestBufferWalk", Vector3.new(18, 0.55, 82), CFrame.new(158, 1.2, 210), C.sidewalk, Enum.Material.Concrete)

root:SetAttribute("ASC_LayoutCorrectionPass", "0.4.3-layout-correction-1")
root:SetAttribute("ASC_LockerTreeCollisionFixed", true)
root:SetAttribute("ASC_ResidentialRoadHouseCollisionFixed", true)
root:SetAttribute("ASC_YouthStudioSportsCollisionFixed", true)
Workspace:SetAttribute("ASC_LayoutCorrectionPass", "0.4.3-layout-correction-1")

print("[AFTER SCHOOL CITY] Layout Correction v0.4.3 initialized")
