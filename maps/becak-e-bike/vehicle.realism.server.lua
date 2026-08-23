-- BECAK E-BIKE — Cargo E-Bike 01 vehicle realism pass v1.0
-- Adds layered mechanical/body detail to the live masterplan vehicle without changing physics.
-- Dedicated to maps/becak-e-bike. All generated parts are massless/non-collision and welded to chassis.

local Workspace = game:GetService('Workspace')
local root = Workspace:WaitForChild('BecakEBike',30)
if not root then return end
local vehicles = root:WaitForChild('Vehicles',30)
if not vehicles then return end

local BLACK=Color3.fromRGB(18,20,22)
local DARK=Color3.fromRGB(42,45,48)
local METAL=Color3.fromRGB(112,116,119)
local SILVER=Color3.fromRGB(190,193,195)
local GLASS=Color3.fromRGB(120,150,160)
local AMBER=Color3.fromRGB(255,158,48)
local WHITE=Color3.fromRGB(235,238,236)

local function setup(p,color,material)
    p.Anchored=false p.CanCollide=false p.CanTouch=false p.CanQuery=false p.Massless=true
    p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
    p.Color=color or BLACK p.Material=material or Enum.Material.Metal
    return p
end
local function part(parent,name,size,cf,color,material,shape)
    local p=setup(Instance.new('Part'),color,material);p.Name=name;p.Size=size;p.CFrame=cf
    if shape then p.Shape=shape end;p.Parent=parent;return p
end
local function wedge(parent,name,size,cf,color,material)
    local p=setup(Instance.new('WedgePart'),color,material);p.Name=name;p.Size=size;p.CFrame=cf;p.Parent=parent;return p
end
local function weld(chassis,p)
    local w=Instance.new('WeldConstraint');w.Part0=chassis;w.Part1=p;w.Parent=p
end
local function tube(parent,chassis,name,length,radius,cf,color)
    local p=part(parent,name,Vector3.new(length,radius*2,radius*2),cf,color or BLACK,Enum.Material.Metal,Enum.PartType.Cylinder)
    weld(chassis,p);return p
end

local function addWheelDetail(folder,chassis,wheel,prefix)
    if not wheel or not wheel:IsA('BasePart') then return end
    local cf=wheel.CFrame
    local disc=part(folder,prefix..'BrakeDisc',Vector3.new(1.18,1.9,1.9),cf,Color3.fromRGB(132,135,137),Enum.Material.Metal,Enum.PartType.Cylinder);weld(chassis,disc)
    local hub=part(folder,prefix..'HubCap',Vector3.new(1.24,.72,.72),cf,SILVER,Enum.Material.Metal,Enum.PartType.Cylinder);weld(chassis,hub)
    for i=0,7 do
        local a=math.rad(i*45)
        local spoke=part(folder,prefix..'Spoke',Vector3.new(.12,.12,1.45),cf*CFrame.Angles(a,0,0)*CFrame.new(0,0,.72),METAL,Enum.Material.Metal)
        weld(chassis,spoke)
    end
end

