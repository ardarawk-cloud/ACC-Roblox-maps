-- BBYA SOCIAL HUB — BASEMENT FULL UPGRADE v1
-- Uniform underground lighting + premium lounge rebuild + room identity.
-- Audio routing / Basement Indo AutoDJ are intentionally untouched.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end

-- BasementPremiumUpgrade rebuilds the Underground model at server start. Do not
-- capture the older structural model: wait until the final premium room exists.
local basement=nil
local deadline=os.clock()+35
repeat
 local candidate=root:FindFirstChild("Underground")
 if candidate and candidate:GetAttribute("Pass")=="BASEMENT_PREMIUM_V2"
  and candidate:FindFirstChild("CheckerFloor")
  and candidate:FindFirstChild("WhitePentagonCeilingLights")
  and candidate:FindFirstChild("PremiumLounge") then
  basement=candidate
  break
 end
 task.wait(.15)
until os.clock()>=deadline
if not basement then warn("[BBYA] Basement Full Upgrade skipped: final premium Underground was not ready") return end

local checker=basement:FindFirstChild("CheckerFloor")
local pentagons=basement:FindFirstChild("WhitePentagonCeilingLights")
local oldLounge=basement:FindFirstChild("PremiumLounge")
task.wait(.55)
if basement.Parent~=root or root:FindFirstChild("Underground")~=basement then
 warn("[BBYA] Basement Full Upgrade aborted: Underground changed during startup")
 return
end

local old=basement:FindFirstChild("BasementFullUpgradeV1")
if old then old:Destroy() end

local out=Instance.new("Model")
out.Name="BasementFullUpgradeV1"
out.Parent=basement
out:SetAttribute("UniformLighting",true)
out:SetAttribute("PremiumLoungeV4",true)
out:SetAttribute("UndergroundIdentity",true)
out:SetAttribute("AudioSystemUntouched",true)

local C={
 dark=Color3.fromRGB(12,14,18),
 leather=Color3.fromRGB(26,28,33),
 leather2=Color3.fromRGB(36,39,45),
 fabric=Color3.fromRGB(46,49,56),
 metal=Color3.fromRGB(72,76,84),
 glass=Color3.fromRGB(71,82,93),
 white=Color3.fromRGB(232,234,230),
 blue=Color3.fromRGB(0,144,255),
 yellow=Color3.fromRGB(255,205,38),
 wash=Color3.fromRGB(225,232,242),
}

local function part(name,size,cf,color,mat,collide,parent,transparency)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.dark;p.Material=mat or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=false
 p.Transparency=transparency or 0;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or out
 return p
end

local function hiddenAnchor(name,pos,parent)
 local p=part(name,Vector3.new(.35,.35,.35),CFrame.new(pos),C.white,Enum.Material.SmoothPlastic,false,parent,1)
 p.CastShadow=false
 return p
end

-- -----------------------------------------------------------------------------
-- 1) UNIFORM LIGHTING
-- Spread broad, low-contrast fill across the whole room instead of creating
-- isolated bright checker tiles. Existing blue/yellow/pentagon fixtures remain.
-- -----------------------------------------------------------------------------
local lighting=Instance.new("Model");lighting.Name="UniformRoomLighting";lighting.Parent=out

-- Broaden existing pentagon wash so the left/right lounge zones receive the
-- same white base illumination without increasing visible fixture count.
if pentagons then
 for _,obj in ipairs(pentagons:GetDescendants()) do
  if obj:IsA("SurfaceLight") then
   obj.Brightness=.48
   obj.Range=18
   obj.Angle=150
   obj.Shadows=false
  end
 end
end

-- Tame the old narrow neon hotspots while retaining the blue/yellow club color.
for _,obj in ipairs(basement:GetChildren()) do
 if obj:IsA("BasePart") and (obj.Name:match("^CeilingBlue") or obj.Name:match("^CeilingYellow")) then
  for _,light in ipairs(obj:GetChildren()) do
   if light:IsA("SurfaceLight") then
    light.Brightness=.30
    light.Range=14
    light.Angle=150
    light.Shadows=false
   end
  end
 end
