-- BBYA SOCIAL HUB — VIP LOUNGE SEATING v3
-- Four black upholstered L-sofa corners with layered rugs, detailed low tables,
-- hidden under-sofa glow, dimensional wall panels and restrained private-club accents.
-- Late VIP-only decorative pass: preserves rail, precise floor neon, audio, travel,
-- speakers, portal and center circulation.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper=root:WaitForChild("UpperLevels",30)
if not upper then return end
local vip=upper:WaitForChild("L2_VIP_Level",30)
if not vip then return end
local active=vip:WaitForChild("VIPMinimalStanding",30)
if not active then return end

active:WaitForChild("VIPPrivateClubUpgradeV2",30)

for _,name in ipairs({"VIPLoungeSeatingV1","VIPLoungeSeatingV2","VIPLoungeSeatingV3"}) do
 local old=active:FindFirstChild(name)
 if old then old:Destroy() end
end

local out=Instance.new("Model")
out.Name="VIPLoungeSeatingV3"
out:SetAttribute("Pass","VIP_LOUNGE_SEATING_V3")
out:SetAttribute("LoungeSetCount",4)
out:SetAttribute("Layout","FOUR_CORNER_L_LOUNGES")
out:SetAttribute("RoundedCushions",true)
out:SetAttribute("BlackUpholstery",true)
out:SetAttribute("LayeredRugs",true)
out:SetAttribute("DetailedTables",true)
out:SetAttribute("HiddenUnderSofaGlow",true)
out:SetAttribute("DimensionalWallPanels",true)
out:SetAttribute("PrivateClubPlaques",true)
out:SetAttribute("CenterCirculationPreserved",true)
out:SetAttribute("VIPSystemsUntouched",true)
out.Parent=active

