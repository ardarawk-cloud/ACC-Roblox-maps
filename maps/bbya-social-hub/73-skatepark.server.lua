-- BBYA SOCIAL HUB — PREMIUM SKATE PLAZA v4
-- Native Roblox geometry rebuild: premium concrete street plaza, clean ride lines,
-- modern dark-metal perimeter, restrained champagne accents, and clear teleport apron.
-- Static/mobile-conscious scenery only. No global Lighting writes.
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end

local old=root:FindFirstChild("RearSkatepark")
if old then old:Destroy() end

local m=Instance.new("Model")
m.Name="RearSkatepark"
m.Parent=root
m:SetAttribute("Pass","PREMIUM_SKATE_PLAZA_V4")
m:SetAttribute("TeleportKey","Skatepark")
m:SetAttribute("Layout","PREMIUM_STREET_PLAZA_V4")
m:SetAttribute("TeleportCenterClear",true)
m:SetAttribute("CenterClearanceStuds",24)
m:SetAttribute("MobileLightweight",true)
m:SetAttribute("GlobalLightingWrites",false)
m:SetAttribute("AudioAuthorityUntouched",true)
m:SetAttribute("NativeGeometryOnly",true)

local C={
 concrete=Color3.fromRGB(93,94,96),
 concreteLight=Color3.fromRGB(111,111,110),
 concreteDark=Color3.fromRGB(64,65,68),
 charcoal=Color3.fromRGB(20,21,24),
 metal=Color3.fromRGB(54,57,62),
 metalSoft=Color3.fromRGB(82,85,89),
 champagne=Color3.fromRGB(212,170,92),
 warm=Color3.fromRGB(244,225,190),
 white=Color3.fromRGB(236,235,229),
 wood=Color3.fromRGB(109,78,54),
}

local function part(name,size,cf,color,material,collide,parent,class)
 local p
 if class=="WedgePart" then p=Instance.new("WedgePart")
 elseif class=="CornerWedgePart" then p=Instance.new("CornerWedgePart")
 else p=Instance.new("Part") end
 p.Name=name
 p.Size=size
 p.CFrame=cf
 p.Color=color or C.concrete
 p.Material=material or Enum.Material.Concrete
 p.Anchored=true
 p.CanCollide=collide~=false
 p.CanTouch=false
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or m
 return p
end

local function trim(name,size,cf,parent,color)
 local p=part(name,size,cf,color or C.champagne,Enum.Material.Metal,false,parent)
 p.CastShadow=false
 return p
end

local function rail(name,size,cf,parent,color)
 local p=part(name,size,cf,color or C.metalSoft,Enum.Material.Metal,true,parent)
 p.CastShadow=true
 return p
end

local function sign(name,cf,size,title,sub)
 local backing=part(name,size,cf,C.charcoal,Enum.Material.Metal,false)
 local gui=Instance.new("SurfaceGui")
 gui.Name="PremiumSign"
 gui.Face=Enum.NormalId.Front
 gui.PixelsPerStud=56
 gui.LightInfluence=.25
 gui.Parent=backing
 local line=Instance.new("Frame")
 line.BorderSizePixel=0
 line.BackgroundColor3=C.champagne
 line.Position=UDim2.fromScale(.055,.13)
 line.Size=UDim2.fromScale(.018,.72)
 line.Parent=gui
 local t=Instance.new("TextLabel")
 t.BackgroundTransparency=1
 t.Position=UDim2.fromScale(.105,.12)
 t.Size=UDim2.fromScale(.82,.47)
 t.Text=title
 t.TextXAlignment=Enum.TextXAlignment.Left
 t.TextColor3=C.white
 t.Font=Enum.Font.GothamBlack
 t.TextScaled=true
 t.Parent=gui
 local s=Instance.new("TextLabel")
 s.BackgroundTransparency=1
 s.Position=UDim2.fromScale(.108,.64)
 s.Size=UDim2.fromScale(.76,.15)
 s.Text=sub
 s.TextXAlignment=Enum.TextXAlignment.Left
 s.TextColor3=Color3.fromRGB(173,176,179)
 s.Font=Enum.Font.GothamMedium
 s.TextScaled=true
 s.Parent=gui
 return backing
end

