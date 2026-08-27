-- AFTER SCHOOL CITY — Visual Fidelity + Prop Clearance v0.5.0
-- Screenshot-driven polish after verified LIVE v16 / Orientation Correction v0.4.7.
-- Presentation + circulation only: no economy, persistence, monetization or gameplay authority.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC VisualFidelity] AfterSchoolCity root missing")
    return
end

root:WaitForChild("V047_OrientationCorrection", 20)

if root:FindFirstChild("V050_VisualFidelity") then
    return
end

local districts = root:WaitForChild("Districts", 10)
local landscaping = root:FindFirstChild("Landscaping")
local landmarks = root:FindFirstChild("Landmarks")

local layer = Instance.new("Model")
layer.Name = "V050_VisualFidelity"
layer:SetAttribute("ASC_Layer", "VISUAL_FIDELITY")
layer:SetAttribute("ASC_Version", "0.5.0-visual-fidelity-1")
layer.Parent = root

-- Literal values are intentionally audit-friendly.
local SHOP_INTERIOR_WIDTH = 22
local SHOP_PROP_X_LIMIT = 8.5
local SHOP_SIGN_WIDTH = 18
local SHOP_SIGN_HEIGHT = 3.6
local SKATE_SIGN_WIDTH = 26
local SKATE_SIGN_HEIGHT = 3.6
local SKATE_SIGN_Z = 63
local DOWNTOWN_SIGN_WIDTH = 10
local DOWNTOWN_SIGN_HEIGHT = 2.6
local DOWNTOWN_SIGN_X = 40
local DOWNTOWN_SIGN_Z = 160
local EXTERIOR_LIGHT_BRIGHTNESS_MAX = 0.38
local EXTERIOR_LIGHT_RANGE_MAX = 14
local SCHOOL_AXIS_CLEAR_X = 14
local SCHOOL_AXIS_CLEAR_Z_MIN = 168
local SCHOOL_AXIS_CLEAR_Z_MAX = 180

local STUDENT_ROW_TREE_CLEAR_TARGETS = {
    {x = -151, z = 107},
    {x = -151, z = 157},
    {x = 151, z = 111},
}

