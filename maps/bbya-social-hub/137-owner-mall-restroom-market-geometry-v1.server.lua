-- BBYA SOCIAL HUB — OWNER MALL / RESTROOM / NIGHT MARKET GEOMETRY v1
-- Final screenshot-driven geometry authority requested by owner.
-- Scope is deliberately narrow:
--   1) Mall floor-to-floor spacing = exactly 15 studs.
--   2) Shared restroom gets real tall-avatar headroom and interior-facing mirror.
--   3) Pasar Malam canopies get comfortable camera/avatar clearance.
-- No Music/DJ, Support, Fishing, Party Stuff, Travel, Main Club audio/UI or economy changes.

local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",60)
if not root then return end

local MARK="BBYAOwnerGeometry15StudV1"

local function shiftPart(part,dy)
 if not part or not part:IsA("BasePart") or part:GetAttribute(MARK) then return end
 part.CFrame=part.CFrame+Vector3.new(0,dy,0)
 part:SetAttribute(MARK,true)
end

local function extendUp(part,extra)
 if not part or not part:IsA("BasePart") or part:GetAttribute(MARK) then return end
 part.Size=Vector3.new(part.Size.X,part.Size.Y+extra,part.Size.Z)
 part.CFrame=part.CFrame+Vector3.new(0,extra/2,0)
 part:SetAttribute(MARK,true)
end

local function shiftModel(model,dy)
 if not model or not model:IsA("Model") or model:GetAttribute(MARK) then return end
 model:PivotTo(model:GetPivot()+Vector3.new(0,dy,0))
 model:SetAttribute(MARK,true)
 for _,d in ipairs(model:GetDescendants()) do
  if d:IsA("BasePart") then d:SetAttribute(MARK,true) end
 end
end

local function waitAttribute(instance,name,value,timeout)
 local deadline=os.clock()+(timeout or 120)
 while instance and instance.Parent and instance:GetAttribute(name)~=value and os.clock()<deadline do
  task.wait(.2)
 end
 return instance and instance.Parent and instance:GetAttribute(name)==value
end

local function addSurfaceText(partObj,text,color)
 local old=partObj:FindFirstChildOfClass("SurfaceGui")
 if old then old:Destroy() end
 local gui=Instance.new("SurfaceGui")
 gui.Face=Enum.NormalId.Front
 gui.PixelsPerStud=55
 gui.LightInfluence=.05
 gui.Parent=partObj
 local label=Instance.new("TextLabel")
 label.Size=UDim2.fromScale(1,1)
 label.BackgroundTransparency=1
 label.Text=text
 label.TextColor3=color
 label.Font=Enum.Font.GothamBold
 label.TextScaled=true
 label.TextWrapped=true
 label.Parent=gui
end

