-- Mountain Social Adventure visual polish v1.5
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Terrain=Workspace.Terrain
local root=Workspace:WaitForChild("ACC_MountainSocial")
local decor=root:WaitForChild("Decor")

local route={
Vector3.new(0,22,690),Vector3.new(-132,75,555),Vector3.new(88,126,430),Vector3.new(212,182,300),
Vector3.new(78,236,158),Vector3.new(-118,300,34),Vector3.new(-224,356,-106),Vector3.new(-74,414,-242),
Vector3.new(116,470,-336),Vector3.new(204,526,-432),Vector3.new(94,575,-540),Vector3.new(0,620,-650)}

local function mk(name,size,cf,mat,col,parent,tr,collide)
 local p=Instance.new("Part");p.Name=name;p.Anchored=true;p.Size=size;p.CFrame=cf
 p.Material=mat or Enum.Material.Wood;if col then p.Color=col end;p.Transparency=tr or 0
 p.CanCollide=collide~=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or decor;return p
end

local old=root:FindFirstChild("VisualPolishV15");if old then old:Destroy() end
local polish=Instance.new("Folder");polish.Name="VisualPolishV15";polish.Parent=root

-- Replace giant spherical masses with a continuous irregular ridge.
Terrain:Clear()
Terrain:FillBlock(CFrame.new(0,-34,40),Vector3.new(2100,68,2100),Enum.Material.Ground)
math.randomseed(150826)

for i=1,64 do
 local a=math.random()*math.pi*2;local r=math.random(120,720)
 Terrain:FillBall(Vector3.new(math.cos(a)*r,math.random(8,25),560+math.sin(a)*r),math.random(30,74),Enum.Material.Grass)
end

local function radiusFor(y)
 if y<120 then return 96 elseif y<250 then return 84 elseif y<400 then return 70 elseif y<520 then return 56 else return 42 end
end

for seg=1,#route-1 do
 local a,b=route[seg],route[seg+1];local d=b-a;local side=Vector3.new(-d.Z,0,d.X)
 if side.Magnitude>0 then side=side.Unit end
 local steps=math.max(10,math.floor(d.Magnitude/26))
 for s=0,steps do
  local t=s/steps;local c=a:Lerp(b,t);local r=radiusFor(c.Y);local mat=c.Y<260 and Enum.Material.Grass or Enum.Material.Rock
  Terrain:FillBall(c-Vector3.new(0,r*.50,0)+Vector3.new(math.random(-6,6),math.random(-5,5),math.random(-6,6)),r,mat)
  for _,sign in ipairs({-1,1}) do
   local sr=r*math.random(50,72)/100
   Terrain:FillBall(c+side*(r*.68*sign)-Vector3.new(0,r*.50,0),sr,mat)
  end
 end
end

