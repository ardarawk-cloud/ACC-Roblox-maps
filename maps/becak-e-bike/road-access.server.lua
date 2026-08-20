-- BECAK E-BIKE — road access + drivability hotfix v1.6
-- Removes curb-like collision from visual road slabs so the low e-bike chassis can enter/leave roads cleanly.
-- Dedicated to maps/becak-e-bike only.

local Workspace = game:GetService('Workspace')
local RunService = game:GetService('RunService')

local root = Workspace:WaitForChild('BecakEBike',30)
if not root then return end
local world = root:WaitForChild('Nusakarya',30)
local vehicles = root:WaitForChild('Vehicles',30)
if not world or not vehicles then return end

local function flattenRoadPart(p)
    if not p:IsA('BasePart') then return end
    if not string.match(p.Name,'^Jalan_') then return end
    if string.find(p.Name,'_Mark',1,true) then
        p.CanCollide = false
        p.CanTouch = false
        p.CanQuery = true
        p.CFrame = CFrame.new(p.Position.X,0.13,p.Position.Z) * (p.CFrame - p.CFrame.Position)
        return
    end
    -- Road is a visual skin over the continuous ground, not a raised curb.
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = true
    p.Size = Vector3.new(p.Size.X,0.10,p.Size.Z)
    p.CFrame = CFrame.new(p.Position.X,0.055,p.Position.Z) * (p.CFrame - p.CFrame.Position)
end

for _,x in ipairs(world:GetDescendants()) do flattenRoadPart(x) end
world.DescendantAdded:Connect(function(x)
    task.defer(function() flattenRoadPart(x) end)
end)

-- HQ driveway gives a clear visual route from spawn/garage area to Jalan Merdeka.
local oldDriveway = world:FindFirstChild('HQ_Driveway')
if oldDriveway then oldDriveway:Destroy() end
local driveway = Instance.new('Part')
driveway.Name='HQ_Driveway'
driveway.Size=Vector3.new(18,0.08,58)
driveway.CFrame=CFrame.new(-80,0.05,-50)
driveway.Anchored=true
driveway.CanCollide=false
driveway.CanTouch=false
driveway.Material=Enum.Material.Asphalt
driveway.Color=Color3.fromRGB(52,54,57)
driveway:SetAttribute('Purpose','Seamless HQ road access')
driveway.Parent=world

-- A low-friction, stable chassis tune. Movement remains owned by the existing runtime controller.
local function tuneVehicle(model)
    if not model:IsA('Model') then return end
    local chassis=model:FindFirstChild('Chassis') or model.PrimaryPart
    if not chassis or not chassis:IsA('BasePart') then return end
    chassis.CustomPhysicalProperties=PhysicalProperties.new(1.15,0.28,0.08,1,1)
    chassis.CanCollide=true
    model:SetAttribute('RoadAccessTune','v1.6')
end
for _,m in ipairs(vehicles:GetChildren()) do task.defer(tuneVehicle,m) end
vehicles.ChildAdded:Connect(function(m)
    task.wait(.35)
    tuneVehicle(m)
end)

-- Conservative recovery: only rescue vehicles that actually fall below the playable ground.
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

Workspace:SetAttribute('ACC_BecakRoadAccess','v1.6')
Workspace:SetAttribute('ACC_BecakRoadAccessReady',true)
print('[BECAK E-BIKE] Road access v1.6 active: flat roads + HQ driveway + chassis tune')
