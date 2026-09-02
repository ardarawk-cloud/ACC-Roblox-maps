-- BBYA SOCIAL HUB — MALL VERTICAL SPACING 20 + CINEMA v16
-- TEST branch authority for Mall vertical structure only.
-- Floor levels: L1=1, L2=21, L3=41, L4=61 (20 studs floor-to-floor).
-- Keeps the v15 lift-facing Cinema orientation and center corridor to Sky Lounge.
-- No audio / Fishing / global Lighting / VIP / Night Market / economy changes.

local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local mall=root:WaitForChild("BBYAMall",60)
if not mall then return end

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
local state=remotes and remotes:FindFirstChild("State")
local mallAction=remotes and remotes:FindFirstChild("MallAction")

local C={
 dark=Color3.fromRGB(25,27,31),
 graphite=Color3.fromRGB(48,50,55),
 slate=Color3.fromRGB(72,70,69),
 carpet=Color3.fromRGB(54,43,49),
 red=Color3.fromRGB(176,50,58),
 gold=Color3.fromRGB(211,168,90),
 white=Color3.fromRGB(242,241,237),
 glass=Color3.fromRGB(115,143,155),
 warmStone=Color3.fromRGB(112,107,101),
}

local LEVELS={1,21,41,61}
local OFFSETS={0,6,12,18}

local function part(name,size,cf,color,mat,collide,parent,tr)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.CFrame=cf
 p.Color=color or C.dark
 p.Material=mat or Enum.Material.SmoothPlastic
 p.Anchored=true
 p.CanCollide=collide==true
 p.CanTouch=false
 p.CanQuery=false
 p.Transparency=tr or 0
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or mall
 return p
end

local function textOn(partObj,text,color)
 local oldGui=partObj:FindFirstChildOfClass("SurfaceGui")
 if oldGui then oldGui:Destroy() end
 local gui=Instance.new("SurfaceGui")
 gui.Face=Enum.NormalId.Front
 gui.PixelsPerStud=55
 gui.LightInfluence=.05
 gui.Parent=partObj
 local label=Instance.new("TextLabel")
 label.Size=UDim2.fromScale(1,1)
 label.BackgroundTransparency=1
 label.Text=text
 label.TextColor3=color or C.white
 label.Font=Enum.Font.GothamBold
 label.TextScaled=true
 label.TextWrapped=true
 label.Parent=gui
 return label
end

local function toast(player,msg)
 if state and state:IsA("RemoteEvent") then state:FireClient(player,"toast",msg) end
end

local function prompt(parent,action,obj,callback)
 local q=Instance.new("ProximityPrompt")
 q.ActionText=action
 q.ObjectText=obj
 q.HoldDuration=.05
 q.MaxActivationDistance=10
 q.RequiresLineOfSight=false
 q.Parent=parent
 if callback then q.Triggered:Connect(callback) end
 return q
end

local function cinemaSeat(name,cf,parent)
 local s=Instance.new("Seat")
 s.Name=name
 s.Size=Vector3.new(2.6,.75,2.5)
 s.CFrame=cf
 s.Color=Color3.fromRGB(68,52,58)
 s.Material=Enum.Material.Fabric
 s.Anchored=true
 s.CanCollide=true
 s.Parent=parent
 local back=part(name.."Back",Vector3.new(2.6,2.3,.35),cf*CFrame.new(0,1.25,1.05),Color3.fromRGB(58,44,50),Enum.Material.Fabric,true,parent,0)
 back.CanQuery=false
 return s
end

local function moveModel(modelObj,dy)
 if not modelObj or not modelObj:IsA("Model") or dy==0 then return end
 modelObj:PivotTo(CFrame.new(0,dy,0)*modelObj:GetPivot())
end

local function shiftPart(partObj,dy)
 if not partObj or not partObj:IsA("BasePart") or dy==0 then return end
 partObj.CFrame=CFrame.new(0,dy,0)*partObj.CFrame
end

local function floorOffsetForY(y)
 if y>=58 then return 23 end
 if y>=43 then return 18 end
 if y>=29 then return 12 end
 if y>=15 then return 6 end
 return 0
end

local function shiftModelPartsByOldFloor(modelObj)
 if not modelObj then return end
 for _,d in ipairs(modelObj:GetDescendants()) do
  if d:IsA("BasePart") then
   shiftPart(d,floorOffsetForY(d.Position.Y))
  end
 end
