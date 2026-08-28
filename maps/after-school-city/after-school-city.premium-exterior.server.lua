-- AFTER SCHOOL CITY — Premium Exterior Pass v0.6.0
-- Exterior/material/detail upgrade on top of verified V0.5.3 circulation.
-- Keeps school/storefronts interior-ready; no economy, persistence, monetization or gameplay authority.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC PremiumExterior] AfterSchoolCity root missing")
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
    warn("[ASC PremiumExterior] completion attribute timeout: " .. name)
    return false
end

if not waitForWorkspaceAttribute("ASC_RoadCenterlineClearancePass", 45) then
    return
end

if root:FindFirstChild("V060_PremiumExterior") then
    return
end

local districts = root:WaitForChild("Districts", 10)
local roads = root:FindFirstChild("RoadsAndPaths")

local layer = Instance.new("Model")
layer.Name = "V060_PremiumExterior"
layer:SetAttribute("ASC_Layer", "PREMIUM_EXTERIOR")
layer:SetAttribute("ASC_Version", "0.6.0-premium-exterior-1")
layer.Parent = root

-- Mobile-first presentation budgets. These are hard runtime ceilings for this pass.
local PREMIUM_PART_BUDGET = 220
local PREMIUM_LIGHT_BUDGET = 16
local MAIN_ROAD_EDGE_X = 17.6
local MAIN_ROAD_CENTER_Z = -61.5
local MAIN_ROAD_DETAIL_LENGTH = 400

local C = {
    navy = Color3.fromRGB(28, 40, 60),
    blue = Color3.fromRGB(53, 95, 145),
    gold = Color3.fromRGB(224, 164, 60),
    cream = Color3.fromRGB(226, 218, 202),
    white = Color3.fromRGB(238, 240, 242),
    charcoal = Color3.fromRGB(45, 49, 56),
    metal = Color3.fromRGB(76, 82, 91),
    glass = Color3.fromRGB(91, 139, 170),
    warm = Color3.fromRGB(245, 214, 164),
    red = Color3.fromRGB(180, 72, 65),
    teal = Color3.fromRGB(56, 126, 119),
    purple = Color3.fromRGB(122, 91, 147),
    green = Color3.fromRGB(66, 116, 69),
    stone = Color3.fromRGB(169, 166, 158),
}

local partCount = 0
local lightCount = 0

local function part(parent, name, size, cf, color, material, canCollide)
    if partCount >= PREMIUM_PART_BUDGET then
        warn("[ASC PremiumExterior] part budget reached")
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
    p.Parent = parent
    partCount += 1
    return p
end

local function addPointLight(parent, brightness, range, color)
    if not parent or lightCount >= PREMIUM_LIGHT_BUDGET then
        return nil
    end
    local light = Instance.new("PointLight")
    light.Brightness = math.min(brightness or 0.2, 0.24)
    light.Range = math.min(range or 7, 9)
    light.Color = color or C.warm
    light.Shadows = false
    light.Parent = parent
    lightCount += 1
    return light
end

local function surfaceText(plate, text, face, textColor)
    if not plate then return end
    local gui = Instance.new("SurfaceGui")
    gui.Name = "PremiumSignage"
    gui.Face = face
    gui.AlwaysOnTop = false
    gui.LightInfluence = 0.3
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
    label.TextWrapped = false
    label.Parent = gui
end

local function addWindowFrame(parent, windowPart, frameColor)
    if not windowPart or not windowPart:IsA("BasePart") then return end
    local w = windowPart.Size.X
    local h = windowPart.Size.Y
    local d = math.max(windowPart.Size.Z + 0.12, 0.18)
    local cf = windowPart.CFrame
    part(parent, "WindowFrameTop", Vector3.new(w + 0.4, 0.35, d), cf * CFrame.new(0, h / 2 + 0.15, 0), frameColor, Enum.Material.Metal, false)
    part(parent, "WindowFrameBottom", Vector3.new(w + 0.4, 0.35, d), cf * CFrame.new(0, -h / 2 - 0.15, 0), frameColor, Enum.Material.Metal, false)
    part(parent, "WindowMullion", Vector3.new(0.28, h, d), cf, frameColor, Enum.Material.Metal, false)
