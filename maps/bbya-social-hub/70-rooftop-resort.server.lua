-- BBYA SOCIAL HUB — ROOFTOP RESORT PREMIUM v3
-- Premium interactive rooftop resort authority.
-- Rebuilds Rooftop only: infinity pool, cabanas, bar, sunset lounge, pool loungers,
-- landscape, warm practical lights and native seating. NO global Lighting edits.
-- Access / gamepass / travel / DJ / VIP / Mall / Underground / fishing are untouched.

local Workspace=game:GetService("Workspace")
local Terrain=Workspace.Terrain
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper=root:WaitForChild("UpperLevels",30)
if not upper then return end
local roof=upper:WaitForChild("R_Rooftop",30)
if not roof then return end

task.wait(.55)
for _,child in ipairs(roof:GetChildren()) do child:Destroy() end

roof:SetAttribute("Pass","ROOFTOP_RESORT_PREMIUM_V3")
roof:SetAttribute("NoNeon",true)
roof:SetAttribute("RealTerrainWaterPool",true)
roof:SetAttribute("PoolHasRecessedBasin",true)
roof:SetAttribute("NativeSeating",true)
roof:SetAttribute("GlobalLightingUntouched",true)
roof:SetAttribute("AccessLogicUntouched",true)
roof:SetAttribute("DesignLanguage","Bali sky resort • limestone • teak • glass • warm hospitality")

local C={
 limestone=Color3.fromRGB(151,143,132),
 limestoneDark=Color3.fromRGB(111,105,98),
 concrete=Color3.fromRGB(84,82,80),
 charcoal=Color3.fromRGB(42,43,45),
 ink=Color3.fromRGB(25,26,28),
 teak=Color3.fromRGB(111,78,54),
 teakDark=Color3.fromRGB(68,48,37),
 fabric=Color3.fromRGB(216,207,193),
 fabricWarm=Color3.fromRGB(177,151,128),
 fabricDark=Color3.fromRGB(88,76,69),
 metal=Color3.fromRGB(65,67,70),
 brass=Color3.fromRGB(173,134,79),
 glass=Color3.fromRGB(118,151,162),
 pool=Color3.fromRGB(68,88,92),
 leaf=Color3.fromRGB(63,100,67),
 leaf2=Color3.fromRGB(81,121,77),
 warm=Color3.fromRGB(255,218,177),
 aqua=Color3.fromRGB(113,190,199),
 fire=Color3.fromRGB(255,151,77),
 white=Color3.fromRGB(236,233,225),
}

local function part(name,size,cf,color,material,transparency,collide,parent)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.CFrame=cf
 p.Color=color or C.concrete
 p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0
 p.Anchored=true
 p.CanCollide=collide~=false
 p.CanTouch=false
 p.CanQuery=true
 p.CastShadow=true
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or roof
 return p
end

local function cylinder(name,height,diameter,cf,color,material,parent,collide,transparency)
 local p=part(name,Vector3.new(height,diameter,diameter),cf*CFrame.Angles(0,0,math.rad(90)),color,material,transparency or 0,collide,parent)
 p.Shape=Enum.PartType.Cylinder
 return p
end

local function model(name,parent)
 local m=Instance.new("Model")
 m.Name=name
 m.Parent=parent or roof
 return m
end

local function pointLight(parent,color,brightness,range)
 local l=Instance.new("PointLight")
 l.Name="RooftopPracticalLight"
 l.Color=color or C.warm
 l.Brightness=brightness or .8
 l.Range=range or 14
 l.Shadows=true
 l.Parent=parent
 return l
end

local function surfaceLight(parent,face,color,brightness,range,angle)
 local l=Instance.new("SurfaceLight")
 l.Name="RooftopSurfaceLight"
 l.Face=face or Enum.NormalId.Bottom
 l.Color=color or C.warm
 l.Brightness=brightness or .7
 l.Range=range or 12
 l.Angle=angle or 120
 l.Shadows=false
 l.Parent=parent
 return l
