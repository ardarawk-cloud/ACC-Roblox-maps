-- BBYA SOCIAL HUB — MAIN CLUB TRANSITION PASS v1.0
-- Purpose: premium reveal from Social Lobby into the main dance floor.
-- Keeps rooftop systems separate.

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "BBYA Main Club Transition v1"
local old = workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace

local C = {
    black = Color3.fromRGB(8, 8, 14),
    charcoal = Color3.fromRGB(22, 21, 31),
    pink = Color3.fromRGB(255, 42, 170),
    magenta = Color3.fromRGB(215, 55, 255),
    cyan = Color3.fromRGB(40, 225, 255),
    blue = Color3.fromRGB(45, 125, 255),
    gold = Color3.fromRGB(255, 190, 90),
    glass = Color3.fromRGB(50, 65, 92),
}

local function part(name, size, cf, color, material, transparency, collide, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.CanCollide = collide ~= false
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color or C.charcoal
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
    light.Brightness = 1.4
    light.Range = 17
    light.Shadows = false
    light.Parent = p
    return p
end

local function sign(name, text, cf, size, color, parent)
    local b = part(name, size, cf, C.black, Enum.Material.SmoothPlastic, 0, false, parent)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.PixelsPerStud = 28
    gui.LightInfluence = 0
    gui.Parent = b

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBlack
    label.Text = text
    label.TextScaled = true
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.28
    label.Parent = gui
    return b
end

-- Coordinates continue the established venue axis:
-- lobby around Z=61, main club/stage toward negative Z.
local corridor = Instance.new("Folder")
corridor.Name = "Club Reveal Corridor"
corridor.Parent = root

-- Premium compressed corridor: narrow enough to create anticipation,
-- wide enough for multiplayer flow.
part("Transition Floor", Vector3.new(58, 1.2, 42), CFrame.new(0, 2.2, 35), C.black, Enum.Material.Marble, 0, true, corridor)
part("Transition Ceiling", Vector3.new(58, 1, 42), CFrame.new(0, 18, 35), C.black, Enum.Material.Metal, 0, true, corridor)
part("Transition Wall L", Vector3.new(2, 17, 42), CFrame.new(-29, 10, 35), C.charcoal, Enum.Material.Slate, 0, true, corridor)
part("Transition Wall R", Vector3.new(2, 17, 42), CFrame.new(29, 10, 35), C.charcoal, Enum.Material.Slate, 0, true, corridor)

-- Perspective ribs make the player feel pulled into the room.
for i = 0, 6 do
    local z = 53 - i * 6
    local color = (i % 2 == 0) and C.pink or C.blue
    neon("Reveal Rib L " .. i, Vector3.new(.35, 13, .35), CFrame.new(-25.5, 10, z), color, corridor)
    neon("Reveal Rib R " .. i, Vector3.new(.35, 13, .35), CFrame.new(25.5, 10, z), color, corridor)
    neon("Reveal Rib Top " .. i, Vector3.new(51, .35, .35), CFrame.new(0, 16.3, z), color, corridor)
end

sign("Main Club Header", "ENTER THE NIGHT", CFrame.new(0, 13.2, 14.3), Vector3.new(36, 5, .6), C.pink, corridor)
sign("Club Subline", "MAIN CLUB  •  DANCE FLOOR  •  LIVE DJ", CFrame.new(0, 8.5, 14.2), Vector3.new(32, 2.2, .5), C.cyan, corridor)

-- Main-club reveal frame. The lower opening deliberately stays open.
part("Reveal Frame L", Vector3.new(5, 20, 4), CFrame.new(-29, 11, 11), C.black, Enum.Material.Metal, 0, true, corridor)
part("Reveal Frame R", Vector3.new(5, 20, 4), CFrame.new(29, 11, 11), C.black, Enum.Material.Metal, 0, true, corridor)
part("Reveal Frame Top", Vector3.new(63, 4, 4), CFrame.new(0, 19, 11), C.black, Enum.Material.Metal, 0, true, corridor)
neon("Reveal Crown", Vector3.new(38, .55, .55), CFrame.new(0, 16.7, 8.8), C.pink, corridor)

-- VIP split: visible but does not block general club access.
local vip = Instance.new("Folder")
vip.Name = "VIP Split"
vip.Parent = root
part("VIP Split Deck", Vector3.new(23, 1, 23), CFrame.new(39, 3, 26), C.charcoal, Enum.Material.Marble, 0, true, vip)
part("VIP Rail", Vector3.new(1, 5, 23), CFrame.new(27.5, 5.7, 26), C.glass, Enum.Material.Glass, .48, true, vip)
sign("VIP Direction", "VIP  ↗", CFrame.new(39, 8, 14.5) * CFrame.Angles(0, math.rad(180), 0), Vector3.new(14, 3.5, .5), C.gold, vip)
neon("VIP Edge", Vector3.new(22, .25, .25), CFrame.new(39, 3.7, 14.4), C.gold, vip)

-- Crowd funnel markers: keeps center sightline open toward stage.
local social = Instance.new("Folder")
social.Name = "Transition Social Edges"
social.Parent = root
for side = -1, 1, 2 do
    for i = 0, 2 do
        local z = 46 - i * 10
        local base = part("Edge Table " .. side .. " " .. i, Vector3.new(5, 1.1, 5), CFrame.new(side * 20, 3.3, z), C.black, Enum.Material.Glass, .12, true, social)
        neon("Edge Glow " .. side .. " " .. i, Vector3.new(5.4, .14, 5.4), base.CFrame * CFrame.new(0, .65, 0), side < 0 and C.blue or C.pink, social)
    end
end

-- Trigger zones for reveal pulses. They are non-collidable and invisible.
local trigger = part("Club Reveal Trigger", Vector3.new(48, 10, 5), CFrame.new(0, 7, 18), Color3.new(1,1,1), Enum.Material.SmoothPlastic, 1, false, root)
local debounce = {}

local revealLights = {}
for _, obj in ipairs(root:GetDescendants()) do
    if obj:IsA("PointLight") then
        table.insert(revealLights, obj)
    end
end

local function pulseReveal()
    for _, light in ipairs(revealLights) do
        local start = light.Brightness
        light.Brightness = math.max(start, 3.8)
        TweenService:Create(light, TweenInfo.new(.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Brightness = start}):Play()
    end
end

trigger.Touched:Connect(function(hit)
    local character = hit and hit.Parent
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if debounce[character] then return end
    debounce[character] = true
    pulseReveal()
    task.delay(3, function()
        debounce[character] = nil
    end)
end)

-- Keep lobby warm enough to read, then visually increase contrast near club.
local cc = Lighting:FindFirstChild("BBYAClubTransitionColor") or Instance.new("ColorCorrectionEffect")
cc.Name = "BBYAClubTransitionColor"
cc.Brightness = 0.015
cc.Contrast = 0.09
cc.Saturation = 0.04
cc.TintColor = Color3.fromRGB(245, 235, 255)
cc.Parent = Lighting

print("[BBYA] Main Club Transition Pass v1 loaded")
