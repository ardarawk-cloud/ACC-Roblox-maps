-- BBYA SOCIAL HUB — MALL ARCHITECTURE REALISM v3
-- Architectural realism pass for BBYA Mall.
-- Goal: remove the large flat / boxy silhouette without replacing working Mall systems.
-- Adds layered facade depth, storefront portals, roof silhouette, plaza micro-detail,
-- street furniture and restrained vegetation. Mobile-conscious and local-light only.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",60)
if not root then return end

local mall=root:WaitForChild("BBYAMall",90)
if not mall then return end
local live=mall:WaitForChild("MallLiveUpgradeV2",120)
local atr=mall:WaitForChild("AtriumExperience",90)
if not live or not atr then
 warn("[BBYA] Mall Architecture v3: base/live Mall unavailable")
 return
end

-- The base Mall publishes its model early, while tenant construction continues.
-- Wait for one representative storefront before styling the full tenant set.
mall:WaitForChild("Tenant_luma",45)
task.wait(1.5)

local old=mall:FindFirstChild("MallArchitectureV3")
if old then old:Destroy() end
local out=Instance.new("Model")
out.Name="MallArchitectureV3"
out:SetAttribute("Pass","MALL_ARCHITECTURE_REALISM_V3")
out:SetAttribute("BoxyFacadeReduced",true)
out:SetAttribute("LayeredFacade",true)
out:SetAttribute("StorefrontDepth",true)
out:SetAttribute("RoofSilhouette",true)
out:SetAttribute("ArrivalMicroDetail",true)
out:SetAttribute("MobileBudgetAware",true)
out:SetAttribute("GlobalLightingUntouched",true)
out.Parent=mall

local C={
 black=Color3.fromRGB(10,11,13),
 ink=Color3.fromRGB(19,20,23),
 charcoal=Color3.fromRGB(34,35,39),
 graphite=Color3.fromRGB(55,58,64),
 metal=Color3.fromRGB(88,92,98),
 brushed=Color3.fromRGB(116,118,121),
 stone=Color3.fromRGB(112,107,101),
 limestone=Color3.fromRGB(161,156,146),
 glass=Color3.fromRGB(97,120,131),
 brass=Color3.fromRGB(189,148,86),
 champagne=Color3.fromRGB(220,184,119),
 warm=Color3.fromRGB(255,224,189),
 fabric=Color3.fromRGB(49,47,52),
 wood=Color3.fromRGB(104,77,57),
 leaf=Color3.fromRGB(58,91,64),
 soil=Color3.fromRGB(59,47,38),
 white=Color3.fromRGB(238,239,241),
}

local function model(name,parent)
 local m=Instance.new("Model")
 m.Name=name
 m.Parent=parent or out
 return m
end

local function part(name,size,cf,color,material,collide,parent,transparency)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.CFrame=cf
 p.Color=color or C.graphite
 p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0
 p.Anchored=true
 p.CanCollide=collide==true
 p.CanTouch=false
 p.CanQuery=true
 p.CastShadow=p.Material~=Enum.Material.Neon and p.Transparency<.9
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or out
 return p
end

local function neon(name,size,cf,color,parent,transparency)
 local p=part(name,size,cf,color or C.champagne,Enum.Material.Neon,false,parent,transparency or 0)
 p.CastShadow=false
 return p
end

local function cylinder(name,size,cf,color,material,collide,parent,transparency)
 local p=part(name,size,cf,color,material,collide,parent,transparency)
 p.Shape=Enum.PartType.Cylinder
 return p
end

local function ball(name,size,cf,color,material,collide,parent,transparency)
 local p=part(name,size,cf,color,material,collide,parent,transparency)
 p.Shape=Enum.PartType.Ball
 return p
end

local function localPoint(parent,color,brightness,range)
 local l=Instance.new("PointLight")
 l.Name="MallArchitectureLocalLight"
 l.Color=color or C.warm
 l.Brightness=brightness or .35
 l.Range=range or 8
 l.Shadows=false
 l.Parent=parent
 return l