-- Broken rock shoulders middle/upper mountain.
for i=1,96 do
 local seg=math.random(5,#route-1);local a,b=route[seg],route[seg+1];local p=a:Lerp(b,math.random())
 local d=b-a;local side=Vector3.new(-d.Z,0,d.X).Unit
 Terrain:FillBall(p+side*math.random(-82,82)+Vector3.new(0,math.random(-28,18),0),math.random(8,22),Enum.Material.Rock)
end

-- Narrow natural soil ribbon with slight switchback motion.
for seg=1,#route-1 do
 local a,b=route[seg],route[seg+1];local d=b-a;local side=Vector3.new(-d.Z,0,d.X)
 if side.Magnitude>0 then side=side.Unit end
 local steps=math.max(10,math.floor(d.Magnitude/16))
 for s=0,steps do
  local t=s/steps;local sway=math.sin(seg*1.6+t*6.2)*(seg<7 and 12 or 8)
  local p=a:Lerp(b,t)+side*sway-Vector3.new(0,3,0)
  Terrain:FillBall(p,seg<5 and 8 or 6,Enum.Material.Ground)
 end
end

-- Basecamp clearing.
local base=route[1];Terrain:FillBall(base-Vector3.new(0,9,0),54,Enum.Material.Ground)
local prev=root:FindFirstChild("BasecampVisual");if prev then prev:Destroy() end
local camp=Instance.new("Model");camp.Name="BasecampVisual";camp.Parent=root
local hut=base+Vector3.new(-34,5,22)
mk("HutFloor",Vector3.new(28,1,20),CFrame.new(hut),Enum.Material.WoodPlanks,Color3.fromRGB(92,70,48),camp)
mk("HutBack",Vector3.new(28,12,1),CFrame.new(hut+Vector3.new(0,6,9.5)),Enum.Material.WoodPlanks,Color3.fromRGB(83,61,42),camp)
mk("HutLeft",Vector3.new(1,12,20),CFrame.new(hut+Vector3.new(-13.5,6,0)),Enum.Material.WoodPlanks,Color3.fromRGB(83,61,42),camp)
mk("HutRight",Vector3.new(1,12,20),CFrame.new(hut+Vector3.new(13.5,6,0)),Enum.Material.WoodPlanks,Color3.fromRGB(83,61,42),camp)
mk("RoofA",Vector3.new(17,1,23),CFrame.new(hut+Vector3.new(-7,13,0))*CFrame.Angles(0,0,math.rad(24)),Enum.Material.Slate,Color3.fromRGB(54,57,55),camp)
mk("RoofB",Vector3.new(17,1,23),CFrame.new(hut+Vector3.new(7,13,0))*CFrame.Angles(0,0,math.rad(-24)),Enum.Material.Slate,Color3.fromRGB(54,57,55),camp)

local gate=base+Vector3.new(-2,5,-30)
mk("GateL",Vector3.new(3,13,3),CFrame.new(gate+Vector3.new(-10,0,0)),Enum.Material.Wood,Color3.fromRGB(71,51,35),camp)
mk("GateR",Vector3.new(3,13,3),CFrame.new(gate+Vector3.new(10,0,0)),Enum.Material.Wood,Color3.fromRGB(71,51,35),camp)
local sign=mk("TrailheadSign",Vector3.new(24,6,1.2),CFrame.new(gate+Vector3.new(0,5.5,0)),Enum.Material.WoodPlanks,Color3.fromRGB(70,54,38),camp)
local sg=Instance.new("SurfaceGui");sg.Face=Enum.NormalId.Front;sg.PixelsPerStud=30;sg.Parent=sign
local tx=Instance.new("TextLabel");tx.Size=UDim2.fromScale(1,1);tx.BackgroundTransparency=1;tx.Text="MOUNTAIN SOCIAL ADVENTURE\nTRAILHEAD";tx.TextColor3=Color3.fromRGB(234,224,196);tx.TextScaled=true;tx.Font=Enum.Font.GothamBold;tx.Parent=sg

for i,off in ipairs({Vector3.new(28,3,20),Vector3.new(34,3,2),Vector3.new(24,3,-15),Vector3.new(43,3,13)}) do
 local tent=mk("Tent"..i,Vector3.new(10,6,7),CFrame.new(base+off)*CFrame.Angles(0,math.rad(i*28),math.rad(38)),Enum.Material.Fabric,Color3.fromRGB(69,86,64),camp,0,false);tent.CanCollide=false
end

-- Lightweight vegetation types by altitude.
local function tree(pos,scale,dark)
 local h=12*scale
 local trunk=mk("Trunk",Vector3.new(2*scale,h,2*scale),CFrame.new(pos+Vector3.new(0,h/2,0)),Enum.Material.Wood,Color3.fromRGB(72,53,38),polish,0,false);trunk.CanCollide=false
 local c1=mk("Canopy",Vector3.new(9*scale,7*scale,9*scale),CFrame.new(pos+Vector3.new(0,h*.82,0)),Enum.Material.Grass,dark and Color3.fromRGB(35,66,47) or Color3.fromRGB(48,82,54),polish,0,false);c1.Shape=Enum.PartType.Ball;c1.CanCollide=false
 local c2=mk("Canopy",Vector3.new(6*scale,6*scale,6*scale),CFrame.new(pos+Vector3.new(0,h+2.5*scale,0)),Enum.Material.Grass,dark and Color3.fromRGB(42,73,51) or Color3.fromRGB(56,93,61),polish,0,false);c2.Shape=Enum.PartType.Ball;c2.CanCollide=false
end

-- Dense lower forest and thinner mist forest.
for i=1,95 do
 local seg=math.random(1,6);local a,b=route[seg],route[seg+1];local p=a:Lerp(b,math.random())
 local d=b-a;local side=Vector3.new(-d.Z,0,d.X).Unit
 local off=side*math.random(26,88)*(math.random()<.5 and -1 or 1)
 tree(p+off-Vector3.new(0,5,0),.7+math.random()*.5,seg>=5)
end
for i=1,30 do
 local seg=math.random(7,9);local a,b=route[seg],route[seg+1];local p=a:Lerp(b,math.random())
 local d=b-a;local side=Vector3.new(-d.Z,0,d.X).Unit
 tree(p+side*math.random(-60,60)-Vector3.new(0,5,0),.55+math.random()*.3,true)
end

-- Route-edge rocks and small cairns; visual guidance without neon markers.
for i=1,80 do
 local seg=math.random(2,#route-1);local a,b=route[seg],route[seg+1];local p=a:Lerp(b,math.random())
 local d=b-a;local side=Vector3.new(-d.Z,0,d.X).Unit
 local rock=mk("TrailRock",Vector3.new(math.random(3,8),math.random(2,5),math.random(3,8)),CFrame.new(p+side*math.random(-24,24)-Vector3.new(0,2,0))*CFrame.Angles(math.random(),math.random(),math.random()),Enum.Material.Rock,Color3.fromRGB(83,86,82),polish,0,false);rock.Shape=Enum.PartType.Ball;rock.CanCollide=false
end
for _,idx in ipairs({3,6,8,10,11}) do
 local p=route[idx]+Vector3.new(12,1,5)
 for j=1,3 do mk("Cairn",Vector3.new(3.8-j*.45,1.4,3.3-j*.35),CFrame.new(p+Vector3.new(0,j*1.15,0)),Enum.Material.Rock,Color3.fromRGB(95,96,92),polish,0,false) end
end

-- Camp identity at mid and upper zones.
for _,idx in ipairs({5,9}) do
 local p=route[idx]+Vector3.new(16,0,8)
 local ring=mk("CampRing",Vector3.new(8,1,8),CFrame.new(p),Enum.Material.Slate,Color3.fromRGB(75,74,69),polish,0,false);ring.Shape=Enum.PartType.Cylinder;ring.CanCollide=false
 local fire=Instance.new("Fire");fire.Size=5;fire.Heat=6;fire.Parent=ring
 for s=1,3 do mk("Log",Vector3.new(9,1.2,1.4),CFrame.new(p+Vector3.new(math.cos(s*2.1)*7,0.5,math.sin(s*2.1)*7))*CFrame.Angles(0,s*2.1,0),Enum.Material.Wood,Color3.fromRGB(83,59,40),polish) end
end

-- Summit marker is compact and photo-friendly.
local summit=route[12]
local flag=mk("SummitPole",Vector3.new(.7,18,.7),CFrame.new(summit+Vector3.new(6,9,-5)),Enum.Material.Metal,Color3.fromRGB(110,112,110),polish)
local cloth=mk("SummitFlag",Vector3.new(8,4,.3),CFrame.new(summit+Vector3.new(10,15,-5)),Enum.Material.Fabric,Color3.fromRGB(179,45,45),polish,0,false);cloth.CanCollide=false

-- Cinematic but restrained environment.
Lighting.GlobalShadows=true
Lighting.Brightness=2.1
local cc=Lighting:FindFirstChild("ACC_MountainColor")
if cc then cc.Contrast=.08;cc.Saturation=-.04 end

local spawn=root:FindFirstChild("MountainSpawn")
if spawn and spawn:IsA("SpawnLocation") then spawn.Transparency=1;spawn.CanCollide=false;spawn.Duration=0 end

root:SetAttribute("VisualPolish","1.5")
root:SetAttribute("BuildVersion","1.5.0-biome-polish")
print("[ACC] Mountain visual polish v1.5 applied")