end

local function beamBetween(name,a,b,color,material,parent,thickness)
 local mid=(a+b)/2
 local len=(b-a).Magnitude
 return part(name,Vector3.new(thickness or .28,thickness or .28,len),CFrame.lookAt(mid,b),color,material or Enum.Material.Metal,0,false,parent)
end

local seatCount=0
local function nativeSeat(name,pos,target,size,parent)
 local s=Instance.new("Seat")
 s.Name=name
 s.Size=size or Vector3.new(2.4,.34,2.4)
 s.CFrame=CFrame.lookAt(pos,target)
 s.Transparency=1
 s.Anchored=true
 s.CanCollide=true
 s.CanTouch=true
 s.CanQuery=false
 s.CastShadow=false
 s.Disabled=false
 s.Parent=parent or roof
 seatCount+=1
 return s
end

local function signText(partObj,face,title,subtitle)
 local gui=Instance.new("SurfaceGui")
 gui.Name="ResortIdentityGui"
 gui.Face=face
 gui.PixelsPerStud=70
 gui.LightInfluence=.12
 gui.Parent=partObj
 local bg=Instance.new("Frame")
 bg.Size=UDim2.fromScale(1,1)
 bg.BackgroundTransparency=1
 bg.Parent=gui
 local t=Instance.new("TextLabel")
 t.BackgroundTransparency=1
 t.Position=UDim2.fromScale(.06,.14)
 t.Size=UDim2.fromScale(.88,.48)
 t.Text=title
 t.TextColor3=C.white
 t.Font=Enum.Font.GothamBold
 t.TextScaled=true
 t.Parent=bg
 local sub=Instance.new("TextLabel")
 sub.BackgroundTransparency=1
 sub.Position=UDim2.fromScale(.10,.66)
 sub.Size=UDim2.fromScale(.80,.16)
 sub.Text=subtitle
 sub.TextColor3=C.brass
 sub.Font=Enum.Font.GothamMedium
 sub.TextScaled=true
 sub.Parent=bg
end

-- -----------------------------------------------------------------------------
-- 1) ARCHITECTURAL DECK + SAFETY EDGE
-- -----------------------------------------------------------------------------
local architecture=model("RooftopArchitectureV3")
part("RoofWest",Vector3.new(32.6,1.2,92),CFrame.new(-45.7,44.35,0),C.charcoal,Enum.Material.Concrete,0,true,architecture)
part("RoofEast",Vector3.new(32.6,1.2,92),CFrame.new(45.7,44.35,0),C.charcoal,Enum.Material.Concrete,0,true,architecture)
part("RoofSouth",Vector3.new(58.8,1.2,41.8),CFrame.new(0,44.35,-25.1),C.charcoal,Enum.Material.Concrete,0,true,architecture)
part("RoofNorth",Vector3.new(58.8,1.2,17.8),CFrame.new(0,44.35,37.1),C.charcoal,Enum.Material.Concrete,0,true,architecture)

-- Layered limestone coping and teak hospitality decks.
part("PoolDeckW",Vector3.new(9.8,.44,40),CFrame.new(-34.2,45.14,12),C.limestone,Enum.Material.Limestone,0,true,architecture)
part("PoolDeckE",Vector3.new(9.8,.44,40),CFrame.new(34.2,45.14,12),C.limestone,Enum.Material.Limestone,0,true,architecture)
part("PoolDeckS",Vector3.new(58.6,.44,8.2),CFrame.new(0,45.14,-8.0),C.limestone,Enum.Material.Limestone,0,true,architecture)
part("PoolDeckN",Vector3.new(58.6,.44,8.2),CFrame.new(0,45.14,32.0),C.limestone,Enum.Material.Limestone,0,true,architecture)
part("SunsetDeck",Vector3.new(112,.42,18),CFrame.new(0,45.15,-36),C.teak,Enum.Material.WoodPlanks,0,true,architecture)
part("GardenDeckWest",Vector3.new(19,.42,52),CFrame.new(-50,45.15,8),C.teakDark,Enum.Material.WoodPlanks,0,true,architecture)
part("GardenDeckEast",Vector3.new(19,.42,52),CFrame.new(50,45.15,8),C.teakDark,Enum.Material.WoodPlanks,0,true,architecture)

