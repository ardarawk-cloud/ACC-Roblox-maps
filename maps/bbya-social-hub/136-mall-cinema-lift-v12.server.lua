-- BBYA SOCIAL HUB — MALL CINEMA + REAR LIFT v12 / L4 SAFETY v13
-- Screenshot-driven Mall-only refinement.
-- Keeps the v12 cinema and rear lift in place, then fixes L4 circulation and fall hazards.
-- No audio / Fishing / global Lighting / VIP / Night Market / economy changes.

local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local mall=root:WaitForChild("BBYAMall",60)
if not mall then return end

local old=mall:FindFirstChild("MallCinemaLiftV12")
if old then old:Destroy() end
local pass=Instance.new("Model")
pass.Name="MallCinemaLiftV12"
pass.Parent=mall

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
local state=remotes and remotes:FindFirstChild("State")

local C={
 dark=Color3.fromRGB(25,27,31),
 graphite=Color3.fromRGB(48,50,55),
 slate=Color3.fromRGB(72,70,69),
 carpet=Color3.fromRGB(54,43,49),
 red=Color3.fromRGB(176,50,58),
 gold=Color3.fromRGB(211,168,90),
 white=Color3.fromRGB(242,241,237),
 glass=Color3.fromRGB(115,143,155),
}

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
 p.Parent=parent or pass
 return p
end

local function textOn(partObj,text,color)
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

-- Wait until v11 has replaced the original elevator. This keeps execution deterministic.
local deadline=os.clock()+120
while mall:GetAttribute("MallCentralLift")~="V11" and os.clock()<deadline do task.wait(.25) end

-- -----------------------------------------------------------------------------
-- 1) REAR-WALL LIFT
-- -----------------------------------------------------------------------------
local oldLift=mall:FindFirstChild("ElevatorCore")
if oldLift then oldLift:Destroy() end

local elevator=Instance.new("Model")
elevator.Name="ElevatorCore"
elevator:SetAttribute("Pass","REAR_WALL_LIFT_V12")
elevator:SetAttribute("RearWallFlush",true)
elevator.Parent=mall

local levels={1,15,29,43}
local doorZ=434.6
local rearZ=442.0
local lobbyZ=428.5

part("LiftRearPanel",Vector3.new(16.5,57,.6),CFrame.new(0,29,rearZ),C.glass,Enum.Material.Glass,true,elevator,.38)
for _,x in ipairs({-8.2,8.2}) do
 part("LiftPier"..x,Vector3.new(1.2,57,8.5),CFrame.new(x,29,438.0),C.graphite,Enum.Material.Metal,true,elevator,0)
end

local function liftPrompt(parent,action,targetFloor,targetY)
 prompt(parent,action,"LIFT • L"..targetFloor,function(player)
  local char=player.Character
  if char then
   char:PivotTo(CFrame.new(0,targetY+3,424.5))
   toast(player,"Lift • Level "..targetFloor)
  end
 end)
end

for i,y in ipairs(levels) do
 part("LiftLobby"..i,Vector3.new(21,.42,11),CFrame.new(0,y+.72,lobbyZ),C.slate,Enum.Material.Slate,true,elevator,0)
 part("LiftDoorL"..i,Vector3.new(6.2,8.5,.35),CFrame.new(-3.15,y+5.1,doorZ),C.dark,Enum.Material.Metal,true,elevator,0)
 part("LiftDoorR"..i,Vector3.new(6.2,8.5,.35),CFrame.new(3.15,y+5.1,doorZ),C.dark,Enum.Material.Metal,true,elevator,0)
 local header=part("LiftHeader"..i,Vector3.new(15,2.25,.28),CFrame.new(0,y+10.15,doorZ-.1),C.graphite,Enum.Material.Metal,false,elevator,0)
 if i==4 then textOn(header,"L4 • CINEMA\nREAR LIFT",C.gold) else textOn(header,"REAR LIFT • L"..i,C.white) end
 if i<4 then
  local up=part("LiftUpPad"..i,Vector3.new(3.2,.2,3.2),CFrame.new(-4,y+1.02,423.2),C.gold,Enum.Material.Neon,false,elevator,.20)
  up.CanQuery=true
  liftPrompt(up,"UP",i+1,levels[i+1])
 end
 if i>1 then
  local down=part("LiftDownPad"..i,Vector3.new(3.2,.2,3.2),CFrame.new(4,y+1.02,423.2),C.white,Enum.Material.Neon,false,elevator,.34)
  down.CanQuery=true
  liftPrompt(down,"DOWN",i-1,levels[i-1])
 end
