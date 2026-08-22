-- BBYA SOCIAL HUB — PAID ZONE HARD SEAL v2
-- Collision backup behind the visible premium perimeter. Eliminates the narrow strip between
-- venue/skate fences and the outer screen so players cannot walk around paid Skatepark/Funkot access.
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",35)
if not root then return end
local old=root:FindFirstChild("PaidZoneHardSealV1");if old then old:Destroy() end
local m=Instance.new("Model");m.Name="PaidZoneHardSealV1";m.Parent=root
m:SetAttribute("Pass","PAID_ZONE_HARD_SEAL_V2")
m:SetAttribute("NoSideGang",true)
m:SetAttribute("SkateparkTravelOnly",true)
m:SetAttribute("FunkotTravelOnly",true)
m:SetAttribute("InvisibleCollisionBackup",true)
local function wall(name,size,cf)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=true;p.CanTouch=false;p.CanQuery=false;p.Transparency=1;p.CastShadow=false;p.Parent=m;return p
end
-- Existing venue/skate outer face is around X +/-60, premium screen is around X +/-64.
-- Fill that entire strip for the full property depth; there is physically nowhere to squeeze through.
wall("NoGangLeft",Vector3.new(5,26,520),CFrame.new(-61.5,13,55))
wall("NoGangRight",Vector3.new(5,26,520),CFrame.new(61.5,13,55))
-- Paid-zone transition planes. Legitimate pass owners arrive by Travel teleport beyond each plane.
wall("SkateTravelPlane",Vector3.new(122,18,1.6),CFrame.new(0,9,73.6))
wall("FunkotTravelPlane",Vector3.new(122,22,1.8),CFrame.new(0,11,157.4))
m:SetAttribute("SkateTravelPlaneZ",73.6)
m:SetAttribute("SkateTravelTeleportZ",112)
m:SetAttribute("FunkotTravelPlaneZ",157.4)
m:SetAttribute("FunkotTravelTeleportZ",205)
print("[BBYA] Paid Zone Hard Seal v2 online: no side gang / Skatepark + Funkot travel-only")
