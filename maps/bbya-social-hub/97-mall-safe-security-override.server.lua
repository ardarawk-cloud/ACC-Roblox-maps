-- BBYA SOCIAL HUB — MALL-SAFE SECURITY OVERRIDE v1
-- Late correction for the security pass after the dedicated Mall build landed on main.
-- The paid-zone security ends at the north edge of Funkot (~Z250) and never enters the Mall connector/plaza.
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",35)
if not root then return end

task.wait(2.2)
local premium=root:FindFirstChild("WorldPremiumV338")
if premium then
 local security=premium:FindFirstChild("PaidZoneSecurity")
 if security then
  local rear=security:FindFirstChild("NoBypassRearBoundary")
  if rear then rear:Destroy() end
  for _,side in ipairs({"Left","Right"}) do
   local b=security:FindFirstChild("NoBypassWorldBoundary"..side)
   if b and b:IsA("BasePart") then
    b.Size=Vector3.new(3,28,340)
    b.CFrame=CFrame.new(side=="Left" and -73 or 73,14,80)
   end
  end
  security:SetAttribute("MallSafeNorthLimitZ",250)
  security:SetAttribute("RearBoundaryRemovedForMall",true)
 end
 premium:SetAttribute("MallConnectorPreserved",true)
end

local hard=root:FindFirstChild("PaidZoneHardSealV1")
if hard then
 local left=hard:FindFirstChild("NoGangLeft")
 local right=hard:FindFirstChild("NoGangRight")
 if left and left:IsA("BasePart") then left.Size=Vector3.new(14,26,340);left.CFrame=CFrame.new(-66,13,80) end
 if right and right:IsA("BasePart") then right.Size=Vector3.new(14,26,340);right.CFrame=CFrame.new(66,13,80) end
 hard:SetAttribute("MallSafeNorthLimitZ",250)
 hard:SetAttribute("MallConnectorPreserved",true)
end

-- Never parent, move, resize, recolor or inspect descendants of BBYAMall here.
local mall=root:FindFirstChild("BBYAMall")
if mall then mall:SetAttribute("PremiumSecurityUntouchedMall",true) end

print("[BBYA] Mall-safe security override: no side gang through Funkot, Mall connector preserved")