local function style(model)
    if not model:IsA('Model') or model:GetAttribute('VehicleRealismStyled') then return end
    local chassis=model.PrimaryPart or model:FindFirstChild('Chassis')
    local visual=model:FindFirstChild('MasterplanVisual')
    if not chassis or not visual then return end
    model:SetAttribute('VehicleRealismStyled',true)
    model:SetAttribute('VehicleRealismVersion','v1.0')

    local old=model:FindFirstChild('VehicleRealism') if old then old:Destroy() end
    local folder=Instance.new('Model');folder.Name='VehicleRealism';folder.Parent=model

    -- Cargo box: bevel impression and panel layering to avoid a single cuboid silhouette.
    for _,side in ipairs({-1,1}) do
        local rail=tube(folder,chassis,'CargoUpperRail',4.55,.10,chassis.CFrame*CFrame.new(side*3.08,3.78,-3.05)*CFrame.Angles(0,math.rad(90),0),BLACK);rail.CastShadow=true
        local lower=tube(folder,chassis,'CargoLowerRail',4.45,.08,chassis.CFrame*CFrame.new(side*3.1,1.45,-3.08)*CFrame.Angles(0,math.rad(90),0),METAL)
        local chamfer=wedge(folder,'CargoCornerChamfer',Vector3.new(.55,2.55,.55),chassis.CFrame*CFrame.new(side*2.93,2.45,-5.42)*CFrame.Angles(0,side>0 and math.rad(45) or math.rad(-135),0),DARK,Enum.Material.Metal);weld(chassis,chamfer)
    end
    local frontLip=part(folder,'CargoFrontLip',Vector3.new(5.55,.16,.36),chassis.CFrame*CFrame.new(0,3.82,-5.48),BLACK,Enum.Material.Metal);weld(chassis,frontLip)
    local floorTrim=part(folder,'CargoFloorTrim',Vector3.new(5.7,.16,4.5),chassis.CFrame*CFrame.new(0,.72,-3.1),METAL,Enum.Material.Metal);weld(chassis,floorTrim)

    -- Handlebar cockpit: grips, controls, mirrors and compact headlight cluster.
    for _,x in ipairs({-2.15,2.15}) do
        local grip=tube(folder,chassis,'RubberGrip',.9,.19,chassis.CFrame*CFrame.new(x,4.6,-.15),DARK);grip.Material=Enum.Material.SmoothPlastic
        local stalk=tube(folder,chassis,'MirrorStalk',1.15,.07,chassis.CFrame*CFrame.new(x*.78,5.15,-.18)*CFrame.Angles(0,0,math.rad(58)),METAL)
        local mirror=part(folder,'Mirror',Vector3.new(.32,.9,1.05),chassis.CFrame*CFrame.new(x*.93,5.62,-.18),GLASS,Enum.Material.Glass,Enum.PartType.Cylinder);mirror.Transparency=.12;weld(chassis,mirror)
        local indicator=part(folder,'FrontIndicator',Vector3.new(.24,.42,.42),chassis.CFrame*CFrame.new(x*.92,4.18,-.62),AMBER,Enum.Material.Neon,Enum.PartType.Ball);weld(chassis,indicator)
    end
    local headShell=part(folder,'HeadlightShell',Vector3.new(1.6,.72,.72),chassis.CFrame*CFrame.new(0,4.0,-.72)*CFrame.Angles(0,0,math.rad(90)),BLACK,Enum.Material.Metal,Enum.PartType.Cylinder);weld(chassis,headShell)
    local lens=part(folder,'HeadlightLens',Vector3.new(1.68,.53,.53),headShell.CFrame,WHITE,Enum.Material.Glass,Enum.PartType.Cylinder);lens.Transparency=.12;weld(chassis,lens)
    local light=Instance.new('PointLight');light.Name='HeadlightGlow';light.Brightness=.55;light.Range=16;light.Color=Color3.fromRGB(245,242,220);light.Parent=lens

    -- Rider area: seat contour, foot rests, battery housing, controller box.
    local seatTop=part(folder,'SaddleCushionTop',Vector3.new(2.0,.32,1.18),chassis.CFrame*CFrame.new(0,3.72,3.02),Color3.fromRGB(35,35,34),Enum.Material.SmoothPlastic);weld(chassis,seatTop)
    for _,x in ipairs({-1.45,1.45}) do
        local peg=tube(folder,chassis,'FootPeg',1.05,.11,chassis.CFrame*CFrame.new(x,1.25,2.25),METAL);weld(chassis,peg)
    end
    local battery=part(folder,'BatteryHousing',Vector3.new(2.4,1.35,1.65),chassis.CFrame*CFrame.new(0,1.25,2.3),BLACK,Enum.Material.Metal);weld(chassis,battery)
    local controller=part(folder,'MotorController',Vector3.new(1.25,.68,1.1),chassis.CFrame*CFrame.new(0,2.0,3.85),DARK,Enum.Material.Metal);weld(chassis,controller)

    -- Wheel/fender detail. Existing wheels remain the canonical visible diameter.
    local fronts={}
    for _,d in ipairs(visual:GetDescendants()) do if d.Name=='FrontWheel20' and d:IsA('BasePart') then table.insert(fronts,d) end end
    for i,w in ipairs(fronts) do addWheelDetail(folder,chassis,w,'Front'..i) end
    local rear=visual:FindFirstChild('RearWheel26',true);addWheelDetail(folder,chassis,rear,'Rear')
    for _,x in ipairs({-3.55,3.55}) do
        local fender=part(folder,'FrontFender',Vector3.new(.34,4.72,4.72),chassis.CFrame*CFrame.new(x,1.38,-3.15)*CFrame.Angles(0,0,math.rad(90)),DARK,Enum.Material.Metal,Enum.PartType.Cylinder);fender.Transparency=.08;weld(chassis,fender)
    end

    -- Rear rack and mudguard cues.
    local rack=part(folder,'RearRack',Vector3.new(3.3,.18,2.4),chassis.CFrame*CFrame.new(0,3.15,4.15),BLACK,Enum.Material.Metal);weld(chassis,rack)
    for _,x in ipairs({-1.45,1.45}) do tube(folder,chassis,'RearRackRail',2.45,.07,chassis.CFrame*CFrame.new(x,3.55,4.15)*CFrame.Angles(0,math.rad(90),0),METAL) end

    Workspace:SetAttribute('BecakVehicleRealismPartCount',(Workspace:GetAttribute('BecakVehicleRealismPartCount') or 0)+#folder:GetDescendants())
end

for _,m in ipairs(vehicles:GetChildren()) do task.defer(style,m) end
vehicles.ChildAdded:Connect(function(m) task.wait(.4);style(m) end)
Workspace:SetAttribute('ACC_BecakVehicleRealism','v1.0')
Workspace:SetAttribute('BecakVehicleLayeredBody','ON')
Workspace:SetAttribute('BecakVehicleMechanicalDetail','ON')
Workspace:SetAttribute('BecakVehicleCockpitDetail','ON')
