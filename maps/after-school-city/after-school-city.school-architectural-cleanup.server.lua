-- AFTER SCHOOL CITY — School Interior Architectural Cleanup v0.7.4
-- Finishing pass on top of V0.7.3: smaller architectural signage, doorway framing,
-- grounded furniture, restrained wall/ceiling finishing, and warmer interior lighting.
-- No road authority, orientation, gameplay, economy, persistence, clubs authority,
-- monetization, dedication, or room-layout changes are introduced here.

local Workspace = game:GetService("Workspace")

local VERSION = "0.7.4-school-architectural-cleanup-1"
local MAX_CLEANUP_PARTS = 58

local C = {
    navy = Color3.fromRGB(25, 37, 55),
    charcoal = Color3.fromRGB(43, 47, 53),
    metal = Color3.fromRGB(78, 84, 92),
    gold = Color3.fromRGB(190, 142, 58),
    wood = Color3.fromRGB(120, 86, 62),
    woodDark = Color3.fromRGB(88, 62, 48),
    warm = Color3.fromRGB(245, 214, 164),
    warmWhite = Color3.fromRGB(237, 233, 224),
    mutedBlue = Color3.fromRGB(57, 73, 94),
}

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V074 Arch] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_SignageOrientationPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V074 Arch] AfterSchoolCity root missing")
    return
end

local districts = root:WaitForChild("Districts", 10)
local school = districts and districts:WaitForChild("SchoolDistrict", 10)
if not school then
    warn("[ASC V074 Arch] SchoolDistrict missing")
    return
end

if school:FindFirstChild("V074_SchoolArchitecturalCleanup") then
    return
end

local interior = school:FindFirstChild("V070_SchoolInterior")
if not interior then
    warn("[ASC V074 Arch] V070_SchoolInterior missing")
    return
end

local mainMass = school:FindFirstChild("MainBuilding")
local leftMass = school:FindFirstChild("LeftWing")
local rightMass = school:FindFirstChild("RightWing")
if not (mainMass and leftMass and rightMass and mainMass:IsA("BasePart") and leftMass:IsA("BasePart") and rightMass:IsA("BasePart")) then
    warn("[ASC V074 Arch] school massing missing")
    return
end

local layer = Instance.new("Model")
layer.Name = "V074_SchoolArchitecturalCleanup"
layer:SetAttribute("ASC_Layer", "SCHOOL_ARCHITECTURAL_CLEANUP")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = school

local createdParts = 0
local signsRefined = 0
local doorFramesAdded = 0
local furnitureDetails = 0
local lightFixturesRefined = 0

local function part(parent, name, size, cf, color, material, canCollide)
    if createdParts >= MAX_CLEANUP_PARTS then
        warn("[ASC V074 Arch] cleanup part budget reached")
        return nil
    end
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Color = color or C.warmWhite
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

local function getPrimaryGuiAndLabel(signPart)
    if not signPart or not signPart:IsA("BasePart") then
        return nil, nil
    end
    for _, child in ipairs(signPart:GetChildren()) do
        if child:IsA("SurfaceGui") and child.Name ~= "V073OppositeSignage" then
            local label = child:FindFirstChild("Label")
            if label and label:IsA("TextLabel") then
                return child, label
            end
        end
    end
    return nil, nil
end

local function normalizedText(text)
    return string.upper((text or ""):gsub("←", ""):gsub("→", ""):gsub("•", "/"):gsub("%s+", " "))
end

