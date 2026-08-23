local Workspace=game:GetService("Workspace")

-- TRACK 01 v2.6 arrival + yard atmosphere pass.
-- Visual/physical only: no audio uploads or asset references.
local deadline=os.clock()+45
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_INTERIOR_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
local architecture=world and world:FindFirstChild("Architecture")
local props=world and world:FindFirstChild("Props")
local railway=world and world:FindFirstChild("Railway")
if not (world and architecture and props and railway) then return end

local old=world:FindFirstChild("TRACK01_Atmosphere_v26")
if old then old:Destroy() end
local atmosphere=Instance.new("Folder")
atmosphere.Name="TRACK01_Atmosphere_v26"
atmosphere.Parent=world
local arrival=Instance.new("Folder"); arrival.Name="ArrivalSequence"; arrival.Parent=atmosphere
local station=Instance.new("Folder"); station.Name="StationAtmosphere"; station.Parent=atmosphere
local yard=Instance.new("Folder"); yard.Name="YardAtmosphere"; yard.Parent=atmosphere
local rail=Instance.new("Folder"); rail.Name="RailwayAtmosphere"; rail.Parent=atmosphere

local C={
    black=Color3.fromRGB(17,18,18),
    charcoal=Color3.fromRGB(29,30,30),
    steel=Color3.fromRGB(73,75,73),
    steel2=Color3.fromRGB(101,101,96),
    rust=Color3.fromRGB(91,48,37),
    rustDark=Color3.fromRGB(61,37,31),
    brick=Color3.fromRGB(75,49,42),
    concrete=Color3.fromRGB(72,69,64),
    warm=Color3.fromRGB(240,219,193),
    amber=Color3.fromRGB(241,161,79),
    red=Color3.fromRGB(184,42,36),
    cream=Color3.fromRGB(171,152,116),
    wood=Color3.fromRGB(74,53,40),
    glass=Color3.fromRGB(35,45,47),
    foliage=Color3.fromRGB(49,59,42),
}

local function cf(x,y,z,rx,ry,rz)
    return CFrame.new(x,y,z)*CFrame.Angles(math.rad(rx or 0),math.rad(ry or 0),math.rad(rz or 0))
end
local function part(parent,name,size,frame,color,material,transparency,collide)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=frame
    p.Color=color or C.steel
    p.Material=material or Enum.Material.Metal
    p.Anchored=true
    p.CanCollide=collide==true
    p.CanTouch=false
    p.CanQuery=true
    p.Transparency=transparency or 0
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end
local function cylinder(parent,name,size,frame,color,material,transparency,collide)
    local p=part(parent,name,size,frame,color,material,transparency,collide)
    p.Shape=Enum.PartType.Cylinder
    return p
end
local function ball(parent,name,size,frame,color,material,transparency)
    local p=part(parent,name,size,frame,color,material,transparency,false)
    p.Shape=Enum.PartType.Ball
    return p
end
local function pointLight(parent,color,brightness,range,shadows)
    local l=Instance.new("PointLight")
    l.Color=color
    l.Brightness=brightness
    l.Range=range
    l.Shadows=shadows==true
    l.Parent=parent
    return l
end
local function spotLight(parent,color,brightness,range,angle,face)
    local l=Instance.new("SpotLight")
    l.Color=color
    l.Brightness=brightness
    l.Range=range
    l.Angle=angle
    l.Face=face or Enum.NormalId.Bottom
    l.Shadows=true
    l.Parent=parent
    return l
end
local function surfaceText(target,face,text,textColor,bgColor,font)
    local gui=Instance.new("SurfaceGui")
    gui.Name="AtmosphereSignage"
    gui.Face=face
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=44
    gui.LightInfluence=0.25
    gui.Parent=target
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundColor3=bgColor or C.black
    label.BackgroundTransparency=0.08
    label.BorderSizePixel=0
    label.Text=text
    label.TextColor3=textColor or C.cream
    label.TextScaled=true
    label.TextWrapped=true
    label.Font=font or Enum.Font.RobotoMono
    label.Parent=gui
end

-- Arrival lane: readable but still abandoned/industrial.
for _,x in ipairs({-68,-49,-30,-11}) do
    local pole=cylinder(arrival,"ArrivalLampPole",Vector3.new(8.5,0.36,0.36),cf(x,4.6,-62,0,0,90),C.charcoal,Enum.Material.Metal,0,true)
    local head=part(arrival,"ArrivalLampHead",Vector3.new(2.2,0.45,1.0),cf(x,9.0,-62),C.black,Enum.Material.Metal,0,false)
    local glow=part(arrival,"ArrivalLampGlow",Vector3.new(1.45,0.12,0.70),cf(x,8.72,-62),C.warm,Enum.Material.Neon,0.16,false)
    pointLight(glow,C.warm,0.48,11,false)
