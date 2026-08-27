-- AFTER SCHOOL CITY — Circulation Sanitize Pass v0.4.4
-- Screenshot-driven correction for blocked doors, trees in walkways and Club Hub setback/orientation.
-- Placement-only: no economy, persistence, monetization or gameplay authority.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC CirculationSanitize] AfterSchoolCity root missing")
    return
end

root:WaitForChild("V043_LayoutCorrection", 20)

if root:FindFirstChild("V044_CirculationSanitize") then
    return
end

local districts = root:WaitForChild("Districts", 10)
local school = districts:FindFirstChild("SchoolDistrict")
local landscaping = root:FindFirstChild("Landscaping")

local layer = Instance.new("Model")
layer.Name = "V044_CirculationSanitize"
layer:SetAttribute("ASC_Layer", "CIRCULATION_SANITIZE")
layer:SetAttribute("ASC_Version", "0.4.4-circulation-sanitize-1")
layer.Parent = root

local C = {
    white = Color3.fromRGB(240, 242, 245),
    concrete = Color3.fromRGB(198, 202, 208),
    navy = Color3.fromRGB(34, 48, 72),
    blue = Color3.fromRGB(59, 102, 151),
    glass = Color3.fromRGB(91, 139, 170),
    dark = Color3.fromRGB(37, 41, 48),
    metal = Color3.fromRGB(83, 88, 96),
    gold = Color3.fromRGB(242, 180, 65),
    purple = Color3.fromRGB(142, 107, 157),
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

local function window(parent, name, size, cf)
    local w = part(parent, name, size, cf, C.glass, Enum.Material.Glass, 0.16)
    w.CanCollide = false
    w.CastShadow = false
    return w
end

local function signWest(parent, text, pos)
    local plate = part(parent, "ClubHubSign", Vector3.new(0.6, 4.5, 22), CFrame.new(pos), C.blue, Enum.Material.SmoothPlastic)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Left
    gui.AlwaysOnTop = false
    gui.PixelsPerStud = 30
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
end

local function inSchoolFrontZone(pos)
    -- Hard no-tree circulation envelope around front plaza, locker breezeway,
    -- school approach and east/west entrance zones seen blocked in live v12.
    return pos.Z >= 236 and pos.Z <= 286 and math.abs(pos.X) <= 116
end

-- =========================================================
-- A. HARD-CLEAR SCHOOL FRONT CIRCULATION
-- No decorative tree is allowed inside the front plaza / locker / doorway envelope.
-- Trees can be reintroduced later only after measured clearance.
-- =========================================================
if landscaping then
    for _, child in ipairs(landscaping:GetChildren()) do
        if child:IsA("Model") and (child.Name == "Tree" or child.Name == "SafeCampusTree") then
            local probe = child:FindFirstChildWhichIsA("BasePart", true)
            if probe and inSchoolFrontZone(probe.Position) then
                child:Destroy()
            end
        elseif child:IsA("BasePart") and inSchoolFrontZone(child.Position) then
            if child.Name == "StreetTreeTrunk" or child.Name == "StreetTreeCrown" then
                child:Destroy()
            end
        end
    end
end

-- Defensive cleanup for any tree-like parts created in other late visual layers
-- inside the locker/door circulation boxes.
for _, descendant in ipairs(root:GetDescendants()) do
    if descendant:IsA("BasePart") and inSchoolFrontZone(descendant.Position) then
        local lower = string.lower(descendant.Name)
        if string.find(lower, "tree") or lower == "trunk" or lower == "crown" then
            descendant:Destroy()
        end
    end
end

-- =========================================================
-- B. REMOVE OLD CLUB HUB + ITS OVERLAPPING EAST POCKET PLAZA
-- v0.4.2 moved the original 54-stud Club Hub next to the X=126 side street,
-- leaving its east wall effectively on the sidewalk and presenting a blank wall.
-- =========================================================
if school then
    local schoolLife = school:FindFirstChild("V03_SchoolLife")
    local oldClub = schoolLife and schoolLife:FindFirstChild("ClubHub")
    if oldClub then
        oldClub:Destroy()
    end
end

local spatial = root:FindFirstChild("V041_SpatialCleanup")
local corridor = spatial and spatial:FindFirstChild("V041_SchoolDowntownCorridor")
if corridor then
    for _, obj in ipairs(corridor:GetChildren()) do
        if obj:IsA("BasePart") then
            local p = obj.Position
            if p.X >= 25 and p.X <= 72 and p.Z >= 150 and p.Z <= 176 then
                obj:Destroy()
            end
        end
    end
end

-- =========================================================
-- C. REBUILD CLUB HUB AS A COMPACT, STREET-CLEAR BUILDING
-- Center X=74 gives measured clearance from both the central avenue and the
-- X=126 secondary street. Entrance faces west toward the internal pedestrian side,
-- while the road-facing east facade gets windows instead of a blank wall.
-- =========================================================
local club = Instance.new("Model")
club.Name = "ClubHubV044"
club:SetAttribute("ASC_ClearanceChecked", true)
club:SetAttribute("ASC_EntranceFaces", "WEST")
club:SetAttribute("ASC_SideStreetClearance", "11_STUDS_PLUS")
club.Parent = layer

local cx, cz = 74, 145
local width, depth, height = 40, 26, 16

part(club, "Body", Vector3.new(width, height, depth), CFrame.new(cx, 1.3 + height / 2, cz), Color3.fromRGB(220, 222, 220), Enum.Material.Concrete)
part(club, "Roof", Vector3.new(width + 2, 1.2, depth + 2), CFrame.new(cx, 1.3 + height + 0.6, cz), C.navy, Enum.Material.Metal)

-- West-facing entrance and glazing.
part(club, "EntranceDoor", Vector3.new(0.7, 9, 7), CFrame.new(cx - width / 2 - 0.38, 5.9, cz), C.dark, Enum.Material.Metal)
window(club, "FrontWindowNorth", Vector3.new(0.55, 6.5, 8), CFrame.new(cx - width / 2 - 0.42, 8.2, cz - 8))
window(club, "FrontWindowSouth", Vector3.new(0.55, 6.5, 8), CFrame.new(cx - width / 2 - 0.42, 8.2, cz + 8))
signWest(club, "CLUB HUB", Vector3.new(cx - width / 2 - 0.72, 14.2, cz))

-- East facade faces the side street; keep it readable and non-blank.
for _, z in ipairs({cz - 8, cz, cz + 8}) do
    window(club, "RoadFacingWindow", Vector3.new(0.55, 6.2, 6), CFrame.new(cx + width / 2 + 0.32, 8, z))
end

-- Internal club color bands are visible through the west entrance/windows.
part(club, "MusicFeature", Vector3.new(2.5, 7, 7), CFrame.new(cx - 10, 5.3, cz - 8), C.gold, Enum.Material.SmoothPlastic)
part(club, "ArtFeature", Vector3.new(2.5, 7, 7), CFrame.new(cx - 10, 5.3, cz), C.purple, Enum.Material.SmoothPlastic)
part(club, "GamingFeature", Vector3.new(2.5, 7, 7), CFrame.new(cx - 10, 5.3, cz + 8), C.blue, Enum.Material.SmoothPlastic)

-- Dedicated access pad stops before the central-road sidewalk instead of overlapping it.
part(club, "AccessPad", Vector3.new(12, 0.6, 30), CFrame.new(47.5, 1.3, cz), C.concrete, Enum.Material.Concrete)

root:SetAttribute("ASC_CirculationSanitizePass", "0.4.4-circulation-sanitize-1")
root:SetAttribute("ASC_SchoolFrontTreeFree", true)
root:SetAttribute("ASC_ClubHubRebuiltForClearance", true)
Workspace:SetAttribute("ASC_CirculationSanitizePass", "0.4.4-circulation-sanitize-1")

print("[AFTER SCHOOL CITY] Circulation Sanitize v0.4.4 initialized")
