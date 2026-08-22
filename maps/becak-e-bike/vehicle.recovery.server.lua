-- BECAK E-BIKE — Vehicle Recovery Assist v1.35
-- Automatic owner-only self-righting, fast multi-probe curb assist, hill-start anti-rollback,
-- plus conservative high-speed anti-tip damping for mobile drivability.
-- Designed to improve stability without replacing the core VehicleSeat controller.

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')

local root = Workspace:WaitForChild('BecakEBike', 30)
if not root then return end
local vehicles = root:WaitForChild('Vehicles', 30)
if not vehicles then return end

local remotes = ReplicatedStorage:FindFirstChild('BecakEBikeRemotes')
local toast = remotes and remotes:FindFirstChild('Toast')

local FLIP_UP_Y = 0.38
local FLIP_HOLD_SECONDS = 1.35
-- v1.35: curb geometry is already wall-filtered by the multi-probe routine, so the
-- stall hold can be shorter. This makes mobile curb recovery feel responsive instead
-- of requiring the player to hold throttle against the obstacle for more than a second.
local STALL_HOLD_SECONDS = 0.85
local STALL_SPEED = 2.0
local THROTTLE_THRESHOLD = 0.50
local RECOVERY_COOLDOWN = 6
local ASSIST_FORWARD_SPEED = 7.5
local ASSIST_UP_SPEED = 4.6
local CURB_PROBE_DISTANCE = 4.5
local CURB_SIDE_OFFSET = 1.35
local CURB_LOW_HEIGHT = 0.35
local CURB_CLEAR_HEIGHT = 2.15
local CURB_MAX_TOP_HEIGHT = 1.35

-- Hill-start assist is intentionally conservative: it only fights rollback while the owner
-- is actively requesting forward throttle at very low speed. This avoids changing normal handling.
local HILL_CHECK_DISTANCE = 5.5
local HILL_MIN_RISE = 0.55
local HILL_MAX_SPEED = 5.0
local ROLLBACK_TRIGGER_SPEED = 0.7
local HILL_ASSIST_FORWARD_SPEED = 4.2
local HILL_ASSIST_COOLDOWN = 1.1

-- Stability assist only damps pitch/roll spin once the becak is already moving at road speed.
-- Yaw remains untouched so steering authority stays with the native controller.
local STABILITY_MIN_SPEED = 11
local STABILITY_MAX_TILT_RATE = 1.7
local STABILITY_DAMPING = 0.58
local STABILITY_MIN_UP_Y = 0.62

local states = {}
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function ownerOf(model)
    local id = tonumber(model:GetAttribute('OwnerUserId'))
    if not id then return nil end
    return Players:GetPlayerByUserId(id)
end

local function horizontal(v)
    return Vector3.new(v.X, 0, v.Z)
end

local function clearMomentum(model)
    for _,obj in ipairs(model:GetDescendants()) do
        if obj:IsA('BasePart') then
            obj.AssemblyLinearVelocity = Vector3.zero
            obj.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

local function safeLook(chassis)
    local look = horizontal(chassis.CFrame.LookVector)
    if look.Magnitude < 0.05 then return Vector3.new(0,0,-1) end
    return look.Unit
end

local function notify(player, text)
    if toast and player then toast:FireClient(player, text) end
end

local function recoverFlip(model, chassis, player, state)
    local pos = chassis.Position + Vector3.new(0, 2.4, 0)
    local look = safeLook(chassis)
    clearMomentum(model)
    model:PivotTo(CFrame.lookAt(pos, pos + look))
    state.cooldownUntil = os.clock() + RECOVERY_COOLDOWN
    state.flipSince = nil
    state.stallSince = nil
    model:SetAttribute('RecoveryCount', (tonumber(model:GetAttribute('RecoveryCount')) or 0) + 1)
    model:SetAttribute('LastRecoveryMode', 'SELF_RIGHT')
    notify(player, 'Becak otomatis dibalikkan ke posisi aman.')
end

local function desiredTravelDirection(chassis, seat)
    local look = safeLook(chassis)
    local throttleSign = seat.ThrottleFloat < 0 and -1 or 1
    local travel = look * throttleSign
    local right = horizontal(chassis.CFrame.RightVector)
    if right.Magnitude > 0.05 then
        travel += right.Unit * math.clamp(seat.SteerFloat, -1, 1) * 0.28 * throttleSign
    end
    if travel.Magnitude < 0.05 then return look * throttleSign end
    return travel.Unit
end

