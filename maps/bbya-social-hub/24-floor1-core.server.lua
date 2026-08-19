local W=game:GetService("Workspace")
local root=W:FindFirstChild("BBYA_ZERO_BUILD")
if not root then root=Instance.new("Folder");root.Name="BBYA_ZERO_BUILD";root.Parent=W end
local old=root:FindFirstChild("Floor1Core")
if old then old:Destroy() end
local m=Instance.new("Model");m.Name="Floor1Core";m.Parent=root

local C={
 dark=Color3.fromRGB(14,12,17),
 wall=Color3.fromRGB(28,23,31),
 floor=Color3.fromRGB(61,49,56),
 floor2=Color3.fromRGB(77,60,67),
 pink=Color3.fromRGB(255,42,157),
 blue=Color3.fromRGB(0,174,255),
 warm=Color3.fromRGB(255,188,122),
 glass=Color3.fromRGB(56,37,61),
 metal=Color3.fromRGB(44,39,49)
}
local function p(n,s,cf,col,mat,t,parent)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.CanCollide=true;x.Size=s;x.CFrame=cf;x.Color=col;x.Material=mat or Enum.Material.SmoothPlastic;x.Transparency=t or 0;x.Parent=parent or m;return x
end
local function neon(n,s,cf,col,parent)
 local x=p(n,s,cf,col or C.pink,Enum.Material.Neon,0,parent);x.CanCollide=false;return x
end
local function light(parent,col,b,r)
 local l=Instance.new("PointLight");l.Color=col;l.Brightness=b;l.Range=r;l.Shadows=true;l.Parent=parent;return l
end
local function zone(name)
 local z=Instance.new("Model");z.Name=name;z.Parent=m;return z
end
local function textBoard(parent,name,text,size,cf,col)
 local board=p(name,size,cf,C.dark,Enum.Material.Metal,0,parent)
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.AlwaysOnTop=true;gui.LightInfluence=0;gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize;gui.CanvasSize=Vector2.new(1000,240);gui.Parent=board
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Text=text;t.TextScaled=true;t.Font=Enum.Font.GothamBold;t.TextColor3=col or C.pink;t.Parent=gui
 return board
end

-- Shared L1 floor plate; entrance build remains independent/locked.
p("L1Floor",Vector3.new(120,1,90),CFrame.new(0,0.5,0),C.floor,Enum.Material.Slate)
p("NorthWall",Vector3.new(120,24,2),CFrame.new(0,12,44),C.dark)
p("WestWall",Vector3.new(2,24,90),CFrame.new(-59,12,0),C.dark)
p("EastWall",Vector3.new(2,24,90),CFrame.new(59,12,0),C.dark)

-- 02 RECEPTION / HOST
local reception=zone("02_Reception")
p("ReceptionBackdrop",Vector3.new(36,10,1.2),CFrame.new(0,5,-28),C.wall,Enum.Material.Metal,0,reception)
p("ReceptionDesk",Vector3.new(22,3.2,4),CFrame.new(0,2.1,-32),C.metal,Enum.Material.Slate,0,reception)
neon("ReceptionEdge",Vector3.new(20,.18,.25),CFrame.new(0,3.8,-34.05),C.pink,reception)
local rl=neon("ReceptionWarm",Vector3.new(10,.2,.3),CFrame.new(0,9.4,-27.35),C.warm,reception);light(rl,C.warm,1.8,14)
textBoard(reception,"ReceptionLabel","RECEPTION",Vector3.new(18,3,.4),CFrame.new(0,6.8,-27.3),C.pink)

-- 03 PHOTO / SELFIE AREA
local photo=zone("03_PhotoArea")
p("PhotoFloor",Vector3.new(28,.3,18),CFrame.new(-40,.7,-34),C.floor2,Enum.Material.Slate,0,photo)
p("PhotoBackdrop",Vector3.new(28,12,1),CFrame.new(-40,6,-25.6),C.wall,Enum.Material.Metal,0,photo)
for _,x in ipairs({-50,-40,-30}) do local n=neon("PhotoPink"..x,Vector3.new(5,.18,.22),CFrame.new(x,9.5,-25),C.pink,photo);light(n,C.pink,1.3,10) end
neon("PhotoFrameTop",Vector3.new(16,.25,.3),CFrame.new(-40,8,-24.95),C.pink,photo)
neon("PhotoFrameL",Vector3.new(.25,8,.3),CFrame.new(-48,4,-24.95),C.pink,photo)
neon("PhotoFrameR",Vector3.new(.25,8,.3),CFrame.new(-32,4,-24.95),C.pink,photo)
textBoard(photo,"PhotoLabel","PHOTO AREA",Vector3.new(18,3,.4),CFrame.new(-40,11,-25),C.pink)

