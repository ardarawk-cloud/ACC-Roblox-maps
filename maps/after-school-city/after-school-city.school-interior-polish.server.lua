-- AFTER SCHOOL CITY — School Interior Polish v0.7.1
-- Visual polish on top of V0.7 School Interior: fixes detached street-light geometry,
-- reduces oversized signage, improves school identity/readability, and gives key furniture grounded supports.
-- No road authority, economy, persistence, activities, clubs gameplay, or monetization is introduced here.

local Workspace = game:GetService("Workspace")

local VERSION = "0.7.1-school-interior-polish-1"
local MAX_POLISH_PARTS = 90

local C = {
    navy = Color3.fromRGB(28, 40, 60),
    blue = Color3.fromRGB(53, 95, 145),
    gold = Color3.fromRGB(224, 164, 60),
    teal = Color3.fromRGB(56, 126, 119),
    purple = Color3.fromRGB(122, 91, 147),
    charcoal = Color3.fromRGB(45, 49, 56),
    metal = Color3.fromRGB(76, 82, 91),
    wood = Color3.fromRGB(132, 94, 63),
    warm = Color3.fromRGB(245, 214, 164),
    white = Color3.fromRGB(238, 240, 242),
}

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V071 Polish] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_SchoolInteriorPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V071 Polish] AfterSchoolCity root missing")
    return
end

local districts = root:WaitForChild("Districts", 10)
local school = districts and districts:WaitForChild("SchoolDistrict", 10)
if not school then
    warn("[ASC V071 Polish] SchoolDistrict missing")
    return
end

if school:FindFirstChild("V071_SchoolInteriorPolish") then
    return
end

local interior = school:FindFirstChild("V070_SchoolInterior")
if not interior then
    warn("[ASC V071 Polish] V070_SchoolInterior missing")
    return
end

local layer = Instance.new("Model")
layer.Name = "V071_SchoolInteriorPolish"
layer:SetAttribute("ASC_Layer", "SCHOOL_INTERIOR_POLISH")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = school

local createdParts = 0
local streetLightsFixed = 0
local signsPolished = 0
local furnitureSupports = 0

local function part(parent, name, size, cf, color, material, canCollide)
    if createdParts >= MAX_POLISH_PARTS then
        warn("[ASC V071 Polish] polish part budget reached")
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
    createdParts += 1
    return p
end

local function getTextLabel(signPart)
    if not signPart or not signPart:IsA("BasePart") then
        return nil
    end
    for _, child in ipairs(signPart:GetChildren()) do
        if child:IsA("SurfaceGui") then
            local label = child:FindFirstChild("Label")
            if label and label:IsA("TextLabel") then
                return label
            end
        end
    end
    return nil
end

local function findSignByText(text)
    for _, obj in ipairs(interior:GetDescendants()) do
        if obj:IsA("BasePart") then
            local label = getTextLabel(obj)
            if label and label.Text == text then
                return obj, label
            end
        end
    end
    return nil, nil
end

local function polishTextLabel(label, replacementText)
    if not label then
        return
    end
    if replacementText then
        label.Text = replacementText
    end
    label.TextScaled = true
    label.TextWrapped = false
    label.TextSize = 24
    label.Font = Enum.Font.GothamBold
    label.Size = UDim2.fromScale(0.88, 0.72)
    label.Position = UDim2.fromScale(0.06, 0.14)
end

local function polishInteriorSign(sourceText, replacementText, size, yOffset)
    local signPart, label = findSignByText(sourceText)
    if not signPart then
        return false
    end
    signPart.Size = size
    signPart.CFrame = signPart.CFrame * CFrame.new(0, yOffset or 0, 0)
    signPart.Material = Enum.Material.Metal
    signPart.CanCollide = false
    polishTextLabel(label, replacementText)
    signsPolished += 1
    return true
end

