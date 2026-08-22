-- BECAK E-BIKE — road access + drivability hardening v1.34
-- Makes road/grass/sidewalk/curb transitions seamless for the low Cargo E-Bike 01 chassis.
-- Dedicated to maps/becak-e-bike only.

local Workspace = game:GetService('Workspace')
local RunService = game:GetService('RunService')

local root = Workspace:WaitForChild('BecakEBike',30)
if not root then return end
local world = root:WaitForChild('Nusakarya',30)
local vehicles = root:WaitForChild('Vehicles',30)
if not world or not vehicles then return end

local seamParts = 0
local seamRegistry = {}

local function isRoadEdgeName(name)
    local n = string.lower(name)
    return string.match(name,'^Sidewalk_') ~= nil
        or string.find(n,'sidewalk',1,true) ~= nil
        or string.find(n,'trotoar',1,true) ~= nil
        or string.find(n,'pavement',1,true) ~= nil
        or string.find(n,'footpath',1,true) ~= nil
        or string.find(n,'walkway',1,true) ~= nil
        or string.find(n,'walk_path',1,true) ~= nil
        or string.find(n,'pedestrian_path',1,true) ~= nil
        or string.find(n,'kerbstone',1,true) ~= nil
        or string.find(n,'curbstone',1,true) ~= nil
        or string.find(n,'roadedge',1,true) ~= nil
        or string.find(n,'road_edge',1,true) ~= nil
        or string.match(n,'^curb') ~= nil
        or string.match(n,'^kerb') ~= nil
        or string.find(n,'curbcut',1,true) ~= nil
        or string.find(n,'curb_cut',1,true) ~= nil
end

-- City kits often use generic child names such as "Part" inside a Folder/Model named
-- Trotoar, Sidewalk, Curb, or Pavement. Checking ancestors closes that hole without
-- disabling collision on unrelated buildings, walls, props, or fences.
local function isRoadEdgePart(p)
    if isRoadEdgeName(p.Name) then return true end
    local ancestor = p.Parent
    while ancestor and ancestor ~= world do
        if isRoadEdgeName(ancestor.Name) then return true end
        ancestor = ancestor.Parent
    end
    return false
end

local function flattenVisualSurface(p, attributeName)
    p.Size = Vector3.new(p.Size.X,0.10,p.Size.Z)
    p.CFrame = CFrame.new(p.Position.X,0.055,p.Position.Z) * (p.CFrame - p.CFrame.Position)
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = true
    if attributeName then p:SetAttribute(attributeName,true) end
    p:SetAttribute('BecakDriveSurface',true)
end

local function registerSeamPart(p)
    if seamRegistry[p] then return false end
    seamRegistry[p] = true
    seamParts += 1
    return true
end

local function tuneRoadSurface(p)
    if not p:IsA('BasePart') then return end

    if string.match(p.Name,'^Jalan_') then
        if string.find(p.Name,'_Mark',1,true) then
            p.CanCollide = false
            p.CanTouch = false
            p.CanQuery = true
            p.CFrame = CFrame.new(p.Position.X,0.13,p.Position.Z) * (p.CFrame - p.CFrame.Position)
            return
        end
        -- Road is a visual skin over the continuous playable ground.
        flattenVisualSurface(p,'BecakRoadSkin')
        return
    end

    -- v1.34: normalize curb/trotoar aliases on the part OR any parent container, then
    -- keep a cached registry so the runtime audit never rescans the entire city tree.
    if isRoadEdgePart(p) then
        flattenVisualSurface(p,'BecakSeamlessRoadEdge')
        p:SetAttribute('BecakSeamlessSidewalk',true)
        p:SetAttribute('BecakMountableCurb',true)
        registerSeamPart(p)
    end
end

for _,x in ipairs(world:GetDescendants()) do tuneRoadSurface(x) end
world.DescendantAdded:Connect(function(x)
    task.defer(function() tuneRoadSurface(x) end)
end)
world.DescendantRemoving:Connect(function(x)
    if seamRegistry[x] then
        seamRegistry[x] = nil
        seamParts = math.max(0,seamParts-1)
    end
end)

-- Broad, flat driveway from the HQ/spawn lawn to the nearest road.
local oldDriveway = world:FindFirstChild('HQ_Driveway')
if oldDriveway then oldDriveway:Destroy() end
local driveway = Instance.new('Part')
driveway.Name='HQ_Driveway'
driveway.Size=Vector3.new(36,0.08,88)
driveway.CFrame=CFrame.new(-80,0.05,-47)
driveway.Anchored=true
driveway.CanCollide=false
driveway.CanTouch=false
driveway.CanQuery=true
driveway.Material=Enum.Material.Asphalt
driveway.Color=Color3.fromRGB(52,54,57)
driveway:SetAttribute('Purpose','Seamless HQ road access')
driveway:SetAttribute('BecakDriveSurface',true)
driveway.Parent=world

