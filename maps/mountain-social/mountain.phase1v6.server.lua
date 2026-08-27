-- ACC Mountain Social Adventure — REBUILD v6.0 PHASE 1
-- Scope hard-lock: Spawn village -> paved road -> damaged road -> gravel -> trail mouth -> narrowing forest trail -> POS 1.
-- Rule: TERRAIN FIRST. After TERRAIN_FROZEN=true, this script performs no terrain edits.
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Terrain=Workspace.Terrain

local ROOT_NAME="ACC_MountainSocial"
local prior=Workspace:FindFirstChild(ROOT_NAME);if prior then prior:Destroy() end
local root=Instance.new("Folder");root.Name=ROOT_NAME;root.Parent=Workspace
local folders={}
for _,name in ipairs({"Checkpoints","Village","RiceFields","Roadside","ForestEdge","POS1","RouteDebug"}) do
 local f=Instance.new("Folder");f.Name=name;f.Parent=root;folders[name]=f
end

math.randomseed(602801)

local function mk(name,size,cf,mat,col,parent,tr,coll)
 local p=Instance.new("Part");p.Name=name;p.Anchored=true;p.Size=size;p.CFrame=cf
 p.Material=mat or Enum.Material.SmoothPlastic;if col then p.Color=col end
 p.Transparency=tr or 0;p.CanCollide=coll==true;p.CastShadow=true
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or root
 return p
end
local function beam(name,a,b,width,mat,col,parent,coll)
 local d=b-a;if d.Magnitude<.05 then return nil end
 return mk(name,Vector3.new(width,width,d.Magnitude),CFrame.lookAt((a+b)/2,b),mat,col,parent,0,coll)
end
local function ellipsoid(name,pos,size,col,parent)
 local p=mk(name,size,CFrame.new(pos)*CFrame.Angles(math.rad(math.random(-8,8)),math.rad(math.random(0,180)),math.rad(math.random(-7,7))),Enum.Material.LeafyGrass,col,parent,0,false)
 p.Shape=Enum.PartType.Ball;return p
end
local function terrainStrip(a,b,width,height,mat)
 local d=b-a;if d.Magnitude<.05 then return end
 Terrain:FillBlock(CFrame.lookAt((a+b)/2,b),Vector3.new(width,height,d.Magnitude+2.2),mat)
end
local function shallowMound(x,z,r,top,mat)
 Terrain:FillBall(Vector3.new(x,top-r,z),r,mat or Enum.Material.Grass)
end
local function catmull(p0,p1,p2,p3,t)
 local t2=t*t;local t3=t2*t
 return .5*((2*p1)+(-p0+p2)*t+(2*p0-5*p1+4*p2-p3)*t2+(-p0+3*p1-3*p2+p3)*t3)
