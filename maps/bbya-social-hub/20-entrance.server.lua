-- BBYA SOCIAL HUB — ENTRANCE BUILD v0.1
-- Reference target: dark premium entry lobby with large BBYA SOCIAL HUB sign,
-- warm interior lighting, glass-front lounge/bar view, planter accents, clear walk-in axis.
-- Scope ONLY: entrance / arrival threshold. No club core, VIP, rooftop, UI or systems.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "BBYA_ZERO_BUILD"
local root = Workspace:FindFirstChild(ROOT_NAME)
if not root then
    root = Instance.new("Folder")
    root.Name = ROOT_NAME
    root.Parent = Workspace
end

local old = root:FindFirstChild("Entrance")
if old then old:Destroy() end

local model = Instance.new("Model")
model.Name = "Entrance"
model.Parent = root

local C = {
    black = Color3.fromRGB(10, 8, 13),
    charcoal = Color3.fromRGB(22, 18, 25),
    wall = Color3.fromRGB(28, 22, 29),
    floor = Color3.fromRGB(52, 42, 48),
    trim = Color3.fromRGB(255, 37, 149),
    warm = Color3.fromRGB(255, 177, 110),
    glass = Color3.fromRGB(43, 24, 48),
    green = Color3.fromRGB(54, 82, 61),
}

local function part(name, size, cf, color, material, transparency)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = true
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Transparency = transparency or 0
    p.Parent = model
    return p
end

local function neon(name, size, cf, color)
    local p = part(name, size, cf, color, Enum.Material.Neon)
    p.CanCollide = false
    return p
end

local function surfaceText(partObj, face, text, color, textSize)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "SignGui"
    gui.Face = face
    gui.AlwaysOnTop = true
    gui.LightInfluence = 0
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 35
    gui.Parent = partObj

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1,1)
    label.Text = text
    label.TextColor3 = color
    label.TextScaled = false
    label.TextSize = textSize or 72
    label.Font = Enum.Font.GothamMedium
    label.TextStrokeTransparency = 0.75
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = gui
    return label
end

-- Coordinate convention: front / public approach is SOUTH (-Z).
-- Entrance occupies central front portion of the 120x90 building footprint.

-- Arrival forecourt / approach
part("ArrivalForecourt", Vector3.new(70, 1, 24), CFrame.new(0, 0, -55), C.floor, Enum.Material.Slate)
neon("ArrivalEdgeLeft", Vector3.new(0.35, 0.18, 22), CFrame.new(-34.2, 0.62, -55), C.trim)
neon("ArrivalEdgeRight", Vector3.new(0.35, 0.18, 22), CFrame.new(34.2, 0.62, -55), C.trim)

-- Main threshold floor continuing inside
part("EntranceFloor", Vector3.new(70, 1, 32), CFrame.new(0, 0, -31), C.floor, Enum.Material.Slate)

-- Tall facade side masses, leaving broad central opening
part("FacadeLeft", Vector3.new(18, 22, 6), CFrame.new(-26, 11, -45), C.black, Enum.Material.SmoothPlastic)
part("FacadeRight", Vector3.new(18, 22, 6), CFrame.new(26, 11, -45), C.black, Enum.Material.SmoothPlastic)
part("FacadeTop", Vector3.new(34, 6, 6), CFrame.new(0, 19, -45), C.black, Enum.Material.SmoothPlastic)

-- Sign panel above entrance, close to reference composition
local signPanel = part("MainSignPanel", Vector3.new(52, 13, 1.2), CFrame.new(0, 23.5, -42.7), C.charcoal, Enum.Material.SmoothPlastic)
surfaceText(signPanel, Enum.NormalId.Front, "♕\nBBYA\nSOCIAL HUB", C.trim, 78)
neon("SignGlowTop", Vector3.new(52, 0.25, 0.35), CFrame.new(0, 29.9, -42.05), C.trim)
neon("SignGlowBottom", Vector3.new(52, 0.18, 0.35), CFrame.new(0, 17.1, -42.05), C.trim)

-- Open entry aperture and glass strips on both sides
local glassL = part("GlassLeft", Vector3.new(16, 14, 0.5), CFrame.new(-25, 9, -41.8), C.glass, Enum.Material.Glass, 0.38)
glassL.CanCollide = false
local glassR = part("GlassRight", Vector3.new(16, 14, 0.5), CFrame.new(25, 9, -41.8), C.glass, Enum.Material.Glass, 0.38)
glassR.CanCollide = false

-- Interior ceiling bands; open central sightline
part("EntryCeiling", Vector3.new(70, 1, 25), CFrame.new(0, 16, -29), C.black, Enum.Material.SmoothPlastic)
neon("CeilingPinkBand", Vector3.new(54, 0.18, 0.22), CFrame.new(0, 15.4, -37), C.trim)

