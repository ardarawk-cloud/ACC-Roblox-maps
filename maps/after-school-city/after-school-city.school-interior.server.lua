-- AFTER SCHOOL CITY — School Interior V1 v0.7.0
-- Converts the school massing into an accessible, mobile-budgeted interior while preserving the V0.6 exterior envelope.
-- No activities, economy, persistence, clubs authority or monetization is introduced here.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC SchoolInterior] AfterSchoolCity root missing")
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
    warn("[ASC SchoolInterior] completion attribute timeout: " .. name)
    return false
end

if not waitForWorkspaceAttribute("ASC_PremiumExteriorPass", 45) then
    return
end

local districts = root:WaitForChild("Districts", 10)
local school = districts and districts:WaitForChild("SchoolDistrict", 10)
if not school then
    warn("[ASC SchoolInterior] SchoolDistrict missing")
    return
end

if school:FindFirstChild("V070_SchoolInterior") then
    return
end

local layer = Instance.new("Model")
layer.Name = "V070_SchoolInterior"
layer:SetAttribute("ASC_Layer", "SCHOOL_INTERIOR")
layer:SetAttribute("ASC_Version", "0.7.0-school-interior-1")
layer.Parent = school

local INTERIOR_PART_BUDGET = 240
local INTERIOR_LIGHT_BUDGET = 10
local INTERIOR_LIGHT_MAX_BRIGHTNESS = 0.22
local INTERIOR_LIGHT_MAX_RANGE = 10

local C = {
    cream = Color3.fromRGB(226, 218, 202),
    white = Color3.fromRGB(238, 240, 242),
    pale = Color3.fromRGB(219, 224, 228),
    navy = Color3.fromRGB(28, 40, 60),
    blue = Color3.fromRGB(53, 95, 145),
    gold = Color3.fromRGB(224, 164, 60),
    charcoal = Color3.fromRGB(45, 49, 56),
    metal = Color3.fromRGB(76, 82, 91),
    wood = Color3.fromRGB(141, 105, 75),
    green = Color3.fromRGB(66, 116, 69),
    teal = Color3.fromRGB(56, 126, 119),
    purple = Color3.fromRGB(122, 91, 147),
    red = Color3.fromRGB(180, 72, 65),
    warm = Color3.fromRGB(245, 214, 164),
    tile = Color3.fromRGB(202, 207, 211),
}

local partCount = 0
local lightCount = 0

local function part(parent, name, size, cf, color, material, canCollide)
    if partCount >= INTERIOR_PART_BUDGET then
        warn("[ASC SchoolInterior] part budget reached")
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
    p.CanCollide = canCollide ~= false
    p.CanTouch = false
    p.Parent = parent
    partCount += 1
    return p
end

local function addPointLight(parent, brightness, range, color)
    if not parent or lightCount >= INTERIOR_LIGHT_BUDGET then
        return nil
    end
    local light = Instance.new("PointLight")
    light.Brightness = math.min(brightness or 0.18, INTERIOR_LIGHT_MAX_BRIGHTNESS)
    light.Range = math.min(range or 8, INTERIOR_LIGHT_MAX_RANGE)
    light.Color = color or C.warm
    light.Shadows = false
    light.Parent = parent
    lightCount += 1
    return light
end

local function surfaceText(plate, text, face, textColor)
    if not plate then return end
    local gui = Instance.new("SurfaceGui")
    gui.Name = "InteriorSignage"
    gui.Face = face or Enum.NormalId.Front
    gui.AlwaysOnTop = false
    gui.LightInfluence = 0.25
    gui.PixelsPerStud = 32
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

local function sign(parent, text, size, cf, color, face)
    local plate = part(parent, "RoomSign", size, cf, color or C.navy, Enum.Material.Metal, false)
    surfaceText(plate, text, face or Enum.NormalId.Front, C.white)
    return plate
end

