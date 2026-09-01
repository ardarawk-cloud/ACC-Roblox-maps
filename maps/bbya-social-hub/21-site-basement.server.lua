-- BBYA SOCIAL HUB — SITE + TALL AVATAR VERTICAL STACK v1
-- Non-destructive vertical headroom pass for the existing stacked venue building.
-- X/Z layout, venue content, audio authority, local lighting architecture and visual identity stay intact.
-- Strategy: deepen Underground while keeping Main/entrance anchored, then lift VIP and Rooftop cumulatively.

local Workspace=game:GetService("Workspace")
local Terrain=Workspace.Terrain
local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
if not root then root=Instance.new("Folder");root.Name="BBYA_ZERO_BUILD";root.Parent=Workspace end

local old=root:FindFirstChild("SiteBasement")
if old then old:Destroy() end
local m=Instance.new("Model");m.Name="SiteBasement";m.Parent=root

local TARGET_CLEAR_HEADROOM=28
local UNDERGROUND_DELTA=-14
local VIP_FLOOR_DELTA=5
local VIP_MID_DELTA=9.75
local ROOFTOP_DELTA=14.5

local function p(n,s,pos,col,mat)
 local x=Instance.new("Part")
 x.Name=n;x.Anchored=true;x.CanCollide=true;x.Size=s;x.CFrame=CFrame.new(pos)
 x.Color=col;x.Material=mat or Enum.Material.Concrete;x.Parent=m
 return x
end

-- Main/site datum stays exactly where it was so entrance, street and horizontal world alignment do not move.
p("Site",Vector3.new(160,1,120),Vector3.new(0,-0.5,0),Color3.fromRGB(18,18,22),Enum.Material.Slate)
-- Underground floor is lowered 14 studs. The structural side walls are extended upward to the unchanged site slab.
p("BasementFloor",Vector3.new(120,1,90),Vector3.new(0,-29.5,0),Color3.fromRGB(24,24,28))
p("BasementNorth",Vector3.new(120,30,2),Vector3.new(0,-15,44),Color3.fromRGB(20,20,24))
p("BasementSouth",Vector3.new(120,30,2),Vector3.new(0,-15,-44),Color3.fromRGB(20,20,24))
p("BasementWest",Vector3.new(2,30,88),Vector3.new(-59,-15,0),Color3.fromRGB(20,20,24))
p("BasementEast",Vector3.new(2,30,88),Vector3.new(59,-15,0),Color3.fromRGB(20,20,24))

local function shiftPartY(part,delta)
 if not part or not part:IsA("BasePart") or part:GetAttribute("BBYAHeadroomShiftedV1") then return end
 part.CFrame=part.CFrame+Vector3.new(0,delta,0)
 part:SetAttribute("BBYAHeadroomShiftedV1",true)
end

local function shiftModelY(model,delta)
 if not model or not model:IsA("Model") or model:GetAttribute("BBYAHeadroomShiftedV1") then return end
 model:PivotTo(model:GetPivot()+Vector3.new(0,delta,0))
 model:SetAttribute("BBYAHeadroomShiftedV1",true)
 for _,d in ipairs(model:GetDescendants()) do
  if d:IsA("BasePart") then d:SetAttribute("BBYAHeadroomShiftedV1",true) end
 end
end

local function extendUp(part,extra)
 if not part or not part:IsA("BasePart") or part:GetAttribute("BBYAHeadroomExtendedV1") then return end
 part.Size=Vector3.new(part.Size.X,part.Size.Y+extra,part.Size.Z)
 part.CFrame=part.CFrame+Vector3.new(0,extra/2,0)
 part:SetAttribute("BBYAHeadroomExtendedV1",true)
end

