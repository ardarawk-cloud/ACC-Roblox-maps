-- AFTER SCHOOL CITY — Premium Map Pass 1 v0.2
-- Standalone namespace: Workspace/AfterSchoolCity
-- Goal: replace raw blockout presentation with a readable, mobile-friendly city foundation.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "AfterSchoolCity"
local existing = Workspace:FindFirstChild(ROOT_NAME)
if existing then
    Workspace:SetAttribute("ASC_WorldScaffold", "v0.2-preserve")
    Workspace:SetAttribute("ASC_WorldScaffoldMode", "PRESERVE_EXISTING")
    print("[AFTER SCHOOL CITY] Existing root preserved; Premium Map Pass skipped")
    return
end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root:SetAttribute("ACC_Project", "after-school-city")
root:SetAttribute("ASC_MapVersion", "0.2-premium-pass-1")
root.Parent = Workspace

local districts = Instance.new("Folder")
districts.Name = "Districts"
districts.Parent = root

local roads = Instance.new("Folder")
roads.Name = "RoadsAndPaths"
roads.Parent = root

local landscaping = Instance.new("Folder")
landscaping.Name = "Landscaping"
landscaping.Parent = root

local furniture = Instance.new("Folder")
furniture.Name = "StreetFurniture"
furniture.Parent = root

local landmarks = Instance.new("Folder")
landmarks.Name = "Landmarks"
landmarks.Parent = root

local C = {
    asphalt = Color3.fromRGB(48, 52, 60),
    asphalt2 = Color3.fromRGB(57, 62, 70),
    sidewalk = Color3.fromRGB(198, 202, 208),
    curb = Color3.fromRGB(224, 226, 230),
    white = Color3.fromRGB(240, 242, 245),
    cream = Color3.fromRGB(231, 224, 207),
    schoolBlue = Color3.fromRGB(59, 102, 151),
    navy = Color3.fromRGB(34, 48, 72),
    glass = Color3.fromRGB(92, 142, 172),
    gold = Color3.fromRGB(242, 180, 65),
    grass = Color3.fromRGB(82, 137, 82),
    grassLight = Color3.fromRGB(103, 154, 93),
    tree = Color3.fromRGB(66, 119, 72),
    trunk = Color3.fromRGB(103, 78, 57),
    brick = Color3.fromRGB(171, 112, 86),
    brickLight = Color3.fromRGB(197, 146, 112),
    purple = Color3.fromRGB(126, 102, 144),
    teal = Color3.fromRGB(64, 126, 121),
    skate = Color3.fromRGB(105, 110, 119),
    water = Color3.fromRGB(69, 139, 174),
    metal = Color3.fromRGB(78, 84, 94),
    dark = Color3.fromRGB(28, 31, 38),
}

local function part(parent, name, size, cframe, color, material, transparency)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cframe
    p.Color = color or C.white
    p.Material = material or Enum.Material.SmoothPlastic
    p.Transparency = transparency or 0
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function wedge(parent, name, size, cframe, color, material)
    local p = Instance.new("WedgePart")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cframe
    p.Color = color or C.skate
    p.Material = material or Enum.Material.Concrete
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function cylinder(parent, name, size, cframe, color, material)
    local p = part(parent, name, size, cframe, color, material)
    p.Shape = Enum.PartType.Cylinder
    return p
end

local function surfaceText(parent, text, face, textColor, backgroundTransparency, textSize)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "Signage"
    gui.Face = face or Enum.NormalId.Back
    gui.AlwaysOnTop = false
    gui.LightInfluence = 0.2
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 35
    gui.Parent = parent

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = backgroundTransparency == nil and 1 or backgroundTransparency
    label.BackgroundColor3 = C.dark
    label.Text = text
    label.TextColor3 = textColor or C.white
    label.Font = Enum.Font.GothamBold
    label.TextScaled = false
    label.TextSize = textSize or 24
    label.TextWrapped = true
    label.Parent = gui
    return gui
end

local function window(parent, name, size, cframe)
    local w = part(parent, name, size, cframe, C.glass, Enum.Material.Glass, 0.18)
    w.CanCollide = false
    w.CastShadow = false
    return w
end