-- =========================================================
-- A. DETACHED/FLOATING STREET LIGHT FIX
-- The original cylinder was sized on Y and then rotated 90 degrees, while Roblox cylinders use X as their axis.
-- Correcting Size.X grounds the pole from the sidewalk to the lamp head without changing street placement.
-- =========================================================
local furniture = root:FindFirstChild("StreetFurniture")
if furniture then
    for _, model in ipairs(furniture:GetChildren()) do
        if model:IsA("Model") and model.Name == "StreetLight" then
            local pole = model:FindFirstChild("Pole")
            local lamp = model:FindFirstChild("Lamp")
            if pole and pole:IsA("BasePart") and lamp and lamp:IsA("BasePart") then
                pole.Shape = Enum.PartType.Cylinder
                pole.Size = Vector3.new(11, 0.65, 0.65)
                pole.Material = Enum.Material.Metal
                pole.Color = C.metal
                pole.CanCollide = false

                lamp.Size = Vector3.new(2.25, 0.55, 1.25)
                lamp.CFrame = CFrame.new(pole.Position + Vector3.new(0, 5.62, 0))
                lamp.Material = Enum.Material.Neon
                lamp.Color = C.warm
                lamp.CanCollide = false
                lamp.CastShadow = false

                local light = lamp:FindFirstChildOfClass("PointLight")
                if light then
                    light.Brightness = 0.20
                    light.Range = 9
                    light.Shadows = false
                    light.Color = C.warm
                end

                model:SetAttribute("ASC_V071StreetLightFixed", true)
                streetLightsFixed += 1
            end
        end
    end
end

-- =========================================================
-- B. SCHOOL / SKATE IDENTITY POLISH
-- =========================================================
local schoolSign = school:FindFirstChild("SchoolSign")
if schoolSign and schoolSign:IsA("BasePart") then
    schoolSign.Size = Vector3.new(52, 5.6, 0.7)
    schoolSign.Color = C.navy
    schoolSign.Material = Enum.Material.Metal
    local label = getTextLabel(schoolSign)
    if label then
        polishTextLabel(label, "AFTER SCHOOL ACADEMY")
        label.Size = UDim2.fromScale(0.92, 0.70)
        label.Position = UDim2.fromScale(0.04, 0.15)
    end
    schoolSign:SetAttribute("ASC_V071SchoolSignPolished", true)
end

local skate = districts:FindFirstChild("SkatePark")
local skateSign = skate and skate:FindFirstChild("SkateSign")
if skateSign and skateSign:IsA("BasePart") then
    skateSign.Size = Vector3.new(28, 5.0, 0.75)
    skateSign.CFrame = CFrame.new(235, 7.2, 65.5)
    skateSign.Material = Enum.Material.Metal
    skateSign.Color = C.navy
    local label = getTextLabel(skateSign)
    if label then
        polishTextLabel(label, "AFTER SCHOOL SKATE")
        label.TextColor3 = C.gold
    end
    part(layer, "SkateSignPostL", Vector3.new(0.65, 7.2, 0.65), CFrame.new(223.5, 3.6, 65.5), C.metal, Enum.Material.Metal, false)
    part(layer, "SkateSignPostR", Vector3.new(0.65, 7.2, 0.65), CFrame.new(246.5, 3.6, 65.5), C.metal, Enum.Material.Metal, false)
    skateSign:SetAttribute("ASC_V071SkateSignPolished", true)
end

-- =========================================================
-- C. COMPACT, READABLE SCHOOL SIGNAGE
-- =========================================================
polishInteriorSign("WELCOME / MAIN HALL", "MAIN HALL", Vector3.new(11.5, 1.8, 0.32), 0.8)
polishInteriorSign("LIBRARY", nil, Vector3.new(8.0, 1.65, 0.30), 0)
polishInteriorSign("CANTEEN", nil, Vector3.new(8.0, 1.65, 0.30), 0)
polishInteriorSign("TEACHER / ADMIN", nil, Vector3.new(10.2, 1.65, 0.30), 0)
polishInteriorSign("CLUB ROOMS", nil, Vector3.new(8.8, 1.65, 0.30), 0)
polishInteriorSign("CLASSROOM A", nil, Vector3.new(7.4, 1.5, 0.28), 0)
polishInteriorSign("CLASSROOM B", nil, Vector3.new(7.4, 1.5, 0.28), 0)
polishInteriorSign("MUSIC CLUB", nil, Vector3.new(7.3, 1.45, 0.28), 0)
polishInteriorSign("ART CLUB", nil, Vector3.new(7.3, 1.45, 0.28), 0)
polishInteriorSign("TOILET A", nil, Vector3.new(5.5, 1.25, 0.25), 0)
polishInteriorSign("TOILET B", nil, Vector3.new(5.5, 1.25, 0.25), 0)
polishInteriorSign("← LIBRARY / CANTEEN", "← LIBRARY • CANTEEN", Vector3.new(11.2, 1.4, 0.28), 0)
polishInteriorSign("ADMIN / CLUBS →", "ADMIN • CLUBS →", Vector3.new(11.2, 1.4, 0.28), 0)

