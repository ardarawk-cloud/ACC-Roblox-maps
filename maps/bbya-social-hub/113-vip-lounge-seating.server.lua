-- BBYA SOCIAL HUB — VIP LOUNGE SEATING v2
-- Four black upholstered L-sofa corners with low black tables, rugs, restrained table props and warm wall accents.
-- Late VIP-only decorative pass: preserves rail, precise floor neon, audio, travel, speakers, portal and center circulation.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper=root:WaitForChild("UpperLevels",30)
if not upper then return end
local vip=upper:WaitForChild("L2_VIP_Level",30)
if not vip then return end
local active=vip:WaitForChild("VIPMinimalStanding",30)
if not active then return end

-- Furniture must decorate the final architectural VIP, never race the enclosure pass.
active:WaitForChild("VIPPrivateClubUpgradeV2",30)

for _,name in ipairs({"VIPLoungeSeatingV1","VIPLoungeSeatingV2"}) do
 local old=active:FindFirstChild(name)
 if old then old:Destroy() end
end

local out=Instance.new("Model")
out.Name="VIPLoungeSeatingV2"
out:SetAttribute("Pass","VIP_LOUNGE_SEATING_V2")
out:SetAttribute("LoungeSetCount",4)
out:SetAttribute("Layout","FOUR_CORNER_L_LOUNGES")
out:SetAttribute("RoundedCushions",true)
out:SetAttribute("BlackUpholstery",true)
out:SetAttribute("DarkRugs",true)
out:SetAttribute("TablePropsPerSet",4)
out:SetAttribute("WarmWallAccentPerSet",true)
out:SetAttribute("CenterCirculationPreserved",true)
out:SetAttribute("VIPSystemsUntouched",true)
out.Parent=active

local C={
 black=Color3.fromRGB(9,9,11),
 fabric=Color3.fromRGB(19,19,23),
 fabric2=Color3.fromRGB(27,26,31),
 graphite=Color3.fromRGB(34,35,40),
 metal=Color3.fromRGB(52,53,58),
 glass=Color3.fromRGB(15,16,19),
 rug=Color3.fromRGB(24,22,27),
 rugEdge=Color3.fromRGB(45,40,45),
 brass=Color3.fromRGB(133,101,60),
 warm=Color3.fromRGB(255,220,185),
 bottle=Color3.fromRGB(48,39,31),
}

local function model(name,parent)
 local m=Instance.new("Model");m.Name=name;m.Parent=parent or out;return m
end

local function block(name,size,cf,color,material,transparency,collide,parent)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.black;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=false
 p.CastShadow=transparency~=1 and material~=Enum.Material.Neon;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or out
 return p
end

local function verticalCylinder(name,height,diameter,cf,color,material,transparency,parent)
 local p=block(name,Vector3.new(height,diameter,diameter),cf*CFrame.Angles(0,0,math.rad(90)),color,material,transparency,false,parent)
 p.Shape=Enum.PartType.Cylinder
 return p
end

-- Sphere meshes stretched into soft ellipsoids avoid the rigid/Minecraft sofa silhouette.
local function softEllipsoid(name,scale,cf,color,parent)
 local p=block(name,Vector3.new(1,1,1),cf,color or C.fabric,Enum.Material.Fabric,0,false,parent)
 local mesh=Instance.new("SpecialMesh")
 mesh.MeshType=Enum.MeshType.Sphere
 mesh.Scale=scale
 mesh.Parent=p
 return p
end

local function seatBase(name,cf,parent)
 local s=Instance.new("Seat")
 s.Name=name;s.Size=Vector3.new(4.0,.52,3.25);s.CFrame=cf;s.Transparency=1;s.Anchored=true
 s.CanCollide=true;s.CanTouch=true;s.CanQuery=false;s.CastShadow=false;s.Parent=parent
 return s
end

local function makeRug(parent,cf,width,depth)
 local rug=model("DarkLoungeRug",parent)
 block("RugField",Vector3.new(width,.07,depth),cf*CFrame.new(0,.035,0),C.rug,Enum.Material.Fabric,0,false,rug)
 -- very thin graphite/brass edge gives the rug a finished private-club look without bright neon.
 block("EdgeNorth",Vector3.new(width,.035,.07),cf*CFrame.new(0,.075,-depth/2+.05),C.rugEdge,Enum.Material.Metal,0,false,rug)
 block("EdgeSouth",Vector3.new(width,.035,.07),cf*CFrame.new(0,.075,depth/2-.05),C.rugEdge,Enum.Material.Metal,0,false,rug)
 return rug
end

