local W=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local root=W:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder",W);root.Name="BBYA_ZERO_BUILD"
local old=root:FindFirstChild("UndergroundFurnishAndLight");if old then old:Destroy() end
local m=Instance.new("Model",root);m.Name="UndergroundFurnishAndLight"
local C={dark=Color3.fromRGB(11,14,20),metal=Color3.fromRGB(45,51,62),blue=Color3.fromRGB(0,142,255),yellow=Color3.fromRGB(255,202,36),white=Color3.fromRGB(235,238,242),black=Color3.fromRGB(18,18,22),brown=Color3.fromRGB(66,44,28)}
local function p(n,s,cf,c,mat,t,parent)local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.CanCollide=true;x.Size=s;x.CFrame=cf;x.Color=c;x.Material=mat or Enum.Material.SmoothPlastic;x.Transparency=t or 0;x.Parent=parent or m;return x end
local function neon(n,s,cf,c,parent)local x=p(n,s,cf,c,Enum.Material.Neon,0,parent);x.CanCollide=false;return x end
local function point(parent,c,b,r)local l=Instance.new("PointLight");l.Color=c;l.Brightness=b;l.Range=r;l.Shadows=true;l.Parent=parent;return l end
local function seatSet(prefix,x,z,rot,accent)
 local model=Instance.new("Model",m);model.Name=prefix
 local cf=CFrame.new(x,-13.5,z)*CFrame.Angles(0,math.rad(rot),0)
 p(prefix.."Base",Vector3.new(12,1.1,5),cf,C.black,Enum.Material.Fabric,0,model)
 p(prefix.."Back",Vector3.new(12,3.6,1),cf*CFrame.new(0,2.1,2),C.black,Enum.Material.Fabric,0,model)
 p(prefix.."ArmL",Vector3.new(1.1,2.4,5),cf*CFrame.new(-5.5,1.2,0),C.black,Enum.Material.Fabric,0,model)
 p(prefix.."ArmR",Vector3.new(1.1,2.4,5),cf*CFrame.new(5.5,1.2,0),C.black,Enum.Material.Fabric,0,model)
 neon(prefix.."Glow",Vector3.new(10,.12,.12),cf*CFrame.new(0,.15,-2.58),accent,model)
 p(prefix.."Table",Vector3.new(5,.5,3),cf*CFrame.new(0,.6,-5),C.metal,Enum.Material.Metal,0,model)
end
-- UNDERGROUND premium sofa lounges on left/right
for _,z in ipairs({-18,0,18}) do seatSet("SofaL"..z,-43,z,90,C.blue);seatSet("SofaR"..z,43,z,-90,C.yellow) end
-- UNDERGROUND rear bar in same rear direction as DJ, shifted to back-left corner
local bar=Instance.new("Model",m);bar.Name="UndergroundBar"
p("BarBack",Vector3.new(34,8,1),CFrame.new(-39,-9.5,38.5),C.dark,Enum.Material.Metal,0,bar)
p("BarCounter",Vector3.new(30,3,5),CFrame.new(-39,-12.4,33),C.metal,Enum.Material.Slate,0,bar)
neon("BarBlueEdge",Vector3.new(28,.16,.16),CFrame.new(-39,-10.75,30.45),C.blue,bar)
neon("BarYellowEdge",Vector3.new(20,.12,.12),CFrame.new(-39,-10.4,30.25),C.yellow,bar)
for i=-3,3 do
 local x=-39+i*4
 p("BottleShelf"..i,Vector3.new(2.2,3,.7),CFrame.new(x,-8.6,37.8),i%2==0 and C.blue or C.yellow,Enum.Material.Glass,.15,bar)
 p("BarStool"..i,Vector3.new(2.3,.5,2.3),CFrame.new(x,-13.5,29.5),C.black,Enum.Material.Fabric,0,bar)
 p("StoolLeg"..i,Vector3.new(.35,2.6,.35),CFrame.new(x,-14.8,29.5),C.metal,Enum.Material.Metal,0,bar)
end
-- bartender NPC, simple but proportioned humanoid-style
local npc=Instance.new("Model",m);npc.Name="UndergroundBartenderNPC"
p("Torso",Vector3.new(3.6,4.8,1.8),CFrame.new(-39,-8.8,35.5),C.black,Enum.Material.Fabric,0,npc)
local head=p("Head",Vector3.new(2.2,2.2,2.2),CFrame.new(-39,-5.3,35.5),Color3.fromRGB(206,158,122),Enum.Material.SmoothPlastic,0,npc);head.Shape=Enum.PartType.Ball
p("Hair",Vector3.new(2.35,.8,2.35),CFrame.new(-39,-4.55,35.5),Color3.fromRGB(26,22,22),Enum.Material.SmoothPlastic,0,npc)
p("ArmL",Vector3.new(1,4,1),CFrame.new(-41.2,-8.8,34.9)*CFrame.Angles(math.rad(18),0,math.rad(12)),Color3.fromRGB(206,158,122),Enum.Material.SmoothPlastic,0,npc)
p("ArmR",Vector3.new(1,4,1),CFrame.new(-36.8,-8.8,34.9)*CFrame.Angles(math.rad(18),0,math.rad(-12)),Color3.fromRGB(206,158,122),Enum.Material.SmoothPlastic,0,npc)
p("LegL",Vector3.new(1.3,4.2,1.4),CFrame.new(-40,-13.1,35.5),Color3.fromRGB(34,35,42),Enum.Material.Fabric,0,npc)
p("LegR",Vector3.new(1.3,4.2,1.4),CFrame.new(-38,-13.1,35.5),Color3.fromRGB(34,35,42),Enum.Material.Fabric,0,npc)
-- reinforce Underground dance floor with premium tile accents
for _,x in ipairs({-20,-10,0,10,20}) do neon("UGDanceX"..x,Vector3.new(.12,.07,28),CFrame.new(x,-14.62,1),x%20==0 and C.blue or C.yellow,m) end
for _,z in ipairs({-10,1,12}) do neon("UGDanceZ"..z,Vector3.new(48,.07,.12),CFrame.new(0,-14.61,z),z==1 and C.yellow or C.blue,m) end
-- MAIN CLUB brighter lighting: ambient + focused ceiling fixtures
Lighting.Brightness=2.35
Lighting.Ambient=Color3.fromRGB(72,66,82)
Lighting.OutdoorAmbient=Color3.fromRGB(35,33,43)
Lighting.ExposureCompensation=.25
local main=Instance.new("Model",m);main.Name="MainClubBrightening"
for _,x in ipairs({-24,-12,0,12,24}) do
 for _,z in ipairs({-2,10,22}) do
  local fixture=p("MainCeilingLight_"..x.."_"..z,Vector3.new(3,.3,3),CFrame.new(x,18,z),Color3.fromRGB(235,235,245),Enum.Material.Neon,0,main)
  point(fixture,Color3.fromRGB(235,225,255),2.2,28)
 end
end
for _,x in ipairs({-26,26}) do
 local wash=neon("MainSideWash"..x,Vector3.new(.25,7,.25),CFrame.new(x,8,15),x<0 and Color3.fromRGB(255,60,170) or Color3.fromRGB(0,180,255),main)
 point(wash,wash.Color,1.8,20)
end
print("[BBYA] Underground bar + bartender + premium sofas + dance floor, Main Club brightened")