local function buildMallFix()
 local mall=root:WaitForChild("BBYAMall",120)
 if not mall then return end

 -- Do not race the late Mall builders. v12 is the current final lift/cinema authority.
 waitAttribute(mall,"MallCentralLift","V12_REAR_WALL",150)
 local deadline=os.clock()+90
 while not root:FindFirstChild("ClubPurityMallStudiosV1") and os.clock()<deadline do task.wait(.2) end
 deadline=os.clock()+90
 while mall:GetAttribute("MallGoldRailClearance")~="V11" and os.clock()<deadline do task.wait(.2) end
 mall:WaitForChild("MallArchitectureV3",60)
 mall:WaitForChild("MallPremiumAtmosphereV9",60)
 task.wait(1)

 if mall:GetAttribute("OwnerMallFloorSpacingAuthority")=="15_STUD_V1" then return end

 -- Canonical floor datums. L1 stays fixed; each next slab is exactly +15 studs.
 local LEVELS={1,16,31,46}
 local floorDelta={0,1,2,3}

 for level=2,4 do
  shiftModel(mall:FindFirstChild("Level"..level),floorDelta[level])
 end

 -- Retail shells built directly under the Mall.
 local floor2Tenants={"Tenant_north","Tenant_street","Tenant_page","Tenant_glow","Tenant_sound","Tenant_fit"}
 for _,name in ipairs(floor2Tenants) do shiftModel(mall:FindFirstChild(name),1) end

 -- L3 / L4 destination models.
 for _,name in ipairs({"FoodHall","SkylineCafe","PixelArcade","LittleCity"}) do shiftModel(mall:FindFirstChild(name),2) end
 shiftModel(mall:FindFirstChild("BBYACinema"),3)
 shiftModel(mall:FindFirstChild("SkyLounge"),3)

 -- Directory boards that live on upper floors.
 for _,name in ipairs({"DirectoryBoard3","DirectoryFace3"}) do shiftPart(mall:FindFirstChild(name),1) end
 for _,name in ipairs({"DirectoryBoard4","DirectoryFace4"}) do shiftPart(mall:FindFirstChild(name),2) end

 -- Base shell grows upward while keeping its ground contact fixed.
 for _,name in ipairs({"WestExterior","EastExterior","RearExterior","FrontGlassLeft","FrontGlassRight"}) do
  extendUp(mall:FindFirstChild(name),3)
 end
 for _,d in ipairs(mall:GetChildren()) do
  if d:IsA("BasePart") and d.Name:match("^FrontFin") then extendUp(d,3) end
 end
 for _,name in ipairs({"RoofWest","RoofEast","RoofSouth","RoofNorth","AtriumSkylight","MallHeroSign","HeroUnderline","MallSubSign"}) do
  shiftPart(mall:FindFirstChild(name),3)
 end
 for _,d in ipairs(mall:GetChildren()) do
  if d:IsA("BasePart") and d.Name:match("^SkylightRib") then shiftPart(d,3) end
 end

 -- Mall Architecture v3 is a separate decoration authority, so move its floor-linked details too.
 local arch=mall:FindFirstChild("MallArchitectureV3")
 if arch then
  local storefronts=arch:FindFirstChild("StorefrontDepthV3",true)
  if storefronts then
   for _,tenant in ipairs(floor2Tenants) do
    shiftModel(storefronts:FindFirstChild(tenant.."_Portal"),1)
   end
  end
  for _,d in ipairs(arch:GetDescendants()) do
   if d:IsA("BasePart") then
    local n=d.Name
    if n:match("^Spandrel1") then shiftPart(d,1)
    elseif n:match("^Spandrel2") then shiftPart(d,2)
    elseif n:match("^Spandrel3") then shiftPart(d,3)
    elseif n:match("^AngledFacadeBlade") or n:match("^SidePilaster[^C]") or n:match("^RearPilaster") then extendUp(d,3)
    elseif n:match("^BladeCap") or n:match("^SidePilasterCap") or n=="RearCornice"
      or n=="FrontCornice" or n=="CorniceReveal" or n:match("^RoofBlade") or n=="RoofCrownCenter" then shiftPart(d,3)
    elseif n:match("^SideDatumUpper") then shiftPart(d,3)
    elseif n:match("^SideDatum") then shiftPart(d,1)
    end
   end
  end
 end

 -- Premium atmosphere: thresholds are not parented to tenants, and rail caps have absolute Y datums.
 local atmosphere=mall:FindFirstChild("MallPremiumAtmosphereV9")
 if atmosphere then
  local retail=atmosphere:FindFirstChild("RetailThresholdWarmthV9",true)
  if retail then
   for _,tenant in ipairs(floor2Tenants) do
    shiftPart(retail:FindFirstChild("Threshold_"..tenant),1)
   end
  end
  local rails=atmosphere:FindFirstChild("AtriumRailCapsV9",true)
  if rails then
   for _,d in ipairs(rails:GetDescendants()) do
    if d:IsA("BasePart") then
     if d.Name:find("L2",1,true) then shiftPart(d,1)
     elseif d.Name:find("L3",1,true) then shiftPart(d,2)
     elseif d.Name:find("L4",1,true) then shiftPart(d,3) end
    end
   end
  end
  local arrival=atmosphere:FindFirstChild("PremiumArrivalAtmosphereV9",true)
  if arrival then
   for _,d in ipairs(arrival:GetDescendants()) do
    if d:IsA("BasePart") and d.Name:match("^ArrivalCeiling_") then shiftPart(d,1) end
   end
  end
 end

 -- Gallery ceiling strips sit immediately below the next slab; follow the new 15-stud datums.
 local galleryAuthority=mall:FindFirstChild("MallPremiumGalleryV6")
 if galleryAuthority then
  for _,d in ipairs(galleryAuthority:GetDescendants()) do
   if d:IsA("BasePart") and d.Name:match("^CeilingPanel_") then
    local y=d.Position.Y
    if y<28 then shiftPart(d,1)
    elseif y<42 then shiftPart(d,2)
    else shiftPart(d,3) end
   end
  end
 end

 -- Any level identity panels created outside Level models must stay aligned to the slab they label.
 for _,d in ipairs(mall:GetChildren()) do
  if d:IsA("BasePart") and (d.Name:match("^LevelSignW") or d.Name:match("^LevelSignE")) then
   local level=tonumber(d.Name:match("(%d+)$"))
   if level and floorDelta[level] and floorDelta[level]>0 then shiftPart(d,floorDelta[level]) end
  end
 end

 -- Passport sensors use absolute Y positions in the live-upgrade authority.
 local live=mall:FindFirstChild("MallLiveUpgradeV2")
 if live then
  local passport=live:FindFirstChild("MallPassportZones",true)
  if passport then
   shiftPart(passport:FindFirstChild("Passport_LEVEL2"),1)
   shiftPart(passport:FindFirstChild("Passport_FOOD"),2)
   shiftPart(passport:FindFirstChild("Passport_CINEMA"),3)
  end
  local presence=live:FindFirstChild("MallPresenceVolume",true)
  if presence and presence:IsA("BasePart") and not presence:GetAttribute(MARK) then
   extendUp(presence,3)
  end
 end

 -- Rebuild the switchbacks instead of stretching old 14-stud stairs and leaving broken risers.
 local oldEscal=mall:FindFirstChild("Escalators")
 if oldEscal then oldEscal:Destroy() end
 local escal=Instance.new("Model")
 escal.Name="Escalators"
 escal:SetAttribute("Pass","OWNER_15_STUD_SWITCHBACK_V1")
 escal:SetAttribute("FloorRiseStuds",15)
 escal.Parent=mall

 local graphite=Color3.fromRGB(61,61,61)
 local warmStone=Color3.fromRGB(112,107,101)
 local gold=Color3.fromRGB(204,163,96)
 local function mpart(name,size,cf,color,material,collide,parent,tr)
  local p=Instance.new("Part")
  p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
  p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=false;p.Transparency=tr or 0
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent
  return p
 end
 local function beamBetween(name,a,b,parent,thickness)
  local mid=(a+b)/2
  local p=mpart(name,Vector3.new(thickness,thickness,(b-a).Magnitude),CFrame.lookAt(mid,b),gold,Enum.Material.Metal,false,parent,0)
  p.CastShadow=false
  return p
 end
 local function buildSwitchback(name,baseY,targetY,edgeZ,dir,xBase)
  local stair=Instance.new("Model");stair.Name=name;stair.Parent=escal
  local xA=xBase-3.55;local xB=xBase+3.55
  local depth=1.62;local run=1.34;local stepH=.50
  local rise=targetY-baseY;local stepRise=rise/14
  local firstStart=edgeZ+dir*1.18
  local midZ=edgeZ+dir*10.45
  for i=0,6 do
   local z=firstStart+dir*(i*run)
   local y=baseY+.75+i*stepRise
   mpart("FlightA_Step"..i,Vector3.new(5.9,stepH,depth),CFrame.new(xA,y,z),graphite,Enum.Material.Metal,true,stair,0)
  end
  local midY=baseY+rise/2
  mpart("MidLanding",Vector3.new(14.5,.48,3.6),CFrame.new(xBase,midY,midZ),warmStone,Enum.Material.Slate,true,stair,0)
  for i=0,6 do
   local z=midZ-dir*(1.18+i*run)
   local y=midY+.75+i*stepRise
   mpart("FlightB_Step"..i,Vector3.new(5.9,stepH,depth),CFrame.new(xB,y,z),graphite,Enum.Material.Metal,true,stair,0)
  end
  mpart("LowerLanding",Vector3.new(8.6,.42,3.1),CFrame.new(xA,baseY+.22,edgeZ+dir*.72),warmStone,Enum.Material.Slate,true,stair,0)
  mpart("UpperLanding",Vector3.new(8.6,.42,3.1),CFrame.new(xB,targetY+.22,edgeZ+dir*.72),warmStone,Enum.Material.Slate,true,stair,0)
  beamBetween("OuterRailA",Vector3.new(xA-3,baseY+2.1,firstStart),Vector3.new(xA-3,midY+1.0,midZ-dir*.3),stair,.14)
  beamBetween("OuterRailB",Vector3.new(xB+3,midY+1.6,midZ-dir*.3),Vector3.new(xB+3,targetY+1.0,edgeZ+dir),stair,.14)
  beamBetween("InnerRailA",Vector3.new(xA+3,baseY+2.1,firstStart),Vector3.new(xA+3,midY+1.0,midZ-dir*.3),stair,.11)
  beamBetween("InnerRailB",Vector3.new(xB-3,midY+1.6,midZ-dir*.3),Vector3.new(xB-3,targetY+1.0,edgeZ+dir),stair,.11)
 end
 buildSwitchback("L1_L2_SouthWest",LEVELS[1],LEVELS[2],338,1,-18)
 buildSwitchback("L2_L3_NorthEast",LEVELS[2],LEVELS[3],392,-1,18)
 buildSwitchback("L3_L4_SouthWest",LEVELS[3],LEVELS[4],338,1,-18)

 -- Rebuild the late v12 rear lift on the same X/Z footprint with the corrected floor datums.
 local oldLift=mall:FindFirstChild("ElevatorCore")
 if oldLift then oldLift:Destroy() end
 local elevator=Instance.new("Model")
 elevator.Name="ElevatorCore"
 elevator:SetAttribute("Pass","OWNER_REAR_LIFT_15_STUD_V1")
 elevator:SetAttribute("FloorRiseStuds",15)
 elevator.Parent=mall
 local doorZ=434.6;local rearZ=442.0;local lobbyZ=428.5
 local glassColor=Color3.fromRGB(115,143,155)
 local dark=Color3.fromRGB(25,27,31)
 local white=Color3.fromRGB(242,241,237)
 mpart("LiftRearPanel",Vector3.new(16.5,60,.6),CFrame.new(0,30.5,rearZ),glassColor,Enum.Material.Glass,true,elevator,.38)
 for _,x in ipairs({-8.2,8.2}) do mpart("LiftPier"..x,Vector3.new(1.2,60,8.5),CFrame.new(x,30.5,438),graphite,Enum.Material.Metal,true,elevator,0) end
 local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
 local state=remotes and remotes:FindFirstChild("State")
 local function toast(player,msg)
  if state and state:IsA("RemoteEvent") then state:FireClient(player,"toast",msg) end
 end
 local function liftPrompt(parent,action,targetFloor,targetY)
  local q=Instance.new("ProximityPrompt")
  q.ActionText=action;q.ObjectText="LIFT • L"..targetFloor;q.HoldDuration=.05;q.MaxActivationDistance=10;q.RequiresLineOfSight=false;q.Parent=parent
  q.Triggered:Connect(function(player)
   local char=player.Character
   if char then char:PivotTo(CFrame.new(0,targetY+3,424.5));toast(player,"Lift • Level "..targetFloor) end
  end)
 end
 for i,y in ipairs(LEVELS) do
  mpart("LiftLobby"..i,Vector3.new(21,.42,11),CFrame.new(0,y+.72,lobbyZ),warmStone,Enum.Material.Slate,true,elevator,0)
  mpart("LiftDoorL"..i,Vector3.new(6.2,8.5,.35),CFrame.new(-3.15,y+5.1,doorZ),dark,Enum.Material.Metal,true,elevator,0)
  mpart("LiftDoorR"..i,Vector3.new(6.2,8.5,.35),CFrame.new(3.15,y+5.1,doorZ),dark,Enum.Material.Metal,true,elevator,0)
  local header=mpart("LiftHeader"..i,Vector3.new(15,2.25,.28),CFrame.new(0,y+10.15,doorZ-.1),graphite,Enum.Material.Metal,false,elevator,0)
  addSurfaceText(header,i==4 and "L4 • CINEMA\nREAR LIFT" or "REAR LIFT • L"..i,i==4 and gold or white)
  if i<4 then
   local up=mpart("LiftUpPad"..i,Vector3.new(3.2,.2,3.2),CFrame.new(-4,y+1.02,423.2),gold,Enum.Material.Neon,false,elevator,.20);up.CanQuery=true
   liftPrompt(up,"UP",i+1,LEVELS[i+1])
  end
  if i>1 then
   local down=mpart("LiftDownPad"..i,Vector3.new(3.2,.2,3.2),CFrame.new(4,y+1.02,423.2),white,Enum.Material.Neon,false,elevator,.34);down.CanQuery=true
   liftPrompt(down,"DOWN",i-1,LEVELS[i-1])
  end
 end

 mall:SetAttribute("MallFloorLevels","1,16,31,46")
 mall:SetAttribute("MallFloorSpacingStuds",15)
 mall:SetAttribute("MallCentralLift","OWNER_15_STUD_V1")
 mall:SetAttribute("OwnerMallFloorSpacingAuthority","15_STUD_V1")
 mall:SetAttribute("OwnerMallGeometryScope","FLOOR_SPACING_ONLY")
