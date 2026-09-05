-- BBYA SOCIAL HUB — STAFF TOWER ABOVE FUNKOT v1
-- WORLD / BUILD authority only: static architecture, stairs, furniture, landscape and local fixtures.
-- No UI/HUD, audio, gameplay, monetization, role enforcement, teleport logic or production publish behavior.

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
 warn("[BBYA Staff Tower] Funkot final shell not ready; build skipped")
 return
end

task.wait(.8)

local previous=funkot:FindFirstChild("StaffTowerV1")
if previous then previous:Destroy() end

local tower=Instance.new("Model")
tower.Name="StaffTowerV1"
tower.Parent=funkot
tower:SetAttribute("Pass","STAFF_TOWER_V1")
tower:SetAttribute("WorldBuildAuthority","148_STAFF_TOWER_V1")
tower:SetAttribute("Location","ABOVE_FUNKOT")
tower:SetAttribute("RoleIntent","OWNER_ADMIN_MODERATOR")
tower:SetAttribute("RoleEnforcementDeferred",true)
tower:SetAttribute("TeleportAuthorityChanged",false)
tower:SetAttribute("AudioUntouched",true)
tower:SetAttribute("GameplayUntouched",true)
tower:SetAttribute("MonetizationUntouched",true)
tower:SetAttribute("NoRuntimeLoops",true)
tower:SetAttribute("StaticEnvironment",true)
tower:SetAttribute("DesignLanguage","PRIVATE_EXECUTIVE_STAFF_RESIDENCE")

local ceiling=funkot:FindFirstChild("Ceiling")
local cx=ceiling.Position.X
local cz=ceiling.Position.Z
local roofTop=ceiling.Position.Y+ceiling.Size.Y/2

-- Existing Funkot shell is 112 x 88. The tower intentionally uses a smaller setback mass.
local PODIUM_W,PODIUM_D=72,48
local TOWER_W,TOWER_D=52,34
local CORE_W,CORE_D=10,13
local coreX=cx+18
local coreZ=cz+8
local level1Y=roofTop+2.9
local floorSurface={level1Y,level1Y+13,level1Y+26,level1Y+39}

