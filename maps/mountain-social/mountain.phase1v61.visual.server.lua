-- ACC Mountain Social Adventure — v6.1 PHASE 1 COMPOSITION PASS
-- Scope hard-lock: Spawn village -> road transition -> trail mouth -> narrowing forest -> POS1 only.
-- This pass performs NO Terrain edits. It rebuilds only grounded visual composition after v6 terrain is final.
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Terrain=Workspace.Terrain

local root=Workspace:WaitForChild("ACC_MountainSocial",45)
if not root then error("v6.1 composition: ACC_MountainSocial missing") end
local deadline=os.clock()+45
while not (root:GetAttribute("Phase1Ready")==true and root:GetAttribute("TerrainFrozen")==true) do
 if os.clock()>deadline then error("v6.1 composition: terrain readiness timeout") end
 task.wait(.2)
end

local function folder(name)
 local f=root:FindFirstChild(name)
 if not f then f=Instance.new("Folder");f.Name=name;f.Parent=root end
 return f
end
local Village=folder("Village")
local RiceFields=folder("RiceFields")
local Roadside=folder("Roadside")
local ForestEdge=folder("ForestEdge")
local POS1=folder("POS1")
local Checkpoints=folder("Checkpoints")

-- Clear only Phase1 visual folders. Terrain and route remain authoritative from v6.0.
for _,f in ipairs({Village,RiceFields,Roadside,ForestEdge,POS1}) do f:ClearAllChildren() end
for _,o in ipairs(Checkpoints:GetChildren()) do if o:GetAttribute("CheckpointIndex")==1 then o:Destroy() end end

local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Include;rp.FilterDescendantsInstances={Terrain};rp.IgnoreWater=true
local function groundY(x,z)
 local hit=Workspace:Raycast(Vector3.new(x,700,z),Vector3.new(0,-1400,0),rp)
 return hit and hit.Position.Y or 10
end
local function mk(name,size,cf,mat,col,parent,tr,coll)
 local p=Instance.new("Part")
 p.Name=name;p.Anchored=true;p.Size=size;p.CFrame=cf;p.Material=mat or Enum.Material.SmoothPlastic
 if col then p.Color=col end
 p.Transparency=tr or 0;p.CanCollide=coll==true;p.CastShadow=true
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent
 return p
end
local function beam(name,a,b,width,mat,col,parent,coll)
 local d=b-a;if d.Magnitude<.05 then return nil end
 return mk(name,Vector3.new(width,width,d.Magnitude),CFrame.lookAt((a+b)/2,b),mat,col,parent,0,coll)
end
local function textSign(part,text,frontColor)
 local sg=Instance.new("SurfaceGui");sg.Face=Enum.NormalId.Front;sg.PixelsPerStud=40;sg.Parent=part
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextScaled=true;t.Font=Enum.Font.GothamBold;t.TextColor3=frontColor or Color3.fromRGB(239,232,207);t.Parent=sg
end

-- Road center interpolation copied from terrain master route, so every visual stays relative to the actual road.
local roadNodes={{1060,0},{930,8},{800,-4},{670,16},{545,42},{430,59},{335,61},{255,53},{185,42},{150,38}}
local function roadX(z)
 for i=1,#roadNodes-1 do
  local z1,x1=roadNodes[i][1],roadNodes[i][2];local z2,x2=roadNodes[i+1][1],roadNodes[i+1][2]
  if z<=z1 and z>=z2 then local t=(z1-z)/(z1-z2);return x1+(x2-x1)*t end
 end
 return z>1060 and 0 or 38
end

