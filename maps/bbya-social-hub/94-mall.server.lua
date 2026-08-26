-- BBYA SOCIAL HUB — ACTIVE REAR MALL v1
-- Four-floor walkable mall behind Funkot Club: atrium, active tenants, food court, arcade,
-- cinema, escalators, elevators, directories, seating, automatic entry and internal wayfinding.
local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local Players=game:GetService("Players")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local old=root:FindFirstChild("BBYAMall")
if old then old:Destroy() end
local mall=Instance.new("Model");mall.Name="BBYAMall";mall.Parent=root
mall:SetAttribute("Pass","ACTIVE_MALL_V1")
mall:SetAttribute("TeleportKey","Mall")
mall:SetAttribute("Location","BEHIND_FUNKOT")
mall:SetAttribute("Floors",4)
mall:SetAttribute("TenantCount",18)

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local mallEvent=remotes:FindFirstChild("MallEvent") or Instance.new("RemoteEvent")
mallEvent.Name="MallEvent";mallEvent.Parent=remotes
local mallAction=remotes:FindFirstChild("MallAction") or Instance.new("RemoteEvent")
mallAction.Name="MallAction";mallAction.Parent=remotes
local state=remotes:FindFirstChild("State")

local C={
 concrete=Color3.fromRGB(58,60,64),wall=Color3.fromRGB(224,222,216),white=Color3.fromRGB(246,245,241),
 dark=Color3.fromRGB(28,30,34),black=Color3.fromRGB(11,12,14),glass=Color3.fromRGB(145,190,205),
 metal=Color3.fromRGB(92,98,105),gold=Color3.fromRGB(211,166,86),pink=Color3.fromRGB(235,56,147),
 cyan=Color3.fromRGB(38,192,214),green=Color3.fromRGB(67,173,116),orange=Color3.fromRGB(229,125,62),
 blue=Color3.fromRGB(62,116,217),purple=Color3.fromRGB(137,82,220),wood=Color3.fromRGB(120,86,61),
 plant=Color3.fromRGB(55,106,70),red=Color3.fromRGB(192,62,67),
}
local function part(name,size,cf,color,mat,collide,parent,transparency)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.wall;p.Material=mat or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=collide~=false;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Transparency=transparency or 0;p.Parent=parent or mall;return p
end
local function neon(name,size,cf,color,parent)
 local p=part(name,size,cf,color,Enum.Material.Neon,false,parent);p.CastShadow=false;return p
end
local function glass(name,size,cf,parent,transparency)
 local p=part(name,size,cf,C.glass,Enum.Material.Glass,true,parent,transparency or .32);p.CastShadow=false;return p
end
local function sign(parent,name,textValue,size,cf,color,bg)
 local p=part(name,size,cf,bg or C.dark,Enum.Material.SmoothPlastic,false,parent)
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.PixelsPerStud=55;g.Parent=p
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=textValue;t.TextColor3=color or C.white;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.TextWrapped=true;t.Parent=g
 return p
end
local function prompt(parent,action,obj,hold)
 local q=Instance.new("ProximityPrompt");q.ActionText=action;q.ObjectText=obj;q.HoldDuration=hold or 0;q.MaxActivationDistance=11;q.RequiresLineOfSight=false;q.Parent=parent;return q
end
local function toast(player,msg)
 if state and state:IsA("RemoteEvent") then state:FireClient(player,"toast",msg) end
end
local function seat(name,cf,parent)
 local s=Instance.new("Seat");s.Name=name;s.Size=Vector3.new(2.3,.7,2.3);s.CFrame=cf;s.Anchored=true;s.Color=Color3.fromRGB(75,76,80);s.Material=Enum.Material.Fabric;s.Parent=parent or mall;return s
