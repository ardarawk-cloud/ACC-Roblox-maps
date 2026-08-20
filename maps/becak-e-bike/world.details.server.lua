-- BECAK E-BIKE — Nusakarya visual/detail pass v1.1
local Workspace=game:GetService('Workspace')
local root=Workspace:WaitForChild('BecakEBike',20)
if not root then return end
local world=root:WaitForChild('Nusakarya',20)
if not world then return end

local details=Instance.new('Folder') details.Name='CityDetails' details.Parent=world
local function p(name,size,cf,color,material,collide)
 local x=Instance.new('Part');x.Name=name;x.Size=size;x.CFrame=cf;x.Anchored=true;x.CanCollide=collide~=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Color=color;x.Material=material or Enum.Material.SmoothPlastic;x.Parent=details;return x
end
local function cylinder(name,size,cf,color)
 local x=p(name,size,cf,color,Enum.Material.SmoothPlastic,true);x.Shape=Enum.PartType.Cylinder;return x
end

-- Main sidewalks
local concrete=Color3.fromRGB(150,150,145)
p('Sidewalk_Merdeka_N',Vector3.new(1100,1,8),CFrame.new(0,.55,-25),concrete,Enum.Material.Concrete,true)
p('Sidewalk_Merdeka_S',Vector3.new(1100,1,8),CFrame.new(0,.55,25),concrete,Enum.Material.Concrete,true)
p('Sidewalk_Nusantara_W',Vector3.new(8,1,1100),CFrame.new(-25,.55,0),concrete,Enum.Material.Concrete,true)
p('Sidewalk_Nusantara_E',Vector3.new(8,1,1100),CFrame.new(25,.55,0),concrete,Enum.Material.Concrete,true)

-- Zebra crossings around city centre
for _,z in ipairs({-38,38}) do
 for i=-4,4 do p('Crosswalk',Vector3.new(3.2,.08,11),CFrame.new(i*6,.52,z),Color3.fromRGB(235,235,230),Enum.Material.SmoothPlastic,false) end
end
for _,x in ipairs({-38,38}) do
 for i=-4,4 do p('Crosswalk',Vector3.new(11,.08,3.2),CFrame.new(x,.52,i*6),Color3.fromRGB(235,235,230),Enum.Material.SmoothPlastic,false) end
end

-- Street lights
local function lightPole(pos,rot)
 local pole=p('StreetLightPole',Vector3.new(.7,10,.7),CFrame.new(pos)*CFrame.Angles(0,rot or 0,0),Color3.fromRGB(65,68,70),Enum.Material.Metal,true)
 local arm=p('StreetLightArm',Vector3.new(4,.45,.45),pole.CFrame*CFrame.new(1.8,4.6,0),Color3.fromRGB(65,68,70),Enum.Material.Metal,true)
 local lamp=p('StreetLamp',Vector3.new(1.2,.35,1.2),arm.CFrame*CFrame.new(1.6,-.25,0),Color3.fromRGB(255,235,175),Enum.Material.Neon,false)
 local l=Instance.new('PointLight');l.Range=25;l.Brightness=1.1;l.Color=Color3.fromRGB(255,225,170);l.Parent=lamp
end
for x=-500,500,80 do lightPole(Vector3.new(x,5,-31),0);lightPole(Vector3.new(x,5,31),math.pi) end
for z=-500,500,80 do lightPole(Vector3.new(-31,5,z),math.pi/2);lightPole(Vector3.new(31,5,z),-math.pi/2) end

-- Trees & planter rhythm
local function tree(pos,scale)
 scale=scale or 1
 local trunk=p('TreeTrunk',Vector3.new(2*scale,9*scale,2*scale),CFrame.new(pos+Vector3.new(0,4.5*scale,0)),Color3.fromRGB(105,72,45),Enum.Material.Wood,true)
 local crown=p('TreeCrown',Vector3.new(9*scale,9*scale,9*scale),CFrame.new(pos+Vector3.new(0,11*scale,0)),Color3.fromRGB(62,132,72),Enum.Material.Grass,false);crown.Shape=Enum.PartType.Ball
