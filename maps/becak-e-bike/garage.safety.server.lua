-- BECAK E-BIKE — garage/economy interaction safety v1.5
-- Additive guard around existing economy-facing ProximityPrompts. It does not own player economy data.
-- v1.5 adds disconnect-safe service prompt unlocks and stale-lock watchdog recovery.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BecakEBike", 30)
if not root then return end
local interactives = root:WaitForChild("Interactives", 30)
if not interactives then return end
local garage = interactives:WaitForChild("Garage", 30)
if not garage then return end
local prompt = garage:FindFirstChildOfClass("ProximityPrompt")
if not prompt then warn("[BECAK E-BIKE] Garage safety: upgrade prompt not found") return end

local COOLDOWN_SECONDS = 1.25
local HOLD_SECONDS = 0.65
local SERVICE_HOLD_SECONDS = 0.55
local SERVICE_MAX_DISTANCE = 10
local SERVICE_COOLDOWN_SECONDS = 1.0
local STALE_LOCK_GRACE_SECONDS = 0.75
local locked = false
local unlockToken = 0
local lockOwnerUserId = 0
local garageLockedAt = 0

prompt.HoldDuration = math.max(prompt.HoldDuration, HOLD_SECONDS)
prompt.MaxActivationDistance = math.min(prompt.MaxActivationDistance, 10)
prompt.RequiresLineOfSight = true

local function clearGuardForUserId(userId)
    if userId == 0 then return end
    local owner = Players:GetPlayerByUserId(userId)
    if owner and owner.Parent then owner:SetAttribute("BecakGarageTransactionGuard", "READY") end
end

local function releaseLock(token)
    if token ~= unlockToken then return end
    if prompt.Parent and garage.Parent then prompt.Enabled = true end
    clearGuardForUserId(lockOwnerUserId)
    lockOwnerUserId = 0
    garageLockedAt = 0
    locked = false
end

prompt.Triggered:Connect(function(player)
    if locked then return end
    locked = true
    unlockToken += 1
    local token = unlockToken
    lockOwnerUserId = player.UserId
    garageLockedAt = os.clock()
    prompt.Enabled = false
    player:SetAttribute("BecakGarageTransactionGuard", "COOLDOWN")
    player:SetAttribute("BecakGarageLastGuardedAt", Workspace:GetServerTimeNow())
    task.delay(COOLDOWN_SECONDS, function() releaseLock(token) end)
end)

local hardenedServicePrompts = 0
local servicePromptStates = {}
local function hardenServicePrompt(target, label)
    if not target then return false end
    local servicePrompt = target:FindFirstChildOfClass("ProximityPrompt")
    if not servicePrompt then warn("[BECAK E-BIKE] Economy interaction safety: prompt not found for " .. label) return false end
    servicePrompt.HoldDuration = math.max(servicePrompt.HoldDuration, SERVICE_HOLD_SECONDS)
    servicePrompt.MaxActivationDistance = math.min(servicePrompt.MaxActivationDistance, SERVICE_MAX_DISTANCE)
    servicePrompt.RequiresLineOfSight = true
    servicePrompt:SetAttribute("BecakEconomyInteractionSafety", "v1.5")
    servicePrompt:SetAttribute("BecakEconomyServiceLabel", label)

    local state = {locked=false, token=0, ownerUserId=0, lockedAt=0, prompt=servicePrompt, label=label}
    servicePromptStates[servicePrompt] = state

    local function releaseServiceLock(token)
        if state.token ~= token then return end
        state.locked = false
        state.lockedAt = 0
        local ownerId = state.ownerUserId
        state.ownerUserId = 0
        if servicePrompt.Parent then servicePrompt.Enabled = true end
        local owner = ownerId ~= 0 and Players:GetPlayerByUserId(ownerId) or nil
        if owner and owner.Parent then owner:SetAttribute("BecakServiceTransactionGuard", "READY") end
    end

    state.release = releaseServiceLock
    servicePrompt.Triggered:Connect(function(player)
        if state.locked then return end
        state.locked = true
        state.token += 1
        local token = state.token
        state.ownerUserId = player.UserId
        state.lockedAt = os.clock()
        servicePrompt.Enabled = false
        player:SetAttribute("BecakServiceTransactionGuard", label .. ":COOLDOWN")
        player:SetAttribute("BecakServiceLastGuardedAt", Workspace:GetServerTimeNow())
        task.delay(SERVICE_COOLDOWN_SECONDS, function() releaseServiceLock(token) end)
    end)

    hardenedServicePrompts += 1
    return true
end

local chargingStation = interactives:FindFirstChild("ChargingStation") or interactives:WaitForChild("ChargingStation", 10)
hardenServicePrompt(chargingStation, "ChargingStation")
local repairShop = interactives:FindFirstChild("RepairShop") or interactives:WaitForChild("RepairShop", 10)
hardenServicePrompt(repairShop, "RepairShop")
local masterplanSystems = root:FindFirstChild("MasterplanSystems") or root:WaitForChild("MasterplanSystems", 10)
local cargoJobs = masterplanSystems and (masterplanSystems:FindFirstChild("CargoJobs") or masterplanSystems:WaitForChild("CargoJobs", 10))
local cargoDepot = cargoJobs and (cargoJobs:FindFirstChild("CargoDepot") or cargoJobs:WaitForChild("CargoDepot", 10))
hardenServicePrompt(cargoDepot, "CargoDepot")

