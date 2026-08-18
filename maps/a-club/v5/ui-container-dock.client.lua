-- BBYA SOCIAL HUB — V5 CONTAINER DOCK v1.0
-- The three launcher containers themselves can be tucked away.
-- TOP hides upward, LEFT hides left, RIGHT hides right.
-- Each leaves only a small edge tab so the UI can be restored with one tap.
-- Bottom docking is forbidden to protect Roblox joystick/jump controls.

local CONTAINER_PEEK = 18
local SWIPE_TRIGGER = 28
local handleRoot = Instance.new("Frame")
handleRoot.Name = "BBYAContainerDockHandles"
handleRoot.BackgroundTransparency = 1
handleRoot.Size = UDim2.fromScale(1,1)
handleRoot.ZIndex = 120
handleRoot.Parent = gui

local dockState = {
    TOP = {object=topBar, edge="TOP", hidden=false},
    LEFT = {object=leftRail, edge="LEFT", hidden=false},
    RIGHT = {object=rightRail, edge="RIGHT", hidden=false},
}

local function makeHandle(name, textValue, accent)
    local b = button(handleRoot, textValue, accent)
    b.Name = name
    b.ZIndex = 125
    b.TextSize = 10
    return b
end

local topHandle = makeHandle("TopDockHandle", "MOVE", PINK)
local leftHandle = makeHandle("LeftDockHandle", "<", PINK)
local rightHandle = makeHandle("RightDockHandle", ">", CYAN)

local topPeek = makeHandle("TopPeekTab", "v", PINK)
local leftPeek = makeHandle("LeftPeekTab", ">", PINK)
local rightPeek = makeHandle("RightPeekTab", "<", CYAN)
for _,b in ipairs({topPeek,leftPeek,rightPeek}) do b.Visible=false end

local function viewport()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(800,600)
end

local function syncHandles()
    local v = viewport()

    if topBar.Visible then
        local ap,as = topBar.AbsolutePosition,topBar.AbsoluteSize
        topHandle.Size = UDim2.fromOffset(64,18)
        topHandle.Position = UDim2.fromOffset(ap.X + as.X/2 - 32, ap.Y + as.Y - 9)
        topHandle.Visible = true
    else topHandle.Visible=false end

    if leftRail.Visible then
        local ap,as = leftRail.AbsolutePosition,leftRail.AbsoluteSize
        leftHandle.Size = UDim2.fromOffset(18,54)
        leftHandle.Position = UDim2.fromOffset(ap.X + as.X - 9, ap.Y + as.Y/2 - 27)
        leftHandle.Visible = true
    else leftHandle.Visible=false end

    if rightRail.Visible then
        local ap,as = rightRail.AbsolutePosition,rightRail.AbsoluteSize
        rightHandle.Size = UDim2.fromOffset(18,54)
        rightHandle.Position = UDim2.fromOffset(ap.X - 9, ap.Y + as.Y/2 - 27)
        rightHandle.Visible = true
    else rightHandle.Visible=false end

    if dockState.TOP.hidden then
        topPeek.Size = UDim2.fromOffset(76,CONTAINER_PEEK)
        topPeek.AnchorPoint = Vector2.new(.5,0)
        topPeek.Position = UDim2.fromOffset(math.clamp(v.X*.58,90,v.X-90),0)
    end
    if dockState.LEFT.hidden then
        leftPeek.Size = UDim2.fromOffset(CONTAINER_PEEK,66)
        leftPeek.AnchorPoint = Vector2.new(0,.5)
        leftPeek.Position = UDim2.fromOffset(0,math.clamp(v.Y*.46,110,v.Y-150))
    end
    if dockState.RIGHT.hidden then
        rightPeek.Size = UDim2.fromOffset(CONTAINER_PEEK,66)
        rightPeek.AnchorPoint = Vector2.new(1,.5)
        rightPeek.Position = UDim2.fromOffset(v.X,math.clamp(v.Y*.46,110,v.Y-150))
    end
end