-- Warm stone transition bands make the deck read as architecture instead of giant rectangles.
for _,z in ipairs({-15.8,-11.8,35.8}) do
 part("StoneBand"..z,Vector3.new(58.5,.055,.28),CFrame.new(0,45.38,z),C.brass,Enum.Material.Metal,.18,false,architecture)
end

-- Frameless outer safety glass with slim metal shoe at floor level.
for _,d in ipairs({
 {"North",Vector3.new(118,5,.28),CFrame.new(0,47.7,45.0),Vector3.new(118,.18,.42),CFrame.new(0,45.28,45.0)},
 {"South",Vector3.new(118,5,.28),CFrame.new(0,47.7,-45.0),Vector3.new(118,.18,.42),CFrame.new(0,45.28,-45.0)},
 {"West",Vector3.new(.28,5,90),CFrame.new(-59.0,47.7,0),Vector3.new(.42,.18,90),CFrame.new(-59.0,45.28,0)},
 {"East",Vector3.new(.28,5,90),CFrame.new(59.0,47.7,0),Vector3.new(.42,.18,90),CFrame.new(59.0,45.28,0)},
}) do
 local g=part("GlassRail"..d[1],d[2],d[3],C.glass,Enum.Material.Glass,.66,true,architecture)
 g.Reflectance=.04
 part("RailShoe"..d[1],d[4],d[5],C.metal,Enum.Material.Metal,0,true,architecture)
end

-- -----------------------------------------------------------------------------
-- 2) TRUE RECESSED INFINITY POOL
-- -----------------------------------------------------------------------------
local pool=model("RooftopInfinityPoolV3")
Terrain:FillBlock(CFrame.new(0,44.1,12),Vector3.new(58,8,32),Enum.Material.Air)
Terrain:FillBlock(CFrame.new(0,43.42,12),Vector3.new(56,3.0,30),Enum.Material.Water)

part("PoolBasinFloor",Vector3.new(58,.50,32),CFrame.new(0,41.55,12),C.pool,Enum.Material.Slate,0,true,pool)
part("PoolWallN",Vector3.new(58,3.8,.65),CFrame.new(0,43.45,27.55),C.limestoneDark,Enum.Material.Limestone,0,true,pool)
part("PoolWallS",Vector3.new(58,3.8,.65),CFrame.new(0,43.45,-3.55),C.limestoneDark,Enum.Material.Limestone,0,true,pool)
part("PoolWallW",Vector3.new(.65,3.8,30),CFrame.new(-28.65,43.45,12),C.limestoneDark,Enum.Material.Limestone,0,true,pool)
part("PoolWallE",Vector3.new(.65,3.8,30),CFrame.new(28.65,43.45,12),C.limestoneDark,Enum.Material.Limestone,0,true,pool)

-- Infinity view edge + underwater reveal, subtle local pool light only.
local infinity=part("InfinityGlass",Vector3.new(54,2.55,.22),CFrame.new(0,43.78,-3.88),C.glass,Enum.Material.Glass,.78,false,pool)
infinity.Reflectance=.05
for _,x in ipairs({-20,-10,0,10,20}) do
 local lens=part("PoolWallLens"..x,Vector3.new(2.3,.20,.12),CFrame.new(x,42.65,-3.72),C.aqua,Enum.Material.Glass,.20,false,pool)
 pointLight(lens,C.aqua,.20,8)
end

