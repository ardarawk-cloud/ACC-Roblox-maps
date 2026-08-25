-- BBYA SOCIAL HUB — SKATEPARK UPGRADE v3 PROPER
-- Premium urban dressing + rideable skateboards. Preserves audio authority and legacy lighting hook names.
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local park=root:WaitForChild("RearSkatepark",30)
if not park then return end
task.wait(.35)

local old=park:FindFirstChild("SkateparkUpgradeV2")
if old then old:Destroy() end
local out=Instance.new("Model")
out.Name="SkateparkUpgradeV2" -- kept for lighting/exposure compatibility
out.Parent=park
out:SetAttribute("Version","V3_PROPER")
out:SetAttribute("FenceRoadLights",true)
out:SetAttribute("PremiumUrbanDressing",true)
out:SetAttribute("RideableSkateboards",true)
out:SetAttribute("AudioAuthorityUntouched",true)

local C={
 dark=Color3.fromRGB(22,23,26), metal=Color3.fromRGB(70,74,80),
 concrete=Color3.fromRGB(78,79,82), white=Color3.fromRGB(240,239,232),
 warm=Color3.fromRGB(248,226,184), cyan=Color3.fromRGB(34,157,190),
 yellow=Color3.fromRGB(224,181,48), red=Color3.fromRGB(185,58,48),
 wood=Color3.fromRGB(112,78,52), black=Color3.fromRGB(15,16,18),
}
local function part(name,size,cf,color,mat,collide,parent,class)
 local p=(class=="WedgePart") and Instance.new("WedgePart") or Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.dark;p.Material=mat or Enum.Material.Metal
 p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or out;return p
end

-- LIGHTING HOOKS ---------------------------------------------------------------
-- Existing 86/88 scripts retune RoadWash/FloodFill by these names.
local lights=Instance.new("Model");lights.Name="FenceRoadLights";lights.Parent=out
local function roadLamp(name,pos,faceDir)
 part(name.."Mast",Vector3.new(.28,5.7,.28),CFrame.new(pos.X,12.7,pos.Z),C.metal,Enum.Material.Metal,false,lights)
 local armCenter=Vector3.new(pos.X,15.35,pos.Z)+faceDir*2.1
 part(name.."Arm",Vector3.new(.24,.24,4.4),CFrame.lookAt(armCenter,armCenter+faceDir)*CFrame.Angles(0,math.rad(90),0),C.metal,Enum.Material.Metal,false,lights)
 local headPos=Vector3.new(pos.X,15.15,pos.Z)+faceDir*4.15
 local head=part(name.."Head",Vector3.new(2.5,.32,1.15),CFrame.lookAt(headPos,headPos+faceDir),Color3.fromRGB(43,45,49),Enum.Material.Metal,false,lights)
 local lens=part(name.."Lens",Vector3.new(2.1,.08,.86),head.CFrame*CFrame.new(0,-.2,0),C.warm,Enum.Material.Glass,false,lights);lens.Transparency=.15
 local spot=Instance.new("SpotLight");spot.Name="RoadWash";spot.Face=Enum.NormalId.Bottom;spot.Color=C.white;spot.Brightness=3;spot.Range=48;spot.Angle=84;spot.Shadows=false;spot.Parent=head
 local fill=Instance.new("PointLight");fill.Name="FloodFill";fill.Color=C.warm;fill.Brightness=.55;fill.Range=25;fill.Shadows=false;fill.Parent=head
end
for _,x in ipairs({-48,-24,0,24,48}) do roadLamp("North"..x,Vector3.new(x,0,149.4),Vector3.new(0,0,-1)) end
for _,z in ipairs({92,124}) do
 roadLamp("West"..z,Vector3.new(-58.4,0,z),Vector3.new(1,0,0))
 roadLamp("East"..z,Vector3.new(58.4,0,z),Vector3.new(-1,0,0))
end

-- PREMIUM URBAN DRESSING -------------------------------------------------------
local dress=Instance.new("Model");dress.Name="UrbanDressingV3";dress.Parent=out

