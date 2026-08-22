-- BBYA SOCIAL HUB — WORLD PREMIUM PASS v338
-- Late authoritative finishing layer for every BBYA venue EXCEPT Mall.
-- Priorities: close all Skatepark bypass routes, seal former-pillar holes, add believable premium furniture,
-- functional seating, architectural lighting, realistic micro-details and venue-specific dressing.

local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",35)
if not root then return end

task.wait(1.5)
local old=root:FindFirstChild("WorldPremiumV338")
if old then old:Destroy() end
local out=Instance.new("Model")
out.Name="WorldPremiumV338"
out.Parent=root
out:SetAttribute("Pass","WORLD_PREMIUM_V338")
out:SetAttribute("MallExcluded",true)
out:SetAttribute("PaidZoneBypassClosed",true)
out:SetAttribute("DesignLanguage","premium hospitality + nightlife realism")

local C={
 black=Color3.fromRGB(8,8,11), charcoal=Color3.fromRGB(22,23,27), graphite=Color3.fromRGB(39,40,46),
 metal=Color3.fromRGB(67,70,78), brushed=Color3.fromRGB(105,108,114), glass=Color3.fromRGB(80,102,113),
 stone=Color3.fromRGB(101,96,92), limestone=Color3.fromRGB(128,122,113), marble=Color3.fromRGB(142,137,134),
 leather=Color3.fromRGB(31,30,35), fabric=Color3.fromRGB(48,44,51), fabricLight=Color3.fromRGB(191,184,176),
 wood=Color3.fromRGB(103,75,54), brass=Color3.fromRGB(190,147,80), champagne=Color3.fromRGB(222,184,116),
 warm=Color3.fromRGB(255,222,184), white=Color3.fromRGB(239,240,243), cyan=Color3.fromRGB(31,184,214),
 pink=Color3.fromRGB(235,42,156), leaf=Color3.fromRGB(57,93,62), red=Color3.fromRGB(188,54,65),
}

local function model(name,parent)
 local m=Instance.new("Model");m.Name=name;m.Parent=parent or out;return m
end
local function part(name,size,cf,color,material,collide,parent,transparency)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.graphite;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=true;p.CastShadow=(p.Transparency<.95)
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or out;return p
end
local function cylinder(name,size,cf,color,material,collide,parent,transparency)
 local p=part(name,size,cf,color,material,collide,parent,transparency);p.Shape=Enum.PartType.Cylinder;return p
end
local function ball(name,size,cf,color,material,collide,parent,transparency)
 local p=part(name,size,cf,color,material,collide,parent,transparency);p.Shape=Enum.PartType.Ball;return p
end
local function seat(name,size,cf,color,parent)
 local s=Instance.new("Seat");s.Name=name;s.Size=size;s.CFrame=cf;s.Color=color or C.fabric;s.Material=Enum.Material.Fabric;s.Anchored=true;s.CanCollide=true;s.CanTouch=true;s.TopSurface=Enum.SurfaceType.Smooth;s.BottomSurface=Enum.SurfaceType.Smooth;s.Parent=parent or out;return s
end
local function warmPoint(parent,brightness,range,color)
 local l=Instance.new("PointLight");l.Color=color or C.warm;l.Brightness=brightness or .8;l.Range=range or 12;l.Shadows=true;l.Parent=parent;return l
end
local function spot(parent,face,color,brightness,range,angle)
 local l=Instance.new("SpotLight");l.Face=face or Enum.NormalId.Bottom;l.Color=color or C.warm;l.Brightness=brightness or 1;l.Range=range or 24;l.Angle=angle or 45;l.Shadows=true;l.Parent=parent;return l
end
local function labelFace(p,textValue,color,sub)
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.PixelsPerStud=60;g.LightInfluence=.18;g.Parent=p
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=UDim2.fromScale(.05,.08);t.Size=UDim2.fromScale(.90,sub and .54 or .84);t.Text=textValue;t.TextColor3=color or C.white;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.Parent=g
 if sub then local s=Instance.new("TextLabel");s.BackgroundTransparency=1;s.Position=UDim2.fromScale(.08,.66);s.Size=UDim2.fromScale(.84,.18);s.Text=sub;s.TextColor3=C.fabricLight;s.Font=Enum.Font.GothamBold;s.TextScaled=true;s.Parent=g end
