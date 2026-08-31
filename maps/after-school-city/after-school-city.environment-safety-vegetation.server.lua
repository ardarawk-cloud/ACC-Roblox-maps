-- AFTER SCHOOL CITY — Environment Safety + Vegetation Grounding v0.8.9
-- Fixes poolside street-light clearance and repairs legacy floating/broken trees.
-- Adds lightweight canopy depth only; roads, pool geometry, gameplay/economy and dedication remain read-only.

local Workspace = game:GetService("Workspace")

local VERSION = "0.8.9-environment-safety-vegetation-1"
local POOL_LAMP_CLEARANCE = 3.0
local TREE_RAY_HEIGHT = 80
local TREE_RAY_DEPTH = 220

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V089 Environment] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_SwimmablePoolPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V089 Environment] AfterSchoolCity root missing")
    return
end
if root:FindFirstChild("V089_EnvironmentPolish") then
    return
end

local roads = root:FindFirstChild("RoadsAndPaths")
local districts = root:FindFirstChild("Districts")
local landscaping = root:FindFirstChild("Landscaping")
local furniture = root:FindFirstChild("StreetFurniture")
local poolLayer = root:FindFirstChild("V088_SwimmablePool")
local park = districts and districts:FindFirstChild("Park")
local parkGround = park and park:FindFirstChild("ParkGround")
local northSouthRoad = roads and roads:FindFirstChild("NorthSouthRoad")
local eastWestRoad = roads and roads:FindFirstChild("EastWestRoad")

if not landscaping or not furniture or not poolLayer then
    warn("[ASC V089 Environment] required landscaping/furniture/pool authority missing")
    return
end
if not northSouthRoad or not eastWestRoad then
    warn("[ASC V089 Environment] protected road authority missing")
    return
end

local westWall = poolLayer:FindFirstChild("PoolWallWest")
local eastWall = poolLayer:FindFirstChild("PoolWallEast")
local northWall = poolLayer:FindFirstChild("PoolWallNorth")
local southWall = poolLayer:FindFirstChild("PoolWallSouth")
if not westWall or not eastWall or not northWall or not southWall then
    warn("[ASC V089 Environment] pool wall authority missing")
    return
end

local roadSnapshot = {
    NSCFrame = northSouthRoad.CFrame,
    NSSize = northSouthRoad.Size,
    NSMaterial = northSouthRoad.Material,
    EWCFrame = eastWestRoad.CFrame,
    EWSize = eastWestRoad.Size,
    EWMaterial = eastWestRoad.Material,
}

local layer = Instance.new("Model")
layer.Name = "V089_EnvironmentPolish"
layer:SetAttribute("ASC_Layer", "ENVIRONMENT_SAFETY_VEGETATION")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

-- =========================================================
-- A. POOLSIDE LIGHT SAFETY
-- Move any legacy StreetLight whose pole sits inside/too close to the pool basin.
-- =========================================================
local poolMinX = westWall.Position.X - westWall.Size.X * 0.5 - POOL_LAMP_CLEARANCE
local poolMaxX = eastWall.Position.X + eastWall.Size.X * 0.5 + POOL_LAMP_CLEARANCE
local poolMinZ = northWall.Position.Z - northWall.Size.Z * 0.5 - POOL_LAMP_CLEARANCE
local poolMaxZ = southWall.Position.Z + southWall.Size.Z * 0.5 + POOL_LAMP_CLEARANCE

local parkMaxX = math.huge
if parkGround and parkGround:IsA("BasePart") then
    parkMaxX = parkGround.Position.X + parkGround.Size.X * 0.5 - 5
end

local movedLights = 0
local function insidePoolClearance(x, z)
    return x >= poolMinX and x <= poolMaxX and z >= poolMinZ and z <= poolMaxZ
end

