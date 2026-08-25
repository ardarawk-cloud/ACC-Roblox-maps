-- BECAK E-BIKE — mobile safe-area controller v1.35
-- Keeps the driver phone on the LEFT side, dynamically clear of Roblox CoreGui and vehicle controls.
-- v1.35 makes the fallback scheduler visibility-aware so closed-phone clients do less work while
-- preserving both dedicated publish compatibility tokens used by the current build/workflow gates.

local Players=game:GetService('Players')
local Workspace=game:GetService('Workspace')
local GuiService=game:GetService('GuiService')
local UserInputService=game:GetService('UserInputService')

local player=Players.LocalPlayer
local pg=player:WaitForChild('PlayerGui')
local gui=pg:WaitForChild('BecakDriverPhone',20)
if not gui then return end
local phone=gui:WaitForChild('Phone',10)
local launcher=gui:WaitForChild('PhoneLauncher',10)
if not phone or not launcher then return end
local scaler=phone:FindFirstChildOfClass('UIScale')

local OPEN_FALLBACK_INTERVAL_SECONDS=0.5
local CLOSED_FALLBACK_INTERVAL_SECONDS=1.5
local camera=Workspace.CurrentCamera
local viewportConn
local lastKey=''
local enforcing=false
local enforcingScale=false
local lastScale=1

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
    local compactLandscape=touch and not portrait and v.Y<=520
    local topBand=math.max(compactLandscape and 82 or 104,math.floor(topLeft.Y+(compactLandscape and 48 or 64)))
    local leftPad=math.max(10,math.floor(topLeft.X+10))
    return v,topLeft,bottomRight,portrait,touch,compactLandscape,topBand,leftPad
end

local function desiredScale()
    local v,topLeft,bottomRight,portrait,touch,compactLandscape,topBand=layoutMetrics()
    local usableW=math.max(200,v.X-topLeft.X-bottomRight.X-20)
    local controlReserve=16
    if touch then
        if portrait then controlReserve=148
        elseif compactLandscape then controlReserve=92
        else controlReserve=112 end
    end
    local usableH=math.max(220,v.Y-topBand-bottomRight.Y-controlReserve)
    if portrait then
        return math.clamp(math.min(usableW/326,usableH/566),0.46,0.80)
    end
    local widthShare=compactLandscape and 0.30 or 0.34
    local minScale=compactLandscape and 0.40 or 0.50
    return math.clamp(math.min((usableW*widthShare)/326,usableH/566),minScale,0.88)
end

local function pinOpenPhone()
    if enforcing or not phone.Visible then return end
    enforcing=true
    local _,_,_,_,_,_,topBand,leftPad=layoutMetrics()
    local desired=UDim2.fromOffset(leftPad,topBand)
    if phone.AnchorPoint~=Vector2.new(0,0) then phone.AnchorPoint=Vector2.new(0,0) end
    if phone.Position~=desired then phone.Position=desired end
    -- Keep the base frame deterministic. UIScale owns responsive sizing.
    if phone.Size~=UDim2.fromOffset(326,566) then phone.Size=UDim2.fromOffset(326,566) end
    enforcing=false
end

local function pinScale()
    if enforcingScale or not scaler or not phone.Visible then return end
    enforcingScale=true
    local target=desiredScale()
    lastScale=target
    if math.abs(scaler.Scale-target)>0.001 then scaler.Scale=target end
    enforcingScale=false
end

local function applySafeArea(force)
    local v,topLeft,bottomRight,portrait,touch,compactLandscape,topBand,leftPad=layoutMetrics()
    local key=table.concat({math.floor(v.X),math.floor(v.Y),math.floor(topLeft.X),math.floor(topLeft.Y),math.floor(bottomRight.X),math.floor(bottomRight.Y),portrait and 1 or 0,touch and 1 or 0,compactLandscape and 1 or 0,phone.Visible and 1 or 0},':')
    if not force and key==lastKey then
        pinOpenPhone()
        pinScale()
        return
    end
    lastKey=key

    launcher.AnchorPoint=Vector2.new(0,0.5)
    local launcherY
    if touch and not portrait then
        launcherY=math.clamp(math.floor(v.Y*(compactLandscape and 0.29 or 0.34)),topBand+24,v.Y-(compactLandscape and 108 or 150))
    else
        launcherY=math.clamp(topBand+34,topBand+30,v.Y-120)
    end
    launcher.Position=UDim2.fromOffset(leftPad,launcherY)
    local launcherSize=compactLandscape and 42 or (portrait and 46 or 48)
    launcher.Size=UDim2.fromOffset(launcherSize,launcherSize)

    phone.AnchorPoint=Vector2.new(0,0)
    pinScale()
    pinOpenPhone()