-- SITE / ARRIVAL ---------------------------------------------------------------
part("RearWalk",Vector3.new(20,.55,48),CFrame.new(0,.275,74),C.concreteDark,Enum.Material.Concrete,true)
part("SkateSlab",Vector3.new(126,1,82),CFrame.new(0,.5,112),C.concrete,Enum.Material.Concrete,true)

-- Layered slab lip gives the plaza a deliberate architectural edge.
part("NorthFoundation",Vector3.new(126,2.5,2.2),CFrame.new(0,1.75,152),C.charcoal,Enum.Material.Concrete,true)
part("WestFoundation",Vector3.new(2.2,2.5,80),CFrame.new(-62,1.75,112),C.charcoal,Enum.Material.Concrete,true)
part("EastFoundation",Vector3.new(2.2,2.5,80),CFrame.new(62,1.75,112),C.charcoal,Enum.Material.Concrete,true)
part("SouthFoundationL",Vector3.new(47,2.5,2.2),CFrame.new(-38.5,1.75,72),C.charcoal,Enum.Material.Concrete,true)
part("SouthFoundationR",Vector3.new(47,2.5,2.2),CFrame.new(38.5,1.75,72),C.charcoal,Enum.Material.Concrete,true)

-- Modern open perimeter rail: cleaner and lower-part-count than chain-link mesh.
local perimeter=Instance.new("Model");perimeter.Name="PremiumPerimeter";perimeter.Parent=m
local function fenceH(prefix,z,x0,x1)
 for x=x0,x1,12 do rail(prefix.."Post"..math.floor(x),Vector3.new(.24,5.4,.24),CFrame.new(x,5.7,z),perimeter,C.metal) end
 rail(prefix.."Top",Vector3.new(math.abs(x1-x0)+.2,.20,.20),CFrame.new((x0+x1)/2,8.35,z),perimeter,C.metal)
 rail(prefix.."Mid",Vector3.new(math.abs(x1-x0)+.2,.12,.12),CFrame.new((x0+x1)/2,5.85,z),perimeter,C.metalSoft)
end
local function fenceV(prefix,x,z0,z1)
 for z=z0,z1,12 do rail(prefix.."Post"..math.floor(z),Vector3.new(.24,5.4,.24),CFrame.new(x,5.7,z),perimeter,C.metal) end
 rail(prefix.."Top",Vector3.new(.20,.20,math.abs(z1-z0)+.2),CFrame.new(x,8.35,(z0+z1)/2),perimeter,C.metal)
 rail(prefix.."Mid",Vector3.new(.12,.12,math.abs(z1-z0)+.2),CFrame.new(x,5.85,(z0+z1)/2),perimeter,C.metalSoft)
end
fenceH("North",151.9,-61,61)
fenceH("SouthL",72.1,-61,-15)
fenceH("SouthR",72.1,15,61)
fenceV("West",-61.9,73,151)
fenceV("East",61.9,73,151)

-- Teleport lands at (0,3,112). Keep a full 24x22 obstacle-free apron.
local arrival=part("ArrivalApron",Vector3.new(24,.055,22),CFrame.new(0,1.03,112),C.concreteDark,Enum.Material.SmoothPlastic,false)
arrival.Transparency=.16
trim("ArrivalEdgeL",Vector3.new(.12,.06,20),CFrame.new(-12,1.045,112),m)
trim("ArrivalEdgeR",Vector3.new(.12,.06,20),CFrame.new(12,1.045,112),m)
trim("ArrivalEdgeN",Vector3.new(24,.06,.12),CFrame.new(0,1.045,123),m)

-- SOUTH SIGNATURE STREET SET ---------------------------------------------------
local south=Instance.new("Model");south.Name="SignatureStreetSet";south.Parent=m
-- Broad five stair with darker shadow risers and champagne stair-edge pins.
for i=0,4 do
 local z=81.7+i*2.45
 local y=1.42+i*.46
 part("Stair"..i,Vector3.new(16,.92,3.2),CFrame.new(-13,y,z),i%2==0 and C.concreteLight or C.concreteDark,Enum.Material.Concrete,true,south)
 trim("StairEdge"..i,Vector3.new(16,.07,.12),CFrame.new(-13,y+.49,z-1.52),south,C.metalSoft)
