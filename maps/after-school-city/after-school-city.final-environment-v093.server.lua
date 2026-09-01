-- AFTER SCHOOL CITY — Final Environment Polish v0.9.3
-- Final visual-only pass before gameplay foundation.
-- Focus: rear/side architectural depth, service detail, street-tree silhouette, and restrained ambience.
-- No road, pool, signage, gameplay, economy, persistence, monetization, music, or dedication authority.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local VERSION = "0.9.3-final-environment-polish-1"
local PART_BUDGET = 190

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V093 Final Environment] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_SignageTypographyBoostPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V093 Final Environment] AfterSchoolCity root missing")
    return
end
if root:FindFirstChild("V093_FinalEnvironmentPolish") then
    return
end

local districts = root:FindFirstChild("Districts")
local roads = root:FindFirstChild("RoadsAndPaths")
local landscaping = root:FindFirstChild("Landscaping")
local streetLife = root:FindFirstChild("V04_StreetLife")
local poolLayer = root:FindFirstChild("V088_SwimmablePool")

if not districts or not roads then
    warn("[ASC V093 Final Environment] district/road authority missing")
    return
end

local protectedRoadNames = {"NorthSouthRoad", "EastWestRoad", "SchoolSportsRoad"}
local protectedRoadSnapshot = {}
for _, name in ipairs(protectedRoadNames) do
    local p = roads:FindFirstChild(name)
    if not p or not p:IsA("BasePart") then
        warn("[ASC V093 Final Environment] protected road missing: " .. name)
        return
    end
    protectedRoadSnapshot[name] = {
        Ref = p,
        CFrame = p.CFrame,
        Size = p.Size,
        Material = p.Material,
        Color = p.Color,
    }
end

local protectedPoolSnapshot = {}
if poolLayer then
    for _, name in ipairs({"PoolWallWest", "PoolWallEast", "PoolWallNorth", "PoolWallSouth"}) do
        local p = poolLayer:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            protectedPoolSnapshot[name] = {
                Ref = p,
                CFrame = p.CFrame,
                Size = p.Size,
                Material = p.Material,
            }
        end
    end
end

local layer = Instance.new("Model")
layer.Name = "V093_FinalEnvironmentPolish"
layer:SetAttribute("ASC_Layer", "FINAL_ENVIRONMENT_POLISH")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

local C = {
    navy = Color3.fromRGB(31, 45, 68),
    charcoal = Color3.fromRGB(47, 52, 60),
    metal = Color3.fromRGB(82, 88, 98),
    silver = Color3.fromRGB(143, 150, 158),
    concrete = Color3.fromRGB(166, 171, 177),
    warm = Color3.fromRGB(235, 205, 160),
    gold = Color3.fromRGB(218, 164, 70),
    teal = Color3.fromRGB(62, 123, 118),
    blue = Color3.fromRGB(58, 101, 151),
    purple = Color3.fromRGB(118, 91, 142),
    red = Color3.fromRGB(169, 73, 67),
    green = Color3.fromRGB(67, 111, 70),
    greenWarm = Color3.fromRGB(78, 123, 76),
}

local partCount = 0
local schoolDetailCount = 0
local downtownDetailCount = 0
local studentRowDetailCount = 0
local vegetationDetailCount = 0
local recreationDetailCount = 0

local function visualPart(parent, name, size, cf, color, material, transparency)
    if partCount >= PART_BUDGET then
        return nil
    end
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Color = color or C.charcoal
    p.Material = material or Enum.Material.Metal
    p.Transparency = transparency or 0
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = true
    p.Parent = parent
    partCount += 1
    return p
end

local function addRearServiceDoor(parent, prefix, body, xRatio, accent)
    if not body or not body:IsA("BasePart") then return 0 end
    local x = math.clamp(body.Size.X * (xRatio or 0.22), -18, 18)
    local rearZ = -body.Size.Z * 0.5 - 0.38
    local baseY = -body.Size.Y * 0.5 + 4.8
    local made = 0

    if visualPart(parent, prefix .. "RearServiceDoor", Vector3.new(5.8, 8.4, 0.42), body.CFrame * CFrame.new(x, baseY, rearZ), C.charcoal, Enum.Material.Metal) then
        made += 1
    end
    if visualPart(parent, prefix .. "RearDoorHeader", Vector3.new(6.6, 0.55, 0.55), body.CFrame * CFrame.new(x, baseY + 4.45, rearZ - 0.06), accent or C.navy, Enum.Material.Metal) then
        made += 1
    end
    if visualPart(parent, prefix .. "RearMeterBox", Vector3.new(2.4, 3.0, 0.55), body.CFrame * CFrame.new(x + 4.5, baseY + 0.5, rearZ), C.silver, Enum.Material.Metal) then
        made += 1
    end
    return made
