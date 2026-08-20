-- BBYA SOCIAL HUB — VIP SKY LOUNGE v1
-- Replaces upper-level placeholder boxes with a usable premium social lounge.
-- Does not touch Floor 1 / DJ booth.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",20)
if not root then return end
local upper=root:WaitForChild("UpperLevels",20)
if not upper then warn("[BBYA VIP] UpperLevels missing");return end
local vip=upper:FindFirstChild("L2_VIP_Level")
if not vip then warn("[BBYA VIP] L2_VIP_Level missing");return end

local old=vip:FindFirstChild("PremiumVIPPass")
if old then old:Destroy() end

-- Remove only known placeholder solids/rails from the old blockout.
for _,obj in ipairs(vip:GetChildren()) do
 if obj.Name=="QueenSkybox" or obj.Name:match("^PrivateRoom") or obj.Name:match("^BalconyRail") or obj.Name=="VIPLoungeBack" then
  obj:Destroy()
 end
end

local out=Instance.new("Model")
out.Name="PremiumVIPPass"
out:SetAttribute("Pass","VIP_SKY_LOUNGE_V1")
out.Parent=vip

local C={
 black=Color3.fromRGB(7,7,10),ink=Color3.fromRGB(14,12,18),panel=Color3.fromRGB(27,23,31),
 graphite=Color3.fromRGB(44,40,49),metal=Color3.fromRGB(65,61,70),glass=Color3.fromRGB(88,104,118),
 velvet=Color3.fromRGB(72,40,64),velvet2=Color3.fromRGB(47,35,49),pink=Color3.fromRGB(255,42,157),
 cyan=Color3.fromRGB(0,190,225),gold=Color3.fromRGB(226,177,93),warm=Color3.fromRGB(255,203,146),
 white=Color3.fromRGB(240,237,242),green=Color3.fromRGB(70,205,132),
}

local function part(name,size,cf,color,material,transparency,parent,collide)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.panel;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=true;p.CastShadow=true
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or out
 return p
end
local function neon(name,size,cf,color,parent,transparency)
 local p=part(name,size,cf,color or C.pink,Enum.Material.Neon,transparency or 0,parent,false);p.CastShadow=false;return p
end
local function model(name,parent)local m=Instance.new("Model");m.Name=name;m.Parent=parent or out;return m end
local function light(parent,color,brightness,range)
 local l=Instance.new("PointLight");l.Color=color;l.Brightness=brightness;l.Range=range;l.Shadows=true;l.Parent=parent;return l
end
local function surfaceText(partObj,value,color)
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.AlwaysOnTop=false;g.LightInfluence=.15;g.PixelsPerStud=55;g.Parent=partObj
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=value;t.TextColor3=color or C.white;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.Parent=g
 return t
end

-- FLOOR FINISH / ENTRY ---------------------------------------------------------
local entry=model("VIPEntry")
part("EntryRunner",Vector3.new(18,.10,20),CFrame.new(46,25.06,0),Color3.fromRGB(31,26,33),Enum.Material.Slate,0,entry,true)
part("EntryArchTop",Vector3.new(18,1.0,1.0),CFrame.new(46,31.8,-7.5),C.graphite,Enum.Material.Metal,0,entry,false)
part("EntryArchL",Vector3.new(1.0,13,1.0),CFrame.new(37.5,25.8,-7.5),C.graphite,Enum.Material.Metal,0,entry,false)
part("EntryArchR",Vector3.new(1.0,13,1.0),CFrame.new(54.5,25.8,-7.5),C.graphite,Enum.Material.Metal,0,entry,false)
local entryGlow=neon("EntryGlow",Vector3.new(14,.10,.10),CFrame.new(46,31.25,-8.03),C.gold,entry,.06);light(entryGlow,C.gold,.7,15)
local sign=part("VIPSign",Vector3.new(10,2.4,.16),CFrame.new(46,29.6,-8.06),C.black,Enum.Material.SmoothPlastic,0,entry,false)
surfaceText(sign,"BBYA  VIP",C.white)

-- Real glass balcony railing around the inner atrium. -------------------------
local rails=model("GlassBalcony")
local function glassRail(name,size,cf,accent)
 local g=part(name,size,cf,C.glass,Enum.Material.Glass,.55,rails,false);g.Reflectance=.08
 neon(name.."Accent",Vector3.new(size.X>.5 and size.X or .08,.08,size.Z>.5 and size.Z or .08),cf*CFrame.new(0,size.Y/2+.08,0),accent or C.pink,rails,.12)
