-- BBYAVATAR accessibility/performance controls v1.1.
-- Session-local only: no user preference data is persisted or transmitted.
local settingsState = {
    lowFX = false,
    largeUI = false,
    compactUI = false,
}

local originalLightStates = setmetatable({}, {__mode = "k"})
local originalEffectStates = setmetatable({}, {__mode = "k"})
local baseFrameSize = frame.Size
local baseContentSize = content.Size

local panelScale = frame:FindFirstChild("BBYAVATAR_PanelScale")
if not panelScale then
    panelScale = Instance.new("UIScale")
    panelScale.Name = "BBYAVATAR_PanelScale"
    panelScale.Scale = 1
    panelScale.Parent = frame
end

local function tuneFxObject(obj, enabled)
    if obj:IsA("PointLight") or obj:IsA("SurfaceLight") or obj:IsA("SpotLight") then
        if originalLightStates[obj] == nil then originalLightStates[obj] = obj.Enabled end
        obj.Enabled = enabled and false or originalLightStates[obj]
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
        if originalEffectStates[obj] == nil then originalEffectStates[obj] = obj.Enabled end
        obj.Enabled = enabled and false or originalEffectStates[obj]
    end
end

local function applyLowFX(enabled)
    settingsState.lowFX = enabled
    local showroom = workspace:FindFirstChild("BBYAVATAR_SHOWROOM")
    if showroom then
        for _, obj in ipairs(showroom:GetDescendants()) do tuneFxObject(obj, enabled) end
    end
    local atmosphere = game:GetService("Lighting"):FindFirstChild("BBYAVATAR_Atmosphere")
    if atmosphere and atmosphere:IsA("Atmosphere") then
        atmosphere.Density = enabled and 0.04 or 0.14
        atmosphere.Haze = enabled and 0.15 or 0.8
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if not settingsState.lowFX then return end
    if obj:IsDescendantOf(workspace:FindFirstChild("BBYAVATAR_SHOWROOM") or workspace) then
        task.defer(function() if obj.Parent then tuneFxObject(obj, true) end end)
    end
end)

local function applyLargeUI(enabled)
    settingsState.largeUI = enabled
    if enabled then
        local width = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 900
        panelScale.Scale = width < 700 and 1.04 or 1.08
    else
        panelScale.Scale = 1
    end
end

local function applyCompactUI(enabled)
    settingsState.compactUI = enabled
    if enabled then
        frame.Size = UDim2.fromScale(0.88, 0.76)
        content.Size = UDim2.fromScale(0.93, 0.67)
    else
        frame.Size = baseFrameSize
        content.Size = baseContentSize
    end
end

local function makeToggle(parent, label, key, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,48)
    b.BackgroundColor3 = Color3.fromRGB(37,40,50)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0,14)
    pad.PaddingRight = UDim.new(0,14)
    pad.Parent = b

    local function refresh()
        b.Text = label .. "    " .. (settingsState[key] and "ON" or "OFF")
    end
    b.Activated:Connect(function()
        callback(not settingsState[key])
        refresh()
    end)
    refresh()
    return b
end

local function renderSettings()
    clearContent()

    local h = Instance.new("TextLabel")
    h.BackgroundTransparency = 1
    h.Size = UDim2.new(1,0,0,42)
    h.Font = Enum.Font.GothamBlack
    h.Text = "DISPLAY & ACCESSIBILITY"
    h.TextColor3 = Color3.new(1,1,1)
    h.TextSize = 24
    h.TextXAlignment = Enum.TextXAlignment.Left
    h.Parent = content

    local d = Instance.new("TextLabel")
    d.BackgroundTransparency = 1
    d.Position = UDim2.fromOffset(0,44)
    d.Size = UDim2.new(1,0,0,54)
    d.Font = Enum.Font.Gotham
    d.Text = "Tune readability and reduce visual load on lower-end devices. Settings apply only to this play session."
    d.TextWrapped = true
    d.TextColor3 = Color3.fromRGB(190,195,210)
    d.TextSize = 14
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.TextYAlignment = Enum.TextYAlignment.Top
    d.Parent = content

    local actions = Instance.new("Frame")
    actions.BackgroundTransparency = 1
    actions.Position = UDim2.fromOffset(0,108)
    actions.Size = UDim2.new(1,0,0,190)
    actions.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,9)
    layout.Parent = actions

    makeToggle(actions, "LOW FX", "lowFX", applyLowFX)
    makeToggle(actions, "LARGER CATALOG UI", "largeUI", applyLargeUI)
    makeToggle(actions, "COMPACT CATALOG PANEL", "compactUI", applyCompactUI)

    local reset = Instance.new("TextButton")
    reset.Size = UDim2.new(1,0,0,44)
    reset.BackgroundColor3 = Color3.fromRGB(52,45,48)
    reset.TextColor3 = Color3.new(1,1,1)
    reset.Font = Enum.Font.GothamBold
    reset.TextSize = 13
    reset.Text = "RESET DISPLAY SETTINGS"
    reset.Parent = actions
    Instance.new("UICorner", reset).CornerRadius = UDim.new(0,11)
    reset.Activated:Connect(function()
        applyLowFX(false)
        applyLargeUI(false)
        applyCompactUI(false)
        status.Text = "Display settings reset."
        task.defer(renderSettings)
    end)
end

renderers.SETTINGS = renderSettings

local settingsTab = Instance.new("TextButton")
settingsTab.Name = "SettingsTab"
settingsTab.Size = UDim2.fromOffset(94,38)
settingsTab.BackgroundColor3 = Color3.fromRGB(35,37,46)
settingsTab.TextColor3 = Color3.new(1,1,1)
settingsTab.Font = Enum.Font.GothamBold
settingsTab.TextSize = 11
settingsTab.Text = "SETTINGS"
settingsTab.Parent = tabs
Instance.new("UICorner", settingsTab).CornerRadius = UDim.new(0,10)
settingsTab.Activated:Connect(function() selectTab("SETTINGS") end)

print("[BBYAVATAR] Accessibility/performance controls v1.1 ready")