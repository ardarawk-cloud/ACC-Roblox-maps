-- BECAK E-BIKE — passenger e-becak geometry realism v2.0
-- V3.2 mechanical silhouette pass aligned to the corrected visual wheels and proven collision-pod locations.
-- No gameplay physics are changed here; all generated structure is massless and non-collision.

local Workspace=game:GetService('Workspace')
local root=Workspace:WaitForChild('BecakEBike',30)
if not root then return end
local vehicles=root:WaitForChild('Vehicles',30)
if not vehicles then return end

local BLACK=Color3.fromRGB(20,22,23)
local METAL=Color3.fromRGB(111,116,118)
local DARK=Color3.fromRGB(50,53,54)

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

local function part(parent,name,size,cf,color,material)
    local p=setup(Instance.new('Part'),color,material)
    p.Name=name
    p.Size=size
    p.CFrame=cf
    p.Parent=parent
    return p
end

local function weld(chassis,p)
    local w=Instance.new('WeldConstraint')
    w.Part0=chassis
    w.Part1=p
    w.Parent=p
end

local function beamBetween(parent,chassis,name,a,b,thickness,color)
    local delta=b-a
    local len=delta.Magnitude
    if len<.05 then return nil end
    local mid=(a+b)/2
    -- CFrame.lookAt points -Z at b; a block's Z length therefore follows the link without cylinder-axis ambiguity.
    local p=part(parent,name,Vector3.new(thickness,thickness,len),CFrame.lookAt(mid,b),color or BLACK,Enum.Material.Metal)
    weld(chassis,p)
    return p
end

local function add(model)
    if not model:IsA('Model') or model:GetAttribute('VehicleGeometryRealismStyledV32') then return end
    local chassis=model.PrimaryPart or model:FindFirstChild('Chassis')
    local visual=model:FindFirstChild('MasterplanVisual')
    if not chassis or not chassis:IsA('BasePart') or not visual then return end
    if model:GetAttribute('PassengerCompartmentPosition')~='FRONT' then return end

    model:SetAttribute('VehicleGeometryRealismStyled',true)
    model:SetAttribute('VehicleGeometryRealismStyledV32',true)
    model:SetAttribute('VehicleGeometryRealismVersion','v2.0')

    local old=model:FindFirstChild('VehicleGeometryRealism')
    if old then old:Destroy() end
    local folder=Instance.new('Model')
    folder.Name='VehicleGeometryRealism'
    folder.Parent=model

    local function localPos(x,y,z)
        return (chassis.CFrame*CFrame.new(x,y,z)).Position
    end

    -- Front double-wheel suspension/fork structure. Hub coordinates exactly match the V3.2 visible wheels.
    for _,x in ipairs({-2.35,2.35}) do
        local hub=localPos(x,-.65,-3.10)
        local upper=localPos(x*.72,1.30,-1.38)
        local brace=localPos(x*.78,.45,-1.88)
        beamBetween(folder,chassis,'FrontForkMain',upper,hub,.18,BLACK)
        beamBetween(folder,chassis,'FrontForkBrace',brace,hub,.12,METAL)
    end
    local axle=part(folder,'FrontAxleBridge',Vector3.new(4.92,.20,.20),chassis.CFrame*CFrame.new(0,-.65,-3.10),METAL,Enum.Material.Metal)
    weld(chassis,axle)

    -- Compact central frame under passenger compartment and driver position.
    local centerBeam=part(folder,'CenterFrame',Vector3.new(.34,.30,6.30),chassis.CFrame*CFrame.new(0,-.30,.05),BLACK,Enum.Material.Metal)
    weld(chassis,centerBeam)
    for _,x in ipairs({-1.35,1.35}) do
        local lower=part(folder,'SideFrame',Vector3.new(.25,.25,5.55),chassis.CFrame*CFrame.new(x,-.30,-.20),BLACK,Enum.Material.Metal)
        weld(chassis,lower)
    end

    -- Rear triangle terminates at the actual rear wheel/contact-pod center.
    local rearHub=localPos(0,-.45,3.50)
    for _,x in ipairs({-1.08,1.08}) do
        beamBetween(folder,chassis,'RearSeatStay',localPos(x,1.15,1.72),rearHub,.15,BLACK)
        beamBetween(folder,chassis,'RearChainStay',localPos(x,-.18,1.25),rearHub,.14,METAL)
    end
    local motor=part(folder,'RearMotorHousing',Vector3.new(.88,.92,.92),chassis.CFrame*CFrame.new(0,-.45,3.50),DARK,Enum.Material.Metal)
    motor.Shape=Enum.PartType.Cylinder
    weld(chassis,motor)

    -- Short steering tie structure remains below the passenger canopy; no loose/floating cable geometry.
    local steeringCross=part(folder,'SteeringCrossMember',Vector3.new(3.45,.16,.16),chassis.CFrame*CFrame.new(0,.55,-1.65),METAL,Enum.Material.Metal)
    weld(chassis,steeringCross)
    for _,x in ipairs({-1.58,1.58}) do
        beamBetween(folder,chassis,'SteeringLink',localPos(x,.55,-1.65),localPos(x/1.58*2.35,-.42,-3.00),.10,METAL)
    end

    Workspace:SetAttribute('BecakVehicleGeometryParts',(Workspace:GetAttribute('BecakVehicleGeometryParts') or 0)+#folder:GetDescendants())
end

for _,m in ipairs(vehicles:GetChildren()) do task.delay(.55,add,m) end
vehicles.ChildAdded:Connect(function(m)
    task.wait(.55)
    add(m)
end)

Workspace:SetAttribute('ACC_BecakVehicleGeometryRealism','v2.0')
Workspace:SetAttribute('BecakMechanicalForkGeometry','ON')
Workspace:SetAttribute('BecakSegmentedFenders','RETIRED_V3_2')
Workspace:SetAttribute('BecakControlCableGeometry','RETIRED_V3_2')
Workspace:SetAttribute('BecakRearTriangleGeometry','ON')
Workspace:SetAttribute('BecakGeometryGroundContactAligned','ON')
Workspace:SetAttribute('BecakGeometryPassengerAuthority','FRONT')