end
local function planter(name,cf,parent)
 local box=part(name.."Box",Vector3.new(7,2,4),cf,C.dark,Enum.Material.Concrete,true,parent)
 part(name.."Soil",Vector3.new(6.2,.35,3.2),cf*CFrame.new(0,1.08,0),Color3.fromRGB(58,45,35),Enum.Material.Ground,false,parent)
 for i,x in ipairs({-2,0,2}) do
  part(name.."Stem"..i,Vector3.new(.35,2.2,.35),cf*CFrame.new(x,2.15,0),Color3.fromRGB(70,82,58),Enum.Material.Wood,false,parent)
  local leaf=Instance.new("Part");leaf.Name=name.."Leaf"..i;leaf.Shape=Enum.PartType.Ball;leaf.Size=Vector3.new(2.5,2.2,2.5);leaf.CFrame=cf*CFrame.new(x,3.35,0);leaf.Color=C.plant;leaf.Material=Enum.Material.SmoothPlastic;leaf.Anchored=true;leaf.CanCollide=false;leaf.CanTouch=false;leaf.Parent=parent or mall
 end
 return box
end

-- Connector: Funkot north wall is around Z=249; the mall begins behind it.
local connector=Instance.new("Model");connector.Name="FunkotMallConnector";connector.Parent=mall
part("ConnectorDeck",Vector3.new(24,1,36),CFrame.new(0,.6,268),Color3.fromRGB(65,66,68),Enum.Material.Concrete,true,connector)
for _,x in ipairs({-12,12}) do
 part("ConnectorRail"..x,Vector3.new(.5,3.6,36),CFrame.new(x,2.25,268),C.metal,Enum.Material.Metal,true,connector)
end
for _,z in ipairs({254,266,278}) do neon("ConnectorLight"..z,Vector3.new(20,.12,.18),CFrame.new(0,4.4,z),C.cyan,connector) end
sign(connector,"ConnectorSign","BBYA MALL  →",Vector3.new(20,3,.4),CFrame.new(0,6,282)*CFrame.Angles(0,math.rad(180),0),C.white,C.black)

-- Overall footprint and floor heights.
local CX,CZ=0,365
local W,D=190,156
local LEVELS={1,15,29,43}
local slabThickness=1
local atriumW,atriumD=60,54

-- Base plaza, façade apron and shell columns.
part("MallGround",Vector3.new(W+24,1,D+28),CFrame.new(CX,.5,CZ),Color3.fromRGB(77,78,80),Enum.Material.Concrete,true)
part("FrontPlaza",Vector3.new(132,.8,34),CFrame.new(0,.45,280),Color3.fromRGB(96,96,94),Enum.Material.Concrete,true)
for _,x in ipairs({-56,-36,36,56}) do planter("FrontPlanter"..x,CFrame.new(x,1.5,286),mall) end

-- Floor plates use four bands around the central atrium so the opening stays genuinely open.
local function floorBands(y,index)
 local f=Instance.new("Model");f.Name="Level"..index;f.Parent=mall
 local sideW=(W-atriumW)/2
 part("WestSlab",Vector3.new(sideW,slabThickness,D),CFrame.new(-(atriumW+sideW)/2,y,CZ),Color3.fromRGB(216,214,207),Enum.Material.Concrete,true,f)
 part("EastSlab",Vector3.new(sideW,slabThickness,D),CFrame.new((atriumW+sideW)/2,y,CZ),Color3.fromRGB(216,214,207),Enum.Material.Concrete,true,f)
 local bandD=(D-atriumD)/2
 part("SouthSlab",Vector3.new(atriumW,slabThickness,bandD),CFrame.new(0,y,CZ-(atriumD+bandD)/2),Color3.fromRGB(216,214,207),Enum.Material.Concrete,true,f)
 part("NorthSlab",Vector3.new(atriumW,slabThickness,bandD),CFrame.new(0,y,CZ+(atriumD+bandD)/2),Color3.fromRGB(216,214,207),Enum.Material.Concrete,true,f)
 if index>1 then
  local railY=y+2.4
  for _,x in ipairs({-atriumW/2,atriumW/2}) do glass("AtriumRailX"..index..x,Vector3.new(.35,4.2,atriumD),CFrame.new(x,railY,CZ),f,.48) end
  for _,z in ipairs({CZ-atriumD/2,CZ+atriumD/2}) do glass("AtriumRailZ"..index..z,Vector3.new(atriumW,4.2,.35),CFrame.new(0,railY,z),f,.48) end
 end
 return f
