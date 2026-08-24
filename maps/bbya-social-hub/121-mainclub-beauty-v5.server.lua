-- BBYA SOCIAL HUB — MAIN CLUB BEAUTY v5
-- Local-only beauty/visibility pass layered after MainClubPremiumV4.
-- Slightly brighter premium club ambience without touching global Lighting, audio, VIP, Mall, restroom or monetization.
-- Stage and DJ booth geometry are intentionally untouched.
-- v6 mobile sightline revision: slim premium entrance/front pillars.
-- v7 mobile premium refinement: facade depth, local interior depth cues and realistic bar finishing.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local realism=root:WaitForChild("MainClubRealism",30)
local premium=root:WaitForChild("MainClubPremiumV4",30)
if not realism or not premium then return end

local old=root:FindFirstChild("MainClubBeautyV5")
if old then old:Destroy() end

local out=Instance.new("Model")
out.Name="MainClubBeautyV5"
out:SetAttribute("Pass","MAIN_CLUB_BEAUTY_V5")
out:SetAttribute("Scope","MAIN_CLUB_ONLY")
out:SetAttribute("LocalBrightnessOnly",true)
out:SetAttribute("GlobalLightingUntouched",true)
out:SetAttribute("AudioUntouched",true)
out:SetAttribute("StageUntouched",true)
out:SetAttribute("DJBoothUntouched",true)
out:SetAttribute("VIPUntouched",true)
out:SetAttribute("MallUntouched",true)
out:SetAttribute("RestroomUntouched",true)
out:SetAttribute("MonetizationUntouched",true)
out:SetAttribute("FishingUntouched",true)
out:SetAttribute("CeilingFillCount",6)
out:SetAttribute("BarPendantCount",3)
out:SetAttribute("SlimPillarsV6",true)
out:SetAttribute("MobileSightlineFix",true)
out:SetAttribute("MobilePremiumV7",true)
out:SetAttribute("FacadeDepthV7",true)
out:SetAttribute("InteriorDepthLocalOnlyV7",true)
out:SetAttribute("BarRealismV7",true)
out:SetAttribute("SocialLoungeRetained",true)
out.Parent=root

local C={
 black=Color3.fromRGB(8,8,10),
 ink=Color3.fromRGB(14,13,17),
 graphite=Color3.fromRGB(37,36,42),
 metal=Color3.fromRGB(65,63,70),
 brass=Color3.fromRGB(176,132,77),
 champagne=Color3.fromRGB(208,169,105),
 warm=Color3.fromRGB(255,221,190),
 pink=Color3.fromRGB(247,55,158),
 cyan=Color3.fromRGB(42,198,222),
 glass=Color3.fromRGB(182,195,204),
 smoked=Color3.fromRGB(72,79,88),
}

local function block(name,size,cf,color,material,transparency,parent)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.graphite;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=material~=Enum.Material.Neon
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or out
 return p
end

local function verticalCylinder(name,height,diameter,cf,color,material,transparency,parent)
 local p=block(name,Vector3.new(height,diameter,diameter),cf*CFrame.Angles(0,0,math.rad(90)),color,material,transparency,parent)
 p.Shape=Enum.PartType.Cylinder
 return p
end

local function point(parent,color,brightness,range)
 local l=Instance.new("PointLight")
 l.Name="MainClubLocalFill";l.Color=color;l.Brightness=brightness;l.Range=range;l.Shadows=false;l.Parent=parent
 return l
end

local function surface(parent,color,brightness,range,angle)
 local l=Instance.new("SurfaceLight")
 l.Name="MainClubCeilingFill";l.Face=Enum.NormalId.Bottom;l.Color=color;l.Brightness=brightness;l.Range=range;l.Angle=angle or 110;l.Shadows=false;l.Parent=parent
 return l
end

for _,d in ipairs(premium:GetDescendants()) do
 if (d:IsA("PointLight") or d:IsA("SurfaceLight")) and d.Name=="ArchitecturalWarmth" then
  d.Brightness=math.min(d.Brightness*1.16,.72)
 end
end

for _,d in ipairs(realism:GetDescendants()) do
 if d:IsA("SpotLight") and d.Parent and tostring(d.Parent.Name):match("^Downlight") then
  d.Brightness=math.min(d.Brightness*1.10,1.32)
 end
end