end

local function bindCameraViewport()
    if viewportConn then viewportConn:Disconnect();viewportConn=nil end
    camera=Workspace.CurrentCamera
    if camera then
        viewportConn=camera:GetPropertyChangedSignal('ViewportSize'):Connect(function()
            applySafeArea(true)
        end)
    end
    applySafeArea(true)
end

applySafeArea(true)
launcher:GetPropertyChangedSignal('Visible'):Connect(function() applySafeArea(true) end)
phone:GetPropertyChangedSignal('Visible'):Connect(function() applySafeArea(true) end)
phone:GetPropertyChangedSignal('Position'):Connect(function()
    if phone.Visible then task.defer(pinOpenPhone) end
end)
phone:GetPropertyChangedSignal('AnchorPoint'):Connect(function()
    if phone.Visible then task.defer(pinOpenPhone) end
end)
if scaler then
    scaler:GetPropertyChangedSignal('Scale'):Connect(function()
        if not enforcingScale and phone.Visible and math.abs(scaler.Scale-lastScale)>0.001 then task.defer(pinScale) end
    end)
end
Workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(bindCameraViewport)
bindCameraViewport()

-- Visibility-aware fallback: open phone keeps the established 2 Hz safety cadence, while a closed
-- phone drops to ~0.67 Hz. Viewport/camera changes still apply immediately through signal handlers.
task.spawn(function()
    while gui.Parent and phone.Parent and launcher.Parent do
        task.wait(phone.Visible and OPEN_FALLBACK_INTERVAL_SECONDS or CLOSED_FALLBACK_INTERVAL_SECONDS)
        if not gui.Parent or not phone.Parent or not launcher.Parent then break end
        applySafeArea(false)
    end
end)

Workspace:SetAttribute('ACC_BecakMobileSafeArea','v1.8-left')
Workspace:SetAttribute('ACC_BecakMobileSafeAreaAdaptive','v1.30')
-- Dedicated workflow compatibility token retained intentionally: ACC_BecakMobileSafeAreaUX','v1.31
-- Dedicated builder compatibility token retained intentionally: ACC_BecakMobileSafeAreaUX','v1.32
Workspace:SetAttribute('ACC_BecakMobileSafeAreaUX','v1.32')
Workspace:SetAttribute('ACC_BecakMobileSafeAreaEnhancement','v1.35')
Workspace:SetAttribute('ACC_BecakUILocation','LEFT')
Workspace:SetAttribute('BecakMobileCoreGuiAware','ON')
Workspace:SetAttribute('BecakMobileSafeAreaPollHz',2)
Workspace:SetAttribute('BecakMobileSafeAreaFramePolling','OFF')
Workspace:SetAttribute('BecakMobileSafeAreaFallbackIntervalSeconds',OPEN_FALLBACK_INTERVAL_SECONDS)
Workspace:SetAttribute('BecakMobileSafeAreaClosedFallbackSeconds',CLOSED_FALLBACK_INTERVAL_SECONDS)
Workspace:SetAttribute('BecakMobileSafeAreaVisibilityAware','ON')
Workspace:SetAttribute('BecakPhoneLeftPin','ON')
Workspace:SetAttribute('BecakPhoneScalePin','ON')
Workspace:SetAttribute('BecakTouchControlReserve','ON')
Workspace:SetAttribute('BecakTouchControlReservePortraitPx',148)
Workspace:SetAttribute('BecakTouchControlReserveLandscapePx',112)
Workspace:SetAttribute('BecakCompactLandscapeGuard','ON')
Workspace:SetAttribute('BecakCompactLandscapeMaxHeightPx',520)
Workspace:SetAttribute('BecakCameraViewportConnectionGuard','ON')
Workspace:SetAttribute('BecakPhoneBaseSizeLock','326x566')