end
for i,y in ipairs(LEVELS) do floorBands(y,i) end

-- Exterior shell: warm concrete side/rear walls, premium glass front, vertical fins and roof frame.
part("WestExterior",Vector3.new(2,58,D),CFrame.new(-W/2,29,CZ),Color3.fromRGB(203,201,194),Enum.Material.Concrete,true)
part("EastExterior",Vector3.new(2,58,D),CFrame.new(W/2,29,CZ),Color3.fromRGB(203,201,194),Enum.Material.Concrete,true)
part("RearExterior",Vector3.new(W,58,2),CFrame.new(0,29,CZ+D/2),Color3.fromRGB(203,201,194),Enum.Material.Concrete,true)
for _,x in ipairs({-82,-66,-50,-34,-18,18,34,50,66,82}) do
 part("FrontFin"..x,Vector3.new(1.2,58,2.2),CFrame.new(x,29,CZ-D/2),C.dark,Enum.Material.Metal,true)
end
glass("FrontGlassLeft",Vector3.new(82,54,1),CFrame.new(-54,29,CZ-D/2+.3),mall,.27)
glass("FrontGlassRight",Vector3.new(82,54,1),CFrame.new(54,29,CZ-D/2+.3),mall,.27)
part("RoofWest",Vector3.new(64,1.4,D),CFrame.new(-63,58,CZ),C.dark,Enum.Material.Metal,true)
part("RoofEast",Vector3.new(64,1.4,D),CFrame.new(63,58,CZ),C.dark,Enum.Material.Metal,true)
part("RoofSouth",Vector3.new(atriumW,1.4,51),CFrame.new(0,58,CZ-51.5),C.dark,Enum.Material.Metal,true)
part("RoofNorth",Vector3.new(atriumW,1.4,51),CFrame.new(0,58,CZ+51.5),C.dark,Enum.Material.Metal,true)
-- Glass skylight over the atrium.
glass("AtriumSkylight",Vector3.new(atriumW,1,atriumD),CFrame.new(0,58,CZ),mall,.4)
for _,x in ipairs({-30,-15,0,15,30}) do neon("SkylightRib"..x,Vector3.new(.35,.25,atriumD),CFrame.new(x,57.5,CZ),C.white,mall) end

-- Automatic sliding glass entrance.
local doors=Instance.new("Model");doors.Name="AutomaticEntrance";doors.Parent=mall
local left=glass("EntryDoorL",Vector3.new(15,11,.7),CFrame.new(-7.6,6.5,CZ-D/2-.2),doors,.25)
local right=glass("EntryDoorR",Vector3.new(15,11,.7),CFrame.new(7.6,6.5,CZ-D/2-.2),doors,.25)
local closedL,closedR=left.CFrame,right.CFrame
local openL=closedL*CFrame.new(-12,0,0);local openR=closedR*CFrame.new(12,0,0)
local trigger=part("EntrySensor",Vector3.new(38,10,18),CFrame.new(0,5,CZ-D/2-2),C.white,Enum.Material.SmoothPlastic,false,doors,1)
trigger.CanTouch=true
local doorBusy=false
trigger.Touched:Connect(function(hit)
 local char=hit and hit.Parent
 if doorBusy or not char or not Players:GetPlayerFromCharacter(char) then return end
 doorBusy=true
 TweenService:Create(left,TweenInfo.new(.5,Enum.EasingStyle.Quad),{CFrame=openL}):Play();TweenService:Create(right,TweenInfo.new(.5,Enum.EasingStyle.Quad),{CFrame=openR}):Play()
 task.delay(3,function()
  TweenService:Create(left,TweenInfo.new(.55,Enum.EasingStyle.Quad),{CFrame=closedL}):Play();TweenService:Create(right,TweenInfo.new(.55,Enum.EasingStyle.Quad),{CFrame=closedR}):Play()
  task.wait(.6);doorBusy=false
 end)
end)