end

local function setWorldY(p,newY)
 local pos=p.Position
 p.CFrame=CFrame.new(pos.X,newY,pos.Z)*p.CFrame.Rotation
end

local function setTallPart(p,newY,newHeight)
 setWorldY(p,newY)
 p.Size=Vector3.new(p.Size.X,newHeight,p.Size.Z)
end

-- Wait for the previous Mall passes to finish their geometry before one coherent reflow.
local deadline=os.clock()+150
while mall:GetAttribute("MallCentralLift")~="V11" and os.clock()<deadline do task.wait(.25) end
local live=mall:WaitForChild("MallLiveUpgradeV2",90)
local architecture=mall:WaitForChild("MallArchitectureV3",90)
if architecture then architecture:WaitForChild("LayeredFrontFacadeV3",30) end
task.wait(1.5)

-- -----------------------------------------------------------------------------
-- 1) ONE-TIME 20 STUD VERTICAL REFLOW
-- -----------------------------------------------------------------------------
if mall:GetAttribute("FloorSpacingStuds")~=20 then
 -- Floor plates and their railings.
 moveModel(mall:FindFirstChild("Level2"),6)
 moveModel(mall:FindFirstChild("Level3"),12)
 moveModel(mall:FindFirstChild("Level4"),18)

 -- Retail tenant floors: first six remain L1, next six move with L2.
 for _,name in ipairs({
  "Tenant_north","Tenant_street","Tenant_page","Tenant_glow","Tenant_sound","Tenant_fit"
 }) do moveModel(mall:FindFirstChild(name),6) end

 -- Destination floors.
 for _,name in ipairs({"FoodHall","SkylineCafe","PixelArcade","LittleCity"}) do
  moveModel(mall:FindFirstChild(name),12)
 end
 for _,name in ipairs({"BBYACinema","SkyLounge"}) do
  moveModel(mall:FindFirstChild(name),18)
 end

 -- Base exterior shell reaches the new roofline instead of stopping at the old 58-stud top.
 for _,name in ipairs({"WestExterior","EastExterior","RearExterior"}) do
  local p=mall:FindFirstChild(name)
  if p and p:IsA("BasePart") then setTallPart(p,40.5,81) end
 end
 for _,name in ipairs({"FrontGlassLeft","FrontGlassRight"}) do
  local p=mall:FindFirstChild(name)
  if p and p:IsA("BasePart") then setTallPart(p,40.5,77) end
 end
 for _,d in ipairs(mall:GetChildren()) do
  if d:IsA("BasePart") and d.Name:match("^FrontFin") then setTallPart(d,40.5,78) end
 end
 for _,name in ipairs({"RoofWest","RoofEast","RoofSouth","RoofNorth","AtriumSkylight"}) do
  local p=mall:FindFirstChild(name)
  if p and p:IsA("BasePart") then setWorldY(p,81) end
 end
 for _,d in ipairs(mall:GetChildren()) do
  if d:IsA("BasePart") and d.Name:match("^SkylightRib") then setWorldY(d,80.5) end
 end
 local hero=mall:FindFirstChild("MallHeroSign");if hero and hero:IsA("BasePart") then setWorldY(hero,73) end
 local underline=mall:FindFirstChild("HeroUnderline");if underline and underline:IsA("BasePart") then setWorldY(underline,67.7) end
 local sub=mall:FindFirstChild("MallSubSign");if sub and sub:IsA("BasePart") then setWorldY(sub,64) end

 -- Later Mall live objects that were authored against the old floor elevations.
 if live then shiftModelPartsByOldFloor(live) end

 -- Architecture pass: retail-depth pieces move with their floors; facade crown is stretched explicitly.
 if architecture then
  local storefrontDepth=architecture:FindFirstChild("StorefrontDepthV3",true)
  if storefrontDepth then shiftModelPartsByOldFloor(storefrontDepth) end

  for _,d in ipairs(architecture:GetDescendants()) do
   if d:IsA("BasePart") then
    if d.Name:match("^Spandrel1") then setWorldY(d,20)
    elseif d.Name:match("^Spandrel2") then setWorldY(d,40)
    elseif d.Name:match("^Spandrel3") then setWorldY(d,60)
    elseif d.Name=="SideDatum" then setWorldY(d,20)
    elseif d.Name=="SideDatumUpper" then setWorldY(d,60)
    elseif d.Name:match("^AngledFacadeBlade") then setTallPart(d,37.5,66)
    elseif d.Name:match("^SidePilaster") and not d.Name:match("Cap") then setTallPart(d,36.5,69)
    elseif d.Name:match("^RearPilaster") then setTallPart(d,36,68)
    elseif d.Name=="FrontCornice" then setWorldY(d,78.4)
    elseif d.Name=="CorniceReveal" then setWorldY(d,77.95)
    elseif d.Name:match("^RoofBlade") then setWorldY(d,84.8)
    elseif d.Name=="RoofCrownCenter" then setWorldY(d,82.8)
    elseif d.Name=="RearCornice" then setWorldY(d,76.8)
    end
   end
  end
 end

 -- Atmosphere rails/lights may already exist; move each item to its corresponding new level.
 local atmosphere=mall:FindFirstChild("MallPremiumAtmosphereV9")
 if atmosphere then
  shiftModelPartsByOldFloor(atmosphere)
  atmosphere:SetAttribute("FloorSpacing20Applied",true)
 else
  task.spawn(function()
   local later=mall:WaitForChild("MallPremiumAtmosphereV9",180)
   if later and not later:GetAttribute("FloorSpacing20Applied") then
    task.wait(1)
    shiftModelPartsByOldFloor(later)
    later:SetAttribute("FloorSpacing20Applied",true)
   end
  end)
 end

 mall:SetAttribute("FloorSpacingStuds",20)
 mall:SetAttribute("FloorLevels","1,21,41,61")
 mall:SetAttribute("VerticalAuthority","V16_20_STUD")
