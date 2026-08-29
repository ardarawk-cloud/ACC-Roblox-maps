-- AFTER SCHOOL CITY — School + Road Visual Defect Cleanup v0.7.7
-- Screenshot-driven post-pass cleanup after v0.7.6.
-- Removes legacy SPORTS wayfinding, clears the concrete strip crossing SchoolSportsRoad,
-- trims the SportsGround off the road edge, and reduces Club Rooms placeholder geometry.
-- No road/orientation authority changes; no gameplay, economy, persistence, clubs, monetization, or dedication changes.

local Workspace = game:GetService("Workspace")

local VERSION = "0.7.7-school-road-visual-defect-cleanup-1"
local MAX_CLEANUP_PARTS = 24
local SPORTS_ROAD_MARGIN = 3.0

local C = {
    navy = Color3.fromRGB(31, 43, 62),
    navySoft = Color3.fromRGB(51, 63, 80),
    purpleSoft = Color3.fromRGB(83, 69, 101),
    blueSoft = Color3.fromRGB(54, 76, 104),
    gold = Color3.fromRGB(196, 145, 55),
    wood = Color3.fromRGB(112, 80, 58),
    metal = Color3.fromRGB(66, 72, 82),
    pale = Color3.fromRGB(219, 224, 228),
}

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V077 Cleanup] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_ExteriorLockerCleanupPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V077 Cleanup] AfterSchoolCity root missing")
    return
end

if root:FindFirstChild("V077_SchoolRoadVisualDefectCleanup") then
    return
end

local districts = root:WaitForChild("Districts", 10)
local roads = root:WaitForChild("RoadsAndPaths", 10)
local school = districts:FindFirstChild("SchoolDistrict")
local sports = districts:FindFirstChild("SportsField")
if not school then
    warn("[ASC V077 Cleanup] SchoolDistrict missing")
    return
end

local layer = Instance.new("Model")
layer.Name = "V077_SchoolRoadVisualDefectCleanup"
layer:SetAttribute("ASC_Layer", "SCHOOL_ROAD_VISUAL_DEFECT_CLEANUP")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

local createdParts = 0
local legacySportsSignsRemoved = 0
local roadCrossingPartsRemoved = 0
local sportsGroundTrimmed = 0
local clubZonesRestyled = 0
local clubTablesRestyled = 0
local clubTableLegsAdded = 0
local sinkCountersRestyled = 0
local clubSignsCompacted = 0

local function part(parent, name, size, cf, color, material, canCollide)
    if createdParts >= MAX_CLEANUP_PARTS then
        warn("[ASC V077 Cleanup] cleanup part budget reached")
        return nil
    end
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Color = color or C.navySoft
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

local function compactFrontBackSign(plate, width, height)
    if not plate or not plate:IsA("BasePart") then
        return false
    end
    local gui
    local label
    for _, child in ipairs(plate:GetChildren()) do
        if child:IsA("SurfaceGui") then
            local candidate = child:FindFirstChild("Label")
            if candidate and candidate:IsA("TextLabel") then
                gui = child
                label = candidate
                break
            end
        end
    end
    if not gui or not label then
        return false
    end
    if gui.Face ~= Enum.NormalId.Front and gui.Face ~= Enum.NormalId.Back then
        return false
    end
    plate.Size = Vector3.new(width, height, math.min(plate.Size.Z, 0.22))
    plate.Color = C.navy
    plate.Material = Enum.Material.Metal
    plate.CanCollide = false
    label.TextScaled = true
    label.TextWrapped = false
    plate:SetAttribute("ASC_V077CompactSign", true)
    return true
end