end
local function planter(name,pos,scale,parent)
 scale=scale or 1;local m=model(name,parent)
 cylinder("Pot",Vector3.new(2.4*scale,3.2*scale,3.2*scale),CFrame.new(pos.X,pos.Y,pos.Z)*CFrame.Angles(0,0,math.rad(90)),C.graphite,Enum.Material.Concrete,true,m)
 cylinder("Trunk",Vector3.new(3.8*scale,.42*scale,.42*scale),CFrame.new(pos.X,pos.Y+2.5*scale,pos.Z)*CFrame.Angles(0,0,math.rad(90)),C.wood,Enum.Material.Wood,false,m)
 for i=1,7 do local a=math.rad((i-1)*51.43);local leaf=ball("Leaf"..i,Vector3.new(1.4,1.9,1.1)*scale,CFrame.new(pos.X+math.cos(a)*.9*scale,pos.Y+4.5*scale,pos.Z+math.sin(a)*.9*scale),C.leaf,Enum.Material.SmoothPlastic,false,m);leaf.CanQuery=false end
 return m
end

-- =============================================================================
-- 1) PAID-ZONE SECURITY / NO FREE WALK TO SKATEPARK OR FUNKOT
-- =============================================================================
local security=model("PaidZoneSecurity")
security:SetAttribute("SkateparkTravelOnly",true)
security:SetAttribute("PhysicalBypassClosed",true)

-- The old 15x8 corner fills were too low and left jumpable space after the large pillar removal.
-- These architectural seals overlap both facade and shell, removing the left/right holes completely.
for _,x in ipairs({-54,54}) do
 local side=x<0 and "Left" or "Right"
 part("FormerPillarSeal"..side,Vector3.new(18,20,16),CFrame.new(x,10,-38),C.black,Enum.Material.Concrete,true,security)
 part("FlutedFace"..side,Vector3.new(15.5,15.5,.35),CFrame.new(x,10,-46.15),C.graphite,Enum.Material.Metal,false,security)
 for i=-3,3 do part("Flute"..side..i,Vector3.new(.16,13.5,.20),CFrame.new(x+i*1.8,10,-46.37),C.brushed,Enum.Material.Metal,false,security) end
 local up=part("SealUplight"..side,Vector3.new(.3,.3,.3),CFrame.new(x,1.3,-47),C.black,Enum.Material.SmoothPlastic,false,security,1);warmPoint(up,.55,10,C.warm)
end

-- Visible side perimeter: no more service alley/gang from the front toward the paid park.
for _,x in ipairs({-64,64}) do
 local side=x<0 and "Left" or "Right"
 part("PerimeterPlinth"..side,Vector3.new(2.6,5.5,154),CFrame.new(x,2.75,0),C.charcoal,Enum.Material.Concrete,true,security)
 local glass=part("PerimeterGlass"..side,Vector3.new(1.1,9.5,154),CFrame.new(x,10.2,0),C.glass,Enum.Material.Glass,true,security,.42);glass.Reflectance=.06
 for z=-72,72,8 do part("PerimeterPost"..side..z,Vector3.new(1.55,15.5,.38),CFrame.new(x,8,z),C.metal,Enum.Material.Metal,true,security) end
 part("PerimeterCap"..side,Vector3.new(2.1,.35,154),CFrame.new(x,15.1,0),C.champagne,Enum.Material.Metal,false,security)
end

-- Invisible outer collision is only a fail-safe. Visible architecture above communicates the boundary.
for _,x in ipairs({-73,73}) do part("NoBypassWorldBoundary"..(x<0 and "Left" or "Right"),Vector3.new(3,28,520),CFrame.new(x,14,55),C.black,Enum.Material.SmoothPlastic,true,security,1) end
part("NoBypassRearBoundary",Vector3.new(148,28,3),CFrame.new(0,14,274),C.black,Enum.Material.SmoothPlastic,true,security,1)

-- Close the actual Skatepark center gate. Owners/pass holders still arrive by Travel teleport inside the park.
local gate=model("SkateparkTravelGate",security)
part("GateFrameL",Vector3.new(1.2,14,2),CFrame.new(-11.5,7,73.3),C.metal,Enum.Material.Metal,true,gate)
part("GateFrameR",Vector3.new(1.2,14,2),CFrame.new(11.5,7,73.3),C.metal,Enum.Material.Metal,true,gate)
part("GateHeader",Vector3.new(24.2,1.2,2),CFrame.new(0,13.4,73.3),C.metal,Enum.Material.Metal,true,gate)
local door=part("LockedTravelGlass",Vector3.new(22,12.4,1.1),CFrame.new(0,6.3,73.3),C.glass,Enum.Material.Glass,true,gate,.28);door.Reflectance=.08
for x=-9,9,3 do part("GateVertical"..x,Vector3.new(.24,11.4,1.25),CFrame.new(x,6.3,73.1),C.brushed,Enum.Material.Metal,false,gate) end
local gateSign=part("TravelOnlySign",Vector3.new(19,3,.35),CFrame.new(0,10.6,72.45)*CFrame.Angles(0,math.rad(180),0),C.black,Enum.Material.Metal,false,gate)
labelFace(gateSign,"SKATEPARK","TRAVEL ACCESS • 5 R$")
gate:SetAttribute("PhysicalEntryLocked",true);gate:SetAttribute("TravelKey","Skatepark")

