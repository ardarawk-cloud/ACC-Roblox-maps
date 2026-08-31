-- AFTER SCHOOL CITY — Premium Environment Pass v0.9.1
-- Visual depth pass after V0.8.9 safety grounding and V0.9.0 personal music player.
-- Adds source-grounded facade/roof/service/street/pool detail only.
-- All new geometry is anchored, non-collidable and non-interactive by design.

local Workspace = game:GetService("Workspace")

local VERSION = "0.9.1-premium-environment-1"
local PART_BUDGET = 230

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V091 Environment] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_EnvironmentSafetyVegetationPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V091 Environment] AfterSchoolCity root missing")
    return
end
if root:FindFirstChild("V091_PremiumEnvironment") then
    return
end

local districts = root:FindFirstChild("Districts")
local roads = root:FindFirstChild("RoadsAndPaths")
local landscaping = root:FindFirstChild("Landscaping")
local streetLife = root:FindFirstChild("V04_StreetLife")
local cityLife = root:FindFirstChild("V03_CityLife")
local poolLayer = root:FindFirstChild("V088_SwimmablePool")

if not districts or not roads then
    warn("[ASC V091 Environment] district/road authority missing")
    return
end

local northSouthRoad = roads:FindFirstChild("NorthSouthRoad")
local eastWestRoad = roads:FindFirstChild("EastWestRoad")
if not northSouthRoad or not eastWestRoad then
    warn("[ASC V091 Environment] protected road authority missing")
    return
end

local protectedRoadSnapshot = {
    NSCFrame = northSouthRoad.CFrame,
    NSSize = northSouthRoad.Size,
    NSMaterial = northSouthRoad.Material,
    NSColor = northSouthRoad.Color,
    EWCFrame = eastWestRoad.CFrame,
    EWSize = eastWestRoad.Size,
    EWMaterial = eastWestRoad.Material,
    EWColor = eastWestRoad.Color,
}

local protectedPoolSnapshot = {}
if poolLayer then
    for _, name in ipairs({"PoolWallWest", "PoolWallEast", "PoolWallNorth", "PoolWallSouth"}) do
        local wall = poolLayer:FindFirstChild(name)
        if wall and wall:IsA("BasePart") then
            protectedPoolSnapshot[name] = {
                Ref = wall,
                CFrame = wall.CFrame,
                Size = wall.Size,
                Material = wall.Material,
            }
        end
    end
end

local layer = Instance.new("Model")
layer.Name = "V091_PremiumEnvironment"
layer:SetAttribute("ASC_Layer", "PREMIUM_ENVIRONMENT")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

local C = {
    navy = Color3.fromRGB(31, 45, 68),
    blue = Color3.fromRGB(58, 103, 154),
    gold = Color3.fromRGB(224, 168, 70),
    charcoal = Color3.fromRGB(48, 53, 62),
    metal = Color3.fromRGB(82, 88, 98),
    silver = Color3.fromRGB(143, 150, 158),
    warm = Color3.fromRGB(237, 211, 171),
    white = Color3.fromRGB(232, 235, 238),
    concrete = Color3.fromRGB(169, 174, 181),
    stone = Color3.fromRGB(147, 145, 139),
    teal = Color3.fromRGB(63, 125, 120),
    green = Color3.fromRGB(67, 111, 70),
    wood = Color3.fromRGB(126, 91, 64),
    red = Color3.fromRGB(171, 72, 67),
}

local partCount = 0
local schoolDetailCount = 0
local downtownDetailCount = 0
local studentRowDetailCount = 0
local streetDetailCount = 0
local poolDetailCount = 0

local function part(parent, name, size, cf, color, material, transparency)
    if partCount >= PART_BUDGET then
        return nil
    end
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Color = color or C.white
    p.Material = material or Enum.Material.SmoothPlastic
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

local function surfaceText(plate, text, face, color)
    if not plate then return end
    local gui = Instance.new("SurfaceGui")
    gui.Name = "V091Sign"
    gui.Face = face or Enum.NormalId.Front
    gui.AlwaysOnTop = false
    gui.LightInfluence = 0.45
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 30
    gui.Parent = plate

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or C.white
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextWrapped = false
    label.Parent = gui
