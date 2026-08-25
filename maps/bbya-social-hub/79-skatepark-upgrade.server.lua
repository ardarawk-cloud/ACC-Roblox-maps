-- BBYA SOCIAL HUB — SKATEPARK UPGRADE v5 DIRECT DRIVE
-- Rounded proper-board visual + direct mobile/keyboard movement authority.
-- Skatepark geometry/lighting hooks preserved. Venue audio is intentionally untouched.
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local park=root:WaitForChild("RearSkatepark",30)
if not park then return end
task.wait(.35)

local old=park:FindFirstChild("SkateparkUpgradeV2")
if old then old:Destroy() end
local out=Instance.new("Model")
out.Name="SkateparkUpgradeV2" -- compatibility for existing lighting/exposure scripts
out.Parent=park
out:SetAttribute("Version","V5_DIRECT_DRIVE")
out:SetAttribute("FenceRoadLights",true)
out:SetAttribute("PremiumUrbanDressing",true)
out:SetAttribute("RideableSkateboards",true)
out:SetAttribute("ProperRoundedDeck",true)
out:SetAttribute("DirectDrive",true)
out:SetAttribute("AudioAuthorityUntouched",true)

local C={
 dark=Color3.fromRGB(22,23,26),metal=Color3.fromRGB(70,74,80),
 white=Color3.fromRGB(240,239,232),warm=Color3.fromRGB(248,226,184),
 cyan=Color3.fromRGB(34,157,190),yellow=Color3.fromRGB(224,181,48),
 black=Color3.fromRGB(15,16,18),
}
local function staticPart(name,size,cf,color,mat,collide,parent)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.dark;p.Material=mat or Enum.Material.Metal
 p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or out
 return p
end

-- Existing lighting scripts 86/88 depend on FenceRoadLights/RoadWash/FloodFill names.
local lights=Instance.new("Model");lights.Name="FenceRoadLights";lights.Parent=out
local function roadLamp(name,pos,faceDir)
 staticPart(name.."Mast",Vector3.new(.28,5.7,.28),CFrame.new(pos.X,12.7,pos.Z),C.metal,Enum.Material.Metal,false,lights)
 local armCenter=Vector3.new(pos.X,15.35,pos.Z)+faceDir*2.1
 staticPart(name.."Arm",Vector3.new(.24,.24,4.4),CFrame.lookAt(armCenter,armCenter+faceDir)*CFrame.Angles(0,math.rad(90),0),C.metal,Enum.Material.Metal,false,lights)
 local headPos=Vector3.new(pos.X,15.15,pos.Z)+faceDir*4.15
 local head=staticPart(name.."Head",Vector3.new(2.5,.32,1.15),CFrame.lookAt(headPos,headPos+faceDir),Color3.fromRGB(43,45,49),Enum.Material.Metal,false,lights)
 local lens=staticPart(name.."Lens",Vector3.new(2.1,.08,.86),head.CFrame*CFrame.new(0,-.2,0),C.warm,Enum.Material.Glass,false,lights);lens.Transparency=.15
 local spot=Instance.new("SpotLight");spot.Name="RoadWash";spot.Face=Enum.NormalId.Bottom;spot.Color=C.white;spot.Brightness=3;spot.Range=48;spot.Angle=84;spot.Shadows=false;spot.Parent=head
 local fill=Instance.new("PointLight");fill.Name="FloodFill";fill.Color=C.warm;fill.Brightness=.55;fill.Range=25;fill.Shadows=false;fill.Parent=head
end
for _,x in ipairs({-48,-24,0,24,48}) do roadLamp("North"..x,Vector3.new(x,0,149.4),Vector3.new(0,0,-1)) end
for _,z in ipairs({92,124}) do
 roadLamp("West"..z,Vector3.new(-58.4,0,z),Vector3.new(1,0,0))
 roadLamp("East"..z,Vector3.new(58.4,0,z),Vector3.new(-1,0,0))
