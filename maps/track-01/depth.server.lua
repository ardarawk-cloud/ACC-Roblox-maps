local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")

-- TRACK 01 v2.3 venue-depth pass.
-- Goal: preserve the corrected faded-red color while making each railcar read as a
-- retired real-world carriage rather than a flat Roblox box. Geometry is deliberately
-- selective so mobile part-count remains reasonable.
local deadline=os.clock()+30
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_CORRECTION_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
local train=world and world:FindFirstChild("TrainCars")
local architecture=world and world:FindFirstChild("Architecture")
local props=world and world:FindFirstChild("Props")
local lightsFolder=root:FindFirstChild("DynamicLights")
if not (world and train and architecture and props and lightsFolder) then return end

root:SetAttribute("VenueDepthVersion","2.3.0")
root:SetAttribute("VenueDepthLock","Retired faded-red railway carriage with structural depth")

local C={
    red=Color3.fromRGB(111,31,34),
    redAlt=Color3.fromRGB(122,35,38),
    redDark=Color3.fromRGB(64,21,24),
    redShadow=Color3.fromRGB(79,24,27),
    charcoal=Color3.fromRGB(24,25,25),
    rubber=Color3.fromRGB(17,18,18),
    steel=Color3.fromRGB(70,72,71),
    steelLight=Color3.fromRGB(100,101,97),
    grime=Color3.fromRGB(32,31,29),
    rust=Color3.fromRGB(92,49,38),
    cream=Color3.fromRGB(172,153,117),
    glassBack=Color3.fromRGB(22,30,34),
    warm=Color3.fromRGB(236,218,194),
    amber=Color3.fromRGB(255,164,79),
    signal=Color3.fromRGB(184,44,37),
    concrete=Color3.fromRGB(72,70,66),
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

local function cylinder(parent,name,size,frame,color,material,transparency)
    local p=part(parent,name,size,frame,color,material,transparency,false)
    p.Shape=Enum.PartType.Cylinder
    return p
end

local function beamBetween(parent,name,a,b,thickness,color,material,transparency)
    local delta=b-a
    local length=delta.Magnitude
    local mid=(a+b)*0.5
    return part(parent,name,Vector3.new(thickness,thickness,length),CFrame.lookAt(mid,b),color,material,transparency,false)
end

local function surfaceText(target,face,text,textColor,bgColor,font)
    local gui=Instance.new("SurfaceGui")
    gui.Name="DepthSignage"
    gui.Face=face
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=44
    gui.LightInfluence=0.30
    gui.Parent=target
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundColor3=bgColor or C.charcoal
    label.BackgroundTransparency=0.08
    label.BorderSizePixel=0
    label.Text=text
    label.TextColor3=textColor or C.cream
    label.TextScaled=true
    label.TextWrapped=true
    label.Font=font or Enum.Font.RobotoMono
    label.Parent=gui
    return label
end

local depth=Instance.new("Folder")
depth.Name="TRACK01_VenueDepth_v23"
depth.Parent=world
local railcarDetail=Instance.new("Folder")
railcarDetail.Name="RailcarStructuralDepth"
railcarDetail.Parent=depth
local platformDetail=Instance.new("Folder")
platformDetail.Name="PlatformDepth"
platformDetail.Parent=depth
local stationDetail=Instance.new("Folder")
stationDetail.Name="StationDepth"
stationDetail.Parent=depth
local lightDetail=Instance.new("Folder")
lightDetail.Name="DepthLighting"
lightDetail.Parent=depth

local cars={
    {name="CAR_01_SOCIAL",z=-58,role="SOCIAL",shade=C.red},
    {name="CAR_02_BAR",z=-5,role="BAR",shade=C.redAlt},
    {name="CAR_03_DANCE",z=48,role="DANCE",shade=C.red},
    {name="CAR_04_END_OF_LINE",z=101,role="END OF LINE",shade=C.redAlt},
}

-- Window positions match the base carriage generator. The platform-side center window
-- is the open door, so we do not frame it as glass.
local windowOffsets={-19,-12.5,-6,0.5,7,13.5}

for index,spec in ipairs(cars) do
    local car=train:FindFirstChild(spec.name)
    if car then
        local z=spec.z

        -- Deep lower skirt and upper waist line stop the side from reading as one flat slab.
        for _,sx in ipairs({-1,1}) do
            local x=22+sx*8.64
            part(railcarDetail,"InsetLowerSkirt",Vector3.new(0.16,1.0,46.5),cf(x,5.25,z),C.redShadow,Enum.Material.Metal,0.03,false)
            part(railcarDetail,"WaistShadow",Vector3.new(0.13,0.42,46),cf(x,9.05,z),C.redDark,Enum.Material.Metal,0.06,false)
            part(railcarDetail,"RoofGutter",Vector3.new(0.22,0.35,47),cf(x,14.95,z),C.charcoal,Enum.Material.Metal,0,false)

            -- Recess behind each window. A dark inset around existing glass gives visible depth
            -- without rebuilding every window from several small parts.
            for _,dz in ipairs(windowOffsets) do
                local isPlatformDoor=(sx==-1 and math.abs(dz-0.5)<0.2)
                if not isPlatformDoor then
                    local recessX=x-sx*0.20
                    part(railcarDetail,"WindowRecess",Vector3.new(0.12,3.75,5.72),cf(recessX,11.05,z+dz),C.glassBack,Enum.Material.Metal,0.05,false)
                    part(railcarDetail,"WindowBrow",Vector3.new(0.10,0.30,5.85),cf(x-sx*0.27,13.05,z+dz),C.redDark,Enum.Material.Metal,0,false)
                end
            end
        end

        -- Platform-side doorway gets a proper recessed jamb, kick plate, threshold and grab bars.
        local doorX=13.20
        part(railcarDetail,"DoorRecess",Vector3.new(0.16,7.7,5.55),cf(doorX,9.0,z+0.5),C.charcoal,Enum.Material.Metal,0.02,false)
        part(railcarDetail,"DoorKickPlate",Vector3.new(0.12,1.25,5.2),cf(doorX-0.04,5.35,z+0.5),C.steel,Enum.Material.DiamondPlate,0,false)
        part(railcarDetail,"DoorThreshold",Vector3.new(2.0,0.28,5.65),cf(12.15,4.05,z+0.5),C.steelLight,Enum.Material.DiamondPlate,0,false)
        for _,dz in ipairs({-2.35,2.35}) do
            cylinder(railcarDetail,"DoorGrab",Vector3.new(4.6,0.26,0.26),cf(12.80,8.2,z+0.5+dz,0,0,90),C.steelLight,Enum.Material.Metal,0)
        end

        -- Destination/zone blind: small railway-like sign above the platform door.
        local blind=part(railcarDetail,"DestinationBlind",Vector3.new(0.12,1.15,7.2),cf(13.12,14.15,z+0.5),C.charcoal,Enum.Material.Metal,0,false)
        surfaceText(blind,Enum.NormalId.Front,string.format("01  %s",spec.role),C.cream,C.charcoal,Enum.Font.RobotoMono)

        -- Underframe diagonals add silhouette depth when viewed from the platform.
        local leftX=15.0
        local rightX=29.0
        for _,sx in ipairs({-1,1}) do
            local x=(sx==-1) and leftX or rightX
            beamBetween(railcarDetail,"UnderframeBrace",Vector3.new(x,3.55,z-19),Vector3.new(x,2.35,z-8),0.36,C.charcoal,Enum.Material.Metal,0)
            beamBetween(railcarDetail,"UnderframeBrace",Vector3.new(x,2.35,z+8),Vector3.new(x,3.55,z+19),0.36,C.charcoal,Enum.Material.Metal,0)
        end

        -- Flexible gangway/diaphragm around each car end visually separates the carriages.
        for _,endSign in ipairs({-1,1}) do
            local ez=z+endSign*24.85
            part(railcarDetail,"GangwayTop",Vector3.new(7.0,0.55,0.42),cf(22,14.15,ez),C.rubber,Enum.Material.SmoothPlastic,0,false)
            part(railcarDetail,"GangwayBottom",Vector3.new(7.0,0.55,0.42),cf(22,5.4,ez),C.rubber,Enum.Material.SmoothPlastic,0,false)
            part(railcarDetail,"GangwayLeft",Vector3.new(0.55,9.3,0.42),cf(18.55,9.75,ez),C.rubber,Enum.Material.SmoothPlastic,0,false)
            part(railcarDetail,"GangwayRight",Vector3.new(0.55,9.3,0.42),cf(25.45,9.75,ez),C.rubber,Enum.Material.SmoothPlastic,0,false)
        end

        -- Roof center channel and low-profile vents create a stronger railway roof silhouette.
        part(railcarDetail,"RoofCenterChannel",Vector3.new(1.35,0.28,39),cf(22,17.78,z),C.charcoal,Enum.Material.Metal,0,false)
        for _,dz in ipairs({-12,0,12}) do
            part(railcarDetail,"RoofEquipment",Vector3.new(3.3,0.65,4.4),cf(22,18.05,z+dz),C.steel,Enum.Material.Metal,0,false)
            cylinder(railcarDetail,"RoofCap",Vector3.new(0.45,2.2,2.2),cf(22,18.45,z+dz,0,0,90),C.charcoal,Enum.Material.Metal,0)
        end

        -- Small faded maintenance stencil, still red-first rather than rust-first.
        local stencil=part(railcarDetail,"MaintenanceStencil",Vector3.new(0.10,1.1,5.4),cf(30.62,6.4,z-15),spec.shade,Enum.Material.Metal,0.08,false)
        surfaceText(stencil,Enum.NormalId.Front,string.format("DEPOT 01-%02d",index),C.cream,spec.shade,Enum.Font.RobotoMono)
    end
end

-- Platform realism: drainage, cable conduit, tactile breaks and a modest inspection pit edge.
for z=-124,136,26 do
    part(platformDetail,"DrainGrate",Vector3.new(3.2,0.06,0.7),cf(7.8,2.91,z),C.charcoal,Enum.Material.DiamondPlate,0,false)
end
part(platformDetail,"UtilityConduit",Vector3.new(0.34,0.34,236),cf(-9.0,5.6,16),C.steel,Enum.Material.Metal,0,false)
for z=-100,120,44 do
    part(platformDetail,"ConduitClamp",Vector3.new(0.8,0.8,0.22),cf(-9.0,5.6,z),C.charcoal,Enum.Material.Metal,0,false)
end

-- Old station route board and electrical cabinet: practical remnants instead of random clutter.
local routeBoard=part(stationDetail,"OldRouteBoard",Vector3.new(20,7.5,0.55),cf(-69.7,9.5,-112,0,90,0),C.charcoal,Enum.Material.Metal,0,false)
surfaceText(routeBoard,Enum.NormalId.Front,"TRACK 01\nLOCAL  •  NIGHT SERVICE\nTERMINUS  →  END OF LINE",C.cream,C.charcoal,Enum.Font.RobotoMono)
part(stationDetail,"ElectricalCabinet",Vector3.new(5.5,8.2,2.4),cf(-67,4.1,-141),Color3.fromRGB(55,58,56),Enum.Material.Metal,0,true)
part(stationDetail,"CabinetDoor",Vector3.new(4.8,6.9,0.14),cf(-67,4.2,-139.75),Color3.fromRGB(65,68,65),Enum.Material.Metal,0,false)
for y=2.1,6.2,2.05 do
    cylinder(stationDetail,"CabinetLatch",Vector3.new(0.35,0.6,0.6),cf(-65.1,y,-139.55,0,90,0),C.rust,Enum.Material.CorrodedMetal,0)
end

-- Neutral canopy pools: enough light to read the red body but not wash the venue orange.
for z=-103,131,39 do
    local fixture=part(lightDetail,"NeutralCanopyFixture",Vector3.new(2.5,0.35,1.2),cf(3.2,13.55,z),C.charcoal,Enum.Material.Metal,0,false)
    local light=Instance.new("PointLight")
    light.Color=C.warm
    light.Brightness=0.48
    light.Range=13
    light.Shadows=true
    light.Parent=fixture
end

-- A restrained red bounce only around the hero end-of-line carriage.
for _,z in ipairs({91,111}) do
    local fixture=part(lightDetail,"HeroBounceFixture",Vector3.new(0.65,0.55,1.0),cf(10.5,3.5,z),C.charcoal,Enum.Material.Metal,0,false)
    local light=Instance.new("SpotLight")
    light.Face=Enum.NormalId.Right
    light.Color=Color3.fromRGB(145,48,46)
    light.Brightness=0.38
    light.Range=12
    light.Angle=70
    light.Shadows=false
    light.Parent=fixture
end

-- Slightly more contrast in the blacks while keeping red paint readable on mobile.
Lighting.Brightness=1.70
Lighting.Ambient=Color3.fromRGB(38,40,42)
Lighting.OutdoorAmbient=Color3.fromRGB(46,48,49)
local cc=Lighting:FindFirstChild("TRACK01_Color")
if cc and cc:IsA("ColorCorrectionEffect") then
    cc.Brightness=0.008
    cc.Contrast=0.17
    cc.Saturation=-0.03
    cc.TintColor=Color3.fromRGB(242,235,228)
end

Workspace:SetAttribute("ACC_TRACK01_DEPTH_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","2.3.0")
print("[TRACK 01] venue depth ready v2.3.0")
