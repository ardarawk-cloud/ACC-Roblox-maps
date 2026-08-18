-- BBYA SOCIAL HUB — LIVE PLAYTEST FIX PASS v4.7
-- Built from real mobile screenshots: improve readability, reduce sign clutter,
-- smooth prototype surfaces, tone neon, and add architectural fill lighting.

local Lighting = game:GetService("Lighting")

local ROOT_NAME = "BBYA Live Fix v4.7"
local old = workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end
local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace

local PINK = Color3.fromRGB(255,72,196)
local CYAN = Color3.fromRGB(70,215,255)
local GOLD = Color3.fromRGB(255,198,105)
local DARK = Color3.fromRGB(31,29,39)
local DARK2 = Color3.fromRGB(45,41,52)
local WARM = Color3.fromRGB(255,226,196)

-- -------------------------------------------------------------------------
-- 1. Readable premium night instead of near-black voids.
-- -------------------------------------------------------------------------
Lighting.ClockTime = 22.7
Lighting.Brightness = 2.35
Lighting.ExposureCompensation = 0.22
Lighting.Ambient = Color3.fromRGB(55,50,70)
Lighting.OutdoorAmbient = Color3.fromRGB(34,35,51)
Lighting.FogColor = Color3.fromRGB(30,32,48)
Lighting.FogStart = 520
Lighting.FogEnd = 1500

local bloom = Lighting:FindFirstChild("BBYA_Bloom_v4")
if bloom and bloom:IsA("BloomEffect") then
 bloom.Intensity = .32
 bloom.Size = 20
 bloom.Threshold = 1.55
end
local color = Lighting:FindFirstChild("BBYA_Color_v4")
if color and color:IsA("ColorCorrectionEffect") then
 color.Brightness = .08
 color.Contrast = .01
 color.Saturation = .03
 color.TintColor = Color3.fromRGB(248,242,255)
end
local atmosphere = Lighting:FindFirstChild("BBYA_Atmosphere_v4")
if atmosphere and atmosphere:IsA("Atmosphere") then
 atmosphere.Density = .105
 atmosphere.Haze = .35
 atmosphere.Glare = .025
 atmosphere.Color = Color3.fromRGB(120,123,150)
 atmosphere.Decay = Color3.fromRGB(48,38,66)
end

local function lightAnchor(name,pos,color,brightness,range)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=Vector3.new(1,1,1)
 p.CFrame=CFrame.new(pos)
 p.Transparency=1
 p.Anchored=true
 p.CanCollide=false
 p.CanTouch=false
 p.CanQuery=false
 p.Parent=root
 local l=Instance.new("PointLight")
 l.Color=color
 l.Brightness=brightness
 l.Range=range
 l.Shadows=false
 l.Parent=p
 return p
end

-- Soft architectural fill: enough to read avatars/walls without washing neon out.
for _,cfg in ipairs({
 {Vector3.new(0,18,24),WARM,.72,34},
 {Vector3.new(0,18,-20),Color3.fromRGB(214,205,255),.62,34},
 {Vector3.new(-60,16,2),Color3.fromRGB(210,220,255),.56,27},
 {Vector3.new(60,16,2),Color3.fromRGB(255,205,232),.56,27},
 {Vector3.new(0,48,-20),Color3.fromRGB(208,225,255),.62,34},
 {Vector3.new(-58,48,20),WARM,.52,28},
 {Vector3.new(58,48,20),Color3.fromRGB(255,210,235),.52,28},
}) do
 lightAnchor("Premium Fill Light",cfg[1],cfg[2],cfg[3],cfg[4])
end

-- -------------------------------------------------------------------------
-- 2. Remove the obvious prototype/stud look and improve dark material read.
-- -------------------------------------------------------------------------
for _,obj in ipairs(workspace:GetDescendants()) do
 if obj:IsA("BasePart") then
  obj.TopSurface = Enum.SurfaceType.Smooth
  obj.BottomSurface = Enum.SurfaceType.Smooth
  local n=string.lower(obj.Name)
  if string.find(n,"stair") or string.find(n,"step") then
   if obj.Material ~= Enum.Material.Neon and obj.Material ~= Enum.Material.Glass then
    obj.Material = Enum.Material.Slate
    obj.Color = DARK2
   end
  end
  -- Very black structural slabs were disappearing completely on phones.
  if obj.Material ~= Enum.Material.Neon and obj.Material ~= Enum.Material.Glass and obj.Transparency < .15 then
   local c=obj.Color
   if c.R < .075 and c.G < .075 and c.B < .09 and not string.find(n,"skyline") then
    obj.Color = DARK
   end
  end
  -- Keep dance-floor language focused on BBYA pink/cyan, not rainbow arcade.
  if string.find(n,"dance edge") or string.find(n,"dance neon") then
   obj.Color = obj.Position.X < 0 and CYAN or PINK
   local l=obj:FindFirstChildOfClass("PointLight")
   if l then l.Color=obj.Color;l.Brightness=math.min(l.Brightness,.38);l.Range=math.min(l.Range,6) end
  end
 end
