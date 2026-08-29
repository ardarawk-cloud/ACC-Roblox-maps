-- AFTER SCHOOL CITY — Student Row + Shop Interiors v0.8.0
-- Upgrades the five existing downtown walk-in shops and converts three Student Row blocks
-- into orientation-safe walk-in interiors derived from each live Body.CFrame.
-- Presentation/social-space only. No economy, purchases, inventory, persistence, clubs,
-- monetization, marketplace, or gameplay authority is introduced here.

local Workspace = game:GetService("Workspace")

local VERSION = "0.8.0-student-row-shop-interiors-1"
local MAX_PARTS = 170
local MAX_LIGHTS = 8
local LIGHT_BRIGHTNESS_MAX = 0.18
local LIGHT_RANGE_MAX = 9

local C = {
    navy = Color3.fromRGB(29, 41, 60),
    charcoal = Color3.fromRGB(47, 52, 60),
    white = Color3.fromRGB(235, 238, 241),
    pale = Color3.fromRGB(218, 223, 227),
    concrete = Color3.fromRGB(193, 196, 198),
    wood = Color3.fromRGB(118, 86, 63),
    metal = Color3.fromRGB(70, 76, 85),
    gold = Color3.fromRGB(215, 164, 66),
    blue = Color3.fromRGB(55, 92, 132),
    teal = Color3.fromRGB(58, 117, 111),
    purple = Color3.fromRGB(108, 84, 128),
    red = Color3.fromRGB(157, 78, 71),
    green = Color3.fromRGB(74, 116, 78),
    warm = Color3.fromRGB(245, 218, 173),
}

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V080 Interiors] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_SchoolRoadVisualDefectCleanupPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V080 Interiors] AfterSchoolCity root missing")
    return
end

if root:FindFirstChild("V080_StudentRowShopInteriors") then
    return
end

local districts = root:WaitForChild("Districts", 10)
local downtown = districts:FindFirstChild("Downtown")
local streetLife = root:FindFirstChild("V04_StreetLife")
local studentRow = streetLife and streetLife:FindFirstChild("StudentRowInfill")
if not (downtown and studentRow) then
    warn("[ASC V080 Interiors] required downtown/student row authority missing")
    return
end

local layer = Instance.new("Model")
layer.Name = "V080_StudentRowShopInteriors"
layer:SetAttribute("ASC_Layer", "STUDENT_ROW_SHOP_INTERIORS")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

local partCount = 0
local lightCount = 0
local downtownUpgraded = 0
local studentRowBuilt = 0

local function part(parent, name, size, cf, color, material, canCollide)
    if partCount >= MAX_PARTS then
        warn("[ASC V080 Interiors] part budget reached")
        return nil
    end
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Color = color or C.white
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.CanCollide = canCollide == true
    p.CanTouch = false
    p.CastShadow = true
    p.Parent = parent
    partCount += 1
    return p
end

local function addLight(parent)
    if not parent or lightCount >= MAX_LIGHTS then
        return
    end
    local light = Instance.new("PointLight")
    light.Brightness = LIGHT_BRIGHTNESS_MAX
    light.Range = LIGHT_RANGE_MAX
    light.Color = C.warm
    light.Shadows = false
    light.Parent = parent
    lightCount += 1
end

local function surfaceText(plate, text, face, textColor)
    if not plate then return end
    local gui = Instance.new("SurfaceGui")
    gui.Name = "V080InteriorSignage"
    gui.Face = face or Enum.NormalId.Front
    gui.AlwaysOnTop = false
    gui.LightInfluence = 0.28
    gui.PixelsPerStud = 30
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
    label.TextWrapped = false
    label.Parent = gui
end

local function interiorSign(parent, text, cf, width, accent)
    local plate = part(parent, "InteriorSign", Vector3.new(width or 14, 1.7, 0.26), cf, C.navy, Enum.Material.Metal, false)
    if plate then
        surfaceText(plate, text, Enum.NormalId.Front, accent or C.gold)
    end
    return plate
end

