local Workspace=game:GetService("Workspace")

local deadline=os.clock()+25
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_UPGRADE_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
if not world then return end
local train=world:FindFirstChild("TrainCars")
local upgrade=world:FindFirstChild("TRACK01_Upgrade_v2")
local lightsFolder=root:FindFirstChild("DynamicLights")
if not (train and upgrade and lightsFolder) then return end

root:SetAttribute("PolishVersion","2.1.0")

local C={
    fadedRed=Color3.fromRGB(112,37,31),
    darkRed=Color3.fromRGB(70,27,25),
    rust=Color3.fromRGB(119,57,37),
    deepRust=Color3.fromRGB(69,38,30),
    black=Color3.fromRGB(18,18,17),
    steel=Color3.fromRGB(82,81,76),
    cream=Color3.fromRGB(180,159,118),
    amber=Color3.fromRGB(255,163,75),
    red=Color3.fromRGB(190,43,33),
    wood=Color3.fromRGB(78,56,40),
}

local function cf(x,y,z,rx,ry,rz)
    return CFrame.new(x,y,z)*CFrame.Angles(math.rad(rx or 0),math.rad(ry or 0),math.rad(rz or 0))
end

local function part(parent,name,size,frame,color,material,transparency,collide,shape)
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
    if shape then p.Shape=shape end
    p.Parent=parent
    return p
end

local function cylinder(parent,name,size,frame,color,material,collide)
    return part(parent,name,size,frame,color,material,0,collide,Enum.PartType.Cylinder)
end

local function ball(parent,name,size,frame,color,material)
    return part(parent,name,size,frame,color,material,0,false,Enum.PartType.Ball)
end

local function surfaceText(target,face,text,textColor,bgColor,font)
    local gui=Instance.new("SurfaceGui")
    gui.Name="PolishSignage"
    gui.Face=face
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=44
    gui.LightInfluence=0.2
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
    label.Font=font or Enum.Font.GothamBold
    label.Parent=gui
    return label
end

local polish=Instance.new("Folder")
polish.Name="TRACK01_FinalPolish_v21"
polish.Parent=world
local railDetail=Instance.new("Folder")
railDetail.Name="RailcarMechanicalDetail"
railDetail.Parent=polish
local navigation=Instance.new("Folder")
navigation.Name="NavigationAndArrival"
navigation.Parent=polish
local venueDetail=Instance.new("Folder")
venueDetail.Name="VenueDetail"
venueDetail.Parent=polish

-- Give every retired carriage more mechanical depth and a clearer zone identity.
local cars={
    {name="CAR_01_SOCIAL",z=-58,label="CAR 01  /  SOCIAL"},
    {name="CAR_02_BAR",z=-5,label="CAR 02  /  BAR"},
    {name="CAR_03_DANCE",z=48,label="CAR 03  /  DANCE"},
    {name="CAR_04_END_OF_LINE",z=101,label="CAR 04  /  END OF LINE"},
}

for i,spec in ipairs(cars) do
    local car=train:FindFirstChild(spec.name)
    if car then
        local z=spec.z
        -- Visible brake reservoir and cross-piping between the bogies.
        cylinder(railDetail,"BrakeReservoir",Vector3.new(6.0,1.4,1.4),cf(22,2.15,z,0,0,90),C.deepRust,Enum.Material.CorrodedMetal,false)
        part(railDetail,"BrakePipe",Vector3.new(0.38,0.38,28),cf(18.8,2.2,z),C.rust,Enum.Material.CorrodedMetal,0,false)
        part(railDetail,"BrakePipe",Vector3.new(0.38,0.38,28),cf(25.2,2.2,z),C.rust,Enum.Material.CorrodedMetal,0,false)
        for _,dz in ipairs({-15.5,15.5}) do
            for _,x in ipairs({17.5,26.5}) do
                cylinder(railDetail,"Suspension",Vector3.new(1.5,1.15,1.15),cf(x,3.0,z+dz,0,0,90),C.black,Enum.Material.CorrodedMetal,false)
            end
        end
        -- Platform-side door handrails and step edge make the boarding point read as a real carriage.
        for _,dz in ipairs({-3,3}) do
            cylinder(railDetail,"DoorHandrail",Vector3.new(5.6,0.32,0.32),cf(11.9,8.2,z+dz,0,0,90),C.steel,Enum.Material.CorrodedMetal,false)
        end
        part(railDetail,"DoorStepEdge",Vector3.new(0.35,0.35,6.2),cf(10.65,3.75,z),C.cream,Enum.Material.CorrodedMetal,0.20,false)

        -- Zone plaque faces the platform; subdued enough to keep the abandoned look.
        local plaque=part(navigation,"CarZonePlaque",Vector3.new(0.18,2.2,10.5),cf(13.28,12.8,z+13,0,90,0),C.darkRed,Enum.Material.CorrodedMetal,0,false)
        surfaceText(plaque,Enum.NormalId.Front,spec.label,C.cream,C.darkRed,Enum.Font.RobotoMono)

        -- A few missing/faded maintenance marks so the weathering feels authored rather than uniform.
        for _,dz in ipairs({-16,8,18}) do
            part(railDetail,"MaintenanceScar",Vector3.new(0.10,0.38,3.8),cf(13.27,6.3+(i%2)*0.4,z+dz,0,(i*11+dz)%13-6,0),C.steel,Enum.Material.CorrodedMetal,0.32,false)
        end
    end
