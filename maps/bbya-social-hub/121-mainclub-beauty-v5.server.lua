-- BBYA SOCIAL HUB — MAIN CLUB BEAUTY v5
-- Local-only beauty/visibility pass layered after MainClubPremiumV4.
-- Slightly brighter premium club ambience without touching global Lighting, audio, VIP, Mall, restroom or monetization.
-- Stage and DJ booth geometry are intentionally untouched.

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

-- 1) Slightly lift the existing local architectural warmth from the Premium v4 pass.
for _,d in ipairs(premium:GetDescendants()) do
 if (d:IsA("PointLight") or d:IsA("SurfaceLight")) and d.Name=="ArchitecturalWarmth" then
  d.Brightness=math.min(d.Brightness*1.16,.72)
 end
end

-- 2) Lift only the base Main Club ceiling downlights. No global Lighting service mutation.
for _,d in ipairs(realism:GetDescendants()) do
 if d:IsA("SpotLight") and d.Parent and tostring(d.Parent.Name):match("^Downlight") then
  d.Brightness=math.min(d.Brightness*1.10,1.32)
 end
end

-- 3) Six broad, soft warm ceiling fills. These reveal faces/furniture but keep the room club-dark.
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

-- 4) Realistic bar pendants + local service light. Main bar becomes readable without flooding dance floor.
for i,z in ipairs({5.5,11.0,16.5}) do
 block("BarPendantStem_"..i,Vector3.new(.08,2.2,.08),CFrame.new(41.2,13.0,z),C.metal,Enum.Material.Metal,0,out)
 local shade=block("BarPendantShade_"..i,Vector3.new(.74,.30,.74),CFrame.new(41.2,11.86,z),C.black,Enum.Material.Metal,0,out)
 local bulb=block("BarPendantBulb_"..i,Vector3.new(.30,.18,.30),CFrame.new(41.2,11.64,z),C.warm,Enum.Material.Neon,.32,out)
 bulb.CastShadow=false
 point(bulb,C.warm,.30,8.5)
end

-- 5) Entrance reveal fill: enough light to read the portal and faces on arrival.
for i,x in ipairs({-9.5,15.5}) do
 local e=block("EntranceWarmEmitter_"..i,Vector3.new(.10,.10,.10),CFrame.new(x,8.2,-5.9),C.warm,Enum.Material.Neon,.86,out)
 e.CastShadow=false
 point(e,C.warm,.34,11.5)
end

-- 6) Thin champagne edge lines give the dance floor a premium frame without becoming a neon grid.
for i,x in ipairs({-25.9,31.9}) do
 local edge=block("DanceFloorChampagneEdge_"..i,Vector3.new(.045,.04,34.5),CFrame.new(x,1.14,11.2),C.champagne,Enum.Material.Neon,.50,out)
 edge.CastShadow=false
end
block("FrontChampagneThreshold",Vector3.new(50,.04,.05),CFrame.new(3,1.14,-6.8),C.champagne,Enum.Material.Neon,.48,out)

-- 7) Small reflective side details near the entrance increase depth while staying collision-free.
for i,x in ipairs({-22.8,28.8}) do
 local mirror=block("EntranceReflectivePanel_"..i,Vector3.new(2.2,5.8,.08),CFrame.new(x,5.2,-5.65),C.glass,Enum.Material.Glass,.48,out)
 mirror.Reflectance=.12
 block("EntranceReflectiveTrim_"..i,Vector3.new(2.35,.07,.10),CFrame.new(x,8.12,-5.70),C.champagne,Enum.Material.Metal,0,out)
end

print("[BBYA] Main Club Beauty v5 online: local warm fill + premium bar/entrance finish + slightly brighter club; global Lighting/audio untouched")