end

mall:SetAttribute("MallCentralLift","V12_REAR_WALL")
mall:SetAttribute("MallLiftRearWallFlush",true)

-- -----------------------------------------------------------------------------
-- 2) REAL L4 CINEMA
-- Keep v12 in its current location. v13 only opens circulation and removes the overhang.
-- -----------------------------------------------------------------------------
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
 cxModel.Parent=cinema

 local y=43
 -- v13: south edge is exactly Z=392, matching the real north atrium boundary.
 -- The v12 50-stud lobby reached to Z=385, placing walkable floor outside the safety glass.
 part("CinemaLobbyV12",Vector3.new(172,.42,43),CFrame.new(0,y+.72,413.5),C.carpet,Enum.Material.Carpet,true,cxModel,0)
 part("CenterAisle",Vector3.new(15,.08,38),CFrame.new(0,y+1.0,414),C.gold,Enum.Material.Neon,false,cxModel,.55)

 local hero=part("CinemaHeroV12",Vector3.new(42,4,.35),CFrame.new(0,y+11.6,392.2),C.dark,Enum.Material.Metal,false,cxModel,0)
 textOn(hero,"BBYA CINEMA • SCREEN A + B",C.white)

 local snack=part("CinemaConcessionV12",Vector3.new(12,2.8,4.5),CFrame.new(0,y+2.4,400),C.graphite,Enum.Material.Metal,true,cxModel,0)
 local snackTop=part("CinemaConcessionGlow",Vector3.new(12.5,.16,4.8),CFrame.new(0,y+3.9,400),C.red,Enum.Material.Neon,false,cxModel,.10)
 snackTop.CastShadow=false
 local snackSign=part("CinemaSnackSign",Vector3.new(11,2,.25),CFrame.new(0,y+6.1,397.65),C.dark,Enum.Material.Metal,false,cxModel,0)
 textOn(snackSign,"SNACKS • DRINKS",C.gold)
 prompt(snack,"ORDER","CINEMA BAR",function(player)toast(player,"Cinema bar • order received")end)

 local function buildScreenRoom(label,cx)
  local room=Instance.new("Model")
  room.Name="Screen"..label
  room.Parent=cxModel
  local width=68
  local depth=42
  local centerZ=413
  local frontZ=centerZ-depth/2
  local rearWallZ=centerZ+depth/2
  local half=width/2

  part("Floor",Vector3.new(width,.4,depth),CFrame.new(cx,y+.92,centerZ),Color3.fromRGB(43,36,40),Enum.Material.Carpet,true,room,0)
  part("LeftWall",Vector3.new(1,12,depth),CFrame.new(cx-half,y+6.8,centerZ),C.dark,Enum.Material.Slate,true,room,0)
  part("RightWall",Vector3.new(1,12,depth),CFrame.new(cx+half,y+6.8,centerZ),C.dark,Enum.Material.Slate,true,room,0)
  part("RearWall",Vector3.new(width,12,1),CFrame.new(cx,y+6.8,rearWallZ),C.dark,Enum.Material.Slate,true,room,0)
  part("Ceiling",Vector3.new(width,.45,depth),CFrame.new(cx,y+12.5,centerZ),Color3.fromRGB(33,34,38),Enum.Material.Metal,true,room,0)

  -- v13: remove the two broad black facade walls that cut across the L4 circulation path.
  -- Side walls plus the entry header still define each screening room without a floor-level blocker.
  local entryHead=part("EntryHeader",Vector3.new(15,2.4,.32),CFrame.new(cx,y+10.5,frontZ-.55),C.graphite,Enum.Material.Metal,false,room,0)
  textOn(entryHead,"SCREEN "..label,C.gold)

  local frame=part("ScreenFrame",Vector3.new(54,8.8,.55),CFrame.new(cx,y+7.2,rearWallZ-.65),Color3.fromRGB(9,10,12),Enum.Material.Metal,false,room,0)
  local screen=part("MovieScreen",Vector3.new(50,6.8,.18),CFrame.new(cx,y+7.2,rearWallZ-1.0),Color3.fromRGB(220,220,216),Enum.Material.SmoothPlastic,false,room,0)
  screen.CastShadow=false
  textOn(screen,"BBYA CINEMA\nSCREEN "..label,Color3.fromRGB(40,41,45))

  for row=1,4 do
   local rz=400+(row-1)*6.2
   local rise=(row-1)*.35
   part("Riser"..row,Vector3.new(60,.28,5.2),CFrame.new(cx,y+1.05+rise/2,rz),Color3.fromRGB(48,39,43),Enum.Material.Carpet,true,room,0)
   for _,xo in ipairs({-24,-18,-12,-6,6,12,18,24}) do
    cinemaSeat("Seat"..row.."_"..xo,CFrame.new(cx+xo,y+1.55+rise,rz)*CFrame.Angles(0,math.rad(180),0),room)
   end
  end

  for _,xoff in ipairs({-32,32}) do
   for _,zoff in ipairs({400,412,424}) do
    local glow=part("AisleGlow",Vector3.new(.14,.16,4.2),CFrame.new(cx+xoff,y+1.15,zoff),C.red,Enum.Material.Neon,false,room,.12)
    glow.CastShadow=false
   end
  end

  local showPad=part("ShowtimePad",Vector3.new(3,2.2,3),CFrame.new(cx,y+2.0,frontZ+4.0),C.red,Enum.Material.Neon,false,room,.30)
  showPad.CanQuery=true
  prompt(showPad,"SHOWTIMES","SCREEN "..label,function(player)
   toast(player,"Screen "..label.." • Neon City 19:00 • Midnight Run 21:10 • After Hours 23:30")
  end)
 end

 buildScreenRoom("A",-48)
 buildScreenRoom("B",48)
 cinema:SetAttribute("Experience","REAL_SCREENING_ROOMS_V12")
 cinema:SetAttribute("PortalOnlyTheatresRemoved",true)
 cinema:SetAttribute("L4Circulation","V13_OPEN_FACADE")
 mall:SetAttribute("MallCinemaExperience","V12_V13_SAFETY")