-- =========================================================
-- A. REMOVE LEGACY SCHOOL-LIFE SPORTS WAYFINDING
-- This exact legacy sign survived earlier DOWNTOWN-only reconciliation and can
-- appear inside the corrected school shell after the orientation passes.
-- =========================================================
local schoolLife = school:FindFirstChild("V03_SchoolLife")
if schoolLife then
    local plates = {}
    for _, descendant in ipairs(schoolLife:GetDescendants()) do
        if descendant:IsA("TextLabel") then
            local normalized = descendant.Text:gsub("%s+", " ")
            if string.find(normalized, "SPORTS", 1, true) then
                local gui = descendant.Parent
                local plate = gui and gui.Parent
                if gui and gui:IsA("SurfaceGui") and plate and plate:IsA("BasePart") and plate.Name == "Sign" then
                    table.insert(plates, plate)
                end
            end
        end
    end
    for _, plate in ipairs(plates) do
        if plate.Parent then
            plate:Destroy()
            legacySportsSignsRemoved += 1
        end
    end
end

-- =========================================================
-- B. SCHOOL ↔ SPORTS ROAD: REMOVE THE KNOWN CONCRETE CROSSING DEFECT
-- V0.4.3 SportsWestBufferWalk was authored as an 82-stud north/south strip at
-- X=158, which physically crosses the later compact SchoolSportsRoad at Z=210.
-- Remove only that obsolete visual buffer. The protected road stays untouched.
-- =========================================================
local layoutCorrection = root:FindFirstChild("V043_LayoutCorrection")
if layoutCorrection then
    local crossing = layoutCorrection:FindFirstChild("SportsWestBufferWalk")
    if crossing and crossing:IsA("BasePart") then
        crossing:Destroy()
        roadCrossingPartsRemoved += 1
    end
end

-- Keep the SportsField ground fully outside the east edge of SchoolSportsRoad.
-- Preserve its east boundary and rotation; only trim the west edge overlap.
local schoolSportsRoad = roads:FindFirstChild("SchoolSportsRoad")
local sportsGround = sports and sports:FindFirstChild("SportsGround")
if schoolSportsRoad and schoolSportsRoad:IsA("BasePart") and sportsGround and sportsGround:IsA("BasePart") then
    local roadEast = schoolSportsRoad.Position.X + schoolSportsRoad.Size.X / 2
    local desiredWest = roadEast + SPORTS_ROAD_MARGIN
    local currentWest = sportsGround.Position.X - sportsGround.Size.X / 2
    local currentEast = sportsGround.Position.X + sportsGround.Size.X / 2
    if currentWest < desiredWest and currentEast > desiredWest then
        local newSizeX = currentEast - desiredWest
        if newSizeX > 40 then
            local newCenterX = (desiredWest + currentEast) / 2
            local rotation = sportsGround.CFrame - sportsGround.Position
            sportsGround.Size = Vector3.new(newSizeX, sportsGround.Size.Y, sportsGround.Size.Z)
            sportsGround.CFrame = CFrame.new(newCenterX, sportsGround.Position.Y, sportsGround.Position.Z) * rotation
            sportsGround:SetAttribute("ASC_V077RoadEdgeTrimmed", true)
            sportsGroundTrimmed += 1
        end
    end
end

