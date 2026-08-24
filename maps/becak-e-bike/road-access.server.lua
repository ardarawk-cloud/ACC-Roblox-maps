-- BECAK E-BIKE — road access + drivability hardening v1.37
-- Makes road/grass/sidewalk/curb transitions seamless for the low Cargo E-Bike 01 chassis.
-- v1.35 added lightweight last-safe-road recovery so fallen vehicles return near their route instead of always HQ.
-- v1.36 only records recovery anchors above validated drive surfaces and rejects decorative/off-road anchors.
-- v1.37 adds conservative self-recovery for a fully tipped, stationary Becak after a sustained delay.
-- Dedicated to maps/becak-e-bike only.

local Workspace = game:GetService('Workspace')
local RunService = game:GetService('RunService')

local root = Workspace:WaitForChild('BecakEBike',30)
if not root then return end
local world = root:WaitForChild('Nusakarya',30)
local vehicles = root:WaitForChild('Vehicles',30)
if not world or not vehicles then return end

local FLIP_RECOVERY_DELAY=5
local FLIP_UP_DOT=0.15
local FLIP_MAX_SPEED=2.5
local seamParts = 0
local seamRegistry = {}
local lastSafeCFrame = setmetatable({}, {__mode='k'})
local lastSafeSurface = setmetatable({}, {__mode='k'})
local tippedSince = setmetatable({}, {__mode='k'})

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
        flattenVisualSurface(p,'BecakRoadSkin')
        return
    end
    if isRoadEdgePart(p) then
        flattenVisualSurface(p,'BecakSeamlessRoadEdge')
        p:SetAttribute('BecakSeamlessSidewalk',true)
        p:SetAttribute('BecakMountableCurb',true)
        registerSeamPart(p)
    end
end

for _,x in ipairs(world:GetDescendants()) do tuneRoadSurface(x) end
world.DescendantAdded:Connect(function(x) task.defer(function() tuneRoadSurface(x) end) end)
world.DescendantRemoving:Connect(function(x)
    if seamRegistry[x] then seamRegistry[x]=nil seamParts=math.max(0,seamParts-1) end
end)

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

local curbCuts = world:FindFirstChild('BecakCurbCuts')
if curbCuts then curbCuts:Destroy() end
curbCuts=Instance.new('Folder')
curbCuts.Name='BecakCurbCuts'
curbCuts.Parent=world
local function curbCut(name,size,cf)
    local p=Instance.new('Part')
    p.Name=name p.Size=size p.CFrame=cf p.Anchored=true
    p.CanCollide=false p.CanTouch=false p.CanQuery=true
    p.Material=Enum.Material.Concrete p.Color=Color3.fromRGB(150,150,145)
    p:SetAttribute('BecakCurbCut',true) p:SetAttribute('BecakDriveSurface',true)
    p.Parent=curbCuts
end
curbCut('CurbCut_Merdeka_N',Vector3.new(26,0.08,12),CFrame.new(-80,0.05,-25))
curbCut('CurbCut_Merdeka_S',Vector3.new(26,0.08,12),CFrame.new(-80,0.05,25))
curbCut('CurbCut_Nusantara_W',Vector3.new(12,0.08,26),CFrame.new(-25,0.05,-40))
curbCut('CurbCut_Nusantara_E',Vector3.new(12,0.08,26),CFrame.new(25,0.05,-40))

local rayParams=RaycastParams.new()
rayParams.FilterType=Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater=true

local function uprightRoadCFrame(chassis,groundY)
    local look=chassis.CFrame.LookVector
    local flat=Vector3.new(look.X,0,look.Z)
    if flat.Magnitude < 0.05 then flat=Vector3.new(0,0,-1) else flat=flat.Unit end
    local y=math.max(2.4,(groundY or chassis.Position.Y)+2.15)
    local pos=Vector3.new(chassis.Position.X,y,chassis.Position.Z)
    return CFrame.lookAt(pos,pos+flat)
end

