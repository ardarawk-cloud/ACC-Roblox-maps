-- BBYA SOCIAL HUB — STAFF TOWER ABOVE FUNKOT v2 PRIVACY REBUILD
-- Owner-authorized replacement of the miniature/blockout tower.
-- WORLD / BUILD authority only. Preserves StaffTowerV1 model identity and Travel arrival threshold path.
-- No audio, monetization, role persistence, DJ, Music, Message, Mall, or Funkot geometry changes.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end

local deadline=os.clock()+45
local funkot
repeat
 local candidate=root:FindFirstChild("FunkotClub")
 if candidate and candidate:GetAttribute("Pass")=="FUNKOT_CLUB_V1"
  and candidate:FindFirstChild("Ceiling")
  and candidate:FindFirstChild("DanceFloorSlab") then
  funkot=candidate
  break
 end
 task.wait(.2)
until os.clock()>=deadline

if not funkot then
 warn("[BBYA Staff Tower v2] Funkot final shell not ready; build skipped")
 return
end

task.wait(.8)

local previous=funkot:FindFirstChild("StaffTowerV1")
if previous then previous:Destroy() end

local tower=Instance.new("Model")
tower.Name="StaffTowerV1"
tower.Parent=funkot
tower:SetAttribute("Pass","STAFF_TOWER_V1")
tower:SetAttribute("WorldBuildAuthority","148_STAFF_TOWER_V2_PRIVACY_REBUILD")
tower:SetAttribute("Location","ABOVE_FUNKOT")
tower:SetAttribute("RoleIntent","OWNER_ADMIN_MODERATOR")
tower:SetAttribute("AudioUntouched",true)
tower:SetAttribute("GameplayUntouched",true)
tower:SetAttribute("MonetizationUntouched",true)
tower:SetAttribute("NoRuntimeLoops",true)
tower:SetAttribute("StaticEnvironment",true)
tower:SetAttribute("DesignLanguage","FULL_SCALE_PRIVATE_EXECUTIVE_RESIDENCE")
tower:SetAttribute("PrivacySequence","STAIR_CORE>VESTIBULE>HALL>PRIVATE_ROOM")
tower:SetAttribute("BedDirectlyVisibleFromStairs",false)
tower:SetAttribute("MiniatureBlockoutRetired",true)

local ceiling=funkot:FindFirstChild("Ceiling")
local cx=ceiling.Position.X
local cz=ceiling.Position.Z
local roofTop=ceiling.Position.Y+ceiling.Size.Y/2

-- Full-scale replacement. Avatar-scale circulation and privacy take priority over compact massing.
local PODIUM_W,PODIUM_D=104,76
local TOWER_W,TOWER_D=84,60
local CORE_W,CORE_D=14,20
local FLOOR_H=16
local coreX=cx+32
local coreZ=cz+11
local level1Y=roofTop+3.0
local floorSurface={level1Y,level1Y+FLOOR_H,level1Y+FLOOR_H*2,level1Y+FLOOR_H*3}

local C={
 black=Color3.fromRGB(10,11,14),
 charcoal=Color3.fromRGB(28,30,35),
 graphite=Color3.fromRGB(51,54,61),
 metal=Color3.fromRGB(93,98,108),
 glass=Color3.fromRGB(120,154,168),
 concrete=Color3.fromRGB(118,116,112),
 stone=Color3.fromRGB(160,155,147),
 wood=Color3.fromRGB(109,78,55),
 woodDark=Color3.fromRGB(72,53,42),
 fabric=Color3.fromRGB(67,65,70),
 fabricLight=Color3.fromRGB(190,184,176),
 brass=Color3.fromRGB(188,145,81),
 warm=Color3.fromRGB(255,225,188),
 leaf=Color3.fromRGB(51,86,59),
 soil=Color3.fromRGB(58,44,35),
 white=Color3.fromRGB(235,234,230),
}

local function model(name,parent)
 local m=Instance.new("Model")
 m.Name=name
 m.Parent=parent or tower
 return m
end

local function part(name,size,cf,color,material,collide,parent,transparency)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.CFrame=cf
 p.Color=color or C.charcoal
 p.Material=material or Enum.Material.SmoothPlastic
 p.Anchored=true
 p.CanCollide=collide==true
 p.CanTouch=false
 p.CanQuery=collide==true
 p.Transparency=transparency or 0
 p.CastShadow=p.Transparency<.88
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or tower
 return p
end

local function glass(name,size,cf,parent,transparency,collide)
 local p=part(name,size,cf,C.glass,Enum.Material.Glass,collide~=false,parent,transparency or .44)
 p.Reflectance=.04
 p.CastShadow=false
 return p
end

local function localLight(parent,brightness,range)
 local l=Instance.new("PointLight")
 l.Name="TowerLocalLight"
 l.Color=C.warm
 l.Brightness=brightness or .38
 l.Range=range or 14
 l.Shadows=false
 l.Parent=parent
 return l
end

local function beamBetween(name,a,b,thickness,color,parent,collide)
 local mid=(a+b)/2
 return part(name,Vector3.new(thickness,thickness,(b-a).Magnitude),CFrame.lookAt(mid,b),color or C.metal,Enum.Material.Metal,collide==true,parent)