local function addTableProps(tableModel,baseCF,mirror)
 local props=model("TableDetail",tableModel)
 -- recessed serving tray
 block("Tray",Vector3.new(2.55,.10,1.55),baseCF*CFrame.new(-.55*mirror,1.48,.15),C.metal,Enum.Material.Metal,0,false,props)
 -- one dark bottle with small neck/cap
 verticalCylinder("BottleBody",1.28,.66,baseCF*CFrame.new(.45*mirror,2.06,.15),C.bottle,Enum.Material.Glass,.12,props)
 verticalCylinder("BottleNeck",.42,.30,baseCF*CFrame.new(.45*mirror,2.86,.15),C.bottle,Enum.Material.Glass,.08,props)
 verticalCylinder("BottleCap",.12,.32,baseCF*CFrame.new(.45*mirror,3.12,.15),C.brass,Enum.Material.Metal,0,props)
 -- two compact glasses; translucent and low so the tables stay uncluttered.
 for i,offset in ipairs({-.65,.05}) do
  local g=verticalCylinder("Glass"..i,.62,.48,baseCF*CFrame.new(offset*mirror,1.86,-.35),Color3.fromRGB(188,196,203),Enum.Material.Glass,.50,props)
  g.Reflectance=.06
 end
 return props
end

local function makeTable(parent,cf,mirror)
 local t=model("LowSquareTable",parent)
 local top=block("Top",Vector3.new(5.25,.34,5.25),cf*CFrame.new(0,1.22,0),C.glass,Enum.Material.Glass,.08,true,t)
 top.Reflectance=.09
 block("UnderTop",Vector3.new(4.70,.18,4.70),cf*CFrame.new(0,1.00,0),C.black,Enum.Material.Metal,0,false,t)
 block("Pedestal",Vector3.new(1.12,1.02,1.12),cf*CFrame.new(0,.45,0),C.black,Enum.Material.Metal,0,true,t)
 block("Foot",Vector3.new(3.0,.16,3.0),cf*CFrame.new(0,.05,0),C.metal,Enum.Material.Metal,0,false,t)
 addTableProps(t,cf,mirror)
 return t
end

local function addWallAccent(parent,x,z,endSign)
 local m=model("WarmWallAccent",parent)
 -- fixture remains on the outer wall and uses warm light only; no global Lighting edits.
 block("Backplate",Vector3.new(4.6,.22,.24),CFrame.new(x,31.65,z),C.black,Enum.Material.Metal,0,false,m)
 local bar=block("ChampagneBar",Vector3.new(3.6,.12,.16),CFrame.new(x,31.65,z-endSign*.16),C.brass,Enum.Material.Neon,.12,false,m)
 bar.CastShadow=false
 local emitter=block("WarmEmitter",Vector3.new(.18,.18,.18),CFrame.new(x,31.15,z-endSign*.46),C.black,Enum.Material.SmoothPlastic,1,false,m)
 local light=Instance.new("PointLight")
 light.Name="LoungeWarmWash";light.Color=C.warm;light.Brightness=.48;light.Range=11;light.Shadows=false;light.Parent=emitter
 return m
end

local function backCushion(parent,name,pos,yaw)
 local cf=CFrame.new(pos)*CFrame.Angles(math.rad(-7),math.rad(yaw),0)
 return softEllipsoid(name,Vector3.new(4.20,2.42,1.04),cf,C.fabric2,parent)
end

local function seatCushion(parent,name,pos,yaw,index)
 local cf=CFrame.new(pos)*CFrame.Angles(0,math.rad(yaw),0)
 softEllipsoid(name,Vector3.new(4.15,1.36,3.58),cf,(index%2==0) and C.fabric2 or C.fabric,parent)
 seatBase(name.."Seat",cf*CFrame.new(0,-.33,0),parent)
end

local function arm(parent,name,pos,yaw)
 softEllipsoid(name,Vector3.new(1.22,1.82,3.62),CFrame.new(pos)*CFrame.Angles(0,math.rad(yaw),0),C.fabric2,parent)
end