end

-- 12 broad ceiling washes. All anchors are invisible; only the room receives light.
for xi,x in ipairs({-45,-15,15,45}) do
 for zi,z in ipairs({-29,0,29}) do
  local a=hiddenAnchor(string.format("CeilingFill_%d_%d",xi,zi),Vector3.new(x,-1.55,z),lighting)
  local s=Instance.new("SurfaceLight")
  s.Name="EvenCeilingWash";s.Face=Enum.NormalId.Bottom;s.Color=C.wash;s.Brightness=.68;s.Range=28;s.Angle=155;s.Shadows=false;s.Parent=a
 end
end

-- Gentle side fill reveals sofas, acoustic panels and back corners evenly.
for i,d in ipairs({
 {Vector3.new(-54,-8,-27),Color3.fromRGB(205,220,239)},
 {Vector3.new(-54,-8,24),Color3.fromRGB(225,229,235)},
 {Vector3.new(54,-8,-27),Color3.fromRGB(225,229,235)},
 {Vector3.new(54,-8,24),Color3.fromRGB(205,220,239)},
 {Vector3.new(0,-7,-38),Color3.fromRGB(230,230,222)},
 {Vector3.new(0,-7,38),Color3.fromRGB(220,228,238)},
}) do
 local a=hiddenAnchor("SoftFill"..i,d[1],lighting)
 local l=Instance.new("PointLight")
 l.Name="SoftRoomFill";l.Color=d[2];l.Brightness=.38;l.Range=25;l.Shadows=false;l.Parent=a
end

-- Checker floor remains black/white but the white tiles are slightly softened so
-- they do not clip to pure white under the more uniform room wash.
if checker then
 for _,tile in ipairs(checker:GetChildren()) do
  if tile:IsA("BasePart") then
   tile.Reflectance=0
   local avg=(tile.Color.R+tile.Color.G+tile.Color.B)/3
   if avg>.55 then tile.Color=Color3.fromRGB(222,223,219) end
  end
 end
end

-- -----------------------------------------------------------------------------
-- 2) PREMIUM LOUNGE REBUILD
-- Replace the large block sofas with lower, cleaner club sectionals and subtle
-- under-seat accents. Keep the central dance floor fully open.
-- -----------------------------------------------------------------------------
if oldLounge and oldLounge.Parent then oldLounge:Destroy() end
local lounge=Instance.new("Model");lounge.Name="PremiumLoungeV4";lounge.Parent=out

local function lowGlow(name,size,cf,color,parent)
 local p=part(name,size,cf,color,Enum.Material.Neon,false,parent)
 p.CastShadow=false
 local l=Instance.new("SurfaceLight");l.Name="LoungeUnderglow";l.Face=Enum.NormalId.Top;l.Color=color;l.Brightness=.16;l.Range=5;l.Angle=120;l.Shadows=false;l.Parent=p
 return p
end

local function sectional(side,z,accent)
 local x=side*48.5
 local innerX=side*44.0
 local cluster=Instance.new("Model");cluster.Name=(side<0 and "West" or "East").."Sectional_"..tostring(z);cluster.Parent=lounge

 part("Plinth",Vector3.new(10.8,.72,15.5),CFrame.new(x,-14.15,z),Color3.fromRGB(18,20,24),Enum.Material.Metal,true,cluster)
 part("Seat",Vector3.new(10.5,1.45,15.1),CFrame.new(x,-13.15,z),C.leather2,Enum.Material.Fabric,true,cluster)

 part("BackShell",Vector3.new(1.55,4.25,15.3),CFrame.new(side*54.1,-11.35,z),C.leather,Enum.Material.Fabric,true,cluster)
 for n=-2,2 do
  local cz=z+n*2.7
  part("BackCushion"..n,Vector3.new(1.72,3.25,2.35),CFrame.new(side*53.15,-11.45,cz),C.fabric,Enum.Material.Fabric,false,cluster)
 end

 part("ArmFront",Vector3.new(9.6,2.15,1.15),CFrame.new(x,-12.35,z-7.0),C.leather,Enum.Material.Fabric,true,cluster)
 part("ArmRear",Vector3.new(9.6,2.15,1.15),CFrame.new(x,-12.35,z+7.0),C.leather,Enum.Material.Fabric,true,cluster)
 lowGlow("InnerUnderglow",Vector3.new(.12,.10,13.8),CFrame.new(innerX,-14.48,z),accent,cluster)
