-- BECAK E-BIKE — Vehicle Signal Lights v1.42
-- Lightweight visual feedback for braking and reversing. Visual-only parts never affect physics.

local Workspace = game:GetService('Workspace')

local UPDATE_HZ = 8
local ROOT_NAME = 'BecakEBike'
local tracked = {}

local function makeLamp(model, chassis, name, offset, color)
    local old = model:FindFirstChild(name)
    if old and old:IsA('BasePart') then return old end

    local lamp = Instance.new('Part')
    lamp.Name = name
    lamp.Size = Vector3.new(0.55, 0.28, 0.18)
    lamp.Material = Enum.Material.Neon
    lamp.Color = color
    lamp.Transparency = 0.72
    lamp.CanCollide = false
    lamp.CanTouch = false
    lamp.CanQuery = false
    lamp.Massless = true
    lamp.Anchored = false
    lamp.CFrame = chassis.CFrame * CFrame.new(offset)
    lamp.Parent = model

    local weld = Instance.new('WeldConstraint')
    weld.Part0 = chassis
    weld.Part1 = lamp
    weld.Parent = lamp
    return lamp
end

local function track(model)
    if not model:IsA('Model') or tracked[model] then return end
    if not model:GetAttribute('OwnerUserId') then return end
    local chassis = model.PrimaryPart or model:FindFirstChild('Chassis')
    local seat = model:FindFirstChild('DriverSeat', true)
    if not chassis or not chassis:IsA('BasePart') or not seat or not seat:IsA('VehicleSeat') then return end

    local left = makeLamp(model, chassis, 'RearBrakeLightLeft', Vector3.new(-2.15, 0.25, 4.9), Color3.fromRGB(255, 45, 35))
    local right = makeLamp(model, chassis, 'RearBrakeLightRight', Vector3.new(2.15, 0.25, 4.9), Color3.fromRGB(255, 45, 35))
    local reverse = makeLamp(model, chassis, 'RearReverseLight', Vector3.new(0, 0.18, 4.92), Color3.fromRGB(235, 245, 255))

    tracked[model] = {chassis = chassis, seat = seat, left = left, right = right, reverse = reverse, lastSpeed = 0}
    model:SetAttribute('VehicleSignalsReady', true)
    model:SetAttribute('VehicleSignalsVersion', 'v1.42')
end

local function setLamp(lamp, on, activeTransparency, idleTransparency)
    if not lamp or not lamp.Parent then return end
    lamp.Transparency = on and activeTransparency or idleTransparency
end

local function scan()
    local root = Workspace:FindFirstChild(ROOT_NAME)
    local vehicles = root and root:FindFirstChild('Vehicles')
    if not vehicles then return end
    for _, child in ipairs(vehicles:GetChildren()) do track(child) end
end

scan()
local root = Workspace:FindFirstChild(ROOT_NAME)
local vehicles = root and root:FindFirstChild('Vehicles')
if vehicles then vehicles.ChildAdded:Connect(function(child) task.defer(track, child) end) end

local interval = 1 / UPDATE_HZ
while task.wait(interval) do
    if not vehicles or not vehicles.Parent then
        root = Workspace:FindFirstChild(ROOT_NAME)
        vehicles = root and root:FindFirstChild('Vehicles')
        if vehicles then scan() end
    end

    for model, state in pairs(tracked) do
        if not model.Parent or not state.chassis.Parent then
            tracked[model] = nil
        else
            local velocity = state.chassis.AssemblyLinearVelocity
            local forwardSpeed = state.chassis.CFrame.LookVector:Dot(velocity)
            local speed = math.abs(forwardSpeed)
            local throttle = state.seat.ThrottleFloat
            local decelerating = state.lastSpeed - speed > 0.45
            local braking = speed > 2 and (math.abs(throttle) < 0.05 and decelerating or throttle * forwardSpeed < -0.2)
            local reversing = throttle < -0.05 or forwardSpeed < -2

            setLamp(state.left, braking, 0.08, 0.72)
            setLamp(state.right, braking, 0.08, 0.72)
            setLamp(state.reverse, reversing, 0.12, 0.88)
            model:SetAttribute('BrakeLightsActive', braking)
            model:SetAttribute('ReverseLightActive', reversing)
            state.lastSpeed = speed
        end
    end
end

Workspace:SetAttribute('ACC_BecakVehicleSignals', 'v1.42')
Workspace:SetAttribute('BecakBrakeLights', 'ON')
Workspace:SetAttribute('BecakReverseLight', 'ON')
Workspace:SetAttribute('BecakVehicleSignalsHz', UPDATE_HZ)
print('[BECAK E-BIKE] vehicle signals v1.42 ready • brake + reverse visual feedback • physics-safe')
