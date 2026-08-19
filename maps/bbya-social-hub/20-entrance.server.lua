-- BBYA SOCIAL HUB — ENTRANCE BUILD v0.7
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

-- Ground / arrival
part("ArrivalForecourt",Vector3.new(96,1,30),CFrame.new(0,0,-59),C.floor2,Enum.Material.Slate)
part("EntranceFloor",Vector3.new(90,1,46),CFrame.new(0,0,-22),C.floor,Enum.Material.Slate)
part("FrontStep",Vector3.new(72,.8,5),CFrame.new(0,.2,-45),C.charcoal,Enum.Material.Slate)
neon("FrontStepGlow",Vector3.new(70,.12,.25),CFrame.new(0,.65,-47.3),C.pink)

-- Facade: wider, layered, less like a flat black box
part("FacadeLeftWing",Vector3.new(26,26,12),CFrame.new(-35,13,-41),C.black)
part("FacadeRightWing",Vector3.new(26,26,12),CFrame.new(35,13,-41),C.black)
part("FacadeSignWall",Vector3.new(58,21,9),CFrame.new(0,25.5,-41.5),C.black)
part("FacadeLeftReturn",Vector3.new(8,18,22),CFrame.new(-44,9,-30),C.charcoal)
part("FacadeRightReturn",Vector3.new(8,18,22),CFrame.new(44,9,-30),C.charcoal)
part("Canopy",Vector3.new(58,1.4,10),CFrame.new(0,18.1,-37.5),C.charcoal,Enum.Material.Metal)
neon("CanopyFrontGlow",Vector3.new(56,.22,.28),CFrame.new(0,17.4,-42.3),C.pink)

-- Entrance portal columns + top beam
part("PortalLeft",Vector3.new(3,17,3),CFrame.new(-25.5,8.5,-37.1),C.charcoal,Enum.Material.Metal)
part("PortalRight",Vector3.new(3,17,3),CFrame.new(25.5,8.5,-37.1),C.charcoal,Enum.Material.Metal)
part("PortalTop",Vector3.new(54,3,3),CFrame.new(0,17,-37.1),C.charcoal,Enum.Material.Metal)
neon("EntryTop",Vector3.new(50,.3,.38),CFrame.new(0,15.8,-35.55),C.pink)
neon("EntryLeft",Vector3.new(.3,14,.38),CFrame.new(-24,8,-35.55),C.pink)
neon("EntryRight",Vector3.new(.3,14,.38),CFrame.new(24,8,-35.55),C.pink)

-- Branding
wallText("BBYATitle",Vector3.new(0,28.2,-37.05),Vector2.new(66,10.5),"BBYA",Enum.Font.GothamBold)
wallText("SocialHubTitle",Vector3.new(0,20.8,-37.03),Vector2.new(45,4.6),"SOCIAL HUB",Enum.Font.GothamMedium)
local z=-36.85
local pts={Vector3.new(-7.5,35.8,z),Vector3.new(-6.2,41.2,z),Vector3.new(-2.5,38.2,z),Vector3.new(0,43.5,z),Vector3.new(2.5,38.2,z),Vector3.new(6.2,41.2,z),Vector3.new(7.5,35.8,z)}
for i=1,#pts-1 do stroke("CrownStroke"..i,pts[i],pts[i+1],.5) end
stroke("CrownBase",Vector3.new(-7.5,35.8,z),Vector3.new(7.5,35.8,z),.5)
stroke("CrownBase2",Vector3.new(-6.4,34.6,z),Vector3.new(6.4,34.6,z),.38)

-- Glass frontage like reference
local gl=part("GlassLeft",Vector3.new(18,14,.45),CFrame.new(-34,8,-34.9),C.glass,Enum.Material.Glass,.18);gl.CanCollide=false
local gr=part("GlassRight",Vector3.new(18,14,.45),CFrame.new(34,8,-34.9),C.glass,Enum.Material.Glass,.18);gr.CanCollide=false
neon("GlassLeftTop",Vector3.new(18,.16,.22),CFrame.new(-34,15,-34.55),C.pink)
neon("GlassRightTop",Vector3.new(18,.16,.22),CFrame.new(34,15,-34.55),C.pink)

-- Interior shell with stronger depth
part("InteriorCeiling",Vector3.new(90,1,46),CFrame.new(0,17,-14),C.black)
part("InteriorRearWall",Vector3.new(90,18,2),CFrame.new(0,9,8),C.charcoal)
part("InteriorLeftWall",Vector3.new(2,18,46),CFrame.new(-44,9,-14),C.wall)
part("InteriorRightWall",Vector3.new(2,18,46),CFrame.new(44,9,-14),C.wall)
part("RearAccentWall",Vector3.new(28,10,.6),CFrame.new(-18,7,6.7),C.wallWarm)
neon("RearAccentGlow",Vector3.new(26,.22,.25),CFrame.new(-18,11.9,6.35),C.pink)