-- Visible curb-cut strips remain navigation/readability cues, but never block physics.
local curbCuts = world:FindFirstChild('BecakCurbCuts')
if curbCuts then curbCuts:Destroy() end
curbCuts=Instance.new('Folder')
curbCuts.Name='BecakCurbCuts'
curbCuts.Parent=world
local function curbCut(name,size,cf)
    local p=Instance.new('Part')
    p.Name=name
    p.Size=size
    p.CFrame=cf
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=true
    p.Material=Enum.Material.Concrete
    p.Color=Color3.fromRGB(150,150,145)
    p:SetAttribute('BecakCurbCut',true)
    p:SetAttribute('BecakDriveSurface',true)
    p.Parent=curbCuts
end
curbCut('CurbCut_Merdeka_N',Vector3.new(26,0.08,12),CFrame.new(-80,0.05,-25))
curbCut('CurbCut_Merdeka_S',Vector3.new(26,0.08,12),CFrame.new(-80,0.05,25))
curbCut('CurbCut_Nusantara_W',Vector3.new(12,0.08,26),CFrame.new(-25,0.05,-40))
curbCut('CurbCut_Nusantara_E',Vector3.new(12,0.08,26),CFrame.new(25,0.05,-40))

-- Low-friction, stable chassis tune. Movement remains owned by the existing runtime controller.
local function tuneVehicle(model)
    if not model:IsA('Model') then return end
    local chassis=model:FindFirstChild('Chassis') or model.PrimaryPart
    if not chassis or not chassis:IsA('BasePart') then return end
    chassis.CustomPhysicalProperties=PhysicalProperties.new(1.10,0.16,0.04,1,1)
    chassis.CanCollide=true
    model:SetAttribute('RoadAccessTune','v1.34')
end
for _,m in ipairs(vehicles:GetChildren()) do task.defer(tuneVehicle,m) end
vehicles.ChildAdded:Connect(function(m)
    task.wait(.35)
    tuneVehicle(m)
end)

-- Runtime seam audit: audit only the known road-edge registry instead of calling
-- world:GetDescendants() every 0.5s. This keeps self-healing behavior while avoiding
-- repeated O(world-size) scans as Nusakarya grows.
local auditAcc=0
local recoveryAcc=0
RunService.Heartbeat:Connect(function(dt)
    auditAcc += dt
    recoveryAcc += dt

    if auditAcc >= 0.5 then
        auditAcc=0
        local repaired=0
        local stale=0
        for p in pairs(seamRegistry) do
            if not p.Parent or not p:IsDescendantOf(world) then
                seamRegistry[p] = nil
                seamParts = math.max(0,seamParts-1)
                stale += 1
            elseif p:IsA('BasePart') and p.CanCollide then
                flattenVisualSurface(p,'BecakSeamlessRoadEdge')
                p:SetAttribute('BecakSeamlessSidewalk',true)
                p:SetAttribute('BecakMountableCurb',true)
                repaired += 1
            end
        end
        if repaired > 0 then
            Workspace:SetAttribute('BecakRoadEdgeAutoRepairs',(tonumber(Workspace:GetAttribute('BecakRoadEdgeAutoRepairs')) or 0)+repaired)
        end
        Workspace:SetAttribute('BecakRoadEdgeRegistrySize',seamParts)
        Workspace:SetAttribute('BecakRoadEdgeRegistryStaleCleanups',(tonumber(Workspace:GetAttribute('BecakRoadEdgeRegistryStaleCleanups')) or 0)+stale)
    end

    -- Conservative recovery: only rescue vehicles that actually fall below playable ground.
    if recoveryAcc >= 0.5 then
        recoveryAcc=0
        for _,m in ipairs(vehicles:GetChildren()) do
            local ch=m:IsA('Model') and (m:FindFirstChild('Chassis') or m.PrimaryPart)
            if ch and ch:IsA('BasePart') and ch.Position.Y < -6 then
                ch.AssemblyLinearVelocity=Vector3.zero
                ch.AssemblyAngularVelocity=Vector3.zero
                ch.CFrame=CFrame.new(-80,2.8,-38) * CFrame.Angles(0,math.rad(180),0)
            end
        end
    end
end)

Workspace:SetAttribute('ACC_BecakRoadAccess','v1.34')
Workspace:SetAttribute('ACC_BecakRoadAccessReady',true)
Workspace:SetAttribute('ACC_BecakSidewalkCollision','OFF')
Workspace:SetAttribute('ACC_BecakGenericCurbCollision','OFF')
Workspace:SetAttribute('ACC_BecakRoadEdgeAudit','ON')
Workspace:SetAttribute('ACC_BecakRoadEdgeAncestorAudit','ON')
Workspace:SetAttribute('ACC_BecakRoadEdgeAliasAudit','ON')
Workspace:SetAttribute('ACC_BecakRoadEdgeCachedAudit','ON')
Workspace:SetAttribute('BecakRoadEdgeSeamParts',seamParts)
Workspace:SetAttribute('BecakRoadEdgeRegistrySize',seamParts)
Workspace:SetAttribute('BecakRoadEdgeAuditHz',2)
print('[BECAK E-BIKE] Road access v1.34 active: cached road-edge registry + seamless curb/trotoar self-heal')