local C={
 black=Color3.fromRGB(12,13,16),
 charcoal=Color3.fromRGB(31,33,37),
 graphite=Color3.fromRGB(52,55,61),
 metal=Color3.fromRGB(91,95,103),
 glass=Color3.fromRGB(119,153,166),
 concrete=Color3.fromRGB(124,121,116),
 stone=Color3.fromRGB(151,146,138),
 wood=Color3.fromRGB(105,76,55),
 fabric=Color3.fromRGB(72,68,70),
 fabricLight=Color3.fromRGB(184,178,170),
 brass=Color3.fromRGB(184,143,82),
 warm=Color3.fromRGB(255,226,190),
 leaf=Color3.fromRGB(57,91,61),
 soil=Color3.fromRGB(60,45,35),
 white=Color3.fromRGB(232,232,228),
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

local function glass(name,size,cf,parent,transparency)
 local p=part(name,size,cf,C.glass,Enum.Material.Glass,true,parent,transparency or .42)
 p.Reflectance=.05
 p.CastShadow=false
 return p
end

local function cylinder(name,height,diameter,cf,color,material,collide,parent,transparency)
 local p=part(name,Vector3.new(height,diameter,diameter),cf*CFrame.Angles(0,0,math.rad(90)),color,material,collide,parent,transparency)
 p.Shape=Enum.PartType.Cylinder
 return p
end

local function localLight(parent,brightness,range)
 local l=Instance.new("PointLight")
 l.Name="TowerLocalLight"
 l.Color=C.warm
 l.Brightness=brightness or .45
 l.Range=range or 12
 l.Shadows=false
 l.Parent=parent
 return l
end

local function beamBetween(name,a,b,thickness,color,parent,collide)
 local mid=(a+b)/2
 return part(name,Vector3.new(thickness,thickness,(b-a).Magnitude),CFrame.lookAt(mid,b),color or C.metal,Enum.Material.Metal,collide==true,parent)
end

local function sofa(name,cf,width,parent)
 local m=model(name,parent)
 local w=width or 6.8
 part("Base",Vector3.new(w,.72,2.8),cf*CFrame.new(0,.65,0),C.fabric,Enum.Material.Fabric,true,m)
 part("Back",Vector3.new(w,2.4,.48),cf*CFrame.new(0,1.65,1.15)*CFrame.Angles(math.rad(-7),0,0),C.fabric,Enum.Material.Fabric,true,m)
 part("ArmL",Vector3.new(.5,1.5,2.9),cf*CFrame.new(-w/2+.2,1.0,0),C.fabric,Enum.Material.Fabric,true,m)
 part("ArmR",Vector3.new(.5,1.5,2.9),cf*CFrame.new(w/2-.2,1.0,0),C.fabric,Enum.Material.Fabric,true,m)
 return m
end

local function lowTable(name,cf,w,d,parent)
 local m=model(name,parent)
 part("Top",Vector3.new(w,.28,d),cf*CFrame.new(0,1.25,0),C.stone,Enum.Material.Marble,true,m)
 part("Stem",Vector3.new(.45,1.15,.45),cf*CFrame.new(0,.62,0),C.brass,Enum.Material.Metal,true,m)
 return m
end

local function bed(name,cf,w,d,parent)
 local m=model(name,parent)
 part("Frame",Vector3.new(w,.55,d),cf*CFrame.new(0,.55,0),C.wood,Enum.Material.WoodPlanks,true,m)
 part("Mattress",Vector3.new(w-.4,.65,d-.45),cf*CFrame.new(0,1.15,0),C.fabricLight,Enum.Material.Fabric,true,m)
 part("Headboard",Vector3.new(w,2.5,.42),cf*CFrame.new(0,1.75,d/2-.1),C.fabric,Enum.Material.Fabric,true,m)
 for _,x in ipairs({-w*.22,w*.22}) do
  part("Pillow"..tostring(x),Vector3.new(w*.30,.35,1.4),cf*CFrame.new(x,1.68,d*.30),C.white,Enum.Material.Fabric,false,m)
 end
 return m
end

local function desk(name,cf,w,parent)
 local m=model(name,parent)
 part("Top",Vector3.new(w,.28,2.1),cf*CFrame.new(0,2.45,0),C.wood,Enum.Material.WoodPlanks,true,m)
 for _,x in ipairs({-w/2+.35,w/2-.35}) do
  part("Leg"..tostring(x),Vector3.new(.28,2.3,.28),cf*CFrame.new(x,1.2,0),C.metal,Enum.Material.Metal,true,m)
 end
 return m
end

local function planter(name,cf,parent)
 local m=model(name,parent)
 part("Box",Vector3.new(3.6,1.4,3.6),cf*CFrame.new(0,.7,0),C.concrete,Enum.Material.Concrete,true,m)
 part("Soil",Vector3.new(3.0,.18,3.0),cf*CFrame.new(0,1.48,0),C.soil,Enum.Material.Ground,false,m)
 part("Trunk",Vector3.new(.36,3.4,.36),cf*CFrame.new(0,3.1,0),C.wood,Enum.Material.Wood,false,m)
 for i=1,5 do
  local a=math.rad((i-1)*72)
  local leaf=part("Leaf"..i,Vector3.new(1.35,1.8,1.2),cf*CFrame.new(math.cos(a)*.75,4.7,math.sin(a)*.75),C.leaf,Enum.Material.SmoothPlastic,false,m)
  leaf.Shape=Enum.PartType.Ball
  leaf.CanQuery=false
 end
 return m
end

-- =============================================================================
-- 1) TRANSFER PODIUM / SETBACK BASE
-- =============================================================================
local podium=model("TransferPodium")
podium:SetAttribute("Footprint","72x48")
podium:SetAttribute("FunkotRoofTopY",roofTop)