end

-- -----------------------------------------------------------------------------
-- 3) L4 ATRIUM SAFETY PERIMETER
-- Rebuild the actual atrium edge from the base mall dimensions instead of inheriting
-- mixed v11 fragments. Only the L3->L4 stair landing receives a controlled opening.
-- -----------------------------------------------------------------------------
local floor4=mall:FindFirstChild("Level4")
if floor4 then
 for _,d in ipairs(floor4:GetChildren()) do
  if d:IsA("BasePart") and (d.Name:match("^AtriumRailX4") or d.Name:match("^AtriumRailZ4")) then
   d:Destroy()
  end
 end

 local railY=45.4
 local centerZ=365
 local southZ=338
 local northZ=392
 local edgeX=30
 local atriumDepth=54
 local atriumWidth=60
 local gapCenter=-14.45
 local gapWidth=9.8
 local gapLeft=gapCenter-gapWidth/2
 local gapRight=gapCenter+gapWidth/2

 local function glassRail(name,size,cf)
  local r=part(name,size,cf,C.glass,Enum.Material.Glass,true,floor4,.48)
  r.CastShadow=false
  return r
 end

 -- Continuous west/east/north protection.
 glassRail("AtriumRailX4_V13_W",Vector3.new(.35,4.2,atriumDepth),CFrame.new(-edgeX,railY,centerZ))
 glassRail("AtriumRailX4_V13_E",Vector3.new(.35,4.2,atriumDepth),CFrame.new(edgeX,railY,centerZ))
 glassRail("AtriumRailZ4_V13_N",Vector3.new(atriumWidth,4.2,.35),CFrame.new(0,railY,northZ))

 -- South rail split only around the real upper landing.
 local leftEdge=-atriumWidth/2
 local rightEdge=atriumWidth/2
 local leftWidth=gapLeft-leftEdge
 local rightWidth=rightEdge-gapRight
 if leftWidth>0 then
  glassRail("AtriumRailZ4_V13_SL",Vector3.new(leftWidth,4.2,.35),CFrame.new(leftEdge+leftWidth/2,railY,southZ))
 end
 if rightWidth>0 then
  glassRail("AtriumRailZ4_V13_SR",Vector3.new(rightWidth,4.2,.35),CFrame.new(gapRight+rightWidth/2,railY,southZ))
 end

 floor4:SetAttribute("AtriumSafety","V13_REBUILT")
 floor4:SetAttribute("SouthStairGapWidth",gapWidth)
 floor4:SetAttribute("SouthStairGapCenterX",gapCenter)
 mall:SetAttribute("MallL4AtriumSafety","V13")
end

pass:SetAttribute("CinemaBuilt",cinema~=nil)
pass:SetAttribute("LiftRearWall",true)
pass:SetAttribute("L4Safety","V13")
mall:SetAttribute("MallScreenshotQC","V13")
print("[BBYA] Mall v13 online: cinema kept in place; L4 overhang removed; black facade blockers opened; atrium glass perimeter rebuilt")