end
for _,spec in ipairs({{-67,-54,10,5,-4},{-37,-56,8,4,5},{-12,-58,7,3,-7}}) do
    local x,z,sx,sz,ry=spec[1],spec[2],spec[3],spec[4],spec[5]
    part(arrival,"ArrivalPuddle",Vector3.new(sx,0.035,sz),cf(x,0.42,z,0,ry,0),C.glass,Enum.Material.Glass,0.48,false)
end
local entryBoard=part(arrival,"EntryBoard",Vector3.new(19,5.2,0.45),cf(-39,9.5,-70.5),C.black,Enum.Material.Metal,0,false)
surfaceText(entryBoard,Enum.NormalId.Front,"TRACK 01\nNIGHT SERVICE  •  BOARDING",C.cream,C.black,Enum.Font.GothamBold)

-- Station facade: old gooseneck lamps, ticket grille detail and battered information case.
for _,x in ipairs({-60,-39,-18}) do
    part(station,"FacadeLampArm",Vector3.new(0.28,0.28,2.4),cf(x,13.0,-76.0,75,0,0),C.charcoal,Enum.Material.Metal,0,false)
    local shade=cylinder(station,"FacadeLampShade",Vector3.new(0.30,1.7,1.7),cf(x,12.5,-77.0,0,90,0),C.black,Enum.Material.Metal,0,false)
    local bulb=ball(station,"FacadeLampBulb",Vector3.new(0.55,0.55,0.55),cf(x,12.2,-77.1),C.warm,Enum.Material.Neon,0.08)
    pointLight(bulb,C.warm,0.58,12,true)
end
for x=-63,-45,3 do
    part(station,"TicketGrilleV",Vector3.new(0.16,4.3,0.16),cf(x,7.1,-132.7),C.steel,Enum.Material.Metal,0,false)
end
for y=5.6,8.6,1.5 do
    part(station,"TicketGrilleH",Vector3.new(18.2,0.16,0.16),cf(-54, y,-132.7),C.steel,Enum.Material.Metal,0,false)
end
local infoCase=part(station,"OldInfoCase",Vector3.new(14.5,7.0,0.55),cf(-69.2,9.1,-98,0,90,0),C.charcoal,Enum.Material.Metal,0,false)
part(station,"InfoCaseGlass",Vector3.new(12.8,5.4,0.12),cf(-68.85,9.1,-98,0,90,0),Color3.fromRGB(43,54,57),Enum.Material.Glass,0.35,false)
surfaceText(infoCase,Enum.NormalId.Front,"TONIGHT\nPLATFORM 01\nLAST TRAIN  04:00",C.cream,C.charcoal)

-- Platform light rhythm: small pools, not a fully bright station.
for z=-110,126,24 do
    local bracket=part(station,"PlatformWallBracket",Vector3.new(1.6,0.45,0.55),cf(-8.5,10.5,z),C.charcoal,Enum.Material.Metal,0,false)
    local lamp=part(station,"PlatformWallGlow",Vector3.new(0.8,0.18,0.8),cf(-7.7,10.15,z),C.warm,Enum.Material.Neon,0.18,false)
    pointLight(lamp,C.warm,0.30,8,false)
end

-- The Yard: intentional outdoor room rather than leftover asphalt.
-- Perimeter pipe frame and string lights.
for _,x in ipairs({-71,-51,-31}) do
    cylinder(yard,"YardLightPole",Vector3.new(11,0.42,0.42),cf(x,5.8,44,0,0,90),C.charcoal,Enum.Material.Metal,0,true)
    cylinder(yard,"YardLightPole",Vector3.new(11,0.42,0.42),cf(x,5.8,92,0,0,90),C.charcoal,Enum.Material.Metal,0,true)
end
for _,z in ipairs({44,68,92}) do
    part(yard,"YardCable",Vector3.new(42,0.10,0.10),cf(-51,10.7,z),C.black,Enum.Material.SmoothPlastic,0,false)
    for x=-69,-33,6 do
        local bulb=ball(yard,"YardStringBulb",Vector3.new(0.38,0.38,0.38),cf(x,10.45,z),C.amber,Enum.Material.Neon,0.10)
        pointLight(bulb,C.amber,0.12,4,false)
    end
end