-- Podium top is the Level 1 walking datum; low transfer pads land directly on the Funkot roof.
local podiumCenterY=floorSurface[1]-.4
part("PodiumSlab",Vector3.new(PODIUM_W,.8,PODIUM_D),CFrame.new(cx,podiumCenterY,cz),C.concrete,Enum.Material.Concrete,true,podium)
for _,x in ipairs({-30,-15,0,15,30}) do
 for _,z in ipairs({-18,18}) do
  part("TransferPad"..x.."_"..z,Vector3.new(1.4,2.0,1.4),CFrame.new(cx+x,roofTop+1.0,cz+z),C.graphite,Enum.Material.Metal,true,podium)
 end
end

-- Podium safety glass. Tower mass is inset, leaving a usable perimeter terrace.
for _,z in ipairs({cz-PODIUM_D/2,cz+PODIUM_D/2}) do
 glass("PodiumGlassZ"..z,Vector3.new(PODIUM_W,3.6,.28),CFrame.new(cx,floorSurface[1]+1.8,z),podium,.46)
 part("PodiumCapZ"..z,Vector3.new(PODIUM_W,.16,.42),CFrame.new(cx,floorSurface[1]+3.62,z),C.brass,Enum.Material.Metal,false,podium)
end
for _,x in ipairs({cx-PODIUM_W/2,cx+PODIUM_W/2}) do
 glass("PodiumGlassX"..x,Vector3.new(.28,3.6,PODIUM_D),CFrame.new(x,floorSurface[1]+1.8,cz),podium,.46)
 part("PodiumCapX"..x,Vector3.new(.42,.16,PODIUM_D),CFrame.new(x,floorSurface[1]+3.62,cz),C.brass,Enum.Material.Metal,false,podium)
end
part("PrivateArrivalThreshold",Vector3.new(7,.10,3),CFrame.new(cx+18,floorSurface[1]+.06,cz-13.5),C.stone,Enum.Material.Marble,false,podium)

-- =============================================================================
-- 2) TOWER SHELL / FLOOR PLATES
-- =============================================================================
local shell=model("ExecutiveTowerShell")
shell:SetAttribute("MainFootprint","52x34")
shell:SetAttribute("Floors",3)

local towerLeft=cx-TOWER_W/2
local towerRight=cx+TOWER_W/2
local towerSouth=cz-TOWER_D/2
local towerNorth=cz+TOWER_D/2
local coreLeft=coreX-CORE_W/2
local coreRight=coreX+CORE_W/2
local coreSouth=coreZ-CORE_D/2
local coreNorth=coreZ+CORE_D/2

local function slabWithCoreOpening(name,surfaceY,parent)
 local centerY=surfaceY-.4
 local leftWidth=coreLeft-towerLeft
 local rightWidth=towerRight-coreRight
 local southDepth=coreSouth-towerSouth
 local northDepth=towerNorth-coreNorth
 part(name.."West",Vector3.new(leftWidth,.8,TOWER_D),CFrame.new(towerLeft+leftWidth/2,centerY,cz),C.concrete,Enum.Material.Concrete,true,parent)
 part(name.."East",Vector3.new(rightWidth,.8,TOWER_D),CFrame.new(coreRight+rightWidth/2,centerY,cz),C.concrete,Enum.Material.Concrete,true,parent)
 part(name.."South",Vector3.new(CORE_W,.8,southDepth),CFrame.new(coreX,centerY,towerSouth+southDepth/2),C.concrete,Enum.Material.Concrete,true,parent)
 part(name.."North",Vector3.new(CORE_W,.8,northDepth),CFrame.new(coreX,centerY,coreNorth+northDepth/2),C.concrete,Enum.Material.Concrete,true,parent)
end