end

local function wallAlongX(name,x,z,yBase,width,height,parent,color)
 return part(name,Vector3.new(width,height,.36),CFrame.new(x,yBase+height/2,z),color or C.charcoal,Enum.Material.Concrete,true,parent)
end

local function wallAlongZ(name,x,z,yBase,depth,height,parent,color)
 return part(name,Vector3.new(.36,height,depth),CFrame.new(x,yBase+height/2,z),color or C.charcoal,Enum.Material.Concrete,true,parent)
end

local function wallAlongXWithDoor(name,centerX,z,yBase,width,height,doorCenterX,doorWidth,parent,color)
 local leftEdge=centerX-width/2
 local rightEdge=centerX+width/2
 local doorL=math.max(leftEdge,doorCenterX-doorWidth/2)
 local doorR=math.min(rightEdge,doorCenterX+doorWidth/2)
 local leftW=doorL-leftEdge
 local rightW=rightEdge-doorR
 if leftW>.15 then wallAlongX(name.."L",leftEdge+leftW/2,z,yBase,leftW,height,parent,color) end
 if rightW>.15 then wallAlongX(name.."R",doorR+rightW/2,z,yBase,rightW,height,parent,color) end
 part(name.."Header",Vector3.new(math.max(.2,doorR-doorL),height-8,.42),CFrame.new((doorL+doorR)/2,yBase+8+(height-8)/2,z),color or C.charcoal,Enum.Material.Concrete,true,parent)
 part(name.."JambL",Vector3.new(.28,8,.55),CFrame.new(doorL,yBase+4,z),C.brass,Enum.Material.Metal,false,parent)
 part(name.."JambR",Vector3.new(.28,8,.55),CFrame.new(doorR,yBase+4,z),C.brass,Enum.Material.Metal,false,parent)
end

local function wallAlongZWithDoor(name,x,centerZ,yBase,depth,height,doorCenterZ,doorWidth,parent,color)
 local lowEdge=centerZ-depth/2
 local highEdge=centerZ+depth/2
 local doorL=math.max(lowEdge,doorCenterZ-doorWidth/2)
 local doorR=math.min(highEdge,doorCenterZ+doorWidth/2)
 local lowD=doorL-lowEdge
 local highD=highEdge-doorR
 if lowD>.15 then wallAlongZ(name.."S",x,lowEdge+lowD/2,yBase,lowD,height,parent,color) end
 if highD>.15 then wallAlongZ(name.."N",x,doorR+highD/2,yBase,highD,height,parent,color) end
 part(name.."Header",Vector3.new(.42,height-8,math.max(.2,doorR-doorL)),CFrame.new(x,yBase+8+(height-8)/2,(doorL+doorR)/2),color or C.charcoal,Enum.Material.Concrete,true,parent)
 part(name.."JambS",Vector3.new(.55,8,.28),CFrame.new(x,yBase+4,doorL),C.brass,Enum.Material.Metal,false,parent)
 part(name.."JambN",Vector3.new(.55,8,.28),CFrame.new(x,yBase+4,doorR),C.brass,Enum.Material.Metal,false,parent)
end

local function rug(name,cf,w,d,parent,color)
 return part(name,Vector3.new(w,.08,d),cf*CFrame.new(0,.05,0),color or C.fabric,Enum.Material.Fabric,false,parent)
end

local function sofa(name,cf,width,parent)
 local m=model(name,parent)
 local w=width or 9
 part("SeatBase",Vector3.new(w,.75,3.3),cf*CFrame.new(0,.72,0),C.fabric,Enum.Material.Fabric,true,m)
 part("SeatCushion",Vector3.new(w-.7,.55,2.6),cf*CFrame.new(0,1.25,-.15),C.fabricLight,Enum.Material.Fabric,true,m)
 part("Back",Vector3.new(w,2.8,.55),cf*CFrame.new(0,2.0,1.38)*CFrame.Angles(math.rad(-6),0,0),C.fabric,Enum.Material.Fabric,true,m)
 part("ArmL",Vector3.new(.55,1.65,3.35),cf*CFrame.new(-w/2+.24,1.18,0),C.fabric,Enum.Material.Fabric,true,m)
 part("ArmR",Vector3.new(.55,1.65,3.35),cf*CFrame.new(w/2-.24,1.18,0),C.fabric,Enum.Material.Fabric,true,m)
 return m
end

local function loungeChair(name,cf,parent)
 local m=model(name,parent)
 part("Seat",Vector3.new(3.2,.7,3.2),cf*CFrame.new(0,.72,0),C.fabric,Enum.Material.Fabric,true,m)
 part("Back",Vector3.new(3.2,2.6,.48),cf*CFrame.new(0,2.0,1.33)*CFrame.Angles(math.rad(-7),0,0),C.fabric,Enum.Material.Fabric,true,m)
 return m
end

local function lowTable(name,cf,w,d,parent)
 local m=model(name,parent)
 part("Top",Vector3.new(w,.3,d),cf*CFrame.new(0,1.35,0),C.stone,Enum.Material.Marble,true,m)
 part("Stem",Vector3.new(.7,1.2,.7),cf*CFrame.new(0,.65,0),C.brass,Enum.Material.Metal,true,m)
 return m