end

-- -----------------------------------------------------------------------------
-- 2) REBUILD SWITCHBACK STAIRS FOR A TRUE 20-STUD RISE
-- -----------------------------------------------------------------------------
local oldEscal=mall:FindFirstChild("Escalators")
if oldEscal then oldEscal:Destroy() end
local escal=Instance.new("Model")
escal.Name="Escalators"
escal:SetAttribute("Pass","V16_20_STUD_SWITCHBACK")
escal.Parent=mall

local function beamBetween(name,a,b,color,parentObj,thickness)
 local mid=(a+b)/2
 local len=(b-a).Magnitude
 local p=part(name,Vector3.new(thickness or .15,thickness or .15,len),CFrame.lookAt(mid,b),color,Enum.Material.Metal,false,parentObj,0)
 p.CastShadow=false
 return p
end

local function buildSwitchback20(name,baseY,edgeZ,dir,xBase)
 local stair=Instance.new("Model")
 stair.Name=name
 stair.Parent=escal
 local xA=xBase-3.55
 local xB=xBase+3.55
 local depth=1.42
 local run=.90
 local stepH=.46
 local firstStart=edgeZ+dir*1.15
 local midZ=edgeZ+dir*10.35

 for i=0,9 do
  local z=firstStart+dir*(i*run)
  local y=baseY+.72+i
  part("FlightA_Step"..i,Vector3.new(5.9,stepH,depth),CFrame.new(xA,y,z),C.graphite,Enum.Material.Metal,true,stair,0)
 end
 part("MidLanding",Vector3.new(14.5,.48,3.6),CFrame.new(xBase,baseY+10.0,midZ),C.warmStone,Enum.Material.Slate,true,stair,0)
 for i=0,9 do
  local z=midZ-dir*(1.15+i*run)
  local y=baseY+10.72+i
  part("FlightB_Step"..i,Vector3.new(5.9,stepH,depth),CFrame.new(xB,y,z),C.graphite,Enum.Material.Metal,true,stair,0)
 end
 part("LowerLanding",Vector3.new(8.6,.42,3.1),CFrame.new(xA,baseY+.22,edgeZ+dir*.72),C.warmStone,Enum.Material.Slate,true,stair,0)
 part("UpperLanding",Vector3.new(8.6,.42,3.1),CFrame.new(xB,baseY+20.22,edgeZ+dir*.72),C.warmStone,Enum.Material.Slate,true,stair,0)

 local firstA=Vector3.new(xA-3.0,baseY+2.0,firstStart)
 local firstB=Vector3.new(xA-3.0,baseY+10.4,midZ-dir*.3)
 local secondA=Vector3.new(xB+3.0,baseY+11.0,midZ-dir*.3)
 local secondB=Vector3.new(xB+3.0,baseY+20.9,edgeZ+dir*1.0)
 beamBetween("OuterRailA",firstA,firstB,C.gold,stair,.14)
 beamBetween("OuterRailB",secondA,secondB,C.gold,stair,.14)
 beamBetween("InnerRailA",Vector3.new(xA+3.0,firstA.Y,firstA.Z),Vector3.new(xA+3.0,firstB.Y,firstB.Z),C.gold,stair,.11)
 beamBetween("InnerRailB",Vector3.new(xB-3.0,secondA.Y,secondA.Z),Vector3.new(xB-3.0,secondB.Y,secondB.Z),C.gold,stair,.11)
