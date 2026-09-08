-- MOUNT BBYA — VISUAL LOCK REBUILD v1.1
-- Active rebuild candidate. Target: Universe 4187755690 / Place 11832985967 only.
-- Visual progression: Desa -> Basecamp -> Hutan Tropis -> Pos 1 -> Lembah & Sungai -> Pos 2 -> Jalur Tebing -> Pos 3 / High Camp -> Pegunungan Tinggi -> Jalur Summit -> Puncak.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Terrain = Workspace.Terrain

local ROOT_NAME = "MOUNT_BBYA_REBUILD_V11"
local BUILD = "visual-lock-rebuild-v1.1"
local old = Workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = Workspace
root:SetAttribute("Project", "MOUNT BBYA")
root:SetAttribute("BuildVersion", BUILD)
root:SetAttribute("VisualLock", "TROPICAL_INDONESIAN_MOUNTAIN_2026_09_08")
root:SetAttribute("ForbiddenProjectTouched", false)
root:SetAttribute("GroundedTrailArchitecture", true)
root:SetAttribute("RuntimeState", "BUILDING")

local folders = {}
for _, name in ipairs({"Route","Village","Basecamp","Forest","Checkpoints","Valley","Cliff","HighCamp","Highland","Summit","Scenery"}) do
    local f = Instance.new("Folder")
    f.Name = name
    f.Parent = root
    folders[name] = f
end

math.randomseed(8092026)

local color = {
    dirt=Color3.fromRGB(105,82,57), mud=Color3.fromRGB(82,69,52), leaf=Color3.fromRGB(44,92,47),
    leaf2=Color3.fromRGB(65,112,55), wood=Color3.fromRGB(92,65,43), woodDark=Color3.fromRGB(63,48,37),
    stone=Color3.fromRGB(83,84,80), stoneDark=Color3.fromRGB(58,60,58), wall=Color3.fromRGB(201,188,158),
    roof=Color3.fromRGB(105,61,43), metal=Color3.fromRGB(84,89,86), sign=Color3.fromRGB(73,54,38),
    water=Color3.fromRGB(72,126,139), red=Color3.fromRGB(190,38,43), white=Color3.fromRGB(235,235,229)
}

local function mk(name,size,cf,material,col,parent,canCollide,transparency)
    local p=Instance.new("Part")
    p.Name=name;p.Anchored=true;p.Size=size;p.CFrame=cf;p.Material=material or Enum.Material.SmoothPlastic
    if col then p.Color=col end
    p.CanCollide=canCollide~=false;p.Transparency=transparency or 0;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent or root
    return p
end

local function cyl(name,pos,r,h,material,col,parent,collide)
    local p=mk(name,Vector3.new(h,r*2,r*2),CFrame.new(pos)*CFrame.Angles(0,0,math.rad(90)),material,col,parent,collide)
    p.Shape=Enum.PartType.Cylinder
    return p
end

local function sphere(name,pos,size,material,col,parent,collide)
    local p=mk(name,size,CFrame.new(pos)*CFrame.Angles(math.rad(math.random(-10,10)),math.rad(math.random(0,180)),math.rad(math.random(-10,10))),material,col,parent,collide)
    p.Shape=Enum.PartType.Ball
    return p
end

local function segment(name,a,b,width,height,material,col,parent,collide)
    local d=b-a
    if d.Magnitude<0.1 then return nil end
    return mk(name,Vector3.new(width,height,d.Magnitude+1),CFrame.lookAt((a+b)*0.5,b),material,col,parent,collide)
end

local function board(name,pos,lookAt,width,height,text,parent)
    local p=mk(name,Vector3.new(width,height,.7),CFrame.lookAt(pos,lookAt),Enum.Material.WoodPlanks,color.sign,parent,true)
    local gui=Instance.new("SurfaceGui");gui.Name="Label";gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(900,320);gui.Parent=p
    local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Text=text;label.TextScaled=true;label.TextWrapped=true
    label.TextColor3=color.white;label.Font=Enum.Font.GothamBold;label.TextStrokeTransparency=.65;label.Parent=gui
    return p
end

