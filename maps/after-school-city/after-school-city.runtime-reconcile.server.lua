-- AFTER SCHOOL CITY — Runtime Reconcile v0.5.1
-- Final deterministic reconciliation after all presentation/spatial passes COMPLETE.
-- Fixes Roblox server-script scheduling races where a late layer object existed
-- before the previous pass had actually finished mutating the world.
-- Presentation/circulation only: no economy, persistence, monetization or gameplay authority.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC RuntimeReconcile] AfterSchoolCity root missing")
    return
end

local REQUIRED_COMPLETION_ATTRIBUTES = {
    "ASC_SchoolLifePass",
    "ASC_DowntownLifePass",
    "ASC_CityLifePass",
    "ASC_StreetDensityPass",
    "ASC_SpatialCleanupPass",
    "ASC_StructuralRealignmentPass",
    "ASC_LayoutCorrectionPass",
    "ASC_CirculationSanitizePass",
    "ASC_ClearanceSanitizePass",
    "ASC_SourceSpatialFixPass",
    "ASC_OrientationCorrectionPass",
    "ASC_VisualFidelityPass",
}

local function waitForCompletionAttribute(attributeName, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 40)
    repeat
        if Workspace:GetAttribute(attributeName) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC RuntimeReconcile] completion attribute timeout: " .. attributeName)
    return false
end

for _, attributeName in ipairs(REQUIRED_COMPLETION_ATTRIBUTES) do
    if not waitForCompletionAttribute(attributeName, 40) then
        return
    end
end

if root:FindFirstChild("V051_RuntimeReconcile") then
    return
end

local districts = root:WaitForChild("Districts", 10)
local landmarks = root:FindFirstChild("Landmarks")

local layer = Instance.new("Model")
layer.Name = "V051_RuntimeReconcile"
layer:SetAttribute("ASC_Layer", "RUNTIME_RECONCILE")
layer:SetAttribute("ASC_Version", "0.5.1-runtime-reconcile-1")
layer.Parent = root

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
end

local function moveX(p, targetX)
    p.CFrame = p.CFrame + Vector3.new(targetX - p.Position.X, 0, 0)
end

local function nearXZ(p, x, z, tolerance)
    return math.abs(p.Position.X - x) <= tolerance and math.abs(p.Position.Z - z) <= tolerance
end

local function findTextPlates(container, exactText)
    local result = {}
    if not container then
        return result
    end
    for _, descendant in ipairs(container:GetDescendants()) do
        if descendant:IsA("TextLabel") and descendant.Text == exactText then
            local gui = descendant.Parent
            local plate = gui and gui.Parent
            if gui and gui:IsA("SurfaceGui") and plate and plate:IsA("BasePart") then
                table.insert(result, {plate = plate, gui = gui, label = descendant})
            end
        end
    end
    return result
end

-- A. Remove every legacy school-axis bollard after all older layers are done.
local schoolBollards = {}
for _, descendant in ipairs(root:GetDescendants()) do
    if descendant:IsA("BasePart") and descendant.Name == "SchoolBollard" then
        if math.abs(descendant.Position.X) <= SCHOOL_AXIS_CLEAR_X
            and descendant.Position.Z >= SCHOOL_AXIS_CLEAR_Z_MIN
            and descendant.Position.Z <= SCHOOL_AXIS_CLEAR_Z_MAX then
            table.insert(schoolBollards, descendant)
        end
    end
end
for _, obj in ipairs(schoolBollards) do
    obj:Destroy()
end

-- B. Relocate/compact the welcome element regardless of its exact nested hierarchy.
if landmarks then
    local welcome = landmarks:FindFirstChild("WelcomeMonument", true)
    if welcome and welcome:IsA("BasePart") then
        welcome.Size = Vector3.new(28, 5, 1)
        welcome.CFrame = CFrame.new(-82, 4.2, 268)
        welcome:SetAttribute("ASC_RuntimeReconciled", true)
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

    local accent = landmarks:FindFirstChild("WelcomeAccent", true)
    if accent and accent:IsA("BasePart") then
        accent.Size = Vector3.new(30, 0.55, 1.4)
        accent.CFrame = CFrame.new(-82, 7.05, 268)
        accent.Material = Enum.Material.Metal
        accent:SetAttribute("ASC_RuntimeReconciled", true)
    end
end

-- C. Remove prototype vending blocks globally after all authors have finished.
local vendingGarbage = {}
for _, descendant in ipairs(root:GetDescendants()) do
    if descendant:IsA("BasePart") and (descendant.Name == "VendingMachine" or descendant.Name == "VendingGlow") then
        table.insert(vendingGarbage, descendant)
    end
end
for _, obj in ipairs(vendingGarbage) do
    obj:Destroy()
end

