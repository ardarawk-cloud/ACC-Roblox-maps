-- BBYAVATAR Style Streak client v1.
-- Displays only server-confirmed persisted streak values. If persistence is unavailable,
-- the experience fails soft and does not invent a streak number.

local streakButton = Instance.new("TextButton")
streakButton.Name = "StyleStreak"
streakButton.AnchorPoint = Vector2.new(1, 1)
streakButton.Position = UDim2.fromScale(0.97, 0.875)
streakButton.Size = UDim2.fromOffset(132, 38)
streakButton.BackgroundColor3 = Color3.fromRGB(46, 43, 57)
streakButton.TextColor3 = Color3.new(1, 1, 1)
streakButton.Font = Enum.Font.GothamBold
streakButton.TextSize = 11
streakButton.Text = "WELCOME BACK"
streakButton.AutoButtonColor = true
streakButton.Parent = gui
Instance.new("UICorner", streakButton).CornerRadius = UDim.new(0, 12)

local function refreshStyleStreak()
    local persisted = player:GetAttribute("BBYAVATAR_VisitStreakPersisted") == true
    local streak = tonumber(player:GetAttribute("BBYAVATAR_VisitStreak")) or 0
    if persisted and streak > 0 then
        streakButton.Text = string.format("STYLE STREAK  %d", streak)
        streakButton.BackgroundColor3 = streak >= 7 and Color3.fromRGB(84, 63, 47) or Color3.fromRGB(46, 43, 57)
    else
        streakButton.Text = "WELCOME BACK"
        streakButton.BackgroundColor3 = Color3.fromRGB(46, 43, 57)
    end
end

for _, attributeName in ipairs({
    "BBYAVATAR_VisitStreak",
    "BBYAVATAR_BestStreak",
    "BBYAVATAR_DistinctVisitDays",
    "BBYAVATAR_VisitStreakPersisted",
}) do
    player:GetAttributeChangedSignal(attributeName):Connect(refreshStyleStreak)
end

streakButton.Activated:Connect(function()
    frame.Visible = true
    local persisted = player:GetAttribute("BBYAVATAR_VisitStreakPersisted") == true
    local streak = tonumber(player:GetAttribute("BBYAVATAR_VisitStreak")) or 0
    local best = tonumber(player:GetAttribute("BBYAVATAR_BestStreak")) or 0
    local visits = tonumber(player:GetAttribute("BBYAVATAR_DistinctVisitDays")) or 0

    if persisted and streak > 0 then
        status.Text = string.format("Style Streak: %d day%s • best %d • %d distinct visit day%s. Tracked once per UTC day; no paid reward is attached.", streak, streak == 1 and "" or "s", best, visits, visits == 1 and "" or "s")
    else
        status.Text = "Style Streak sync is temporarily unavailable. Catalog, try-on, saves, and purchases still work normally."
    end
end)

-- Preserve control-safe placement on narrow/touch viewports without covering the Roblox thumb area.
local function updateStreakViewport()
    local camera = workspace.CurrentCamera
    local size = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local narrow = size.X < 700
    if narrow then
        streakButton.Size = UDim2.fromOffset(112, 34)
        streakButton.TextSize = 10
        streakButton.Position = UDim2.fromScale(0.96, 0.865)
    else
        streakButton.Size = UDim2.fromOffset(132, 38)
        streakButton.TextSize = 11
        streakButton.Position = UDim2.fromScale(0.97, 0.875)
    end
end

local viewportCamera = workspace.CurrentCamera
if viewportCamera then viewportCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateStreakViewport) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    viewportCamera = workspace.CurrentCamera
    if viewportCamera then viewportCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateStreakViewport) end
    updateStreakViewport()
end)

refreshStyleStreak()
updateStreakViewport()
print("[BBYAVATAR] Style Streak mobile badge v1 ready")