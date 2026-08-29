-- AFTER SCHOOL CITY — V0.8 Student Row Interior Sign Finalize
-- Runs only after the V0.8 interior pass completes and faces back-wall signage inward.
-- Presentation only; no gameplay/economy/purchase authority.

local Workspace = game:GetService("Workspace")

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V080 SignFinalize] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_StudentRowShopInteriorsPass", 45) then
    return
end

local root = Workspace:FindFirstChild("AfterSchoolCity")
if not root then return end

local fixed = 0
for _, descendant in ipairs(root:GetDescendants()) do
    if descendant:IsA("SurfaceGui") and descendant.Name == "V080InteriorSignage" then
        local plate = descendant.Parent
        if plate and plate:IsA("BasePart") and plate.Name == "InteriorSign" then
            -- InteriorSign is mounted on the local back wall; Back (+local Z) faces the room.
            descendant.Face = Enum.NormalId.Back
            plate:SetAttribute("ASC_V080SignFacesInterior", true)
            fixed += 1
        end
    end
end

root:SetAttribute("ASC_V080InteriorSignsFinalized", fixed)
Workspace:SetAttribute("ASC_StudentRowInteriorSignFinalizePass", "0.8.0-student-row-shop-interiors-1")
print(string.format("[AFTER SCHOOL CITY] V0.8 interior signage finalized; fixed=%d", fixed))
