-- BBYA SOCIAL HUB — V5 FLOATING / EDGE-DOCK UI v1.0
-- Open panels are draggable floating windows.
-- Release near LEFT / RIGHT / TOP to dock and collapse into a small edge tab.
-- Bottom docking is intentionally disabled to protect Roblox movement/jump controls.

local FLOAT_DOCK_THRESHOLD = 48
local FLOAT_EDGE_GAP = 8
local FLOAT_BOTTOM_SAFE = 118
local FLOAT_TAB_W = 34
local FLOAT_TAB_H = 72

local floatDockRoot = Instance.new("Frame")
floatDockRoot.Name = "FloatingDockTabs"
floatDockRoot.BackgroundTransparency = 1
floatDockRoot.Size = UDim2.fromScale(1, 1)
floatDockRoot.ZIndex = 80
floatDockRoot.Parent = gui

local floatingState = {}

local function viewportSize()
    local camera = workspace.CurrentCamera
    return camera and camera.ViewportSize or Vector2.new(800, 600)
end

local function clampPanelXY(panel, x, y)
    local v = viewportSize()
    local w, h = panel.AbsoluteSize.X, panel.AbsoluteSize.Y
    local maxX = math.max(FLOAT_EDGE_GAP, v.X - w - FLOAT_EDGE_GAP)
    local maxY = math.max(74, v.Y - h - FLOAT_BOTTOM_SAFE)
    return math.clamp(x, FLOAT_EDGE_GAP, maxX), math.clamp(y, 74, maxY)
end

local function setAbsolutePanelPosition(panel, x, y)
    panel.AnchorPoint = Vector2.new(0, 0)
    local cx, cy = clampPanelXY(panel, x, y)
    panel.Position = UDim2.fromOffset(cx, cy)
end

local function restoreFloatingPanel(key)
    local spec = panelSpecs[key]
    local state = floatingState[key]
    if not spec or not state then return end

    for otherKey,otherSpec in pairs(panelSpecs) do
        if otherKey ~= key then otherSpec.panel.Visible = false end
    end
    topDrawer.Visible = false
    activeKey = key

    if state.tab then state.tab.Visible = false end
    state.docked = nil
    spec.panel.Visible = true

    local v = viewportSize()
    local p = spec.panel
    local w, h = p.AbsoluteSize.X, p.AbsoluteSize.Y
    local x
    if spec.origin == "RIGHT" then
        x = v.X - w - 100
    else
        x = 100
    end
    local y = math.max(82, (v.Y - h) * .48)
    setAbsolutePanelPosition(p, x, y)
    player:SetAttribute("BBYAFloatingPanel", key)
end

local function ensureDockTab(key, accent)
    local state = floatingState[key]
    if state.tab then return state.tab end

    local tab = button(floatDockRoot, key:sub(1, 2), accent)
    tab.Name = key .. "DockTab"
    tab.Size = UDim2.fromOffset(FLOAT_TAB_W, FLOAT_TAB_H)
    tab.TextSize = 9
    tab.TextWrapped = true
    tab.ZIndex = 85
    tab.Visible = false
    tab.Activated:Connect(function()
        restoreFloatingPanel(key)
    end)
    state.tab = tab
    return tab
end

local function dockPanel(key, edge)
    local spec = panelSpecs[key]
    local state = floatingState[key]
    if not spec or not state then return end

    local panel = spec.panel
    local tab = ensureDockTab(key, spec.accent)
    local v = viewportSize()
    local abs = panel.AbsolutePosition
    local tabX, tabY

    if edge == "LEFT" then
        tab.AnchorPoint = Vector2.new(0, .5)
        tab.Size = UDim2.fromOffset(24, FLOAT_TAB_H)
        tab.Text = ">"
        tabX = 0
        tabY = math.clamp(abs.Y + panel.AbsoluteSize.Y/2, 130, v.Y - 150)
        tab.Position = UDim2.fromOffset(tabX, tabY)
    elseif edge == "RIGHT" then
        tab.AnchorPoint = Vector2.new(1, .5)
        tab.Size = UDim2.fromOffset(24, FLOAT_TAB_H)
        tab.Text = "<"
        tabX = v.X
        tabY = math.clamp(abs.Y + panel.AbsoluteSize.Y/2, 130, v.Y - 150)
        tab.Position = UDim2.fromOffset(tabX, tabY)
    else -- TOP
        tab.AnchorPoint = Vector2.new(.5, 0)
        tab.Size = UDim2.fromOffset(78, 24)
        tab.Text = key:sub(1, 5) .. " v"
        tabX = math.clamp(abs.X + panel.AbsoluteSize.X/2, 120, v.X - 120)
        tabY = 0
        tab.Position = UDim2.fromOffset(tabX, tabY)
    end

    panel.Visible = false
    tab.Visible = true
    state.docked = edge
    activeKey = nil
    player:SetAttribute("BBYALastDockEdge", edge)
    player:SetAttribute("BBYAFloatingPanel", key .. "_DOCKED")
end

