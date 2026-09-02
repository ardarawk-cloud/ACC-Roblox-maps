-- AFTER SCHOOL CITY — V1.1.1 Streetlight Geometry Hotfix
-- Fixes the legacy Cylinder axis/size mismatch that makes streetlight poles render
-- as detached/floating cylindrical pieces while the neon lamp head remains above.
-- Scope: streetlight pole geometry only. No gameplay/UI/music/road/pool changes.

local Workspace = game:GetService("Workspace")

local VERSION = "1.1.1-streetlight-geometry-hotfix-1"
local EXPECTED_STREETLIGHTS = 26
local TARGET_POLE_SIZE = Vector3.new(11, 0.65, 0.65)

local deadline = os.clock() + 45
while Workspace:GetAttribute("ASC_WorldScaffold") == nil and os.clock() < deadline do
    task.wait(0.1)
end

local root = Workspace:FindFirstChild("AfterSchoolCity")
if not root then
    warn("[ASC V111 Streetlight] AfterSchoolCity root missing")
    return
end

local furniture = root:FindFirstChild("StreetFurniture")
if not furniture then
    warn("[ASC V111 Streetlight] StreetFurniture missing")
    return
end

local fixedCount = 0
for _, model in ipairs(furniture:GetChildren()) do
    if model:IsA("Model") and model.Name == "StreetLight" then
        local pole = model:FindFirstChild("Pole")
        if pole and pole:IsA("Part") and pole.Shape == Enum.PartType.Cylinder then
            -- Roblox Cylinder length follows local X. The legacy source used the
            -- 11-stud length on Y and then rotated X -> Y, producing a malformed
            -- detached cylinder. Put the length on X and preserve the exact CFrame.
            pole.Size = TARGET_POLE_SIZE
            fixedCount += 1
        end
    end
end

Workspace:SetAttribute("ASC_StreetlightGeometryHotfix", VERSION)
Workspace:SetAttribute("ASC_StreetlightPoleFixedCount", fixedCount)
Workspace:SetAttribute("ASC_StreetlightExpectedCount", EXPECTED_STREETLIGHTS)

if fixedCount ~= EXPECTED_STREETLIGHTS then
    warn(string.format("[ASC V111 Streetlight] fixed %d streetlights; expected %d", fixedCount, EXPECTED_STREETLIGHTS))
else
    print(string.format("[ASC V111 Streetlight] geometry fixed for all %d streetlights", fixedCount))
end