local function markOriginalMassAsInteriorVoid(mass)
    if not mass or not mass:IsA("BasePart") then
        return false
    end
    mass.Transparency = 1
    mass.CanCollide = false
    mass.CanTouch = false
    mass.CastShadow = false
    mass:SetAttribute("ASC_InteriorVoid", true)
    mass:SetAttribute("ASC_ExteriorEnvelopePreserved", true)
    return true
end

local function shellFloor(parent, mass, name)
    local size = mass.Size
    return part(parent, name .. "Floor", Vector3.new(size.X - 1.2, 0.8, size.Z - 1.2), mass.CFrame * CFrame.new(0, -size.Y / 2 + 0.5, 0), C.tile, Enum.Material.Concrete, true)
end

local function fullBackWall(parent, mass, name, color)
    local size = mass.Size
    return part(parent, name .. "BackWall", Vector3.new(size.X, size.Y, 0.9), mass.CFrame * CFrame.new(0, 0, size.Z / 2 - 0.45), color, Enum.Material.Concrete, true)
end

local function splitSideWall(parent, mass, name, xSign, color, gapDepth)
    local size = mass.Size
    local gap = gapDepth or 12
    local segmentDepth = (size.Z - gap) / 2
    local zOffset = gap / 2 + segmentDepth / 2
    for _, z in ipairs({-zOffset, zOffset}) do
        part(parent, name .. "SideWall", Vector3.new(0.9, size.Y, segmentDepth), mass.CFrame * CFrame.new(xSign * (size.X / 2 - 0.45), 0, z), color, Enum.Material.Concrete, true)
    end
end

local function fullSideWall(parent, mass, name, xSign, color)
    local size = mass.Size
    return part(parent, name .. "SideWall", Vector3.new(0.9, size.Y, size.Z), mass.CFrame * CFrame.new(xSign * (size.X / 2 - 0.45), 0, 0), color, Enum.Material.Concrete, true)
end

local function mainFrontWall(parent, mass)
    local size = mass.Size
    local frontZ = -size.Z / 2 + 0.45
    local bottomY = -size.Y / 2

    -- Lower wall preserves a clear 24-stud central entrance.
    part(parent, "MainFrontLowerL", Vector3.new((size.X - 24) / 2, 10, 0.9), mass.CFrame * CFrame.new(-(size.X + 24) / 4, bottomY + 5, frontZ), C.cream, Enum.Material.Concrete, true)
    part(parent, "MainFrontLowerR", Vector3.new((size.X - 24) / 2, 10, 0.9), mass.CFrame * CFrame.new((size.X + 24) / 4, bottomY + 5, frontZ), C.cream, Enum.Material.Concrete, true)

    -- Horizontal bands preserve the existing lower and upper window apertures.
    part(parent, "MainFrontBandLow", Vector3.new(size.X, 1.5, 0.9), mass.CFrame * CFrame.new(0, -4.1, frontZ), C.cream, Enum.Material.Concrete, true)
    part(parent, "MainFrontBandMid", Vector3.new(size.X, 1.5, 0.9), mass.CFrame * CFrame.new(0, 5.0, frontZ), C.cream, Enum.Material.Concrete, true)
    part(parent, "MainFrontBandTop", Vector3.new(size.X, 2.4, 0.9), mass.CFrame * CFrame.new(0, 15.3, frontZ), C.cream, Enum.Material.Concrete, true)

    -- Vertical infill avoids covering the existing windows at x ±45/±29.
    local strips = {
        {-53.2, 3.2}, {-37.0, 4.0}, {0, 46.0}, {37.0, 4.0}, {53.2, 3.2},
    }
    for _, strip in ipairs(strips) do
        part(parent, "MainFrontPier", Vector3.new(strip[2], 18.0, 0.9), mass.CFrame * CFrame.new(strip[1], 5.8, frontZ), C.cream, Enum.Material.Concrete, true)
    end
end