end

local function addRoofParapet(parent, prefix, roof, accent)
    if not roof or not roof:IsA("BasePart") then return 0 end
    local sx, sy, sz = roof.Size.X, roof.Size.Y, roof.Size.Z
    local top = sy * 0.5 + 0.58
    local z = sz * 0.5 - 0.42
    local x = sx * 0.5 - 0.42
    local made = 0
    if part(parent, prefix .. "ParapetFront", Vector3.new(math.max(2, sx - 1.2), 1.0, 0.6), roof.CFrame * CFrame.new(0, top, z), accent, Enum.Material.Metal) then made += 1 end
    if part(parent, prefix .. "ParapetBack", Vector3.new(math.max(2, sx - 1.2), 1.0, 0.6), roof.CFrame * CFrame.new(0, top, -z), accent, Enum.Material.Metal) then made += 1 end
    if part(parent, prefix .. "ParapetLeft", Vector3.new(0.6, 1.0, math.max(2, sz - 1.2)), roof.CFrame * CFrame.new(-x, top, 0), accent, Enum.Material.Metal) then made += 1 end
    if part(parent, prefix .. "ParapetRight", Vector3.new(0.6, 1.0, math.max(2, sz - 1.2)), roof.CFrame * CFrame.new(x, top, 0), accent, Enum.Material.Metal) then made += 1 end
    return made
end

local function addRearServiceUnit(parent, prefix, body, index)
    if not body or not body:IsA("BasePart") then return 0 end
    index = index or 1
    local xOffset = math.clamp(body.Size.X * (index == 1 and -0.22 or 0.22), -16, 16)
    local rearZ = -body.Size.Z * 0.5 - 0.45
    local baseY = -body.Size.Y * 0.5 + 5.0
    local unit = part(parent, prefix .. "RearAC", Vector3.new(5.2, 3.6, 1.2), body.CFrame * CFrame.new(xOffset, baseY, rearZ), C.silver, Enum.Material.Metal)
    local grille = part(parent, prefix .. "RearACGrille", Vector3.new(3.2, 2.2, 0.18), body.CFrame * CFrame.new(xOffset, baseY, rearZ - 0.7), C.charcoal, Enum.Material.Metal)
    return (unit and 1 or 0) + (grille and 1 or 0)
end

local function addDrainPipe(parent, prefix, body, side)
    if not body or not body:IsA("BasePart") then return 0 end
    local x = (body.Size.X * 0.5 + 0.22) * (side or 1)
    local frontZ = body.Size.Z * 0.5 + 0.18
    local pipe = part(parent, prefix .. "Downpipe", Vector3.new(0.45, math.max(3, body.Size.Y - 2), 0.45), body.CFrame * CFrame.new(x, 0, frontZ), C.metal, Enum.Material.Metal)
    return pipe and 1 or 0
end