end

sectional(-1,-11,C.blue);sectional(-1,11,C.yellow)
sectional(1,-11,C.yellow);sectional(1,11,C.blue)

local function coffeeTable(name,x,z)
 local t=Instance.new("Model");t.Name=name;t.Parent=lounge
 part("Top",Vector3.new(7.2,.34,6.4),CFrame.new(x,-13.35,z),C.glass,Enum.Material.Glass,true,t,.18)
 for _,dx in ipairs({-2.8,2.8}) do
  for _,dz in ipairs({-2.35,2.35}) do part("Leg",Vector3.new(.22,1.35,.22),CFrame.new(x+dx,-14.05,z+dz),C.metal,Enum.Material.Metal,true,t) end
 end
end
coffeeTable("WestTable",-35.5,0);coffeeTable("EastTable",35.5,0)

-- -----------------------------------------------------------------------------
-- 3) UNDERGROUND ROOM IDENTITY / FINISHING
-- Clean back-wall identity behind the DJ booth. No interaction or audio logic.
-- -----------------------------------------------------------------------------
local identity=Instance.new("Model");identity.Name="UndergroundIdentity";identity.Parent=out
local sign=part("IdentityPanel",Vector3.new(42,7,.26),CFrame.new(0,-7.0,42.38),Color3.fromRGB(17,20,25),Enum.Material.Metal,false,identity)
sign.CanQuery=true
local sg=Instance.new("SurfaceGui");sg.Name="IdentityGui";sg.Face=Enum.NormalId.Front;sg.PixelsPerStud=70;sg.LightInfluence=.15;sg.Parent=sign
local title=Instance.new("TextLabel");title.BackgroundTransparency=1;title.Position=UDim2.fromScale(.04,.10);title.Size=UDim2.fromScale(.92,.48);title.Text="BBYA UNDERGROUND";title.Font=Enum.Font.GothamBlack;title.TextScaled=true;title.TextColor3=C.white;title.Parent=sg
local sub=Instance.new("TextLabel");sub.BackgroundTransparency=1;sub.Position=UDim2.fromScale(.08,.62);sub.Size=UDim2.fromScale(.84,.20);sub.Text="INDO ROOM  •  BREAKBEAT  •  INDO BOUNCE";sub.Font=Enum.Font.GothamBold;sub.TextScaled=true;sub.TextColor3=C.blue;sub.Parent=sg

for _,x in ipairs({-48,-24,0,24,48}) do
 part("NorthTrim"..x,Vector3.new(.09,9.8,.18),CFrame.new(x,-7.8,42.55),C.metal,Enum.Material.Metal,false,identity)
 part("SouthTrim"..x,Vector3.new(.09,9.8,.18),CFrame.new(x,-7.8,-42.55),C.metal,Enum.Material.Metal,false,identity)
end

basement:SetAttribute("LightingProfile","EVEN_UNDERGROUND_V4")
basement:SetAttribute("LoungeProfile","LOW_SECTIONAL_V4")
basement:SetAttribute("RoomIdentity","BBYA_UNDERGROUND_INDO")

print("[BBYA] Basement Full Upgrade v1 online: even lighting / premium sectionals / underground identity")
