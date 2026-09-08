-- MOUNT BBYA — RUNTIME REBUILD v1.3
-- Goal: lowland spawn/village becomes playable first; upper mountain streams in afterwards.
-- Target identity is enforced by external builder/publisher. No Mountain Social code is used here.

local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Players=game:GetService("Players")
local Terrain=Workspace.Terrain

local ROOT_NAME="MOUNT_BBYA_REBUILD_V13"
local BUILD="runtime-rebuild-v1.3"
local old=Workspace:FindFirstChild(ROOT_NAME);if old then old:Destroy() end
local root=Instance.new("Folder");root.Name=ROOT_NAME;root.Parent=Workspace
root:SetAttribute("Project","MOUNT BBYA")
root:SetAttribute("BuildVersion",BUILD)
root:SetAttribute("RuntimeState","BUILDING_LOWLAND")
root:SetAttribute("StreamingArchitecture","LOWLAND_FIRST_UPPER_ASYNC")
root:SetAttribute("VisualLock","TROPICAL_INDONESIAN_MOUNTAIN_2026_09_08")

local folders={}
for _,name in ipairs({"Route","Village","Basecamp","Forest","Checkpoints","Valley","Cliff","HighCamp","Highland","Summit","Scenery"}) do
 local f=Instance.new("Folder");f.Name=name;f.Parent=root;folders[name]=f
end

math.randomseed(13092026)
local C={
 dirt=Color3.fromRGB(103,79,55),mud=Color3.fromRGB(78,65,49),leaf=Color3.fromRGB(45,91,46),leaf2=Color3.fromRGB(64,111,55),
 wood=Color3.fromRGB(93,66,43),woodDark=Color3.fromRGB(62,47,36),stone=Color3.fromRGB(86,87,82),stoneDark=Color3.fromRGB(60,62,59),
 wall=Color3.fromRGB(200,188,158),roof=Color3.fromRGB(104,63,44),sign=Color3.fromRGB(72,54,39),water=Color3.fromRGB(63,120,132),
 red=Color3.fromRGB(190,38,43),white=Color3.fromRGB(238,238,232),metal=Color3.fromRGB(91,96,93)
}

local function mk(name,size,cf,mat,col,parent,collide,tr)
 local p=Instance.new("Part");p.Name=name;p.Anchored=true;p.Size=size;p.CFrame=cf;p.Material=mat or Enum.Material.SmoothPlastic
 if col then p.Color=col end;p.CanCollide=collide~=false;p.Transparency=tr or 0;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or root;return p
end
local function cyl(name,pos,r,h,mat,col,parent,collide)
 local p=mk(name,Vector3.new(h,r*2,r*2),CFrame.new(pos)*CFrame.Angles(0,0,math.rad(90)),mat,col,parent,collide);p.Shape=Enum.PartType.Cylinder;return p
end
local function sphere(name,pos,size,mat,col,parent,collide)
 local p=mk(name,size,CFrame.new(pos)*CFrame.Angles(math.rad(math.random(-8,8)),math.rad(math.random(0,180)),math.rad(math.random(-8,8))),mat,col,parent,collide);p.Shape=Enum.PartType.Ball;return p
end
local function seg(name,a,b,w,h,mat,col,parent,collide)
 local d=b-a;if d.Magnitude<.1 then return nil end
 return mk(name,Vector3.new(w,h,d.Magnitude+1),CFrame.lookAt((a+b)*.5,b),mat,col,parent,collide)
end
local function board(name,pos,lookAt,w,h,text,parent)
 local p=mk(name,Vector3.new(w,h,.7),CFrame.lookAt(pos,lookAt),Enum.Material.WoodPlanks,C.sign,parent,true)
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(900,320);gui.Parent=p
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextScaled=true;t.TextWrapped=true;t.TextColor3=C.white;t.Font=Enum.Font.GothamBold;t.TextStrokeTransparency=.65;t.Parent=gui
 return p
