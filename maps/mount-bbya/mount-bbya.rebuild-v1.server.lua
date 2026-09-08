-- MOUNT BBYA — VISUAL LOCK REBUILD v1.0
-- Owner: Arda
-- Target: MOUNT BBYA only (Universe 4187755690 / Place 11832985967)
-- Mountain Social is a separate forbidden target and is never referenced by this runtime.
-- Design lock: Desa -> Basecamp -> Hutan Tropis -> Pos 1 -> Lembah & Sungai -> Pos 2 -> Jalur Tebing -> Pos 3 -> Pegunungan Tinggi -> Jalur Summit -> Puncak.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Terrain = Workspace.Terrain

local ROOT_NAME = "MOUNT_BBYA_REBUILD_V1"
local BUILD = "visual-lock-rebuild-v1.0"
local old = Workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = Workspace
root:SetAttribute("Project", "MOUNT BBYA")
root:SetAttribute("BuildVersion", BUILD)
root:SetAttribute("VisualLock", "TROPICAL_INDONESIAN_MOUNTAIN_2026_09_08")
root:SetAttribute("ForbiddenProjectTouched", false)
root:SetAttribute("TerrainArchitecture", "FOUNDATION_CARVE_SUBGRADE_TRAIL")
root:SetAttribute("RuntimeState", "BUILDING")

local folders = {}
for _, name in ipairs({
    "Route", "Village", "Basecamp", "Forest", "Checkpoints", "Valley",
    "Cliff", "HighCamp", "Highland", "Summit", "Scenery", "Safety"
}) do
    local f = Instance.new("Folder")
    f.Name = name
    f.Parent = root
    folders[name] = f
end

math.randomseed(8092026)

local C = {
    dirt = Color3.fromRGB(105, 82, 57),
    mud = Color3.fromRGB(82, 69, 52),
    grass = Color3.fromRGB(80, 111, 61),
    darkGrass = Color3.fromRGB(53, 83, 47),
    leaf = Color3.fromRGB(44, 92, 47),
    leaf2 = Color3.fromRGB(65, 112, 55),
    wood = Color3.fromRGB(92, 65, 43),
    woodDark = Color3.fromRGB(63, 48, 37),
    stone = Color3.fromRGB(83, 84, 80),
    stoneDark = Color3.fromRGB(58, 60, 58),
    villageWall = Color3.fromRGB(201, 188, 158),
    roof = Color3.fromRGB(105, 61, 43),
    metal = Color3.fromRGB(84, 89, 86),
    sign = Color3.fromRGB(73, 54, 38),
    water = Color3.fromRGB(72, 126, 139),
    red = Color3.fromRGB(190, 38, 43),
    white = Color3.fromRGB(235, 235, 229),
}

local function part(name, size, cf, material, color, parent, collide, transparency)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Material = material or Enum.Material.SmoothPlastic
    if color then p.Color = color end
    p.CanCollide = collide ~= false
    p.Transparency = transparency or 0
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.CastShadow = true
    p.Parent = parent or root
    return p
end

local function cylinder(name, pos, radius, height, material, color, parent, collide)
    local p = part(name, Vector3.new(height, radius * 2, radius * 2), CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90)), material, color, parent, collide)
    p.Shape = Enum.PartType.Cylinder
    return p
end

local function ball(name, pos, size, material, color, parent, collide)
    local p = part(name, size, CFrame.new(pos) * CFrame.Angles(math.rad(math.random(-12,12)), math.rad(math.random(0,180)), math.rad(math.random(-12,12))), material, color, parent, collide)
    p.Shape = Enum.PartType.Ball
    return p
end

local function linePart(name, a, b, width, height, material, color, parent, collide)
    local d = b - a
    if d.Magnitude < 0.1 then return nil end
    local mid = (a + b) * 0.5
    return part(name, Vector3.new(width, height, d.Magnitude + 1), CFrame.lookAt(mid, b), material, color, parent, collide)
end

local function textBoard(name, pos, lookAt, width, height, text, parent)
    local cf = CFrame.lookAt(pos, lookAt)
    local board = part(name, Vector3.new(width, height, 0.7), cf, Enum.Material.WoodPlanks, C.sign, parent, true)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "Label"
    gui.Face = Enum.NormalId.Front
    gui.CanvasSize = Vector2.new(900, 320)
    gui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
    gui.Parent = board
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = C.white
    label.TextScaled = true
    label.TextWrapped = true
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.65
    label.Parent = gui
    return board
end

local function postSign(name, pos, facePoint, text, parent)
    cylinder(name.."_PostL", pos + Vector3.new(-5, -3, 0), 0.45, 7, Enum.Material.Wood, C.woodDark, parent, true)
    cylinder(name.."_PostR", pos + Vector3.new(5, -3, 0), 0.45, 7, Enum.Material.Wood, C.woodDark, parent, true)
    return textBoard(name, pos, facePoint, 13, 5.5, text, parent)