local function isValidatedDriveSurface(hit)
    if not hit or not hit:IsA('BasePart') or not hit:IsDescendantOf(world) then return false end
    if hit:GetAttribute('BecakDriveSurface')==true or hit:GetAttribute('BecakRoadSkin')==true or hit:GetAttribute('BecakCurbCut')==true then return true end
    return string.match(hit.Name,'^Jalan_') ~= nil and not string.find(hit.Name,'_Mark',1,true)
end

local function validatedRoadAnchor(model,chassis)
    rayParams.FilterDescendantsInstances={model}
    local result=Workspace:Raycast(chassis.Position+Vector3.new(0,3,0),Vector3.new(0,-10,0),rayParams)
    if not result or not isValidatedDriveSurface(result.Instance) then return nil,nil end
    if result.Normal.Y < 0.72 then return nil,nil end
    return uprightRoadCFrame(chassis,result.Position.Y),result.Instance
end

local function recoverVehicle(model,chassis,safe,surfaceName,reason)
    chassis.AssemblyLinearVelocity=Vector3.zero
    chassis.AssemblyAngularVelocity=Vector3.zero
    local destination=(safe or (CFrame.new(-80,2.8,-38)*CFrame.Angles(0,math.rad(180),0))) + Vector3.new(0,1.2,0)
    model:PivotTo(destination)
    tippedSince[model]=nil
    Workspace:SetAttribute('BecakLastSafeRecoveries',(tonumber(Workspace:GetAttribute('BecakLastSafeRecoveries')) or 0)+1)
    Workspace:SetAttribute('BecakLastRecoverySurface',surfaceName or 'HQ_FALLBACK')
    Workspace:SetAttribute('BecakLastRecoveryReason',reason)
end

local function tuneVehicle(model)
    if not model:IsA('Model') then return end
    local chassis=model:FindFirstChild('Chassis') or model.PrimaryPart
    if not chassis or not chassis:IsA('BasePart') then return end
    chassis.CustomPhysicalProperties=PhysicalProperties.new(1.10,0.16,0.04,1,1)
    chassis.CanCollide=true
    model:SetAttribute('RoadAccessTune','v1.37')
    if chassis.Position.Y > -1 and chassis.Position.Y < 30 and chassis.CFrame.UpVector.Y > 0.45 then
        local safe,surface=validatedRoadAnchor(model,chassis)
        if safe then lastSafeCFrame[model]=safe lastSafeSurface[model]=surface.Name end
    end
end
for _,m in ipairs(vehicles:GetChildren()) do task.defer(tuneVehicle,m) end
vehicles.ChildAdded:Connect(function(m) task.wait(.35) tuneVehicle(m) end)
vehicles.ChildRemoved:Connect(function(m) lastSafeCFrame[m]=nil lastSafeSurface[m]=nil tippedSince[m]=nil end)