-- MAIN: preserve floor, stage, bar, booth, furniture and X/Z layout. Only extend shell pieces that ended at Y=24
-- so the raised VIP floor does not leave an exterior/structural gap.
task.spawn(function()
 local floor1=root:WaitForChild("Floor1Core",30)
 local shell=root:WaitForChild("ShellAndDressing",30)
 if not floor1 or not shell then return end
 task.wait(1)

 local floorWalls={
  FrontLeftWall=true,FrontRightWall=true,LeftFrontOuter=true,LeftMidOuter=true,LeftRearOuter=true,
  RightFrontOuter=true,RightMidOuter=true,RightRearOuter=true,RearWall=true,
 }
 for _,d in ipairs(floor1:GetDescendants()) do
  if d:IsA("BasePart") and floorWalls[d.Name] then extendUp(d,VIP_FLOOR_DELTA) end
 end

 for _,d in ipairs(shell:GetChildren()) do
  if d:IsA("BasePart") then
   local top=d.Position.Y+d.Size.Y/2
   if (d.Name:match("^L1") or d.Name:match("^ClubColumn")) and top>=23.9 then
    extendUp(d,VIP_FLOOR_DELTA)
   elseif d.Name:match("^L2.*Fascia") then
    -- New VIP floor underside ~=29; new Rooftop underside ~=58.3.
    d.Size=Vector3.new(d.Size.X,30,d.Size.Z)
    d.CFrame=CFrame.new(d.Position.X,44,d.Position.Z)*d.CFrame.Rotation
    d:SetAttribute("BBYAHeadroomExtendedV1",true)
   elseif d.Name:match("^VIPSeat") then
    shiftPartY(d,VIP_FLOOR_DELTA)
   elseif d.Name:match("^RoofLounge") or d.Name:match("^RoofPathLight") then
    shiftPartY(d,ROOFTOP_DELTA)
   end
  end
 end

 root:SetAttribute("BBYAMainClearHeadroomTarget",TARGET_CLEAR_HEADROOM)
end)

-- UNDERGROUND: final premium builder remains the visual authority. Keep its ceiling and ceiling fixtures where they are,
-- move every floor/wall-level object down with the new slab, and stretch only the four concrete shell walls.
task.spawn(function()
 local deadline=os.clock()+50
 local underground
 repeat
  local u=root:FindFirstChild("Underground")
  if u and u:GetAttribute("Pass")=="BASEMENT_PREMIUM_V2"
   and u:FindFirstChild("CheckerFloor")
   and u:FindFirstChild("BasementFullUpgradeV1")
   and u:FindFirstChild("AcousticTreatmentV3") then
   underground=u;break
  end
  task.wait(.2)
 until os.clock()>=deadline
 if not underground then warn("[BBYA Headroom] Underground final authority not ready");return end
 task.wait(1.5)

 local shellNames={NorthWall=true,SouthWall=true,WestWall=true,EastWall=true}
 for _,name in ipairs({"NorthWall","SouthWall","WestWall","EastWall"}) do
  local wall=underground:FindFirstChild(name)
  if wall and wall:IsA("BasePart") then
   wall.Size=Vector3.new(wall.Size.X,30,wall.Size.Z)
   wall.CFrame=CFrame.new(wall.Position.X,-15,wall.Position.Z)*wall.CFrame.Rotation
   wall:SetAttribute("BBYAHeadroomShiftedV1",true)
   wall:SetAttribute("BBYAHeadroomExtendedV1",true)
  end
 end

 -- Keep the single lighting authority but lower its four invisible fills just enough for the taller room.
 -- Brightness/range/count are deliberately untouched.
 for _,d in ipairs(underground:GetDescendants()) do
  if d:IsA("BasePart") and d.Name:match("^RoomFillAnchor") then
   shiftPartY(d,-6)
  end
 end

 for _,d in ipairs(underground:GetDescendants()) do
  if d:IsA("BasePart") and not d:GetAttribute("BBYAHeadroomShiftedV1") then
   if d.Parent==underground and (d.Name=="Ceiling" or shellNames[d.Name]) then
    d:SetAttribute("BBYAHeadroomShiftedV1",true)
   elseif d.Position.Y<=-4.5 then
    shiftPartY(d,UNDERGROUND_DELTA)
   end
  end
 end

 underground:SetAttribute("BBYAHeadroomProfile","TALL_AVATAR_V1")
 underground:SetAttribute("BBYATargetClearHeadroom",TARGET_CLEAR_HEADROOM)
 underground:SetAttribute("BBYAFloorDeltaY",UNDERGROUND_DELTA)
 underground:SetAttribute("AudioSystemUntouched",true)
 underground:SetAttribute("LightingAuthorityPreserved","V6_SINGLE_LOCAL_AUTHORITY")
 root:SetAttribute("BBYAUndergroundClearHeadroomTarget",TARGET_CLEAR_HEADROOM)
 print("[BBYA Headroom] Underground extended to ~28 studs; existing content preserved")
end)