Players.PlayerRemoving:Connect(function(player)
    if locked and player.UserId == lockOwnerUserId then
        unlockToken += 1
        if prompt.Parent and garage.Parent then prompt.Enabled = true end
        lockOwnerUserId = 0
        garageLockedAt = 0
        locked = false
    end
    for _,state in pairs(servicePromptStates) do
        if state.locked and state.ownerUserId == player.UserId then
            state.token += 1
            state.locked = false
            state.lockedAt = 0
            state.ownerUserId = 0
            if state.prompt and state.prompt.Parent then state.prompt.Enabled = true end
        end
    end
end)

-- Rare scheduler/runtime mutations should not leave economy prompts permanently disabled.
task.spawn(function()
    while root.Parent do
        task.wait(1)
        local now = os.clock()
        if locked and garageLockedAt > 0 and now - garageLockedAt > COOLDOWN_SECONDS + STALE_LOCK_GRACE_SECONDS then
            unlockToken += 1
            if prompt.Parent and garage.Parent then prompt.Enabled = true end
            clearGuardForUserId(lockOwnerUserId)
            lockOwnerUserId = 0
            garageLockedAt = 0
            locked = false
            Workspace:SetAttribute("BecakGarageStaleLockRecoveries", (Workspace:GetAttribute("BecakGarageStaleLockRecoveries") or 0) + 1)
        end
        for _,state in pairs(servicePromptStates) do
            if state.locked and state.lockedAt > 0 and now - state.lockedAt > SERVICE_COOLDOWN_SECONDS + STALE_LOCK_GRACE_SECONDS then
                state.token += 1
                local ownerId = state.ownerUserId
                state.locked = false
                state.lockedAt = 0
                state.ownerUserId = 0
                if state.prompt and state.prompt.Parent then state.prompt.Enabled = true end
                local owner = ownerId ~= 0 and Players:GetPlayerByUserId(ownerId) or nil
                if owner and owner.Parent then owner:SetAttribute("BecakServiceTransactionGuard", "READY") end
                Workspace:SetAttribute("BecakServiceStaleLockRecoveries", (Workspace:GetAttribute("BecakServiceStaleLockRecoveries") or 0) + 1)
            end
        end
    end
end)

Workspace:SetAttribute("ACC_BecakGarageSafety", "v1.0")
-- Preserve v1.4 compatibility for existing World QC while exposing additive v1.5 resilience separately.
Workspace:SetAttribute("ACC_BecakGarageSafetyEnhancement", "v1.4")
Workspace:SetAttribute("ACC_BecakGarageSafetyResilience", "v1.5")
Workspace:SetAttribute("BecakGaragePurchaseDebounce", "ON")
Workspace:SetAttribute("BecakGaragePurchaseCooldownSeconds", COOLDOWN_SECONDS)
Workspace:SetAttribute("BecakGarageMobileDeliberateHold", "ON")
Workspace:SetAttribute("BecakGarageHoldDurationSeconds", HOLD_SECONDS)
Workspace:SetAttribute("BecakGarageRequiresLineOfSight", "ON")
Workspace:SetAttribute("BecakGarageDisconnectUnlockGuard", "ON")
Workspace:SetAttribute("BecakEconomyPromptSafety", "ON")
Workspace:SetAttribute("BecakServicePromptSafety", "ON")
Workspace:SetAttribute("BecakEconomyPromptHoldDurationSeconds", SERVICE_HOLD_SECONDS)
Workspace:SetAttribute("BecakEconomyPromptMaxActivationDistance", SERVICE_MAX_DISTANCE)
Workspace:SetAttribute("BecakEconomyPromptRequiresLineOfSight", "ON")
Workspace:SetAttribute("BecakEconomyPromptHardenedCount", hardenedServicePrompts)
Workspace:SetAttribute("BecakEconomyServicePromptDebounce", "ON")
Workspace:SetAttribute("BecakEconomyServicePromptCooldownSeconds", SERVICE_COOLDOWN_SECONDS)
Workspace:SetAttribute("BecakEconomyServiceDisconnectUnlockGuard", "ON")
Workspace:SetAttribute("BecakEconomyPromptStaleLockWatchdog", "ON")
Workspace:SetAttribute("BecakEconomyPromptStaleLockGraceSeconds", STALE_LOCK_GRACE_SECONDS)
Workspace:SetAttribute("BecakChargingPromptSafety", "ON")
Workspace:SetAttribute("BecakGarageStaleLockRecoveries", Workspace:GetAttribute("BecakGarageStaleLockRecoveries") or 0)
Workspace:SetAttribute("BecakServiceStaleLockRecoveries", Workspace:GetAttribute("BecakServiceStaleLockRecoveries") or 0)