-- Railway salvage seating cluster with a less blocky silhouette.
for _,spec in ipairs({{-58,58,0},{-43,58,180},{-58,78,0},{-43,78,180}}) do
    local x,z,ry=spec[1],spec[2],spec[3]
    part(yard,"SalvageBenchSeat",Vector3.new(10,0.55,2.7),cf(x,2.5,z,0,ry,0),C.wood,Enum.Material.WoodPlanks,0,true)
    part(yard,"SalvageBenchBack",Vector3.new(10,2.5,0.42),cf(x,3.8,z-1.1,0,ry,0),C.wood,Enum.Material.WoodPlanks,0,false)
    for _,dx in ipairs({-3.6,3.6}) do
        cylinder(yard,"BenchLeg",Vector3.new(2.5,0.34,0.34),cf(x+dx,1.35,z,0,0,90),C.rustDark,Enum.Material.CorrodedMetal,0,true)
    end
end

-- Fire barrel / heat light focal point, deliberately low brightness.
local fireBarrel=cylinder(yard,"FireBarrel",Vector3.new(4.5,3.0,3.0),cf(-51,2.6,68,0,0,90),C.rust,Enum.Material.CorrodedMetal,0,true)
for i=0,5 do
    part(yard,"BarrelCut",Vector3.new(0.18,0.32,0.8),fireBarrel.CFrame*CFrame.new(0,0.7,(i-2.5)*0.8),C.black,Enum.Material.Metal,0,false)
end
local fireGlow=ball(yard,"FireGlow",Vector3.new(1.4,1.4,1.4),cf(-51,4.5,68),Color3.fromRGB(235,119,55),Enum.Material.Neon,0.32)
pointLight(fireGlow,Color3.fromRGB(235,119,55),0.38,9,false)

-- Photo wall built from railway signal language, not generic neon.
part(yard,"PhotoWall",Vector3.new(30,8.5,0.8),cf(-75,5.0,74,0,90,0),C.charcoal,Enum.Material.Metal,0,true)
local photoSign=part(yard,"PhotoSign",Vector3.new(21,4.2,0.16),cf(-74.5,6.2,74,0,90,0),C.black,Enum.Material.Metal,0,false)
surfaceText(photoSign,Enum.NormalId.Front,"NO DESTINATION\nJUST THE NIGHT",C.cream,C.black,Enum.Font.GothamBlack)
for _,y in ipairs({3.0,8.8}) do
    for _,z in ipairs({66,82}) do
        local marker=ball(yard,"SignalMarker",Vector3.new(1.4,1.4,1.4),cf(-74.2,y,z),((z+y)%2<1) and C.red or C.amber,Enum.Material.Neon,0.10)
        pointLight(marker,marker.Color,0.18,5,false)
    end
end

-- Railway-side story details: signal mast and mileage/stop marker.
cylinder(rail,"SignalMast",Vector3.new(13.5,0.55,0.55),cf(35,7.3,147,0,0,90),C.steel,Enum.Material.CorrodedMetal,0,true)
part(rail,"SignalHead",Vector3.new(3.5,6.8,2.0),cf(35,12.0,147),C.black,Enum.Material.Metal,0,false)
for _,spec in ipairs({{14.0,C.red},{11.7,C.amber},{9.4,Color3.fromRGB(66,103,69)}}) do
    local y,col=spec[1],spec[2]
    local lens=ball(rail,"SignalLens",Vector3.new(1.35,1.35,0.55),cf(35,y,145.9),col,Enum.Material.Neon,0.18)
    pointLight(lens,col,0.16,5,false)
end
local mile=part(rail,"MileMarker",Vector3.new(4.8,5.5,0.55),cf(7.5,4.8,142),C.black,Enum.Material.Metal,0,true)
surfaceText(mile,Enum.NormalId.Front,"T01\n0.0",C.cream,C.black)

-- A few sparse weeds along the old rail edge; enough age without turning the venue into ruins.
for z=-145,170,35 do
    for _,x in ipairs({10.5,33.5}) do
        cylinder(rail,"RailWeed",Vector3.new(1.8,0.16,0.16),cf(x,1.1,z,0,0,78),C.foliage,Enum.Material.Grass,0,false)
        cylinder(rail,"RailWeed",Vector3.new(1.4,0.14,0.14),cf(x+0.5,0.9,z+0.7,0,0,102),C.foliage,Enum.Material.Grass,0,false)
    end
end

root:SetAttribute("AtmosphereVersion","2.6.0")
Workspace:SetAttribute("ACC_TRACK01_ATMOSPHERE_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","2.6.0")
print("[TRACK 01] arrival + yard atmosphere ready v2.6.0")