-- Subtle painted edge lines guide flow without covering the concrete.
for _,spec in ipairs({
 {"WestGuide",Vector3.new(.18,.05,52),CFrame.new(-28,1.035,112),C.yellow},
 {"EastGuide",Vector3.new(.18,.05,52),CFrame.new(27,1.035,112),C.yellow},
 {"SouthGuide",Vector3.new(54,.05,.18),CFrame.new(0,1.035,101),C.yellow},
}) do
 local p=part(spec[1],spec[2],spec[3],spec[4],Enum.Material.SmoothPlastic,false,dress);p.Transparency=.12
end

local function wallGraphic(name,cf,size,title,sub,accent)
 local backing=part(name,size,cf,Color3.fromRGB(27,28,31),Enum.Material.SmoothPlastic,false,dress)
 local sg=Instance.new("SurfaceGui");sg.Name="StreetGraphic";sg.Face=Enum.NormalId.Front;sg.PixelsPerStud=58;sg.LightInfluence=.25;sg.Parent=backing
 local bar=Instance.new("Frame");bar.BorderSizePixel=0;bar.BackgroundColor3=accent;bar.Position=UDim2.fromScale(.04,.08);bar.Size=UDim2.fromScale(.018,.84);bar.Parent=sg
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=UDim2.fromScale(.09,.13);t.Size=UDim2.fromScale(.84,.5);t.Text=title;t.TextXAlignment=Enum.TextXAlignment.Left;t.TextColor3=C.white;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.Parent=sg
 local s=Instance.new("TextLabel");s.BackgroundTransparency=1;s.Position=UDim2.fromScale(.09,.66);s.Size=UDim2.fromScale(.8,.16);s.Text=sub;s.TextXAlignment=Enum.TextXAlignment.Left;s.TextColor3=Color3.fromRGB(174,178,184);s.Font=Enum.Font.GothamBold;s.TextScaled=true;s.Parent=sg
end
wallGraphic("NorthGraphicL",CFrame.new(-37,3.2,148.86),Vector3.new(27,3,.16),"RIDE AFTER DARK","BBYA STREET SESSION",C.yellow)
wallGraphic("NorthGraphicR",CFrame.new(37,3.2,148.86),Vector3.new(27,3,.16),"KEEP ROLLING","BALI • MUSIC • SKATE",C.cyan)

-- Board-rack zone, positioned away from teleport and ride lines.
local rack=Instance.new("Model");rack.Name="BoardRentalRack";rack.Parent=dress
part("RackBack",Vector3.new(16,5,.4),CFrame.new(49,3.5,78.1),Color3.fromRGB(35,37,41),Enum.Material.Metal,false,rack)
part("RackHeader",Vector3.new(16,1,.48),CFrame.new(49,6.3,78.05),C.black,Enum.Material.Metal,false,rack)
local sg=Instance.new("SurfaceGui");sg.Face=Enum.NormalId.Front;sg.PixelsPerStud=55;sg.Parent=rack.RackHeader
local tx=Instance.new("TextLabel");tx.BackgroundTransparency=1;tx.Size=UDim2.fromScale(1,1);tx.Text="BBYA BOARD RACK";tx.TextColor3=C.white;tx.Font=Enum.Font.GothamBlack;tx.TextScaled=true;tx.Parent=sg

-- Small spectator barrier behind benches; keeps players out of the south ride-in lane.
for _,x in ipairs({24,36,48}) do
 part("Bollard"..x,Vector3.new(.45,2.3,.45),CFrame.new(x,2.1,80.3),C.metal,Enum.Material.Metal,true,dress)
end

-- RIDEABLE SKATEBOARDS ---------------------------------------------------------
local boardsFolder=Instance.new("Model");boardsFolder.Name="RideableSkateboards";boardsFolder.Parent=out
local activeBoards={}
local BOARD_SPEED=34
local REVERSE_SPEED=14
local ACCEL=30
local COAST=16
local TURN_RATE=math.rad(105)
local PARK_MIN_X,PARK_MAX_X=-64,64
local PARK_MIN_Z,PARK_MAX_Z=69,155

local function moveToward(v,target,delta)
 if v<target then return math.min(v+delta,target) end
 if v>target then return math.max(v-delta,target) end
 return target
end

local function visualPart(model,name,size,cf,color,material,shape)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material
 p.Shape=shape or Enum.PartType.Block;p.Anchored=false;p.CanCollide=false;p.CanTouch=false;p.Massless=true
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=model
 return p
