-- BBYA SOCIAL HUB — MEGA CLUB ARCHITECTURE v2.0
-- Runtime architecture layer injected into the active A-Club place.
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local ROOT_NAME = "BBYA Mega Architecture v2"
local QUEEN_USER_ID = 4271188557

local old = workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end
local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace

local C = {
 black=Color3.fromRGB(10,10,16), midnight=Color3.fromRGB(16,20,38),
 blue=Color3.fromRGB(30,145,255), cyan=Color3.fromRGB(40,235,255),
 pink=Color3.fromRGB(255,45,165), magenta=Color3.fromRGB(215,45,255),
 purple=Color3.fromRGB(105,55,210), gold=Color3.fromRGB(255,190,75),
 glass=Color3.fromRGB(55,80,110), stone=Color3.fromRGB(30,29,37),
 water=Color3.fromRGB(25,150,220), green=Color3.fromRGB(27,88,61),
}

local function part(name,size,cf,color,material,transparency,collide,parent)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=collide~=false
 p.Material=material or Enum.Material.SmoothPlastic;p.Color=color or C.stone;p.Transparency=transparency or 0
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or root
 return p
end

local function neon(name,size,cf,color,parent)
 local p=part(name,size,cf,color,Enum.Material.Neon,0,false,parent)
 local l=Instance.new("PointLight");l.Color=color;l.Brightness=1.25;l.Range=18;l.Shadows=false;l.Parent=p
 return p
end

local function label(partObj,text,color)
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=28;gui.LightInfluence=0;gui.Parent=partObj
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Font=Enum.Font.GothamBlack;t.Text=text;t.TextScaled=true;t.TextColor3=color or C.pink;t.TextStrokeTransparency=.25;t.Parent=gui
 return t
end

local function sign(name,text,cf,w,h,color,parent)
 local b=part(name,Vector3.new(w or 30,h or 6,.6),cf,C.black,Enum.Material.SmoothPlastic,0,false,parent)
 label(b,text,color or C.pink)
 return b
end

local function glassRail(name,center,size,parent)
 return part(name,size,center,C.glass,Enum.Material.Glass,.55,true,parent)
end

local function seat(name,cf,color,parent)
 local s=Instance.new("Seat");s.Name=name;s.Size=Vector3.new(6,1.4,5);s.CFrame=cf;s.Anchored=true;s.Color=color or C.purple;s.Material=Enum.Material.Fabric;s.Parent=parent or root;return s
end

local function loungeCluster(prefix,center,yaw,color,parent)
 local cf=CFrame.new(center)*CFrame.Angles(0,math.rad(yaw or 0),0)
 seat(prefix.." A",cf*CFrame.new(-7,0,0),color,parent)
 seat(prefix.." B",cf*CFrame.new(7,0,0),color,parent)
 part(prefix.." Table",Vector3.new(7,1,5),cf*CFrame.new(0,.5,-5),C.black,Enum.Material.Glass,.12,true,parent)
 neon(prefix.." Accent",Vector3.new(16,.18,.22),cf*CFrame.new(0,1.4,2.6),C.pink,parent)
end

local function palm(prefix,pos,scale,parent)
 scale=scale or 1
 part(prefix.." Trunk",Vector3.new(1.4*scale,10*scale,1.4*scale),CFrame.new(pos+Vector3.new(0,5*scale,0))*CFrame.Angles(0,0,math.rad(-4)),Color3.fromRGB(73,48,33),Enum.Material.Wood,0,true,parent)
 for i=0,5 do
  local a=i*math.pi/3
  part(prefix.." Leaf"..i,Vector3.new(1,0.35,8)*scale,CFrame.new(pos+Vector3.new(0,10.3*scale,0))*CFrame.Angles(0,a,math.rad(-18)),C.green,Enum.Material.SmoothPlastic,0,false,parent)
 end
end

-- Night environment
Lighting.ClockTime=0.15
Lighting.Brightness=1.65
Lighting.Ambient=Color3.fromRGB(20,24,44)
Lighting.OutdoorAmbient=Color3.fromRGB(8,12,28)
Lighting.FogColor=Color3.fromRGB(17,24,48)
Lighting.FogStart=250
Lighting.FogEnd=1050

local atmosphere=Lighting:FindFirstChild("BBYAAtmosphere") or Instance.new("Atmosphere")
atmosphere.Name="BBYAAtmosphere";atmosphere.Density=.23;atmosphere.Offset=.1;atmosphere.Color=Color3.fromRGB(65,83,130);atmosphere.Decay=Color3.fromRGB(22,13,44);atmosphere.Glare=.1;atmosphere.Haze=1.2;atmosphere.Parent=Lighting