-- Broad entry steps + shallow sun shelf.
for i,data in ipairs({
 {y=44.74,z=24.6,w=12},
 {y=44.08,z=22.65,w=12},
 {y=43.42,z=20.7,w=12},
 {y=42.76,z=18.75,w=12},
}) do
 part("PoolStep"..i,Vector3.new(data.w,.52,2.15),CFrame.new(-20,data.y,data.z),C.limestone,Enum.Material.Limestone,0,true,pool)
end
part("ShallowSunShelf",Vector3.new(13,.48,8.4),CFrame.new(-20,42.30,14.3),Color3.fromRGB(102,113,112),Enum.Material.Slate,0,true,pool)

-- Stainless handrail geometry, not neon.
for _,x in ipairs({-24,-16}) do
 local a=Vector3.new(x,45.5,25.4)
 local b=Vector3.new(x,43.4,20.0)
 beamBetween("PoolHandrail",a,b,C.metal,Enum.Material.Metal,pool,.18)
end

-- -----------------------------------------------------------------------------
-- 3) SCULPTURAL CABANAS + DAYBEDS
-- -----------------------------------------------------------------------------
local cabanas=model("PremiumCabanasV3")
local function cabana(name,x,z,yaw)
 local m=model(name,cabanas)
 local base=CFrame.new(x,45.45,z)*CFrame.Angles(0,math.rad(yaw),0)
 -- Slim posts and deep timber portal.
 for _,sx in ipairs({-6.1,6.1}) do
  for _,sz in ipairs({-4.1,4.1}) do
   part("Post",Vector3.new(.42,7.7,.42),base*CFrame.new(sx,3.85,sz),C.teakDark,Enum.Material.WoodPlanks,0,true,m)
  end
 end
 for _,sz in ipairs({-4.1,4.1}) do
  part("TopBeam",Vector3.new(12.7,.52,.52),base*CFrame.new(0,7.7,sz),C.teakDark,Enum.Material.WoodPlanks,0,true,m)
 end
 -- Slatted canopy creates real shadow pattern.
 for _,sx in ipairs({-5.4,-4.05,-2.7,-1.35,0,1.35,2.7,4.05,5.4}) do
  part("RoofSlat",Vector3.new(.28,.20,8.8),base*CFrame.new(sx,7.86,0),C.teak,Enum.Material.WoodPlanks,0,false,m)
 end
 -- Layered daybed rather than one block.
 part("DaybedPlinth",Vector3.new(10.2,.55,5.8),base*CFrame.new(0,.55,0),C.teakDark,Enum.Material.WoodPlanks,0,true,m)
 part("DaybedCushion",Vector3.new(9.7,.52,5.3),base*CFrame.new(0,1.10,0),C.fabric,Enum.Material.Fabric,0,true,m)
 part("DaybedBack",Vector3.new(9.7,2.15,.48),base*CFrame.new(0,2.15,2.38)*CFrame.Angles(math.rad(-9),0,0),C.fabricDark,Enum.Material.Fabric,0,true,m)
 for _,xo in ipairs({-3.3,0,3.3}) do
  part("BackPillow",Vector3.new(2.6,1.55,.42),base*CFrame.new(xo,2.18,2.05)*CFrame.Angles(math.rad(-9),0,0),C.fabricWarm,Enum.Material.Fabric,0,false,m)
 end
 local lamp=cylinder("Pendant",.58,.92,base*CFrame.new(0,6.35,0),C.warm,Enum.Material.Glass,m,false,.10)
 pointLight(lamp,C.warm,.75,12)
 -- Two auto-sit zones per daybed, both face the pool.
 local target=Vector3.new(0,45.9,12)
 for i,xo in ipairs({-2.5,2.5}) do
  nativeSeat("DaybedSeat"..i,(base*CFrame.new(xo,1.55,0)).Position,target,Vector3.new(3.6,.32,4.2),m)
 end
end
cabana("CabanaWest",-48,20,90)
cabana("CabanaEast",48,20,-90)

