-- BECAK E-BIKE — Ground Contact / Clearance v1.36
-- Replaces the large rectangular chassis as the road-contact surface with three smooth,
-- low-friction spherical contact pods aligned to the visual wheel tracks. This keeps the
-- becak at useful ride height and prevents the chassis edge from catching on curb lips.

local Workspace = game:GetService('Workspace')

local root = Workspace:WaitForChild('BecakEBike', 30)
if not root then return end
local vehicles = root:WaitForChild('Vehicles', 30)
if not vehicles then return end

local POD_DIAMETER = 3.6
local POD_FRICTION = 0.22
local POD_DENSITY = 0.72
local PODS = {
    {'GroundContactFrontLeft',  Vector3.new(-2.35, -0.45, -3.10)},
    {'GroundContactFrontRight', Vector3.new( 2.35, -0.45, -3.10)},
    {'GroundContactRear',       Vector3.new( 0.00, -0.45,  3.50)},
}

local function makePod(model, chassis, name, offset)
    local old = model:FindFirstChild(name)
    if old and old:IsA('BasePart') then return old end

    local pod = Instance.new('Part')
    pod.Name = name
    pod.Shape = Enum.PartType.Ball
    pod.Size = Vector3.new(POD_DIAMETER, POD_DIAMETER, POD_DIAMETER)
    pod.CFrame = chassis.CFrame * CFrame.new(offset)
    pod.Transparency = 1
    pod.Anchored = false
    pod.CanCollide = true
    pod.CanTouch = false
    pod.CanQuery = false
    pod.CastShadow = false
    pod.CustomPhysicalProperties = PhysicalProperties.new(POD_DENSITY, POD_FRICTION, 0.02, 1, 1)
    pod.Parent = model

    local weld = Instance.new('WeldConstraint')
    weld.Name = name .. '_Weld'
    weld.Part0 = chassis
    weld.Part1 = pod
    weld.Parent = pod
    return pod
end

local function tuneVehicle(model)
    if not model:IsA('Model') or not model.Parent then return end
    local chassis = model.PrimaryPart or model:FindFirstChild('Chassis')
    if not chassis or not chassis:IsA('BasePart') then return end

    -- The prototype originally drove on the full 6x10 rectangular chassis. Its front/bottom
    -- edges can catch curb geometry even when the visible wheels look clear. Let the three
    -- smooth pods own road collision instead.
    chassis.CanCollide = false
    chassis.CanTouch = false
    chassis.CustomPhysicalProperties = PhysicalProperties.new(1.0, 0.20, 0.02, 1, 1)

    for _,obj in ipairs(model:GetDescendants()) do
        if obj:IsA('BasePart') and (obj.Name == 'FrontWheel' or obj.Name == 'RearWheel') then
            obj.CanCollide = false
            obj.CanTouch = false
            obj.CanQuery = false
        end
    end

    local count = 0
    for _,def in ipairs(PODS) do
        if makePod(model, chassis, def[1], def[2]) then count += 1 end
    end
    model:SetAttribute('GroundContactReady', count == #PODS)
    model:SetAttribute('GroundContactPods', count)
    model:SetAttribute('GroundContactVersion', 'v1.36')
end

for _,model in ipairs(vehicles:GetChildren()) do
    task.defer(tuneVehicle, model)
end
vehicles.ChildAdded:Connect(function(model)
    -- Runtime creates/welds the visual vehicle in one function; deferring one task tick lets
    -- Chassis/PrimaryPart exist before contact tuning without polling.
    task.defer(tuneVehicle, model)
end)

Workspace:SetAttribute('ACC_BecakGroundContact','v1.36')
Workspace:SetAttribute('BecakChassisCollision','OFF')
Workspace:SetAttribute('BecakGroundContactPods',#PODS)
Workspace:SetAttribute('BecakGroundContactShape','BALL')
Workspace:SetAttribute('BecakGroundContactFriction',POD_FRICTION)
print('[BECAK E-BIKE] ground contact v1.36 ready • 3 smooth pods • chassis snag collision OFF')