end

local function bed(name,cf,w,d,parent)
 local m=model(name,parent)
 part("Frame",Vector3.new(w,.65,d),cf*CFrame.new(0,.62,0),C.woodDark,Enum.Material.WoodPlanks,true,m)
 part("Mattress",Vector3.new(w-.5,.72,d-.55),cf*CFrame.new(0,1.28,0),C.fabricLight,Enum.Material.Fabric,true,m)
 part("Headboard",Vector3.new(w,3.1,.48),cf*CFrame.new(0,2.0,d/2-.12),C.fabric,Enum.Material.Fabric,true,m)
 for i,x in ipairs({-w*.24,w*.24}) do
  part("Pillow"..i,Vector3.new(w*.32,.42,1.65),cf*CFrame.new(x,1.82,d*.30),C.white,Enum.Material.Fabric,false,m)
 end
 return m
end

local function desk(name,cf,w,parent)
 local m=model(name,parent)
 part("Top",Vector3.new(w,.32,2.5),cf*CFrame.new(0,2.55,0),C.wood,Enum.Material.WoodPlanks,true,m)
 for i,x in ipairs({-w/2+.42,w/2-.42}) do
  part("Leg"..i,Vector3.new(.32,2.4,.32),cf*CFrame.new(x,1.25,0),C.metal,Enum.Material.Metal,true,m)
 end
 return m
end

local function wardrobe(name,cf,w,parent)
 local m=model(name,parent)
 part("Body",Vector3.new(w,7.2,2.1),cf*CFrame.new(0,3.6,0),C.woodDark,Enum.Material.WoodPlanks,true,m)
 part("Trim",Vector3.new(w+.12,.16,2.18),cf*CFrame.new(0,7.1,0),C.brass,Enum.Material.Metal,false,m)
 return m
end

local function planter(name,cf,parent)
 local m=model(name,parent)
 part("Box",Vector3.new(4.2,1.5,4.2),cf*CFrame.new(0,.75,0),C.concrete,Enum.Material.Concrete,true,m)
 part("Soil",Vector3.new(3.6,.18,3.6),cf*CFrame.new(0,1.56,0),C.soil,Enum.Material.Ground,false,m)
 part("Trunk",Vector3.new(.42,4.0,.42),cf*CFrame.new(0,3.45,0),C.wood,Enum.Material.Wood,false,m)
 for i=1,7 do
  local a=math.rad((i-1)*(360/7))
  local leaf=part("Leaf"..i,Vector3.new(1.7,2.0,1.5),cf*CFrame.new(math.cos(a)*.95,5.15,math.sin(a)*.95),C.leaf,Enum.Material.SmoothPlastic,false,m)
  leaf.Shape=Enum.PartType.Ball
  leaf.CanQuery=false
 end
 return m
end

local towerLeft=cx-TOWER_W/2
local towerRight=cx+TOWER_W/2
local towerSouth=cz-TOWER_D/2
local towerNorth=cz+TOWER_D/2
local coreLeft=coreX-CORE_W/2
local coreRight=coreX+CORE_W/2
local coreSouth=coreZ-CORE_D/2
local coreNorth=coreZ+CORE_D/2

-- =============================================================================
-- 1) TRANSFER PODIUM / FULL-SCALE ARRIVAL TERRACE
-- =============================================================================
local podium=model("TransferPodium")
podium:SetAttribute("Footprint","104x76")
podium:SetAttribute("FunkotRoofTopY",roofTop)
local podiumCenterY=floorSurface[1]-.45
part("PodiumSlab",Vector3.new(PODIUM_W,.9,PODIUM_D),CFrame.new(cx,podiumCenterY,cz),C.concrete,Enum.Material.Concrete,true,podium)
part("ArrivalCarpet",Vector3.new(15,.08,10),CFrame.new(cx+25,floorSurface[1]+.06,cz-31),C.fabric,Enum.Material.Fabric,false,podium)
part("PrivateArrivalThreshold",Vector3.new(9,.10,4),CFrame.new(cx+25,floorSurface[1]+.07,cz-25.5),C.stone,Enum.Material.Marble,false,podium)

for _,z in ipairs({cz-PODIUM_D/2,cz+PODIUM_D/2}) do
 glass("PodiumGlassZ"..z,Vector3.new(PODIUM_W,4.0,.30),CFrame.new(cx,floorSurface[1]+2.0,z),podium,.47,true)
 part("PodiumCapZ"..z,Vector3.new(PODIUM_W,.18,.46),CFrame.new(cx,floorSurface[1]+4.05,z),C.brass,Enum.Material.Metal,false,podium)
end
for _,x in ipairs({cx-PODIUM_W/2,cx+PODIUM_W/2}) do
 glass("PodiumGlassX"..x,Vector3.new(.30,4.0,PODIUM_D),CFrame.new(x,floorSurface[1]+2.0,cz),podium,.47,true)
 part("PodiumCapX"..x,Vector3.new(.46,.18,PODIUM_D),CFrame.new(x,floorSurface[1]+4.05,cz),C.brass,Enum.Material.Metal,false,podium)
