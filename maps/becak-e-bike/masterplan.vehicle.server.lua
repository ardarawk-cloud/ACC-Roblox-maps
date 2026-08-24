-- BECAK E-BIKE — Cargo E-Bike 01 masterplan vehicle visual v1.1
-- Canon visual: 3 wheels, 2x front 20in, 1x rear 26in, front cargo box,
-- rider saddle behind cargo, upright handlebar, matte-black carbon-steel look.
-- v1.1 performance: decorative visual parts are excluded from touch/query simulation.

local Workspace = game:GetService('Workspace')
local root = Workspace:WaitForChild('BecakEBike', 30)
if not root then return end
local vehicles = root:WaitForChild('Vehicles', 30)
if not vehicles then return end

local BLACK = Color3.fromRGB(24,26,28)
local DARK = Color3.fromRGB(42,45,48)
local PANEL = Color3.fromRGB(32,34,36)
local METAL = Color3.fromRGB(74,76,78)
local WHITE = Color3.fromRGB(235,235,232)
local RED = Color3.fromRGB(195,45,40)

local function makePart(parent,name,size,cf,color,material,shape)
    local p = Instance.new('Part')
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = false
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Massless = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Color = color or BLACK
    p.Material = material or Enum.Material.Metal
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end

local function weld(rootPart,p)
    local w = Instance.new('WeldConstraint')
    w.Part0 = rootPart
    w.Part1 = p
    w.Parent = p
end

local function addBrand(panel)
    local gui = Instance.new('SurfaceGui')
    gui.Face = Enum.NormalId.Left
    gui.AlwaysOnTop = false
    gui.Parent = panel
    local bg = Instance.new('Frame')
    bg.Size = UDim2.fromScale(1,1)
    bg.BackgroundTransparency = 1
    bg.Parent = gui
    local t = Instance.new('TextLabel')
    t.Size = UDim2.fromScale(.88,.6)
    t.Position = UDim2.fromScale(.06,.2)
    t.BackgroundTransparency = 1
    t.Text = 'BECAK\nE-BIKE'
    t.TextColor3 = WHITE
    t.TextStrokeTransparency = .65
    t.Font = Enum.Font.GothamBlack
    t.TextScaled = true
    t.Parent = bg
end

local function hideLegacy(model)
    for _,name in ipairs({'PassengerCabin','Canopy','WheelFL','WheelFR','WheelRear','FrontWheel','RearWheel'}) do
        local p = model:FindFirstChild(name,true)
        if p and p:IsA('BasePart') then
            p.Transparency = 1
            p.CanCollide = false
        end
    end
end

