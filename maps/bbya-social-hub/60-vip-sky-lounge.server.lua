-- BBYA SOCIAL HUB — VIP SKY LOUNGE v2
-- Functional premium upper-floor social lounge.
-- Single owner for VIP dressing; does not touch Floor 1 / DJ booth.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",20)
if not root then return end
local upper=root:WaitForChild("UpperLevels",20)
if not upper then warn("[BBYA VIP] UpperLevels missing");return end
local vip=upper:FindFirstChild("L2_VIP_Level")
if not vip then warn("[BBYA VIP] L2_VIP_Level missing");return end

local old=vip:FindFirstChild("PremiumVIPPass")
if old then old:Destroy() end

-- Remove only obsolete placeholder geometry owned by the old upper-level pass.
for _,obj in ipairs(vip:GetChildren()) do
 if obj.Name=="QueenSkybox" or obj.Name:match("^PrivateRoom") or obj.Name:match("^BalconyRail") or obj.Name=="VIPLoungeBack" then
  obj:Destroy()
 end
end

local out=Instance.new("Model")
out.Name="PremiumVIPPass"
out:SetAttribute("Pass","VIP_SKY_LOUNGE_V2")
out:SetAttribute("Version",2)
out.Parent=vip

local C={
 black=Color3.fromRGB(6,6,9),ink=Color3.fromRGB(13,11,17),panel=Color3.fromRGB(25,21,29),
 graphite=Color3.fromRGB(42,38,47),metal=Color3.fromRGB(68,63,73),glass=Color3.fromRGB(91,111,126),
 velvet=Color3.fromRGB(77,37,65),velvet2=Color3.fromRGB(48,31,48),pink=Color3.fromRGB(255,42,157),
 cyan=Color3.fromRGB(0,200,232),gold=Color3.fromRGB(229,181,94),warm=Color3.fromRGB(255,207,150),
 white=Color3.fromRGB(244,241,246),green=Color3.fromRGB(72,210,137),slate=Color3.fromRGB(33,28,36),
}

local function part(name,size,cf,color,material,transparency,parent,collide)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.panel;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=true;p.CastShadow=true
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or out
 return p
end
local function seatPart(name,size,cf,color,parent)
 local s=Instance.new("Seat")
 s.Name=name;s.Size=size;s.CFrame=cf;s.Color=color or C.velvet2;s.Material=Enum.Material.Fabric
 s.Anchored=true;s.CanCollide=true;s.CanTouch=true;s.CanQuery=true;s.CastShadow=true
 s.TopSurface=Enum.SurfaceType.Smooth;s.BottomSurface=Enum.SurfaceType.Smooth;s.Parent=parent or out
 return s
end
local function neon(name,size,cf,color,parent,transparency)
 local p=part(name,size,cf,color or C.pink,Enum.Material.Neon,transparency or 0,parent,false);p.CastShadow=false;return p
end
local function model(name,parent)local m=Instance.new("Model");m.Name=name;m.Parent=parent or out;return m end
local function light(parent,color,brightness,range)
 local l=Instance.new("PointLight");l.Color=color;l.Brightness=brightness;l.Range=range;l.Shadows=true;l.Parent=parent;return l
end
local function surfaceText(partObj,value,color,face)
 local g=Instance.new("SurfaceGui");g.Face=face or Enum.NormalId.Front;g.AlwaysOnTop=false;g.LightInfluence=.08;g.PixelsPerStud=55;g.Parent=partObj
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=value;t.TextColor3=color or C.white;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.Parent=g
 return t
end
local function prompt(parent,action,objectText,distance)
 local p=Instance.new("ProximityPrompt");p.ActionText=action;p.ObjectText=objectText;p.HoldDuration=0;p.MaxActivationDistance=distance or 9;p.RequiresLineOfSight=false;p.Parent=parent;return p
end

-- ENTRY + ELEVATOR ARRIVAL -----------------------------------------------------
local entry=model("VIPEntry")
part("EntryRunner",Vector3.new(18,.10,22),CFrame.new(46,25.06,-1),C.slate,Enum.Material.Slate,0,entry,true)
part("EntryArchTop",Vector3.new(18,1.0,1.0),CFrame.new(46,31.8,-8),C.graphite,Enum.Material.Metal,0,entry,false)
part("EntryArchL",Vector3.new(1.0,13,1.0),CFrame.new(37.5,25.8,-8),C.graphite,Enum.Material.Metal,0,entry,false)
part("EntryArchR",Vector3.new(1.0,13,1.0),CFrame.new(54.5,25.8,-8),C.graphite,Enum.Material.Metal,0,entry,false)
local entryGlow=neon("EntryGlow",Vector3.new(14,.10,.10),CFrame.new(46,31.25,-8.53),C.gold,entry,.06);light(entryGlow,C.gold,.75,15)
local sign=part("VIPSign",Vector3.new(10,2.4,.16),CFrame.new(46,29.6,-8.56),C.black,Enum.Material.SmoothPlastic,0,entry,false)
surfaceText(sign,"BBYA  VIP",C.white)