end

local function addRearLouver(parent, prefix, body, xRatio, width)
    if not body or not body:IsA("BasePart") then return 0 end
    local x = math.clamp(body.Size.X * (xRatio or -0.2), -20, 20)
    local rearZ = -body.Size.Z * 0.5 - 0.36
    local y = math.clamp(body.Size.Y * 0.12, 3.5, 7.0)
    local w = math.min(width or 7.5, math.max(4.5, body.Size.X * 0.2))
    local made = 0

    if visualPart(parent, prefix .. "RearLouverFrame", Vector3.new(w, 4.6, 0.38), body.CFrame * CFrame.new(x, y, rearZ), C.metal, Enum.Material.Metal) then
        made += 1
    end
    for i = -2, 2 do
        if visualPart(parent, prefix .. "RearLouverBlade", Vector3.new(w - 0.7, 0.28, 0.24), body.CFrame * CFrame.new(x, y + i * 0.72, rearZ - 0.28), C.charcoal, Enum.Material.Metal) then
            made += 1
        end
    end
    return made
end

local function addBasePlinth(parent, prefix, body, color)
    if not body or not body:IsA("BasePart") then return 0 end
    local frontZ = body.Size.Z * 0.5 + 0.26
    local rearZ = -body.Size.Z * 0.5 - 0.26
    local y = -body.Size.Y * 0.5 + 1.0
    local width = math.max(6, body.Size.X - 1.5)
    local made = 0
    if visualPart(parent, prefix .. "FrontPlinth", Vector3.new(width, 1.4, 0.35), body.CFrame * CFrame.new(0, y, frontZ), color or C.concrete, Enum.Material.Concrete) then made += 1 end
    if visualPart(parent, prefix .. "RearPlinth", Vector3.new(width, 1.4, 0.35), body.CFrame * CFrame.new(0, y, rearZ), color or C.concrete, Enum.Material.Concrete) then made += 1 end
    return made
end

-- =========================================================
-- A. SCHOOL — finish side/rear elevations instead of adding more front clutter.
-- =========================================================
local school = districts:FindFirstChild("SchoolDistrict")
if school then
    local schoolDetail = Instance.new("Model")
    schoolDetail.Name = "SchoolFinalArchitecturalDepth"
    schoolDetail.Parent = layer

    for index, buildingName in ipairs({"MainBuilding", "LeftWing", "RightWing"}) do
        local body = school:FindFirstChild(buildingName)
        if body and body:IsA("BasePart") then
            schoolDetailCount += addRearServiceDoor(schoolDetail, buildingName, index == 2 and -0.24 or 0.24, C.blue)
            schoolDetailCount += addRearLouver(schoolDetail, buildingName, index == 3 and 0.18 or -0.18, buildingName == "MainBuilding" and 9.5 or 6.8)
            schoolDetailCount += addBasePlinth(schoolDetail, buildingName, body, C.concrete)

            local sideX = body.Size.X * 0.5 + 0.28
            for _, sign in ipairs({-1, 1}) do
                for _, yRatio in ipairs({-0.18, 0.18}) do
                    local panel = visualPart(
                        schoolDetail,
                        buildingName .. "SideRelief",
                        Vector3.new(0.42, math.max(4.5, body.Size.Y * 0.22), math.max(5.0, body.Size.Z * 0.34)),
                        body.CFrame * CFrame.new(sideX * sign, body.Size.Y * yRatio, 0),
                        C.navy,
                        Enum.Material.Metal
                    )
                    if panel then schoolDetailCount += 1 end
                end
            end
        end
    end
end

