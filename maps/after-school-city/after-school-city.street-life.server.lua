-- AFTER SCHOOL CITY — Street Density Pass v0.4
-- Adds secondary streets, low-rise infill, alleys, parking, parked vehicles and street props.
-- Visual-only layer: no economy, persistence or monetization authority.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC StreetLife] AfterSchoolCity root missing")
    return
end

if root:FindFirstChild("V04_StreetLife") then
    return
end

local roads = root:WaitForChild("RoadsAndPaths", 10)
local districts = root:WaitForChild("Districts", 10)
local furniture = root:FindFirstChild("StreetFurniture") or root
local landscaping = root:FindFirstChild("Landscaping") or root

local layer = Instance.new("Model")
layer.Name = "V04_StreetLife"
layer:SetAttribute("ASC_Layer", "STREET_DENSITY")
layer:SetAttribute("ASC_Version", "0.4-street-density-pass-1")
layer.Parent = root

local C = {
    asphalt = Color3.fromRGB(48, 52, 60),
    asphalt2 = Color3.fromRGB(57, 62, 70),
    sidewalk = Color3.fromRGB(194, 199, 205),
    curb = Color3.fromRGB(224, 226, 230),
    white = Color3.fromRGB(239, 241, 244),
    dark = Color3.fromRGB(31, 35, 42),
    navy = Color3.fromRGB(34, 48, 72),
    blue = Color3.fromRGB(59, 102, 151),
    gold = Color3.fromRGB(242, 180, 65),
    glass = Color3.fromRGB(91, 139, 170),
    brick = Color3.fromRGB(173, 114, 87),
    cream = Color3.fromRGB(226, 219, 204),
    teal = Color3.fromRGB(63, 126, 120),
    green = Color3.fromRGB(70, 124, 72),
    hedge = Color3.fromRGB(63, 108, 65),
    metal = Color3.fromRGB(79, 85, 94),
    wood = Color3.fromRGB(132, 96, 66),
    concrete = Color3.fromRGB(177, 182, 188),
    red = Color3.fromRGB(185, 76, 67),
    yellow = Color3.fromRGB(225, 178, 61),
}

local function part(parent, name, size, cf, color, material, transparency)
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
    p.Parent = parent
    return p
end

local function sign(parent, text, size, cf, color, textColor)
    local plate = part(parent, "Sign", size, cf, color or C.navy, Enum.Material.SmoothPlastic)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.AlwaysOnTop = false
    gui.PixelsPerStud = 30
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.Parent = plate

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = textColor or C.white
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextWrapped = true
    label.Parent = gui
    return plate
end

local function window(parent, name, size, cf)
    local w = part(parent, name, size, cf, C.glass, Enum.Material.Glass, 0.18)
    w.CanCollide = false
    w.CastShadow = false
    return w
end

local function tree(parent, pos, scale)
    scale = scale or 1
    local trunk = part(parent, "StreetTreeTrunk", Vector3.new(1.8 * scale, 7 * scale, 1.8 * scale), CFrame.new(pos + Vector3.new(0, 3.5 * scale, 0)), Color3.fromRGB(101, 76, 53), Enum.Material.Wood)
    trunk.CanCollide = true
    local crown = part(parent, "StreetTreeCrown", Vector3.new(7.5 * scale, 7.5 * scale, 7.5 * scale), CFrame.new(pos + Vector3.new(0, 9 * scale, 0)), C.green, Enum.Material.Grass)
    crown.Shape = Enum.PartType.Ball
    crown.CanCollide = false
end

local function lamp(parent, pos)
    part(parent, "StreetLampPole", Vector3.new(0.6, 9, 0.6), CFrame.new(pos + Vector3.new(0, 4.5, 0)), C.metal, Enum.Material.Metal)
    local head = part(parent, "StreetLampHead", Vector3.new(2.2, 0.55, 1.3), CFrame.new(pos + Vector3.new(0, 9.2, 0)), Color3.fromRGB(255, 229, 176), Enum.Material.Neon)
    head.CanCollide = false
    local light = Instance.new("PointLight")
    light.Brightness = 0.55
    light.Range = 16
    light.Color = Color3.fromRGB(255, 225, 175)
    light.Shadows = false
    light.Parent = head
