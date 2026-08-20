-- BBYA SOCIAL HUB — SOCIAL PANEL SAFE AREA PATCH v1
-- Forces the Social menu to stay fully inside the visible mobile/landscape viewport.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("BBYASocialHangoutUI", 30)
if not gui then return end
local camera = workspace.CurrentCamera

local function findPanel()
    for _,d in ipairs(gui:GetDescendants()) do
        if d:IsA("TextLabel") and d.Text == "BBYA SOCIAL" then
            return d.Parent
        end
    end
    return nil
end

local function findBody(panel)
    for _,d in ipairs(panel:GetChildren()) do
        if d:IsA("Frame") and d.Position.Y.Offset >= 120 and d.BackgroundTransparency == 1 then
            return d
        end
    end
    return nil
end

local panel = findPanel()
if not panel then
    task.wait(1)
    panel = findPanel()
end
if not panel then
    warn("[BBYA] Social safe-area patch: panel not found")
    return
end
panel.Name = "SocialSafePanel"
panel.ClipsDescendants = true

local function apply()
    camera = workspace.CurrentCamera or camera
    local vp = camera and camera.ViewportSize or Vector2.new(1280,720)

    -- Leave room for Roblox top controls and bottom mobile movement controls.
    local topSafe = math.max(48, math.floor(vp.Y * 0.07))
    local bottomSafe = math.max(28, math.floor(vp.Y * 0.08))
    local sideSafe = math.max(18, math.floor(vp.X * 0.025))

    local maxW = math.max(310, vp.X - sideSafe*2)
    local maxH = math.max(330, vp.Y - topSafe - bottomSafe)
    local width = math.clamp(math.floor(vp.X * 0.58), 310, math.min(680,maxW))
    local height = math.clamp(math.floor(vp.Y * 0.72), 330, math.min(510,maxH))

    panel.AnchorPoint = Vector2.new(.5,0)
    panel.Position = UDim2.fromOffset(math.floor(vp.X/2), topSafe)
    panel.Size = UDim2.fromOffset(width,height)

    -- Remove constraints that could push the panel outside a short landscape screen.
    local constraint = panel:FindFirstChildOfClass("UISizeConstraint")
    if constraint then
        constraint.MinSize = Vector2.new(300,300)
        constraint.MaxSize = Vector2.new(math.max(300,maxW), math.max(300,maxH))
    end

    local body = findBody(panel)
    if body then
        body.Size = UDim2.new(1,-36,1,-150)
        body.ClipsDescendants = true
    end

    -- Any ScrollingFrame inside Social must be vertical and fit its parent.
    for _,d in ipairs(panel:GetDescendants()) do
        if d:IsA("ScrollingFrame") then
            d.AutomaticCanvasSize = Enum.AutomaticSize.Y
            d.CanvasSize = UDim2.new()
            d.ScrollingDirection = Enum.ScrollingDirection.Y
            d.ScrollBarThickness = 3
            d.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
            d.Active = true
        end
    end
end

apply()
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(apply) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    camera = workspace.CurrentCamera
    apply()
    if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(apply) end
end)

print("[BBYA] Social menu safe-area patch v1 online")
