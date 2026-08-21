-- BBYA SOCIAL HUB — VIP FLOOR NEON CLEANUP v2
-- Owner revision: remove the inner floor neon entirely instead of trying to align it.
-- Ceiling triangle lighting and room ambience remain untouched.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper=root:WaitForChild("UpperLevels",30)
local vip=upper and upper:WaitForChild("L2_VIP_Level",30)
local active=vip and vip:WaitForChild("VIPMinimalStanding",30)
if not active then return end

task.wait(.55)

for _,name in ipairs({"FloorBoundaryNeon","PreciseInnerFloorNeon"}) do
 local obj=active:FindFirstChild(name)
 if obj then obj:Destroy() end
end

active:SetAttribute("FloorBoundaryNeonSegments",0)
active:SetAttribute("InnerFloorNeonRemoved",true)
active:SetAttribute("FloorLightingProfile","NO_ASYMMETRIC_NEON")

print("[BBYA] VIP floor neon cleanup v2: all inner/outer floor neon removed")