-- =========================================================
-- D. FURNITURE GROUNDING / DETAIL
-- Existing tops remain authoritative; supports remove the placeholder/floating read.
-- =========================================================
local supportSpecs = {
    StudentDesk = {height = 2.6, width = 0.55, depth = 1.4},
    StudentSeat = {height = 2.0, width = 0.55, depth = 1.0},
    TeacherDesk = {height = 2.6, width = 0.7, depth = 1.8},
    LibraryStudyTable = {height = 1.0, width = 0.65, depth = 1.8},
    CanteenTable = {height = 1.0, width = 0.65, depth = 1.6},
    AdminDesk = {height = 1.0, width = 0.7, depth = 1.8},
    TeacherTable = {height = 1.0, width = 0.7, depth = 1.8},
    ClubTable = {height = 1.0, width = 0.65, depth = 1.6},
}

for _, obj in ipairs(interior:GetDescendants()) do
    if obj:IsA("BasePart") then
        local spec = supportSpecs[obj.Name]
        if spec and createdParts < MAX_POLISH_PARTS then
            local supportCF = obj.CFrame * CFrame.new(0, -(obj.Size.Y / 2 + spec.height / 2), 0)
            local support = part(layer, obj.Name .. "Support", Vector3.new(spec.width, spec.height, spec.depth), supportCF, C.charcoal, Enum.Material.Metal, false)
            if support then
                support.CastShadow = true
                furnitureSupports += 1
            end
        end
    end
end

-- Library shelves: reduce monolithic block feel while preserving the aisle layout.
local leftWing = interior:FindFirstChild("LeftWingInterior")
if leftWing then
    for _, shelf in ipairs(leftWing:GetChildren()) do
        if shelf:IsA("BasePart") and shelf.Name == "LibraryShelf" then
            shelf.Size = Vector3.new(1.6, 6.5, 8.5)
            shelf.Color = C.wood
            shelf.Material = Enum.Material.Wood
            for _, y in ipairs({-2.1, 0, 2.1}) do
                part(layer, "LibraryShelfBand", Vector3.new(1.9, 0.18, 8.2), shelf.CFrame * CFrame.new(0, y, 0), C.charcoal, Enum.Material.Metal, false)
            end
        end
    end
end

-- Interior fixtures stay within the original V0.7 brightness/range hard caps.
local lightingLayer = interior:FindFirstChild("InteriorLighting")
if lightingLayer then
    for _, fixture in ipairs(lightingLayer:GetDescendants()) do
        if fixture:IsA("BasePart") and fixture.Name == "CeilingLight" then
            fixture.Size = Vector3.new(4.8, 0.28, 1.25)
            fixture.Color = C.warm
            fixture.Material = Enum.Material.Neon
            fixture.CastShadow = false
            local light = fixture:FindFirstChildOfClass("PointLight")
            if light then
                light.Brightness = math.min(0.22, 0.22)
                light.Range = math.min(10, 10)
                light.Shadows = false
            end
        end
    end
end

school:SetAttribute("ASC_SchoolInteriorPolishPass", VERSION)
school:SetAttribute("ASC_V071StreetLightsFixed", streetLightsFixed)
school:SetAttribute("ASC_V071SignsPolished", signsPolished)
school:SetAttribute("ASC_V071FurnitureSupports", furnitureSupports)
school:SetAttribute("ASC_V071PolishPartCount", createdParts)
root:SetAttribute("ASC_SchoolInteriorPolishV071", true)
Workspace:SetAttribute("ASC_SchoolInteriorPolishPass", VERSION)
Workspace:SetAttribute("ASC_StreetLightGeometryFixed", streetLightsFixed > 0)

print(string.format("[AFTER SCHOOL CITY] School Interior Polish v0.7.1 initialized; lightsFixed=%d signs=%d supports=%d newParts=%d", streetLightsFixed, signsPolished, furnitureSupports, createdParts))