-- =========================================================
-- A. SCHOOL: facade relief, sill depth, roof edge language
-- =========================================================
local school = districts:FindFirstChild("SchoolDistrict")
if school then
    local schoolDetail = Instance.new("Model")
    schoolDetail.Name = "SchoolPremiumDepth"
    schoolDetail.Parent = layer

    for _, buildingName in ipairs({"MainBuilding", "LeftWing", "RightWing"}) do
        local body = school:FindFirstChild(buildingName)
        if body and body:IsA("BasePart") then
            local frontZ = body.Size.Z * 0.5 + 0.36
            for _, ratio in ipairs({-0.2, 0.24}) do
                if part(schoolDetail, buildingName .. "FacadeBand", Vector3.new(math.max(6, body.Size.X - 3), 0.62, 0.56), body.CFrame * CFrame.new(0, body.Size.Y * ratio, frontZ), C.navy, Enum.Material.Metal) then
                    schoolDetailCount += 1
                end
            end
            schoolDetailCount += addDrainPipe(schoolDetail, buildingName, body, buildingName == "LeftWing" and -1 or 1)
        end
    end

    for _, roofName in ipairs({"MainRoof", "LeftRoof", "RightRoof"}) do
        schoolDetailCount += addRoofParapet(schoolDetail, roofName, school:FindFirstChild(roofName), C.charcoal)
    end

    for _, obj in ipairs(school:GetDescendants()) do
        if partCount >= PART_BUDGET then break end
        if obj:IsA("BasePart") and (obj.Name == "MainWindow" or obj.Name == "MainWindowUpper" or obj.Name == "WingWindow") then
            local sill = part(schoolDetail, obj.Name .. "Sill", Vector3.new(obj.Size.X + 0.6, 0.34, math.max(0.75, obj.Size.Z + 0.4)), obj.CFrame * CFrame.new(0, -obj.Size.Y * 0.5 - 0.16, 0), C.charcoal, Enum.Material.Metal)
            if sill then schoolDetailCount += 1 end
        end
    end

    local mainRoof = school:FindFirstChild("MainRoof")
    if mainRoof and mainRoof:IsA("BasePart") then
        for _, xRatio in ipairs({-0.28, 0.28}) do
            local x = mainRoof.Size.X * xRatio
            if part(schoolDetail, "RoofVentStack", Vector3.new(2.1, 3.4, 2.1), mainRoof.CFrame * CFrame.new(x, mainRoof.Size.Y * 0.5 + 2.1, -mainRoof.Size.Z * 0.18), C.metal, Enum.Material.Metal) then
                schoolDetailCount += 1
            end
            local cap = part(schoolDetail, "RoofVentCap", Vector3.new(3.0, 0.45, 3.0), mainRoof.CFrame * CFrame.new(x, mainRoof.Size.Y * 0.5 + 3.95, -mainRoof.Size.Z * 0.18), C.charcoal, Enum.Material.Metal)
            if cap then schoolDetailCount += 1 end
        end
    end
end

-- =========================================================
-- B. DOWNTOWN: parapets, rear service detail, shop display ledges
-- =========================================================
local downtown = districts:FindFirstChild("Downtown")
if downtown then
    local downtownDetail = Instance.new("Model")
    downtownDetail.Name = "DowntownPremiumDepth"
    downtownDetail.Parent = layer

    for _, shopName in ipairs({"ARCADE", "CAFE", "STYLE", "MUSIC", "HOBBY"}) do
        local shop = downtown:FindFirstChild("Shop_" .. shopName)
        local body = shop and shop:FindFirstChild("Building")
        if body and body:IsA("BasePart") then
            -- Existing body itself is used as the spatial authority; no hard-coded shop coordinates.
            local topY = body.Size.Y * 0.5 + 0.52
            local frontZ = body.Size.Z * 0.5 + 0.38
            local roofLip = part(downtownDetail, shopName .. "RoofLip", Vector3.new(math.max(8, body.Size.X - 1), 0.82, 0.62), body.CFrame * CFrame.new(0, topY, frontZ), C.charcoal, Enum.Material.Metal)
            if roofLip then downtownDetailCount += 1 end

            downtownDetailCount += addRearServiceUnit(downtownDetail, shopName, body, 1)
            downtownDetailCount += addDrainPipe(downtownDetail, shopName, body, (shopName == "CAFE" or shopName == "MUSIC") and -1 or 1)

            local displayLedge = part(downtownDetail, shopName .. "DisplayLedge", Vector3.new(math.max(7, body.Size.X * 0.44), 0.4, 1.0), body.CFrame * CFrame.new(0, -body.Size.Y * 0.5 + 3.2, frontZ + 0.2), C.concrete, Enum.Material.Concrete)
            if displayLedge then downtownDetailCount += 1 end
        end
    end
end

