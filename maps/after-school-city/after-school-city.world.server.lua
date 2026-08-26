-- AFTER SCHOOL CITY — world scaffold v0.1
-- Standalone namespace: Workspace/AfterSchoolCity
-- Source-only blockout. Do not destroy an existing production root.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "AfterSchoolCity"
local existing = Workspace:FindFirstChild(ROOT_NAME)
if existing then
    Workspace:SetAttribute("ASC_WorldScaffold", "v0.1-preserve")
    Workspace:SetAttribute("ASC_WorldScaffoldMode", "PRESERVE_EXISTING")
    print("[AFTER SCHOOL CITY] Existing root preserved; scaffold skipped")
    return
end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root:SetAttribute("ACC_Project", "after-school-city")
root:SetAttribute("ASC_ScaffoldVersion", "0.1")
root.Parent = Workspace

local districts = Instance.new("Folder")
districts.Name = "Districts"
districts.Parent = root

local roads = Instance.new("Folder")
roads.Name = "RoadsAndPaths"
roads.Parent = root

local landmarks = Instance.new("Folder")
landmarks.Name = "Landmarks"
landmarks.Parent = root

local function part(parent, name, size, cframe, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cframe
    p.Color = color or Color3.fromRGB(120, 120, 120)
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function billboard(parent, text)
    local gui = Instance.new("BillboardGui")
    gui.Name = "BlockoutLabel"
    gui.Size = UDim2.fromOffset(260, 60)
    gui.StudsOffset = Vector3.new(0, 7, 0)
    gui.AlwaysOnTop = true
    gui.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
    label.BackgroundTransparency = 0.15
    label.Text = text
    label.TextColor3 = Color3.fromRGB(245, 247, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
end

local palette = {
    School = Color3.fromRGB(71, 121, 184),
    Downtown = Color3.fromRGB(201, 135, 69),
    SkatePark = Color3.fromRGB(91, 92, 104),
    Park = Color3.fromRGB(77, 142, 91),
    Residential = Color3.fromRGB(156, 111, 160),
    SportsField = Color3.fromRGB(58, 127, 116),
}

local zoneSpecs = {
    {name = "SchoolDistrict", label = "SCHOOL DISTRICT", center = Vector3.new(0, 0, 210), size = Vector3.new(220, 2, 150), color = palette.School},
    {name = "Downtown", label = "DOWNTOWN", center = Vector3.new(0, 0, 0), size = Vector3.new(230, 2, 170), color = palette.Downtown},
    {name = "SkatePark", label = "SKATE PARK", center = Vector3.new(235, 0, 0), size = Vector3.new(150, 2, 150), color = palette.SkatePark},
    {name = "Park", label = "CITY PARK", center = Vector3.new(0, 0, -210), size = Vector3.new(220, 2, 150), color = palette.Park},
    {name = "Residential", label = "RESIDENTIAL", center = Vector3.new(-235, 0, 0), size = Vector3.new(150, 2, 150), color = palette.Residential},
    {name = "SportsField", label = "SPORTS FIELD", center = Vector3.new(235, 0, 210), size = Vector3.new(150, 2, 130), color = palette.SportsField},
}

for _, spec in ipairs(zoneSpecs) do
    local model = Instance.new("Model")
    model.Name = spec.name
    model:SetAttribute("ASC_Blockout", true)
    model:SetAttribute("ASC_DistrictLabel", spec.label)
    model.Parent = districts

    local pad = part(model, "DistrictPad", spec.size, CFrame.new(spec.center), spec.color, Enum.Material.Concrete)
    billboard(pad, spec.label)

    -- Lightweight massing blocks make the district silhouette visible in a first audit.
    if spec.name == "SchoolDistrict" then
        part(model, "SchoolMainMassing", Vector3.new(118, 30, 46), CFrame.new(spec.center + Vector3.new(0, 16, 4)), Color3.fromRGB(227, 232, 238), Enum.Material.Concrete)
        part(model, "SchoolWingLeft", Vector3.new(42, 20, 58), CFrame.new(spec.center + Vector3.new(-72, 11, 6)), Color3.fromRGB(211, 219, 229), Enum.Material.Concrete)
        part(model, "SchoolWingRight", Vector3.new(42, 20, 58), CFrame.new(spec.center + Vector3.new(72, 11, 6)), Color3.fromRGB(211, 219, 229), Enum.Material.Concrete)
    elseif spec.name == "Downtown" then
        for i, x in ipairs({-82, -41, 0, 41, 82}) do
            local h = 22 + (i % 3) * 8
            part(model, "ShopBlock_" .. i, Vector3.new(31, h, 36), CFrame.new(spec.center + Vector3.new(x, h / 2 + 1, -35)), Color3.fromRGB(218, 204, 184), Enum.Material.Brick)
        end
        part(model, "CentralPlaza", Vector3.new(105, 0.6, 58), CFrame.new(spec.center + Vector3.new(0, 1.3, 39)), Color3.fromRGB(206, 205, 198), Enum.Material.Concrete)
    elseif spec.name == "SkatePark" then
        part(model, "SkateDeck", Vector3.new(112, 0.8, 104), CFrame.new(spec.center + Vector3.new(0, 1.4, 0)), Color3.fromRGB(116, 118, 124), Enum.Material.Concrete)
        local rampA = part(model, "RampA", Vector3.new(35, 4, 20), CFrame.new(spec.center + Vector3.new(-31, 3.5, 5)) * CFrame.Angles(math.rad(-8), 0, 0), Color3.fromRGB(66, 69, 76), Enum.Material.Metal)
        rampA.CanCollide = true
        part(model, "GrindBox", Vector3.new(30, 3, 8), CFrame.new(spec.center + Vector3.new(29, 2.8, -16)), Color3.fromRGB(76, 79, 87), Enum.Material.Metal)
    elseif spec.name == "Park" then
        part(model, "LakeBlockout", Vector3.new(86, 0.5, 54), CFrame.new(spec.center + Vector3.new(38, 1.3, 0)), Color3.fromRGB(74, 145, 181), Enum.Material.Glass).Transparency = 0.2
        part(model, "PicnicLawn", Vector3.new(86, 0.6, 68), CFrame.new(spec.center + Vector3.new(-45, 1.3, 0)), Color3.fromRGB(91, 157, 94), Enum.Material.Grass)
    elseif spec.name == "Residential" then
        for i, z in ipairs({-48, 0, 48}) do
            local h = 20 + i * 4
            part(model, "ApartmentBlock_" .. i, Vector3.new(64, h, 34), CFrame.new(spec.center + Vector3.new(0, h / 2 + 1, z)), Color3.fromRGB(221, 214, 225), Enum.Material.Concrete)
        end
    elseif spec.name == "SportsField" then
        part(model, "Court", Vector3.new(104, 0.5, 72), CFrame.new(spec.center + Vector3.new(0, 1.3, 0)), Color3.fromRGB(183, 119, 77), Enum.Material.Concrete)
        part(model, "BleachersBlockout", Vector3.new(105, 8, 16), CFrame.new(spec.center + Vector3.new(0, 5, 48)), Color3.fromRGB(182, 187, 193), Enum.Material.Metal)
    end
end

-- Compact cross-city circulation. These are blockout paths, not final roads.
local roadColor = Color3.fromRGB(48, 51, 58)
part(roads, "NorthSouthSpine", Vector3.new(34, 0.6, 505), CFrame.new(0, 1.1, 0), roadColor, Enum.Material.Asphalt)
part(roads, "EastWestSpine", Vector3.new(545, 0.6, 34), CFrame.new(0, 1.1, 0), roadColor, Enum.Material.Asphalt)
part(roads, "SchoolSportsConnector", Vector3.new(235, 0.6, 26), CFrame.new(125, 1.1, 210), roadColor, Enum.Material.Asphalt)

local spawn = Instance.new("SpawnLocation")
spawn.Name = "AfterSchoolSpawn"
spawn.Size = Vector3.new(12, 1, 12)
spawn.CFrame = CFrame.new(0, 3, 265)
spawn.Anchored = true
spawn.Neutral = true
spawn.Material = Enum.Material.Neon
spawn.Color = Color3.fromRGB(255, 188, 77)
spawn.Parent = landmarks
billboard(spawn, "SCHOOL'S OUT!")

local cityMarker = part(landmarks, "CityCenterMarker", Vector3.new(18, 18, 18), CFrame.new(0, 10, 0), Color3.fromRGB(255, 190, 78), Enum.Material.Neon)
cityMarker.Shape = Enum.PartType.Ball
cityMarker.CanCollide = false
billboard(cityMarker, "AFTER SCHOOL CITY")

-- First-look lighting only. Final art direction will replace this after visual audit.
Lighting.ClockTime = 16.8
Lighting.Brightness = 2.2
Lighting.GlobalShadows = true
Lighting.EnvironmentDiffuseScale = 0.35
Lighting.EnvironmentSpecularScale = 0.35
Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 140)

Workspace:SetAttribute("ASC_WorldScaffold", "v0.1")
Workspace:SetAttribute("ASC_WorldScaffoldMode", "CREATED_BLOCKOUT")
Workspace:SetAttribute("ASC_DistrictCount", #zoneSpecs)
Workspace:SetAttribute("ASC_CorePositioning", "SCHOOL_LIFE_ROLEPLAY")
print("[AFTER SCHOOL CITY] world scaffold v0.1 initialized")
