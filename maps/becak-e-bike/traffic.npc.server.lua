-- BECAK E-BIKE — lightweight traffic + pedestrian life v1.14
-- Dedicated to maps/becak-e-bike. Mobile-first ambient AI with player/vehicle-aware yielding,
-- traffic headway, intersection pacing, bounded counts, deterministic routes, distance culling, and adaptive cadence.
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
 local body=p(m,'Body',Vector3.new(5.5,1.6,9),color);body.CFrame=CFrame.new(0,-100,0);m.PrimaryPart=body
 local roof=p(m,'Roof',Vector3.new(4.5,1.3,4.5),color:Lerp(Color3.new(1,1,1),.12));roof.CFrame=body.CFrame*CFrame.new(0,1.35,.3)
 local glass=p(m,'Glass',Vector3.new(4.2,.85,2.2),Color3.fromRGB(55,70,78));glass.Material=Enum.Material.Glass;glass.Transparency=.2;glass.CFrame=body.CFrame*CFrame.new(0,1.35,-1.1)
 for _,o in ipairs({Vector3.new(-2.4,-.75,-2.7),Vector3.new(2.4,-.75,-2.7),Vector3.new(-2.4,-.75,2.7),Vector3.new(2.4,-.75,2.7)}) do
  local w=p(m,'Wheel',Vector3.new(1.1,1.1,.7),Color3.fromRGB(24,24,24));w.Shape=Enum.PartType.Cylinder;w.CFrame=body.CFrame*CFrame.new(o)*CFrame.Angles(0,0,math.rad(90))
 end
 local brakeL=p(m,'BrakeLight',Vector3.new(.8,.45,.2),Color3.fromRGB(90,15,15));brakeL.CFrame=body.CFrame*CFrame.new(-1.65,.1,4.55)
 local brakeR=p(m,'BrakeLight',Vector3.new(.8,.45,.2),Color3.fromRGB(90,15,15));brakeR.CFrame=body.CFrame*CFrame.new(1.65,.1,4.55)
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
 actors[#actors+1]={model=m,route=route,seg=((i-1)%#route)+1,t=(i*.13)%1,speed=18+(i%3)*3,yielding=false}
end
local walkers={}
for i=1,8 do
 local route=walkRoutes[((i-1)%#walkRoutes)+1]
 local m=makePed('Pedestrian_'..i,shirts[((i-1)%#shirts)+1])
 walkers[#walkers+1]={model=m,a=route[1],b=route[2],t=(i*.17)%1,dir=(i%2==0) and 1 or -1,speed=4+(i%2)}
end

local function nearestPlayerInfo(pos)
 local best=math.huge
 local bestHrp=nil
 for _,plr in ipairs(Players:GetPlayers()) do
  local ch=plr.Character;local hrp=ch and ch:FindFirstChild('HumanoidRootPart')
  if hrp then
   local d=(hrp.Position-pos).Magnitude
   if d<best then best=d;bestHrp=hrp end
  end
 end
 return best,bestHrp
end

local function nearestOwnedVehicleInfo(pos)
 local best=math.huge
 local bestPart=nil
 for _,model in ipairs(playerVehicles:GetChildren()) do
  local primary=model:IsA('Model') and model.PrimaryPart
  if primary then
   local d=(primary.Position-pos).Magnitude
   if d<best then best=d;bestPart=primary end
  end
 end
 return best,bestPart
end

local function trafficAhead(selfActor,pos,travel)
 local nearest=math.huge
 for _,other in ipairs(actors) do
  if other~=selfActor and other.model.PrimaryPart then
   local relative=other.model.PrimaryPart.Position-pos
   local ahead=relative:Dot(travel)
   if ahead>0 and ahead<28 then
    local lateral=(relative-travel*ahead).Magnitude
    if lateral<7 then nearest=math.min(nearest,ahead) end
   end
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
   scale=math.min(scale,.48+.52*math.clamp((52-ahead)/52,0,1))
  elseif (pos-center).Magnitude<20 then
   scale=math.min(scale,.58)
  end
 end
 return scale
end

local function setBrakeLights(model,on)
 local c=on and Color3.fromRGB(255,40,28) or Color3.fromRGB(90,15,15)
 for _,x in ipairs(model:GetChildren()) do if x.Name=='BrakeLight' and x:IsA('BasePart') then x.Color=c end end
end

local function setVisible(model,visible)
 if model:GetAttribute('Visible')==visible then return end
 model:SetAttribute('Visible',visible)
 for _,x in ipairs(model:GetDescendants()) do if x:IsA('BasePart') then x.Transparency=visible and (x.Name=='Glass' and .2 or 0) or 1 end end
end

local accum=0
RunService.Heartbeat:Connect(function(dt)
 accum+=dt
 local playerCount=#Players:GetPlayers()
 local targetStep=playerCount>0 and .05 or .25 -- 20 Hz occupied, 4 Hz empty
 if accum<targetStep then return end
 dt=math.min(accum,.25);accum=0

 for _,a in ipairs(actors) do
  local from=a.route[a.seg];local to=a.route[a.seg%#a.route+1];local len=(to-from).Magnitude
  local pos=from:Lerp(to,a.t)
  local travel=(to-from).Unit
  local playerDist,hrp=nearestPlayerInfo(pos)
  local vehicleDist,vehiclePart=nearestOwnedVehicleInfo(pos)
  local yieldNow=false

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

  local speedScale=intersectionScale(pos,travel)
  a.yielding=yieldNow
  if not yieldNow then
   a.t+=a.speed*speedScale*dt/math.max(len,1)
   if a.t>=1 then a.t-=1;a.seg=a.seg%#a.route+1;from=a.route[a.seg];to=a.route[a.seg%#a.route+1] end
   pos=from:Lerp(to,a.t)
  end
  local cf=CFrame.lookAt(pos,to)
  a.model:PivotTo(cf)
  a.model:SetAttribute('Yielding',yieldNow)
  a.model:SetAttribute('IntersectionSpeedScale',speedScale)
  setBrakeLights(a.model,yieldNow or speedScale<.7)
  setVisible(a.model,playerDist<430 or vehicleDist<430)
 end

 for _,w in ipairs(walkers) do
  local len=(w.b-w.a).Magnitude
  local pos=w.a:Lerp(w.b,w.t)
  local playerDist=nearestPlayerInfo(pos)
  local vehicleDist=nearestOwnedVehicleInfo(pos)
  local walkScale=(playerDist<7 or vehicleDist<10) and 0 or 1 -- pause before clipping through player/becak
  w.t+=w.dir*w.speed*dt/math.max(len,1)*walkScale
  if w.t>1 then w.t=1;w.dir=-1 elseif w.t<0 then w.t=0;w.dir=1 end
  pos=w.a:Lerp(w.b,w.t);local target=w.dir>0 and w.b or w.a
  w.model:PivotTo(CFrame.lookAt(pos,target));setVisible(w.model,playerDist<240 or vehicleDist<240)
 end
end)

Workspace:SetAttribute('ACC_BecakTrafficNPC','v1.14')
Workspace:SetAttribute('BecakTrafficVehicleCount',#actors)
Workspace:SetAttribute('BecakPedestrianCount',#walkers)
Workspace:SetAttribute('BecakTrafficPlayerYield','ON')
Workspace:SetAttribute('BecakTrafficVehicleYield','ON')
Workspace:SetAttribute('BecakTrafficHeadway','ON')
Workspace:SetAttribute('BecakTrafficBrakeLights','ON')
Workspace:SetAttribute('BecakTrafficIntersectionPacing','ON')
Workspace:SetAttribute('BecakTrafficAdaptiveTick','ON')
print('[BECAK E-BIKE] traffic + pedestrian AI v1.14 ready: intersection pacing + becak-aware yield + headway')