end

-- Stronger anchor materials so major levels are readable in screenshots.
local anchorLooks={
 ["Main Floor"]={Color3.fromRGB(48,45,55),Enum.Material.Slate},
 ["Rooftop Floor"]={Color3.fromRGB(51,47,57),Enum.Material.Slate},
 ["Left VIP Platform"]={Color3.fromRGB(62,55,68),Enum.Material.Marble},
 ["Right VIP Platform"]={Color3.fromRGB(62,55,68),Enum.Material.Marble},
 ["DJ Stage"]={Color3.fromRGB(35,31,42),Enum.Material.Metal},
 ["DJ Booth"]={Color3.fromRGB(47,39,54),Enum.Material.Metal},
 ["BBYA Bar"]={Color3.fromRGB(50,40,51),Enum.Material.Marble},
}
for name,look in pairs(anchorLooks) do
 local p=workspace:FindFirstChild(name,true)
 if p and p:IsA("BasePart") then p.Color=look[1];p.Material=look[2] end
end

-- -------------------------------------------------------------------------
-- 3. Signage hierarchy: one hero message per sightline.
-- -------------------------------------------------------------------------
local hideNames={
 "WF Arrival Welcome",
 "WF Lobby Directory",
 "WF West Services",
 "WF East Services",
 "WF West VIP",
 "WF East VIP",
 "WF Stairs West",
 "WF Stairs East",
 "Lobby Direction",
 "VIP Left Sign",
 "VIP Right Sign",
 "Roof Wayfinding L",
 "Roof Wayfinding R",
 "Concierge Sign",
}
for _,name in ipairs(hideNames) do
 local o=workspace:FindFirstChild(name,true)
 if o and o:IsA("BasePart") then
  o.Transparency=1
  o.CanCollide=false
  for _,g in ipairs(o:GetChildren()) do if g:IsA("SurfaceGui") then g.Enabled=false end end
 end
end

local resizeSigns={
 ["West VIP Gate Sign"]=Vector3.new(8.5,1.8,.3),
 ["East VIP Gate Sign"]=Vector3.new(8.5,1.8,.3),
 ["Photo Portal Sign"]=Vector3.new(18,2.3,.3),
 ["Sky Lift Vertical Sign"]=Vector3.new(5.5,7,.3),
}
for name,size in pairs(resizeSigns) do
 local o=workspace:FindFirstChild(name,true)
 if o and o:IsA("BasePart") then o.Size=size end
end

-- -------------------------------------------------------------------------
-- 4. Glass rails / stair stringers: cheap geometry that makes stairs read built-in.
-- -------------------------------------------------------------------------
local function part(name,size,cf,color,material,transparency)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=false;p.CanTouch=false
 p.Material=material or Enum.Material.Metal;p.Color=color or DARK2;p.Transparency=transparency or 0
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=root
 return p
end

-- VIP stair side rails following the existing stair vectors.
for _,side in ipairs({-1,1}) do
 local x=47*side
 local endX=68*side
 local z1,z2=27,11
 local mid=Vector3.new((x+endX)/2,8.2,(z1+z2)/2)
 local length=(Vector3.new(endX,0,z2)-Vector3.new(x,0,z1)).Magnitude
 local yaw=math.atan2(endX-x,z2-z1)
 for _,offset in ipairs({-4.7,4.7}) do
  local cf=CFrame.new(mid)*CFrame.Angles(0,yaw,math.rad(-26*side))*CFrame.new(offset,0,0)
  part("VIP Stair Glass Rail",Vector3.new(.35,3.4,length),cf,Color3.fromRGB(77,105,135),Enum.Material.Glass,.45)
 end
end

-- Rooftop stairs get simple side stringers to break the giant block-step silhouette.
for _,x in ipairs({-78,78}) do
 for _,ox in ipairs({-4.7,4.7}) do
  local beam=part("Roof Stair Stringer",Vector3.new(.45,3,39),CFrame.new(x+ox,24.5,39)*CFrame.Angles(math.rad(-33),0,0),DARK2,Enum.Material.Metal,0)
  beam.CanQuery=false
 end
end

workspace:SetAttribute("BBYALiveFix","4.7")
print("[BBYA] Live Fix v4.7 loaded — brighter premium night, clean signage, smoother geometry")
