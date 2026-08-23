-- ACC Mountain Social Adventure — Lowland Master v5.2
-- Scope lock: Spawn village -> rice fields -> village road -> foothill -> POS 1 only.
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Terrain=Workspace.Terrain
local root=Workspace:WaitForChild("ACC_MountainSocial",20);if not root then return end

task.wait(40) -- run last so old lowland layers can be cleaned deterministically

local old=root:FindFirstChild("LowlandMasterV52");if old then old:Destroy() end
local master=Instance.new("Folder");master.Name="LowlandMasterV52";master.Parent=root

local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Include;rp.FilterDescendantsInstances={Terrain};rp.IgnoreWater=false
local function terrainY(x,z)
 local hit=Workspace:Raycast(Vector3.new(x,1800,z),Vector3.new(0,-3600,0),rp)
 return hit and hit.Position.Y or nil
end
local function mk(n,s,cf,mat,col,parent,tr,coll)
 local p=Instance.new("Part");p.Name=n;p.Anchored=true;p.Size=s;p.CFrame=cf;p.Material=mat or Enum.Material.Ground
 if col then p.Color=col end;p.Transparency=tr or 0;p.CanCollide=coll==true;p.CastShadow=true
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or master;return p
end
local function segment(n,a,b,w,h,mat,col,parent,tr,coll)
 local d=b-a;if d.Magnitude<.04 then return nil end
 return mk(n,Vector3.new(w,h,d.Magnitude+.12),CFrame.lookAt((a+b)/2,b),mat,col,parent,tr,coll)
end
local function beam(n,a,b,w,mat,col,parent,coll)
 return segment(n,a,b,w,w,mat,col,parent,0,coll)
end
local function ball(n,pos,size,mat,col,parent,coll)
 local p=mk(n,Vector3.new(size,size*.72,size*.88),CFrame.new(pos)*CFrame.Angles(math.rad(math.random(-11,11)),math.rad(math.random(0,180)),math.rad(math.random(-9,9))),mat,col,parent,0,coll)
 p.Shape=Enum.PartType.Ball;return p
end
local function centerOf(obj)
 if obj:IsA("BasePart") then return obj.Position end
 if obj:IsA("Model") then local ok,cf=pcall(function() return select(1,obj:GetBoundingBox()) end);if ok and cf then return cf.Position end end
 return nil
end

-- Remove only legacy scenery inside the lowland corridor. Upper mountain stays untouched.
local cleanupCount=0
for _,folderName in ipairs({"VisualPolishV42","PrecisionV44","RealismV47","MicroDetailV48","EnvironmentV49","ImmersiveV50","WorldLifeV51"}) do
 local folder=root:FindFirstChild(folderName)
 if folder then
  for _,obj in ipairs(folder:GetChildren()) do
   local p=centerOf(obj)
   if p and p.Z>-120 and math.abs(p.X)<340 then obj:Destroy();cleanupCount+=1 end
  end
 end
end
local low=root:FindFirstChild("Lowlands")
if low then for _,obj in ipairs(low:GetChildren()) do obj:Destroy();cleanupCount+=1 end end
local legacyCamp=root:FindFirstChild("BasecampACC");if legacyCamp then legacyCamp:Destroy();cleanupCount+=1 end
local legacyPad=root:FindFirstChild("CheckpointPad_01");if legacyPad then legacyPad:Destroy();cleanupCount+=1 end

-- Lowland terrain breakup far from the road: broad shallow crowns, never giant boulders.
for _,v in ipairs({
 {-245,1020,115,13},{245,985,128,15},{-275,845,145,18},{280,805,150,20},
 {-285,640,155,24},{290,600,160,27},{-250,410,145,31},{260,355,150,34},
 {-205,205,125,38},{210,145,130,40}
}) do Terrain:FillBall(Vector3.new(v[1],v[4]-v[3],v[2]),v[3],Enum.Material.Grass) end