local houseCount=0
local function house(z,side,w,d,rot,variant)
 local cx=roadX(z);local x=cx+side*(31+(variant%3)*3);local y=groundY(x,z)
 local m=Instance.new("Model");m.Name="VillageHouse_Close_"..houseCount+1;m.Parent=Village
 local cf=CFrame.new(x,y,z)*CFrame.Angles(0,math.rad(rot),0)
 local wall=variant%2==0 and Color3.fromRGB(206,197,178) or Color3.fromRGB(190,181,163)
 local trim=Color3.fromRGB(92,78,61);local roof=variant%2==0 and Color3.fromRGB(74,76,72) or Color3.fromRGB(96,66,48)
 mk("StoneSkirt",Vector3.new(w+2,1.5,d+2),cf*CFrame.new(0,.45,0),Enum.Material.Rock,Color3.fromRGB(98,96,88),m,0,true)
 mk("Wall",Vector3.new(w,8.1,d),cf*CFrame.new(0,4.5,0),Enum.Material.Brick,wall,m,0,true)
 for _,sgn in ipairs({-1,1}) do mk("Roof",Vector3.new(w*.62,.65,d+3.6),cf*CFrame.new(sgn*w*.23,9.9,0)*CFrame.Angles(0,0,math.rad(-sgn*27)),Enum.Material.Metal,roof,m,0,true) end
 mk("Door",Vector3.new(2.8,5.9,.28),cf*CFrame.new(0,3.3,-d*.5-.16),Enum.Material.Wood,Color3.fromRGB(73,52,37),m,0,false)
 for _,sx in ipairs({-.28,.28}) do
  local win=mk("Window",Vector3.new(3.0,2.4,.22),cf*CFrame.new(w*sx,5.6,-d*.5-.18),Enum.Material.Glass,Color3.fromRGB(202,183,130),m,.12,false)
  local light=Instance.new("PointLight");light.Brightness=.55;light.Range=8;light.Color=Color3.fromRGB(255,212,157);light.Parent=win
 end
 mk("Porch",Vector3.new(w*.62,.45,3.2),cf*CFrame.new(0,.68,-d*.5-1.45),Enum.Material.WoodPlanks,trim,m,0,true)
 local jar=mk("WaterJar",Vector3.new(1.2,1.45,1.2),cf*CFrame.new(w*.34,.78,-d*.5-1.35),Enum.Material.Slate,Color3.fromRGB(114,83,57),m,0,false);jar.Shape=Enum.PartType.Ball
 mk("Planter",Vector3.new(3.4,.5,1.0),cf*CFrame.new(-w*.30,.35,-d*.5-1.35),Enum.Material.WoodPlanks,trim,m,0,false)
 houseCount+=1
end

local houseSpecs={
 {1018,-1,23,18,10,1},{965,1,22,18,-12,2},{905,-1,23,18,8,3},{845,1,22,18,-10,4},
 {785,-1,22,17,9,5},{720,1,21,17,-10,6},{655,-1,21,17,8,7},{590,1,20,16,-8,8},
 {520,-1,20,16,7,9},{455,1,19,16,-8,10}
}
for i,s in ipairs(houseSpecs) do house(s[1],s[2],s[3],s[4],s[5],s[6]);if i%3==0 then task.wait() end end

local fenceCount=0
for z=1035,470,-42 do
 local side=((math.floor((1035-z)/42)%2)==0) and -1 or 1
 local cx=roadX(z);local x=cx+side*22.5;local y=groundY(x,z)
 local m=Roadside
 local p1=Vector3.new(x,y,z);local p2=Vector3.new(x,y+3.4,z)
 mk("FencePost",Vector3.new(.45,3.4,.45),CFrame.new((p1+p2)/2),Enum.Material.Wood,Color3.fromRGB(88,66,46),m,0,false)
 local z2=z-18;local x2=roadX(z2)+side*22.5;local y2=groundY(x2,z2)
 beam("FenceRail",Vector3.new(x,y+2.3,z),Vector3.new(x2,y2+2.3,z2),.25,Enum.Material.Wood,Color3.fromRGB(97,72,48),m,false)
 fenceCount+=2
end

local riceCount=0
for rowZ=995,565,-72 do
 for _,side in ipairs({-1,1}) do
  local cx=roadX(rowZ);local baseX=cx+side*(72+((math.floor(rowZ/20))%3)*8)
  for band=-2,2 do
   local bz=rowZ+band*6
   beam("RiceBund",Vector3.new(baseX-18,groundY(baseX-18,bz)+.18,bz),Vector3.new(baseX+18,groundY(baseX+18,bz)+.18,bz),.32,Enum.Material.Ground,Color3.fromRGB(93,82,59),RiceFields,false)
   for k=-8,8 do
    local bx=baseX+k*2.0;local yy=groundY(bx,bz)
    mk("RiceBlade",Vector3.new(.10,1.15,.10),CFrame.new(bx,yy+.58,bz)*CFrame.Angles(0,0,math.rad((k%3)-1)*5),Enum.Material.Grass,Color3.fromRGB(83,131,57),RiceFields,0,false)
    riceCount+=1
   end
  end
 end
 task.wait()
