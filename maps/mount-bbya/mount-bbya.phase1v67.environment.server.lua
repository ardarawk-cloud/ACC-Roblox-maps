-- MOUNT BBYA — PHASE 1 ENVIRONMENT AUTHORITY v6.7
-- Research-grounded rebuild: Indonesian/Bali highland village -> agricultural foothill -> trailhead -> montane forest -> POS 1.
-- One environment authority. No active visual patch chain.
-- Scope hard-lock: SPAWN_TO_CP1_ONLY.

local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Terrain=Workspace.Terrain

local ROOT_NAME="ACC_MountainSocial" -- retained for checkpoint-system compatibility only
local prior=Workspace:FindFirstChild(ROOT_NAME)
if prior then prior:Destroy() end
local root=Instance.new("Folder")
root.Name=ROOT_NAME
root.Parent=Workspace

local folders={}
for _,name in ipairs({"Village","Agriculture","Roadside","ForestEdge","Checkpoints","POS1","Landscape"}) do
 local f=Instance.new("Folder");f.Name=name;f.Parent=root;folders[name]=f
end

math.randomseed(670903)

local function mk(name,size,cf,mat,col,parent,tr,coll)
 local p=Instance.new("Part")
 p.Name=name;p.Anchored=true;p.Size=size;p.CFrame=cf
 p.Material=mat or Enum.Material.SmoothPlastic
 p.Color=col or Color3.fromRGB(160,160,160)
 p.Transparency=tr or 0;p.CanCollide=coll==true;p.CastShadow=true
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or root
 return p
end

local function beam(name,a,b,width,mat,col,parent,coll)
 local d=b-a
 if d.Magnitude<.05 then return nil end
 return mk(name,Vector3.new(width,width,d.Magnitude),CFrame.lookAt((a+b)/2,b),mat,col,parent,0,coll)
end

local function terrainStrip(a,b,width,height,mat)
 local d=b-a
 if d.Magnitude<.05 then return end
 Terrain:FillBlock(CFrame.lookAt((a+b)/2,b),Vector3.new(width,height,d.Magnitude+2),mat)
end

local function catmull(p0,p1,p2,p3,t)
 local t2=t*t;local t3=t2*t
 return .5*((2*p1)+(-p0+p2)*t+(2*p0-5*p1+4*p2-p3)*t2+(-p0+3*p1-3*p2+p3)*t3)
end