local function styleVehicle(model)
    if not model:IsA('Model') or model:GetAttribute('MasterplanVehicleStyled') then return end
    local chassis = model.PrimaryPart or model:FindFirstChild('Chassis')
    if not chassis or not chassis:IsA('BasePart') then return end
    model:SetAttribute('MasterplanVehicleStyled',true)
    model:SetAttribute('VehicleModel','Cargo E-Bike 01')
    model:SetAttribute('VehicleType','CARGO E-BIKE (3 RODA)')
    model:SetAttribute('LengthMM',1960)
    model:SetAttribute('WidthMM',820)
    model:SetAttribute('HeightMM',950)
    model:SetAttribute('MaxLoadKG',150)
    model:SetAttribute('FrontWheelInch',20)
    model:SetAttribute('RearWheelInch',26)
    model:SetAttribute('Finish','Powder Coating')
    model:SetAttribute('VisualPhysicsLite','v1.1')

    hideLegacy(model)

    local old = model:FindFirstChild('MasterplanVisual')
    if old then old:Destroy() end
    local visual = Instance.new('Model')
    visual.Name = 'MasterplanVisual'
    visual.Parent = model

    -- Scale Roblox body to retain drive physics while reading like the engineering masterplan.
    local cargo = makePart(visual,'CargoBox',Vector3.new(6.0,3.4,4.8),chassis.CFrame*CFrame.new(0,2.15,-3.1),PANEL,Enum.Material.Metal)
    weld(chassis,cargo)
    addBrand(cargo)

    local cargoFloor = makePart(visual,'CargoFloor',Vector3.new(5.6,.35,4.4),chassis.CFrame*CFrame.new(0,.9,-3.1),BLACK,Enum.Material.Metal)
    weld(chassis,cargoFloor)

    -- Open-top rim / box structure.
    for _,spec in ipairs({
        {Vector3.new(.22,1.2,4.9),CFrame.new(-3.05,3.3,-3.1)},
        {Vector3.new(.22,1.2,4.9),CFrame.new( 3.05,3.3,-3.1)},
        {Vector3.new(6.0,1.2,.22),CFrame.new(0,3.3,-5.5)},
        {Vector3.new(6.0,1.2,.22),CFrame.new(0,3.3,-.7)},
    }) do
        local p=makePart(visual,'CargoRim',spec[1],chassis.CFrame*CFrame.new(spec[2].Position),BLACK,Enum.Material.Metal)
        weld(chassis,p)
    end

    -- Upright steering stem and handlebar behind cargo box.
    local stem = makePart(visual,'UprightStem',Vector3.new(.45,3.4,.45),chassis.CFrame*CFrame.new(0,3.1,.0)*CFrame.Angles(math.rad(-8),0,0),METAL,Enum.Material.Metal)
    weld(chassis,stem)
    local bar = makePart(visual,'UprightHandlebar',Vector3.new(4.6,.38,.38),chassis.CFrame*CFrame.new(0,4.6,-.15),BLACK,Enum.Material.Metal)
    weld(chassis,bar)

    -- Rider saddle area.
    local saddlePost = makePart(visual,'SaddlePost',Vector3.new(.55,2.25,.55),chassis.CFrame*CFrame.new(0,2.25,3.05),METAL,Enum.Material.Metal)
    weld(chassis,saddlePost)
    local saddle = makePart(visual,'Saddle',Vector3.new(2.2,.55,1.35),chassis.CFrame*CFrame.new(0,3.45,3.05),DARK,Enum.Material.SmoothPlastic)
    weld(chassis,saddle)

    -- Front pair: 20-inch-equivalent wheels flanking the cargo box.
    for _,x in ipairs({-3.55,3.55}) do
        local wheel = makePart(visual,'FrontWheel20',Vector3.new(1.05,4.4,4.4),chassis.CFrame*CFrame.new(x,1.25,-3.15)*CFrame.Angles(0,0,math.rad(90)),BLACK,Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
        weld(chassis,wheel)
        local hub = makePart(visual,'FrontHub',Vector3.new(1.16,1.05,1.05),wheel.CFrame,WHITE,Enum.Material.Metal,Enum.PartType.Cylinder)
        weld(chassis,hub)
    end

    -- Larger single rear wheel: 26-inch-equivalent.
    local rear = makePart(visual,'RearWheel26',Vector3.new(1.15,5.7,5.7),chassis.CFrame*CFrame.new(0,1.55,4.25)*CFrame.Angles(0,0,math.rad(90)),BLACK,Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
    weld(chassis,rear)
    local rearHub = makePart(visual,'RearHub',Vector3.new(1.25,1.2,1.2),rear.CFrame,WHITE,Enum.Material.Metal,Enum.PartType.Cylinder)
    weld(chassis,rearHub)

    -- Carbon-steel frame impression.
    for _,spec in ipairs({
        {Vector3.new(.42,.42,7.4),CFrame.new(-1.8,1.0,.5)*CFrame.Angles(0,math.rad(9),0)},
        {Vector3.new(.42,.42,7.4),CFrame.new( 1.8,1.0,.5)*CFrame.Angles(0,math.rad(-9),0)},
        {Vector3.new(4.4,.4,.4),CFrame.new(0,1.0,2.8)},
    }) do
        local p=makePart(visual,'CarbonSteelFrame',spec[1],chassis.CFrame*spec[2],BLACK,Enum.Material.Metal)
        weld(chassis,p)
    end

    local rearLight = makePart(visual,'RearReflector',Vector3.new(1.2,.45,.25),chassis.CFrame*CFrame.new(0,2.1,5.05),RED,Enum.Material.Neon)
    weld(chassis,rearLight)

    local badge = makePart(visual,'ModelBadge',Vector3.new(2.4,.5,.12),chassis.CFrame*CFrame.new(0,3.45,-5.56),WHITE,Enum.Material.SmoothPlastic)
    weld(chassis,badge)

    print('[BECAK E-BIKE] Styled vehicle as Cargo E-Bike 01 masterplan for',model.Name)
end

for _,m in ipairs(vehicles:GetChildren()) do task.defer(styleVehicle,m) end
vehicles.ChildAdded:Connect(function(m)
    task.wait(.25)
    styleVehicle(m)
end)

Workspace:SetAttribute('ACC_BecakVehicleMasterplan','Cargo E-Bike 01 v1.0')
Workspace:SetAttribute('ACC_BecakVehicleVisualPerformance','v1.1')
Workspace:SetAttribute('BecakDecorativeVisualTouch','OFF')
Workspace:SetAttribute('BecakDecorativeVisualQuery','OFF')
