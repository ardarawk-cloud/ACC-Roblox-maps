-- AFTER SCHOOL CITY — Exterior Locker Cleanup v0.7.6
-- Removes the legacy School Life v0.3 LockerBreezeway from the exterior campus.
-- Interior hall lockers from V0.7.5 are intentionally preserved.
-- No road, orientation, gameplay, economy, persistence, clubs, monetization,
-- dedication, school interior layout, or signage authority is introduced here.

local Workspace = game:GetService("Workspace")

local VERSION = "0.7.6-exterior-locker-cleanup-1"

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V076 ExteriorLocker] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_LockerClearancePass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V076 ExteriorLocker] AfterSchoolCity root missing")
    return
end

local districts = root:WaitForChild("Districts", 10)
local school = districts and districts:WaitForChild("SchoolDistrict", 10)
if not school then
    warn("[ASC V076 ExteriorLocker] SchoolDistrict missing")
    return
end

if school:GetAttribute("ASC_ExteriorLockerCleanupPass") == VERSION then
    return
end

local removedModels = 0
local removedLockerParts = 0

-- Legacy source authority: V03_SchoolLife/LockerBreezeway.
-- Remove by exact model name anywhere under SchoolDistrict so later orientation/reparenting
-- cannot leave a duplicate exterior locker bank behind.
local targets = {}
for _, obj in ipairs(school:GetDescendants()) do
    if obj:IsA("Model") and obj.Name == "LockerBreezeway" then
        table.insert(targets, obj)
    end
end

for _, model in ipairs(targets) do
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("BasePart") and (child.Name == "Locker" or child.Name == "LockerVent") then
            removedLockerParts += 1
        end
    end
    model:Destroy()
    removedModels += 1
end

-- Fail-closed verification: the exterior legacy model must not exist after this pass.
local residual = school:FindFirstChild("LockerBreezeway", true)
if residual then
    warn("[ASC V076 ExteriorLocker] residual LockerBreezeway detected; forcing removal")
    residual:Destroy()
    removedModels += 1
end

school:SetAttribute("ASC_ExteriorLockerCleanupPass", VERSION)
school:SetAttribute("ASC_V076ExteriorLockerModelsRemoved", removedModels)
school:SetAttribute("ASC_V076ExteriorLockerPartsRemoved", removedLockerParts)
root:SetAttribute("ASC_ExteriorLockerCleanupV076", true)
Workspace:SetAttribute("ASC_ExteriorLockerCleanupPass", VERSION)

print(string.format("[AFTER SCHOOL CITY] Exterior Locker Cleanup v0.7.6 initialized; modelsRemoved=%d lockerPartsRemoved=%d", removedModels, removedLockerParts))
