local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local ROOT = "BBYAVATAR_SHOWROOM"

local old = Workspace:FindFirstChild(ROOT)
if old then old:Destroy() end

local oldRemote = ReplicatedStorage:FindFirstChild("BBYAVATAR")
if oldRemote then oldRemote:Destroy() end

for _, effectName in ipairs({"BBYAVATAR_Color", "BBYAVATAR_Atmosphere"}) do
    local oldEffect = Lighting:FindFirstChild(effectName)
    if oldEffect then oldEffect:Destroy() end
end

Lighting.ClockTime = 17.8
Lighting.Brightness = 2.2
Lighting.Ambient = Color3.fromRGB(78, 82, 96)
Lighting.OutdoorAmbient = Color3.fromRGB(105, 108, 125)

local color = Instance.new("ColorCorrectionEffect")
color.Name = "BBYAVATAR_Color"
color.Brightness = 0.02
color.Contrast = 0.08
color.Saturation = -0.06
color.Parent = Lighting

local atmosphere = Instance.new("Atmosphere")
atmosphere.Name = "BBYAVATAR_Atmosphere"
atmosphere.Density = 0.18
atmosphere.Offset = 0.08
atmosphere.Haze = 1.1
atmosphere.Glare = 0.05
atmosphere.Parent = Lighting

local function makePart(parent, name, size, cframe, material, partColor)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Anchored = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = partColor or Color3.fromRGB(34, 36, 44)
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function surfaceLabel(part, text, face, textSize, textColor)
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
    label.TextColor3 = textColor or Color3.fromRGB(245, 245, 248)
    label.TextWrapped = true
    label.TextScaled = textSize == nil
    if textSize then label.TextSize = textSize end
    label.Parent = gui
    return label
end

local function addSoftLight(part, lightColor, range, brightness)
    local light = Instance.new("SurfaceLight")
    light.Face = Enum.NormalId.Front
    light.Angle = 110
    light.Range = range or 12
    light.Brightness = brightness or 0.8
    light.Color = lightColor
    light.Shadows = false
    light.Parent = part
end

local root = Instance.new("Folder")
root.Name = ROOT
root.Parent = Workspace
root:SetAttribute("BuildVersion", "2.1")
root:SetAttribute("Experience", "BBYAVATAR")
root:SetAttribute("UXRevision", "WAYFINDING_A")

local shell = Instance.new("Folder")
shell.Name = "Architecture"
shell.Parent = root

