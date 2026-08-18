-- BBYA SOCIAL HUB — PREMIUM LOBBY EXPERIENCE v1.0
-- Adds social flow, interactive routing, premium lobby ambience and clear venue transitions.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "BBYA Lobby Experience v1"
local old = workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace

local C = {
    black = Color3.fromRGB(9, 9, 15),
    pink = Color3.fromRGB(255, 45, 178),
    magenta = Color3.fromRGB(210, 45, 255),
    cyan = Color3.fromRGB(45, 225, 255),
    purple = Color3.fromRGB(92, 42, 155),
    warm = Color3.fromRGB(255, 186, 108),
    glass = Color3.fromRGB(55, 68, 96),
}

local function part(name, size, cf, color, material, transparency, collide, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.CanCollide = collide ~= false
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color or C.black
    p.Transparency = transparency or 0
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or root
    return p
end

local function neon(name, size, cf, color, parent)
    local p = part(name, size, cf, color, Enum.Material.Neon, 0, false, parent)
    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = 1.6
    light.Range = 18
    light.Shadows = false
    light.Parent = p
    return p
end

local function textPanel(name, text, cf, size, color, parent)
    local p = part(name, size or Vector3.new(18, 5, .5), cf, C.black, Enum.Material.SmoothPlastic, 0, false, parent)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 34
    gui.LightInfluence = 0
    gui.Parent = p
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextScaled = true
    label.TextColor3 = color or C.pink
    label.TextStrokeTransparency = .45
    label.Parent = gui
    return p
end

local function prompt(parent, actionText, objectText, callback)
    local pp = Instance.new("ProximityPrompt")
    pp.ActionText = actionText
    pp.ObjectText = objectText
    pp.KeyboardKeyCode = Enum.KeyCode.E
    pp.HoldDuration = .25
    pp.MaxActivationDistance = 11
    pp.RequiresLineOfSight = false
    pp.Parent = parent
    pp.Triggered:Connect(callback)
    return pp
end

local lobby = Instance.new("Folder")
lobby.Name = "Premium Social Lobby"
lobby.Parent = root

-- Strong visual corridor from arrival into the club.
for i = -4, 4 do
    local x = i * 11
    neon("Lobby Guide " .. i, Vector3.new(7, .12, .65), CFrame.new(x, 2.1, 61), (i % 2 == 0) and C.pink or C.cyan, lobby)
end

-- Entrance ceiling halo.
for i = 0, 11 do
    local a = (math.pi * 2 / 12) * i
    local x, z = math.cos(a) * 27, 61 + math.sin(a) * 11
    neon("Halo " .. i, Vector3.new(4.8, .22, .22), CFrame.new(x, 18, z) * CFrame.Angles(0, -a, 0), (i % 3 == 0) and C.cyan or C.pink, lobby)
end

-- Social lounge islands.
local loungePositions = {
    Vector3.new(-33, 3.2, 62), Vector3.new(33, 3.2, 62),
    Vector3.new(-18, 3.2, 70), Vector3.new(18, 3.2, 70),
}
for i, pos in ipairs(loungePositions) do
    local island = part("Lounge Island " .. i, Vector3.new(15, 1, 9), CFrame.new(pos), C.black, Enum.Material.Marble, 0, true, lobby)
    neon("Lounge Underglow " .. i, Vector3.new(13, .14, 7), CFrame.new(pos - Vector3.new(0, .53, 0)), i % 2 == 0 and C.cyan or C.pink, lobby)
    for s = -1, 1, 2 do
        local seat = Instance.new("Seat")
        seat.Name = "Social Seat " .. i .. " " .. s
        seat.Size = Vector3.new(5.5, 1.2, 3.5)
        seat.CFrame = CFrame.new(pos + Vector3.new(s * 4, 1.1, 0))
        seat.Anchored = true
        seat.Material = Enum.Material.Fabric
        seat.Color = i % 2 == 0 and Color3.fromRGB(45, 38, 78) or Color3.fromRGB(72, 32, 65)
        seat.Parent = lobby
    end
end

-- Central welcome concierge kiosk.
local concierge = part("Concierge Desk", Vector3.new(19, 4, 5), CFrame.new(0, 4, 72), C.black, Enum.Material.Marble, 0, true, lobby)
neon("Concierge Edge", Vector3.new(18, .18, .22), CFrame.new(0, 6.1, 69.45), C.pink, lobby)
textPanel("Concierge Sign", "WELCOME TO BBYA", CFrame.new(0, 10, 69.6), Vector3.new(24, 4, .4), C.pink, lobby)
prompt(concierge, "Venue Guide", "BBYA Concierge", function(player)
    player:SetAttribute("BBYA_LastGuide", os.time())
end)

-- Photo wall inspired by the reference neon identity.
local photoWall = part("BBYA Photo Wall", Vector3.new(28, 14, 1), CFrame.new(-46, 9, 73), C.black, Enum.Material.Slate, 0, true, lobby)
textPanel("Photo Logo", "♛\nBBYA\nSOCIAL HUB", CFrame.new(-46, 10, 72.45), Vector3.new(22, 11, .35), C.pink, lobby)
for _, x in ipairs({-57, -35}) do
    neon("Photo Edge " .. x, Vector3.new(.28, 13, .28), CFrame.new(x, 9, 72.2), C.magenta, lobby)
end
local photoSpot = part("Photo Spot", Vector3.new(9, .18, 6), CFrame.new(-46, 2.15, 65), C.pink, Enum.Material.Neon, .12, false, lobby)
prompt(photoSpot, "Pose", "BBYA Photo Moment", function(player)
    player:SetAttribute("BBYA_PhotoMoment", os.time())
end)

-- Route hubs: main club and rooftop. These are venue flow shortcuts, not monetization gates.
local clubPad = part("Main Club Access", Vector3.new(13, .35, 8), CFrame.new(18, 2.25, 51), C.cyan, Enum.Material.Neon, .15, false, lobby)
textPanel("Main Club Access Sign", "MAIN CLUB ↓", CFrame.new(18, 7, 47.6), Vector3.new(16, 3.5, .4), C.cyan, lobby)
prompt(clubPad, "Enter", "Main Club", function(player)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(0, 5, 22) end
end)

local roofPad = part("Rooftop Lift Pad", Vector3.new(13, .35, 8), CFrame.new(-18, 2.25, 51), C.pink, Enum.Material.Neon, .15, false, lobby)
textPanel("Rooftop Lift Sign", "ROOFTOP ↑", CFrame.new(-18, 7, 47.6), Vector3.new(16, 3.5, .4), C.pink, lobby)
prompt(roofPad, "Ride Lift", "Rooftop Pool Party", function(player)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(0, 42, 18) end
end)

-- Small premium warm lights so the lobby is not only neon.
for _, x in ipairs({-42, -28, -14, 0, 14, 28, 42}) do
    local lamp = part("Warm Pendant " .. x, Vector3.new(.7, 1.1, .7), CFrame.new(x, 14, 61), C.warm, Enum.Material.Neon, 0, false, lobby)
    local pl = Instance.new("PointLight")
    pl.Color = C.warm
    pl.Brightness = 1.2
    pl.Range = 12
    pl.Parent = lamp
end

-- Soft breathing effect for the hero lobby lighting.
task.spawn(function()
    local on = false
    while root.Parent do
        on = not on
        for _, obj in ipairs(lobby:GetDescendants()) do
            if obj:IsA("PointLight") and obj.Color ~= C.warm then
                TweenService:Create(obj, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Brightness = on and 2.2 or 1.15
                }):Play()
            end
        end
        task.wait(1.8)
    end
end)

-- Player presence marker for future analytics/social effects.
Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("BBYA_LobbyExperience", true)
end)
for _, player in ipairs(Players:GetPlayers()) do
    player:SetAttribute("BBYA_LobbyExperience", true)
end

print("[BBYA] Premium Lobby Experience v1 loaded")