-- Level 1 uses the podium surface. Levels 2, 3 and roof retain a stair opening.
slabWithCoreOpening("Level2Slab",floorSurface[2],shell)
slabWithCoreOpening("Level3Slab",floorSurface[3],shell)
slabWithCoreOpening("RoofSlab",floorSurface[4],shell)

local function facadeLevel(name,floorY,nextSurfaceY,parent)
 local m=model(name,parent)
 local wallBottom=floorY
 local nextSlabBottom=nextSurfaceY-.8
 local h=nextSlabBottom-wallBottom
 local cy=wallBottom+h/2
 glass("FrontGlass",Vector3.new(TOWER_W,h,.34),CFrame.new(cx,cy,towerSouth),m,.38)
 glass("RearGlass",Vector3.new(TOWER_W,h,.34),CFrame.new(cx,cy,towerNorth),m,.38)
 glass("WestGlass",Vector3.new(.34,h,TOWER_D),CFrame.new(towerLeft,cy,cz),m,.38)
 -- East facade keeps a real 5-stud opening aligned with the private core for a future elevator/bridge handoff.
 local doorHalf=2.5
 local southDepth=(coreZ-doorHalf)-towerSouth
 local northDepth=towerNorth-(coreZ+doorHalf)
 glass("EastGlassSouth",Vector3.new(.34,h,southDepth),CFrame.new(towerRight,cy,towerSouth+southDepth/2),m,.38)
 glass("EastGlassNorth",Vector3.new(.34,h,northDepth),CFrame.new(towerRight,cy,coreZ+doorHalf+northDepth/2),m,.38)
 part("EastDoorHeader",Vector3.new(.55,1.0,5.0),CFrame.new(towerRight,nextSlabBottom-.5,coreZ),C.graphite,Enum.Material.Metal,true,m)
 for _,x in ipairs({towerLeft,cx-13,cx,cx+13,towerRight}) do
  part("FrameFront"..x,Vector3.new(.46,h,.55),CFrame.new(x,cy,towerSouth),C.graphite,Enum.Material.Metal,true,m)
  part("FrameRear"..x,Vector3.new(.46,h,.55),CFrame.new(x,cy,towerNorth),C.graphite,Enum.Material.Metal,true,m)
 end
 for _,z in ipairs({towerSouth,cz-5.7,cz+5.7,towerNorth}) do
  part("FrameWest"..z,Vector3.new(.55,h,.46),CFrame.new(towerLeft,cy,z),C.graphite,Enum.Material.Metal,true,m)
  part("FrameEast"..z,Vector3.new(.55,h,.46),CFrame.new(towerRight,cy,z),C.graphite,Enum.Material.Metal,true,m)
 end
 part("LowerBandFront",Vector3.new(TOWER_W,.55,.7),CFrame.new(cx,floorY+.28,towerSouth-.02),C.charcoal,Enum.Material.Metal,true,m)
 part("LowerBandRear",Vector3.new(TOWER_W,.55,.7),CFrame.new(cx,floorY+.28,towerNorth+.02),C.charcoal,Enum.Material.Metal,true,m)
 return m
end

facadeLevel("ModeratorFacade",floorSurface[1],floorSurface[2],shell)
facadeLevel("AdminFacade",floorSurface[2],floorSurface[3],shell)
facadeLevel("OwnerFacade",floorSurface[3],floorSurface[4],shell)

-- =============================================================================
-- 3) SERVICE STAIR CORE — PHYSICAL ONLY, NO ACCESS/PERMISSION LOGIC
-- =============================================================================
local core=model("PrivateAccessCore")
core:SetAttribute("FutureElevatorIntegration",true)
core:SetAttribute("RoleAccessAuthority","SYSTEM_HANDOFF_REQUIRED")
core:SetAttribute("OpenInteriorSide",true)