-- =============================================================================
-- 2) ARRIVAL / ENTRANCE HOSPITALITY
-- =============================================================================
local entrance=model("EntranceHospitality")
local canopy=part("GlassCanopy",Vector3.new(48,.65,8.5),CFrame.new(0,18.1,-50.5),C.glass,Enum.Material.Glass,false,entrance,.46);canopy.Reflectance=.08
for _,x in ipairs({-22,22}) do
 part("CanopyBeam"..x,Vector3.new(.8,1,9),CFrame.new(x,17.8,-50.5),C.metal,Enum.Material.Metal,false,entrance)
 for _,z in ipairs({-47.3,-53.7}) do part("CanopyBrace"..x..z,Vector3.new(.45,7,.45),CFrame.new(x,14,z),C.metal,Enum.Material.Metal,false,entrance) end
end
for _,x in ipairs({-18,-9,0,9,18}) do local a=part("CanopyDownlight"..x,Vector3.new(.7,.22,.7),CFrame.new(x,17.65,-51),C.black,Enum.Material.Metal,false,entrance);spot(a,Enum.NormalId.Bottom,C.warm,.85,18,52) end
for _,x in ipairs({-36,-24,-12,12,24,36}) do
 local b=cylinder("ArrivalBollard"..x,Vector3.new(2.2,.72,.72),CFrame.new(x,1.6,-58)*CFrame.Angles(0,0,math.rad(90)),C.graphite,Enum.Material.Metal,true,entrance)
 local lamp=ball("BollardLamp"..x,Vector3.new(.8,.8,.8),CFrame.new(x,2.9,-58),C.warm,Enum.Material.Glass,false,entrance,.12);warmPoint(lamp,.35,7)
end
planter("ArrivalPlanterL",Vector3.new(-43,1.5,-58),1.1,entrance);planter("ArrivalPlanterR",Vector3.new(43,1.5,-58),1.1,entrance)

-- =============================================================================
-- 3) MAIN CLUB — USABLE LOUNGE / TABLES / AUDIO DETAIL
-- =============================================================================
local main=model("MainClubFurniture")
local function clubSofa(name,x,z,yaw)
 local m=model(name,main);local cf=CFrame.new(x,1.55,z)*CFrame.Angles(0,math.rad(yaw),0)
 seat("Seat",Vector3.new(8,1.15,3.3),cf,C.fabric,m)
 part("Back",Vector3.new(8,3,.55),cf*CFrame.new(0,1.55,1.35)*CFrame.Angles(math.rad(-8),0,0),C.leather,Enum.Material.Fabric,true,m)
 for _,sx in ipairs({-3.55,3.55}) do part("Arm"..sx,Vector3.new(.7,2.0,3.4),cf*CFrame.new(sx,.5,0),C.leather,Enum.Material.Fabric,true,m) end
 part("BrassFoot",Vector3.new(7.2,.12,.16),cf*CFrame.new(0,-.72,-1.65),C.brass,Enum.Material.Metal,false,m)
end
clubSofa("WestLoungeA",-42,2,90);clubSofa("WestLoungeB",-42,24,90);clubSofa("EastLoungeA",42,2,-90);clubSofa("EastLoungeB",42,24,-90)
for _,spec in ipairs({{-35,2},{-35,24},{35,2},{35,24}}) do
 local x,z=spec[1],spec[2];local t=model("CocktailTable"..x.."_"..z,main)
 cylinder("Top",Vector3.new(.35,4.2,4.2),CFrame.new(x,2.4,z)*CFrame.Angles(0,0,math.rad(90)),C.marble,Enum.Material.Marble,true,t)
 cylinder("Stem",Vector3.new(2.2,.34,.34),CFrame.new(x,1.2,z)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,true,t)
end
for _,x in ipairs({-24,30}) do
 local sp=model("StageSpeaker"..x,main)
 part("Sub",Vector3.new(5.2,4.2,4.6),CFrame.new(x,4.1,37),C.black,Enum.Material.Metal,true,sp)
 part("Mid",Vector3.new(4.5,5.6,3.8),CFrame.new(x,8.8,37.2),C.graphite,Enum.Material.Metal,true,sp)
 for _,y in ipairs({7.3,9.1,10.7}) do cylinder("Driver"..y,Vector3.new(.22,2.25,2.25),CFrame.new(x,y,35.2)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,false,sp) end