end

-- Platform wall-wash fixtures illuminate the rusty-red body without turning it into a neon train.
for z=-72,116,27 do
    local fixture=part(venueDetail,"TrainWashFixture",Vector3.new(0.8,0.65,1.0),cf(10.2,3.45,z),C.black,Enum.Material.Metal,0,false)
    local spot=Instance.new("SpotLight")
    spot.Face=Enum.NormalId.Right
    spot.Color=((math.floor((z+72)/27)%3)==0) and C.amber or Color3.fromRGB(229,189,137)
    spot.Brightness=0.95
    spot.Range=17
    spot.Angle=62
    spot.Shadows=true
    spot.Parent=fixture
end

-- Arrival sequence: old turnstiles in the station hall, then a clear boarding portal.
for _,x in ipairs({-46,-39,-32}) do
    cylinder(navigation,"TurnstilePost",Vector3.new(4.6,0.75,0.75),cf(x,3.1,-91,0,0,90),C.deepRust,Enum.Material.CorrodedMetal,true)
    for arm=0,2 do
        local angle=arm*120+12
        part(navigation,"TurnstileArm",Vector3.new(5.2,0.28,0.28),cf(x,4.1,-91,0,angle,0),C.steel,Enum.Material.CorrodedMetal,0,false)
    end
end

part(navigation,"BoardingPortalL",Vector3.new(1.0,12,1.0),cf(-13,6.0,-68),C.deepRust,Enum.Material.CorrodedMetal,0,true)
part(navigation,"BoardingPortalR",Vector3.new(1.0,12,1.0),cf(7,6.0,-68),C.deepRust,Enum.Material.CorrodedMetal,0,true)
part(navigation,"BoardingPortalTop",Vector3.new(21,1.0,1.0),cf(-3,12.0,-68),C.deepRust,Enum.Material.CorrodedMetal,0,true)
local boardingSign=part(navigation,"BoardingSign",Vector3.new(16,4.0,0.55),cf(-3,10.0,-67.4),C.black,Enum.Material.CorrodedMetal,0,false)
surfaceText(boardingSign,Enum.NormalId.Front,"BOARDING  /  PLATFORM 01",C.cream,C.black,Enum.Font.GothamBlack)

-- Wayfinding is kept physical rather than HUD-based.
local wayfinder=part(navigation,"Wayfinder",Vector3.new(15,7.2,0.55),cf(-4,9.8,141),C.black,Enum.Material.CorrodedMetal,0,false)
surfaceText(wayfinder,Enum.NormalId.Front,"← STATION\nTHE YARD ←\nEND OF LINE →",C.cream,C.black,Enum.Font.RobotoMono)

