-- BBYA SOCIAL HUB — V5 FLOATING / EDGE-PEEK UI v1.1
-- Open panels are draggable floating windows.
-- IMPORTANT UX RULE:
--   Dragging to an edge NEVER hides/destroys the window.
--   A deliberately parked window remains alive mostly off-screen and leaves a visible pull-tab/sliver.
--   Simply touching a screen edge does NOT auto-dock.
-- Bottom parking is intentionally disabled to protect Roblox movement/jump controls.

local FLOAT_EDGE_GAP = 8
local FLOAT_BOTTOM_SAFE = 118
local FLOAT_PEEK = 32
local FLOAT_TAB_W = 30
local FLOAT_TAB_H = 72
local FLOAT_PARK_ARM = 96 -- user must push until <=96 px of the panel remains visible
local FLOAT_TOP_ARM = 72

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

local function clampFreePanelXY(panel, x, y)
    local v = viewportSize()
    local w, h = panel.AbsoluteSize.X, panel.AbsoluteSize.Y
    local maxX = math.max(FLOAT_EDGE_GAP, v.X - w - FLOAT_EDGE_GAP)
    local maxY = math.max(74, v.Y - h - FLOAT_BOTTOM_SAFE)
    return math.clamp(x, FLOAT_EDGE_GAP, maxX), math.clamp(y, 74, maxY)
end

local function setAbsolutePanelPosition(panel, x, y, allowParked)
    panel.AnchorPoint = Vector2.new(0, 0)
    if allowParked then
        panel.Position = UDim2.fromOffset(x, y)
    else
        local cx, cy = clampFreePanelXY(panel, x, y)
        panel.Position = UDim2.fromOffset(cx, cy)
    end
end

local function hideDockTab(state)
    if state and state.tab then state.tab.Visible = false end
end

local function restoreFloatingPanel(key)
    local spec = panelSpecs[key]
    local state = floatingState[key]
    if not spec or not state then return end

    for otherKey,otherSpec in pairs(panelSpecs) do
        if otherKey ~= key then
            otherSpec.panel.Visible = false
            local os = floatingState[otherKey]
            hideDockTab(os)
            if os then os.docked = nil end
        end
    end
    topDrawer.Visible = false
    activeKey = key

    hideDockTab(state)
    state.docked = nil
    spec.panel.Visible = true

    local v = viewportSize()
    local p = spec.panel
    local w, h = p.AbsoluteSize.X, p.AbsoluteSize.Y
    local x
    if state.lastX then
        x = state.lastX
    elseif spec.origin == "RIGHT" then
        x = v.X - w - 100
    else
        x = 100
    end
    local y = state.lastY or math.max(82, (v.Y - h) * .48)
    setAbsolutePanelPosition(p, x, y, false)
    player:SetAttribute("BBYAFloatingPanel", key .. "_FREE")
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

-- Park the actual panel outside the viewport. It remains Visible=true.
-- The small tab is only a pull handle; it is NOT a replacement for the panel.
local function parkPanel(key, edge)
    local spec = panelSpecs[key]
    local state = floatingState[key]
    if not spec or not state then return end

    local panel = spec.panel
    local tab = ensureDockTab(key, spec.accent)
    local v = viewportSize()
    local abs = panel.AbsolutePosition
    local w, h = panel.AbsoluteSize.X, panel.AbsoluteSize.Y
    local x, y = abs.X, abs.Y

    if edge == "LEFT" then
        x = -w + FLOAT_PEEK
        y = math.clamp(abs.Y, 74, math.max(74, v.Y - h - FLOAT_BOTTOM_SAFE))
        tab.AnchorPoint = Vector2.new(0, .5)
        tab.Size = UDim2.fromOffset(FLOAT_TAB_W, FLOAT_TAB_H)
        tab.Text = ">"
        tab.Position = UDim2.fromOffset(0, math.clamp(y + h/2, 130, v.Y - 150))
    elseif edge == "RIGHT" then
        x = v.X - FLOAT_PEEK
        y = math.clamp(abs.Y, 74, math.max(74, v.Y - h - FLOAT_BOTTOM_SAFE))
        tab.AnchorPoint = Vector2.new(1, .5)
        tab.Size = UDim2.fromOffset(FLOAT_TAB_W, FLOAT_TAB_H)
        tab.Text = "<"
        tab.Position = UDim2.fromOffset(v.X, math.clamp(y + h/2, 130, v.Y - 150))
    else -- TOP
        x = math.clamp(abs.X, FLOAT_EDGE_GAP, math.max(FLOAT_EDGE_GAP, v.X - w - FLOAT_EDGE_GAP))
        y = -h + FLOAT_PEEK
        tab.AnchorPoint = Vector2.new(.5, 0)
        tab.Size = UDim2.fromOffset(82, FLOAT_TAB_W)
        tab.Text = key:sub(1, 5) .. " v"
        tab.Position = UDim2.fromOffset(math.clamp(x + w/2, 120, v.X - 120), 0)
    end

    panel.Visible = true
    panel.ZIndex = 20
    setAbsolutePanelPosition(panel, x, y, true)
    tab.Visible = true
    state.docked = edge
    activeKey = key
    player:SetAttribute("BBYALastDockEdge", edge)
    player:SetAttribute("BBYAFloatingPanel", key .. "_PEEK_" .. edge)
