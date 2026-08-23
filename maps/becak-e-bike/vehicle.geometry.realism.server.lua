-- BECAK E-BIKE — Cargo E-Bike geometry realism v1.0
-- Mechanical silhouette pass. Adds forks, stays, segmented fenders and cable runs without changing physics.
local Workspace=game:GetService('Workspace')
local root=Workspace:WaitForChild('BecakEBike',30)
if not root then return end
local vehicles=root:WaitForChild('Vehicles',30)
if not vehicles then return end
local BLACK=Color3.fromRGB(18,20,22)
local METAL=Color3.fromRGB(105,110,114)
local DARK=Color3.fromRGB(48,50,52)
local RED=Color3.fromRGB(190,45,38)

local function setup(p,color,material)
 p.Anchored=false;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Color=color;p.Material=material or Enum.Material.Metal
 return p
end
local function part(parent,name,size,cf,color,material,shape)
 local p=setup(Instance.new('Part'),color,material);p.Name=name;p.Size=size;p.CFrame=cf;if shape then p.Shape=shape end;p.Parent=parent;return p
end
local function weld(chassis,p)
 local w=Instance.new('WeldConstraint');w.Part0=chassis;w.Part1=p;w.Parent=p
end
local function rod(parent,chassis,name,len,radius,cf,color)
 local p=part(parent,name,Vector3.new(len,radius*2,radius*2),cf,color or METAL,Enum.Material.Metal,Enum.PartType.Cylinder);weld(chassis,p);return p
end
local function link(parent,chassis,name,a,b,radius,color)
 local delta=b-a;local len=delta.Magnitude;if len<.05 then return end
 local mid=(a+b)/2
 local p=rod(parent,chassis,name,len,radius,CFrame.lookAt(mid,b)*CFrame.Angles(0,math.rad(90),0),color)
 return p
end
local function fenderSegments(parent,chassis,center,side)
 -- three thin tangent segments over the top half of each front wheel instead of a solid cylinder-disc fender
 local radius=2.45
 for i=-1,1 do
  local a=math.rad(90+i*28)
  local pos=center+Vector3.new(0,math.sin(a)*radius,math.cos(a)*radius)
  local seg=part(parent,'FrontFenderSegment',Vector3.new(.32,.18,1.65),CFrame.new(pos)*CFrame.Angles(a-math.rad(90),0,0),DARK,Enum.Material.Metal)
  weld(chassis,seg)
 end
end

