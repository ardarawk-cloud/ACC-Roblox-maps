-- BBYA SOCIAL HUB — VIP MINIMAL STANDING LOUNGE v3
-- Owner request: empty VIP. Standing/social space + sound only.
-- No sofas, booths, bar, plants, gates, signs, ceiling art or decorative clutter.
-- Floor 1 / DJ systems / monetization are untouched.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",20)
if not root then return end
local upper=root:WaitForChild("UpperLevels",20)
if not upper then return end
local vip=upper:WaitForChild("L2_VIP_Level",20)
if not vip then return end

-- Hard reset L2 VIP only. UpperLevels creates the old placeholder first;
-- this pass deliberately replaces ALL of it with the minimal owner-approved layout.
for _,child in ipairs(vip:GetChildren()) do
 child:Destroy()
end

local out=Instance.new("Model")
out.Name="VIPMinimalStanding"
out:SetAttribute("Pass","VIP_MINIMAL_STANDING_V3")
out:SetAttribute("FurnitureCount",0)
out:SetAttribute("DecorCount",0)
out:SetAttribute("StandingOnly",true)
out:SetAttribute("Floor1Untouched",true)
out.Parent=vip

local DARK=Color3.fromRGB(18,16,20)
local FLOOR=Color3.fromRGB(43,39,45)
local RAIL=Color3.fromRGB(38,43,48)
local SPEAKER=Color3.fromRGB(10,10,12)

local function part(name,size,cf,color,material,transparency,collide)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.CFrame=cf
 p.Color=color or DARK
 p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0
 p.Anchored=true
 p.CanCollide=collide==true
 p.CanTouch=false
 p.CanQuery=true
 p.CastShadow=true
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=out
 return p
end

-- Same ring footprint as the original upper floor, but clean and undecorated.
-- The central opening remains so VIP can overlook the main club.
part("NorthStandingFloor",Vector3.new(116,1,22),CFrame.new(0,24.5,34),FLOOR,Enum.Material.Slate,0,true)
part("SouthStandingFloor",Vector3.new(116,1,18),CFrame.new(0,24.5,-36),FLOOR,Enum.Material.Slate,0,true)
part("WestStandingFloor",Vector3.new(24,1,52),CFrame.new(-46,24.5,-1),FLOOR,Enum.Material.Slate,0,true)
part("EastStandingFloor",Vector3.new(24,1,52),CFrame.new(46,24.5,-1),FLOOR,Enum.Material.Slate,0,true)

-- Minimal dark safety glass around the central opening. No neon strips.
local function rail(name,size,cf)
 local r=part(name,size,cf,RAIL,Enum.Material.Glass,.56,false)
 r.Reflectance=.05
 return r
end
rail("NorthInnerRail",Vector3.new(70,3,.18),CFrame.new(0,26.4,23))
rail("SouthInnerRail",Vector3.new(70,3,.18),CFrame.new(0,26.4,-27))
rail("WestInnerRail",Vector3.new(.18,3,50),CFrame.new(-35,26.4,-2))
rail("EastInnerRail",Vector3.new(.18,3,50),CFrame.new(35,26.4,-2))

-- Two understated speaker cabinets only; no colored lighting.
local function speaker(name,x)
 part(name,Vector3.new(5,7,2.6),CFrame.new(x,28.5,42),SPEAKER,Enum.Material.Metal,0,false)
 part(name.."Woofer",Vector3.new(2.6,2.6,.18),CFrame.new(x,27.7,40.62),Color3.fromRGB(24,24,27),Enum.Material.SmoothPlastic,0,false)
end
speaker("VIPSpeakerL",-27)
speaker("VIPSpeakerR",27)

-- One spatial audio emitter for the whole VIP. It is intentionally quieter than Main Floor.
local emitter=part("VIPSoundEmitter",Vector3.new(1,1,1),CFrame.new(0,30,12),DARK,Enum.Material.SmoothPlastic,1,false)
emitter.CanQuery=false
local sound=Instance.new("Sound")
sound.Name="VIPAmbientSound"
sound.SoundId="rbxassetid://1846869595"
sound.Volume=.24
sound.Looped=true
sound.RollOffMode=Enum.RollOffMode.InverseTapered
sound.RollOffMinDistance=16
sound.RollOffMaxDistance=105
sound.EmitterSize=22
sound.Parent=emitter
sound:Play()

-- Minimal roof access kept at the east side. No billboard/gate decoration.
local roofPad=part("RooftopAccess",Vector3.new(7,.35,7),CFrame.new(48,25.2,-19),Color3.fromRGB(28,25,30),Enum.Material.Slate,0,true)
local prompt=Instance.new("ProximityPrompt")
prompt.Name="RooftopAccessPrompt"
prompt.ActionText="Go Up"
prompt.ObjectText="Rooftop"
prompt.HoldDuration=0
prompt.MaxActivationDistance=7
prompt.RequiresLineOfSight=false
prompt.Parent=roofPad
prompt.Triggered:Connect(function(player)
 local char=player.Character
 local hrp=char and char:FindFirstChild("HumanoidRootPart")
 if hrp then hrp.CFrame=CFrame.new(43,47,-28) end
end)

print("[BBYA] VIP Minimal Standing v3 online: empty floor + safety rail + spatial sound")