end

-- =========================================================
-- A. SCHOOL — PREMIUM, BUT INTERIOR-READY
-- =========================================================
local school = districts:FindFirstChild("SchoolDistrict")
if school then
    local schoolPremium = Instance.new("Model")
    schoolPremium.Name = "V060_SchoolExterior"
    schoolPremium.Parent = layer

    -- Recessed portal frame around the existing road-facing glass entrance.
    part(schoolPremium, "EntrancePierL", Vector3.new(1.2, 14.5, 1.1), CFrame.new(-17.5, 8.6, 178.75), C.navy, Enum.Material.Metal, false)
    part(schoolPremium, "EntrancePierR", Vector3.new(1.2, 14.5, 1.1), CFrame.new(17.5, 8.6, 178.75), C.navy, Enum.Material.Metal, false)
    part(schoolPremium, "EntranceLintel", Vector3.new(36.2, 1.2, 1.1), CFrame.new(0, 15.6, 178.75), C.navy, Enum.Material.Metal, false)
    part(schoolPremium, "CanopyFrontFascia", Vector3.new(34, 1.1, 0.8), CFrame.new(0, 13.8, 170.45), C.gold, Enum.Material.Metal, false)

    -- Architectural side bands break up the flat 112-stud façade without moving the building mass.
    for _, x in ipairs({-52, 52}) do
        part(schoolPremium, "FacadePier", Vector3.new(2.2, 30, 0.7), CFrame.new(x, 17.5, 179.15), C.navy, Enum.Material.Concrete, false)
    end
    part(schoolPremium, "MainRoofLip", Vector3.new(116, 1.1, 0.9), CFrame.new(0, 36.5, 176.75), C.charcoal, Enum.Material.Metal, false)

    -- Existing windows gain restrained frames/mullions rather than additional glass walls.
    for _, obj in ipairs(school:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name == "MainWindow" or obj.Name == "MainWindowUpper" or obj.Name == "WingWindow") then
            addWindowFrame(schoolPremium, obj, C.charcoal)
        end
    end

    -- Rooftop service detail is visible from distance but stays lightweight.
    for _, x in ipairs({-34, -11, 12, 35}) do
        local unit = part(schoolPremium, "RoofHVAC", Vector3.new(9, 2.4, 5.5), CFrame.new(x, 38.0, 201), C.metal, Enum.Material.Metal, false)
        if unit then
            part(schoolPremium, "RoofHVACVent", Vector3.new(6.2, 0.35, 3.5), CFrame.new(x, 39.35, 201), C.charcoal, Enum.Material.Metal, false)
        end
    end

    school:SetAttribute("ASC_InteriorReady", true)
    school:SetAttribute("ASC_PremiumExterior", "0.6.0")
end