end

-- =============================================================================
-- 4) VIP — STANDING-ONLY BOTTLE SERVICE DETAILS (NO PINK NEON)
-- =============================================================================
local vip=model("VIPStandingPremium")
for _,spec in ipairs({{-47,-20},{-47,5},{-47,30},{47,-20},{47,5},{47,30}}) do
 local x,z=spec[1],spec[2];local m=model("StandingTable"..x.."_"..z,vip)
 cylinder("Top",Vector3.new(.28,3.8,3.8),CFrame.new(x,28.0,z)*CFrame.Angles(0,0,math.rad(90)),C.marble,Enum.Material.Marble,true,m)
 cylinder("Stem",Vector3.new(2.6,.30,.30),CFrame.new(x,26.6,z)*CFrame.Angles(0,0,math.rad(90)),C.champagne,Enum.Material.Metal,true,m)
 cylinder("BottleBucket",Vector3.new(1.2,1.7,1.7),CFrame.new(x,28.75,z)*CFrame.Angles(0,0,math.rad(90)),C.brushed,Enum.Material.Metal,false,m)
 local lamp=ball("TableLamp",Vector3.new(.55,.55,.55),CFrame.new(x+1.2,28.6,z),C.warm,Enum.Material.Glass,false,m,.08);warmPoint(lamp,.22,5,C.warm)
end
local ledge=part("RearBottleLedge",Vector3.new(62,.36,2.4),CFrame.new(0,27.3,40),C.marble,Enum.Material.Marble,true,vip)
for x=-27,27,9 do cylinder("Bottle"..x,Vector3.new(1.1,.38,.38),CFrame.new(x,28.0,40)*CFrame.Angles(0,0,math.rad(90)),C.glass,Enum.Material.Glass,false,vip,.28) end

-- =============================================================================
-- 5) ROOFTOP — MICRO HOSPITALITY DETAIL
-- =============================================================================
local roof=model("RooftopMicroDetail")
for _,spec in ipairs({{-21,-35},{21,-35},{-42,10},{42,10}}) do
 local x,z=spec[1],spec[2];local side=model("SideTable"..x.."_"..z,roof)
 cylinder("TableTop",Vector3.new(.22,2.9,2.9),CFrame.new(x,46.6,z)*CFrame.Angles(0,0,math.rad(90)),C.stone,Enum.Material.Limestone,true,side)
 cylinder("Lantern",Vector3.new(.9,.85,.85),CFrame.new(x,47.2,z),C.warm,Enum.Material.Glass,false,side,.18);warmPoint(side.Lantern,.28,6)
end
for _,spec in ipairs({{-16,-34},{16,-34}}) do
 local x,z=spec[1],spec[2];local tray=model("ServiceTray"..x,roof)
 cylinder("Tray",Vector3.new(.12,2.5,2.5),CFrame.new(x,46.2,z)*CFrame.Angles(0,0,math.rad(90)),C.brushed,Enum.Material.Metal,false,tray)
 for i=-1,1 do cylinder("Glass"..i,Vector3.new(.65,.34,.34),CFrame.new(x+i*.65,46.65,z),C.glass,Enum.Material.Glass,false,tray,.35) end
end

-- =============================================================================
-- 6) UNDERGROUND — STANDING TABLES / INDUSTRIAL DETAIL
-- =============================================================================
local underground=model("UndergroundMicroDetail")
for _,spec in ipairs({{-40,-27},{-40,27},{40,-27},{40,27}}) do
 local x,z=spec[1],spec[2];local m=model("HighTable"..x.."_"..z,underground)
 cylinder("Top",Vector3.new(.28,3.5,3.5),CFrame.new(x,-11.7,z)*CFrame.Angles(0,0,math.rad(90)),C.graphite,Enum.Material.Metal,true,m)
 cylinder("Stem",Vector3.new(2.8,.32,.32),CFrame.new(x,-13.2,z)*CFrame.Angles(0,0,math.rad(90)),C.metal,Enum.Material.Metal,true,m)
 local l=part("PinLight",Vector3.new(.22,.22,.22),CFrame.new(x,-11.3,z),C.white,Enum.Material.Neon,false,m);warmPoint(l,.14,4,(x<0) and C.cyan or C.warm)
end

