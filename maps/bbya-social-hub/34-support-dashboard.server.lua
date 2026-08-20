-- BBYA SOCIAL HUB — ENTRANCE SUPPORT WALLS v4
-- Dual premium support displays mounted flush to the left/right entrance glass panels.
-- Left: Top Supporters. Right: Live Support + open support menu.

local W = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local root = W:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder")
root.Name = "BBYA_ZERO_BUILD"
root.Parent = W

local old = root:FindFirstChild("SupportDashboard")
if old then old:Destroy() end

local model = Instance.new("Model")
model.Name = "SupportDashboard"
model:SetAttribute("Pass", "ENTRANCE_DUAL_SUPPORT_V4")
model.Parent = root

local PINK = Color3.fromRGB(255, 38, 155)
local CYAN = Color3.fromRGB(0, 205, 235)
local WHITE = Color3.fromRGB(244, 241, 247)
local MUTED = Color3.fromRGB(151, 145, 161)
local DARK = Color3.fromRGB(8, 8, 11)
local PANEL = Color3.fromRGB(20, 18, 24)
local PANEL2 = Color3.fromRGB(29, 25, 34)
local GOLD = Color3.fromRGB(238, 190, 94)
local SILVER = Color3.fromRGB(201, 205, 214)
local BRONZE = Color3.fromRGB(201, 129, 84)

local function part(name, size, cf, color, material, transparency, parent)
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
    p.Parent = parent or model
    return p
end

local function corner(obj, px)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, px or 10)
    c.Parent = obj
end

local function stroke(obj, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
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

local function label(parent, textValue, pos, size, color, font, align, scaled)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Position = pos
    t.Size = size
    t.Text = textValue
    t.TextColor3 = color or WHITE
    t.Font = font or Enum.Font.GothamMedium
    t.TextScaled = scaled ~= false
    t.TextWrapped = true
    t.TextXAlignment = align or Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Center
    t.Parent = parent
    return t
end

local function makeBoard(name, x, accentTop, accentBottom)
    local holder = Instance.new("Model")
    holder.Name = name
    holder.Parent = model

    -- Entrance glass panels live at X ±33, Y 7, Z -44.2 and face the arrival forecourt.
    -- Board sits just in front of the glass, flush enough to read as integrated architecture.
    local cf = CFrame.new(x, 7.0, -44.48)
    part("Recess", Vector3.new(15.45, 12.05, .30), cf * CFrame.new(0, 0, .10), Color3.fromRGB(5,5,7), Enum.Material.Metal, 0, holder)
    local face = part("DisplayGlass", Vector3.new(14.65, 11.25, .10), cf * CFrame.new(0, 0, -.14), Color3.fromRGB(10,9,13), Enum.Material.Glass, .05, holder)
    face.Reflectance = .06
    part("TopTrim", Vector3.new(14.72, .10, .12), cf * CFrame.new(0, 5.66, -.21), accentTop, Enum.Material.Neon, 0, holder)
    part("BottomTrim", Vector3.new(14.72, .08, .12), cf * CFrame.new(0, -5.66, -.21), accentBottom, Enum.Material.Neon, 0, holder)

    local light = Instance.new("PointLight")
    light.Color = accentTop
    light.Brightness = .28
    light.Range = 7
    light.Shadows = false
    light.Parent = face

    local gui = Instance.new("SurfaceGui")
    gui.Name = "SupportUI"
    gui.Face = Enum.NormalId.Front
    gui.AlwaysOnTop = false
    gui.LightInfluence = .2
    gui.PixelsPerStud = 72
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.Parent = face

    local bg = frame(gui, UDim2.fromScale(0,0), UDim2.fromScale(1,1), DARK, 0)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 14, 30)),
        ColorSequenceKeypoint.new(.50, Color3.fromRGB(12, 10, 15)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 16, 20)),
    })
    grad.Rotation = 14
    grad.Parent = bg
    return holder, face, bg
end

-- LEFT: TOP SUPPORTERS ---------------------------------------------------------
local leftModel, leftFace, left = makeBoard("TopSupportersWall", -33, GOLD, PINK)
label(left, "BBYA", UDim2.fromScale(.055,.055), UDim2.fromScale(.18,.07), WHITE, Enum.Font.GothamBlack)
label(left, "TOP SUPPORTERS", UDim2.fromScale(.055,.122), UDim2.fromScale(.72,.085), GOLD, Enum.Font.GothamBlack)
label(left, "COMMUNITY HALL OF FAME", UDim2.fromScale(.055,.203), UDim2.fromScale(.58,.04), MUTED, Enum.Font.GothamBold)
local dividerL = frame(left, UDim2.fromScale(.055,.258), UDim2.fromScale(.89,.004), GOLD, .12)
local dgl = Instance.new("UIGradient");dgl.Color=ColorSequence.new(GOLD,PINK);dgl.Parent=dividerL