makePart(shell, "Floor", Vector3.new(180, 1, 140), CFrame.new(0, 0, 0), Enum.Material.Concrete, Color3.fromRGB(25, 26, 31))
makePart(shell, "BackWall", Vector3.new(180, 32, 1), CFrame.new(0, 16, -69.5), Enum.Material.SmoothPlastic, Color3.fromRGB(18, 19, 24))
makePart(shell, "LeftWall", Vector3.new(1, 32, 140), CFrame.new(-89.5, 16, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(18, 19, 24))
makePart(shell, "RightWall", Vector3.new(1, 32, 140), CFrame.new(89.5, 16, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(18, 19, 24))

-- Entrance framing creates a clear first read on mobile without floating BillboardGui text.
makePart(shell, "EntranceLeft", Vector3.new(3, 16, 3), CFrame.new(-17, 8, 64), Enum.Material.Metal, Color3.fromRGB(58, 61, 73))
makePart(shell, "EntranceRight", Vector3.new(3, 16, 3), CFrame.new(17, 8, 64), Enum.Material.Metal, Color3.fromRGB(58, 61, 73))
local entranceHeader = makePart(shell, "EntranceHeader", Vector3.new(37, 4, 3), CFrame.new(0, 15, 64), Enum.Material.SmoothPlastic, Color3.fromRGB(31, 33, 41))
surfaceLabel(entranceHeader, "BBYAVATAR", Enum.NormalId.Front)

local spawn = Instance.new("SpawnLocation")
spawn.Name = "Spawn"
spawn.Size = Vector3.new(10, 1, 10)
spawn.CFrame = CFrame.new(0, 1.5, 58) * CFrame.Angles(0, math.rad(180), 0)
spawn.Anchored = true
spawn.Neutral = true
spawn.Transparency = 0.55
spawn.Color = Color3.fromRGB(80, 84, 102)
spawn.Parent = root

local hero = makePart(root, "HeroWall", Vector3.new(80, 18, 1), CFrame.new(0, 12, -67.8), Enum.Material.SmoothPlastic, Color3.fromRGB(26, 28, 36))
surfaceLabel(hero, "BBYAVATAR\nDISCOVER • CREATE • SAVE • SHOP", Enum.NormalId.Front)
addSoftLight(hero, Color3.fromRGB(210, 218, 255), 16, 0.7)

local runway = makePart(root, "Runway", Vector3.new(28, 1, 68), CFrame.new(0, 0.7, 18), Enum.Material.SmoothPlastic, Color3.fromRGB(46, 48, 58))
local runwayLight = Instance.new("PointLight")
runwayLight.Brightness = 1.4
runwayLight.Range = 24
runwayLight.Color = Color3.fromRGB(210, 218, 255)
runwayLight.Parent = runway

-- Low-profile aisle strips provide directional structure while staying mobile/performance safe.
for _, x in ipairs({-17, 17}) do
    makePart(shell, "RunwayGuide_" .. tostring(x), Vector3.new(0.35, 0.08, 92), CFrame.new(x, 0.57, 4), Enum.Material.Neon, Color3.fromRGB(90, 96, 122))
end

local directory = makePart(root, "Directory", Vector3.new(46, 9, 1), CFrame.new(0, 6, 48.5), Enum.Material.SmoothPlastic, Color3.fromRGB(33, 35, 43))
surfaceLabel(directory, "LEFT WING  ←  TRENDING • STREETWEAR • LUXURY • BALI\nCENTER  ↓  FEATURED LOOKS\nRIGHT WING  →  NEW DROPS • CYBER • CUTE • CREATORS", Enum.NormalId.Front, 24, Color3.fromRGB(232, 234, 242))
addSoftLight(directory, Color3.fromRGB(190, 198, 235), 10, 0.5)

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
    surfaceLabel(back, string.format("%02d  %s", index, category), Enum.NormalId.Front)
    addSoftLight(back, accent, 10, 0.45)

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
addSoftLight(featuredSign, Color3.fromRGB(125, 115, 180), 11, 0.55)
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
addSoftLight(editorSign, Color3.fromRGB(110, 135, 210), 9, 0.45)
local ep = Instance.new("ProximityPrompt")
ep.ActionText = "CREATE LOOK"
ep.ObjectText = "AVATAR STUDIO"
ep.HoldDuration = 0
ep.MaxActivationDistance = 12
ep.RequiresLineOfSight = false
ep.Parent = editor
ep.Triggered:Connect(function(player) openEvent:FireClient(player, "STUDIO") end)

local photo = makePart(utility, "PhotoStudio", Vector3.new(22, 1, 14), CFrame.new(34, 0.7, 56), Enum.Material.SmoothPlastic, Color3.fromRGB(54, 57, 72))
local photoSign = makePart(utility, "PhotoStudioSign", Vector3.new(22, 6, 1), CFrame.new(34, 4.5, 49.5), Enum.Material.SmoothPlastic, Color3.fromRGB(95, 64, 91))
surfaceLabel(photoSign, "PHOTO STUDIO", Enum.NormalId.Front)
addSoftLight(photoSign, Color3.fromRGB(190, 126, 181), 9, 0.45)
local pp = Instance.new("ProximityPrompt")
pp.ActionText = "OPEN"
pp.ObjectText = "PHOTO STUDIO"
pp.HoldDuration = 0
pp.MaxActivationDistance = 12
pp.RequiresLineOfSight = false
pp.Parent = photo
pp.Triggered:Connect(function(player) openEvent:FireClient(player, "PHOTO") end)

print("[BBYAVATAR] Showroom v2.1 wayfinding ready")
