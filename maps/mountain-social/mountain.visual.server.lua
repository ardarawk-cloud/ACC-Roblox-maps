-- Mountain Social Adventure visual polish v1.6
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Terrain=Workspace.Terrain
local root=Workspace:WaitForChild("ACC_MountainSocial")
local decor=root:WaitForChild("Decor")
local route={Vector3.new(0,22,690),Vector3.new(-132,75,555),Vector3.new(88,126,430),Vector3.new(212,182,300),Vector3.new(78,236,158),Vector3.new(-118,300,34),Vector3.new(-224,356,-106),Vector3.new(-74,414,-242),Vector3.new(116,470,-336),Vector3.new(204,526,-432),Vector3.new(94,575,-540),Vector3.new(0,620,-650)}
local function mk(n,s,c,m,col,p,tr,co)local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=c;x.Material=m or Enum.Material.Rock;if col then x.Color=col end;x.Transparency=tr or 0;x.CanCollide=co~=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p or decor;return x end
local old=root:FindFirstChild("VisualPolishV16");if old then old:Destroy() end
local f=Instance.new("Folder");f.Name="VisualPolishV16";f.Parent=root
math.randomseed(160826)
-- Landmark 1: Sungai Batu crossing.
local river=route[3]
for i=-6,6 do Terrain:FillBall(river+Vector3.new(i*8,-5,math.sin(i*.8)*8),7,Enum.Material.Water) end
for i=-5,5 do local r=mk("RiverStone",Vector3.new(math.random(5,10),math.random(2,4),math.random(5,9)),CFrame.new(river+Vector3.new(i*9,1,math.sin(i*.8)*8))*CFrame.Angles(0,math.random(),0),Enum.Material.Rock,Color3.fromRGB(86,90,88),f);r.Shape=Enum.PartType.Ball end
-- Landmark 2: Lumina waterfall with pool and mist particles.
local fall=route[4]+Vector3.new(38,18,-12)
Terrain:FillBall(fall-Vector3.new(0,20,0),18,Enum.Material.Water)
local face=mk("WaterfallFace",Vector3.new(14,58,1.2),CFrame.new(fall),Enum.Material.Glass,Color3.fromRGB(170,211,224),f,.42,false)
local pe=Instance.new("ParticleEmitter");pe.Name="WaterMist";pe.Rate=18;pe.Lifetime=NumberRange.new(1.2,2.2);pe.Speed=NumberRange.new(2,5);pe.SpreadAngle=Vector2.new(35,35);pe.Size=NumberSequence.new(.8,2.8);pe.Transparency=NumberSequence.new(.35,1);pe.Parent=face
-- Landmark 3: Tebing Angin narrow rock wall.
local cliff=route[6]
for i=1,9 do Terrain:FillBall(cliff+Vector3.new(-42+i*9,math.random(-8,24),-28),math.random(14,24),Enum.Material.Rock) end
-- Landmark 4: Jembatan Awan, compact rope bridge over a carved gap.
local bridge=route[8]
for i=-5,5 do local plank=mk("BridgePlank",Vector3.new(9,.8,3.2),CFrame.new(bridge+Vector3.new(i*3,2,0)),Enum.Material.WoodPlanks,Color3.fromRGB(91,67,43),f);plank.CanCollide=true end
for _,z in ipairs({-5,5}) do mk("BridgeRail",Vector3.new(34,.45,.45),CFrame.new(bridge+Vector3.new(0,5,z)),Enum.Material.Wood,Color3.fromRGB(67,49,34),f,false,false) end
-- Cloud-sea layer below upper ridge, visual only.
local cloud=mk("CloudSea",Vector3.new(900,2,900),CFrame.new(40,548,-500),Enum.Material.Glass,Color3.fromRGB(215,226,231),f,.78,false);cloud.CanCollide=false
-- Summit photo zone: stone circle + understated ACC marker.
local summit=route[12]
for i=1,10 do local a=i/10*math.pi*2;local r=mk("SummitStone",Vector3.new(5,3,5),CFrame.new(summit+Vector3.new(math.cos(a)*20,0,math.sin(a)*20)),Enum.Material.Rock,Color3.fromRGB(92,94,92),f);r.Shape=Enum.PartType.Ball end
local sign=mk("SummitACC",Vector3.new(18,5,1),CFrame.new(summit+Vector3.new(0,5,-17)),Enum.Material.WoodPlanks,Color3.fromRGB(65,52,40),f)
local sg=Instance.new("SurfaceGui");sg.Face=Enum.NormalId.Front;sg.Parent=sign;local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text="SUMMIT ACC";t.TextScaled=true;t.Font=Enum.Font.GothamBold;t.TextColor3=Color3.fromRGB(235,230,215);t.Parent=sg
-- Small trail signs at decision points; no neon UI markers.
for _,idx in ipairs({2,4,7,9,11}) do local p=route[idx]+Vector3.new(9,4,8);mk("SignPost",Vector3.new(1,8,1),CFrame.new(p),Enum.Material.Wood,Color3.fromRGB(72,54,39),f);local board=mk("TrailSign",Vector3.new(8,2.5,.7),CFrame.new(p+Vector3.new(0,3,0)),Enum.Material.WoodPlanks,Color3.fromRGB(80,61,43),f);board.CanCollide=false end
-- Low vegetation clusters around lower route to break empty ground.
for i=1,110 do local seg=math.random(1,6);local a,b=route[seg],route[seg+1];local p=a:Lerp(b,math.random());local d=b-a;local side=Vector3.new(-d.Z,0,d.X).Unit;local q=p+side*math.random(-65,65)-Vector3.new(0,3,0);local bush=mk("Bush",Vector3.new(math.random(3,7),math.random(2,5),math.random(3,7)),CFrame.new(q),Enum.Material.Grass,Color3.fromRGB(math.random(37,52),math.random(70,91),math.random(43,59)),f,0,false);bush.Shape=Enum.PartType.Ball end
Lighting.GlobalShadows=true
root:SetAttribute("VisualPolish","1.6");root:SetAttribute("BuildVersion","1.6.0-landmark-immersion")
print("[ACC] Mountain visual polish v1.6 applied")