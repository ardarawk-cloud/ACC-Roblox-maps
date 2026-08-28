-- AFTER SCHOOL CITY — Signage Orientation Hotfix v0.7.3
-- Corrects reversed/swap-prone school signage after the V0.7.2 visual depth pass.
-- Directional signs are derived from the authoritative current school mass CFrames,
-- and room signage is made readable from both approach sides without changing layout/collision.
-- No road, orientation authority, gameplay, economy, persistence, clubs, monetization, or dedication changes.

local Workspace = game:GetService("Workspace")

local VERSION = "0.7.3-signage-orientation-hotfix-1"

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V073 Signage] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_SchoolVisualDepthPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V073 Signage] AfterSchoolCity root missing")
    return
end

local districts = root:WaitForChild("Districts", 10)
local school = districts and districts:WaitForChild("SchoolDistrict", 10)
if not school then
    warn("[ASC V073 Signage] SchoolDistrict missing")
    return
end

if school:FindFirstChild("V073_SignageOrientationHotfix") then
    return
end

local interior = school:FindFirstChild("V070_SchoolInterior")
if not interior then
    warn("[ASC V073 Signage] V070_SchoolInterior missing")
    return
end

local mainMass = school:FindFirstChild("MainBuilding")
local leftMass = school:FindFirstChild("LeftWing")
local rightMass = school:FindFirstChild("RightWing")
if not (mainMass and leftMass and rightMass and mainMass:IsA("BasePart") and leftMass:IsA("BasePart") and rightMass:IsA("BasePart")) then
    warn("[ASC V073 Signage] school massing missing")
    return
end

local layer = Instance.new("Model")
layer.Name = "V073_SignageOrientationHotfix"
layer:SetAttribute("ASC_Layer", "SIGNAGE_ORIENTATION_HOTFIX")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = school

local directionalSignsFixed = 0
local oppositeFacesAdded = 0
local roomSignsChecked = 0

local function getSurfaceGuiAndLabel(signPart)
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

local function oppositeFace(face)
    if face == Enum.NormalId.Left then return Enum.NormalId.Right end
    if face == Enum.NormalId.Right then return Enum.NormalId.Left end
    if face == Enum.NormalId.Front then return Enum.NormalId.Back end
    if face == Enum.NormalId.Back then return Enum.NormalId.Front end
    if face == Enum.NormalId.Top then return Enum.NormalId.Bottom end
    if face == Enum.NormalId.Bottom then return Enum.NormalId.Top end
    return nil
end

local function normalizedText(text)
    return string.upper((text or ""):gsub("←", ""):gsub("→", ""):gsub("•", "/"):gsub("%s+", " "))
end

local function isRoomOrNavigationLabel(text)
    local t = normalizedText(text)
    return string.find(t, "CLASSROOM", 1, true)
        or string.find(t, "LIBRARY", 1, true)
        or string.find(t, "CANTEEN", 1, true)
        or string.find(t, "TEACHER", 1, true)
        or string.find(t, "ADMIN", 1, true)
        or string.find(t, "CLUB", 1, true)
        or string.find(t, "TOILET", 1, true)
        or string.find(t, "MAIN HALL", 1, true)
end

local function ensureOppositeReadableFace(signPart, gui)
    local opposite = oppositeFace(gui.Face)
    if not opposite then
        return false
    end

    local existing = signPart:FindFirstChild("V073OppositeSignage")
    if existing and existing:IsA("SurfaceGui") then
        existing.Face = opposite
        return true
    end

    local clone = gui:Clone()
    clone.Name = "V073OppositeSignage"
    clone.Face = opposite
    clone.AlwaysOnTop = false
    clone.LightInfluence = gui.LightInfluence
    clone.Parent = signPart
    oppositeFacesAdded += 1
    return true
end

local mainCF = mainMass.CFrame
local libraryTargetX = mainCF:PointToObjectSpace(leftMass.Position).X
local adminTargetX = mainCF:PointToObjectSpace(rightMass.Position).X