-- Warm ceiling lights and pink practicals
for _,x in ipairs({-32,-16,0,16,32}) do local p=neon("WarmCeiling",Vector3.new(9,.2,.4),CFrame.new(x,16.25,-20),C.warm);light(p,C.warm,2.6,22) end
for _,zz in ipairs({-31,-18,-5,5}) do local p=neon("PinkCeiling",Vector3.new(6,.18,.35),CFrame.new(0,16.2,zz),C.pink);light(p,C.pink,1.8,16) end

-- Showcase / bar visible through left side
part("ShowcaseFrame",Vector3.new(32,12,1.2),CFrame.new(-23,6.5,-5),C.charcoal)
local sg=part("ShowcaseGlass",Vector3.new(29,8.5,.3),CFrame.new(-23,7,-4.3),C.glass,Enum.Material.Glass,.15);sg.CanCollide=false
part("ShowcaseCounter",Vector3.new(28,2.6,5),CFrame.new(-23,2,-7),C.wallWarm,Enum.Material.Slate)
local st=neon("ShowcaseGlow",Vector3.new(29,.2,.3),CFrame.new(-23,11,-4),C.pink);light(st,C.pink,1.2,11)

-- Lounge furniture, more visible near entrance
local function sofa(n,x,zv,r)local s=part(n,Vector3.new(10,2.2,4.2),CFrame.new(x,1.7,zv)*CFrame.Angles(0,math.rad(r or 0),0),C.wallWarm,Enum.Material.Fabric);part(n.."Back",Vector3.new(10,3.2,1.2),s.CFrame*CFrame.new(0,2,-1.7),C.charcoal,Enum.Material.Fabric) end
sofa("LoungeA",8,-8,0);sofa("LoungeB",24,-1,180);sofa("LoungeC",-6,1,90)
for i,p in ipairs({Vector3.new(8,1,-2),Vector3.new(24,1,-7),Vector3.new(-13,1,0)}) do part("Table"..i,Vector3.new(5,1.1,3),CFrame.new(p),C.wallWarm,Enum.Material.Slate);local g=neon("TableGlow"..i,Vector3.new(4.4,.1,2.4),CFrame.new(p+Vector3.new(0,.62,0)),C.warm);light(g,C.warm,.7,7) end

-- Planters closer to reference framing
for i,x in ipairs({-36,36}) do part("Planter"..i,Vector3.new(8,2.6,8),CFrame.new(x,1.5,-27),C.charcoal,Enum.Material.Slate);for j=1,6 do local stem=part("Plant"..i.."_"..j,Vector3.new(.55,4+j*.35,.55),CFrame.new(x+(j-3.5)*.75,4,-27+((j%2)*1.2)),C.green,Enum.Material.Grass);stem.CanCollide=false end;neon("PlanterGlow"..i,Vector3.new(7.2,.12,7.2),CFrame.new(x,2.85,-27),C.pink) end

-- Extra facade warm sconces so structure reads at night
for _,x in ipairs({-42,-31,31,42}) do local p=neon("FacadeWarm",Vector3.new(.35,2.4,.4),CFrame.new(x,8,-35.5),C.warm);light(p,C.warm,2.4,17) end

local spawn=Instance.new("SpawnLocation");spawn.Name="EntranceSpawn";spawn.Anchored=true;spawn.Neutral=true;spawn.Size=Vector3.new(7,1,7);spawn.CFrame=CFrame.lookAt(Vector3.new(0,1,-66),Vector3.new(0,9,-20));spawn.Transparency=1;spawn.Parent=model

Lighting.ClockTime=20.1;Lighting.Brightness=3.4;Lighting.Ambient=Color3.fromRGB(78,56,76);Lighting.OutdoorAmbient=Color3.fromRGB(46,34,48);Lighting.EnvironmentDiffuseScale=.5;Lighting.EnvironmentSpecularScale=.55
for _,n in ipairs({"BBYAEntranceColor","BBYABloom"}) do local e=Lighting:FindFirstChild(n);if e then e:Destroy() end end
local cc=Instance.new("ColorCorrectionEffect");cc.Name="BBYAEntranceColor";cc.Brightness=.1;cc.Contrast=.03;cc.Saturation=.06;cc.TintColor=Color3.fromRGB(255,240,246);cc.Parent=Lighting
local bloom=Instance.new("BloomEffect");bloom.Name="BBYABloom";bloom.Intensity=.4;bloom.Size=24;bloom.Threshold=1.05;bloom.Parent=Lighting
print("[BBYA] Entrance v0.7 facade depth and reference fidelity pass")