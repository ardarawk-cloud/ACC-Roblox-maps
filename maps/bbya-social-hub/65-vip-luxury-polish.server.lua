-- BBYA SOCIAL HUB — VIP LUXURY POLISH v1
-- Finishing layer for L2 VIP only: arrival ceremony, warm wayfinding, lounge detail and premium decor.
-- Does not touch Floor 1, DJ booth, DJ wall or monetization.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper=root:WaitForChild("UpperLevels",30)
if not upper then return end
local vip=upper:WaitForChild("L2_VIP_Level",30)
if not vip then return end
local premium=vip:WaitForChild("PremiumVIPPass",30)
if not premium then return end

local old=premium:FindFirstChild("VIPLuxuryPolish")
if old then old:Destroy() end
local out=Instance.new("Model")
out.Name="VIPLuxuryPolish"
out:SetAttribute("Pass","VIP_LUXURY_POLISH_V1")
out.Parent=premium

local C={
 black=Color3.fromRGB(8,7,10),ink=Color3.fromRGB(18,15,20),graphite=Color3.fromRGB(41,36,44),
 gold=Color3.fromRGB(224,176,91),warm=Color3.fromRGB(255,222,174),pink=Color3.fromRGB(231,55,145),
 brass=Color3.fromRGB(153,112,58),glass=Color3.fromRGB(105,118,126),green=Color3.fromRGB(52,86,64),
 marble=Color3.fromRGB(79,72,78),white=Color3.fromRGB(240,236,238),velvet=Color3.fromRGB(70,35,57),
}

local function part(name,size,cf,color,material,transparency,parent,collide)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.graphite;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=true
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.CastShadow=true;p.Parent=parent or out
 return p
end
local function neon(name,size,cf,color,parent,trans)
 local p=part(name,size,cf,color or C.warm,Enum.Material.Neon,trans or .04,parent,false);p.CastShadow=false;return p
end
local function model(name,parent)local m=Instance.new("Model");m.Name=name;m.Parent=parent or out;return m end
local function light(parent,color,brightness,range)
 local l=Instance.new("PointLight");l.Color=color;l.Brightness=brightness;l.Range=range;l.Shadows=false;l.Parent=parent;return l
end
local function cylinder(name,size,cf,color,material,parent)
 local p=part(name,size,cf,color,material or Enum.Material.Metal,0,parent,false);p.Shape=Enum.PartType.Cylinder;return p
end

-- ARRIVAL CEREMONY -------------------------------------------------------------
local arrival=model("ArrivalCeremony")
for i,x in ipairs({41.5,45.0,49.0,52.5}) do
 local side=(i<=2) and -1 or 1
 local z=-7.2+((i%2)*2.2)
 local stem=cylinder("Stanchion"..i,Vector3.new(2.2,.26,.26),CFrame.new(x,26.1,z)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,arrival)
 cylinder("Base"..i,Vector3.new(.18,1.45,1.45),CFrame.new(x,25.2,z)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,arrival)
 local cap=part("Cap"..i,Vector3.new(.45,.45,.45),CFrame.new(x,27.2,z),C.gold,Enum.Material.Metal,0,arrival,false);cap.Shape=Enum.PartType.Ball
 if i==1 or i==3 then
  local targetX=(i==1) and 45.0 or 52.5
  part("VelvetRope"..i,Vector3.new(math.abs(targetX-x),.20,.20),CFrame.new((x+targetX)/2,26.7,z),C.velvet,Enum.Material.Fabric,0,arrival,false)
 end
end

-- CENTRAL WARM GUIDE: low-profile floor accents from arrival toward overlook. --
local guide=model("WarmFloorGuide")
for i,z in ipairs({-10,-3,4,11,18,25,32}) do
 local len=(i%2==0) and 8 or 5
 neon("GuideL"..i,Vector3.new(len,.035,.08),CFrame.new(-6,25.16,z),C.gold,guide,.18)
 neon("GuideR"..i,Vector3.new(len,.035,.08),CFrame.new(6,25.16,z),C.warm,guide,.22)
end

-- WALL SCONCES: sparse warm pools, not nightclub strobes. ---------------------
local sconces=model("WarmWallSconces")
local sconceData={
 {-36,30,-18,0},{-36,30,-5,0},{-36,30,8,0},{36,30,-18,180},{36,30,-5,180},{36,30,8,180},
 {-51.6,30,8,90},{-51.6,30,32,90},{57.0,30,12,-90},{57.0,30,34,-90},
}
for i,d in ipairs(sconceData) do
 local cf=CFrame.new(d[1],d[2],d[3])*CFrame.Angles(0,math.rad(d[4]),0)
 local base=part("SconceBase"..i,Vector3.new(1.3,2.5,.24),cf,C.ink,Enum.Material.Metal,0,sconces,false)
 local glow=neon("SconceGlow"..i,Vector3.new(.18,1.45,.08),cf*CFrame.new(0,0,-.14),(i%4==0) and C.gold or C.warm,sconces,.06)
 light(glow,glow.Color,.32,9)