end

buildSwitchback20("L1_L2_SouthWest",LEVELS[1],338,1,-18)
buildSwitchback20("L2_L3_NorthEast",LEVELS[2],392,-1,18)
buildSwitchback20("L3_L4_SouthWest",LEVELS[3],338,1,-18)

-- -----------------------------------------------------------------------------
-- 3) REAR-WALL LIFT AT 20-STUD LEVELS
-- -----------------------------------------------------------------------------
local oldLift=mall:FindFirstChild("ElevatorCore")
if oldLift then oldLift:Destroy() end
local elevator=Instance.new("Model")
elevator.Name="ElevatorCore"
elevator:SetAttribute("Pass","REAR_WALL_LIFT_V16_20_STUD")
elevator:SetAttribute("RearWallFlush",true)
elevator:SetAttribute("CinemaArrivalAxis","CENTER_SPINE")
elevator.Parent=mall

local doorZ=434.6
local rearZ=442.0
local lobbyZ=428.5
part("LiftRearPanel",Vector3.new(16.5,77,.6),CFrame.new(0,39,rearZ),C.glass,Enum.Material.Glass,true,elevator,.38)
for _,x in ipairs({-8.2,8.2}) do
 part("LiftPier"..x,Vector3.new(1.2,77,8.5),CFrame.new(x,39,438.0),C.graphite,Enum.Material.Metal,true,elevator,0)
end

local function liftPrompt(parentObj,action,targetFloor,targetY)
 prompt(parentObj,action,"LIFT • L"..targetFloor,function(player)
  local char=player.Character
  if char then
   char:PivotTo(CFrame.new(0,targetY+3,424.5))
   toast(player,"Lift • Level "..targetFloor)
  end
 end)
end

for i,y in ipairs(LEVELS) do
 part("LiftLobby"..i,Vector3.new(21,.42,11),CFrame.new(0,y+.72,lobbyZ),C.slate,Enum.Material.Slate,true,elevator,0)
 part("LiftDoorL"..i,Vector3.new(6.2,8.5,.35),CFrame.new(-3.15,y+5.1,doorZ),C.dark,Enum.Material.Metal,true,elevator,0)
 part("LiftDoorR"..i,Vector3.new(6.2,8.5,.35),CFrame.new(3.15,y+5.1,doorZ),C.dark,Enum.Material.Metal,true,elevator,0)
 local header=part("LiftHeader"..i,Vector3.new(15,2.25,.28),CFrame.new(0,y+10.15,doorZ-.1),C.graphite,Enum.Material.Metal,false,elevator,0)
 if i==4 then textOn(header,"L4 • CINEMA\nA  ←   LIFT   →  B",C.gold) else textOn(header,"REAR LIFT • L"..i,C.white) end
 if i<4 then
  local up=part("LiftUpPad"..i,Vector3.new(3.2,.2,3.2),CFrame.new(-4,y+1.02,423.2),C.gold,Enum.Material.Neon,false,elevator,.20)
  up.CanQuery=true
  liftPrompt(up,"UP",i+1,LEVELS[i+1])
 end
 if i>1 then
  local down=part("LiftDownPad"..i,Vector3.new(3.2,.2,3.2),CFrame.new(4,y+1.02,423.2),C.white,Enum.Material.Neon,false,elevator,.34)
  down.CanQuery=true
  liftPrompt(down,"DOWN",i-1,LEVELS[i-1])
 end
end
mall:SetAttribute("MallCentralLift","V16_20_STUD_REAR_WALL")
mall:SetAttribute("MallLiftRearWallFlush",true)