-- ===================== ARRIVAL PLAZA =====================
local arrival=Instance.new("Folder");arrival.Name="Arrival Plaza";arrival.Parent=root
part("Arrival Plaza Floor",Vector3.new(150,2,82),CFrame.new(0,0,108),C.stone,Enum.Material.Slate,0,true,arrival)
part("Arrival Reflecting Pool L",Vector3.new(36,.5,28),CFrame.new(-53,1,107),C.water,Enum.Material.Glass,.25,false,arrival)
part("Arrival Reflecting Pool R",Vector3.new(36,.5,28),CFrame.new(53,1,107),C.water,Enum.Material.Glass,.25,false,arrival)
for _,x in ipairs({-72,-58,58,72}) do palm("Arrival Palm "..x,Vector3.new(x,1,112),1.15,arrival) end
for _,x in ipairs({-38,-19,0,19,38}) do neon("Arrival Path Light "..x,Vector3.new(12,.18,1.2),CFrame.new(x,1.15,120),x%38==0 and C.pink or C.blue,arrival) end

-- monumental curved-ish gateway from staggered masses
part("Gate Left Tower",Vector3.new(13,30,12),CFrame.new(-30,15,83)*CFrame.Angles(0,math.rad(-7),0),C.black,Enum.Material.Slate,0,true,arrival)
part("Gate Right Tower",Vector3.new(13,30,12),CFrame.new(30,15,83)*CFrame.Angles(0,math.rad(7),0),C.black,Enum.Material.Slate,0,true,arrival)
part("Gate Canopy",Vector3.new(58,5,12),CFrame.new(0,27,83),C.black,Enum.Material.Metal,0,true,arrival)
neon("Gate Neon Crown Bar",Vector3.new(34,.7,.7),CFrame.new(0,24.1,76.8),C.pink,arrival)
sign("BBYA Giant Sign","♛  BBYA SOCIAL HUB  ♛",CFrame.new(0,31,77),58,7,C.pink,arrival)
sign("Arrival Motto","MUSIC  •  DANCE  •  FRIENDS  •  VIBES",CFrame.new(0,22.5,77),45,3,C.cyan,arrival)

-- photo portals
for i,x in ipairs({-58,58}) do
 part("Photo Portal "..i.." L",Vector3.new(2,15,2),CFrame.new(x-8,8,132),C.black,Enum.Material.Metal,0,true,arrival)
 part("Photo Portal "..i.." R",Vector3.new(2,15,2),CFrame.new(x+8,8,132),C.black,Enum.Material.Metal,0,true,arrival)
 neon("Photo Portal "..i.." Top",Vector3.new(18,.6,.6),CFrame.new(x,15.2,132),i==1 and C.blue or C.pink,arrival)
 sign("Photo Sign "..i,i==1 and "NEON MOMENT" or "BBYA NIGHTS",CFrame.new(x,10,131),14,4,i==1 and C.blue or C.pink,arrival)
end

-- ===================== GRAND LOBBY / TRANSITION =====================
local lobby=Instance.new("Folder");lobby.Name="Grand Lobby";lobby.Parent=root
part("Lobby Floor",Vector3.new(118,2,32),CFrame.new(0,1,61),C.black,Enum.Material.Marble,0,true,lobby)
for _,x in ipairs({-54,54}) do
 part("Lobby Column "..x,Vector3.new(5,20,5),CFrame.new(x,11,61),C.stone,Enum.Material.Slate,0,true,lobby)
 neon("Lobby Column Neon "..x,Vector3.new(.5,18,.5),CFrame.new(x,11,58.3),x<0 and C.blue or C.pink,lobby)
end
sign("Lobby Wayfinding","CLUB   ↑     VIP   ↗     ROOFTOP   ↖",CFrame.new(0,13,46),48,4,C.cyan,lobby)

-- ===================== CLUB ARCHITECTURE DEPTH =====================
local club=Instance.new("Folder");club.Name="Main Club Upgrade";club.Parent=root
-- overhead ring and side mezzanines
part("Upper Balcony Left",Vector3.new(26,2,76),CFrame.new(-72,16,-9),C.stone,Enum.Material.Slate,0,true,club)
part("Upper Balcony Right",Vector3.new(26,2,76),CFrame.new(72,16,-9),C.stone,Enum.Material.Slate,0,true,club)
part("Upper Balcony Rear",Vector3.new(118,2,18),CFrame.new(0,16,28),C.stone,Enum.Material.Slate,0,true,club)
glassRail("Balcony Rail Left",CFrame.new(-58,20,-9),Vector3.new(1,7,76),club)
glassRail("Balcony Rail Right",CFrame.new(58,20,-9),Vector3.new(1,7,76),club)
glassRail("Balcony Rail Rear",CFrame.new(0,20,19),Vector3.new(116,7,1),club)