local function wingFrontWall(parent, mass, name)
    local size = mass.Size
    local frontZ = -size.Z / 2 + 0.45
    local bottomY = -size.Y / 2
    part(parent, name .. "FrontLower", Vector3.new(size.X, 7.5, 0.9), mass.CFrame * CFrame.new(0, bottomY + 3.75, frontZ), C.pale, Enum.Material.Concrete, true)
    part(parent, name .. "FrontTop", Vector3.new(size.X, 8.3, 0.9), mass.CFrame * CFrame.new(0, 8.35, frontZ), C.pale, Enum.Material.Concrete, true)
    for _, strip in ipairs({{-22.0, 3.0}, {-7.0, 4.0}, {7.0, 4.0}, {22.0, 3.0}}) do
        part(parent, name .. "FrontPier", Vector3.new(strip[2], 8.2, 0.9), mass.CFrame * CFrame.new(strip[1], -0.2, frontZ), C.pale, Enum.Material.Concrete, true)
    end
end

local mainMass = school:FindFirstChild("MainBuilding")
local leftMass = school:FindFirstChild("LeftWing")
local rightMass = school:FindFirstChild("RightWing")
if not (mainMass and leftMass and rightMass and mainMass:IsA("BasePart") and leftMass:IsA("BasePart") and rightMass:IsA("BasePart")) then
    warn("[ASC SchoolInterior] required school massing missing")
    layer:Destroy()
    return
end

local shell = Instance.new("Model")
shell.Name = "InteriorShell"
shell.Parent = layer

-- Preserve the V0.6 exterior footprint while opening the original solid blocks for traversal.
markOriginalMassAsInteriorVoid(mainMass)
markOriginalMassAsInteriorVoid(leftMass)
markOriginalMassAsInteriorVoid(rightMass)

shellFloor(shell, mainMass, "Main")
fullBackWall(shell, mainMass, "Main", C.cream)
splitSideWall(shell, mainMass, "MainLeft", -1, C.cream, 13)
splitSideWall(shell, mainMass, "MainRight", 1, C.cream, 13)
mainFrontWall(shell, mainMass)

shellFloor(shell, leftMass, "LeftWing")
fullBackWall(shell, leftMass, "LeftWing", C.pale)
fullSideWall(shell, leftMass, "LeftWingOuter", -1, C.pale)
splitSideWall(shell, leftMass, "LeftWingInner", 1, C.pale, 13)
wingFrontWall(shell, leftMass, "LeftWing")

shellFloor(shell, rightMass, "RightWing")
fullBackWall(shell, rightMass, "RightWing", C.pale)
fullSideWall(shell, rightMass, "RightWingOuter", 1, C.pale)
splitSideWall(shell, rightMass, "RightWingInner", -1, C.pale, 13)
wingFrontWall(shell, rightMass, "RightWing")

-- Make the existing glass entrance read as two side panels with a real central walk-through.
for name, x in pairs({EntranceGlassL = -7.5, EntranceGlassR = 7.5}) do
    local glass = school:FindFirstChild(name)
    if glass and glass:IsA("BasePart") then
        glass.Size = Vector3.new(6.5, glass.Size.Y, glass.Size.Z)
        glass.CFrame = CFrame.new(x, glass.Position.Y, glass.Position.Z)
        glass.CanCollide = false
        glass:SetAttribute("ASC_EntranceSidePanel", true)
    end
end

-- =========================================================
-- MAIN BUILDING — LOBBY, HALL, LOCKERS, CLASSROOMS
-- All interior placement is derived from current mass CFrames so v0.4.7 orientation remains authoritative.
-- =========================================================
local mainInterior = Instance.new("Model")
mainInterior.Name = "MainBuildingInterior"
mainInterior.Parent = layer

local mainCF = mainMass.CFrame
local mainBottom = -mainMass.Size.Y / 2 + 0.9