end

local function planter(parent, pos)
    part(parent, "PlanterBase", Vector3.new(6, 1.8, 4), CFrame.new(pos + Vector3.new(0, 0.9, 0)), Color3.fromRGB(115, 105, 91), Enum.Material.Concrete)
    local bush = part(parent, "PlanterBush", Vector3.new(5, 2.8, 3), CFrame.new(pos + Vector3.new(0, 2.8, 0)), C.hedge, Enum.Material.Grass)
    bush.Shape = Enum.PartType.Ball
    bush.CanCollide = false
end

local function lowRise(parent, name, pos, size, facade, signText)
    local m = Instance.new("Model")
    m.Name = name
    m.Parent = parent

    local w, h, d = size.X, size.Y, size.Z
    part(m, "Body", size, CFrame.new(pos + Vector3.new(0, h / 2, 0)), facade, Enum.Material.Concrete)
    part(m, "Roof", Vector3.new(w + 2, 1.2, d + 2), CFrame.new(pos + Vector3.new(0, h + 0.6, 0)), C.dark, Enum.Material.Metal)
    part(m, "FrontTrim", Vector3.new(w + 0.4, 1, 1), CFrame.new(pos + Vector3.new(0, h - 2, d / 2 + 0.45)), C.navy, Enum.Material.Metal)

    local frontZ = pos.Z + d / 2 + 0.55
    local door = part(m, "Door", Vector3.new(7, 10, 0.7), CFrame.new(pos.X, 5.3, frontZ), C.dark, Enum.Material.Wood)
    door:SetAttribute("ASC_Entrance", true)

    for _, xOff in ipairs({-w * 0.3, w * 0.3}) do
        window(m, "FrontWindow", Vector3.new(math.max(7, w * 0.18), 7, 0.6), CFrame.new(pos.X + xOff, 9, frontZ))
    end

    if h >= 22 then
        for _, xOff in ipairs({-w * 0.3, 0, w * 0.3}) do
            window(m, "UpperWindow", Vector3.new(math.max(6, w * 0.15), 6, 0.6), CFrame.new(pos.X + xOff, h - 7, frontZ))
        end
    end

    if signText then
        sign(m, signText, Vector3.new(math.min(w - 6, 30), 4.2, 0.6), CFrame.new(pos.X, math.min(h - 3, 15), frontZ + 0.35), C.navy, C.white)
    end

    return m
end

local function parkedCar(parent, name, pos, yaw, bodyColor)
    local m = Instance.new("Model")
    m.Name = name
    m:SetAttribute("ASC_Prop", "PARKED_VEHICLE")
    m.Parent = parent

    local cf = CFrame.new(pos) * CFrame.Angles(0, math.rad(yaw or 0), 0)
    part(m, "LowerBody", Vector3.new(10, 2.2, 18), cf * CFrame.new(0, 2.6, 0), bodyColor, Enum.Material.SmoothPlastic)
    part(m, "Cabin", Vector3.new(8.2, 3.4, 9), cf * CFrame.new(0, 5.1, -0.5), bodyColor:Lerp(C.white, 0.12), Enum.Material.SmoothPlastic)
    local windshield = window(m, "Windshield", Vector3.new(7.3, 2.4, 0.35), cf * CFrame.new(0, 5.5, 4.15))
    windshield.CanCollide = false
    local rear = window(m, "RearWindow", Vector3.new(7.3, 2.2, 0.35), cf * CFrame.new(0, 5.5, -5.15))
    rear.CanCollide = false

    for _, x in ipairs({-5.2, 5.2}) do
        for _, z in ipairs({-5.8, 5.8}) do
            local wheel = part(m, "Wheel", Vector3.new(2.2, 2.2, 1.3), cf * CFrame.new(x, 2, z) * CFrame.Angles(0, 0, math.rad(90)), C.dark, Enum.Material.Rubber)
            wheel.Shape = Enum.PartType.Cylinder
        end
    end

    part(m, "FrontBumper", Vector3.new(9, 0.7, 0.7), cf * CFrame.new(0, 2.2, 9.2), C.metal, Enum.Material.Metal)
    part(m, "RearBumper", Vector3.new(9, 0.7, 0.7), cf * CFrame.new(0, 2.2, -9.2), C.metal, Enum.Material.Metal)
    return m