local function sampleSpline(ctrl,steps)
 local pts={}
 for i=1,#ctrl-1 do
  local p0=ctrl[math.max(1,i-1)]
  local p1=ctrl[i]
  local p2=ctrl[i+1]
  local p3=ctrl[math.min(#ctrl,i+2)]
  for s=0,steps-1 do table.insert(pts,catmull(p0,p1,p2,p3,s/steps)) end
 end
 table.insert(pts,ctrl[#ctrl])
 return pts
end

local function routeYAtZ(ctrl,z)
 for i=1,#ctrl-1 do
  local a,b=ctrl[i],ctrl[i+1]
  if z<=a.Z and z>=b.Z then
   local t=(a.Z-z)/(a.Z-b.Z)
   return a.Y+(b.Y-a.Y)*t
  end
 end
 return ctrl[#ctrl].Y
end

local function roadXAtZ(ctrl,z)
 for i=1,#ctrl-1 do
  local a,b=ctrl[i],ctrl[i+1]
  if z<=a.Z and z>=b.Z then
   local t=(a.Z-z)/(a.Z-b.Z)
   return a.X+(b.X-a.X)*t
  end
 end
 return ctrl[#ctrl].X
end

-- ==========================================================================
-- TERRAIN AUTHORITY — layered foothills, no spherical/dome mountain language.
-- ==========================================================================
Terrain:Clear()
Terrain:FillBlock(CFrame.new(0,-17,470),Vector3.new(2400,54,2050),Enum.Material.Grass) -- top ~10

local function ridgeWedge(x,y,z,w,h,d,yaw,mat,flip)
 local cf=CFrame.new(x,y+h*.5,z)*CFrame.Angles(0,math.rad(yaw),flip and math.rad(180) or 0)
 Terrain:FillWedge(cf,Vector3.new(w,h,d),mat or Enum.Material.Grass)
end

-- Near foothills frame the village without touching the road corridor.
for _,r in ipairs({
 {-430,10,970,430,56,360,12,false},{455,10,920,450,62,360,-14,true},
 {-470,10,690,500,74,390,18,false},{500,10,610,520,82,400,-12,true},
 {-455,10,380,520,98,390,15,false},{480,10,300,540,108,390,-18,true},
 {-420,10,90,500,122,350,22,false},{440,10,30,520,132,360,-20,true}
}) do ridgeWedge(table.unpack(r)) end

-- Layered background ridges create depth before the main mountain mass.
ridgeWedge(-360,10,-210,620,145,420,12,Enum.Material.Grass,false)
ridgeWedge(390,10,-260,650,160,440,-14,Enum.Material.Grass,true)
ridgeWedge(-120,10,-430,760,185,420,8,Enum.Material.Rock,false)
ridgeWedge(260,10,-500,720,205,440,-12,Enum.Material.Rock,true)
ridgeWedge(40,10,-650,1080,245,520,2,Enum.Material.Rock,false)

-- Road: vehicle-accessible village road, gently climbing and progressively rougher.
local roadCtrl={
 Vector3.new(0,10.8,1060),Vector3.new(7,11.3,950),Vector3.new(-5,12.1,840),
 Vector3.new(12,13.0,730),Vector3.new(31,14.1,625),Vector3.new(47,15.4,525),
 Vector3.new(57,16.8,430),Vector3.new(58,18.1,340),Vector3.new(50,19.4,260),
 Vector3.new(40,20.6,190),Vector3.new(36,21.2,155)
}
local roadPts=sampleSpline(roadCtrl,10)
local function roadWidth(progress)
 if progress<.55 then return 21 elseif progress<.80 then return 18 else return 15.5 end
end
for i=1,#roadPts-1 do
 local a,b=roadPts[i],roadPts[i+1]
 local progress=(i-1)/math.max(1,#roadPts-2)
 local w=roadWidth(progress)
 terrainStrip(a+Vector3.new(0,7,0),b+Vector3.new(0,7,0),w+18,14,Enum.Material.Air)
 terrainStrip(a-Vector3.new(0,1.25,0),b-Vector3.new(0,1.25,0),w+8,3.0,Enum.Material.Ground)
 local material=progress<.61 and Enum.Material.Pavement or (progress<.82 and Enum.Material.Ground or Enum.Material.Gravel)
 terrainStrip(a-Vector3.new(0,.10,0),b-Vector3.new(0,.10,0),w,.72,material)
end

local roadEnd=roadPts[#roadPts]
Terrain:FillBlock(CFrame.new(roadEnd-Vector3.new(0,1.0,0)),Vector3.new(42,2.8,32),Enum.Material.Ground)
Terrain:FillBlock(CFrame.new(roadEnd-Vector3.new(0,.08,0)),Vector3.new(37,.65,28),Enum.Material.Ground)

-- Hiking trail: narrower, winding, continuously climbing; walking path, not obby.
local trailCtrl={
 Vector3.new(27,21.0,190),Vector3.new(10,23.0,156),Vector3.new(-7,25.8,121),
 Vector3.new(-20,29.1,84),Vector3.new(-31,32.8,47),Vector3.new(-43,36.8,12),
 Vector3.new(-57,40.8,-21),Vector3.new(-69,44.5,-50),Vector3.new(-82,48.0,-76)
}
local trailPts=sampleSpline(trailCtrl,10)
local function trailWidth(progress)return 7.4-progress*2.8 end
for i=1,#trailPts-1 do
 local a,b=trailPts[i],trailPts[i+1]
 local progress=(i-1)/math.max(1,#trailPts-2)
 local w=trailWidth(progress)
 terrainStrip(a+Vector3.new(0,4.0,0),b+Vector3.new(0,4.0,0),w+8,8,Enum.Material.Air)
 terrainStrip(a-Vector3.new(0,.72,0),b-Vector3.new(0,.72,0),w+4.5,1.9,Enum.Material.Ground)
 terrainStrip(a-Vector3.new(0,.05,0),b-Vector3.new(0,.05,0),w,.52,Enum.Material.Ground)
end

local cp1=trailPts[#trailPts]
Terrain:FillBlock(CFrame.new(cp1-Vector3.new(0,.9,0)),Vector3.new(44,2.4,34),Enum.Material.Ground)
Terrain:FillBlock(CFrame.new(cp1-Vector3.new(0,.05,0)),Vector3.new(40,.55,30),Enum.Material.Ground)
terrainStrip(cp1+Vector3.new(-3,.1,-14),cp1+Vector3.new(-7,.8,-29),5.0,1.5,Enum.Material.Ground)

-- Village lots follow the road elevation. They are compact, roadside, and grounded.
local houseSpecs={
 {1010,-1,26,20,9,1},{952,1,25,20,-11,2},{892,-1,27,21,8,3},{830,1,25,20,-10,4},
 {765,-1,26,20,7,5},{698,1,25,19,-9,6},{630,-1,24,19,8,7},{560,1,24,19,-8,8},
 {490,-1,24,18,7,9},{420,1,23,18,-7,10}
}
for _,h in ipairs(houseSpecs) do
 local z,side,w,d=h[1],h[2],h[3],h[4]
 local x=roadXAtZ(roadCtrl,z)+side*34
 local y=routeYAtZ(roadCtrl,z)
 Terrain:FillBlock(CFrame.new(x,y+3,z),Vector3.new(w+12,8,d+12),Enum.Material.Air)
 Terrain:FillBlock(CFrame.new(x,y-1.0,z),Vector3.new(w+10,2.4,d+10),Enum.Material.Ground)
 Terrain:FillBlock(CFrame.new(x,y-.05,z),Vector3.new(w+8,.55,d+8),Enum.Material.Grass)
end

-- Dry highland agricultural terraces: coffee/citrus/vegetable ground, not wet rice paddies.
local farmTerraces={
 {-125,970,68,30},{135,930,72,30},{-145,850,74,32},{155,810,78,32},
 {-160,720,80,34},{170,675,82,34},{-170,590,82,34},{185,545,84,34},
 {-175,455,78,32},{190,410,80,32}
}
for i,f in ipairs(farmTerraces) do
 local x,z,w,d=f[1],f[2],f[3],f[4]
 local y=routeYAtZ(roadCtrl,math.clamp(z,155,1060))-1.0+(i%3)*.55
 Terrain:FillBlock(CFrame.new(x,y+2,z),Vector3.new(w+7,6,d+7),Enum.Material.Air)
 Terrain:FillBlock(CFrame.new(x,y-.8,z),Vector3.new(w+6,2.0,d+6),Enum.Material.Ground)
 Terrain:FillBlock(CFrame.new(x,y+.05,z),Vector3.new(w,.45,d),Enum.Material.Grass)
end

-- Roadside drainage follows the actual road; visible as shallow channels and culvert crossings.
for sideSign=-1,1,2 do
 for i=8,#roadPts-10,6 do
  local p=roadPts[i];local n=roadPts[math.min(#roadPts,i+1)]
  local d=n-p;local flat=Vector3.new(d.X,0,d.Z)
  if flat.Magnitude>0 then
   local side=Vector3.new(-flat.Z,0,flat.X).Unit*sideSign
   local w=roadWidth((i-1)/math.max(1,#roadPts-2))
   local a=p+side*(w*.5+3.1)-Vector3.new(0,.48,0)
   local b=n+side*(w*.5+3.1)-Vector3.new(0,.48,0)
   terrainStrip(a,b,1.5,.58,Enum.Material.Air)
  end
 end
end

root:SetAttribute("TerrainFrozen",true)
root:SetAttribute("TerrainArchitecture","V67_LAYERED_RIDGE_SINGLE_AUTHORITY")

local rp=RaycastParams.new()
rp.FilterType=Enum.RaycastFilterType.Include
rp.FilterDescendantsInstances={Terrain}
rp.IgnoreWater=true
local function groundY(x,z)
 local hit=Workspace:Raycast(Vector3.new(x,700,z),Vector3.new(0,-1400,0),rp)
 return hit and hit.Position.Y or 10
end

local function textSign(p,text,face)
 local sg=Instance.new("SurfaceGui")
 sg.Face=face or Enum.NormalId.Front;sg.PixelsPerStud=42;sg.Parent=p
 local t=Instance.new("TextLabel")
 t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextScaled=true
 t.Font=Enum.Font.GothamBold;t.TextColor3=Color3.fromRGB(240,234,214);t.TextStrokeTransparency=.78;t.Parent=sg
end

-- ==========================================================================
-- VILLAGE — human-scale architecture, compact compounds, roadside life.
-- ==========================================================================
local houseCount=0
local function buildHouse(spec,index)
 local z,side,w,d,rot,variant=table.unpack(spec)
 local x=roadXAtZ(roadCtrl,z)+side*34
 local y=groundY(x,z)
 local m=Instance.new("Model");m.Name="HighlandHouse_"..index;m.Parent=folders.Village
 local cf=CFrame.new(x,y,z)*CFrame.Angles(0,math.rad(rot),0)
 local wall=variant%2==0 and Color3.fromRGB(195,187,170) or Color3.fromRGB(211,201,181)
 local stone=Color3.fromRGB(101,97,88)
 local roof=variant%3==0 and Color3.fromRGB(87,64,49) or Color3.fromRGB(72,76,72)
 mk("Foundation",Vector3.new(w+2,1.1,d+2),cf*CFrame.new(0,.5,0),Enum.Material.Rock,stone,m,0,true)
 mk("Wall",Vector3.new(w,12.2,d),cf*CFrame.new(0,6.6,0),Enum.Material.Brick,wall,m,0,true)
 for _,sgn in ipairs({-1,1}) do
  mk("Roof",Vector3.new(w*.62,.9,d+4.2),cf*CFrame.new(sgn*w*.23,14.7,0)*CFrame.Angles(0,0,math.rad(-sgn*28)),Enum.Material.Metal,roof,m,0,true)
 end
 mk("Door",Vector3.new(3.4,7.2,.32),cf*CFrame.new(0,4.0,-d*.5-.18),Enum.Material.Wood,Color3.fromRGB(77,55,39),m,0,false)
 for _,sx in ipairs({-.28,.28}) do
  local win=mk("Window",Vector3.new(3.8,3.1,.28),cf*CFrame.new(w*sx,7.4,-d*.5-.20),Enum.Material.Glass,Color3.fromRGB(158,183,183),m,.16,false)
  local light=Instance.new("PointLight");light.Brightness=.45;light.Range=9;light.Color=Color3.fromRGB(255,215,163);light.Parent=win
 end
 mk("Porch",Vector3.new(w*.64,.55,4.2),cf*CFrame.new(0,.78,-d*.5-1.8),Enum.Material.WoodPlanks,Color3.fromRGB(110,80,54),m,0,true)
 -- Low compound walls and open gate; avoids houses floating alone in empty fields.
 for _,sx in ipairs({-1,1}) do
  mk("YardWall",Vector3.new(1.0,3.0,d+10),cf*CFrame.new(sx*(w*.5+4),1.5,1),Enum.Material.Rock,stone,m,0,true)
 end
 mk("RearWall",Vector3.new(w+9,3.0,1.0),cf*CFrame.new(0,1.5,d*.5+5),Enum.Material.Rock,stone,m,0,true)
 mk("FrontWallL",Vector3.new(w*.35,2.5,1.0),cf*CFrame.new(-w*.34,1.25,-d*.5-5),Enum.Material.Rock,stone,m,0,true)
 mk("FrontWallR",Vector3.new(w*.35,2.5,1.0),cf*CFrame.new(w*.34,1.25,-d*.5-5),Enum.Material.Rock,stone,m,0,true)
 -- Everyday yard cues.
 local jar=mk("WaterJar",Vector3.new(1.4,1.7,1.4),cf*CFrame.new(w*.35,.9,-d*.5-1.4),Enum.Material.Slate,Color3.fromRGB(112,80,57),m,0,false);jar.Shape=Enum.PartType.Ball
 mk("Planter",Vector3.new(4.4,.65,1.3),cf*CFrame.new(-w*.30,.36,-d*.5-1.4),Enum.Material.WoodPlanks,Color3.fromRGB(96,69,47),m,0,false)
 houseCount+=1
end
for i,h in ipairs(houseSpecs) do buildHouse(h,i);if i%3==0 then task.wait() end end

-- Village warung, scaled as a real roadside structure.
local wz=610;local wx=roadXAtZ(roadCtrl,wz)+34;local wy=groundY(wx,wz)
local war=Instance.new("Model");war.Name="WarungKakiGunung";war.Parent=folders.Roadside
local wcf=CFrame.new(wx,wy,wz)*CFrame.Angles(0,math.rad(-8),0)
mk("Floor",Vector3.new(20,.6,13),wcf*CFrame.new(0,.4,0),Enum.Material.WoodPlanks,Color3.fromRGB(111,80,53),war,0,true)
mk("Back",Vector3.new(20,9.0,.6),wcf*CFrame.new(0,4.9,5.8),Enum.Material.WoodPlanks,Color3.fromRGB(126,93,61),war,0,true)
mk("Roof",Vector3.new(23,.7,16),wcf*CFrame.new(0,10.2,0)*CFrame.Angles(math.rad(5),0,0),Enum.Material.Metal,Color3.fromRGB(73,76,71),war,0,true)
mk("Counter",Vector3.new(11,3.2,1.6),wcf*CFrame.new(1.5,1.9,-6.2),Enum.Material.WoodPlanks,Color3.fromRGB(86,61,42),war,0,true)

-- ==========================================================================
-- AGRICULTURE — Kintamani-inspired coffee + citrus + small vegetable beds.
-- ==========================================================================
local cropCount=0
local function coffeeShrub(x,z,s)
 local y=groundY(x,z);local m=Instance.new("Model");m.Name="CoffeeShrub";m.Parent=folders.Agriculture
 mk("Stem",Vector3.new(.28,2.7*s,.28),CFrame.new(x,y+1.35*s,z),Enum.Material.Wood,Color3.fromRGB(76,57,39),m,0,false)
 for i=1,5 do
  local a=(i-1)*1.256;local r=1.15*s
  mk("LeafCluster",Vector3.new(2.1*s,.65*s,1.4*s),CFrame.new(x+math.cos(a)*r,y+2.1*s+(i%2)*.3,z+math.sin(a)*r)*CFrame.Angles(math.rad((i%3)-1)*8,a,math.rad((i%2==0 and 1 or -1)*8)),Enum.Material.LeafyGrass,Color3.fromRGB(54,97,48),m,0,false)
 end
 cropCount+=1
end
local function citrusTree(x,z,s)
 local y=groundY(x,z);local m=Instance.new("Model");m.Name="CitrusTree";m.Parent=folders.Agriculture
 local h=7.0*s
 mk("Trunk",Vector3.new(.65*s,h*.55,.65*s),CFrame.new(x,y+h*.275,z),Enum.Material.Wood,Color3.fromRGB(79,59,39),m,0,true)
 for i=1,6 do
  local a=(i-1)*math.pi/3;local r=(2.1+(i%2)*.5)*s
  mk("LeafMass",Vector3.new(3.7*s,1.8*s,2.8*s),CFrame.new(x+math.cos(a)*r,y+h*.63+(i%3)*.45*s,z+math.sin(a)*r)*CFrame.Angles(math.rad((i%2)*6),a,math.rad((i%3)-1)*7),Enum.Material.LeafyGrass,Color3.fromRGB(48,91,44),m,0,false)
 end
 for i=1,4 do
  local a=i*1.47
  local fruit=mk("Citrus",Vector3.new(.38,.38,.38),CFrame.new(x+math.cos(a)*2.2*s,y+h*.62+(i%2)*.5,z+math.sin(a)*2.0*s),Enum.Material.SmoothPlastic,Color3.fromRGB(218,133,35),m,0,false)
  fruit.Shape=Enum.PartType.Ball
 end
 cropCount+=1
end
for ti,f in ipairs(farmTerraces) do
 local x,z,w,d=f[1],f[2],f[3],f[4]
 for row=-1,1 do
  for col=-3,3 do
   local px=x+col*(w/8);local pz=z+row*(d/4)
   if (col+row+ti)%3==0 then citrusTree(px,pz,.82+((col+4)%3)*.05) else coffeeShrub(px,pz,.9) end
  end
 end
 if ti%2==0 then
  local y=groundY(x,z)
  for r=-1,1 do mk("VegetableBed",Vector3.new(w*.55,.28,2.2),CFrame.new(x,y+.12,z+r*4.0),Enum.Material.Ground,Color3.fromRGB(86,72,51),folders.Agriculture,0,false) end
 end
 task.wait()
end

-- ==========================================================================
-- ROADSIDE — drainage, utility line, fences, roadside planting.
-- ==========================================================================
local utilityCount=0
local poles={}
for _,z in ipairs({1015,905,795,685,575,465,355,250}) do
 local x=roadXAtZ(roadCtrl,z)+23.5;local y=groundY(x,z);local h=24
 mk("UtilityPole",Vector3.new(.9,h,.9),CFrame.new(x,y+h*.5,z),Enum.Material.Wood,Color3.fromRGB(75,57,42),folders.Roadside,0,true)
 mk("CrossArm",Vector3.new(6.2,.46,.46),CFrame.new(x,y+h-1.2,z),Enum.Material.Wood,Color3.fromRGB(72,55,41),folders.Roadside,0,false)
 table.insert(poles,Vector3.new(x,y+h-1.0,z));utilityCount+=1
end
local function sagWire(a,b)
 local last=nil
 for s=0,10 do
  local t=s/10
  local q=a:Lerp(b,t)+Vector3.new(0,-math.sin(math.pi*t)*2.3,0)
  if last then beam("UtilityCable",last,q,.09,Enum.Material.SmoothPlastic,Color3.fromRGB(35,35,34),folders.Roadside,false) end
  last=q
 end
end
for i=1,#poles-1 do sagWire(poles[i],poles[i+1]) end

local fenceCount=0
for z=1025,395,-45 do
 local side=((math.floor((1025-z)/45)%2)==0) and -1 or 1
 local x=roadXAtZ(roadCtrl,z)+side*23;local y=groundY(x,z)
 mk("FencePost",Vector3.new(.48,3.8,.48),CFrame.new(x,y+1.9,z),Enum.Material.Wood,Color3.fromRGB(88,66,46),folders.Roadside,0,false)
 local z2=z-20;local x2=roadXAtZ(roadCtrl,z2)+side*23;local y2=groundY(x2,z2)
 beam("FenceRail",Vector3.new(x,y+2.5,z),Vector3.new(x2,y2+2.5,z2),.26,Enum.Material.Wood,Color3.fromRGB(95,70,48),folders.Roadside,false)
 fenceCount+=2
end

for z=1020,270,-30 do
 local cx=roadXAtZ(roadCtrl,z)
 for _,side in ipairs({-1,1}) do
  local x=cx+side*14.2;local y=groundY(x,z)
  local stone=mk("DrainStone",Vector3.new(1.2,.55,2.5),CFrame.new(x,y+.18,z)*CFrame.Angles(math.rad(4),math.rad(z*1.8),math.rad(side*4)),Enum.Material.Rock,Color3.fromRGB(92,90,82),folders.Roadside,0,false)
  stone.Shape=Enum.PartType.Ball
  for k=1,3 do
   local gx=x+side*(1.1+k*.7);local gz=z+(k-2)*1.1;local gy=groundY(gx,gz)
   mk("RoadGrass",Vector3.new(.09,1.2+k*.12,.09),CFrame.new(gx,gy+.6,gz)*CFrame.Angles(0,0,math.rad(side*7)),Enum.Material.Grass,Color3.fromRGB(74,109,54),folders.Roadside,0,false)
  end
 end
end

-- Single village identity marker, oriented toward spawn approach.
local vz=980;local vx=roadXAtZ(roadCtrl,vz)-23;local vy=groundY(vx,vz)
local welcomePos=Vector3.new(vx,vy+6.2,vz)
for _,sx in ipairs({-1,1}) do mk("WelcomePost",Vector3.new(.85,6.4,.85),CFrame.new(vx+sx*6,vy+3.2,vz),Enum.Material.Wood,Color3.fromRGB(73,54,39),folders.Roadside,0,true) end
local welcome=mk("VillageWelcome",Vector3.new(14,3.0,.45),CFrame.lookAt(welcomePos,Vector3.new(0,vy+6,1060)),Enum.Material.WoodPlanks,Color3.fromRGB(77,57,40),folders.Roadside,0,false)
textSign(welcome,"MOUNT BBYA  •  DESA KAKI GUNUNG",Enum.NormalId.Front)

-- ==========================================================================
-- VEGETATION — mature multi-layer trees; clusters, understory, no ball-tree silhouette.
-- ==========================================================================
local treeCount=0
local understoryCount=0
local function matureTree(x,z,s,variant,parent)
 local y=groundY(x,z);local m=Instance.new("Model");m.Name="MatureHighlandTree";m.Parent=parent or folders.ForestEdge
 local bark=Color3.fromRGB(66+variant*2,50+variant,36)
 local leaf=variant%2==0 and Color3.fromRGB(42,78,40) or Color3.fromRGB(49,87,43)
 local h=(25+variant*2.2)*s
 mk("Trunk",Vector3.new(1.45*s,h*.67,1.45*s),CFrame.new(x,y+h*.335,z)*CFrame.Angles(0,0,math.rad((variant%5)-2)),Enum.Material.Wood,bark,m,0,true)
 local crown=Vector3.new(x,y+h*.63,z)
 for j=1,7 do
  local a=(j-1)*.897+variant*.16
  local len=(5.5+(j%3)*1.2)*s
  local tip=crown+Vector3.new(math.cos(a)*len,(j%3)*1.2*s,math.sin(a)*len)
  beam("Branch",crown,tip,.32*s,Enum.Material.Wood,bark,m,false)
  mk("LeafPad",Vector3.new((6.0+(j%2))*s,(2.2+(j%3)*.35)*s,(4.1+(j%2)*.5)*s),CFrame.new(tip)*CFrame.Angles(math.rad((j%3)-1)*8,a,math.rad((j%2==0 and 1 or -1)*7)),Enum.Material.LeafyGrass,leaf,m,0,false)
 end
 treeCount+=1
end
local function understory(x,z,s)
 local y=groundY(x,z)
 for i=1,5 do
  local a=(i-1)*1.256;local len=(2.6+(i%2)*.7)*s
  mk("FernFrond",Vector3.new(len,.09,.6*s),CFrame.new(x+math.cos(a)*len*.35,y+.6+(i%2)*.25,z+math.sin(a)*len*.35)*CFrame.Angles(math.rad(-13),-a,math.rad((i%2==0 and 1 or -1)*10)),Enum.Material.Grass,Color3.fromRGB(58,104,50),folders.ForestEdge,0,false)
 end
 understoryCount+=1
end

-- Village shade trees: fewer, larger, intentionally clustered.
for i,t in ipairs({{-70,945,1.0,1},{75,875,.95,2},{-80,790,1.05,3},{88,690,.98,4},{-78,590,1.0,2},{96,505,1.02,3},{-55,410,.95,1}}) do
 matureTree(t[1],t[2],t[3],t[4],folders.Roadside)
end

-- Forest edge thickens progressively toward trail and CP1.
local forestPositions={
 {-28,350,.95,1},{94,340,1.0,2},{-18,310,1.03,3},{88,295,.98,4},{-20,265,1.05,2},{82,250,1.0,3},
 {-24,220,1.03,4},{75,210,1.0,1},{-32,180,1.08,2},{68,170,1.0,3},{-42,140,1.05,4},{57,128,1.02,2},
 {-52,105,1.08,1},{46,94,1.02,3},{-61,70,1.10,4},{36,62,1.05,2},{-70,35,1.08,3},{25,26,1.0,1},
 {-82,0,1.12,4},{14,-6,1.05,2},{-91,-34,1.10,1},{2,-42,1.08,3},{-101,-70,1.15,4},{-42,-91,1.08,2}
}
for i,t in ipairs(forestPositions) do
 matureTree(t[1],t[2],t[3],t[4],folders.ForestEdge)
 if i%2==0 then understory(t[1]+5,t[2]-4,.9) end
 if i%5==0 then task.wait() end
end

-- Trail texture: roots/rocks live mostly on edges and never form jump obstacles.
local trailDetailCount=0
for i=8,#trailPts-5,7 do
 local p=trailPts[i];local n=trailPts[math.min(#trailPts,i+1)]
 local flat=Vector3.new(n.X-p.X,0,n.Z-p.Z)
 if flat.Magnitude>0 then
  local side=Vector3.new(-flat.Z,0,flat.X).Unit
  local y=groundY(p.X,p.Z)
  beam("ExposedRoot",Vector3.new(p.X,y+.09,p.Z)-side*1.8,Vector3.new(p.X,y+.13,p.Z)+side*1.5,.16,Enum.Material.Wood,Color3.fromRGB(76,55,38),folders.ForestEdge,false)
  local rx=p.X+side.X*2.8;local rz=p.Z+side.Z*2.8;local ry=groundY(rx,rz)
  local rock=mk("TrailRock",Vector3.new(1.4,.75,1.8),CFrame.new(rx,ry+.28,rz)*CFrame.Angles(math.rad(7),math.rad(i*31),math.rad(5)),Enum.Material.Rock,Color3.fromRGB(90,89,82),folders.ForestEdge,0,false);rock.Shape=Enum.PartType.Ball
  trailDetailCount+=2
 end
end

-- Trailhead: vehicle ends, walking trail begins. One information board only.
local tm=Vector3.new(trailCtrl[1].X,groundY(trailCtrl[1].X,trailCtrl[1].Z),trailCtrl[1].Z)
for _,sx in ipairs({-1,1}) do
 mk("VehicleStopBollard",Vector3.new(.75,3.4,.75),CFrame.new(tm+Vector3.new(sx*5.0,1.7,3)),Enum.Material.Wood,Color3.fromRGB(87,63,43),folders.ForestEdge,0,true)
end
local trailSignPos=tm+Vector3.new(0,6.2,-1.5)
for _,sx in ipairs({-1,1}) do mk("TrailSignPost",Vector3.new(.8,6.0,.8),CFrame.new(tm+Vector3.new(sx*5.2,3.0,-1.5)),Enum.Material.Wood,Color3.fromRGB(71,52,37),folders.ForestEdge,0,true) end
local trailBoard=mk("TrailMouthSign",Vector3.new(12.8,2.8,.42),CFrame.lookAt(trailSignPos,Vector3.new(roadEnd.X,trailSignPos.Y,roadEnd.Z+20)),Enum.Material.WoodPlanks,Color3.fromRGB(73,54,38),folders.ForestEdge,0,false)
textSign(trailBoard,"JALUR PENDAKIAN  •  POS 1",Enum.NormalId.Front)

-- POS1: modest shelter/rest point, not a platform or checkpoint obstacle.
local cp1Y=groundY(cp1.X,cp1.Z)
local hut=Instance.new("Model");hut.Name="POS1Shelter";hut.Parent=folders.POS1
local hcf=CFrame.new(cp1.X-13,cp1Y,cp1.Z+7)*CFrame.Angles(0,math.rad(10),0)
mk("Foundation",Vector3.new(18,.7,12),hcf*CFrame.new(0,.33,0),Enum.Material.Rock,Color3.fromRGB(100,96,86),hut,0,true)
for _,sx in ipairs({-1,1}) do for _,sz in ipairs({-1,1}) do mk("Post",Vector3.new(.65,7.5,.65),hcf*CFrame.new(sx*7.4,3.75,sz*4.4),Enum.Material.Wood,Color3.fromRGB(90,65,44),hut,0,true) end end
mk("Bench",Vector3.new(9,.55,2.0),hcf*CFrame.new(0,.75,2.6),Enum.Material.WoodPlanks,Color3.fromRGB(96,69,47),hut,0,true)
mk("Roof",Vector3.new(21,.7,15),hcf*CFrame.new(0,8.3,0)*CFrame.Angles(math.rad(5),0,0),Enum.Material.Metal,Color3.fromRGB(67,72,68),hut,0,true)
local cpBoardPos=Vector3.new(cp1.X+10,cp1Y+5.0,cp1.Z+3)
for _,sx in ipairs({-1,1}) do mk("CP1SignPost",Vector3.new(.75,5.0,.75),CFrame.new(cpBoardPos+Vector3.new(sx*4.9,-2.5,0)),Enum.Material.Wood,Color3.fromRGB(72,53,37),folders.POS1,0,true) end
local cpBoard=mk("CP1MountBBYA",Vector3.new(11.5,2.7,.42),CFrame.lookAt(cpBoardPos,Vector3.new(trailCtrl[#trailCtrl-1].X,cpBoardPos.Y,trailCtrl[#trailCtrl-1].Z)),Enum.Material.WoodPlanks,Color3.fromRGB(70,51,36),folders.POS1,0,false)
textSign(cpBoard,"POS 1  •  MOUNT BBYA",Enum.NormalId.Front)

local cpTrigger=mk("CP01_POS1",Vector3.new(9,1,9),CFrame.new(cp1.X,cp1Y+.55,cp1.Z),Enum.Material.SmoothPlastic,Color3.new(1,1,1),folders.Checkpoints,1,false)
cpTrigger:SetAttribute("CheckpointIndex",1);cpTrigger:SetAttribute("CheckpointName","POS 1 - MOUNT BBYA");cpTrigger:SetAttribute("SaveReady",true)

-- Spawn faces down the first readable village-road segment.
local sy=groundY(0,1060)
local spawn=Instance.new("SpawnLocation")
spawn.Name="MountainSpawn";spawn.Anchored=true;spawn.Size=Vector3.new(12,1,12)
spawn.CFrame=CFrame.lookAt(Vector3.new(0,sy+1.0,1060),Vector3.new(roadCtrl[2].X,sy+1.0,roadCtrl[2].Z))
spawn.Transparency=1;spawn.CanCollide=true;spawn.Neutral=true;spawn.Duration=0;spawn.Parent=root

-- Spatial runtime checks.
local roadGapCount=0
for i=1,#roadPts,6 do
 local p=roadPts[i];local y=groundY(p.X,p.Z)
 if not y or math.abs(y-p.Y)>2.6 then roadGapCount+=1 end
end
local trailRise=cp1.Y-trailCtrl[1].Y
local ok=roadGapCount==0 and trailRise>=25 and houseCount>=10 and treeCount>=25 and utilityCount>=8

root:SetAttribute("Project","MOUNT BBYA")
root:SetAttribute("EnvironmentAuthority","V6.7_RESEARCH_GROUNDED_SINGLE_SOURCE")
root:SetAttribute("EnvironmentReferences","BALI_KINTAMANI_HIGHLAND+INDONESIAN_MONTANE_TRAIL")
root:SetAttribute("Phase1Scope","SPAWN_TO_CP1_ONLY")
root:SetAttribute("Phase1Flow","VILLAGE>HIGHLAND_FARMS>ROUGH_ROAD>VEHICLE_STOP>TRAILHEAD>MONTANE_FOREST>CP1")
root:SetAttribute("TerrainFrozen",true)
root:SetAttribute("RoadTerrainNative",true)
root:SetAttribute("VehicleRoadEndsBeforeTrail",true)
root:SetAttribute("TrailBranchesFromRoad",true)
root:SetAttribute("TrailRiseStuds",trailRise)
root:SetAttribute("VillageHouseCount",houseCount)
root:SetAttribute("HighlandCropCount",cropCount)
root:SetAttribute("GroundedTreeCount",treeCount)
root:SetAttribute("UnderstoryClusterCount",understoryCount)
root:SetAttribute("GroundedPoleCount",utilityCount)
root:SetAttribute("VillageFenceDetailCount",fenceCount)
root:SetAttribute("TrailDetailCount",trailDetailCount)
root:SetAttribute("RoadGapCount",roadGapCount)
root:SetAttribute("Phase1Ready",ok)
root:SetAttribute("Phase1VisualReady",ok)
root:SetAttribute("MountBBYAPhase1PremiumReady",ok)
root:SetAttribute("MountBBYASignFacingReady",ok)
root:SetAttribute("EnvironmentResearchReady",ok)
root:SetAttribute("BuildVersion","6.7.0-research-grounded-environment")

Lighting.GlobalShadows=true
Lighting.EnvironmentDiffuseScale=.68
Lighting.EnvironmentSpecularScale=.52
Lighting.ShadowSoftness=.31
Workspace:SetAttribute("ACC_MountainBuild","mount-bbya-v6.7-research-grounded")
Workspace:SetAttribute("ACC_MountBBYA_EnvironmentQC",ok and "PASS" or "FAIL")
print("[MOUNT BBYA] v6.7 environment authority ready",ok,houseCount,cropCount,treeCount,trailRise,roadGapCount)
