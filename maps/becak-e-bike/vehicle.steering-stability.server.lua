-- BECAK E-BIKE — Speed Sensitive Steering Stability v1.42
-- Softens yaw authority as road speed rises so the 3-wheel becak is easier to control on mobile.
-- v1.38 cargo-aware damping. v1.39 condition-aware damping. v1.40 sharp-corner anti-tip.
-- v1.41 rapid steering-reversal damping. v1.42 keeps occupied behavior at 10 Hz but
-- throttles unoccupied vehicles to 2 Hz to reduce idle server work without changing handling.

local Workspace = game:GetService('Workspace')

local root = Workspace:WaitForChild('BecakEBike', 30)
if not root then return end
local vehicles = root:WaitForChild('Vehicles', 30)
if not vehicles then return end

local UPDATE_HZ = 10
local IDLE_UPDATE_HZ = 2
local IDLE_TICK_DIVISOR = math.max(1, math.floor(UPDATE_HZ / IDLE_UPDATE_HZ + 0.5))
local LOW_SPEED = 8
local HIGH_SPEED = 30
local CARGO_BLEND_START_SPEED = 12
local CONDITION_BLEND_START_SPEED = 14
local CONDITION_FULL_ASSIST_AT = 45
local CORNER_BLEND_START_SPEED = 15
local CORNER_STEER_DEADZONE = 0.35
local REVERSAL_BLEND_START_SPEED = 14
local REVERSAL_STEER_DEADZONE = 0.45
local REVERSAL_HOLD_SECONDS = 0.45
local LOW_P = 9000
local HIGH_P = 4300
local LOW_D = 650
local HIGH_D = 1100
local LOW_YAW_TORQUE = 150000
local HIGH_YAW_TORQUE = 82000
local CARGO_HIGH_SPEED_P_SCALE = 0.88
local CARGO_HIGH_SPEED_YAW_SCALE = 0.84
local CARGO_DAMPING_SCALE = 1.12
local CONDITION_HIGH_SPEED_P_SCALE = 0.90
local CONDITION_HIGH_SPEED_YAW_SCALE = 0.80
local CONDITION_DAMPING_SCALE = 1.18
local CORNER_HIGH_SPEED_P_SCALE = 0.88
local CORNER_HIGH_SPEED_YAW_SCALE = 0.72
local CORNER_DAMPING_SCALE = 1.22
local REVERSAL_HIGH_SPEED_P_SCALE = 0.90
local REVERSAL_HIGH_SPEED_YAW_SCALE = 0.68
local REVERSAL_DAMPING_SCALE = 1.28

local tracked = {}
local tickIndex = 0

local function planarSpeed(part)
    local v = part.AssemblyLinearVelocity
    return Vector3.new(v.X, 0, v.Z).Magnitude
end

local function alphaFor(speed)
    return math.clamp((speed - LOW_SPEED) / math.max(1, HIGH_SPEED - LOW_SPEED), 0, 1)
end

local function cargoBlendFor(speed, loaded)
    if not loaded then return 0 end
    return math.clamp((speed - CARGO_BLEND_START_SPEED) / math.max(1, HIGH_SPEED - CARGO_BLEND_START_SPEED), 0, 1)
end

local function conditionBlendFor(speed, condition)
    condition = math.clamp(tonumber(condition) or 100, 0, 100)
    if condition >= 100 or speed <= CONDITION_BLEND_START_SPEED then return 0 end
    local damageBlend = math.clamp((100 - condition) / math.max(1, 100 - CONDITION_FULL_ASSIST_AT), 0, 1)
    local speedBlend = math.clamp((speed - CONDITION_BLEND_START_SPEED) / math.max(1, HIGH_SPEED - CONDITION_BLEND_START_SPEED), 0, 1)
    return damageBlend * speedBlend
end

local function cornerBlendFor(speed, steer)
    local steerAmount = math.abs(tonumber(steer) or 0)
    if speed <= CORNER_BLEND_START_SPEED or steerAmount <= CORNER_STEER_DEADZONE then return 0 end
    local steerBlend = math.clamp((steerAmount - CORNER_STEER_DEADZONE) / math.max(0.01, 1 - CORNER_STEER_DEADZONE), 0, 1)
    local speedBlend = math.clamp((speed - CORNER_BLEND_START_SPEED) / math.max(1, HIGH_SPEED - CORNER_BLEND_START_SPEED), 0, 1)
    return steerBlend * speedBlend