local function collapse(which)
    local s = dockState[which]
    if not s or s.hidden then return end
    s.hidden=true
    s.object.Visible=false
    if which=="TOP" then
        topDrawer.Visible=false
        topDrawerOpen=false
        topPeek.Visible=true
    elseif which=="LEFT" then
        leftPeek.Visible=true
    elseif which=="RIGHT" then
        rightPeek.Visible=true
    end
    player:SetAttribute("BBYAHiddenContainer",which)
    syncHandles()
end

local function restore(which)
    local s = dockState[which]
    if not s then return end
    s.hidden=false
    s.object.Visible=true
    if which=="TOP" then topPeek.Visible=false end
    if which=="LEFT" then leftPeek.Visible=false end
    if which=="RIGHT" then rightPeek.Visible=false end
    player:SetAttribute("BBYAHiddenContainer","")
    task.defer(syncHandles)
end

topPeek.Activated:Connect(function() restore("TOP") end)
leftPeek.Activated:Connect(function() restore("LEFT") end)
rightPeek.Activated:Connect(function() restore("RIGHT") end)

local function bindSwipe(handle, which)
    local active=false
    local startPointer
    local startPos
    local obj=dockState[which].object

    handle.Activated:Connect(function()
        -- Quick tap also hides the container; dragging gives the sliding gesture.
        if not active then collapse(which) end
    end)

    handle.InputBegan:Connect(function(input)
        if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        active=true
        startPointer=input.Position
        startPos=obj.Position
        input.Changed:Connect(function()
            if input.UserInputState~=Enum.UserInputState.End or not active then return end
            local delta=input.Position-startPointer
            active=false
            local shouldHide = (which=="LEFT" and delta.X < -SWIPE_TRIGGER)
                or (which=="RIGHT" and delta.X > SWIPE_TRIGGER)
                or (which=="TOP" and delta.Y < -SWIPE_TRIGGER)
            if shouldHide then
                collapse(which)
            else
                obj.Position=startPos
                syncHandles()
            end
        end)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not active then return end
        if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local delta=input.Position-startPointer
        if which=="LEFT" then
            local off=math.clamp(startPos.X.Offset+delta.X,-obj.AbsoluteSize.X+CONTAINER_PEEK,startPos.X.Offset)
            obj.Position=UDim2.new(startPos.X.Scale,off,startPos.Y.Scale,startPos.Y.Offset)
        elseif which=="RIGHT" then
            local off=math.clamp(startPos.X.Offset+delta.X,startPos.X.Offset,obj.AbsoluteSize.X-CONTAINER_PEEK)
            obj.Position=UDim2.new(startPos.X.Scale,off,startPos.Y.Scale,startPos.Y.Offset)
        else
            local off=math.clamp(startPos.Y.Offset+delta.Y,-obj.AbsoluteSize.Y+CONTAINER_PEEK,startPos.Y.Offset)
            obj.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset,startPos.Y.Scale,off)
        end
        syncHandles()
    end)
end

bindSwipe(topHandle,"TOP")
bindSwipe(leftHandle,"LEFT")
bindSwipe(rightHandle,"RIGHT")

-- If responsive layout recalculates positions, restore the dock handles afterward.
local cam=workspace.CurrentCamera
if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(function() task.defer(syncHandles) end) end
for _,obj in ipairs({topBar,leftRail,rightRail}) do
    obj:GetPropertyChangedSignal("Position"):Connect(syncHandles)
    obj:GetPropertyChangedSignal("Size"):Connect(syncHandles)
end

RunService.RenderStepped:Connect(function()
    -- Three lightweight overlays only; keeps handles glued to launcher containers during touch drag.
    if topBar.Visible or leftRail.Visible or rightRail.Visible then syncHandles() end
end)

player:SetAttribute("BBYAUIContainerDock","1.0")
player:SetAttribute("BBYAUIContainerDockRule","TOP_UP/LEFT_LEFT/RIGHT_RIGHT/PEEK_ONLY")
print("[BBYA] Container dock 1.0 loaded • top/left/right launcher shells can tuck into screen edges")