end

local roadsideDetail=0
for z=1040,360,-24 do
 local cx=roadX(z)
 for _,side in ipairs({-1,1}) do
  local x=cx+side*(15.0+((z/24)%3));local y=groundY(x,z)
  for k=1,3 do
   local gx=x+side*(k*.8);local gz=z+(k-2)*1.2;local gy=groundY(gx,gz)
   mk("RoadGrass",Vector3.new(.08,1.0+.12*k,.08),CFrame.new(gx,gy+.5,gz)*CFrame.Angles(0,0,math.rad(side*6)),Enum.Material.Grass,Color3.fromRGB(74,108,54),Roadside,0,false)
  end
  if z%48==8 or z%48==-40 then
   local r=mk("ShoulderStone",Vector3.new(1.3,.7,1.6),CFrame.new(x+side*1.5,y+.25,z+1.8)*CFrame.Angles(math.rad(7),math.rad(z),math.rad(5)),Enum.Material.Rock,Color3.fromRGB(93,91,83),Roadside,0,false);r.Shape=Enum.PartType.Ball
  end
  roadsideDetail+=4
 end
end

local vz=990;local vx=roadX(vz)-24;local vy=groundY(vx,vz)
for _,sx in ipairs({-1,1}) do mk("VillageSignPost",Vector3.new(.7,5.2,.7),CFrame.new(vx+sx*5.8,vy+2.6,vz),Enum.Material.Wood,Color3.fromRGB(74,55,39),Roadside,0,true) end
local vs=mk("VillageSign",Vector3.new(13,3,.45),CFrame.new(vx,vy+5.4,vz),Enum.Material.WoodPlanks,Color3.fromRGB(80,58,40),Roadside,0,false)
textSign(vs,"DESA KAKI GUNUNG")

local wz=620;local wx=roadX(wz)+30;local wy=groundY(wx,wz);local war=Instance.new("Model");war.Name="WarungKakiGunung";war.Parent=Roadside
local wcf=CFrame.new(wx,wy,wz)*CFrame.Angles(0,math.rad(-8),0)
mk("WarungFloor",Vector3.new(16,.5,10),wcf*CFrame.new(0,.35,0),Enum.Material.WoodPlanks,Color3.fromRGB(111,80,53),war,0,true)
mk("WarungBack",Vector3.new(16,6.8,.5),wcf*CFrame.new(0,3.7,4.6),Enum.Material.WoodPlanks,Color3.fromRGB(122,91,61),war,0,true)
mk("WarungRoof",Vector3.new(18,.55,12),wcf*CFrame.new(0,7.5,0)*CFrame.Angles(math.rad(4),0,0),Enum.Material.Metal,Color3.fromRGB(72,74,69),war,0,true)
local ws=mk("WarungSign",Vector3.new(12,2.2,.35),wcf*CFrame.new(0,6.4,-5.2),Enum.Material.WoodPlanks,Color3.fromRGB(75,54,38),war,0,false);textSign(ws,"WARUNG KAKI GUNUNG")
local wl=Instance.new("PointLight");wl.Brightness=1.0;wl.Range=16;wl.Color=Color3.fromRGB(255,207,143);wl.Parent=ws

local roadCue=0
for z=560,190,-34 do
 local x=roadX(z);local y=groundY(x,z)
 for _,off in ipairs({-4.5,3.7}) do
  mk("BrokenRoadPatch",Vector3.new(2.2,.06,4.8),CFrame.new(x+off,y+.025,z)*CFrame.Angles(0,math.rad(z*1.7+off*9),0),Enum.Material.Ground,Color3.fromRGB(93,80,62),Roadside,0,false)
  roadCue+=1
 end
end