local elevator=model("VIPArrivalLobby")
part("LiftPortal",Vector3.new(11,9,.6),CFrame.new(52,29,-20),C.ink,Enum.Material.Metal,0,elevator,false)
part("LiftDoorL",Vector3.new(4.4,7.1,.22),CFrame.new(49.7,28.4,-19.65),C.metal,Enum.Material.Metal,0,elevator,false)
part("LiftDoorR",Vector3.new(4.4,7.1,.22),CFrame.new(54.3,28.4,-19.65),C.metal,Enum.Material.Metal,0,elevator,false)
neon("LiftSeam",Vector3.new(.12,6.3,.12),CFrame.new(52,28.4,-19.50),C.gold,elevator,.04)
local liftSign=part("LiftSign",Vector3.new(8,1.25,.12),CFrame.new(52,33.0,-19.45),C.black,Enum.Material.SmoothPlastic,0,elevator,false)
surfaceText(liftSign,"VIP ARRIVAL",C.gold)
part("LobbyRunner",Vector3.new(15,.10,12),CFrame.new(47,25.06,-14),Color3.fromRGB(37,30,38),Enum.Material.Slate,0,elevator,true)
for i,x in ipairs({41.5,46,50.5}) do neon("ArrivalFloorLine"..i,Vector3.new(3.2,.05,.08),CFrame.new(x,25.14,-10),i==2 and C.gold or C.pink,elevator,.12) end

-- GLASS BALCONY ---------------------------------------------------------------
local rails=model("GlassBalcony")
local function glassRail(name,size,cf,accent)
 local g=part(name,size,cf,C.glass,Enum.Material.Glass,.58,rails,false);g.Reflectance=.08
 local accentSize=Vector3.new(size.X>.5 and size.X or .08,.08,size.Z>.5 and size.Z or .08)
 neon(name.."Accent",accentSize,cf*CFrame.new(0,size.Y/2+.08,0),accent or C.pink,rails,.12)
end
glassRail("NorthRail",Vector3.new(78,3.0,.18),CFrame.new(0,26.7,25),C.pink)
glassRail("SouthRail",Vector3.new(78,3.0,.18),CFrame.new(0,26.7,-26),C.cyan)
glassRail("WestRail",Vector3.new(.18,3.0,50),CFrame.new(-38,26.7,0),C.gold)
glassRail("EastRail",Vector3.new(.18,3.0,50),CFrame.new(38,26.7,0),C.pink)

-- NORTH SKY LOUNGE -------------------------------------------------------------
local lounge=model("NorthSkyLounge")
part("LoungeFinish",Vector3.new(62,.12,18),CFrame.new(0,25.06,34),C.slate,Enum.Material.Slate,0,lounge,true)
part("FeatureWall",Vector3.new(54,8,.55),CFrame.new(0,29,43.4),C.ink,Enum.Material.Slate,0,lounge,false)
local feature=part("FeatureLogo",Vector3.new(20,4.5,.15),CFrame.new(0,30.0,43.05),C.black,Enum.Material.SmoothPlastic,0,lounge,false)
surfaceText(feature,"BBYA",C.white)
neon("LogoUnderline",Vector3.new(16,.08,.08),CFrame.new(0,27.55,42.94),C.pink,lounge,.04)