-- Arrival lobby and longitudinal circulation spine.
part(mainInterior, "LobbyFloorAccent", Vector3.new(22, 0.08, 10), mainCF * CFrame.new(0, mainBottom + 0.45, -16), C.gold, Enum.Material.SmoothPlastic, false)
part(mainInterior, "HallFloorAccent", Vector3.new(13, 0.08, 29), mainCF * CFrame.new(0, mainBottom + 0.45, 4), C.blue, Enum.Material.SmoothPlastic, false)
sign(mainInterior, "WELCOME / MAIN HALL", Vector3.new(18, 3.2, 0.4), mainCF * CFrame.new(0, -8.0, -21.8), C.navy, Enum.NormalId.Front)

-- Classroom separation walls leave the central hall open.
for _, x in ipairs({-8.2, 8.2}) do
    for _, z in ipairs({-14.5, 0.5, 15.0}) do
        part(mainInterior, "HallPartition", Vector3.new(0.7, 12, 9.5), mainCF * CFrame.new(x, -10.0, z), C.white, Enum.Material.Concrete, true)
    end
end

-- Two broad classrooms, one on each side of the hallway.
local classrooms = {
    {name = "CLASSROOM A", x = -31.5, accent = C.blue},
    {name = "CLASSROOM B", x = 31.5, accent = C.teal},
}
for _, room in ipairs(classrooms) do
    local roomModel = Instance.new("Model")
    roomModel.Name = room.name:gsub(" ", "_")
    roomModel.Parent = mainInterior
    sign(roomModel, room.name, Vector3.new(9.5, 2.4, 0.35), mainCF * CFrame.new(room.x > 0 and 8.65 or -8.65, -8.0, -7.5), room.accent, room.x > 0 and Enum.NormalId.Left or Enum.NormalId.Right)
    part(roomModel, "Board", Vector3.new(17, 5, 0.4), mainCF * CFrame.new(room.x, -8.2, 20.7), C.charcoal, Enum.Material.Slate, false)
    part(roomModel, "TeacherDesk", Vector3.new(9, 1.1, 3.2), mainCF * CFrame.new(room.x, -13.0, 15.5), C.wood, Enum.Material.Wood, true)
    for row = 0, 1 do
        for col = -1, 1 do
            local dx = col * 9
            local dz = -6 + row * 10
            part(roomModel, "StudentDesk", Vector3.new(6.2, 1.0, 3.0), mainCF * CFrame.new(room.x + dx, -13.0, dz), C.wood, Enum.Material.Wood, true)
            part(roomModel, "StudentSeat", Vector3.new(4.2, 0.8, 2.0), mainCF * CFrame.new(room.x + dx, -13.6, dz - 3.0), room.accent, Enum.Material.SmoothPlastic, true)
        end
    end
end

-- Hall lockers: readable identity without excessive per-door geometry.
local lockers = Instance.new("Model")
lockers.Name = "HallLockers"
lockers.Parent = mainInterior
for i = 0, 7 do
    local z = -12 + i * 3.4
    local side = (i % 2 == 0) and -1 or 1
    local locker = part(lockers, "LockerBank", Vector3.new(1.4, 6.2, 2.7), mainCF * CFrame.new(side * 6.9, -13.2, z), (i % 2 == 0) and C.blue or C.gold, Enum.Material.Metal, true)
    if locker then
        locker:SetAttribute("ASC_Prop", "LOCKER")
    end
end

-- =========================================================
-- LEFT WING — LIBRARY + CANTEEN
-- =========================================================
local leftInterior = Instance.new("Model")
leftInterior.Name = "LeftWingInterior"
leftInterior.Parent = layer
local leftCF = leftMass.CFrame

part(leftInterior, "LibraryCanteenDividerL", Vector3.new(18, 11, 0.7), leftCF * CFrame.new(-14, -6.0, 0), C.white, Enum.Material.Concrete, true)
part(leftInterior, "LibraryCanteenDividerR", Vector3.new(18, 11, 0.7), leftCF * CFrame.new(14, -6.0, 0), C.white, Enum.Material.Concrete, true)
sign(leftInterior, "LIBRARY", Vector3.new(12, 2.8, 0.4), leftCF * CFrame.new(0, -4.0, -10.5), C.teal, Enum.NormalId.Front)
sign(leftInterior, "CANTEEN", Vector3.new(12, 2.8, 0.4), leftCF * CFrame.new(0, -4.0, 10.5), C.gold, Enum.NormalId.Back)