local function tree(parent, pos, scale)
    scale = scale or 1
    local m = Instance.new("Model")
    m.Name = "Tree"
    m.Parent = parent
    local trunk = cylinder(m, "Trunk", Vector3.new(2.4 * scale, 10 * scale, 2.4 * scale), CFrame.new(pos + Vector3.new(0, 5 * scale, 0)) * CFrame.Angles(0, 0, math.rad(90)), C.trunk, Enum.Material.Wood)
    trunk.CanCollide = true
    local crown = part(m, "Crown", Vector3.new(10 * scale, 10 * scale, 10 * scale), CFrame.new(pos + Vector3.new(0, 12 * scale, 0)), C.tree, Enum.Material.Grass)
    crown.Shape = Enum.PartType.Ball
    crown.CanCollide = false
    return m
end

local function bench(parent, pos, yaw)
    local m = Instance.new("Model")
    m.Name = "Bench"
    m.Parent = parent
    local cf = CFrame.new(pos) * CFrame.Angles(0, math.rad(yaw or 0), 0)
    part(m, "Seat", Vector3.new(9, 0.7, 2.3), cf * CFrame.new(0, 2.1, 0), Color3.fromRGB(125, 90, 63), Enum.Material.Wood)
    part(m, "Back", Vector3.new(9, 3.3, 0.6), cf * CFrame.new(0, 3.8, 1.05), Color3.fromRGB(125, 90, 63), Enum.Material.Wood)
    part(m, "LegL", Vector3.new(0.6, 2, 0.6), cf * CFrame.new(-3.4, 1, 0), C.metal, Enum.Material.Metal)
    part(m, "LegR", Vector3.new(0.6, 2, 0.6), cf * CFrame.new(3.4, 1, 0), C.metal, Enum.Material.Metal)
    return m
end

