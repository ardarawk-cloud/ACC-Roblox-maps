-- BECAK E-BIKE — mobile safe-area controller v1.28
-- Keeps the driver phone on the LEFT side, dynamically clear of Roblox CoreGui and vehicle controls.

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

local function readInset()
    local ok,topLeft,bottomRight=pcall(function()
        return GuiService:GetGuiInset()
    end)
    if ok and typeof(topLeft)=='Vector2' and typeof(bottomRight)=='Vector2' then
        return topLeft,bottomRight
    end
    return Vector2.zero,Vector2.zero
end

local function applySafeArea(force)
    camera=Workspace.CurrentCamera or camera
    local v=camera and camera.ViewportSize or Vector2.new(800,600)
    local topLeft,bottomRight=readInset()
    local portrait=v.Y>v.X
    local touch=UserInputService.TouchEnabled
    local topBand=math.max(104,math.floor(topLeft.Y+64))
    local leftPad=math.max(12,math.floor(topLeft.X+12))

    local key=table.concat({math.floor(v.X),math.floor(v.Y),math.floor(topLeft.X),math.floor(topLeft.Y),portrait and 1 or 0,touch and 1 or 0,phone.Visible and 1 or 0},':')
    if not force and key==lastKey then return end
    lastKey=key

    -- Closed launcher stays on the left edge, below CoreGui. On touch landscape it sits
    -- around the upper-middle left so it cannot overlap the Roblox menu/chat/mic cluster.
    launcher.AnchorPoint=Vector2.new(0,0.5)
    local launcherY
    if touch and not portrait then
        launcherY=math.clamp(math.floor(v.Y*0.36),topBand+30,v.Y-120)
    else
        launcherY=math.clamp(topBand+34,topBand+30,v.Y-100)
    end
    launcher.Position=UDim2.fromOffset(leftPad,launcherY)
    local launcherSize=portrait and 48 or 50
    launcher.Size=UDim2.fromOffset(launcherSize,launcherSize)

    -- Open phone remains left-aligned and scales to the actual usable viewport.
    phone.AnchorPoint=Vector2.new(0,0)
    local usableW=math.max(220,v.X-topLeft.X-bottomRight.X-24)
    local usableH=math.max(300,v.Y-topBand-bottomRight.Y-18)
    if scaler then
        if portrait then
            scaler.Scale=math.clamp(math.min(usableW/326,usableH/566),0.58,0.80)
        else
            -- Keep the phone within the left third so steering/throttle controls remain clear.
            scaler.Scale=math.clamp(math.min((usableW*0.34)/326,usableH/566),0.62,0.88)
        end
    end
    if phone.Visible then
        phone.Position=UDim2.fromOffset(leftPad,topBand)
    end
end

applySafeArea(true)
launcher:GetPropertyChangedSignal('Visible'):Connect(function() applySafeArea(true) end)
phone:GetPropertyChangedSignal('Visible'):Connect(function() applySafeArea(true) end)
if camera then camera:GetPropertyChangedSignal('ViewportSize'):Connect(function() applySafeArea(true) end) end
Workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
    camera=Workspace.CurrentCamera
    if camera then camera:GetPropertyChangedSignal('ViewportSize'):Connect(function() applySafeArea(true) end) end
    applySafeArea(true)
end)

-- Low-frequency inset recheck handles mobile orientation/CoreGui changes without a 25 Hz layout loop.
local acc=0
RunService.RenderStepped:Connect(function(dt)
    acc += dt
    if acc < 0.25 then return end
    acc=0
    applySafeArea(false)
end)

Workspace:SetAttribute('ACC_BecakMobileSafeArea','v1.28-adaptive-left')
Workspace:SetAttribute('ACC_BecakUILocation','LEFT')
Workspace:SetAttribute('BecakMobileCoreGuiAware','ON')
Workspace:SetAttribute('BecakMobileSafeAreaPollHz',4)