local ceilingFills={
 {-17,18.15,4},{2,18.15,4},{21,18.15,4},
 {-17,18.15,23},{2,18.15,23},{21,18.15,23},
}
for i,v in ipairs(ceilingFills) do
 local fixture=block("CeilingFillFixture_"..i,Vector3.new(3.6,.12,1.10),CFrame.new(v[1],v[2],v[3]),C.black,Enum.Material.Metal,0,out)
 local diffuser=block("CeilingFillDiffuser_"..i,Vector3.new(3.0,.03,.74),CFrame.new(v[1],v[2]-.075,v[3]),C.warm,Enum.Material.Neon,.76,out)
 diffuser.CastShadow=false
 surface(diffuser,C.warm,.42,18,115)
end

for i,z in ipairs({5.5,11.0,16.5}) do
 block("BarPendantStem_"..i,Vector3.new(.08,2.2,.08),CFrame.new(41.2,13.0,z),C.metal,Enum.Material.Metal,0,out)
 local shade=block("BarPendantShade_"..i,Vector3.new(.74,.30,.74),CFrame.new(41.2,11.86,z),C.black,Enum.Material.Metal,0,out)
 local bulb=block("BarPendantBulb_"..i,Vector3.new(.30,.18,.30),CFrame.new(41.2,11.64,z),C.warm,Enum.Material.Neon,.32,out)
 bulb.CastShadow=false
 point(bulb,C.warm,.30,8.5)
end

for i,x in ipairs({-9.5,15.5}) do
 local e=block("EntranceWarmEmitter_"..i,Vector3.new(.10,.10,.10),CFrame.new(x,8.2,-5.9),C.warm,Enum.Material.Neon,.86,out)
 e.CastShadow=false
 point(e,C.warm,.34,11.5)
end

for i,x in ipairs({-25.9,31.9}) do
 local edge=block("DanceFloorChampagneEdge_"..i,Vector3.new(.045,.04,34.5),CFrame.new(x,1.14,11.2),C.champagne,Enum.Material.Neon,.50,out)
 edge.CastShadow=false
end
block("FrontChampagneThreshold",Vector3.new(50,.04,.05),CFrame.new(3,1.14,-6.8),C.champagne,Enum.Material.Neon,.48,out)

for i,x in ipairs({-22.8,28.8}) do
 local mirror=block("EntranceReflectivePanel_"..i,Vector3.new(2.2,5.8,.08),CFrame.new(x,5.2,-5.65),C.glass,Enum.Material.Glass,.48,out)
 mirror.Reflectance=.12
 block("EntranceReflectiveTrim_"..i,Vector3.new(2.35,.07,.10),CFrame.new(x,8.12,-5.70),C.champagne,Enum.Material.Metal,0,out)
end

-- MOBILE SIGHTLINE FIX v6 -----------------------------------------------------
local frontPremium=root:FindFirstChild("Floor1FrontPremium")
local transition=frontPremium and frontPremium:FindFirstChild("EntranceToClubTransition",true)
if transition then
 local left=transition:FindFirstChild("PortalL")
 local right=transition:FindFirstChild("PortalR")
 if left and left:IsA("BasePart") then left.Size=Vector3.new(.62,10.8,.92);left.Material=Enum.Material.Metal;left.Color=C.black end
 if right and right:IsA("BasePart") then right.Size=Vector3.new(.62,10.8,.92);right.Material=Enum.Material.Metal;right.Color=C.black end
 local accentL=transition:FindFirstChild("PortalAccentL")
 local accentR=transition:FindFirstChild("PortalAccentR")
 if accentL and accentL:IsA("BasePart") then accentL.Size=Vector3.new(.055,7.8,.055);accentL.CFrame=CFrame.new(-13.14,6.25,-5.50);accentL.Transparency=.12 end
 if accentR and accentR:IsA("BasePart") then accentR.Size=Vector3.new(.055,7.8,.055);accentR.CFrame=CFrame.new(13.14,6.25,-5.50);accentR.Transparency=.12 end
end