end
local function weld(a,b)
 local w=Instance.new("WeldConstraint");w.Part0=a;w.Part1=b;w.Parent=a
end
local function boardColor(i)
 local colors={Color3.fromRGB(36,112,170),Color3.fromRGB(188,59,48),Color3.fromRGB(214,166,42),Color3.fromRGB(72,76,83)}
 return colors[((i-1)%#colors)+1]
end

local function createBoard(index,spawnCF)
 local model=Instance.new("Model");model.Name="BBYASkateboard"..index;model.Parent=boardsFolder
 model:SetAttribute("BBYARideableSkateboard",true);model:SetAttribute("BoardIndex",index);model:SetAttribute("MaxSpeed",BOARD_SPEED)

 local deck=Instance.new("Part");deck.Name="Deck";deck.Size=Vector3.new(2.35,.28,5.6);deck.CFrame=spawnCF;deck.Color=boardColor(index);deck.Material=Enum.Material.WoodPlanks
 deck.Anchored=false;deck.CanCollide=true;deck.CanTouch=true;deck.TopSurface=Enum.SurfaceType.Smooth;deck.BottomSurface=Enum.SurfaceType.Smooth
 deck.CustomPhysicalProperties=PhysicalProperties.new(.8,.45,.1,1,1);deck.Parent=model
 model.PrimaryPart=deck

 -- Black grip top and metal trucks are visual only.
 local grip=visualPart(model,"Grip",Vector3.new(2.18,.06,5.22),spawnCF*CFrame.new(0,.17,0),Color3.fromRGB(24,25,27),Enum.Material.SmoothPlastic);weld(deck,grip)
 for _,z in ipairs({-1.72,1.72}) do
  local truck=visualPart(model,"Truck",Vector3.new(2.25,.18,.42),spawnCF*CFrame.new(0,-.24,z),Color3.fromRGB(120,123,128),Enum.Material.Metal);weld(deck,truck)
  for _,x in ipairs({-1.12,1.12}) do
   local wh=visualPart(model,"Wheel",Vector3.new(.42,.42,.36),spawnCF*CFrame.new(x,-.39,z)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(224,222,205),Enum.Material.SmoothPlastic,Enum.PartType.Cylinder);weld(deck,wh)
  end
 end

 local seat=Instance.new("VehicleSeat");seat.Name="BBYASkateSeat";seat.Size=Vector3.new(1.65,.35,1.9);seat.CFrame=spawnCF*CFrame.new(0,.72,0);seat.Transparency=1
 seat.Anchored=false;seat.CanCollide=false;seat.CanTouch=false;seat.Massless=true;seat.MaxSpeed=0;seat.Torque=0;seat.TurnSpeed=0;seat.Parent=model;weld(deck,seat)

 local att=Instance.new("Attachment");att.Name="StabilityAttachment";att.Parent=deck
 local align=Instance.new("AlignOrientation");align.Name="SkateUpright";align.Mode=Enum.OrientationAlignmentMode.OneAttachment;align.Attachment0=att
 align.RigidityEnabled=false;align.Responsiveness=18;align.MaxTorque=90000;align.MaxAngularVelocity=20;align.Parent=deck
 local _,yaw,_=spawnCF:ToOrientation();align.CFrame=CFrame.Angles(0,yaw,0)

 local prompt=Instance.new("ProximityPrompt");prompt.Name="RidePrompt";prompt.ActionText="Ride Skateboard";prompt.ObjectText="BBYA Board"
 prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.HoldDuration=0;prompt.MaxActivationDistance=8;prompt.RequiresLineOfSight=false;prompt.Parent=deck
 prompt.Triggered:Connect(function(player)
  if seat.Occupant then return end
  local char=player.Character;local hum=char and char:FindFirstChildOfClass("Humanoid")
  if hum and hum.Health>0 then seat:Sit(hum) end
 end)

 local state={model=model,deck=deck,seat=seat,align=align,spawnCF=spawnCF,yaw=yaw,speed=0,lastOccupied=0}
 seat:GetPropertyChangedSignal("Occupant"):Connect(function()
  if seat.Occupant then
   state.lastOccupied=os.clock()
   pcall(function() deck:SetNetworkOwner(nil) end)
   prompt.Enabled=false
  else
   state.speed=0
   prompt.Enabled=true
  end
 end)
 table.insert(activeBoards,state)
 return model
end

local spawnCFrames={
 CFrame.new(45,1.55,82)*CFrame.Angles(0,math.rad(180),0),
 CFrame.new(49,1.55,82)*CFrame.Angles(0,math.rad(180),0),
 CFrame.new(53,1.55,82)*CFrame.Angles(0,math.rad(180),0),
 CFrame.new(57,1.55,82)*CFrame.Angles(0,math.rad(180),0),
}
for i,cf in ipairs(spawnCFrames) do createBoard(i,cf) end

local rayParams=RaycastParams.new();rayParams.FilterType=Enum.RaycastFilterType.Exclude;rayParams.IgnoreWater=true
RunService.Heartbeat:Connect(function(dt)
 for _,b in ipairs(activeBoards) do
  if not b.deck.Parent then continue end
  local pos=b.deck.Position
  if pos.Y < -8 or pos.X<PARK_MIN_X or pos.X>PARK_MAX_X or pos.Z<PARK_MIN_Z or pos.Z>PARK_MAX_Z then
   if not b.seat.Occupant then
    b.model:PivotTo(b.spawnCF);b.deck.AssemblyLinearVelocity=Vector3.zero;b.deck.AssemblyAngularVelocity=Vector3.zero;b.speed=0
    local _,ry,_=b.spawnCF:ToOrientation();b.yaw=ry;b.align.CFrame=CFrame.Angles(0,b.yaw,0)
   end
   continue
  end

  local hum=b.seat.Occupant
  if hum then
   local player=Players:GetPlayerFromCharacter(hum.Parent)
   if player then b.lastOccupied=os.clock() end
   local throttle=math.clamp(b.seat.ThrottleFloat,-1,1)
   local steer=math.clamp(b.seat.SteerFloat,-1,1)
   if math.abs(throttle)>.05 then
    local target=(throttle>0) and BOARD_SPEED or -REVERSE_SPEED
    b.speed=moveToward(b.speed,target,ACCEL*dt)
   else
    b.speed=moveToward(b.speed,0,COAST*dt)
   end
   local turnScale=.28+math.min(math.abs(b.speed)/18,1)
   b.yaw=b.yaw-steer*TURN_RATE*turnScale*dt
   b.align.CFrame=CFrame.Angles(0,b.yaw,0)

   rayParams.FilterDescendantsInstances={b.model,hum.Parent}
   local grounded=Workspace:Raycast(pos,Vector3.new(0,-2.0,0),rayParams)~=nil
   local forward=CFrame.Angles(0,b.yaw,0).LookVector
   local vel=b.deck.AssemblyLinearVelocity
   if grounded then
    b.deck.AssemblyLinearVelocity=Vector3.new(forward.X*b.speed,vel.Y,forward.Z*b.speed)
   else
    -- Airborne: keep momentum; orientation stays upright for predictable landings.
    local h=Vector3.new(vel.X,0,vel.Z)
    if h.Magnitude<math.abs(b.speed)*.7 then
     b.deck.AssemblyLinearVelocity=Vector3.new(forward.X*b.speed*.82,vel.Y,forward.Z*b.speed*.82)
    end
   end
  elseif b.deck.AssemblyLinearVelocity.Magnitude<1.5 and os.clock()-b.lastOccupied>22 then
   local dist=(b.deck.Position-b.spawnCF.Position).Magnitude
   if dist>12 then
    b.model:PivotTo(b.spawnCF);b.deck.AssemblyLinearVelocity=Vector3.zero;b.deck.AssemblyAngularVelocity=Vector3.zero;b.speed=0
    local _,ry,_=b.spawnCF:ToOrientation();b.yaw=ry;b.align.CFrame=CFrame.Angles(0,b.yaw,0)
   end
  end
 end
end)

park:SetAttribute("Gameplay","RIDEABLE_SKATEBOARD_V1")
park:SetAttribute("BoardCount",#spawnCFrames)
print("[BBYA] Skatepark v3 proper online: premium street layout + 4 rideable skateboards; audio untouched")