end

local function isStrongSteer(value)
    return math.abs(tonumber(value) or 0) >= REVERSAL_STEER_DEADZONE
end

local function oppositeStrongSteer(previous, current)
    if not isStrongSteer(previous) or not isStrongSteer(current) then return false end
    return previous * current < 0
end

local function track(model)
    if not model:IsA('Model') then return end
    local chassis = model.PrimaryPart or model:FindFirstChild('Chassis')
    if not chassis or not chassis:IsA('BasePart') then return end
    local gyro = chassis:FindFirstChildOfClass('BodyGyro')
    if not gyro then return end
    local seat = model:FindFirstChild('DriverSeat', true)
    if seat and not seat:IsA('VehicleSeat') then seat = nil end
    tracked[model] = {chassis = chassis, gyro = gyro, seat = seat, lastSteer = 0, reversalHold = 0}
    model:SetAttribute('SteeringStabilityReady', true)
    model:SetAttribute('SteeringStabilityVersion', 'v1.42')
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
    tickIndex += 1
    for model,state in pairs(tracked) do
        local chassis = state.chassis
        local gyro = state.gyro
        if not model.Parent or not chassis.Parent or not gyro.Parent then
            tracked[model] = nil
        else
            if not state.seat or not state.seat.Parent then
                local seat = model:FindFirstChild('DriverSeat', true)
                state.seat = seat and seat:IsA('VehicleSeat') and seat or nil
            end

            local occupied = state.seat and state.seat.Occupant ~= nil
            local shouldUpdate = occupied or (tickIndex % IDLE_TICK_DIVISOR == 0)
            if shouldUpdate then
                local speed = planarSpeed(chassis)
                local a = alphaFor(speed)
                local cargoLoaded = model:GetAttribute('CargoVisualLoaded') == true
                local cargoBlend = cargoBlendFor(speed, cargoLoaded)
                local condition = model:GetAttribute('Condition') or 100
                local conditionBlend = conditionBlendFor(speed, condition)
                local steer = state.seat and state.seat.SteerFloat or 0
                local cornerBlend = cornerBlendFor(speed, steer)

                if speed >= REVERSAL_BLEND_START_SPEED and oppositeStrongSteer(state.lastSteer, steer) then
                    state.reversalHold = REVERSAL_HOLD_SECONDS
                else
                    local elapsed = occupied and interval or (interval * IDLE_TICK_DIVISOR)
                    state.reversalHold = math.max(0, state.reversalHold - elapsed)
                end
                state.lastSteer = steer

                local reversalSpeedBlend = math.clamp((speed - REVERSAL_BLEND_START_SPEED) / math.max(1, HIGH_SPEED - REVERSAL_BLEND_START_SPEED), 0, 1)
                local reversalTimeBlend = math.clamp(state.reversalHold / REVERSAL_HOLD_SECONDS, 0, 1)
                local reversalBlend = reversalSpeedBlend * reversalTimeBlend

                local baseP = LOW_P + (HIGH_P - LOW_P) * a
                local baseD = LOW_D + (HIGH_D - LOW_D) * a
                local baseYawTorque = LOW_YAW_TORQUE + (HIGH_YAW_TORQUE - LOW_YAW_TORQUE) * a

                local cargoPScale = 1 + (CARGO_HIGH_SPEED_P_SCALE - 1) * cargoBlend
                local cargoYawScale = 1 + (CARGO_HIGH_SPEED_YAW_SCALE - 1) * cargoBlend
                local cargoDScale = 1 + (CARGO_DAMPING_SCALE - 1) * cargoBlend
                local conditionPScale = 1 + (CONDITION_HIGH_SPEED_P_SCALE - 1) * conditionBlend
                local conditionYawScale = 1 + (CONDITION_HIGH_SPEED_YAW_SCALE - 1) * conditionBlend
                local conditionDScale = 1 + (CONDITION_DAMPING_SCALE - 1) * conditionBlend
                local cornerPScale = 1 + (CORNER_HIGH_SPEED_P_SCALE - 1) * cornerBlend
                local cornerYawScale = 1 + (CORNER_HIGH_SPEED_YAW_SCALE - 1) * cornerBlend
                local cornerDScale = 1 + (CORNER_DAMPING_SCALE - 1) * cornerBlend
                local reversalPScale = 1 + (REVERSAL_HIGH_SPEED_P_SCALE - 1) * reversalBlend
                local reversalYawScale = 1 + (REVERSAL_HIGH_SPEED_YAW_SCALE - 1) * reversalBlend
                local reversalDScale = 1 + (REVERSAL_DAMPING_SCALE - 1) * reversalBlend

                gyro.P = baseP * cargoPScale * conditionPScale * cornerPScale * reversalPScale
                gyro.D = baseD * cargoDScale * conditionDScale * cornerDScale * reversalDScale
                local finalYawScale = cargoYawScale * conditionYawScale * cornerYawScale * reversalYawScale
                gyro.MaxTorque = Vector3.new(0, baseYawTorque * finalYawScale, 0)

                model:SetAttribute('SteeringStabilitySpeed', math.floor(speed * 10 + 0.5) / 10)
                model:SetAttribute('SteeringStabilityScale', math.floor((1 - a * 0.55) * finalYawScale * 100 + 0.5) / 100)
                model:SetAttribute('SteeringCargoAssistActive', cargoBlend > 0.01)
                model:SetAttribute('SteeringCargoAssistBlend', math.floor(cargoBlend * 100 + 0.5) / 100)
                model:SetAttribute('SteeringConditionAssistActive', conditionBlend > 0.01)
                model:SetAttribute('SteeringConditionAssistBlend', math.floor(conditionBlend * 100 + 0.5) / 100)
                model:SetAttribute('SteeringCornerAssistActive', cornerBlend > 0.01)
                model:SetAttribute('SteeringCornerAssistBlend', math.floor(cornerBlend * 100 + 0.5) / 100)
                model:SetAttribute('SteeringReversalAssistActive', reversalBlend > 0.01)
                model:SetAttribute('SteeringReversalAssistBlend', math.floor(reversalBlend * 100 + 0.5) / 100)
                model:SetAttribute('SteeringInput', math.floor(steer * 100 + 0.5) / 100)
                model:SetAttribute('SteeringUpdateMode', occupied and 'ACTIVE_10HZ' or 'IDLE_2HZ')
            end
        end
    end