-- =========================================================
-- C. STUDENT ROW: every low-rise receives believable roof/service finish
-- =========================================================
local studentRow = streetLife and streetLife:FindFirstChild("StudentRowInfill")
if studentRow then
    local rowDetail = Instance.new("Model")
    rowDetail.Name = "StudentRowPremiumDepth"
    rowDetail.Parent = layer

    for _, model in ipairs(studentRow:GetChildren()) do
        if model:IsA("Model") then
            local body = model:FindFirstChild("Body")
            local roof = model:FindFirstChild("Roof")
            if body and body:IsA("BasePart") then
                if roof and roof:IsA("BasePart") then
                    studentRowDetailCount += addRoofParapet(rowDetail, model.Name, roof, C.charcoal)
                end
                studentRowDetailCount += addRearServiceUnit(rowDetail, model.Name, body, 1)
                studentRowDetailCount += addDrainPipe(rowDetail, model.Name, body, model.Name == "CornerTech" and -1 or 1)
            end
        end
    end
end

-- =========================================================
-- D. STREET: premium utility language + grounded tree base finish
-- =========================================================
local streetDetail = Instance.new("Model")
streetDetail.Name = "StreetPremiumFurniture"
streetDetail.Parent = layer

if landscaping then
    for _, treeModel in ipairs(landscaping:GetChildren()) do
        if partCount >= PART_BUDGET - 12 then break end
        if treeModel:IsA("Model") and treeModel.Name == "Tree" then
            local trunk = treeModel:FindFirstChild("Trunk")
            if trunk and trunk:IsA("BasePart") then
                local groundY = tonumber(treeModel:GetAttribute("ASC_V089GroundY")) or (trunk.Position.Y - 1)
                local grate = part(streetDetail, "TreeGroundGrate", Vector3.new(5.2, 0.12, 5.2), CFrame.new(trunk.Position.X, groundY + 0.08, trunk.Position.Z), C.charcoal, Enum.Material.Metal)
                if grate then streetDetailCount += 1 end
            end
        end
    end
end

-- Service furniture stays beyond the main 40-stud avenue and cannot block movement.
for _, item in ipairs({
    {x = -72, z = 58, kind = "WASTE"},
    {x = 72, z = 58, kind = "RECYCLE"},
    {x = -72, z = 132, kind = "RECYCLE"},
    {x = 72, z = 132, kind = "WASTE"},
}) do
    local body = part(streetDetail, "StreetBin_" .. item.kind, Vector3.new(2.4, 3.6, 2.4), CFrame.new(item.x, 3.3, item.z), item.kind == "RECYCLE" and C.teal or C.charcoal, Enum.Material.Metal)
    local lid = part(streetDetail, "StreetBinLid", Vector3.new(2.7, 0.3, 2.7), CFrame.new(item.x, 5.25, item.z), C.silver, Enum.Material.Metal)
    if body then streetDetailCount += 1 end
    if lid then streetDetailCount += 1 end
end

-- Compact pedestrian-height wayfinding, deliberately outside asphalt and centerline.
for _, entry in ipairs({
    {x = -62, z = 92, text = "SCHOOL  ↑   ·   CITY  ↓", yaw = 0},
    {x = 62, z = 166, text = "PARK  ←   ·   SPORTS  →", yaw = 0},
}) do
    local post = part(streetDetail, "WayfindingPost", Vector3.new(0.7, 5.5, 0.7), CFrame.new(entry.x, 4.2, entry.z), C.metal, Enum.Material.Metal)
    local plate = part(streetDetail, "WayfindingPlate", Vector3.new(16, 3.2, 0.55), CFrame.new(entry.x, 7.1, entry.z) * CFrame.Angles(0, math.rad(entry.yaw), 0), C.navy, Enum.Material.Metal)
    if post then streetDetailCount += 1 end
    if plate then
        surfaceText(plate, entry.text, Enum.NormalId.Front, C.white)
        surfaceText(plate, entry.text, Enum.NormalId.Back, C.white)
        streetDetailCount += 1
    end
end