-- -----------------------------------------------------------------------------
-- 4) L4 CINEMA AT Y=61 — A LEFT / B RIGHT / CENTER SPINE OPEN
-- -----------------------------------------------------------------------------
local oldPass=mall:FindFirstChild("MallCinemaLiftV12")
if oldPass then oldPass:Destroy() end
local pass=Instance.new("Model")
pass.Name="MallCinemaLiftV12"
pass:SetAttribute("Pass","CINEMA_LIFT_SPACING_V16")
pass.Parent=mall

local cinema=mall:WaitForChild("BBYACinema",60)
if cinema then
 for _,name in ipairs({"CinemaLobby","Concession","ConcessionTop","CinemaHero"}) do
  local d=cinema:FindFirstChild(name,true)
  if d then d:Destroy() end
 end
 for i=1,4 do
  for _,prefix in ipairs({"Theatre","TheatreSign"}) do
   local d=cinema:FindFirstChild(prefix..i,true)
   if d then d:Destroy() end
  end
 end
 local previous=cinema:FindFirstChild("CinemaExperienceV12")
 if previous then previous:Destroy() end

 local cxModel=Instance.new("Model")
 cxModel.Name="CinemaExperienceV12"
 cxModel:SetAttribute("Orientation","V16_LIFT_FACING_20_STUD")
 cxModel:SetAttribute("CenterSpineClear",true)
 cxModel.Parent=cinema

 local y=LEVELS[4]
 local centerZ=414
 local innerX=16
 local outerX=84
 local roomCenter=50
 local roomLength=68
 local roomDepth=38
 local southZ=centerZ-roomDepth/2
 local northZ=centerZ+roomDepth/2

 part("CinemaArrivalFloor",Vector3.new(172,.42,43),CFrame.new(0,y+.72,413.5),C.carpet,Enum.Material.Carpet,true,cxModel,0)
 local spine=part("CenterSpine",Vector3.new(17,.08,40),CFrame.new(0,y+1.0,413.5),C.gold,Enum.Material.Neon,false,cxModel,.64)
 spine.CastShadow=false
 local wayfinding=part("CinemaWayfinding",Vector3.new(28,3.2,.30),CFrame.new(0,y+10.8,425.2),C.graphite,Enum.Material.Metal,false,cxModel,0)
 textOn(wayfinding,"SCREEN A  ←     →  SCREEN B\nMALL / SKY LOUNGE  ↓",C.white)

 local snack=part("CinemaConcessionV16",Vector3.new(7,2.8,4.5),CFrame.new(-10.8,y+2.4,397.5),C.graphite,Enum.Material.Metal,true,cxModel,0)
 local snackTop=part("CinemaConcessionGlowV16",Vector3.new(7.4,.16,4.8),CFrame.new(-10.8,y+3.9,397.5),C.red,Enum.Material.Neon,false,cxModel,.10)
 snackTop.CastShadow=false
 local snackSign=part("CinemaSnackSignV16",Vector3.new(6.8,1.8,.25),CFrame.new(-10.8,y+6.0,395.15),C.dark,Enum.Material.Metal,false,cxModel,0)
 textOn(snackSign,"SNACKS • DRINKS",C.gold)
 prompt(snack,"ORDER","CINEMA BAR",function(player)toast(player,"Cinema bar • order received")end)

 local function buildSideRoom(label,side)
  local room=Instance.new("Model")
  room.Name="Screen"..label
  room:SetAttribute("EntranceFacesCenter",true)
  room.Parent=cxModel
  local cx=side*roomCenter
  local inner=side*innerX
  local outer=side*outerX
  local signYaw=(side<0) and math.rad(-90) or math.rad(90)
  local seatYaw=(side<0) and math.rad(90) or math.rad(-90)

  part("Floor",Vector3.new(roomLength,.4,roomDepth),CFrame.new(cx,y+.92,centerZ),Color3.fromRGB(43,36,40),Enum.Material.Carpet,true,room,0)
  part("Ceiling",Vector3.new(roomLength,.45,roomDepth),CFrame.new(cx,y+17.5,centerZ),Color3.fromRGB(33,34,38),Enum.Material.Metal,true,room,0)
  part("OuterWall",Vector3.new(1,17,roomDepth),CFrame.new(outer,y+9.3,centerZ),C.dark,Enum.Material.Slate,true,room,0)
  part("SouthWall",Vector3.new(roomLength,17,1),CFrame.new(cx,y+9.3,southZ),C.dark,Enum.Material.Slate,true,room,0)
  part("NorthWall",Vector3.new(roomLength,17,1),CFrame.new(cx,y+9.3,northZ),C.dark,Enum.Material.Slate,true,room,0)

  local doorwayHalf=6.0
  local segmentDepth=(roomDepth-(doorwayHalf*2))/2
  local southSegZ=southZ+segmentDepth/2
  local northSegZ=northZ-segmentDepth/2
  part("InnerWallSouth",Vector3.new(1,17,segmentDepth),CFrame.new(inner,y+9.3,southSegZ),C.dark,Enum.Material.Slate,true,room,0)
  part("InnerWallNorth",Vector3.new(1,17,segmentDepth),CFrame.new(inner,y+9.3,northSegZ),C.dark,Enum.Material.Slate,true,room,0)

  local entryHead=part("EntryHeader",Vector3.new(12,2.5,.34),CFrame.new(inner,y+13.7,centerZ)*CFrame.Angles(0,signYaw,0),C.graphite,Enum.Material.Metal,false,room,0)
  textOn(entryHead,"SCREEN "..label,C.gold)
  local threshold=part("EntryGlow",Vector3.new(4.5,.08,11),CFrame.new(inner-side*2.2,y+1.04,centerZ),C.red,Enum.Material.Neon,false,room,.38)
  threshold.CastShadow=false

  local screenX=outer-side*.72
  local frame=part("ScreenFrame",Vector3.new(30,10.8,.55),CFrame.new(screenX,y+10.0,centerZ)*CFrame.Angles(0,signYaw,0),Color3.fromRGB(9,10,12),Enum.Material.Metal,false,room,0)
  local screen=part("MovieScreen",Vector3.new(27,8.8,.18),CFrame.new(screenX-side*.20,y+10.0,centerZ)*CFrame.Angles(0,signYaw,0),Color3.fromRGB(220,220,216),Enum.Material.SmoothPlastic,false,room,0)
  frame.CastShadow=false
  screen.CastShadow=false
  textOn(screen,"BBYA CINEMA\nSCREEN "..label,Color3.fromRGB(40,41,45))

  for row=1,5 do
   local rowX=inner+side*(10+(row-1)*10)
   local rise=(row-1)*.55
   part("Riser"..row,Vector3.new(7.8,.30,32),CFrame.new(rowX,y+1.05+rise/2,centerZ),Color3.fromRGB(48,39,43),Enum.Material.Carpet,true,room,0)
   for _,zo in ipairs({-12,-8,-4,4,8,12}) do
    cinemaSeat("Seat"..row.."_"..zo,CFrame.new(rowX,y+1.55+rise,centerZ+zo)*CFrame.Angles(0,seatYaw,0),room)
   end
  end

  local showPad=part("ShowtimePad",Vector3.new(3,2.2,3),CFrame.new(inner-side*3.3,y+2.0,centerZ+7.8),C.red,Enum.Material.Neon,false,room,.30)
  showPad.CanQuery=true
  prompt(showPad,"SHOWTIMES","SCREEN "..label,function(player)
   toast(player,"Screen "..label.." • Neon City 19:00 • Midnight Run 21:10 • After Hours 23:30")
  end)
 end

 buildSideRoom("A",-1)
 buildSideRoom("B",1)
 cinema:SetAttribute("Experience","REAL_SCREENING_ROOMS_V16")
 cinema:SetAttribute("LiftFacingEntrances",true)
 cinema:SetAttribute("CenterSpineClear",true)
 cinema:SetAttribute("L4Circulation","V16_20_STUD_CINEMA_SIDE_ROOMS")
 mall:SetAttribute("MallCinemaExperience","V16_LIFT_FACING_20_STUD")