-- Keep the east/rear shaft walls for massing; the west side stays open to each interior floor.
part("CoreWallEast",Vector3.new(.45,39,CORE_D),CFrame.new(coreRight-.35,floorSurface[1]+19.5,coreZ),C.charcoal,Enum.Material.Concrete,true,core)
part("CoreRearWall",Vector3.new(CORE_W,39,.45),CFrame.new(coreX,floorSurface[1]+19.5,coreNorth-.25),C.charcoal,Enum.Material.Concrete,true,core)

local function stairRun(name,lowerSurface,upperSurface,reverse,parent)
 local m=model(name,parent)
 local steps=12
 local slabBottom=upperSurface-.8
 local availableRise=slabBottom-lowerSurface
 local rise=availableRise/steps
 local runDepth=(CORE_D-1.8)/steps
 for i=0,steps-1 do
  local zIndex=reverse and (steps-1-i) or i
  local z=coreSouth+.9+runDepth*(zIndex+.5)
  local y=lowerSurface+rise*(i+.5)
  part("Step"..i,Vector3.new(4.2,rise,runDepth+.04),CFrame.new(coreX-.8,y,z),C.stone,Enum.Material.Concrete,true,m)
 end
 local startZ=reverse and coreNorth-.9 or coreSouth+.9
 local endZ=reverse and coreSouth+.9 or coreNorth-.9
 local a=Vector3.new(coreX-3.1,lowerSurface+2.6,startZ)
 local b=Vector3.new(coreX-3.1,slabBottom+2.2,endZ)
 beamBetween("Handrail",a,b,.18,C.metal,m,false)
 return m
end

stairRun("StaffToAdmin",floorSurface[1],floorSurface[2],false,core)
stairRun("AdminToOwner",floorSurface[2],floorSurface[3],true,core)
stairRun("OwnerToRoof",floorSurface[3],floorSurface[4],false,core)

for _,y in ipairs({floorSurface[1],floorSurface[2],floorSurface[3],floorSurface[4]}) do
 part("CoreLanding"..y,Vector3.new(4.8,.3,2.1),CFrame.new(coreX-3.0,y+.15,coreNorth-1.15),C.stone,Enum.Material.Concrete,true,core)
end

-- =============================================================================
-- 4) LEVEL 1 — MODERATOR / STAFF LOUNGE
-- =============================================================================
local staff=model("ModeratorStaffFloor")
staff:SetAttribute("Program","LOBBY_LOUNGE_MEETING_OFFICE_PANTRY_RESTROOM")
local y1=floorSurface[1]

part("MeetingWall",Vector3.new(.34,8.8,13),CFrame.new(cx-8,y1+4.4,cz-8.5),C.charcoal,Enum.Material.Concrete,true,staff)
part("OfficeWall",Vector3.new(12,8.8,.34),CFrame.new(cx+6,y1+4.4,cz-2.5),C.charcoal,Enum.Material.Concrete,true,staff)
part("PantryWall",Vector3.new(16,8.8,.34),CFrame.new(cx+2,y1+4.4,cz+9.5),C.charcoal,Enum.Material.Concrete,true,staff)

sofa("LoungeSofaA",CFrame.new(cx-1,y1,cz+1),7.4,staff)
sofa("LoungeSofaB",CFrame.new(cx-1,y1,cz+8)*CFrame.Angles(0,math.rad(180),0),7.4,staff)
lowTable("LoungeTable",CFrame.new(cx-1,y1,cz+4.5),4.4,2.7,staff)

part("MeetingTable",Vector3.new(10,.7,4.2),CFrame.new(cx-17,y1+1.8,cz-8),C.wood,Enum.Material.WoodPlanks,true,staff)
for _,x in ipairs({cx-21,cx-17,cx-13}) do
 part("MeetingChairN"..x,Vector3.new(2.1,1.0,2.1),CFrame.new(x,y1+.8,cz-11),C.fabric,Enum.Material.Fabric,true,staff)
 part("MeetingChairS"..x,Vector3.new(2.1,1.0,2.1),CFrame.new(x,y1+.8,cz-5),C.fabric,Enum.Material.Fabric,true,staff)