end

local function planterCluster(name,x,z,scale,parent)
 scale=scale or 1
 local m=model(name,parent)
 cylinder("Planter",Vector3.new(1.6*scale,4.4*scale,4.4*scale),CFrame.new(x,1.75,z)*CFrame.Angles(0,0,math.rad(90)),C.charcoal,Enum.Material.Concrete,true,m)
 cylinder("Soil",Vector3.new(.25*scale,3.8*scale,3.8*scale),CFrame.new(x,2.60,z)*CFrame.Angles(0,0,math.rad(90)),C.soil,Enum.Material.Ground,false,m)
 for i=1,5 do
  local a=math.rad((i-1)*72)
  local px=x+math.cos(a)*.72*scale
  local pz=z+math.sin(a)*.72*scale
  part("Stem"..i,Vector3.new(.16*scale,2.3*scale,.16*scale),CFrame.new(px,3.75,pz),C.wood,Enum.Material.Wood,false,m)
  ball("Leaf"..i,Vector3.new(1.25,1.85,1.05)*scale,CFrame.new(px,5.0+((i%2)*.28),pz),C.leaf,Enum.Material.SmoothPlastic,false,m)
 end
 return m
end

local function bench(name,x,z,yaw,parent)
 local m=model(name,parent)
 local cf=CFrame.new(x,1.30,z)*CFrame.Angles(0,math.rad(yaw),0)
 local s=Instance.new("Seat")
 s.Name="Seat"
 s.Size=Vector3.new(7.2,.65,2.3)
 s.CFrame=cf
 s.Color=C.fabric
 s.Material=Enum.Material.Fabric
 s.Anchored=true
 s.CanCollide=true
 s.CanTouch=true
 s.TopSurface=Enum.SurfaceType.Smooth
 s.BottomSurface=Enum.SurfaceType.Smooth
 s.Parent=m
 part("Back",Vector3.new(7.2,2.1,.42),cf*CFrame.new(0,1.15,1.02)*CFrame.Angles(math.rad(-7),0,0),C.fabric,Enum.Material.Fabric,true,m)
 for _,xoff in ipairs({-3.2,3.2}) do
  part("Leg"..xoff,Vector3.new(.35,.85,.35),cf*CFrame.new(xoff,-.55,0),C.brass,Enum.Material.Metal,true,m)
 end
 return m
end

-- =============================================================================
-- 1) ATRIUM SCULPTURE: OPEN FRAME, NEVER SOLID CYLINDER WALLS
-- =============================================================================
for _,d in ipairs(atr:GetChildren()) do
 if d.Name:match("^SculptureRing") or d.Name:match("^OpenFrame") then d:Destroy() end
end
local sculpture=model("OpenAtriumSculptureV3",out)
local sculptColors={C.champagne,Color3.fromRGB(222,72,151),Color3.fromRGB(58,188,211)}
for i=1,3 do
 local half=5+i*2
 local y=7+i*5
 local rot=CFrame.Angles(0,math.rad(18*i),math.rad(45))
 local center=CFrame.new(0,y,365)*rot
 neon("FrameTop"..i,Vector3.new(half*2,.24,.24),center*CFrame.new(0,half,0),sculptColors[i],sculpture,.08)
 neon("FrameBottom"..i,Vector3.new(half*2,.24,.24),center*CFrame.new(0,-half,0),sculptColors[i],sculpture,.08)
 neon("FrameLeft"..i,Vector3.new(.24,half*2,.24),center*CFrame.new(-half,0,0),sculptColors[i],sculpture,.08)
 neon("FrameRight"..i,Vector3.new(.24,half*2,.24),center*CFrame.new(half,0,0),sculptColors[i],sculpture,.08)
end

-- =============================================================================
-- 2) FRONT FACADE: BREAK THE SINGLE FLAT GLASS PLANE INTO ARCHITECTURAL BAYS
-- Base glass remains for weather enclosure; this pass gives it depth and hierarchy.
-- =============================================================================
local facade=model("LayeredFrontFacadeV3",out)
local frontZ=286.65

