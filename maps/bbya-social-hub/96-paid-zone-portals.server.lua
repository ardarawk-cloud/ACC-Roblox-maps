-- BBYA SOCIAL HUB — RETIRED FUNKOT CLOSED WALL SOURCE v3
-- The old visible 24x30 closed-wall / lobby box is retired at its source.
-- PaidZoneHardSealV1 remains the invisible access-security authority.
-- Funkot music and the active Funkot club geometry are untouched.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",35)
if not root then return end

local function retire()
 local old=root:FindFirstChild("PaidZonePortalsV1")
 if old then old:Destroy() end
 local stray=root:FindFirstChild("FunkotClosedSouthWall")
 if stray then stray:Destroy() end
 root:SetAttribute("FunkotClosedWallSourceRetired",true)
 root:SetAttribute("FunkotAccessSecurityAuthority","PaidZoneHardSealV1")
end

retire()
root.ChildAdded:Connect(function(child)
 if child.Name=="PaidZonePortalsV1" or child.Name=="FunkotClosedSouthWall" then
  task.defer(function()
   if child.Parent==root then child:Destroy() end
  end)
 end
end)

print("[BBYA] retired Funkot closed-wall source v3 online: visible lobby wall disabled at source")