-- =========================================================
-- B. DOWNTOWN — DISTINCT SHOP IDENTITIES, OPEN FRONTS PRESERVED
-- =========================================================
local downtown = districts:FindFirstChild("Downtown")
local shopAccents = {
    ARCADE = C.gold,
    CAFE = C.teal,
    STYLE = C.purple,
    MUSIC = C.blue,
    HOBBY = C.red,
}
if downtown then
    local downtownPremium = Instance.new("Model")
    downtownPremium.Name = "V060_DowntownFacades"
    downtownPremium.Parent = layer

    for shopName, accent in pairs(shopAccents) do
        local shop = downtown:FindFirstChild("Shop_" .. shopName)
        local building = shop and shop:FindFirstChild("Building")
        if shop and building and building:IsA("BasePart") then
            local cx = building.Position.X
            local h = building.Size.Y
            local frontZ = building.Position.Z + building.Size.Z / 2 + 0.45
            local facadeWidth = math.min(building.Size.X - 2, 22)

            -- Cornice + edge frames give each 24-stud shop a finished storefront without closing the walk-in opening.
            part(downtownPremium, shopName .. "Cornice", Vector3.new(facadeWidth, 0.7, 0.7), CFrame.new(cx, h - 1.4, frontZ), accent, Enum.Material.Metal, false)
            part(downtownPremium, shopName .. "FrameL", Vector3.new(0.7, 13, 0.7), CFrame.new(cx - 10.2, 8, frontZ), C.charcoal, Enum.Material.Metal, false)
            part(downtownPremium, shopName .. "FrameR", Vector3.new(0.7, 13, 0.7), CFrame.new(cx + 10.2, 8, frontZ), C.charcoal, Enum.Material.Metal, false)
            part(downtownPremium, shopName .. "EntryMat", Vector3.new(7.2, 0.08, 3.2), CFrame.new(cx, 1.48, frontZ + 1.7), accent, Enum.Material.Fabric, false)

            for _, dx in ipairs({-7.2, 7.2}) do
                local sconce = part(downtownPremium, shopName .. "Sconce", Vector3.new(0.65, 1.25, 0.55), CFrame.new(cx + dx, 10.5, frontZ + 0.45), C.warm, Enum.Material.SmoothPlastic, false)
                addPointLight(sconce, 0.18, 6.5, C.warm)
            end

            local sign = shop:FindFirstChild("StoreSign")
            if sign and sign:IsA("BasePart") then
                sign.Material = Enum.Material.Metal
                sign.Color = C.navy
            end
            local awning = shop:FindFirstChild("Awning")
            if awning and awning:IsA("BasePart") then
                awning.Material = Enum.Material.Fabric
                awning.Color = accent
            end

            shop:SetAttribute("ASC_InteriorReady", true)
            shop:SetAttribute("ASC_FutureMarketplaceReady", shopName == "STYLE" or shopName == "MUSIC" or shopName == "HOBBY")
            shop:SetAttribute("ASC_PremiumFacade", "0.6.0")
        end
    end
end

-- =========================================================
-- C. STUDENT ROW — PREMIUM LOW-RISE FRONTS, DOORS REMAIN CLEAR
-- =========================================================
local streetLife = root:FindFirstChild("V04_StreetLife")
local studentRow = streetLife and streetLife:FindFirstChild("StudentRowInfill")
local rowAccents = {
    StudentMiniMart = C.gold,
    StudyLounge = C.blue,
    CommunityLibrary = C.teal,
}
if studentRow then
    local rowPremium = Instance.new("Model")
    rowPremium.Name = "V060_StudentRowFacades"
    rowPremium.Parent = layer

    for modelName, accent in pairs(rowAccents) do
        local model = studentRow:FindFirstChild(modelName)
        local body = model and model:FindFirstChild("Body")
        if model and body and body:IsA("BasePart") then
            local frontLocalZ = body.Size.Z / 2 + 0.55
            local topY = body.Size.Y / 2 - 2.0
            local width = math.min(body.Size.X - 8, 34)
            part(rowPremium, modelName .. "Fascia", Vector3.new(width, 0.8, 0.65), body.CFrame * CFrame.new(0, topY, frontLocalZ), accent, Enum.Material.Metal, false)
            part(rowPremium, modelName .. "Canopy", Vector3.new(14, 0.5, 3.2), body.CFrame * CFrame.new(0, -body.Size.Y / 2 + 10.8, frontLocalZ + 1.45), accent, Enum.Material.Metal, false)
            part(rowPremium, modelName .. "TrimL", Vector3.new(0.65, 12, 0.65), body.CFrame * CFrame.new(-body.Size.X * 0.4, -body.Size.Y / 2 + 8, frontLocalZ), C.charcoal, Enum.Material.Metal, false)
            part(rowPremium, modelName .. "TrimR", Vector3.new(0.65, 12, 0.65), body.CFrame * CFrame.new(body.Size.X * 0.4, -body.Size.Y / 2 + 8, frontLocalZ), C.charcoal, Enum.Material.Metal, false)
            part(rowPremium, modelName .. "RoofUnit", Vector3.new(7, 2, 4.5), body.CFrame * CFrame.new(body.Size.X * 0.24, body.Size.Y / 2 + 1.4, -2), C.metal, Enum.Material.Metal, false)
            model:SetAttribute("ASC_InteriorReady", true)
            model:SetAttribute("ASC_PremiumFacade", "0.6.0")
        end
    end
