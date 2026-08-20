-- BBYA SOCIAL HUB — INTEGRATED SUPPORT WALL v3
-- Compact architectural fixture mounted into the main bar wall. Never floats in the entrance sightline.

local W = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local root = W:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder")
root.Name = "BBYA_ZERO_BUILD"
root.Parent = W

local old = root:FindFirstChild("SupportDashboard")
if old then old:Destroy() end

local model = Instance.new("Model")
model.Name = "SupportDashboard"
model.Parent = root

local PINK = Color3.fromRGB(255, 38, 155)
local CYAN = Color3.fromRGB(0, 205, 235)
local WHITE = Color3.fromRGB(244, 241, 247)
local MUTED = Color3.fromRGB(151, 145, 161)
local DARK = Color3.fromRGB(10, 9, 13)
local PANEL = Color3.fromRGB(20, 18, 24)
local GOLD = Color3.fromRGB(238, 190, 94)

local function part(name, size, cf, color, material, transparency)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Transparency = transparency or 0
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = true
    p.CastShadow = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = model
    return p
end

-- Main-bar rear wall is around X=52. Mount the board flush to it, facing inward toward -X.
local wallCF = CFrame.new(50.85, 6.25, 11) * CFrame.Angles(0, math.rad(90), 0)
part("Recess", Vector3.new(13.4, 7.15, .32), wallCF * CFrame.new(0, 0, .08), Color3.fromRGB(5, 5, 7), Enum.Material.Metal, 0)
local face = part("DisplayGlass", Vector3.new(12.55, 6.30, .10), wallCF * CFrame.new(0, 0, -.18), Color3.fromRGB(13, 11, 16), Enum.Material.Glass, .10)
part("TopTrim", Vector3.new(12.65, .09, .12), wallCF * CFrame.new(0, 3.18, -.24), PINK, Enum.Material.Neon, 0)
part("BottomTrim", Vector3.new(12.65, .07, .12), wallCF * CFrame.new(0, -3.18, -.24), CYAN, Enum.Material.Neon, 0)

local pinkLight = Instance.new("PointLight")
pinkLight.Color = PINK
pinkLight.Brightness = .45
pinkLight.Range = 7
pinkLight.Shadows = false
pinkLight.Parent = face

local gui = Instance.new("SurfaceGui")
gui.Name = "SawerUI"
gui.Face = Enum.NormalId.Front
gui.AlwaysOnTop = false
gui.LightInfluence = .35
gui.PixelsPerStud = 70
gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
gui.Parent = face

local function corner(obj, px)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, px or 8)
    c.Parent = obj
end

local function stroke(obj, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = 1
    s.Transparency = transparency or 0
    s.Parent = obj
end

local function frame(parent, pos, size, color, transparency, radius)
    local f = Instance.new("Frame")
    f.Position = pos
    f.Size = size
    f.BackgroundColor3 = color
    f.BackgroundTransparency = transparency or 0
    f.BorderSizePixel = 0
    f.Parent = parent
    if radius then corner(f, radius) end
    return f
end

local function label(parent, textValue, pos, size, color, font, align)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Position = pos
    t.Size = size
    t.Text = textValue
    t.TextColor3 = color or WHITE
    t.Font = font or Enum.Font.GothamMedium
    t.TextScaled = true
    t.TextXAlignment = align or Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Center
    t.Parent = parent
    return t
end

local bg = frame(gui, UDim2.fromScale(0,0), UDim2.fromScale(1,1), DARK, 0)
local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 14, 30)),
    ColorSequenceKeypoint.new(.52, Color3.fromRGB(13, 11, 17)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 15, 19)),
})
grad.Rotation = 12
grad.Parent = bg

