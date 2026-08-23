-- ACC Mountain Social Adventure — World Life / Summit Polish v5.1
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Terrain=Workspace.Terrain
local root=Workspace:WaitForChild("ACC_MountainSocial",20);if not root then return end

task.wait(28)
local old=root:FindFirstChild("WorldLifeV51");if old then old:Destroy() end
local f=Instance.new("Folder");f.Name="WorldLifeV51";f.Parent=root

local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Include;rp.FilterDescendantsInstances={Terrain};rp.IgnoreWater=false
local function terrainY(x,z)
 local hit=Workspace:Raycast(Vector3.new(x,1700,z),Vector3.new(0,-3400,0),rp)
 return hit and hit.Position.Y or nil
end
local function mk(n,s,cf,m,c,p,tr,coll)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Material=m or Enum.Material.Ground
 if c then x.Color=c end;x.Transparency=tr or 0;x.CanCollide=coll==true;x.CastShadow=true;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p or f;return x
end
local function beam(n,a,b,w,mat,col,p,coll)
 local d=b-a;if d.Magnitude<.05 then return nil end
 return mk(n,Vector3.new(w,w,d.Magnitude),CFrame.lookAt((a+b)/2,b),mat,col,p,0,coll)
end
local function ball(n,pos,size,mat,col,p,coll)
 local x=mk(n,Vector3.new(size,size*.72,size*.9),CFrame.new(pos)*CFrame.Angles(math.rad(math.random(-14,14)),math.rad(math.random(0,180)),math.rad(math.random(-12,12))),mat,col,p,0,coll);x.Shape=Enum.PartType.Ball;return x
end

math.randomseed(510824)

-- 1) Lived-in village details: subtle utilitarian props, all terrain-grounded.
local villageLife=0
local villageSpots={
 Vector3.new(-70,0,920),Vector3.new(76,0,865),Vector3.new(-88,0,760),Vector3.new(92,0,690),
 Vector3.new(-82,0,590),Vector3.new(86,0,500),Vector3.new(-68,0,420),Vector3.new(74,0,350)
}
for i,p in ipairs(villageSpots) do
 local y=terrainY(p.X,p.Z)
 if y then
  local cf=CFrame.new(p.X,y,p.Z)*CFrame.Angles(0,math.rad((i*37)%180),0)
  -- low wooden bench
  mk("VillageBenchSeat",Vector3.new(5.2,.38,1.15),cf*CFrame.new(0,1.35,0),Enum.Material.WoodPlanks,Color3.fromRGB(111,78,49),f,0,true)
  mk("VillageBenchLeg",Vector3.new(.42,1.35,.8),cf*CFrame.new(-1.65,.68,0),Enum.Material.Wood,Color3.fromRGB(81,58,41),f,0,true)
  mk("VillageBenchLeg",Vector3.new(.42,1.35,.8),cf*CFrame.new(1.65,.68,0),Enum.Material.Wood,Color3.fromRGB(81,58,41),f,0,true)
  -- water jar / utility drum
  local jar=mk("WaterJar",Vector3.new(1.5,2.1,1.5),cf*CFrame.new(3.0,1.05,.2),Enum.Material.Slate,Color3.fromRGB(108,93,72),f,0,true);jar.Shape=Enum.PartType.Cylinder
  villageLife+=4
 end
end

-- Short woven/wood fences around selected yards. Irregular spans avoid a repeated arcade look.
local fenceLines={
 {Vector3.new(-122,0,900),Vector3.new(-122,0,820)},
 {Vector3.new(118,0,785),Vector3.new(120,0,700)},
 {Vector3.new(-130,0,610),Vector3.new(-126,0,525)},
 {Vector3.new(125,0,510),Vector3.new(120,0,430)}
}
for li,line in ipairs(fenceLines) do
 local a,b=line[1],line[2]
 for s=0,5 do
  local t=s/5;local p=a:Lerp(b,t);local y=terrainY(p.X,p.Z)
  if y then mk("YardFencePost",Vector3.new(.32,3.0,.32),CFrame.new(p.X,y+1.5,p.Z)*CFrame.Angles(0,0,math.rad(((s+li)%3)-1)*2),Enum.Material.Wood,Color3.fromRGB(91,66,45),f,0,true);villageLife+=1 end
 end
 local ya=terrainY(a.X,a.Z);local yb=terrainY(b.X,b.Z)
 if ya and yb then
  beam("YardFenceRail",Vector3.new(a.X,ya+1.0,a.Z),Vector3.new(b.X,yb+1.0,b.Z),.22,Enum.Material.Wood,Color3.fromRGB(103,75,50),f,false)
  beam("YardFenceRail",Vector3.new(a.X,ya+2.0,a.Z),Vector3.new(b.X,yb+2.0,b.Z),.20,Enum.Material.Wood,Color3.fromRGB(103,75,50),f,false)
  villageLife+=2
 end
