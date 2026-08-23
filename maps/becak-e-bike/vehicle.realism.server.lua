-- BECAK E-BIKE — Cargo E-Bike 01 vehicle realism pass v1.1
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
local RED=Color3.fromRGB(185,38,32)
local GREEN=Color3.fromRGB(25,135,72)

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
local function addSurfaceBrand(panel)
    local gui=Instance.new('SurfaceGui');gui.Name='RealismBrand';gui.Face=Enum.NormalId.Left;gui.AlwaysOnTop=false;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=35;gui.Parent=panel
    local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text='BECAK E-BIKE';t.TextColor3=WHITE;t.TextScaled=true;t.Font=Enum.Font.GothamBold;t.Parent=gui
end

local function addWheelDetail(folder,chassis,wheel,prefix)
    if not wheel or not wheel:IsA('BasePart') then return end
    local cf=wheel.CFrame
    local disc=part(folder,prefix..'BrakeDisc',Vector3.new(1.18,1.9,1.9),cf,Color3.fromRGB(132,135,137),Enum.Material.Metal,Enum.PartType.Cylinder);weld(chassis,disc)
    local hub=part(folder,prefix..'HubCap',Vector3.new(1.24,.72,.72),cf,SILVER,Enum.Material.Metal,Enum.PartType.Cylinder);weld(chassis,hub)
    for i=0,11 do
        local a=math.rad(i*30)
        local spoke=part(folder,prefix..'Spoke',Vector3.new(.08,.08,1.52),cf*CFrame.Angles(a,0,0)*CFrame.new(0,0,.76),METAL,Enum.Material.Metal)
        weld(chassis,spoke)
    end
    local caliper=part(folder,prefix..'BrakeCaliper',Vector3.new(.34,.5,.7),cf*CFrame.new(.62,.55,.62),Color3.fromRGB(172,58,42),Enum.Material.Metal);weld(chassis,caliper)
end