-- 04 SALON & LOOK STUDIO
local salon=zone("04_SalonLookStudio")
p("SalonFloor",Vector3.new(28,.3,26),CFrame.new(-43,.7,-12),C.floor2,Enum.Material.Slate,0,salon)
p("SalonDivider",Vector3.new(1,12,26),CFrame.new(-29.5,6,-12),C.wall,Enum.Material.Metal,0,salon)
for i,z in ipairs({-20,-12,-4}) do
 p("SalonConsole"..i,Vector3.new(8,2.4,2),CFrame.new(-49,1.9,z),C.metal,Enum.Material.Slate,0,salon)
 local mirror=p("SalonMirror"..i,Vector3.new(8,6,.25),CFrame.new(-49,6,z+1.1),C.glass,Enum.Material.Glass,.18,salon);mirror.CanCollide=false
 local l=neon("SalonWarm"..i,Vector3.new(7,.15,.2),CFrame.new(-49,9,z+1),C.warm,salon);light(l,C.warm,1.4,9)
end
textBoard(salon,"SalonLabel","SALON & LOOK",Vector3.new(20,3,.4),CFrame.new(-42,10,-25),C.pink)

-- 05 MAIN DANCE FLOOR
local dance=zone("05_MainDanceFloor")
p("DanceFloor",Vector3.new(60,.35,40),CFrame.new(0,.72,0),Color3.fromRGB(36,31,42),Enum.Material.Slate,0,dance)
for _,x in ipairs({-24,-12,0,12,24}) do neon("DanceStripX"..x,Vector3.new(.16,.08,36),CFrame.new(x,.94,0),x==0 and C.blue or C.pink,dance) end
for _,z in ipairs({-14,0,14}) do neon("DanceStripZ"..z,Vector3.new(56,.08,.16),CFrame.new(0,.95,z),z==0 and C.blue or C.pink,dance) end

-- 06 DJ BOOTH
local dj=zone("06_DJBooth")
p("DJPlatform",Vector3.new(24,2.2,9),CFrame.new(0,1.6,24),C.metal,Enum.Material.Metal,0,dj)
p("DJDesk",Vector3.new(18,3,4),CFrame.new(0,3.2,21.5),C.dark,Enum.Material.Metal,0,dj)
neon("DJDeskGlow",Vector3.new(16,.22,.25),CFrame.new(0,4.8,19.45),C.pink,dj)
for _,x in ipairs({-6,0,6}) do local l=neon("DJLight"..x,Vector3.new(2,.16,.2),CFrame.new(x,7,23),C.blue,dj);light(l,C.blue,1.5,12) end
textBoard(dj,"DJLabel","DJ BOOTH",Vector3.new(18,3,.4),CFrame.new(0,8.2,28.8),C.pink)

-- 07 STAGE / LIGHTING SHOW
local stage=zone("07_StageLighting")
p("StageDeck",Vector3.new(52,2.6,9),CFrame.new(0,2,31),C.wall,Enum.Material.Metal,0,stage)
p("StageBack",Vector3.new(52,15,1.2),CFrame.new(0,8.5,35),C.dark,Enum.Material.Metal,0,stage)
for _,x in ipairs({-20,-10,0,10,20}) do
 local n=neon("StageBar"..x,Vector3.new(5,.25,.3),CFrame.new(x,12.5,34.3),(x%20==0) and C.pink or C.blue,stage);light(n,n.Color,2.1,16)
end
neon("StageTop",Vector3.new(46,.25,.3),CFrame.new(0,15.2,34.3),C.pink,stage)

-- 08 MAIN BAR
local bar=zone("08_MainBar")
p("BarFloor",Vector3.new(22,.3,28),CFrame.new(45,.7,2),C.floor2,Enum.Material.Slate,0,bar)
p("BarBack",Vector3.new(2,12,28),CFrame.new(56,6,2),C.wall,Enum.Material.Metal,0,bar)
p("BarCounter",Vector3.new(4,3,24),CFrame.new(38.5,2,2),C.metal,Enum.Material.Slate,0,bar)
neon("BarCounterGlow",Vector3.new(.18,.2,22),CFrame.new(36.45,3.6,2),C.pink,bar)
for _,z in ipairs({-8,0,8}) do
 p("BarShelf"..z,Vector3.new(.6,5,6),CFrame.new(54.8,5.5,z),C.dark,Enum.Material.Metal,0,bar)
 local l=neon("BarWarm"..z,Vector3.new(.25,4.5,.18),CFrame.new(54.4,5.5,z),C.warm,bar);light(l,C.warm,1.2,9)
end
textBoard(bar,"BarLabel","MAIN BAR",Vector3.new(18,3,.4),CFrame.new(45,10,-11.7)*CFrame.Angles(0,math.rad(90),0),C.pink)

-- Preserve central sightline from entrance to DJ/stage.
local sight=neon("CenterSightline",Vector3.new(.12,.05,64),CFrame.new(0,1.02,-5),C.blue,m);sight.Transparency=.55

print("[BBYA] Floor 1 core zones 02-08 built; entrance untouched")