end

-- PREMIUM PLANT / SCULPTURE PAIRS ---------------------------------------------
local decor=model("SignatureDecor")
local function planter(name,x,z)
 local m=model(name,decor)
 cylinder("Pot",Vector3.new(2.4,2.8,2.8),CFrame.new(x,26.1,z)*CFrame.Angles(0,0,math.rad(90)),C.graphite,Enum.Material.Slate,m)
 local stem=part("Stem",Vector3.new(.28,3.6,.28),CFrame.new(x,28.4,z),Color3.fromRGB(45,78,55),Enum.Material.SmoothPlastic,0,m,false)
 for j=1,5 do
  local a=(j-1)*math.pi*2/5
  local leaf=part("Leaf"..j,Vector3.new(.55,2.2,1.1),CFrame.new(x+math.cos(a)*.7,29.7,z+math.sin(a)*.7)*CFrame.Angles(math.rad(18),-a,math.rad(12)),Color3.fromRGB(58,96,70),Enum.Material.SmoothPlastic,0,m,false)
 end
end
planter("ArrivalPlantL",34,-8)
planter("ArrivalPlantR",58,-8)
planter("LoungePlantL",-31,38)
planter("LoungePlantR",31,38)

-- COCKTAIL DETAIL TABLES -------------------------------------------------------
local cocktails=model("CocktailDetails")
local function cocktailTable(name,x,z)
 local m=model(name,cocktails)
 cylinder("Stem",Vector3.new(1.4,.30,.30),CFrame.new(x,25.8,z)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,m)
 local top=cylinder("Top",Vector3.new(.20,3.2,3.2),CFrame.new(x,26.55,z)*CFrame.Angles(0,0,math.rad(90)),C.marble,Enum.Material.Marble,m)
 local bottle=cylinder("Bottle",Vector3.new(1.25,.38,.38),CFrame.new(x,27.25,z)*CFrame.Angles(0,0,math.rad(90)),C.gold,Enum.Material.Glass,m);bottle.Transparency=.12
 for j,dx in ipairs({-.75,.75}) do
  local glass=cylinder("Glass"..j,Vector3.new(.52,.46,.46),CFrame.new(x+dx,27.0,z+.45)*CFrame.Angles(0,0,math.rad(90)),C.glass,Enum.Material.Glass,m);glass.Transparency=.25
 end
end
cocktailTable("SocialTableA",-19,20)
cocktailTable("SocialTableB",19,20)
cocktailTable("PrivateHallTable",47,7)

-- PRIVATE CORRIDOR ACCENTS -----------------------------------------------------
local corridor=model("PrivateCorridorFinish")
for i,z in ipairs({13,25,37}) do
 local plaque=part("PrivatePlaque"..i,Vector3.new(5.5,1.2,.14),CFrame.new(37.9,30.2,z),C.black,Enum.Material.Metal,0,corridor,false)
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Right;g.LightInfluence=.05;g.PixelsPerStud=50;g.Parent=plaque
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=string.format("PRIVATE  %02d",i);t.TextColor3=C.gold;t.Font=Enum.Font.GothamBold;t.TextScaled=true;t.Parent=g
 neon("PrivateLine"..i,Vector3.new(.08,.08,6.0),CFrame.new(37.72,28.8,z),C.gold,corridor,.16)
end

-- SMALL SIGNATURE FLOOR EMBLEM -------------------------------------------------
local emblem=model("VIPFloorEmblem")
local disk=cylinder("EmblemDisk",Vector3.new(.06,7.5,7.5),CFrame.new(0,25.16,3)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,emblem);disk.CanQuery=false
local ring=cylinder("EmblemRing",Vector3.new(.075,8.1,8.1),CFrame.new(0,25.17,3)*CFrame.Angles(0,0,math.rad(90)),C.gold,Enum.Material.Neon,emblem);ring.Transparency=.08;ring.CanQuery=false
local center=cylinder("EmblemCenter",Vector3.new(.08,6.9,6.9),CFrame.new(0,25.18,3)*CFrame.Angles(0,0,math.rad(90)),C.ink,Enum.Material.Slate,emblem);center.CanQuery=false

out:SetAttribute("Floor1Untouched",true)
out:SetAttribute("Style","Warm Luxury Lounge")
out:SetAttribute("FunctionalGeometryPreserved",true)
print("[BBYA] VIP Luxury Polish v1 online: arrival + guide + sconces + decor + private corridor finish")