local function style(model)
    if not model:IsA('Model') or model:GetAttribute('VehicleRealismStyled') then return end
    local chassis=model.PrimaryPart or model:FindFirstChild('Chassis')
    local visual=model:FindFirstChild('MasterplanVisual')
    if not chassis or not visual then return end
    model:SetAttribute('VehicleRealismStyled',true)
    model:SetAttribute('VehicleRealismVersion','v1.1')

    local old=model:FindFirstChild('VehicleRealism') if old then old:Destroy() end
    local folder=Instance.new('Model');folder.Name='VehicleRealism';folder.Parent=model

    -- Reduce the visual dominance of the original rectangular cargo primitive.
    local baseCargo=visual:FindFirstChild('CargoBox',true)
    if baseCargo and baseCargo:IsA('BasePart') then baseCargo.Transparency=.88 end

    -- Rebuild cargo body as layered sheet-metal panels with angled corner caps.
    local sideThickness=.16
    for _,side in ipairs({-1,1}) do
        local sidePanel=part(folder,'CargoSidePanel',Vector3.new(sideThickness,2.58,4.45),chassis.CFrame*CFrame.new(side*2.92,2.35,-3.05),Color3.fromRGB(30,33,35),Enum.Material.Metal);weld(chassis,sidePanel)
        addSurfaceBrand(sidePanel)
        local upper=tube(folder,chassis,'CargoUpperRail',4.55,.10,chassis.CFrame*CFrame.new(side*3.08,3.78,-3.05)*CFrame.Angles(0,math.rad(90),0),BLACK);upper.CastShadow=true
        tube(folder,chassis,'CargoLowerRail',4.45,.08,chassis.CFrame*CFrame.new(side*3.1,1.45,-3.08)*CFrame.Angles(0,math.rad(90),0),METAL)
        local frontChamfer=wedge(folder,'CargoFrontChamfer',Vector3.new(.62,2.55,.68),chassis.CFrame*CFrame.new(side*2.75,2.45,-5.28)*CFrame.Angles(0,side>0 and math.rad(45) or math.rad(-135),0),DARK,Enum.Material.Metal);weld(chassis,frontChamfer)
        local rearChamfer=wedge(folder,'CargoRearChamfer',Vector3.new(.54,2.4,.58),chassis.CFrame*CFrame.new(side*2.76,2.35,-.88)*CFrame.Angles(0,side>0 and math.rad(135) or math.rad(-45),0),DARK,Enum.Material.Metal);weld(chassis,rearChamfer)
        local reflector=part(folder,'CargoSideReflector',Vector3.new(.10,.28,.7),chassis.CFrame*CFrame.new(side*3.03,1.45,-4.65),AMBER,Enum.Material.Neon);weld(chassis,reflector)
    end
    local frontPanel=part(folder,'CargoFrontPanel',Vector3.new(5.35,2.5,.16),chassis.CFrame*CFrame.new(0,2.35,-5.38),Color3.fromRGB(28,31,33),Enum.Material.Metal);weld(chassis,frontPanel)
    local rearPanel=part(folder,'CargoRearPanel',Vector3.new(5.35,2.5,.16),chassis.CFrame*CFrame.new(0,2.35,-.73),Color3.fromRGB(34,37,39),Enum.Material.Metal);weld(chassis,rearPanel)
    local frontLip=part(folder,'CargoFrontLip',Vector3.new(5.55,.16,.36),chassis.CFrame*CFrame.new(0,3.82,-5.48),BLACK,Enum.Material.Metal);weld(chassis,frontLip)
    local floorTrim=part(folder,'CargoFloorTrim',Vector3.new(5.7,.16,4.5),chassis.CFrame*CFrame.new(0,.72,-3.1),METAL,Enum.Material.Metal);weld(chassis,floorTrim)
    for _,x in ipairs({-2.3,0,2.3}) do
        local rib=part(folder,'CargoPanelRib',Vector3.new(.10,2.15,.10),chassis.CFrame*CFrame.new(x,2.4,-5.49),METAL,Enum.Material.Metal);weld(chassis,rib)
    end

    -- Handlebar cockpit: grips, controls, mirrors, cable routing and compact headlight cluster.
    for _,x in ipairs({-2.15,2.15}) do
        local grip=tube(folder,chassis,'RubberGrip',.9,.19,chassis.CFrame*CFrame.new(x,4.6,-.15),DARK);grip.Material=Enum.Material.SmoothPlastic
        tube(folder,chassis,'MirrorStalk',1.15,.07,chassis.CFrame*CFrame.new(x*.78,5.15,-.18)*CFrame.Angles(0,0,math.rad(58)),METAL)
        local mirror=part(folder,'Mirror',Vector3.new(.32,.9,1.05),chassis.CFrame*CFrame.new(x*.93,5.62,-.18),GLASS,Enum.Material.Glass,Enum.PartType.Cylinder);mirror.Transparency=.12;weld(chassis,mirror)
        local indicator=part(folder,'FrontIndicator',Vector3.new(.24,.42,.42),chassis.CFrame*CFrame.new(x*.92,4.18,-.62),AMBER,Enum.Material.Neon,Enum.PartType.Ball);weld(chassis,indicator)
        local lever=part(folder,'BrakeLever',Vector3.new(.72,.08,.12),chassis.CFrame*CFrame.new(x*.82,4.38,.08)*CFrame.Angles(0,0,x>0 and math.rad(-18) or math.rad(18)),METAL,Enum.Material.Metal);weld(chassis,lever)
    end
    local headShell=part(folder,'HeadlightShell',Vector3.new(1.6,.72,.72),chassis.CFrame*CFrame.new(0,4.0,-.72)*CFrame.Angles(0,0,math.rad(90)),BLACK,Enum.Material.Metal,Enum.PartType.Cylinder);weld(chassis,headShell)
    local lens=part(folder,'HeadlightLens',Vector3.new(1.68,.53,.53),headShell.CFrame,WHITE,Enum.Material.Glass,Enum.PartType.Cylinder);lens.Transparency=.12;weld(chassis,lens)
    local light=Instance.new('PointLight');light.Name='HeadlightGlow';light.Brightness=.55;light.Range=16;light.Color=Color3.fromRGB(245,242,220);light.Parent=lens
    for _,x in ipairs({-.35,.35}) do
        tube(folder,chassis,'ControlCable',3.1,.035,chassis.CFrame*CFrame.new(x,3.35,.5)*CFrame.Angles(math.rad(12),0,0),Color3.fromRGB(28,28,28))
    end

    -- Rider area: seat contour, foot rests, battery housing, controller and chain guard.
    local seatTop=part(folder,'SaddleCushionTop',Vector3.new(2.0,.32,1.18),chassis.CFrame*CFrame.new(0,3.72,3.02),Color3.fromRGB(35,35,34),Enum.Material.SmoothPlastic);weld(chassis,seatTop)
    local seatNose=wedge(folder,'SaddleNose',Vector3.new(1.15,.32,.55),chassis.CFrame*CFrame.new(0,3.72,2.22)*CFrame.Angles(0,math.rad(180),0),Color3.fromRGB(35,35,34),Enum.Material.SmoothPlastic);weld(chassis,seatNose)
    for _,x in ipairs({-1.45,1.45}) do tube(folder,chassis,'FootPeg',1.05,.11,chassis.CFrame*CFrame.new(x,1.25,2.25),METAL) end
    local battery=part(folder,'BatteryHousing',Vector3.new(2.4,1.35,1.65),chassis.CFrame*CFrame.new(0,1.25,2.3),BLACK,Enum.Material.Metal);weld(chassis,battery)
    local batteryBand=part(folder,'BatteryBand',Vector3.new(2.48,.16,1.73),battery.CFrame*CFrame.new(0,.28,0),GREEN,Enum.Material.Metal);weld(chassis,batteryBand)
    local controller=part(folder,'MotorController',Vector3.new(1.25,.68,1.1),chassis.CFrame*CFrame.new(0,2.0,3.85),DARK,Enum.Material.Metal);weld(chassis,controller)
    local chainGuard=part(folder,'ChainGuard',Vector3.new(.18,1.15,3.1),chassis.CFrame*CFrame.new(-.68,1.0,3.12),BLACK,Enum.Material.Metal);weld(chassis,chainGuard)

    -- Wheel, brake, arch and fender detail. Existing wheels remain canonical visible diameter.
    local fronts={}
    for _,d in ipairs(visual:GetDescendants()) do if d.Name=='FrontWheel20' and d:IsA('BasePart') then table.insert(fronts,d) end end
    for i,w in ipairs(fronts) do addWheelDetail(folder,chassis,w,'Front'..i) end
    local rear=visual:FindFirstChild('RearWheel26',true);addWheelDetail(folder,chassis,rear,'Rear')
    for _,x in ipairs({-3.55,3.55}) do
        local arch=tube(folder,chassis,'FrontWheelArch',4.95,.11,chassis.CFrame*CFrame.new(x,3.15,-3.15)*CFrame.Angles(0,0,math.rad(90)),BLACK)
        arch.Transparency=.05
        local mudFlap=part(folder,'FrontMudFlap',Vector3.new(.18,1.45,.95),chassis.CFrame*CFrame.new(x,1.05,-1.15),DARK,Enum.Material.SmoothPlastic);weld(chassis,mudFlap)
    end

    -- Rear rack, mudguard, tail housing and license plate cues.
    local rack=part(folder,'RearRack',Vector3.new(3.3,.18,2.4),chassis.CFrame*CFrame.new(0,3.15,4.15),BLACK,Enum.Material.Metal);weld(chassis,rack)
    for _,x in ipairs({-1.45,1.45}) do tube(folder,chassis,'RearRackRail',2.45,.07,chassis.CFrame*CFrame.new(x,3.55,4.15)*CFrame.Angles(0,math.rad(90),0),METAL) end
    local tailHousing=part(folder,'TailLightHousing',Vector3.new(1.55,.72,.38),chassis.CFrame*CFrame.new(0,2.25,5.12),BLACK,Enum.Material.Metal);weld(chassis,tailHousing)
    local tailLens=part(folder,'TailLightLens',Vector3.new(1.18,.48,.12),chassis.CFrame*CFrame.new(0,2.25,5.33),RED,Enum.Material.Neon);weld(chassis,tailLens)
    local plate=part(folder,'LicensePlate',Vector3.new(1.65,.62,.08),chassis.CFrame*CFrame.new(0,1.55,5.35),Color3.fromRGB(25,25,25),Enum.Material.Metal);weld(chassis,plate)

    Workspace:SetAttribute('BecakVehicleRealismPartCount',(Workspace:GetAttribute('BecakVehicleRealismPartCount') or 0)+#folder:GetDescendants())
end

for _,m in ipairs(vehicles:GetChildren()) do task.defer(style,m) end
vehicles.ChildAdded:Connect(function(m) task.wait(.4);style(m) end)
Workspace:SetAttribute('ACC_BecakVehicleRealism','v1.0') -- compatibility marker used by current build validator
Workspace:SetAttribute('ACC_BecakVehicleRealismEnhancement','v1.1')
Workspace:SetAttribute('BecakVehicleLayeredBody','ON')
Workspace:SetAttribute('BecakVehicleMechanicalDetail','ON')
Workspace:SetAttribute('BecakVehicleCockpitDetail','ON')
Workspace:SetAttribute('BecakCargoCuboidBreakup','ON')
Workspace:SetAttribute('BecakVehicleBrakeDetail','ON')
Workspace:SetAttribute('BecakVehicleCableDetail','ON')