-- =============================================================================
-- 7) SKATEPARK — PREMIUM SPECTATOR / LOCKERS / FLOOD LIGHTS
-- =============================================================================
local skate=model("SkateparkPremium")
local function spectatorBench(name,x,z,yaw)
 local m=model(name,skate);local cf=CFrame.new(x,2.0,z)*CFrame.Angles(0,math.rad(yaw),0)
 seat("BenchSeat",Vector3.new(10,1,2.7),cf,C.fabric,m)
 part("BenchBack",Vector3.new(10,2.7,.45),cf*CFrame.new(0,1.5,1.15)*CFrame.Angles(math.rad(-8),0,0),C.graphite,Enum.Material.Metal,true,m)
 for _,sx in ipairs({-4.2,4.2}) do part("BenchLeg"..sx,Vector3.new(.35,1.6,.35),cf*CFrame.new(sx,-.8,0),C.metal,Enum.Material.Metal,true,m) end
end
spectatorBench("WestSpectatorA",-51,91,-90);spectatorBench("WestSpectatorB",-51,133,-90);spectatorBench("EastSpectatorA",51,91,90);spectatorBench("EastSpectatorB",51,133,90)
local lockers=model("SkateLockers",skate)
for i=1,8 do
 local x=-44+(i-1)*4.7;local l=part("Locker"..i,Vector3.new(4.1,7,2.3),CFrame.new(x,4.0,147.5),C.graphite,Enum.Material.Metal,true,lockers)
 part("LockerVent"..i,Vector3.new(2.3,.12,.12),CFrame.new(x,5.2,146.3),C.brushed,Enum.Material.Metal,false,lockers)
 part("LockerHandle"..i,Vector3.new(.12,.55,.12),CFrame.new(x+1.25,3.6,146.3),C.champagne,Enum.Material.Metal,false,lockers)
end
for _,spec in ipairs({{-54,80},{54,80},{-54,144},{54,144}}) do
 local x,z=spec[1],spec[2];local pole=model("FloodPole"..x.."_"..z,skate)
 cylinder("Pole",Vector3.new(15,.45,.45),CFrame.new(x,8,z)*CFrame.Angles(0,0,math.rad(90)),C.metal,Enum.Material.Metal,true,pole)
 local head=part("Head",Vector3.new(2.4,1.1,1.4),CFrame.lookAt(Vector3.new(x,15,z),Vector3.new(0,2,112)),C.black,Enum.Material.Metal,false,pole)
 spot(head,Enum.NormalId.Front,C.white,2.3,74,54)
end

-- =============================================================================
-- 8) FUNKOT CLUB — REAL SPEAKER STACKS / SERVICE DETAIL
-- =============================================================================
local funkot=model("FunkotPremium")
for _,x in ipairs({-29,29}) do
 local tower=model("SpeakerTower"..x,funkot)
 part("SubA",Vector3.new(6.8,5.4,4.8),CFrame.new(x,4.0,232),C.black,Enum.Material.Metal,true,tower)
 part("SubB",Vector3.new(6.8,5.4,4.8),CFrame.new(x,9.6,232),C.black,Enum.Material.Metal,true,tower)
 part("Top",Vector3.new(5.4,6.8,4.2),CFrame.new(x,15.6,232),C.graphite,Enum.Material.Metal,true,tower)
 for _,y in ipairs({3.8,9.4,14.2,16.7}) do cylinder("Driver"..y,Vector3.new(.20,2.5,2.5),CFrame.new(x,y,229.55)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,false,tower) end
end
local service=part("FunkotServiceBar",Vector3.new(28,3.3,6),CFrame.new(39,2.2,219),C.charcoal,Enum.Material.Metal,true,funkot)
part("FunkotServiceTop",Vector3.new(29,.34,6.8),CFrame.new(39,4.0,219),C.marble,Enum.Material.Marble,true,funkot)
for x=29,49,5 do
 local stool=model("FunkotStool"..x,funkot)
 seat("Seat",Vector3.new(2.3,.55,2.3),CFrame.new(x,2.6,214.5),C.fabric,stool)
 cylinder("Stem",Vector3.new(2.1,.26,.26),CFrame.new(x,1.4,214.5)*CFrame.Angles(0,0,math.rad(90)),C.metal,Enum.Material.Metal,true,stool)
end

-- Safety marker for future passes: never touch any Mall-named hierarchy.
out:SetAttribute("DoNotModifyMall",true)
out:SetAttribute("FurnitureFamilies",8)
out:SetAttribute("FunctionalSeats",12)
out:SetAttribute("SecurityGateClosed",true)
out:SetAttribute("FormerPillarSeals",2)

print("[BBYA] World Premium v338 online: anti-bypass + premium furniture/features; Mall excluded")
