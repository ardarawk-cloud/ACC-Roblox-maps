local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local ROOT = "BBYAVATAR_SHOWROOM"

local old = Workspace:FindFirstChild(ROOT)
if old then old:Destroy() end

local oldRemote = ReplicatedStorage:FindFirstChild("BBYAVATAR")
if oldRemote then oldRemote:Destroy() end

Lighting.ClockTime = 17.8
Lighting.Brightness = 2.2
Lighting.Ambient = Color3.fromRGB(78, 82, 96)
Lighting.OutdoorAmbient = Color3.fromRGB(105, 108, 125)

local function makePart(parent, name, size, cframe, material, color)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Anchored = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color or Color3.fromRGB(34, 36, 44)
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function surfaceLabel(part, text, face, textSize)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "Sign"
    gui.Face = face or Enum.NormalId.Front
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 40
    gui.AlwaysOnTop = false
    gui.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBlack
    label.Text = text
    label.TextColor3 = Color3.fromRGB(245, 245, 248)
    label.TextWrapped = true
    label.TextScaled = textSize == nil
    if textSize then label.TextSize = textSize end
    label.Parent = gui
    return label
end

local root = Instance.new("Folder")
root.Name = ROOT
root.Parent = Workspace
root:SetAttribute("BuildVersion", "2.0")
root:SetAttribute("Experience", "BBYAVATAR")

local shell = Instance.new("Folder")
shell.Name = "Architecture"
shell.Parent = root

