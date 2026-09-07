-- BBYA SOCIAL HUB — DISTRICT SERVICE PROMENADE v1.1 PERIMETER ANCHORED
-- Repairs the Mall perimeter QC regression: no floating trees/lights, no bench in the walking line,
-- and no unsupported empty verge. Travel/paywall/audio authorities remain untouched.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30);if not root then return end
local mall=root:WaitForChild("BBYAMall",30)
local market=root:WaitForChild("BBYANightMarket",30)
if not mall or not market then return end

task.wait(1.8)
local old=root:FindFirstChild("DistrictServicePromenadeV1");if old then old:Destroy()end
local out=Instance.new("Model");out.Name="DistrictServicePromenadeV1";out.Parent=root
out:SetAttribute("Pass","DISTRICT_SERVICE_PROMENADE_V1_1_ANCHORED")
out:SetAttribute("Route","MALL_EAST_TO_NIGHT_MARKET")
out:SetAttribute("StaticEnvironment",true)
out:SetAttribute("TravelAuthorityChanged",false)
out:SetAttribute("AudioInjected",false)
out:SetAttribute("PerimeterSupport","VERGE_AND_FURNITURE_ANCHORED")

local C={curb=Color3.fromRGB(128,124,116),paver=Color3.fromRGB(101,98,92),asphalt=Color3.fromRGB(48,49,48),metal=Color3.fromRGB(72,75,77),dark=Color3.fromRGB(29,30,30),warm=Color3.fromRGB(255,220,168),wood=Color3.fromRGB(116,82,57),leaf=Color3.fromRGB(52,91,58),leaf2=Color3.fromRGB(68,108,67),soil=Color3.fromRGB(57,43,33),white=Color3.fromRGB(237,235,227),gold=Color3.fromRGB(205,163,88)}
local function part(name,size,cf,color,material,collide,parent,transparency)local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.metal;p.Material=material or Enum.Material.Metal;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=true;p.Transparency=transparency or 0;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.CastShadow=p.Transparency<.9;p.Parent=parent or out;return p end
local function ball(name,size,cf,color,parent)local p=part(name,size,cf,color,Enum.Material.SmoothPlastic,false,parent);p.Shape=Enum.PartType.Ball;p.CanQuery=false;return p end
local function cylinder(name,size,cf,color,material,collide,parent)local p=part(name,size,cf,color,material,collide,parent);p.Shape=Enum.PartType.Cylinder;return p end
local function light(parent,brightness,range)local l=Instance.new("PointLight");l.Color=C.warm;l.Brightness=brightness or .75;l.Range=range or 15;l.Shadows=false;l.Parent=parent;return l end
local function guiFace(board,face,title,sub)local g=Instance.new("SurfaceGui");g.Face=face;g.PixelsPerStud=55;g.LightInfluence=.2;g.Parent=board;local bg=Instance.new("Frame");bg.Size=UDim2.fromScale(1,1);bg.BackgroundColor3=C.dark;bg.BorderSizePixel=0;bg.Parent=g;local accent=Instance.new("Frame");accent.Size=UDim2.new(0,6,1,0);accent.BackgroundColor3=C.gold;accent.BorderSizePixel=0;accent.Parent=bg;local h=Instance.new("TextLabel");h.BackgroundTransparency=1;h.Position=UDim2.fromScale(.09,.11);h.Size=UDim2.fromScale(.84,.47);h.Text=title;h.TextColor3=C.white;h.Font=Enum.Font.GothamBlack;h.TextScaled=true;h.TextXAlignment=Enum.TextXAlignment.Left;h.Parent=bg;local s=Instance.new("TextLabel");s.BackgroundTransparency=1;s.Position=UDim2.fromScale(.09,.62);s.Size=UDim2.fromScale(.84,.20);s.Text=sub;s.TextColor3=Color3.fromRGB(170,166,157);s.Font=Enum.Font.GothamBold;s.TextScaled=true;s.TextXAlignment=Enum.TextXAlignment.Left;s.Parent=bg end
local function sign(name,cf,title,sub,parent)local m=Instance.new("Model");m.Name=name;m.Parent=parent or out;part("Post",Vector3.new(.32,6.2,.32),cf*CFrame.new(0,3.1,0),C.metal,Enum.Material.Metal,true,m);local board=part("Board",Vector3.new(7.6,3.4,.34),cf*CFrame.new(0,6.0,0),C.dark,Enum.Material.Metal,false,m);guiFace(board,Enum.NormalId.Front,title,sub);guiFace(board,Enum.NormalId.Back,title,sub);return m end
local function streetLamp(name,x,z,parent)local m=Instance.new("Model");m.Name=name;m.Parent=parent or out;part("Foot",Vector3.new(.85,.28,.85),CFrame.new(x,.94,z),C.curb,Enum.Material.Concrete,true,m);part("Mast",Vector3.new(.32,7.4,.32),CFrame.new(x,4.72,z),C.metal,Enum.Material.Metal,true,m);part("Arm",Vector3.new(2.0,.22,.22),CFrame.new(x-.82,8.22,z),C.metal,Enum.Material.Metal,false,m);local head=part("Head",Vector3.new(1.2,.28,.72),CFrame.new(x-1.7,8.18,z),C.dark,Enum.Material.Metal,false,m);light(head,.72,15);return m end
local function treePit(name,x,z,parent)local m=Instance.new("Model");m.Name=name;m.Parent=parent or out;part("Planter",Vector3.new(4.2,1.25,4.2),CFrame.new(x,1.34,z),C.curb,Enum.Material.Concrete,true,m);part("Soil",Vector3.new(3.45,.18,3.45),CFrame.new(x,2.02,z),C.soil,Enum.Material.Ground,false,m);cylinder("Trunk",Vector3.new(4.4,.48,.48),CFrame.new(x,4.13,z)*CFrame.Angles(0,0,math.rad(90)),C.wood,Enum.Material.Wood,false,m);ball("CrownA",Vector3.new(4.2,3.5,4.0),CFrame.new(x,6.43,z),C.leaf,m);ball("CrownB",Vector3.new(3.0,2.7,3.1),CFrame.new(x-1.2,6.08,z+.4),C.leaf2,m);ball("CrownC",Vector3.new(2.8,2.5,3.0),CFrame.new(x+1.1,6.23,z-.35),C.leaf2,m);return m end
local function bench(name,cf,parent)local m=Instance.new("Model");m.Name=name;m.Parent=parent or out;for _,y in ipairs({1.25,2.05})do part("Slat"..tostring(y),Vector3.new(6,.34,.75),cf*CFrame.new(0,y,0),C.wood,Enum.Material.WoodPlanks,true,m)end;for _,x in ipairs({-2.35,2.35})do part("Leg"..x,Vector3.new(.32,1.4,.55),cf*CFrame.new(x,.72,0),C.metal,Enum.Material.Metal,true,m);part("BackPost"..x,Vector3.new(.28,2.4,.28),cf*CFrame.new(x,2.0,.55)*CFrame.Angles(math.rad(-7),0,0),C.metal,Enum.Material.Metal,true,m)end;return m end
local function bin(name,x,z,parent)local m=Instance.new("Model");m.Name=name;m.Parent=parent or out;local body=cylinder("Body",Vector3.new(2.5,1.25,1.25),CFrame.new(x,1.7,z)*CFrame.Angles(0,0,math.rad(90)),C.dark,Enum.Material.Metal,true,m);cylinder("Lid",Vector3.new(.18,1.42,1.42),CFrame.new(x,2.98,z)*CFrame.Angles(0,0,math.rad(90)),C.metal,Enum.Material.Metal,false,m);body:SetAttribute("BBYABin",true);return m end