end

-- Premium urban dressing retained from proper Skatepark v3.
local dress=Instance.new("Model");dress.Name="UrbanDressingV5";dress.Parent=out
for _,spec in ipairs({
 {"WestGuide",Vector3.new(.18,.05,52),CFrame.new(-28,1.035,112),C.yellow},
 {"EastGuide",Vector3.new(.18,.05,52),CFrame.new(27,1.035,112),C.yellow},
 {"SouthGuide",Vector3.new(54,.05,.18),CFrame.new(0,1.035,101),C.yellow},
}) do
 local p=staticPart(spec[1],spec[2],spec[3],spec[4],Enum.Material.SmoothPlastic,false,dress);p.Transparency=.12
end
local function wallGraphic(name,cf,size,title,sub,accent)
 local backing=staticPart(name,size,cf,Color3.fromRGB(27,28,31),Enum.Material.SmoothPlastic,false,dress)
 local sg=Instance.new("SurfaceGui");sg.Name="StreetGraphic";sg.Face=Enum.NormalId.Front;sg.PixelsPerStud=58;sg.LightInfluence=.25;sg.Parent=backing
 local bar=Instance.new("Frame");bar.BorderSizePixel=0;bar.BackgroundColor3=accent;bar.Position=UDim2.fromScale(.04,.08);bar.Size=UDim2.fromScale(.018,.84);bar.Parent=sg
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=UDim2.fromScale(.09,.13);t.Size=UDim2.fromScale(.84,.5);t.Text=title;t.TextXAlignment=Enum.TextXAlignment.Left;t.TextColor3=C.white;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.Parent=sg
 local s=Instance.new("TextLabel");s.BackgroundTransparency=1;s.Position=UDim2.fromScale(.09,.66);s.Size=UDim2.fromScale(.8,.16);s.Text=sub;s.TextXAlignment=Enum.TextXAlignment.Left;s.TextColor3=Color3.fromRGB(174,178,184);s.Font=Enum.Font.GothamBold;s.TextScaled=true;s.Parent=sg
end
wallGraphic("NorthGraphicL",CFrame.new(-37,3.2,148.86),Vector3.new(27,3,.16),"RIDE AFTER DARK","BBYA STREET SESSION",C.yellow)
wallGraphic("NorthGraphicR",CFrame.new(37,3.2,148.86),Vector3.new(27,3,.16),"KEEP ROLLING","BALI • MUSIC • SKATE",C.cyan)
local rack=Instance.new("Model");rack.Name="BoardRentalRack";rack.Parent=dress
staticPart("RackBack",Vector3.new(16,5,.4),CFrame.new(49,3.5,78.1),Color3.fromRGB(35,37,41),Enum.Material.Metal,false,rack)
staticPart("RackHeader",Vector3.new(16,1,.48),CFrame.new(49,6.3,78.05),C.black,Enum.Material.Metal,false,rack)
local rackGui=Instance.new("SurfaceGui");rackGui.Face=Enum.NormalId.Front;rackGui.PixelsPerStud=55;rackGui.Parent=rack.RackHeader
local rackText=Instance.new("TextLabel");rackText.BackgroundTransparency=1;rackText.Size=UDim2.fromScale(1,1);rackText.Text="BBYA BOARD RACK";rackText.TextColor3=C.white;rackText.Font=Enum.Font.GothamBlack;rackText.TextScaled=true;rackText.Parent=rackGui
for _,x in ipairs({24,36,48}) do staticPart("Bollard"..x,Vector3.new(.45,2.3,.45),CFrame.new(x,2.1,80.3),C.metal,Enum.Material.Metal,true,dress) end