end

-- -----------------------------------------------------------------------------
-- 5) L4 ATRIUM SAFETY AT THE NEW Y=61 FLOOR
-- -----------------------------------------------------------------------------
local floor4=mall:FindFirstChild("Level4")
if floor4 then
 for _,d in ipairs(floor4:GetChildren()) do
  if d:IsA("BasePart") and (d.Name:match("^AtriumRailX4") or d.Name:match("^AtriumRailZ4")) then d:Destroy() end
 end
 local railY=LEVELS[4]+2.4
 local centerZ=365
 local southZ=338
 local northZ=392
 local edgeX=30
 local atriumDepth=54
 local atriumWidth=60
 local stairGapCenter=-14.45
 local stairGapWidth=12.5
 local cinemaGapCenter=0
 local cinemaGapWidth=22
 local leftEdge=-atriumWidth/2
 local rightEdge=atriumWidth/2

 local function glassRail(name,size,cf)
  local r=part(name,size,cf,C.glass,Enum.Material.Glass,true,floor4,.48)
  r.CastShadow=false
  return r
 end
 glassRail("AtriumRailX4_V16_W",Vector3.new(.35,4.2,atriumDepth),CFrame.new(-edgeX,railY,centerZ))
 glassRail("AtriumRailX4_V16_E",Vector3.new(.35,4.2,atriumDepth),CFrame.new(edgeX,railY,centerZ))

 local cinemaGapLeft=cinemaGapCenter-cinemaGapWidth/2
 local cinemaGapRight=cinemaGapCenter+cinemaGapWidth/2
 local northLeftWidth=cinemaGapLeft-leftEdge
 local northRightWidth=rightEdge-cinemaGapRight
 if northLeftWidth>0 then glassRail("AtriumRailZ4_V16_NL",Vector3.new(northLeftWidth,4.2,.35),CFrame.new(leftEdge+northLeftWidth/2,railY,northZ)) end
 if northRightWidth>0 then glassRail("AtriumRailZ4_V16_NR",Vector3.new(northRightWidth,4.2,.35),CFrame.new(cinemaGapRight+northRightWidth/2,railY,northZ)) end

 local stairGapLeft=stairGapCenter-stairGapWidth/2
 local stairGapRight=stairGapCenter+stairGapWidth/2
 local southLeftWidth=stairGapLeft-leftEdge
 local southRightWidth=rightEdge-stairGapRight
 if southLeftWidth>0 then glassRail("AtriumRailZ4_V16_SL",Vector3.new(southLeftWidth,4.2,.35),CFrame.new(leftEdge+southLeftWidth/2,railY,southZ)) end
 if southRightWidth>0 then glassRail("AtriumRailZ4_V16_SR",Vector3.new(southRightWidth,4.2,.35),CFrame.new(stairGapRight+southRightWidth/2,railY,southZ)) end

 floor4:SetAttribute("AtriumSafety","V16_20_STUD")
 floor4:SetAttribute("SouthStairGapWidth",stairGapWidth)
 floor4:SetAttribute("NorthCinemaGapWidth",cinemaGapWidth)
 mall:SetAttribute("MallL4AtriumSafety","V16_20_STUD")
