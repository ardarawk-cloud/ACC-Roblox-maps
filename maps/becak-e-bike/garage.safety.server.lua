-- BECAK E-BIKE — garage/economy interaction safety v1.2
-- Additive guard around existing economy-facing ProximityPrompts. It does not own player economy data.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BecakEBike", 30)
if not root then return end
local interactives = root:WaitForChild("Interactives", 30)
if not interactives then return end
local garage = interactives:WaitForChild("Garage", 30)
if not garage then return end
local prompt = garage:FindFirstChildOfClass("ProximityPrompt")
if not prompt then
    warn("[BECAK E-BIKE] Garage safety: upgrade prompt not found")
    return
end

local COOLDOWN_SECONDS = 1.25
local HOLD_SECONDS = 0.65
local SERVICE_HOLD_SECONDS = 0.55
local SERVICE_MAX_DISTANCE = 10
local locked = false
local unlockToken = 0
local lockOwnerUserId = 0

-- Mobile-friendly deliberate activation while preserving the existing purchase handler.
prompt.HoldDuration = math.max(prompt.HoldDuration, HOLD_SECONDS)
prompt.MaxActivationDistance = math.min(prompt.MaxActivationDistance, 10)
prompt.RequiresLineOfSight = true

local function clearGuardForUserId(userId)
    if userId == 0 then return end
    local owner = Players:GetPlayerByUserId(userId)
    if owner and owner.Parent then
        owner:SetAttribute("BecakGarageTransactionGuard", "READY")
    end
end

local function releaseLock(token)
    if token ~= unlockToken then return end
    if prompt.Parent and garage.Parent then
        prompt.Enabled = true
    end
    clearGuardForUserId(lockOwnerUserId)
    lockOwnerUserId = 0
    locked = false
end

prompt.Triggered:Connect(function(player)
    if locked then return end
    locked = true
    unlockToken += 1
    local token = unlockToken
    lockOwnerUserId = player.UserId
    prompt.Enabled = false
    player:SetAttribute("BecakGarageTransactionGuard", "COOLDOWN")
    player:SetAttribute("BecakGarageLastGuardedAt", Workspace:GetServerTimeNow())
    task.delay(COOLDOWN_SECONDS, function()
        releaseLock(token)
    end)
end)

-- Never leave the shared prompt stuck if the triggering player disconnects during cooldown.
Players.PlayerRemoving:Connect(function(player)
    if locked and player.UserId == lockOwnerUserId then
        unlockToken += 1
        if prompt.Parent and garage.Parent then prompt.Enabled = true end
        lockOwnerUserId = 0
        locked = false
    end
end)

-- Harden other economy-facing service prompts created by the masterplan without replacing their handlers.
-- This closes through-wall/mobile accidental activations while keeping existing repair/cargo pricing and job logic intact.
local hardenedServicePrompts = 0
local function hardenServicePrompt(target, label)
    if not target then return false end
    local servicePrompt = target:FindFirstChildOfClass("ProximityPrompt")
    if not servicePrompt then
        warn("[BECAK E-BIKE] Economy interaction safety: prompt not found for " .. label)
        return false
    end
    servicePrompt.HoldDuration = math.max(servicePrompt.HoldDuration, SERVICE_HOLD_SECONDS)
    servicePrompt.MaxActivationDistance = math.min(servicePrompt.MaxActivationDistance, SERVICE_MAX_DISTANCE)
    servicePrompt.RequiresLineOfSight = true
    servicePrompt:SetAttribute("BecakEconomyInteractionSafety", "v1.2")
    hardenedServicePrompts += 1
    return true
end

local repairShop = interactives:FindFirstChild("RepairShop")
if not repairShop then repairShop = interactives:WaitForChild("RepairShop", 10) end
hardenServicePrompt(repairShop, "RepairShop")

local masterplanSystems = root:FindFirstChild("MasterplanSystems")
if not masterplanSystems then masterplanSystems = root:WaitForChild("MasterplanSystems", 10) end
local cargoJobs = masterplanSystems and masterplanSystems:FindFirstChild("CargoJobs")
if not cargoJobs and masterplanSystems then cargoJobs = masterplanSystems:WaitForChild("CargoJobs", 10) end
local cargoDepot = cargoJobs and cargoJobs:FindFirstChild("CargoDepot")
if not cargoDepot and cargoJobs then cargoDepot = cargoJobs:WaitForChild("CargoDepot", 10) end
hardenServicePrompt(cargoDepot, "CargoDepot")

Workspace:SetAttribute("ACC_BecakGarageSafety", "v1.0") -- dedicated builder compatibility token
Workspace:SetAttribute("ACC_BecakGarageSafetyEnhancement", "v1.2")
Workspace:SetAttribute("BecakGaragePurchaseDebounce", "ON")
Workspace:SetAttribute("BecakGaragePurchaseCooldownSeconds", COOLDOWN_SECONDS)
Workspace:SetAttribute("BecakGarageMobileDeliberateHold", "ON")
Workspace:SetAttribute("BecakGarageHoldDurationSeconds", HOLD_SECONDS)
Workspace:SetAttribute("BecakGarageRequiresLineOfSight", "ON")
Workspace:SetAttribute("BecakGarageDisconnectUnlockGuard", "ON")
Workspace:SetAttribute("BecakEconomyPromptSafety", "ON")
Workspace:SetAttribute("BecakEconomyPromptHoldDurationSeconds", SERVICE_HOLD_SECONDS)
Workspace:SetAttribute("BecakEconomyPromptMaxActivationDistance", SERVICE_MAX_DISTANCE)
Workspace:SetAttribute("BecakEconomyPromptRequiresLineOfSight", "ON")
Workspace:SetAttribute("BecakEconomyPromptHardenedCount", hardenedServicePrompts)