for _,name in ipairs({"FrontGlassLeft","FrontGlassRight"}) do
 local g=mall:FindFirstChild(name)
 if g and g:IsA("BasePart") then
  g.Color=C.glass
  g.Transparency=.38
  g.Reflectance=.08
 end
end

-- Slim existing fins; the old full-depth fins read like giant prison bars on phone.
for _,d in ipairs(mall:GetChildren()) do
 if d:IsA("BasePart") and d.Name:match("^FrontFin") then
  d.Size=Vector3.new(.72,55,1.15)
  d.Color=C.graphite
  d.Material=Enum.Material.Metal
 end
end

-- Horizontal floor bands / spandrels establish four readable levels without blocking views.
for i,y in ipairs({14.0,28.0,42.0}) do
 for _,spec in ipairs({{-55,72},{55,72}}) do
  part("Spandrel"..i.."_"..spec[1],Vector3.new(spec[2],1.05,1.25),CFrame.new(spec[1],y,frontZ),C.ink,Enum.Material.Metal,false,facade,.04)
  part("SpandrelCap"..i.."_"..spec[1],Vector3.new(spec[2]-3,.10,1.36),CFrame.new(spec[1],y+.62,frontZ-.08),C.brass,Enum.Material.Metal,false,facade)
 end
end

-- Central arrival portal is deliberately shallow: strong silhouette, no obstruction.
for _,x in ipairs({-22.5,22.5}) do
 part("ArrivalPier"..x,Vector3.new(2.2,34,3.0),CFrame.new(x,20.0,frontZ-.45),C.charcoal,Enum.Material.Metal,false,facade)
 part("ArrivalPierFace"..x,Vector3.new(2.55,27,.28),CFrame.new(x,20.0,frontZ-2.0),C.limestone,Enum.Material.Slate,false,facade)
 neon("ArrivalPierReveal"..x,Vector3.new(.12,22,.10),CFrame.new(x+(x<0 and 1.42 or -1.42),19.5,frontZ-2.22),C.champagne,facade,.16)
end
part("ArrivalPortalHeader",Vector3.new(47,2.0,3.0),CFrame.new(0,36.6,frontZ-.45),C.charcoal,Enum.Material.Metal,false,facade)
part("ArrivalPortalSoffit",Vector3.new(41,.22,2.2),CFrame.new(0,35.45,frontZ-1.0),C.black,Enum.Material.Metal,false,facade)
neon("ArrivalHeaderReveal",Vector3.new(35,.10,.12),CFrame.new(0,35.15,frontZ-2.15),C.champagne,facade,.16)

-- Angled outer fins create a stepped facade instead of a single rectangular face.
for _,spec in ipairs({{-43,-12},{43,12},{-72,-8},{72,8}}) do
 local x,yaw=spec[1],spec[2]
 part("AngledFacadeBlade"..x,Vector3.new(1.0,43,8.0),CFrame.new(x,26,287.4)*CFrame.Angles(0,math.rad(yaw),0),C.graphite,Enum.Material.Metal,false,facade)
 part("BladeCap"..x,Vector3.new(1.12,.18,7.5),CFrame.new(x,47.6,287.4)*CFrame.Angles(0,math.rad(yaw),0),C.brass,Enum.Material.Metal,false,facade)
end

-- Top cornice and crown blades break the roofline silhouette.
part("FrontCornice",Vector3.new(178,.72,2.3),CFrame.new(0,55.4,287.4),C.charcoal,Enum.Material.Metal,false,facade)
part("CorniceReveal",Vector3.new(166,.10,.16),CFrame.new(0,54.95,286.15),C.champagne,Enum.Material.Metal,false,facade)
for _,x in ipairs({-58,58}) do
 part("RoofBlade"..x,Vector3.new(5.2,9.5,3.2),CFrame.new(x,61.8,289.0),C.ink,Enum.Material.Metal,false,facade)
 part("RoofBladeFace"..x,Vector3.new(4.25,7.0,.22),CFrame.new(x,61.8,287.3),C.limestone,Enum.Material.Slate,false,facade)
