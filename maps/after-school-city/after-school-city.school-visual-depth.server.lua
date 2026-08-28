-- AFTER SCHOOL CITY — School Visual Depth Pass v0.7.2
-- Architectural polish on top of V0.7.1: fixes side-facing sign plate geometry,
-- reduces placeholder color blocks, adds restrained interior depth, and normalizes school furniture/materials.
-- No road authority, orientation, gameplay, economy, persistence, clubs authority, monetization, or dedication changes.

local Workspace = game:GetService("Workspace")

local VERSION = "0.7.2-school-visual-depth-1"
local MAX_DEPTH_PARTS = 64

local C = {
    navy = Color3.fromRGB(25, 37, 55),
    navySoft = Color3.fromRGB(45, 58, 75),
    slate = Color3.fromRGB(64, 72, 82),
    gold = Color3.fromRGB(196, 145, 55),
    bronze = Color3.fromRGB(156, 116, 66),
    warmWhite = Color3.fromRGB(236, 232, 222),
    wood = Color3.fromRGB(126, 91, 63),
    woodDark = Color3.fromRGB(91, 65, 49),
    charcoal = Color3.fromRGB(43, 47, 53),
    mutedBlue = Color3.fromRGB(61, 79, 101),
}

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V072 Depth] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_SchoolInteriorPolishPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V072 Depth] AfterSchoolCity root missing")
    return
end

local districts = root:WaitForChild("Districts", 10)
local school = districts and districts:WaitForChild("SchoolDistrict", 10)
if not school then
    warn("[ASC V072 Depth] SchoolDistrict missing")
    return
end

if school:FindFirstChild("V072_SchoolVisualDepth") then
    return
end

local interior = school:FindFirstChild("V070_SchoolInterior")
if not interior then
    warn("[ASC V072 Depth] V070_SchoolInterior missing")
    return
end

local v071 = school:FindFirstChild("V071_SchoolInteriorPolish")
if not v071 then
    warn("[ASC V072 Depth] V071_SchoolInteriorPolish missing")
    return
end

local layer = Instance.new("Model")
layer.Name = "V072_SchoolVisualDepth"
layer:SetAttribute("ASC_Layer", "SCHOOL_VISUAL_DEPTH")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = school

local createdParts = 0
local signsRebuilt = 0
local furnitureRestyled = 0
local lockersRestyled = 0
local depthDetails = 0

local function part(parent, name, size, cf, color, material, canCollide)
    if createdParts >= MAX_DEPTH_PARTS then
        warn("[ASC V072 Depth] depth part budget reached")
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

local function getSurfaceLabel(signPart)
    if not signPart or not signPart:IsA("BasePart") then
        return nil, nil
    end
    for _, child in ipairs(signPart:GetChildren()) do
        if child:IsA("SurfaceGui") then
            local label = child:FindFirstChild("Label")
            if label and label:IsA("TextLabel") then
                return child, label
            end
        end
    end
    return nil, nil
end