end

local function rayGround(x, z, fromY)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Include
    rp.FilterDescendantsInstances = {Terrain}
    rp.IgnoreWater = true
    local hit = Workspace:Raycast(Vector3.new(x, fromY or 1500, z), Vector3.new(0, -2500, 0), rp)
    return hit and hit.Position.Y or nil
end

-- Route control points. 42 nodes, ~7.1k studs of actual climb progression.
local route = {
    Vector3.new(0,24,1650), Vector3.new(40,25,1510), Vector3.new(-20,28,1380), Vector3.new(60,33,1260),
    Vector3.new(-50,42,1160), Vector3.new(-180,55,1070), Vector3.new(-320,70,990), Vector3.new(-450,88,900),
    Vector3.new(-520,110,790), Vector3.new(-420,135,680), Vector3.new(-260,160,600), Vector3.new(-80,185,540),
    Vector3.new(120,205,500), Vector3.new(300,225,430), Vector3.new(430,245,340), Vector3.new(360,265,240),
    Vector3.new(190,282,155), Vector3.new(0,300,100), Vector3.new(-190,322,20), Vector3.new(-350,345,-80),
    Vector3.new(-430,370,-190), Vector3.new(-350,395,-300), Vector3.new(-170,420,-390), Vector3.new(30,445,-470),
    Vector3.new(230,470,-540), Vector3.new(400,500,-630), Vector3.new(480,535,-740), Vector3.new(390,570,-850),
    Vector3.new(210,605,-920), Vector3.new(20,640,-980), Vector3.new(-180,675,-1040), Vector3.new(-350,710,-1130),
    Vector3.new(-430,748,-1240), Vector3.new(-360,785,-1350), Vector3.new(-190,820,-1440), Vector3.new(20,850,-1500),
    Vector3.new(220,880,-1560), Vector3.new(390,910,-1650), Vector3.new(450,940,-1760), Vector3.new(360,970,-1870),
    Vector3.new(190,1000,-1950), Vector3.new(0,1028,-2010)
}

local function routeDistance()
    local total = 0
    for i = 1, #route - 1 do total += (route[i+1] - route[i]).Magnitude end
    return total
