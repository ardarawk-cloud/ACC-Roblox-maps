-- BECAK E-BIKE — Nusakarya passenger e-becak visual authority v2.0
-- V3.2 root fix: passenger compartment FRONT, driver BEHIND, realistic relative vehicle scale,
-- correctly oriented visible wheels, and visible tyre contact aligned to the proven ground-contact pods.
-- This script changes visual geometry only; VehicleSeat, chassis physics and contact pods remain authoritative.

local Workspace=game:GetService('Workspace')
local root=Workspace:WaitForChild('BecakEBike',30)
if not root then return end
local vehicles=root:WaitForChild('Vehicles',30)
if not vehicles then return end

local FRAME=Color3.fromRGB(27,31,32)
local FRAME_SOFT=Color3.fromRGB(54,59,60)
local BODY=Color3.fromRGB(33,82,61)
local BODY_DARK=Color3.fromRGB(25,58,47)
local SEAT=Color3.fromRGB(38,39,39)
local METAL=Color3.fromRGB(126,132,133)
local TYRE=Color3.fromRGB(22,23,23)
local HUB=Color3.fromRGB(172,176,176)
local WHITE=Color3.fromRGB(238,240,234)
local AMBER=Color3.fromRGB(255,171,52)
local RED=Color3.fromRGB(210,43,36)

local function makePart(parent,name,size,cf,color,material,shape)
    local p=Instance.new('Part')
    p.Name=name
    p.Size=size
    p.CFrame=cf
    p.Anchored=false
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.Massless=true
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Color=color or FRAME
    p.Material=material or Enum.Material.Metal
    if shape then p.Shape=shape end
    p.Parent=parent
    return p
end

local function weld(chassis,p)
    local w=Instance.new('WeldConstraint')
    w.Part0=chassis
    w.Part1=p
    w.Parent=p
end

local function addBrand(panel)
    local gui=Instance.new('SurfaceGui')
    gui.Name='BecakBrand'
    gui.Face=Enum.NormalId.Left
    gui.AlwaysOnTop=false
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=32
    gui.Parent=panel
    local t=Instance.new('TextLabel')
    t.Size=UDim2.fromScale(1,1)
    t.BackgroundTransparency=1
    t.Text='BECAK E-BIKE'
    t.TextColor3=WHITE
    t.TextStrokeTransparency=.72
    t.Font=Enum.Font.GothamBold
    t.TextScaled=true
    t.Parent=gui
end

local function hidePart(p)
    if p and p:IsA('BasePart') then
        p.Transparency=1
        p.CanCollide=false
        p.CanTouch=false
        p.CanQuery=false
        p.CastShadow=false
    end
end

local function hideLegacy(model,chassis)
    -- The runtime physics body remains present but is not part of the V3.2 visual silhouette.
    hidePart(chassis)
    hidePart(model:FindFirstChild('DriverSeat',true))
    for _,name in ipairs({
        'PassengerCabin','Canopy','Battery',
        'FrontWheelL','FrontWheelR','RearWheel',
        'WheelFL','WheelFR','WheelRear','FrontWheel'
    }) do
        hidePart(model:FindFirstChild(name,true))
    end
end