for _, x in ipairs({-15, -5, 5, 15}) do
    part(leftInterior, "LibraryShelf", Vector3.new(2.2, 7.5, 10), leftCF * CFrame.new(x, -8.3, -16.5), C.wood, Enum.Material.Wood, true)
end
part(leftInterior, "LibraryStudyTable", Vector3.new(12, 1.0, 5), leftCF * CFrame.new(0, -10.2, -7.5), C.wood, Enum.Material.Wood, true)
for _, x in ipairs({-7, 7}) do
    part(leftInterior, "LibrarySeat", Vector3.new(4, 0.8, 2.2), leftCF * CFrame.new(x, -10.8, -7.5), C.teal, Enum.Material.SmoothPlastic, true)
end

part(leftInterior, "CanteenCounter", Vector3.new(28, 4.0, 3.5), leftCF * CFrame.new(0, -9.8, 21.5), C.wood, Enum.Material.Wood, true)
part(leftInterior, "CanteenCounterTop", Vector3.new(30, 0.5, 4.2), leftCF * CFrame.new(0, -7.55, 21.5), C.charcoal, Enum.Material.Slate, true)
for _, x in ipairs({-12, 0, 12}) do
    part(leftInterior, "CanteenTable", Vector3.new(7, 0.9, 4), leftCF * CFrame.new(x, -10.2, 9.0), C.wood, Enum.Material.Wood, true)
    part(leftInterior, "CanteenBench", Vector3.new(7, 0.7, 1.7), leftCF * CFrame.new(x, -10.7, 5.8), C.gold, Enum.Material.SmoothPlastic, true)
end

-- =========================================================
-- RIGHT WING — TEACHER/ADMIN + CLUB ROOMS + TOILETS
-- =========================================================
local rightInterior = Instance.new("Model")
rightInterior.Name = "RightWingInterior"
rightInterior.Parent = layer
local rightCF = rightMass.CFrame

part(rightInterior, "AdminClubDividerL", Vector3.new(18, 11, 0.7), rightCF * CFrame.new(-14, -6.0, 0), C.white, Enum.Material.Concrete, true)
part(rightInterior, "AdminClubDividerR", Vector3.new(18, 11, 0.7), rightCF * CFrame.new(14, -6.0, 0), C.white, Enum.Material.Concrete, true)
sign(rightInterior, "TEACHER / ADMIN", Vector3.new(15, 2.8, 0.4), rightCF * CFrame.new(0, -4.0, -10.5), C.blue, Enum.NormalId.Front)
sign(rightInterior, "CLUB ROOMS", Vector3.new(15, 2.8, 0.4), rightCF * CFrame.new(0, -4.0, 10.5), C.purple, Enum.NormalId.Back)

part(rightInterior, "AdminDesk", Vector3.new(11, 1.0, 4), rightCF * CFrame.new(-9, -10.2, -15), C.wood, Enum.Material.Wood, true)
part(rightInterior, "TeacherTable", Vector3.new(11, 1.0, 4), rightCF * CFrame.new(9, -10.2, -15), C.wood, Enum.Material.Wood, true)
part(rightInterior, "AdminStorage", Vector3.new(4, 8, 10), rightCF * CFrame.new(19, -8.0, -18), C.metal, Enum.Material.Metal, true)