end

local function finishPanelDrag(key)
    local spec = panelSpecs[key]
    local state = floatingState[key]
    if not spec or not state then return end
    local panel = spec.panel
    local v = viewportSize()
    local pos = panel.AbsolutePosition
    local size = panel.AbsoluteSize

    -- Deliberate park detection. Merely touching an edge is NOT enough.
    local visibleFromLeft = pos.X + size.X
    local visibleFromRight = v.X - pos.X
    local visibleFromTop = pos.Y + size.Y

    local edge
    if pos.X < 0 and visibleFromLeft <= FLOAT_PARK_ARM then
        edge = "LEFT"
    elseif pos.X + size.X > v.X and visibleFromRight <= FLOAT_PARK_ARM then
        edge = "RIGHT"
    elseif pos.Y < 0 and visibleFromTop <= FLOAT_TOP_ARM then
        edge = "TOP"
    end

    if edge then
        parkPanel(key, edge)
    else
        hideDockTab(state)
        state.docked = nil
        local x, y = clampFreePanelXY(panel, pos.X, pos.Y)
        setAbsolutePanelPosition(panel, x, y, false)
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
        local w, h = panel.AbsoluteSize.X, panel.AbsoluteSize.Y

        -- Allow intentional off-screen parking while guaranteeing a recoverable sliver.
        x = math.clamp(x, -w + FLOAT_PEEK, v.X - FLOAT_PEEK)
        y = math.clamp(y, -h + FLOAT_PEEK, v.Y - panel.AbsoluteSize.Y - 18)
        panel.Position = UDim2.fromOffset(x, y)
    end

    grip.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        state.dragging = true
        hideDockTab(state)
        state.docked = nil
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
        local state = floatingState[key]
        if not spec.panel.Visible then
            hideDockTab(state)
            if state then state.docked = nil end
            return
        end
        hideDockTab(state)
        if state then state.docked = nil end
        task.defer(function()
            if not spec.panel.Visible then return end
            local abs = spec.panel.AbsolutePosition
            setAbsolutePanelPosition(spec.panel, abs.X, abs.Y, false)
            player:SetAttribute("BBYAFloatingPanel", key .. "_FREE")
        end)
    end)
end

-- Keep parked windows and pull-tabs recoverable after rotation/resizing.
local function refreshDockTabs()
    local v = viewportSize()
    for key,state in pairs(floatingState) do
        local tab = state.tab
        local spec = panelSpecs[key]
        if tab and tab.Visible and state.docked and spec and spec.panel.Visible then
            local p = spec.panel
            local w,h = p.AbsoluteSize.X,p.AbsoluteSize.Y
            if state.docked == "LEFT" then
                setAbsolutePanelPosition(p,-w+FLOAT_PEEK,math.clamp(p.AbsolutePosition.Y,74,math.max(74,v.Y-h-FLOAT_BOTTOM_SAFE)),true)
                tab.Position = UDim2.fromOffset(0, math.clamp(p.AbsolutePosition.Y + h/2, 130, v.Y - 150))
            elseif state.docked == "RIGHT" then
                setAbsolutePanelPosition(p,v.X-FLOAT_PEEK,math.clamp(p.AbsolutePosition.Y,74,math.max(74,v.Y-h-FLOAT_BOTTOM_SAFE)),true)
                tab.Position = UDim2.fromOffset(v.X, math.clamp(p.AbsolutePosition.Y + h/2, 130, v.Y - 150))
            elseif state.docked == "TOP" then
                setAbsolutePanelPosition(p,math.clamp(p.AbsolutePosition.X,FLOAT_EDGE_GAP,math.max(FLOAT_EDGE_GAP,v.X-w-FLOAT_EDGE_GAP)),-h+FLOAT_PEEK,true)
                tab.Position = UDim2.fromOffset(math.clamp(p.AbsolutePosition.X + w/2,120,v.X-120),0)
            end
        end
    end
end

local floatingCam = workspace.CurrentCamera
if floatingCam then floatingCam:GetPropertyChangedSignal("ViewportSize"):Connect(refreshDockTabs) end

player:SetAttribute("BBYAUIFloatingDock", "1.1")
player:SetAttribute("BBYAUIDockEdges", "LEFT/RIGHT/TOP_PEEK_WINDOW")
player:SetAttribute("BBYAUIEdgeDisappearGuard", "PASS")
print("[BBYA] Floating dock UI 1.1 loaded • windows never disappear • deliberate edge parking • 32px recoverable peek")