end
part("RoofCrownCenter",Vector3.new(48,2.1,3.2),CFrame.new(0,59.8,289.0),C.ink,Enum.Material.Metal,false,facade)

-- =============================================================================
-- 3) SIDE / REAR SHELL RHYTHM
-- Keep solid weather walls but add pilasters and shadow bands so they do not read as boxes.
-- =============================================================================
local shell=model("ExteriorShellDepthV3",out)
for _,x in ipairs({-95.9,95.9}) do
 local sign=x<0 and -1 or 1
 for _,z in ipairs({320,350,380,410}) do
  part("SidePilaster"..x.."_"..z,Vector3.new(1.2,46,2.4),CFrame.new(x-sign*.35,25,z),C.graphite,Enum.Material.Metal,false,shell)
  part("SidePilasterCap"..x.."_"..z,Vector3.new(1.4,.16,3.0),CFrame.new(x-sign*.42,48.1,z),C.brass,Enum.Material.Metal,false,shell)
 end
 part("SideDatum"..x,Vector3.new(1.1,.18,124),CFrame.new(x-sign*.42,14.0,365),C.brass,Enum.Material.Metal,false,shell)
 part("SideDatumUpper"..x,Vector3.new(1.1,.18,124),CFrame.new(x-sign*.42,42.0,365),C.brass,Enum.Material.Metal,false,shell)
end
for _,x in ipairs({-72,-36,0,36,72}) do
 part("RearPilaster"..x,Vector3.new(2.5,44,1.0),CFrame.new(x,25,443.8),C.graphite,Enum.Material.Metal,false,shell)
end
part("RearCornice",Vector3.new(176,.70,2.1),CFrame.new(0,53.8,443.8),C.charcoal,Enum.Material.Metal,false,shell)

-- =============================================================================
-- 4) STOREFRONTS: TURN FLAT GLASS BOXES INTO RECESSED RETAIL PORTALS
-- Existing interactions, counters and doors remain untouched.
-- =============================================================================
local storefronts=model("StorefrontDepthV3",out)
for _,unit in ipairs(mall:GetChildren()) do
 if unit:IsA("Model") and unit.Name:match("^Tenant_") then
  local storeGlass=unit:FindFirstChild("StoreGlass")
  local door=unit:FindFirstChild("StoreDoor")
  local signPart=unit:FindFirstChild("StoreSign")
  if storeGlass and storeGlass:IsA("BasePart") and door and door:IsA("BasePart") then
   local accent=(signPart and signPart:IsA("BasePart")) and signPart.Color or C.champagne
   storeGlass.Color=C.glass
   storeGlass.Transparency=.43
   storeGlass.Reflectance=.06
   door.Color=Color3.fromRGB(117,142,151)
   door.Transparency=.30
   door.Reflectance=.07

   local x=storeGlass.Position.X
   local y=storeGlass.Position.Y
   local z=storeGlass.Position.Z
   local inward=x<0 and 1 or -1
   local parent=model(unit.Name.."_Portal",storefronts)

   part("PortalJambA",Vector3.new(.72,10.2,.62),CFrame.new(x+inward*.28,y+.4,z-9.7),C.charcoal,Enum.Material.Metal,false,parent)
   part("PortalJambB",Vector3.new(.72,10.2,.62),CFrame.new(x+inward*.28,y+.4,z+9.7),C.charcoal,Enum.Material.Metal,false,parent)
   part("PortalHead",Vector3.new(.72,.70,19.8),CFrame.new(x+inward*.28,y+5.2,z),C.charcoal,Enum.Material.Metal,false,parent)
   part("StonePlinth",Vector3.new(.82,.42,19.0),CFrame.new(x+inward*.34,y-4.30,z),C.stone,Enum.Material.Slate,false,parent)
   local canopy=part("StoreCanopy",Vector3.new(2.5,.24,8.2),CFrame.new(x+inward*1.05,y+4.0,z),C.ink,Enum.Material.Metal,false,parent)
   neon("BrandReveal",Vector3.new(.12,.10,17.2),CFrame.new(x+inward*.72,y+4.78,z),accent,parent,.12)
   local task=part("CanopyTask",Vector3.new(.10,.10,.10),canopy.CFrame*CFrame.new(inward*.95,-.18,0),C.warm,Enum.Material.Neon,false,parent,.92)
   task.CastShadow=false
   localPoint(task,C.warm,.10,3.6)

   if signPart and signPart:IsA("BasePart") then
    signPart.Color=C.ink
    signPart.Material=Enum.Material.Metal
    signPart.Transparency=0
   end
  end
 end
