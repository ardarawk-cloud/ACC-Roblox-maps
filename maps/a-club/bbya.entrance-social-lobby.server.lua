-- BBYA SOCIAL HUB — Entrance Social Lobby v1.0
-- Reference direction: neon BBYA crown signage + premium dark social lobby.
local ROOT_NAME = "BBYA Entrance Social Lobby v1"
local old = workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end
local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace

local C = {
 black = Color3.fromRGB(8,8,13),
 stone = Color3.fromRGB(24,22,30),
 pink = Color3.fromRGB(255,42,190),
 magenta = Color3.fromRGB(220,35,255),
 purple = Color3.fromRGB(93,42,140),
 warm = Color3.fromRGB(255,184,90),
 green = Color3.fromRGB(38,92,62),
 glass = Color3.fromRGB(70,54,90),
}

local function part(name,size,cf,color,material,transparency,collide,parent)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=collide~=false
 p.Color=color or C.stone;p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=transparency or 0
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or root
 return p
end

local function neon(name,size,cf,color,parent)
 local p=part(name,size,cf,color or C.pink,Enum.Material.Neon,0,false,parent)
 local l=Instance.new("PointLight");l.Color=p.Color;l.Brightness=1.8;l.Range=20;l.Shadows=false;l.Parent=p
 return p
end

local function label(partObj,text,color)
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=30;gui.LightInfluence=0;gui.Parent=partObj
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Font=Enum.Font.GothamBlack;t.Text=text;t.TextScaled=true;t.TextColor3=color or C.pink;t.TextStrokeTransparency=.35;t.Parent=gui
 return t
end

local function sign(name,text,cf,size,color,parent)
 local b=part(name,size,cf,C.black,Enum.Material.SmoothPlastic,0,false,parent)
 label(b,text,color or C.pink)
 return b
end

local function seat(name,cf,parent)
 local s=Instance.new("Seat");s.Name=name;s.Size=Vector3.new(5.5,1.2,4.5);s.CFrame=cf;s.Anchored=true;s.Color=Color3.fromRGB(55,35,68);s.Material=Enum.Material.Fabric;s.Parent=parent or root;return s
end

local function planter(name,pos,parent)
 part(name.." Box",Vector3.new(6,2,3),CFrame.new(pos),C.black,Enum.Material.Slate,0,true,parent)
 neon(name.." Glow",Vector3.new(5.5,.18,2.5),CFrame.new(pos+Vector3.new(0,1.1,0)),C.pink,parent)
 for i=-1,1 do
  local stem=part(name.." Stem "..i,Vector3.new(.35,3,.35),CFrame.new(pos+Vector3.new(i*1.25,2.4,0)),C.green,Enum.Material.SmoothPlastic,0,false,parent)
  part(name.." Leaf "..i,Vector3.new(1.8,.35,3),stem.CFrame*CFrame.new(0,1,0)*CFrame.Angles(0,math.rad(i*25),math.rad(-18)),C.green,Enum.Material.SmoothPlastic,0,false,parent)
 end
end

local lobby=Instance.new("Folder");lobby.Name="Entrance Social Lobby";lobby.Parent=root

-- Covered entry volume, immediately behind monumental exterior gateway.
part("Lobby Floor",Vector3.new(104,2,42),CFrame.new(0,1,58),C.stone,Enum.Material.Slate,0,true,lobby)
part("Lobby Ceiling",Vector3.new(104,2,42),CFrame.new(0,20,58),C.black,Enum.Material.Metal,0,true,lobby)
part("Lobby Back Wall",Vector3.new(104,20,2),CFrame.new(0,10,38),C.black,Enum.Material.Slate,0,true,lobby)
part("Lobby Left Wall",Vector3.new(2,20,42),CFrame.new(-51,10,58),C.black,Enum.Material.Slate,0,true,lobby)
part("Lobby Right Wall",Vector3.new(2,20,42),CFrame.new(51,10,58),C.black,Enum.Material.Slate,0,true,lobby)