for _,z in ipairs({-40,-16,8,28}) do
 loungeCluster("Left Balcony "..z,Vector3.new(-72,18,z),90,C.purple,club)
 loungeCluster("Right Balcony "..z,Vector3.new(72,18,z),-90,Color3.fromRGB(100,35,85),club)
end

-- ceiling festival truss
for _,z in ipairs({-48,-28,-8,12}) do
 part("Festival Truss "..z,Vector3.new(112,.7,.7),CFrame.new(0,25,z),C.black,Enum.Material.Metal,0,false,club)
 for _,x in ipairs({-42,-21,0,21,42}) do
  local lamp=neon("Moving Light "..x.." "..z,Vector3.new(2.2,1.4,2.2),CFrame.new(x,24,z),((x+z)%2==0) and C.pink or C.blue,club)
  local beam=Instance.new("SpotLight");beam.Angle=42;beam.Brightness=4;beam.Range=65;beam.Color=lamp.Color;beam.Shadows=false;beam.Face=Enum.NormalId.Bottom;beam.Parent=lamp
 end
end

-- stage side wings, more festival composition
part("Stage Wing L",Vector3.new(20,18,10),CFrame.new(-43,10,-57),C.black,Enum.Material.Metal,0,true,club)
part("Stage Wing R",Vector3.new(20,18,10),CFrame.new(43,10,-57),C.black,Enum.Material.Metal,0,true,club)
for _,x in ipairs({-43,43}) do
 for y=4,16,4 do neon("Stage Pixel "..x.." "..y,Vector3.new(13,.7,.5),CFrame.new(x,y,-51.8),y%8==0 and C.pink or C.cyan,club) end
end
sign("Stage Header","BBYA • NIGHT SYSTEM",CFrame.new(0,25,-59),54,6,C.pink,club)

-- ===================== QUEEN SKYBOX =====================
local queen=Instance.new("Folder");queen.Name="BBYA Queen Skybox";queen.Parent=root
part("Queen Platform",Vector3.new(42,2,28),CFrame.new(0,25,8),C.black,Enum.Material.Marble,0,true,queen)
glassRail("Queen Front Glass",CFrame.new(0,29,-5.5),Vector3.new(42,7,1),queen)
part("Queen Back Wall",Vector3.new(42,15,2),CFrame.new(0,32,21),C.black,Enum.Material.Slate,0,true,queen)
sign("Queen Sign","♛  BBYA QUEEN  ♛",CFrame.new(0,35,19.8),32,6,C.pink,queen)
local throne=Instance.new("Seat");throne.Name="BBYA QUEEN THRONE";throne.Size=Vector3.new(8,3,7);throne.CFrame=CFrame.new(0,28,13);throne.Anchored=true;throne.Color=Color3.fromRGB(70,30,85);throne.Material=Enum.Material.Fabric;throne.Parent=queen
part("Queen Throne Back",Vector3.new(10,10,2),CFrame.new(0,32,16),C.black,Enum.Material.Metal,0,true,queen)
for i=0,4 do neon("Queen Crown Spike "..i,Vector3.new(1.2,6,1.2),CFrame.new(-6+i*3,38+(i%2)*2,18)*CFrame.Angles(0,0,math.rad((i-2)*8)),C.pink,queen) end
loungeCluster("Queen Lounge Left",Vector3.new(-13,27,8),0,Color3.fromRGB(100,35,100),queen)
loungeCluster("Queen Lounge Right",Vector3.new(13,27,8),0,Color3.fromRGB(100,35,100),queen)

local function queenFX(active)
 for _,o in ipairs(queen:GetDescendants()) do
  if o:IsA("PointLight") then o.Brightness=active and 3 or 1.25 end
 end
end
throne:GetPropertyChangedSignal("Occupant"):Connect(function()
 local hum=throne.Occupant
 local plr=hum and Players:GetPlayerFromCharacter(hum.Parent)
 if plr and plr.UserId~=QUEEN_USER_ID then hum.Sit=false;return end
 queenFX(plr~=nil)
end)

