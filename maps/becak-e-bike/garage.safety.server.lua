-- BECAK E-BIKE — garage/economy interaction safety v1.1
-- Additive guard around the existing garage ProximityPrompt. It does not own player economy data.
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

Workspace:SetAttribute("ACC_BecakGarageSafety", "v1.0") -- dedicated builder compatibility token
Workspace:SetAttribute("ACC_BecakGarageSafetyEnhancement", "v1.1")
Workspace:SetAttribute("BecakGaragePurchaseDebounce", "ON")
Workspace:SetAttribute("BecakGaragePurchaseCooldownSeconds", COOLDOWN_SECONDS)
Workspace:SetAttribute("BecakGarageMobileDeliberateHold", "ON")
Workspace:SetAttribute("BecakGarageHoldDurationSeconds", HOLD_SECONDS)
Workspace:SetAttribute("BecakGarageRequiresLineOfSight", "ON")
Workspace:SetAttribute("BecakGarageDisconnectUnlockGuard", "ON")