local tm=Vector3.new(28,groundY(28,190),190)
for _,sx in ipairs({-1,1}) do mk("TrailMouthPost",Vector3.new(.85,6.8,.85),CFrame.new(tm+Vector3.new(sx*5.5,3.4,0)),Enum.Material.Wood,Color3.fromRGB(71,52,37),ForestEdge,0,true) end
local tms=mk("TrailMouthSign",Vector3.new(13,2.6,.4),CFrame.new(tm+Vector3.new(0,6.8,0))*CFrame.Angles(0,math.rad(-14),0),Enum.Material.WoodPlanks,Color3.fromRGB(73,54,38),ForestEdge,0,false)
textSign(tms,"JALUR PENDAKIAN  •  POS 1")
for _,sx in ipairs({-1,1}) do
 local bx=tm.X+sx*7.8;local bz=tm.Z+3;local by=groundY(bx,bz)
 mk("VehicleStopBollard",Vector3.new(.7,3.1,.7),CFrame.new(bx,by+1.55,bz),Enum.Material.Wood,Color3.fromRGB(89,64,43),ForestEdge,0,true)
end

local treeCount=0
local function tree(x,z,s,variant)
 local y=groundY(x,z);local m=Instance.new("Model");m.Name="DenseGroundedTree";m.Parent=ForestEdge
 local bark=Color3.fromRGB(68+variant*2,50+variant,36)
 local leaf=variant%2==0 and Color3.fromRGB(38,73,39) or Color3.fromRGB(46,82,42)
 local h=(12+variant*.6)*s
 mk("Trunk",Vector3.new(1.15*s,h,1.15*s),CFrame.new(x,y+h*.5,z)*CFrame.Angles(0,0,math.rad((variant%5)-2)),Enum.Material.Wood,bark,m,0,true)
 local crown=Vector3.new(x,y+h*.78,z)
 for j=1,5 do
  local ang=(j-1)*1.256+variant*.17;local r=3.3*s+(j%2)*1.2*s
  local pos=crown+Vector3.new(math.cos(ang)*r,(j%3)*1.15*s,math.sin(ang)*r)
  beam("Branch",crown,pos,.28*s,Enum.Material.Wood,bark,m,false)
  local leafPart=mk("LeafMass",Vector3.new((4.2+(j%2))*s,(2.7+(j%3)*.35)*s,(3.7+(j%2)*.4)*s),CFrame.new(pos)*CFrame.Angles(math.rad((j%3)-1)*7,math.rad(j*31),math.rad((j%2)*6)),Enum.Material.LeafyGrass,leaf,m,0,false)
  leafPart.Shape=Enum.PartType.Ball
 end
 treeCount+=1
end

local forestPositions={
 {-8,390,1},{96,375,2},{4,345,3},{112,330,1},{8,305,2},{102,295,3},{0,270,4},{96,260,2},
 {-2,235,1},{87,230,3},{-5,205,2},{80,205,4},{-15,175,3},{72,170,1},
 {-35,140,2},{58,135,3},{-49,105,4},{42,100,2},{-58,70,1},{34,65,3},
 {-72,35,2},{24,30,4},{-82,0,3},{15,-5,1},{-94,-38,4},{5,-42,2},{-101,-72,1},{-31,-88,3}
}
for i,t in ipairs(forestPositions) do tree(t[1],t[2],.72+(t[3]%3)*.05,t[3]);if i%5==0 then task.wait() end end

local trailPts={{28,190},{10,155},{-10,118},{-26,77},{-35,34},{-51,-4},{-67,-39},{-82,-72}}
local trailDetail=0
for i=2,#trailPts do
 local a=trailPts[i-1];local b=trailPts[i]
 for s=1,4 do
  local t=s/5;local x=a[1]+(b[1]-a[1])*t;local z=a[2]+(b[2]-a[2])*t;local y=groundY(x,z)
  local side=((s+i)%2==0) and -1 or 1
  local dx=b[1]-a[1];local dz=b[2]-a[2];local mag=math.sqrt(dx*dx+dz*dz);local nx=-dz/mag;local nz=dx/mag
  local rx=x+nx*side*3.2;local rz=z+nz*side*3.2;local ry=groundY(rx,rz)
  local rock=mk("TrailStone",Vector3.new(1.1+(s%2)*.45,.65,1.25),CFrame.new(rx,ry+.26,rz)*CFrame.Angles(math.rad(7),math.rad(i*41+s*19),math.rad(5)),Enum.Material.Rock,Color3.fromRGB(91,90,82),ForestEdge,0,false);rock.Shape=Enum.PartType.Ball
  if s%2==0 then beam("TrailRoot",Vector3.new(x-1.5,y+.10,z),Vector3.new(x+1.7,y+.14,z+.5),.14,Enum.Material.Wood,Color3.fromRGB(76,56,39),ForestEdge,false) end
  trailDetail+=1
 end