local function curbProbe(model, chassis, travel, lateralOffset)
    local right = horizontal(chassis.CFrame.RightVector)
    if right.Magnitude < 0.05 then right = Vector3.new(1,0,0) else right = right.Unit end
    local base = chassis.Position + right * lateralOffset
    local lowOrigin = base + Vector3.new(0, CURB_LOW_HEIGHT, 0)
    local highOrigin = base + Vector3.new(0, CURB_CLEAR_HEIGHT, 0)
    local lowHit = Workspace:Raycast(lowOrigin, travel * CURB_PROBE_DISTANCE, rayParams)
    if not lowHit then return nil end
    local highHit = Workspace:Raycast(highOrigin, travel * CURB_PROBE_DISTANCE, rayParams)
    if highHit then return nil end

    -- Reject walls/tall obstacles: sample downward from above the contact point and require
    -- a low top surface. This keeps assist focused on curbs/sidewalk lips rather than buildings.
    local contact = lowHit.Position
    local topOrigin = contact + Vector3.new(0, CURB_MAX_TOP_HEIGHT + 1.0, 0) - travel * 0.2
    local topHit = Workspace:Raycast(topOrigin, Vector3.new(0, -(CURB_MAX_TOP_HEIGHT + 1.4), 0), rayParams)
    if not topHit then return nil end
    local topRise = topHit.Position.Y - chassis.Position.Y
    if topRise > CURB_MAX_TOP_HEIGHT then return nil end
    return lowHit
end

local function tryLowCurbAssist(model, chassis, seat, player, state)
    rayParams.FilterDescendantsInstances = {model}
    local travel = desiredTravelDirection(chassis, seat)

    -- Three probes cover center + both front wheel tracks, so diagonal approaches to a curb
    -- are detected reliably on mobile. Direction follows throttle sign, fixing reverse-stall cases.
    local hit = curbProbe(model, chassis, travel, 0)
        or curbProbe(model, chassis, travel, CURB_SIDE_OFFSET)
        or curbProbe(model, chassis, travel, -CURB_SIDE_OFFSET)
    if not hit then return false end

    local velocity = chassis.AssemblyLinearVelocity
    chassis.AssemblyLinearVelocity = travel * math.max(ASSIST_FORWARD_SPEED, horizontal(velocity).Magnitude) + Vector3.new(0, ASSIST_UP_SPEED, 0)
    state.cooldownUntil = os.clock() + 1.8
    state.stallSince = nil
    model:SetAttribute('CurbAssistCount', (tonumber(model:GetAttribute('CurbAssistCount')) or 0) + 1)
    model:SetAttribute('LastRecoveryMode', 'FAST_MULTI_PROBE_CURB_ASSIST')
    notify(player, 'Curb Assist aktif — becak dibantu melewati bibir jalan.')
    return true
end

local function tryHillStartAssist(model, chassis, seat, state)
    if seat.ThrottleFloat < THROTTLE_THRESHOLD then return false end

    local look = safeLook(chassis)
    local velocity = chassis.AssemblyLinearVelocity
    local horizontalVelocity = horizontal(velocity)
    if horizontalVelocity.Magnitude > HILL_MAX_SPEED then return false end

    -- Only activate when the vehicle is actually rolling backwards relative to its facing direction.
    local signedForwardSpeed = horizontalVelocity:Dot(look)
    if signedForwardSpeed > -ROLLBACK_TRIGGER_SPEED then return false end

    rayParams.FilterDescendantsInstances = {model}
    local down = Vector3.new(0, -8, 0)
    local hereHit = Workspace:Raycast(chassis.Position + Vector3.new(0, 2.0, 0), down, rayParams)
    local aheadHit = Workspace:Raycast(chassis.Position + look * HILL_CHECK_DISTANCE + Vector3.new(0, 3.5, 0), down, rayParams)
    if not hereHit or not aheadHit then return false end

    local rise = aheadHit.Position.Y - hereHit.Position.Y
    if rise < HILL_MIN_RISE then return false end

    -- Preserve vertical motion, cancel rollback, and give a small forward start impulse.
    chassis.AssemblyLinearVelocity = look * HILL_ASSIST_FORWARD_SPEED + Vector3.new(0, velocity.Y, 0)
    state.cooldownUntil = os.clock() + HILL_ASSIST_COOLDOWN
    model:SetAttribute('HillStartAssistCount', (tonumber(model:GetAttribute('HillStartAssistCount')) or 0) + 1)
    model:SetAttribute('LastRecoveryMode', 'HILL_START_ASSIST')
    return true