local function sign(name,pos,lookAt,text,parent)
    cyl(name.."_L",pos+Vector3.new(-5,-3,0),.45,7,Enum.Material.Wood,color.woodDark,parent,true)
    cyl(name.."_R",pos+Vector3.new(5,-3,0),.45,7,Enum.Material.Wood,color.woodDark,parent,true)
    return board(name,pos,lookAt,13,5.5,text,parent)
end

local groundParams=RaycastParams.new()
groundParams.FilterType=Enum.RaycastFilterType.Include
groundParams.FilterDescendantsInstances={Terrain}
groundParams.IgnoreWater=true
local function groundY(x,z,fromY)
    local hit=Workspace:Raycast(Vector3.new(x,fromY or 1500,z),Vector3.new(0,-2600,0),groundParams)
    return hit and hit.Position.Y or nil
end

-- ~7.1k studs of connected hiking route; checkpoints are intentionally far apart.
local route={
Vector3.new(0,24,1650),Vector3.new(40,25,1510),Vector3.new(-20,28,1380),Vector3.new(60,33,1260),Vector3.new(-50,42,1160),
Vector3.new(-180,55,1070),Vector3.new(-320,70,990),Vector3.new(-450,88,900),Vector3.new(-520,110,790),Vector3.new(-420,135,680),
Vector3.new(-260,160,600),Vector3.new(-80,185,540),Vector3.new(120,205,500),Vector3.new(300,225,430),Vector3.new(430,245,340),
Vector3.new(360,265,240),Vector3.new(190,282,155),Vector3.new(0,300,100),Vector3.new(-190,322,20),Vector3.new(-350,345,-80),
Vector3.new(-430,370,-190),Vector3.new(-350,395,-300),Vector3.new(-170,420,-390),Vector3.new(30,445,-470),Vector3.new(230,470,-540),
Vector3.new(400,500,-630),Vector3.new(480,535,-740),Vector3.new(390,570,-850),Vector3.new(210,605,-920),Vector3.new(20,640,-980),
Vector3.new(-180,675,-1040),Vector3.new(-350,710,-1130),Vector3.new(-430,748,-1240),Vector3.new(-360,785,-1350),Vector3.new(-190,820,-1440),
Vector3.new(20,850,-1500),Vector3.new(220,880,-1560),Vector3.new(390,910,-1650),Vector3.new(450,940,-1760),Vector3.new(360,970,-1870),
Vector3.new(190,1000,-1950),Vector3.new(0,1028,-2010)
}