local function sofa(name,x,z,yaw,width)
 local m=model(name,lounge);local cf=CFrame.new(x,26.0,z)*CFrame.Angles(0,math.rad(yaw or 0),0);local w=width or 10
 -- Decorative shell plus two actual Roblox Seats, hidden inside the upholstery visually.
 part("Base",Vector3.new(w,1.05,3.2),cf,C.velvet2,Enum.Material.Fabric,0,m,true)
 part("Back",Vector3.new(w,2.7,.8),cf*CFrame.new(0,1.35,1.35),C.velvet,Enum.Material.Fabric,0,m,false)
 part("ArmL",Vector3.new(.7,1.8,3.2),cf*CFrame.new(-w/2+.35,.4,0),C.velvet,Enum.Material.Fabric,0,m,false)
 part("ArmR",Vector3.new(.7,1.8,3.2),cf*CFrame.new(w/2-.35,.4,0),C.velvet,Enum.Material.Fabric,0,m,false)
 local span=w*.44
 seatPart("SeatL",Vector3.new(math.max(2.2,w*.34),.35,2.35),cf*CFrame.new(-span/2,.72,-.15),C.velvet2,m)
 seatPart("SeatR",Vector3.new(math.max(2.2,w*.34),.35,2.35),cf*CFrame.new(span/2,.72,-.15),C.velvet2,m)
end
local function tableTop(name,x,z,parent)
 local m=model(name,parent or lounge)
 part("Stem",Vector3.new(.35,1.3,.35),CFrame.new(x,25.7,z),C.metal,Enum.Material.Metal,0,m,false)
 local top=part("Top",Vector3.new(4.2,.18,2.8),CFrame.new(x,26.4,z),C.glass,Enum.Material.Glass,.20,m,false);top.Reflectance=.10
 neon("Edge",Vector3.new(3.7,.05,.05),CFrame.new(x,26.51,z-1.4),C.gold,m,.18)
end
for i,x in ipairs({-22,0,22}) do
 sofa("LoungeSofa"..i,x,38,180,12)
 tableTop("LoungeTable"..i,x,32.7)
end

-- CENTRAL OVERLOOK: visual focal point + social seating ------------------------
local overlook=model("SkyOverlook")
part("OverlookDeck",Vector3.new(30,.14,13),CFrame.new(0,25.08,18),Color3.fromRGB(29,25,33),Enum.Material.Slate,0,overlook,true)
local rail=part("OverlookGlass",Vector3.new(27,2.5,.16),CFrame.new(0,26.45,12),C.glass,Enum.Material.Glass,.60,overlook,false);rail.Reflectance=.08
neon("OverlookEdge",Vector3.new(26,.08,.08),CFrame.new(0,27.72,11.92),C.cyan,overlook,.10)
local title=part("OverlookMark",Vector3.new(10,1.4,.12),CFrame.new(0,29.2,24.45),C.black,Enum.Material.SmoothPlastic,0,overlook,false)
surfaceText(title,"SKY SOCIAL",C.gold)
for i,x in ipairs({-9,9}) do
 local pod=model("OverlookPod"..i,overlook)
 seatPart("Seat",Vector3.new(5,.45,2.6),CFrame.new(x,25.85,19.2),C.velvet2,pod)
 part("Back",Vector3.new(5,2.2,.65),CFrame.new(x,26.85,20.15),C.velvet,Enum.Material.Fabric,0,pod,false)
 tableTop("PodTable",x,15.5,pod)
end

-- VIP BAR + USABLE STOOLS ------------------------------------------------------
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
surfaceText(barSign,"VIP BAR",C.gold,Enum.NormalId.Right)
for i,z in ipairs({14.5,19,23.5,28}) do
 local stool=model("BarStool"..i,bar)
 part("Stem",Vector3.new(.35,1.6,.35),CFrame.new(-38.5,25.85,z),C.metal,Enum.Material.Metal,0,stool,false)
 seatPart("Seat",Vector3.new(2.4,.42,2.4),CFrame.new(-38.5,26.75,z)*CFrame.Angles(0,math.rad(90),0),C.velvet2,stool)
end