-- DIRECT-RIDE AUTHORITY --------------------------------------------------------
local controlRemote=ReplicatedStorage:FindFirstChild("BBYASkateControlV5")
if controlRemote and not controlRemote:IsA("RemoteEvent") then controlRemote:Destroy();controlRemote=nil end
if not controlRemote then controlRemote=Instance.new("RemoteEvent");controlRemote.Name="BBYASkateControlV5";controlRemote.Parent=ReplicatedStorage end

local boardsFolder=Instance.new("Model");boardsFolder.Name="RideableSkateboards";boardsFolder.Parent=out
local activeBoards={}
local stateByModel={}
local playerInputs={}
local BOARD_SPEED=38
local ACCEL=48
local COAST=22
local TURN_RATE=math.rad(180)
local PARK_MIN_X,PARK_MAX_X=-65,65
local PARK_MIN_Z,PARK_MAX_Z=68,156

local function moveToward(v,target,delta)
 if v<target then return math.min(v+delta,target) end
 if v>target then return math.max(v-delta,target) end
 return target
end
local function angleDelta(from,to) return math.atan2(math.sin(to-from),math.cos(to-from)) end
local function weld(a,b)
 local w=Instance.new("WeldConstraint");w.Part0=a;w.Part1=b;w.Parent=a
end
local function loosePart(model,name,size,cf,color,material,shape)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
 p.Shape=shape or Enum.PartType.Block;p.Anchored=false;p.CanCollide=false;p.CanTouch=false;p.Massless=true
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=model
 return p
end
local function ellipsoid(model,name,cf,scale,color,material,chassis)
 local p=loosePart(model,name,Vector3.new(1,1,1),cf,color,material)
 local mesh=Instance.new("SpecialMesh");mesh.MeshType=Enum.MeshType.Sphere;mesh.Scale=scale;mesh.Parent=p
 weld(chassis,p)
 return p
