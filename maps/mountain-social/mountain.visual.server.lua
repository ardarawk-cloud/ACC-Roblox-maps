-- Mountain Social Adventure visual polish v1.4
local Workspace=game:GetService("Workspace")
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

-- Replace giant spherical masses with a continuous irregular ridge.
Terrain:Clear()
Terrain:FillBlock(CFrame.new(0,-34,40),Vector3.new(2100,68,2100),Enum.Material.Ground)
math.randomseed(140826)

for i=1,56 do
 local a=math.random()*math.pi*2;local r=math.random(120,720)
 Terrain:FillBall(Vector3.new(math.cos(a)*r,math.random(8,25),560+math.sin(a)*r),math.random(35,82),Enum.Material.Grass)
end

local function radiusFor(y)
 if y<120 then return 98 elseif y<250 then return 86 elseif y<400 then return 72 elseif y<520 then return 58 else return 44 end
end

for seg=1,#route-1 do
 local a,b=route[seg],route[seg+1];local d=b-a;local side=Vector3.new(-d.Z,0,d.X)
 if side.Magnitude>0 then side=side.Unit end
 local steps=math.max(8,math.floor(d.Magnitude/30))
 for s=0,steps do
  local t=s/steps;local c=a:Lerp(b,t);local r=radiusFor(c.Y);local mat=c.Y<260 and Enum.Material.Grass or Enum.Material.Rock
  Terrain:FillBall(c-Vector3.new(0,r*.48,0)+Vector3.new(math.random(-7,7),math.random(-5,5),math.random(-7,7)),r,mat)
  for _,sign in ipairs({-1,1}) do
   local sr=r*math.random(55,78)/100
   Terrain:FillBall(c+side*(r*.7*sign)-Vector3.new(0,r*.48,0),sr,mat)
  end
 end
end

for i=1,72 do
 local seg=math.random(5,#route-1);local a,b=route[seg],route[seg+1];local p=a:Lerp(b,math.random())
 local d=b-a;local side=Vector3.new(-d.Z,0,d.X).Unit
 Terrain:FillBall(p+side*math.random(-75,75)+Vector3.new(0,math.random(-25,20),0),math.random(10,25),Enum.Material.Rock)
end

-- Soil ribbon under the hiking route.
for seg=1,#route-1 do
 local a,b=route[seg],route[seg+1];local d=b-a;local side=Vector3.new(-d.Z,0,d.X)
 if side.Magnitude>0 then side=side.Unit end
 local steps=math.max(8,math.floor(d.Magnitude/20))
 for s=0,steps do
  local t=s/steps;local p=a:Lerp(b,t)+side*math.sin(seg*1.8+t*5)*9-Vector3.new(0,3,0)
  Terrain:FillBall(p,seg<5 and 10 or 7,Enum.Material.Ground)
 end
end

-- Basecamp clearing and grounded trailhead.
local base=route[1];Terrain:FillBall(base-Vector3.new(0,9,0),50,Enum.Material.Ground)
local old=root:FindFirstChild("BasecampVisual");if old then old:Destroy() end
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

for i,off in ipairs({Vector3.new(28,3,20),Vector3.new(34,3,2),Vector3.new(24,3,-15)}) do
 local tent=mk("Tent"..i,Vector3.new(10,6,7),CFrame.new(base+off)*CFrame.Angles(0,math.rad(i*28),math.rad(38)),Enum.Material.Fabric,Color3.fromRGB(69,86,64),camp,0,false);tent.CanCollide=false
end

local spawn=root:FindFirstChild("MountainSpawn")
if spawn and spawn:IsA("SpawnLocation") then spawn.Transparency=1;spawn.CanCollide=false;spawn.Duration=0 end

root:SetAttribute("VisualPolish","1.4")
root:SetAttribute("BuildVersion","1.4.0-visual-polish")
print("[ACC] Mountain visual polish v1.4 applied")