-- =========================================================
-- B. DOWNTOWN — believable rear/service elevations while storefront fronts stay unchanged.
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
    local downtownDetail = Instance.new("Model")
    downtownDetail.Name = "DowntownFinalServiceDepth"
    downtownDetail.Parent = layer

    for shopName, accent in pairs(shopAccents) do
        local shop = downtown:FindFirstChild("Shop_" .. shopName)
        local body = shop and shop:FindFirstChild("Building")
        if body and body:IsA("BasePart") then
            downtownDetailCount += addRearServiceDoor(downtownDetail, shopName, body, shopName == "CAFE" and -0.18 or 0.18, accent)
            downtownDetailCount += addRearLouver(downtownDetail, shopName, body, shopName == "STYLE" and 0.2 or -0.2, 6.5)
            downtownDetailCount += addBasePlinth(downtownDetail, shopName, body, C.concrete)

            local rearZ = -body.Size.Z * 0.5 - 0.5
            local conduitX = math.clamp(body.Size.X * -0.32, -9, 9)
            if visualPart(downtownDetail, shopName .. "RearConduit", Vector3.new(0.36, math.max(5, body.Size.Y - 5), 0.36), body.CFrame * CFrame.new(conduitX, 0, rearZ), C.metal, Enum.Material.Metal) then
                downtownDetailCount += 1
            end
        end
    end
end

-- =========================================================
-- C. STUDENT ROW — complete the unseen backs/sides of the low-rise block.
-- =========================================================
local studentRow = streetLife and streetLife:FindFirstChild("StudentRowInfill")
if studentRow then
    local rowDetail = Instance.new("Model")
    rowDetail.Name = "StudentRowFinalServiceDepth"
    rowDetail.Parent = layer

    local rowIndex = 0
    for _, model in ipairs(studentRow:GetChildren()) do
        if model:IsA("Model") then
            local body = model:FindFirstChild("Body")
            if body and body:IsA("BasePart") then
                rowIndex += 1
                local accent = (rowIndex % 3 == 1 and C.gold) or (rowIndex % 3 == 2 and C.blue) or C.teal
                studentRowDetailCount += addRearServiceDoor(rowDetail, model.Name, body, rowIndex % 2 == 0 and -0.18 or 0.18, accent)
                studentRowDetailCount += addRearLouver(rowDetail, model.Name, body, rowIndex % 2 == 0 and 0.22 or -0.22, 6.4)
                studentRowDetailCount += addBasePlinth(rowDetail, model.Name, body, C.concrete)
            end
        end
    end
end

-- =========================================================
-- D. VEGETATION — break the remaining repeated StreetTreeCrown spheres.
-- Core corridor TreeCrown objects were already handled by V0.9.2 and are intentionally skipped.
-- =========================================================
if landscaping then
    local vegetationDetail = Instance.new("Model")
    vegetationDetail.Name = "StreetTreeFinalSilhouette"
    vegetationDetail.Parent = layer

    local index = 0
    for _, crown in ipairs(landscaping:GetDescendants()) do
        if partCount >= PART_BUDGET - 20 then break end
        if crown:IsA("BasePart") and crown.Name == "StreetTreeCrown" then
            index += 1
            crown.CanCollide = false
            crown.CanTouch = false
            crown.CanQuery = false
            crown.Material = Enum.Material.Grass

            local original = crown.Size
            crown.Size = Vector3.new(original.X * 0.82, original.Y * 0.90, original.Z * 0.82)
            local direction = index % 2 == 0 and 1 or -1
            local lobeSize = Vector3.new(math.max(3.4, original.X * 0.58), math.max(3.6, original.Y * 0.62), math.max(3.4, original.Z * 0.58))

            local a = visualPart(vegetationDetail, "StreetCanopyLobeA", lobeSize, crown.CFrame * CFrame.new(original.X * 0.26 * direction, original.Y * 0.04, original.Z * 0.10), crown.Color, Enum.Material.Grass)
            local b = visualPart(vegetationDetail, "StreetCanopyLobeB", lobeSize * 0.88, crown.CFrame * CFrame.new(-original.X * 0.23 * direction, original.Y * 0.12, -original.Z * 0.15), crown.Color:Lerp(C.greenWarm, 0.18), Enum.Material.Grass)
            if a then a.Shape = Enum.PartType.Ball end
            if b then b.Shape = Enum.PartType.Ball end
            vegetationDetailCount += 1
        end
    end
end

