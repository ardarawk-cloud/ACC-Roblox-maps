-- AFTER SCHOOL CITY — Locker Clearance Hotfix v0.7.5
-- Moves hall lockers out of classroom doorway clear zones and keeps them flush to solid corridor walls.
-- Preserves V0.7.4 architectural cleanup, signage orientation, road/orientation authority, gameplay and dedication.

local Workspace = game:GetService("Workspace")

local VERSION = "0.7.5-locker-clearance-hotfix-1"

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V075 Locker] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_SchoolArchitecturalCleanupPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V075 Locker] AfterSchoolCity root missing")
    return
end

local districts = root:WaitForChild("Districts", 10)
local school = districts and districts:WaitForChild("SchoolDistrict", 10)
if not school then
    warn("[ASC V075 Locker] SchoolDistrict missing")
    return
end

if school:FindFirstChild("V075_LockerClearanceHotfix") then
    return
end

local interior = school:FindFirstChild("V070_SchoolInterior")
local mainMass = school:FindFirstChild("MainBuilding")
if not interior or not mainMass or not mainMass:IsA("BasePart") then
    warn("[ASC V075 Locker] school interior or MainBuilding missing")
    return
end

local mainInterior = interior:FindFirstChild("MainBuildingInterior")
local lockersModel = mainInterior and mainInterior:FindFirstChild("HallLockers")
if not lockersModel then
    warn("[ASC V075 Locker] HallLockers missing")
    return
end

local layer = Instance.new("Model")
layer.Name = "V075_LockerClearanceHotfix"
layer:SetAttribute("ASC_Layer", "LOCKER_CLEARANCE_HOTFIX")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = school

local mainCF = mainMass.CFrame
local SAFE_Z_SLOTS = {-16.7, -13.3, 0.0, 3.3}
local DOOR_ZONES = {
    {-10.0, -4.0},
    {5.0, 10.5},
}
local WALL_X = 7.58
local LOCKER_SIZE = Vector3.new(0.82, 5.65, 2.25)

local left = {}
local right = {}

for _, locker in ipairs(lockersModel:GetChildren()) do
    if locker:IsA("BasePart") and locker.Name == "LockerBank" then
        local localPos = mainCF:PointToObjectSpace(locker.Position)
        table.insert(localPos.X < 0 and left or right, {
            part = locker,
            localY = localPos.Y,
            localZ = localPos.Z,
        })
    end
end

local function sortByZ(a, b)
    return a.localZ < b.localZ
end

table.sort(left, sortByZ)
table.sort(right, sortByZ)

local moved = 0
local resized = 0
local clearanceViolations = 0

local function applySide(entries, sideSign)
    for index, entry in ipairs(entries) do
        local locker = entry.part
        local slot = SAFE_Z_SLOTS[((index - 1) % #SAFE_Z_SLOTS) + 1]
        locker.Size = LOCKER_SIZE
        locker.CFrame = mainCF * CFrame.new(sideSign * WALL_X, entry.localY, slot)
        locker.Color = Color3.fromRGB(45, 58, 75)
        locker.Material = Enum.Material.Metal
        locker.Reflectance = 0.01
        locker.CanCollide = true
        locker.CanTouch = false
        locker:SetAttribute("ASC_V075LockerWallMounted", true)
        locker:SetAttribute("ASC_V075LockerSlotZ", slot)
        moved += 1
        resized += 1
    end
end

applySide(left, -1)
applySide(right, 1)

local function intersectsDoorZone(z, halfDepth)
    local minZ = z - halfDepth
    local maxZ = z + halfDepth
    for _, zone in ipairs(DOOR_ZONES) do
        if maxZ > zone[1] and minZ < zone[2] then
            return true
        end
    end
    return false
end

for _, locker in ipairs(lockersModel:GetChildren()) do
    if locker:IsA("BasePart") and locker.Name == "LockerBank" then
        local p = mainCF:PointToObjectSpace(locker.Position)
        if intersectsDoorZone(p.Z, locker.Size.Z / 2) then
            clearanceViolations += 1
            locker.CanCollide = false
            locker.Transparency = 1
            locker:SetAttribute("ASC_V075FailClosedDoorClearance", true)
            warn(string.format("[ASC V075 Locker] fail-closed locker still intersects door zone: x=%.2f z=%.2f", p.X, p.Z))
        end
    end
end

school:SetAttribute("ASC_LockerClearancePass", VERSION)
school:SetAttribute("ASC_V075LockersMoved", moved)
school:SetAttribute("ASC_V075LockersResized", resized)
school:SetAttribute("ASC_V075DoorClearanceViolations", clearanceViolations)
root:SetAttribute("ASC_LockerClearanceHotfixV075", true)
Workspace:SetAttribute("ASC_LockerClearancePass", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] Locker Clearance Hotfix v0.7.5 initialized; moved=%d resized=%d clearanceViolations=%d",
    moved,
    resized,
    clearanceViolations
))