makePart(shell, "Floor", Vector3.new(180, 1, 140), CFrame.new(0, 0, 0), Enum.Material.Concrete, Color3.fromRGB(25, 26, 31))
makePart(shell, "BackWall", Vector3.new(180, 32, 1), CFrame.new(0, 16, -69.5), Enum.Material.SmoothPlastic, Color3.fromRGB(18, 19, 24))
makePart(shell, "LeftWall", Vector3.new(1, 32, 140), CFrame.new(-89.5, 16, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(18, 19, 24))
makePart(shell, "RightWall", Vector3.new(1, 32, 140), CFrame.new(89.5, 16, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(18, 19, 24))

local spawn = Instance.new("SpawnLocation")
spawn.Name = "Spawn"
spawn.Size = Vector3.new(10, 1, 10)
spawn.CFrame = CFrame.new(0, 1.5, 58)
spawn.Anchored = true
spawn.Neutral = true
spawn.Transparency = 0.35
spawn.Color = Color3.fromRGB(80, 84, 102)
spawn.Parent = root

local hero = makePart(root, "HeroWall", Vector3.new(80, 18, 1), CFrame.new(0, 12, -67.8), Enum.Material.SmoothPlastic, Color3.fromRGB(26, 28, 36))
surfaceLabel(hero, "BBYAVATAR\nDISCOVER • CREATE • SAVE • SHOP", Enum.NormalId.Front)

local runway = makePart(root, "Runway", Vector3.new(28, 1, 68), CFrame.new(0, 0.7, 18), Enum.Material.SmoothPlastic, Color3.fromRGB(46, 48, 58))
local runwayLight = Instance.new("PointLight")
runwayLight.Brightness = 2
runwayLight.Range = 26
runwayLight.Color = Color3.fromRGB(210, 218, 255)
runwayLight.Parent = runway

local remoteRoot = Instance.new("Folder")
remoteRoot.Name = "BBYAVATAR"
remoteRoot.Parent = ReplicatedStorage
local openEvent = Instance.new("RemoteEvent")
openEvent.Name = "OpenCatalog"
openEvent.Parent = remoteRoot

local function makeZone(index, category, pos, accent)
    local model = Instance.new("Model")
    model.Name = string.format("Zone_%02d_%s", index, category)
    model:SetAttribute("Category", category)
    model.Parent = root

    local base = makePart(model, "Base", Vector3.new(30, 1, 18), CFrame.new(pos), Enum.Material.SmoothPlastic, Color3.fromRGB(31, 33, 40))
    local back = makePart(model, "SignWall", Vector3.new(30, 8, 1), CFrame.new(pos.X, 5, pos.Z - 8.5), Enum.Material.SmoothPlastic, accent)
    surfaceLabel(back, category, Enum.NormalId.Front)

    local rail = makePart(model, "DisplayRail", Vector3.new(24, 0.6, 2), CFrame.new(pos.X, 2, pos.Z - 2.5), Enum.Material.Metal, Color3.fromRGB(110, 114, 128))
    rail.CanCollide = false

    for slot = -1, 1 do
        local pedestal = makePart(model, "Pedestal_" .. tostring(slot + 2), Vector3.new(5, 1.2, 5), CFrame.new(pos.X + slot * 8, 1.1, pos.Z + 2.5), Enum.Material.Marble, Color3.fromRGB(220, 220, 225))
        pedestal:SetAttribute("Category", category)
    end

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "OPEN CATALOG"
    prompt.ObjectText = category
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = base
    prompt.Triggered:Connect(function(player)
        openEvent:FireClient(player, category)
    end)
end

local zones = {
    {"TRENDING", Vector3.new(-58, 0.7, 40), Color3.fromRGB(101, 72, 170)},
    {"NEW DROPS", Vector3.new(58, 0.7, 40), Color3.fromRGB(45, 112, 170)},
    {"STREETWEAR", Vector3.new(-58, 0.7, 14), Color3.fromRGB(135, 77, 55)},
    {"CYBER", Vector3.new(58, 0.7, 14), Color3.fromRGB(39, 128, 136)},
    {"LUXURY", Vector3.new(-58, 0.7, -12), Color3.fromRGB(142, 112, 49)},
    {"CUTE", Vector3.new(58, 0.7, -12), Color3.fromRGB(154, 79, 130)},
    {"BALI", Vector3.new(-58, 0.7, -38), Color3.fromRGB(116, 84, 52)},
    {"CREATORS", Vector3.new(58, 0.7, -38), Color3.fromRGB(61, 105, 75)},
}

for i, z in ipairs(zones) do
    makeZone(i, z[1], z[2], z[3])
end

local featured = makePart(root, "FeaturedStage", Vector3.new(34, 1.5, 20), CFrame.new(0, 1, -47), Enum.Material.Marble, Color3.fromRGB(225, 225, 230))
featured:SetAttribute("Category", "FEATURED")
local featuredSign = makePart(root, "FeaturedSign", Vector3.new(34, 7, 1), CFrame.new(0, 5, -56.5), Enum.Material.SmoothPlastic, Color3.fromRGB(70, 65, 100))
surfaceLabel(featuredSign, "FEATURED LOOKS", Enum.NormalId.Front)
local fp = Instance.new("ProximityPrompt")
fp.ActionText = "DISCOVER"
fp.ObjectText = "FEATURED LOOKS"
fp.HoldDuration = 0
fp.MaxActivationDistance = 14
fp.RequiresLineOfSight = false
fp.Parent = featured
fp.Triggered:Connect(function(player)
    openEvent:FireClient(player, "FEATURED")
end)

local utility = Instance.new("Folder")
utility.Name = "UtilityZones"
utility.Parent = root

local editor = makePart(utility, "AvatarStudio", Vector3.new(22, 1, 14), CFrame.new(-34, 0.7, 56), Enum.Material.SmoothPlastic, Color3.fromRGB(54, 57, 72))
local editorSign = makePart(utility, "AvatarStudioSign", Vector3.new(22, 6, 1), CFrame.new(-34, 4.5, 49.5), Enum.Material.SmoothPlastic, Color3.fromRGB(55, 67, 105))
surfaceLabel(editorSign, "AVATAR STUDIO", Enum.NormalId.Front)
local ep = Instance.new("ProximityPrompt")
ep.ActionText = "CREATE LOOK"
ep.ObjectText = "AVATAR STUDIO"
ep.HoldDuration = 0
ep.MaxActivationDistance = 12
ep.Parent = editor
ep.Triggered:Connect(function(player) openEvent:FireClient(player, "STUDIO") end)

local photo = makePart(utility, "PhotoStudio", Vector3.new(22, 1, 14), CFrame.new(34, 0.7, 56), Enum.Material.SmoothPlastic, Color3.fromRGB(54, 57, 72))
local photoSign = makePart(utility, "PhotoStudioSign", Vector3.new(22, 6, 1), CFrame.new(34, 4.5, 49.5), Enum.Material.SmoothPlastic, Color3.fromRGB(95, 64, 91))
surfaceLabel(photoSign, "PHOTO STUDIO", Enum.NormalId.Front)
local pp = Instance.new("ProximityPrompt")
pp.ActionText = "OPEN"
pp.ObjectText = "PHOTO STUDIO"
pp.HoldDuration = 0
pp.MaxActivationDistance = 12
pp.Parent = photo
pp.Triggered:Connect(function(player) openEvent:FireClient(player, "PHOTO") end)

print("[BBYAVATAR] Showroom v2 ready")