end
-- Center handrail + two architectural hubbas.
rail("StairHandrail",Vector3.new(.32,.32,14.3),CFrame.new(-13,4.05,87.4)*CFrame.Angles(math.rad(-10.5),0,0),south,C.metalSoft)
for _,z in ipairs({81.9,92.8}) do rail("StairRailLeg"..z,Vector3.new(.26,2.9,.26),CFrame.new(-13,2.48,z),south,C.metalSoft) end
part("HubbaWest",Vector3.new(3.2,1.55,14.8),CFrame.new(-22.8,2.15,87.5)*CFrame.Angles(math.rad(-7),0,0),C.concreteDark,Enum.Material.Concrete,true,south)
part("HubbaEast",Vector3.new(3.2,1.55,14.8),CFrame.new(-3.2,2.15,87.5)*CFrame.Angles(math.rad(-7),0,0),C.concreteDark,Enum.Material.Concrete,true,south)
trim("HubbaCopingWest",Vector3.new(.17,.17,14.6),CFrame.new(-21.25,2.98,87.5)*CFrame.Angles(math.rad(-7),0,0),south,C.champagne)
trim("HubbaCopingEast",Vector3.new(.17,.17,14.6),CFrame.new(-4.75,2.98,87.5)*CFrame.Angles(math.rad(-7),0,0),south,C.champagne)

-- WEST FLOW LINE ---------------------------------------------------------------
local west=Instance.new("Model");west.Name="WestFlowLine";west.Parent=m
part("WestBank",Vector3.new(18,5.4,14),CFrame.new(-45,3.2,96)*CFrame.Angles(0,math.rad(180),0),C.concreteDark,Enum.Material.Concrete,true,west,"WedgePart")
part("WestBankDeck",Vector3.new(18,.75,4.6),CFrame.new(-45,5.55,88.1),C.concreteDark,Enum.Material.Concrete,true,west)
trim("WestBankCoping",Vector3.new(18,.18,.25),CFrame.new(-45,5.98,90.25),west,C.champagne)
part("WestManualPad",Vector3.new(19,1.15,11),CFrame.new(-44,1.58,117.5),Color3.fromRGB(69,70,72),Enum.Material.Concrete,true,west)
trim("WestPadCoping",Vector3.new(19,.16,.24),CFrame.new(-44,2.2,112.15),west,C.metalSoft)
rail("WestFlatBar",Vector3.new(.30,.30,19),CFrame.new(-44,2.32,137),west,C.metalSoft)
for _,z in ipairs({129,145}) do rail("WestFlatBarLeg"..z,Vector3.new(.26,2.05,.26),CFrame.new(-44,1.46,z),west,C.metalSoft) end

-- EAST TECH LINE ---------------------------------------------------------------
local east=Instance.new("Model");east.Name="EastTechLine";east.Parent=m
part("EastLedge",Vector3.new(23,1.5,4.4),CFrame.new(38,1.75,91),C.concreteDark,Enum.Material.Concrete,true,east)
trim("EastLedgeCopingFront",Vector3.new(23,.17,.22),CFrame.new(38,2.54,88.93),east,C.champagne)
trim("EastLedgeCopingRear",Vector3.new(23,.14,.18),CFrame.new(38,2.54,93.07),east,C.metalSoft)
part("EastEuroBank",Vector3.new(19,5,15),CFrame.new(41,3.0,113)*CFrame.Angles(0,math.rad(90),0),C.concreteDark,Enum.Material.Concrete,true,east,"WedgePart")
part("EastDeck",Vector3.new(13,1,16),CFrame.new(52,4.1,113),Color3.fromRGB(61,62,65),Enum.Material.Concrete,true,east)
trim("EastDeckEdge",Vector3.new(.20,.18,15.5),CFrame.new(45.55,4.64,113),east,C.champagne)
-- Low technical rail sits beyond the teleport apron.
rail("EastLowRail",Vector3.new(.28,.28,18),CFrame.new(27,2.18,135),east,C.metalSoft)
for _,z in ipairs({128,142}) do rail("EastLowRailLeg"..z,Vector3.new(.24,1.75,.24),CFrame.new(27,1.45,z),east,C.metalSoft) end

