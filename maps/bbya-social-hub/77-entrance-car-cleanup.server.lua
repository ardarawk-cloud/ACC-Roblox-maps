-- BBYA SOCIAL HUB — ENTRANCE CAR CLEANUP v1
-- Until real premium sports-car meshes are canonical, remove the blocky fallback cars entirely.
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local scene=root:WaitForChild("EntranceStreetScene",30)
if not scene then return end
task.wait(.35)
local removed=0
for _,name in ipairs({"CloudCarSlot_Red","CloudCarSlot_Blue"}) do
 local car=scene:FindFirstChild(name)
 if car then car:Destroy();removed+=1 end
end
scene:SetAttribute("FallbackCarsRemoved",true)
scene:SetAttribute("PremiumCarRequiredBeforeReturn",true)
print("[BBYA] Entrance car cleanup removed "..removed.." non-premium fallback cars")