-- =========================================================
-- E. POOL: finish basin edge visually without touching terrain water or walls
-- =========================================================
if poolLayer then
    local poolDetail = Instance.new("Model")
    poolDetail.Name = "PoolPremiumFinish"
    poolDetail.Parent = layer

    local west = poolLayer:FindFirstChild("PoolWallWest")
    local east = poolLayer:FindFirstChild("PoolWallEast")
    local north = poolLayer:FindFirstChild("PoolWallNorth")
    local south = poolLayer:FindFirstChild("PoolWallSouth")

    for _, wall in ipairs({west, east, north, south}) do
        if wall and wall:IsA("BasePart") then
            local coping = part(poolDetail, wall.Name .. "Coping", Vector3.new(wall.Size.X + 0.5, 0.28, wall.Size.Z + 0.5), wall.CFrame * CFrame.new(0, wall.Size.Y * 0.5 + 0.16, 0), C.white, Enum.Material.Concrete)
            if coping then poolDetailCount += 1 end
        end
    end

    if north and north:IsA("BasePart") then
        local signX = north.Position.X + math.min(22, north.Size.X * 0.28)
        local signZ = north.Position.Z - north.Size.Z * 0.5 - 1.1
        local safety = part(poolDetail, "PoolSafetySign", Vector3.new(10, 3.4, 0.45), CFrame.new(signX, north.Position.Y + 4.1, signZ), C.navy, Enum.Material.Metal)
        if safety then
            surfaceText(safety, "SWIM SAFE", Enum.NormalId.Front, C.white)
            poolDetailCount += 1
        end
    end
end

-- =========================================================
-- F. VALIDATE PROTECTED AUTHORITIES REMAIN BIT-FOR-BIT RUNTIME UNCHANGED
-- =========================================================
local roadsUnchanged = northSouthRoad.CFrame == protectedRoadSnapshot.NSCFrame
    and northSouthRoad.Size == protectedRoadSnapshot.NSSize
    and northSouthRoad.Material == protectedRoadSnapshot.NSMaterial
    and northSouthRoad.Color == protectedRoadSnapshot.NSColor
    and eastWestRoad.CFrame == protectedRoadSnapshot.EWCFrame
    and eastWestRoad.Size == protectedRoadSnapshot.EWSize
    and eastWestRoad.Material == protectedRoadSnapshot.EWMaterial
    and eastWestRoad.Color == protectedRoadSnapshot.EWColor

local poolUnchanged = true
for _, snapshot in pairs(protectedPoolSnapshot) do
    if snapshot.Ref.CFrame ~= snapshot.CFrame or snapshot.Ref.Size ~= snapshot.Size or snapshot.Ref.Material ~= snapshot.Material then
        poolUnchanged = false
        break
    end
end

if not roadsUnchanged or not poolUnchanged then
    layer:SetAttribute("ASC_V091Pass", false)
    layer:SetAttribute("ASC_V091RoadsUnchanged", roadsUnchanged)
    layer:SetAttribute("ASC_V091PoolUnchanged", poolUnchanged)
    warn(string.format("[ASC V091 Environment] HARD LOCK FAILED roadsUnchanged=%s poolUnchanged=%s", tostring(roadsUnchanged), tostring(poolUnchanged)))
    return
end

layer:SetAttribute("ASC_V091Pass", true)
layer:SetAttribute("ASC_V091RoadsUnchanged", true)
layer:SetAttribute("ASC_V091PoolUnchanged", true)
layer:SetAttribute("ASC_V091PartCount", partCount)
layer:SetAttribute("ASC_V091SchoolDetailCount", schoolDetailCount)
layer:SetAttribute("ASC_V091DowntownDetailCount", downtownDetailCount)
layer:SetAttribute("ASC_V091StudentRowDetailCount", studentRowDetailCount)
layer:SetAttribute("ASC_V091StreetDetailCount", streetDetailCount)
layer:SetAttribute("ASC_V091PoolDetailCount", poolDetailCount)
root:SetAttribute("ASC_PremiumEnvironmentV091", true)
Workspace:SetAttribute("ASC_PremiumEnvironmentPass", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V0.9.1 premium environment initialized; parts=%d school=%d downtown=%d studentRow=%d street=%d pool=%d",
    partCount,
    schoolDetailCount,
    downtownDetailCount,
    studentRowDetailCount,
    streetDetailCount,
    poolDetailCount
))
