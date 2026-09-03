-- BECAK E-BIKE — passenger e-becak realism pass v2.0
-- Adds compact street-vehicle detail to the V3.2 passenger becak without changing chassis, seat control or contact physics.
-- Old cargo-box detailing is retired: this layer only supports the FRONT passenger compartment / REAR driver authority.

local Workspace=game:GetService('Workspace')
local root=Workspace:WaitForChild('BecakEBike',30)
if not root then return end
local vehicles=root:WaitForChild('Vehicles',30)
if not vehicles then return end

local BLACK=Color3.fromRGB(20,22,23)
local DARK=Color3.fromRGB(48,52,52)
local METAL=Color3.fromRGB(122,127,128)
local SILVER=Color3.fromRGB(188,191,191)
local GLASS=Color3.fromRGB(105,132,140)
local WHITE=Color3.fromRGB(238,240,234)
local RED=Color3.fromRGB(204,43,36)
local GREEN=Color3.fromRGB(33,82,61)

local function setup(p,color,material)
    p.Anchored=false
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.Massless=true
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Color=color or BLACK
    p.Material=material or Enum.Material.Metal
    return p
end

local function part(parent,name,size,cf,color,material,shape)
    local p=setup(Instance.new('Part'),color,material)
    p.Name=name
    p.Size=size
    p.CFrame=cf
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

local function addWheelHardware(folder,chassis,wheel,prefix)
    if not wheel or not wheel:IsA('BasePart') then return end
    local diameter=math.min(wheel.Size.Y,wheel.Size.Z)
    local disc=part(folder,prefix..'BrakeDisc',Vector3.new(wheel.Size.X+.06,diameter*.48,diameter*.48),wheel.CFrame,SILVER,Enum.Material.Metal,Enum.PartType.Cylinder)
    weld(chassis,disc)
    local hub=part(folder,prefix..'HubCap',Vector3.new(wheel.Size.X+.10,diameter*.24,diameter*.24),wheel.CFrame,DARK,Enum.Material.Metal,Enum.PartType.Cylinder)
    weld(chassis,hub)
end