end

-- 2) Rice irrigation realism: shallow canals + tiny wood crossings + bund stones.
local irrigation=0
local canalLines={
 {Vector3.new(-155,0,975),Vector3.new(-150,0,615)},
 {Vector3.new(152,0,940),Vector3.new(148,0,610)},
 {Vector3.new(-142,0,565),Vector3.new(-132,0,330)},
 {Vector3.new(140,0,560),Vector3.new(132,0,335)}
}
for ci,line in ipairs(canalLines) do
 local a,b=line[1],line[2]
 local segments=12
 local last=nil
 for s=0,segments do
  local t=s/segments;local p=a:Lerp(b,t);local y=terrainY(p.X,p.Z)
  if y then
   local q=Vector3.new(p.X,y+.08,p.Z)
   if last then
    local water=beam("IrrigationWater",last,q,1.55,Enum.Material.Glass,Color3.fromRGB(80,112,104),f,false);if water then water.Transparency=.36 end
    local left=Vector3.new(-.95,0,0);ball("CanalStone",q+left,.8+math.random()*.5,Enum.Material.Rock,Color3.fromRGB(104,99,84),f,false)
    irrigation+=2
   end
   last=q
  end
 end
 -- small crossing near middle of each canal
 local mid=a:Lerp(b,.5);local my=terrainY(mid.X,mid.Z)
 if my then
  mk("CanalFootbridge",Vector3.new(5.2,.28,2.1),CFrame.new(mid.X,my+.48,mid.Z)*CFrame.Angles(0,math.rad(ci%2==0 and 90 or 0),0),Enum.Material.WoodPlanks,Color3.fromRGB(119,84,52),f,0,true)
  irrigation+=1
 end
end

-- 3) Lower forest depth: mossy rock clusters, fallen deadwood and layered saplings.
local forestDepth=0
for i=1,64 do
 local z=-80-math.random()*1180
 local x=-285+math.random()*570
 local y=terrainY(x,z)
 if y and y>22 and y<390 then
  if i%4==0 then
   local base=Vector3.new(x,y+.08,z)
   local len=6+math.random()*8;local ang=math.random()*math.pi*2
   beam("FallenDeadwood",base+Vector3.new(0,.6,0),base+Vector3.new(math.cos(ang)*len,.35,math.sin(ang)*len),.65+math.random()*.45,Enum.Material.Wood,Color3.fromRGB(72,57,43),f,false)
  elseif i%3==0 then
   local r=ball("MossRock",Vector3.new(x,y+.2,z),1.5+math.random()*3.2,Enum.Material.Rock,Color3.fromRGB(91,96,79),f,false)
   local moss=ball("MossCap",Vector3.new(x,y+.65,z),1.2+math.random()*2.4,Enum.Material.Grass,Color3.fromRGB(62,89,52),f,false);moss.Transparency=.08
  else
   local h=3.2+math.random()*4.5
   mk("ForestSapling",Vector3.new(.35,h,.35),CFrame.new(x,y+h*.5,z)*CFrame.Angles(0,0,math.rad(math.random(-7,7))),Enum.Material.Wood,Color3.fromRGB(78,59,42),f,0,false)
   for k=1,3 do
    local q=ball("SaplingLeaf",Vector3.new(x+math.random(-12,12)/10,y+h*.7+k*.45,z+math.random(-12,12)/10),1.8+math.random()*1.7,Enum.Material.LeafyGrass,Color3.fromRGB(48+math.random(0,12),82+math.random(0,18),43+math.random(0,10)),f,false);q.CanCollide=false
   end
  end
  forestDepth+=1
 end
end

-- 4) Trail edge retaining stones on selected steep transitions: keeps route readable but natural.
local trailEdge=0
local edges={
 {Vector3.new(-232,0,-1040),Vector3.new(-260,0,-1135)},
 {Vector3.new(-248,0,-1180),Vector3.new(-270,0,-1275)},
 {Vector3.new(-245,0,-1320),Vector3.new(-230,0,-1405)},
 {Vector3.new(210,0,-1970),Vector3.new(255,0,-2055)}
}
for ei,line in ipairs(edges) do
 for s=0,7 do
  local p=line[1]:Lerp(line[2],s/7);local y=terrainY(p.X,p.Z)
  if y then
   local offset=((s%2)*.55)-.25
   ball("TrailRetainingStone",Vector3.new(p.X+offset,y+.22,p.Z),1.5+math.random()*1.7,Enum.Material.Rock,Color3.fromRGB(104+math.random(0,12),102+math.random(0,10),93+math.random(0,9)),f,true)
   trailEdge+=1
  end
 end