end
planter("ArrivalPlanterL",CFrame.new(cx+12,floorSurface[1],cz-29),podium)
planter("ArrivalPlanterR",CFrame.new(cx+38,floorSurface[1],cz-29),podium)

-- =============================================================================
-- 2) SHELL / FLOOR PLATES / HUMAN-SCALE FACADE
-- =============================================================================
local shell=model("ExecutiveTowerShell")
shell:SetAttribute("MainFootprint","84x60")
shell:SetAttribute("FloorToFloor",FLOOR_H)
shell:SetAttribute("Floors",3)

local function slabWithCoreOpening(name,surfaceY,parent)
 local y=surfaceY-.45
 local westW=coreLeft-towerLeft
 local eastW=towerRight-coreRight
 local southD=coreSouth-towerSouth
 local northD=towerNorth-coreNorth
 part(name.."West",Vector3.new(westW,.9,TOWER_D),CFrame.new(towerLeft+westW/2,y,cz),C.concrete,Enum.Material.Concrete,true,parent)
 part(name.."East",Vector3.new(eastW,.9,TOWER_D),CFrame.new(coreRight+eastW/2,y,cz),C.concrete,Enum.Material.Concrete,true,parent)
 part(name.."South",Vector3.new(CORE_W,.9,southD),CFrame.new(coreX,y,towerSouth+southD/2),C.concrete,Enum.Material.Concrete,true,parent)
 part(name.."North",Vector3.new(CORE_W,.9,northD),CFrame.new(coreX,y,coreNorth+northD/2),C.concrete,Enum.Material.Concrete,true,parent)
end
slabWithCoreOpening("Level2Slab",floorSurface[2],shell)
slabWithCoreOpening("Level3Slab",floorSurface[3],shell)
slabWithCoreOpening("RoofSlab",floorSurface[4],shell)

local function facadeLevel(name,floorY,nextSurfaceY,isGround,parent)
 local m=model(name,parent)
 local h=(nextSurfaceY-.9)-floorY
 local cy=floorY+h/2
 -- West / north facade are continuous premium glass bands with structural piers.
 glass("WestGlass",Vector3.new(.36,h,TOWER_D),CFrame.new(towerLeft,cy,cz),m,.40,true)
 glass("NorthGlass",Vector3.new(TOWER_W,h,.36),CFrame.new(cx,cy,towerNorth),m,.40,true)
 -- East facade is partly solid around the private core.
 glass("EastSouthGlass",Vector3.new(.36,h,coreSouth-towerSouth-2),CFrame.new(towerRight,cy,towerSouth+(coreSouth-towerSouth-2)/2),m,.40,true)
 glass("EastNorthGlass",Vector3.new(.36,h,towerNorth-coreNorth-2),CFrame.new(towerRight,cy,coreNorth+2+(towerNorth-coreNorth-2)/2),m,.40,true)
 -- South facade: ground floor keeps a true 8-stud arrival opening; upper floors are continuous glazing.
 if isGround then
  local entryX=cx+25
  local doorW=8
  local leftW=(entryX-doorW/2)-towerLeft
  local rightW=towerRight-(entryX+doorW/2)
  glass("SouthGlassL",Vector3.new(leftW,h,.36),CFrame.new(towerLeft+leftW/2,cy,towerSouth),m,.40,true)
  glass("SouthGlassR",Vector3.new(rightW,h,.36),CFrame.new(entryX+doorW/2+rightW/2,cy,towerSouth),m,.40,true)
  part("EntryHeader",Vector3.new(doorW,h-8,.50),CFrame.new(entryX,floorY+8+(h-8)/2,towerSouth),C.graphite,Enum.Material.Metal,true,m)
  part("EntryJambL",Vector3.new(.34,8,.55),CFrame.new(entryX-doorW/2,floorY+4,towerSouth),C.brass,Enum.Material.Metal,false,m)
  part("EntryJambR",Vector3.new(.34,8,.55),CFrame.new(entryX+doorW/2,floorY+4,towerSouth),C.brass,Enum.Material.Metal,false,m)
 else
  glass("SouthGlass",Vector3.new(TOWER_W,h,.36),CFrame.new(cx,cy,towerSouth),m,.40,true)
 end
 for _,x in ipairs({towerLeft,cx-21,cx,cx+21,towerRight}) do
  part("PillarS"..tostring(x),Vector3.new(.48,h,.62),CFrame.new(x,cy,towerSouth),C.graphite,Enum.Material.Metal,true,m)
  part("PillarN"..tostring(x),Vector3.new(.48,h,.62),CFrame.new(x,cy,towerNorth),C.graphite,Enum.Material.Metal,true,m)
 end
 for _,z in ipairs({towerSouth,cz-15,cz,cz+15,towerNorth}) do
  part("PillarW"..tostring(z),Vector3.new(.62,h,.48),CFrame.new(towerLeft,cy,z),C.graphite,Enum.Material.Metal,true,m)
  part("PillarE"..tostring(z),Vector3.new(.62,h,.48),CFrame.new(towerRight,cy,z),C.graphite,Enum.Material.Metal,true,m)
 end
 part("SouthLowerBand",Vector3.new(TOWER_W,.58,.72),CFrame.new(cx,floorY+.3,towerSouth),C.charcoal,Enum.Material.Metal,true,m)
 part("NorthLowerBand",Vector3.new(TOWER_W,.58,.72),CFrame.new(cx,floorY+.3,towerNorth),C.charcoal,Enum.Material.Metal,true,m)
 return m
