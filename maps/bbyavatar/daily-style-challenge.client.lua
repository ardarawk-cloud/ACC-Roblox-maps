-- BBYAVATAR daily style challenge v2 client.
-- Small mobile-safe retention card with privacy-safe streak display.

local getChallenge = root:WaitForChild("GetDailyStyleChallenge")
local challengeUpdated = root:WaitForChild("DailyStyleChallengeUpdated")
local trackRemote = root:FindFirstChild("TrackEvent")

local challengeGui = Instance.new("ScreenGui")
challengeGui.Name = "BBYAVATAR_DailyStyle"
challengeGui.ResetOnSpawn = false
challengeGui.IgnoreGuiInset = false
challengeGui.DisplayOrder = 7
challengeGui.Parent = player:WaitForChild("PlayerGui")

local chip = Instance.new("TextButton")
chip.Name = "DailyStyleChip"
chip.AnchorPoint = Vector2.new(0, 1)
chip.Position = UDim2.new(0, 14, 1, -18)
chip.Size = UDim2.fromOffset(174, 44)
chip.BackgroundColor3 = Color3.fromRGB(29, 31, 40)
chip.TextColor3 = Color3.new(1,1,1)
chip.Font = Enum.Font.GothamBold
chip.TextSize = 12
chip.Text = "DAILY STYLE  0/3"
chip.Parent = challengeGui
Instance.new("UICorner", chip).CornerRadius = UDim.new(0, 13)

local panel = Instance.new("Frame")
panel.Name = "DailyStylePanel"
panel.AnchorPoint = Vector2.new(0, 1)
panel.Position = UDim2.new(0, 14, 1, -70)
panel.Size = UDim2.fromOffset(296, 264)
panel.BackgroundColor3 = Color3.fromRGB(18, 20, 27)
panel.Visible = false
panel.Parent = challengeGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(16, 13)
title.Size = UDim2.new(1, -52, 0, 28)
title.Font = Enum.Font.GothamBlack
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "DAILY STYLE"
title.Parent = panel

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -10, 0, 10)
close.Size = UDim2.fromOffset(32, 32)
close.BackgroundColor3 = Color3.fromRGB(43, 46, 57)
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.Text = "×"
close.Parent = panel
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 10)

local themeLabel = Instance.new("TextLabel")
themeLabel.BackgroundTransparency = 1
themeLabel.Position = UDim2.fromOffset(16, 48)
themeLabel.Size = UDim2.new(1, -32, 0, 46)
themeLabel.Font = Enum.Font.GothamBold
themeLabel.TextColor3 = Color3.fromRGB(205, 211, 236)
themeLabel.TextSize = 13
themeLabel.TextWrapped = true
themeLabel.TextXAlignment = Enum.TextXAlignment.Left
themeLabel.TextYAlignment = Enum.TextYAlignment.Top
themeLabel.Text = "Loading today’s theme…"
themeLabel.Parent = panel

local streakLabel = Instance.new("TextLabel")
streakLabel.BackgroundColor3 = Color3.fromRGB(38, 42, 57)
streakLabel.Position = UDim2.fromOffset(16, 96)
streakLabel.Size = UDim2.new(1, -32, 0, 28)
streakLabel.Font = Enum.Font.GothamBold
streakLabel.TextColor3 = Color3.fromRGB(222, 225, 239)
streakLabel.TextSize = 12
streakLabel.Text = "STYLE STREAK  0 DAYS"
streakLabel.Parent = panel
Instance.new("UICorner", streakLabel).CornerRadius = UDim.new(0, 9)

local checklist = Instance.new("TextLabel")
checklist.BackgroundTransparency = 1
checklist.Position = UDim2.fromOffset(16, 132)
checklist.Size = UDim2.new(1, -32, 0, 74)
checklist.Font = Enum.Font.Gotham
checklist.TextColor3 = Color3.fromRGB(229, 231, 239)
checklist.TextSize = 13
checklist.TextWrapped = true
checklist.TextXAlignment = Enum.TextXAlignment.Left
checklist.TextYAlignment = Enum.TextYAlignment.Top
checklist.Text = "○ Browse a look\n○ Try something on\n○ Save a pick or outfit"
checklist.Parent = panel

local explore = Instance.new("TextButton")
explore.Position = UDim2.new(0, 16, 1, -50)
explore.Size = UDim2.new(1, -32, 0, 36)
explore.BackgroundColor3 = Color3.fromRGB(65, 75, 112)
explore.TextColor3 = Color3.new(1,1,1)
explore.Font = Enum.Font.GothamBold
explore.TextSize = 12
explore.Text = "EXPLORE TODAY’S STYLE"
explore.Parent = panel
Instance.new("UICorner", explore).CornerRadius = UDim.new(0, 10)

local state = nil
local busy = false

local function mark(done, text)
    return (done and "✓  " or "○  ") .. text
end

local function render(nextState)
    if typeof(nextState) ~= "table" then return end
    state = nextState
    local progress = tonumber(state.progress) or 0
    local streak = math.max(0, math.floor(tonumber(state.streak) or 0))

    chip.Text = state.completed and ("DAILY ✓  •  " .. tostring(streak) .. " DAY STREAK") or ("DAILY STYLE  " .. tostring(progress) .. "/3")
    themeLabel.Text = tostring(state.theme or "TODAY") .. "  •  " .. tostring(state.prompt or "Build a look today.")
    streakLabel.Text = "STYLE STREAK  " .. tostring(streak) .. (streak == 1 and " DAY" or " DAYS")
    checklist.Text = table.concat({
        mark(state.browse == true, "Browse a look"),
        mark(state.tryOn == true, "Try something on"),
        mark(state.save == true, "Save a pick or outfit"),
    }, "\n")
    explore.Text = state.completed and "CHALLENGE COMPLETE" or ("EXPLORE " .. tostring(state.category or "FEATURED"))
    explore.Active = not state.completed
    explore.AutoButtonColor = not state.completed
end

local function refresh()
    if busy then return end
    busy = true
    task.spawn(function()
        local ok, result = pcall(function() return getChallenge:InvokeServer() end)
        if ok then render(result) end
        busy = false
    end)
end

chip.Activated:Connect(function()
    panel.Visible = not panel.Visible
    if panel.Visible then
        if trackRemote then pcall(function() trackRemote:FireServer("CHALLENGE_OPEN") end) end
        refresh()
    end
end)
close.Activated:Connect(function() panel.Visible = false end)

explore.Activated:Connect(function()
    if not state or state.completed then return end
    panel.Visible = false
    activeCategory = tostring(state.category or "FEATURED")
    frame.Visible = true
    activeTab = "DISCOVER"
    if renderers and renderers.DISCOVER then renderers.DISCOVER() elseif renderDiscover then renderDiscover() end
end)

challengeUpdated.OnClientEvent:Connect(render)
refresh()

local function resize()
    local camera = workspace.CurrentCamera
    local width = camera and camera.ViewportSize.X or 800
    if width < 500 then
        chip.Size = UDim2.fromOffset(154, 42)
        panel.Size = UDim2.new(1, -28, 0, 250)
    else
        chip.Size = UDim2.fromOffset(174, 44)
        panel.Size = UDim2.fromOffset(296, 264)
    end
end
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
resize()
print("[BBYAVATAR] daily style challenge v2 streak client ready")