end

-- 5) Summit payoff polish: weathered natural cairn, plaque, resting slab, no arcade monument.
local summitDetail=0
local summit=Vector3.new(96,0,-2525);local sy=terrainY(summit.X,summit.Z)
if sy then
 local base=Vector3.new(summit.X,sy,summit.Z)
 for layer=1,5 do
  local count=6-layer
  for i=1,count do
   local a=(i/count)*math.pi*2+layer*.42
   local radius=math.max(.35,3.0-layer*.5)
   local p=base+Vector3.new(math.cos(a)*radius,layer*.55,math.sin(a)*radius)
   ball("SummitCairnStone",p,2.4-layer*.25,Enum.Material.Slate,Color3.fromRGB(105+layer*3,105+layer*2,101+layer*2),f,true)
   summitDetail+=1
  end
 end
 local post=mk("SummitPlaquePost",Vector3.new(.7,5.6,.7),CFrame.new(base+Vector3.new(4.8,2.8,0)),Enum.Material.Wood,Color3.fromRGB(82,60,42),f,0,true)
 local board=mk("SummitPlaque",Vector3.new(6.8,2.1,.36),CFrame.new(base+Vector3.new(4.8,5.2,0))*CFrame.Angles(0,math.rad(-18),0),Enum.Material.WoodPlanks,Color3.fromRGB(105,75,47),f,0,true)
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.AlwaysOnTop=false;gui.LightInfluence=.25;gui.Parent=board
 local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Text="PUNCAK UTAMA";label.TextColor3=Color3.fromRGB(235,229,210);label.TextScaled=true;label.Font=Enum.Font.GothamBold;label.Parent=gui
 local rest=ball("SummitRestRock",base+Vector3.new(-5.5,.2,2.5),4.8,Enum.Material.Slate,Color3.fromRGB(112,111,106),f,true);rest.Size=Vector3.new(6.8,1.1,3.8)
 summitDetail+=4
end

-- 6) Subtle night fireflies only in lower forest. Tiny emission count, disabled outside night.
local fireflyEmitters={}
for i=1,5 do
 local p=Vector3.new(-160+math.random(-90,90),0,-360-i*135);local y=terrainY(p.X,p.Z)
 if y then
  local anchor=mk("FireflyAnchor",Vector3.new(.2,.2,.2),CFrame.new(p.X,y+4,p.Z),Enum.Material.SmoothPlastic,Color3.fromRGB(255,224,144),f,1,false)
  local pe=Instance.new("ParticleEmitter");pe.Name="NightFireflies";pe.Rate=0;pe.Lifetime=NumberRange.new(2.2,4.0);pe.Speed=NumberRange.new(.25,.8);pe.SpreadAngle=Vector2.new(180,180);pe.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.08),NumberSequenceKeypoint.new(.5,.14),NumberSequenceKeypoint.new(1,0)});pe.LightEmission=.7;pe.Color=ColorSequence.new(Color3.fromRGB(255,222,136));pe.Parent=anchor
  table.insert(fireflyEmitters,pe)
 end
end
local function updateNightFX()
 local phase=tostring(Workspace:GetAttribute("ACC_DayPhase") or "")
 local night=phase=="NIGHT" or Lighting.ClockTime>=18.5 or Lighting.ClockTime<5.2
 for _,pe in ipairs(fireflyEmitters) do pe.Rate=night and 1.6 or 0 end
end
updateNightFX();Workspace:GetAttributeChangedSignal("ACC_DayPhase"):Connect(updateNightFX)
task.spawn(function() while f.Parent do updateNightFX();task.wait(10) end end)

root:SetAttribute("WorldLifeReady",true)
root:SetAttribute("WorldLifeVersion","5.1")
root:SetAttribute("VillageLifeDetailCount",villageLife)
root:SetAttribute("IrrigationDetailCount",irrigation)
root:SetAttribute("ForestDepthDetailCount",forestDepth)
root:SetAttribute("TrailRetainingDetailCount",trailEdge)
root:SetAttribute("SummitPolishDetailCount",summitDetail)
root:SetAttribute("NightFireflyEmitterCount",#fireflyEmitters)
print("[ACC] Mountain v5.1 world-life realism ready",villageLife,irrigation,forestDepth,trailEdge,summitDetail,#fireflyEmitters)
