-- BECAK E-BIKE — lightweight traffic + pedestrian life v1.20
-- V3.2 keeps the proven ambient AI/yield/LOD logic and remeshes only the traffic-car visual authority.
-- Cars now use real-world-relative proportions, grounded vertical wheels, cabin glazing and road-car detailing.
local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local Workspace=game:GetService('Workspace')

local root=Workspace:WaitForChild('BecakEBike',20)
if not root then return end
local world=root:WaitForChild('Nusakarya',20)
if not world then return end
local playerVehicles=root:WaitForChild('Vehicles',20)
if not playerVehicles then return end

local trafficFolder=world:FindFirstChild('AmbientTraffic') or Instance.new('Folder')
trafficFolder.Name='AmbientTraffic';trafficFolder.Parent=world
local pedestrianFolder=world:FindFirstChild('AmbientPedestrians') or Instance.new('Folder')
pedestrianFolder.Name='AmbientPedestrians';pedestrianFolder.Parent=world

local function p(parent,name,size,color)
 local x=Instance.new('Part');x.Name=name;x.Size=size;x.Anchored=true;x.CanCollide=false;x.CanTouch=false;x.CanQuery=false
 x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Color=color;x.Material=Enum.Material.SmoothPlastic;x.Parent=parent
 return x
end

local function makeVehicle(name,color)
 local m=Instance.new('Model');m.Name=name;m.Parent=trafficFolder
 -- Primary body is deliberately wider than the V3.2 becak cabin and close to a normal sedan footprint.
 local body=p(m,'Body',Vector3.new(5.9,1.45,9.8),color);body.CFrame=CFrame.new(0,-100,0);m.PrimaryPart=body
 local hood=p(m,'Hood',Vector3.new(5.35,.58,2.35),color:Lerp(Color3.new(1,1,1),.05));hood.CFrame=body.CFrame*CFrame.new(0,.88,-3.55)
 local trunk=p(m,'Trunk',Vector3.new(5.3,.58,1.75),color:Lerp(Color3.new(0,0,0),.04));trunk.CFrame=body.CFrame*CFrame.new(0,.88,4.0)
 local cabin=p(m,'Cabin',Vector3.new(4.75,1.35,4.65),color:Lerp(Color3.new(1,1,1),.10));cabin.CFrame=body.CFrame*CFrame.new(0,1.35,.15)
 local roof=p(m,'Roof',Vector3.new(4.55,.24,4.25),color:Lerp(Color3.new(1,1,1),.06));roof.CFrame=body.CFrame*CFrame.new(0,2.10,.18)

 local windshield=p(m,'Glass',Vector3.new(4.35,.95,.12),Color3.fromRGB(58,76,84));windshield.Material=Enum.Material.Glass;windshield.Transparency=.2;windshield.CFrame=body.CFrame*CFrame.new(0,1.48,-2.18)*CFrame.Angles(math.rad(-11),0,0)
 local rearGlass=p(m,'Glass',Vector3.new(4.25,.88,.12),Color3.fromRGB(58,76,84));rearGlass.Material=Enum.Material.Glass;rearGlass.Transparency=.2;rearGlass.CFrame=body.CFrame*CFrame.new(0,1.48,2.35)*CFrame.Angles(math.rad(11),0,0)
 for _,x in ipairs({-2.40,2.40}) do
  local sideGlass=p(m,'Glass',Vector3.new(.10,.82,3.45),Color3.fromRGB(58,76,84));sideGlass.Material=Enum.Material.Glass;sideGlass.Transparency=.2;sideGlass.CFrame=body.CFrame*CFrame.new(x,1.48,.10)
 end

 -- Cylinder length stays on X (axle axis). Removing the old 90-degree Z rotation keeps tyres vertical.
 for _,o in ipairs({Vector3.new(-2.72,-.15,-3.18),Vector3.new(2.72,-.15,-3.18),Vector3.new(-2.72,-.15,3.15),Vector3.new(2.72,-.15,3.15)}) do
  local w=p(m,'Wheel',Vector3.new(.76,1.65,1.65),Color3.fromRGB(24,24,24));w.Shape=Enum.PartType.Cylinder;w.CFrame=body.CFrame*CFrame.new(o)
  local hub=p(m,'WheelHub',Vector3.new(.82,.62,.62),Color3.fromRGB(145,148,150));hub.Shape=Enum.PartType.Cylinder;hub.CFrame=w.CFrame
 end

 local frontBumper=p(m,'FrontBumper',Vector3.new(5.45,.28,.22),Color3.fromRGB(45,47,48));frontBumper.CFrame=body.CFrame*CFrame.new(0,-.05,-5.0)
 local rearBumper=p(m,'RearBumper',Vector3.new(5.45,.28,.22),Color3.fromRGB(45,47,48));rearBumper.CFrame=body.CFrame*CFrame.new(0,-.05,5.0)
 for _,x in ipairs({-1.72,1.72}) do
  local head=p(m,'HeadLight',Vector3.new(.82,.42,.16),Color3.fromRGB(244,238,205));head.Material=Enum.Material.Neon;head.CFrame=body.CFrame*CFrame.new(x,.38,-4.98)
  local brake=p(m,'BrakeLight',Vector3.new(.82,.44,.16),Color3.fromRGB(90,15,15));brake.Material=Enum.Material.Neon;brake.CFrame=body.CFrame*CFrame.new(x,.38,4.98)
 end
 m:SetAttribute('TrafficVehicleScale','REAL_WORLD_RELATIVE_V3_2')
 m:SetAttribute('TrafficVehicleRemesh','SEDAN_V3_2')
 return m