sign(mall,"MallHeroSign","BBYA MALL",Vector3.new(70,9,.8),CFrame.new(0,50,CZ-D/2-.4),C.white,C.black)
neon("HeroUnderline",Vector3.new(66,.3,.5),CFrame.new(0,44.7,CZ-D/2-.8),C.gold,mall)
sign(mall,"MallSubSign","SHOP • EAT • PLAY • CINEMA",Vector3.new(45,3.2,.6),CFrame.new(0,41,CZ-D/2-.5),C.gold,C.dark)

-- Atrium feature sculpture and furniture.
local atr=Instance.new("Model");atr.Name="AtriumExperience";atr.Parent=mall
part("AtriumStage",Vector3.new(28,.8,18),CFrame.new(0,1.4,CZ),C.dark,Enum.Material.Metal,true,atr)
for i=1,3 do
 local ring=Instance.new("Part");ring.Name="SculptureRing"..i;ring.Shape=Enum.PartType.Cylinder;ring.Size=Vector3.new(.4,14+i*3,14+i*3);ring.CFrame=CFrame.new(0,7+i*3,CZ)*CFrame.Angles(0,0,math.rad(90));ring.Color=({C.gold,C.pink,C.cyan})[i];ring.Material=Enum.Material.Neon;ring.Anchored=true;ring.CanCollide=false;ring.Parent=atr
end
for _,z in ipairs({CZ-38,CZ+38}) do
 for _,x in ipairs({-20,0,20}) do seat("AtriumSeat",CFrame.new(x,2,z),atr) end
end

-- Directory boards.
local tenantData={
 {id="luma",name="LUMA FASHION",cat="Fashion",floor=1,side="WEST",x=-70,z=330,color=C.pink},
 {id="stride",name="STRIDE SNEAKERS",cat="Sneakers",floor=1,side="EAST",x=70,z=330,color=C.orange},
 {id="byte",name="BYTE TECH",cat="Electronics",floor=1,side="WEST",x=-70,z=365,color=C.cyan},
 {id="daily",name="DAILY MARKET",cat="Supermarket",floor=1,side="EAST",x=70,z=365,color=C.green},
 {id="mono",name="MONO HOME",cat="Home",floor=1,side="WEST",x=-70,z=405,color=C.gold},
 {id="muse",name="MUSE BEAUTY",cat="Beauty",floor=1,side="EAST",x=70,z=405,color=C.purple},
 {id="north",name="NORTH LABEL",cat="Fashion",floor=2,side="WEST",x=-70,z=330,color=C.blue},
 {id="street",name="STREET UNIT",cat="Streetwear",floor=2,side="EAST",x=70,z=330,color=C.red},
 {id="page",name="PAGE & CO",cat="Books",floor=2,side="WEST",x=-70,z=365,color=C.gold},
 {id="glow",name="GLOW LAB",cat="Beauty",floor=2,side="EAST",x=70,z=365,color=C.pink},
 {id="sound",name="SOUND ROOM",cat="Audio",floor=2,side="WEST",x=-70,z=405,color=C.cyan},
 {id="fit",name="FIT DISTRICT",cat="Sports",floor=2,side="EAST",x=70,z=405,color=C.green},
 {id="food",name="BBYA FOOD HALL",cat="Food Court",floor=3,side="WEST",x=-65,z=350,color=C.orange},
 {id="cafe",name="SKYLINE CAFE",cat="Cafe",floor=3,side="EAST",x=65,z=350,color=C.gold},
 {id="arcade",name="PIXEL ARCADE",cat="Arcade",floor=3,side="WEST",x=-65,z=400,color=C.purple},
 {id="kids",name="LITTLE CITY",cat="Family",floor=3,side="EAST",x=65,z=400,color=C.cyan},
 {id="cinema",name="BBYA CINEMA",cat="Cinema",floor=4,side="NORTH",x=0,z=410,color=C.red},
 {id="lounge",name="SKY LOUNGE",cat="Lounge",floor=4,side="SOUTH",x=0,z=320,color=C.blue},
}
local tenantById={}
for _,t in ipairs(tenantData) do tenantById[t.id]=t end

local function openDirectory(player,mode,data)
 mallEvent:FireClient(player,mode,data or tenantData)