local east=market:FindFirstChild("MallEastWalkway");if east and east:IsA("BasePart")then east.Material=Enum.Material.Concrete;east.Color=Color3.fromRGB(91,89,84);east:SetAttribute("DistrictPromenadeSurface",true)end
local rear=market:FindFirstChild("MallRearWalkway");if rear and rear:IsA("BasePart")then rear.Material=Enum.Material.Concrete;rear.Color=Color3.fromRGB(91,89,84);rear:SetAttribute("DistrictPromenadeSurface",true)end

local support=Instance.new("Model");support.Name="MallPerimeterSupport";support.Parent=out
part("EastLandscapeVerge",Vector3.new(10,.8,182),CFrame.new(121,.40,365),Color3.fromRGB(86,84,79),Enum.Material.Concrete,true,support)
part("EastOuterRetaining",Vector3.new(.8,2.2,182),CFrame.new(126,.10,365),C.curb,Enum.Material.Concrete,true,support)
part("RearFurnitureApron",Vector3.new(116,.8,5.5),CFrame.new(58,.40,447.0),Color3.fromRGB(86,84,79),Enum.Material.Concrete,true,support)

local edge=Instance.new("Model");edge.Name="EdgeAndDrainage";edge.Parent=out
for _,x in ipairs({98.5,115.5})do part("EastCurb"..x,Vector3.new(.55,.42,178),CFrame.new(x,1.00,365),C.curb,Enum.Material.Concrete,true,edge)end
for _,x in ipairs({100.0,114.0})do part("EastPaverBand"..x,Vector3.new(1.55,.06,176),CFrame.new(x,.80,365),C.paver,Enum.Material.Slate,false,edge)end
part("EastGutter",Vector3.new(.70,.07,176),CFrame.new(116.05,.80,365),C.asphalt,Enum.Material.Metal,false,edge)
for i,z in ipairs({292,314,336,358,380,402,424,446})do part("EastDrainGrate"..i,Vector3.new(1.1,.075,3.6),CFrame.new(115.95,.825,z),C.dark,Enum.Material.Metal,false,edge)end
for _,z in ipairs({446.5,463.5})do part("RearCurb"..z,Vector3.new(114,.42,.55),CFrame.new(58,1.00,z),C.curb,Enum.Material.Concrete,true,edge)end
for _,z in ipairs({448.0,462.0})do part("RearPaverBand"..z,Vector3.new(112,.06,1.55),CFrame.new(58,.80,z),C.paver,Enum.Material.Slate,false,edge)end
part("RearGutter",Vector3.new(112,.07,.70),CFrame.new(58,.80,464.05),C.asphalt,Enum.Material.Metal,false,edge)
for i,x in ipairs({8,24,40,56,72,88,104})do part("RearDrainGrate"..i,Vector3.new(3.6,.075,1.1),CFrame.new(x,.825,463.95),C.dark,Enum.Material.Metal,false,edge)end