end

desk("StaffDeskA",CFrame.new(cx+6,y1,cz-10),7.5,staff)
desk("StaffDeskB",CFrame.new(cx+6,y1,cz-5),7.5,staff)
part("PantryCounter",Vector3.new(14,2.6,2.2),CFrame.new(cx+3,y1+1.3,cz+13),C.wood,Enum.Material.WoodPlanks,true,staff)
part("PantryTop",Vector3.new(14.4,.25,2.5),CFrame.new(cx+3,y1+2.72,cz+13),C.stone,Enum.Material.Marble,true,staff)

-- Restroom is a real room shell with an open doorway, not a solid placeholder block.
local restX,restZ=cx+10,cz+9
part("RestroomBack",Vector3.new(7,8.2,.34),CFrame.new(restX,y1+4.1,restZ+3.35),C.graphite,Enum.Material.Concrete,true,staff)
part("RestroomWest",Vector3.new(.34,8.2,7),CFrame.new(restX-3.35,y1+4.1,restZ),C.graphite,Enum.Material.Concrete,true,staff)
part("RestroomEast",Vector3.new(.34,8.2,7),CFrame.new(restX+3.35,y1+4.1,restZ),C.graphite,Enum.Material.Concrete,true,staff)
part("RestroomFrontL",Vector3.new(2.3,8.2,.34),CFrame.new(restX-2.35,y1+4.1,restZ-3.35),C.graphite,Enum.Material.Concrete,true,staff)
part("RestroomFrontR",Vector3.new(2.3,8.2,.34),CFrame.new(restX+2.35,y1+4.1,restZ-3.35),C.graphite,Enum.Material.Concrete,true,staff)
part("RestroomVanity",Vector3.new(3.4,2.1,1.3),CFrame.new(restX-1.4,y1+1.05,restZ+2.35),C.stone,Enum.Material.Marble,true,staff)

-- =============================================================================
-- 5) LEVEL 2 — FOUR COMPACT ADMIN APARTMENTS
-- =============================================================================
local admin=model("AdminApartments")
admin:SetAttribute("UnitCount",4)
local y2=floorSurface[2]

-- Central corridor along Z. Short wall segments leave doorway gaps between apartments and corridor.
for _,x in ipairs({cx-19,cx-7,cx+5}) do
 part("CorridorSouth"..x,Vector3.new(8,9.2,.34),CFrame.new(x,y2+4.6,cz-2.5),C.charcoal,Enum.Material.Concrete,true,admin)
 part("CorridorNorth"..x,Vector3.new(8,9.2,.34),CFrame.new(x,y2+4.6,cz+2.5),C.charcoal,Enum.Material.Concrete,true,admin)
end
part("FrontUnitDivider",Vector3.new(.34,9.2,11),CFrame.new(cx-2,y2+4.6,cz-10.5),C.charcoal,Enum.Material.Concrete,true,admin)
part("RearUnitDivider",Vector3.new(.34,9.2,11),CFrame.new(cx-2,y2+4.6,cz+10.5),C.charcoal,Enum.Material.Concrete,true,admin)

local unitCenters={
 {name="AdminUnitA",x=cx-14,z=cz-10,yaw=0},
 {name="AdminUnitB",x=cx+8,z=cz-10,yaw=0},
 {name="AdminUnitC",x=cx-14,z=cz+10,yaw=180},
 {name="AdminUnitD",x=cx+8,z=cz+10,yaw=180},
}
for _,u in ipairs(unitCenters) do
 local unit=model(u.name,admin)
 unit:SetAttribute("StaticApartment",true)
 local base=CFrame.new(u.x,y2,u.z)*CFrame.Angles(0,math.rad(u.yaw),0)
 bed("Bed",base*CFrame.new(-2.7,0,1.7),5.2,6.3,unit)
 desk("Desk",base*CFrame.new(4.5,0,-2.8),4.8,unit)
 part("Wardrobe",Vector3.new(3.8,6.3,1.6),base*CFrame.new(5.2,3.15,3.8),C.wood,Enum.Material.WoodPlanks,true,unit)
 part("BathScreen",Vector3.new(4.2,6.2,.25),base*CFrame.new(5.0,3.1,1.0),C.glass,Enum.Material.Glass,true,unit,.48)
 part("Vanity",Vector3.new(3.8,2.2,1.4),base*CFrame.new(4.6,1.1,-.2),C.stone,Enum.Material.Marble,true,unit)