-- Interior left showcase / bar-like glass counter visible from entrance
part("ShowcaseBack", Vector3.new(26, 9, 1), CFrame.new(-22, 6, -19), C.charcoal, Enum.Material.SmoothPlastic)
local showcaseGlass = part("ShowcaseGlass", Vector3.new(24, 7, 0.4), CFrame.new(-22, 6, -18.4), C.glass, Enum.Material.Glass, 0.3)
showcaseGlass.CanCollide = false
part("ShowcaseCounter", Vector3.new(24, 3, 5), CFrame.new(-22, 2.1, -20), C.wall, Enum.Material.SmoothPlastic)
neon("ShowcaseGlow", Vector3.new(23, 0.18, 0.25), CFrame.new(-22, 8.7, -18.1), C.trim)

-- Warm visible social seating islands as seen through entrance
for i, x in ipairs({-12, 9}) do
    part("LowSofa"..i, Vector3.new(10, 2.4, 4.5), CFrame.new(x, 1.7, -9), C.charcoal, Enum.Material.Fabric)
    part("LowTable"..i, Vector3.new(5.5, 1.2, 3.2), CFrame.new(x, 1.1, -4.8), Color3.fromRGB(48,35,42), Enum.Material.SmoothPlastic)
end

-- Side planter blocks framing the approach
for i, x in ipairs({-31, 31}) do
    part("Planter"..i, Vector3.new(7, 2.5, 7), CFrame.new(x, 1.5, -33), C.charcoal, Enum.Material.Slate)
    local plant = part("PlantCore"..i, Vector3.new(1.8, 4.5, 1.8), CFrame.new(x, 4.2, -33), C.green, Enum.Material.Grass)
    plant.CanCollide = false
    neon("PlanterGlow"..i, Vector3.new(6.2, 0.15, 6.2), CFrame.new(x, 2.84, -33), C.trim)
end

-- Warm wall sconces / lobby points
for _, pos in ipairs({
    Vector3.new(-31, 8, -25), Vector3.new(31, 8, -25),
    Vector3.new(-31, 8, -11), Vector3.new(31, 8, -11)
}) do
    local fixture = neon("WarmFixture", Vector3.new(0.35, 1.8, 0.35), CFrame.new(pos), C.warm)
    local light = Instance.new("PointLight")
    light.Color = C.warm
    light.Brightness = 1.3
    light.Range = 13
    light.Shadows = true
    light.Parent = fixture
end

-- Pink ambient points for the entrance identity
for _, pos in ipairs({
    Vector3.new(-20, 12.8, -32), Vector3.new(0, 12.8, -32), Vector3.new(20, 12.8, -32)
}) do
    local lamp = neon("PinkCeilingLamp", Vector3.new(1.2, 0.25, 1.2), CFrame.new(pos), C.trim)
    local light = Instance.new("PointLight")
    light.Color = C.trim
    light.Brightness = 1
    light.Range = 10
    light.Parent = lamp
end

-- Spawn at the front facing inward.
local spawn = Instance.new("SpawnLocation")
spawn.Name = "EntranceSpawn"
spawn.Anchored = true
spawn.CanCollide = true
spawn.Neutral = true
spawn.Size = Vector3.new(7, 1, 7)
spawn.CFrame = CFrame.lookAt(Vector3.new(0, 1, -60), Vector3.new(0, 1, -30))
spawn.Transparency = 1
spawn.Parent = model

-- Entrance boundary markers for later exact integration with L1 plan.
local markers = Instance.new("Folder")
markers.Name = "Markers"
markers.Parent = model
local function marker(name, position)
    local p = part(name, Vector3.new(0.5,0.5,0.5), CFrame.new(position), Color3.fromRGB(255,255,255), Enum.Material.SmoothPlastic, 1)
    p.CanCollide = false
    p.Parent = markers
end
marker("PublicAxisStart", Vector3.new(0, 0, -60))
marker("MainDoorAxis", Vector3.new(0, 0, -42))
marker("LobbyAxis", Vector3.new(0, 0, -24))
marker("ClubTransition", Vector3.new(0, 0, -8))

-- Mild global night ambience only if not already configured by a later lighting module.
if not Lighting:FindFirstChild("BBYAEntranceColor") then
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "BBYAEntranceColor"
    cc.Brightness = -0.05
    cc.Contrast = 0.12
    cc.Saturation = -0.02
    cc.TintColor = Color3.fromRGB(255, 225, 244)
    cc.Parent = Lighting
end

print("[BBYA] Entrance v0.1 built from zero-baseline reference")