local function addTable(parent, cf, width, depth, seats)
    local top = part(parent, "TableTop", Vector3.new(width, 0.5, depth), cf * CFrame.new(0, 3.0, 0), C.wood, Enum.Material.Wood, true)
    for _, offset in ipairs({
        Vector3.new(-width * 0.38, 1.45, -depth * 0.32),
        Vector3.new(width * 0.38, 1.45, -depth * 0.32),
        Vector3.new(-width * 0.38, 1.45, depth * 0.32),
        Vector3.new(width * 0.38, 1.45, depth * 0.32),
    }) do
        part(parent, "TableLeg", Vector3.new(0.42, 2.8, 0.42), cf * CFrame.new(offset), C.metal, Enum.Material.Metal, true)
    end
    if seats then
        for _, offset in ipairs({Vector3.new(0, 1.5, -depth / 2 - 2.1), Vector3.new(0, 1.5, depth / 2 + 2.1)}) do
            part(parent, "Seat", Vector3.new(math.min(width - 1, 5.5), 0.55, 1.6), cf * CFrame.new(offset), C.charcoal, Enum.Material.Fabric, true)
        end
    end
    return top
end

local function addWallShelf(parent, cf, width, height, depth)
    part(parent, "ShelfBack", Vector3.new(width, height, 0.55), cf, C.charcoal, Enum.Material.Wood, false)
    for y = -height / 2 + 1.5, height / 2 - 1.0, 2.4 do
        part(parent, "Shelf", Vector3.new(width, 0.28, depth), cf * CFrame.new(0, y, depth / 2), C.wood, Enum.Material.Wood, true)
    end
end

local function hideLegacyMass(model, body)
    body.Transparency = 1
    body.CanCollide = false
    body.CanTouch = false
    body.CanQuery = false
    body.CastShadow = false
    body:SetAttribute("ASC_V080InteriorVoid", true)

    local door = model:FindFirstChild("Door")
    if door and door:IsA("BasePart") then
        door.Transparency = 1
        door.CanCollide = false
        door.CanTouch = false
        door.CanQuery = false
        door.CastShadow = false
        door:SetAttribute("ASC_V080OpenEntrance", true)
    end
end

local function buildShell(model, body, displayName, accent)
    local existing = model:FindFirstChild("V080_Interior")
    if existing then
        existing:Destroy()
    end

    hideLegacyMass(model, body)

    local interior = Instance.new("Model")
    interior.Name = "V080_Interior"
    interior:SetAttribute("ASC_Enterable", true)
    interior:SetAttribute("ASC_InteriorType", displayName)
    interior.Parent = model

    local cf = body.CFrame
    local w, h, d = body.Size.X, body.Size.Y, body.Size.Z
    local floorY = -h / 2 + 0.32
    local wallY = 0

    part(interior, "Floor", Vector3.new(w - 1.4, 0.6, d - 1.4), cf * CFrame.new(0, floorY, 0), C.concrete, Enum.Material.Concrete, true)
    part(interior, "BackWall", Vector3.new(w - 0.8, h - 1.0, 0.8), cf * CFrame.new(0, wallY, -d / 2 + 0.4), C.pale, Enum.Material.Concrete, true)
    part(interior, "WallL", Vector3.new(0.8, h - 1.0, d - 0.8), cf * CFrame.new(-w / 2 + 0.4, wallY, 0), C.pale, Enum.Material.Concrete, true)
    part(interior, "WallR", Vector3.new(0.8, h - 1.0, d - 0.8), cf * CFrame.new(w / 2 - 0.4, wallY, 0), C.pale, Enum.Material.Concrete, true)
    part(interior, "Ceiling", Vector3.new(w - 1.0, 0.65, d - 1.0), cf * CFrame.new(0, h / 2 - 0.35, 0), C.charcoal, Enum.Material.Metal, false)

    -- Architectural open-front frame. Existing windows stay visible and the center remains walkable.
    part(interior, "FrontPierL", Vector3.new(1.1, h - 2, 0.9), cf * CFrame.new(-w / 2 + 0.65, -0.5, d / 2 - 0.45), C.navy, Enum.Material.Metal, true)
    part(interior, "FrontPierR", Vector3.new(1.1, h - 2, 0.9), cf * CFrame.new(w / 2 - 0.65, -0.5, d / 2 - 0.45), C.navy, Enum.Material.Metal, true)
    part(interior, "FrontLintel", Vector3.new(w - 1.2, 1.1, 0.9), cf * CFrame.new(0, h / 2 - 1.0, d / 2 - 0.45), accent, Enum.Material.Metal, false)
    part(interior, "EntryMat", Vector3.new(8.0, 0.08, 4.2), cf * CFrame.new(0, floorY + 0.36, d / 2 - 3.0), accent, Enum.Material.Fabric, false)

    local lightBar = part(interior, "InteriorLight", Vector3.new(math.min(w - 8, 18), 0.25, 1.0), cf * CFrame.new(0, h / 2 - 0.8, 0), C.warm, Enum.Material.SmoothPlastic, false)
    addLight(lightBar)

    interiorSign(interior, displayName, cf * CFrame.new(0, h / 2 - 3.2, -d / 2 + 0.85), math.min(w - 8, 22), accent)
    return interior, cf, w, h, d, floorY