end

local function buildRestroomFix()
 local restroom=root:WaitForChild("SharedRestroomV1",90)
 if not restroom or restroom:GetAttribute("OwnerTallRestroomAuthority")=="V1" then return end
 task.wait(.5)
 local architecture=restroom:FindFirstChild("Architecture")
 local fixtures=restroom:FindFirstChild("Fixtures")
 local detail=restroom:FindFirstChild("Detail")
 if not architecture or not fixtures or not detail then return end

 local function setYSize(name,height,centerY,parent)
  local p=(parent or architecture):FindFirstChild(name)
  if p and p:IsA("BasePart") then p.Size=Vector3.new(p.Size.X,height,p.Size.Z);p.CFrame=CFrame.new(p.Position.X,centerY,p.Position.Z)*p.CFrame.Rotation end
 end
 local function setY(name,y,parent)
  local p=(parent or detail):FindFirstChild(name)
  if p and p:IsA("BasePart") then p.CFrame=CFrame.new(p.Position.X,y,p.Position.Z)*p.CFrame.Rotation end
 end

 -- Floor stays fixed. Walls grow upward to ~15 studs clear interior height.
 for _,name in ipairs({"LeftWall","RightWall","BackWall","FrontWallL","FrontWallR"}) do setYSize(name,15.2,8.65,architecture) end
 local ceiling=architecture:FindFirstChild("Ceiling")
 if ceiling and ceiling:IsA("BasePart") then ceiling.CFrame=CFrame.new(ceiling.Position.X,16.45,ceiling.Position.Z)*ceiling.CFrame.Rotation end
 setYSize("DoorHeader",3.2,14.65,architecture)
 setYSize("EntryFrameL",11.8,6.95,detail);setYSize("EntryFrameR",11.8,6.95,detail)
 setY("RestroomSign",14.55,detail);setY("RestroomSubSign",13.48,detail);setY("RestroomSignAccent",13.05,detail)
 setYSize("PrivacyDivider",11.8,6.95,architecture);setY("PrivacyHeader",12.92,detail);setY("PrivacyAccent",12.78,detail)

 for _,d in ipairs(fixtures:GetChildren()) do
  if d:IsA("BasePart") and d.Name:match("^StallDivider_") then d.Size=Vector3.new(d.Size.X,11.5,d.Size.Z);d.CFrame=CFrame.new(d.Position.X,6.8,d.Position.Z)*d.CFrame.Rotation
  elseif d:IsA("BasePart") and d.Name:match("^StallDoor_") then d.Size=Vector3.new(d.Size.X,10.6,d.Size.Z);d.CFrame=CFrame.new(d.Position.X,6.35,d.Position.Z)*d.CFrame.Rotation end
 end

 -- Mirror was visually reading backwards. Put the glass on the room-facing (+Z) side of its backing/frame.
 local frame=detail:FindFirstChild("MirrorFrame")
 local mirror=fixtures:FindFirstChild("Mirror")
 if frame and frame:IsA("BasePart") then frame.CFrame=CFrame.new(38.2,7.65,-13.28);frame.Size=Vector3.new(5.7,5.35,.08) end
 if mirror and mirror:IsA("BasePart") then
  mirror.CFrame=CFrame.new(38.2,7.65,-13.06)*CFrame.Angles(0,math.rad(180),0)
  mirror.Size=Vector3.new(5.35,4.95,.10)
  mirror.Reflectance=.28
  mirror:SetAttribute("InteriorFacing","POSITIVE_Z")
 end
 setY("MirrorLightBar",10.42,detail)
 local lightBar=detail:FindFirstChild("MirrorLightBar");if lightBar and lightBar:IsA("BasePart") then lightBar.CFrame=CFrame.new(lightBar.Position.X,lightBar.Position.Y,-12.92)*lightBar.CFrame.Rotation end
 for _,name in ipairs({"MirrorAccentL","MirrorAccentR"}) do
  local p=detail:FindFirstChild(name)
  if p and p:IsA("BasePart") then p.Size=Vector3.new(p.Size.X,4.8,p.Size.Z);p.CFrame=CFrame.new(p.Position.X,7.65,-12.91)*p.CFrame.Rotation end
 end

 for i=1,6 do setY("RestroomCeilingLight_"..i,16.18,detail) end
 setY("CoveAccentL",14.35,detail);setY("CoveAccentR",14.35,detail)

 restroom:SetAttribute("ClearInteriorHeightStuds",15.1)
 restroom:SetAttribute("LayoutVersion","V4_OWNER_TALL")
 restroom:SetAttribute("MirrorInteriorFacing",true)
 restroom:SetAttribute("OwnerTallRestroomAuthority","V1")