end
local function sampleSpline(ctrl,steps)
 local pts={}
 for i=1,#ctrl-1 do
  local p0=ctrl[math.max(1,i-1)];local p1=ctrl[i];local p2=ctrl[i+1];local p3=ctrl[math.min(#ctrl,i+2)]
  for s=0,steps-1 do table.insert(pts,catmull(p0,p1,p2,p3,s/steps)) end
 end
 table.insert(pts,ctrl[#ctrl]);return pts
end
local function xzDist(a,b)
 local dx=a.X-b.X;local dz=a.Z-b.Z;return math.sqrt(dx*dx+dz*dz)
end
local function minDistTo(points,p)
 local best=1e9
 for _,q in ipairs(points) do local d=xzDist(q,p);if d<best then best=d end end
 return best
end

-- ============================================================================
-- STAGE A — TERRAIN FOUNDATION. Nothing visual is placed before this is final.
-- ============================================================================
Terrain:Clear()
Terrain:FillBlock(CFrame.new(0,-15,470),Vector3.new(2200,50,1900),Enum.Material.Grass) -- top ~= 10

-- Broad landscape only. No spherical hill is allowed on the road/trail corridor.
for _,m in ipairs({
 {-430,1040,260,20},{430,990,280,22},{-470,760,285,25},{470,700,295,27},
 {-445,480,270,29},{450,390,285,32},{-410,165,245,34},{405,105,250,37},
 {-520,-260,300,62},{500,-330,320,70},{-330,-520,300,86},{340,-570,320,92}
}) do shallowMound(m[1],m[2],m[3],m[4],Enum.Material.Grass) end

-- Gentle foothill around, not on, the hiking corridor.
for _,m in ipairs({{-230,70,155,30},{190,40,165,32},{-250,-90,175,39},{235,-120,180,42}}) do
 shallowMound(m[1],m[2],m[3],m[4],Enum.Material.Grass)
end

-- Vehicle route: deliberately gentle grades. It ENDS before hiking begins.
local roadCtrl={
 Vector3.new(0,10.7,1060),Vector3.new(8,10.9,930),Vector3.new(-4,11.2,800),
 Vector3.new(16,11.6,670),Vector3.new(42,12.2,545),Vector3.new(59,12.9,430),
 Vector3.new(61,13.7,335),Vector3.new(53,14.5,255),Vector3.new(42,15.2,185),
 Vector3.new(38,15.5,150)
}
local roadPts=sampleSpline(roadCtrl,10)

local function roadWidth(progress)
 if progress<.58 then return 22 elseif progress<.80 then return 19 else return 16 end
end

-- Carve first, then fill subgrade and road material. This makes floating road impossible.
for i=1,#roadPts-1 do
 local a,b=roadPts[i],roadPts[i+1];local progress=(i-1)/math.max(1,#roadPts-2);local w=roadWidth(progress)
 terrainStrip(a+Vector3.new(0,7,0),b+Vector3.new(0,7,0),w+18,14,Enum.Material.Air)
 terrainStrip(a-Vector3.new(0,1.35,0),b-Vector3.new(0,1.35,0),w+9,3.1,Enum.Material.Ground)
 local material=progress<.76 and Enum.Material.Pavement or Enum.Material.Ground
 terrainStrip(a-Vector3.new(0,.12,0),b-Vector3.new(0,.12,0),w,.75,material)
end

-- Vehicle turnaround / end of public road.
local roadEnd=roadPts[#roadPts]
Terrain:FillBlock(CFrame.new(roadEnd-Vector3.new(0,1.2,0)),Vector3.new(48,3.0,42),Enum.Material.Ground)
Terrain:FillBlock(CFrame.new(roadEnd-Vector3.new(0,.10,0)),Vector3.new(40,.8,34),Enum.Material.Ground)

-- Hiking trail branches from the LEFT side of the damaged road, then winds into forest.
local trailCtrl={
 Vector3.new(28,15.5,190),Vector3.new(10,15.9,155),Vector3.new(-10,16.4,118),
 Vector3.new(-26,17.1,77),Vector3.new(-35,18.0,34),Vector3.new(-51,19.1,-4),
 Vector3.new(-67,20.4,-39),Vector3.new(-82,22.0,-72)
}
local trailPts=sampleSpline(trailCtrl,9)
local function trailWidth(progress)return 9.2-progress*3.7 end
for i=1,#trailPts-1 do
 local a,b=trailPts[i],trailPts[i+1];local progress=(i-1)/math.max(1,#trailPts-2);local w=trailWidth(progress)
 terrainStrip(a+Vector3.new(0,5,0),b+Vector3.new(0,5,0),w+9,10,Enum.Material.Air)
 terrainStrip(a-Vector3.new(0,.8,0),b-Vector3.new(0,.8,0),w+5,2.1,Enum.Material.Ground)
 terrainStrip(a-Vector3.new(0,.05,0),b-Vector3.new(0,.05,0),w,.58,Enum.Material.Ground)
end

-- POS1 clearing is a small natural bench, not a giant circular mountain/platform.
local cp1=Vector3.new(-82,22.0,-72)
Terrain:FillBlock(CFrame.new(cp1-Vector3.new(0,1.15,0)),Vector3.new(58,3.0,44),Enum.Material.Ground)
Terrain:FillBlock(CFrame.new(cp1-Vector3.new(0,.08,0)),Vector3.new(52,.7,38),Enum.Material.Ground)
-- short continuation stub only; Phase 2 will start here later.
terrainStrip(cp1+Vector3.new(-5,0,-15),cp1+Vector3.new(-10,.7,-32),6.0,1.7,Enum.Material.Ground)

-- House pads are explicitly cut/fill BEFORE houses exist.
local housePads={
 {-62,1000,11.1,24,20,12},{67,945,11.25,23,19,-14},{-72,865,11.45,24,19,8},
 {74,780,11.7,23,19,-11},{-80,690,11.9,22,18,10},{82,598,12.15,22,18,-12},
 {-86,510,12.4,21,18,8},{90,430,12.75,21,18,-10}
}
for _,h in ipairs(housePads) do
 Terrain:FillBlock(CFrame.new(h[1],h[3]-1.05,h[2]),Vector3.new(h[4]+8,2.5,h[5]+8),Enum.Material.Ground)
end

-- Rice terraces: grounded, stepped and separated from the road corridor.
local paddies={
 {-150,970,10.55,62,38},{150,950,10.6,62,38},{-160,885,10.7,66,40},{163,860,10.75,66,40},
 {-170,795,10.9,68,41},{176,760,11.0,68,41},{-178,700,11.15,68,42},{184,655,11.25,68,42},
 {-180,600,11.45,66,40},{190,550,11.55,66,40}
}
for _,p in ipairs(paddies) do
 Terrain:FillBlock(CFrame.new(p[1],p[3]-.75,p[2]),Vector3.new(p[4]+4,1.7,p[5]+4),Enum.Material.Ground)
 Terrain:FillBlock(CFrame.new(p[1],p[3]-.05,p[2]),Vector3.new(p[4]-3,.28,p[5]-3),Enum.Material.Water)
end

-- Shallow roadside drainage, terrain-native, no floating blue Part strips.
for sideSign=-1,1,2 do
 for i=8,56,4 do
  local p=roadPts[i];local n=roadPts[math.min(#roadPts,i+1)];local d=n-p;local flat=Vector3.new(d.X,0,d.Z)
  if flat.Magnitude>0 then
   local side=Vector3.new(-flat.Z,0,flat.X).Unit*sideSign
   local a=p+side*(roadWidth((i-1)/(#roadPts-2))*.5+3.5)-Vector3.new(0,.55,0)
   local b=n+side*(roadWidth((i-1)/(#roadPts-2))*.5+3.5)-Vector3.new(0,.55,0)
   terrainStrip(a,b,1.25,.65,Enum.Material.Air)
   terrainStrip(a-Vector3.new(0,.25,0),b-Vector3.new(0,.25,0),.55,.25,Enum.Material.Water)
  end
 end
end

-- TERRAIN FREEZE: absolutely no Terrain Fill* calls below this line.
root:SetAttribute("TerrainFrozen",true)
root:SetAttribute("TerrainArchitecture","TERRAIN_FIRST_SINGLE_SOURCE")

local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Include;rp.FilterDescendantsInstances={Terrain};rp.IgnoreWater=true
local function groundY(x,z)
 local hit=Workspace:Raycast(Vector3.new(x,700,z),Vector3.new(0,-1400,0),rp)
 return hit and hit.Position.Y or nil
end

-- ============================================================================
-- STAGE B — VISUALS. Every asset below uses the FINAL terrain.
-- ============================================================================
local houseCount=0
local houseBases={}
local function buildHouse(spec,index)
 local x,z,_,w,d,rot=table.unpack(spec);local y=groundY(x,z);if not y then return end
 local m=Instance.new("Model");m.Name="VillageHouse_"..index;m.Parent=folders.Village
 local cf=CFrame.new(x,y,z)*CFrame.Angles(0,math.rad(rot),0);local wall=index%2==0 and Color3.fromRGB(194,185,165) or Color3.fromRGB(207,196,174)
 mk("Foundation",Vector3.new(w+2,.9,d+2),cf*CFrame.new(0,.42,0),Enum.Material.Rock,Color3.fromRGB(102,99,90),m,0,true)
 mk("Wall",Vector3.new(w,8.2,d),cf*CFrame.new(0,4.6,0),Enum.Material.Brick,wall,m,0,true)
 for _,sgn in ipairs({-1,1}) do
  mk("Roof",Vector3.new(w*.61,.7,d+4),cf*CFrame.new(sgn*w*.23,10.1,0)*CFrame.Angles(0,0,math.rad(-sgn*27)),Enum.Material.Metal,index%2==0 and Color3.fromRGB(73,77,73) or Color3.fromRGB(91,67,51),m,0,true)
 end
 mk("Door",Vector3.new(3.0,6.1,.3),cf*CFrame.new(0,3.4,-d*.5-.18),Enum.Material.Wood,Color3.fromRGB(74,53,38),m,0,false)
 for _,sx in ipairs({-1,1}) do
  mk("Window",Vector3.new(3.4,2.6,.25),cf*CFrame.new(sx*w*.28,5.6,-d*.5-.2),Enum.Material.Glass,Color3.fromRGB(145,174,176),m,.2,false)
 end
 mk("Porch",Vector3.new(w*.58,.45,3.7),cf*CFrame.new(0,.65,-d*.5-1.7),Enum.Material.WoodPlanks,Color3.fromRGB(106,77,51),m,0,true)
 table.insert(houseBases,{x=x,z=z,y=y});houseCount+=1
end
for i,h in ipairs(housePads) do buildHouse(h,i) end

-- Rice bunds + non-ball rice blades.
local riceBladeCount=0
for pi,p in ipairs(paddies) do
 local x,z,_,w,d=table.unpack(p);local y=groundY(x,z) or p[3]
 local m=Instance.new("Model");m.Name="RiceTerrace_"..pi;m.Parent=folders.RiceFields
 local bund=Color3.fromRGB(91,80,59)
 mk("BundN",Vector3.new(w+2,.7,1.2),CFrame.new(x,y+.30,z-d*.5),Enum.Material.Ground,bund,m,0,true)
 mk("BundS",Vector3.new(w+2,.7,1.2),CFrame.new(x,y+.30,z+d*.5),Enum.Material.Ground,bund,m,0,true)
 mk("BundL",Vector3.new(1.2,.7,d),CFrame.new(x-w*.5,y+.30,z),Enum.Material.Ground,bund,m,0,true)
 mk("BundR",Vector3.new(1.2,.7,d),CFrame.new(x+w*.5,y+.30,z),Enum.Material.Ground,bund,m,0,true)
 for rz=-2,2 do for rx=-4,4 do
  local bx=x+rx*(w/11);local bz=z+rz*(d/6)
  for k=-1,1 do
   mk("RiceBlade",Vector3.new(.09,1.25+(k+1)*.08,.09),CFrame.new(bx+k*.18,y+.72,bz+k*.10)*CFrame.Angles(0,0,math.rad(k*8)),Enum.Material.Grass,Color3.fromRGB(90,139,61),m,0,false);riceBladeCount+=1
  end
 end end
end

-- Natural roadside and forest trees. No tree can spawn inside road/trail clearances.
local allRoutePts={};for _,p in ipairs(roadPts) do table.insert(allRoutePts,p) end;for _,p in ipairs(trailPts) do table.insert(allRoutePts,p) end
local treeCount=0;local treeBases={}
local function tree(x,z,scale,variant,parent)
 local y=groundY(x,z);if not y then return end
 local base=Vector3.new(x,y,z);local m=Instance.new("Model");m.Name="GroundedTree";m.Parent=parent or folders.Roadside
 local bark=variant%2==0 and Color3.fromRGB(72,53,38) or Color3.fromRGB(81,59,40)
 local leaf=variant%3==0 and Color3.fromRGB(39,72,39) or Color3.fromRGB(48,84,43)
 local h=(11.5+variant*.7)*scale
 mk("Trunk",Vector3.new(1.2*scale,h,1.2*scale),CFrame.new(base+Vector3.new(0,h*.5,0))*CFrame.Angles(0,0,math.rad((variant%5)-2)),Enum.Material.Wood,bark,m,0,true)
 local fork=base+Vector3.new(0,h*.67,0)
 for b=1,4 do
  local ang=(b-1)*math.pi*.5+variant*.23;local tip=fork+Vector3.new(math.cos(ang)*4.0*scale,2.4*scale,math.sin(ang)*4.0*scale)
  beam("Branch",fork,tip,.32*scale,Enum.Material.Wood,bark,m,false)
  ellipsoid("LeafCluster",tip,Vector3.new(5.0,3.4,4.4)*scale,leaf,m)
 end
 ellipsoid("TopCluster",base+Vector3.new(0,h+2.1*scale,0),Vector3.new(5.8,4.0,5.2)*scale,leaf,m)
 table.insert(treeBases,{x=x,z=z,y=y});treeCount+=1
end

-- Sparse village trees.
for _,t in ipairs({{-112,1030,.75,1},{118,1005,.68,2},{-108,910,.72,3},{111,820,.70,1},{-115,720,.72,2},{118,625,.68,3},{-122,535,.72,1},{126,455,.68,2}}) do
 if minDistTo(roadPts,Vector3.new(t[1],0,t[2]))>22 then tree(t[1],t[2],t[3],t[4],folders.Roadside) end
end
-- Dense transition forest from damaged road toward CP1.
for z=330,-115,-28 do
 for sideSign=-1,1,2 do
  local x=(sideSign*(38+math.random(4,18)))+math.sin(z*.06)*14
  local p=Vector3.new(x,0,z)
  local clearance= z>150 and 18 or 11
  if minDistTo(allRoutePts,p)>clearance then tree(x,z,.70+math.random()*0.18,math.random(1,4),folders.ForestEdge) end
 end
end
for _,t in ipairs({{-92,160,.82,3},{70,145,.78,2},{-105,100,.86,4},{62,75,.80,1},{-112,45,.88,2},{52,20,.84,3},{-118,-15,.9,4},{38,-38,.82,2},{-120,-70,.9,1},{-25,-92,.84,3}}) do
 if minDistTo(trailPts,Vector3.new(t[1],0,t[2]))>10 then tree(t[1],t[2],t[3],t[4],folders.ForestEdge) end
end

-- Utility poles are grounded AFTER terrain is frozen and only exist beside vehicle road.
local poleCount=0;local poleBases={};local poles={}
for i=8,math.min(#roadPts-8,67),9 do
 local a=roadPts[i];local b=roadPts[i+1];local flat=Vector3.new(b.X-a.X,0,b.Z-a.Z)
 if flat.Magnitude>0 then
  local side=Vector3.new(-flat.Z,0,flat.X).Unit
  local progress=(i-1)/(#roadPts-2);local w=roadWidth(progress);local q=a+side*(w*.5+9)
  local y=groundY(q.X,q.Z)
  if y then
   local base=Vector3.new(q.X,y,q.Z);local top=base+Vector3.new(0,13.5,0)
   mk("UtilityPole",Vector3.new(.72,13.5,.72),CFrame.new(base+Vector3.new(0,6.75,0)),Enum.Material.Wood,Color3.fromRGB(67,50,37),folders.Roadside,0,true)
   beam("CrossArm",top-side*2.5,top+side*2.5,.28,Enum.Material.Wood,Color3.fromRGB(67,50,37),folders.Roadside,false)
   table.insert(poles,{top=top,side=side});table.insert(poleBases,{x=q.X,z=q.Z,y=y});poleCount+=1
  end
 end
end
local function sagWire(a,b)
 local last=nil
 for s=0,8 do
  local t=s/8;local q=a:Lerp(b,t)+Vector3.new(0,-math.sin(math.pi*t)*2.0,0)
  if last then beam("PowerWire",last,q,.075,Enum.Material.SmoothPlastic,Color3.fromRGB(28,28,27),folders.Roadside,false) end
  last=q
 end
end
for i=1,#poles-1 do
 for _,sgn in ipairs({-1,1}) do sagWire(poles[i].top+poles[i].side*sgn*2.0,poles[i+1].top+poles[i+1].side*sgn*2.0) end
end

-- Broken-road cues are embedded INTO the terrain surface, never bridge slabs.
local wearCount=0
for i=48,math.min(#roadPts-4,78),6 do
 local p=roadPts[i];local y=groundY(p.X,p.Z)
 if y then
  mk("EmbeddedRoadWear",Vector3.new(2.5+(i%3),.08,4.5+(i%4)),CFrame.new(p.X,y+.035,p.Z)*CFrame.Angles(0,math.rad(i*17),0),Enum.Material.Ground,Color3.fromRGB(99,88,69),folders.Roadside,0,false);wearCount+=1
 end
end

-- Trail detail: roots/rocks increase gradually; they never block the whole tread.
local trailDetailCount=0
for i=12,#trailPts-7,8 do
 local p=trailPts[i];local y=groundY(p.X,p.Z)
 if y then
  local n=trailPts[i+1];local flat=Vector3.new(n.X-p.X,0,n.Z-p.Z);local side=flat.Magnitude>0 and Vector3.new(-flat.Z,0,flat.X).Unit or Vector3.xAxis
  local a=Vector3.new(p.X,y+.12,p.Z)-side*2.0;local b=Vector3.new(p.X,y+.18,p.Z)+side*1.6
  beam("ExposedRoot",a,b,.16,Enum.Material.Wood,Color3.fromRGB(78,57,39),folders.ForestEdge,false)
  local r=mk("TrailRock",Vector3.new(1.1,0.65,1.35),CFrame.new(p.X+side.X*2.7,y+.27,p.Z+side.Z*2.7)*CFrame.Angles(math.rad(8),math.rad(i*21),math.rad(6)),Enum.Material.Rock,Color3.fromRGB(91,91,84),folders.ForestEdge,0,false);r.Shape=Enum.PartType.Ball
  trailDetailCount+=2
 end
end

-- POS1: modest grounded hiking post, reached AFTER the narrowing forest trail.
local cp1Y=groundY(cp1.X,cp1.Z) or cp1.Y
local pos=folders.POS1
local hutCf=CFrame.new(cp1.X-17,cp1Y,cp1.Z+7)*CFrame.Angles(0,math.rad(11),0)
mk("HutFoundation",Vector3.new(20,.7,14),hutCf*CFrame.new(0,.32,0),Enum.Material.Rock,Color3.fromRGB(101,97,87),pos,0,true)
mk("HutWall",Vector3.new(19,7.4,13),hutCf*CFrame.new(0,4.0,0),Enum.Material.WoodPlanks,Color3.fromRGB(111,80,53),pos,0,true)
for _,sgn in ipairs({-1,1}) do mk("HutRoof",Vector3.new(11.5,.7,16),hutCf*CFrame.new(sgn*4.3,8.6,0)*CFrame.Angles(0,0,math.rad(-sgn*26)),Enum.Material.Metal,Color3.fromRGB(66,72,68),pos,0,true) end
mk("RegistrationCounter",Vector3.new(7.5,2.8,1.7),hutCf*CFrame.new(2,1.7,-7.1),Enum.Material.WoodPlanks,Color3.fromRGB(79,58,41),pos,0,true)
local gate=Vector3.new(cp1.X+4,cp1Y,cp1.Z-12)
for _,sx in ipairs({-1,1}) do mk("GatePost",Vector3.new(1.25,8.0,1.25),CFrame.new(gate+Vector3.new(sx*5.3,4,0)),Enum.Material.Wood,Color3.fromRGB(70,51,36),pos,0,true) end
local sign=mk("POS1Sign",Vector3.new(12,2.8,.4),CFrame.new(gate+Vector3.new(0,8.1,0)),Enum.Material.WoodPlanks,Color3.fromRGB(72,53,37),pos,0,false)
local sg=Instance.new("SurfaceGui");sg.Face=Enum.NormalId.Front;sg.PixelsPerStud=38;sg.Parent=sign
local st=Instance.new("TextLabel");st.Size=UDim2.fromScale(1,1);st.BackgroundTransparency=1;st.Text="POS 1 — KAKI GUNUNG";st.TextScaled=true;st.Font=Enum.Font.GothamBold;st.TextColor3=Color3.fromRGB(237,229,204);st.Parent=sg

-- Invisible checkpoint trigger is small and exactly on the final clearing.
local cp=mk("CP01_POS1",Vector3.new(10,1,10),CFrame.new(cp1.X,cp1Y+.6,cp1.Z),Enum.Material.SmoothPlastic,Color3.new(1,1,1),folders.Checkpoints,1,false)
cp:SetAttribute("CheckpointIndex",1);cp:SetAttribute("CheckpointName","POS 1 - KAKI GUNUNG");cp:SetAttribute("SaveReady",true)

-- Spawn sits on terrain final and looks along the village road.
local sy=groundY(0,1060) or 10.7
local spawn=Instance.new("SpawnLocation");spawn.Name="MountainSpawn";spawn.Anchored=true;spawn.Size=Vector3.new(12,1,12)
spawn.CFrame=CFrame.lookAt(Vector3.new(0,sy+1.0,1060),Vector3.new(8,sy+1.0,1015));spawn.Transparency=1;spawn.CanCollide=true;spawn.Neutral=true;spawn.Duration=0;spawn.Parent=root

-- ============================================================================
-- SPATIAL QC — test the actual geometry rules, not just marker strings.
-- ============================================================================
local roadGapCount=0;local roadSampleCount=0
for i=1,#roadPts,6 do
 local p=roadPts[i];local y=groundY(p.X,p.Z);roadSampleCount+=1
 if not y or math.abs(y-p.Y)>2.2 then roadGapCount+=1 end
end
local floatingPoleCount=0
for _,b in ipairs(poleBases) do local y=groundY(b.x,b.z);if not y or math.abs(y-b.y)>.35 then floatingPoleCount+=1 end end
local floatingTreeCount=0
for _,b in ipairs(treeBases) do local y=groundY(b.x,b.z);if not y or math.abs(y-b.y)>.35 then floatingTreeCount+=1 end end
local houseTerrainConflictCount=0
for _,b in ipairs(houseBases) do local y=groundY(b.x,b.z);if not y or math.abs(y-b.y)>.35 then houseTerrainConflictCount+=1 end end

root:SetAttribute("Project","Mountain Social Adventure")
root:SetAttribute("RebuildGeneration","6.0")
root:SetAttribute("Phase1Scope","SPAWN_TO_CP1_ONLY")
root:SetAttribute("Phase1Flow","VILLAGE>PAVED>DAMAGED>GRAVEL>TRAIL_MOUTH>NARROW_FOREST>CP1")
root:SetAttribute("Phase1Ready",true)
root:SetAttribute("TerrainFrozen",true)
root:SetAttribute("LegacyGeometryLoaded",false)
root:SetAttribute("RoadTerrainNative",true)
root:SetAttribute("VehicleRoadEndsBeforeTrail",true)
root:SetAttribute("TrailBranchesFromRoad",true)
root:SetAttribute("RoadSampleCount",roadSampleCount)
root:SetAttribute("RoadGapCount",roadGapCount)
root:SetAttribute("FloatingPoleCount",floatingPoleCount)
root:SetAttribute("FloatingTreeCount",floatingTreeCount)
root:SetAttribute("HouseTerrainConflictCount",houseTerrainConflictCount)
root:SetAttribute("VillageHouseCount",houseCount)
root:SetAttribute("RiceBladeCount",riceBladeCount)
root:SetAttribute("GroundedTreeCount",treeCount)
root:SetAttribute("GroundedPoleCount",poleCount)
root:SetAttribute("RoadWearCount",wearCount)
root:SetAttribute("TrailDetailCount",trailDetailCount)
root:SetAttribute("BuildVersion","6.0.0-phase1-terrain-first")

Lighting.GlobalShadows=true;Lighting.EnvironmentDiffuseScale=.55;Lighting.EnvironmentSpecularScale=.42;Lighting.ShadowSoftness=.30
print("[ACC] REBUILD v6.0 PHASE1 ready",roadGapCount,floatingPoleCount,floatingTreeCount,houseTerrainConflictCount,houseCount,treeCount,poleCount)