end

-- =========================================================
-- A. STUDENT ROW — THREE SOLID BLOCKS BECOME REAL WALK-IN INTERIORS
-- =========================================================
local studentSpecs = {
    StudentMiniMart = {label = "MINI MART", accent = C.gold},
    StudyLounge = {label = "STUDY LOUNGE", accent = C.blue},
    CommunityLibrary = {label = "COMMUNITY LIBRARY", accent = C.teal},
}

for modelName, spec in pairs(studentSpecs) do
    local model = studentRow:FindFirstChild(modelName)
    local body = model and model:FindFirstChild("Body")
    if model and body and body:IsA("BasePart") then
        local interior, cf, w, h, d, floorY = buildShell(model, body, spec.label, spec.accent)
        if interior then
            if modelName == "StudentMiniMart" then
                part(interior, "ServiceCounter", Vector3.new(w * 0.46, 3.2, 3.2), cf * CFrame.new(0, floorY + 1.9, -d / 2 + 3.0), C.wood, Enum.Material.Wood, true)
                part(interior, "CounterTop", Vector3.new(w * 0.48, 0.4, 3.6), cf * CFrame.new(0, floorY + 3.65, -d / 2 + 3.0), C.charcoal, Enum.Material.Slate, true)
                addWallShelf(interior, cf * CFrame.new(-w / 2 + 1.0, 0, -2.0) * CFrame.Angles(0, math.rad(90), 0), math.min(d - 9, 18), 8, 2.2)
                addWallShelf(interior, cf * CFrame.new(w / 2 - 1.0, 0, -2.0) * CFrame.Angles(0, math.rad(-90), 0), math.min(d - 9, 18), 8, 2.2)
                for _, x in ipairs({-7, 7}) do
                    part(interior, "DisplayIsland", Vector3.new(5.2, 2.1, 7.5), cf * CFrame.new(x, floorY + 1.35, 1.5), C.pale, Enum.Material.Metal, true)
                    part(interior, "DisplayTop", Vector3.new(5.5, 0.25, 7.8), cf * CFrame.new(x, floorY + 2.55, 1.5), spec.accent, Enum.Material.SmoothPlastic, false)
                end
            elseif modelName == "StudyLounge" then
                addWallShelf(interior, cf * CFrame.new(0, 0, -d / 2 + 0.9), math.min(w - 12, 24), 8, 2.0)
                for _, z in ipairs({-5.5, 5.5}) do
                    addTable(interior, cf * CFrame.new(0, floorY, z), math.min(w - 16, 14), 4.2, true)
                end
                part(interior, "QuietBench", Vector3.new(math.min(w - 14, 16), 0.65, 2.2), cf * CFrame.new(0, floorY + 1.7, d / 2 - 6.5), C.blue, Enum.Material.Fabric, true)
            elseif modelName == "CommunityLibrary" then
                addWallShelf(interior, cf * CFrame.new(-w / 2 + 1.0, 0, -2.0) * CFrame.Angles(0, math.rad(90), 0), math.min(d - 8, 22), 9, 2.0)
                addWallShelf(interior, cf * CFrame.new(w / 2 - 1.0, 0, -2.0) * CFrame.Angles(0, math.rad(-90), 0), math.min(d - 8, 22), 9, 2.0)
                addTable(interior, cf * CFrame.new(0, floorY, -4.5), math.min(w - 18, 16), 4.6, true)
                addTable(interior, cf * CFrame.new(0, floorY, 6.0), math.min(w - 18, 16), 4.6, true)
            end

            model:SetAttribute("ASC_V080WalkInInterior", true)
            model:SetAttribute("ASC_V080EntranceClear", true)
            studentRowBuilt += 1
        end
    end