end
facadeLevel("StaffFacade",floorSurface[1],floorSurface[2],true,shell)
facadeLevel("AdminFacade",floorSurface[2],floorSurface[3],false,shell)
facadeLevel("OwnerFacade",floorSurface[3],floorSurface[4],false,shell)

-- =============================================================================
-- 3) ENCLOSED PRIVATE STAIR CORE / VESTIBULE LANDINGS
-- =============================================================================
local core=model("PrivateAccessCore")
core:SetAttribute("PrivacyCore",true)
core:SetAttribute("OpenBedroomSightline",false)
core:SetAttribute("RoleAccessAuthority","TRAVEL_SERVER_AND_ROLE_SYSTEM")

wallAlongZ("CoreEast",coreRight-.2,coreZ,floorSurface[1],CORE_D,FLOOR_H*3,core,C.charcoal)
wallAlongX("CoreNorth",coreX,coreNorth-.2,floorSurface[1],CORE_W,FLOOR_H*3,core,C.charcoal)
wallAlongZ("CoreWest",coreLeft+.2,coreZ+3.5,floorSurface[1],CORE_D-7,FLOOR_H*3,core,C.charcoal)

local function stairRun(name,lowerSurface,upperSurface,reverse,parent)
 local m=model(name,parent)
 local steps=15
 local slabBottom=upperSurface-.9
 local availableRise=slabBottom-lowerSurface
 local rise=availableRise/steps
 local runDepth=(CORE_D-2.4)/steps
 for i=0,steps-1 do
  local zIndex=reverse and (steps-1-i) or i
  local z=coreSouth+1.2+runDepth*(zIndex+.5)
  local y=lowerSurface+rise*(i+.5)
  part("Step"..i,Vector3.new(5.4,rise,runDepth+.05),CFrame.new(coreX-.5,y,z),C.stone,Enum.Material.Concrete,true,m)
 end
 local startZ=reverse and coreNorth-1.2 or coreSouth+1.2
 local endZ=reverse and coreSouth+1.2 or coreNorth-1.2
 beamBetween("Handrail",Vector3.new(coreX-3.5,lowerSurface+2.8,startZ),Vector3.new(coreX-3.5,slabBottom+2.3,endZ),.20,C.metal,m,false)
 return m
end
stairRun("StaffToAdmin",floorSurface[1],floorSurface[2],false,core)
stairRun("AdminToOwner",floorSurface[2],floorSurface[3],true,core)
stairRun("OwnerToRoof",floorSurface[3],floorSurface[4],false,core)

for i,y in ipairs(floorSurface) do
 part("CoreLanding"..i,Vector3.new(6.6,.35,3.0),CFrame.new(coreX-3.0,y+.18,coreNorth-1.8),C.stone,Enum.Material.Concrete,true,core)
end

-- =============================================================================
-- 4) LEVEL 1 — STAFF RECEPTION / LOUNGE / MEETING / OFFICE
-- =============================================================================
local staff=model("ModeratorStaffFloor")
staff:SetAttribute("Program","RECEPTION_LOUNGE_MEETING_OFFICE_PANTRY_RESTROOM")
staff:SetAttribute("PrivacyFromArrival","PUBLIC_STAFF_LOBBY_ONLY")
local y1=floorSurface[1]

-- Arrival sequence: exterior threshold -> reception vestibule -> staff lounge. No private bed program on this floor.
wallAlongXWithDoor("ReceptionScreen",cx+20,cz-18,y1,34,10,cx+25,7,staff,C.charcoal)
part("ReceptionDesk",Vector3.new(10,3.0,2.8),CFrame.new(cx+12,y1+1.5,cz-22),C.wood,Enum.Material.WoodPlanks,true,staff)
part("ReceptionTop",Vector3.new(10.4,.24,3.0),CFrame.new(cx+12,y1+3.1,cz-22),C.stone,Enum.Material.Marble,true,staff)

-- Meeting room west-front with real doorway.
wallAlongZ("MeetingDivider",cx-12,cz-14,y1,28,10,staff,C.charcoal)
wallAlongXWithDoor("MeetingEntry",cx-27,cz-3.5,y1,30,10,cx-20,6,staff,C.charcoal)
part("MeetingTable",Vector3.new(14,.75,5.2),CFrame.new(cx-27,y1+1.9,cz-15),C.wood,Enum.Material.WoodPlanks,true,staff)
for i,x in ipairs({cx-33,cx-27,cx-21}) do
 loungeChair("MeetingChairN"..i,CFrame.new(x,y1,cz-19)*CFrame.Angles(0,math.rad(180),0),staff)
 loungeChair("MeetingChairS"..i,CFrame.new(x,y1,cz-11),staff)
end