local C = {
    navy = Color3.fromRGB(31, 43, 62),
    blue = Color3.fromRGB(59, 102, 151),
    gold = Color3.fromRGB(232, 173, 67),
    white = Color3.fromRGB(238, 240, 242),
    metal = Color3.fromRGB(69, 75, 84),
    warmLamp = Color3.fromRGB(244, 218, 170),
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

local function surfaceText(plate, text, face, textColor)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "Signage"
    gui.Face = face
    gui.AlwaysOnTop = false
    gui.LightInfluence = 0.25
    gui.PixelsPerStud = 34
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.Parent = plate

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = textColor or C.white
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextWrapped = true
    label.Parent = gui
    return gui
end

local function findTextPlate(container, exactText)
    if not container then
        return nil, nil
    end
    for _, descendant in ipairs(container:GetDescendants()) do
        if descendant:IsA("TextLabel") and descendant.Text == exactText then
            local gui = descendant.Parent
            local plate = gui and gui.Parent
            if gui and gui:IsA("SurfaceGui") and plate and plate:IsA("BasePart") then
                return plate, gui
            end
        end
    end
    return nil, nil
end

local function moveX(p, targetX)
    p.CFrame = p.CFrame + Vector3.new(targetX - p.Position.X, 0, 0)
end

local function nearXZ(p, x, z, tolerance)
    return math.abs(p.Position.X - x) <= tolerance and math.abs(p.Position.Z - z) <= tolerance
end

-- =========================================================
-- A. SCHOOL ARRIVAL: REMOVE PROTOTYPE OBSTRUCTIONS FROM THE AXIS
-- =========================================================
local cityLife = root:FindFirstChild("V03_CityLife")
local oldCorridor = cityLife and cityLife:FindFirstChild("SchoolDowntownCorridor")
if oldCorridor then
    for _, obj in ipairs(oldCorridor:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name == "SchoolBollard" then
            if math.abs(obj.Position.X) <= SCHOOL_AXIS_CLEAR_X
                and obj.Position.Z >= SCHOOL_AXIS_CLEAR_Z_MIN
                and obj.Position.Z <= SCHOOL_AXIS_CLEAR_Z_MAX then
                obj:Destroy()
            end
        end
    end
end

-- The original welcome monument was authored for the old north-side spawn.
-- Keep the message but move it off the school movement axis and reduce its mass.
if landmarks then
    local welcome = landmarks:FindFirstChild("WelcomeMonument")
    if welcome and welcome:IsA("BasePart") then
        welcome.Size = Vector3.new(28, 5, 1)
        welcome.CFrame = CFrame.new(-82, 4.2, 268)
        welcome:SetAttribute("ASC_VisualFidelityRelocated", true)
        for _, gui in ipairs(welcome:GetChildren()) do
            if gui:IsA("SurfaceGui") then
                for _, label in ipairs(gui:GetChildren()) do
                    if label:IsA("TextLabel") then
                        label.TextScaled = true
                    end
                end
            end
        end
    end

    local accent = landmarks:FindFirstChild("WelcomeAccent")
    if accent and accent:IsA("BasePart") then
        accent.Size = Vector3.new(30, 0.55, 1.4)
        accent.CFrame = CFrame.new(-82, 7.05, 268)
        accent.Material = Enum.Material.Metal
    end
end

-- =========================================================
-- B. REMOVE THE TWO PROTOTYPE VENDING BLOCKS FROM PEDESTRIAN SPACE
-- =========================================================
local vendingGarbage = {}
for _, descendant in ipairs(root:GetDescendants()) do
    if descendant:IsA("BasePart") and (descendant.Name == "VendingMachine" or descendant.Name == "VendingGlow") then
        table.insert(vendingGarbage, descendant)
    end
end
for _, obj in ipairs(vendingGarbage) do
    obj:Destroy()
end

-- =========================================================
-- C. STUDENT ROW: HARD-CLEAR TREES FROM DOOR ACCESS PADS
-- =========================================================
if landscaping then
    local toRemove = {}
    for _, obj in ipairs(landscaping:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name == "StreetTreeTrunk" or obj.Name == "StreetTreeCrown") then
            for _, target in ipairs(STUDENT_ROW_TREE_CLEAR_TARGETS) do
                if nearXZ(obj, target.x, target.z, 2.2) then
                    table.insert(toRemove, obj)
                    break
                end
            end
        end
    end
    for _, obj in ipairs(toRemove) do
        obj:Destroy()
    end
end

-- =========================================================
-- D. DOWNTOWN SHOP SHELLS MUST FIT THE 24-STUD EFFECTIVE BUILDINGS
-- v0.4.6 narrowed buildings but legacy v0.3 interiors remained 32 studs wide.
-- =========================================================
local downtown = districts:FindFirstChild("Downtown")
if downtown then
    for _, shopName in ipairs({"ARCADE", "CAFE", "STYLE", "MUSIC", "HOBBY"}) do
        local shop = downtown:FindFirstChild("Shop_" .. shopName)
        local building = shop and shop:FindFirstChild("Building")
        local interior = shop and shop:FindFirstChild("V03_Interior")
        if shop and building and building:IsA("BasePart") then
            local cx = building.Position.X
            shop:SetAttribute("ASC_VisualFidelity", "0.5.0")
            shop:SetAttribute("ASC_InteriorEffectiveWidth", SHOP_INTERIOR_WIDTH)

            local storeSign = shop:FindFirstChild("StoreSign")
            if storeSign and storeSign:IsA("BasePart") then
                storeSign.Size = Vector3.new(SHOP_SIGN_WIDTH, SHOP_SIGN_HEIGHT, math.min(storeSign.Size.Z, 0.55))
                for _, gui in ipairs(storeSign:GetChildren()) do
                    if gui:IsA("SurfaceGui") then
                        for _, label in ipairs(gui:GetChildren()) do
                            if label:IsA("TextLabel") then
                                label.TextScaled = true
                                label.TextWrapped = false
                            end
                        end
                    end
                end
            end

            local awning = shop:FindFirstChild("Awning")
            if awning and awning:IsA("BasePart") then
                awning.Size = Vector3.new(20, 0.55, 3.5)
            end

            if interior then
                local half = SHOP_INTERIOR_WIDTH / 2
                for _, obj in ipairs(interior:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        if obj.Name == "Floor" or obj.Name == "BackWall" or obj.Name == "Ceiling" or obj.Name == "Threshold" then
                            obj.Size = Vector3.new(SHOP_INTERIOR_WIDTH, obj.Size.Y, obj.Size.Z)
                        elseif obj.Name == "WallL" then
                            obj.Size = Vector3.new(0.8, obj.Size.Y, obj.Size.Z)
                            moveX(obj, cx - half)
                        elseif obj.Name == "WallR" then
                            obj.Size = Vector3.new(0.8, obj.Size.Y, obj.Size.Z)
                            moveX(obj, cx + half)
                        elseif obj.Name == "FrontPostL" then
                            obj.Size = Vector3.new(0.8, obj.Size.Y, 0.8)
                            moveX(obj, cx - half + 0.5)
                        elseif obj.Name == "FrontPostR" then
                            obj.Size = Vector3.new(0.8, obj.Size.Y, 0.8)
                            moveX(obj, cx + half - 0.5)
                        elseif obj.Name == "LabelPlate" then
                            obj.Size = Vector3.new(math.min(obj.Size.X, 18), math.min(obj.Size.Y, 3.5), obj.Size.Z)
                            for _, gui in ipairs(obj:GetChildren()) do
                                if gui:IsA("SurfaceGui") then
                                    for _, label in ipairs(gui:GetChildren()) do
                                        if label:IsA("TextLabel") then
                                            label.TextScaled = true
                                        end
                                    end
                                end
                            end
                        else
                            local dx = obj.Position.X - cx
                            if math.abs(dx) > SHOP_PROP_X_LIMIT then
                                moveX(obj, cx + (dx < 0 and -SHOP_PROP_X_LIMIT or SHOP_PROP_X_LIMIT))
                            end
                            if obj.Name == "Shelf" or obj.Name == "ShelfBack" then
                                obj.Size = Vector3.new(math.min(obj.Size.X, 7), obj.Size.Y, obj.Size.Z)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- =========================================================
-- E. REPLACE GIANT/PROTOTYPE SKATE WALL WITH A COMPACT TWO-SIDED ENTRY SIGN
-- =========================================================
local skate = districts:FindFirstChild("SkatePark")
if skate then
    local oldSign = skate:FindFirstChild("SkateSign")
    if oldSign then
        oldSign:Destroy()
    end

    local entry = Instance.new("Model")
    entry.Name = "V050_SkateEntry"
    entry:SetAttribute("ASC_CompactSign", true)
    entry.Parent = layer

    part(entry, "PostL", Vector3.new(0.8, 7, 0.8), CFrame.new(222, 4.7, SKATE_SIGN_Z), C.metal, Enum.Material.Metal)
    part(entry, "PostR", Vector3.new(0.8, 7, 0.8), CFrame.new(248, 4.7, SKATE_SIGN_Z), C.metal, Enum.Material.Metal)
    local plate = part(entry, "SkateEntrySign", Vector3.new(SKATE_SIGN_WIDTH, SKATE_SIGN_HEIGHT, 0.55), CFrame.new(235, 8.4, SKATE_SIGN_Z), C.navy, Enum.Material.Metal)
    surfaceText(plate, "AFTER SCHOOL SKATE", Enum.NormalId.Front, C.gold)
    surfaceText(plate, "AFTER SCHOOL SKATE", Enum.NormalId.Back, C.gold)
end

-- =========================================================
-- F. SCHOOL WAYFINDING: SMALL, FREESTANDING, NOT A WALL-SIZED DEBUG PLATE
-- =========================================================
local school = districts:FindFirstChild("SchoolDistrict")
local schoolLife = school and school:FindFirstChild("V03_SchoolLife")
local downtownPlate, downtownGui = findTextPlate(schoolLife, "DOWNTOWN  ↓")
if downtownPlate and downtownGui then
    downtownPlate.Size = Vector3.new(DOWNTOWN_SIGN_WIDTH, DOWNTOWN_SIGN_HEIGHT, 0.45)
    downtownPlate.CFrame = CFrame.new(DOWNTOWN_SIGN_X, 4.2, DOWNTOWN_SIGN_Z)
    downtownGui.Face = Enum.NormalId.Front
    for _, label in ipairs(downtownGui:GetChildren()) do
        if label:IsA("TextLabel") then
            label.TextScaled = true
        end
    end
    downtownPlate:SetAttribute("ASC_CompactWayfinding", true)
end

-- =========================================================
-- G. LIGHTING: KEEP LIGHT SOURCES, REMOVE FLOATING WHITE NEON-BLOCK LOOK
-- =========================================================
for _, descendant in ipairs(root:GetDescendants()) do
    if descendant:IsA("PointLight") then
        descendant.Brightness = math.min(descendant.Brightness, EXTERIOR_LIGHT_BRIGHTNESS_MAX)
        descendant.Range = math.min(descendant.Range, EXTERIOR_LIGHT_RANGE_MAX)
        descendant.Shadows = false
    elseif descendant:IsA("BasePart") and (descendant.Name == "Lamp" or descendant.Name == "LampHead" or descendant.Name == "StreetLampHead") then
        descendant.Material = Enum.Material.SmoothPlastic
        descendant.Color = C.warmLamp
        descendant.CanCollide = false
        descendant.Size = Vector3.new(
            math.min(descendant.Size.X, 1.8),
            math.min(descendant.Size.Y, 0.38),
            math.min(descendant.Size.Z, 0.9)
        )
    end
end

root:SetAttribute("ASC_VisualFidelityPass", "0.5.0-visual-fidelity-1")
root:SetAttribute("ASC_SchoolAxisPropClear", true)
root:SetAttribute("ASC_PrototypeVendingRemoved", true)
root:SetAttribute("ASC_StudentRowDoorTreesCleared", true)
root:SetAttribute("ASC_DowntownInteriorWidthReconciled", true)
root:SetAttribute("ASC_SkateSignCompacted", true)
root:SetAttribute("ASC_WayfindingCompacted", true)
root:SetAttribute("ASC_ExteriorLightsNormalized", true)
Workspace:SetAttribute("ASC_VisualFidelityPass", "0.5.0-visual-fidelity-1")

print("[AFTER SCHOOL CITY] Visual Fidelity + Prop Clearance v0.5.0 initialized")
