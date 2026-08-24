-- BECAK E-BIKE — garage/economy interaction safety v1.0
-- Additive guard around the existing garage ProximityPrompt. It does not own player economy data.
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
local locked = false
local unlockToken = 0

-- Mobile-friendly deliberate activation while preserving the existing purchase handler.
prompt.HoldDuration = math.max(prompt.HoldDuration, 0.65)
prompt.MaxActivationDistance = math.min(prompt.MaxActivationDistance, 10)

prompt.Triggered:Connect(function(player)
    if locked then return end
    locked = true
    unlockToken += 1
    local token = unlockToken
    prompt.Enabled = false
    player:SetAttribute("BecakGarageTransactionGuard", "COOLDOWN")
    task.delay(COOLDOWN_SECONDS, function()
        if token ~= unlockToken then return end
        if prompt.Parent and garage.Parent then
            prompt.Enabled = true
        end
        if player.Parent then
            player:SetAttribute("BecakGarageTransactionGuard", "READY")
        end
        locked = false
    end)
end)

Workspace:SetAttribute("ACC_BecakGarageSafety", "v1.0")
Workspace:SetAttribute("BecakGaragePurchaseDebounce", "ON")
Workspace:SetAttribute("BecakGaragePurchaseCooldownSeconds", COOLDOWN_SECONDS)
Workspace:SetAttribute("BecakGarageMobileDeliberateHold", "ON")