end

-- -----------------------------------------------------------------------------
-- 6) CORRECT LEGACY DIRECTORY TELEPORT Y AFTER THE ORIGINAL GUIDE HANDLER RUNS
-- -----------------------------------------------------------------------------
if mallAction and mallAction:IsA("RemoteEvent") then
 local destinationFloor={
  luma=1,stride=1,byte=1,daily=1,mono=1,muse=1,
  north=2,street=2,page=2,glow=2,sound=2,fit=2,
  food=3,cafe=3,arcade=3,kids=3,
  cinema=4,lounge=4,
 }
 mallAction.OnServerEvent:Connect(function(player,action,id)
  if action~="guide" then return end
  local floor=destinationFloor[tostring(id or "")]
  if not floor then return end
  task.delay(.12,function()
   local char=player.Character
   if not char then return end
   local pivot=char:GetPivot()
   char:PivotTo(CFrame.new(pivot.Position.X,LEVELS[floor]+3,pivot.Position.Z)*pivot.Rotation)
  end)
 end)
end

pass:SetAttribute("CinemaBuilt",cinema~=nil)
pass:SetAttribute("LiftRearWall",true)
pass:SetAttribute("L4Safety","V16")
pass:SetAttribute("CinemaAtriumAccess",true)
pass:SetAttribute("CenterSpineClear",true)
pass:SetAttribute("ScreenA_Left",true)
pass:SetAttribute("ScreenB_Right",true)
pass:SetAttribute("FloorSpacingStuds",20)
mall:SetAttribute("MallScreenshotQC","V16_20_STUD")
print("[BBYA] Mall v16 online: 20-stud floor spacing; L1=1 L2=21 L3=41 L4=61; lift/stairs/cinema/guide aligned")
