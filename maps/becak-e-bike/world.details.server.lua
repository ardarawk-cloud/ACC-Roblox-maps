-- BECAK E-BIKE — Nusakarya visual/detail pass v1.2
-- Streetscape geometry pass: safer road edges, rounded furniture, shelters, kiosks and layered public space.
local Workspace=game:GetService('Workspace')
local root=Workspace:WaitForChild('BecakEBike',20)
if not root then return end
local world=root:WaitForChild('Nusakarya',20)
if not world then return end

local old=world:FindFirstChild('CityDetails') if old then old:Destroy() end
local details=Instance.new('Folder') details.Name='CityDetails' details.Parent=world
local function p(name,size,cf,color,material,collide)
 local x=Instance.new('Part');x.Name=name;x.Size=size;x.CFrame=cf;x.Anchored=true;x.CanCollide=collide==true;x.CanTouch=collide==true;x.CanQuery=collide==true;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Color=color;x.Material=material or Enum.Material.SmoothPlastic;x.Parent=details;return x
end
local function cylinder(name,size,cf,color,material,collide)
 local x=p(name,size,cf,color,material or Enum.Material.SmoothPlastic,collide);x.Shape=Enum.PartType.Cylinder;return x
end
local function ball(name,size,cf,color,material)
 local x=p(name,size,cf,color,material or Enum.Material.SmoothPlastic,false);x.Shape=Enum.PartType.Ball;return x
end
local function wedge(name,size,cf,color,material)
 local x=Instance.new('WedgePart');x.Name=name;x.Size=size;x.CFrame=cf;x.Anchored=true;x.CanCollide=false;x.CanTouch=false;x.CanQuery=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Color=color;x.Material=material or Enum.Material.SmoothPlastic;x.Parent=details;return x
end

-- Main sidewalks are visual walking surfaces only; vehicle physics never depends on climbing a 1-stud curb.
local concrete=Color3.fromRGB(150,150,145)
p('Sidewalk_Merdeka_N',Vector3.new(1100,.28,8),CFrame.new(0,.16,-25),concrete,Enum.Material.Concrete,false)
p('Sidewalk_Merdeka_S',Vector3.new(1100,.28,8),CFrame.new(0,.16,25),concrete,Enum.Material.Concrete,false)
p('Sidewalk_Nusantara_W',Vector3.new(8,.28,1100),CFrame.new(-25,.16,0),concrete,Enum.Material.Concrete,false)
p('Sidewalk_Nusantara_E',Vector3.new(8,.28,1100),CFrame.new(25,.16,0),concrete,Enum.Material.Concrete,false)
-- Narrow dark edge strips give the visual impression of a curb without creating a physics wall.
for _,z in ipairs({-21.1,21.1,-28.9,28.9}) do p('CurbVisual',Vector3.new(1100,.18,.34),CFrame.new(0,.28,z),Color3.fromRGB(91,91,87),Enum.Material.Concrete,false) end
for _,x in ipairs({-21.1,21.1,-28.9,28.9}) do p('CurbVisual',Vector3.new(.34,.18,1100),CFrame.new(x,.28,0),Color3.fromRGB(91,91,87),Enum.Material.Concrete,false) end

-- Zebra crossings around city centre
for _,z in ipairs({-38,38}) do
 for i=-4,4 do p('Crosswalk',Vector3.new(3.2,.045,11),CFrame.new(i*6,.5,z),Color3.fromRGB(235,235,230),Enum.Material.SmoothPlastic,false) end
end
for _,x in ipairs({-38,38}) do
 for i=-4,4 do p('Crosswalk',Vector3.new(11,.045,3.2),CFrame.new(x,.5,i*6),Color3.fromRGB(235,235,230),Enum.Material.SmoothPlastic,false) end
end

-- Street lights with cylindrical poles and angled arms.
local function lightPole(pos,rot)
 local base=cylinder('StreetLightBase',Vector3.new(.45,1.5,1.5),CFrame.new(pos+Vector3.new(0,.23,0))*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(58,61,63),Enum.Material.Metal,false)
 local pole=cylinder('StreetLightPole',Vector3.new(10,.55,.55),CFrame.new(pos+Vector3.new(0,5,0))*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(65,68,70),Enum.Material.Metal,false)
 local arm=p('StreetLightArm',Vector3.new(4,.28,.28),CFrame.new(pos+Vector3.new(1.55,9.4,0))*CFrame.Angles(0,rot or 0,math.rad(-8)),Color3.fromRGB(65,68,70),Enum.Material.Metal,false)
 local lamp=p('StreetLamp',Vector3.new(1.25,.32,.72),arm.CFrame*CFrame.new(1.65,-.18,0),Color3.fromRGB(255,235,175),Enum.Material.Neon,false)
 local l=Instance.new('PointLight');l.Range=25;l.Brightness=.85;l.Color=Color3.fromRGB(255,225,170);l.Parent=lamp