end
glassRail("NorthRail",Vector3.new(78,3.0,.18),CFrame.new(0,26.7,25),C.pink)
glassRail("SouthRail",Vector3.new(78,3.0,.18),CFrame.new(0,26.7,-26),C.cyan)
glassRail("WestRail",Vector3.new(.18,3.0,50),CFrame.new(-38,26.7,0),C.gold)
glassRail("EastRail",Vector3.new(.18,3.0,50),CFrame.new(38,26.7,0),C.pink)

-- NORTH SKY LOUNGE -------------------------------------------------------------
local lounge=model("NorthSkyLounge")
part("LoungeFinish",Vector3.new(62,.12,16),CFrame.new(0,25.06,34),Color3.fromRGB(32,27,34),Enum.Material.Slate,0,lounge,true)
part("FeatureWall",Vector3.new(54,8,.55),CFrame.new(0,29,43.4),C.ink,Enum.Material.Slate,0,lounge,false)
local feature=part("FeatureLogo",Vector3.new(20,4.5,.15),CFrame.new(0,30.0,43.05),C.black,Enum.Material.SmoothPlastic,0,lounge,false)
surfaceText(feature,"BBYA",C.white)
neon("LogoUnderline",Vector3.new(16,.08,.08),CFrame.new(0,27.55,42.94),C.pink,lounge,.04)

local function sofa(name,x,z,yaw,width)
 local m=model(name,lounge);local cf=CFrame.new(x,26.0,z)*CFrame.Angles(0,math.rad(yaw or 0),0);local w=width or 10
 part("Seat",Vector3.new(w,1.0,3.2),cf,C.velvet2,Enum.Material.Fabric,0,m,false)
 part("Back",Vector3.new(w,2.7,.8),cf*CFrame.new(0,1.35,1.35),C.velvet,Enum.Material.Fabric,0,m,false)
 part("ArmL",Vector3.new(.7,1.8,3.2),cf*CFrame.new(-w/2+.35,.4,0),C.velvet,Enum.Material.Fabric,0,m,false)
 part("ArmR",Vector3.new(.7,1.8,3.2),cf*CFrame.new(w/2-.35,.4,0),C.velvet,Enum.Material.Fabric,0,m,false)
end
local function tableTop(name,x,z)
 local m=model(name,lounge)
 part("Stem",Vector3.new(.35,1.3,.35),CFrame.new(x,25.7,z),C.metal,Enum.Material.Metal,0,m,false)
 local top=part("Top",Vector3.new(4.2,.18,2.8),CFrame.new(x,26.4,z),C.glass,Enum.Material.Glass,.20,m,false);top.Reflectance=.10
 neon("Edge",Vector3.new(3.7,.05,.05),CFrame.new(x,26.51,z-1.4),C.gold,m,.18)
end
for i,x in ipairs({-22,0,22}) do
 sofa("LoungeSofa"..i,x,38,180,12)
 tableTop("LoungeTable"..i,x,32.7)
 sofa("LoungeOpposite"..i,x,28.5,0,9)
end

-- VIP BAR ---------------------------------------------------------------------
local bar=model("VIPBar")
part("BarBody",Vector3.new(24,3.4,4.0),CFrame.new(-43,26.7,20),C.graphite,Enum.Material.Metal,0,bar,true)
part("BarTop",Vector3.new(24.8,.32,4.7),CFrame.new(-43,28.55,20),Color3.fromRGB(112,105,113),Enum.Material.Marble,0,bar,false)
neon("UnderBar",Vector3.new(21,.08,.08),CFrame.new(-43,27.85,17.62),C.gold,bar,.10)
part("BackBar",Vector3.new(1.0,9.0,24),CFrame.new(-53.1,29.0,20),C.ink,Enum.Material.Slate,0,bar,false)
for shelf,y in ipairs({27.0,29.4,31.8}) do
 part("Shelf"..shelf,Vector3.new(.75,.12,20),CFrame.new(-52.4,y,20),C.black,Enum.Material.Metal,0,bar,false)
 local gl=neon("ShelfGlow"..shelf,Vector3.new(.08,.06,18.5),CFrame.new(-51.98,y-.05,20),shelf==2 and C.pink or C.warm,bar,.15);light(gl,gl.Color,.28,8)