end

-- =========================================================
-- D. STREET — CLEAN ROAD EDGE LANGUAGE, NO CENTERLINE OBSTRUCTION
-- =========================================================
if roads then
    local roadDetail = Instance.new("Model")
    roadDetail.Name = "V060_RoadDetail"
    roadDetail.Parent = layer
    for _, x in ipairs({-MAIN_ROAD_EDGE_X, MAIN_ROAD_EDGE_X}) do
        local line = part(roadDetail, "MainRoadEdgeLine", Vector3.new(0.24, 0.05, MAIN_ROAD_DETAIL_LENGTH), CFrame.new(x, 1.44, MAIN_ROAD_CENTER_Z), C.white, Enum.Material.SmoothPlastic, false)
        if line then
            line.CastShadow = false
        end
    end
end

-- =========================================================
-- E. PARK + SKATE — FINISHED EDGES AND WAYFINDING
-- =========================================================
local park = districts:FindFirstChild("Park")
if park then
    local recreation = Instance.new("Model")
    recreation.Name = "V060_ParkExterior"
    recreation.Parent = layer

    -- Complete the lake edge without entering the water footprint.
    part(recreation, "LakeEdgeWest", Vector3.new(3, 0.7, 58), CFrame.new(-1.5, 1.4, -210), C.stone, Enum.Material.Rock, false)
    part(recreation, "LakeEdgeEast", Vector3.new(3, 0.7, 58), CFrame.new(89.5, 1.4, -210), C.stone, Enum.Material.Rock, false)

    -- Entry sign stays off the main avenue.
    part(recreation, "ParkSignPostL", Vector3.new(0.7, 5.5, 0.7), CFrame.new(-81, 4.1, -145), C.metal, Enum.Material.Metal, false)
    part(recreation, "ParkSignPostR", Vector3.new(0.7, 5.5, 0.7), CFrame.new(-59, 4.1, -145), C.metal, Enum.Material.Metal, false)
    local parkSign = part(recreation, "ParkEntrySign", Vector3.new(22, 4.2, 0.55), CFrame.new(-70, 7.2, -145), C.navy, Enum.Material.Metal, false)
    surfaceText(parkSign, "CITY PARK", Enum.NormalId.Front, C.white)
    surfaceText(parkSign, "CITY PARK", Enum.NormalId.Back, C.white)
end

local skate = districts:FindFirstChild("SkatePark")
if skate then
    local skateLife = skate:FindFirstChild("V03_SkateLife")
    local skatePremium = Instance.new("Model")
    skatePremium.Name = "V060_SkateExterior"
    skatePremium.Parent = layer
    if skateLife then
        for _, obj in ipairs(skateLife:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name == "BankA" or obj.Name == "BankB" or obj.Name == "ManualPad") then
                part(skatePremium, obj.Name .. "EdgeAccent", Vector3.new(math.min(obj.Size.X, 28), 0.25, 0.35), obj.CFrame * CFrame.new(0, obj.Size.Y / 2 + 0.18, -obj.Size.Z / 2 + 0.2), C.gold, Enum.Material.Metal, false)
            end
        end
    end
end