-- Hero sign inspired by the approved reference, placed as first visual anchor.
sign("Hero BBYA Sign","BBYA",CFrame.new(0,15.2,39.2),Vector3.new(64,9,.6),C.pink,lobby)
sign("Hero Social Hub Sign","SOCIAL HUB",CFrame.new(0,9.3,39.15),Vector3.new(42,4,.5),Color3.fromRGB(255,120,225),lobby)
-- simple crown silhouette above logo
for i,x in ipairs({-9,-4.5,0,4.5,9}) do
 local h=(i==3) and 5.5 or ((i==2 or i==4) and 4.5 or 3.2)
 neon("Crown Spike "..i,Vector3.new(1,h,.8),CFrame.new(x,21.5+h/2,39.4)*CFrame.Angles(0,0,math.rad((i-3)*9)),C.pink,lobby)
end
neon("Crown Base",Vector3.new(24,.8,.8),CFrame.new(0,21.7,39.4),C.pink,lobby)

-- Bar directly visible from the entry axis.
part("Social Bar Counter",Vector3.new(34,4,7),CFrame.new(-23,4.1,50),Color3.fromRGB(21,18,26),Enum.Material.Marble,0,true,lobby)
neon("Social Bar Front Glow",Vector3.new(32,.35,.35),CFrame.new(-23,5.4,53.6),C.pink,lobby)
part("Social Bar Back",Vector3.new(32,10,2),CFrame.new(-23,8,42.8),C.black,Enum.Material.Slate,0,true,lobby)
for x=-34,-12,5.5 do
 neon("Bottle Shelf "..x,Vector3.new(8,.3,.4),CFrame.new(x,8,44),C.magenta,lobby)
end
sign("Bar Sign","BBYA SOCIAL BAR",CFrame.new(-23,13.2,43.8),Vector3.new(28,3,.4),C.pink,lobby)

-- Social lounge pockets.
for i,z in ipairs({51,61,71}) do
 seat("Lounge Left "..i,CFrame.new(18,2.8,z)*CFrame.Angles(0,math.rad(90),0),lobby)
 seat("Lounge Right "..i,CFrame.new(35,2.8,z)*CFrame.Angles(0,math.rad(-90),0),lobby)
 part("Lounge Table "..i,Vector3.new(7,1,4),CFrame.new(26.5,2,z),C.glass,Enum.Material.Glass,.18,true,lobby)
 neon("Lounge Underlight "..i,Vector3.new(8,.18,.35),CFrame.new(26.5,1.35,z+2.1),i%2==0 and C.magenta or C.pink,lobby)
end

-- Premium entrance planters + warm accent points.
planter("Planter L",Vector3.new(-43,2.1,72),lobby)
planter("Planter R",Vector3.new(43,2.1,72),lobby)
for _,x in ipairs({-44,-30,-16,16,30,44}) do
 local lamp=part("Warm Lamp "..x,Vector3.new(.5,.5,.5),CFrame.new(x,11,54),C.warm,Enum.Material.Neon,0,false,lobby)
 local pl=Instance.new("PointLight");pl.Color=C.warm;pl.Brightness=.9;pl.Range=13;pl.Parent=lamp
end

-- Floor guidance: main club straight ahead, rooftop intentionally separated.
neon("Club Guide L",Vector3.new(.35,.12,22),CFrame.new(-7,2.08,28),C.pink,lobby)
neon("Club Guide R",Vector3.new(.35,.12,22),CFrame.new(7,2.08,28),C.pink,lobby)
sign("Club Direction","MAIN CLUB  ↓",CFrame.new(0,8,37.8),Vector3.new(24,3,.35),C.pink,lobby)
sign("Rooftop Direction","ROOFTOP POOL PARTY  ↖",CFrame.new(-31,6.2,37.75),Vector3.new(24,2.6,.35),C.magenta,lobby)

-- Arrival soft threshold so the player reads this as lobby, not rooftop.
part("Entry Threshold",Vector3.new(54,1,3),CFrame.new(0,2.2,77),C.black,Enum.Material.Marble,0,true,lobby)
neon("Entry Threshold Glow",Vector3.new(52,.3,.3),CFrame.new(0,2.8,75.4),C.pink,lobby)

print("[BBYA] Entrance Social Lobby v1 loaded")
