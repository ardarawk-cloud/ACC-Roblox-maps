-- BBYA SOCIAL HUB — ENTRANCE BUILD v0.6
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder");root.Name="BBYA_ZERO_BUILD";root.Parent=Workspace
local old=root:FindFirstChild("Entrance");if old then old:Destroy() end
local model=Instance.new("Model");model.Name="Entrance";model.Parent=root
local C={black=Color3.fromRGB(8,7,11),charcoal=Color3.fromRGB(23,18,26),wall=Color3.fromRGB(35,27,36),wallWarm=Color3.fromRGB(47,35,40),floor=Color3.fromRGB(73,59,61),floor2=Color3.fromRGB(88,69,68),pink=Color3.fromRGB(255,42,157),warm=Color3.fromRGB(255,185,118),warmDim=Color3.fromRGB(209,127,75),glass=Color3.fromRGB(61,35,63),green=Color3.fromRGB(59,91,66)}
local function part(n,s,cf,c,m,t)local p=Instance.new("Part");p.Name=n;p.Anchored=true;p.CanCollide=true;p.Size=s;p.CFrame=cf;p.Color=c;p.Material=m or Enum.Material.SmoothPlastic;p.Transparency=t or 0;p.Parent=model;return p end
local function neon(n,s,cf,c)local p=part(n,s,cf,c or C.pink,Enum.Material.Neon);p.CanCollide=false;return p end
local function light(p,c,b,r)local l=Instance.new("PointLight");l.Color=c;l.Brightness=b;l.Range=r;l.Shadows=true;l.Parent=p end
local function wallText(name,pos,size,text,font)
 local panel=part(name.."Panel",Vector3.new(size.X,size.Y,.3),CFrame.new(pos),Color3.fromRGB(10,8,13),Enum.Material.SmoothPlastic,0)
 local gui=Instance.new("SurfaceGui");gui.Name=name;gui.Face=Enum.NormalId.Front;gui.AlwaysOnTop=false;gui.LightInfluence=0;gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize;gui.CanvasSize=Vector2.new(math.floor(size.X*40),math.floor(size.Y*40));gui.Parent=panel
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Text=text;t.TextColor3=C.pink;t.TextScaled=true;t.Font=font;t.TextStrokeColor3=C.pink;t.TextStrokeTransparency=.28;t.Parent=gui
 return panel