local navigationSigns = {}

for _, obj in ipairs(interior:GetDescendants()) do
    if obj:IsA("BasePart") and obj.Name == "RoomSign" then
        local gui, label = getSurfaceGuiAndLabel(obj)
        if gui and label and isRoomOrNavigationLabel(label.Text) then
            roomSignsChecked += 1
            local t = normalizedText(label.Text)
            if string.find(t, "LIBRARY / CANTEEN", 1, true) or string.find(t, "ADMIN / CLUBS", 1, true) then
                table.insert(navigationSigns, {part = obj, gui = gui, label = label})
            else
                -- Room plates can be approached from either direction. Keep the architectural
                -- plate geometry from V0.7.2, but ensure the opposite physical face carries
                -- the same correctly oriented text instead of exposing a reversed/back side.
                ensureOppositeReadableFace(obj, gui)
                obj:SetAttribute("ASC_V073TwoSidedReadable", true)
            end
        end
    end
end

-- Navigation boards are assigned by actual target-wing position in MainBuilding local space.
-- This makes the labels immune to the earlier world/orientation correction and prevents
-- LIBRARY/CANTEEN and ADMIN/CLUBS from ending up on the opposite side.
if #navigationSigns >= 2 then
    table.sort(navigationSigns, function(a, b)
        return mainCF:PointToObjectSpace(a.part.Position).X < mainCF:PointToObjectSpace(b.part.Position).X
    end)

    local function chooseClosest(targetX, excluded)
        local best, bestDistance
        for _, entry in ipairs(navigationSigns) do
            if entry ~= excluded then
                local x = mainCF:PointToObjectSpace(entry.part.Position).X
                local d = math.abs(x - targetX)
                if not bestDistance or d < bestDistance then
                    best = entry
                    bestDistance = d
                end
            end
        end
        return best
    end

    local librarySign = chooseClosest(libraryTargetX, nil)
    local adminSign = chooseClosest(adminTargetX, librarySign)

    local function applyDirectional(entry, targetX, baseText)
        if not entry then return end
        local signX = mainCF:PointToObjectSpace(entry.part.Position).X

        -- Side-mounted sign must face the central hall, not the room interior.
        entry.gui.Face = signX < 0 and Enum.NormalId.Right or Enum.NormalId.Left

        -- Arrow is derived from target wing position, not hard-coded world left/right.
        if targetX < 0 then
            entry.label.Text = "← " .. baseText
        else
            entry.label.Text = baseText .. " →"
        end

        local opposite = entry.part:FindFirstChild("V073OppositeSignage")
        if opposite then
            opposite:Destroy()
        end
        ensureOppositeReadableFace(entry.part, entry.gui)
        entry.part:SetAttribute("ASC_V073DirectionalSignFixed", baseText)
        directionalSignsFixed += 1
    end

    applyDirectional(librarySign, libraryTargetX, "LIBRARY / CANTEEN")
    applyDirectional(adminSign, adminTargetX, "ADMIN / CLUBS")
end

school:SetAttribute("ASC_SignageOrientationPass", VERSION)
school:SetAttribute("ASC_V073DirectionalSignsFixed", directionalSignsFixed)
school:SetAttribute("ASC_V073OppositeFacesAdded", oppositeFacesAdded)
school:SetAttribute("ASC_V073RoomSignsChecked", roomSignsChecked)
root:SetAttribute("ASC_SignageOrientationHotfixV073", true)
Workspace:SetAttribute("ASC_SignageOrientationPass", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] Signage Orientation Hotfix v0.7.3 initialized; directional=%d oppositeFaces=%d checked=%d libraryTargetX=%.2f adminTargetX=%.2f",
    directionalSignsFixed,
    oppositeFacesAdded,
    roomSignsChecked,
    libraryTargetX,
    adminTargetX
))