local function compactSignWidth(text)
    local t = normalizedText(text)
    local widths = {
        ["MAIN HALL"] = 6.8,
        ["LIBRARY"] = 5.4,
        ["CANTEEN"] = 5.4,
        ["TEACHER / ADMIN"] = 7.7,
        ["CLUB ROOMS"] = 6.5,
        ["CLASSROOM A"] = 6.5,
        ["CLASSROOM B"] = 6.5,
        ["MUSIC CLUB"] = 6.0,
        ["ART CLUB"] = 5.5,
        ["TOILET A"] = 4.7,
        ["TOILET B"] = 4.7,
        ["LIBRARY / CANTEEN"] = 8.7,
        ["ADMIN / CLUBS"] = 7.9,
    }
    return widths[t] or math.clamp(4.5 + (#t * 0.14), 4.8, 8.8)
end

local function refineSign(signPart)
    local gui, label = getPrimaryGuiAndLabel(signPart)
    if not gui or not label then
        return false
    end
    local t = normalizedText(label.Text)
    local relevant = string.find(t, "CLASSROOM", 1, true)
        or string.find(t, "LIBRARY", 1, true)
        or string.find(t, "CANTEEN", 1, true)
        or string.find(t, "TEACHER", 1, true)
        or string.find(t, "ADMIN", 1, true)
        or string.find(t, "CLUB", 1, true)
        or string.find(t, "TOILET", 1, true)
        or string.find(t, "MAIN HALL", 1, true)
    if not relevant then
        return false
    end

    local width = compactSignWidth(label.Text)
    local directional = string.find(t, "LIBRARY / CANTEEN", 1, true) or string.find(t, "ADMIN / CLUBS", 1, true)
    local height = directional and 0.92 or 1.04
    local thickness = 0.16

    if gui.Face == Enum.NormalId.Left or gui.Face == Enum.NormalId.Right then
        signPart.Size = Vector3.new(thickness, height, width)
    elseif gui.Face == Enum.NormalId.Front or gui.Face == Enum.NormalId.Back then
        signPart.Size = Vector3.new(width, height, thickness)
    end

    signPart.Color = C.navy
    signPart.Material = Enum.Material.Metal
    signPart.Transparency = 0.02
    signPart.CanCollide = false
    signPart.CastShadow = true
    signPart:SetAttribute("ASC_V074CompactArchitecturalSign", true)

    for _, surface in ipairs(signPart:GetChildren()) do
        if surface:IsA("SurfaceGui") then
            surface.AlwaysOnTop = false
            surface.LightInfluence = 0.20
            surface.PixelsPerStud = 42
            local textLabel = surface:FindFirstChild("Label")
            if textLabel and textLabel:IsA("TextLabel") then
                textLabel.Font = Enum.Font.GothamSemibold
                textLabel.TextScaled = true
                textLabel.TextWrapped = false
                textLabel.TextColor3 = C.warmWhite
                textLabel.TextStrokeTransparency = 0.90
                textLabel.Size = UDim2.fromScale(0.90, 0.68)
                textLabel.Position = UDim2.fromScale(0.05, 0.08)
            end
            local accent = surface:FindFirstChild("V072Accent")
            if accent and accent:IsA("Frame") then
                accent.Size = UDim2.fromScale(0.56, 0.045)
                accent.Position = UDim2.fromScale(0.22, 0.83)
                accent.BackgroundColor3 = C.gold
            end
        end
    end

    signsRefined += 1
    return true
end

for _, obj in ipairs(interior:GetDescendants()) do
    if obj:IsA("BasePart") and obj.Name == "RoomSign" then
        refineSign(obj)
    end
end

local mainCF = mainMass.CFrame
local leftCF = leftMass.CFrame
local rightCF = rightMass.CFrame

local function addWallPlaneDoorFrame(parent, prefix, baseCF, centerX, centerY, centerZ, openingWidth, openingHeight, wallThickness, frameDepthOnZ)
    local postWidth = 0.42
    local headerHeight = 0.42
    if frameDepthOnZ then
        local postSize = Vector3.new(postWidth, openingHeight, wallThickness + 0.18)
        local leftPost = part(parent, prefix .. "JambL", postSize, baseCF * CFrame.new(centerX - openingWidth / 2, centerY, centerZ), C.charcoal, Enum.Material.Metal, false)
        local rightPost = part(parent, prefix .. "JambR", postSize, baseCF * CFrame.new(centerX + openingWidth / 2, centerY, centerZ), C.charcoal, Enum.Material.Metal, false)
        local header = part(parent, prefix .. "Header", Vector3.new(openingWidth + postWidth, headerHeight, wallThickness + 0.18), baseCF * CFrame.new(centerX, centerY + openingHeight / 2, centerZ), C.charcoal, Enum.Material.Metal, false)
        if leftPost and rightPost and header then doorFramesAdded += 1 end
    else
        local postSize = Vector3.new(wallThickness + 0.18, openingHeight, postWidth)
        local leftPost = part(parent, prefix .. "JambL", postSize, baseCF * CFrame.new(centerX, centerY, centerZ - openingWidth / 2), C.charcoal, Enum.Material.Metal, false)
        local rightPost = part(parent, prefix .. "JambR", postSize, baseCF * CFrame.new(centerX, centerY, centerZ + openingWidth / 2), C.charcoal, Enum.Material.Metal, false)
        local header = part(parent, prefix .. "Header", Vector3.new(wallThickness + 0.18, headerHeight, openingWidth + postWidth), baseCF * CFrame.new(centerX, centerY + openingHeight / 2, centerZ), C.charcoal, Enum.Material.Metal, false)
        if leftPost and rightPost and header then doorFramesAdded += 1 end
    end
end

-- Classroom entrances are the existing gap centered around local Z=-7 between V0.7 hall partitions.
for _, x in ipairs({-8.2, 8.2}) do
    addWallPlaneDoorFrame(layer, x < 0 and "ClassroomAFrame" or "ClassroomBFrame", mainCF, x, -12.35, -7.0, 5.0, 6.7, 0.70, false)
end

-- Main-to-wing connector gaps already exist in the V0.7 shell; frame them without changing collision.
local mainSideX = mainMass.Size.X / 2 - 0.45
for _, x in ipairs({-mainSideX, mainSideX}) do
    addWallPlaneDoorFrame(layer, x < 0 and "LeftWingConnectorFrame" or "RightWingConnectorFrame", mainCF, x, -12.25, 0, 11.7, 6.9, 0.90, false)
end

-- Library/Canteen and Admin/Clubs dividers leave a 10-stud central passage.
addWallPlaneDoorFrame(layer, "LibraryCanteenPassageFrame", leftCF, 0, -8.25, 0, 9.6, 5.8, 0.70, true)
addWallPlaneDoorFrame(layer, "AdminClubPassageFrame", rightCF, 0, -8.25, 0, 9.6, 5.8, 0.70, true)

local function addTableDetail(tablePart, prefix)
    if not tablePart or not tablePart:IsA("BasePart") then
        return
    end
    local legHeight = 1.55
    local legY = -(tablePart.Size.Y / 2 + legHeight / 2)
    local xInset = math.max(0.65, tablePart.Size.X / 2 - 0.85)
    for _, x in ipairs({-xInset, xInset}) do
        local leg = part(layer, prefix .. "Leg", Vector3.new(0.42, legHeight, math.max(0.55, tablePart.Size.Z - 0.7)), tablePart.CFrame * CFrame.new(x, legY, 0), C.charcoal, Enum.Material.Metal, false)
        if leg then furnitureDetails += 1 end
    end
    local modesty = part(layer, prefix .. "Modesty", Vector3.new(math.max(1.2, tablePart.Size.X - 1.4), 1.25, 0.20), tablePart.CFrame * CFrame.new(0, -0.85, tablePart.Size.Z / 2 - 0.18), C.woodDark, Enum.Material.Wood, false)
    if modesty then furnitureDetails += 1 end
end

local rightInterior = interior:FindFirstChild("RightWingInterior")
if rightInterior then
    addTableDetail(rightInterior:FindFirstChild("AdminDesk"), "AdminDesk")
    addTableDetail(rightInterior:FindFirstChild("TeacherTable"), "TeacherTable")

    local storage = rightInterior:FindFirstChild("AdminStorage")
    if storage and storage:IsA("BasePart") then
        storage.Color = C.mutedBlue
        storage.Material = Enum.Material.Metal
        storage.Size = Vector3.new(3.5, 7.2, 8.8)
        storage:SetAttribute("ASC_V074AdminStorageRefined", true)
    end
end

local leftInterior = interior:FindFirstChild("LeftWingInterior")
if leftInterior then
    local study = leftInterior:FindFirstChild("LibraryStudyTable")
    addTableDetail(study, "LibraryStudy")

    local counter = leftInterior:FindFirstChild("CanteenCounter")
    if counter and counter:IsA("BasePart") then
        counter.Color = C.woodDark
        counter.Material = Enum.Material.Wood
        local toe = part(layer, "CanteenCounterToeKick", Vector3.new(counter.Size.X - 1.0, 0.38, 0.36), counter.CFrame * CFrame.new(0, -counter.Size.Y / 2 + 0.22, -counter.Size.Z / 2 - 0.12), C.charcoal, Enum.Material.Metal, false)
        if toe then furnitureDetails += 1 end
        for _, x in ipairs({-8.5, 0, 8.5}) do
            local vertical = part(layer, "CanteenCounterFrontTrim", Vector3.new(0.18, counter.Size.Y - 0.7, 0.24), counter.CFrame * CFrame.new(x, 0, -counter.Size.Z / 2 - 0.14), C.gold, Enum.Material.Metal, false)
            if vertical then furnitureDetails += 1 end
        end
    end
end

-- Restrained warm cove strips: visual definition only, no extra light instances.
for _, item in ipairs({
    {mainCF, Vector3.new(-6.0, 11.45, 4), Vector3.new(0.18, 0.18, 24)},
    {mainCF, Vector3.new(6.0, 11.45, 4), Vector3.new(0.18, 0.18, 24)},
    {leftCF, Vector3.new(0, 8.9, -14), Vector3.new(22, 0.16, 0.18)},
    {rightCF, Vector3.new(0, 8.9, -14), Vector3.new(22, 0.16, 0.18)},
}) do
    local strip = part(layer, "WarmCoveStrip", item[3], item[1] * CFrame.new(item[2]), C.warm, Enum.Material.Neon, false)
    if strip then
        strip.CastShadow = false
    end
end

local lightingLayer = interior:FindFirstChild("InteriorLighting")
if lightingLayer then
    for _, fixture in ipairs(lightingLayer:GetDescendants()) do
        if fixture:IsA("BasePart") and fixture.Name == "CeilingLight" then
            fixture.Size = Vector3.new(4.4, 0.22, 1.05)
            fixture.Color = C.warm
            fixture.Material = Enum.Material.Neon
            fixture.CastShadow = false
            fixture:SetAttribute("ASC_V074LightingRefined", true)
            local light = fixture:FindFirstChildOfClass("PointLight")
            if light then
                light.Brightness = math.min(0.20, 0.22)
                light.Range = math.min(9.0, 10)
                light.Color = C.warm
                light.Shadows = false
            end
            lightFixturesRefined += 1
        end
    end
end

school:SetAttribute("ASC_SchoolArchitecturalCleanupPass", VERSION)
school:SetAttribute("ASC_V074SignsRefined", signsRefined)
school:SetAttribute("ASC_V074DoorFramesAdded", doorFramesAdded)
school:SetAttribute("ASC_V074FurnitureDetails", furnitureDetails)
school:SetAttribute("ASC_V074LightFixturesRefined", lightFixturesRefined)
school:SetAttribute("ASC_V074CleanupPartCount", createdParts)
root:SetAttribute("ASC_SchoolArchitecturalCleanupV074", true)
Workspace:SetAttribute("ASC_SchoolArchitecturalCleanupPass", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] School Architectural Cleanup v0.7.4 initialized; signs=%d frames=%d furniture=%d lights=%d newParts=%d",
    signsRefined,
    doorFramesAdded,
    furnitureDetails,
    lightFixturesRefined,
    createdParts
))