-- Central staff lounge.
rug("StaffLoungeRug",CFrame.new(cx-4,y1,cz+8),25,17,staff,C.fabric)
sofa("StaffSofaA",CFrame.new(cx-10,y1,cz+12),10,staff)
sofa("StaffSofaB",CFrame.new(cx+2,y1,cz+4)*CFrame.Angles(0,math.rad(-90),0),9,staff)
lowTable("StaffCoffeeTable",CFrame.new(cx-5,y1,cz+8),5.4,3.6,staff)

-- Office / pantry / restroom behind dedicated partitions.
wallAlongXWithDoor("OfficeFront",cx+12,cz+3.5,y1,28,10,cx+4,6,staff,C.charcoal)
wallAlongZ("OfficeWest",cx-2,cz+15,y1,23,10,staff,C.charcoal)
desk("StaffDeskA",CFrame.new(cx+8,y1,cz+13),8,staff)
desk("StaffDeskB",CFrame.new(cx+19,y1,cz+13),8,staff)
part("PantryCounter",Vector3.new(17,2.8,2.5),CFrame.new(cx+8,y1+1.4,cz+25),C.wood,Enum.Material.WoodPlanks,true,staff)
part("PantryTop",Vector3.new(17.4,.24,2.8),CFrame.new(cx+8,y1+2.9,cz+25),C.stone,Enum.Material.Marble,true,staff)

local restX,restZ=cx+24,cz+20
wallAlongX("RestroomNorth",restX,restZ+7,y1,15,10,staff,C.graphite)
wallAlongZ("RestroomEast",restX+7.5,restZ,y1,14,10,staff,C.graphite)
wallAlongZ("RestroomWest",restX-7.5,restZ,y1,14,10,staff,C.graphite)
wallAlongXWithDoor("RestroomSouth",restX,restZ-7,y1,15,10,restX-3,4.5,staff,C.graphite)
part("RestroomVanity",Vector3.new(5.5,2.2,1.6),CFrame.new(restX-2,y1+1.1,restZ+5.5),C.stone,Enum.Material.Marble,true,staff)

-- =============================================================================
-- 5) LEVEL 2 — FOUR REAL ADMIN SUITES + CENTRAL CORRIDOR
-- =============================================================================
local admin=model("AdminApartments")
admin:SetAttribute("UnitCount",4)
admin:SetAttribute("PrivacyLayout","STAIR>LANDING>COMMON_CORRIDOR>PRIVATE_DOOR>SUITE")
admin:SetAttribute("BedDirectSightlineFromStairs",false)
local y2=floorSurface[2]

-- Corridor is a real neutral zone. Stair lands at east end; all beds sit behind suite doors and internal partitions.
rug("AdminCorridorRunner",CFrame.new(cx-8,y2,cz),60,6,admin,C.fabric)
wallAlongXWithDoor("SouthSuiteWallA",cx-27,cz-4,y2,30,10,cx-23,5,admin,C.charcoal)
wallAlongXWithDoor("SouthSuiteWallB",cx+3,cz-4,y2,30,10,cx+7,5,admin,C.charcoal)
wallAlongXWithDoor("NorthSuiteWallA",cx-27,cz+4,y2,30,10,cx-23,5,admin,C.charcoal)
wallAlongXWithDoor("NorthSuiteWallB",cx+3,cz+4,y2,30,10,cx+7,5,admin,C.charcoal)
wallAlongZ("SouthUnitDivider",cx-12,cz-17,y2,26,10,admin,C.charcoal)
wallAlongZ("NorthUnitDivider",cx-12,cz+17,y2,26,10,admin,C.charcoal)
-- Screen the stair landing from the suite corridor so no room is visible immediately after climbing.
wallAlongZWithDoor("AdminVestibuleScreen",cx+20,cz,y2,18,10,cz,6,admin,C.graphite)

local unitSpecs={
 {name="AdminSuiteA",x=cx-27,z=cz-17,yaw=0,doorX=cx-23},
 {name="AdminSuiteB",x=cx+3,z=cz-17,yaw=0,doorX=cx+7},
 {name="AdminSuiteC",x=cx-27,z=cz+17,yaw=180,doorX=cx-23},
 {name="AdminSuiteD",x=cx+3,z=cz+17,yaw=180,doorX=cx+7},
}
for _,u in ipairs(unitSpecs) do
 local unit=model(u.name,admin)
 unit:SetAttribute("StaticSuite",true)
 unit:SetAttribute("PrivateDoor",true)
 unit:SetAttribute("BedVisibleFromCorridor",false)
 local base=CFrame.new(u.x,y2,u.z)*CFrame.Angles(0,math.rad(u.yaw),0)
 -- Internal privacy wall creates a bedroom zone at the exterior side of each suite.
 wallAlongXWithDoor("BedroomPrivacyWall",u.x,u.z+(u.yaw==0 and -4.5 or 4.5),y2,26,9,u.x-6,5,unit,C.graphite)
 bed("Bed",base*CFrame.new(-5.5,0,4.5),7.4,9.0,unit)
 wardrobe("Wardrobe",base*CFrame.new(7.5,0,6.2),5.2,unit)
 desk("Desk",base*CFrame.new(6.5,0,-4.0),6.8,unit)
 lowTable("SideTable",base*CFrame.new(0.8,0,5.5),2.6,2.2,unit)
 -- Compact private bath is screened, not exposed beside the bed.
 wallAlongZWithDoor("BathPrivacy",u.x+10,u.z,y2,12,9,u.z+(u.yaw==0 and -2.5 or 2.5),4,unit,C.graphite)
 part("BathVanity",Vector3.new(4.6,2.2,1.5),base*CFrame.new(9.2,1.1,1.5),C.stone,Enum.Material.Marble,true,unit)
 glass("ShowerScreen",Vector3.new(4.4,6.7,.26),base*CFrame.new(9.2,3.35,5.8),unit,.46,true)
