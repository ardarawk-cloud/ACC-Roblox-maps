-- BECAK E-BIKE — Ground Contact / Clearance v1.37
-- Replaces the large rectangular chassis as the road-contact surface with three smooth,
-- low-friction spherical contact pods aligned to the visual wheel tracks. This keeps the
-- becak at useful ride height and prevents the chassis edge from catching on curb lips.
-- v1.37 adds a low-frequency self-heal audit so missing/altered contact pods cannot silently
-- degrade drivability after runtime mutations, respawns, or later vehicle-system passes.

local Workspace = game:GetService('Workspace')
local RunService = game:GetService('RunService')

local root = Workspace:WaitForChild('BecakEBike', 30)
if not root then return end
local vehicles = root:WaitForChild('Vehicles', 30)
if not vehicles then return end

local POD_DIAMETER = 3.6
local POD_FRICTION = 0.22
local POD_DENSITY = 0.72
local AUDIT_INTERVAL = 1.0
local PODS = {
    {'GroundContactFrontLeft',  Vector3.new(-2.35, -0.45, -3.10)},
    {'GroundContactFrontRight', Vector3.new( 2.35, -0.45, -3.10)},
    {'GroundContactRear',       Vector3.new( 0.00, -0.45,  3.50)},
}

local function applyPodProperties(pod)
    pod.Shape = Enum.PartType.Ball
    pod.Size = Vector3.new(POD_DIAMETER, POD_DIAMETER, POD_DIAMETER)
    pod.Transparency = 1
    pod.Anchored = false
    pod.CanCollide = true
    pod.CanTouch = false
    pod.CanQuery = false
    pod.CastShadow = false
    pod.CustomPhysicalProperties = PhysicalProperties.new(POD_DENSITY, POD_FRICTION, 0.02, 1, 1)
end

local function ensureWeld(pod, chassis, name)
    local weld = pod:FindFirstChild(name .. '_Weld')
    if weld and weld:IsA('WeldConstraint') and weld.Part0 == chassis and weld.Part1 == pod then return false end
    if weld then weld:Destroy() end
    weld = Instance.new('WeldConstraint')
    weld.Name = name .. '_Weld'
    weld.Part0 = chassis
    weld.Part1 = pod
    weld.Parent = pod
    return true
end

local function makePod(model, chassis, name, offset)
    local pod = model:FindFirstChild(name)
    local created = false
    if not pod or not pod:IsA('BasePart') then
        if pod then pod:Destroy() end
        pod = Instance.new('Part')
        pod.Name = name
        pod.CFrame = chassis.CFrame * CFrame.new(offset)
        pod.Parent = model
        created = true
    end
    applyPodProperties(pod)
    ensureWeld(pod, chassis, name)
    return pod, created
end

local function tuneVehicle(model)
    if not model:IsA('Model') or not model.Parent then return false,0 end
    local chassis = model.PrimaryPart or model:FindFirstChild('Chassis')
    if not chassis or not chassis:IsA('BasePart') then return false,0 end

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

    local count,created = 0,0
    for _,def in ipairs(PODS) do
        local pod,wasCreated = makePod(model, chassis, def[1], def[2])
        if pod then count += 1 end
        if wasCreated then created += 1 end
    end
    model:SetAttribute('GroundContactReady', count == #PODS)
    model:SetAttribute('GroundContactPods', count)
    model:SetAttribute('GroundContactVersion', 'v1.37')
    return count == #PODS,created
end

for _,model in ipairs(vehicles:GetChildren()) do
    task.defer(tuneVehicle, model)
end
vehicles.ChildAdded:Connect(function(model)
    -- Runtime creates/welds the visual vehicle in one function; deferring one task tick lets
    -- Chassis/PrimaryPart exist before contact tuning without polling.
    task.defer(tuneVehicle, model)
end)

local auditAcc = 0
RunService.Heartbeat:Connect(function(dt)
    auditAcc += dt
    if auditAcc < AUDIT_INTERVAL then return end
    auditAcc = 0
    local repaired = 0
    local healthy = 0
    for _,model in ipairs(vehicles:GetChildren()) do
        if model:IsA('Model') then
            local before = model:GetAttribute('GroundContactReady') == true
            local ok,created = tuneVehicle(model)
            if ok then healthy += 1 end
            if created > 0 or (not before and ok) then repaired += math.max(created,1) end
        end
    end
    if repaired > 0 then
        Workspace:SetAttribute('BecakGroundContactAutoRepairs',(tonumber(Workspace:GetAttribute('BecakGroundContactAutoRepairs')) or 0)+repaired)
    end
    Workspace:SetAttribute('BecakGroundContactHealthyVehicles',healthy)
end)

Workspace:SetAttribute('ACC_BecakGroundContact','v1.36') -- compatibility marker for current builder/QC
Workspace:SetAttribute('ACC_BecakGroundContactEnhancement','v1.37')
Workspace:SetAttribute('BecakChassisCollision','OFF')
Workspace:SetAttribute('BecakGroundContactPods',#PODS)
Workspace:SetAttribute('BecakGroundContactShape','BALL')
Workspace:SetAttribute('BecakGroundContactFriction',POD_FRICTION)
Workspace:SetAttribute('BecakGroundContactSelfHeal','ON')
Workspace:SetAttribute('BecakGroundContactAuditHz',1 / AUDIT_INTERVAL)
print('[BECAK E-BIKE] ground contact v1.37 ready • 3 smooth pods • 1 Hz self-heal audit • chassis snag collision OFF')
