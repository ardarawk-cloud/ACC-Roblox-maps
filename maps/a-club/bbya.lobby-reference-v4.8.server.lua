-- BBYA SOCIAL HUB — FRONT LOBBY REFERENCE REBUILD v4.8
-- Direction from live reference: giant BBYA crown neon identity + warm premium social lobby.

local ROOT_NAME = "BBYA Front Lobby v4.8"
local old = workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace

local C = {
 dark = Color3.fromRGB(28,24,31),
 dark2 = Color3.fromRGB(43,35,45),
 stone = Color3.fromRGB(72,59,62),
 wood = Color3.fromRGB(88,62,49),
 pink = Color3.fromRGB(255,82,211),
 pinkSoft = Color3.fromRGB(255,138,225),
 purple = Color3.fromRGB(155,84,210),
 warm = Color3.fromRGB(255,190,132),
 warmWhite = Color3.fromRGB(255,231,205),
 green = Color3.fromRGB(68,115,76),
 glass = Color3.fromRGB(100,75,105),
}

local function part(name,size,cf,color,material,transparency,collide,parent)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=collide~=false
 p.CanTouch=false;p.Material=material or Enum.Material.SmoothPlastic;p.Color=color or C.dark
 p.Transparency=transparency or 0;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or root
 return p
end

local function light(name,pos,color,brightness,range,parent)
 local a=part(name,Vector3.new(.4,.4,.4),CFrame.new(pos),color,Enum.Material.Neon,1,false,parent)
 local l=Instance.new("PointLight")
 l.Color=color;l.Brightness=brightness;l.Range=range;l.Shadows=false;l.Parent=a
 return a
end

local function surfaceText(base,text,color,font,face)
 local g=Instance.new("SurfaceGui")
 g.Face=face
 g.LightInfluence=0
 g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
 g.PixelsPerStud=36
 g.Parent=base
 local t=Instance.new("TextLabel")
 t.Size=UDim2.fromScale(1,1)
 t.BackgroundTransparency=1
 t.Text=text
 t.TextColor3=color
 t.TextStrokeColor3=Color3.fromRGB(120,22,95)
 t.TextStrokeTransparency=.35
 t.Font=font or Enum.Font.GothamBlack
 t.TextScaled=true
 t.TextWrapped=true
 t.Parent=g
 return t
end

local function doubleSign(name,text,cf,size,color,font,parent)
 local p=part(name,size,cf,C.dark,Enum.Material.Metal,0,false,parent)
 surfaceText(p,text,color,font,Enum.NormalId.Front)
 surfaceText(p,text,color,font,Enum.NormalId.Back)
 return p
end

local function neonBar(name,size,cf,color,parent,brightness,range)
 local p=part(name,size,cf,color,Enum.Material.Neon,0,false,parent)
 local l=Instance.new("PointLight")
 l.Color=color;l.Brightness=brightness or .45;l.Range=range or 7;l.Shadows=false;l.Parent=p
 return p
end

local function planter(name,pos,size,parent)
 part(name.." Base",size,CFrame.new(pos),C.dark2,Enum.Material.Slate,0,true,parent)
 part(name.." Soil",Vector3.new(size.X-.7,.35,size.Z-.7),CFrame.new(pos+Vector3.new(0,size.Y/2+.12,0)),Color3.fromRGB(60,42,34),Enum.Material.Ground,0,false,parent)
 for i=-1,1 do
  local stem=part(name.." Stem "..i,Vector3.new(.35,3.2,.35),CFrame.new(pos+Vector3.new(i*1.2,size.Y/2+1.7,0)),Color3.fromRGB(55,93,62),Enum.Material.SmoothPlastic,0,false,parent)
  stem.CFrame=stem.CFrame*CFrame.Angles(0,0,math.rad(i*12))
  part(name.." Leaf "..i,Vector3.new(1.8,.25,4),stem.CFrame*CFrame.new(0,1.3,0)*CFrame.Angles(math.rad(18),0,0),C.green,Enum.Material.Grass,0,false,parent)
 end
end