end

-- =============================================================================
-- 6) LEVEL 3 — OWNER PENTHOUSE WITH REAL PRIVACY SEQUENCE
-- =============================================================================
local owner=model("OwnerPenthouse")
owner:SetAttribute("Program","PRIVATE_FOYER_LIVING_OFFICE_DRESSING_BATH_BEDROOM")
owner:SetAttribute("PrivacySequence","STAIR>OWNER_VESTIBULE>FOYER>PRIVATE_HALL>BEDROOM")
owner:SetAttribute("BedroomDoorRequired",true)
owner:SetAttribute("BedDirectSightlineFromStairs",false)
local y3=floorSurface[3]

-- Stair lands into an enclosed owner vestibule, never into the bedroom.
wallAlongZ("OwnerVestibuleEast",cx+22,cz,y3,20,10,owner,C.graphite)
wallAlongXWithDoor("OwnerVestibuleWest",cx+14,cz-9,y3,16,10,cx+10,6,owner,C.graphite)
wallAlongX("OwnerVestibuleNorth",cx+14,cz+9,y3,16,10,owner,C.graphite)
rug("OwnerFoyerRug",CFrame.new(cx+10,y3,cz-13),16,9,owner,C.fabric)
part("OwnerFoyerConsole",Vector3.new(8,2.5,1.8),CFrame.new(cx+9,y3+1.25,cz-18),C.woodDark,Enum.Material.WoodPlanks,true,owner)

-- Living room occupies the south-west, separated from private bedroom hall.
wallAlongXWithDoor("PrivateHallScreen",cx-16,cz+5,y3,44,10,cx-3,6,owner,C.charcoal)
rug("OwnerLivingRug",CFrame.new(cx-18,y3,cz-12),30,18,owner,C.fabric)
sofa("OwnerSofa",CFrame.new(cx-25,y3,cz-14),11,owner)
loungeChair("OwnerChairA",CFrame.new(cx-10,y3,cz-17)*CFrame.Angles(0,math.rad(-35),0),owner)
loungeChair("OwnerChairB",CFrame.new(cx-7,y3,cz-9)*CFrame.Angles(0,math.rad(-120),0),owner)
lowTable("OwnerCoffeeTable",CFrame.new(cx-17,y3,cz-11),6.4,4.4,owner)
part("OwnerMediaConsole",Vector3.new(12,2.4,1.9),CFrame.new(cx-19,y3+1.2,cz-2),C.woodDark,Enum.Material.WoodPlanks,true,owner)

-- Owner office remains accessible from living/foyer without passing through bedroom.
wallAlongZWithDoor("OwnerOfficeWall",cx+1,cz-14,y3,24,10,cz-13,6,owner,C.charcoal)
desk("OwnerDesk",CFrame.new(cx+9,y3,cz-14),9.5,owner)
part("OwnerCredenza",Vector3.new(10,2.5,1.9),CFrame.new(cx+9,y3+1.25,cz-23),C.wood,Enum.Material.WoodPlanks,true,owner)

-- Private bedroom is north-west and behind two boundaries from the stair core.
wallAlongZWithDoor("BedroomEastWall",cx-2,cz+17,y3,24,10,cz+12,6,owner,C.charcoal)
wallAlongX("BedroomSouthWall",cx-22,cz+5,y3,40,10,owner,C.charcoal)
rug("BedroomRug",CFrame.new(cx-23,y3,cz+18),28,17,owner,C.fabric)
bed("OwnerBed",CFrame.new(cx-25,y3,cz+19)*CFrame.Angles(0,math.rad(180),0),9.2,11.0,owner)
wardrobe("OwnerWardrobeA",CFrame.new(cx-8,y3,cz+21),6.5,owner)
wardrobe("OwnerWardrobeB",CFrame.new(cx-8,y3,cz+13),6.5,owner)
lowTable("BedroomBench",CFrame.new(cx-25,y3,cz+10),7.0,2.8,owner)

-- Dressing + bath occupy north-east, separated from both stair and bed.
wallAlongZWithDoor("DressingWest",cx+8,cz+18,y3,20,10,cz+12,5,owner,C.graphite)
wallAlongXWithDoor("BathSouth",cx+16,cz+8,y3,16,10,cx+14,5,owner,C.graphite)
part("BathVanity",Vector3.new(8,2.4,1.8),CFrame.new(cx+15,y3+1.2,cz+21),C.stone,Enum.Material.Marble,true,owner)
glass("OwnerShowerGlass",Vector3.new(6.0,7.2,.28),CFrame.new(cx+19,y3+3.6,cz+16),owner,.45,true)
part("DressingBench",Vector3.new(6.2,.85,2.4),CFrame.new(cx+6,y3+.48,cz+14),C.fabric,Enum.Material.Fabric,true,owner)

