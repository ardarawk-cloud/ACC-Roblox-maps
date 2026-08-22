-- BBYA SOCIAL HUB — MOBILE UI FINAL OVERRIDE v3
-- Early mobile fallback + Travel panel sizing.
-- Social drawer authority now belongs to MobilePanelPrecision v2 once that script
-- has claimed the DANCE/CARRY UI, preventing two late scripts from fighting layout.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local function round(obj, r)
    local c = obj:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = obj
end

local function precisionOwnsSocial(gui)
    for _, name in ipairs({"DancePanel", "CarryPanel"}) do
        local panel = gui:FindFirstChild(name)
        if panel and panel:GetAttribute("BBYAMobilePrecisionOwner") == "v2" then
            return true
        end
    end
    return false
end

local function styleSocialFallback()
    local gui = pg:FindFirstChild("BBYASocialHangoutUI")
    if not gui or precisionOwnsSocial(gui) then return end

    local dance, carry
    for _, obj in ipairs(gui:GetChildren()) do
        if obj:IsA("TextButton") then
            local t = string.upper(obj.Text or "")
            if t == "DANCE" then dance = obj elseif t == "CARRY" then carry = obj end
        end
    end
    if not dance or not carry then return end

    local vp = (camera and camera.ViewportSize) or Vector2.new(1280, 720)
    local size = 42
    local left = 3
    local lower = math.clamp(math.floor(vp.Y * .22), 150, 184)

    dance.AnchorPoint = Vector2.new(0, 1)
    carry.AnchorPoint = Vector2.new(0, 1)
    dance.Size = UDim2.fromOffset(size, size)
    carry.Size = UDim2.fromOffset(size, size)
    dance.Position = UDim2.new(0, left, 1, -lower - size - 6)
    carry.Position = UDim2.new(0, left, 1, -lower)
    dance.TextSize = 8
    carry.TextSize = 8
    dance.ZIndex = 70
    carry.ZIndex = 70
    round(dance, 10)
    round(carry, 10)

    local panelW = math.clamp(math.floor(vp.X * .26), 238, 286)
    local panelH = math.clamp(math.floor(vp.Y * .40), 210, 270)
    for _, name in ipairs({"DancePanel", "CarryPanel"}) do
        local p = gui:FindFirstChild(name)
        if p and p:IsA("Frame") and p:GetAttribute("BBYAMobilePrecisionOwner") ~= "v2" then
            p.AnchorPoint = Vector2.new(0, 1)
            p.Size = UDim2.fromOffset(panelW, panelH)
            p.Position = UDim2.new(0, left, 1, -lower - size - 12)
            p.ClipsDescendants = true
            p.ZIndex = 60
            round(p, 12)
            p:SetAttribute("BBYALegacyMobileFallback", true)
        end
    end
end

local function compactTravel()
    local gui = pg:FindFirstChild("BBYAClubUI")
    if not gui then return end
    local panel = gui:FindFirstChild("HubPanel")
    if not panel or not panel:IsA("Frame") then return end

    local vp = (camera and camera.ViewportSize) or Vector2.new(1280, 720)
    local isPhone = UserInputService.TouchEnabled or vp.Y < 800
    if not isPhone then return end

    local w = math.clamp(math.floor(vp.X * .48), 460, 650)
    local h = math.clamp(math.floor(vp.Y * .68), 300, 420)
    panel.AnchorPoint = Vector2.new(.5, .5)
    panel.Position = UDim2.fromScale(.5, .52)
    panel.Size = UDim2.fromOffset(w, h)
    panel:SetAttribute("BBYATravelMobileLayout", "v3")

    local travelScroller = panel:FindFirstChild("TravelDestinationScroller", true)
    if travelScroller and travelScroller:IsA("ScrollingFrame") then
        travelScroller.ScrollBarThickness = 2
        local grid = travelScroller:FindFirstChildOfClass("UIGridLayout")
        if grid then
            grid.CellPadding = UDim2.fromOffset(6, 6)
            local available = math.max(360, travelScroller.AbsoluteSize.X)
            local cellW = math.floor((available - 6) / 2)
            grid.CellSize = UDim2.fromOffset(cellW, 72)
        end
    end
end

local function apply()
    pcall(styleSocialFallback)
    pcall(compactTravel)
end

apply()
pg.ChildAdded:Connect(function()
    task.defer(apply)
end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    camera = workspace.CurrentCamera
    task.defer(apply)
end)
if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(apply)
end

-- Short bootstrap window only. Precision v2 becomes the long-lived social owner.
task.spawn(function()
    for _ = 1, 18 do
        task.wait(.35)
        apply()
    end
end)

print("[BBYA] Mobile UI final override v3: travel sizing + conflict-free social fallback")