end

-- Preserve current builder compatibility while exposing the new enhancement separately.
Workspace:SetAttribute('ACC_BecakSteeringStability', 'v1.41')
Workspace:SetAttribute('ACC_BecakSteeringStabilityEnhancement', 'v1.42')
Workspace:SetAttribute('BecakSpeedSensitiveSteering', 'ON')
Workspace:SetAttribute('BecakCargoAwareSteering', 'ON')
Workspace:SetAttribute('BecakConditionAwareSteering', 'ON')
Workspace:SetAttribute('BecakCornerAntiTipAssist', 'ON')
Workspace:SetAttribute('BecakSteeringReversalAssist', 'ON')
Workspace:SetAttribute('BecakSteeringIdleThrottle', 'ON')
Workspace:SetAttribute('BecakSteeringCargoBlendStartSpeed', CARGO_BLEND_START_SPEED)
Workspace:SetAttribute('BecakSteeringConditionBlendStartSpeed', CONDITION_BLEND_START_SPEED)
Workspace:SetAttribute('BecakSteeringConditionFullAssistAt', CONDITION_FULL_ASSIST_AT)
Workspace:SetAttribute('BecakSteeringCornerBlendStartSpeed', CORNER_BLEND_START_SPEED)
Workspace:SetAttribute('BecakSteeringCornerDeadzone', CORNER_STEER_DEADZONE)
Workspace:SetAttribute('BecakSteeringReversalBlendStartSpeed', REVERSAL_BLEND_START_SPEED)
Workspace:SetAttribute('BecakSteeringReversalDeadzone', REVERSAL_STEER_DEADZONE)
Workspace:SetAttribute('BecakSteeringReversalHoldSeconds', REVERSAL_HOLD_SECONDS)
Workspace:SetAttribute('BecakSteeringStabilityHz', UPDATE_HZ)
Workspace:SetAttribute('BecakSteeringIdleHz', IDLE_UPDATE_HZ)
Workspace:SetAttribute('BecakSteeringHighSpeedP', HIGH_P)
Workspace:SetAttribute('BecakSteeringHighSpeedYawTorque', HIGH_YAW_TORQUE)
print('[BECAK E-BIKE] steering stability v1.42 ready • occupied 10 Hz • idle 2 Hz • handling preserved')