end

-- =========================================================
-- B. DOWNTOWN — PRESERVE EXISTING V0.3 SHELLS, UPGRADE THEIR PRESENTATION
-- =========================================================
local shopAccents = {
    ARCADE = C.gold,
    CAFE = C.teal,
    STYLE = C.purple,
    MUSIC = C.blue,
    HOBBY = C.red,
}

for shopName, accent in pairs(shopAccents) do
    local shop = downtown:FindFirstChild("Shop_" .. shopName)
    local interior = shop and shop:FindFirstChild("V03_Interior")
    local floor = interior and interior:FindFirstChild("Floor")
    if shop and interior and floor and floor:IsA("BasePart") then
        local polish = Instance.new("Model")
        polish.Name = "V080_InteriorPolish"
        polish.Parent = interior

        local floorCF = floor.CFrame
        local floorY = floor.Size.Y / 2 + 0.08
        local runner = part(polish, "ShopFloorRunner", Vector3.new(math.min(floor.Size.X - 6, 14), 0.08, math.min(floor.Size.Z - 10, 20)), floorCF * CFrame.new(0, floorY, 2.0), accent, Enum.Material.Fabric, false)
        if runner then runner.CastShadow = false end

        -- Ground large legacy furniture that previously read as floating/blockout.
        for _, obj in ipairs(interior:GetDescendants()) do
            if obj:IsA("BasePart") then
                if obj.Name == "ListeningTable" or obj.Name == "HobbyTable" then
                    obj.Material = Enum.Material.Wood
                    obj.Color = C.wood
                    obj:SetAttribute("ASC_V080GroundedFurniture", true)
                    for _, xOff in ipairs({-obj.Size.X * 0.38, obj.Size.X * 0.38}) do
                        for _, zOff in ipairs({-obj.Size.Z * 0.32, obj.Size.Z * 0.32}) do
                            part(polish, "FurnitureLeg", Vector3.new(0.45, 2.6, 0.45), obj.CFrame * CFrame.new(xOff, -obj.Size.Y / 2 - 1.3, zOff), C.metal, Enum.Material.Metal, true)
                        end
                    end
                elseif obj.Name == "CafeCounter" then
                    obj.Material = Enum.Material.Wood
                    obj.Color = C.wood
                    obj:SetAttribute("ASC_V080CounterFinished", true)
                elseif obj.Name == "ClothingRack" then
                    obj.Size = Vector3.new(math.min(obj.Size.X, 1.2), math.min(obj.Size.Y, 6.2), math.min(obj.Size.Z, 12))
                    obj.Color = C.metal
                    obj.Material = Enum.Material.Metal
                elseif obj.Name == "Display" then
                    obj.Size = Vector3.new(math.min(obj.Size.X, 3.8), math.min(obj.Size.Y, 2.2), math.min(obj.Size.Z, 0.8))
                    obj.CanCollide = false
                elseif obj.Name == "CabinetScreen" then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.CanCollide = false
                end
            end
        end

        shop:SetAttribute("ASC_V080InteriorUpgraded", true)
        shop:SetAttribute("ASC_V080PurchaseAuthority", false)
        downtownUpgraded += 1
    end
end

layer:SetAttribute("ASC_V080StudentRowBuilt", studentRowBuilt)
layer:SetAttribute("ASC_V080DowntownUpgraded", downtownUpgraded)
layer:SetAttribute("ASC_V080PartCount", partCount)
layer:SetAttribute("ASC_V080LightCount", lightCount)
layer:SetAttribute("ASC_V080TargetInteriors", 8)
layer:SetAttribute("ASC_V080EconomyAuthority", false)
layer:SetAttribute("ASC_V080PurchaseAuthority", false)

root:SetAttribute("ASC_StudentRowShopInteriorsReady", true)
root:SetAttribute("ASC_V080InteriorCount", studentRowBuilt + downtownUpgraded)
Workspace:SetAttribute("ASC_StudentRowShopInteriorsPass", VERSION)

print(string.format("[AFTER SCHOOL CITY] V0.8.0 interiors ready; studentRow=%d downtown=%d parts=%d lights=%d economy=OFF purchases=OFF", studentRowBuilt, downtownUpgraded, partCount, lightCount))
