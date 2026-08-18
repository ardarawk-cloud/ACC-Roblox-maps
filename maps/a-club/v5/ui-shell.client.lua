-- BBYA SOCIAL HUB — V5 MOBILE SAFE UI SHELL v1.0
-- Layout contract:
-- TOP controls/panels open DOWN.
-- LEFT rail panels open RIGHT.
-- RIGHT rail panels open LEFT.
-- Bottom-left and bottom-right remain reserved for Roblox movement/jump controls.
-- This shell is architecture-inspection-safe: no gameplay remotes required.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("BBYA_V5_UI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "BBYA_V5_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 35
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local PINK = Color3.fromRGB(255, 55, 198)
local CYAN = Color3.fromRGB(40, 220, 255)
local GOLD = Color3.fromRGB(255, 205, 80)
local BG = Color3.fromRGB(9, 8, 14)
local CARD = Color3.fromRGB(21, 18, 29)
local CARD2 = Color3.fromRGB(31, 25, 42)
local WHITE = Color3.fromRGB(245, 243, 250)
local MUTED = Color3.fromRGB(164, 156, 176)
local GREEN = Color3.fromRGB(110, 225, 150)

local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 12)
    c.Parent = o
end

local function stroke(o, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or PINK
    s.Transparency = transparency or .55
    s.Thickness = thickness or 1
    s.Parent = o
end

local function text(parent, value, size, pos, textSize, color, bold, align)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Size = size
    t.Position = pos
    t.Text = value
    t.TextColor3 = color or WHITE
    t.TextSize = textSize or 12
    t.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    t.TextXAlignment = align or Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Center
    t.TextWrapped = true
    t.Parent = parent
    return t
end

local function button(parent, value, accent)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.BackgroundColor3 = CARD
    b.Text = value
    b.TextColor3 = accent or WHITE
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.Parent = parent
    corner(b, 11)
    stroke(b, accent or PINK, .78, 1)
    return b
end

local toast = Instance.new("TextLabel")
toast.AnchorPoint = Vector2.new(.5, 0)
toast.BackgroundColor3 = BG
toast.BackgroundTransparency = .03
toast.Size = UDim2.fromOffset(320, 38)
toast.Position = UDim2.new(.5, 0, 0, 82)
toast.TextColor3 = WHITE
toast.TextSize = 12
toast.Font = Enum.Font.GothamBold
toast.Visible = false
toast.ZIndex = 100
toast.Parent = gui
corner(toast, 11)
stroke(toast, PINK, .45, 1)

local toastToken = 0
local function notify(msg)
    toastToken += 1
    local token = toastToken
    toast.Text = tostring(msg)
    toast.Visible = true
    toast.TextTransparency = 0
    toast.BackgroundTransparency = .03
    task.delay(1.8, function()
        if token ~= toastToken then return end
        TweenService:Create(toast, TweenInfo.new(.18), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
        task.wait(.2)
        if token == toastToken then toast.Visible = false end
    end)
end

-- ============================================================
-- TOP BAR — expands DOWN only.
-- ============================================================
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.AnchorPoint = Vector2.new(.5, 0)
topBar.BackgroundColor3 = BG
topBar.BackgroundTransparency = .035
topBar.ZIndex = 10
topBar.Parent = gui
corner(topBar, 14)
stroke(topBar, PINK, .4, 1.2)

local brand = text(topBar, "BBYA", UDim2.fromOffset(72, 24), UDim2.fromOffset(16, 8), 18, PINK, true)
local playerLine = text(topBar, player.DisplayName, UDim2.fromOffset(180, 18), UDim2.fromOffset(16, 31), 11, WHITE, true)
local zoneLine = text(topBar, "ZONE -- • TRANSIT", UDim2.fromOffset(260, 22), UDim2.fromOffset(110, 10), 13, CYAN, true)
local phaseLine = text(topBar, "V5.2 MODULAR", UDim2.fromOffset(180, 18), UDim2.fromOffset(110, 34), 10, MUTED, false)

local topOpen = button(topBar, "ZONE ▾", CYAN)
topOpen.Name = "TopOpen"

local topDrawer = Instance.new("Frame")
topDrawer.Name = "TopDrawer"
topDrawer.AnchorPoint = Vector2.new(.5, 0)
topDrawer.BackgroundColor3 = BG
topDrawer.BackgroundTransparency = .015
topDrawer.Visible = false
topDrawer.ZIndex = 9
topDrawer.Parent = gui
corner(topDrawer, 14)
stroke(topDrawer, CYAN, .45, 1)
text(topDrawer, "ZONE INSPECTOR", UDim2.new(1, -28, 0, 28), UDim2.fromOffset(14, 12), 16, WHITE, true)
local inspector = text(topDrawer, "Current zone will appear here.", UDim2.new(1, -28, 0, 70), UDim2.fromOffset(14, 44), 12, MUTED, false)
text(topDrawer, "Screenshot rule: report the zone code shown in the top bar. Fixes stay isolated to that module.", UDim2.new(1, -28, 0, 54), UDim2.fromOffset(14, 112), 11, WHITE, false)

-- ============================================================
-- SIDE RAILS — kept above Roblox movement/jump areas.
-- LEFT opens RIGHT. RIGHT opens LEFT.
-- ============================================================
local leftRail = Instance.new("Frame")
leftRail.Name = "LeftRail"
leftRail.AnchorPoint = Vector2.new(0, .5)
leftRail.BackgroundColor3 = BG
leftRail.BackgroundTransparency = .04
leftRail.ZIndex = 10
leftRail.Parent = gui
corner(leftRail, 16)
stroke(leftRail, PINK, .48, 1)

local rightRail = Instance.new("Frame")
rightRail.Name = "RightRail"
rightRail.AnchorPoint = Vector2.new(1, .5)
rightRail.BackgroundColor3 = BG
rightRail.BackgroundTransparency = .04
rightRail.ZIndex = 10
rightRail.Parent = gui
corner(rightRail, 16)
stroke(rightRail, CYAN, .48, 1)

local leftLayout = Instance.new("UIListLayout")
leftLayout.Padding = UDim.new(0, 7)
leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
leftLayout.VerticalAlignment = Enum.VerticalAlignment.Center
leftLayout.Parent = leftRail

local rightLayout = Instance.new("UIListLayout")
rightLayout.Padding = UDim.new(0, 7)
rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
rightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
rightLayout.Parent = rightRail

local panelHost = Instance.new("Frame")
panelHost.Name = "PanelHost"
panelHost.BackgroundTransparency = 1
panelHost.Size = UDim2.fromScale(1, 1)
panelHost.Parent = gui

local panelSpecs = {}
local activeKey = nil

local function makePanel(key, title, origin, accent)
    local p = Instance.new("Frame")
    p.Name = key .. "Panel"
    p.BackgroundColor3 = BG
    p.BackgroundTransparency = .01
    p.Visible = false
    p.ClipsDescendants = true
    p.ZIndex = 20
    p.Parent = panelHost
    corner(p, 18)
    stroke(p, accent, .35, 1.1)
    text(p, title, UDim2.new(1, -64, 0, 30), UDim2.fromOffset(18, 14), 18, WHITE, true)
    local x = button(p, "×", WHITE)
    x.Size = UDim2.fromOffset(34, 34)
    x.Position = UDim2.new(1, -48, 0, 10)
    x.TextSize = 20
    panelSpecs[key] = {panel=p, origin=origin, accent=accent}
    x.Activated:Connect(function()
        p.Visible = false
        activeKey = nil
    end)
    return p
end

local function contentLine(p, y, heading, body, accent)
    text(p, heading, UDim2.new(1, -36, 0, 22), UDim2.fromOffset(18, y), 12, accent or PINK, true)
    text(p, body, UDim2.new(1, -36, 0, 48), UDim2.fromOffset(18, y + 22), 11, MUTED, false)
end

local danceP = makePanel("DANCE", "DANCE STUDIO", "LEFT", PINK)
contentLine(danceP, 62, "ARCHITECTURE MODE", "Dance controls will connect after the V5 circulation plan is approved. UI placement is already final-safe.", PINK)
contentLine(danceP, 138, "SAFE OPEN DIRECTION", "This panel slides to the RIGHT of the left rail and never enters the movement joystick area.", CYAN)

local vipP = makePanel("VIP", "VIP ACCESS", "LEFT", GOLD)
contentLine(vipP, 62, "C1 / C2 / C3", "VIP West, VIP East and Queen/Private Bridge are coded as separate architecture modules.", GOLD)
contentLine(vipP, 138, "PASS STATUS", "VIP purchase remains disabled until a real Game Pass ID is configured.", MUTED)

local photoP = makePanel("PHOTO", "PHOTO / VIEW", "LEFT", CYAN)
contentLine(photoP, 62, "D6 PHOTO / VIEW DECK", "The rooftop photo/view zone is isolated as D6 for fast screenshot-based maintenance.", CYAN)

local teleportP = makePanel("TELEPORT", "ZONE NAVIGATION", "LEFT", GREEN)
contentLine(teleportP, 62, "INSPECTION NAV", "Architecture teleport will be connected after landing pads are locked. Zone codes remain the source of truth.", GREEN)

local musicP = makePanel("MUSIC", "MUSIC CONTROLLER", "RIGHT", PINK)
contentLine(musicP, 62, "HYBRID AUTO-DJ", "Music system is intentionally disconnected during greybox review so architecture can be inspected without runtime noise.", PINK)
contentLine(musicP, 138, "SAFE OPEN DIRECTION", "This panel slides LEFT from the right rail and stays clear of the jump button.", CYAN)

local sawerP = makePanel("SAWER", "SAWER / SUPPORT", "RIGHT", PINK)
contentLine(sawerP, 62, "SUPPORT PANEL", "Nominal buttons are reserved for R$5 / R$10 / R$50 / R$100 / R$500.", PINK)
contentLine(sawerP, 138, "NOT ACTIVE YET", "Developer Product IDs are not configured, so real purchases remain disabled.", GOLD)
local amounts = Instance.new("Frame")
amounts.BackgroundTransparency = 1
amounts.Position = UDim2.fromOffset(18, 212)
amounts.Size = UDim2.new(1, -36, 0, 62)
amounts.Parent = sawerP
local amountLayout = Instance.new("UIListLayout")
amountLayout.FillDirection = Enum.FillDirection.Horizontal
amountLayout.Padding = UDim.new(0, 7)
amountLayout.Parent = amounts
for _,n in ipairs({5,10,50,100,500}) do
    local b = button(amounts, "R$"..n, PINK)
    b.Size = UDim2.new(.2, -6, 0, 52)
    b.BackgroundColor3 = CARD2
    b.Activated:Connect(function() notify("Sawer R$"..n.." belum aktif") end)
end

local profileP = makePanel("PROFILE", "PROFILE", "RIGHT", CYAN)
contentLine(profileP, 62, player.DisplayName, "UserId "..player.UserId.." • current zone is shown live in the top status bar.", CYAN)

local settingsP = makePanel("SETTINGS", "UI SETTINGS", "RIGHT", GOLD)
contentLine(settingsP, 62, "MOBILE SAFE MARGINS: ON", "Bottom-left and bottom-right are permanently reserved for Roblox movement controls.", GREEN)
contentLine(settingsP, 138, "DRAWER RULES", "Top ↓  •  Left →  •  Right ←", GOLD)

local function railButton(parent, labelText, accent, key)
    local b = button(parent, labelText, accent)
    b.Size = UDim2.fromOffset(60, 54)
    b.TextSize = 10
    b.Activated:Connect(function()
        if activeKey == key then
            panelSpecs[key].panel.Visible = false
            activeKey = nil
            return
        end
        for k,spec in pairs(panelSpecs) do
            if k ~= key then spec.panel.Visible = false end
        end
        topDrawer.Visible = false
        activeKey = key
        local spec = panelSpecs[key]
        spec.panel.Visible = true
    end)
    return b
end

railButton(leftRail, "✦\nDANCE", PINK, "DANCE")
railButton(leftRail, "♛\nVIP", GOLD, "VIP")
railButton(leftRail, "◎\nPHOTO", CYAN, "PHOTO")
railButton(leftRail, "⌖\nTP", GREEN, "TELEPORT")

railButton(rightRail, "♫\nMUSIC", PINK, "MUSIC")
railButton(rightRail, "◆\nSAWER", PINK, "SAWER")
railButton(rightRail, "●\nPROFILE", CYAN, "PROFILE")
railButton(rightRail, "⚙\nSET", GOLD, "SETTINGS")

local topDrawerOpen = false
topOpen.Activated:Connect(function()
    topDrawerOpen = not topDrawerOpen
    for _,spec in pairs(panelSpecs) do spec.panel.Visible = false end
    activeKey = nil
    topDrawer.Visible = topDrawerOpen
    topOpen.Text = topDrawerOpen and "ZONE ▴" or "ZONE ▾"
end)

-- ============================================================
-- RESPONSIVE LAYOUT
-- ============================================================
local function applyLayout()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local v = cam.ViewportSize
    local mobile = UserInputService.TouchEnabled or v.X < 900

    local topW = math.clamp(v.X * (mobile and .62 or .58), 430, 860)
    local topH = mobile and 60 or 66
    topBar.Size = UDim2.fromOffset(topW, topH)
    topBar.Position = UDim2.new(.58, 0, 0, 8)
    topOpen.Size = UDim2.fromOffset(88, mobile and 38 or 42)
    topOpen.Position = UDim2.new(1, -100, .5, -(mobile and 19 or 21))

    topDrawer.Size = UDim2.fromOffset(math.min(topW, 650), mobile and 180 or 200)
    topDrawer.Position = UDim2.new(.58, 0, 0, topH + 14)

    local railW = mobile and 70 or 78
    local railH = mobile and 270 or 304
    leftRail.Size = UDim2.fromOffset(railW, railH)
    rightRail.Size = UDim2.fromOffset(railW, railH)
    -- Rails stop well above the two Roblox thumb controls.
    leftRail.Position = UDim2.new(0, 12, .48, 0)
    rightRail.Position = UDim2.new(1, -12, .48, 0)

    local panelW = math.clamp(v.X * (mobile and .42 or .34), 330, 520)
    local panelH = math.clamp(v.Y * .58, 300, 460)
    local centerY = .52
    for _,spec in pairs(panelSpecs) do
        local p = spec.panel
        p.Size = UDim2.fromOffset(panelW, panelH)
        p.AnchorPoint = Vector2.new(spec.origin == "RIGHT" and 1 or 0, .5)
        if spec.origin == "LEFT" then
            p.Position = UDim2.new(0, 12 + railW + 12, centerY, 0)
        else
            p.Position = UDim2.new(1, -(12 + railW + 12), centerY, 0)
        end
    end

    toast.Position = UDim2.new(.5, 0, 0, topH + 18)
    player:SetAttribute("BBYAUIProfile", mobile and "MOBILE_SAFE" or "DESKTOP_SAFE")
end

local cam = workspace.CurrentCamera
if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(applyLayout) end
applyLayout()

-- ============================================================
-- LIVE ZONE DETECTOR FOR SCREENSHOT DIAGNOSTICS
-- ============================================================
local currentZone = "--"
local currentZoneName = "TRANSIT"
local function detectZone()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local root = workspace:FindFirstChild("BBYA V5.2 MODULAR GREYBOX")
    if not root then return end
    local p = hrp.Position
    local bestCode, bestName, bestVolume
    for _,f in ipairs(root:GetChildren()) do
        if f:IsA("Folder") then
            local code = f:GetAttribute("BBYAZoneCode")
            if code then
                local cx,cy,cz = f:GetAttribute("BBYACenterX"),f:GetAttribute("BBYACenterY"),f:GetAttribute("BBYACenterZ")
                local sx,sy,sz = f:GetAttribute("BBYASizeX"),f:GetAttribute("BBYASizeY"),f:GetAttribute("BBYASizeZ")
                if cx and cy and cz and sx and sy and sz then
                    local yHalf = math.max(sy/2, 7)
                    if math.abs(p.X-cx) <= sx/2 and math.abs(p.Y-cy) <= yHalf and math.abs(p.Z-cz) <= sz/2 then
                        local vol = sx * math.max(sy,1) * sz
                        if not bestVolume or vol < bestVolume then
                            bestCode, bestName, bestVolume = code, f:GetAttribute("BBYAZoneName") or "ZONE", vol
                        end
                    end
                end
            end
        end
    end
    bestCode = bestCode or "--"
    bestName = bestName or "TRANSIT"
    if bestCode ~= currentZone or bestName ~= currentZoneName then
        currentZone, currentZoneName = bestCode, bestName
        zoneLine.Text = "ZONE "..currentZone.." • "..currentZoneName
        inspector.Text = "CURRENT: ["..currentZone.."] "..currentZoneName.."\nScreenshot diagnostics can target this exact module."
        player:SetAttribute("BBYACurrentZone", currentZone)
        player:SetAttribute("BBYACurrentZoneName", currentZoneName)
    end
end

local acc = 0
RunService.Heartbeat:Connect(function(dt)
    acc += dt
    if acc >= .35 then
        acc = 0
        detectZone()
    end
end)

player:SetAttribute("BBYAV5UIShell", "1.0")
player:SetAttribute("BBYAUIDrawerRule", "TOP_DOWN/LEFT_RIGHT/RIGHT_LEFT")
print("[BBYA] V5 mobile-safe UI shell loaded • top↓ left→ right←")
