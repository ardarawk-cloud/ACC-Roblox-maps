local Workspace = game:GetService("Workspace")

local square = Workspace:WaitForChild("WonderSquare_Premium", 20)
if not square then return end

local old = square:FindFirstChild("Decor")
if old then old:Destroy() end

local decor = Instance.new("Folder")
decor.Name = "Decor"
decor.Parent = square

local SURFACE_Y = tonumber(square:GetAttribute("WP_SurfaceY")) or 6.55

local function makePart(name, size, position, material, color, collide, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.CanCollide = collide == true
    p.CanTouch = false
    p.CanQuery = collide == true
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color or Color3.fromRGB(255,255,255)
    if shape then p.Shape = shape end
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = decor
    return p
end

-- Soft stepping paths visually connect the central fountain to each major zone.
local pathColors = {
    Color3.fromRGB(203,236,207),
    Color3.fromRGB(255,211,234),
    Color3.fromRGB(207,225,255),
    Color3.fromRGB(226,211,255),
}

local directions = {
    Vector3.new(-1,0,-1),
    Vector3.new(1,0,-1),
    Vector3.new(1,0,1),
    Vector3.new(-1,0,1),
}

for pathIndex, direction in ipairs(directions) do
    local unit = direction.Unit
    for step=1,5 do
        local distance = 13 + step * 4.1
        local pos = unit * distance + Vector3.new(0, SURFACE_Y + .62, 0)
        local tile = makePart(
            "Pocket Path "..pathIndex.."-"..step,
            Vector3.new(5.2,.22,3.2),
            pos,
            Enum.Material.SmoothPlastic,
            pathColors[pathIndex],
            false
        )
        tile.Orientation = Vector3.new(0, pathIndex % 2 == 0 and 45 or -45, 0)
    end
end

-- Four small benches create a social ring without blocking the fountain or routes.
local benchColor = Color3.fromRGB(185,132,91)
local benchPositions = {
    {Vector3.new(0,SURFACE_Y+1.4,-20),0},
    {Vector3.new(0,SURFACE_Y+1.4,20),180},
    {Vector3.new(-20,SURFACE_Y+1.4,0),90},
    {Vector3.new(20,SURFACE_Y+1.4,0),-90},
}

for i, info in ipairs(benchPositions) do
    local model = Instance.new("Model")
    model.Name = "Pocket Bench "..i
    model.Parent = decor

    local cf = CFrame.new(info[1]) * CFrame.Angles(0, math.rad(info[2]), 0)
    local seat = makePart("Seat", Vector3.new(7,.7,2.2), cf.Position, Enum.Material.WoodPlanks, benchColor, true)
    seat.CFrame = cf
    seat.Parent = model

    local back = makePart("Back", Vector3.new(7,2.3,.55), cf.Position, Enum.Material.WoodPlanks, benchColor, true)
    back.CFrame = cf * CFrame.new(0,1.4,1.0)
    back.Parent = model

    for leg=-1,1,2 do
        local foot = makePart("Leg", Vector3.new(.55,1.5,.55), cf.Position, Enum.Material.Wood, Color3.fromRGB(115,88,72), true)
        foot.CFrame = cf * CFrame.new(leg*2.4,-1.0,0)
        foot.Parent = model
    end
end

-- Stylized pocket trees/planters at plaza corners. Simple geometry keeps mobile cost low.
local planterSpots = {
    Vector3.new(-39,SURFACE_Y+1,-39),
    Vector3.new(39,SURFACE_Y+1,-39),
    Vector3.new(-39,SURFACE_Y+1,39),
    Vector3.new(39,SURFACE_Y+1,39),
}
local crownColors = {
    Color3.fromRGB(136,215,150),
    Color3.fromRGB(255,184,218),
    Color3.fromRGB(151,205,255),
    Color3.fromRGB(199,175,255),
}

for i, spot in ipairs(planterSpots) do
    local planter = makePart("Pocket Planter "..i, Vector3.new(6,1.5,6), spot, Enum.Material.Slate, Color3.fromRGB(238,231,218), true)
    local trunk = makePart("Pocket Tree Trunk "..i, Vector3.new(1.4,6,1.4), spot + Vector3.new(0,3.7,0), Enum.Material.Wood, Color3.fromRGB(135,96,69), false)
    local crown = makePart("Pocket Tree Crown "..i, Vector3.new(6.8,6.8,6.8), spot + Vector3.new(0,7.2,0), Enum.Material.Grass, crownColors[i], false, Enum.PartType.Ball)
    planter:SetAttribute("WP_DecorType","Planter")
    trunk:SetAttribute("WP_DecorType","Tree")
    crown:SetAttribute("WP_DecorType","Tree")
end

-- Give the fountain a bright center jewel that remains readable through day/night.
local jewel = makePart("Wonder Fountain Heart", Vector3.new(2.4,2.4,2.4), Vector3.new(0,12.2,0), Enum.Material.Neon, Color3.fromRGB(255,226,112), false, Enum.PartType.Ball)
local jewelLight = Instance.new("PointLight")
jewelLight.Color = Color3.fromRGB(255,226,140)
jewelLight.Brightness = 1.2
jewelLight.Range = 14
jewelLight.Parent = jewel

-- Add the master tagline to the welcome arch without external textures/assets.
local arch = square:FindFirstChild("WONDERPOCKET Arch")
if arch and arch:IsA("BasePart") then
    local existing = arch:FindFirstChild("WP_Tagline")
    if existing then existing:Destroy() end

    local gui = Instance.new("BillboardGui")
    gui.Name = "WP_Tagline"
    gui.Adornee = arch
    gui.Size = UDim2.fromOffset(260,32)
    gui.StudsOffsetWorldSpace = Vector3.new(0,-3.0,0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 120
    gui.Parent = arch

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.Text = "Build Your Little World"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255,248,218)
    label.TextStrokeColor3 = Color3.fromRGB(48,63,112)
    label.TextStrokeTransparency = .35
    label.Parent = gui
end

print("[WONDERPOCKET] Low-part Wonder Square paths, seating, pocket trees and tagline loaded")