-- =========================================================
-- C. CLUB ROOMS: REDUCE BLOCKOUT LOOK WITHOUT ENABLING CLUB GAMEPLAY
-- =========================================================
local interior = school:FindFirstChild("V070_SchoolInterior")
local rightInterior = interior and interior:FindFirstChild("RightWingInterior")
if rightInterior then
    local clubTableIndex = 0
    for _, obj in ipairs(rightInterior:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj.Name == "ClubZone" then
                obj.Size = Vector3.new(14, 0.06, 10)
                obj.Material = Enum.Material.Fabric
                obj.Color = obj.Position.X < rightInterior:GetPivot().Position.X and C.blueSoft or C.purpleSoft
                obj.Transparency = 0.02
                obj.CanCollide = false
                obj.CastShadow = false
                obj:SetAttribute("ASC_V077ClubRug", true)
                clubZonesRestyled += 1
            elseif obj.Name == "ClubTable" then
                clubTableIndex += 1
                obj.Size = Vector3.new(6.6, 0.55, 2.8)
                obj.Material = Enum.Material.Wood
                obj.Color = C.wood
                obj:SetAttribute("ASC_V077GroundedTable", true)
                clubTablesRestyled += 1

                for _, offset in ipairs({
                    Vector3.new(-2.55, -0.80, -0.95),
                    Vector3.new(2.55, -0.80, -0.95),
                    Vector3.new(-2.55, -0.80, 0.95),
                    Vector3.new(2.55, -0.80, 0.95),
                }) do
                    local leg = part(layer, "ClubTableLeg", Vector3.new(0.38, 1.05, 0.38), obj.CFrame * CFrame.new(offset), C.metal, Enum.Material.Metal, true)
                    if leg then
                        leg:SetAttribute("ASC_V077ClubTableIndex", clubTableIndex)
                        clubTableLegsAdded += 1
                    end
                end
            elseif obj.Name == "SinkCounter" then
                obj.Size = Vector3.new(5.4, 1.25, 1.65)
                obj.Color = C.pale
                obj.Material = Enum.Material.Marble
                obj:SetAttribute("ASC_V077CompactSinkCounter", true)
                sinkCountersRestyled += 1
            elseif obj.Name == "RoomSign" then
                local targetText
                for _, gui in ipairs(obj:GetChildren()) do
                    if gui:IsA("SurfaceGui") then
                        local label = gui:FindFirstChild("Label")
                        if label and label:IsA("TextLabel") then
                            targetText = label.Text
                            break
                        end
                    end
                end
                if targetText == "CLUB ROOMS" then
                    if compactFrontBackSign(obj, 10.5, 1.35) then
                        clubSignsCompacted += 1
                    end
                elseif targetText == "MUSIC CLUB" or targetText == "ART CLUB" then
                    if compactFrontBackSign(obj, 7.2, 1.10) then
                        clubSignsCompacted += 1
                    end
                end
            end
        end
    end
end

-- Final defensive check: the obsolete crossing must not survive this pass.
local residualCrossing = root:FindFirstChild("SportsWestBufferWalk", true)
if residualCrossing and residualCrossing:IsA("BasePart") then
    residualCrossing:Destroy()
    roadCrossingPartsRemoved += 1
end

layer:SetAttribute("ASC_V077LegacySportsSignsRemoved", legacySportsSignsRemoved)
layer:SetAttribute("ASC_V077RoadCrossingPartsRemoved", roadCrossingPartsRemoved)
layer:SetAttribute("ASC_V077SportsGroundTrimmed", sportsGroundTrimmed)
layer:SetAttribute("ASC_V077ClubZonesRestyled", clubZonesRestyled)
layer:SetAttribute("ASC_V077ClubTablesRestyled", clubTablesRestyled)
layer:SetAttribute("ASC_V077ClubTableLegsAdded", clubTableLegsAdded)
layer:SetAttribute("ASC_V077SinkCountersRestyled", sinkCountersRestyled)
layer:SetAttribute("ASC_V077ClubSignsCompacted", clubSignsCompacted)
layer:SetAttribute("ASC_V077NewPartCount", createdParts)

root:SetAttribute("ASC_SchoolRoadVisualDefectCleanupV077", true)
root:SetAttribute("ASC_SchoolSportsRoadVisualClear", true)
root:SetAttribute("ASC_LegacySportsWayfindingRemoved", true)
root:SetAttribute("ASC_ClubRoomsVisualCleanup", true)
Workspace:SetAttribute("ASC_SchoolRoadVisualDefectCleanupPass", VERSION)

print(string.format("[AFTER SCHOOL CITY] V0.7.7 cleanup initialized; sportsSigns=%d roadCrossings=%d sportsTrim=%d clubZones=%d clubTables=%d legs=%d sinks=%d signs=%d newParts=%d", legacySportsSignsRemoved, roadCrossingPartsRemoved, sportsGroundTrimmed, clubZonesRestyled, clubTablesRestyled, clubTableLegsAdded, sinkCountersRestyled, clubSignsCompacted, createdParts))