end

local function parkingLot(parent, name, center, size)
    local m = Instance.new("Model")
    m.Name = name
    m.Parent = parent
    part(m, "ParkingSurface", Vector3.new(size.X, 0.5, size.Z), CFrame.new(center + Vector3.new(0, 1.15, 0)), C.asphalt2, Enum.Material.Asphalt)

    for x = -size.X / 2 + 10, size.X / 2 - 10, 12 do
        local stripe = part(m, "ParkingStripe", Vector3.new(0.25, 0.05, 13), CFrame.new(center + Vector3.new(x, 1.43, 0)), C.white, Enum.Material.SmoothPlastic)
        stripe.CanCollide = false
    end
    return m
end

-- =========================================================
-- SECONDARY STREET GRID
-- =========================================================
local streetGrid = Instance.new("Model")
streetGrid.Name = "SecondaryStreetGrid"
streetGrid.Parent = layer

-- Two north-south side streets create actual city blocks around the main school avenue.
for _, x in ipairs({-126, 126}) do
    part(streetGrid, "SideStreet", Vector3.new(28, 0.6, 190), CFrame.new(x, 1.05, 98), C.asphalt2, Enum.Material.Asphalt)
    part(streetGrid, "SidewalkW", Vector3.new(7, 0.65, 190), CFrame.new(x - 17.5, 1.2, 98), C.sidewalk, Enum.Material.Concrete)
    part(streetGrid, "SidewalkE", Vector3.new(7, 0.65, 190), CFrame.new(x + 17.5, 1.2, 98), C.sidewalk, Enum.Material.Concrete)

    for z = 20, 180, 24 do
        local dash = part(streetGrid, "SideStreetDash", Vector3.new(0.3, 0.05, 9), CFrame.new(x, 1.39, z), C.yellow, Enum.Material.SmoothPlastic)
        dash.CanCollide = false
    end
end

-- Short cross streets turn the long empty grass strips into smaller blocks.
for _, z in ipairs({62, 132}) do
    part(streetGrid, "CrossStreet", Vector3.new(280, 0.6, 24), CFrame.new(0, 1.05, z), C.asphalt2, Enum.Material.Asphalt)
    part(streetGrid, "CrossSidewalkN", Vector3.new(280, 0.65, 6), CFrame.new(0, 1.2, z - 15), C.sidewalk, Enum.Material.Concrete)
    part(streetGrid, "CrossSidewalkS", Vector3.new(280, 0.65, 6), CFrame.new(0, 1.2, z + 15), C.sidewalk, Enum.Material.Concrete)
end

-- =========================================================
-- STUDENT ROW / COMMUNITY INFILL
-- =========================================================
local infill = Instance.new("Model")
infill.Name = "StudentRowInfill"
infill.Parent = layer

lowRise(infill, "StudentMiniMart", Vector3.new(-176, 0, 108), Vector3.new(48, 22, 34), C.cream, "MINI MART")
lowRise(infill, "StudyLounge", Vector3.new(-176, 0, 158), Vector3.new(48, 25, 34), Color3.fromRGB(211, 218, 221), "STUDY LOUNGE")
lowRise(infill, "CommunityLibrary", Vector3.new(176, 0, 112), Vector3.new(52, 27, 36), Color3.fromRGB(202, 212, 219), "CITY LIBRARY")
lowRise(infill, "YouthStudio", Vector3.new(176, 0, 162), Vector3.new(52, 23, 34), Color3.fromRGB(215, 203, 220), "YOUTH STUDIO")