-- D. Remove known Student Row tree parts from entrance approaches, independent of parent folder.
local treeGarbage = {}
for _, descendant in ipairs(root:GetDescendants()) do
    if descendant:IsA("BasePart") and (descendant.Name == "StreetTreeTrunk" or descendant.Name == "StreetTreeCrown") then
        for _, target in ipairs(STUDENT_ROW_TREE_CLEAR_TARGETS) do
            if nearXZ(descendant, target.x, target.z, 2.2) then
                table.insert(treeGarbage, descendant)
                break
            end
        end
    end
end
for _, obj in ipairs(treeGarbage) do
    obj:Destroy()
end

-- E. Reconcile Downtown shells after v0.4.6 positioning and all later orientation work.
local downtown = districts:FindFirstChild("Downtown")
if downtown then
    for _, shopName in ipairs({"ARCADE", "CAFE", "STYLE", "MUSIC", "HOBBY"}) do
        local shop = downtown:FindFirstChild("Shop_" .. shopName)
        local building = shop and shop:FindFirstChild("Building")
        local interior = shop and shop:FindFirstChild("V03_Interior")
        if shop and building and building:IsA("BasePart") then
            local cx = building.Position.X
            local storeSign = shop:FindFirstChild("StoreSign")
            if storeSign and storeSign:IsA("BasePart") then
                storeSign.Size = Vector3.new(SHOP_SIGN_WIDTH, SHOP_SIGN_HEIGHT, math.min(storeSign.Size.Z, 0.55))
                for _, gui in ipairs(storeSign:GetChildren()) do
                    if gui:IsA("SurfaceGui") then
                        gui.Face = Enum.NormalId.Back
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
                                    gui.Face = Enum.NormalId.Back
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
            shop:SetAttribute("ASC_RuntimeReconciled", true)
        end
    end
end

-- F. Ensure the giant legacy skate wall is gone and compact entry sign exists.
local skate = districts:FindFirstChild("SkatePark")
if skate then
    local oldSigns = {}
    for _, descendant in ipairs(skate:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Name == "SkateSign" then
            table.insert(oldSigns, descendant)
        end
    end
    for _, obj in ipairs(oldSigns) do
        obj:Destroy()
    end

    local existingEntry = root:FindFirstChild("V050_SkateEntry", true)
    if existingEntry and existingEntry:IsA("Model") then
        local plate = existingEntry:FindFirstChild("SkateEntrySign", true)
        if plate and plate:IsA("BasePart") then
            plate.Size = Vector3.new(SKATE_SIGN_WIDTH, SKATE_SIGN_HEIGHT, 0.55)
            plate.CFrame = CFrame.new(235, 8.4, SKATE_SIGN_Z)
        end
    else
        local entry = Instance.new("Model")
        entry.Name = "V051_SkateEntry"
        entry.Parent = layer
        part(entry, "PostL", Vector3.new(0.8, 7, 0.8), CFrame.new(222, 4.7, SKATE_SIGN_Z), C.metal, Enum.Material.Metal)
        part(entry, "PostR", Vector3.new(0.8, 7, 0.8), CFrame.new(248, 4.7, SKATE_SIGN_Z), C.metal, Enum.Material.Metal)
        local plate = part(entry, "SkateEntrySign", Vector3.new(SKATE_SIGN_WIDTH, SKATE_SIGN_HEIGHT, 0.55), CFrame.new(235, 8.4, SKATE_SIGN_Z), C.navy, Enum.Material.Metal)
        surfaceText(plate, "AFTER SCHOOL SKATE", Enum.NormalId.Front, C.gold)
        surfaceText(plate, "AFTER SCHOOL SKATE", Enum.NormalId.Back, C.gold)
    end
end

-- G. Reassert compact Downtown wayfinding after Orientation Correction has completed.
for _, record in ipairs(findTextPlates(root, "DOWNTOWN  ↓")) do
    record.plate.Size = Vector3.new(DOWNTOWN_SIGN_WIDTH, DOWNTOWN_SIGN_HEIGHT, 0.45)
    record.plate.CFrame = CFrame.new(DOWNTOWN_SIGN_X, 4.2, DOWNTOWN_SIGN_Z)
    record.gui.Face = Enum.NormalId.Front
    record.label.TextScaled = true
    record.plate:SetAttribute("ASC_RuntimeReconciled", true)
end

-- H. Reassert exterior light budgets after every older light author has completed.
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

root:SetAttribute("ASC_RuntimeReconcilePass", "0.5.1-runtime-reconcile-1")
root:SetAttribute("ASC_RuntimeOrderingRaceFixed", true)
root:SetAttribute("ASC_FinalVisualStateReconciled", true)
Workspace:SetAttribute("ASC_RuntimeReconcilePass", "0.5.1-runtime-reconcile-1")

print("[AFTER SCHOOL CITY] Runtime Reconcile v0.5.1 initialized after all completion attributes")
