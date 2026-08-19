local W=game:GetService("Workspace")
local root=W:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder",W);root.Name="BBYA_ZERO_BUILD"
local old=root:FindFirstChild("BasementBOH");if old then old:Destroy() end
local old2=root:FindFirstChild("Underground");if old2 then old2:Destroy() end
local m=Instance.new("Model",root);m.Name="Underground"
local C={dark=Color3.fromRGB(9,12,18),wall=Color3.fromRGB(20,27,38),floor=Color3.fromRGB(25,31,40),yellow=Color3.fromRGB(255,202,36),blue=Color3.fromRGB(0,142,255),metal=Color3.fromRGB(48,54,65),white=Color3.fromRGB(230,235,240)}
local function p(n,s,cf,c,mat,t)local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Color=c;x.Material=mat or Enum.Material.Concrete;x.Transparency=t or 0;x.Parent=m;return x end
local function neon(n,s,cf,c)local x=p(n,s,cf,c,Enum.Material.Neon);x.CanCollide=false;return x end
local function textPanel(n,text,cf,size,color,bg)local part=p(n,size,cf,bg or C.dark,Enum.Material.Metal);local sg=Instance.new("SurfaceGui",part);sg.Face=Enum.NormalId.Front;sg.AlwaysOnTop=false;local t=Instance.new("TextLabel",sg);t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextColor3=color;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;return part end
p("Floor",Vector3.new(120,1,90),CFrame.new(0,-15.5,0),C.floor);p("Ceiling",Vector3.new(120,1,90),CFrame.new(0,-.5,0),C.dark)
p("NorthWall",Vector3.new(120,16,2),CFrame.new(0,-8,44),C.wall);p("SouthWall",Vector3.new(120,16,2),CFrame.new(0,-8,-44),C.wall);p("WestWall",Vector3.new(2,16,90),CFrame.new(-59,-8,0),C.wall);p("EastWall",Vector3.new(2,16,90),CFrame.new(59,-8,0),C.wall)
for _,z in ipairs({-34,-17,0,17,34}) do neon("BlueCeiling"..z,Vector3.new(72,.18,.18),CFrame.new(0,-1.1,z),C.blue) end
for _,x in ipairs({-48,-32,-16,0,16,32,48}) do neon("YellowCross"..x,Vector3.new(.18,.18,54),CFrame.new(x,-1.15,0),C.yellow) end
neon("FloorBlueL",Vector3.new(.18,.12,70),CFrame.new(-26,-14.9,0),C.blue);neon("FloorBlueR",Vector3.new(.18,.12,70),CFrame.new(26,-14.9,0),C.blue);neon("FloorYellow",Vector3.new(52,.12,.18),CFrame.new(0,-14.88,-25),C.yellow)
textPanel("BBYAGraffiti","BBYA",CFrame.new(0,-7.5,42.85)*CFrame.Angles(0,math.rad(180),0),Vector3.new(46,9,.35),C.yellow,C.dark);textPanel("UndergroundTag","UNDERGROUND",CFrame.new(0,-12.3,42.62)*CFrame.Angles(0,math.rad(180),0),Vector3.new(30,2,.3),C.blue,C.dark)
p("DJStage",Vector3.new(42,2,15),CFrame.new(0,-13.8,31),C.metal,Enum.Material.Metal);neon("StageBlue",Vector3.new(40,.22,.22),CFrame.new(0,-12.7,23.55),C.blue);neon("StageYellow",Vector3.new(28,.18,.18),CFrame.new(0,-12.55,24),C.yellow);p("DJDesk",Vector3.new(28,3,5),CFrame.new(0,-10.9,32),C.dark,Enum.Material.Metal)
for _,x in ipairs({-8,8}) do p("DeckBody"..x,Vector3.new(8,.8,4),CFrame.new(x,-9.05,31),C.metal,Enum.Material.Metal);local jog=p("JogWheel"..x,Vector3.new(3,.35,3),CFrame.new(x,-8.48,31),C.dark,Enum.Material.Metal);jog.Shape=Enum.PartType.Cylinder;jog.CFrame=CFrame.new(x,-8.48,31)*CFrame.Angles(0,0,math.rad(90));neon("JogRing"..x,Vector3.new(3.2,.08,.25),CFrame.new(x,-8.25,29.35),x<0 and C.blue or C.yellow);for i=-1,1 do neon("Pad"..x..i,Vector3.new(.55,.08,.55),CFrame.new(x+i*.8,-8.22,32.2),i==0 and C.yellow or C.blue) end end
p("Mixer",Vector3.new(6,.75,4),CFrame.new(0,-9,31),Color3.fromRGB(34,38,47),Enum.Material.Metal);for i=-2,2 do p("Fader"..i,Vector3.new(.12,.15,1.4),CFrame.new(i*.8,-8.55,31),C.white,Enum.Material.Metal);neon("MixerLED"..i,Vector3.new(.18,.08,.45),CFrame.new(i*.8,-8.42,30),i%2==0 and C.blue or C.yellow) end
-- laptop sits on console in front of mixer
p("LaptopBase",Vector3.new(5,.22,2.4),CFrame.new(0,-8.42,27.8),C.metal,Enum.Material.Metal)
local laptopCF=CFrame.new(0,-7.05,28.85)*CFrame.Angles(math.rad(-8),0,0)
p("LaptopScreen",Vector3.new(5,2.8,.22),laptopCF,C.dark,Enum.Material.Metal);neon("LaptopDisplay",Vector3.new(4.5,2.3,.06),laptopCF*CFrame.new(0,0,-.14),C.blue)
for _,x in ipairs({-19,19}) do p("Sub"..x,Vector3.new(7,9,6),CFrame.new(x,-10.5,34),C.dark,Enum.Material.Metal);local woofer=p("Woofer"..x,Vector3.new(4,1,4),CFrame.new(x,-9.8,30.9),C.metal,Enum.Material.Metal);woofer.Shape=Enum.PartType.Cylinder;woofer.CFrame=CFrame.new(x,-9.8,30.9)*CFrame.Angles(math.rad(90),0,0) end
p("DanceFloor",Vector3.new(54,.2,35),CFrame.new(0,-14.85,2),Color3.fromRGB(17,22,30),Enum.Material.SmoothPlastic);for _,x in ipairs({-25,25}) do neon("DanceStrip"..x,Vector3.new(.25,.08,31),CFrame.new(x,-14.68,2),x<0 and C.blue or C.yellow) end
-- premium sofas along side walls, both facing inward toward dance floor
for _,side in ipairs({-1,1}) do
 local x=side*49
 local backX=side*55
 local accent=side<0 and C.blue or C.yellow
 p("SofaSeat"..side,Vector3.new(10,2.2,24),CFrame.new(x,-13.8,2),Color3.fromRGB(40,43,52),Enum.Material.SmoothPlastic)
 p("SofaBack"..side,Vector3.new(2.4,4.4,24),CFrame.new(backX,-11.7,2),C.dark,Enum.Material.SmoothPlastic)
 p("SofaArmFront"..side,Vector3.new(10,3,2),CFrame.new(x,-12.4,-10),C.dark,Enum.Material.SmoothPlastic)
 p("SofaArmRear"..side,Vector3.new(10,3,2),CFrame.new(x,-12.4,14),C.dark,Enum.Material.SmoothPlastic)
 neon("SofaGlow"..side,Vector3.new(.18,.15,20),CFrame.new(side*43.9,-12.55,2),accent)
 p("LoungeTable"..side,Vector3.new(6,1,8),CFrame.new(side*38,-13.7,2),C.metal,Enum.Material.Metal)