end

-- =============================================================================
-- 6) LEVEL 3 — OWNER PENTHOUSE
-- =============================================================================
local owner=model("OwnerPenthouse")
owner:SetAttribute("Program","PRIVATE_LOUNGE_BEDROOM_OFFICE_DRESSING_BATH_TERRACE_ACCESS")
local y3=floorSurface[3]

part("BedroomDivider",Vector3.new(.34,9.5,13),CFrame.new(cx-4,y3+4.75,cz+9.5),C.charcoal,Enum.Material.Concrete,true,owner)
part("OfficeDivider",Vector3.new(12,9.5,.34),CFrame.new(cx+7,y3+4.75,cz-2.5),C.charcoal,Enum.Material.Concrete,true,owner)
part("BathCoreDivider",Vector3.new(.34,9.5,11),CFrame.new(cx+11.2,y3+4.75,cz+9.5),C.charcoal,Enum.Material.Concrete,true,owner)

sofa("OwnerSofa",CFrame.new(cx-9,y3,cz-8),9.2,owner)
lowTable("OwnerCoffeeTable",CFrame.new(cx-9,y3,cz-3.4),5.4,3.2,owner)
part("MediaConsole",Vector3.new(10,2.2,1.8),CFrame.new(cx-9,y3+1.1,cz+1),C.wood,Enum.Material.WoodPlanks,true,owner)

bed("OwnerBed",CFrame.new(cx-15,y3,cz+9),7.0,7.5,owner)
part("OwnerWardrobe",Vector3.new(5.2,7.0,2.0),CFrame.new(cx-22,y3+3.5,cz+7),C.wood,Enum.Material.WoodPlanks,true,owner)

desk("OwnerDesk",CFrame.new(cx+9,y3,cz-8),8.5,owner)
part("OfficeCredenza",Vector3.new(8,2.4,1.8),CFrame.new(cx+14,y3+1.2,cz-3.5),C.wood,Enum.Material.WoodPlanks,true,owner)

-- Bath / dressing stays west of the stair core so circulation remains clear.
part("BathVanity",Vector3.new(6.5,2.4,1.8),CFrame.new(cx+7,y3+1.2,cz+10),C.stone,Enum.Material.Marble,true,owner)
glass("ShowerGlass",Vector3.new(5.2,7,.25),CFrame.new(cx+9,y3+3.5,cz+12.5),owner,.45)
part("DressingBench",Vector3.new(5.6,.8,2.2),CFrame.new(cx+7,y3+.5,cz+4),C.fabric,Enum.Material.Fabric,true,owner)

-- =============================================================================
-- 7) ROOF TERRACE — VISUAL HELIPAD LOOK, NO VEHICLE SYSTEM
-- =============================================================================
local roof=model("PrivateRoofTerrace")
roof:SetAttribute("HelipadVisualOnly",true)
local yr=floorSurface[4]

for _,z in ipairs({towerSouth,towerNorth}) do
 glass("RoofGlassZ"..z,Vector3.new(TOWER_W,3.7,.28),CFrame.new(cx,yr+1.85,z),roof,.45)
end
for _,x in ipairs({towerLeft,towerRight}) do
 glass("RoofGlassX"..x,Vector3.new(.28,3.7,TOWER_D),CFrame.new(x,yr+1.85,cz),roof,.45)