end
local function sign(name,pos,lookAt,text,parent)
 cyl(name.."L",pos+Vector3.new(-5,-3,0),.45,7,Enum.Material.Wood,C.woodDark,parent,true)
 cyl(name.."R",pos+Vector3.new(5,-3,0),.45,7,Enum.Material.Wood,C.woodDark,parent,true)
 return board(name,pos,lookAt,13,5.5,text,parent)
end
local groundParams=RaycastParams.new();groundParams.FilterType=Enum.RaycastFilterType.Include;groundParams.FilterDescendantsInstances={Terrain};groundParams.IgnoreWater=true
local function groundY(x,z,fromY)
 local hit=Workspace:Raycast(Vector3.new(x,fromY or 1600,z),Vector3.new(0,-3000,0),groundParams);return hit and hit.Position.Y or nil
end

local route={
Vector3.new(0,24,1650),Vector3.new(40,27,1510),Vector3.new(-20,31,1380),Vector3.new(60,36,1260),Vector3.new(-50,44,1160),
Vector3.new(-180,57,1070),Vector3.new(-320,72,990),Vector3.new(-450,90,900),Vector3.new(-520,112,790),Vector3.new(-420,137,680),
Vector3.new(-260,162,600),Vector3.new(-80,187,540),Vector3.new(120,207,500),Vector3.new(300,227,430),Vector3.new(430,247,340),
Vector3.new(360,267,240),Vector3.new(190,284,155),Vector3.new(0,302,100),Vector3.new(-190,324,20),Vector3.new(-350,347,-80),
Vector3.new(-430,372,-190),Vector3.new(-350,397,-300),Vector3.new(-170,422,-390),Vector3.new(30,447,-470),Vector3.new(230,472,-540),
Vector3.new(400,502,-630),Vector3.new(480,537,-740),Vector3.new(390,572,-850),Vector3.new(210,607,-920),Vector3.new(20,642,-980),
Vector3.new(-180,677,-1040),Vector3.new(-350,712,-1130),Vector3.new(-430,750,-1240),Vector3.new(-360,787,-1350),Vector3.new(-190,822,-1440),
Vector3.new(20,852,-1500),Vector3.new(220,882,-1560),Vector3.new(390,912,-1650),Vector3.new(450,942,-1760),Vector3.new(360,972,-1870),
Vector3.new(190,1002,-1950),Vector3.new(0,1030,-2010)}
local routeStuds=0;for i=1,#route-1 do routeStuds+=(route[i+1]-route[i]).Magnitude end
root:SetAttribute("RouteStuds",math.floor(routeStuds));root:SetAttribute("RouteNodeCount",#route)

local function trailWidth(i)
 if i<5 then return 20 elseif i<17 then return 14 elseif i<24 then return 12 elseif i<34 then return 9 else return 8 end
end
local trails={};local trailCount=0
local function ridgeRadius(i)
 if i<=8 then return 145 elseif i<=17 then return 135 elseif i<=25 then return 125 elseif i<=34 then return 112 else return 100 end
end
local function buildRidgeNode(i)
 local p=route[i];local r=ridgeRadius(i);local mat=i>=29 and Enum.Material.Rock or Enum.Material.Grass
 Terrain:FillBall(p-Vector3.new(0,r*.62,0),r,mat)
 if i>1 and i<#route and i%2==0 then
  local flat=Vector3.new(route[i+1].X-route[i-1].X,0,route[i+1].Z-route[i-1].Z)
  if flat.Magnitude>1 then
   local side=Vector3.new(-flat.Z,0,flat.X).Unit
   Terrain:FillBall(p+side*r*.78-Vector3.new(0,r*.72,0),r*.64,mat)
   Terrain:FillBall(p-side*r*.78-Vector3.new(0,r*.76,0),r*.60,mat)
  end
 end
end
local function buildTrailSegment(i)
 local a,b=route[i],route[i+1];local d=b-a;local w=trailWidth(i);local cf=CFrame.lookAt((a+b)*.5,b)
 Terrain:FillBlock(cf*CFrame.new(0,4.2,0),Vector3.new(w+16,12,d.Magnitude+4),Enum.Material.Air)
 Terrain:FillBlock(cf*CFrame.new(0,-2.7,0),Vector3.new(w+8,6,d.Magnitude+4),i>=29 and Enum.Material.Rock or Enum.Material.Ground)
 local mat=i>=29 and Enum.Material.Slate or (i>=17 and Enum.Material.Mud or Enum.Material.Ground)
 local col=i>=29 and C.stone or (i>=17 and C.mud or C.dirt)
 local p=seg(string.format("Trail_%02d",i),a+Vector3.new(0,.05,0),b+Vector3.new(0,.05,0),w,1.05,mat,col,folders.Route,true)
 if p then p:SetAttribute("RouteIndex",i);trails[i]=p;trailCount+=1 end
end

-- LOWLAND FIRST: small foundation + first ridge only. No giant full-map FillBall.
Terrain:Clear();Terrain.WaterColor=Color3.fromRGB(53,103,111);Terrain.WaterTransparency=.25;Terrain.WaterWaveSize=.1;Terrain.WaterWaveSpeed=6
Terrain:FillBlock(CFrame.new(0,-20,1390),Vector3.new(1050,90,1180),Enum.Material.Grass)
for i=1,8 do buildRidgeNode(i);if i%2==0 then task.wait() end end
for i=1,7 do buildTrailSegment(i);if i%3==0 then task.wait() end end
root:SetAttribute("TerrainArchitecture","RIDGE_CHAIN_LOWLAND_FIRST")

local function hut(name,pos,yaw,scale,parent,wallCol)
 scale=scale or 1;local m=Instance.new("Model");m.Name=name;m.Parent=parent;local cf=CFrame.new(pos)*CFrame.Angles(0,math.rad(yaw),0)
 mk("Foundation",Vector3.new(24*scale,1.2,18*scale),cf*CFrame.new(0,.6,0),Enum.Material.Rock,C.stone,m,true)
 mk("Walls",Vector3.new(22*scale,10*scale,16*scale),cf*CFrame.new(0,6*scale,0),Enum.Material.Brick,wallCol or C.wall,m,true)
 mk("RoofL",Vector3.new(14*scale,.8,21*scale),cf*CFrame.new(-5*scale,13*scale,0)*CFrame.Angles(0,0,math.rad(28)),Enum.Material.WoodPlanks,C.roof,m,true)
 mk("RoofR",Vector3.new(14*scale,.8,21*scale),cf*CFrame.new(5*scale,13*scale,0)*CFrame.Angles(0,0,math.rad(-28)),Enum.Material.WoodPlanks,C.roof,m,true)
 mk("Door",Vector3.new(4*scale,7*scale,.5),cf*CFrame.new(0,4*scale,-8.25*scale),Enum.Material.Wood,C.woodDark,m,false)
 return m
end
local function tree(pos,scale,parent)
 local m=Instance.new("Model");m.Name="Tree";m.Parent=parent
 cyl("Trunk",pos+Vector3.new(0,6*scale,0),1.05*scale,12*scale,Enum.Material.Wood,C.woodDark,m,true)
 sphere("CrownA",pos+Vector3.new(0,14*scale,0),Vector3.new(10,8,10)*scale,Enum.Material.LeafyGrass,C.leaf,m,false)
 sphere("CrownB",pos+Vector3.new(4*scale,12.5*scale,1*scale),Vector3.new(8,7,8)*scale,Enum.Material.LeafyGrass,C.leaf2,m,false)
end
local function tent(name,pos,yaw,parent,col)
 local m=Instance.new("Model");m.Name=name;m.Parent=parent;local cf=CFrame.new(pos)*CFrame.Angles(0,math.rad(yaw),0);col=col or Color3.fromRGB(167,119,63)
 mk("Floor",Vector3.new(10,.6,9),cf*CFrame.new(0,.3,0),Enum.Material.Fabric,col,m,true)
 mk("FlyL",Vector3.new(7.2,.35,10),cf*CFrame.new(-2.6,3.1,0)*CFrame.Angles(0,0,math.rad(50)),Enum.Material.Fabric,col,m,false)
 mk("FlyR",Vector3.new(7.2,.35,10),cf*CFrame.new(2.6,3.1,0)*CFrame.Angles(0,0,math.rad(-50)),Enum.Material.Fabric,col,m,false)
end
local function campfire(name,pos,parent)
 local m=Instance.new("Model");m.Name=name;m.Parent=parent
 for r=1,3 do mk("Log",Vector3.new(7,1,1),CFrame.new(pos+Vector3.new(0,.6,0))*CFrame.Angles(0,math.rad(r*60),0),Enum.Material.Wood,C.woodDark,m,false) end
 local flame=sphere("Flame",pos+Vector3.new(0,2,0),Vector3.new(2.2,4,2.2),Enum.Material.Neon,Color3.fromRGB(236,129,42),m,false);flame.Transparency=.15
 local l=Instance.new("PointLight");l.Range=20;l.Brightness=2;l.Color=Color3.fromRGB(255,169,88);l.Parent=flame
end

-- Spawn village is guaranteed before players are released from temporary staging.
mk("VillageRoad",Vector3.new(38,1.2,330),CFrame.new(0,24.2,1510),Enum.Material.Pavement,Color3.fromRGB(74,76,73),folders.Village,true)
for _,s in ipairs({{-130,25,1590,8,1},{130,25,1580,-10,1},{-165,25,1490,12,1.1},{160,25,1460,-8,1},{-145,26,1380,7,.95},{145,27,1360,-7,1.05}}) do hut("RumahWarga",Vector3.new(s[1],s[2],s[3]),s[4],s[5],folders.Village) end
hut("Warung",Vector3.new(-72,25,1320),5,1.15,folders.Village,Color3.fromRGB(205,177,122))
sign("WarungSign",Vector3.new(-72,37,1306),Vector3.new(-72,37,1260),"WARUNG PENDAKI",folders.Village)
mk("Parking",Vector3.new(95,1,72),CFrame.new(92,24.1,1325),Enum.Material.Concrete,Color3.fromRGB(112,112,104),folders.Village,true)
for i=1,4 do mk("PendakiVehicle",Vector3.new(15,5,7),CFrame.new(60+(i-1)*22,27.1,1310+(i%2)*22),Enum.Material.Metal,i%2==0 and Color3.fromRGB(216,216,204) or Color3.fromRGB(80,92,91),folders.Village,true) end
mk("GateL",Vector3.new(3,18,3),CFrame.new(-19,33,1245),Enum.Material.WoodPlanks,C.woodDark,folders.Village,true)
mk("GateR",Vector3.new(3,18,3),CFrame.new(19,33,1245),Enum.Material.WoodPlanks,C.woodDark,folders.Village,true)
board("Welcome",Vector3.new(0,40,1245),Vector3.new(0,40,1200),42,7,"SELAMAT DATANG DI MOUNT BBYA",folders.Village)
local spawn=Instance.new("SpawnLocation");spawn.Name="MountBBYA_Spawn";spawn.Anchored=true;spawn.CanCollide=true;spawn.Neutral=true;spawn.Duration=0;spawn.Size=Vector3.new(16,1,16);spawn.CFrame=CFrame.new(route[1]+Vector3.new(0,1.2,0));spawn.Material=Enum.Material.Slate;spawn.Transparency=.1;spawn.Parent=root

hut("RegistrasiBasecamp",route[5]+Vector3.new(-35,2,20),-15,1.25,folders.Basecamp,Color3.fromRGB(188,176,148))
sign("BasecampTitle",route[5]+Vector3.new(10,16,15),route[6],"BASECAMP MOUNT BBYA\nREGISTRASI • PERALATAN • CAMPING",folders.Basecamp)
mk("BasecampDeck",Vector3.new(90,1.2,55),CFrame.new(route[5]+Vector3.new(28,-.3,-18)),Enum.Material.WoodPlanks,C.wood,folders.Basecamp,true)
for i=1,4 do tent("BaseTent_"..i,route[5]+Vector3.new(45+(i%2)*16,2,-35-math.floor((i-1)/2)*16),i*8,folders.Basecamp,i%2==0 and Color3.fromRGB(90,111,72) or Color3.fromRGB(177,112,61)) end
campfire("BasecampFire",route[5]+Vector3.new(30,2,-10),folders.Basecamp)
for i=1,28 do local x=math.random(-320,320);local z=math.random(1260,1720);local y=groundY(x,z,450);if y and math.abs(x)>45 then tree(Vector3.new(x,y,z),math.random(72,110)/100,folders.Forest) end end

root:SetAttribute("VillageReady",true);root:SetAttribute("BasecampReady",true);root:SetAttribute("LowlandReady",true);root:SetAttribute("RuntimeState","LOWLAND_READY")
Workspace:SetAttribute("MOUNT_BBYA_BUILD",BUILD);Workspace:SetAttribute("MOUNT_BBYA_LOWLAND_READY",true)
print("[MOUNT BBYA] v1.3 LOWLAND_READY")

-- Checkpoint state is ready even while upper terrain streams.
local cpSpecs={{1,17,"POS 1"},{2,25,"POS 2"},{3,31,"POS 3 / HIGH CAMP"},{4,42,"PUNCAK"}}
local cpCFrames={}
local function bindPlayer(plr)
 if plr:GetAttribute("MountBBYACheckpoint")==nil then plr:SetAttribute("MountBBYACheckpoint",0) end
 plr.CharacterAdded:Connect(function(ch) task.wait(.35);local cp=plr:GetAttribute("MountBBYACheckpoint") or 0;local cf=cpCFrames[cp];if cf and ch.Parent then ch:PivotTo(cf) end end)
end
for _,p in ipairs(Players:GetPlayers()) do bindPlayer(p) end;Players.PlayerAdded:Connect(bindPlayer)

local function buildCheckpoint(idx,ri,title)
 local p=route[ri];local m=Instance.new("Model");m.Name="Checkpoint_"..idx;m.Parent=folders.Checkpoints
 local pad=mk("Trigger",Vector3.new(24,1.1,18),CFrame.new(p+Vector3.new(0,.5,0)),Enum.Material.Slate,idx==4 and Color3.fromRGB(101,98,90) or Color3.fromRGB(76,99,69),m,true)
 pad:SetAttribute("CheckpointIndex",idx);pad:SetAttribute("CheckpointName",title);sign("Sign",p+Vector3.new(0,12,-10),route[math.max(1,ri-1)],title,m);cpCFrames[idx]=CFrame.new(p+Vector3.new(0,5,0))
 pad.Touched:Connect(function(hit) local ch=hit and hit.Parent;local plr=ch and Players:GetPlayerFromCharacter(ch);if plr then local oldCp=plr:GetAttribute("MountBBYACheckpoint") or 0;if idx>oldCp then plr:SetAttribute("MountBBYACheckpoint",idx);plr:SetAttribute("MountBBYALastCheckpointName",title) end end end)
end

-- UPPER WORLD: moderate ridge nodes, yielding frequently so the server never freezes on giant terrain edits.
task.spawn(function()
 root:SetAttribute("RuntimeState","BUILDING_UPPER")
 for i=9,#route do buildRidgeNode(i);if i%2==0 then task.wait(.03) end end
 for i=8,#route-1 do buildTrailSegment(i);if i%3==0 then task.wait(.03) end end

 -- forest corridor
 local treeCount=28
 for i=7,23 do local p,n=route[i],route[i+1];local flat=Vector3.new(n.X-p.X,0,n.Z-p.Z);if flat.Magnitude>1 then local side=Vector3.new(-flat.Z,0,flat.X).Unit;for k=1,3 do local s=k%2==0 and -1 or 1;local off=side*s*math.random(30,92)+flat.Unit*math.random(-35,35);local x,z=p.X+off.X,p.Z+off.Z;local y=groundY(x,z,1500);if y then tree(Vector3.new(x,y,z),math.random(78,120)/100,folders.Forest);treeCount+=1 end end end;if i%4==0 then task.wait() end end
 sign("ForestSign",route[10]+Vector3.new(18,13,12),route[11],"JALUR HUTAN TROPIS",folders.Forest)

 buildCheckpoint(1,17,"POS 1");hut("Pos1Shelter",route[17]+Vector3.new(30,1,25),35,.75,folders.Checkpoints,Color3.fromRGB(163,151,126))

 -- valley and bridge
 local riverCenter=Vector3.new(-330,325,-115);Terrain:FillBlock(CFrame.new(riverCenter+Vector3.new(0,-6,0))*CFrame.Angles(0,math.rad(-12),0),Vector3.new(210,18,68),Enum.Material.Air);Terrain:FillBlock(CFrame.new(riverCenter+Vector3.new(0,-11,0))*CFrame.Angles(0,math.rad(-12),0),Vector3.new(210,8,54),Enum.Material.Water)
 if trails[19] then trails[19].Transparency=1;trails[19].CanCollide=false end;if trails[20] then trails[20].Transparency=1;trails[20].CanCollide=false end
 local a,b=route[19],route[21];local dir=b-a;local cf=CFrame.lookAt((a+b)*.5,b);local plankCount=math.floor(dir.Magnitude/7)
 for i=0,plankCount do local p=a:Lerp(b,i/math.max(1,plankCount))+Vector3.new(0,2,0);mk("BridgePlank",Vector3.new(11,.75,5.5),CFrame.lookAt(p,p+dir),Enum.Material.WoodPlanks,C.wood,folders.Valley,true) end
 for _,ss in ipairs({-1,1}) do local off=cf.RightVector*ss*6;seg("BridgeRail",a+off+Vector3.new(0,6,0),b+off+Vector3.new(0,6,0),.45,.45,Enum.Material.Metal,C.metal,folders.Valley,false) end
 sign("ValleySign",route[20]+Vector3.new(30,13,15),route[21],"LEMBAH & SUNGAI\nJEMBATAN GANTUNG",folders.Valley)

 buildCheckpoint(2,25,"POS 2");hut("Pos2Shelter",route[25]+Vector3.new(-30,1,22),-25,.7,folders.Checkpoints,Color3.fromRGB(151,145,129));tent("Pos2Tent",route[25]+Vector3.new(30,1,22),20,folders.Checkpoints,Color3.fromRGB(91,110,71))
 for i=25,32 do local a2,b2=route[i],route[i+1];local flat=Vector3.new(b2.X-a2.X,0,b2.Z-a2.Z);if flat.Magnitude>1 then local side=Vector3.new(-flat.Z,0,flat.X).Unit;local off=side*((i%3==0) and -6.5 or 6.5);seg("CliffRope",a2+off+Vector3.new(0,5,0),b2+off+Vector3.new(0,5,0),.38,.38,Enum.Material.Metal,Color3.fromRGB(117,106,85),folders.Cliff,false);cyl("CliffPost",a2+off+Vector3.new(0,2.5,0),.32,5,Enum.Material.Wood,C.woodDark,folders.Cliff,true) end end
 sign("CliffSign",route[28]+Vector3.new(25,14,15),route[29],"JALUR TEBING",folders.Cliff)

 buildCheckpoint(3,31,"POS 3 / HIGH CAMP");local hc=route[31];hut("HighCampShelter",hc+Vector3.new(-38,1,26),10,.78,folders.HighCamp,Color3.fromRGB(142,139,127));for i=1,5 do tent("HighTent_"..i,hc+Vector3.new(18+(i%3)*18,1,10-math.floor((i-1)/3)*20),i*12,folders.HighCamp,i%2==0 and Color3.fromRGB(116,83,61) or Color3.fromRGB(76,99,69)) end;campfire("HighCampFire",hc+Vector3.new(0,2,18),folders.HighCamp)

 local rockCount=0
 for i=31,#route do local p=route[i];local n=route[math.min(#route,i+1)];local flat=Vector3.new(n.X-p.X,0,n.Z-p.Z);if flat.Magnitude>1 then local side=Vector3.new(-flat.Z,0,flat.X).Unit;for k=1,3 do local s=k%2==0 and -1 or 1;local q=p+side*s*math.random(18,70)+flat.Unit*math.random(-40,40)+Vector3.new(0,math.random(-2,6),0);sphere("VolcanicRock",q,Vector3.new(math.random(6,16),math.random(4,12),math.random(7,18)),Enum.Material.Slate,k%2==0 and C.stoneDark or C.stone,folders.Highland,true);rockCount+=1 end end;if i%4==0 then task.wait() end end
 sign("HighlandSign",route[35]+Vector3.new(-28,14,10),route[36],"ZONA PEGUNUNGAN TINGGI",folders.Highland)
 for i=36,#route-1,2 do cyl("SummitMarker",route[i]+Vector3.new(0,3,0),.35,6,Enum.Material.Wood,C.woodDark,folders.Summit,true) end
 buildCheckpoint(4,42,"PUNCAK");local summit=route[#route];mk("SummitDeck",Vector3.new(70,1.2,48),CFrame.new(summit+Vector3.new(0,.5,0)),Enum.Material.Slate,Color3.fromRGB(79,80,76),folders.Summit,true);sign("SummitBoard",summit+Vector3.new(0,13,-18),route[#route-1],"MOUNT BBYA\nPUNCAK • 2.487 MDPL",folders.Summit);cyl("FlagPole",summit+Vector3.new(28,10,5),.45,20,Enum.Material.Metal,Color3.fromRGB(150,150,145),folders.Summit,true);mk("FlagRed",Vector3.new(12,3.5,.25),CFrame.new(summit+Vector3.new(34,17.3,5)),Enum.Material.Fabric,C.red,folders.Summit,false);mk("FlagWhite",Vector3.new(12,3.5,.25),CFrame.new(summit+Vector3.new(34,13.8,5)),Enum.Material.Fabric,C.white,folders.Summit,false)

 root:SetAttribute("TreeCount",treeCount);root:SetAttribute("RockCount",rockCount);root:SetAttribute("TrailSegmentCount",trailCount);root:SetAttribute("CheckpointCount",4);root:SetAttribute("FullRouteZones",11);root:SetAttribute("RuntimeState","READY")
 Workspace:SetAttribute("MOUNT_BBYA_FULL_READY",true)
 print(string.format("[MOUNT BBYA] v1.3 FULL_READY route=%d trail=%d trees=%d rocks=%d",math.floor(routeStuds),trailCount,treeCount,rockCount))
end)

-- fall rescue while streaming
 task.spawn(function()
 while root.Parent do
  for _,plr in ipairs(Players:GetPlayers()) do local ch=plr.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart");if hrp and hrp.Position.Y<-60 then local cp=plr:GetAttribute("MountBBYACheckpoint") or 0;ch:PivotTo(cpCFrames[cp] or (spawn.CFrame+Vector3.new(0,5,0)));hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero end end
  task.wait(.7)
 end
 end)

Lighting.ClockTime=7.1;Lighting.Brightness=2.35;Lighting.GlobalShadows=true;Lighting.OutdoorAmbient=Color3.fromRGB(112,118,110);Lighting.Ambient=Color3.fromRGB(84,89,84)
for _,n in ipairs({"MountBBYA_Atmosphere","MountBBYA_Color","MountBBYA_Bloom"}) do local e=Lighting:FindFirstChild(n);if e then e:Destroy() end end
local at=Instance.new("Atmosphere");at.Name="MountBBYA_Atmosphere";at.Density=.23;at.Offset=.04;at.Color=Color3.fromRGB(205,219,211);at.Decay=Color3.fromRGB(113,128,119);at.Glare=.06;at.Haze=1.35;at.Parent=Lighting
local cc=Instance.new("ColorCorrectionEffect");cc.Name="MountBBYA_Color";cc.Brightness=.02;cc.Contrast=.07;cc.Saturation=.04;cc.TintColor=Color3.fromRGB(246,244,230);cc.Parent=Lighting
