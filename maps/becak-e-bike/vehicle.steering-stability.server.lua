-- BECAK E-BIKE — Speed Sensitive Steering Stability v1.37
-- Softens yaw authority as road speed rises so the 3-wheel becak is easier to control on mobile.
-- This does not replace the main vehicle controller; it only retunes the existing BodyGyro.

local Workspace = game:GetService('Workspace')

local root = Workspace:WaitForChild('BecakEBike', 30)
if not root then return end
local vehicles = root:WaitForChild('Vehicles', 30)
if not vehicles then return end

local UPDATE_HZ = 10
local LOW_SPEED = 8
local HIGH_SPEED = 30
local LOW_P = 9000
local HIGH_P = 4300
local LOW_D = 650
local HIGH_D = 1100
local LOW_YAW_TORQUE = 150000
local HIGH_YAW_TORQUE = 82000

local tracked = {}

local function planarSpeed(part)
    local v = part.AssemblyLinearVelocity
    return Vector3.new(v.X, 0, v.Z).Magnitude
end

local function alphaFor(speed)
    return math.clamp((speed - LOW_SPEED) / math.max(1, HIGH_SPEED - LOW_SPEED), 0, 1)
end

local function track(model)
    if not model:IsA('Model') then return end
    local chassis = model.PrimaryPart or model:FindFirstChild('Chassis')
    if not chassis or not chassis:IsA('BasePart') then return end
    local gyro = chassis:FindFirstChildOfClass('BodyGyro')
    if not gyro then return end
    tracked[model] = {chassis = chassis, gyro = gyro}
    model:SetAttribute('SteeringStabilityReady', true)
    model:SetAttribute('SteeringStabilityVersion', 'v1.37')
end

local function untrack(model)
    tracked[model] = nil
end

for _,model in ipairs(vehicles:GetChildren()) do
    task.defer(track, model)
end
vehicles.ChildAdded:Connect(function(model)
    task.defer(track, model)
end)
vehicles.ChildRemoved:Connect(untrack)

local interval = 1 / UPDATE_HZ
while task.wait(interval) do
    for model,state in pairs(tracked) do
        local chassis = state.chassis
        local gyro = state.gyro
        if not model.Parent or not chassis.Parent or not gyro.Parent then
            tracked[model] = nil
        else
            local speed = planarSpeed(chassis)
            local a = alphaFor(speed)
            gyro.P = LOW_P + (HIGH_P - LOW_P) * a
            gyro.D = LOW_D + (HIGH_D - LOW_D) * a
            local yawTorque = LOW_YAW_TORQUE + (HIGH_YAW_TORQUE - LOW_YAW_TORQUE) * a
            gyro.MaxTorque = Vector3.new(0, yawTorque, 0)
            model:SetAttribute('SteeringStabilitySpeed', math.floor(speed * 10 + 0.5) / 10)
            model:SetAttribute('SteeringStabilityScale', math.floor((1 - a * 0.55) * 100 + 0.5) / 100)
        end
    end
end

Workspace:SetAttribute('ACC_BecakSteeringStability', 'v1.37')
Workspace:SetAttribute('BecakSpeedSensitiveSteering', 'ON')
Workspace:SetAttribute('BecakSteeringStabilityHz', UPDATE_HZ)
Workspace:SetAttribute('BecakSteeringHighSpeedP', HIGH_P)
Workspace:SetAttribute('BecakSteeringHighSpeedYawTorque', HIGH_YAW_TORQUE)
print('[BECAK E-BIKE] steering stability v1.37 ready • speed-sensitive yaw damping • mobile friendly')
