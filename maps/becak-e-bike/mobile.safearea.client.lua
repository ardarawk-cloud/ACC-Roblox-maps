-- BECAK E-BIKE — mobile safe-area controller v1.8
-- Keeps the driver phone on the LEFT side as requested, below Roblox top controls and clear of vehicle controls.

local Players=game:GetService('Players')
local Workspace=game:GetService('Workspace')
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
local function applySafeArea()
    camera=Workspace.CurrentCamera or camera
    local v=camera and camera.ViewportSize or Vector2.new(800,600)
    local portrait=v.Y>v.X

    -- User preference: launcher on the left, but below Roblox top-left menu/chat/mic controls.
    launcher.AnchorPoint=Vector2.new(0,0)
    launcher.Position=portrait and UDim2.new(0,16,0,118) or UDim2.new(0,18,0,112)
    launcher.Size=UDim2.fromOffset(portrait and 48 or 50,portrait and 48 or 50)

    -- Phone opens on the left side. Leave a top safety band for Roblox CoreGui.
    phone.AnchorPoint=Vector2.new(0,0)
    if scaler then
        if portrait then
            scaler.Scale=math.clamp(math.min((v.X-24)/326,(v.Y-210)/566),0.60,0.78)
        else
            scaler.Scale=math.clamp(math.min((v.X*0.34)/326,(v.Y-168)/566),0.66,0.88)
        end
    end
    if phone.Visible then
        phone.Position=portrait and UDim2.new(0,12,0,106) or UDim2.new(0,16,0,104)
    end
end

applySafeArea()
launcher:GetPropertyChangedSignal('Visible'):Connect(applySafeArea)
phone:GetPropertyChangedSignal('Visible'):Connect(applySafeArea)
if camera then camera:GetPropertyChangedSignal('ViewportSize'):Connect(applySafeArea) end
Workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
    camera=Workspace.CurrentCamera
    if camera then camera:GetPropertyChangedSignal('ViewportSize'):Connect(applySafeArea) end
    applySafeArea()
end)

-- Base phone UI still owns its open/close tween. Re-assert the safe position while visible
-- so it cannot drift to the right or into mobile steering/jump controls.
local acc=0
RunService.RenderStepped:Connect(function(dt)
    acc += dt
    if acc < 0.04 then return end
    acc=0
    applySafeArea()
end)

Workspace:SetAttribute('ACC_BecakMobileSafeArea','v1.8-left')
Workspace:SetAttribute('ACC_BecakUILocation','LEFT')