local function wheel(parent,chassis,name,center,diameter,width)
    -- Roblox cylinders use the X axis as their length axis. No 90-degree Z rotation is wanted here:
    -- leaving X as the axle axis makes the wheel stand vertically instead of becoming a horizontal platter.
    local cf=chassis.CFrame*CFrame.new(center)
    local tyre=makePart(parent,name,Vector3.new(width,diameter,diameter),cf,TYRE,Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
    weld(chassis,tyre)
    local hub=makePart(parent,name..'Hub',Vector3.new(width+.08,diameter*.30,diameter*.30),cf,HUB,Enum.Material.Metal,Enum.PartType.Cylinder)
    weld(chassis,hub)
    return tyre
end

local function styleVehicle(model)
    if not model:IsA('Model') or model:GetAttribute('MasterplanVehicleStyledV32') then return end
    local chassis=model.PrimaryPart or model:FindFirstChild('Chassis')
    if not chassis or not chassis:IsA('BasePart') then return end

    model:SetAttribute('MasterplanVehicleStyled',true)
    model:SetAttribute('MasterplanVehicleStyledV32',true)
    model:SetAttribute('VehicleModel','Nusakarya Passenger E-Becak')
    model:SetAttribute('VehicleType','ELECTRIC PASSENGER BECAK')
    model:SetAttribute('PassengerCompartmentPosition','FRONT')
    model:SetAttribute('DriverPosition','BEHIND_PASSENGER')
    model:SetAttribute('VisualScaleAuthority','V3.2_REAL_WORLD_RELATIVE')
    model:SetAttribute('VisualPhysicsLite','v2.0')

    hideLegacy(model,chassis)

    local old=model:FindFirstChild('MasterplanVisual')
    if old then old:Destroy() end
    local visual=Instance.new('Model')
    visual.Name='MasterplanVisual'
    visual.Parent=model

    -- Lower structural rails. The tyre contact line is local Y=-2.25, matching vehicle.ground-contact.server.lua.
    for _,x in ipairs({-1.55,1.55}) do
        local rail=makePart(visual,'LowerFrameRail',Vector3.new(.28,.28,6.35),chassis.CFrame*CFrame.new(x,-.42,.05),FRAME,Enum.Material.Metal)
        weld(chassis,rail)
    end
    local frontCross=makePart(visual,'FrontAxleFrame',Vector3.new(4.65,.30,.30),chassis.CFrame*CFrame.new(0,-.45,-3.10),FRAME,Enum.Material.Metal)
    weld(chassis,frontCross)
    local rearCross=makePart(visual,'RearFrameBridge',Vector3.new(3.35,.30,.30),chassis.CFrame*CFrame.new(0,-.35,2.65),FRAME,Enum.Material.Metal)
    weld(chassis,rearCross)

    -- Passenger compartment: compact open cabin in FRONT of the driver, not a cargo box.
    local floor=makePart(visual,'PassengerFloor',Vector3.new(3.85,.28,3.25),chassis.CFrame*CFrame.new(0,.12,-2.45),BODY_DARK,Enum.Material.Metal)
    weld(chassis,floor)
    local frontApron=makePart(visual,'PassengerFrontApron',Vector3.new(3.85,1.20,.22),chassis.CFrame*CFrame.new(0,.82,-4.00),BODY,Enum.Material.Metal)
    weld(chassis,frontApron)
    addBrand(frontApron)
    for _,x in ipairs({-1.82,1.82}) do
        local side=makePart(visual,'PassengerSidePanel',Vector3.new(.18,1.08,2.72),chassis.CFrame*CFrame.new(x,.78,-2.55),BODY,Enum.Material.Metal)
        weld(chassis,side)
    end

    -- Two-person front bench and backrest. Driver remains physically controlled by the hidden VehicleSeat behind it.
    local cushion=makePart(visual,'PassengerBench',Vector3.new(3.45,.42,1.28),chassis.CFrame*CFrame.new(0,.78,-2.12),SEAT,Enum.Material.SmoothPlastic)
    weld(chassis,cushion)
    local backrest=makePart(visual,'PassengerBackrest',Vector3.new(3.45,1.55,.30),chassis.CFrame*CFrame.new(0,1.62,-1.42)*CFrame.Angles(math.rad(-7),0,0),SEAT,Enum.Material.SmoothPlastic)
    weld(chassis,backrest)
    local footwell=makePart(visual,'PassengerFootwell',Vector3.new(3.35,.18,1.15),chassis.CFrame*CFrame.new(0,.42,-3.35),FRAME_SOFT,Enum.Material.Metal)
    weld(chassis,footwell)

    -- Passenger canopy has four physical-looking posts, eliminating the floating slab silhouette.
    local postY=2.25
    for _,x in ipairs({-1.72,1.72}) do
        for _,z in ipairs({-3.72,-1.20}) do
            local post=makePart(visual,'CanopySupport',Vector3.new(.14,3.05,.14),chassis.CFrame*CFrame.new(x,postY,z),FRAME,Enum.Material.Metal)
            weld(chassis,post)
        end
    end
    local canopy=makePart(visual,'PassengerCanopy',Vector3.new(4.05,.22,3.42),chassis.CFrame*CFrame.new(0,3.80,-2.45),FRAME_SOFT,Enum.Material.Metal)
    weld(chassis,canopy)
    local canopyTrim=makePart(visual,'CanopyFrontTrim',Vector3.new(4.12,.18,.18),chassis.CFrame*CFrame.new(0,3.64,-4.08),BODY,Enum.Material.Metal)
    weld(chassis,canopyTrim)

    -- Driver zone sits behind the passenger compartment.
    local saddle=makePart(visual,'DriverSaddle',Vector3.new(1.75,.34,1.05),chassis.CFrame*CFrame.new(0,1.42,2.15),SEAT,Enum.Material.SmoothPlastic)
    weld(chassis,saddle)
    local saddlePost=makePart(visual,'DriverSaddlePost',Vector3.new(.28,1.55,.28),chassis.CFrame*CFrame.new(0,.63,2.20),METAL,Enum.Material.Metal)
    weld(chassis,saddlePost)
    local steeringStem=makePart(visual,'SteeringStem',Vector3.new(.30,2.45,.30),chassis.CFrame*CFrame.new(0,2.22,.55)*CFrame.Angles(math.rad(-12),0,0),METAL,Enum.Material.Metal)
    weld(chassis,steeringStem)
    local handlebar=makePart(visual,'Handlebar',Vector3.new(3.10,.28,.28),chassis.CFrame*CFrame.new(0,3.34,.28),FRAME,Enum.Material.Metal)
    weld(chassis,handlebar)
    for _,x in ipairs({-1.38,1.38}) do
        local grip=makePart(visual,'HandleGrip',Vector3.new(.58,.36,.36),chassis.CFrame*CFrame.new(x,3.34,.28),SEAT,Enum.Material.SmoothPlastic)
        weld(chassis,grip)
    end

    -- Visible wheels are scaled against avatar/traffic and aligned with the collision-pod ground line.
    wheel(visual,chassis,'FrontWheel',Vector3.new(-2.35,-.65,-3.10),3.20,.68)
    wheel(visual,chassis,'FrontWheel',Vector3.new( 2.35,-.65,-3.10),3.20,.68)
    wheel(visual,chassis,'RearWheelV32',Vector3.new(0,-.45,3.50),3.60,.76)

    -- Battery/controller low and central so the vehicle reads as electric without becoming a floating black box.
    local battery=makePart(visual,'BatteryHousing',Vector3.new(1.75,1.05,1.65),chassis.CFrame*CFrame.new(0,.28,1.45),FRAME,Enum.Material.Metal)
    weld(chassis,battery)
    local batteryBand=makePart(visual,'BatteryAccent',Vector3.new(1.82,.16,1.72),chassis.CFrame*CFrame.new(0,.42,1.45),BODY,Enum.Material.Metal)
    weld(chassis,batteryBand)

    -- Road equipment and lighting integrated into the body.
    local head=makePart(visual,'Headlamp',Vector3.new(1.05,.52,.18),chassis.CFrame*CFrame.new(0,1.14,-4.14),WHITE,Enum.Material.Neon)
    weld(chassis,head)
    for _,x in ipairs({-1.48,1.48}) do
        local indicator=makePart(visual,'FrontIndicator',Vector3.new(.38,.32,.16),chassis.CFrame*CFrame.new(x,1.05,-4.14),AMBER,Enum.Material.Neon)
        weld(chassis,indicator)
    end
    local tail=makePart(visual,'RearLamp',Vector3.new(1.00,.42,.18),chassis.CFrame*CFrame.new(0,.86,4.35),RED,Enum.Material.Neon)
    weld(chassis,tail)
    local plate=makePart(visual,'RearPlate',Vector3.new(1.35,.52,.10),chassis.CFrame*CFrame.new(0,.24,4.42),Color3.fromRGB(30,30,30),Enum.Material.Metal)
    weld(chassis,plate)

    print('[BECAK E-BIKE] V3.2 passenger e-becak visual ready for',model.Name)
end

for _,m in ipairs(vehicles:GetChildren()) do task.defer(styleVehicle,m) end
vehicles.ChildAdded:Connect(function(m)
    task.wait(.25)
    styleVehicle(m)
end)

Workspace:SetAttribute('ACC_BecakVehicleMasterplan','Nusakarya Passenger E-Becak v2.0')
Workspace:SetAttribute('ACC_BecakVehicleVisualPerformance','v2.0')
Workspace:SetAttribute('BecakPassengerCompartmentPosition','FRONT')
Workspace:SetAttribute('BecakDriverPosition','BEHIND_PASSENGER')
Workspace:SetAttribute('BecakVisibleWheelGroundLineY',-2.25)
Workspace:SetAttribute('BecakWheelCylinderAxis','X')
Workspace:SetAttribute('BecakDecorativeVisualTouch','OFF')
Workspace:SetAttribute('BecakDecorativeVisualQuery','OFF')
