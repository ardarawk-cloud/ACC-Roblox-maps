-- AFTER SCHOOL CITY — Runtime Hard Cleanup v0.5.2
-- Final fail-safe presentation cleanup after V0.5.1 runtime reconcile completes.
-- Uses hierarchy-independent names + measured area envelopes so moved legacy props cannot survive.
-- Presentation/circulation only: no economy, persistence, monetization or gameplay authority.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC RuntimeHardCleanup] AfterSchoolCity root missing")
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
    warn("[ASC RuntimeHardCleanup] completion attribute timeout: " .. name)
    return false
end

if not waitForWorkspaceAttribute("ASC_RuntimeReconcilePass", 45) then
    return
end

if root:FindFirstChild("V052_RuntimeHardCleanup") then
    return
end

local districts = root:WaitForChild("Districts", 10)
local landmarks = root:FindFirstChild("Landmarks")

local layer = Instance.new("Model")
layer.Name = "V052_RuntimeHardCleanup"
layer:SetAttribute("ASC_Layer", "RUNTIME_HARD_CLEANUP")
layer:SetAttribute("ASC_Version", "0.5.2-runtime-hard-cleanup-1")
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

-- Hard pedestrian envelope between spawn and the school steps.
local SCHOOL_AXIS_HARD_X = 12
local SCHOOL_AXIS_HARD_Z_MIN = 149
local SCHOOL_AXIS_HARD_Z_MAX = 169
local SCHOOL_AXIS_OBSTRUCTION_TOP_MIN = 2.2
local SCHOOL_AXIS_OBSTRUCTION_BOTTOM_MAX = 8