end
root:SetAttribute("RouteStuds", math.floor(routeDistance()))
root:SetAttribute("RouteNodeCount", #route)

-- ============================================================================
-- TERRAIN FOUNDATION — one connected mountain, then corridor carve + subgrade.
-- ============================================================================
Terrain:Clear()
Terrain.WaterColor = Color3.fromRGB(55, 105, 112)
Terrain.WaterTransparency = 0.25
Terrain.WaterWaveSize = 0.12
Terrain.WaterWaveSpeed = 7

-- Lowland foundation and broad connected mountain mass.
Terrain:FillBlock(CFrame.new(0,-22,500), Vector3.new(2300,70,3600), Enum.Material.Grass)
for _, m in ipairs({
    {0,960,880,260,Enum.Material.Grass},
    {40,380,980,510,Enum.Material.Grass},
    {-30,-330,930,730,Enum.Material.Grass},
    {20,-1030,830,920,Enum.Material.Rock},
    {0,-1670,690,1085,Enum.Material.Rock},
}) do
    local x,z,r,top,mat = m[1],m[2],m[3],m[4],m[5]
    Terrain:FillBall(Vector3.new(x, top-r, z), r, mat)
end

-- Side ridges make the silhouette irregular instead of a single round cone.
for _, m in ipairs({
    {-620,670,380,240},{610,530,410,300},{-650,50,460,460},{650,-100,440,500},
    {-620,-620,410,650},{610,-710,390,690},{-560,-1200,360,820},{540,-1270,350,850},
    {-410,-1700,310,980},{420,-1760,290,990}
}) do
    Terrain:FillBall(Vector3.new(m[1],m[4]-m[3],m[2]), m[3], (m[4] > 600) and Enum.Material.Rock or Enum.Material.Grass)
end

-- Spawn/village bench and basecamp bench.
Terrain:FillBlock(CFrame.new(0,17,1530), Vector3.new(720,45,430), Enum.Material.Grass)
Terrain:FillBlock(CFrame.new(-45,36,1190), Vector3.new(470,52,300), Enum.Material.Grass)

local trailSegmentCount = 0
local trailParts = {}
local bridgeStartIndex, bridgeEndIndex = 19, 21
local cliffStartIndex, cliffEndIndex = 25, 33
local summitStartIndex = 36

local function trailWidthFor(i)
    if i < 5 then return 20 end
    if i < 17 then return 14 end
    if i < 24 then return 12 end
    if i < 34 then return 9 end
    return 8
end

-- Guaranteed grounded route. Carve corridor first, refill its own subgrade, then add slightly embedded tread.
for i = 1, #route - 1 do
    local a, b = route[i], route[i+1]
    local w = trailWidthFor(i)
    local d = b - a
    local mid = (a+b)*0.5
    local cf = CFrame.lookAt(mid, b)
    Terrain:FillBlock(cf * CFrame.new(0,5,0), Vector3.new(w+24, 18, d.Magnitude+5), Enum.Material.Air)
    Terrain:FillBlock(cf * CFrame.new(0,-3.3,0), Vector3.new(w+10, 8, d.Magnitude+5), i >= 31 and Enum.Material.Rock or Enum.Material.Ground)
    local material = i >= 31 and Enum.Material.Slate or (i >= 17 and Enum.Material.Mud or Enum.Material.Ground)
    local color = i >= 31 and C.stone or (i >= 17 and C.mud or C.dirt)
    local tread = linePart("Trail_%02d".format(i), a + Vector3.new(0,0.05,0), b + Vector3.new(0,0.05,0), w, 1.15, material, color, folders.Route, true)
    if tread then
        tread:SetAttribute("RouteIndex", i)
        table.insert(trailParts, tread)
        trailSegmentCount += 1
    end
end

-- Natural edging so the path reads as part of the terrain, not a floating ribbon.
for i = 5, #route-2, 2 do
    local p = route[i]
    local nextP = route[i+1]
    local flat = Vector3.new(nextP.X-p.X,0,nextP.Z-p.Z)
    if flat.Magnitude > 1 then
        local side = Vector3.new(-flat.Z,0,flat.X).Unit
        for _, s in ipairs({-1,1}) do
            local edge = p + side * s * (trailWidthFor(i)*0.65 + math.random(2,7))
            ball("TrailEdgeRock", edge + Vector3.new(0,math.random(-1,2),0), Vector3.new(math.random(5,10),math.random(3,7),math.random(5,12)), Enum.Material.Rock, C.stoneDark, folders.Scenery, true)
        end
    end
end

-- ============================================================================
-- VILLAGE / SPAWN
-- ============================================================================
local function hut(name, pos, yaw, scale, parent, wallColor)
    scale = scale or 1
    local m = Instance.new("Model"); m.Name = name; m.Parent = parent
    local cf = CFrame.new(pos) * CFrame.Angles(0,math.rad(yaw),0)
    part("Foundation", Vector3.new(24*scale,1.2,18*scale), cf*CFrame.new(0,0.6,0), Enum.Material.Rock, C.stone, m, true)
    part("Walls", Vector3.new(22*scale,10*scale,16*scale), cf*CFrame.new(0,6*scale,0), Enum.Material.Brick, wallColor or C.villageWall, m, true)
    part("RoofL", Vector3.new(14*scale,0.8,21*scale), cf*CFrame.new(-5*scale,13*scale,0)*CFrame.Angles(0,0,math.rad(28)), Enum.Material.WoodPlanks, C.roof, m, true)
    part("RoofR", Vector3.new(14*scale,0.8,21*scale), cf*CFrame.new(5*scale,13*scale,0)*CFrame.Angles(0,0,math.rad(-28)), Enum.Material.WoodPlanks, C.roof, m, true)
    part("Door", Vector3.new(4*scale,7*scale,0.5), cf*CFrame.new(0,4*scale,-8.25*scale), Enum.Material.Wood, C.woodDark, m, false)
    part("WindowL", Vector3.new(4*scale,3*scale,0.35), cf*CFrame.new(-6*scale,6.5*scale,-8.3*scale), Enum.Material.Glass, Color3.fromRGB(139,171,173), m, false, 0.2)
    part("WindowR", Vector3.new(4*scale,3*scale,0.35), cf*CFrame.new(6*scale,6.5*scale,-8.3*scale), Enum.Material.Glass, Color3.fromRGB(139,171,173), m, false, 0.2)
    return m
end

-- Village road / arrival lane.
part("VillageRoad", Vector3.new(38,1.2,350), CFrame.new(0,24.2,1510), Enum.Material.Pavement, Color3.fromRGB(74,76,73), folders.Village, true)
for _, spec in ipairs({
    {-130,25,1590,8,1.0},{130,25,1580,-10,1.0},{-165,25,1490,12,1.15},{160,25,1460,-8,1.0},
    {-145,26,1380,7,0.95},{145,27,1360,-7,1.05}
}) do
    hut("RumahWarga", Vector3.new(spec[1],spec[2],spec[3]), spec[4], spec[5], folders.Village)
end
hut("Warung_Mbak_Sari", Vector3.new(-70,25,1315), 5, 1.15, folders.Village, Color3.fromRGB(205,177,122))
postSign("WarungSign", Vector3.new(-70,37,1304), Vector3.new(-70,37,1260), "WARUNG\nMBAK SARI", folders.Village)

-- Parking bay and simple vehicles as grounded silhouettes.
part("ParkingPad", Vector3.new(95,1.0,75), CFrame.new(92,24.1,1320), Enum.Material.Concrete, Color3.fromRGB(112,112,104), folders.Village, true)
for i=1,4 do
    local x = 60 + (i-1)*22
    local body = part("PendakiVehicle", Vector3.new(15,5,7), CFrame.new(x,27.1,1310 + (i%2)*22), Enum.Material.Metal, i%2==0 and Color3.fromRGB(218,218,205) or Color3.fromRGB(80,92,91), folders.Village, true)
    for _, off in ipairs({Vector3.new(-5,-2.2,-3.5),Vector3.new(5,-2.2,-3.5),Vector3.new(-5,-2.2,3.5),Vector3.new(5,-2.2,3.5)}) do
        local w = cylinder("Wheel", body.Position+off, 1.4, 1.1, Enum.Material.SmoothPlastic, Color3.fromRGB(30,30,30), folders.Village, true)
        w.CFrame = CFrame.new(body.Position+off) * CFrame.Angles(0,math.rad(90),math.rad(90))
    end
end
postSign("ParkingSign", Vector3.new(92,34,1275), Vector3.new(92,34,1230), "PARKIR PENDAKI", folders.Village)

-- Gateway.
part("GatePostL", Vector3.new(3,18,3), CFrame.new(-19,33,1245), Enum.Material.WoodPlanks, C.woodDark, folders.Village, true)
part("GatePostR", Vector3.new(3,18,3), CFrame.new(19,33,1245), Enum.Material.WoodPlanks, C.woodDark, folders.Village, true)
textBoard("WelcomeGate", Vector3.new(0,40,1245), Vector3.new(0,40,1200), 42, 7, "SELAMAT DATANG DI MOUNT BBYA", folders.Village)

local spawn = Instance.new("SpawnLocation")
spawn.Name = "MountBBYA_Spawn"
spawn.Anchored = true
spawn.CanCollide = true
spawn.Neutral = true
spawn.Duration = 0
spawn.Size = Vector3.new(16,1,16)
spawn.CFrame = CFrame.new(route[1] + Vector3.new(0,1.2,0))
spawn.Material = Enum.Material.Slate
spawn.Color = Color3.fromRGB(95,105,94)
spawn.Transparency = 0.15
spawn.Parent = root

-- ============================================================================
-- BASECAMP
-- ============================================================================
local basePos = route[5] + Vector3.new(-35,2,20)
hut("RegistrasiBasecamp", basePos, -15, 1.25, folders.Basecamp, Color3.fromRGB(188,176,148))
postSign("BasecampTitle", route[5]+Vector3.new(10,16,15), route[6], "BASECAMP MOUNT BBYA\nREGISTRASI • PERALATAN • CAMPING", folders.Basecamp)
part("BasecampDeck", Vector3.new(90,1.2,55), CFrame.new(route[5]+Vector3.new(28,-0.3,-18)), Enum.Material.WoodPlanks, C.wood, folders.Basecamp, true)

local function tent(name, pos, yaw, parent, color)
    local m = Instance.new("Model"); m.Name=name; m.Parent=parent
    local cf=CFrame.new(pos)*CFrame.Angles(0,math.rad(yaw),0)
    part("Floor",Vector3.new(10,0.6,9),cf*CFrame.new(0,0.3,0),Enum.Material.Fabric,color or Color3.fromRGB(167,119,63),m,true)
    part("FlyL",Vector3.new(7.2,0.35,10),cf*CFrame.new(-2.6,3.1,0)*CFrame.Angles(0,0,math.rad(50)),Enum.Material.Fabric,color or Color3.fromRGB(167,119,63),m,false)
    part("FlyR",Vector3.new(7.2,0.35,10),cf*CFrame.new(2.6,3.1,0)*CFrame.Angles(0,0,math.rad(-50)),Enum.Material.Fabric,color or Color3.fromRGB(167,119,63),m,false)
    return m
end
for i=1,4 do tent("BaseTent_"..i, route[5]+Vector3.new(45+(i%2)*16,2,-35-math.floor((i-1)/2)*16), i*8, folders.Basecamp, i%2==0 and Color3.fromRGB(90,111,72) or Color3.fromRGB(177,112,61)) end

local function campfire(name,pos,parent)
    local m=Instance.new("Model");m.Name=name;m.Parent=parent
    for r=1,3 do
        local log=part("Log",Vector3.new(7,1.1,1.1),CFrame.new(pos+Vector3.new(0,0.7,0))*CFrame.Angles(0,math.rad(r*60),0),Enum.Material.Wood,C.woodDark,m,true)
        log.CanCollide=false
    end
    local flame=ball("Flame",pos+Vector3.new(0,2.2,0),Vector3.new(2.2,4.2,2.2),Enum.Material.Neon,Color3.fromRGB(236,129,42),m,false)
    flame.Transparency=.15
    local light=Instance.new("PointLight");light.Range=22;light.Brightness=2.3;light.Color=Color3.fromRGB(255,169,88);light.Parent=flame
end
campfire("BasecampFire",route[5]+Vector3.new(30,2,-10),folders.Basecamp)

-- ============================================================================
-- FOREST / SCENERY
-- ============================================================================
local function tree(name, pos, scale, parent)
    scale=scale or 1
    local m=Instance.new("Model");m.Name=name;m.Parent=parent
    cylinder("Trunk",pos+Vector3.new(0,6*scale,0),1.1*scale,12*scale,Enum.Material.Wood,C.woodDark,m,true)
    ball("CrownA",pos+Vector3.new(0,14*scale,0),Vector3.new(10,8,10)*scale,Enum.Material.LeafyGrass,C.leaf,m,false)
    ball("CrownB",pos+Vector3.new(4*scale,12.5*scale,0),Vector3.new(8,7,8)*scale,Enum.Material.LeafyGrass,C.leaf2,m,false)
    ball("CrownC",pos+Vector3.new(-4*scale,12*scale,2*scale),Vector3.new(8,6,8)*scale,Enum.Material.LeafyGrass,C.leaf,m,false)
end

local treeCount=0
for i=6,24 do
    local p=route[i]
    local n=route[math.min(#route,i+1)]
    local flat=Vector3.new(n.X-p.X,0,n.Z-p.Z)
    if flat.Magnitude>1 then
        local side=Vector3.new(-flat.Z,0,flat.X).Unit
        for k=1,5 do
            local s=(k%2==0) and -1 or 1
            local offset=side*s*math.random(34,125)+flat.Unit*math.random(-55,55)
            local x,z=p.X+offset.X,p.Z+offset.Z
            local y=rayGround(x,z,1200)
            if y then tree("ForestTree",Vector3.new(x,y,z),math.random(80,135)/100,folders.Forest);treeCount+=1 end
        end
    end
end

-- Extra lowland vegetation cluster.
for i=1,35 do
    local x=math.random(-310,310);local z=math.random(1260,1680);local y=rayGround(x,z,300)
    if y and math.abs(x)>35 then tree("VillageTree",Vector3.new(x,y,z),math.random(70,110)/100,folders.Forest);treeCount+=1 end
end

-- ============================================================================
-- CHECKPOINTS
-- ============================================================================
local checkpointSpecs={
    {1,17,"POS 1", "± 900 MDPL"},
    {2,25,"POS 2", "± 1.400 MDPL"},
    {3,31,"POS 3 / HIGH CAMP", "± 2.000 MDPL"},
    {4,42,"PUNCAK", "2.487 MDPL"},
}
local checkpointPositions={}

local function checkpoint(index, routeIndex, title, sub)
    local p=route[routeIndex]
    local m=Instance.new("Model");m.Name="Checkpoint_"..index;m.Parent=folders.Checkpoints
    local pad=part("Trigger",Vector3.new(24,1.1,18),CFrame.new(p+Vector3.new(0,0.5,0)),Enum.Material.Slate,index==4 and Color3.fromRGB(101,98,90) or Color3.fromRGB(76,99,69),m,true)
    pad:SetAttribute("CheckpointIndex",index)
    pad:SetAttribute("CheckpointName",title)
    postSign("Sign",p+Vector3.new(0,12,-10),route[math.max(1,routeIndex-1)],title.."\n"..sub,m)
    table.insert(checkpointPositions,p)
    return pad
end
local checkpointPads={}
for _,s in ipairs(checkpointSpecs) do table.insert(checkpointPads,checkpoint(s[1],s[2],s[3],s[4])) end

-- Simple shelter at Pos 1.
hut("Pos1Shelter",route[17]+Vector3.new(30,1,25),35,0.75,folders.Checkpoints,Color3.fromRGB(163,151,126))

-- ============================================================================
-- LEMBAH & SUNGAI + SUSPENSION BRIDGE
-- ============================================================================
local riverCenter=Vector3.new(-330,323,-115)
Terrain:FillBlock(CFrame.new(riverCenter+Vector3.new(0,-6,0))*CFrame.Angles(0,math.rad(-12),0),Vector3.new(210,18,68),Enum.Material.Air)
Terrain:FillBlock(CFrame.new(riverCenter+Vector3.new(0,-11,0))*CFrame.Angles(0,math.rad(-12),0),Vector3.new(210,8,54),Enum.Material.Water)

-- Waterfall descending off the side of the valley.
local falls=part("Waterfall",Vector3.new(25,90,4),CFrame.new(-505,305,-145)*CFrame.Angles(0,math.rad(10),0),Enum.Material.Glass,C.water,folders.Valley,false,.35)
falls.CanTouch=false
local mist=ball("WaterfallMist",Vector3.new(-505,260,-145),Vector3.new(45,18,28),Enum.Material.Glass,Color3.fromRGB(188,211,207),folders.Valley,false)
mist.Transparency=.7

local bridgeA=route[19]
local bridgeB=route[21]
local bridgeMid=(bridgeA+bridgeB)*.5
local bridgeDir=(bridgeB-bridgeA)
local bridgeLen=bridgeDir.Magnitude
local bridgeCF=CFrame.lookAt(bridgeMid,bridgeB)
for i=0,math.floor(bridgeLen/8) do
    local t=i/math.max(1,math.floor(bridgeLen/8))
    local p=bridgeA:Lerp(bridgeB,t)+Vector3.new(0,2,0)
    part("BridgePlank",Vector3.new(10,.75,5.5),CFrame.lookAt(p,p+bridgeDir),Enum.Material.WoodPlanks,C.wood,folders.Valley,true)
end
for _,side in ipairs({-1,1}) do
    local off=bridgeCF.RightVector*side*6
    linePart("BridgeRail",bridgeA+off+Vector3.new(0,6,0),bridgeB+off+Vector3.new(0,6,0),.5,.5,Enum.Material.Metal,C.metal,folders.Valley,false)
    for i=0,8 do
        local p=bridgeA:Lerp(bridgeB,i/8)+off
        cylinder("BridgePost",p+Vector3.new(0,3.2,0),.28,6.5,Enum.Material.Wood,C.woodDark,folders.Valley,false)
    end
end
postSign("ValleySign",route[20]+Vector3.new(30,13,15),route[21],"LEMBAH & SUNGAI\nAIR TERJUN • JEMBATAN GANTUNG",folders.Valley)

-- ============================================================================
-- POS 2 + CLIFF ROUTE
-- ============================================================================
local pos2=route[25]
Terrain:FillBlock(CFrame.new(pos2-Vector3.new(0,3,0)),Vector3.new(95,8,75),Enum.Material.Rock)
hut("Pos2Shelter",pos2+Vector3.new(-32,1,22),-25,.7,folders.Checkpoints,Color3.fromRGB(151,145,129))
tent("Pos2Tent",pos2+Vector3.new(32,1,22),20,folders.Checkpoints,Color3.fromRGB(91,110,71))

-- Cliff safety ropes/rails on the dangerous outer edge.
for i=cliffStartIndex,cliffEndIndex-1 do
    local a,b=route[i],route[i+1]
    local flat=Vector3.new(b.X-a.X,0,b.Z-a.Z)
    if flat.Magnitude>1 then
        local side=Vector3.new(-flat.Z,0,flat.X).Unit
        local sign=(i%3==0) and -1 or 1
        local off=side*sign*6.5
        local ra=a+off+Vector3.new(0,5,0)
        local rb=b+off+Vector3.new(0,5,0)
        linePart("CliffRope",ra,rb,.38,.38,Enum.Material.Metal,Color3.fromRGB(117,106,85),folders.Cliff,false)
        cylinder("CliffPost",a+off+Vector3.new(0,2.5,0),.32,5,Enum.Material.Wood,C.woodDark,folders.Cliff,true)
    end
end

-- Ladder accents at the steepest cliff nodes, backed by walkable trail underfoot.
for _,idx in ipairs({27,29,32}) do
    local p=route[idx]
    local q=route[idx+1]
    local side=Vector3.new(q.Z-p.Z,0,-(q.X-p.X)).Unit
    local base=p+side*8+Vector3.new(0,2,0)
    for r=0,7 do
        part("LadderRung",Vector3.new(7,.45,.65),CFrame.new(base+Vector3.new(0,r*2.2,0))*CFrame.Angles(0,math.atan2(q.X-p.X,q.Z-p.Z),0),Enum.Material.Wood,C.wood,folders.Cliff,true)
    end
end
postSign("CliffSign",route[28]+Vector3.new(25,14,15),route[29],"JALUR TEBING\nJAGA JARAK • IKUTI JALUR",folders.Cliff)

-- ============================================================================
-- POS 3 / HIGH CAMP
-- ============================================================================
local highCamp=route[31]
Terrain:FillBlock(CFrame.new(highCamp-Vector3.new(0,3.5,0)),Vector3.new(125,9,95),Enum.Material.Rock)
hut("HighCampShelter",highCamp+Vector3.new(-38,1,26),10,.78,folders.HighCamp,Color3.fromRGB(142,139,127))
for i=1,5 do
    tent("HighTent_"..i,highCamp+Vector3.new(18+(i%3)*18,1,10-math.floor((i-1)/3)*20),i*12,folders.HighCamp,i%2==0 and Color3.fromRGB(116,83,61) or Color3.fromRGB(76,99,69))
end
campfire("HighCampFire",highCamp+Vector3.new(0,2,18),folders.HighCamp)
postSign("HighCampTitle",highCamp+Vector3.new(0,15,-18),route[32],"POS 3 / HIGH CAMP\nANGIN KENCANG • SUHU MENURUN",folders.HighCamp)

-- ============================================================================
-- HIGHLAND / VOLCANIC RIDGE
-- ============================================================================
local rockCount=0
for i=31,#route do
    local p=route[i]
    local n=route[math.min(#route,i+1)]
    local flat=Vector3.new(n.X-p.X,0,n.Z-p.Z)
    if flat.Magnitude>1 then
        local side=Vector3.new(-flat.Z,0,flat.X).Unit
        for k=1,4 do
            local s=(k%2==0) and -1 or 1
            local pos=p+side*s*math.random(18,85)+flat.Unit*math.random(-45,45)+Vector3.new(0,math.random(-3,7),0)
            ball("VolcanicRock",pos,Vector3.new(math.random(6,18),math.random(4,13),math.random(7,21)),Enum.Material.Slate,k%2==0 and C.stoneDark or C.stone,folders.Highland,true)
            rockCount+=1
        end
    end
end
postSign("HighlandSign",route[35]+Vector3.new(-30,15,10),route[36],"ZONA PEGUNUNGAN TINGGI\nBATU VULKANIK • ANGIN KENCANG",folders.Highland)

-- Summit ridge markers; no fantasy lighting.
for i=summitStartIndex,#route-1,2 do
    local p=route[i]
    cylinder("SummitMarker",p+Vector3.new(0,3,0),.35,6,Enum.Material.Wood,C.woodDark,folders.Summit,true)
end
postSign("SummitTrailSign",route[37]+Vector3.new(-24,12,10),route[38],"JALUR SUMMIT\nRIDGE MENUJU PUNCAK",folders.Summit)

-- ============================================================================
-- SUMMIT
-- ============================================================================
local summit=route[#route]
Terrain:FillBlock(CFrame.new(summit-Vector3.new(0,4,0)),Vector3.new(110,10,82),Enum.Material.Rock)
part("SummitDeck",Vector3.new(70,1.2,48),CFrame.new(summit+Vector3.new(0,.5,0)),Enum.Material.Slate,Color3.fromRGB(79,80,76),folders.Summit,true)
postSign("SummitBoard",summit+Vector3.new(0,13,-18),route[#route-1],"MOUNT BBYA\nPUNCAK • 2.487 MDPL",folders.Summit)

-- Indonesian flag.
local pole=cylinder("FlagPole",summit+Vector3.new(28,10,5),.45,20,Enum.Material.Metal,Color3.fromRGB(150,150,145),folders.Summit,true)
part("FlagRed",Vector3.new(12,3.5,.25),CFrame.new(summit+Vector3.new(34,17.3,5)),Enum.Material.Fabric,C.red,folders.Summit,false)
part("FlagWhite",Vector3.new(12,3.5,.25),CFrame.new(summit+Vector3.new(34,13.8,5)),Enum.Material.Fabric,C.white,folders.Summit,false)
part("PhotoSpot",Vector3.new(22,.8,16),CFrame.new(summit+Vector3.new(-30,.7,8)),Enum.Material.WoodPlanks,C.wood,folders.Summit,true)
textBoard("PhotoSpotLabel",summit+Vector3.new(-30,8,-1),route[#route-1],18,5,"PHOTO SPOT\nMOUNT BBYA",folders.Summit)

-- ============================================================================
-- LIGHTING / ATMOSPHERE
-- ============================================================================
Lighting.ClockTime = 7.15
Lighting.Brightness = 2.35
Lighting.GlobalShadows = true
Lighting.EnvironmentDiffuseScale = 0.35
Lighting.EnvironmentSpecularScale = 0.5
Lighting.OutdoorAmbient = Color3.fromRGB(112,118,110)
Lighting.Ambient = Color3.fromRGB(84,89,84)

for _,objName in ipairs({"MountBBYA_Atmosphere","MountBBYA_Color","MountBBYA_Bloom"}) do
    local existing=Lighting:FindFirstChild(objName);if existing then existing:Destroy() end
end
local atmosphere=Instance.new("Atmosphere")
atmosphere.Name="MountBBYA_Atmosphere"
atmosphere.Density=.29
atmosphere.Offset=.05
atmosphere.Color=Color3.fromRGB(205,219,211)
atmosphere.Decay=Color3.fromRGB(113,128,119)
atmosphere.Glare=.08
atmosphere.Haze=1.7
atmosphere.Parent=Lighting
local cc=Instance.new("ColorCorrectionEffect")
cc.Name="MountBBYA_Color";cc.Brightness=.02;cc.Contrast=.08;cc.Saturation=.03;cc.TintColor=Color3.fromRGB(246,244,230);cc.Parent=Lighting
local bloom=Instance.new("BloomEffect")
bloom.Name="MountBBYA_Bloom";bloom.Intensity=.12;bloom.Size=18;bloom.Threshold=1.45;bloom.Parent=Lighting

-- ============================================================================
-- CHECKPOINT RUNTIME
-- ============================================================================
local checkpointCFrames={}
for idx,s in ipairs(checkpointSpecs) do checkpointCFrames[idx]=CFrame.new(route[s[2]]+Vector3.new(0,5,0)) end

local function bindPlayer(plr)
    if plr:GetAttribute("MountBBYACheckpoint") == nil then plr:SetAttribute("MountBBYACheckpoint",0) end
    plr.CharacterAdded:Connect(function(ch)
        task.wait(.35)
        local cp=plr:GetAttribute("MountBBYACheckpoint") or 0
        local cf=checkpointCFrames[cp]
        if cf and ch.Parent then ch:PivotTo(cf) end
    end)
end
for _,plr in ipairs(Players:GetPlayers()) do bindPlayer(plr) end
Players.PlayerAdded:Connect(bindPlayer)

for idx,pad in ipairs(checkpointPads) do
    pad.Touched:Connect(function(hit)
        local ch=hit and hit.Parent
        local plr=ch and Players:GetPlayerFromCharacter(ch)
        if not plr then return end
        local oldCp=plr:GetAttribute("MountBBYACheckpoint") or 0
        if idx > oldCp then
            plr:SetAttribute("MountBBYACheckpoint",idx)
            plr:SetAttribute("MountBBYALastCheckpointName",checkpointSpecs[idx][3])
        end
    end)
end

-- Fall rescue: returns players to latest checkpoint or spawn.
task.spawn(function()
    while root.Parent do
        for _,plr in ipairs(Players:GetPlayers()) do
            local ch=plr.Character
            local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y < -60 then
                local cp=plr:GetAttribute("MountBBYACheckpoint") or 0
                local cf=checkpointCFrames[cp] or spawn.CFrame+Vector3.new(0,5,0)
                ch:PivotTo(cf)
                hrp.AssemblyLinearVelocity=Vector3.zero
                hrp.AssemblyAngularVelocity=Vector3.zero
            end
        end
        task.wait(.6)
    end
end)

-- ============================================================================
-- RUNTIME QC MARKERS
-- ============================================================================
local minCheckpointSpacing=1e9
for i=1,#checkpointPositions-1 do
    local d=(checkpointPositions[i+1]-checkpointPositions[i]).Magnitude
    if d<minCheckpointSpacing then minCheckpointSpacing=d end
end
root:SetAttribute("TrailSegmentCount",trailSegmentCount)
root:SetAttribute("TreeCount",treeCount)
root:SetAttribute("RockCount",rockCount)
root:SetAttribute("CheckpointCount",#checkpointPads)
root:SetAttribute("MinimumCheckpointSpacing",math.floor(minCheckpointSpacing))
root:SetAttribute("GroundedTrailArchitecture",true)
root:SetAttribute("FullRouteZones",11)
root:SetAttribute("VillageReady",true)
root:SetAttribute("BasecampReady",true)
root:SetAttribute("ForestReady",true)
root:SetAttribute("ValleyReady",true)
root:SetAttribute("CliffReady",true)
root:SetAttribute("HighCampReady",true)
root:SetAttribute("SummitReady",true)
root:SetAttribute("RuntimeState","READY")
Workspace:SetAttribute("MOUNT_BBYA_BUILD",BUILD)
Workspace:SetAttribute("MOUNT_BBYA_READY",true)

print(string.format("[MOUNT BBYA] %s READY route=%d studs trail=%d trees=%d rocks=%d checkpoints=%d minCpSpacing=%d", BUILD, math.floor(routeDistance()), trailSegmentCount, treeCount, rockCount, #checkpointPads, math.floor(minCheckpointSpacing)))