end

local function makePed(name,shirt)
 local m=Instance.new('Model');m.Name=name;m.Parent=pedestrianFolder
 local torso=p(m,'Torso',Vector3.new(1.6,2.1,.8),shirt);torso.CFrame=CFrame.new(0,-100,0);m.PrimaryPart=torso
 local head=p(m,'Head',Vector3.new(1.2,1.2,1.2),Color3.fromRGB(217,166,125));head.Shape=Enum.PartType.Ball;head.CFrame=torso.CFrame*CFrame.new(0,1.65,0)
 local legs=p(m,'Legs',Vector3.new(1.35,1.9,.7),Color3.fromRGB(48,51,55));legs.CFrame=torso.CFrame*CFrame.new(0,-1.9,0)
 return m
end

local routes={
 {Vector3.new(-520,1.45,-8),Vector3.new(520,1.45,-8),Vector3.new(520,1.45,8),Vector3.new(-520,1.45,8)},
 {Vector3.new(-8,1.45,-520),Vector3.new(-8,1.45,520),Vector3.new(8,1.45,520),Vector3.new(8,1.45,-520)},
 {Vector3.new(-520,1.45,292),Vector3.new(150,1.45,292),Vector3.new(150,1.45,308),Vector3.new(-520,1.45,308)},
 {Vector3.new(-150,1.45,-308),Vector3.new(520,1.45,-308),Vector3.new(520,1.45,-292),Vector3.new(-150,1.45,-292)},
}
local walkRoutes={
 {Vector3.new(-480,2.1,325),Vector3.new(-250,2.1,325)},
 {Vector3.new(120,2.1,45),Vector3.new(310,2.1,45)},
 {Vector3.new(-360,2.1,-115),Vector3.new(-250,2.1,-115)},
 {Vector3.new(330,2.1,-255),Vector3.new(430,2.1,-255)},
}
local intersections={
 Vector3.new(0,1.45,0),Vector3.new(150,1.45,300),Vector3.new(-150,1.45,-300)
}
local colors={Color3.fromRGB(196,66,62),Color3.fromRGB(65,112,172),Color3.fromRGB(224,185,67),Color3.fromRGB(62,139,91),Color3.fromRGB(185,185,190),Color3.fromRGB(78,78,82)}
local shirts={Color3.fromRGB(57,111,173),Color3.fromRGB(177,78,67),Color3.fromRGB(69,143,91),Color3.fromRGB(185,132,54),Color3.fromRGB(113,82,157)}