local function add(model)
 if not model:IsA('Model') or model:GetAttribute('VehicleGeometryRealismStyled') then return end
 local chassis=model.PrimaryPart or model:FindFirstChild('Chassis')
 local visual=model:FindFirstChild('MasterplanVisual')
 if not chassis or not visual then return end
 model:SetAttribute('VehicleGeometryRealismStyled',true)
 model:SetAttribute('VehicleGeometryRealismVersion','v1.0')
 local old=model:FindFirstChild('VehicleGeometryRealism') if old then old:Destroy() end
 local folder=Instance.new('Model');folder.Name='VehicleGeometryRealism';folder.Parent=model

 -- front fork legs and axle bridge make the two-wheel front end mechanically readable
 for _,x in ipairs({-3.55,3.55}) do
  local top=(chassis.CFrame*CFrame.new(x*.72,3.15,-.65)).Position
  local hub=(chassis.CFrame*CFrame.new(x,1.25,-3.15)).Position
  link(folder,chassis,'FrontForkLeg',top,hub,.10,BLACK)
  link(folder,chassis,'FrontForkBrace',top+Vector3.new(0,.28,0),hub+Vector3.new(0,.28,0),.07,METAL)
  fenderSegments(folder,chassis,hub,x)
 end
 local axle=part(folder,'FrontAxleBridge',Vector3.new(7.35,.18,.18),chassis.CFrame*CFrame.new(0,1.25,-3.15),METAL,Enum.Material.Metal);weld(chassis,axle)

 -- rear triangle / chain stays
 local rearHub=(chassis.CFrame*CFrame.new(0,1.55,4.25)).Position
 for _,x in ipairs({-1.35,1.35}) do
  local upper=(chassis.CFrame*CFrame.new(x,2.85,2.45)).Position
  local lower=(chassis.CFrame*CFrame.new(x,1.0,2.0)).Position
  link(folder,chassis,'RearSeatStay',upper,rearHub,.09,BLACK)
  link(folder,chassis,'RearChainStay',lower,rearHub,.09,BLACK)
 end

 -- chain guard and motor housing cues
 local guard=part(folder,'ChainGuard',Vector3.new(.28,.86,3.8),chassis.CFrame*CFrame.new(-1.05,1.35,2.95)*CFrame.Angles(math.rad(-6),0,0),BLACK,Enum.Material.Metal);weld(chassis,guard)
 local motor=part(folder,'RearHubMotor',Vector3.new(1.36,1.42,1.42),chassis.CFrame*CFrame.new(0,1.55,4.25)*CFrame.Angles(0,0,math.rad(90)),DARK,Enum.Material.Metal,Enum.PartType.Cylinder);weld(chassis,motor)

 -- steering/brake cable beams; cheap and visually useful
 local barL=Instance.new('Attachment');barL.Name='CableBarL';barL.Position=Vector3.new(-1.6,4.45,-.25);barL.Parent=chassis
 local barR=Instance.new('Attachment');barR.Name='CableBarR';barR.Position=Vector3.new(1.6,4.45,-.25);barR.Parent=chassis
 local frameL=Instance.new('Attachment');frameL.Name='CableFrameL';frameL.Position=Vector3.new(-.85,2.3,1.0);frameL.Parent=chassis
 local frameR=Instance.new('Attachment');frameR.Name='CableFrameR';frameR.Position=Vector3.new(.85,2.3,1.0);frameR.Parent=chassis
 for _,pair in ipairs({{barL,frameL},{barR,frameR}}) do
  local beam=Instance.new('Beam');beam.Name='ControlCable';beam.Attachment0=pair[1];beam.Attachment1=pair[2];beam.Width0=.035;beam.Width1=.035;beam.Color=ColorSequence.new(Color3.fromRGB(25,25,25));beam.CurveSize0=-.45;beam.CurveSize1=.25;beam.FaceCamera=true;beam.Parent=folder
 end

 -- rear lamp housing / reflector mount instead of a floating neon slab
 local housing=part(folder,'RearLampHousing',Vector3.new(1.65,.62,.38),chassis.CFrame*CFrame.new(0,2.18,5.02),BLACK,Enum.Material.Metal);weld(chassis,housing)
 local lens=part(folder,'RearLampLens',Vector3.new(1.28,.34,.12),housing.CFrame*CFrame.new(0,0,.23),RED,Enum.Material.Neon);weld(chassis,lens)

 -- cargo side tubes add thin engineering structure around the box silhouette
 for _,x in ipairs({-3.18,3.18}) do
  for _,y in ipairs({1.55,3.75}) do
   local rail=rod(folder,chassis,'CargoSideTube',4.72,.07,chassis.CFrame*CFrame.new(x,y,-3.08)*CFrame.Angles(0,math.rad(90),0),BLACK);rail.CastShadow=true
  end
 end

 Workspace:SetAttribute('BecakVehicleGeometryParts',(Workspace:GetAttribute('BecakVehicleGeometryParts') or 0)+#folder:GetDescendants())
end
for _,m in ipairs(vehicles:GetChildren()) do task.defer(add,m) end
vehicles.ChildAdded:Connect(function(m) task.wait(.45);add(m) end)
Workspace:SetAttribute('ACC_BecakVehicleGeometryRealism','v1.0')
Workspace:SetAttribute('BecakMechanicalForkGeometry','ON')
Workspace:SetAttribute('BecakSegmentedFenders','ON')
Workspace:SetAttribute('BecakControlCableGeometry','ON')
Workspace:SetAttribute('BecakRearTriangleGeometry','ON')