end

-- Guard the stair opening on three sides; south remains the intentional stair exit.
glass("CoreGuardWest",Vector3.new(.28,3.4,CORE_D),CFrame.new(coreLeft,yr+1.7,coreZ),roof,.46)
glass("CoreGuardEast",Vector3.new(.28,3.4,CORE_D),CFrame.new(coreRight,yr+1.7,coreZ),roof,.46)
glass("CoreGuardNorth",Vector3.new(CORE_W,3.4,.28),CFrame.new(coreX,yr+1.7,coreNorth),roof,.46)

cylinder("HelipadOuter",.18,16,CFrame.new(cx-10,yr+.12,cz),C.graphite,Enum.Material.Metal,false,roof)
cylinder("HelipadInner",.20,12.5,CFrame.new(cx-10,yr+.23,cz),C.charcoal,Enum.Material.Metal,false,roof)
part("HLeft",Vector3.new(.8,.12,6),CFrame.new(cx-13,yr+.35,cz),C.white,Enum.Material.SmoothPlastic,false,roof)
part("HRight",Vector3.new(.8,.12,6),CFrame.new(cx-7,yr+.35,cz),C.white,Enum.Material.SmoothPlastic,false,roof)
part("HBridge",Vector3.new(6,.12,.8),CFrame.new(cx-10,yr+.35,cz),C.white,Enum.Material.SmoothPlastic,false,roof)

sofa("RoofSofa",CFrame.new(cx+11,yr,cz-6),7.2,roof)
lowTable("RoofTable",CFrame.new(cx+11,yr,cz-1.5),4.2,2.7,roof)
planter("RoofPlanterNE",CFrame.new(cx+8,yr,cz+12),roof)
planter("RoofPlanterSE",CFrame.new(cx+21,yr,cz-12),roof)
planter("RoofPlanterNW",CFrame.new(cx-22,yr,cz+12),roof)

-- =============================================================================
-- 8) RESTRAINED ARCHITECTURAL LIGHTING — STATIC, NO SHADOWS, NO LOOPS
-- =============================================================================
local lighting=model("TowerArchitecturalLighting")
for levelIndex=1,3 do
 local y=floorSurface[levelIndex+1]-.95
 for i,x in ipairs({cx-17,cx-5,cx+7}) do
  local fixture=part("CeilingFixture"..levelIndex.."_"..i,Vector3.new(1.2,.18,1.2),CFrame.new(x,y,cz),C.brass,Enum.Material.Metal,false,lighting)
  localLight(fixture,.42,12)
 end
end
for i,x in ipairs({cx-20,cx+20}) do
 local bollard=part("RoofBollard"..i,Vector3.new(.8,2.2,.8),CFrame.new(x,yr+1.1,cz-13),C.graphite,Enum.Material.Metal,true,lighting)
 localLight(bollard,.30,8)
end

-- Source-derived spatial evidence for later QC / integration handoff.
tower:SetAttribute("FunkotCenterX",cx)
tower:SetAttribute("FunkotCenterZ",cz)
tower:SetAttribute("FunkotRoofTopY",roofTop)
tower:SetAttribute("PodiumWidth",PODIUM_W)
tower:SetAttribute("PodiumDepth",PODIUM_D)
tower:SetAttribute("TowerWidth",TOWER_W)
tower:SetAttribute("TowerDepth",TOWER_D)
tower:SetAttribute("ModeratorFloorY",floorSurface[1])
tower:SetAttribute("AdminFloorY",floorSurface[2])
tower:SetAttribute("OwnerFloorY",floorSurface[3])
tower:SetAttribute("RoofTerraceY",floorSurface[4])
tower:SetAttribute("InstalledDescendants",#tower:GetDescendants())

print("[BBYA] Staff Tower v1 built above Funkot: moderator lounge / 4 admin apartments / owner penthouse / private roof terrace")