label(bg, "BBYA", UDim2.fromScale(.055,.07), UDim2.fromScale(.16,.09), WHITE, Enum.Font.GothamBlack)
label(bg, "SUPPORT WALL", UDim2.fromScale(.205,.07), UDim2.fromScale(.38,.09), PINK, Enum.Font.GothamBlack)
label(bg, "Community supporters · live session", UDim2.fromScale(.057,.155), UDim2.fromScale(.55,.05), MUTED, Enum.Font.GothamMedium)

local divider = frame(bg, UDim2.fromScale(.055,.225), UDim2.fromScale(.89,.004), PINK, .18)
local dgrad = Instance.new("UIGradient")
dgrad.Color = ColorSequence.new(PINK, CYAN)
dgrad.Parent = divider

local left = frame(bg, UDim2.fromScale(.055,.275), UDim2.fromScale(.58,.56), PANEL, .05, 10)
stroke(left, Color3.fromRGB(70, 58, 78), .45)
label(left, "TOP SUPPORTERS", UDim2.fromScale(.045,.055), UDim2.fromScale(.50,.09), WHITE, Enum.Font.GothamBold)

local rows = {
    {"01", GOLD},
    {"02", Color3.fromRGB(200,203,213)},
    {"03", Color3.fromRGB(201,129,84)},
}
for i, row in ipairs(rows) do
    local y = .19 + (i-1)*.245
    local card = frame(left, UDim2.fromScale(.04,y), UDim2.fromScale(.92,.19), Color3.fromRGB(29,25,34), .05, 8)
    local rank = frame(card, UDim2.fromScale(.03,.19), UDim2.fromScale(.14,.62), Color3.fromRGB(13,12,16), 0, 99)
    stroke(rank, row[2], .25)
    label(rank, row[1], UDim2.fromScale(.05,.05), UDim2.fromScale(.90,.90), row[2], Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    label(card, "OPEN", UDim2.fromScale(.21,.22), UDim2.fromScale(.30,.26), WHITE, Enum.Font.GothamBold)
    label(card, "Waiting for supporter", UDim2.fromScale(.21,.50), UDim2.fromScale(.58,.22), MUTED, Enum.Font.GothamMedium)
end

local action = frame(bg, UDim2.fromScale(.665,.275), UDim2.fromScale(.28,.56), Color3.fromRGB(18,16,22), .03, 10)
stroke(action, PINK, .35)
label(action, "LIGHT UP", UDim2.fromScale(.08,.09), UDim2.fromScale(.84,.10), WHITE, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
label(action, "THE ROOM", UDim2.fromScale(.08,.19), UDim2.fromScale(.84,.10), PINK, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
label(action, "Support opens the\nfull menu on your screen.", UDim2.fromScale(.10,.35), UDim2.fromScale(.80,.17), MUTED, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
local button = frame(action, UDim2.fromScale(.10,.62), UDim2.fromScale(.80,.18), PINK, 0, 9)
local bgrad = Instance.new("UIGradient")
bgrad.Color = ColorSequence.new(Color3.fromRGB(255,41,157), Color3.fromRGB(181,31,151))
bgrad.Parent = button
label(button, "TAP / USE", UDim2.fromScale(.08,.12), UDim2.fromScale(.84,.76), WHITE, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
label(bg, "BBYA SOCIAL HUB  ·  24/7", UDim2.fromScale(.055,.89), UDim2.fromScale(.55,.045), MUTED, Enum.Font.GothamBold)

local prompt = Instance.new("ProximityPrompt")
prompt.Name = "OpenSawerMenu"
prompt.ActionText = "Open Support"
prompt.ObjectText = "BBYA Support Wall"
prompt.KeyboardKeyCode = Enum.KeyCode.E
prompt.HoldDuration = 0
prompt.MaxActivationDistance = 10
prompt.RequiresLineOfSight = false
prompt.Parent = face

local remotes = ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
local state = remotes and remotes:FindFirstChild("State")
prompt.Triggered:Connect(function(player)
    if state then state:FireClient(player, "openSupport", true) end
end)

print("[BBYA] Support wall integrated flush into main bar interior")
