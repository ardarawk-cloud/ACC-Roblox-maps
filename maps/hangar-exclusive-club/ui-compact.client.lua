-- Hangar Exclusive Club — compact mobile UI v2
-- Keeps DJ controls available to staff without blocking gameplay.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local djGui = playerGui:WaitForChild("DJPanelGui", 15)
if not djGui then return end
local panel = djGui:FindFirstChildWhichIsA("Frame")
if not panel then return end

-- Wait for the original client to finish constructing the controls.
task.wait(0.5)

local toggle = djGui:FindFirstChild("DJCompactToggle")
if not toggle then
    toggle = Instance.new("TextButton")
    toggle.Name = "DJCompactToggle"
    toggle.Text = "DJ"
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 13
    toggle.TextColor3 = Color3.fromRGB(242,245,248)
    toggle.BackgroundColor3 = Color3.fromRGB(16,18,22)
    toggle.BorderSizePixel = 0
    toggle.Size = UDim2.fromOffset(46,34)
    toggle.Position = UDim2.new(1,-62,0,76)
    toggle.Visible = player:GetAttribute("HangarDJ") == true
    toggle.Parent = djGui
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,9)
    c.Parent=toggle
    local s=Instance.new("UIStroke")
    s.Color=Color3.fromRGB(58,64,74)
    s.Transparency=0.35
    s.Parent=toggle
end

panel.Size = UDim2.fromOffset(276,198)
local OPEN_POS = UDim2.new(1,-292,0,118)
local CLOSED_POS = UDim2.new(1,20,0,118)
panel.Position = CLOSED_POS
panel.Visible = false

local open = false
local changing = false

local function applyVisibility()
    local isDJ = player:GetAttribute("HangarDJ") == true
    toggle.Visible = isDJ
    if not isDJ then
        open = false
        panel.Visible = false
        panel.Position = CLOSED_POS
    end
end

local function setOpen(value)
    if player:GetAttribute("HangarDJ") ~= true then return end
    open = value
    changing = true
    if open then
        panel.Visible = true
        panel.Position = CLOSED_POS
        TweenService:Create(panel,TweenInfo.new(0.22,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=OPEN_POS}):Play()
        toggle.Text = "×"
    else
        local tween=TweenService:Create(panel,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position=CLOSED_POS})
        tween:Play()
        tween.Completed:Once(function()
            if not open then panel.Visible=false end
        end)
        toggle.Text = "DJ"
    end
    task.defer(function() changing=false end)
end

toggle.MouseButton1Click:Connect(function()
    setOpen(not open)
end)

-- If the legacy controller tries to force the panel visible again, keep the
-- compact state authoritative unless the user explicitly opened it.
panel:GetPropertyChangedSignal("Visible"):Connect(function()
    if changing then return end
    if panel.Visible and not open then
        changing=true
        panel.Visible=false
        task.defer(function() changing=false end)
    end
end)

player:GetAttributeChangedSignal("HangarDJ"):Connect(applyVisibility)
applyVisibility()

-- Music button stays compact; its large panel is already closed by default.
local musicGui=playerGui:FindFirstChild("MusicPlayerGui")
if musicGui then
    local musicToggle=musicGui:FindFirstChild("MusicToggleButton")
    if musicToggle and musicToggle:IsA("TextButton") then
        musicToggle.Size=UDim2.fromOffset(78,34)
        musicToggle.TextSize=13
    end
end
