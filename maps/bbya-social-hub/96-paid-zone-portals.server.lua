-- BBYA SOCIAL HUB — FUNKOT CLOSED WALL v2
-- Retires the old open-frame Funkot doorway. The physical opening is sealed with a wall.
-- Travel/teleport remains the only legitimate Funkot access; paid-zone hard-seal authority is untouched.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",35)
if not root then return end

local old=root:FindFirstChild("PaidZonePortalsV1")
if old then old:Destroy() end

local m=Instance.new("Model")
m.Name="PaidZonePortalsV1"
m.Parent=root
m:SetAttribute("Pass","FUNKOT_CLOSED_WALL_V2")
m:SetAttribute("FunkotTravelOnly",true)
m:SetAttribute("OldDoorRetired",true)
m:SetAttribute("OpeningSealed",true)
m:SetAttribute("HardSealAuthority","PaidZoneHardSealV1")
m:SetAttribute("TeleportAuthorityUntouched",true)

-- Rear Funkot shell SouthWallL/R leave a 24-stud center opening from X -12..12 at Z 161.
-- Fill exactly that opening with the same shell profile; no walk-through door remains.
local wall=Instance.new("Part")
wall.Name="FunkotClosedSouthWall"
wall.Size=Vector3.new(24,30,2)
wall.CFrame=CFrame.new(0,15.5,161)
wall.Color=Color3.fromRGB(20,21,25)
wall.Material=Enum.Material.Concrete
wall.Anchored=true
wall.CanCollide=true
wall.CanTouch=false
wall.CanQuery=true
wall.CastShadow=true
wall.TopSurface=Enum.SurfaceType.Smooth
wall.BottomSurface=Enum.SurfaceType.Smooth
wall.Parent=m
wall:SetAttribute("Purpose","SEALED_FUNKTOT_ENTRY_OPENING")
wall:SetAttribute("AccessMode","TRAVEL_TELEPORT_ONLY")

-- Small flush identifier only; this is signage, not a door/portal.
local sign=Instance.new("SurfaceGui")
sign.Name="FunkotClosedWallSign"
sign.Face=Enum.NormalId.Front
sign.PixelsPerStud=38
sign.LightInfluence=.15
sign.Parent=wall

local text=Instance.new("TextLabel")
text.BackgroundTransparency=1
text.AnchorPoint=Vector2.new(.5,.5)
text.Position=UDim2.fromScale(.5,.5)
text.Size=UDim2.fromScale(.78,.18)
text.Text="FUNKOT CLUB  •  TRAVEL ACCESS"
text.TextColor3=Color3.fromRGB(220,220,226)
text.Font=Enum.Font.GothamBold
text.TextScaled=true
text.TextTransparency=.28
text.Parent=sign

print("[BBYA] Funkot closed wall v2 online: old doorway retired / opening sealed / Travel teleport preserved")