end
for i,cf in ipairs({CFrame.new(-23,4,302),CFrame.new(23,4,302),CFrame.new(-39,18,365),CFrame.new(39,32,365)}) do
 local board=part("DirectoryBoard"..i,Vector3.new(11,7,.8),cf,C.dark,Enum.Material.Metal,true,mall)
 sign(mall,"DirectoryFace"..i,"DIRECTORY\nTOUCH TO EXPLORE",Vector3.new(10.2,6.2,.25),cf*CFrame.new(0,0,-.55),C.white,C.black)
 prompt(board,"OPEN","MALL DIRECTORY",0).Triggered:Connect(function(player)openDirectory(player,"directory",tenantData)end)
end

-- Tenant shells: real storefront depth, glass frontage, counters, racks/displays and interaction prompts.
local function buildTenant(t)
 local y=LEVELS[t.floor]
 local unit=Instance.new("Model");unit.Name="Tenant_"..t.id;unit.Parent=mall
 local side=t.x<0 and -1 or 1
 local cx=t.x
 local depth=26
 local width=46
 part("Floor",Vector3.new(width,.35,depth),CFrame.new(cx,y+.7,t.z),Color3.fromRGB(202,199,191),Enum.Material.Concrete,true,unit)
 part("Back",Vector3.new(width,11,1),CFrame.new(cx,y+6,t.z+((t.z<CZ) and -depth/2 or depth/2)),Color3.fromRGB(235,233,226),Enum.Material.SmoothPlastic,true,unit)
 part("SideA",Vector3.new(1,11,depth),CFrame.new(cx-width/2,y+6,t.z),C.wall,Enum.Material.SmoothPlastic,true,unit)
 part("SideB",Vector3.new(1,11,depth),CFrame.new(cx+width/2,y+6,t.z),C.wall,Enum.Material.SmoothPlastic,true,unit)
 local frontX=cx-side*width/2
 glass("StoreGlass",Vector3.new(.45,9,depth-7),CFrame.new(frontX,y+5.5,t.z),unit,.45)
 local door=glass("StoreDoor",Vector3.new(.4,8,6),CFrame.new(frontX,y+5,t.z),unit,.55);door.CanCollide=false
 local banner=sign(unit,"StoreSign",t.name,Vector3.new(.5,3.5,20),CFrame.new(frontX-side*.35,y+10.1,t.z)*CFrame.Angles(0,side>0 and math.rad(-90) or math.rad(90),0),C.white,t.color)
 -- fixtures
 part("Counter",Vector3.new(10,2.2,3),CFrame.new(cx-side*9,y+1.8,t.z),C.dark,Enum.Material.WoodPlanks,true,unit)
 for n,zoff in ipairs({-8,0,8}) do
  part("Display"..n,Vector3.new(8,1.1,3),CFrame.new(cx+side*6,y+1.25,t.z+zoff),Color3.fromRGB(116,112,106),Enum.Material.WoodPlanks,true,unit)
  neon("DisplayGlow"..n,Vector3.new(7,.08,2.5),CFrame.new(cx+side*6,y+1.85,t.z+zoff),t.color,unit)
 end
 local interact=part("Interact",Vector3.new(2.5,2.5,2.5),CFrame.new(frontX-side*3,y+2.2,t.z),t.color,Enum.Material.Neon,false,unit,.35)
 local pr=prompt(interact,"BROWSE",t.name,0)
 pr.Triggered:Connect(function(player)openDirectory(player,"store",t)end)
 return unit
end
for i=1,12 do buildTenant(tenantData[i]) end