local C={
 black=Color3.fromRGB(9,9,11),
 fabric=Color3.fromRGB(19,19,23),
 fabric2=Color3.fromRGB(27,26,31),
 accentFabric=Color3.fromRGB(66,57,58),
 graphite=Color3.fromRGB(34,35,40),
 metal=Color3.fromRGB(52,53,58),
 glass=Color3.fromRGB(15,16,19),
 smoked=Color3.fromRGB(33,38,43),
 rug=Color3.fromRGB(24,22,27),
 rugInset=Color3.fromRGB(31,28,34),
 rugEdge=Color3.fromRGB(45,40,45),
 brass=Color3.fromRGB(133,101,60),
 champagne=Color3.fromRGB(184,145,88),
 warm=Color3.fromRGB(255,220,185),
 amber=Color3.fromRGB(255,184,112),
 bottle=Color3.fromRGB(48,39,31),
 ice=Color3.fromRGB(205,220,230),
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
 local rug=model("LayeredLoungeRug",parent)
 block("RugField",Vector3.new(width,.07,depth),cf*CFrame.new(0,.035,0),C.rug,Enum.Material.Fabric,0,false,rug)
 block("RugInset",Vector3.new(width-1.0,.025,depth-1.0),cf*CFrame.new(0,.079,0),C.rugInset,Enum.Material.Fabric,0,false,rug)
 block("EdgeNorth",Vector3.new(width,.035,.07),cf*CFrame.new(0,.085,-depth/2+.05),C.rugEdge,Enum.Material.Metal,0,false,rug)
 block("EdgeSouth",Vector3.new(width,.035,.07),cf*CFrame.new(0,.085,depth/2-.05),C.rugEdge,Enum.Material.Metal,0,false,rug)
 -- restrained corner details make the rug feel tailored without reading as a bright outline.
 local cornerLen=1.5
 for _,sx in ipairs({-1,1}) do
  for _,sz in ipairs({-1,1}) do
   block("BrassCornerX_"..sx.."_"..sz,Vector3.new(cornerLen,.025,.045),cf*CFrame.new(sx*(width/2-.82),.105,sz*(depth/2-.18)),C.brass,Enum.Material.Metal,0,false,rug)
  end
 end
 return rug
end

local function addIceBucket(props,baseCF,mirror)
 local bucket=verticalCylinder("IceBucket",.82,1.05,baseCF*CFrame.new(1.42*mirror,1.84,.55),C.metal,Enum.Material.Metal,0,props)
 bucket.Reflectance=.12
 verticalCylinder("IceBucketRim",.10,1.16,baseCF*CFrame.new(1.42*mirror,2.28,.55),C.champagne,Enum.Material.Metal,0,props)
 for i=1,3 do
  local x=(1.18+(i-1)*.20)*mirror
  local z=.47+((i%2)*.18)
  local ice=block("IceCube"..i,Vector3.new(.26,.22,.26),baseCF*CFrame.new(x,2.37,z),C.ice,Enum.Material.Glass,.34,false,props)
  ice.Reflectance=.05
 end
end

local function addTableProps(tableModel,baseCF,mirror)
 local props=model("TableDetailV3",tableModel)
 block("Tray",Vector3.new(2.55,.10,1.55),baseCF*CFrame.new(-.55*mirror,1.48,.15),C.metal,Enum.Material.Metal,0,false,props)
 verticalCylinder("BottleBody",1.28,.66,baseCF*CFrame.new(.45*mirror,2.06,.15),C.bottle,Enum.Material.Glass,.12,props)
 verticalCylinder("BottleNeck",.42,.30,baseCF*CFrame.new(.45*mirror,2.86,.15),C.bottle,Enum.Material.Glass,.08,props)
 verticalCylinder("BottleCap",.12,.32,baseCF*CFrame.new(.45*mirror,3.12,.15),C.brass,Enum.Material.Metal,0,props)
 for i,offset in ipairs({-.65,.05}) do
  local g=verticalCylinder("Glass"..i,.62,.48,baseCF*CFrame.new(offset*mirror,1.86,-.35),Color3.fromRGB(188,196,203),Enum.Material.Glass,.50,props)
  g.Reflectance=.06
 end
 addIceBucket(props,baseCF,mirror)
 return props
end

local function makeTable(parent,cf,mirror)
 local t=model("LowSquareTableV3",parent)
 local top=block("Top",Vector3.new(5.25,.34,5.25),cf*CFrame.new(0,1.22,0),C.glass,Enum.Material.Glass,.08,true,t)
 top.Reflectance=.09
 block("UnderTop",Vector3.new(4.70,.18,4.70),cf*CFrame.new(0,1.00,0),C.black,Enum.Material.Metal,0,false,t)
 block("Pedestal",Vector3.new(1.12,1.02,1.12),cf*CFrame.new(0,.45,0),C.black,Enum.Material.Metal,0,true,t)
 block("Foot",Vector3.new(3.0,.16,3.0),cf*CFrame.new(0,.05,0),C.metal,Enum.Material.Metal,0,false,t)
 -- thin champagne reveal under the glass top.
 block("ChampagneReveal",Vector3.new(4.82,.05,4.82),cf*CFrame.new(0,1.08,0),C.champagne,Enum.Material.Metal,0,false,t)
 addTableProps(t,cf,mirror)
 return t
end

local function addWallAccent(parent,x,z,endSign)
 local m=model("DimensionalWallAccentV3",parent)
 -- smoked panel + floating frame gives each corner its own private-club identity.
 local panel=block("SmokedPanel",Vector3.new(7.0,4.7,.18),CFrame.new(x,32.0,z),C.smoked,Enum.Material.Glass,.32,false,m)
 panel.Reflectance=.08
 block("FrameTop",Vector3.new(7.15,.10,.20),CFrame.new(x,34.38,z-endSign*.05),C.brass,Enum.Material.Metal,0,false,m)
 block("FrameBottom",Vector3.new(7.15,.10,.20),CFrame.new(x,29.62,z-endSign*.05),C.brass,Enum.Material.Metal,0,false,m)
 block("Backplate",Vector3.new(4.8,.24,.23),CFrame.new(x,31.95,z-endSign*.15),C.black,Enum.Material.Metal,0,false,m)
 local bar=block("ChampagneBar",Vector3.new(3.75,.13,.15),CFrame.new(x,31.95,z-endSign*.31),C.champagne,Enum.Material.Neon,.18,false,m)
 bar.CastShadow=false
 local emitter=block("WarmEmitter",Vector3.new(.18,.18,.18),CFrame.new(x,31.45,z-endSign*.55),C.black,Enum.Material.SmoothPlastic,1,false,m)
 local light=Instance.new("PointLight")
 light.Name="LoungeWarmWashV3";light.Color=C.warm;light.Brightness=.52;light.Range=11.5;light.Shadows=false;light.Parent=emitter
 return m
end

local function addToeGlow(parent,cx,wallZ,outerX,returnCenterZ,endSign,frontCompact)
 local m=model("HiddenToeGlowV3",parent)
 local main=block("MainGlow",Vector3.new(frontCompact and 15.8 or 16.8,.07,.12),CFrame.new(cx,25.04,wallZ-endSign*2.02),C.amber,Enum.Material.Neon,.30,false,m)
 local ret=block("ReturnGlow",Vector3.new(.12,.07,frontCompact and 8.2 or 9.0),CFrame.new(outerX-endSign*0,25.04,returnCenterZ),C.amber,Enum.Material.Neon,.34,false,m)
 main.CastShadow=false;ret.CastShadow=false
 for _,strip in ipairs({main,ret}) do
  local wash=Instance.new("SurfaceLight")
  wash.Name="ToeKickWash";wash.Face=Enum.NormalId.Top;wash.Color=C.warm;wash.Brightness=.16;wash.Range=3.2;wash.Angle=110;wash.Shadows=false;wash.Parent=strip
 end
 return m
end

local function addPlaque(parent,cx,wallZ,endSign)
 local p=block("BBYABrassPlaque",Vector3.new(2.65,.62,.08),CFrame.new(cx,25.88,wallZ-endSign*2.25),C.brass,Enum.Material.Metal,0,false,parent)
 local gui=Instance.new("SurfaceGui")
 gui.Name="BBYAPlaqueFace";gui.Face=(endSign==1) and Enum.NormalId.Front or Enum.NormalId.Back;gui.LightInfluence=.15;gui.PixelsPerStud=80;gui.Parent=p
 local text=Instance.new("TextLabel")
 text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Text="BBYA";text.TextColor3=Color3.fromRGB(234,207,158)
 text.TextStrokeTransparency=.86;text.Font=Enum.Font.GothamBold;text.TextScaled=true;text.Parent=gui
 return p
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
 local lounge=model(name,out)
 local cx=side*(frontCompact and 42.0 or 41.0)
 local outerX=side*52.2
 local wallZ=endSign*40.2
 local returnCenterZ=endSign*34.8
 local mainYaw=(endSign==1) and 0 or 180
 local returnYaw=(side==1) and 90 or -90

 block("MainPlinth",Vector3.new(frontCompact and 18.0 or 18.8,.60,4.35),CFrame.new(cx,25.23,wallZ),C.black,Enum.Material.Metal,0,true,lounge)
 block("ReturnPlinth",Vector3.new(4.35,.60,frontCompact and 10.4 or 11.2),CFrame.new(outerX,25.23,returnCenterZ),C.black,Enum.Material.Metal,0,true,lounge)

 for i=1,4 do
  local spacing=frontCompact and 4.15 or 4.40
  local x=cx-(1.5*spacing)+(i-1)*spacing
  seatCushion(lounge,"MainSeat"..i,Vector3.new(x,25.99,wallZ-endSign*.20),mainYaw,i)
  backCushion(lounge,"MainBack"..i,Vector3.new(x,27.62,wallZ+endSign*2.12),mainYaw)
 end

 local returnStart=31.8
 local returnSpacing=frontCompact and 4.05 or 4.30
 for i=1,2 do
  local z=endSign*(returnStart+(i-1)*returnSpacing)
  seatCushion(lounge,"ReturnSeat"..i,Vector3.new(outerX-side*.05,25.99,z),returnYaw,i)
  local backX=outerX+side*2.12
  backCushion(lounge,"ReturnBack"..i,Vector3.new(backX,27.62,z),returnYaw)
 end

 arm(lounge,"InnerArm",Vector3.new(cx-side*(frontCompact and 8.55 or 9.10),26.52,wallZ-endSign*.15),mainYaw)
 arm(lounge,"ReturnArm",Vector3.new(outerX,26.52,endSign*29.45),returnYaw)
 softEllipsoid("LoosePillowA",Vector3.new(2.02,1.62,.70),CFrame.new(cx-side*2.7,27.20,wallZ+endSign*1.22)*CFrame.Angles(0,math.rad(side*12),math.rad(side*7)),C.fabric2,lounge)
 softEllipsoid("LoosePillowB",Vector3.new(1.82,1.52,.66),CFrame.new(outerX-side*.34,27.18,endSign*35.9)*CFrame.Angles(math.rad(-4),math.rad(returnYaw),math.rad(-side*8)),C.fabric,lounge)
 -- one muted accent pillow per lounge; still dark enough to keep the sofa black-led.
 softEllipsoid("AccentPillow",Vector3.new(1.72,1.46,.62),CFrame.new(cx+side*2.2,27.18,wallZ+endSign*1.24)*CFrame.Angles(0,math.rad(-side*10),math.rad(side*5)),C.accentFabric,lounge)

 block("PlinthAccent",Vector3.new(frontCompact and 16.8 or 17.6,.07,.07),CFrame.new(cx,25.48,wallZ-endSign*2.22),C.brass,Enum.Material.Metal,0,false,lounge)
 addToeGlow(lounge,cx,wallZ,outerX,returnCenterZ,endSign,frontCompact)
 addPlaque(lounge,cx,wallZ,endSign)

 local tableX=side*(frontCompact and 43.2 or 41.0)
 local tableZ=endSign*(frontCompact and 32.7 or 31.2)
 local rugX=side*(frontCompact and 43.0 or 41.5)
 local rugZ=endSign*(frontCompact and 33.4 or 32.7)
 makeRug(lounge,CFrame.new(rugX,25.005,rugZ),frontCompact and 15.5 or 17.5,frontCompact and 7.6 or 9.2)
 makeTable(lounge,CFrame.new(tableX,25.0,tableZ),side)
 addWallAccent(lounge,cx,endSign*43.22,endSign)

 lounge:SetAttribute("SeatCount",6)
 lounge:SetAttribute("WallHugging",true)
 lounge:SetAttribute("FrontCompact",frontCompact==true)
 lounge:SetAttribute("UnderSofaGlow",true)
 lounge:SetAttribute("PrivateClubPlaque",true)
 return lounge
end

buildLounge("NW_Lounge",-1,1,false)
buildLounge("NE_Lounge",1,1,false)
buildLounge("SW_Lounge",-1,-1,true)
buildLounge("SE_Lounge",1,-1,true)

active:SetAttribute("StandingOnly",false)
active:SetAttribute("VIPFurnitureMode","FOUR_CORNER_L_LOUNGES_V3")
active:SetAttribute("VIPLoungeSeatCount",24)
active:SetAttribute("VIPLoungeTableCount",4)
active:SetAttribute("VIPLoungeRugCount",4)
active:SetAttribute("VIPLoungeWarmAccentCount",4)
active:SetAttribute("VIPLoungeToeGlowCount",8)
active:SetAttribute("VIPLoungePlaqueCount",4)
active:SetAttribute("VIPLoungeIceBucketCount",4)
out:SetAttribute("SeatCount",24)
out:SetAttribute("TableCount",4)
out:SetAttribute("RugCount",4)
out:SetAttribute("WarmAccentCount",4)
out:SetAttribute("ToeGlowStripCount",8)
out:SetAttribute("PlaqueCount",4)
out:SetAttribute("IceBucketCount",4)

print("[BBYA] VIP Lounge Seating v3 online: 4 luxury L-lounges / 24 seats / layered rugs / detailed tables / hidden warm glow / wall panels")