-- Two club bays, kept as social spaces only; EnableClubs remains false.
for index, clubInfo in ipairs({{"MUSIC CLUB", -11, C.blue}, {"ART CLUB", 11, C.purple}}) do
    local text, x, accent = clubInfo[1], clubInfo[2], clubInfo[3]
    part(rightInterior, "ClubZone", Vector3.new(18, 0.08, 15), rightCF * CFrame.new(x, -11.55, 11.5), accent, Enum.Material.SmoothPlastic, false)
    sign(rightInterior, text, Vector3.new(10, 2.3, 0.35), rightCF * CFrame.new(x, -5.0, 20.0), accent, Enum.NormalId.Back)
    part(rightInterior, "ClubTable", Vector3.new(8, 1.0, 4), rightCF * CFrame.new(x, -10.2, 11.5), C.wood, Enum.Material.Wood, true)
end

-- Compact toilet bays at the rear outer edge.
local toilets = Instance.new("Model")
toilets.Name = "SchoolToilets"
toilets.Parent = rightInterior
for index, x in ipairs({-15, 15}) do
    local label = index == 1 and "TOILET A" or "TOILET B"
    part(toilets, "ToiletDivider", Vector3.new(0.7, 9, 11), rightCF * CFrame.new(x > 0 and 5 or -5, -7.0, 21), C.white, Enum.Material.Concrete, true)
    part(toilets, "SinkCounter", Vector3.new(7, 2.2, 2.4), rightCF * CFrame.new(x, -9.4, 23.5), C.tile, Enum.Material.Marble, true)
    sign(toilets, label, Vector3.new(7.5, 2.0, 0.3), rightCF * CFrame.new(x, -5.1, 15.2), C.navy, Enum.NormalId.Front)
end

-- =========================================================
-- LIGHTING — REUSE EXTERIOR GRADE; LOW-COST INTERIOR FIXTURES
-- =========================================================
local lightLayer = Instance.new("Model")
lightLayer.Name = "InteriorLighting"
lightLayer.Parent = layer

local lightPoints = {
    {mainCF, Vector3.new(0, 13.8, -12)}, {mainCF, Vector3.new(0, 13.8, 8)},
    {mainCF, Vector3.new(-31, 13.8, 0)}, {mainCF, Vector3.new(31, 13.8, 0)},
    {leftCF, Vector3.new(0, 9.5, -14)}, {leftCF, Vector3.new(0, 9.5, 14)},
    {rightCF, Vector3.new(0, 9.5, -14)}, {rightCF, Vector3.new(0, 9.5, 14)},
}
for _, item in ipairs(lightPoints) do
    local fixture = part(lightLayer, "CeilingLight", Vector3.new(5.5, 0.35, 1.6), item[1] * CFrame.new(item[2]), C.warm, Enum.Material.Neon, false)
    if fixture then
        fixture.CastShadow = false
        addPointLight(fixture, 0.18, 8.5, C.warm)
    end
end

-- Navigation markers stay physical and compact; no screen-space billboards.
sign(mainInterior, "← LIBRARY / CANTEEN", Vector3.new(16, 2.4, 0.35), mainCF * CFrame.new(-7.7, -7.2, 5.5), C.teal, Enum.NormalId.Right)
sign(mainInterior, "ADMIN / CLUBS →", Vector3.new(16, 2.4, 0.35), mainCF * CFrame.new(7.7, -7.2, 5.5), C.purple, Enum.NormalId.Left)

school:SetAttribute("ASC_InteriorReady", true)
school:SetAttribute("ASC_SchoolInteriorPass", "0.7.0-school-interior-1")
school:SetAttribute("ASC_SchoolInteriorAccessible", true)
school:SetAttribute("ASC_SchoolInteriorRooms", 10)
school:SetAttribute("ASC_SchoolInteriorPartCount", partCount)
school:SetAttribute("ASC_SchoolInteriorLightCount", lightCount)
school:SetAttribute("ASC_SchoolExteriorEnvelopePreserved", true)
root:SetAttribute("ASC_SchoolInteriorV1", true)
Workspace:SetAttribute("ASC_SchoolInteriorPass", "0.7.0-school-interior-1")

print(string.format("[AFTER SCHOOL CITY] School Interior v0.7.0 initialized; parts=%d lights=%d", partCount, lightCount))