-- PRIVATE SOCIAL BOOTHS --------------------------------------------------------
local private=model("PrivateSocialBooths")
local boothZ={17,29,39}
for i,z in ipairs(boothZ) do
 local b=model("PrivateBooth"..i,private)
 part("Floor",Vector3.new(19,.12,9),CFrame.new(48,25.06,z),C.slate,Enum.Material.Slate,0,b,true)
 part("BackWall",Vector3.new(19,7,.45),CFrame.new(48,28.5,z+4.3),C.panel,Enum.Material.Fabric,0,b,false)
 part("SideL",Vector3.new(.45,7,8),CFrame.new(38.7,28.5,z),C.ink,Enum.Material.Slate,0,b,false)
 part("SideR",Vector3.new(.45,7,8),CFrame.new(57.3,28.5,z),C.ink,Enum.Material.Slate,0,b,false)
 local banquette=model("Banquette",b)
 part("Base",Vector3.new(14,1.0,2.6),CFrame.new(48,26.0,z+2.6),C.velvet2,Enum.Material.Fabric,0,banquette,true)
 part("Back",Vector3.new(14,2.8,.7),CFrame.new(48,27.2,z+3.55),C.velvet,Enum.Material.Fabric,0,banquette,false)
 seatPart("SeatL",Vector3.new(5,.34,2.0),CFrame.new(44.9,26.65,z+2.35)*CFrame.Angles(0,math.rad(180),0),C.velvet2,banquette)
 seatPart("SeatR",Vector3.new(5,.34,2.0),CFrame.new(51.1,26.65,z+2.35)*CFrame.Angles(0,math.rad(180),0),C.velvet2,banquette)
 local table=part("Table",Vector3.new(6,.22,3),CFrame.new(48,26.5,z-.4),C.glass,Enum.Material.Glass,.18,b,false);table.Reflectance=.10
 neon("BoothGlow",Vector3.new(13,.08,.08),CFrame.new(48,31.7,z+4.0),i==2 and C.cyan or C.pink,b,.10)
 local plate=part("Number",Vector3.new(4,1.1,.12),CFrame.new(48,30.7,z+4.04),C.black,Enum.Material.SmoothPlastic,0,b,false)
 surfaceText(plate,string.format("VIP %02d",i),i==2 and C.cyan or C.gold)
 prompt(table,"Hang Out",string.format("VIP Booth %02d",i),8)
end

-- PHOTO MOMENT ----------------------------------------------------------------
local photo=model("VIPPhotoWall")
part("PhotoDeck",Vector3.new(18,.12,11),CFrame.new(-45,25.06,-17),C.slate,Enum.Material.Slate,0,photo,true)
part("PhotoBack",Vector3.new(18,8,.48),CFrame.new(-45,29,-22),C.ink,Enum.Material.Slate,0,photo,false)
local photoLogo=part("PhotoLogo",Vector3.new(12,3,.12),CFrame.new(-45,30,-21.7),C.black,Enum.Material.SmoothPlastic,0,photo,false)
surfaceText(photoLogo,"BBYA\nVIP NIGHT",C.white)
neon("PhotoPink",Vector3.new(14,.08,.08),CFrame.new(-45,27.4,-21.6),C.pink,photo,.04)
neon("PhotoGold",Vector3.new(8,.08,.08),CFrame.new(-45,26.8,-21.6),C.gold,photo,.08)
for _,x in ipairs({-51,-39}) do
 local lamp=neon("PhotoLamp"..x,Vector3.new(.18,5,.18),CFrame.new(x,29,-20.9),x< -45 and C.cyan or C.pink,photo,.08);light(lamp,lamp.Color,.55,12)
end

-- CEILING / AMBIENCE -----------------------------------------------------------
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
for i,x in ipairs({-24,0,24}) do
 local cove=neon("NorthCove"..i,Vector3.new(10,.08,.08),CFrame.new(x,34.2,42.8),i==2 and C.gold or C.pink,ceiling,.14)
 light(cove,cove.Color,.28,11)
end

-- WAYFINDING ------------------------------------------------------------------
local way=model("VIPWayfinding")
local status=part("StatusPanel",Vector3.new(8,1.6,.12),CFrame.new(46,30.0,8.45),C.black,Enum.Material.SmoothPlastic,0,way,false)
surfaceText(status,"●  VIP OPEN",C.green)
local loungeSign=part("LoungeDirection",Vector3.new(8,1.3,.12),CFrame.new(36.2,29.4,4),C.black,Enum.Material.SmoothPlastic,0,way,false)
surfaceText(loungeSign,"← SKY LOUNGE",C.gold)
local boothSign=part("BoothDirection",Vector3.new(8,1.3,.12),CFrame.new(55.8,29.4,4),C.black,Enum.Material.SmoothPlastic,0,way,false)
surfaceText(boothSign,"PRIVATE →",C.cyan)

-- Runtime integrity metadata for cloud QC.
local activeSeats=0
for _,d in ipairs(out:GetDescendants()) do if d:IsA("Seat") then activeSeats+=1 end end
out:SetAttribute("ActiveSeats",activeSeats)
out:SetAttribute("PrivateBooths",3)
out:SetAttribute("PhotoMoment",true)
out:SetAttribute("ArrivalLobby",true)

print(string.format("[BBYA] VIP Sky Lounge v2 online: %d active seats + arrival + overlook + photo wall + private booths",activeSeats))