local function desiredSignWidth(text)
    local lengths = {
        ["MAIN HALL"] = 8.0,
        ["LIBRARY"] = 6.4,
        ["CANTEEN"] = 6.4,
        ["TEACHER / ADMIN"] = 9.2,
        ["CLUB ROOMS"] = 7.6,
        ["CLASSROOM A"] = 7.8,
        ["CLASSROOM B"] = 7.8,
        ["MUSIC CLUB"] = 7.3,
        ["ART CLUB"] = 6.5,
        ["TOILET A"] = 5.3,
        ["TOILET B"] = 5.3,
        ["LIBRARY / CANTEEN"] = 10.8,
        ["ADMIN / CLUBS"] = 9.6,
    }
    return lengths[text] or math.clamp(4.8 + (#text * 0.18), 5.5, 11.0)
end

local replacementText = {
    ["← LIBRARY • CANTEEN"] = "LIBRARY / CANTEEN",
    ["← LIBRARY / CANTEEN"] = "LIBRARY / CANTEEN",
    ["ADMIN • CLUBS →"] = "ADMIN / CLUBS",
    ["ADMIN / CLUBS →"] = "ADMIN / CLUBS",
    ["WELCOME / MAIN HALL"] = "MAIN HALL",
}

local function styleLabel(gui, label, text)
    label.Text = text
    label.TextColor3 = C.warmWhite
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextWrapped = false
    label.TextStrokeColor3 = Color3.fromRGB(10, 14, 20)
    label.TextStrokeTransparency = 0.78
    label.Size = UDim2.fromScale(0.86, 0.64)
    label.Position = UDim2.fromScale(0.07, 0.10)

    local accent = gui:FindFirstChild("V072Accent")
    if not accent then
        accent = Instance.new("Frame")
        accent.Name = "V072Accent"
        accent.BorderSizePixel = 0
        accent.BackgroundColor3 = C.gold
        accent.Size = UDim2.fromScale(0.70, 0.055)
        accent.Position = UDim2.fromScale(0.15, 0.82)
        accent.Parent = gui
    end
end

local function rebuildArchitecturalSign(signPart)
    local gui, label = getSurfaceLabel(signPart)
    if not gui or not label then
        return false
    end

    local original = label.Text
    local text = replacementText[original] or original
    local eligible =
        string.find(text, "CLASSROOM", 1, true) or
        string.find(text, "LIBRARY", 1, true) or
        string.find(text, "CANTEEN", 1, true) or
        string.find(text, "ADMIN", 1, true) or
        string.find(text, "CLUB", 1, true) or
        string.find(text, "TOILET", 1, true) or
        string.find(text, "MAIN HALL", 1, true)

    if not eligible then
        return false
    end

    local width = desiredSignWidth(text)
    local height = string.find(text, " / ", 1, true) and 1.28 or 1.42
    local thickness = 0.22

    -- SurfaceGui Left/Right uses the Y/Z face. V0.7/V0.7.1 treated every sign like Front/Back,
    -- which produced long colored slabs protruding into the hallway. Correct dimensions by face.
    if gui.Face == Enum.NormalId.Left or gui.Face == Enum.NormalId.Right then
        signPart.Size = Vector3.new(thickness, height, width)
    elseif gui.Face == Enum.NormalId.Front or gui.Face == Enum.NormalId.Back then
        signPart.Size = Vector3.new(width, height, thickness)
    else
        return false
    end

    signPart.Color = C.navy
    signPart.Material = Enum.Material.Metal
    signPart.Transparency = 0.04
    signPart.CanCollide = false
    signPart.CanTouch = false
    signPart.CastShadow = true
    signPart:SetAttribute("ASC_V072ArchitecturalSign", true)
    styleLabel(gui, label, text)
    signsRebuilt += 1
    return true
end

-- =========================================================
-- A. ARCHITECTURAL SIGNAGE / PLACEHOLDER SLAB CLEANUP
-- =========================================================
for _, obj in ipairs(interior:GetDescendants()) do
    if obj:IsA("BasePart") and obj.Name == "RoomSign" then
        rebuildArchitecturalSign(obj)
    end
end

-- Large school-side identity boards are normalized without touching the dedication UI.
for _, obj in ipairs(school:GetDescendants()) do
    if obj:IsA("BasePart") then
        local gui, label = getSurfaceLabel(obj)
        if gui and label and string.find(label.Text, "THIS CITY IS YOURS", 1, true) then
            local face = gui.Face
            if face == Enum.NormalId.Left or face == Enum.NormalId.Right then
                obj.Size = Vector3.new(0.30, 4.1, 27.0)
            elseif face == Enum.NormalId.Front or face == Enum.NormalId.Back then
                obj.Size = Vector3.new(27.0, 4.1, 0.30)
            end
            obj.Color = C.navy
            obj.Material = Enum.Material.Metal
            obj.CanCollide = false
            label.Text = "AFTER SCHOOL CITY\nTHIS CITY IS YOURS."
            label.TextColor3 = C.warmWhite
            label.Font = Enum.Font.GothamBold
            label.TextScaled = true
            label.TextWrapped = true
            label.TextStrokeTransparency = 0.82
            label.Size = UDim2.fromScale(0.86, 0.76)
            label.Position = UDim2.fromScale(0.07, 0.10)
            obj:SetAttribute("ASC_V072IdentityBoardNormalized", true)
        end
    end
end

local schoolSign = school:FindFirstChild("SchoolSign")
if schoolSign and schoolSign:IsA("BasePart") then
    local gui, label = getSurfaceLabel(schoolSign)
    schoolSign.Size = Vector3.new(34, 3.4, 0.38)
    schoolSign.Color = C.navy
    schoolSign.Material = Enum.Material.Metal
    schoolSign.CanCollide = false
    if gui and label then
        label.Text = "AFTER SCHOOL ACADEMY"
        label.TextColor3 = C.warmWhite
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true
        label.TextWrapped = false
        label.TextStrokeTransparency = 0.84
        label.Size = UDim2.fromScale(0.90, 0.70)
        label.Position = UDim2.fromScale(0.05, 0.15)
    end
    schoolSign:SetAttribute("ASC_V072AcademySignNormalized", true)
end

-- =========================================================
-- B. CORRIDOR MATERIAL / DEPTH PASS
-- =========================================================
local mainInterior = interior:FindFirstChild("MainBuildingInterior")
if mainInterior then
    local lobby = mainInterior:FindFirstChild("LobbyFloorAccent")
    if lobby and lobby:IsA("BasePart") then
        lobby.Color = C.bronze
        lobby.Material = Enum.Material.Slate
        lobby.Transparency = 0.02
    end

    local hall = mainInterior:FindFirstChild("HallFloorAccent")
    if hall and hall:IsA("BasePart") then
        hall.Color = C.navySoft
        hall.Material = Enum.Material.Slate
        hall.Transparency = 0.02

        local halfX = hall.Size.X / 2 - 0.22
        for _, x in ipairs({-halfX, halfX}) do
            local strip = part(layer, "HallRunnerEdge", Vector3.new(0.12, 0.05, hall.Size.Z - 0.6), hall.CFrame * CFrame.new(x, 0.07, 0), C.gold, Enum.Material.Metal, false)
            if strip then
                strip.CastShadow = false
                depthDetails += 1
            end
        end

        for _, z in ipairs({-10.5, -3.5, 3.5, 10.5}) do
            local slat = part(layer, "MainHallCeilingSlat", Vector3.new(hall.Size.X - 0.8, 0.22, 0.46), hall.CFrame * CFrame.new(0, 11.7, z), C.charcoal, Enum.Material.Metal, false)
            if slat then
                depthDetails += 1
            end
        end
    end

    for _, obj in ipairs(mainInterior:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "HallPartition" then
            local baseboard = part(layer, "HallPartitionBaseboard", Vector3.new(obj.Size.X + 0.16, 0.34, obj.Size.Z), obj.CFrame * CFrame.new(0, -obj.Size.Y / 2 + 0.20, 0), C.charcoal, Enum.Material.Metal, false)
            if baseboard then
                depthDetails += 1
            end
        end
    end
end

-- Wing divider base trim: creates a finished wall-floor transition without changing collision authority.
for _, wingName in ipairs({"LeftWingInterior", "RightWingInterior"}) do
    local wing = interior:FindFirstChild(wingName)
    if wing then
        for _, obj in ipairs(wing:GetChildren()) do
            if obj:IsA("BasePart") and string.find(obj.Name, "Divider", 1, true) then
                local trim = part(layer, "WingDividerBaseboard", Vector3.new(obj.Size.X, 0.32, obj.Size.Z + 0.12), obj.CFrame * CFrame.new(0, -obj.Size.Y / 2 + 0.18, 0), C.charcoal, Enum.Material.Metal, false)
                if trim then
                    depthDetails += 1
                end
            end
        end
    end
end

-- =========================================================
-- C. LOCKER + FURNITURE MATERIAL NORMALIZATION
-- =========================================================
local lockers = mainInterior and mainInterior:FindFirstChild("HallLockers")
if lockers then
    local index = 0
    for _, locker in ipairs(lockers:GetChildren()) do
        if locker:IsA("BasePart") and locker.Name == "LockerBank" then
            index += 1
            locker.Size = Vector3.new(1.18, 5.65, 2.45)
            locker.Color = (index % 2 == 0) and C.mutedBlue or C.navySoft
            locker.Material = Enum.Material.Metal
            locker.Reflectance = 0.02
            locker:SetAttribute("ASC_V072LockerRestyled", true)
            lockersRestyled += 1
        end
    end
end

local woodFurniture = {
    StudentDesk = true,
    TeacherDesk = true,
    LibraryStudyTable = true,
    CanteenTable = true,
    AdminDesk = true,
    TeacherTable = true,
    ClubTable = true,
}

local seating = {
    StudentSeat = true,
    CanteenBench = true,
    LibrarySeat = true,
    ClubSeat = true,
}

for _, obj in ipairs(interior:GetDescendants()) do
    if obj:IsA("BasePart") then
        if woodFurniture[obj.Name] then
            obj.Color = C.wood
            obj.Material = Enum.Material.Wood
            obj:SetAttribute("ASC_V072FurnitureRestyled", true)
            furnitureRestyled += 1
        elseif seating[obj.Name] then
            obj.Color = C.navySoft
            obj.Material = Enum.Material.SmoothPlastic
            obj:SetAttribute("ASC_V072FurnitureRestyled", true)
            furnitureRestyled += 1
        elseif obj.Name == "Board" then
            obj.Color = C.charcoal
            obj.Material = Enum.Material.Slate
        elseif obj.Name == "LibraryShelf" then
            obj.Color = C.woodDark
            obj.Material = Enum.Material.Wood
        end
    end
end

-- Add restrained shelf crown/base caps to break up monolithic library blocks.
local leftWing = interior:FindFirstChild("LeftWingInterior")
if leftWing then
    for _, shelf in ipairs(leftWing:GetChildren()) do
        if shelf:IsA("BasePart") and shelf.Name == "LibraryShelf" and createdParts + 2 <= MAX_DEPTH_PARTS then
            local top = part(layer, "LibraryShelfCrown", Vector3.new(shelf.Size.X + 0.18, 0.18, shelf.Size.Z + 0.12), shelf.CFrame * CFrame.new(0, shelf.Size.Y / 2 + 0.08, 0), C.charcoal, Enum.Material.Metal, false)
            local bottom = part(layer, "LibraryShelfBase", Vector3.new(shelf.Size.X + 0.18, 0.18, shelf.Size.Z + 0.12), shelf.CFrame * CFrame.new(0, -shelf.Size.Y / 2 + 0.09, 0), C.charcoal, Enum.Material.Metal, false)
            if top then depthDetails += 1 end
            if bottom then depthDetails += 1 end
        end
    end
end

school:SetAttribute("ASC_SchoolVisualDepthPass", VERSION)
school:SetAttribute("ASC_V072SignsRebuilt", signsRebuilt)
school:SetAttribute("ASC_V072FurnitureRestyled", furnitureRestyled)
school:SetAttribute("ASC_V072LockersRestyled", lockersRestyled)
school:SetAttribute("ASC_V072DepthDetails", depthDetails)
school:SetAttribute("ASC_V072DepthPartCount", createdParts)
root:SetAttribute("ASC_SchoolVisualDepthV072", true)
Workspace:SetAttribute("ASC_SchoolVisualDepthPass", VERSION)

print(string.format("[AFTER SCHOOL CITY] School Visual Depth v0.7.2 initialized; signs=%d furniture=%d lockers=%d details=%d newParts=%d", signsRebuilt, furnitureRestyled, lockersRestyled, depthDetails, createdParts))
