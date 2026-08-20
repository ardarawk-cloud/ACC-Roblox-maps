local Workspace=game:GetService("Workspace")

-- TRACK 01 v2.4 railcar-profile pass.
-- Adds silhouette/profile cues that make the retired cars read less like rectangular Roblox shells.
local deadline=os.clock()+35
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_RESPAWN_LIGHT_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
local train=world and world:FindFirstChild("TrainCars")
if not (world and train) then return end

local old=world:FindFirstChild("TRACK01_Profile_v24")
if old then old:Destroy() end

local profile=Instance.new("Folder")
profile.Name="TRACK01_Profile_v24"
profile.Parent=world
local shell=Instance.new("Folder")
shell.Name="RailcarProfile"
shell.Parent=profile
local vestibules=Instance.new("Folder")
vestibules.Name="VestibuleConnections"
vestibules.Parent=profile
local platform=Instance.new("Folder")
platform.Name="PlatformProfile"
platform.Parent=profile

local C={
    red=Color3.fromRGB(111,31,34),
    redAlt=Color3.fromRGB(122,35,38),
    redDark=Color3.fromRGB(61,20,23),
    charcoal=Color3.fromRGB(23,24,24),
    rubber=Color3.fromRGB(16,17,17),
    steel=Color3.fromRGB(73,75,73),
    steel2=Color3.fromRGB(101,101,96),
    grime=Color3.fromRGB(31,30,28),
    cream=Color3.fromRGB(171,152,116),
    glass=Color3.fromRGB(29,40,44),
    warm=Color3.fromRGB(238,220,198),
    amber=Color3.fromRGB(242,163,84),
}

local function cf(x,y,z,rx,ry,rz)
    return CFrame.new(x,y,z)*CFrame.Angles(math.rad(rx or 0),math.rad(ry or 0),math.rad(rz or 0))
end

local function part(parent,name,size,frame,color,material,transparency,collide)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=frame
    p.Color=color
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

local function surfaceText(target,face,text,textColor,bgColor)
    local gui=Instance.new("SurfaceGui")
    gui.Name="ProfileSignage"
    gui.Face=face
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=42
    gui.LightInfluence=0.35
    gui.Parent=target
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundColor3=bgColor
    label.BackgroundTransparency=0.10
    label.BorderSizePixel=0
    label.Text=text
    label.TextColor3=textColor
    label.TextScaled=true
    label.TextWrapped=true
    label.Font=Enum.Font.RobotoMono
    label.Parent=gui
end

local cars={
    {name="CAR_01_SOCIAL",z=-58,shade=C.red},
    {name="CAR_02_BAR",z=-5,shade=C.redAlt},
    {name="CAR_03_DANCE",z=48,shade=C.red},
    {name="CAR_04_END_OF_LINE",z=101,shade=C.redAlt},
}

for index,spec in ipairs(cars) do
    local car=train:FindFirstChild(spec.name)
    if car then
        local z=spec.z

        -- Sloped roof shoulders: the strongest silhouette change from a box profile.
        part(shell,"RoofShoulderL",Vector3.new(4.0,0.72,47.0),cf(16.2,15.85,z,0,0,-18),C.charcoal,Enum.Material.Metal,0,false)
        part(shell,"RoofShoulderR",Vector3.new(4.0,0.72,47.0),cf(27.8,15.85,z,0,0,18),C.charcoal,Enum.Material.Metal,0,false)
        part(shell,"RoofCrown",Vector3.new(7.7,0.48,47.0),cf(22,17.08,z),Color3.fromRGB(48,49,48),Enum.Material.Metal,0,false)
        part(shell,"RoofCrownSeam",Vector3.new(0.34,0.18,45.5),cf(22,17.40,z),C.steel,Enum.Material.Metal,0,false)

        -- Lower body bevels remove the straight vertical drop to the underframe.
        part(shell,"LowerBevelL",Vector3.new(2.4,0.70,46.0),cf(14.7,5.05,z,0,0,20),spec.shade,Enum.Material.Metal,0.04,false)
        part(shell,"LowerBevelR",Vector3.new(2.4,0.70,46.0),cf(29.3,5.05,z,0,0,-20),spec.shade,Enum.Material.Metal,0.04,false)
        part(shell,"SillShadowL",Vector3.new(0.28,0.55,46.0),cf(13.72,5.20,z),C.grime,Enum.Material.Metal,0.04,false)
        part(shell,"SillShadowR",Vector3.new(0.28,0.55,46.0),cf(30.28,5.20,z),C.grime,Enum.Material.Metal,0.04,false)

        -- End vestibule doors provide a recognizable passenger-carriage end face.
        for _,sign in ipairs({-1,1}) do
            local ez=z+sign*24.78
            local skipRearHero=(index==4 and sign==1)
            if not skipRearHero then
                part(shell,"VestibuleDoor",Vector3.new(5.2,7.7,0.22),cf(22,9.55,ez),C.redDark,Enum.Material.Metal,0,false)
                part(shell,"VestibuleDoorWindow",Vector3.new(3.0,3.0,0.12),cf(22,11.0,ez-sign*0.15),C.glass,Enum.Material.Glass,0.34,false)
                part(shell,"VestibuleDoorKick",Vector3.new(4.5,1.35,0.12),cf(22,6.1,ez-sign*0.16),C.steel,Enum.Material.DiamondPlate,0,false)
                for _,x in ipairs({19.25,24.75}) do
                    part(shell,"EndDoorFrame",Vector3.new(0.34,8.6,0.34),cf(x,9.7,ez),C.steel2,Enum.Material.Metal,0,false)
                end
                part(shell,"EndDoorHeader",Vector3.new(6.0,0.34,0.34),cf(22,14.0,ez),C.steel2,Enum.Material.Metal,0,false)
            end
        end

        -- Small side rain rail and service hatch cues.
        for _,sx in ipairs({-1,1}) do
            local x=22+sx*8.74
            part(shell,"RainRail",Vector3.new(0.14,0.20,42),cf(x,14.65,z),C.steel2,Enum.Material.Metal,0.08,false)
            local hatch=part(shell,"ServiceHatch",Vector3.new(0.10,1.45,4.2),cf(x,6.1,z-18),spec.shade,Enum.Material.Metal,0.02,false)
            part(shell,"HatchSeamTop",Vector3.new(0.12,0.10,4.3),hatch.CFrame*CFrame.new(-sx*0.04,0.72,0),C.redDark,Enum.Material.Metal,0,false)
        end

        -- Sparse air/brake hardware seen under real rolling stock.
        cylinder(shell,"AirTank",Vector3.new(6.5,1.15,1.15),cf(22,2.05,z+6,0,0,90),C.charcoal,Enum.Material.Metal,0,false)
        part(shell,"BatteryBox",Vector3.new(7.0,1.9,4.5),cf(22,2.25,z-6),C.charcoal,Enum.Material.Metal,0,false)
        part(shell,"BatteryBoxLip",Vector3.new(7.2,0.18,4.7),cf(22,3.26,z-6),C.steel,Enum.Material.Metal,0,false)
    end
