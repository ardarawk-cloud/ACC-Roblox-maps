local Workspace = game:GetService("Workspace")

local ROOT_NAME = "BBYAVATAR_SHOWROOM"

local function part(name, size, cframe, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Anchored = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    return p
end

local function label(parent, text, position, size)
    local anchor = part(text:gsub("%s+", "") .. "Sign", size or Vector3.new(16, 5, 1), CFrame.new(position), Enum.Material.SmoothPlastic)
    anchor.Parent = parent

    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.AlwaysOnTop = true
    gui.Parent = anchor

    local title = Instance.new("TextLabel")
    title.Size = UDim2.fromScale(1, 1)
    title.BackgroundTransparency = 1
    title.Text = text
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = gui

    return anchor
end

local old = Workspace:FindFirstChild(ROOT_NAME)
if old then
    old:Destroy()
end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = Workspace

local floor = part("Floor", Vector3.new(150, 1, 110), CFrame.new(0, 0, 0), Enum.Material.Marble)
floor.Parent = root

local backWall = part("BackWall", Vector3.new(150, 28, 1), CFrame.new(0, 14, -54.5), Enum.Material.SmoothPlastic)
backWall.Parent = root
local leftWall = part("LeftWall", Vector3.new(1, 28, 110), CFrame.new(-74.5, 14, 0), Enum.Material.SmoothPlastic)
leftWall.Parent = root
local rightWall = part("RightWall", Vector3.new(1, 28, 110), CFrame.new(74.5, 14, 0), Enum.Material.SmoothPlastic)
rightWall.Parent = root

local lobby = Instance.new("Folder")
lobby.Name = "Lobby"
lobby.Parent = root
label(lobby, "BBYAVATAR", Vector3.new(0, 16, 47), Vector3.new(34, 8, 1))
label(lobby, "AVATAR CATALOG & OUTFIT CREATOR", Vector3.new(0, 10, 47), Vector3.new(38, 4, 1))

local stage = part("FeaturedStage", Vector3.new(38, 2, 22), CFrame.new(0, 1.5, -36), Enum.Material.Neon)
stage.Parent = root
label(root, "FEATURED LOOKS", Vector3.new(0, 8, -53.5), Vector3.new(28, 5, 1))

local spawn = Instance.new("SpawnLocation")
spawn.Name = "Spawn"
spawn.Size = Vector3.new(8, 1, 8)
spawn.CFrame = CFrame.new(0, 1.5, 42)
spawn.Anchored = true
spawn.Neutral = true
spawn.Parent = root

local zones = Instance.new("Folder")
zones.Name = "CategoryZones"
zones.Parent = root

local categoryDefs = {
    {name = "STREETWEAR", x = -52, z = 12},
    {name = "CYBER", x = -26, z = 12},
    {name = "LUXURY", x = 0, z = 12},
    {name = "CUTE", x = 26, z = 12},
    {name = "BALI", x = 52, z = 12},
    {name = "SEASONAL", x = -39, z = -12},
    {name = "CREATORS", x = -13, z = -12},
    {name = "TRENDING", x = 13, z = -12},
    {name = "SAVED", x = 39, z = -12},
}

local displays = Instance.new("Folder")
displays.Name = "DisplayPoints"
displays.Parent = root

for i, def in ipairs(categoryDefs) do
    local zone = Instance.new("Folder")
    zone.Name = def.name
    zone.Parent = zones

    local platform = part(def.name .. "Platform", Vector3.new(18, 1, 14), CFrame.new(def.x, 0.75, def.z), Enum.Material.Marble)
    platform.Parent = zone

    local sign = label(zone, def.name, Vector3.new(def.x, 6, def.z - 6.5), Vector3.new(16, 4, 1))
    sign.CFrame = CFrame.new(def.x, 6, def.z - 6.5)

    local pedestal = part(string.format("Display_%02d", i), Vector3.new(9, 1, 9), CFrame.new(def.x, 1.5, def.z), Enum.Material.Marble)
    pedestal:SetAttribute("Category", def.name)
    pedestal.Parent = displays
end

local photoZone = Instance.new("Folder")
photoZone.Name = "PhotoZone"
photoZone.Parent = root
local photoPlatform = part("PhotoPlatform", Vector3.new(24, 1, 16), CFrame.new(0, 0.75, 31), Enum.Material.Marble)
photoPlatform.Parent = photoZone
label(photoZone, "PHOTO ZONE", Vector3.new(0, 6, 23.5), Vector3.new(18, 4, 1))

print("[BBYAVATAR] Showroom generated with category zones")