end

local cp1=Vector3.new(-82,groundY(-82,-72),-72)
local hut=Instance.new("Model");hut.Name="POS1_Hut_v61";hut.Parent=POS1
local hcf=CFrame.new(cp1.X-15,cp1.Y,cp1.Z+7)*CFrame.Angles(0,math.rad(12),0)
mk("Foundation",Vector3.new(18,.75,12),hcf*CFrame.new(0,.32,0),Enum.Material.Rock,Color3.fromRGB(99,96,87),hut,0,true)
mk("Wall",Vector3.new(17,7.0,11),hcf*CFrame.new(0,3.8,0),Enum.Material.WoodPlanks,Color3.fromRGB(105,77,52),hut,0,true)
for _,sgn in ipairs({-1,1}) do mk("Roof",Vector3.new(10.5,.65,14),hcf*CFrame.new(sgn*3.9,8.15,0)*CFrame.Angles(0,0,math.rad(-sgn*27)),Enum.Material.Metal,Color3.fromRGB(65,70,66),hut,0,true) end
local ps=mk("POS1Board",Vector3.new(11.5,2.6,.4),CFrame.new(cp1.X+5,cp1.Y+5.2,cp1.Z-9),Enum.Material.WoodPlanks,Color3.fromRGB(71,52,36),POS1,0,false);textSign(ps,"POS 1  •  KAKI GUNUNG")
for _,sx in ipairs({-1,1}) do mk("GatePost",Vector3.new(1,7,1),CFrame.new(cp1.X+5+sx*5,cp1.Y+3.5,cp1.Z-9),Enum.Material.Wood,Color3.fromRGB(71,52,36),POS1,0,true) end
local cp=mk("CP01_POS1",Vector3.new(10,1,10),CFrame.new(cp1.X,cp1.Y+.6,cp1.Z),Enum.Material.SmoothPlastic,Color3.new(1,1,1),Checkpoints,1,false)
cp:SetAttribute("CheckpointIndex",1);cp:SetAttribute("CheckpointName","POS 1 - KAKI GUNUNG");cp:SetAttribute("SaveReady",true)

local function lamp(x,z)
 local y=groundY(x,z);local pole=mk("VillageLampPole",Vector3.new(.35,6.5,.35),CFrame.new(x,y+3.25,z),Enum.Material.Metal,Color3.fromRGB(65,62,56),Roadside,0,true)
 local head=mk("VillageLamp",Vector3.new(.9,.45,.9),CFrame.new(x,y+6.6,z),Enum.Material.Metal,Color3.fromRGB(76,71,62),Roadside,0,false)
 local l=Instance.new("PointLight");l.Brightness=1.2;l.Range=15;l.Color=Color3.fromRGB(255,205,145);l.Parent=head
 return pole
end
for _,z in ipairs({1000,830,665,500,335,195}) do lamp(roadX(z)-18,z) end

root:SetAttribute("CompositionPassVersion","6.1")
root:SetAttribute("CompositionScope","SPAWN_TO_CP1_ONLY")
root:SetAttribute("VillageHouseCount",houseCount)
root:SetAttribute("CloseRiceDetailCount",riceCount)
root:SetAttribute("VillageFenceDetailCount",fenceCount)
root:SetAttribute("RoadsideDetailCount",roadsideDetail)
root:SetAttribute("CompositionTreeCount",treeCount)
root:SetAttribute("CompositionTrailDetailCount",trailDetail)
root:SetAttribute("SpawnFraming","DENSE_VILLAGE_ROAD")
root:SetAttribute("Phase1VisualReady",true)
root:SetAttribute("BuildVersion","6.1.0-phase1-composition")
Workspace:SetAttribute("ACC_MountainBuild","v6.1-phase1-composition")
print("[ACC] v6.1 PHASE1 composition ready",houseCount,riceCount,treeCount,trailDetail)
