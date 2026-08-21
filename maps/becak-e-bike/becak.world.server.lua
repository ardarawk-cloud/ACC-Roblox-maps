-- BECAK E-BIKE — safe world bootstrap v1.31
-- Standalone namespace: Workspace/BecakEBike
-- IMPORTANT: never destroy an existing generated/live BecakEBike world.

local Workspace = game:GetService("Workspace")

local ROOT_NAME = "BecakEBike"
local existing = Workspace:FindFirstChild(ROOT_NAME)

-- The generated production place owns Workspace/BecakEBike. Older prototype code
-- destroyed that tree on startup, which could wipe vehicles, interactives, economy,
-- and Nusakarya depending on Script execution order. If a production root already
-- exists, leave it untouched and only expose an audit marker.
if existing then
    Workspace:SetAttribute("ACC_BecakWorldBootstrap", "v1.31-safe")
    Workspace:SetAttribute("BecakWorldBootstrapMode", "PRESERVE_EXISTING")
    print("[BECAK E-BIKE] world bootstrap v1.31: existing production root preserved")
    return
end

-- Fallback prototype is created only for an otherwise-empty development place.
local root = Instance.new("Folder")
root.Name = ROOT_NAME
root:SetAttribute("PrototypeFallback", true)
root.Parent = Workspace

local function part(name, size, cframe, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cframe
    p.Material = material or Enum.Material.Concrete
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = root
    return p
end

local ground = part(
    "TestGround",
    Vector3.new(260, 2, 220),
    CFrame.new(0, -1, 0),
    Enum.Material.Asphalt
)
ground.Color = Color3.fromRGB(35, 38, 42)

local road = part(
    "MainTestRoad",
    Vector3.new(34, 0.6, 900),
    CFrame.new(0, 0.3, 360),
    Enum.Material.Asphalt
)
road.Color = Color3.fromRGB(45, 45, 48)

for z = -60, 780, 28 do
    local marker = part(
        "LaneMarker",
        Vector3.new(0.45, 0.08, 10),
        CFrame.new(0, 0.65, z),
        Enum.Material.Neon
    )
    marker.Color = Color3.fromRGB(235, 210, 80)
    marker.CanCollide = false
    marker.CanTouch = false
    marker.CanQuery = false
end

local spawn = Instance.new("SpawnLocation")
spawn.Name = "BecakSpawn"
spawn.Size = Vector3.new(12, 1, 12)
spawn.CFrame = CFrame.new(0, 1, -65)
spawn.Anchored = true
spawn.Neutral = true
spawn.Material = Enum.Material.Neon
spawn.Color = Color3.fromRGB(65, 180, 255)
spawn.Parent = root

local routeFolder = Instance.new("Folder")
routeFolder.Name = "DeliveryRoutePrototype"
routeFolder.Parent = root

local checkpoints = {
    Vector3.new(0, 2, 80),
    Vector3.new(0, 2, 260),
    Vector3.new(0, 2, 440),
    Vector3.new(0, 2, 620),
    Vector3.new(0, 2, 780),
}

for i, pos in ipairs(checkpoints) do
    local cp = Instance.new("Part")
    cp.Name = string.format("Checkpoint_%02d", i)
    cp.Shape = Enum.PartType.Cylinder
    cp.Size = Vector3.new(1, 16, 16)
    cp.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
    cp.Anchored = true
    cp.CanCollide = false
    cp.CanTouch = false
    cp.CanQuery = false
    cp.Transparency = 0.35
    cp.Material = Enum.Material.Neon
    cp.Color = Color3.fromRGB(70, 210, 140)
    cp.Parent = routeFolder
end

local stand = part(
    "VehiclePrototypePad",
    Vector3.new(26, 1, 18),
    CFrame.new(34, 0.5, -50),
    Enum.Material.Metal
)
stand.Color = Color3.fromRGB(20, 22, 25)

local sign = Instance.new("Part")
sign.Name = "ProjectSign"
sign.Size = Vector3.new(18, 7, 0.8)
sign.CFrame = CFrame.new(34, 5, -58)
sign.Anchored = true
sign.CanCollide = false
sign.Color = Color3.fromRGB(15, 18, 22)
sign.Parent = root

local gui = Instance.new("SurfaceGui")
gui.Face = Enum.NormalId.Front
gui.Parent = sign

local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Text = "BECAK E-BIKE\nPROTOTYPE ZONE"
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.TextColor3 = Color3.fromRGB(240, 245, 255)
label.Parent = gui

Workspace:SetAttribute("ACC_BecakWorldBootstrap", "v1.31-safe")
Workspace:SetAttribute("BecakWorldBootstrapMode", "PROTOTYPE_FALLBACK")
print("[BECAK E-BIKE] world bootstrap v1.31: empty-place prototype initialized")