end
p("BarCounter",Vector3.new(38,3.4,5),CFrame.new(0,-12.9,-34),C.dark,Enum.Material.Metal);p("BarTop",Vector3.new(40,.45,6),CFrame.new(0,-10.95,-34),C.metal,Enum.Material.SmoothPlastic);neon("BarBlueEdge",Vector3.new(39,.16,.16),CFrame.new(0,-10.68,-31),C.blue);neon("BarYellowEdge",Vector3.new(30,.12,.12),CFrame.new(0,-10.48,-30.8),C.yellow)
textPanel("BarSign","BBYA BAR",CFrame.new(0,-6.5,-42.85),Vector3.new(24,4,.3),C.yellow,C.dark)
for i=-5,5 do local col=(i%2==0) and C.blue or C.yellow;neon("Bottle"..i,Vector3.new(.7,2,.7),CFrame.new(i*2.2,-9,-41.5),col) end
local npc=Instance.new("Model",m);npc.Name="UndergroundBartender"
local torso=p("BartenderTorso",Vector3.new(3,4,1.8),CFrame.new(0,-9,-38),Color3.fromRGB(20,22,28),Enum.Material.SmoothPlastic);torso.Parent=npc
local head=p("BartenderHead",Vector3.new(2.2,2.2,2.2),CFrame.new(0,-5.9,-38),Color3.fromRGB(210,170,135),Enum.Material.SmoothPlastic);head.Parent=npc
local apron=p("BartenderApron",Vector3.new(2.5,2.7,.2),CFrame.new(0,-9,-37.05),C.blue,Enum.Material.SmoothPlastic);apron.Parent=npc
print("[BBYA] Underground sofas corrected to face inward toward dance floor")