end
for x=-520,520,65 do tree(Vector3.new(x,0,-48),.75);tree(Vector3.new(x,0,48),.75) end
for z=-520,520,65 do tree(Vector3.new(-48,0,z),.75);tree(Vector3.new(48,0,z),.75) end
for i=0,10 do tree(Vector3.new(-40+i*55,0,-515),1.15) end

-- Market stalls
for i=0,7 do
 local x=-510+i*55
 p('MarketTable',Vector3.new(30,2,10),CFrame.new(x,2,332),Color3.fromRGB(125,78,46),Enum.Material.Wood,true)
 p('MarketAwning',Vector3.new(34,.7,17),CFrame.new(x,7,332),i%2==0 and Color3.fromRGB(205,65,55) or Color3.fromRGB(235,195,65),Enum.Material.Fabric,false)
end

-- Beach promenade + palms
p('BeachPromenade',Vector3.new(700,1,20),CFrame.new(230,.5,-485),Color3.fromRGB(175,165,145),Enum.Material.Concrete,true)
for i=0,9 do
 local base=Vector3.new(-10+i*55,0,-530)
 local trunk=cylinder('PalmTrunk',Vector3.new(16,1.6,1.6),CFrame.new(base+Vector3.new(0,8,0))*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(125,92,58))
 trunk.CanCollide=true
 local crown=p('PalmCrown',Vector3.new(10,4,10),CFrame.new(base+Vector3.new(0,17,0)),Color3.fromRGB(55,140,75),Enum.Material.Grass,false);crown.Shape=Enum.PartType.Ball
end

-- Traffic lights at central junction
local function trafficLight(pos)
 local pole=p('TrafficPole',Vector3.new(.7,10,.7),CFrame.new(pos+Vector3.new(0,5,0)),Color3.fromRGB(50,52,55),Enum.Material.Metal,true)
 local box=p('TrafficSignal',Vector3.new(2.2,5,1.8),pole.CFrame*CFrame.new(0,4.5,0),Color3.fromRGB(35,37,39),Enum.Material.Metal,false)
 for i,c in ipairs({Color3.fromRGB(215,55,50),Color3.fromRGB(235,180,45),Color3.fromRGB(65,190,90)}) do
  local bulb=p('SignalBulb',Vector3.new(.8,.8,.25),box.CFrame*CFrame.new(0,1.6-(i-1)*1.55,-1.02),c,Enum.Material.Neon,false);bulb.Shape=Enum.PartType.Ball
 end
end
for _,pos in ipairs({Vector3.new(-30,0,-30),Vector3.new(30,0,30),Vector3.new(-30,0,30),Vector3.new(30,0,-30)}) do trafficLight(pos) end

-- Benches / social spots
for _,pos in ipairs({Vector3.new(100,0,-100),Vector3.new(140,0,-100),Vector3.new(180,0,-100),Vector3.new(220,0,-485),Vector3.new(270,0,-485)}) do
 p('BenchSeat',Vector3.new(8,.6,2),CFrame.new(pos+Vector3.new(0,2,0)),Color3.fromRGB(115,75,45),Enum.Material.Wood,true)
 p('BenchLeg',Vector3.new(.7,2,.7),CFrame.new(pos+Vector3.new(-3,1,0)),Color3.fromRGB(60,62,64),Enum.Material.Metal,true)
 p('BenchLeg',Vector3.new(.7,2,.7),CFrame.new(pos+Vector3.new(3,1,0)),Color3.fromRGB(60,62,64),Enum.Material.Metal,true)
end

-- Perbukitan Asri silhouette / uphill visual destination
for i=1,7 do
 local s=100+i*28
 local hill=p('Hill_'..i,Vector3.new(s,28+i*10,s),CFrame.new(-260+i*75,10+i*5,560+i*15),Color3.fromRGB(70,112,64),Enum.Material.Grass,true)
 hill.Shape=Enum.PartType.Ball
end

Workspace:SetAttribute('ACC_BecakCityDetails','v1.1')
print('[BECAK E-BIKE] Nusakarya detail pass v1.1 ready')