-- Food Hall and cafe on L3.
local food=Instance.new("Model");food.Name="FoodHall";food.Parent=mall
local fy=LEVELS[3]
part("FoodHallFloor",Vector3.new(72,.4,48),CFrame.new(-56,fy+.7,370),Color3.fromRGB(199,193,184),Enum.Material.CeramicTiles,true,food)
sign(food,"FoodHallSign","BBYA FOOD HALL",Vector3.new(34,4,.5),CFrame.new(-56,fy+10.5,347),C.white,C.orange)
for i,z in ipairs({352,364,376,388}) do
 local x=-82
 part("Kitchen"..i,Vector3.new(18,7,9),CFrame.new(x,fy+4.3,z),Color3.fromRGB(73,70,68),Enum.Material.Metal,true,food)
 local order=part("OrderPoint"..i,Vector3.new(2,2,2),CFrame.new(x+10,fy+2,z),({C.orange,C.green,C.red,C.cyan})[i],Enum.Material.Neon,false,food,.25)
 prompt(order,"ORDER","FOOD STALL "..i,0).Triggered:Connect(function(player)
  player:SetAttribute("BBYAFoodOrders",(player:GetAttribute("BBYAFoodOrders") or 0)+1);toast(player,"Order served • Food Hall counter "..i)
 end)
end
for _,x in ipairs({-65,-48,-31}) do for _,z in ipairs({360,378}) do
 part("Table",Vector3.new(5,.7,5),CFrame.new(x,fy+2.2,z),C.wood,Enum.Material.Wood,true,food)
 for _,dx in ipairs({-4,4}) do seat("FoodSeat",CFrame.new(x+dx,fy+1.8,z)*CFrame.Angles(0,dx>0 and math.rad(-90) or math.rad(90),0),food) end
 end end
local cafe=Instance.new("Model");cafe.Name="SkylineCafe";cafe.Parent=mall
part("CafeDeck",Vector3.new(54,.4,48),CFrame.new(62,fy+.7,370),Color3.fromRGB(206,201,192),Enum.Material.WoodPlanks,true,cafe)
part("CafeBar",Vector3.new(30,3,5),CFrame.new(70,fy+2.4,356),C.wood,Enum.Material.WoodPlanks,true,cafe)
sign(cafe,"CafeSign","SKYLINE CAFE",Vector3.new(28,3.5,.45),CFrame.new(70,fy+9,347),C.white,C.gold)
for _,x in ipairs({44,58,72,86}) do part("CafeTable",Vector3.new(4,.7,4),CFrame.new(x,fy+2.1,378),C.dark,Enum.Material.Metal,true,cafe);seat("CafeSeat",CFrame.new(x,fy+1.7,384)*CFrame.Angles(0,math.rad(180),0),cafe) end
local cafeOrder=part("CafeOrder",Vector3.new(2,2,2),CFrame.new(54,fy+2,356),C.gold,Enum.Material.Neon,false,cafe,.2)
prompt(cafeOrder,"ORDER","SKYLINE CAFE",0).Triggered:Connect(function(player)toast(player,"Coffee order accepted • Skyline Cafe")end)

-- Pixel Arcade and family zone on L3.
local arcade=Instance.new("Model");arcade.Name="PixelArcade";arcade.Parent=mall
for row,z in ipairs({398,410,422}) do for col,x in ipairs({-83,-70,-57,-44}) do
 local machine=part("Arcade_"..row.."_"..col,Vector3.new(5,6,4),CFrame.new(x,fy+3.5,z),Color3.fromRGB(32,31,38),Enum.Material.Metal,true,arcade)
 neon("ArcadeScreen",Vector3.new(3.6,2.4,.15),CFrame.new(x,fy+4.6,z-2.08),((row+col)%2==0) and C.purple or C.cyan,arcade)
 prompt(machine,"PLAY","ARCADE",0).Triggered:Connect(function(player)
  local tickets=math.random(5,15);player:SetAttribute("BBYAArcadeTickets",(player:GetAttribute("BBYAArcadeTickets") or 0)+tickets);toast(player,"Pixel Arcade +"..tickets.." tickets")
 end)
end end
sign(arcade,"ArcadeSign","PIXEL ARCADE",Vector3.new(30,4,.45),CFrame.new(-64,fy+10,394),C.white,C.purple)
local kids=Instance.new("Model");kids.Name="LittleCity";kids.Parent=mall
part("KidsFloor",Vector3.new(55,.4,42),CFrame.new(65,fy+.7,410),Color3.fromRGB(187,206,211),Enum.Material.SmoothPlastic,true,kids)
for i,x in ipairs({45,56,67,78,89}) do
 local block=part("PlayBlock"..i,Vector3.new(8,3+i%3,8),CFrame.new(x,fy+2.2+i%3,410+((i%2==0) and 8 or -7)),({C.pink,C.cyan,C.gold,C.green,C.purple})[i],Enum.Material.SmoothPlastic,true,kids)
 block.Shape=Enum.PartType.Block
