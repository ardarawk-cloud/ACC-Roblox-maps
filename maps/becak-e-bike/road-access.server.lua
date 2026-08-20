-- BECAK E-BIKE — road access + drivability hotfix v1.8
-- Makes roads and sidewalks traversable by the low Cargo E-Bike 01 chassis.
-- Dedicated to maps/becak-e-bike only.

local Workspace = game:GetService('Workspace')
local RunService = game:GetService('RunService')

local root = Workspace:WaitForChild('BecakEBike',30)
if not root then return end
local world = root:WaitForChild('Nusakarya',30)
local vehicles = root:WaitForChild('Vehicles',30)
if not world or not vehicles then return end

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
        -- Road is only a visual skin over the continuous playable ground.
        p.CanCollide = false
        p.CanTouch = false
        p.CanQuery = true
        p.Size = Vector3.new(p.Size.X,0.10,p.Size.Z)
        p.CFrame = CFrame.new(p.Position.X,0.055,p.Position.Z) * (p.CFrame - p.CFrame.Position)
        return
    end

    -- The original 1-stud sidewalks formed a hard curb that trapped the low e-bike.
    -- Keep the sidewalk visible, but reduce it to a shallow mountable lip.
    if string.match(p.Name,'^Sidewalk_') then
        p.Size = Vector3.new(p.Size.X,0.16,p.Size.Z)
        p.CFrame = CFrame.new(p.Position.X,0.085,p.Position.Z) * (p.CFrame - p.CFrame.Position)
        p.CanCollide = true
        p.CanTouch = false
        p.CanQuery = true
        p:SetAttribute('BecakMountableCurb',true)
    end
end

for _,x in ipairs(world:GetDescendants()) do tuneRoadSurface(x) end
world.DescendantAdded:Connect(function(x)
    task.defer(function() tuneRoadSurface(x) end)
end)

-- Broad, flat driveway from the HQ/spawn lawn to the nearest road.
local oldDriveway = world:FindFirstChild('HQ_Driveway')
if oldDriveway then oldDriveway:Destroy() end
local driveway = Instance.new('Part')
driveway.Name='HQ_Driveway'
driveway.Size=Vector3.new(24,0.08,72)
driveway.CFrame=CFrame.new(-80,0.05,-50)
driveway.Anchored=true
driveway.CanCollide=false
driveway.CanTouch=false
driveway.CanQuery=true
driveway.Material=Enum.Material.Asphalt
driveway.Color=Color3.fromRGB(52,54,57)
driveway:SetAttribute('Purpose','Seamless HQ road access')
driveway.Parent=world

-- Add explicit curb-cut strips at the four central sidewalk approaches.
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
    p.Parent=curbCuts
end
curbCut('CurbCut_Merdeka_N',Vector3.new(18,0.10,8),CFrame.new(-80,0.06,-25))
curbCut('CurbCut_Merdeka_S',Vector3.new(18,0.10,8),CFrame.new(-80,0.06,25))
curbCut('CurbCut_Nusantara_W',Vector3.new(8,0.10,18),CFrame.new(-25,0.06,-40))
curbCut('CurbCut_Nusantara_E',Vector3.new(8,0.10,18),CFrame.new(25,0.06,-40))

-- Low-friction, stable chassis tune. Movement remains owned by the existing runtime controller.
local function tuneVehicle(model)
    if not model:IsA('Model') then return end
    local chassis=model:FindFirstChild('Chassis') or model.PrimaryPart
    if not chassis or not chassis:IsA('BasePart') then return end
    chassis.CustomPhysicalProperties=PhysicalProperties.new(1.15,0.22,0.06,1,1)
    chassis.CanCollide=true
    model:SetAttribute('RoadAccessTune','v1.8')
end
for _,m in ipairs(vehicles:GetChildren()) do task.defer(tuneVehicle,m) end
vehicles.ChildAdded:Connect(function(m)
    task.wait(.35)
    tuneVehicle(m)
end)

-- Conservative recovery: only rescue vehicles that actually fall below playable ground.
local acc=0
RunService.Heartbeat:Connect(function(dt)
    acc += dt
    if acc < 0.5 then return end
    acc=0
    for _,m in ipairs(vehicles:GetChildren()) do
        local ch=m:IsA('Model') and (m:FindFirstChild('Chassis') or m.PrimaryPart)
        if ch and ch:IsA('BasePart') and ch.Position.Y < -6 then
            ch.AssemblyLinearVelocity=Vector3.zero
            ch.AssemblyAngularVelocity=Vector3.zero
            ch.CFrame=CFrame.new(-80,2.8,-38) * CFrame.Angles(0,math.rad(180),0)
        end
    end
end)

Workspace:SetAttribute('ACC_BecakRoadAccess','v1.8')
Workspace:SetAttribute('ACC_BecakRoadAccessReady',true)
print('[BECAK E-BIKE] Road access v1.8 active: shallow sidewalks + curb cuts + HQ driveway')