-- VIP: floor-bound groups rise 5 studs; ceiling-bound groups rise 14.5 studs with the Rooftop.
-- This opens the room without scaling furniture/speakers themselves. Mixed wall layers are centered in the taller span.
task.spawn(function()
 local upper=root:WaitForChild("UpperLevels",30)
 if not upper then return end
 local vip=upper:WaitForChild("L2_VIP_Level",30)
 if not vip then return end
 local active=vip:WaitForChild("VIPMinimalStanding",35)
 if not active then return end

 -- Let the current enclosure/private-club/seating layers finish before one deterministic geometry pass.
 local deadline=os.clock()+40
 repeat
  if active:FindFirstChild("VIPEnclosureV7") and active:FindFirstChild("VIPPrivateClubUpgradeV2") then break end
  task.wait(.2)
 until os.clock()>=deadline
 task.wait(1.2)

 -- Floor slabs are direct BasePart children of VIPMinimalStanding.
 for _,child in ipairs(active:GetChildren()) do
  if child:IsA("BasePart") then shiftPartY(child,VIP_FLOOR_DELTA) end
 end

 local floorModels={
  SafetyRails=true,FloorBoundaryNeon=true,PreciseInnerFloorNeon=true,
  VIPLoungeSeatingV1=true,VIPChampagneServiceV1=true,
 }
 local ceilingModels={
  TriangleCeilingLight=true,TriangleCeilingNetwork=true,SuspendedCornerSound=true,
 }

 for _,name in ipairs({"SafetyRails","FloorBoundaryNeon","PreciseInnerFloorNeon","VIPLoungeSeatingV1","VIPChampagneServiceV1"}) do
  shiftModelY(active:FindFirstChild(name),VIP_FLOOR_DELTA)
 end
 for _,name in ipairs({"TriangleCeilingLight","TriangleCeilingNetwork","SuspendedCornerSound"}) do
  shiftModelY(active:FindFirstChild(name),ROOFTOP_DELTA)
 end

 local enclosure=active:FindFirstChild("VIPEnclosureV7")
 if enclosure then
  local walls=enclosure:FindFirstChild("ClosedVIPWalls")
  if walls then
   for _,d in ipairs(walls:GetDescendants()) do
    if d:IsA("BasePart") then
     d.Size=Vector3.new(d.Size.X,d.Size.Y+9.5,d.Size.Z)
     d.CFrame=d.CFrame+Vector3.new(0,VIP_MID_DELTA,0)
     d:SetAttribute("BBYAHeadroomShiftedV1",true)
     d:SetAttribute("BBYAHeadroomExtendedV1",true)
    end
   end
   walls:SetAttribute("BBYAHeadroomShiftedV1",true)
  end
  shiftModelY(enclosure:FindFirstChild("WallAcousticPanels"),VIP_MID_DELTA)
  enclosure:SetAttribute("BBYAHeadroomShiftedV1",true)
 end

 local private=active:FindFirstChild("VIPPrivateClubUpgradeV2")
 if private then
  local floorPrivate={PremiumRailCaps=true,PrivateClubPortal=true}
  local midPrivate={ArchitecturalWallRibs=true,ArchitecturalLightWash=true}
  for _,child in ipairs(private:GetChildren()) do
   if child:IsA("Model") then
    if floorPrivate[child.Name] then shiftModelY(child,VIP_FLOOR_DELTA)
    elseif midPrivate[child.Name] then shiftModelY(child,VIP_MID_DELTA)
    elseif not child:GetAttribute("BBYAHeadroomShiftedV1") then
     local py=child:GetPivot().Position.Y
     shiftModelY(child,(py<33.5 and VIP_FLOOR_DELTA) or (py>=37 and ROOFTOP_DELTA) or VIP_MID_DELTA)
    end
   elseif child:IsA("BasePart") then
    local py=child.Position.Y
    shiftPartY(child,(py<33.5 and VIP_FLOOR_DELTA) or (py>=37 and ROOFTOP_DELTA) or VIP_MID_DELTA)
   end
  end
  private:SetAttribute("BBYAHeadroomShiftedV1",true)
 end

 -- Any remaining top-level VIP model is moved as a whole, preserving its internal proportions.
 for _,child in ipairs(active:GetChildren()) do
  if child:IsA("Model") and not child:GetAttribute("BBYAHeadroomShiftedV1")
   and not floorModels[child.Name] and not ceilingModels[child.Name] then
   local py=child:GetPivot().Position.Y
   shiftModelY(child,(py<33.5 and VIP_FLOOR_DELTA) or (py>=37 and ROOFTOP_DELTA) or VIP_MID_DELTA)
  end
 end

 -- Lift core keeps its bottom datum and reaches the new Rooftop height.
 local circulation=upper:FindFirstChild("VerticalCirculation")
 local lift=circulation and circulation:FindFirstChild("LiftCore")
 if lift and lift:IsA("BasePart") then
  lift.Size=Vector3.new(lift.Size.X,59,lift.Size.Z)
  lift.CFrame=CFrame.new(lift.Position.X,29.5,lift.Position.Z)*lift.CFrame.Rotation
  lift:SetAttribute("BBYAHeadroomExtendedV1",true)
 end

 active:SetAttribute("BBYAHeadroomProfile","TALL_AVATAR_V1")
 active:SetAttribute("BBYAFloorDeltaY",VIP_FLOOR_DELTA)
 active:SetAttribute("BBYACeilingDeltaY",ROOFTOP_DELTA)
 active:SetAttribute("BBYATargetClearHeadroom",TARGET_CLEAR_HEADROOM)
 root:SetAttribute("BBYAVIPClearHeadroomTarget",TARGET_CLEAR_HEADROOM)
 print("[BBYA Headroom] VIP opened to ~28 studs; furniture/audio objects kept at original scale")
end)