for _, model in ipairs(furniture:GetChildren()) do
    if model:IsA("Model") and model.Name == "StreetLight" then
        local pole = model:FindFirstChild("Pole")
        if pole and pole:IsA("BasePart") and insidePoolClearance(pole.Position.X, pole.Position.Z) then
            movedLights += 1
            local targetX = math.min(eastWall.Position.X + eastWall.Size.X * 0.5 + 7.0, parkMaxX)
            local targetZ = pole.Position.Z + (movedLights - 1) * 8
            local delta = Vector3.new(targetX - pole.Position.X, 0, targetZ - pole.Position.Z)
            for _, descendant in ipairs(model:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    descendant.CFrame = descendant.CFrame + delta
                end
            end
            model:SetAttribute("ASC_V089PoolSafe", true)
            model:SetAttribute("ASC_V089RelocatedFromX", pole.Position.X - delta.X)
            model:SetAttribute("ASC_V089RelocatedFromZ", pole.Position.Z - delta.Z)
        end
    end
end

-- =========================================================
-- B. TREE GROUNDING + TRUNK REPAIR
-- Legacy helper built cylinders with the long axis in Size.Y before a 90° rotation,
-- leaving trunks visually short/disconnected. Rebuild from crown scale and actual surface.
-- =========================================================
local groundedTrees = 0
local canopyAccentCount = 0

local function getGroundY(treeModel, x, z, fallbackY)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {treeModel, layer}
    params.IgnoreWater = true
    local origin = Vector3.new(x, fallbackY + TREE_RAY_HEIGHT, z)
    local result = Workspace:Raycast(origin, Vector3.new(0, -TREE_RAY_DEPTH, 0), params)
    return result and result.Position.Y or fallbackY
end

local function addCanopyAccent(parentModel, name, center, size, color)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Shape = Enum.PartType.Ball
    p.Size = size
    p.CFrame = CFrame.new(center)
    p.Color = color
    p.Material = Enum.Material.Grass
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = true
    p.Parent = parentModel
    canopyAccentCount += 1
    return p
end

for _, treeModel in ipairs(landscaping:GetChildren()) do
    if treeModel:IsA("Model") and treeModel.Name == "Tree" then
        local trunk = treeModel:FindFirstChild("Trunk")
        local crown = treeModel:FindFirstChild("Crown")
        if trunk and trunk:IsA("BasePart") and crown and crown:IsA("BasePart") then
            local scale = math.clamp(crown.Size.X / 10, 0.5, 1.5)
            local x = crown.Position.X
            local z = crown.Position.Z
            local groundY = getGroundY(treeModel, x, z, math.max(0, trunk.Position.Y - 5 * scale))
            local trunkHeight = 10 * scale
            local trunkDiameter = 2.4 * scale

            trunk.Size = Vector3.new(trunkHeight, trunkDiameter, trunkDiameter)
            trunk.CFrame = CFrame.new(x, groundY + trunkHeight * 0.5 - 0.08, z) * CFrame.Angles(0, 0, math.rad(90))
            trunk.Material = Enum.Material.Wood
            trunk.CanCollide = true
            trunk.CanTouch = false

            crown.Shape = Enum.PartType.Ball
            crown.Size = Vector3.new(10 * scale, 10 * scale, 10 * scale)
            crown.CFrame = CFrame.new(x, groundY + 12 * scale, z)
            crown.Material = Enum.Material.Grass
            crown.CanCollide = false
            crown.CanTouch = false

            -- Two restrained foliage clusters give each tree depth without expensive meshes.
            addCanopyAccent(treeModel, "CrownAccentA", Vector3.new(x + 2.7 * scale, groundY + 11.6 * scale, z + 1.3 * scale), Vector3.new(6.2, 6.2, 6.2) * scale, crown.Color)
            addCanopyAccent(treeModel, "CrownAccentB", Vector3.new(x - 2.2 * scale, groundY + 12.8 * scale, z - 1.8 * scale), Vector3.new(5.4, 5.4, 5.4) * scale, crown.Color)

            treeModel:SetAttribute("ASC_V089Grounded", true)
            treeModel:SetAttribute("ASC_V089GroundY", groundY)
            treeModel:SetAttribute("ASC_V089Scale", scale)
            groundedTrees += 1
        end
    end
end

-- Validate that no StreetLight pole remains inside the pool safety rectangle.
local unsafeLights = 0
for _, model in ipairs(furniture:GetChildren()) do
    if model:IsA("Model") and model.Name == "StreetLight" then
        local pole = model:FindFirstChild("Pole")
        if pole and pole:IsA("BasePart") and insidePoolClearance(pole.Position.X, pole.Position.Z) then
            unsafeLights += 1
        end
    end
end

local roadsUnchanged = northSouthRoad.CFrame == roadSnapshot.NSCFrame
    and northSouthRoad.Size == roadSnapshot.NSSize
    and northSouthRoad.Material == roadSnapshot.NSMaterial
    and eastWestRoad.CFrame == roadSnapshot.EWCFrame
    and eastWestRoad.Size == roadSnapshot.EWSize
    and eastWestRoad.Material == roadSnapshot.EWMaterial

if unsafeLights > 0 or not roadsUnchanged then
    layer:SetAttribute("ASC_V089Pass", false)
    layer:SetAttribute("ASC_V089UnsafeLights", unsafeLights)
    warn(string.format("[ASC V089 Environment] HARD LOCK FAILED unsafeLights=%d roadsUnchanged=%s", unsafeLights, tostring(roadsUnchanged)))
    return
end

layer:SetAttribute("ASC_V089MovedPoolLights", movedLights)
layer:SetAttribute("ASC_V089GroundedTrees", groundedTrees)
layer:SetAttribute("ASC_V089CanopyAccents", canopyAccentCount)
layer:SetAttribute("ASC_V089UnsafeLights", 0)
layer:SetAttribute("ASC_V089RoadsUnchanged", true)
layer:SetAttribute("ASC_V089Pass", true)
root:SetAttribute("ASC_EnvironmentSafetyV089", true)
Workspace:SetAttribute("ASC_EnvironmentSafetyVegetationPass", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V0.8.9 environment pass initialized; movedPoolLights=%d groundedTrees=%d canopyAccents=%d unsafeLights=0",
    movedLights,
    groundedTrees,
    canopyAccentCount
))