end

-- Continuous vestibule bridges between cars: more believable and easier to traverse.
local bridges={-31.5,21.5,74.5}
for _,z in ipairs(bridges) do
    part(vestibules,"GangwayFloor",Vector3.new(6.2,0.40,4.1),cf(22,4.45,z),C.steel,Enum.Material.DiamondPlate,0,true)
    part(vestibules,"GangwayCeiling",Vector3.new(6.3,0.28,4.1),cf(22,14.2,z),C.rubber,Enum.Material.SmoothPlastic,0,false)
    for _,x in ipairs({18.9,25.1}) do
        part(vestibules,"GangwaySide",Vector3.new(0.28,9.6,4.1),cf(x,9.35,z),C.rubber,Enum.Material.SmoothPlastic,0,false)
        -- shallow accordion ribs
        for dz=-1.5,1.5,1.0 do
            part(vestibules,"BellowsRib",Vector3.new(0.42,9.2,0.13),cf(x,9.35,z+dz),Color3.fromRGB(27,28,28),Enum.Material.SmoothPlastic,0,false)
        end
    end
    local lamp=part(vestibules,"GangwayLamp",Vector3.new(1.4,0.15,1.4),cf(22,13.75,z),C.warm,Enum.Material.Neon,0.12,false)
    local light=Instance.new("PointLight")
    light.Color=C.warm
    light.Brightness=0.40
    light.Range=7
    light.Shadows=false
    light.Parent=lamp
end

-- Platform hardware helps the train sit in a real station environment.
for z=-120,132,28 do
    part(platform,"CanopyColumnFoot",Vector3.new(3.0,0.24,3.0),cf(-5,2.96,z),C.steel,Enum.Material.Metal,0,false)
    for _,dx in ipairs({-1.0,1.0}) do
        for _,dz in ipairs({-1.0,1.0}) do
            cylinder(platform,"ColumnBolt",Vector3.new(0.16,0.24,0.24),cf(-5+dx,3.15,z+dz,0,0,90),C.charcoal,Enum.Material.Metal,0,false)
        end
    end
end
part(platform,"CanopyGutter",Vector3.new(0.42,0.48,270),cf(10.25,14.9,5),C.charcoal,Enum.Material.Metal,0,false)
for z=-110,125,47 do
    part(platform,"GutterDownpipe",Vector3.new(0.42,10.8,0.42),cf(10.25,9.5,z),C.charcoal,Enum.Material.Metal,0,false)
end

-- Front headboard makes CAR 01 read as the start of a retired service.
local headboard=part(profile,"NightServiceHeadboard",Vector3.new(9.5,2.2,0.38),cf(22,12.2,-83.0),C.charcoal,Enum.Material.Metal,0,false)
surfaceText(headboard,Enum.NormalId.Front,"TRACK 01  /  NIGHT SERVICE",C.cream,C.charcoal)

root:SetAttribute("ProfileVersion","2.4.0")
Workspace:SetAttribute("ACC_TRACK01_PROFILE_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","2.4.0")
print("[TRACK 01] railcar profile ready v2.4.0")