local lights=Instance.new("Model");lights.Name="WarmStreetLights";lights.Parent=out
for i,z in ipairs({294,324,354,384,414,444})do streetLamp("EastLamp"..i,122,z,lights)end
for i,x in ipairs({18,46,74,102})do streetLamp("RearLamp"..i,x,468,lights)end
local green=Instance.new("Model");green.Name="StreetGreenery";green.Parent=out
for i,z in ipairs({306,346,386,426})do treePit("EastTree"..i,121,z,green)end
for i,x in ipairs({20,52,84})do local p=part("RearPlanter"..i,Vector3.new(8,1.0,2.4),CFrame.new(x,1.10,445.8),C.curb,Enum.Material.Concrete,true,green);part("RearSoil"..i,Vector3.new(7.2,.16,1.7),CFrame.new(x,1.68,445.8),C.soil,Enum.Material.Ground,false,green);for j=-2,2,2 do ball("RearShrub"..i.."_"..j,Vector3.new(1.8,1.45,1.6),CFrame.new(x+j,2.48,445.8),j==0 and C.leaf2 or C.leaf,green)end;p:SetAttribute("LowProfile",true)end

local furniture=Instance.new("Model");furniture.Name="StreetFurniture";furniture.Parent=out
bench("RearBenchA",CFrame.new(33,.1,448.0)*CFrame.Angles(0,math.rad(180),0),furniture)
bench("RearBenchB",CFrame.new(82,.1,448.0)*CFrame.Angles(0,math.rad(180),0),furniture)
for i,p in ipairs({{123,318},{123,374},{28,468},{92,468}})do bin("Bin"..i,p[1],p[2],furniture)end

local way=Instance.new("Model");way.Name="Wayfinding";way.Parent=out
sign("EastEntrySign",CFrame.new(123,0,286)*CFrame.Angles(0,math.rad(90),0),"NIGHT MARKET  ↑","EAST PROMENADE",way)
sign("RearTurnSign",CFrame.new(108,0,452)*CFrame.Angles(0,math.rad(180),0),"PASAR MALAM  ←","AROUND THE MALL",way)
sign("MarketApproachSign",CFrame.new(20,0,461),"BBYA PASAR MALAM  ↑","WAHANA • GAME • JAJANAN",way)
local wash=Instance.new("Model");wash.Name="MallServiceWallWash";wash.Parent=out
for i,z in ipairs({304,344,384,424})do local head=part("WallWash"..i,Vector3.new(.55,.32,.75),CFrame.new(95.85,6.0,z),C.dark,Enum.Material.Metal,false,wash);local l=Instance.new("SpotLight");l.Face=Enum.NormalId.Left;l.Color=C.warm;l.Brightness=.55;l.Range=13;l.Angle=55;l.Shadows=false;l.Parent=head end

out:SetAttribute("InstalledParts",#out:GetDescendants())
print("[BBYA] District Service Promenade v1.1 online: supported Mall verge / anchored greenery / benches off walking line")
