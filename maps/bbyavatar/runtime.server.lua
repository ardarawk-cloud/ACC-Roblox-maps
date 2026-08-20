local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ROOT = "BBYAVATAR_SHOWROOM"

local old = Workspace:FindFirstChild(ROOT)
if old then old:Destroy() end

local function makePart(name, size, cframe, material)
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

local root = Instance.new("Folder")
root.Name = ROOT
root.Parent = Workspace

local floor = makePart("Floor", Vector3.new(150, 1, 110), CFrame.new(0, 0, 0), Enum.Material.Marble)
floor.Parent = root

for _, wall in ipairs({
    {"BackWall", Vector3.new(150, 28, 1), CFrame.new(0, 14, -54.5)},
    {"LeftWall", Vector3.new(1, 28, 110), CFrame.new(-74.5, 14, 0)},
    {"RightWall", Vector3.new(1, 28, 110), CFrame.new(74.5, 14, 0)},
}) do
    local p = makePart(wall[1], wall[2], wall[3])
    p.Parent = root
end

local spawn = Instance.new("SpawnLocation")
spawn.Name = "Spawn"
spawn.Size = Vector3.new(8, 1, 8)
spawn.CFrame = CFrame.new(0, 1.5, 42)
spawn.Anchored = true
spawn.Neutral = true
spawn.Parent = root

local stage = makePart("FeaturedStage", Vector3.new(36, 2, 18), CFrame.new(0, 1.5, -35), Enum.Material.Neon)
stage.Parent = root

local categories = {
    "STREETWEAR", "CYBER", "LUXURY", "CUTE", "BALI", "SEASONAL", "CREATORS", "TRENDING", "SAVED"
}

local displayFolder = Instance.new("Folder")
displayFolder.Name = "DisplayPoints"
displayFolder.Parent = root

for i, category in ipairs(categories) do
    local row = math.floor((i - 1) / 3)
    local col = (i - 1) % 3
    local x = (col - 1) * 38
    local z = 18 - row * 24

    local zone = makePart("Display_" .. string.format("%02d", i), Vector3.new(24, 1, 14), CFrame.new(x, 1, z), Enum.Material.Marble)
    zone:SetAttribute("Category", category)
    zone.Parent = displayFolder

    local sign = Instance.new("BillboardGui")
    sign.Name = "CategorySign"
    sign.Size = UDim2.fromOffset(320, 80)
    sign.StudsOffset = Vector3.new(0, 6, 0)
    sign.AlwaysOnTop = true
    sign.Parent = zone

    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBold
    text.Text = category
    text.TextScaled = true
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Parent = sign

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Browse"
    prompt.ObjectText = category
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 14
    prompt.RequiresLineOfSight = false
    prompt.Parent = zone
end

local brandAnchor = makePart("BrandAnchor", Vector3.new(2, 2, 2), CFrame.new(0, 7, -51), Enum.Material.SmoothPlastic)
brandAnchor.Transparency = 1
brandAnchor.CanCollide = false
brandAnchor.Parent = root

local brand = Instance.new("BillboardGui")
brand.Size = UDim2.fromOffset(700, 180)
brand.AlwaysOnTop = true
brand.Parent = brandAnchor
local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(1,1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBlack
label.Text = "BBYAVATAR\nAVATAR CATALOG & OUTFIT CREATOR"
label.TextScaled = true
label.TextColor3 = Color3.new(1,1,1)
label.Parent = brand

local remoteRoot = Instance.new("Folder")
remoteRoot.Name = "BBYAVATAR"
remoteRoot.Parent = ReplicatedStorage
local openEvent = Instance.new("RemoteEvent")
openEvent.Name = "OpenCatalog"
openEvent.Parent = remoteRoot

for _, zone in ipairs(displayFolder:GetChildren()) do
    local prompt = zone:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        prompt.Triggered:Connect(function(player)
            openEvent:FireClient(player, zone:GetAttribute("Category") or "Featured")
        end)
    end
end

print("[BBYAVATAR] Live showroom runtime ready")
