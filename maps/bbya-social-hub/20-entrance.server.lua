-- BBYA SOCIAL HUB — ENTRANCE BUILD v0.3
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local ROOT_NAME="BBYA_ZERO_BUILD"
local root=Workspace:FindFirstChild(ROOT_NAME) or Instance.new("Folder")
root.Name=ROOT_NAME; root.Parent=Workspace
local old=root:FindFirstChild("Entrance"); if old then old:Destroy() end
local model=Instance.new("Model"); model.Name="Entrance"; model.Parent=root
local C={black=Color3.fromRGB(8,7,11),charcoal=Color3.fromRGB(23,18,26),wall=Color3.fromRGB(35,27,36),wallWarm=Color3.fromRGB(47,35,40),floor=Color3.fromRGB(73,59,61),floor2=Color3.fromRGB(88,69,68),pink=Color3.fromRGB(255,42,157),magenta=Color3.fromRGB(236,28,146),warm=Color3.fromRGB(255,185,118),warmDim=Color3.fromRGB(209,127,75),glass=Color3.fromRGB(61,35,63),green=Color3.fromRGB(59,91,66)}
local function part(name,size,cf,color,material,transparency,parent)local p=Instance.new("Part");p.Name=name;p.Anchored=true;p.CanCollide=true;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=transparency or 0;p.Parent=parent or model;return p end
local function neon(name,size,cf,color,parent)local p=part(name,size,cf,color or C.pink,Enum.Material.Neon,0,parent);p.CanCollide=false;return p end
local function pointLight(parent,color,brightness,range)local l=Instance.new("PointLight");l.Color=color;l.Brightness=brightness;l.Range=range;l.Shadows=true;l.Parent=parent;return l end
local function textSign(parent,text,color,font)local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.AlwaysOnTop=true;gui.LightInfluence=0;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=70;gui.Parent=parent;local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Text=text;t.TextColor3=color;t.TextScaled=true;t.Font=font or Enum.Font.GothamBold;t.TextStrokeTransparency=.55;t.Parent=gui;return t end
local function beamPart(name,a,b,thickness)local mid=(a+b)/2;local d=(b-a).Magnitude;local p=neon(name,Vector3.new(thickness,thickness,d),CFrame.lookAt(mid,b),C.pink);pointLight(p,C.pink,.45,8);return p end
part("ArrivalForecourt",Vector3.new(78,1,28),CFrame.new(0,0,-58),C.floor2,Enum.Material.Slate)
part("EntranceFloor",Vector3.new(78,1,40),CFrame.new(0,0,-25),C.floor,Enum.Material.Slate)
for _,x in ipairs({-34,-17,0,17,34}) do neon("WarmFloorStrip",Vector3.new(.16,.08,34),CFrame.new(x,.56,-25),C.warmDim) end
neon("FrontThresholdPink",Vector3.new(70,.1,.24),CFrame.new(0,.57,-44),C.pink)
part("FacadeLeftWing",Vector3.new(24,26,10),CFrame.new(-31,13,-42),C.black);part("FacadeRightWing",Vector3.new(24,26,10),CFrame.new(31,13,-42),C.black);part("FacadeHeader",Vector3.new(48,13,10),CFrame.new(0,24.5,-42),C.black)
part("FacadeBackLeft",Vector3.new(2,18,28),CFrame.new(-42,9,-25),C.charcoal);part("FacadeBackRight",Vector3.new(2,18,28),CFrame.new(42,9,-25),C.charcoal)
neon("FacadePinkTop",Vector3.new(76,.3,.34),CFrame.new(0,18.1,-36.8),C.pink);neon("FacadePinkLeft",Vector3.new(.28,18,.34),CFrame.new(-36,9,-36.8),C.pink);neon("FacadePinkRight",Vector3.new(.28,18,.34),CFrame.new(36,9,-36.8),C.pink)
-- Massive branding: BBYA occupies almost full facade width, SOCIAL HUB separate underneath.
local bbyaPanel=part("BBYASignPanel",Vector3.new(72,12,1.2),CFrame.new(0,28,-36.55),C.charcoal);textSign(bbyaPanel,"BBYA",C.pink,Enum.Font.GothamBold)
local socialPanel=part("SocialHubSignPanel",Vector3.new(50,5,1.15),CFrame.new(0,20.1,-36.5),C.charcoal);textSign(socialPanel,"SOCIAL HUB",C.pink,Enum.Font.GothamMedium)
-- Crown is geometry, not a font glyph. Positioned immediately above BBYA.
local z=-35.85
local pts={Vector3.new(-10,36,z),Vector3.new(-8,43,z),Vector3.new(-3,39,z),Vector3.new(0,46,z),Vector3.new(3,39,z),Vector3.new(8,43,z),Vector3.new(10,36,z)}
for i=1,#pts-1 do beamPart("CrownStroke"..i,pts[i],pts[i+1],.55) end
beamPart("CrownBase",Vector3.new(-10,36,z),Vector3.new(10,36,z),.55)
beamPart("CrownBase2",Vector3.new(-8.5,34.5,z),Vector3.new(8.5,34.5,z),.45)
for i,p in ipairs({Vector3.new(-8,43,z),Vector3.new(0,46,z),Vector3.new(8,43,z)}) do local gem=neon("CrownTip"..i,Vector3.new(1.2,1.2,.65),CFrame.new(p),C.pink);pointLight(gem,C.pink,.7,9) end
local gL=part("GlassLeft",Vector3.new(18,15,.55),CFrame.new(-26,8.5,-35.4),C.glass,Enum.Material.Glass,.22);local gR=part("GlassRight",Vector3.new(18,15,.55),CFrame.new(26,8.5,-35.4),C.glass,Enum.Material.Glass,.22);gL.CanCollide=false;gR.CanCollide=false
part("InteriorCeiling",Vector3.new(82,1,40),CFrame.new(0,17,-16),C.black);part("InteriorRearWall",Vector3.new(82,18,2),CFrame.new(0,9,4),C.charcoal);part("InteriorLeftWall",Vector3.new(2,18,40),CFrame.new(-41,9,-16),C.wall);part("InteriorRightWall",Vector3.new(2,18,40),CFrame.new(41,9,-16),C.wall)
for _,x in ipairs({-30,-15,0,15,30}) do local lamp=neon("CeilingWarm",Vector3.new(8,.18,.35),CFrame.new(x,16.3,-22),C.warm);pointLight(lamp,C.warm,1.6,16) end
for _,zz in ipairs({-30,-18,-6}) do local lamp=neon("CeilingPink",Vector3.new(5,.16,.3),CFrame.new(0,16.2,zz),C.pink);pointLight(lamp,C.pink,1.1,12) end
part("ShowcaseWall",Vector3.new(31,11,1.4),CFrame.new(-22,6.5,-8),C.charcoal);local showGlass=part("ShowcaseGlass",Vector3.new(28,8,.35),CFrame.new(-22,7,-7.2),C.glass,Enum.Material.Glass,.18);showGlass.CanCollide=false;part("ShowcaseCounter",Vector3.new(27,2.6,5.5),CFrame.new(-22,2,-10),C.wallWarm,Enum.Material.Slate);neon("ShowcaseTopGlow",Vector3.new(28,.2,.28),CFrame.new(-22,11,-7),C.pink)
for _,x in ipairs({-31,-25,-19,-13}) do local s=neon("ShelfWarm",Vector3.new(3.5,.12,.2),CFrame.new(x,6.5,-6.95),C.warm);pointLight(s,C.warm,.5,6) end
local function sofa(name,pos,rot)local seat=part(name,Vector3.new(10,2.2,4.2),CFrame.new(pos)*CFrame.Angles(0,math.rad(rot or 0),0),C.wallWarm,Enum.Material.Fabric);part(name.."Back",Vector3.new(10,3.2,1.2),seat.CFrame*CFrame.new(0,2,-1.7),C.charcoal,Enum.Material.Fabric) end
sofa("SofaA",Vector3.new(7,1.7,-10),0);sofa("SofaB",Vector3.new(21,1.7,-2),180);sofa("SofaC",Vector3.new(-3,1.7,0),90)
for i,pos in ipairs({Vector3.new(7,1,-4),Vector3.new(21,1,-8),Vector3.new(-10,1,-2)}) do part("LoungeTable"..i,Vector3.new(5,1.1,3),CFrame.new(pos),Color3.fromRGB(54,42,44),Enum.Material.Slate);local glow=neon("TableGlow"..i,Vector3.new(4.3,.09,2.3),CFrame.new(pos+Vector3.new(0,.62,0)),C.warm);pointLight(glow,C.warm,.35,5) end
for i,x in ipairs({-35,35}) do part("Planter"..i,Vector3.new(8,2.6,8),CFrame.new(x,1.5,-27),C.charcoal,Enum.Material.Slate);for j=1,5 do local stem=part("PlantStem"..i.."_"..j,Vector3.new(.5,4+j*.35,.5),CFrame.new(x+(j-3)*.75,4,-27+(j%2==0 and 1 or -1)),C.green,Enum.Material.Grass);stem.CanCollide=false end;neon("PlanterGlow"..i,Vector3.new(7.2,.12,7.2),CFrame.new(x,2.85,-27),C.pink) end
for _,pos in ipairs({Vector3.new(-39,7,-29),Vector3.new(39,7,-29),Vector3.new(-39,7,-13),Vector3.new(39,7,-13),Vector3.new(-39,7,0),Vector3.new(39,7,0)}) do local f=neon("WarmSconce",Vector3.new(.35,2,.4),CFrame.new(pos),C.warm);pointLight(f,C.warm,1.5,14) end
local spawn=Instance.new("SpawnLocation");spawn.Name="EntranceSpawn";spawn.Anchored=true;spawn.CanCollide=true;spawn.Neutral=true;spawn.Size=Vector3.new(7,1,7);spawn.CFrame=CFrame.lookAt(Vector3.new(0,1,-67),Vector3.new(0,9,-22));spawn.Transparency=1;spawn.Parent=model
Lighting.ClockTime=20.6;Lighting.Brightness=2.6;Lighting.Ambient=Color3.fromRGB(52,38,55);Lighting.OutdoorAmbient=Color3.fromRGB(28,22,34);Lighting.EnvironmentDiffuseScale=.35;Lighting.EnvironmentSpecularScale=.45
for _,n in ipairs({"BBYAEntranceColor","BBYAPreviewColor","BBYABloom"}) do local x=Lighting:FindFirstChild(n);if x then x:Destroy() end end
local cc=Instance.new("ColorCorrectionEffect");cc.Name="BBYAEntranceColor";cc.Brightness=.05;cc.Contrast=.08;cc.Saturation=.03;cc.TintColor=Color3.fromRGB(255,235,244);cc.Parent=Lighting
local bloom=Instance.new("BloomEffect");bloom.Name="BBYABloom";bloom.Intensity=.45;bloom.Size=28;bloom.Threshold=1.2;bloom.Parent=Lighting
print("[BBYA] Entrance v0.3: massive BBYA sign + geometric neon crown")