-- ===================== EXPANDED ROOFTOP RESORT =====================
local roof=Instance.new("Folder");roof.Name="Rooftop Resort";roof.Parent=root
part("Rooftop Extension",Vector3.new(176,2,112),CFrame.new(0,36,6),C.stone,Enum.Material.Slate,0,true,roof)
-- preserve open visual zones with raised decks
part("Pool Deck West",Vector3.new(62,1,42),CFrame.new(-50,38,-8),Color3.fromRGB(62,50,57),Enum.Material.WoodPlanks,0,true,roof)
part("Pool Deck East",Vector3.new(62,1,42),CFrame.new(50,38,-8),Color3.fromRGB(62,50,57),Enum.Material.WoodPlanks,0,true,roof)
-- infinity pool large
part("BBYA Infinity Pool",Vector3.new(68,2,34),CFrame.new(0,38,-27),C.water,Enum.Material.Glass,.28,false,roof)
neon("Pool Edge Neon",Vector3.new(70,.35,.35),CFrame.new(0,39,-44),C.cyan,roof)
-- pool stage
part("Pool DJ Deck",Vector3.new(34,3,16),CFrame.new(0,40,35),C.black,Enum.Material.Metal,0,true,roof)
sign("Pool Stage Sign","BBYA POOL PARTY",CFrame.new(0,47,27),32,5,C.pink,roof)
for _,x in ipairs({-45,-25,25,45}) do loungeCluster("Rooftop Cabana "..x,Vector3.new(x,40,21),180,Color3.fromRGB(68,38,74),roof) end
for _,x in ipairs({-77,77}) do for _,z in ipairs({-36,-4,28}) do palm("Roof Palm "..x.." "..z,Vector3.new(x,37,z),1.05,roof) end end
-- glass perimeter
for _,cfg in ipairs({{CFrame.new(0,42,-49),Vector3.new(176,8,1)},{CFrame.new(-87,42,6),Vector3.new(1,8,112)},{CFrame.new(87,42,6),Vector3.new(1,8,112)}}) do glassRail("Rooftop Glass",cfg[1],cfg[2],roof) end

-- ===================== FICTIONAL CITY SKYLINE =====================
local city=Instance.new("Folder");city.Name="Fictional Tropical Skyline";city.Parent=root
math.randomseed(2244)
local towerIndex=0
for side=-1,1,2 do
 for i=1,12 do
  towerIndex+=1
  local x=side*(125+math.random(0,150))
  local z=-120+math.random(-90,220)
  local h=math.random(45,125)
  local w=math.random(18,34)
  local t=part("Sky Tower "..towerIndex,Vector3.new(w,h,w*.72),CFrame.new(x,h/2-2,z),Color3.fromRGB(math.random(16,30),math.random(18,34),math.random(30,48)),Enum.Material.SmoothPlastic,0,true,city)
  for y=8,h-6,10 do
   neon("Tower Window "..towerIndex.." "..y,Vector3.new(w*.65,.35,.25),CFrame.new(x,y,z-(w*.36+.15)),(y%20==0) and C.gold or C.blue,city)
  end
 end
end
-- distant hotel towers behind stage
for i=-4,4 do
 local h=60+((i*i*11)%45)
 local x=i*42
 local z=-185-math.abs(i)*5
 part("Hotel Tower "..i,Vector3.new(29,h,24),CFrame.new(x,h/2,z),C.midnight,Enum.Material.SmoothPlastic,0,true,city)
 for y=10,h-8,12 do neon("Hotel Light "..i.." "..y,Vector3.new(19,.3,.25),CFrame.new(x,y,z-12.2),i%2==0 and C.pink or C.cyan,city) end
end

-- ===================== NAVIGATION / WAYFINDING =====================
local nav=Instance.new("Folder");nav.Name="Navigation";nav.Parent=root
local navs={{"CLUB",Vector3.new(0,4,48),C.pink},{"VIP",Vector3.new(-52,4,42),C.gold},{"QUEEN",Vector3.new(0,18,17),C.pink},{"ROOFTOP",Vector3.new(-72,18,35),C.cyan},{"POOL",Vector3.new(0,42,-6),C.cyan}}
for _,n in ipairs(navs) do sign("Nav "..n[1],n[1],CFrame.new(n[2]),14,3,n[3],nav) end

-- pulse only selected neon accents to keep mobile cost controlled
local pulse={}
for _,o in ipairs(root:GetDescendants()) do
 if o:IsA("BasePart") and o.Material==Enum.Material.Neon and string.find(o.Name,"Path Light") then table.insert(pulse,o) end
end
task.spawn(function()
 while root.Parent do
  for _,p in ipairs(pulse) do TweenService:Create(p,TweenInfo.new(1.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=.45}):Play() end
  task.wait(1.5)
  for _,p in ipairs(pulse) do TweenService:Create(p,TweenInfo.new(1.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=.05}):Play() end
  task.wait(1.5)
 end
end)

print("[BBYA] Mega Architecture v2 loaded: arrival plaza + mezzanines + Queen skybox + rooftop resort + skyline")