-- =========================================================
-- F. VEHICLES — SMALL READABLE DETAILS, NO EXTRA LIGHT SOURCES
-- =========================================================
local vehiclePremium = Instance.new("Model")
vehiclePremium.Name = "V060_VehicleDetail"
vehiclePremium.Parent = layer

local vehicleCount = 0
for _, model in ipairs(root:GetDescendants()) do
    if model:IsA("Model") and model:GetAttribute("ASC_Prop") == "PARKED_VEHICLE" then
        local body = model:FindFirstChild("LowerBody") or model:FindFirstChild("BusBody")
        if body and body:IsA("BasePart") then
            local frontZ = body.Size.Z / 2 + 0.12
            local rearZ = -body.Size.Z / 2 - 0.12
            local xOff = math.min(body.Size.X * 0.3, 3.3)
            for _, x in ipairs({-xOff, xOff}) do
                part(vehiclePremium, "Headlamp", Vector3.new(1.3, 0.55, 0.25), body.CFrame * CFrame.new(x, 0.35, frontZ), C.warm, Enum.Material.SmoothPlastic, false)
                part(vehiclePremium, "TailLamp", Vector3.new(1.3, 0.55, 0.25), body.CFrame * CFrame.new(x, 0.35, rearZ), C.red, Enum.Material.SmoothPlastic, false)
            end
            part(vehiclePremium, "MirrorL", Vector3.new(0.8, 0.5, 1.2), body.CFrame * CFrame.new(-body.Size.X / 2 - 0.35, 0.9, body.Size.Z * 0.22), C.charcoal, Enum.Material.SmoothPlastic, false)
            part(vehiclePremium, "MirrorR", Vector3.new(0.8, 0.5, 1.2), body.CFrame * CFrame.new(body.Size.X / 2 + 0.35, 0.9, body.Size.Z * 0.22), C.charcoal, Enum.Material.SmoothPlastic, false)
            model:SetAttribute("ASC_PremiumVehicleDetail", true)
            vehicleCount += 1
        end
    end
end

-- =========================================================
-- G. LIGHTING — WARM AFTER-SCHOOL GRADE, RESTRAINED FOR MOBILE
-- =========================================================
Lighting.ClockTime = 16.85
Lighting.Brightness = 2.0
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.32
Lighting.EnvironmentDiffuseScale = 0.38
Lighting.EnvironmentSpecularScale = 0.42
Lighting.OutdoorAmbient = Color3.fromRGB(145, 139, 129)

local grade = Lighting:FindFirstChild("ASC_V060ColorGrade")
if not grade then
    grade = Instance.new("ColorCorrectionEffect")
    grade.Name = "ASC_V060ColorGrade"
    grade.Parent = Lighting
end
grade.Brightness = 0.015
grade.Contrast = 0.05
grade.Saturation = 0.055
grade.TintColor = Color3.fromRGB(255, 244, 228)

root:SetAttribute("ASC_PremiumExteriorPass", "0.6.0-premium-exterior-1")
root:SetAttribute("ASC_SchoolPremiumExterior", true)
root:SetAttribute("ASC_DowntownPremiumFacades", true)
root:SetAttribute("ASC_StudentRowPremiumFacades", true)
root:SetAttribute("ASC_StreetPremiumMarkings", true)
root:SetAttribute("ASC_RecreationPremiumExterior", true)
root:SetAttribute("ASC_VehiclePremiumDetail", true)
root:SetAttribute("ASC_PremiumLightingBalanced", true)
root:SetAttribute("ASC_PremiumExteriorPartCount", partCount)
root:SetAttribute("ASC_PremiumExteriorLightCount", lightCount)
root:SetAttribute("ASC_PremiumVehicleCount", vehicleCount)
Workspace:SetAttribute("ASC_PremiumExteriorPass", "0.6.0-premium-exterior-1")

print(string.format("[AFTER SCHOOL CITY] Premium Exterior v0.6.0 initialized; parts=%d lights=%d vehicles=%d", partCount, lightCount, vehicleCount))