-- Small corner kiosks help transitions between districts feel intentional.
lowRise(infill, "CornerBakery", Vector3.new(-145, 0, 18), Vector3.new(38, 18, 28), Color3.fromRGB(224, 199, 174), "BAKERY")
lowRise(infill, "CornerTech", Vector3.new(145, 0, 18), Vector3.new(38, 18, 28), Color3.fromRGB(197, 207, 215), "TECH")

-- Planters and trees frame the new blocks without overfilling mobile render distance.
for _, pos in ipairs({
    Vector3.new(-151, 1.5, 107), Vector3.new(-151, 1.5, 157),
    Vector3.new(151, 1.5, 111), Vector3.new(151, 1.5, 161),
    Vector3.new(-197, 1.5, 84), Vector3.new(197, 1.5, 84)
}) do
    tree(landscaping, pos, 0.72)
end

for _, pos in ipairs({
    Vector3.new(-151, 1.5, 92), Vector3.new(-151, 1.5, 142),
    Vector3.new(151, 1.5, 96), Vector3.new(151, 1.5, 146)
}) do
    planter(infill, pos)
end

-- =========================================================
-- DOWNTOWN BACK ALLEY + SERVICE DETAIL
-- =========================================================
local downtown = districts:FindFirstChild("Downtown")
if downtown then
    local alley = Instance.new("Model")
    alley.Name = "V04_DowntownBackAlley"
    alley.Parent = downtown

    part(alley, "AlleySurface", Vector3.new(220, 0.5, 18), CFrame.new(0, 1.15, -88), C.asphalt2, Enum.Material.Asphalt)
    part(alley, "ServiceWalk", Vector3.new(220, 0.55, 6), CFrame.new(0, 1.2, -100), C.sidewalk, Enum.Material.Concrete)

    for _, x in ipairs({-90, -45, 0, 45, 90}) do
        part(alley, "ServiceDoor", Vector3.new(7, 9, 0.6), CFrame.new(x, 5.8, -76.4), C.dark, Enum.Material.Metal)
        part(alley, "LoadingPad", Vector3.new(20, 0.6, 9), CFrame.new(x, 1.2, -83), C.concrete, Enum.Material.Concrete)
    end

    for _, x in ipairs({-72, 72}) do
        part(alley, "Dumpster", Vector3.new(8, 5, 5), CFrame.new(x, 3.8, -94), Color3.fromRGB(70, 95, 82), Enum.Material.Metal)
        part(alley, "DumpsterLid", Vector3.new(8.4, 0.5, 5.4), CFrame.new(x, 6.5, -94), C.dark, Enum.Material.Metal)
    end

    lamp(alley, Vector3.new(-110, 1.5, -96))
    lamp(alley, Vector3.new(110, 1.5, -96))
end

-- =========================================================
-- PARKING + PARKED VEHICLES
-- =========================================================
local parking = Instance.new("Model")
parking.Name = "ParkingAndVehicles"
parking.Parent = layer

parkingLot(parking, "WestDowntownParking", Vector3.new(-118, 0, -32), Vector3.new(62, 1, 44))
parkingLot(parking, "EastDowntownParking", Vector3.new(118, 0, -32), Vector3.new(62, 1, 44))
parkingLot(parking, "SchoolVisitorParking", Vector3.new(112, 0, 252), Vector3.new(74, 1, 34))

local carColors = {
    Color3.fromRGB(69, 107, 149),
    Color3.fromRGB(185, 76, 67),
    Color3.fromRGB(213, 206, 190),
    Color3.fromRGB(83, 128, 104),
    Color3.fromRGB(108, 92, 130),
    Color3.fromRGB(204, 157, 64),
}