end
sign(kids,"KidsSign","LITTLE CITY",Vector3.new(26,4,.4),CFrame.new(65,fy+10,392),C.white,C.cyan)

-- L4 cinema: lobby, concession, four theatre portals with showtime interaction.
local cy=LEVELS[4]
local cinema=Instance.new("Model");cinema.Name="BBYACinema";cinema.Parent=mall
part("CinemaLobby",Vector3.new(100,.4,48),CFrame.new(0,cy+.7,408),Color3.fromRGB(48,46,48),Enum.Material.Carpet,true,cinema)
part("Concession",Vector3.new(40,4,7),CFrame.new(0,cy+2.8,392),C.dark,Enum.Material.Metal,true,cinema)
neon("ConcessionTop",Vector3.new(38,.2,.25),CFrame.new(0,cy+5,388.4),C.red,cinema)
sign(cinema,"CinemaHero","BBYA CINEMA",Vector3.new(48,6,.5),CFrame.new(0,cy+11,432),C.white,C.red)
for i,x in ipairs({-36,-12,12,36}) do
 local portal=part("Theatre"..i,Vector3.new(18,9,2),CFrame.new(x,cy+5.5,430),Color3.fromRGB(24,23,27),Enum.Material.Metal,true,cinema)
 sign(cinema,"TheatreSign"..i,"SCREEN "..i,Vector3.new(14,3,.3),CFrame.new(x,cy+8.5,428.9),C.white,C.red)
 prompt(portal,"SHOWTIMES","SCREEN "..i,0).Triggered:Connect(function(player)openDirectory(player,"cinema",{screen=i,title="BBYA CINEMA",shows={"NEON CITY • 19:00","MIDNIGHT RUN • 21:10","AFTER HOURS • 23:30"}})end)
end

-- L4 south lounge / event deck.
local lounge=Instance.new("Model");lounge.Name="SkyLounge";lounge.Parent=mall
part("LoungeDeck",Vector3.new(100,.4,40),CFrame.new(0,cy+.7,322),Color3.fromRGB(65,66,71),Enum.Material.WoodPlanks,true,lounge)
for _,x in ipairs({-38,-19,0,19,38}) do seat("LoungeSeat",CFrame.new(x,cy+1.8,322),lounge) end
for _,x in ipairs({-45,45}) do planter("LoungePlanter"..x,CFrame.new(x,cy+1.6,310),lounge) end
sign(lounge,"LoungeSign","SKY LOUNGE • EVENTS",Vector3.new(42,4,.4),CFrame.new(0,cy+10,302),C.white,C.blue)

-- Escalators: paired stair runs through all floors. One direction on each side.
local escal=Instance.new("Model");escal.Name="Escalators";escal.Parent=mall
local function stairRun(baseY,x,z,dir,name)
 for i=0,13 do
  local y=baseY+1+i
  local zz=z+dir*(i*1.35)
  part(name.."Step"..i,Vector3.new(8,1,2.8),CFrame.new(x,y,zz),Color3.fromRGB(90,92,95),Enum.Material.Metal,true,escal)
  neon(name.."Guide"..i,Vector3.new(.14,.12,2.4),CFrame.new(x-3.7,y+.56,zz),C.cyan,escal)
 end
end
for level=1,3 do local y=LEVELS[level];stairRun(y,18,CZ-18,1,"Up"..level);stairRun(y,-18,CZ+18,-1,"Down"..level) end