-- =========================================================
-- E. RECREATION — small non-blocking service furniture, no activity geometry changes.
-- =========================================================
local skate = districts:FindFirstChild("SkatePark")
if skate then
    local recreation = Instance.new("Model")
    recreation.Name = "RecreationFinalFurniture"
    recreation.Parent = layer

    for i, x in ipairs({218, 252}) do
        if visualPart(recreation, "SkateWasteBin", Vector3.new(2.2, 3.2, 2.2), CFrame.new(x, 3.05, 58), C.charcoal, Enum.Material.Metal) then recreationDetailCount += 1 end
        if visualPart(recreation, "SkateBinTop", Vector3.new(2.35, 0.28, 2.35), CFrame.new(x, 4.78, 58), C.metal, Enum.Material.Metal) then recreationDetailCount += 1 end
        if visualPart(recreation, "SkateBinAccent", Vector3.new(1.25, 1.4, 0.16), CFrame.new(x, 3.25, 56.82), i == 1 and C.gold or C.blue, Enum.Material.Metal) then recreationDetailCount += 1 end
    end
end

-- =========================================================
-- F. AMBIENCE — restrained finishing grade; preserve time-of-day and global Lighting authority.
-- =========================================================
local finalGrade = Lighting:FindFirstChild("ASC_V093FinalGrade")
if not finalGrade then
    finalGrade = Instance.new("ColorCorrectionEffect")
    finalGrade.Name = "ASC_V093FinalGrade"
    finalGrade.Parent = Lighting
end
finalGrade.Brightness = 0.008
finalGrade.Contrast = 0.025
finalGrade.Saturation = 0.018
finalGrade.TintColor = Color3.fromRGB(255, 249, 240)

local atmosphere = Lighting:FindFirstChild("ASC_V093Atmosphere")
if not atmosphere then
    atmosphere = Instance.new("Atmosphere")
    atmosphere.Name = "ASC_V093Atmosphere"
    atmosphere.Parent = Lighting
end
atmosphere.Density = 0.08
atmosphere.Offset = 0.12
atmosphere.Color = Color3.fromRGB(218, 224, 230)
atmosphere.Decay = Color3.fromRGB(146, 156, 170)
atmosphere.Glare = 0.02
atmosphere.Haze = 0.42

-- =========================================================
-- G. HARD LOCKS — this pass must not alter protected road/pool authority.
-- =========================================================
local roadsUnchanged = true
for _, snapshot in pairs(protectedRoadSnapshot) do
    local p = snapshot.Ref
    if p.CFrame ~= snapshot.CFrame or p.Size ~= snapshot.Size or p.Material ~= snapshot.Material or p.Color ~= snapshot.Color then
        roadsUnchanged = false
        break
    end
end

local poolUnchanged = true
for _, snapshot in pairs(protectedPoolSnapshot) do
    local p = snapshot.Ref
    if p.CFrame ~= snapshot.CFrame or p.Size ~= snapshot.Size or p.Material ~= snapshot.Material then
        poolUnchanged = false
        break
    end
end

local visualSafetyPass = true
for _, obj in ipairs(layer:GetDescendants()) do
    if obj:IsA("BasePart") and (obj.CanCollide or obj.CanTouch or obj.CanQuery) then
        visualSafetyPass = false
        break
    end
end

local pass = roadsUnchanged and poolUnchanged and visualSafetyPass and partCount <= PART_BUDGET
layer:SetAttribute("ASC_V093Pass", pass)
layer:SetAttribute("ASC_V093RoadsUnchanged", roadsUnchanged)
layer:SetAttribute("ASC_V093PoolUnchanged", poolUnchanged)
layer:SetAttribute("ASC_V093VisualSafety", visualSafetyPass)
layer:SetAttribute("ASC_V093PartCount", partCount)
layer:SetAttribute("ASC_V093SchoolDetails", schoolDetailCount)
layer:SetAttribute("ASC_V093DowntownDetails", downtownDetailCount)
layer:SetAttribute("ASC_V093StudentRowDetails", studentRowDetailCount)
layer:SetAttribute("ASC_V093VegetationDetails", vegetationDetailCount)
layer:SetAttribute("ASC_V093RecreationDetails", recreationDetailCount)

if not pass then
    warn(string.format("[ASC V093 Final Environment] HARD LOCK FAILED roads=%s pool=%s visual=%s parts=%d", tostring(roadsUnchanged), tostring(poolUnchanged), tostring(visualSafetyPass), partCount))
    return
end

root:SetAttribute("ASC_FinalEnvironmentPolish", true)
Workspace:SetAttribute("ASC_FinalEnvironmentPolishPass", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V0.9.3 final environment polish ready; parts=%d school=%d downtown=%d studentRow=%d vegetation=%d recreation=%d",
    partCount,
    schoolDetailCount,
    downtownDetailCount,
    studentRowDetailCount,
    vegetationDetailCount,
    recreationDetailCount
))
