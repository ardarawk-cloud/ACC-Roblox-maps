-- BBYA SOCIAL HUB — MOBILE PANEL PRECISION v2
-- Single owner for compact DANCE/CARRY drawers and the Community overlay.
-- Keeps the approved layout while replacing the old 4 Hz permanent poll with
-- event-driven refreshes plus a very low-frequency safety pass.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local scheduled = false
local viewportConnection

local function scaleFor(parent, name, value)
    local s = parent:FindFirstChild(name)
    if not s or not s:IsA("UIScale") then
        if s then s:Destroy() end
        s = Instance.new("UIScale")
        s.Name = name
        s.Parent = parent
    end
    s.Scale = value
    return s
end

local function findLauncher(gui, wanted)
    for _, obj in ipairs(gui:GetChildren()) do
        if obj:IsA("TextButton") and string.upper(obj.Text or "") == wanted then
            return obj
        end
    end
end

local function applySocial()
    local gui = pg:FindFirstChild("BBYASocialHangoutUI")
    if not gui then return end

    local dance = findLauncher(gui, "DANCE")
    local carry = findLauncher(gui, "CARRY")
    if not dance or not carry then return end

    local vp = (camera and camera.ViewportSize) or Vector2.new(1280, 720)
    local phone = UserInputService.TouchEnabled or vp.Y < 850
    local buttonSize = phone and 40 or 46
    local left = 3
    local lower = math.clamp(math.floor(vp.Y * .22), 148, 180)

    for _, b in ipairs({dance, carry}) do
        b.AnchorPoint = Vector2.new(0, 1)
        b.Size = UDim2.fromOffset(buttonSize, buttonSize)
        b.TextSize = phone and 8 or 9
        b.ZIndex = 90
        local c = b:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 9)
        c.Parent = b
        b:SetAttribute("BBYAMobilePrecisionOwner", "v2")
    end

    dance.Position = UDim2.new(0, left, 1, -lower - buttonSize - 6)
    carry.Position = UDim2.new(0, left, 1, -lower)

    -- Preserve the original 390x390 internal layout, then scale the whole drawer.
    -- This keeps every dance/carry control usable instead of clipping child content.
    local drawerScale = phone and .50 or .68
    for _, name in ipairs({"DancePanel", "CarryPanel"}) do
        local p = gui:FindFirstChild(name)
        if p and p:IsA("Frame") then
            p.AnchorPoint = Vector2.new(0, 1)
            p.Size = UDim2.fromOffset(390, 390)
            p.Position = UDim2.new(0, 52, 1, -lower + buttonSize)
            p.ClipsDescendants = true
            p.ZIndex = 80
            scaleFor(p, "BBYACompactDrawerScale", drawerScale)
            p:SetAttribute("BBYAMobileCompactLocked", true)
            p:SetAttribute("BBYAMobilePrecisionOwner", "v2")
            for _, d in ipairs(p:GetDescendants()) do
                if d:IsA("ScrollingFrame") then d.ScrollBarThickness = 2 end
            end
        end
    end
end

local function applyCommunity()
    local gui = pg:FindFirstChild("BBYAClubUI")
    if not gui then return end

    local shade = gui:FindFirstChild("CommunityOverlay")
    if not shade or not shade:IsA("Frame") then return end
    local panel = shade:FindFirstChild("CommunityPanel")
    if not panel or not panel:IsA("Frame") then return end

    local vp = (camera and camera.ViewportSize) or Vector2.new(1280, 720)
    local phone = UserInputService.TouchEnabled or vp.Y < 850
    local panelScale = phone and ((vp.Y < 650) and .60 or .66) or .82

    panel.AnchorPoint = Vector2.new(.5, .5)
    panel.Position = UDim2.fromScale(.5, .53)
    panel.Size = UDim2.fromOffset(560, 480)
    panel.ClipsDescendants = true
    panel.ZIndex = 81
    scaleFor(panel, "BBYACommunityPrecisionScale", panelScale)
    panel:SetAttribute("BBYAMobilePrecisionLocked", true)
    panel:SetAttribute("BBYAMobilePrecisionOwner", "v2")

    shade.ClipsDescendants = true
    local header = panel:FindFirstChildOfClass("Frame")
    if header then header.ClipsDescendants = true end

    local body = panel:FindFirstChild("CommunityScroller")
    if body and body:IsA("ScrollingFrame") then
        body.Position = UDim2.fromOffset(14, 82)
        body.Size = UDim2.new(1, -28, 1, -94)
        body.ScrollBarThickness = 3
        body.ScrollingEnabled = true
        body.ClipsDescendants = true
        body.CanvasSize = UDim2.fromOffset(0, 560)
    end
end

local function applyAll()
    pcall(applySocial)
    pcall(applyCommunity)
end

local function scheduleApply(delaySeconds)
    if scheduled then return end
    scheduled = true
    task.delay(delaySeconds or 0, function()
        scheduled = false
        applyAll()
    end)
end

local function bindCameraViewport()
    if viewportConnection then
        viewportConnection:Disconnect()
        viewportConnection = nil
    end
    camera = workspace.CurrentCamera
    if camera then
        viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            scheduleApply(.05)
        end)
    end
end

bindCameraViewport()
applyAll()

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    bindCameraViewport()
    scheduleApply(.05)
end)

pg.ChildAdded:Connect(function(child)
    if child.Name == "BBYASocialHangoutUI" or child.Name == "BBYAClubUI" then
        scheduleApply(.05)
        task.delay(.35, applyAll)
        task.delay(1.0, applyAll)
    end
end)

pg.DescendantAdded:Connect(function(obj)
    local n = obj.Name
    if n == "DancePanel" or n == "CarryPanel" or n == "CommunityOverlay" or n == "CommunityPanel" or n == "CommunityScroller" then
        scheduleApply(.05)
    end
end)

UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(function()
    scheduleApply(.05)
end)

-- Rare safety pass for any legacy script that mutates layout without firing a
-- useful structural event. 5 seconds is enough for resilience without a 4 Hz loop.
task.spawn(function()
    while task.wait(5) do
        applyAll()
    end
end)

print("[BBYA] Mobile panel precision v2: event-driven compact social drawers + contained Community overlay")