local function finishPanelDrag(key)
    local spec = panelSpecs[key]
    local state = floatingState[key]
    if not spec or not state then return end
    local panel = spec.panel
    local v = viewportSize()
    local pos = panel.AbsolutePosition
    local size = panel.AbsoluteSize

    local leftDist = pos.X
    local rightDist = v.X - (pos.X + size.X)
    local topDist = pos.Y

    local edge, dist
    if leftDist <= FLOAT_DOCK_THRESHOLD then edge, dist = "LEFT", leftDist end
    if rightDist <= FLOAT_DOCK_THRESHOLD and (not dist or rightDist < dist) then edge, dist = "RIGHT", rightDist end
    if topDist <= FLOAT_DOCK_THRESHOLD and (not dist or topDist < dist) then edge, dist = "TOP", topDist end

    if edge then
        dockPanel(key, edge)
    else
        local x, y = clampPanelXY(panel, pos.X, pos.Y)
        setAbsolutePanelPosition(panel, x, y)
        state.lastX, state.lastY = x, y
        player:SetAttribute("BBYAFloatingPanel", key .. "_FREE")
    end
end

local function makePanelFloating(key, spec)
    local panel = spec.panel
    local state = { dragging = false, dragInput = nil, startPointer = nil, startAbsolute = nil }
    floatingState[key] = state

    local grip = Instance.new("TextButton")
    grip.Name = "FloatingMoveGrip"
    grip.AutoButtonColor = false
    grip.BackgroundColor3 = CARD2
    grip.BackgroundTransparency = .12
    grip.Text = "MOVE"
    grip.TextColor3 = spec.accent
    grip.Font = Enum.Font.GothamBold
    grip.TextSize = 9
    grip.Size = UDim2.fromOffset(58, 20)
    grip.AnchorPoint = Vector2.new(.5, 0)
    grip.Position = UDim2.new(.5, 0, 0, 10)
    grip.ZIndex = 30
    grip.Parent = panel
    corner(grip, 7)
    stroke(grip, spec.accent, .65, 1)

    local function update(input)
        if not state.dragging or not state.startPointer or not state.startAbsolute then return end
        local delta = input.Position - state.startPointer
        local x = state.startAbsolute.X + delta.X
        local y = state.startAbsolute.Y + delta.Y
        local v = viewportSize()
        -- During drag allow a small overshoot toward edges so snapping feels natural.
        x = math.clamp(x, -FLOAT_DOCK_THRESHOLD, v.X - panel.AbsoluteSize.X + FLOAT_DOCK_THRESHOLD)
        y = math.clamp(y, -FLOAT_DOCK_THRESHOLD, v.Y - panel.AbsoluteSize.Y - 18)
        panel.Position = UDim2.fromOffset(x, y)
    end

    grip.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        state.dragging = true
        state.startPointer = input.Position
        state.startAbsolute = panel.AbsolutePosition
        panel.AnchorPoint = Vector2.new(0, 0)
        panel.Position = UDim2.fromOffset(state.startAbsolute.X, state.startAbsolute.Y)

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End and state.dragging then
                state.dragging = false
                finishPanelDrag(key)
            end
        end)
    end)

    grip.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            state.dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if state.dragging and input == state.dragInput then update(input) end
    end)
end

for key,spec in pairs(panelSpecs) do
    makePanelFloating(key, spec)
end

-- If a normal rail button opens a panel, convert its responsive anchored position
-- into a free-floating absolute position once it becomes visible.
for key,spec in pairs(panelSpecs) do
    spec.panel:GetPropertyChangedSignal("Visible"):Connect(function()
        if not spec.panel.Visible then return end
        local state = floatingState[key]
        if state and state.tab then state.tab.Visible = false end
        if state then state.docked = nil end
        task.defer(function()
            if not spec.panel.Visible then return end
            local abs = spec.panel.AbsolutePosition
            setAbsolutePanelPosition(spec.panel, abs.X, abs.Y)
            player:SetAttribute("BBYAFloatingPanel", key)
        end)
    end)
end

-- Keep dock tabs attached to the correct screen edge after rotation/resizing.
local function refreshDockTabs()
    local v = viewportSize()
    for key,state in pairs(floatingState) do
        local tab = state.tab
        if tab and tab.Visible and state.docked then
            if state.docked == "LEFT" then
                tab.Position = UDim2.fromOffset(0, math.clamp(tab.AbsolutePosition.Y + tab.AbsoluteSize.Y/2, 130, v.Y - 150))
            elseif state.docked == "RIGHT" then
                tab.Position = UDim2.fromOffset(v.X, math.clamp(tab.AbsolutePosition.Y + tab.AbsoluteSize.Y/2, 130, v.Y - 150))
            elseif state.docked == "TOP" then
                tab.Position = UDim2.fromOffset(math.clamp(tab.AbsolutePosition.X + tab.AbsoluteSize.X/2, 120, v.X - 120), 0)
            end
        end
    end
end

local floatingCam = workspace.CurrentCamera
if floatingCam then floatingCam:GetPropertyChangedSignal("ViewportSize"):Connect(refreshDockTabs) end

player:SetAttribute("BBYAUIFloatingDock", "1.0")
player:SetAttribute("BBYAUIDockEdges", "LEFT/RIGHT/TOP_ONLY")
print("[BBYA] Floating dock UI 1.0 loaded • drag panels • edge snap • peek tabs • bottom safe")