end
local function boardColor(i)
 local colors={Color3.fromRGB(35,116,178),Color3.fromRGB(194,62,49),Color3.fromRGB(218,166,42),Color3.fromRGB(82,87,96)}
 return colors[((i-1)%#colors)+1]
end

local function addProperBoardVisual(model,chassis,spawnCF,color)
 -- The only collidable part is invisible. Visible deck is a flattened rounded mesh, not a block.
 ellipsoid(model,"RoundedDeck",spawnCF*CFrame.new(0,.05,0),Vector3.new(2.28,.18,5.55),color,Enum.Material.WoodPlanks,chassis)
 ellipsoid(model,"GripTape",spawnCF*CFrame.new(0,.145,0),Vector3.new(2.08,.035,5.20),Color3.fromRGB(23,24,26),Enum.Material.SmoothPlastic,chassis)
 -- Small raised nose/tail pads give the deck a skateboard kick profile.
 local nose=loosePart(model,"NoseKick",Vector3.new(1.72,.10,.62),spawnCF*CFrame.new(0,.20,-2.55)*CFrame.Angles(math.rad(-13),0,0),color,Enum.Material.WoodPlanks);weld(chassis,nose)
 local tail=loosePart(model,"TailKick",Vector3.new(1.72,.10,.62),spawnCF*CFrame.new(0,.20,2.55)*CFrame.Angles(math.rad(13),0,0),color,Enum.Material.WoodPlanks);weld(chassis,tail)
 for _,z in ipairs({-1.68,1.68}) do
  local truck=loosePart(model,"Truck",Vector3.new(2.12,.16,.38),spawnCF*CFrame.new(0,-.23,z),Color3.fromRGB(126,129,134),Enum.Material.Metal);weld(chassis,truck)
  for _,x in ipairs({-1.10,1.10}) do
   local wheel=loosePart(model,"Wheel",Vector3.new(.46,.46,.34),spawnCF*CFrame.new(x,-.39,z)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(229,226,207),Enum.Material.SmoothPlastic,Enum.PartType.Cylinder);weld(chassis,wheel)
  end
 end
end

local function resetState(state)
 state.speed=0
 state.driver.Velocity=Vector3.zero
 state.deck.AssemblyLinearVelocity=Vector3.zero
 state.deck.AssemblyAngularVelocity=Vector3.zero
 state.model:PivotTo(state.spawnCF)
 local _,ry,_=state.spawnCF:ToOrientation();state.yaw=ry;state.align.CFrame=CFrame.Angles(0,ry,0)
end

local function createBoard(index,spawnCF)
 local model=Instance.new("Model");model.Name="BBYASkateboard"..index;model.Parent=boardsFolder
 model:SetAttribute("BBYARideableSkateboard",true);model:SetAttribute("BoardIndex",index)
 model:SetAttribute("VisualProfile","ROUNDED_DECK_KICKTAIL_V5");model:SetAttribute("DriveProfile","DIRECT_BODY_VELOCITY_V5")

 local chassis=Instance.new("Part")
 chassis.Name="InvisibleChassis";chassis.Size=Vector3.new(2.0,.20,5.1);chassis.CFrame=spawnCF;chassis.Transparency=1
 chassis.Anchored=false;chassis.CanCollide=true;chassis.CanTouch=true;chassis.TopSurface=Enum.SurfaceType.Smooth;chassis.BottomSurface=Enum.SurfaceType.Smooth
 chassis.CustomPhysicalProperties=PhysicalProperties.new(.65,.25,.05,1,1);chassis.Parent=model;model.PrimaryPart=chassis
 addProperBoardVisual(model,chassis,spawnCF,boardColor(index))

 -- Normal Seat keeps PlayerModule thumbstick active. VehicleSeat is deliberately not used.
 local seat=Instance.new("Seat");seat.Name="BBYASkateSeat";seat:SetAttribute("BBYASkateSeatV5",true)
 seat.Size=Vector3.new(1.45,.26,1.45);seat.CFrame=spawnCF*CFrame.new(0,.66,0);seat.Transparency=1
 seat.Anchored=false;seat.CanCollide=false;seat.CanTouch=false;seat.Massless=true;seat.Parent=model;weld(chassis,seat)

 local driver=Instance.new("BodyVelocity");driver.Name="DirectHorizontalDriveV5";driver.MaxForce=Vector3.new(180000,0,180000);driver.P=14000;driver.Velocity=Vector3.zero;driver.Parent=chassis
 local att=Instance.new("Attachment");att.Name="StabilityAttachment";att.Parent=chassis
 local align=Instance.new("AlignOrientation");align.Name="SkateUpright";align.Mode=Enum.OrientationAlignmentMode.OneAttachment;align.Attachment0=att
 align.RigidityEnabled=false;align.Responsiveness=24;align.MaxTorque=140000;align.MaxAngularVelocity=28;align.Parent=chassis
 local _,yaw,_=spawnCF:ToOrientation();align.CFrame=CFrame.Angles(0,yaw,0)

 local prompt=Instance.new("ProximityPrompt");prompt.Name="RidePrompt";prompt.ActionText="Ride Skateboard";prompt.ObjectText="BBYA Skateboard"
 prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.HoldDuration=0;prompt.MaxActivationDistance=8;prompt.RequiresLineOfSight=false;prompt.Parent=chassis
 prompt.Triggered:Connect(function(player)
  if seat.Occupant then return end
  local char=player.Character;local hum=char and char:FindFirstChildOfClass("Humanoid")
  if hum and hum.Health>0 then seat:Sit(hum) end
 end)

 local state={model=model,deck=chassis,seat=seat,driver=driver,align=align,spawnCF=spawnCF,yaw=yaw,speed=0,lastOccupied=0}
 stateByModel[model]=state;table.insert(activeBoards,state)
 seat:GetPropertyChangedSignal("Occupant"):Connect(function()
  local hum=seat.Occupant
  if hum then
   state.lastOccupied=os.clock();prompt.Enabled=false
   local p=Players:GetPlayerFromCharacter(hum.Parent);if p then playerInputs[p]=nil end
   pcall(function() chassis:SetNetworkOwner(nil) end)
  else
   state.speed=0;state.driver.Velocity=Vector3.zero;prompt.Enabled=true
  end
 end)
end

local spawnCFrames={
 CFrame.new(45,1.55,82)*CFrame.Angles(0,math.rad(180),0),
 CFrame.new(49,1.55,82)*CFrame.Angles(0,math.rad(180),0),
 CFrame.new(53,1.55,82)*CFrame.Angles(0,math.rad(180),0),
 CFrame.new(57,1.55,82)*CFrame.Angles(0,math.rad(180),0),
}
for i,cf in ipairs(spawnCFrames) do createBoard(i,cf) end

controlRemote.OnServerEvent:Connect(function(player,model,moveX,moveZ,magnitude)
 local state=typeof(model)=="Instance" and stateByModel[model] or nil
 if not state then return end
 local hum=state.seat.Occupant
 if not hum or hum.Parent~=player.Character then return end
 local move=Vector3.new(math.clamp(tonumber(moveX) or 0,-1,1),0,math.clamp(tonumber(moveZ) or 0,-1,1))
 if move.Magnitude>1 then move=move.Unit end
 playerInputs[player]={t=os.clock(),move=move,magnitude=math.clamp(tonumber(magnitude) or move.Magnitude,0,1)}
end)
Players.PlayerRemoving:Connect(function(player) playerInputs[player]=nil end)

RunService.Heartbeat:Connect(function(dt)
 for _,b in ipairs(activeBoards) do
  if not b.deck.Parent then continue end
  local pos=b.deck.Position
  if pos.Y<-10 or pos.X<PARK_MIN_X or pos.X>PARK_MAX_X or pos.Z<PARK_MIN_Z or pos.Z>PARK_MAX_Z then
   if not b.seat.Occupant then resetState(b) end
   continue
  end

  local hum=b.seat.Occupant
  if hum then
   local player=Players:GetPlayerFromCharacter(hum.Parent)
   if player then b.lastOccupied=os.clock() end
   local input=player and playerInputs[player] or nil
   if input and os.clock()-input.t>.55 then input=nil end
   local move=input and input.move or Vector3.zero
   local magnitude=input and input.magnitude or 0

   if move.Magnitude>.05 and magnitude>.04 then
    local dir=move.Unit
    local desiredYaw=math.atan2(-dir.X,-dir.Z)
    b.yaw=b.yaw+math.clamp(angleDelta(b.yaw,desiredYaw),-TURN_RATE*dt,TURN_RATE*dt)
    b.speed=moveToward(b.speed,BOARD_SPEED*magnitude,ACCEL*dt)
   else
    b.speed=moveToward(b.speed,0,COAST*dt)
   end
   b.align.CFrame=CFrame.Angles(0,b.yaw,0)
   local forward=CFrame.Angles(0,b.yaw,0).LookVector
   b.driver.Velocity=Vector3.new(forward.X*b.speed,0,forward.Z*b.speed)
  else
   b.speed=moveToward(b.speed,0,COAST*dt)
   if b.speed<=.05 then b.speed=0;b.driver.Velocity=Vector3.zero end
   if b.deck.AssemblyLinearVelocity.Magnitude<1.25 and os.clock()-b.lastOccupied>20 and (b.deck.Position-b.spawnCF.Position).Magnitude>12 then resetState(b) end
  end
 end
end)

park:SetAttribute("Gameplay","RIDEABLE_SKATEBOARD_V5_DIRECT")
park:SetAttribute("BoardCount",#spawnCFrames)
park:SetAttribute("SkateboardShape","ROUNDED_DECK_KICKTAIL")
park:SetAttribute("SkateboardDrive","DIRECT_PLAYERMODULE_INPUT")
print("[BBYA] Skatepark v5 direct drive online: rounded deck + direct mobile controls; venue audio untouched")