local function seat(name,cf,size,color,parent)
 local s=Instance.new("Seat")
 s.Name=name;s.Size=size;s.CFrame=cf;s.Anchored=true;s.Material=Enum.Material.Fabric;s.Color=color
 s.TopSurface=Enum.SurfaceType.Smooth;s.BottomSurface=Enum.SurfaceType.Smooth;s.Parent=parent
 return s
end

-- Retire older lobby/front branding that caused stacked signage.
for _,name in ipairs({
 "BBYA Arrival Sign","Arrival Subtitle","Facade Crown Pink","Facade Crown Cyan",
 "Portal Title","WF Arrival Welcome","WF Lobby Directory","Lobby Direction","Concierge Sign"
}) do
 local o=workspace:FindFirstChild(name,true)
 if o and o:IsA("BasePart") then
  o.Transparency=1;o.CanCollide=false
  for _,c in ipairs(o:GetChildren()) do if c:IsA("SurfaceGui") then c.Enabled=false end end
 end
end

-- FRONT IDENTITY -----------------------------------------------------------
local facade=Instance.new("Folder");facade.Name="01 BBYA Crown Facade";facade.Parent=root
part("Lobby Hero Backboard",Vector3.new(104,24,2),CFrame.new(0,22,80.4),C.dark,Enum.Material.Metal,0,true,facade)
part("Lobby Hero Lower Beam",Vector3.new(110,2.2,5),CFrame.new(0,10.5,79.2),C.dark2,Enum.Material.Metal,0,true,facade)

-- Large wordmark, with both faces so it reads from outside and inside.
doubleSign("BBYA Hero Wordmark","B B Y A",CFrame.new(0,24,79.2),Vector3.new(78,10,.45),C.pinkSoft,Enum.Font.GothamBlack,facade)
doubleSign("BBYA Social Hub Subtitle","S O C I A L   H U B",CFrame.new(0,17,79.15),Vector3.new(54,4,.38),C.pinkSoft,Enum.Font.GothamMedium,facade)

-- Crown made from neon tubes rather than a flat text glyph.
local crownY,crownZ=34,78.8
neonBar("Crown Base",Vector3.new(18,.45,.45),CFrame.new(0,crownY-3,crownZ),C.pink,facade,.7,10)
for i,cfg in ipairs({
 {-8,0,5,24},{-4,3,5,-24},{0,6,5,0},{4,3,5,24},{8,0,5,-24}
}) do
 local x,y,len,rot=cfg[1],cfg[2],cfg[3],cfg[4]
 neonBar("Crown Stroke "..i,Vector3.new(.48,len,.48),CFrame.new(x,crownY+y,crownZ)*CFrame.Angles(0,0,math.rad(rot)),C.pink,facade,.72,10)
end
part("Crown Jewel",Vector3.new(1.2,1.2,1.2),CFrame.new(10.2,crownY+5,crownZ),C.pinkSoft,Enum.Material.Neon,0,false,facade).Shape=Enum.PartType.Ball

-- Entrance opening beneath logo.
part("Entrance Header",Vector3.new(70,2,6),CFrame.new(0,12,71),C.dark,Enum.Material.Metal,0,true,facade)
for _,x in ipairs({-35,35}) do
 part("Entrance Pier "..x,Vector3.new(4,12,6),CFrame.new(x,6.5,71),C.dark2,Enum.Material.Slate,0,true,facade)
 neonBar("Entrance Pink Edge "..x,Vector3.new(.22,9,.22),CFrame.new(x+(x<0 and 2.1 or -2.1),7,67.8),C.pink,facade,.4,6)
end

-- WARM SOCIAL LOBBY --------------------------------------------------------
local lobby=Instance.new("Folder");lobby.Name="02 Warm Social Lobby";lobby.Parent=root
part("Lobby Warm Floor",Vector3.new(88,.32,28),CFrame.new(0,2.58,60),Color3.fromRGB(89,72,69),Enum.Material.Slate,0,true,lobby)
part("Lobby Warm Ceiling",Vector3.new(90,.8,30),CFrame.new(0,18.8,60),C.dark,Enum.Material.Metal,0,true,lobby)