local reveal=premium:FindFirstChild("MainClubEntranceReveal",true)
if reveal then
 for _,side in ipairs({-1,1}) do
  local pier=reveal:FindFirstChild("PortalPier_"..side)
  if pier and pier:IsA("BasePart") then pier.Size=Vector3.new(.46,10.6,.76);pier.Material=Enum.Material.Metal;pier.Color=C.black end
  local face=reveal:FindFirstChild("PortalFace_"..side)
  if face and face:IsA("BasePart") then face.Size=Vector3.new(.09,8.8,.44);face.Color=C.graphite end
  local inlay=reveal:FindFirstChild("ChampagneInlay_"..side)
  if inlay and inlay:IsA("BasePart") then inlay.Size=Vector3.new(.045,7.8,.06);inlay.Color=C.champagne end
  for rib=1,3 do
   local fin=reveal:FindFirstChild("RevealFin_"..side.."_"..rib)
   if fin and fin:IsA("BasePart") then fin.Size=Vector3.new(.07,5.6,.42) end
  end
 end
end

local shell=realism:FindFirstChild("PremiumShell",true)
if shell then
 for i=1,4 do
  local core=shell:FindFirstChild("ColumnCore"..i)
  local face=shell:FindFirstChild("ColumnFace"..i)
  local glow=shell:FindFirstChild("ColumnGlow"..i)
  if core and core:IsA("BasePart") and core.Position.Z<0 then
   core.Size=Vector3.new(1.12,18.5,1.12);core.Color=C.black;core.Material=Enum.Material.Metal
   if face and face:IsA("BasePart") then face.Size=Vector3.new(1.22,11.0,.09);face.CFrame=CFrame.new(core.Position.X,7.1,core.Position.Z-.61) end
   if glow and glow:IsA("BasePart") then glow.Size=Vector3.new(.04,7.8,.04);glow.CFrame=CFrame.new(core.Position.X,7.2,core.Position.Z-.68);glow.Transparency=.18 end
  end
 end
end

local collars=Instance.new("Folder")
collars.Name="SlimPillarFinishingV6";collars.Parent=out
for _,spec in ipairs({{x=-13.5,z=-5.0,color=C.cyan},{x=13.5,z=-5.0,color=C.pink}}) do
 block("BaseCollar",Vector3.new(.90,.14,1.18),CFrame.new(spec.x,1.18,spec.z),C.metal,Enum.Material.Metal,0,collars)
 block("TopCollar",Vector3.new(.90,.12,1.18),CFrame.new(spec.x,11.55,spec.z),C.champagne,Enum.Material.Metal,0,collars)
 local pin=block("AccentPin",Vector3.new(.045,5.8,.045),CFrame.new(spec.x,6.3,spec.z-.61),spec.color,Enum.Material.Neon,.08,collars)
 pin.CastShadow=false
 point(pin,spec.color,.10,4.2)
end

-- MOBILE PREMIUM REFINEMENT v7 -----------------------------------------------
-- Keep the center aperture open. Premium feel comes from shallow layered material,
-- reflection and local task light rather than larger geometry.
local facade=Instance.new("Model")
facade.Name="MobilePremiumFacadeV7";facade.Parent=out

block("FloatingSoffit",Vector3.new(27.2,.32,1.08),CFrame.new(3,12.02,-6.60),C.ink,Enum.Material.Metal,0,facade)
block("SoffitShadow",Vector3.new(25.4,.08,.34),CFrame.new(3,11.78,-6.88),C.black,Enum.Material.Metal,0,facade)
local soffitReveal=block("SoffitChampagneReveal",Vector3.new(23.8,.045,.06),CFrame.new(3,11.61,-7.08),C.champagne,Enum.Material.Neon,.38,facade)
soffitReveal.CastShadow=false
point(soffitReveal,C.warm,.18,6.8)

for _,spec in ipairs({{x=-12.35,accent=C.cyan},{x=18.35,accent=C.pink}}) do
 local fin=block("FacadeGlassFin",Vector3.new(.07,7.25,.72),CFrame.new(spec.x,6.20,-6.55),C.smoked,Enum.Material.Glass,.48,facade)
 fin.Reflectance=.10
 block("FacadeFinCap",Vector3.new(.11,.10,.78),CFrame.new(spec.x,9.90,-6.55),C.champagne,Enum.Material.Metal,0,facade)
 local pin=block("FacadeAccentPin",Vector3.new(.035,4.60,.035),CFrame.new(spec.x,6.25,-6.94),spec.accent,Enum.Material.Neon,.24,facade)
 pin.CastShadow=false
 point(pin,spec.accent,.08,3.8)