-- Entrance approach envelopes are deliberately wider than the exact old tree coordinates.
local STUDENT_ROW_ENTRANCE_ENVELOPES = {
    {name = "MINI_MART_EAST", xMin = -163, xMax = -144, zMin = 96, zMax = 121},
    {name = "STUDY_LOUNGE_EAST", xMin = -163, xMax = -144, zMin = 148, zMax = 184},
    {name = "CITY_LIBRARY_WEST", xMin = 144, xMax = 163, zMin = 97, zMax = 127},
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

local function inEnvelope(position, envelope)
    return position.X >= envelope.xMin and position.X <= envelope.xMax
        and position.Z >= envelope.zMin and position.Z <= envelope.zMax
end

local function treeLike(instance)
    local lower = string.lower(instance.Name)
    return string.find(lower, "tree", 1, true) ~= nil
        or string.find(lower, "trunk", 1, true) ~= nil
        or string.find(lower, "crown", 1, true) ~= nil
end

local function moveX(p, targetX)
    p.CFrame = p.CFrame + Vector3.new(targetX - p.Position.X, 0, 0)
end

local function collectDistinctTextPlates(exactText)
    local records = {}
    local seen = {}
    for _, descendant in ipairs(root:GetDescendants()) do
        if descendant:IsA("TextLabel") and descendant.Text == exactText then
            local gui = descendant.Parent
            local plate = gui and gui.Parent
            if gui and gui:IsA("SurfaceGui") and plate and plate:IsA("BasePart") and not seen[plate] then
                seen[plate] = true
                table.insert(records, {plate = plate, gui = gui, label = descendant})
            end
        end
    end
    return records
end

-- =========================================================
-- A. GLOBAL PROTOTYPE PURGE, HIERARCHY-INDEPENDENT
-- =========================================================
local exactPrototypeNames = {
    VendingMachine = true,
    VendingGlow = true,
    SkateSign = true,
}
local purge = {}
for _, descendant in ipairs(root:GetDescendants()) do
    if exactPrototypeNames[descendant.Name] then
        table.insert(purge, descendant)
    end
end
for _, obj in ipairs(purge) do
    if obj.Parent then
        obj:Destroy()
    end
end

-- =========================================================
-- B. SCHOOL ARRIVAL HARD-CLEAR
-- Remove named legacy blockers anywhere in the arrival envelope and also remove
-- unknown collidable ground obstructions in the central 24-stud player corridor.
-- =========================================================
local axisGarbage = {}
local axisAllowedNames = {
    AfterSchoolSpawn = true,
    FrontWalk = true,
    FrontPlaza = true,
    CampusCrosswalkStripeV047 = true,
}
for _, descendant in ipairs(root:GetDescendants()) do
    if descendant:IsA("BasePart") then
        local p = descendant.Position
        local lower = string.lower(descendant.Name)
        local inHardAxis = math.abs(p.X) <= SCHOOL_AXIS_HARD_X
            and p.Z >= SCHOOL_AXIS_HARD_Z_MIN
            and p.Z <= SCHOOL_AXIS_HARD_Z_MAX
        local namedBlocker = string.find(lower, "bollard", 1, true)
            or string.find(lower, "vending", 1, true)
            or string.find(lower, "barrier", 1, true)
            or string.find(lower, "blocker", 1, true)

        if inHardAxis and namedBlocker then
            table.insert(axisGarbage, descendant)
        elseif inHardAxis and descendant.CanCollide and not axisAllowedNames[descendant.Name] then
            local topY = p.Y + descendant.Size.Y / 2
            local bottomY = p.Y - descendant.Size.Y / 2
            if topY > SCHOOL_AXIS_OBSTRUCTION_TOP_MIN and bottomY < SCHOOL_AXIS_OBSTRUCTION_BOTTOM_MAX then
                table.insert(axisGarbage, descendant)
            end
        end
    end
end
for _, obj in ipairs(axisGarbage) do
    if obj.Parent then
        obj:Destroy()
    end
end

-- Welcome element is allowed only at the measured off-axis location.
if landmarks then
    local welcome = landmarks:FindFirstChild("WelcomeMonument", true)
    if welcome and welcome:IsA("BasePart") then
        welcome.Size = Vector3.new(28, 5, 1)
        welcome.CFrame = CFrame.new(-82, 4.2, 268)
        welcome:SetAttribute("ASC_RuntimeHardCleaned", true)
    end
    local accent = landmarks:FindFirstChild("WelcomeAccent", true)
    if accent and accent:IsA("BasePart") then
        accent.Size = Vector3.new(30, 0.55, 1.4)
        accent.CFrame = CFrame.new(-82, 7.05, 268)
        accent.Material = Enum.Material.Metal
        accent:SetAttribute("ASC_RuntimeHardCleaned", true)
    end
end

-- =========================================================
-- C. STUDENT ROW ENTRANCE ENVELOPES
-- =========================================================
local treeGarbage = {}
local treeModels = {}
for _, descendant in ipairs(root:GetDescendants()) do
    if descendant:IsA("BasePart") and treeLike(descendant) then
        for _, envelope in ipairs(STUDENT_ROW_ENTRANCE_ENVELOPES) do
            if inEnvelope(descendant.Position, envelope) then
                local parent = descendant.Parent
                if parent and parent:IsA("Model") and treeLike(parent) then
                    treeModels[parent] = true
                else
                    table.insert(treeGarbage, descendant)
                end
                break
            end
        end
    end
end
for model in pairs(treeModels) do
    if model.Parent then
        model:Destroy()
    end
end
for _, obj in ipairs(treeGarbage) do
    if obj.Parent then
        obj:Destroy()
    end
end

-- =========================================================
-- D. DOWNTOWN — HARD CLAMP EVERY LEGACY INTERIOR PART TO EFFECTIVE FOOTPRINT
-- =========================================================
local downtown = districts:FindFirstChild("Downtown")
if downtown then
    for _, shopName in ipairs({"ARCADE", "CAFE", "STYLE", "MUSIC", "HOBBY"}) do
        local shop = downtown:FindFirstChild("Shop_" .. shopName)
        local building = shop and shop:FindFirstChild("Building")
        local interior = shop and shop:FindFirstChild("V03_Interior")
        if shop and building and building:IsA("BasePart") then
            local cx = building.Position.X
            local sign = shop:FindFirstChild("StoreSign")
            if sign and sign:IsA("BasePart") then
                sign.Size = Vector3.new(SHOP_SIGN_WIDTH, SHOP_SIGN_HEIGHT, math.min(sign.Size.Z, 0.55))
                for _, gui in ipairs(sign:GetChildren()) do
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
                for _, obj in ipairs(interior:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        if obj.Size.X > SHOP_INTERIOR_WIDTH then
                            obj.Size = Vector3.new(SHOP_INTERIOR_WIDTH, obj.Size.Y, obj.Size.Z)
                        end
                        local dx = obj.Position.X - cx
                        if math.abs(dx) > SHOP_PROP_X_LIMIT then
                            moveX(obj, cx + (dx < 0 and -SHOP_PROP_X_LIMIT or SHOP_PROP_X_LIMIT))
                        end
                        if obj.Name == "WallL" then
                            obj.Size = Vector3.new(0.8, obj.Size.Y, obj.Size.Z)
                            moveX(obj, cx - SHOP_INTERIOR_WIDTH / 2)
                        elseif obj.Name == "WallR" then
                            obj.Size = Vector3.new(0.8, obj.Size.Y, obj.Size.Z)
                            moveX(obj, cx + SHOP_INTERIOR_WIDTH / 2)
                        elseif obj.Name == "FrontPostL" then
                            obj.Size = Vector3.new(0.8, obj.Size.Y, 0.8)
                            moveX(obj, cx - SHOP_INTERIOR_WIDTH / 2 + 0.5)
                        elseif obj.Name == "FrontPostR" then
                            obj.Size = Vector3.new(0.8, obj.Size.Y, 0.8)
                            moveX(obj, cx + SHOP_INTERIOR_WIDTH / 2 - 0.5)
                        elseif obj.Name == "LabelPlate" then
                            obj.Size = Vector3.new(math.min(obj.Size.X, 18), math.min(obj.Size.Y, 3.5), obj.Size.Z)
                            for _, gui in ipairs(obj:GetChildren()) do
                                if gui:IsA("SurfaceGui") then
                                    gui.Face = Enum.NormalId.Back
                                end
                            end
                        end
                    end
                end
            end
            shop:SetAttribute("ASC_RuntimeHardCleaned", true)
        end
    end
end

-- =========================================================
-- E. SKATE SIGN — EXACTLY ONE COMPACT PLATE
-- =========================================================
local skatePlates = collectDistinctTextPlates("AFTER SCHOOL SKATE")
local keeper = nil
for _, record in ipairs(skatePlates) do
    if record.plate.Name == "SkateEntrySign" then
        keeper = record
        break
    end
end
if not keeper and #skatePlates > 0 then
    keeper = skatePlates[1]
end
for _, record in ipairs(skatePlates) do
    if record ~= keeper and record.plate.Parent then
        record.plate:Destroy()
    end
end
if keeper and keeper.plate.Parent then
    keeper.plate.Name = "SkateEntrySign"
    keeper.plate.Size = Vector3.new(SKATE_SIGN_WIDTH, SKATE_SIGN_HEIGHT, 0.55)
    keeper.plate.CFrame = CFrame.new(235, 8.4, SKATE_SIGN_Z)
    for _, gui in ipairs(keeper.plate:GetChildren()) do
        if gui:IsA("SurfaceGui") then
            for _, label in ipairs(gui:GetChildren()) do
                if label:IsA("TextLabel") then
                    label.TextScaled = true
                end
            end
        end
    end
else
    local entry = Instance.new("Model")
    entry.Name = "V052_SkateEntry"
    entry.Parent = layer
    part(entry, "PostL", Vector3.new(0.8, 7, 0.8), CFrame.new(222, 4.7, SKATE_SIGN_Z), C.metal, Enum.Material.Metal)
    part(entry, "PostR", Vector3.new(0.8, 7, 0.8), CFrame.new(248, 4.7, SKATE_SIGN_Z), C.metal, Enum.Material.Metal)
    local plate = part(entry, "SkateEntrySign", Vector3.new(SKATE_SIGN_WIDTH, SKATE_SIGN_HEIGHT, 0.55), CFrame.new(235, 8.4, SKATE_SIGN_Z), C.navy, Enum.Material.Metal)
    surfaceText(plate, "AFTER SCHOOL SKATE", Enum.NormalId.Front, C.gold)
    surfaceText(plate, "AFTER SCHOOL SKATE", Enum.NormalId.Back, C.gold)
end

-- =========================================================
-- F. WAYFINDING — DE-DUPLICATE, THEN COMPACT ONE PLATE
-- =========================================================
local downtownPlates = collectDistinctTextPlates("DOWNTOWN  ↓")
local downtownKeeper = downtownPlates[1]
for i = 2, #downtownPlates do
    local record = downtownPlates[i]
    if record.plate.Parent then
        record.plate:Destroy()
    end
end
if downtownKeeper and downtownKeeper.plate.Parent then
    downtownKeeper.plate.Size = Vector3.new(DOWNTOWN_SIGN_WIDTH, DOWNTOWN_SIGN_HEIGHT, 0.45)
    downtownKeeper.plate.CFrame = CFrame.new(DOWNTOWN_SIGN_X, 4.2, DOWNTOWN_SIGN_Z)
    downtownKeeper.gui.Face = Enum.NormalId.Front
    downtownKeeper.label.TextScaled = true
    downtownKeeper.plate:SetAttribute("ASC_RuntimeHardCleaned", true)
end

-- =========================================================
-- G. LIGHTS — FINAL BUDGET REASSERTION
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

root:SetAttribute("ASC_RuntimeHardCleanupPass", "0.5.2-runtime-hard-cleanup-1")
root:SetAttribute("ASC_SchoolAxisGroundObstructionsPurged", true)
root:SetAttribute("ASC_StudentRowEntranceEnvelopesClear", true)
root:SetAttribute("ASC_DowntownInteriorHardClamped", true)
root:SetAttribute("ASC_SkateSignDeduplicated", true)
root:SetAttribute("ASC_DowntownWayfindingDeduplicated", true)
Workspace:SetAttribute("ASC_RuntimeHardCleanupPass", "0.5.2-runtime-hard-cleanup-1")

print("[AFTER SCHOOL CITY] Runtime Hard Cleanup v0.5.2 initialized")