local actors={}
for i=1,6 do
 local route=routes[((i-1)%#routes)+1]
 local m=makeVehicle('Traffic_'..i,colors[((i-1)%#colors)+1])
 actors[#actors+1]={model=m,route=route,seg=((i-1)%#route)+1,t=(i*.13)%1,speed=18+(i%3)*3,yielding=false,logicalPos=nil}
end
local walkers={}
for i=1,8 do
 local route=walkRoutes[((i-1)%#walkRoutes)+1]
 local m=makePed('Pedestrian_'..i,shirts[((i-1)%#shirts)+1])
 walkers[#walkers+1]={model=m,a=route[1],b=route[2],t=(i*.17)%1,dir=(i%2==0) and 1 or -1,speed=4+(i%2)}
end

local function buildProximitySnapshot()
 local playerTargets={}
 for _,plr in ipairs(Players:GetPlayers()) do
  local ch=plr.Character
  local hrp=ch and ch:FindFirstChild('HumanoidRootPart')
  if hrp then playerTargets[#playerTargets+1]=hrp end
 end
 local vehicleTargets={}
 for _,model in ipairs(playerVehicles:GetChildren()) do
  local primary=model:IsA('Model') and model.PrimaryPart
  if primary then vehicleTargets[#vehicleTargets+1]=primary end
 end
 return playerTargets,vehicleTargets
end

local function nearestFromSnapshot(targets,pos)
 local best=math.huge
 local bestPart=nil
 for _,part in ipairs(targets) do
  if part.Parent then
   local d=(part.Position-pos).Magnitude
   if d<best then best=d;bestPart=part end
  end
 end
 return best,bestPart
end

local function actorRouteState(a)
 local from=a.route[a.seg]
 local to=a.route[a.seg%#a.route+1]
 local len=(to-from).Magnitude
 local pos=from:Lerp(to,a.t)
 local travel=(to-from).Unit
 return from,to,len,pos,travel
end

local function trafficAhead(selfActor,pos,travel)
 local nearest=math.huge
 for _,other in ipairs(actors) do
  if other~=selfActor then
   local otherPos=other.logicalPos or (other.model.PrimaryPart and other.model.PrimaryPart.Position)
   if otherPos then
    local relative=otherPos-pos
    local ahead=relative:Dot(travel)
    if ahead>0 and ahead<28 then
     local lateral=(relative-travel*ahead).Magnitude
     if lateral<7 then nearest=math.min(nearest,ahead) end
    end
   end
  end
 end
 return nearest
end

local function pedestrianAhead(pos,travel)
 local nearest=math.huge
 for _,w in ipairs(walkers) do
  local pedPos=w.a:Lerp(w.b,w.t)
  local relative=pedPos-pos
  local ahead=relative:Dot(travel)
  if ahead>-2 and ahead<24 then
   local lateral=(relative-travel*ahead).Magnitude
   if lateral<8 then nearest=math.min(nearest,math.max(ahead,0)) end
  end
 end
 return nearest
end

local function intersectionScale(pos,travel)
 local scale=1
 for _,center in ipairs(intersections) do
  local rel=center-pos
  local ahead=rel:Dot(travel)
  local lateral=(rel-travel*ahead).Magnitude
  if ahead>0 and ahead<52 and lateral<18 then
   scale=math.min(scale,.45+.55*math.clamp(ahead/52,0,1))
  elseif (pos-center).Magnitude<20 then
   scale=math.min(scale,.5)
  end
 end
 return scale
end

local function setBrakeLights(model,on)
 if model:GetAttribute('BrakeState')==on then return end
 model:SetAttribute('BrakeState',on)
 local c=on and Color3.fromRGB(255,40,28) or Color3.fromRGB(90,15,15)
 for _,x in ipairs(model:GetChildren()) do if x.Name=='BrakeLight' and x:IsA('BasePart') then x.Color=c end end
end

local function setVisible(model,visible)
 if model:GetAttribute('Visible')==visible then return end
 model:SetAttribute('Visible',visible)
 for _,x in ipairs(model:GetDescendants()) do if x:IsA('BasePart') then x.Transparency=visible and (x.Name=='Glass' and .2 or 0) or 1 end end
end

local function hasNearActivity(playerSnapshot,vehicleSnapshot)
 for _,a in ipairs(actors) do
  local pos=a.logicalPos or (a.model.PrimaryPart and a.model.PrimaryPart.Position)
  if pos then
   local pd=nearestFromSnapshot(playerSnapshot,pos)
   local vd=nearestFromSnapshot(vehicleSnapshot,pos)
   if pd<280 or vd<280 then return true end
  end
 end
 for _,w in ipairs(walkers) do
  local pos=w.a:Lerp(w.b,w.t)
  local pd=nearestFromSnapshot(playerSnapshot,pos)
  local vd=nearestFromSnapshot(vehicleSnapshot,pos)
  if pd<220 or vd<220 then return true end
 end
 return false
end

local accum=0
local lastNearActivity=false
RunService.Heartbeat:Connect(function(dt)
 accum+=dt
 local livePlayers=Players:GetPlayers()
 local playerCount=#livePlayers
 local provisionalStep=playerCount==0 and .25 or (lastNearActivity and .05 or .1)
 if accum<provisionalStep then return end

 local playerSnapshot,vehicleSnapshot=buildProximitySnapshot()
 for _,a in ipairs(actors) do local _,_,_,pos=actorRouteState(a);a.logicalPos=pos end
 local nearActivity=playerCount>0 and hasNearActivity(playerSnapshot,vehicleSnapshot)
 lastNearActivity=nearActivity
 local targetStep=playerCount==0 and .25 or (nearActivity and .05 or .1)
 if accum<targetStep then return end
 dt=math.min(accum,.25);accum=0

 Workspace:SetAttribute('BecakTrafficSnapshotPlayers',#playerSnapshot)
 Workspace:SetAttribute('BecakTrafficSnapshotVehicles',#vehicleSnapshot)
 Workspace:SetAttribute('BecakTrafficNearActivity',nearActivity and 'ON' or 'OFF')
 Workspace:SetAttribute('BecakTrafficCurrentHz',math.floor(1/targetStep+.5))

 local fullTrafficModels=0
 local pedestrianYieldCount=0
 for _,a in ipairs(actors) do
  local from,to,len,pos,travel=actorRouteState(a)
  local playerDist,hrp=nearestFromSnapshot(playerSnapshot,pos)
  local vehicleDist,vehiclePart=nearestFromSnapshot(vehicleSnapshot,pos)
  local yieldNow=false
  local pedestrianYield=false
  if hrp and playerDist<26 then
   local relative=hrp.Position-pos
   local ahead=relative:Dot(travel)
   if ahead>-5 and ahead<22 then yieldNow=true end
  end
  if vehiclePart and vehicleDist<36 then
   local relative=vehiclePart.Position-pos
   local ahead=relative:Dot(travel)
   local lateral=(relative-travel*ahead).Magnitude
   if ahead>-8 and ahead<30 and lateral<10 then yieldNow=true end
  end
  if trafficAhead(a,pos,travel)<15 then yieldNow=true end
  if pedestrianAhead(pos,travel)<12 then yieldNow=true;pedestrianYield=true;pedestrianYieldCount+=1 end

  local speedScale=intersectionScale(pos,travel)
  a.yielding=yieldNow
  if not yieldNow then
   a.t+=a.speed*speedScale*dt/math.max(len,1)
   if a.t>=1 then a.t-=1;a.seg=a.seg%#a.route+1;from=a.route[a.seg];to=a.route[a.seg%#a.route+1] end
   pos=from:Lerp(to,a.t)
  end
  a.logicalPos=pos

  local visible=playerDist<380 or vehicleDist<380
  a.model:SetAttribute('Yielding',yieldNow)
  a.model:SetAttribute('PedestrianYield',pedestrianYield)
  a.model:SetAttribute('IntersectionSpeedScale',speedScale)
  a.model:SetAttribute('SimulationLOD',visible and 'FULL' or 'LOGIC_ONLY')
  setVisible(a.model,visible)
  if visible then
   fullTrafficModels+=1
   local cf=CFrame.lookAt(pos,to)
   a.model:PivotTo(cf)
   setBrakeLights(a.model,yieldNow or speedScale<.72)
  end
 end

 local fullPedestrianModels=0
 for _,w in ipairs(walkers) do
  local len=(w.b-w.a).Magnitude
  local pos=w.a:Lerp(w.b,w.t)
  local playerDist=nearestFromSnapshot(playerSnapshot,pos)
  local vehicleDist=nearestFromSnapshot(vehicleSnapshot,pos)
  local walkScale=(playerDist<7 or vehicleDist<10) and 0 or 1
  w.t+=w.dir*w.speed*dt/math.max(len,1)*walkScale
  if w.t>1 then w.t=1;w.dir=-1 elseif w.t<0 then w.t=0;w.dir=1 end
  pos=w.a:Lerp(w.b,w.t)
  local visible=playerDist<220 or vehicleDist<220
  w.model:SetAttribute('SimulationLOD',visible and 'FULL' or 'LOGIC_ONLY')
  setVisible(w.model,visible)
  if visible then
   fullPedestrianModels+=1
   local target=w.dir>0 and w.b or w.a
   w.model:PivotTo(CFrame.lookAt(pos,target))
  end
 end

 Workspace:SetAttribute('BecakTrafficFullModelCount',fullTrafficModels)
 Workspace:SetAttribute('BecakPedestrianFullModelCount',fullPedestrianModels)
 Workspace:SetAttribute('BecakTrafficPedestrianYieldCount',pedestrianYieldCount)
end)

Workspace:SetAttribute('ACC_BecakTrafficNPC','v1.17')
Workspace:SetAttribute('ACC_BecakTrafficNPCEnhancement','v1.20')
Workspace:SetAttribute('BecakTrafficVehicleCount',#actors)
Workspace:SetAttribute('BecakPedestrianCount',#walkers)
Workspace:SetAttribute('BecakTrafficPlayerYield','ON')
Workspace:SetAttribute('BecakTrafficVehicleYield','ON')
Workspace:SetAttribute('BecakTrafficPedestrianYield','ON')
Workspace:SetAttribute('BecakTrafficHeadway','ON')
Workspace:SetAttribute('BecakTrafficBrakeLights','ON')
Workspace:SetAttribute('BecakTrafficIntersectionPacing','ON')
Workspace:SetAttribute('BecakTrafficIntersectionPacingCorrected','ON')
Workspace:SetAttribute('BecakTrafficAdaptiveTick','ON')
Workspace:SetAttribute('BecakTrafficProximityAdaptiveTick','ON')
Workspace:SetAttribute('BecakTrafficProximitySnapshot','ON')
Workspace:SetAttribute('BecakTrafficModelLOD','ON')
Workspace:SetAttribute('BecakTrafficLogicOnlyCull','ON')
Workspace:SetAttribute('BecakTrafficTrueNearCadence','ON')
Workspace:SetAttribute('BecakTrafficNearHz',20)
Workspace:SetAttribute('BecakTrafficFarHz',10)
Workspace:SetAttribute('BecakTrafficEmptyHz',4)
Workspace:SetAttribute('BecakTrafficLogicOnlyLOD','ON')
Workspace:SetAttribute('BecakTrafficRealScaleRemesh','v3.2')
Workspace:SetAttribute('BecakTrafficWheelCylinderAxis','X')
print('[BECAK E-BIKE] traffic + pedestrian AI v1.20 ready: V3.2 sedan remesh + grounded wheels + existing AI/LOD preserved')