end
for x=-500,500,80 do lightPole(Vector3.new(x,0,-31),0);lightPole(Vector3.new(x,0,31),math.pi) end
for z=-500,500,80 do lightPole(Vector3.new(-31,0,z),math.pi/2);lightPole(Vector3.new(31,0,z),-math.pi/2) end

-- Layered trees: smaller trunk, multiple crowns and low shrub ring.
local function tree(pos,scale)
 scale=scale or 1
 cylinder('TreeTrunk',Vector3.new(8.5*scale,1.25*scale,1.25*scale),CFrame.new(pos+Vector3.new(0,4.25*scale,0))*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(105,72,45),Enum.Material.Wood,false)
 ball('TreeCrown',Vector3.new(7.7*scale,7.2*scale,7.7*scale),CFrame.new(pos+Vector3.new(0,9.7*scale,0)),Color3.fromRGB(62,132,72),Enum.Material.Grass)
 ball('TreeCrownLayer',Vector3.new(5.1*scale,5*scale,5.1*scale),CFrame.new(pos+Vector3.new(-1.8*scale,8.4*scale,.6*scale)),Color3.fromRGB(70,143,77),Enum.Material.Grass)
 ball('TreeCrownLayer',Vector3.new(4.8*scale,4.8*scale,4.8*scale),CFrame.new(pos+Vector3.new(1.7*scale,8.8*scale,-.5*scale)),Color3.fromRGB(56,122,67),Enum.Material.Grass)
 for a=0,2 do local ang=a*math.pi*2/3;ball('TreeShrub',Vector3.new(1.6*scale,1.2*scale,1.6*scale),CFrame.new(pos+Vector3.new(math.cos(ang)*1.7*scale,.6*scale,math.sin(ang)*1.7*scale)),Color3.fromRGB(54,119,63),Enum.Material.Grass) end
end
for x=-520,520,65 do tree(Vector3.new(x,0,-48),.75);tree(Vector3.new(x,0,48),.75) end
for z=-520,520,65 do tree(Vector3.new(-48,0,z),.75);tree(Vector3.new(48,0,z),.75) end
for i=0,10 do tree(Vector3.new(-40+i*55,0,-515),1.05) end

-- Market stalls: pitched fabric roofs, slim posts and rounded produce baskets.
for i=0,7 do
 local x=-510+i*55
 p('MarketTable',Vector3.new(27,1.25,8),CFrame.new(x,1.2,332),Color3.fromRGB(125,78,46),Enum.Material.Wood,false)
 local canopyColor=i%2==0 and Color3.fromRGB(205,65,55) or Color3.fromRGB(235,195,65)
 p('MarketAwning',Vector3.new(30,.35,14),CFrame.new(x,6.65,332),canopyColor,Enum.Material.Fabric,false)
 wedge('MarketAwningSlope',Vector3.new(15,1.3,7),CFrame.new(x-7.5,7.2,332)*CFrame.Angles(0,math.rad(90),0),canopyColor,Enum.Material.Fabric)
 wedge('MarketAwningSlope',Vector3.new(15,1.3,7),CFrame.new(x+7.5,7.2,332)*CFrame.Angles(0,math.rad(-90),0),canopyColor,Enum.Material.Fabric)
 for _,dx in ipairs({-13,13}) do cylinder('MarketPost',Vector3.new(6,.22,.22),CFrame.new(x+dx,3.4,332)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(84,63,45),Enum.Material.Wood,false) end
 for j=-2,2 do ball('ProduceBasket',Vector3.new(2.4,1.15,2.4),CFrame.new(x+j*4.4,2.2,329.8),j%2==0 and Color3.fromRGB(75,145,62) or Color3.fromRGB(205,118,54),Enum.Material.Grass) end
end

-- Beach promenade + palms. Visual surfaces remain non-collision for smooth driving/recovery.
p('BeachPromenade',Vector3.new(700,.28,20),CFrame.new(230,.16,-485),Color3.fromRGB(175,165,145),Enum.Material.Concrete,false)
for i=0,9 do
 local base=Vector3.new(-10+i*55,0,-530)
 cylinder('PalmTrunk',Vector3.new(15,1.25,1.25),CFrame.new(base+Vector3.new(0,7.5,0))*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(125,92,58),Enum.Material.Wood,false)
 ball('PalmCrown',Vector3.new(9,3.6,9),CFrame.new(base+Vector3.new(0,15.2,0)),Color3.fromRGB(55,140,75),Enum.Material.Grass)
 for a=0,3 do local ang=a*math.pi/2;p('PalmFrond',Vector3.new(7,.18,1.3),CFrame.new(base+Vector3.new(math.cos(ang)*3.3,15.6,math.sin(ang)*3.3))*CFrame.Angles(0,-ang,math.rad(-12)),Color3.fromRGB(49,126,67),Enum.Material.Grass,false) end
end