-- Luggage/travel remnants around the old platform strengthen the abandoned-station story.
for _,spec in ipairs({
    {-7,3.3,-18,5.0,2.6,3.0,-8},
    {-5,3.1,91,4.2,2.2,2.8,5},
    {-66,1.7,-66,5.2,2.5,3.1,13},
}) do
    local x,y,z,sx,sy,sz,ry=table.unpack(spec)
    local trunk=part(venueDetail,"OldTrunk",Vector3.new(sx,sy,sz),cf(x,y,z,0,ry,0),C.wood,Enum.Material.WoodPlanks,0,true)
    part(venueDetail,"TrunkBandA",Vector3.new(sx+0.08,0.22,0.3),trunk.CFrame*CFrame.new(0,sy*0.22,-sz*0.24),C.deepRust,Enum.Material.CorrodedMetal,0,false)
    part(venueDetail,"TrunkBandB",Vector3.new(sx+0.08,0.22,0.3),trunk.CFrame*CFrame.new(0,sy*0.22,sz*0.24),C.deepRust,Enum.Material.CorrodedMetal,0,false)
end

-- Car 03/04 receive small overhead moving-light silhouettes; the existing client pulses their lights.
for _,spec in ipairs({
    {17.0,14.1,42,C.amber},{27.0,14.1,54,C.red},
    {17.0,14.1,91,C.red},{27.0,14.1,105,C.amber},
}) do
    local x,y,z,col=table.unpack(spec)
    local fixture=part(venueDetail,"ClubHead",Vector3.new(1.3,1.0,1.6),cf(x,y,z,0,0,(x<22) and -12 or 12),C.black,Enum.Material.Metal,0,false)
    local s=Instance.new("SpotLight")
    s.Face=Enum.NormalId.Bottom
    s.Color=col
    s.Brightness=1.05
    s.Range=18
    s.Angle=48
    s.Shadows=false
    s.Name="PulseLight"
    s.Parent=fixture
    fixture.Parent=lightsFolder
end

-- Yard portal: a simple corroded steel frame makes the outdoor room feel intentional.
part(venueDetail,"YardPortalL",Vector3.new(0.8,12,0.8),cf(-74,6.0,18),C.deepRust,Enum.Material.CorrodedMetal,0,true)
part(venueDetail,"YardPortalR",Vector3.new(0.8,12,0.8),cf(-28,6.0,18),C.deepRust,Enum.Material.CorrodedMetal,0,true)
part(venueDetail,"YardPortalTop",Vector3.new(47,0.8,0.8),cf(-51,12.0,18),C.deepRust,Enum.Material.CorrodedMetal,0,true)
local yardPortalSign=part(venueDetail,"YardPortalSign",Vector3.new(17,4.0,0.45),cf(-51,10.0,17.55),C.darkRed,Enum.Material.CorrodedMetal,0,false)
surfaceText(yardPortalSign,Enum.NormalId.Front,"THE YARD",C.cream,C.darkRed,Enum.Font.GothamBlack)

-- Low bollard lights make The Yard usable while keeping the station itself dominant.
for z=31,103,18 do
    local post=cylinder(venueDetail,"YardBollard",Vector3.new(2.6,0.5,0.5),cf(-18,1.7,z,0,0,90),C.deepRust,Enum.Material.CorrodedMetal,true)
    local glow=ball(venueDetail,"YardBollardGlow",Vector3.new(0.75,0.75,0.75),cf(-18,3.15,z),C.amber,Enum.Material.Neon)
    local light=Instance.new("PointLight")
    light.Color=C.amber
    light.Brightness=0.38
    light.Range=7
    light.Shadows=false
    light.Parent=glow
end

-- End-of-line physical bumper behind the hero car closes the railway composition.
part(railDetail,"BufferBeam",Vector3.new(18,1.2,1.2),cf(22,3.1,134),C.deepRust,Enum.Material.CorrodedMetal,0,true)
for _,x in ipairs({16,28}) do
    cylinder(railDetail,"BufferPost",Vector3.new(4.5,0.8,0.8),cf(x,3.1,132,90,0,0),C.deepRust,Enum.Material.CorrodedMetal,true)
    cylinder(railDetail,"BufferHead",Vector3.new(0.75,3.2,3.2),cf(x,3.1,134.3,0,90,0),C.black,Enum.Material.CorrodedMetal,true)
end
local finalMarker=part(navigation,"FinalMarker",Vector3.new(13,3.2,0.5),cf(22,6.0,135),C.black,Enum.Material.CorrodedMetal,0,false)
surfaceText(finalMarker,Enum.NormalId.Front,"NO FURTHER SERVICE",C.red,C.black,Enum.Font.RobotoMono)

Workspace:SetAttribute("ACC_TRACK01_POLISH_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","2.1.0")
print("[TRACK 01] final polish ready v2.1.0")