-- -----------------------------------------------------------------------------
-- 4) POOLSIDE LOUNGERS
-- -----------------------------------------------------------------------------
local loungers=model("PoolsideLoungersV3")
local function lounger(name,x,z,facePool)
 local m=model(name,loungers)
 local target=facePool and Vector3.new(0,45.7,12) or Vector3.new(x,45.7,z-10)
 local cf=CFrame.lookAt(Vector3.new(x,45.42,z),target)
 part("Frame",Vector3.new(3.4,.34,7.0),cf*CFrame.new(0,.28,0),C.teakDark,Enum.Material.WoodPlanks,0,true,m)
 part("Cushion",Vector3.new(3.0,.34,6.5),cf*CFrame.new(0,.62,0),C.fabric,Enum.Material.Fabric,0,true,m)
 part("Back",Vector3.new(3.0,2.45,.38),cf*CFrame.new(0,1.72,2.65)*CFrame.Angles(math.rad(-18),0,0),C.fabricWarm,Enum.Material.Fabric,0,true,m)
 nativeSeat("LoungerSeat",(cf*CFrame.new(0,1.05,.3)).Position,target,Vector3.new(2.8,.30,3.1),m)
end
for i,z in ipairs({-3,8,19,30}) do
 lounger("WestLounger"..i,-38.7,z,true)
 lounger("EastLounger"..i,38.7,z,true)
end

-- -----------------------------------------------------------------------------
-- 5) ROOFTOP BAR + NATIVE BAR STOOLS
-- -----------------------------------------------------------------------------
local bar=model("RooftopBarV3")
-- Bar canopy with warm timber fins.
for _,x in ipairs({-17.5,17.5}) do
 part("BarColumn",Vector3.new(.48,8.2,.48),CFrame.new(x,49.2,-29.0),C.teakDark,Enum.Material.WoodPlanks,0,true,bar)
end
part("CanopyBeam",Vector3.new(36,.48,.52),CFrame.new(0,53.2,-29.0),C.teakDark,Enum.Material.WoodPlanks,0,true,bar)
for _,x in ipairs({-15,-12,-9,-6,-3,0,3,6,9,12,15}) do
 part("CanopyFin"..x,Vector3.new(.24,.18,8.5),CFrame.new(x,53.35,-25.0),C.teak,Enum.Material.WoodPlanks,0,false,bar)
end

part("BarBody",Vector3.new(34,3.0,6.5),CFrame.new(0,46.75,-24.0),C.concrete,Enum.Material.Concrete,0,true,bar)
part("BarFrontInset",Vector3.new(31.0,1.85,.22),CFrame.new(0,46.9,-20.66),C.teakDark,Enum.Material.WoodPlanks,0,false,bar)
part("BarTop",Vector3.new(35,.34,7.3),CFrame.new(0,48.45,-24.0),C.limestone,Enum.Material.Marble,0,true,bar)
part("BackWall",Vector3.new(35,6.4,.44),CFrame.new(0,49.75,-30.2),C.teakDark,Enum.Material.WoodPlanks,0,true,bar)

-- Integrated identity, intentionally restrained.
local identity=part("BarIdentity",Vector3.new(14,2.4,.16),CFrame.new(0,51.0,-29.94),C.ink,Enum.Material.Metal,0,false,bar)
signText(identity,Enum.NormalId.Front,"BBYA SKY RESORT","ROOFTOP • POOL • SUNSET")

-- Floating shelves and bottle silhouettes.
for row,y in ipairs({49.1,50.65}) do
 part("Shelf"..row,Vector3.new(27,.18,1.1),CFrame.new(0,y,-29.62),C.teak,Enum.Material.WoodPlanks,0,true,bar)
 for i=-6,6 do
  local color=(i%3==0) and Color3.fromRGB(105,147,113) or ((i%2==0) and Color3.fromRGB(152,113,79) or Color3.fromRGB(96,119,145))
  cylinder("Bottle_"..row.."_"..i,1.15,.38,CFrame.new(i*1.85,y+.72,-29.5),color,Enum.Material.Glass,bar,false,.08)
 end
