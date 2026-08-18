local Workspace = game:GetService("Workspace")

local old = Workspace:FindFirstChild("WonderSquare_Premium")
if old then old:Destroy() end

local root = Instance.new("Folder")
root.Name = "WonderSquare_Premium"
root.Parent = Workspace

local FLOOR_Y = 6.55
local PAD_Y = 7.1

local function part(name, size, position, material, color)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color or Color3.fromRGB(255,255,255)
    p.Parent = root
    return p
end

local plaza = part("Wonder Plaza", Vector3.new(90,1,90), Vector3.new(0,FLOOR_Y,0), Enum.Material.Slate, Color3.fromRGB(226,229,238))
plaza:SetAttribute("WP_Zone", "WonderSquare")

local fountainBase = part("Fountain Base", Vector3.new(18,2,18), Vector3.new(0,8,0), Enum.Material.Marble, Color3.fromRGB(245,245,255))
fountainBase.Shape = Enum.PartType.Cylinder
fountainBase.Orientation = Vector3.new(0,0,90)

local water = part("Fountain Water", Vector3.new(14,1,14), Vector3.new(0,9.1,0), Enum.Material.Glass, Color3.fromRGB(86,205,255))
water.Shape = Enum.PartType.Cylinder
water.Orientation = Vector3.new(0,0,90)
water.Transparency = 0.28
water.CanCollide = false

for i=1,12 do
    local a = (i/12)*math.pi*2
    local lamp = part("Glow Lamp", Vector3.new(0.8,5,0.8), Vector3.new(math.cos(a)*34,9.5,math.sin(a)*34), Enum.Material.Metal, Color3.fromRGB(69,75,98))
    local glow = Instance.new("PointLight")
    glow.Color = Color3.fromRGB(255,220,154)
    glow.Range = 16
    glow.Brightness = 1.3
    glow.Parent = lamp
end

local zones = {
    {name="Wondi Playground", pos=Vector3.new(-28,PAD_Y,-24), color=Color3.fromRGB(154,229,159)},
    {name="Fashion Corner", pos=Vector3.new(28,PAD_Y,-24), color=Color3.fromRGB(255,173,217)},
    {name="Adventure Gate", pos=Vector3.new(28,PAD_Y,24), color=Color3.fromRGB(149,191,255)},
    {name="Friend Portals", pos=Vector3.new(-28,PAD_Y,24), color=Color3.fromRGB(205,170,255)},
}

for _, z in ipairs(zones) do
    local pad = part(z.name, Vector3.new(20,1,16), z.pos, Enum.Material.SmoothPlastic, z.color)
    pad:SetAttribute("WP_Zone", z.name)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Top
    gui.AlwaysOnTop = true
    gui.Parent = pad
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.Text = z.name
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.fromRGB(40,45,65)
    label.Parent = gui
end

part("Welcome Arch L", Vector3.new(3,16,3), Vector3.new(-10,15,-43), Enum.Material.SmoothPlastic, Color3.fromRGB(117,181,255))
part("Welcome Arch R", Vector3.new(3,16,3), Vector3.new(10,15,-43), Enum.Material.SmoothPlastic, Color3.fromRGB(255,167,210))
local top = part("WONDERPOCKET Arch", Vector3.new(23,3,3), Vector3.new(0,23,-43), Enum.Material.SmoothPlastic, Color3.fromRGB(255,225,95))
local gui = Instance.new("SurfaceGui")
gui.Face = Enum.NormalId.Front
gui.AlwaysOnTop = true
gui.Parent = top
local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1,1)
title.BackgroundTransparency = 1
title.Text = "WONDERPOCKET"
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.TextColor3 = Color3.fromRGB(35,55,112)
title.Parent = gui

local squareSpawn = Workspace:FindFirstChild("WonderSquareSpawn") or Instance.new("Part")
squareSpawn.Name = "WonderSquareSpawn"
squareSpawn.Size = Vector3.new(4,1,4)
squareSpawn.Position = Vector3.new(0,8,-34)
squareSpawn.Anchored = true
squareSpawn.CanCollide = false
squareSpawn.Transparency = 1
squareSpawn.Parent = Workspace

root:SetAttribute("WP_SurfaceY", FLOOR_Y)
print("[WONDERPOCKET] Premium Wonder Square built above island surface")