local function streetLight(parent, pos)
    local m = Instance.new("Model")
    m.Name = "StreetLight"
    m.Parent = parent
    cylinder(m, "Pole", Vector3.new(0.65, 11, 0.65), CFrame.new(pos + Vector3.new(0, 5.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), C.metal, Enum.Material.Metal)
    local lamp = part(m, "Lamp", Vector3.new(2.5, 0.7, 1.5), CFrame.new(pos + Vector3.new(0, 11.1, 0)), Color3.fromRGB(255, 231, 171), Enum.Material.Neon)
    lamp.CanCollide = false
    local light = Instance.new("PointLight")
    light.Brightness = 1.1
    light.Range = 22
    light.Color = Color3.fromRGB(255, 226, 170)
    light.Shadows = true
    light.Parent = lamp
    return m
end

local function crosswalk(parent, center, axis)
    for i = -4, 4 do
        local offset = i * 3.3
        local size
        local pos
        if axis == "X" then
            size = Vector3.new(1.8, 0.08, 10)
            pos = center + Vector3.new(offset, 0, 0)
        else
            size = Vector3.new(10, 0.08, 1.8)
            pos = center + Vector3.new(0, 0, offset)
        end
        local stripe = part(parent, "CrosswalkStripe", size, CFrame.new(pos + Vector3.new(0, 1.46, 0)), C.white, Enum.Material.SmoothPlastic)
        stripe.CanCollide = false
    end
end

-- =========================================================
-- CITY GROUND + ROADS
-- =========================================================
part(root, "CityGround", Vector3.new(690, 2, 610), CFrame.new(0, -1, 20), Color3.fromRGB(101, 132, 91), Enum.Material.Grass)

part(roads, "NorthSouthRoad", Vector3.new(40, 0.7, 570), CFrame.new(0, 1.05, 18), C.asphalt, Enum.Material.Asphalt)
part(roads, "EastWestRoad", Vector3.new(600, 0.7, 40), CFrame.new(0, 1.05, 0), C.asphalt, Enum.Material.Asphalt)
part(roads, "SchoolSportsRoad", Vector3.new(250, 0.7, 32), CFrame.new(125, 1.05, 210), C.asphalt2, Enum.Material.Asphalt)

-- sidewalks around the two main spines
part(roads, "NS_Sidewalk_W", Vector3.new(9, 0.8, 570), CFrame.new(-24.5, 1.25, 18), C.sidewalk, Enum.Material.Concrete)
part(roads, "NS_Sidewalk_E", Vector3.new(9, 0.8, 570), CFrame.new(24.5, 1.25, 18), C.sidewalk, Enum.Material.Concrete)
part(roads, "EW_Sidewalk_N", Vector3.new(600, 0.8, 9), CFrame.new(0, 1.25, -24.5), C.sidewalk, Enum.Material.Concrete)
part(roads, "EW_Sidewalk_S", Vector3.new(600, 0.8, 9), CFrame.new(0, 1.25, 24.5), C.sidewalk, Enum.Material.Concrete)

-- lane markings
for z = -250, 285, 24 do
    local dash = part(roads, "NS_LaneDash", Vector3.new(0.35, 0.06, 10), CFrame.new(0, 1.43, z), Color3.fromRGB(236, 194, 77), Enum.Material.SmoothPlastic)
    dash.CanCollide = false
end
for x = -280, 280, 24 do
    local dash = part(roads, "EW_LaneDash", Vector3.new(10, 0.06, 0.35), CFrame.new(x, 1.43, 0), Color3.fromRGB(236, 194, 77), Enum.Material.SmoothPlastic)
    dash.CanCollide = false
end
crosswalk(roads, Vector3.new(0, 0, 39), "X")
crosswalk(roads, Vector3.new(0, 0, 181), "X")
crosswalk(roads, Vector3.new(44, 0, 0), "Z")

-- =========================================================
-- SCHOOL DISTRICT — HERO SPAWN AREA
-- =========================================================
local school = Instance.new("Model")
school.Name = "SchoolDistrict"
school:SetAttribute("ASC_District", "School")
school.Parent = districts

part(school, "SchoolGround", Vector3.new(220, 1.1, 150), CFrame.new(0, 0.55, 210), Color3.fromRGB(124, 153, 107), Enum.Material.Grass)
part(school, "FrontPlaza", Vector3.new(126, 0.8, 42), CFrame.new(0, 1.1, 256), C.sidewalk, Enum.Material.Concrete)
part(school, "FrontWalk", Vector3.new(22, 0.8, 76), CFrame.new(0, 1.1, 235), C.sidewalk, Enum.Material.Concrete)

part(school, "MainBuilding", Vector3.new(112, 34, 45), CFrame.new(0, 18, 202), C.cream, Enum.Material.Concrete)
part(school, "LeftWing", Vector3.new(48, 25, 58), CFrame.new(-76, 13.5, 208), Color3.fromRGB(217, 220, 218), Enum.Material.Concrete)
part(school, "RightWing", Vector3.new(48, 25, 58), CFrame.new(76, 13.5, 208), Color3.fromRGB(217, 220, 218), Enum.Material.Concrete)
part(school, "MainRoof", Vector3.new(118, 2.2, 50), CFrame.new(0, 35.8, 202), C.navy, Enum.Material.Metal)
part(school, "LeftRoof", Vector3.new(52, 1.8, 62), CFrame.new(-76, 26.8, 208), C.navy, Enum.Material.Metal)
part(school, "RightRoof", Vector3.new(52, 1.8, 62), CFrame.new(76, 26.8, 208), C.navy, Enum.Material.Metal)

-- front entrance canopy + columns
part(school, "EntranceCanopy", Vector3.new(34, 2, 13), CFrame.new(0, 13.8, 227), C.schoolBlue, Enum.Material.Metal)
part(school, "ColumnL", Vector3.new(2.4, 12, 2.4), CFrame.new(-13, 7.1, 231), C.white, Enum.Material.Concrete)
part(school, "ColumnR", Vector3.new(2.4, 12, 2.4), CFrame.new(13, 7.1, 231), C.white, Enum.Material.Concrete)
window(school, "EntranceGlassL", Vector3.new(10, 10, 0.7), CFrame.new(-6, 7, 224.8))
window(school, "EntranceGlassR", Vector3.new(10, 10, 0.7), CFrame.new(6, 7, 224.8))

local schoolSign = part(school, "SchoolSign", Vector3.new(46, 8, 0.7), CFrame.new(0, 24, 224.8), C.navy, Enum.Material.SmoothPlastic)
surfaceText(schoolSign, "AFTER SCHOOL ACADEMY", Enum.NormalId.Back, C.white, 1, 23)

for _, x in ipairs({-45, -29, 29, 45}) do
    window(school, "MainWindow", Vector3.new(11, 8, 0.55), CFrame.new(x, 18, 224.7))
    window(school, "MainWindowUpper", Vector3.new(11, 7, 0.55), CFrame.new(x, 28, 224.7))
end
for _, wingX in ipairs({-76, 76}) do
    for _, dx in ipairs({-14, 0, 14}) do
        window(school, "WingWindow", Vector3.new(9, 7, 0.55), CFrame.new(wingX + dx, 13, 237.1))
    end
end

part(school, "EntryStep1", Vector3.new(34, 0.8, 8), CFrame.new(0, 1.7, 232), Color3.fromRGB(186, 190, 196), Enum.Material.Concrete)
part(school, "EntryStep2", Vector3.new(29, 0.8, 6), CFrame.new(0, 2.5, 228), Color3.fromRGB(186, 190, 196), Enum.Material.Concrete)

-- school courtyard details
for _, x in ipairs({-88, -60, 60, 88}) do
    tree(landscaping, Vector3.new(x, 1.5, 257), 0.8)
end
bench(furniture, Vector3.new(-43, 1.5, 258), 180)
bench(furniture, Vector3.new(43, 1.5, 258), 180)

local busShelter = Instance.new("Model")
busShelter.Name = "SchoolBusStop"
busShelter.Parent = furniture
part(busShelter, "Roof", Vector3.new(22, 0.8, 7), CFrame.new(-54, 8, 181), C.navy, Enum.Material.Metal)
part(busShelter, "PostL", Vector3.new(0.8, 7, 0.8), CFrame.new(-63, 4.2, 181), C.metal, Enum.Material.Metal)
part(busShelter, "PostR", Vector3.new(0.8, 7, 0.8), CFrame.new(-45, 4.2, 181), C.metal, Enum.Material.Metal)
bench(busShelter, Vector3.new(-54, 1.5, 181), 180)
local busSign = part(busShelter, "BusSign", Vector3.new(12, 3.5, 0.5), CFrame.new(-54, 5.2, 184.2), C.schoolBlue, Enum.Material.SmoothPlastic)
surfaceText(busSign, "SCHOOL BUS", Enum.NormalId.Back, C.white, 1, 20)

-- =========================================================
-- DOWNTOWN
-- =========================================================
local downtown = Instance.new("Model")
downtown.Name = "Downtown"
downtown:SetAttribute("ASC_District", "Downtown")
downtown.Parent = districts
part(downtown, "DowntownGround", Vector3.new(230, 1, 170), CFrame.new(0, 0.5, 0), Color3.fromRGB(156, 151, 139), Enum.Material.Concrete)
part(downtown, "Plaza", Vector3.new(115, 0.8, 54), CFrame.new(0, 1.1, 56), Color3.fromRGB(203, 199, 188), Enum.Material.Concrete)

local shopXs = {-90, -45, 0, 45, 90}
local shopNames = {"ARCADE", "CAFE", "STYLE", "MUSIC", "HOBBY"}
for i, x in ipairs(shopXs) do
    local h = 26 + ((i + 1) % 3) * 5
    local shop = Instance.new("Model")
    shop.Name = "Shop_" .. shopNames[i]
    shop.Parent = downtown
    local facadeColor = (i % 2 == 0) and C.brickLight or C.brick
    part(shop, "Building", Vector3.new(34, h, 40), CFrame.new(x, h / 2 + 1, -56), facadeColor, Enum.Material.Brick)
    part(shop, "RoofTrim", Vector3.new(36, 1.4, 42), CFrame.new(x, h + 1.4, -56), C.dark, Enum.Material.Metal)
    window(shop, "Storefront", Vector3.new(24, 10, 0.65), CFrame.new(x, 6.5, -35.7))
    local sign = part(shop, "StoreSign", Vector3.new(26, 5, 0.55), CFrame.new(x, 14.5, -35.6), C.navy, Enum.Material.SmoothPlastic)
    surfaceText(sign, shopNames[i], Enum.NormalId.Front, (i == 1 and C.gold or C.white), 1, 24)
    part(shop, "Awning", Vector3.new(27, 0.7, 5), CFrame.new(x, 11.5, -33), (i % 2 == 0) and C.schoolBlue or C.gold, Enum.Material.Fabric)
end

-- plaza fountain / hangout centerpiece
local fountain = Instance.new("Model")
fountain.Name = "CentralFountain"
fountain.Parent = downtown
cylinder(fountain, "Basin", Vector3.new(3, 18, 18), CFrame.new(0, 2.3, 56) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(173, 181, 188), Enum.Material.Concrete)
cylinder(fountain, "Water", Vector3.new(1.2, 15, 15), CFrame.new(0, 3.4, 56) * CFrame.Angles(0, 0, math.rad(90)), C.water, Enum.Material.Glass).Transparency = 0.2
part(fountain, "CenterPost", Vector3.new(2.2, 8, 2.2), CFrame.new(0, 7, 56), C.white, Enum.Material.Marble)
for _, x in ipairs({-45, 45}) do
    bench(furniture, Vector3.new(x, 1.5, 59), x < 0 and 90 or -90)
end

-- =========================================================
-- SKATE PARK
-- =========================================================
local skate = Instance.new("Model")
skate.Name = "SkatePark"
skate:SetAttribute("ASC_District", "SkatePark")
skate.Parent = districts
part(skate, "SkateGround", Vector3.new(150, 1, 150), CFrame.new(235, 0.5, 0), Color3.fromRGB(129, 132, 139), Enum.Material.Concrete)
part(skate, "Deck", Vector3.new(122, 0.8, 112), CFrame.new(235, 1.1, 0), Color3.fromRGB(110, 113, 121), Enum.Material.Concrete)
wedge(skate, "QuarterPipeL", Vector3.new(24, 10, 32), CFrame.new(190, 6, -25) * CFrame.Angles(0, math.rad(90), 0), C.skate, Enum.Material.Concrete)
wedge(skate, "QuarterPipeR", Vector3.new(24, 10, 32), CFrame.new(280, 6, 25) * CFrame.Angles(0, math.rad(-90), 0), C.skate, Enum.Material.Concrete)
part(skate, "FunBox", Vector3.new(28, 4, 16), CFrame.new(235, 3.1, 3), C.metal, Enum.Material.Metal)
local rail = cylinder(skate, "GrindRail", Vector3.new(0.65, 30, 0.65), CFrame.new(235, 4.3, -22) * CFrame.Angles(math.rad(90), 0, 0), C.metal, Enum.Material.Metal)
rail.CanCollide = true
local skateSign = part(skate, "SkateSign", Vector3.new(34, 8, 1), CFrame.new(235, 9, 68), C.dark, Enum.Material.Metal)
surfaceText(skateSign, "AFTER SCHOOL SKATE", Enum.NormalId.Back, C.gold, 1, 22)

-- =========================================================
-- CITY PARK
-- =========================================================
local park = Instance.new("Model")
park.Name = "Park"
park:SetAttribute("ASC_District", "Park")
park.Parent = districts
part(park, "ParkGround", Vector3.new(220, 1, 150), CFrame.new(0, 0.5, -210), C.grassLight, Enum.Material.Grass)
local lake = part(park, "Lake", Vector3.new(88, 0.8, 58), CFrame.new(44, 1.05, -210), C.water, Enum.Material.Glass, 0.18)
lake.CanCollide = true
part(park, "LakeBorderN", Vector3.new(92, 0.7, 3), CFrame.new(44, 1.4, -240.5), Color3.fromRGB(176, 171, 154), Enum.Material.Rock)
part(park, "LakeBorderS", Vector3.new(92, 0.7, 3), CFrame.new(44, 1.4, -179.5), Color3.fromRGB(176, 171, 154), Enum.Material.Rock)
part(park, "WalkingPath", Vector3.new(82, 0.65, 15), CFrame.new(-51, 1.2, -210), C.sidewalk, Enum.Material.Concrete)
for _, pos in ipairs({
    Vector3.new(-91, 1.5, -246), Vector3.new(-66, 1.5, -169), Vector3.new(-25, 1.5, -246),
    Vector3.new(86, 1.5, -246), Vector3.new(91, 1.5, -172), Vector3.new(14, 1.5, -168)
}) do
    tree(landscaping, pos, 0.9)
end
bench(furniture, Vector3.new(-54, 1.5, -199), 0)
bench(furniture, Vector3.new(-54, 1.5, -221), 180)

-- =========================================================
-- RESIDENTIAL
-- =========================================================
local residential = Instance.new("Model")
residential.Name = "Residential"
residential:SetAttribute("ASC_District", "Residential")
residential.Parent = districts
part(residential, "ResidentialGround", Vector3.new(150, 1, 150), CFrame.new(-235, 0.5, 0), Color3.fromRGB(115, 144, 103), Enum.Material.Grass)
part(residential, "ResidentialWalk", Vector3.new(120, 0.7, 18), CFrame.new(-235, 1.1, 28), C.sidewalk, Enum.Material.Concrete)

for i, z in ipairs({-48, 0, 48}) do
    local house = Instance.new("Model")
    house.Name = "Townhouse_" .. i
    house.Parent = residential
    local x = -235
    local h = 24 + (i % 2) * 4
    part(house, "Body", Vector3.new(70, h, 34), CFrame.new(x, h / 2 + 1, z), (i % 2 == 0) and Color3.fromRGB(215, 205, 219) or Color3.fromRGB(224, 218, 207), Enum.Material.Concrete)
    part(house, "Roof", Vector3.new(74, 2, 38), CFrame.new(x, h + 2, z), C.navy, Enum.Material.Metal)
    for _, dx in ipairs({-22, -7, 7, 22}) do
        window(house, "Window", Vector3.new(9, 7, 0.55), CFrame.new(x + dx, 13, z + 17.2))
    end
    part(house, "Door", Vector3.new(8, 11, 0.65), CFrame.new(x, 6.8, z + 17.3), C.dark, Enum.Material.Wood)
end
for _, z in ipairs({-67, 67}) do
    tree(landscaping, Vector3.new(-292, 1.5, z), 0.8)
    tree(landscaping, Vector3.new(-178, 1.5, z), 0.8)
end

-- =========================================================
-- SPORTS FIELD
-- =========================================================
local sports = Instance.new("Model")
sports.Name = "SportsField"
sports:SetAttribute("ASC_District", "SportsField")
sports.Parent = districts
part(sports, "SportsGround", Vector3.new(150, 1, 130), CFrame.new(235, 0.5, 210), Color3.fromRGB(84, 137, 104), Enum.Material.Grass)
local court = part(sports, "BasketballCourt", Vector3.new(108, 0.8, 76), CFrame.new(235, 1.1, 205), Color3.fromRGB(177, 115, 78), Enum.Material.Concrete)

-- court markings
part(sports, "CenterLine", Vector3.new(0.35, 0.07, 72), CFrame.new(235, 1.54, 205), C.white, Enum.Material.SmoothPlastic).CanCollide = false
part(sports, "SideLineN", Vector3.new(104, 0.07, 0.35), CFrame.new(235, 1.54, 170), C.white, Enum.Material.SmoothPlastic).CanCollide = false
part(sports, "SideLineS", Vector3.new(104, 0.07, 0.35), CFrame.new(235, 1.54, 240), C.white, Enum.Material.SmoothPlastic).CanCollide = false

local function hoop(parent, pos, yaw)
    local m = Instance.new("Model")
    m.Name = "BasketballHoop"
    m.Parent = parent
    local cf = CFrame.new(pos) * CFrame.Angles(0, math.rad(yaw), 0)
    part(m, "Pole", Vector3.new(1.4, 11, 1.4), cf * CFrame.new(0, 5.5, 0), C.metal, Enum.Material.Metal)
    part(m, "Backboard", Vector3.new(9, 6, 0.6), cf * CFrame.new(0, 10.5, -2.2), C.white, Enum.Material.SmoothPlastic)
    local ring = cylinder(m, "Rim", Vector3.new(0.45, 4.2, 4.2), cf * CFrame.new(0, 8.8, -4.2) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(222, 95, 49), Enum.Material.Metal)
    ring.CanCollide = false
end
hoop(sports, Vector3.new(187, 1.5, 205), -90)
hoop(sports, Vector3.new(283, 1.5, 205), 90)
part(sports, "Bleachers", Vector3.new(105, 7, 16), CFrame.new(235, 4.8, 259), Color3.fromRGB(160, 166, 174), Enum.Material.Metal)
local sportsSign = part(sports, "SportsSign", Vector3.new(34, 7, 1), CFrame.new(235, 8, 148), C.teal, Enum.Material.Metal)
surfaceText(sportsSign, "AFTER SCHOOL SPORTS", Enum.NormalId.Front, C.white, 1, 21)

-- =========================================================
-- CITY LIGHTING / FURNITURE
-- =========================================================
for _, z in ipairs({-230, -150, -70, 75, 150, 230, 275}) do
    streetLight(furniture, Vector3.new(-30, 1.5, z))
    streetLight(furniture, Vector3.new(30, 1.5, z))
end
for _, x in ipairs({-270, -190, -110, 110, 190, 270}) do
    streetLight(furniture, Vector3.new(x, 1.5, -30))
    streetLight(furniture, Vector3.new(x, 1.5, 30))
end

-- Discreet spawn: no neon plate and no debug billboard.
local spawn = Instance.new("SpawnLocation")
spawn.Name = "AfterSchoolSpawn"
spawn.Size = Vector3.new(12, 1, 12)
spawn.CFrame = CFrame.new(0, 2.2, 271)
spawn.Anchored = true
spawn.Neutral = true
spawn.Transparency = 1
spawn.CanCollide = false
spawn.CanTouch = false
spawn.CanQuery = false
spawn.Parent = landmarks

-- Small physical welcome monument, intentionally not AlwaysOnTop.
local welcome = part(landmarks, "WelcomeMonument", Vector3.new(44, 10, 2.2), CFrame.new(0, 7, 278), C.navy, Enum.Material.Concrete)
surfaceText(welcome, "AFTER SCHOOL CITY\nSCHOOL'S OUT. THE CITY IS YOURS.", Enum.NormalId.Front, C.white, 1, 19)
part(landmarks, "WelcomeAccent", Vector3.new(48, 0.8, 3), CFrame.new(0, 12.4, 278), C.gold, Enum.Material.Neon)

-- Lighting: warm after-school golden hour, restrained effects for mobile.
Lighting.ClockTime = 16.65
Lighting.Brightness = 2.1
Lighting.GlobalShadows = true
Lighting.EnvironmentDiffuseScale = 0.32
Lighting.EnvironmentSpecularScale = 0.38
Lighting.OutdoorAmbient = Color3.fromRGB(128, 133, 145)
Lighting.Ambient = Color3.fromRGB(95, 100, 111)

local atmosphere = Instance.new("Atmosphere")
atmosphere.Name = "ASC_Atmosphere"
atmosphere.Density = 0.23
atmosphere.Offset = 0.1
atmosphere.Color = Color3.fromRGB(205, 220, 236)
atmosphere.Decay = Color3.fromRGB(116, 131, 154)
atmosphere.Glare = 0.08
atmosphere.Haze = 1.1
atmosphere.Parent = Lighting

local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Name = "ASC_ColorGrade"
colorCorrection.Brightness = 0.02
colorCorrection.Contrast = 0.06
colorCorrection.Saturation = 0.04
colorCorrection.TintColor = Color3.fromRGB(255, 244, 226)
colorCorrection.Parent = Lighting

local bloom = Instance.new("BloomEffect")
bloom.Name = "ASC_Bloom"
bloom.Intensity = 0.12
bloom.Size = 20
bloom.Threshold = 1.4
bloom.Parent = Lighting

Workspace:SetAttribute("ASC_WorldScaffold", "v0.2-premium-pass-1")
Workspace:SetAttribute("ASC_WorldScaffoldMode", "CREATED_PREMIUM_FOUNDATION")
Workspace:SetAttribute("ASC_DistrictCount", 6)
Workspace:SetAttribute("ASC_DebugBillboards", false)
Workspace:SetAttribute("ASC_CorePositioning", "SCHOOL_LIFE_ROLEPLAY")
print("[AFTER SCHOOL CITY] Premium Map Pass 1 v0.2 initialized")
