-- BECAK E-BIKE — mobile safe-area controller v1.31
-- Keeps the driver phone on the LEFT side, dynamically clear of Roblox CoreGui and vehicle controls.
-- v1.31 also reserves the lower touch-control zone so the open phone cannot cover the movement thumbstick.

local Players=game:GetService('Players')
local Workspace=game:GetService('Workspace')
local GuiService=game:GetService('GuiService')
local UserInputService=game:GetService('UserInputService')
local RunService=game:GetService('RunService')

local player=Players.LocalPlayer
local pg=player:WaitForChild('PlayerGui')
local gui=pg:WaitForChild('BecakDriverPhone',20)
if not gui then return end
local phone=gui:WaitForChild('Phone',10)
local launcher=gui:WaitForChild('PhoneLauncher',10)
if not phone or not launcher then return end
local scaler=phone:FindFirstChildOfClass('UIScale')

local camera=Workspace.CurrentCamera
local lastKey=''
local enforcing=false
local enforcingScale=false

local function readInset()
    local ok,topLeft,bottomRight=pcall(function()
        return GuiService:GetGuiInset()
    end)
    if ok and typeof(topLeft)=='Vector2' and typeof(bottomRight)=='Vector2' then
        return topLeft,bottomRight
    end
    return Vector2.zero,Vector2.zero
end

local function layoutMetrics()
    camera=Workspace.CurrentCamera or camera
    local v=camera and camera.ViewportSize or Vector2.new(800,600)
    local topLeft,bottomRight=readInset()
    local portrait=v.Y>v.X
    local touch=UserInputService.TouchEnabled
    local topBand=math.max(104,math.floor(topLeft.Y+64))
    local leftPad=math.max(12,math.floor(topLeft.X+12))
    return v,topLeft,bottomRight,portrait,touch,topBand,leftPad
end

local function desiredScale()
    local v,topLeft,bottomRight,portrait,touch,topBand=layoutMetrics()
    local usableW=math.max(220,v.X-topLeft.X-bottomRight.X-24)
    -- Reserve the lower-left thumb-control zone on touch devices. This keeps the phone readable
    -- without covering DynamicThumbstick/vehicle movement controls on narrow landscape screens.
    local controlReserve=18
    if touch then controlReserve=portrait and 148 or 112 end
    local usableH=math.max(260,v.Y-topBand-bottomRight.Y-controlReserve)
    if portrait then
        return math.clamp(math.min(usableW/326,usableH/566),0.52,0.80)
    end
    -- Keep the phone within the left third so steering/throttle controls remain clear.
    return math.clamp(math.min((usableW*0.34)/326,usableH/566),0.54,0.88)
end

local function pinOpenPhone()
    if enforcing or not phone.Visible then return end
    enforcing=true
    local _,_,_,_,_,topBand,leftPad=layoutMetrics()
    local desired=UDim2.fromOffset(leftPad,topBand)
    if phone.AnchorPoint~=Vector2.new(0,0) then phone.AnchorPoint=Vector2.new(0,0) end
    if phone.Position~=desired then phone.Position=desired end
    enforcing=false
end

local function pinScale()
    if enforcingScale or not scaler then return end
    enforcingScale=true
    local target=desiredScale()
    if math.abs(scaler.Scale-target)>0.001 then scaler.Scale=target end
    enforcingScale=false
end

local function applySafeArea(force)
    local v,topLeft,bottomRight,portrait,touch,topBand,leftPad=layoutMetrics()

    local key=table.concat({math.floor(v.X),math.floor(v.Y),math.floor(topLeft.X),math.floor(topLeft.Y),portrait and 1 or 0,touch and 1 or 0,phone.Visible and 1 or 0},':')
    if not force and key==lastKey then
        -- Re-assert final ownership even when dimensions did not change.
        pinOpenPhone()
        pinScale()
        return
    end
    lastKey=key

    -- Closed launcher stays on the left edge, below CoreGui. On touch landscape it sits
    -- around the upper-middle left so it cannot overlap the Roblox menu/chat/mic cluster
    -- or the lower-left movement thumbstick.
    launcher.AnchorPoint=Vector2.new(0,0.5)
    local launcherY
    if touch and not portrait then
        launcherY=math.clamp(math.floor(v.Y*0.34),topBand+30,v.Y-150)
    else
        launcherY=math.clamp(topBand+34,topBand+30,v.Y-120)
    end
    launcher.Position=UDim2.fromOffset(leftPad,launcherY)
    local launcherSize=portrait and 46 or 48
    launcher.Size=UDim2.fromOffset(launcherSize,launcherSize)

    -- Open phone remains left-aligned and scales to the actual usable viewport.
    phone.AnchorPoint=Vector2.new(0,0)
    pinScale()
    pinOpenPhone()
end

applySafeArea(true)
launcher:GetPropertyChangedSignal('Visible'):Connect(function() applySafeArea(true) end)
phone:GetPropertyChangedSignal('Visible'):Connect(function() applySafeArea(true) end)
phone:GetPropertyChangedSignal('Position'):Connect(function()
    -- Legacy phone UI can still animate toward the right edge. Reclaim the left-safe-area immediately.
    if phone.Visible then task.defer(pinOpenPhone) end
end)
if scaler then
    scaler:GetPropertyChangedSignal('Scale'):Connect(function()
        -- Legacy phone UI also has its own viewport scaler. Reclaim the safe mobile scale immediately.
        task.defer(pinScale)
    end)
end
if camera then camera:GetPropertyChangedSignal('ViewportSize'):Connect(function() applySafeArea(true) end) end
Workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
    camera=Workspace.CurrentCamera
    if camera then camera:GetPropertyChangedSignal('ViewportSize'):Connect(function() applySafeArea(true) end) end
    applySafeArea(true)
end)

-- Low-frequency inset recheck handles mobile orientation/CoreGui changes without a busy layout loop.
local acc=0
RunService.RenderStepped:Connect(function(dt)
    acc += dt
    if acc < 0.25 then return end
    acc=0
    applySafeArea(false)
end)

-- Keep established compatibility markers while exposing the current adaptive implementation separately.
Workspace:SetAttribute('ACC_BecakMobileSafeArea','v1.8-left')
Workspace:SetAttribute('ACC_BecakMobileSafeAreaAdaptive','v1.30')
Workspace:SetAttribute('ACC_BecakMobileSafeAreaUX','v1.31')
Workspace:SetAttribute('ACC_BecakUILocation','LEFT')
Workspace:SetAttribute('BecakMobileCoreGuiAware','ON')
Workspace:SetAttribute('BecakMobileSafeAreaPollHz',4)
Workspace:SetAttribute('BecakPhoneLeftPin','ON')
Workspace:SetAttribute('BecakPhoneScalePin','ON')
Workspace:SetAttribute('BecakTouchControlReserve','ON')
Workspace:SetAttribute('BecakTouchControlReservePortraitPx',148)
Workspace:SetAttribute('BecakTouchControlReserveLandscapePx',112)