local carSpecs = {
    {Vector3.new(-133, 1.5, -32), 90},
    {Vector3.new(-103, 1.5, -32), 90},
    {Vector3.new(103, 1.5, -32), -90},
    {Vector3.new(133, 1.5, -32), -90},
    {Vector3.new(91, 1.5, 252), 0},
    {Vector3.new(121, 1.5, 252), 0},
}

for i, spec in ipairs(carSpecs) do
    parkedCar(parking, "ParkedCar_" .. i, spec[1], spec[2], carColors[((i - 1) % #carColors) + 1])
end

-- A compact school bus silhouette parked near the existing bus stop.
local bus = Instance.new("Model")
bus.Name = "SchoolBusParked"
bus:SetAttribute("ASC_Prop", "PARKED_SCHOOL_BUS")
bus.Parent = parking
local bcf = CFrame.new(-72, 2, 168) * CFrame.Angles(0, math.rad(90), 0)
part(bus, "BusBody", Vector3.new(11, 8, 30), bcf * CFrame.new(0, 4.8, 0), C.yellow, Enum.Material.SmoothPlastic)
part(bus, "BusRoof", Vector3.new(11.3, 1.2, 30.5), bcf * CFrame.new(0, 9.3, 0), C.white, Enum.Material.Metal)
for _, z in ipairs({-10, -3, 4, 11}) do
    window(bus, "BusWindowL", Vector3.new(0.4, 3, 4.6), bcf * CFrame.new(-5.7, 6.4, z))
    window(bus, "BusWindowR", Vector3.new(0.4, 3, 4.6), bcf * CFrame.new(5.7, 6.4, z))
end
for _, z in ipairs({-10, 10}) do
    for _, x in ipairs({-5.8, 5.8}) do
        local wheel = part(bus, "BusWheel", Vector3.new(2.8, 2.8, 1.4), bcf * CFrame.new(x, 2.4, z) * CFrame.Angles(0, 0, math.rad(90)), C.dark, Enum.Material.Rubber)
        wheel.Shape = Enum.PartType.Cylinder
    end
end

-- =========================================================
-- STREET FURNITURE RHYTHM
-- =========================================================
local props = Instance.new("Model")
props.Name = "StreetFurnitureV04"
props.Parent = furniture

for _, pos in ipairs({
    Vector3.new(-151, 1.5, 64), Vector3.new(-151, 1.5, 132),
    Vector3.new(151, 1.5, 64), Vector3.new(151, 1.5, 132),
    Vector3.new(-108, 1.5, 40), Vector3.new(108, 1.5, 40)
}) do
    lamp(props, pos)
end

for _, pos in ipairs({
    Vector3.new(-151, 1.5, 118), Vector3.new(151, 1.5, 118),
    Vector3.new(-118, 1.5, -58), Vector3.new(118, 1.5, -58)
}) do
    planter(props, pos)
end

-- Fire hydrants / bins / bollards as cheap silhouette detail.
for _, pos in ipairs({Vector3.new(-36, 1.5, 61), Vector3.new(36, 1.5, 131), Vector3.new(-138, 1.5, 23), Vector3.new(138, 1.5, 23)}) do
    part(props, "Hydrant", Vector3.new(2, 3, 2), CFrame.new(pos + Vector3.new(0, 1.5, 0)), C.red, Enum.Material.Metal)
end

for _, pos in ipairs({Vector3.new(-103, 1.5, -57), Vector3.new(103, 1.5, -57), Vector3.new(-164, 1.5, 84), Vector3.new(164, 1.5, 84)}) do
    part(props, "StreetBin", Vector3.new(3, 4.5, 3), CFrame.new(pos + Vector3.new(0, 2.25, 0)), C.dark, Enum.Material.Metal)
end

root:SetAttribute("ASC_StreetDensityPass", "0.4-street-density-pass-1")
Workspace:SetAttribute("ASC_StreetDensityPass", "0.4-street-density-pass-1")
print("[AFTER SCHOOL CITY] Street Density Pass v0.4 initialized")