end
local barSign=part("BarSign",Vector3.new(.16,3.5,11),CFrame.new(-51.92,34.0,20),C.black,Enum.Material.SmoothPlastic,0,bar,false)
local bg=Instance.new("SurfaceGui");bg.Face=Enum.NormalId.Right;bg.AlwaysOnTop=false;bg.PixelsPerStud=45;bg.LightInfluence=.1;bg.Parent=barSign
local bt=Instance.new("TextLabel");bt.Size=UDim2.fromScale(1,1);bt.BackgroundTransparency=1;bt.Text="VIP BAR";bt.TextColor3=C.gold;bt.Font=Enum.Font.GothamBlack;bt.TextScaled=true;bt.Parent=bg

-- PRIVATE SOCIAL BOOTHS: open, walkable rooms instead of solid blocks. ---------
local private=model("PrivateSocialBooths")
local boothZ={17,29,39}
for i,z in ipairs(boothZ) do
 local b=model("PrivateBooth"..i,private)
 part("Floor",Vector3.new(19,.12,9),CFrame.new(48,25.06,z),Color3.fromRGB(34,29,36),Enum.Material.Slate,0,b,true)
 part("BackWall",Vector3.new(19,7,.45),CFrame.new(48,28.5,z+4.3),C.panel,Enum.Material.Fabric,0,b,false)
 part("SideL",Vector3.new(.45,7,8),CFrame.new(38.7,28.5,z),C.ink,Enum.Material.Slate,0,b,false)
 part("SideR",Vector3.new(.45,7,8),CFrame.new(57.3,28.5,z),C.ink,Enum.Material.Slate,0,b,false)
 sofa("BoothSofaDummy",0,0,0,1) -- create helper-owned model, moved below is not used
 local s1=model("Banquette",b)
 part("Seat",Vector3.new(14,1.0,2.6),CFrame.new(48,26.0,z+2.6),C.velvet2,Enum.Material.Fabric,0,s1,false)
 part("Back",Vector3.new(14,2.8,.7),CFrame.new(48,27.2,z+3.55),C.velvet,Enum.Material.Fabric,0,s1,false)
 local table=part("Table",Vector3.new(6,.22,3),CFrame.new(48,26.5,z-.4),C.glass,Enum.Material.Glass,.18,b,false);table.Reflectance=.10
 neon("BoothGlow",Vector3.new(13,.08,.08),CFrame.new(48,31.7,z+4.0),i==2 and C.cyan or C.pink,b,.10)
 local plate=part("Number",Vector3.new(4,1.1,.12),CFrame.new(48,30.7,z+4.04),C.black,Enum.Material.SmoothPlastic,0,b,false)
 surfaceText(plate,string.format("VIP %02d",i),i==2 and C.cyan or C.gold)
end
-- Remove helper dummy created by sofa() above if present.
local helper=lounge:FindFirstChild("BoothSofaDummy")
if helper then helper:Destroy() end

-- CEILING / LIGHTING -----------------------------------------------------------
local ceiling=model("VIPCeiling")
for i,x in ipairs({-24,-12,0,12,24}) do
 part("Beam"..i,Vector3.new(.42,.42,18),CFrame.new(x,35.6,34),C.black,Enum.Material.Metal,0,ceiling,false)
 local lamp=neon("Pendant"..i,Vector3.new(5,.10,.10),CFrame.new(x,34.6,34),i%2==0 and C.gold or C.pink,ceiling,.08)
 light(lamp,lamp.Color,.48,14)
end
for i,z in ipairs({-18,-6,6,18}) do
 local lamp=neon("EastGlow"..i,Vector3.new(12,.08,.08),CFrame.new(48,33.3,z),i%2==0 and C.cyan or C.pink,ceiling,.10)
 light(lamp,lamp.Color,.35,12)
end

-- Ambient identity markers -----------------------------------------------------
local status=part("StatusPanel",Vector3.new(8,1.6,.12),CFrame.new(46,30.0,8.45),C.black,Enum.Material.SmoothPlastic,0,out,false)
surfaceText(status,"●  VIP OPEN",C.green)

print("[BBYA] VIP Sky Lounge v1 online: glass balcony + lounge + VIP bar + walkable private booths")