-- Clear 18-stud central walkway; social zones stay left/right.
part("Lobby Center Runner",Vector3.new(18,.08,25),CFrame.new(0,2.78,60),Color3.fromRGB(116,84,82),Enum.Material.Marble,0,false,lobby)
neonBar("Lobby Runner Pink L",Vector3.new(.12,.08,24),CFrame.new(-9.1,2.85,60),C.pink,lobby,.24,4)
neonBar("Lobby Runner Pink R",Vector3.new(.12,.08,24),CFrame.new(9.1,2.85,60),C.pink,lobby,.24,4)

-- Left illuminated bar / display window like the reference.
part("Lobby Bar Back",Vector3.new(27,10,1),CFrame.new(-27,8,48.5),C.dark2,Enum.Material.Slate,0,true,lobby)
part("Lobby Bar Counter",Vector3.new(27,3.3,6),CFrame.new(-27,4.2,54),Color3.fromRGB(69,50,57),Enum.Material.Marble,0,true,lobby)
neonBar("Lobby Bar Underglow",Vector3.new(25,.14,.16),CFrame.new(-27,2.65,51.1),C.pink,lobby,.32,5)
for row=0,2 do
 part("Lobby Shelf "..row,Vector3.new(22,.25,1.4),CFrame.new(-27,6+row*2.4,49.1),Color3.fromRGB(74,53,64),Enum.Material.WoodPlanks,0,false,lobby)
 for i=-4,4 do
  if i%2==0 then
   local col=i%4==0 and C.pinkSoft or C.warm
   neonBar("Lobby Bottle "..row.." "..i,Vector3.new(.45,1.25,.45),CFrame.new(-27+i*2.1,6.7+row*2.4,48.2),col,lobby,.12,2.5)
  end
 end
end

-- Right lounge cluster, no fake NPCs.
for _,cfg in ipairs({{25,57,0},{31,64,180},{20,66,-25}}) do
 seat("Lobby Lounge Seat",CFrame.new(cfg[1],3.4,cfg[2])*CFrame.Angles(0,math.rad(cfg[3]),0),Vector3.new(7,1.4,4.2),Color3.fromRGB(91,60,78),lobby)
end
part("Lobby Lounge Table",Vector3.new(6,.9,5),CFrame.new(27,3.25,61),Color3.fromRGB(58,45,53),Enum.Material.Glass,.12,true,lobby)
neonBar("Lounge Table Glow",Vector3.new(5,.1,.14),CFrame.new(27,3.75,58.55),C.pink,lobby,.18,4)

-- Planters frame the foreground like the reference without blocking entry.
planter("Lobby Planter L",Vector3.new(-41,4,66),Vector3.new(10,3,8),lobby)
planter("Lobby Planter R",Vector3.new(41,4,66),Vector3.new(10,3,8),lobby)
neonBar("Planter Glow L",Vector3.new(8,.12,.18),CFrame.new(-41,5.6,62.2),C.pink,lobby,.22,4)
neonBar("Planter Glow R",Vector3.new(8,.12,.18),CFrame.new(41,5.6,62.2),C.pink,lobby,.22,4)

-- Warm layered lighting: pink identity + amber hospitality light.
for _,cfg in ipairs({
 {Vector3.new(-26,13,56),C.pinkSoft,.55,22},
 {Vector3.new(26,13,56),C.pinkSoft,.45,20},
 {Vector3.new(-12,13,66),C.warmWhite,.55,22},
 {Vector3.new(12,13,66),C.warmWhite,.55,22},
 {Vector3.new(0,14,52),C.warm,.35,18},
}) do light("Lobby Fill",cfg[1],cfg[2],cfg[3],cfg[4],lobby) end

-- Small destination copy only; no stacked directory wall.
doubleSign("Lobby Welcome Small","WELCOME IN",CFrame.new(0,10.2,47.9),Vector3.new(18,2.1,.28),C.warmWhite,Enum.Font.GothamBold,lobby)

workspace:SetAttribute("BBYAFrontLobby","4.8")
print("[BBYA] Front Lobby v4.8 loaded — crown neon identity + warm premium social lobby")