end

-- =============================================================================
-- 5) ARRIVAL PLAZA MICRO-DETAIL / HOSPITALITY
-- No new driving system; only physical cues that make the forecourt believable.
-- =============================================================================
local plaza=model("ArrivalPlazaRealismV3",out)
-- Drainage channels along the two drop-off lanes.
for _,x in ipairs({-54,54}) do
 part("DrainChannel"..x,Vector3.new(50,.08,.55),CFrame.new(x,1.10,282.0),Color3.fromRGB(48,49,51),Enum.Material.DiamondPlate,false,plaza)
 for i=1,5 do
  part("DrainSlot"..x.."_"..i,Vector3.new(7.2,.035,.08),CFrame.new(x-20+(i-1)*10,1.15,282.0),C.black,Enum.Material.Metal,false,plaza)
 end
end

-- Pedestrian paving bands frame the central connector without blocking it.
for _,x in ipairs({-42,42}) do
 for _,z in ipairs({288,293,298}) do
  part("PaverBand"..x.."_"..z,Vector3.new(26,.045,.18),CFrame.new(x,1.02,z),C.limestone,Enum.Material.Slate,false,plaza)
 end
end

-- Functional benches and restrained planting on the safe edge of the plaza.
bench("PlazaBenchL",-68,294,90,plaza)
bench("PlazaBenchR",68,294,-90,plaza)
planterCluster("PlazaPlantL1",-82,294,1.0,plaza)
planterCluster("PlazaPlantR1",82,294,1.0,plaza)
planterCluster("PlazaPlantL2",-48,301,.9,plaza)
planterCluster("PlazaPlantR2",48,301,.9,plaza)

-- Litter bins / hospitality micro-detail.
for _,x in ipairs({-58,58}) do
 cylinder("WasteBin"..x,Vector3.new(2.6,1.25,1.25),CFrame.new(x,2.05,299)*CFrame.Angles(0,0,math.rad(90)),C.graphite,Enum.Material.Metal,true,plaza)
 part("BinTop"..x,Vector3.new(.18,1.42,1.42),CFrame.new(x,3.38,299)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,false,plaza)
end

-- Low road reflectors: visible detail, no light instances.
for _,x in ipairs({-74,-62,-50,-38,38,50,62,74}) do
 neon("RoadReflector"..x,Vector3.new(1.3,.06,.16),CFrame.new(x,1.13,267.7),C.white,plaza,.30)
end

-- =============================================================================
-- 6) MOBILE / PERFORMANCE GUARDRAILS
-- Decorative facade pieces never participate in touch/query-heavy gameplay.
-- =============================================================================
for _,d in ipairs(out:GetDescendants()) do
 if d:IsA("BasePart") and not d:IsA("Seat") then
  if d.Name:match("Reveal") or d.Name:match("Cap") or d.Name:match("Spandrel") or d.Name:match("Blade")
   or d.Name:match("Cornice") or d.Name:match("Datum") or d.Name:match("Paver") or d.Name:match("RoadReflector")
   or d.Name:match("DrainSlot") or d.Name:match("Frame") then
   d.CanCollide=false
   d.CanTouch=false
   d.CanQuery=false
  end
 end
end

print("[BBYA] Mall Architecture Realism v3 online: layered facade/storefronts/roofline/plaza detail added; global Lighting untouched")