local routeStuds=0
for i=1,#route-1 do routeStuds += (route[i+1]-route[i]).Magnitude end
root:SetAttribute("RouteStuds",math.floor(routeStuds));root:SetAttribute("RouteNodeCount",#route)

-- TERRAIN FIRST: broad mountain -> route carve -> guaranteed subgrade -> tread.
Terrain:Clear()
Terrain.WaterColor=Color3.fromRGB(55,105,112);Terrain.WaterTransparency=.25;Terrain.WaterWaveSize=.12;Terrain.WaterWaveSpeed=7
Terrain:FillBlock(CFrame.new(0,-22,450),Vector3.new(2300,70,3900),Enum.Material.Grass)
for _,m in ipairs({
    {0,960,880,260,"grass"},{40,380,980,510,"grass"},{-30,-330,930,730,"grass"},{20,-1030,830,920,"rock"},{0,-1670,690,1085,"rock"},
    {-620,670,380,240,"grass"},{610,530,410,300,"grass"},{-650,50,460,460,"grass"},{650,-100,440,500,"grass"},
    {-620,-620,410,650,"rock"},{610,-710,390,690,"rock"},{-560,-1200,360,820,"rock"},{540,-1270,350,850,"rock"},
    {-410,-1700,310,980,"rock"},{420,-1760,290,990,"rock"}
}) do
    Terrain:FillBall(Vector3.new(m[1],m[4]-m[3],m[2]),m[3],m[5]=="rock" and Enum.Material.Rock or Enum.Material.Grass)
end
Terrain:FillBlock(CFrame.new(0,17,1530),Vector3.new(720,45,430),Enum.Material.Grass)
Terrain:FillBlock(CFrame.new(-45,36,1190),Vector3.new(470,52,300),Enum.Material.Grass)

local function trailWidth(i)
    if i<5 then return 20 elseif i<17 then return 14 elseif i<24 then return 12 elseif i<34 then return 9 else return 8 end
end
local trails={};local trailCount=0
for i=1,#route-1 do
    local a,b=route[i],route[i+1];local d=b-a;local w=trailWidth(i);local cf=CFrame.lookAt((a+b)*.5,b)
    Terrain:FillBlock(cf*CFrame.new(0,5,0),Vector3.new(w+24,18,d.Magnitude+5),Enum.Material.Air)
    Terrain:FillBlock(cf*CFrame.new(0,-3.3,0),Vector3.new(w+10,8,d.Magnitude+5),i>=31 and Enum.Material.Rock or Enum.Material.Ground)
    local material=i>=31 and Enum.Material.Slate or (i>=17 and Enum.Material.Mud or Enum.Material.Ground)
    local col=i>=31 and color.stone or (i>=17 and color.mud or color.dirt)
    local tread=segment(string.format("Trail_%02d",i),a+Vector3.new(0,.05,0),b+Vector3.new(0,.05,0),w,1.15,material,col,folders.Route,true)
    if tread then tread:SetAttribute("RouteIndex",i);trails[i]=tread;trailCount+=1 end
end
root:SetAttribute("TerrainArchitecture","FOUNDATION_CARVE_SUBGRADE_TRAIL")

for i=5,#route-2,2 do
    local p,n=route[i],route[i+1];local flat=Vector3.new(n.X-p.X,0,n.Z-p.Z)
    if flat.Magnitude>1 then
        local side=Vector3.new(-flat.Z,0,flat.X).Unit
        for _,s in ipairs({-1,1}) do
            local q=p+side*s*(trailWidth(i)*.65+math.random(2,7))
            sphere("TrailEdgeRock",q+Vector3.new(0,math.random(-1,2),0),Vector3.new(math.random(5,10),math.random(3,7),math.random(5,12)),Enum.Material.Rock,color.stoneDark,folders.Scenery,true)
        end
    end
end

local function hut(name,pos,yaw,scale,parent,wallCol)
    scale=scale or 1
    local m=Instance.new("Model");m.Name=name;m.Parent=parent
    local cf=CFrame.new(pos)*CFrame.Angles(0,math.rad(yaw),0)
    mk("Foundation",Vector3.new(24*scale,1.2,18*scale),cf*CFrame.new(0,.6,0),Enum.Material.Rock,color.stone,m,true)
    mk("Walls",Vector3.new(22*scale,10*scale,16*scale),cf*CFrame.new(0,6*scale,0),Enum.Material.Brick,wallCol or color.wall,m,true)
    mk("RoofL",Vector3.new(14*scale,.8,21*scale),cf*CFrame.new(-5*scale,13*scale,0)*CFrame.Angles(0,0,math.rad(28)),Enum.Material.WoodPlanks,color.roof,m,true)
    mk("RoofR",Vector3.new(14*scale,.8,21*scale),cf*CFrame.new(5*scale,13*scale,0)*CFrame.Angles(0,0,math.rad(-28)),Enum.Material.WoodPlanks,color.roof,m,true)
    mk("Door",Vector3.new(4*scale,7*scale,.5),cf*CFrame.new(0,4*scale,-8.25*scale),Enum.Material.Wood,color.woodDark,m,false)
    mk("WindowL",Vector3.new(4*scale,3*scale,.35),cf*CFrame.new(-6*scale,6.5*scale,-8.3*scale),Enum.Material.Glass,Color3.fromRGB(139,171,173),m,false,.2)
    mk("WindowR",Vector3.new(4*scale,3*scale,.35),cf*CFrame.new(6*scale,6.5*scale,-8.3*scale),Enum.Material.Glass,Color3.fromRGB(139,171,173),m,false,.2)
    return m
end

-- DESA / SPAWN
mk("VillageRoad",Vector3.new(38,1.2,350),CFrame.new(0,24.2,1510),Enum.Material.Pavement,Color3.fromRGB(74,76,73),folders.Village,true)
for _,s in ipairs({{-130,25,1590,8,1},{130,25,1580,-10,1},{-165,25,1490,12,1.15},{160,25,1460,-8,1},{-145,26,1380,7,.95},{145,27,1360,-7,1.05}}) do
    hut("RumahWarga",Vector3.new(s[1],s[2],s[3]),s[4],s[5],folders.Village)
end
hut("Warung_Mbak_Sari",Vector3.new(-70,25,1315),5,1.15,folders.Village,Color3.fromRGB(205,177,122))
sign("Warung",Vector3.new(-70,37,1304),Vector3.new(-70,37,1260),"WARUNG\nMBAK SARI",folders.Village)
mk("Parking",Vector3.new(95,1,75),CFrame.new(92,24.1,1320),Enum.Material.Concrete,Color3.fromRGB(112,112,104),folders.Village,true)
for i=1,4 do
    local x=60+(i-1)*22;local z=1310+(i%2)*22
    mk("PendakiVehicle",Vector3.new(15,5,7),CFrame.new(x,27.1,z),Enum.Material.Metal,i%2==0 and Color3.fromRGB(218,218,205) or Color3.fromRGB(80,92,91),folders.Village,true)
end
sign("ParkingSign",Vector3.new(92,34,1275),Vector3.new(92,34,1230),"PARKIR PENDAKI",folders.Village)
mk("GateL",Vector3.new(3,18,3),CFrame.new(-19,33,1245),Enum.Material.WoodPlanks,color.woodDark,folders.Village,true)
mk("GateR",Vector3.new(3,18,3),CFrame.new(19,33,1245),Enum.Material.WoodPlanks,color.woodDark,folders.Village,true)
board("Welcome",Vector3.new(0,40,1245),Vector3.new(0,40,1200),42,7,"SELAMAT DATANG DI MOUNT BBYA",folders.Village)

local spawn=Instance.new("SpawnLocation")
spawn.Name="MountBBYA_Spawn";spawn.Anchored=true;spawn.CanCollide=true;spawn.Neutral=true;spawn.Duration=0;spawn.Size=Vector3.new(16,1,16)
spawn.CFrame=CFrame.new(route[1]+Vector3.new(0,1.2,0));spawn.Material=Enum.Material.Slate;spawn.Color=Color3.fromRGB(95,105,94);spawn.Transparency=.15;spawn.Parent=root

local function tent(name,pos,yaw,parent,col)
    local m=Instance.new("Model");m.Name=name;m.Parent=parent;local cf=CFrame.new(pos)*CFrame.Angles(0,math.rad(yaw),0);col=col or Color3.fromRGB(167,119,63)
    mk("Floor",Vector3.new(10,.6,9),cf*CFrame.new(0,.3,0),Enum.Material.Fabric,col,m,true)
    mk("FlyL",Vector3.new(7.2,.35,10),cf*CFrame.new(-2.6,3.1,0)*CFrame.Angles(0,0,math.rad(50)),Enum.Material.Fabric,col,m,false)
    mk("FlyR",Vector3.new(7.2,.35,10),cf*CFrame.new(2.6,3.1,0)*CFrame.Angles(0,0,math.rad(-50)),Enum.Material.Fabric,col,m,false)
end
local function campfire(name,pos,parent)
    local m=Instance.new("Model");m.Name=name;m.Parent=parent
    for r=1,3 do local log=mk("Log",Vector3.new(7,1.1,1.1),CFrame.new(pos+Vector3.new(0,.7,0))*CFrame.Angles(0,math.rad(r*60),0),Enum.Material.Wood,color.woodDark,m,false);log.CanCollide=false end
    local flame=sphere("Flame",pos+Vector3.new(0,2.2,0),Vector3.new(2.2,4.2,2.2),Enum.Material.Neon,Color3.fromRGB(236,129,42),m,false);flame.Transparency=.15
    local light=Instance.new("PointLight");light.Range=22;light.Brightness=2.3;light.Color=Color3.fromRGB(255,169,88);light.Parent=flame
end

-- BASECAMP
hut("RegistrasiBasecamp",route[5]+Vector3.new(-35,2,20),-15,1.25,folders.Basecamp,Color3.fromRGB(188,176,148))
sign("BasecampTitle",route[5]+Vector3.new(10,16,15),route[6],"BASECAMP MOUNT BBYA\nREGISTRASI • PERALATAN • CAMPING",folders.Basecamp)
mk("BasecampDeck",Vector3.new(90,1.2,55),CFrame.new(route[5]+Vector3.new(28,-.3,-18)),Enum.Material.WoodPlanks,color.wood,folders.Basecamp,true)
for i=1,4 do tent("BaseTent_"..i,route[5]+Vector3.new(45+(i%2)*16,2,-35-math.floor((i-1)/2)*16),i*8,folders.Basecamp,i%2==0 and Color3.fromRGB(90,111,72) or Color3.fromRGB(177,112,61)) end
campfire("BasecampFire",route[5]+Vector3.new(30,2,-10),folders.Basecamp)

-- HUTAN TROPIS
local function tree(pos,scale,parent)
    local m=Instance.new("Model");m.Name="Tree";m.Parent=parent
    cyl("Trunk",pos+Vector3.new(0,6*scale,0),1.1*scale,12*scale,Enum.Material.Wood,color.woodDark,m,true)
    sphere("CrownA",pos+Vector3.new(0,14*scale,0),Vector3.new(10,8,10)*scale,Enum.Material.LeafyGrass,color.leaf,m,false)
    sphere("CrownB",pos+Vector3.new(4*scale,12.5*scale,0),Vector3.new(8,7,8)*scale,Enum.Material.LeafyGrass,color.leaf2,m,false)
end
local treeCount=0
for i=6,24 do
    local p,n=route[i],route[i+1];local flat=Vector3.new(n.X-p.X,0,n.Z-p.Z)
    if flat.Magnitude>1 then
        local side=Vector3.new(-flat.Z,0,flat.X).Unit
        for k=1,5 do
            local s=k%2==0 and -1 or 1;local off=side*s*math.random(34,125)+flat.Unit*math.random(-55,55)
            local x,z=p.X+off.X,p.Z+off.Z;local y=groundY(x,z,1300)
            if y then tree(Vector3.new(x,y,z),math.random(80,135)/100,folders.Forest);treeCount+=1 end
        end
    end
end
for i=1,30 do
    local x,z=math.random(-310,310),math.random(1260,1680);local y=groundY(x,z,350)
    if y and math.abs(x)>38 then tree(Vector3.new(x,y,z),math.random(70,110)/100,folders.Forest);treeCount+=1 end
end
sign("ForestSign",route[9]+Vector3.new(20,14,12),route[10],"JALUR HUTAN TROPIS\nAKAR • LUMPUR • KABUT",folders.Forest)

-- CHECKPOINTS
local cpSpecs={{1,17,"POS 1","± 900 MDPL"},{2,25,"POS 2","± 1.400 MDPL"},{3,31,"POS 3 / HIGH CAMP","± 2.000 MDPL"},{4,42,"PUNCAK","2.487 MDPL"}}
local cpPads,cpPositions,cpCFrames={},{},{}
for _,s in ipairs(cpSpecs) do
    local idx,ri,title,sub=s[1],s[2],s[3],s[4];local p=route[ri]
    local m=Instance.new("Model");m.Name="Checkpoint_"..idx;m.Parent=folders.Checkpoints
    local pad=mk("Trigger",Vector3.new(24,1.1,18),CFrame.new(p+Vector3.new(0,.5,0)),Enum.Material.Slate,idx==4 and Color3.fromRGB(101,98,90) or Color3.fromRGB(76,99,69),m,true)
    pad:SetAttribute("CheckpointIndex",idx);pad:SetAttribute("CheckpointName",title);sign("Sign",p+Vector3.new(0,12,-10),route[math.max(1,ri-1)],title.."\n"..sub,m)
    cpPads[idx]=pad;cpPositions[idx]=p;cpCFrames[idx]=CFrame.new(p+Vector3.new(0,5,0))
end
hut("Pos1Shelter",route[17]+Vector3.new(30,1,25),35,.75,folders.Checkpoints,Color3.fromRGB(163,151,126))

-- LEMBAH & SUNGAI / JEMBATAN GANTUNG
local riverCenter=Vector3.new(-330,323,-115)
Terrain:FillBlock(CFrame.new(riverCenter+Vector3.new(0,-6,0))*CFrame.Angles(0,math.rad(-12),0),Vector3.new(210,18,68),Enum.Material.Air)
Terrain:FillBlock(CFrame.new(riverCenter+Vector3.new(0,-11,0))*CFrame.Angles(0,math.rad(-12),0),Vector3.new(210,8,54),Enum.Material.Water)
if trails[19] then trails[19].Transparency=1;trails[19].CanCollide=false end
if trails[20] then trails[20].Transparency=1;trails[20].CanCollide=false end
local falls=mk("Waterfall",Vector3.new(25,90,4),CFrame.new(-505,305,-145)*CFrame.Angles(0,math.rad(10),0),Enum.Material.Glass,color.water,folders.Valley,false,.35);falls.CanTouch=false
local mist=sphere("WaterfallMist",Vector3.new(-505,260,-145),Vector3.new(45,18,28),Enum.Material.Glass,Color3.fromRGB(188,211,207),folders.Valley,false);mist.Transparency=.7
local bridgeA,bridgeB=route[19],route[21];local bridgeDir=bridgeB-bridgeA;local bridgeCF=CFrame.lookAt((bridgeA+bridgeB)*.5,bridgeB);local plankCount=math.floor(bridgeDir.Magnitude/7)
for i=0,plankCount do local p=bridgeA:Lerp(bridgeB,i/math.max(1,plankCount))+Vector3.new(0,2,0);mk("BridgePlank",Vector3.new(11,.75,5.5),CFrame.lookAt(p,p+bridgeDir),Enum.Material.WoodPlanks,color.wood,folders.Valley,true) end
for _,sideSign in ipairs({-1,1}) do
    local off=bridgeCF.RightVector*sideSign*6
    segment("BridgeRail",bridgeA+off+Vector3.new(0,6,0),bridgeB+off+Vector3.new(0,6,0),.45,.45,Enum.Material.Metal,color.metal,folders.Valley,false)
    for i=0,8 do cyl("BridgePost",bridgeA:Lerp(bridgeB,i/8)+off+Vector3.new(0,3.2,0),.28,6.5,Enum.Material.Wood,color.woodDark,folders.Valley,false) end
end
sign("ValleySign",route[20]+Vector3.new(30,13,15),route[21],"LEMBAH & SUNGAI\nAIR TERJUN • JEMBATAN GANTUNG",folders.Valley)

-- POS 2 / CLIFF
Terrain:FillBlock(CFrame.new(route[25]-Vector3.new(0,3,0)),Vector3.new(95,8,75),Enum.Material.Rock)
hut("Pos2Shelter",route[25]+Vector3.new(-32,1,22),-25,.7,folders.Checkpoints,Color3.fromRGB(151,145,129));tent("Pos2Tent",route[25]+Vector3.new(32,1,22),20,folders.Checkpoints,Color3.fromRGB(91,110,71))
for i=25,32 do
    local a,b=route[i],route[i+1];local flat=Vector3.new(b.X-a.X,0,b.Z-a.Z)
    if flat.Magnitude>1 then local side=Vector3.new(-flat.Z,0,flat.X).Unit;local off=side*((i%3==0) and -6.5 or 6.5);segment("CliffRope",a+off+Vector3.new(0,5,0),b+off+Vector3.new(0,5,0),.38,.38,Enum.Material.Metal,Color3.fromRGB(117,106,85),folders.Cliff,false);cyl("CliffPost",a+off+Vector3.new(0,2.5,0),.32,5,Enum.Material.Wood,color.woodDark,folders.Cliff,true) end
end
sign("CliffSign",route[28]+Vector3.new(25,14,15),route[29],"JALUR TEBING\nJAGA JARAK • IKUTI JALUR",folders.Cliff)

-- POS 3 / HIGH CAMP
local hc=route[31];Terrain:FillBlock(CFrame.new(hc-Vector3.new(0,3.5,0)),Vector3.new(125,9,95),Enum.Material.Rock)
hut("HighCampShelter",hc+Vector3.new(-38,1,26),10,.78,folders.HighCamp,Color3.fromRGB(142,139,127))
for i=1,5 do tent("HighTent_"..i,hc+Vector3.new(18+(i%3)*18,1,10-math.floor((i-1)/3)*20),i*12,folders.HighCamp,i%2==0 and Color3.fromRGB(116,83,61) or Color3.fromRGB(76,99,69)) end
campfire("HighCampFire",hc+Vector3.new(0,2,18),folders.HighCamp);sign("HighCampTitle",hc+Vector3.new(0,15,-18),route[32],"POS 3 / HIGH CAMP\nANGIN KENCANG • SUHU MENURUN",folders.HighCamp)

-- PEGUNUNGAN TINGGI / SUMMIT RIDGE
local rockCount=0
for i=31,#route do
    local p=route[i];local n=route[math.min(#route,i+1)];local flat=Vector3.new(n.X-p.X,0,n.Z-p.Z)
    if flat.Magnitude>1 then local side=Vector3.new(-flat.Z,0,flat.X).Unit;for k=1,4 do local s=k%2==0 and -1 or 1;local q=p+side*s*math.random(18,85)+flat.Unit*math.random(-45,45)+Vector3.new(0,math.random(-3,7),0);sphere("VolcanicRock",q,Vector3.new(math.random(6,18),math.random(4,13),math.random(7,21)),Enum.Material.Slate,k%2==0 and color.stoneDark or color.stone,folders.Highland,true);rockCount+=1 end end
end
sign("HighlandSign",route[35]+Vector3.new(-30,15,10),route[36],"ZONA PEGUNUNGAN TINGGI\nBATU VULKANIK • ANGIN KENCANG",folders.Highland)
for i=36,#route-1,2 do cyl("SummitMarker",route[i]+Vector3.new(0,3,0),.35,6,Enum.Material.Wood,color.woodDark,folders.Summit,true) end
sign("SummitTrail",route[37]+Vector3.new(-24,12,10),route[38],"JALUR SUMMIT\nRIDGE MENUJU PUNCAK",folders.Summit)

-- PUNCAK
local summit=route[#route];Terrain:FillBlock(CFrame.new(summit-Vector3.new(0,4,0)),Vector3.new(110,10,82),Enum.Material.Rock)
mk("SummitDeck",Vector3.new(70,1.2,48),CFrame.new(summit+Vector3.new(0,.5,0)),Enum.Material.Slate,Color3.fromRGB(79,80,76),folders.Summit,true)
sign("SummitBoard",summit+Vector3.new(0,13,-18),route[#route-1],"MOUNT BBYA\nPUNCAK • 2.487 MDPL",folders.Summit)
cyl("FlagPole",summit+Vector3.new(28,10,5),.45,20,Enum.Material.Metal,Color3.fromRGB(150,150,145),folders.Summit,true)
mk("FlagRed",Vector3.new(12,3.5,.25),CFrame.new(summit+Vector3.new(34,17.3,5)),Enum.Material.Fabric,color.red,folders.Summit,false)
mk("FlagWhite",Vector3.new(12,3.5,.25),CFrame.new(summit+Vector3.new(34,13.8,5)),Enum.Material.Fabric,color.white,folders.Summit,false)
mk("PhotoSpot",Vector3.new(22,.8,16),CFrame.new(summit+Vector3.new(-30,.7,8)),Enum.Material.WoodPlanks,color.wood,folders.Summit,true)
board("PhotoLabel",summit+Vector3.new(-30,8,-1),route[#route-1],18,5,"PHOTO SPOT\nMOUNT BBYA",folders.Summit)

-- LIGHTING
Lighting.ClockTime=7.15;Lighting.Brightness=2.35;Lighting.GlobalShadows=true;Lighting.EnvironmentDiffuseScale=.35;Lighting.EnvironmentSpecularScale=.5
Lighting.OutdoorAmbient=Color3.fromRGB(112,118,110);Lighting.Ambient=Color3.fromRGB(84,89,84)
for _,name in ipairs({"MountBBYA_Atmosphere","MountBBYA_Color","MountBBYA_Bloom"}) do local e=Lighting:FindFirstChild(name);if e then e:Destroy() end end
local atmosphere=Instance.new("Atmosphere");atmosphere.Name="MountBBYA_Atmosphere";atmosphere.Density=.29;atmosphere.Offset=.05;atmosphere.Color=Color3.fromRGB(205,219,211);atmosphere.Decay=Color3.fromRGB(113,128,119);atmosphere.Glare=.08;atmosphere.Haze=1.7;atmosphere.Parent=Lighting
local cc=Instance.new("ColorCorrectionEffect");cc.Name="MountBBYA_Color";cc.Brightness=.02;cc.Contrast=.08;cc.Saturation=.03;cc.TintColor=Color3.fromRGB(246,244,230);cc.Parent=Lighting
local bloom=Instance.new("BloomEffect");bloom.Name="MountBBYA_Bloom";bloom.Intensity=.12;bloom.Size=18;bloom.Threshold=1.45;bloom.Parent=Lighting

-- CHECKPOINT RUNTIME / FALL RESCUE
local function bindPlayer(plr)
    if plr:GetAttribute("MountBBYACheckpoint")==nil then plr:SetAttribute("MountBBYACheckpoint",0) end
    plr.CharacterAdded:Connect(function(ch) task.wait(.35);local cp=plr:GetAttribute("MountBBYACheckpoint") or 0;local cf=cpCFrames[cp];if cf and ch.Parent then ch:PivotTo(cf) end end)
end
for _,plr in ipairs(Players:GetPlayers()) do bindPlayer(plr) end
Players.PlayerAdded:Connect(bindPlayer)
for i,pad in ipairs(cpPads) do
    local cpIndex=i
    pad.Touched:Connect(function(hit)
        local ch=hit and hit.Parent;local plr=ch and Players:GetPlayerFromCharacter(ch);if not plr then return end
        local oldCp=plr:GetAttribute("MountBBYACheckpoint") or 0
        if cpIndex>oldCp then plr:SetAttribute("MountBBYACheckpoint",cpIndex);plr:SetAttribute("MountBBYALastCheckpointName",cpSpecs[cpIndex][3]) end
    end)
end
task.spawn(function()
    while root.Parent do
        for _,plr in ipairs(Players:GetPlayers()) do local ch=plr.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart");if hrp and hrp.Position.Y < -60 then local cp=plr:GetAttribute("MountBBYACheckpoint") or 0;ch:PivotTo(cpCFrames[cp] or (spawn.CFrame+Vector3.new(0,5,0)));hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero end end
        task.wait(.6)
    end
end)

local minSpacing=1e9
for i=1,#cpPositions-1 do minSpacing=math.min(minSpacing,(cpPositions[i+1]-cpPositions[i]).Magnitude) end
root:SetAttribute("TrailSegmentCount",trailCount);root:SetAttribute("TreeCount",treeCount);root:SetAttribute("RockCount",rockCount);root:SetAttribute("CheckpointCount",#cpPads);root:SetAttribute("MinimumCheckpointSpacing",math.floor(minSpacing))
root:SetAttribute("FullRouteZones",11);root:SetAttribute("VillageReady",true);root:SetAttribute("BasecampReady",true);root:SetAttribute("ForestReady",true);root:SetAttribute("ValleyReady",true);root:SetAttribute("CliffReady",true);root:SetAttribute("HighCampReady",true);root:SetAttribute("SummitReady",true)
root:SetAttribute("RuntimeState","READY");Workspace:SetAttribute("MOUNT_BBYA_BUILD",BUILD);Workspace:SetAttribute("MOUNT_BBYA_READY",true)
print(string.format("[MOUNT BBYA] %s READY route=%d trail=%d trees=%d rocks=%d checkpoints=%d minSpacing=%d",BUILD,math.floor(routeStuds),trailCount,treeCount,rockCount,#cpPads,math.floor(minSpacing)))
