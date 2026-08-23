-- BBYA SOCIAL HUB — MAIN CLUB BEAUTY v5
-- Local-only beauty/visibility pass layered after MainClubPremiumV4.
-- Slightly brighter premium club ambience without touching global Lighting, audio, VIP, Mall, restroom or monetization.
-- Stage and DJ booth geometry are intentionally untouched.
-- v6 mobile sightline revision: slim premium entrance/front pillars.

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
out:SetAttribute("CeilingFillCount",6)
out:SetAttribute("BarPendantCount",3)
out:SetAttribute("SlimPillarsV6",true)
out:SetAttribute("MobileSightlineFix",true)
out.Parent=root

local C={
 black=Color3.fromRGB(8,8,10),
 graphite=Color3.fromRGB(37,36,42),
 metal=Color3.fromRGB(65,63,70),
 champagne=Color3.fromRGB(208,169,105),
 warm=Color3.fromRGB(255,221,190),
 pink=Color3.fromRGB(247,55,158),
 cyan=Color3.fromRGB(42,198,222),
 glass=Color3.fromRGB(182,195,204),
}

local function block(name,size,cf,color,material,transparency,parent)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.graphite;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=material~=Enum.Material.Neon
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or out
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

print("[BBYA] Main Club Beauty v5 + slim pillars v6 online: sightline opened; premium trim retained; global Lighting/audio untouched")