end

-- Pendants with warm practical light only.
for _,x in ipairs({-12,-6,0,6,12}) do
 local lamp=cylinder("BarPendant"..x,.50,.78,CFrame.new(x,51.8,-22.0),C.warm,Enum.Material.Glass,bar,false,.12)
 pointLight(lamp,C.warm,.60,10)
end

-- Visible stools + invisible native seat zones.
for _,x in ipairs({-13,-8,-3,3,8,13}) do
 local s=model("BarStool"..x,bar)
 cylinder("StoolCushion",.52,2.55,CFrame.new(x,46.85,-18.85),C.fabricDark,Enum.Material.Fabric,s,true,0)
 cylinder("StoolStem",2.2,.30,CFrame.new(x,45.55,-18.85),C.metal,Enum.Material.Metal,s,true,0)
 cylinder("StoolFoot",.16,2.1,CFrame.new(x,44.55,-18.85),C.metal,Enum.Material.Metal,s,true,0)
 nativeSeat("BarSeat",Vector3.new(x,47.28,-18.85),Vector3.new(x,47.28,-24),Vector3.new(2.3,.30,2.3),s)
end

-- -----------------------------------------------------------------------------
-- 6) SUNSET SOCIAL LOUNGE + FIRE FOCAL
-- -----------------------------------------------------------------------------
local sunset=model("SunsetSocialLoungeV3")
local function loungeCluster(name,x,z)
 local m=model(name,sunset)
 cylinder("LowTable",.38,3.8,CFrame.new(x,46.0,z),C.limestone,Enum.Material.Marble,m,true,0)
 for i,a in ipairs({0,120,240}) do
  local r=math.rad(a)
  local px=x+math.cos(r)*4.4
  local pz=z+math.sin(r)*4.4
  local target=Vector3.new(x,46,z)
  local cf=CFrame.lookAt(Vector3.new(px,45.55,pz),target)
  cylinder("ChairBase"..i,.46,3.1,cf,C.teakDark,Enum.Material.WoodPlanks,m,true,0)
  part("ChairCushion"..i,Vector3.new(2.7,.38,2.7),cf*CFrame.new(0,.55,0),C.fabric,Enum.Material.Fabric,0,true,m)
  part("ChairBack"..i,Vector3.new(2.7,2.15,.42),cf*CFrame.new(0,1.55,1.18)*CFrame.Angles(math.rad(-12),0,0),C.fabricDark,Enum.Material.Fabric,0,true,m)
  nativeSeat("LoungeSeat"..i,(cf*CFrame.new(0,.95,0)).Position,target,Vector3.new(2.4,.28,2.4),m)
 end
end
loungeCluster("SunsetLoungeWest",-30,-36)
loungeCluster("SunsetLoungeEast",30,-36)

local fireBase=cylinder("FireBowl",1.0,5.4,CFrame.new(0,45.9,-37),C.charcoal,Enum.Material.Concrete,sunset,true,0)
local fire=Instance.new("Fire")
fire.Color=C.fire
fire.SecondaryColor=Color3.fromRGB(255,205,112)
fire.Heat=4
fire.Size=3.6
fire.Parent=fireBase
pointLight(fireBase,C.fire,.85,13)