local rankColors={GOLD,SILVER,BRONZE}
local rankNames={"#1","#2","#3"}
for i=1,3 do
    local y=.31+(i-1)*.205
    local card=frame(left,UDim2.fromScale(.055,y),UDim2.fromScale(.89,.165),PANEL2,.03,10)
    stroke(card,rankColors[i],.30,1)
    local badge=frame(card,UDim2.fromScale(.025,.14),UDim2.fromScale(.16,.72),Color3.fromRGB(12,11,15),0,99)
    stroke(badge,rankColors[i],.16,2)
    label(badge,rankNames[i],UDim2.fromScale(.08,.08),UDim2.fromScale(.84,.84),rankColors[i],Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
    label(card,"OPEN SLOT",UDim2.fromScale(.22,.18),UDim2.fromScale(.45,.27),WHITE,Enum.Font.GothamBold)
    label(card,"Waiting for supporter",UDim2.fromScale(.22,.49),UDim2.fromScale(.62,.22),MUTED,Enum.Font.GothamMedium)
end
label(left,"BBYA SOCIAL HUB  ·  SUPPORT WALL",UDim2.fromScale(.055,.925),UDim2.fromScale(.70,.035),MUTED,Enum.Font.GothamBold)

-- RIGHT: LIVE SUPPORT ----------------------------------------------------------
local rightModel, rightFace, right = makeBoard("LiveSupportWall", 33, PINK, CYAN)
label(right,"BBYA",UDim2.fromScale(.055,.055),UDim2.fromScale(.18,.07),WHITE,Enum.Font.GothamBlack)
label(right,"LIVE SUPPORT",UDim2.fromScale(.055,.122),UDim2.fromScale(.62,.085),PINK,Enum.Font.GothamBlack)
label(right,"RECENT COMMUNITY ACTIVITY",UDim2.fromScale(.055,.203),UDim2.fromScale(.68,.04),MUTED,Enum.Font.GothamBold)
local dividerR=frame(right,UDim2.fromScale(.055,.258),UDim2.fromScale(.89,.004),PINK,.12)
local dgr=Instance.new("UIGradient");dgr.Color=ColorSequence.new(PINK,CYAN);dgr.Parent=dividerR

for i=1,3 do
    local y=.31+(i-1)*.155
    local card=frame(right,UDim2.fromScale(.055,y),UDim2.fromScale(.89,.12),PANEL,.03,9)
    stroke(card,i==1 and PINK or Color3.fromRGB(61,55,69),i==1 and .28 or .55,1)
    local dot=frame(card,UDim2.fromScale(.035,.31),UDim2.fromScale(.055,.38),i==1 and PINK or CYAN,0,99)
    label(card,"WAITING FOR SUPPORT",UDim2.fromScale(.12,.18),UDim2.fromScale(.67,.27),WHITE,Enum.Font.GothamBold)
    label(card,"Be part of BBYA history",UDim2.fromScale(.12,.50),UDim2.fromScale(.67,.22),MUTED,Enum.Font.GothamMedium)
end

local action=frame(right,UDim2.fromScale(.055,.80),UDim2.fromScale(.89,.12),Color3.fromRGB(55,15,42),0,10)
stroke(action,PINK,.16,1)
local ag=Instance.new("UIGradient");ag.Color=ColorSequence.new(Color3.fromRGB(102,18,70),Color3.fromRGB(22,53,64));ag.Parent=action
label(action,"OPEN SUPPORT MENU",UDim2.fromScale(.05,.13),UDim2.fromScale(.90,.45),WHITE,Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
label(action,"Tap / Use",UDim2.fromScale(.05,.56),UDim2.fromScale(.90,.24),Color3.fromRGB(214,202,218),Enum.Font.GothamMedium,Enum.TextXAlignment.Center)
label(right,"BBYA SOCIAL HUB  ·  LIVE COMMUNITY",UDim2.fromScale(.055,.945),UDim2.fromScale(.75,.027),MUTED,Enum.Font.GothamBold)

-- Functional prompt: both boards open the unified Support panel.
local remotes = ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
local state = remotes and remotes:FindFirstChild("State")
for _,face in ipairs({leftFace,rightFace}) do
    local prompt=Instance.new("ProximityPrompt")
    prompt.Name="OpenSupportMenu"
    prompt.ActionText="Open Support"
    prompt.ObjectText="BBYA Support Wall"
    prompt.KeyboardKeyCode=Enum.KeyCode.E
    prompt.HoldDuration=0
    prompt.MaxActivationDistance=11
    prompt.RequiresLineOfSight=false
    prompt.Parent=face
    prompt.Triggered:Connect(function(player)
        if state then state:FireClient(player,"openSupport",true) end
    end)
end

print("[BBYA] Entrance dual support walls online: Top Supporters left, Live Support right")