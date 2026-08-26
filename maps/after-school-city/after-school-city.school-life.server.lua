-- AFTER SCHOOL CITY — School Life Pass v0.3
-- Adds a denser, playable-looking campus layer without replacing the v0.2 foundation.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC SchoolLife] AfterSchoolCity root missing")
    return
end

local districts = root:WaitForChild("Districts", 10)
local school = districts and districts:WaitForChild("SchoolDistrict", 10)
if not school then
    warn("[ASC SchoolLife] SchoolDistrict missing")
    return
end

if school:FindFirstChild("V03_SchoolLife") then
    return
end

local layer = Instance.new("Model")
layer.Name = "V03_SchoolLife"
layer:SetAttribute("ASC_Layer", "SCHOOL_LIFE")
layer:SetAttribute("ASC_Version", "0.3-city-life-pass-1")
layer.Parent = school

local C = {
    navy = Color3.fromRGB(34, 48, 72),
    blue = Color3.fromRGB(59, 102, 151),
    gold = Color3.fromRGB(242, 180, 65),
    white = Color3.fromRGB(240, 242, 245),
    concrete = Color3.fromRGB(198, 202, 208),
    dark = Color3.fromRGB(37, 41, 48),
    metal = Color3.fromRGB(83, 88, 96),
    wood = Color3.fromRGB(139, 103, 72),
    green = Color3.fromRGB(72, 127, 75),
    glass = Color3.fromRGB(92, 142, 172),
    lockerA = Color3.fromRGB(80, 119, 161),
    lockerB = Color3.fromRGB(214, 170, 75),
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

local function sign(parent, text, size, cf, color)
    local plate = part(parent, "Sign", size, cf, color or C.navy, Enum.Material.SmoothPlastic)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.AlwaysOnTop = false
    gui.PixelsPerStud = 32
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.Parent = plate
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = C.white
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextWrapped = true
    label.Parent = gui
    return plate
end

local function planter(parent, pos)
    part(parent, "Planter", Vector3.new(8, 2, 4), CFrame.new(pos + Vector3.new(0, 1, 0)), Color3.fromRGB(115, 103, 86), Enum.Material.Concrete)
    local bush = part(parent, "Bush", Vector3.new(6.5, 3.5, 3), CFrame.new(pos + Vector3.new(0, 3.2, 0)), C.green, Enum.Material.Grass)
    bush.Shape = Enum.PartType.Ball
    bush.CanCollide = false
end

local function tableSet(parent, pos)
    part(parent, "TableTop", Vector3.new(7, 0.7, 4), CFrame.new(pos + Vector3.new(0, 3.2, 0)), C.wood, Enum.Material.Wood)
    part(parent, "TableLeg", Vector3.new(0.8, 3, 0.8), CFrame.new(pos + Vector3.new(0, 1.5, 0)), C.metal, Enum.Material.Metal)
    part(parent, "BenchA", Vector3.new(7, 0.6, 1.5), CFrame.new(pos + Vector3.new(0, 1.8, -3)), C.wood, Enum.Material.Wood)
    part(parent, "BenchB", Vector3.new(7, 0.6, 1.5), CFrame.new(pos + Vector3.new(0, 1.8, 3)), C.wood, Enum.Material.Wood)
end

-- Front campus gate: compact and readable, no screen-blocking billboard.
part(layer, "GatePostL", Vector3.new(3, 13, 3), CFrame.new(-19, 7.5, 272), C.navy, Enum.Material.Concrete)
part(layer, "GatePostR", Vector3.new(3, 13, 3), CFrame.new(19, 7.5, 272), C.navy, Enum.Material.Concrete)
part(layer, "GateBeam", Vector3.new(41, 3, 3), CFrame.new(0, 13, 272), C.navy, Enum.Material.Concrete)
sign(layer, "AFTER SCHOOL ACADEMY", Vector3.new(30, 5.2, 0.8), CFrame.new(0, 12.8, 270.3), C.blue)

-- Courtyard planters and seating create a stronger arrival sequence.
for _, pos in ipairs({
    Vector3.new(-30, 1.5, 268), Vector3.new(30, 1.5, 268),
    Vector3.new(-30, 1.5, 246), Vector3.new(30, 1.5, 246)
}) do
    planter(layer, pos)
end

for _, pos in ipairs({Vector3.new(-48, 1.5, 248), Vector3.new(48, 1.5, 248)}) do
    tableSet(layer, pos)
end

-- Locker breezeway on the west side of the front plaza.
local lockers = Instance.new("Model")
lockers.Name = "LockerBreezeway"
lockers.Parent = layer
part(lockers, "Floor", Vector3.new(42, 0.7, 15), CFrame.new(-77, 1.4, 252), C.concrete, Enum.Material.Concrete)
part(lockers, "Roof", Vector3.new(42, 1, 15), CFrame.new(-77, 11, 252), C.navy, Enum.Material.Metal)
part(lockers, "PostL", Vector3.new(1, 9, 1), CFrame.new(-96, 6, 246), C.metal, Enum.Material.Metal)
part(lockers, "PostR", Vector3.new(1, 9, 1), CFrame.new(-58, 6, 246), C.metal, Enum.Material.Metal)
for i = 0, 7 do
    local x = -94 + i * 5
    local color = (i % 2 == 0) and C.lockerA or C.lockerB
    local locker = part(lockers, "Locker", Vector3.new(4.2, 7.5, 1.5), CFrame.new(x, 5.1, 257.8), color, Enum.Material.Metal)
    local seam = part(lockers, "LockerVent", Vector3.new(2.6, 0.3, 0.15), CFrame.new(x, 6.4, 257), C.dark, Enum.Material.Metal)
    seam.CanCollide = false
    locker:SetAttribute("ASC_Prop", "LOCKER")
end
sign(lockers, "LOCKERS", Vector3.new(18, 3.5, 0.6), CFrame.new(-77, 9, 244.2), C.blue)

-- Student canteen pavilion: open-sided so it feels usable immediately.
local canteen = Instance.new("Model")
canteen.Name = "StudentCanteen"
canteen.Parent = layer
part(canteen, "Floor", Vector3.new(54, 0.8, 30), CFrame.new(-78, 1.4, 222), Color3.fromRGB(210, 205, 193), Enum.Material.Concrete)
part(canteen, "Roof", Vector3.new(56, 1.2, 32), CFrame.new(-78, 13, 222), C.navy, Enum.Material.Metal)
for _, x in ipairs({-103, -53}) do
    for _, z in ipairs({209, 235}) do
        part(canteen, "Post", Vector3.new(1.1, 11, 1.1), CFrame.new(x, 7, z), C.metal, Enum.Material.Metal)
    end
end
part(canteen, "Counter", Vector3.new(28, 4, 4), CFrame.new(-78, 3.5, 211), C.wood, Enum.Material.Wood)
part(canteen, "CounterTop", Vector3.new(30, 0.6, 5), CFrame.new(-78, 5.7, 211), C.dark, Enum.Material.Slate)
sign(canteen, "STUDENT CANTEEN", Vector3.new(28, 4.5, 0.7), CFrame.new(-78, 10, 205.8), C.blue)
for _, x in ipairs({-91, -65}) do
    tableSet(canteen, Vector3.new(x, 1.5, 227))
end

-- Club hub on the east side: visual home for future music/art/gaming clubs.
local club = Instance.new("Model")
club.Name = "ClubHub"
club.Parent = layer
part(club, "Floor", Vector3.new(54, 0.8, 30), CFrame.new(78, 1.4, 222), Color3.fromRGB(206, 210, 214), Enum.Material.Concrete)
part(club, "BackWall", Vector3.new(54, 13, 1.2), CFrame.new(78, 7.5, 208), C.white, Enum.Material.Concrete)
part(club, "SideWallL", Vector3.new(1.2, 13, 28), CFrame.new(51.5, 7.5, 222), C.white, Enum.Material.Concrete)
part(club, "SideWallR", Vector3.new(1.2, 13, 28), CFrame.new(104.5, 7.5, 222), C.white, Enum.Material.Concrete)
part(club, "Roof", Vector3.new(56, 1.2, 30), CFrame.new(78, 14.3, 222), C.navy, Enum.Material.Metal)
sign(club, "CLUB HUB", Vector3.new(28, 4.5, 0.7), CFrame.new(78, 11, 207.2), C.blue)

-- Three visual club bays; interaction comes later.
local clubNames = {"MUSIC", "ART", "GAMING"}
for i, name in ipairs(clubNames) do
    local x = 59 + (i - 1) * 19
    part(club, name .. "Bay", Vector3.new(16, 6, 6), CFrame.new(x, 4.8, 220), (i == 1 and C.gold) or (i == 2 and Color3.fromRGB(142, 107, 157)) or C.blue, Enum.Material.SmoothPlastic)
    sign(club, name, Vector3.new(13, 2.8, 0.5), CFrame.new(x, 7.8, 216.8), C.dark)
end

-- Bike racks near the school/bus approach.
local bikes = Instance.new("Model")
bikes.Name = "BikeParking"
bikes.Parent = layer
part(bikes, "Pad", Vector3.new(38, 0.6, 14), CFrame.new(-82, 1.3, 184), C.concrete, Enum.Material.Concrete)
for i = 0, 5 do
    local x = -95 + i * 5
    part(bikes, "Rack", Vector3.new(0.8, 3.5, 5), CFrame.new(x, 3, 184), C.metal, Enum.Material.Metal)
end
sign(bikes, "BIKE PARKING", Vector3.new(18, 3, 0.6), CFrame.new(-82, 5.5, 177.2), C.blue)

-- Small wayfinding at pedestrian height.
sign(layer, "DOWNTOWN  ↓", Vector3.new(14, 4, 0.7), CFrame.new(28, 5.2, 171), C.navy)
sign(layer, "SPORTS  →", Vector3.new(14, 4, 0.7), CFrame.new(72, 5.2, 188) * CFrame.Angles(0, math.rad(-90), 0), C.navy)

school:SetAttribute("ASC_SchoolLifePass", "0.3")
Workspace:SetAttribute("ASC_SchoolLifePass", "0.3-city-life-pass-1")
print("[AFTER SCHOOL CITY] School Life Pass v0.3 initialized")