end

local function buildNightMarketFix()
 local market=root:WaitForChild("BBYANightMarket",90)
 if not market then return end
 local premium=market:WaitForChild("PremiumNightMarketV3",90)
 market:WaitForChild("NightMarketBoundaryLayoutGuardV1",90)
 if not premium or market:GetAttribute("OwnerTallCanopyAuthority")=="V1" then return end
 task.wait(.6)

 local CANOPY_Y=14.5
 local LEGACY_POLE_HEIGHT=14.2
 local function raiseLegacy(model)
  if not model or not model:IsA("Model") then return end
  local canopy=model:FindFirstChild("Canopy")
  if canopy and canopy:IsA("BasePart") then canopy.CFrame=CFrame.new(canopy.Position.X,CANOPY_Y,canopy.Position.Z)*canopy.CFrame.Rotation end
  local banner=model:FindFirstChild("Banner")
  if banner and banner:IsA("BasePart") then banner.CFrame=CFrame.new(banner.Position.X,12.8,banner.Position.Z)*banner.CFrame.Rotation end
  for _,p in ipairs(model:GetChildren()) do
   if p:IsA("BasePart") and p.Name=="Pole" then
    local bottom=p.Position.Y-p.Size.Y/2
    p.Size=Vector3.new(p.Size.X,LEGACY_POLE_HEIGHT,p.Size.Z)
    p.CFrame=CFrame.new(p.Position.X,bottom+LEGACY_POLE_HEIGHT/2,p.Position.Z)*p.CFrame.Rotation
   end
  end
  model:SetAttribute("BBYATallTentClearance","OWNER_14_5_STUD_V1")
 end

 raiseLegacy(market:FindFirstChild("TicketInfo"))
 for i=1,12 do raiseLegacy(market:FindFirstChild("Stall"..i)) end

 -- Premium operator/service booths use eight fabric Stripe parts instead of a single Canopy part.
 for _,m in ipairs(premium:GetDescendants()) do
  if m:IsA("Model") then
   local stripeCount=0
   for _,p in ipairs(m:GetChildren()) do if p:IsA("BasePart") and p.Name:match("^Stripe%d+$") then stripeCount+=1 end end
   if stripeCount>=4 then
    for _,p in ipairs(m:GetChildren()) do
     if p:IsA("BasePart") and p.Name:match("^Stripe%d+$") then p.CFrame=CFrame.new(p.Position.X,CANOPY_Y,p.Position.Z)*p.CFrame.Rotation end
    end
    m:SetAttribute("OwnerCanopyClearanceStuds",CANOPY_Y)
   end
  end
 end

 market:SetAttribute("CanopyClearanceY",CANOPY_Y)
 market:SetAttribute("OwnerTallCanopyAuthority","V1")
 market:SetAttribute("OwnerCanopyCameraClearance",true)
end

-- Independent tasks keep one unavailable target from blocking the other fixes.
task.spawn(buildMallFix)
task.spawn(buildRestroomFix)
task.spawn(buildNightMarketFix)

print("[BBYA] Owner Geometry v1 armed: Mall 15-stud floors + tall restroom/mirror + raised Pasar Malam canopies; unrelated systems untouched")