-- Traffic lights at central junction, fully non-collision.
local function trafficLight(pos)
 cylinder('TrafficPole',Vector3.new(9.5,.55,.55),CFrame.new(pos+Vector3.new(0,4.75,0))*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(50,52,55),Enum.Material.Metal,false)
 local box=p('TrafficSignal',Vector3.new(1.9,4.5,1.45),CFrame.new(pos+Vector3.new(0,8.7,0)),Color3.fromRGB(35,37,39),Enum.Material.Metal,false)
 for i,c in ipairs({Color3.fromRGB(215,55,50),Color3.fromRGB(235,180,45),Color3.fromRGB(65,190,90)}) do ball('SignalBulb',Vector3.new(.72,.72,.32),box.CFrame*CFrame.new(0,1.35-(i-1)*1.32,-.82),c,Enum.Material.Neon) end
end
for _,pos in ipairs({Vector3.new(-30,0,-30),Vector3.new(30,0,30),Vector3.new(-30,0,30),Vector3.new(30,0,-30)}) do trafficLight(pos) end

-- Rounded public-space furniture and bus shelters.
local function bench(pos,rot)
 local cf=CFrame.new(pos)*CFrame.Angles(0,rot or 0,0)
 p('BenchSeat',Vector3.new(6.2,.38,1.55),cf*CFrame.new(0,1.8,0),Color3.fromRGB(115,75,45),Enum.Material.Wood,false)
 p('BenchBack',Vector3.new(6.2,1.45,.24),cf*CFrame.new(0,2.65,.62)*CFrame.Angles(math.rad(-8),0,0),Color3.fromRGB(105,69,43),Enum.Material.Wood,false)
 for _,x in ipairs({-2.35,2.35}) do cylinder('BenchLeg',Vector3.new(1.4,.18,.18),cf*CFrame.new(x,1.05,0)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(60,62,64),Enum.Material.Metal,false) end
end
for _,pos in ipairs({Vector3.new(100,0,-100),Vector3.new(140,0,-100),Vector3.new(180,0,-100),Vector3.new(220,0,-485),Vector3.new(270,0,-485)}) do bench(pos,0) end

local function shelter(pos,rot)
 local cf=CFrame.new(pos)*CFrame.Angles(0,rot or 0,0)
 for _,x in ipairs({-4.5,4.5}) do cylinder('BusShelterPost',Vector3.new(6.5,.22,.22),cf*CFrame.new(x,3.25,0)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(65,69,72),Enum.Material.Metal,false) end
 local roof=p('BusShelterRoof',Vector3.new(10,.28,4.4),cf*CFrame.new(0,6.4,0),Color3.fromRGB(68,76,78),Enum.Material.Metal,false)
 local glass=p('BusShelterGlass',Vector3.new(9,4.8,.12),cf*CFrame.new(0,3.5,1.8),Color3.fromRGB(118,153,164),Enum.Material.Glass,false);glass.Transparency=.45
 bench(pos+Vector3.new(0,0,-.6),rot or 0)
end
shelter(Vector3.new(-150,0,-31),0);shelter(Vector3.new(165,0,31),math.pi);shelter(Vector3.new(-31,0,175),math.pi/2);shelter(Vector3.new(31,0,-175),-math.pi/2)

-- Small rounded pocket plazas break long rectangular street corridors.
for _,pos in ipairs({Vector3.new(105,.1,105),Vector3.new(-125,.1,-120),Vector3.new(255,.1,-170)}) do
 cylinder('PocketPlaza',Vector3.new(.18,15,15),CFrame.new(pos)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(164,157,144),Enum.Material.Concrete,false)
 cylinder('PocketPlanter',Vector3.new(1.05,5.8,5.8),CFrame.new(pos+Vector3.new(0,.52,0))*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(104,88,66),Enum.Material.Brick,false)
 ball('PocketGreen',Vector3.new(4.4,2.8,4.4),CFrame.new(pos+Vector3.new(0,1.75,0)),Color3.fromRGB(64,130,70),Enum.Material.Grass)
end

-- Perbukitan Asri silhouette / uphill visual destination.
for i=1,7 do
 local s=100+i*28
 ball('Hill_'..i,Vector3.new(s,28+i*10,s),CFrame.new(-260+i*75,10+i*5,560+i*15),Color3.fromRGB(70,112,64),Enum.Material.Grass)
end

Workspace:SetAttribute('ACC_BecakCityDetails','v1.2')
Workspace:SetAttribute('BecakCityDetailsNonBlocking','ON')
Workspace:SetAttribute('BecakRoundedPublicFurniture','ON')
Workspace:SetAttribute('BecakBusShelterNetwork','ON')
Workspace:SetAttribute('BecakLayeredVegetation','ON')
Workspace:SetAttribute('BecakMarketGeometryUpgrade','ON')
print('[BECAK E-BIKE] Nusakarya detail pass v1.2 ready')