-- -----------------------------------------------------------------------------
-- 7) LANDSCAPE + HOSPITALITY DETAILS
-- -----------------------------------------------------------------------------
local landscape=model("RooftopLandscapeV3")
local function planter(name,pos,scale)
 scale=scale or 1
 local m=model(name,landscape)
 cylinder("Pot",2.5*scale,3.2*scale,CFrame.new(pos.X,46.4,pos.Z),C.concrete,Enum.Material.Concrete,m,true,0)
 cylinder("Trunk",3.9*scale,.40*scale,CFrame.new(pos.X,48.5,pos.Z),C.teakDark,Enum.Material.Wood,m,false,0)
 for i=1,9 do
  local a=math.rad((i-1)*40)
  local col=(i%2==0) and C.leaf or C.leaf2
  local leaf=part("Leaf"..i,Vector3.new(.38*scale,2.4*scale,.80*scale),CFrame.new(pos.X+math.cos(a)*1.05*scale,50.4,pos.Z+math.sin(a)*1.05*scale)*CFrame.Angles(math.rad(20),-a,0),col,Enum.Material.SmoothPlastic,0,false,m)
  leaf.CanQuery=false
 end
end
for i,pos in ipairs({
 Vector3.new(-53,0,-29),Vector3.new(-53,0,2),Vector3.new(-53,0,36),
 Vector3.new(53,0,-29),Vector3.new(53,0,2),Vector3.new(53,0,36),
}) do planter("Planter"..i,pos,1) end

-- Towel console + pool shower, small but makes the resort functional.
local service=model("PoolServiceV3")
part("TowelConsole",Vector3.new(7.5,2.2,2.4),CFrame.new(-41,46.2,36),C.teakDark,Enum.Material.WoodPlanks,0,true,service)
for i=1,4 do
 part("Towel"..i,Vector3.new(1.2,.42,1.55),CFrame.new(-43.0+(i-1)*1.35,47.45,36),C.white,Enum.Material.Fabric,0,false,service)
end
for _,x in ipairs({20,24}) do
 part("ShowerPost"..x,Vector3.new(.24,5.2,.24),CFrame.new(x,47.8,34.7),C.metal,Enum.Material.Metal,0,true,service)
 local head=cylinder("ShowerHead"..x,.16,1.1,CFrame.new(x,50.25,34.1),C.metal,Enum.Material.Metal,service,false,0)
 head.CFrame=CFrame.new(x,50.25,34.1)*CFrame.Angles(math.rad(90),0,0)
end

-- Low practical bollards along sunset deck; local light only.
for _,x in ipairs({-48,-36,-18,18,36,48}) do
 local bollard=part("DeckBollard"..x,Vector3.new(.42,1.45,.42),CFrame.new(x,45.95,-43.2),C.metal,Enum.Material.Metal,0,true,landscape)
 local lens=part("BollardLens"..x,Vector3.new(.30,.34,.30),CFrame.new(x,46.48,-43.2),C.warm,Enum.Material.Glass,.12,false,landscape)
 pointLight(lens,C.warm,.28,7)
end

-- -----------------------------------------------------------------------------
-- 8) ARRIVAL / TELEPORT SAFE LANDING
-- -----------------------------------------------------------------------------
local arrival=model("RooftopArrivalV3")
local pad=part("RooftopArrival",Vector3.new(9,.18,9),CFrame.new(43,45.28,-28),C.limestoneDark,Enum.Material.Marble,.05,true,arrival)
pad.CanQuery=false
part("ArrivalBench",Vector3.new(8,.58,2.2),CFrame.new(48,45.85,-36),C.teakDark,Enum.Material.WoodPlanks,0,true,arrival)
part("ArrivalCushion",Vector3.new(7.5,.36,1.8),CFrame.new(48,46.32,-36),C.fabricWarm,Enum.Material.Fabric,0,true,arrival)
nativeSeat("ArrivalSeat",Vector3.new(48,46.68,-36),Vector3.new(43,46,-28),Vector3.new(6.8,.28,1.7),arrival)

roof:SetAttribute("NativeSeatCount",seatCount)
roof:SetAttribute("RooftopProfile","PREMIUM_SKY_RESORT_V3")
print(string.format("[BBYA] Rooftop Resort Premium v3 online: Terrain infinity pool / interactive seating %d / cabanas / bar / sunset lounge / local lighting only",seatCount))
