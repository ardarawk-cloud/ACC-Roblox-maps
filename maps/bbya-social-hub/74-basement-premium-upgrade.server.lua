-- BBYA SOCIAL HUB — BASEMENT PREMIUM UPGRADE v2
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local old=root:FindFirstChild("Underground")
if old then old:Destroy() end
local m=Instance.new("Model");m.Name="Underground";m.Parent=root
m:SetAttribute("Pass","BASEMENT_PREMIUM_V2")

local C={black=Color3.fromRGB(10,11,14),white=Color3.fromRGB(236,236,232),wall=Color3.fromRGB(24,28,34),metal=Color3.fromRGB(52,57,64),blue=Color3.fromRGB(0,144,255),yellow=Color3.fromRGB(255,205,38),leather=Color3.fromRGB(34,35,40),glass=Color3.fromRGB(52,62,72)}
local function part(name,size,cf,color,mat,collide,parent)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.wall;p.Material=mat or Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=collide~=false;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or m;return p
end
local function neon(name,size,cf,color,parent)
 local p=part(name,size,cf,color,Enum.Material.Neon,false,parent);p.CastShadow=false
 local l=Instance.new("SurfaceLight");l.Face=Enum.NormalId.Bottom;l.Color=color;l.Brightness=.45;l.Range=10;l.Shadows=false;l.Parent=p
 return p
end
local function cylinder(name,size,cf,color,mat,parent)
 local p=part(name,size,cf,color,mat,false,parent);p.Shape=Enum.PartType.Cylinder;return p
end
local function beam(name,a,b,color,parent,thick)
 local d=b-a;local mid=(a+b)/2;local cf=CFrame.lookAt(mid,b)*CFrame.Angles(0,math.rad(90),0)
 return neon(name,Vector3.new(d.Magnitude,thick or .16,thick or .16),cf,color,parent)
end

-- shell
part("Ceiling",Vector3.new(120,1,90),CFrame.new(0,-.5,0),C.black,Enum.Material.Concrete,true)
part("NorthWall",Vector3.new(120,16,2),CFrame.new(0,-8,44),C.wall,Enum.Material.Concrete,true)
part("SouthWall",Vector3.new(120,16,2),CFrame.new(0,-8,-44),C.wall,Enum.Material.Concrete,true)
part("WestWall",Vector3.new(2,16,90),CFrame.new(-59,-8,0),C.wall,Enum.Material.Concrete,true)
part("EastWall",Vector3.new(2,16,90),CFrame.new(59,-8,0),C.wall,Enum.Material.Concrete,true)

-- true black/white checker floor; overlays the structural basement slab.
local checker=Instance.new("Model");checker.Name="CheckerFloor";checker.Parent=m
local tile=10
for xi=-5,5 do
 for zi=-4,4 do
  local color=((xi+zi)%2==0) and C.white or C.black
  part(string.format("Tile_%d_%d",xi,zi),Vector3.new(tile,.18,tile),CFrame.new(xi*tile,-14.91,zi*tile),color,Enum.Material.SmoothPlastic,true,checker)
 end
end

-- blue/yellow club lighting only.
for i,z in ipairs({-34,-17,0,17,34}) do neon("CeilingBlue"..i,Vector3.new(86,.16,.16),CFrame.new(0,-1.05,z),C.blue) end
for i,x in ipairs({-48,-32,-16,0,16,32,48}) do neon("CeilingYellow"..i,Vector3.new(.16,.16,58),CFrame.new(x,-1.08,0),C.yellow) end
neon("WallBlueL",Vector3.new(.14,8,0.14),CFrame.new(-57.8,-7.5,22),C.blue)
neon("WallYellowL",Vector3.new(.14,8,0.14),CFrame.new(-57.8,-7.5,-22),C.yellow)
neon("WallBlueR",Vector3.new(.14,8,0.14),CFrame.new(57.8,-7.5,-22),C.blue)
neon("WallYellowR",Vector3.new(.14,8,0.14),CFrame.new(57.8,-7.5,22),C.yellow)

-- full white pentagon fixtures above lounge zones.
local pentagons=Instance.new("Model");pentagons.Name="WhitePentagonCeilingLights";pentagons.Parent=m
local function pentagon(name,center,radius)
 local pts={}
 for i=0,4 do
  local a=math.rad(-90+i*72);table.insert(pts,center+Vector3.new(math.cos(a)*radius,0,math.sin(a)*radius))
 end
 for i=1,5 do beam(name.."Edge"..i,pts[i],pts[(i%5)+1],C.white,pentagons,.18) end
end
pentagon("PentagonWest",Vector3.new(-39,-1.22,3),8)
pentagon("PentagonCenter",Vector3.new(0,-1.22,-12),8.5)
pentagon("PentagonEast",Vector3.new(39,-1.22,3),8)