-- ROOFTOP: it is an open-air level, so move the completed resort as one unit. This preserves every visual relationship,
-- seat, bar, cabana, light and pool part. Terrain water is recreated at the same relative height after the move.
task.spawn(function()
 local upper=root:WaitForChild("UpperLevels",30)
 if not upper then return end
 local roof=upper:WaitForChild("R_Rooftop",30)
 if not roof then return end
 local deadline=os.clock()+45
 repeat
  if roof:GetAttribute("Pass")=="ROOFTOP_RESORT_PREMIUM_V3"
   and roof:FindFirstChild("RooftopArchitectureV3")
   and roof:FindFirstChild("RooftopInfinityPoolV3")
   and roof:FindFirstChild("RooftopBarV3")
   and roof:FindFirstChild("RooftopTropicalEdgeV32") then break end
  task.wait(.2)
 until os.clock()>=deadline
 if roof:GetAttribute("Pass")~="ROOFTOP_RESORT_PREMIUM_V3" then
  warn("[BBYA Headroom] Rooftop premium authority not ready")
  return
 end
 task.wait(.8)

 -- Clear only the old rooftop pool water volume, then carve/fill the identical pool at the lifted level.
 Terrain:FillBlock(CFrame.new(0,44.1,12),Vector3.new(58,8,32),Enum.Material.Air)
 shiftModelY(roof,ROOFTOP_DELTA)
 Terrain:FillBlock(CFrame.new(0,58.6,12),Vector3.new(58,8,32),Enum.Material.Air)
 Terrain:FillBlock(CFrame.new(0,57.92,12),Vector3.new(56,3.0,30),Enum.Material.Water)

 roof:SetAttribute("BBYAHeadroomProfile","TALL_AVATAR_V1")
 roof:SetAttribute("BBYAVerticalDeltaY",ROOFTOP_DELTA)
 roof:SetAttribute("BBYAOriginalDesignPreserved",true)
 root:SetAttribute("BBYARooftopVerticalDeltaY",ROOFTOP_DELTA)
 print("[BBYA Headroom] Rooftop lifted 14.5 studs as one preserved resort assembly")
end)

root:SetAttribute("BBYAHeadroomAuthority","TALL_AVATAR_VERTICAL_STACK_V1")
root:SetAttribute("BBYAHeadroomTargetStuds",TARGET_CLEAR_HEADROOM)
root:SetAttribute("BBYAHeadroomMainAnchorPreserved",true)
root:SetAttribute("BBYAHeadroomXZPreserved",true)
print("[BBYA] site + tall-avatar vertical stack v1 staged: Underground -14 / Main anchored / VIP +5 / Rooftop +14.5")