-- Elevator core: each floor has UP/DOWN prompts that actually move players.
local elevator=Instance.new("Model");elevator.Name="ElevatorCore";elevator.Parent=mall
part("ElevatorTower",Vector3.new(18,57,16),CFrame.new(78,29,CZ+55),Color3.fromRGB(48,50,54),Enum.Material.Metal,true,elevator)
local floorCF={}
for i,y in ipairs(LEVELS) do
 local lobby=part("ElevatorLobby"..i,Vector3.new(16,.4,12),CFrame.new(68,y+.7,CZ+54),Color3.fromRGB(184,184,180),Enum.Material.CeramicTiles,true,elevator)
 local pad=part("ElevatorPad"..i,Vector3.new(5,.3,5),CFrame.new(68,y+1,CZ+54),C.gold,Enum.Material.Neon,false,elevator,.28)
 floorCF[i]=CFrame.new(68,y+3,CZ+50)
 sign(elevator,"ElevatorLabel"..i,"L"..i,Vector3.new(3,3,.3),CFrame.new(77.1,y+6,CZ+54)*CFrame.Angles(0,math.rad(-90),0),C.gold,C.dark)
 if i<4 then prompt(pad,"UP","ELEVATOR",0).Triggered:Connect(function(player)local c=player.Character;if c then c:PivotTo(floorCF[i+1])end end) end
 if i>1 then local down=prompt(pad,"DOWN","ELEVATOR",0);down.KeyboardKeyCode=Enum.KeyCode.F;down.Triggered:Connect(function(player)local c=player.Character;if c then c:PivotTo(floorCF[i-1])end end) end
end

-- Wayfinding strips and level signs.
for i,y in ipairs(LEVELS) do
 neon("WayfindWest"..i,Vector3.new(.16,.12,118),CFrame.new(-31,y+1.08,CZ),i%2==0 and C.cyan or C.gold,mall)
 neon("WayfindEast"..i,Vector3.new(.16,.12,118),CFrame.new(31,y+1.08,CZ),i%2==0 and C.pink or C.cyan,mall)
 sign(mall,"LevelSignW"..i,"LEVEL "..i,Vector3.new(10,2.5,.35),CFrame.new(-34,y+7,CZ-29),C.white,C.dark)
 sign(mall,"LevelSignE"..i,"LEVEL "..i,Vector3.new(10,2.5,.35),CFrame.new(34,y+7,CZ+29)*CFrame.Angles(0,math.rad(180),0),C.white,C.dark)
end

-- Warm mall lighting from atrium + corridors.
for i,y in ipairs(LEVELS) do
 for _,x in ipairs({-62,-38,38,62}) do for _,z in ipairs({318,350,382,414}) do
  local fixture=part("Light"..i..x..z,Vector3.new(1,.25,1),CFrame.new(x,y+12.5,z),C.white,Enum.Material.Neon,false,mall)
  local l=Instance.new("PointLight");l.Color=Color3.fromRGB(255,239,214);l.Brightness=1.25;l.Range=22;l.Shadows=false;l.Parent=fixture
 end end
end
for _,x in ipairs({-20,0,20}) do
 local fixture=part("AtriumLight"..x,Vector3.new(1,.3,1),CFrame.new(x,53,CZ),C.white,Enum.Material.Neon,false,mall)
 local spot=Instance.new("SpotLight");spot.Face=Enum.NormalId.Bottom;spot.Angle=55;spot.Range=55;spot.Brightness=3;spot.Color=Color3.fromRGB(255,232,200);spot.Shadows=true;spot.Parent=fixture
end

-- Internal wayfinding from the client directory. It is usable only while physically in the mall area.
mallAction.OnServerEvent:Connect(function(player,action,id)
 if action~="guide" then return end
 local t=tenantById[tostring(id or "")];if not t then return end
 local char=player.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");if not hrp then return end
 if hrp.Position.Z<282 and player:GetAttribute("BBYATravelBypass")~=true then toast(player,"Enter BBYA Mall first to use indoor guide.");return end
 local y=LEVELS[t.floor]+3
 hrp.CFrame=CFrame.new(t.x+(t.x<0 and 12 or -12),y,t.z)
 hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero
 toast(player,t.name.." • Level "..t.floor)
end)

print("[BBYA] Active Mall v1 online: 4 floors / 18 destinations / retail + food + arcade + cinema + escalators + elevator")