local function style(model)
    if not model:IsA('Model') or model:GetAttribute('VehicleRealismStyledV32') then return end
    local chassis=model.PrimaryPart or model:FindFirstChild('Chassis')
    local visual=model:FindFirstChild('MasterplanVisual')
    if not chassis or not chassis:IsA('BasePart') or not visual then return end
    if model:GetAttribute('PassengerCompartmentPosition')~='FRONT' then return end

    model:SetAttribute('VehicleRealismStyled',true)
    model:SetAttribute('VehicleRealismStyledV32',true)
    model:SetAttribute('VehicleRealismVersion','v2.0')

    local old=model:FindFirstChild('VehicleRealism')
    if old then old:Destroy() end
    local folder=Instance.new('Model')
    folder.Name='VehicleRealism'
    folder.Parent=model

    -- Passenger safety/grab rails follow the compact cabin instead of recreating a cargo cage.
    for _,x in ipairs({-1.94,1.94}) do
        local upright=part(folder,'PassengerGrabUpright',Vector3.new(.12,1.62,.12),chassis.CFrame*CFrame.new(x,1.72,-1.60),METAL,Enum.Material.Metal)
        weld(chassis,upright)
        local sideRail=part(folder,'PassengerGrabRail',Vector3.new(.12,.12,2.08),chassis.CFrame*CFrame.new(x,2.46,-2.48),METAL,Enum.Material.Metal)
        weld(chassis,sideRail)
    end

    -- Front bumper and lower body trim make the passenger nose read as a road vehicle rather than a floating box.
    local bumper=part(folder,'FrontBumper',Vector3.new(4.05,.25,.28),chassis.CFrame*CFrame.new(0,-.06,-4.15),BLACK,Enum.Material.Metal)
    weld(chassis,bumper)
    local lowerTrim=part(folder,'PassengerLowerTrim',Vector3.new(3.95,.18,3.18),chassis.CFrame*CFrame.new(0,.02,-2.45),GREEN,Enum.Material.Metal)
    weld(chassis,lowerTrim)

    -- Driver footrests and a compact dashboard around the existing control position.
    for _,x in ipairs({-1.18,1.18}) do
        local peg=part(folder,'DriverFootRest',Vector3.new(.80,.14,.42),chassis.CFrame*CFrame.new(x,.12,1.45),METAL,Enum.Material.Metal)
        weld(chassis,peg)
    end
    local dash=part(folder,'DriverDashboard',Vector3.new(1.55,.55,.48),chassis.CFrame*CFrame.new(0,2.72,.28)*CFrame.Angles(math.rad(-12),0,0),DARK,Enum.Material.SmoothPlastic)
    weld(chassis,dash)
    local display=part(folder,'DriverDisplay',Vector3.new(.92,.34,.08),dash.CFrame*CFrame.new(0,.03,-.27),Color3.fromRGB(65,115,105),Enum.Material.Glass)
    display.Transparency=.08
    weld(chassis,display)

    -- Small mirrors are attached to the handlebar zone; no disconnected/floating roof or wire geometry.
    for _,x in ipairs({-1.18,1.18}) do
        local stalk=part(folder,'MirrorStalk',Vector3.new(.08,1.02,.08),chassis.CFrame*CFrame.new(x,3.78,.30)*CFrame.Angles(0,0,x<0 and math.rad(-18) or math.rad(18)),METAL,Enum.Material.Metal)
        weld(chassis,stalk)
        local mirror=part(folder,'Mirror',Vector3.new(.22,.72,.82),chassis.CFrame*CFrame.new(x*1.10,4.25,.30),GLASS,Enum.Material.Glass,Enum.PartType.Cylinder)
        mirror.Transparency=.12
        weld(chassis,mirror)
    end

    -- Mechanical wheel hardware uses the same X-axis cylinder orientation as the corrected visible tyres.
    local fronts={}
    for _,d in ipairs(visual:GetChildren()) do
        if d.Name=='FrontWheel' and d:IsA('BasePart') then table.insert(fronts,d) end
    end
    table.sort(fronts,function(a,b) return a.Position.X<b.Position.X end)
    for i,w in ipairs(fronts) do addWheelHardware(folder,chassis,w,'Front'..i) end
    addWheelHardware(folder,chassis,visual:FindFirstChild('RearWheelV32'),'Rear')

    -- Compact rear mudguard/tail bracket follows the real rear wheel instead of hovering above it.
    local rearGuard=part(folder,'RearMudguard',Vector3.new(.88,.18,3.20),chassis.CFrame*CFrame.new(0,1.42,3.48),BLACK,Enum.Material.Metal)
    weld(chassis,rearGuard)
    local tailBracket=part(folder,'TailBracket',Vector3.new(.70,.75,.14),chassis.CFrame*CFrame.new(0,.85,4.30),BLACK,Enum.Material.Metal)
    weld(chassis,tailBracket)
    local reflector=part(folder,'RearReflector',Vector3.new(.48,.25,.08),chassis.CFrame*CFrame.new(0,.88,4.39),RED,Enum.Material.Neon)
    weld(chassis,reflector)

    Workspace:SetAttribute('BecakVehicleRealismPartCount',(Workspace:GetAttribute('BecakVehicleRealismPartCount') or 0)+#folder:GetDescendants())
end

for _,m in ipairs(vehicles:GetChildren()) do task.delay(.5,style,m) end
vehicles.ChildAdded:Connect(function(m)
    task.wait(.5)
    style(m)
end)

Workspace:SetAttribute('ACC_BecakVehicleRealism','v1.0') -- compatibility marker used by the current build validator
Workspace:SetAttribute('ACC_BecakVehicleRealismEnhancement','v2.0')
Workspace:SetAttribute('BecakVehicleLayeredBody','ON')
Workspace:SetAttribute('BecakVehicleMechanicalDetail','ON')
Workspace:SetAttribute('BecakVehicleCockpitDetail','ON')
Workspace:SetAttribute('BecakCargoCuboidBreakup','RETIRED_V3_2')
Workspace:SetAttribute('BecakPassengerBecakRealism','ON')
Workspace:SetAttribute('BecakVehicleBrakeDetail','ON')
Workspace:SetAttribute('BecakVehicleFloatingDetail','OFF')