-- =============================================================================
-- 7) ROOF TERRACE — ARRIVAL LOBBY + HELIPAD VISUAL + LOUNGE
-- =============================================================================
local roof=model("PrivateRoofTerrace")
roof:SetAttribute("HelipadVisualOnly",true)
roof:SetAttribute("StairExitPrivacyLobby",true)
local yr=floorSurface[4]

for _,z in ipairs({towerSouth,towerNorth}) do glass("RoofGlassZ"..z,Vector3.new(TOWER_W,4.0,.3),CFrame.new(cx,yr+2,z),roof,.46,true) end
for _,x in ipairs({towerLeft,towerRight}) do glass("RoofGlassX"..x,Vector3.new(.3,4.0,TOWER_D),CFrame.new(x,yr+2,cz),roof,.46,true) end

-- Roof stair exits into a small screen lobby before the social terrace.
wallAlongZ("RoofLobbyEast",coreRight+2,coreZ,yr,CORE_D+4,8,roof,C.graphite)
wallAlongXWithDoor("RoofLobbySouth",coreX+1,coreSouth-2,yr,CORE_W+8,8,coreX-2,5,roof,C.graphite)
wallAlongX("RoofLobbyNorth",coreX+1,coreNorth+2,yr,CORE_W+8,8,roof,C.graphite)

-- Low-profile helipad visual, scaled for the larger roof.
local helipad=model("HelipadVisual",roof)
local hx,hz=cx-18,cz
part("HelipadPad",Vector3.new(28,.14,28),CFrame.new(hx,yr+.08,hz),C.charcoal,Enum.Material.Metal,false,helipad)
part("HLeft",Vector3.new(1.0,.12,9),CFrame.new(hx-4,yr+.18,hz),C.white,Enum.Material.SmoothPlastic,false,helipad)
part("HRight",Vector3.new(1.0,.12,9),CFrame.new(hx+4,yr+.18,hz),C.white,Enum.Material.SmoothPlastic,false,helipad)
part("HBridge",Vector3.new(8,.12,1.0),CFrame.new(hx,yr+.18,hz),C.white,Enum.Material.SmoothPlastic,false,helipad)

rug("RoofLoungeRug",CFrame.new(cx+18,yr,cz-8),24,16,roof,C.fabric)
sofa("RoofSofa",CFrame.new(cx+18,yr,cz-13),10,roof)
loungeChair("RoofChairA",CFrame.new(cx+8,yr,cz-5)*CFrame.Angles(0,math.rad(55),0),roof)
loungeChair("RoofChairB",CFrame.new(cx+27,yr,cz-5)*CFrame.Angles(0,math.rad(-55),0),roof)
lowTable("RoofTable",CFrame.new(cx+18,yr,cz-7),5.5,3.8,roof)
planter("RoofPlanterNE",CFrame.new(cx+34,yr,cz+23),roof)
planter("RoofPlanterSE",CFrame.new(cx+34,yr,cz-23),roof)
planter("RoofPlanterNW",CFrame.new(cx-36,yr,cz+23),roof)

-- =============================================================================
-- 8) RESTRAINED ARCHITECTURAL LIGHTING
-- =============================================================================
local lighting=model("TowerArchitecturalLighting")
for levelIndex=1,3 do
 local y=floorSurface[levelIndex+1]-1.05
 for i,x in ipairs({cx-28,cx-10,cx+8,cx+24}) do
  local fixture=part("CeilingFixture"..levelIndex.."_"..i,Vector3.new(1.3,.18,1.3),CFrame.new(x,y,cz),C.brass,Enum.Material.Metal,false,lighting)
  localLight(fixture,.40,14)
 end
end
for i,x in ipairs({cx-34,cx+34}) do
 local bollard=part("RoofBollard"..i,Vector3.new(.85,2.4,.85),CFrame.new(x,yr+1.2,cz-25),C.graphite,Enum.Material.Metal,true,lighting)
 localLight(bollard,.30,9)
end

-- Source-derived spatial evidence for QC / travel integration.
tower:SetAttribute("FunkotCenterX",cx)
tower:SetAttribute("FunkotCenterZ",cz)
tower:SetAttribute("FunkotRoofTopY",roofTop)
tower:SetAttribute("PodiumWidth",PODIUM_W)
tower:SetAttribute("PodiumDepth",PODIUM_D)
tower:SetAttribute("TowerWidth",TOWER_W)
tower:SetAttribute("TowerDepth",TOWER_D)
tower:SetAttribute("FloorHeight",FLOOR_H)
tower:SetAttribute("ModeratorFloorY",floorSurface[1])
tower:SetAttribute("AdminFloorY",floorSurface[2])
tower:SetAttribute("OwnerFloorY",floorSurface[3])
tower:SetAttribute("RoofTerraceY",floorSurface[4])
tower:SetAttribute("InstalledDescendants",#tower:GetDescendants())

print("[BBYA] Staff Tower v2 privacy rebuild: full scale / enclosed stair / admin corridor / owner private foyer + bedroom")