-- premium white DJ stage + booth.
part("DJStage",Vector3.new(46,1.2,15),CFrame.new(0,-14.25,31),Color3.fromRGB(40,42,46),Enum.Material.Metal,true)
part("DJBoothBase",Vector3.new(30,3.6,5.5),CFrame.new(0,-11.9,32),C.white,Enum.Material.SmoothPlastic,true)
part("DJBoothTop",Vector3.new(32,.45,6.2),CFrame.new(0,-9.88,32),Color3.fromRGB(250,250,246),Enum.Material.SmoothPlastic,true)
neon("DJBoothBlue",Vector3.new(28,.12,.12),CFrame.new(0,-10.1,29),C.blue)
neon("DJBoothYellow",Vector3.new(19,.10,.10),CFrame.new(0,-9.95,28.85),C.yellow)
for _,x in ipairs({-8.2,8.2}) do
 part("DeckBody"..x,Vector3.new(7.2,.55,4.2),CFrame.new(x,-9.42,31.7),C.black,Enum.Material.Metal,false)
 local jog=cylinder("Jog"..x,Vector3.new(.22,2.8,2.8),CFrame.new(x,-9.08,31.7)*CFrame.Angles(0,0,math.rad(90)),C.metal,Enum.Material.Metal)
 for n=-2,2 do neon("DeckPad"..x.."_"..n,Vector3.new(.38,.08,.38),CFrame.new(x+n*.7,-9.05,33),n%2==0 and C.blue or C.yellow) end
end
part("Mixer",Vector3.new(6.2,.58,4.2),CFrame.new(0,-9.4,31.7),C.black,Enum.Material.Metal,false)
for n=-2,2 do part("MixerFader"..n,Vector3.new(.10,.12,1.35),CFrame.new(n*.75,-9.04,31.6),C.white,Enum.Material.Metal,false) end

-- upgraded lounge sofas facing the dance floor.
local lounge=Instance.new("Model");lounge.Name="PremiumLounge";lounge.Parent=m
local function sofa(side,z)
 local x=side*48
 part("Seat_"..side.."_"..z,Vector3.new(11,2.1,16),CFrame.new(x,-13.75,z),C.leather,Enum.Material.SmoothPlastic,true,lounge)
 part("Back_"..side.."_"..z,Vector3.new(2.2,4.2,16),CFrame.new(side*54,-11.85,z),Color3.fromRGB(22,23,27),Enum.Material.SmoothPlastic,true,lounge)
 part("ArmA_"..side.."_"..z,Vector3.new(10,3,1.7),CFrame.new(x,-12.35,z-7.2),Color3.fromRGB(26,27,31),Enum.Material.SmoothPlastic,true,lounge)
 part("ArmB_"..side.."_"..z,Vector3.new(10,3,1.7),CFrame.new(x,-12.35,z+7.2),Color3.fromRGB(26,27,31),Enum.Material.SmoothPlastic,true,lounge)
end
for _,z in ipairs({-10,11}) do sofa(-1,z);sofa(1,z) end
for _,x in ipairs({-36,36}) do
 part("LoungeTable"..x,Vector3.new(7,.8,8),CFrame.new(x,-13.65,0),C.glass,Enum.Material.Glass,true,lounge)
end

-- upgraded rear bar.
local bar=Instance.new("Model");bar.Name="PremiumBar";bar.Parent=m
part("BarBody",Vector3.new(44,3.8,5.5),CFrame.new(0,-12.55,-34),Color3.fromRGB(29,30,34),Enum.Material.Metal,true,bar)
part("BarFrontWhite",Vector3.new(40,2.6,.35),CFrame.new(0,-12.45,-31.05),C.white,Enum.Material.SmoothPlastic,false,bar)
part("BarTop",Vector3.new(46,.5,6.5),CFrame.new(0,-10.45,-34),C.white,Enum.Material.SmoothPlastic,true,bar)
neon("BarBlue",Vector3.new(43,.12,.12),CFrame.new(0,-10.72,-30.85),C.blue,bar)
neon("BarYellow",Vector3.new(32,.10,.10),CFrame.new(0,-10.56,-30.7),C.yellow,bar)
for shelfY=-8.8,-5.6,3.2 do
 part("BottleShelf"..shelfY,Vector3.new(34,.28,2),CFrame.new(0,shelfY,-41.7),C.metal,Enum.Material.Metal,true,bar)
end
for i=-7,7 do
 local color=(i%2==0) and C.blue or C.yellow
 cylinder("Bottle"..i,Vector3.new(1.5,.48,.48),CFrame.new(i*2.1,-8,-41.3)*CFrame.Angles(0,0,math.rad(90)),color,Enum.Material.Glass,bar)
end
for i=-4,4 do
 local seat=cylinder("BarStool"..i,Vector3.new(.45,2.3,2.3),CFrame.new(i*4,-13.1,-27.8)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(42,43,48),Enum.Material.SmoothPlastic,bar)
 part("StoolStem"..i,Vector3.new(.35,2.4,.35),CFrame.new(i*4,-14,-27.8),C.metal,Enum.Material.Metal,true,bar)
end

print("[BBYA] Basement Premium v2 online: checker floor / blue-yellow neon / white DJ booth / premium bar-sofas / white pentagons")
