-- AFTER SCHOOL CITY — V1.1.2 Skatepark Light Clearance Hotfix
-- Moves legacy streetlights out of the skate play footprint using the actual
-- runtime SkateGround bounds. No gameplay/UI/music/road/pool authority changes.

local Workspace = game:GetService("Workspace")

local VERSION = "1.1.2-skatepark-light-clearance-1"
local EXPECTED_RELOCATIONS = 4
local CLEARANCE = 12

local deadline = os.clock() + 45
while Workspace:GetAttribute("ASC_StreetlightGeometryHotfix") == nil and os.clock() < deadline do
    task.wait(0.1)
end

local root = Workspace:FindFirstChild("AfterSchoolCity")
if not root then
    warn("[ASC V112 Skate Light] AfterSchoolCity root missing")
    return
end

local districts = root:FindFirstChild("Districts")
local skate = districts and districts:FindFirstChild("SkatePark")
local skateGround = skate and skate:FindFirstChild("SkateGround")
local furniture = root:FindFirstChild("StreetFurniture")

if not skateGround or not skateGround:IsA("BasePart") then
    warn("[ASC V112 Skate Light] SkateGround missing")
    return
end
if not furniture then
    warn("[ASC V112 Skate Light] StreetFurniture missing")
    return
end

local halfX = skateGround.Size.X * 0.5
local halfZ = skateGround.Size.Z * 0.5
local movedCount = 0

local function signOrPositive(value)
    return value < 0 and -1 or 1
end

for _, model in ipairs(furniture:GetChildren()) do
    if model:IsA("Model") and model.Name == "StreetLight" then
        local lamp = model:FindFirstChild("Lamp")
        if lamp and lamp:IsA("BasePart") then
            local localPos = skateGround.CFrame:PointToObjectSpace(lamp.Position)
            local insideX = math.abs(localPos.X) <= halfX
            local insideZ = math.abs(localPos.Z) <= halfZ

            if insideX and insideZ then
                local distanceToXEdge = halfX - math.abs(localPos.X)
                local distanceToZEdge = halfZ - math.abs(localPos.Z)
                local targetLocalX = localPos.X
                local targetLocalZ = localPos.Z

                if distanceToXEdge <= distanceToZEdge then
                    targetLocalX = signOrPositive(localPos.X) * (halfX + CLEARANCE)
                else
                    targetLocalZ = signOrPositive(localPos.Z) * (halfZ + CLEARANCE)
                end

                local targetWorld = skateGround.CFrame:PointToWorldSpace(Vector3.new(targetLocalX, 0, targetLocalZ))
                local delta = Vector3.new(targetWorld.X - lamp.Position.X, 0, targetWorld.Z - lamp.Position.Z)
                model:PivotTo(model:GetPivot() + delta)
                movedCount += 1
            end
        end
    end
end

Workspace:SetAttribute("ASC_SkateparkLightClearance", VERSION)
Workspace:SetAttribute("ASC_SkateparkStreetlightsRelocated", movedCount)
Workspace:SetAttribute("ASC_SkateparkStreetlightExpectedRelocations", EXPECTED_RELOCATIONS)
Workspace:SetAttribute("ASC_SkateparkStreetlightClearanceStuds", CLEARANCE)

if movedCount ~= EXPECTED_RELOCATIONS then
    warn(string.format("[ASC V112 Skate Light] relocated %d streetlights; expected %d", movedCount, EXPECTED_RELOCATIONS))
else
    print(string.format("[ASC V112 Skate Light] relocated all %d skatepark streetlights outside play footprint", movedCount))
end