-- Catmull-Rom centerline. Y is always resolved from actual terrain.
local ctrl={
 Vector3.new(0,0,1060),Vector3.new(16,0,910),Vector3.new(-6,0,745),Vector3.new(28,0,585),
 Vector3.new(69,0,430),Vector3.new(58,0,300),Vector3.new(26,0,205),Vector3.new(-10,0,112),
 Vector3.new(-42,0,22),Vector3.new(-55,0,-30)
}
local function catmull(p0,p1,p2,p3,t)
 local t2=t*t;local t3=t2*t
 return .5*((2*p1)+(-p0+p2)*t+(2*p0-5*p1+4*p2-p3)*t2+(-p0+3*p1-3*p2+p3)*t3)
end
local raw={}
for i=1,#ctrl-1 do
 local p0=ctrl[math.max(1,i-1)];local p1=ctrl[i];local p2=ctrl[i+1];local p3=ctrl[math.min(#ctrl,i+2)]
 for s=0,11 do table.insert(raw,catmull(p0,p1,p2,p3,s/12)) end
end
table.insert(raw,ctrl[#ctrl])
local pts={}
for _,p in ipairs(raw) do local y=terrainY(p.X,p.Z);if y then table.insert(pts,Vector3.new(p.X,y+.36,p.Z)) end end

local function roadWidth(progress)
 if progress<.47 then return 22 elseif progress<.68 then return 19 elseif progress<.84 then return 16.5 else return 14 end
end
local roadSegments=0
local roadMeta={}
for i=1,#pts-1 do
 local a,b=pts[i],pts[i+1];local progress=(i-1)/math.max(1,#pts-2);local w=roadWidth(progress)
 local mat,col
 if progress<.58 then mat=Enum.Material.Asphalt;col=Color3.fromRGB(48,50,50)
 elseif progress<.78 then mat=Enum.Material.Pebble;col=Color3.fromRGB(99,95,84)
 else mat=Enum.Material.Ground;col=Color3.fromRGB(109,88,65) end
 segment(string.format("MasterRoad_%03d",i),a,b,w,.52,mat,col,master,0,true);roadSegments+=1
 local d=b-a;local flat=Vector3.new(d.X,0,d.Z);local side=flat.Magnitude>0 and Vector3.new(-flat.Z,0,flat.X).Unit or Vector3.xAxis
 roadMeta[i]={p=a,side=side,w=w,progress=progress}
 -- terrain-following shoulders with independent Y sampling
 for _,sign in ipairs({-1,1}) do
  local aa=a+side*sign*(w*.5+1.25);local bb=b+side*sign*(w*.5+1.25)
  local ya=terrainY(aa.X,aa.Z);local yb=terrainY(bb.X,bb.Z)
  if ya and yb then
   aa=Vector3.new(aa.X,ya+.18,aa.Z);bb=Vector3.new(bb.X,yb+.18,bb.Z)
   segment("RoadShoulder",aa,bb,2.35,.34,progress<.62 and Enum.Material.Ground or Enum.Material.Pebble,Color3.fromRGB(92,82,63),master,0,true)
  end
 end
 -- subtle center dashes only on public asphalt section
 if progress<.43 and i%4==1 then
  local mid=a:Lerp(b,.5)+Vector3.new(0,.31,0);local dir=(b-a).Unit
  segment("RoadCenterDash",mid-dir*2.3,mid+dir*2.3,.25,.055,Enum.Material.SmoothPlastic,Color3.fromRGB(210,203,180),master,0,false)
 end
end

-- Drainage on lower village section, following the same spline.
local drainCount=0
for i=5,math.min(#pts-2,62),2 do
 local info=roadMeta[i];if info then
  for _,sign in ipairs({-1,1}) do
   local q=info.p+info.side*sign*(info.w*.5+3.2);local y=terrainY(q.X,q.Z)
   if y then
    local q2=q+(pts[i+1]-pts[i]).Unit*7;local y2=terrainY(q2.X,q2.Z)
    if y2 then
     local a=Vector3.new(q.X,y+.10,q.Z);local b=Vector3.new(q2.X,y2+.10,q2.Z)
     segment("StoneDrain",a,b,1.35,.24,Enum.Material.Rock,Color3.fromRGB(92,90,80),master,0,false)
     local water=segment("DrainWater",a+Vector3.new(0,.15,0),b+Vector3.new(0,.15,0),.48,.045,Enum.Material.Glass,Color3.fromRGB(79,109,107),master,.34,false)
     drainCount+=1
    end
   end
  end
 end
end

-- Weathered road surface: thin, irregular cracks/patched aggregate, never raised obstacles.
local roadWear=0
for i=8,math.min(#pts-2,70),7 do
 local a=pts[i];local b=pts[i+1];local dir=(b-a).Unit;local side=roadMeta[i].side
 local start=a:Lerp(b,.45)+Vector3.new(0,.31,0)+side*(((i%3)-1)*2.1)
 local q1=start+dir*1.5+side*.8;local q2=q1+dir*1.9-side*.55
 beam("AsphaltCrack",start,q1,.085,Enum.Material.SmoothPlastic,Color3.fromRGB(29,30,29),master,false)
 beam("AsphaltCrack",q1,q2,.07,Enum.Material.SmoothPlastic,Color3.fromRGB(29,30,29),master,false)
 roadWear+=2
end

-- Village architecture, grounded per building.
local houseCount=0
local function house(x,z,rot,scale,wall,roof)
 local y=terrainY(x,z);if not y then return end
 scale=scale or 1;local m=Instance.new("Model");m.Name="MasterVillageHouse";m.Parent=master
 local cf=CFrame.new(x,y,z)*CFrame.Angles(0,math.rad(rot),0);local w=20*scale;local d=15*scale;local h=8.6*scale
 mk("StoneBase",Vector3.new(w+2,.9,d+2),cf*CFrame.new(0,.42,0),Enum.Material.Rock,Color3.fromRGB(112,106,94),m,0,true)
 mk("PlasterWall",Vector3.new(w,h,d),cf*CFrame.new(0,.9+h*.5,0),Enum.Material.Brick,wall,m,0,true)
 -- layered sloped roof with small tile seams
 for _,sgn in ipairs({-1,1}) do
  local roofCf=cf*CFrame.new(sgn*w*.23,h+3.2,0)*CFrame.Angles(0,0,math.rad(-sgn*26))
  mk("RoofPlane",Vector3.new(w*.59,.72,d+4.2),roofCf,Enum.Material.Metal,roof,m,0,true)
  for k=-2,2 do mk("RoofSeam",Vector3.new(.12,.12,d+4.0),roofCf*CFrame.new(k*w*.105,.42,0),Enum.Material.Metal,Color3.fromRGB(math.max(35,roof.R*255-12),math.max(35,roof.G*255-12),math.max(35,roof.B*255-12)),m,0,false) end
 end
 mk("Door",Vector3.new(3.1*scale,6.3*scale,.32),cf*CFrame.new(0,1+3.15*scale,-d*.5-.2),Enum.Material.Wood,Color3.fromRGB(74,52,36),m,0,false)
 for _,sx in ipairs({-1,1}) do
  local wx=sx*w*.27
  mk("Window",Vector3.new(3.7*scale,2.8*scale,.24),cf*CFrame.new(wx,1+5.2*scale,-d*.5-.22),Enum.Material.Glass,Color3.fromRGB(139,169,172),m,.2,false)
  mk("WindowFrameH",Vector3.new(4.1*scale,.24,.32),cf*CFrame.new(wx,1+6.75*scale,-d*.5-.38),Enum.Material.Wood,Color3.fromRGB(81,61,44),m,0,false)
 end
 mk("Porch",Vector3.new(w*.62,.55,4.0*scale),cf*CFrame.new(0,.62,-d*.5-1.9*scale),Enum.Material.WoodPlanks,Color3.fromRGB(108,79,53),m,0,true)
 for _,sx in ipairs({-1,1}) do mk("PorchPost",Vector3.new(.52,5.1*scale,.52),cf*CFrame.new(sx*w*.25,3.05*scale,-d*.5-3.1*scale),Enum.Material.Wood,Color3.fromRGB(79,58,41),m,0,true) end
 local gutterA=(cf*CFrame.new(-w*.48,h+2.0,-d*.5-1.95)).Position;local gutterB=(cf*CFrame.new(w*.48,h+2.0,-d*.5-1.95)).Position
 beam("RainGutter",gutterA,gutterB,.22,Enum.Material.Metal,Color3.fromRGB(75,76,72),m,false)
 houseCount+=1
end
house(-62,1026,17,.92,Color3.fromRGB(203,191,169),Color3.fromRGB(91,72,57))
house(67,985,-14,.88,Color3.fromRGB(190,181,161),Color3.fromRGB(69,75,72))
house(-71,906,8,.91,Color3.fromRGB(213,200,176),Color3.fromRGB(100,70,52))
house(76,842,-19,.87,Color3.fromRGB(194,185,165),Color3.fromRGB(72,74,70))
house(-79,772,14,.84,Color3.fromRGB(187,177,157),Color3.fromRGB(92,66,49))
house(83,690,-16,.85,Color3.fromRGB(203,192,171),Color3.fromRGB(69,72,69))
house(-88,602,10,.82,Color3.fromRGB(198,187,164),Color3.fromRGB(96,69,50))
house(90,515,-13,.80,Color3.fromRGB(195,185,162),Color3.fromRGB(74,76,71))

-- Terraced rice paddies: smaller, staggered and elevation-aware.
local paddyCount=0
local function paddy(x,z,w,d,rot)
 local y=terrainY(x,z);if not y then return end
 local m=Instance.new("Model");m.Name="MasterRiceTerrace";m.Parent=master;local cf=CFrame.new(x,y+.12,z)*CFrame.Angles(0,math.rad(rot),0)
 mk("TerraceBed",Vector3.new(w,.55,d),cf*CFrame.new(0,.10,0),Enum.Material.Ground,Color3.fromRGB(92,78,57),m,0,true)
 mk("PaddyWater",Vector3.new(w-2,.10,d-2),cf*CFrame.new(0,.43,0),Enum.Material.Glass,Color3.fromRGB(82,122,111),m,.30,false)
 local bundCol=Color3.fromRGB(94,82,60)
 mk("BundN",Vector3.new(w+1,.65,1.3),cf*CFrame.new(0,.38,-d*.5),Enum.Material.Ground,bundCol,m,0,true)
 mk("BundS",Vector3.new(w+1,.65,1.3),cf*CFrame.new(0,.38,d*.5),Enum.Material.Ground,bundCol,m,0,true)
 mk("BundL",Vector3.new(1.3,.65,d),cf*CFrame.new(-w*.5,.38,0),Enum.Material.Ground,bundCol,m,0,true)
 mk("BundR",Vector3.new(1.3,.65,d),cf*CFrame.new(w*.5,.38,0),Enum.Material.Ground,bundCol,m,0,true)
 for r=-1,1 do for c=-2,2 do
  local pos=(cf*CFrame.new(c*w/6,.55,r*d/4)).Position
  for blade=-1,1 do beam("RiceBlade",pos,pos+Vector3.new(blade*.16,1.25+((c+r+blade)%3)*.12,.05*blade),.07,Enum.Material.Grass,Color3.fromRGB(92,139,62),m,false) end
 end end
 paddyCount+=1
end
paddy(-145,1005,58,38,-3);paddy(150,985,60,40,4)
paddy(-155,930,62,40,2);paddy(160,905,64,41,-3)
paddy(-166,842,66,42,-2);paddy(172,815,66,42,3)
paddy(-174,748,67,43,4);paddy(182,710,68,44,-4)
paddy(-180,648,65,42,3);paddy(188,602,66,43,-3)

-- Natural multi-cluster trees. Every trunk starts at raycast ground and stays outside road clearance.
local treeCount=0
local function tree(x,z,scale,variant)
 local y=terrainY(x,z);if not y then return end
 local m=Instance.new("Model");m.Name="MasterTree";m.Parent=master;local base=Vector3.new(x,y,z)
 local bark=variant%2==0 and Color3.fromRGB(77,57,40) or Color3.fromRGB(68,51,37);local green=variant%3==0 and Color3.fromRGB(39,73,41) or Color3.fromRGB(49,88,44)
 local h=(10.2+variant*.55)*scale
 mk("Trunk",Vector3.new(1.45*scale,h,1.45*scale),CFrame.new(base+Vector3.new(0,h*.5,0))*CFrame.Angles(0,0,math.rad((variant%5)-2)),Enum.Material.Wood,bark,m,0,true)
 local fork=base+Vector3.new(0,h*.67,0)
 for b=1,4 do
  local ang=(b-1)*math.pi*.5+variant*.29;local len=(4.0+(b%2)*1.3)*scale;local tip=fork+Vector3.new(math.cos(ang)*len,2.2*scale,math.sin(ang)*len)
  beam("Branch",fork,tip,.42*scale,Enum.Material.Wood,bark,m,false)
  for k=1,2 do ball("LeafCluster",tip+Vector3.new((k-1.5)*2.1*scale,(k%2)*1.3*scale,math.sin(k+ang)*1.7*scale),(3.3+k*.5)*scale,Enum.Material.LeafyGrass,green,m,false) end
 end
 for k=1,4 do ball("LeafCluster",base+Vector3.new(math.cos(k*1.5)*3.3*scale,h+(k%2)*1.2*scale,math.sin(k*1.5)*3.2*scale),3.7*scale,Enum.Material.LeafyGrass,green,m,false) end
 treeCount+=1
end
for i=8,#pts-8,9 do
 local info=roadMeta[i];if info then
  local p=pts[i];local offset=info.w*.5+18+(i%4)*3
  local l=p+info.side*offset;tree(l.X,l.Z,.62+(i%3)*.08,1+(i%4))
  if i%2==0 then local r=p-info.side*(offset+7);tree(r.X,r.Z,.58+(i%4)*.07,2+(i%3)) end
 end
end
-- field-edge trees, deliberately far from asphalt
for _,p in ipairs({{-218,960,.68},{220,900,.72},{-225,790,.66},{232,735,.70},{-220,580,.72},{225,520,.67},{-185,420,.72},{190,355,.70}}) do tree(p[1],p[2],p[3],3) end

-- Warung: open frontage, shelf, counter and warm practical light.
local warungCount=0
local function buildWarung()
 local x,z=56,870;local y=terrainY(x,z);if not y then return end
 local m=Instance.new("Model");m.Name="MasterWarung";m.Parent=master;local cf=CFrame.new(x,y,z)*CFrame.Angles(0,math.rad(-7),0)
 mk("Floor",Vector3.new(20,.6,14),cf*CFrame.new(0,.3,0),Enum.Material.WoodPlanks,Color3.fromRGB(108,79,52),m,0,true)
 mk("BackWall",Vector3.new(20,8,.55),cf*CFrame.new(0,4,6.7),Enum.Material.WoodPlanks,Color3.fromRGB(101,74,49),m,0,true)
 mk("SideWall",Vector3.new(.55,8,14),cf*CFrame.new(-9.7,4,0),Enum.Material.WoodPlanks,Color3.fromRGB(101,74,49),m,0,true)
 mk("Counter",Vector3.new(11,2.7,1.8),cf*CFrame.new(2.5,1.55,-5.5),Enum.Material.WoodPlanks,Color3.fromRGB(82,60,42),m,0,true)
 mk("Shelf",Vector3.new(7,.34,1.2),cf*CFrame.new(-4,5.1,6.1),Enum.Material.WoodPlanks,Color3.fromRGB(82,60,42),m,0,true)
 mk("Roof",Vector3.new(23,.8,17),cf*CFrame.new(0,9.1,0)*CFrame.Angles(math.rad(-7),0,0),Enum.Material.Metal,Color3.fromRGB(73,79,75),m,0,true)
 local sign=mk("Sign",Vector3.new(12.5,2.2,.35),cf*CFrame.new(1.5,7.2,-7.25),Enum.Material.WoodPlanks,Color3.fromRGB(75,55,39),m,0,false)
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.PixelsPerStud=35;gui.Parent=sign
 local tx=Instance.new("TextLabel");tx.Size=UDim2.fromScale(1,1);tx.BackgroundTransparency=1;tx.Text="WARUNG KAKI GUNUNG";tx.TextScaled=true;tx.Font=Enum.Font.GothamBold;tx.TextColor3=Color3.fromRGB(236,226,198);tx.Parent=gui
 for _,sx in ipairs({-1,1}) do local bulb=mk("WarmBulb",Vector3.new(.45,.45,.45),cf*CFrame.new(sx*4.4,6.6,-4.5),Enum.Material.Glass,Color3.fromRGB(255,214,148),m,.08,false);bulb.Shape=Enum.PartType.Ball;local pl=Instance.new("PointLight");pl.Name="LowlandNightLight";pl.Brightness=.8;pl.Range=11;pl.Color=Color3.fromRGB(255,205,139);pl.Shadows=true;pl.Enabled=false;pl.Parent=bulb end
 warungCount=1
end
buildWarung()

-- Utility poles use the exact road tangent and terrain height; wires sag naturally.
local poleCount=0
local poleData={}
for i=8,math.min(#pts-10,76),11 do
 local info=roadMeta[i];if info and info.progress<.70 then
  local p=pts[i];local q=p+info.side*(info.w*.5+10.5);local y=terrainY(q.X,q.Z)
  if y then
   q=Vector3.new(q.X,y,q.Z);local top=q+Vector3.new(0,14.2,0)
   mk("UtilityPole",Vector3.new(.78,14.2,.78),CFrame.new(q+Vector3.new(0,7.1,0)),Enum.Material.Wood,Color3.fromRGB(67,50,37),master,0,true)
   beam("CrossArm",top-info.side*2.8,top+info.side*2.8,.34,Enum.Material.Wood,Color3.fromRGB(67,50,37),master,false)
   for _,sgn in ipairs({-1,1}) do local ins=mk("Insulator",Vector3.new(.3,.55,.3),CFrame.new(top+info.side*sgn*2.1+Vector3.new(0,.38,0)),Enum.Material.SmoothPlastic,Color3.fromRGB(205,198,178),master,0,false);ins.Shape=Enum.PartType.Cylinder end
   poleCount+=1;table.insert(poleData,{top=top,side=info.side})
  end
 end
end
local function sagSpan(name,a,b,segments)
 local prev=nil
 for s=0,segments do
  local t=s/segments;local q=a:Lerp(b,t)+Vector3.new(0,-math.sin(math.pi*t)*(2.0+(b-a).Magnitude/90),0)
  if prev then beam(name,prev,q,.085,Enum.Material.SmoothPlastic,Color3.fromRGB(30,30,29),master,false) end
  prev=q
 end
end
for i=1,#poleData-1 do
 for _,sgn in ipairs({-1,1}) do
  local a=poleData[i].top+poleData[i].side*sgn*2.1+Vector3.new(0,.45,0);local b=poleData[i+1].top+poleData[i+1].side*sgn*2.1+Vector3.new(0,.45,0)
  sagSpan("PowerWire",a,b,7)
 end
end

-- POS 1 rebuilt as a grounded trailhead, using the actual CP1 terrain.
local cp1x,cp1z=-55,-30;local cp1y=terrainY(cp1x,cp1z) or 44
local cp1=Instance.new("Model");cp1.Name="MasterPOS1";cp1.Parent=master
mk("TrailheadGround",Vector3.new(72,1.0,54),CFrame.new(cp1x,cp1y+.25,cp1z),Enum.Material.Ground,Color3.fromRGB(101,85,63),cp1,0,true)
mk("Parking",Vector3.new(27,.62,20),CFrame.new(cp1x+22,cp1y+.58,cp1z+12),Enum.Material.Pebble,Color3.fromRGB(105,101,91),cp1,0,true)
local hutCf=CFrame.new(cp1x-20,cp1y+.6,cp1z+11)*CFrame.Angles(0,math.rad(8),0)
mk("HutFloor",Vector3.new(22,.65,15),hutCf,Enum.Material.WoodPlanks,Color3.fromRGB(99,72,47),cp1,0,true)
mk("HutWall",Vector3.new(21,8,14),hutCf*CFrame.new(0,4.3,0),Enum.Material.WoodPlanks,Color3.fromRGB(114,82,54),cp1,0,true)
for _,sgn in ipairs({-1,1}) do mk("HutRoof",Vector3.new(12.5,.75,18),hutCf*CFrame.new(sgn*4.8,9.5,0)*CFrame.Angles(0,0,math.rad(-sgn*25)),Enum.Material.Metal,Color3.fromRGB(68,73,69),cp1,0,true) end
mk("RegistrationCounter",Vector3.new(8.5,3.1,2),hutCf*CFrame.new(2,1.9,-8),Enum.Material.WoodPlanks,Color3.fromRGB(81,59,41),cp1,0,true)
local gateCenter=Vector3.new(cp1x-5,cp1y,cp1z-22)
for _,sx in ipairs({-1,1}) do mk("GatePost",Vector3.new(1.8,10,1.8),CFrame.new(gateCenter+Vector3.new(sx*8,5,0)),Enum.Material.Wood,Color3.fromRGB(70,51,35),cp1,0,true) end
local gateSign=mk("POS1Sign",Vector3.new(18,4.2,.5),CFrame.new(gateCenter+Vector3.new(0,10,0)),Enum.Material.WoodPlanks,Color3.fromRGB(69,51,35),cp1,0,true)
local gg=Instance.new("SurfaceGui");gg.Face=Enum.NormalId.Front;gg.PixelsPerStud=38;gg.Parent=gateSign
local gt=Instance.new("TextLabel");gt.Size=UDim2.fromScale(1,1);gt.BackgroundTransparency=1;gt.Text="POS 1 — KAKI GUNUNG";gt.TextScaled=true;gt.Font=Enum.Font.GothamBold;gt.TextColor3=Color3.fromRGB(238,229,202);gt.Parent=gg
local routeBoard=mk("RouteBoard",Vector3.new(12,7,.45),CFrame.new(cp1x+23,cp1y+4.1,cp1z-10)*CFrame.Angles(0,math.rad(-16),0),Enum.Material.WoodPlanks,Color3.fromRGB(77,58,41),cp1,0,true)
local rg=Instance.new("SurfaceGui");rg.Face=Enum.NormalId.Front;rg.PixelsPerStud=32;rg.Parent=routeBoard
local rt=Instance.new("TextLabel");rt.Size=UDim2.fromScale(1,1);rt.BackgroundTransparency=1;rt.Text="JALUR PENDAKIAN\nREGISTRASI • CEK PERLENGKAPAN\nMULAI HUTAN BAWAH";rt.TextWrapped=true;rt.TextScaled=true;rt.Font=Enum.Font.GothamMedium;rt.TextColor3=Color3.fromRGB(229,221,199);rt.Parent=rg
for i=1,2 do local p=Vector3.new(cp1x+10+i*9,cp1y,cp1z+22);mk("RestBench",Vector3.new(6,.45,1.1),CFrame.new(p+Vector3.new(0,1.3,0)),Enum.Material.WoodPlanks,Color3.fromRGB(107,76,49),cp1,0,true);mk("BenchLeg",Vector3.new(.4,1.3,.8),CFrame.new(p+Vector3.new(-1.8,.65,0)),Enum.Material.Wood,Color3.fromRGB(78,57,40),cp1,0,true);mk("BenchLeg",Vector3.new(.4,1.3,.8),CFrame.new(p+Vector3.new(1.8,.65,0)),Enum.Material.Wood,Color3.fromRGB(78,57,40),cp1,0,true) end
for _,p in ipairs({Vector3.new(cp1x-6,cp1y,cp1z+20),Vector3.new(cp1x+30,cp1y,cp1z-5)}) do local post=mk("CP1LampPost",Vector3.new(.45,5,.45),CFrame.new(p+Vector3.new(0,2.5,0)),Enum.Material.Wood,Color3.fromRGB(72,53,39),cp1,0,true);local bulb=mk("CP1Lamp",Vector3.new(.65,.7,.65),CFrame.new(p+Vector3.new(0,5.25,0)),Enum.Material.Glass,Color3.fromRGB(255,216,151),cp1,.1,false);local pl=Instance.new("PointLight");pl.Name="LowlandNightLight";pl.Brightness=1;pl.Range=15;pl.Color=Color3.fromRGB(255,203,137);pl.Shadows=true;pl.Enabled=false;pl.Parent=bulb end

-- Keep invisible CP1 save trigger aligned with rebuilt trailhead.
local cps=root:FindFirstChild("Checkpoints")
if cps then for _,obj in ipairs(cps:GetChildren()) do if obj:GetAttribute("CheckpointIndex")==1 and obj:IsA("BasePart") then obj.CFrame=CFrame.new(cp1x,cp1y+1.0,cp1z) end end end

-- Spawn grounded and aimed down the road, not at empty horizon.
local spawn=root:FindFirstChild("MountainSpawn")
if spawn and spawn:IsA("SpawnLocation") then local sy=terrainY(0,1060) or 10;spawn.CFrame=CFrame.lookAt(Vector3.new(0,sy+1.2,1060),Vector3.new(10,sy+1.0,1015)) end

-- Night lighting only for this lowland pass.
local function updateLights()
 local phase=tostring(Workspace:GetAttribute("ACC_DayPhase") or "")
 local night=phase=="NIGHT" or Lighting.ClockTime>=18.4 or Lighting.ClockTime<5.3
 for _,obj in ipairs(master:GetDescendants()) do if obj:IsA("PointLight") and obj.Name=="LowlandNightLight" then obj.Enabled=night end end
end
updateLights();Workspace:GetAttributeChangedSignal("ACC_DayPhase"):Connect(updateLights)
task.spawn(function() while master.Parent do updateLights();task.wait(8) end end)

root:SetAttribute("LowlandMasterReady",true)
root:SetAttribute("LowlandMasterVersion","5.2")
root:SetAttribute("LowlandScope","SPAWN_TO_CP1_ONLY")
root:SetAttribute("LowlandCleanupCount",cleanupCount)
root:SetAttribute("LowlandRoadSegmentCount",roadSegments)
root:SetAttribute("LowlandDrainCount",drainCount)
root:SetAttribute("LowlandRoadWearCount",roadWear)
root:SetAttribute("LowlandHouseCount",houseCount)
root:SetAttribute("LowlandPaddyCount",paddyCount)
root:SetAttribute("LowlandGroundedTreeCount",treeCount)
root:SetAttribute("LowlandUtilityPoleCount",poleCount)
root:SetAttribute("LowlandWarungCount",warungCount)
root:SetAttribute("LowlandCP1Ready",true)
print("[ACC] Mountain v5.2 LOWLAND MASTER ready",roadSegments,houseCount,paddyCount,treeCount,poleCount,cleanupCount)