-- NORTH RETURN / TRANSITIONS ---------------------------------------------------
local north=Instance.new("Model");north.Name="NorthTransitionReturn";north.Parent=m
-- Two wide bank transitions frame a central premium manual island.
part("NorthBankLeft",Vector3.new(30,7.4,16),CFrame.new(-39,4.2,142),C.concreteDark,Enum.Material.Concrete,true,north,"WedgePart")
part("NorthBankRight",Vector3.new(30,7.4,16),CFrame.new(39,4.2,142),C.concreteDark,Enum.Material.Concrete,true,north,"WedgePart")
part("NorthDeckLeft",Vector3.new(30,.8,4),CFrame.new(-39,7.55,150),C.concreteDark,Enum.Material.Concrete,true,north)
part("NorthDeckRight",Vector3.new(30,.8,4),CFrame.new(39,7.55,150),C.concreteDark,Enum.Material.Concrete,true,north)
trim("NorthCopingLeft",Vector3.new(30,.24,.28),CFrame.new(-39,7.98,148.0),north,C.champagne)
trim("NorthCopingRight",Vector3.new(30,.24,.28),CFrame.new(39,7.98,148.0),north,C.champagne)
part("NorthManualIsland",Vector3.new(18,1.0,8),CFrame.new(0,1.5,138.5),Color3.fromRGB(70,71,73),Enum.Material.Concrete,true,north)
trim("NorthIslandCopingL",Vector3.new(.18,.18,8),CFrame.new(-9,2.05,138.5),north,C.metalSoft)
trim("NorthIslandCopingR",Vector3.new(.18,.18,8),CFrame.new(9,2.05,138.5),north,C.metalSoft)

-- PREMIUM SPECTATOR EDGE -------------------------------------------------------
-- Kept west of the south gate so the existing board rack / spawn line at east stays untouched.
local social=Instance.new("Model");social.Name="PremiumSpectatorEdge";social.Parent=m
part("SpectatorPlinth",Vector3.new(27,.55,4.4),CFrame.new(-43,1.28,76.7),C.concreteDark,Enum.Material.Concrete,true,social)
for i,x in ipairs({-51,-43,-35}) do
 part("BenchSeat"..i,Vector3.new(7.2,.34,1.8),CFrame.new(x,2.05,76.3),C.wood,Enum.Material.WoodPlanks,true,social)
 part("BenchLegA"..i,Vector3.new(.28,1.3,1.35),CFrame.new(x-2.35,1.46,76.3),C.metal,Enum.Material.Metal,true,social)
 part("BenchLegB"..i,Vector3.new(.28,1.3,1.35),CFrame.new(x+2.35,1.46,76.3),C.metal,Enum.Material.Metal,true,social)
end
trim("SpectatorGoldLine",Vector3.new(26,.06,.11),CFrame.new(-43,1.59,74.55),social,C.champagne)

-- Restrained floor wayfinding: visual only, no PointLight and no global Lighting mutation.
local accents=Instance.new("Model");accents.Name="ChampagneWayfinding";accents.Parent=m
for _,spec in ipairs({
 {"WestRun",Vector3.new(.12,.05,37),CFrame.new(-31,1.035,128)},
 {"EastRun",Vector3.new(.12,.05,32),CFrame.new(15,1.035,136)},
 {"SouthRun",Vector3.new(30,.05,.12),CFrame.new(26,1.035,102)},
}) do
 local p=part(spec[1],spec[2],spec[3],C.champagne,Enum.Material.SmoothPlastic,false,accents)
 p.Transparency=.28
 p.CastShadow=false
end

sign("SkateparkSign",CFrame.new(0,6.4,151.35),Vector3.new(31,5.6,.36),"BBYA SKATE PLAZA","CONCRETE • STREET • NIGHT")

m:SetAttribute("FeatureSet","STAIRS_HUBBAS_BANKS_LEDGES_RAILS_MANUAL_TRANSITIONS")
m:SetAttribute("PremiumPerimeter",true)
m:SetAttribute("ChampagneAccent",true)
m:SetAttribute("BoardRackEastSideReserved",true)

print("[BBYA] Premium Skate Plaza v4 online: premium native geometry / center clear / mobile-lightweight")