end

local function applyStabilityAssist(model, chassis)
    local speed = horizontal(chassis.AssemblyLinearVelocity).Magnitude
    if speed < STABILITY_MIN_SPEED or chassis.CFrame.UpVector.Y < STABILITY_MIN_UP_Y then return end

    local angular = chassis.AssemblyAngularVelocity
    local tiltRate = Vector2.new(angular.X, angular.Z).Magnitude
    if tiltRate <= STABILITY_MAX_TILT_RATE then return end

    chassis.AssemblyAngularVelocity = Vector3.new(
        angular.X * STABILITY_DAMPING,
        angular.Y,
        angular.Z * STABILITY_DAMPING
    )
    model:SetAttribute('StabilityAssistCount', (tonumber(model:GetAttribute('StabilityAssistCount')) or 0) + 1)
    model:SetAttribute('LastStabilityAssistSpeed', math.floor(speed * 10 + 0.5) / 10)
end

local function stepVehicle(model, dt)
    if not model:IsA('Model') or not model.Parent then states[model] = nil return end
    local chassis = model.PrimaryPart or model:FindFirstChild('Chassis')
    local seat = model:FindFirstChild('DriverSeat', true)
    if not chassis or not chassis:IsA('BasePart') or not seat or not seat:IsA('VehicleSeat') then return end

    local player = ownerOf(model)
    local occupant = seat.Occupant
    local occupiedByOwner = player and occupant and occupant.Parent == player.Character
    if not occupiedByOwner then
        local state = states[model]
        if state then state.flipSince=nil; state.stallSince=nil end
        return
    end

    local state = states[model]
    if not state then
        state = {cooldownUntil=0, flipSince=nil, stallSince=nil}
        states[model] = state
    end
    local now = os.clock()

    -- Keep normal steering/yaw untouched while damping only excessive pitch/roll at speed.
    applyStabilityAssist(model, chassis)

    if now < state.cooldownUntil then return end

    local upY = chassis.CFrame.UpVector.Y
    if upY < FLIP_UP_Y then
        state.flipSince = state.flipSince or now
        if now - state.flipSince >= FLIP_HOLD_SECONDS then
            recoverFlip(model, chassis, player, state)
        end
        return
    else
        state.flipSince = nil
    end

    -- Address the common mobile case where a loaded becak rolls backward on a ramp/slope
    -- even though the player is holding forward throttle.
    if tryHillStartAssist(model, chassis, seat, state) then
        state.stallSince = nil
        return
    end

    local throttle = math.abs(seat.ThrottleFloat)
    local speed = horizontal(chassis.AssemblyLinearVelocity).Magnitude
    if throttle >= THROTTLE_THRESHOLD and speed <= STALL_SPEED then
        state.stallSince = state.stallSince or now
        if now - state.stallSince >= STALL_HOLD_SECONDS then
            if not tryLowCurbAssist(model, chassis, seat, player, state) then
                -- Do not teleport through walls; simply reset the detector and wait for a better geometry match.
                state.stallSince = now
            end
        end
    else
        state.stallSince = nil
    end
end

local acc = 0
RunService.Heartbeat:Connect(function(dt)
    acc += dt
    if acc < 0.1 then return end -- 10 Hz max; lightweight for mobile/server.
    local step = acc
    acc = 0
    for _,model in ipairs(vehicles:GetChildren()) do
        stepVehicle(model, step)
    end
end)

vehicles.ChildRemoved:Connect(function(model) states[model]=nil end)

Workspace:SetAttribute('ACC_BecakVehicleRecovery','v1.35')
Workspace:SetAttribute('BecakSelfRighting','ON')
Workspace:SetAttribute('BecakLowCurbAssist','ON')
Workspace:SetAttribute('BecakMultiProbeCurbAssist','ON')
Workspace:SetAttribute('BecakReverseCurbAssist','ON')
Workspace:SetAttribute('BecakFastCurbAssist','ON')
Workspace:SetAttribute('BecakCurbAssistHoldSeconds',STALL_HOLD_SECONDS)
Workspace:SetAttribute('BecakHillStartAssist','ON')
Workspace:SetAttribute('BecakHighSpeedStabilityAssist','ON')
Workspace:SetAttribute('BecakStabilityMinSpeed',STABILITY_MIN_SPEED)
Workspace:SetAttribute('BecakRecoveryTickHz',10)
print('[BECAK E-BIKE] vehicle recovery v1.35 ready • curb + reverse + self-righting + hill-start + anti-tip stability')