end

-- Local interior depth cues along the dance-floor perimeter. Low-range pools are
-- deliberately restrained so the room reads deeper on phone screens without flattening it.
local depth=Instance.new("Model")
depth.Name="InteriorDepthV7";depth.Parent=out
local depthSpecs={
 {x=-25.45,z=7.0,accent=C.warm},{x=-25.45,z=24.0,accent=C.pink},
 {x=31.45,z=7.0,accent=C.warm},{x=31.45,z=24.0,accent=C.cyan},
}
for i,spec in ipairs(depthSpecs) do
 block("DepthPillar_"..i,Vector3.new(.16,5.4,.54),CFrame.new(spec.x,4.1,spec.z),C.ink,Enum.Material.Metal,0,depth)
 block("DepthBrass_"..i,Vector3.new(.04,4.3,.06),CFrame.new(spec.x,4.2,spec.z-.31),C.brass,Enum.Material.Metal,0,depth)
 local emitter=block("DepthEmitter_"..i,Vector3.new(.08,.18,.18),CFrame.new(spec.x,5.2,spec.z-.38),spec.accent,Enum.Material.Neon,.55,depth)
 emitter.CastShadow=false
 point(emitter,spec.accent,spec.accent==C.warm and .22 or .14,7.2)
end

-- Realistic backbar: smoked mirror, framed edge, usable footrail and restrained stemware.
-- These details sit around the existing MainBarPremium geometry and PremiumV4 service tools.
local barFinish=Instance.new("Model")
barFinish.Name="MainBarRealismV7";barFinish.Parent=out
local mirror=block("BackbarSmokedMirror",Vector3.new(.08,9.6,25.2),CFrame.new(50.62,7.25,11),C.smoked,Enum.Material.Glass,.54,barFinish)
mirror.Reflectance=.16
block("MirrorFrameTop",Vector3.new(.13,.10,25.4),CFrame.new(50.54,12.10,11),C.brass,Enum.Material.Metal,0,barFinish)
block("MirrorFrameBottom",Vector3.new(.13,.10,25.4),CFrame.new(50.54,2.40,11),C.brass,Enum.Material.Metal,0,barFinish)
for _,z in ipairs({-1.55,23.55}) do
 block("MirrorFrameSide",Vector3.new(.13,9.8,.10),CFrame.new(50.54,7.25,z),C.brass,Enum.Material.Metal,0,barFinish)
end

block("CounterChampagneEdge",Vector3.new(.06,.10,24.7),CFrame.new(32.28,4.22,11),C.champagne,Enum.Material.Metal,0,barFinish)
block("BarFootRail",Vector3.new(.18,.18,21.8),CFrame.new(31.35,1.15,11),C.brass,Enum.Material.Metal,0,barFinish)
for i,z in ipairs({2.0,6.5,11.0,15.5,20.0}) do
 block("FootRailBracket_"..i,Vector3.new(1.25,.12,.12),CFrame.new(31.92,.98,z),C.metal,Enum.Material.Metal,0,barFinish)
end

local glassRack=Instance.new("Model")
glassRack.Name="BackbarStemware";glassRack.Parent=barFinish
block("StemwareRail",Vector3.new(.10,.10,10.8),CFrame.new(49.10,10.95,11),C.metal,Enum.Material.Metal,0,glassRack)
for i,z in ipairs({6.8,8.2,9.6,11.0,12.4,13.8,15.2}) do
 block("Stem_"..i,Vector3.new(.05,.72,.05),CFrame.new(48.98,10.50,z),C.glass,Enum.Material.Glass,.42,glassRack)
 local bowl=verticalCylinder("Bowl_"..i,.30,.52,CFrame.new(48.98,10.08,z),C.glass,Enum.Material.Glass,.58,glassRack)
 bowl.Reflectance=.05
end

local taskGlow=block("BackbarTaskGlow",Vector3.new(.04,.05,21.8),CFrame.new(49.24,3.18,11),C.warm,Enum.Material.Neon,.68,barFinish)
taskGlow.CastShadow=false
point(taskGlow,C.warm,.14,4.8)

print("[BBYA] Main Club Beauty v7 online: slim mobile sightline retained; facade depth, local interior depth and realistic bar finish added; global Lighting/DJ/audio/VIP/Mall/fishing untouched")