local auditAcc=0
local recoveryAcc=0
RunService.Heartbeat:Connect(function(dt)
    auditAcc += dt
    recoveryAcc += dt
    if auditAcc >= 0.5 then
        auditAcc=0
        local repaired,stale=0,0
        for p in pairs(seamRegistry) do
            if not p.Parent or not p:IsDescendantOf(world) then
                seamRegistry[p]=nil seamParts=math.max(0,seamParts-1) stale+=1
            elseif p:IsA('BasePart') and p.CanCollide then
                flattenVisualSurface(p,'BecakSeamlessRoadEdge')
                p:SetAttribute('BecakSeamlessSidewalk',true)
                p:SetAttribute('BecakMountableCurb',true)
                repaired+=1
            end
        end
        if repaired>0 then Workspace:SetAttribute('BecakRoadEdgeAutoRepairs',(tonumber(Workspace:GetAttribute('BecakRoadEdgeAutoRepairs')) or 0)+repaired) end
        Workspace:SetAttribute('BecakRoadEdgeRegistrySize',seamParts)
        Workspace:SetAttribute('BecakRoadEdgeRegistryStaleCleanups',(tonumber(Workspace:GetAttribute('BecakRoadEdgeRegistryStaleCleanups')) or 0)+stale)
    end
    if recoveryAcc >= 0.5 then
        recoveryAcc=0
        local now=os.clock()
        for _,m in ipairs(vehicles:GetChildren()) do
            local ch=m:IsA('Model') and (m:FindFirstChild('Chassis') or m.PrimaryPart)
            if ch and ch:IsA('BasePart') then
                local upDot=ch.CFrame.UpVector.Y
                local speed=ch.AssemblyLinearVelocity.Magnitude
                if ch.Position.Y >= -1 and ch.Position.Y < 30 and upDot > 0.45 then
                    tippedSince[m]=nil
                    local safe,surface=validatedRoadAnchor(m,ch)
                    if safe then
                        lastSafeCFrame[m]=safe
                        lastSafeSurface[m]=surface.Name
                        m:SetAttribute('LastSafeDriveSurface',surface.Name)
                    end
                elseif ch.Position.Y < -6 then
                    recoverVehicle(m,ch,lastSafeCFrame[m],lastSafeSurface[m],'FALLEN_WORLD')
                elseif ch.Position.Y >= -1 and ch.Position.Y < 30 and upDot < FLIP_UP_DOT and speed <= FLIP_MAX_SPEED then
                    tippedSince[m]=tippedSince[m] or now
                    local tippedFor=now-tippedSince[m]
                    m:SetAttribute('TippedRecoverySeconds',math.floor(tippedFor*10)/10)
                    if tippedFor>=FLIP_RECOVERY_DELAY then
                        recoverVehicle(m,ch,lastSafeCFrame[m],lastSafeSurface[m],'TIPPED_STATIONARY')
                        m:SetAttribute('TippedRecoverySeconds',0)
                        Workspace:SetAttribute('BecakStationaryFlipRecoveries',(tonumber(Workspace:GetAttribute('BecakStationaryFlipRecoveries')) or 0)+1)
                    end
                else
                    tippedSince[m]=nil
                    m:SetAttribute('TippedRecoverySeconds',0)
                end
            end
        end
    end
end)

Workspace:SetAttribute('ACC_BecakRoadAccess','v1.34') -- compatibility marker
Workspace:SetAttribute('ACC_BecakRoadAccessEnhancement','v1.36') -- build compatibility marker
Workspace:SetAttribute('ACC_BecakRoadAccessDrivability','v1.37')
Workspace:SetAttribute('ACC_BecakRoadAccessReady',true)
Workspace:SetAttribute('ACC_BecakSidewalkCollision','OFF')
Workspace:SetAttribute('ACC_BecakGenericCurbCollision','OFF')
Workspace:SetAttribute('ACC_BecakRoadEdgeAudit','ON')
Workspace:SetAttribute('ACC_BecakRoadEdgeAncestorAudit','ON')
Workspace:SetAttribute('ACC_BecakRoadEdgeAliasAudit','ON')
Workspace:SetAttribute('ACC_BecakRoadEdgeCachedAudit','ON')
Workspace:SetAttribute('BecakLastSafeRoadRecovery','ON')
Workspace:SetAttribute('BecakValidatedRecoverySurface','ON')
Workspace:SetAttribute('BecakRecoveryRaycastDepth',10)
Workspace:SetAttribute('BecakStationaryFlipRecovery','ON')
Workspace:SetAttribute('BecakStationaryFlipRecoveryDelaySeconds',FLIP_RECOVERY_DELAY)
Workspace:SetAttribute('BecakStationaryFlipMaxSpeed',FLIP_MAX_SPEED)
Workspace:SetAttribute('BecakRoadEdgeSeamParts',seamParts)
Workspace:SetAttribute('BecakRoadEdgeRegistrySize',seamParts)
Workspace:SetAttribute('BecakRoadEdgeAuditHz',2)
print('[BECAK E-BIKE] Road access v1.37 active: validated road recovery + conservative stationary flip self-recovery')