end
local function stroke(n,a,b,w)local mid=(a+b)/2;local p=neon(n,Vector3.new(w,w,(b-a).Magnitude),CFrame.lookAt(mid,b),C.pink);light(p,C.pink,.5,9) end
part("ArrivalForecourt",Vector3.new(90,1,28),CFrame.new(0,0,-58),C.floor2,Enum.Material.Slate)
part("EntranceFloor",Vector3.new(86,1,42),CFrame.new(0,0,-24),C.floor,Enum.Material.Slate)
part("FacadeLeftWing",Vector3.new(24,25,10),CFrame.new(-34,12.5,-42),C.black)
part("FacadeRightWing",Vector3.new(24,25,10),CFrame.new(34,12.5,-42),C.black)
part("FacadeSignWall",Vector3.new(56,20,8),CFrame.new(0,25,-42),C.black)
part("FacadeBackLeft",Vector3.new(2,18,30),CFrame.new(-45,9,-24),C.charcoal);part("FacadeBackRight",Vector3.new(2,18,30),CFrame.new(45,9,-24),C.charcoal)
neon("EntryTop",Vector3.new(48,.28,.35),CFrame.new(0,17.5,-36.8),C.pink);neon("EntryLeft",Vector3.new(.28,17,.35),CFrame.new(-24,9,-36.8),C.pink);neon("EntryRight",Vector3.new(.28,17,.35),CFrame.new(24,9,-36.8),C.pink)
-- Fixed wall-mounted signage. Front face naturally points toward SOUTH (-Z), the spawn side.
wallText("BBYATitle",Vector3.new(0,28,-37.72),Vector2.new(66,10.5),"BBYA",Enum.Font.GothamBold)
wallText("SocialHubTitle",Vector3.new(0,20.7,-37.70),Vector2.new(45,4.6),"SOCIAL HUB",Enum.Font.GothamMedium)
-- Crown fixed to facade, slightly in front of the text plane so it cannot disappear behind the wall.
local z=-37.50
local pts={Vector3.new(-7.5,35.8,z),Vector3.new(-6.2,41.2,z),Vector3.new(-2.5,38.2,z),Vector3.new(0,43.5,z),Vector3.new(2.5,38.2,z),Vector3.new(6.2,41.2,z),Vector3.new(7.5,35.8,z)}
for i=1,#pts-1 do stroke("CrownStroke"..i,pts[i],pts[i+1],.5) end
stroke("CrownBase",Vector3.new(-7.5,35.8,z),Vector3.new(7.5,35.8,z),.5)
stroke("CrownBase2",Vector3.new(-6.4,34.6,z),Vector3.new(6.4,34.6,z),.38)
for i,p in ipairs({Vector3.new(-6.2,41.2,z),Vector3.new(0,43.5,z),Vector3.new(6.2,41.2,z)}) do local tip=neon("CrownTip"..i,Vector3.new(.9,.9,.55),CFrame.new(p),C.pink);light(tip,C.pink,.7,9) end
local gl=part("GlassLeft",Vector3.new(18,15,.4),CFrame.new(-34,8.5,-36.5),C.glass,Enum.Material.Glass,.28);gl.CanCollide=false
local gr=part("GlassRight",Vector3.new(18,15,.4),CFrame.new(34,8.5,-36.5),C.glass,Enum.Material.Glass,.28);gr.CanCollide=false
part("InteriorCeiling",Vector3.new(88,1,42),CFrame.new(0,17,-15),C.black);part("InteriorRearWall",Vector3.new(88,18,2),CFrame.new(0,9,5),C.charcoal);part("InteriorLeftWall",Vector3.new(2,18,42),CFrame.new(-44,9,-15),C.wall);part("InteriorRightWall",Vector3.new(2,18,42),CFrame.new(44,9,-15),C.wall)
for _,x in ipairs({-32,-16,0,16,32}) do local p=neon("WarmCeiling",Vector3.new(9,.2,.4),CFrame.new(x,16.3,-20),C.warm);light(p,C.warm,2.2,20) end
for _,zz in ipairs({-31,-18,-5}) do local p=neon("PinkCeiling",Vector3.new(6,.18,.35),CFrame.new(0,16.2,zz),C.pink);light(p,C.pink,1.5,15) end
part("ShowcaseFrame",Vector3.new(32,12,1.2),CFrame.new(-23,6.5,-7),C.charcoal);local sg=part("ShowcaseGlass",Vector3.new(29,8.5,.3),CFrame.new(-23,7,-6.3),C.glass,Enum.Material.Glass,.2);sg.CanCollide=false
part("ShowcaseCounter",Vector3.new(28,2.6,5),CFrame.new(-23,2,-9),C.wallWarm,Enum.Material.Slate);local st=neon("ShowcaseGlow",Vector3.new(29,.2,.3),CFrame.new(-23,11,-6),C.pink);light(st,C.pink,1,10)
local function sofa(n,x,zv,r)local s=part(n,Vector3.new(10,2.2,4.2),CFrame.new(x,1.7,zv)*CFrame.Angles(0,math.rad(r or 0),0),C.wallWarm,Enum.Material.Fabric);part(n.."Back",Vector3.new(10,3.2,1.2),s.CFrame*CFrame.new(0,2,-1.7),C.charcoal,Enum.Material.Fabric) end
sofa("LoungeA",8,-9,0);sofa("LoungeB",23,-3,180);sofa("LoungeC",-5,0,90)
for i,p in ipairs({Vector3.new(8,1,-3),Vector3.new(23,1,-9),Vector3.new(-12,1,-1)}) do part("Table"..i,Vector3.new(5,1.1,3),CFrame.new(p),C.wallWarm,Enum.Material.Slate);local g=neon("TableGlow"..i,Vector3.new(4.4,.1,2.4),CFrame.new(p+Vector3.new(0,.62,0)),C.warm);light(g,C.warm,.5,6) end
for i,x in ipairs({-35,35}) do part("Planter"..i,Vector3.new(8,2.5,8),CFrame.new(x,1.5,-28),C.charcoal,Enum.Material.Slate);for j=1,5 do local stem=part("Plant"..i.."_"..j,Vector3.new(.55,4+j*.35,.55),CFrame.new(x+(j-3)*.8,4,-28+(j%2)),C.green,Enum.Material.Grass);stem.CanCollide=false end;neon("PlanterGlow"..i,Vector3.new(7.2,.12,7.2),CFrame.new(x,2.8,-28),C.pink) end
for _,x in ipairs({-41,-30,30,41}) do local p=neon("FacadeWarm",Vector3.new(.35,2.2,.4),CFrame.new(x,8,-36.2),C.warm);light(p,C.warm,2,15) end
local spawn=Instance.new("SpawnLocation");spawn.Name="EntranceSpawn";spawn.Anchored=true;spawn.Neutral=true;spawn.Size=Vector3.new(7,1,7);spawn.CFrame=CFrame.lookAt(Vector3.new(0,1,-66),Vector3.new(0,10,-20));spawn.Transparency=1;spawn.Parent=model
Lighting.ClockTime=20.3;Lighting.Brightness=3;Lighting.Ambient=Color3.fromRGB(68,48,68);Lighting.OutdoorAmbient=Color3.fromRGB(38,29,43);Lighting.EnvironmentDiffuseScale=.45;Lighting.EnvironmentSpecularScale=.5
for _,n in ipairs({"BBYAEntranceColor","BBYABloom"}) do local e=Lighting:FindFirstChild(n);if e then e:Destroy() end end
local cc=Instance.new("ColorCorrectionEffect");cc.Name="BBYAEntranceColor";cc.Brightness=.08;cc.Contrast=.04;cc.Saturation=.05;cc.TintColor=Color3.fromRGB(255,239,245);cc.Parent=Lighting
local bloom=Instance.new("BloomEffect");bloom.Name="BBYABloom";bloom.Intensity=.38;bloom.Size=24;bloom.Threshold=1.15;bloom.Parent=Lighting
print("[BBYA] Entrance v0.6 fixed facade signage + restored crown")