local function buildLounge(name,side,endSign,frontCompact)
 -- side: -1 west / +1 east. endSign: +1 rear / -1 front.
 -- Every set hugs the OUTER walls, keeping the inner rail/circulation ring clear.
 local lounge=model(name,out)
 local cx=side*(frontCompact and 42.0 or 41.0)
 local outerX=side*52.2
 local wallZ=endSign*40.2
 local returnCenterZ=endSign*34.8
 local mainYaw=(endSign==1) and 0 or 180
 local returnYaw=(side==1) and 90 or -90

 -- dark collision plinths are recessed beneath the soft cushions.
 block("MainPlinth",Vector3.new(frontCompact and 18.0 or 18.8,.60,4.35),CFrame.new(cx,25.23,wallZ),C.black,Enum.Material.Metal,0,true,lounge)
 block("ReturnPlinth",Vector3.new(4.35,.60,frontCompact and 10.4 or 11.2),CFrame.new(outerX,25.23,returnCenterZ),C.black,Enum.Material.Metal,0,true,lounge)

 -- four individual upholstered seats on the long wall run.
 for i=1,4 do
  local spacing=frontCompact and 4.15 or 4.40
  local x=cx-(1.5*spacing)+(i-1)*spacing
  seatCushion(lounge,"MainSeat"..i,Vector3.new(x,25.99,wallZ-endSign*.20),mainYaw,i)
  backCushion(lounge,"MainBack"..i,Vector3.new(x,27.62,wallZ+endSign*2.12),mainYaw)
 end

 -- two-seat return forms the L against the side wall.
 local returnStart=frontCompact and 31.8 or 31.8
 local returnSpacing=frontCompact and 4.05 or 4.30
 for i=1,2 do
  local z=endSign*(returnStart+(i-1)*returnSpacing)
  seatCushion(lounge,"ReturnSeat"..i,Vector3.new(outerX-side*.05,25.99,z),returnYaw,i)
  local backX=outerX+side*2.12
  backCushion(lounge,"ReturnBack"..i,Vector3.new(backX,27.62,z),returnYaw)
 end

 -- rounded terminal arms and loose pillows keep the silhouette soft.
 arm(lounge,"InnerArm",Vector3.new(cx-side*(frontCompact and 8.55 or 9.10),26.52,wallZ-endSign*.15),mainYaw)
 arm(lounge,"ReturnArm",Vector3.new(outerX,26.52,endSign*29.45),returnYaw)
 softEllipsoid("LoosePillowA",Vector3.new(2.02,1.62,.70),CFrame.new(cx-side*2.7,27.20,wallZ+endSign*1.22)*CFrame.Angles(0,math.rad(side*12),math.rad(side*7)),C.fabric2,lounge)
 softEllipsoid("LoosePillowB",Vector3.new(1.82,1.52,.66),CFrame.new(outerX-side*.34,27.18,endSign*35.9)*CFrame.Angles(math.rad(-4),math.rad(returnYaw),math.rad(-side*8)),C.fabric,lounge)

 -- subdued champagne trim under the main plinth: premium accent, not a neon strip.
 block("PlinthAccent",Vector3.new(frontCompact and 16.8 or 17.6,.07,.07),CFrame.new(cx,25.48,wallZ-endSign*2.22),C.brass,Enum.Material.Metal,0,false,lounge)

 -- rug/table stay on the outer half of the walking ring, preserving the inner rail path.
 local tableX=side*(frontCompact and 43.2 or 41.0)
 local tableZ=endSign*(frontCompact and 32.7 or 31.2)
 local rugX=side*(frontCompact and 43.0 or 41.5)
 local rugZ=endSign*(frontCompact and 33.4 or 32.7)
 makeRug(lounge,CFrame.new(rugX,25.005,rugZ),frontCompact and 15.5 or 17.5,frontCompact and 7.6 or 9.2)
 makeTable(lounge,CFrame.new(tableX,25.0,tableZ),side)

 -- one low-intensity architectural wall wash per lounge.
 addWallAccent(lounge,cx,endSign*43.22,endSign)

 lounge:SetAttribute("SeatCount",6)
 lounge:SetAttribute("WallHugging",true)
 lounge:SetAttribute("FrontCompact",frontCompact==true)
 lounge:SetAttribute("TableProps",4)
 return lounge
end

-- Rear sets are full-size; front sets are slightly tighter so the central portal remains visually/open physically clear.
buildLounge("NW_Lounge",-1,1,false)
buildLounge("NE_Lounge",1,1,false)
buildLounge("SW_Lounge",-1,-1,true)
buildLounge("SE_Lounge",1,-1,true)

active:SetAttribute("StandingOnly",false)
active:SetAttribute("VIPFurnitureMode","FOUR_CORNER_L_LOUNGES_V2")
active:SetAttribute("VIPLoungeSeatCount",24)
active:SetAttribute("VIPLoungeTableCount",4)
active:SetAttribute("VIPLoungeRugCount",4)
active:SetAttribute("VIPLoungeWarmAccentCount",4)
out:SetAttribute("SeatCount",24)
out:SetAttribute("TableCount",4)
out:SetAttribute("RugCount",4)
out:SetAttribute("WarmAccentCount",4)
out:SetAttribute("ApproxTablePropCount",16)

print("[BBYA] VIP Lounge Seating v2 online: 4 rounded black L-sofas / 24 seats / 4 detailed tables / 4 rugs / 4 warm wall accents")
