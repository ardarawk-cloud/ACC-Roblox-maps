-- BBYA SOCIAL HUB — ENTRANCE CAR QUARANTINE v3
-- Removes all temporary/fallback entrance cars after the Spectral GT import
-- rendered incorrectly in Roblox. Keep the arrival road clean until a
-- Roblox-native replacement pair is visually verified.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end
local scene = root:WaitForChild("EntranceStreetScene", 30)
if not scene then return end

task.wait(0.35)

local removed = 0
for _, name in ipairs({
	"CloudCarSlot_Red",
	"CloudCarSlot_Blue",
	"PremiumCarPairV1",
	"PremiumCar_Left_Wine",
	"PremiumCar_Right_Pearl",
}) do
	local car = scene:FindFirstChild(name)
	if car then
		car:Destroy()
		removed += 1
	end
end

scene:SetAttribute("FallbackCarsRemoved", true)
scene:SetAttribute("PremiumCarsRequested", false)
scene:SetAttribute("PremiumCarsReady", false)
scene:SetAttribute("PremiumCarsLeftAsset", 0)
scene:SetAttribute("PremiumCarsRightAsset", 0)
scene:SetAttribute("EntranceCarsQuarantined", true)
scene:SetAttribute("EntranceCarAuthority", "QUARANTINE_V3")

print("[BBYA] Entrance car quarantine active; removed " .. removed .. " temporary car objects")
