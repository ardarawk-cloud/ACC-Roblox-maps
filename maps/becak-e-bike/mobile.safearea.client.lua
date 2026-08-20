-- BECAK E-BIKE — mobile safe-area controller v1.6
-- Keeps the driver phone away from Roblox touch controls on portrait/landscape screens.

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

    -- Launcher sits high on the right edge, clear of left thumbstick and right jump/vehicle controls.
    launcher.AnchorPoint=Vector2.new(1,0)
    launcher.Position=portrait and UDim2.new(1,-14,0,104) or UDim2.new(1,-18,0,92)
    launcher.Size=UDim2.fromOffset(portrait and 48 or 50,portrait and 48 or 50)

    -- Phone opens in the upper-right quadrant instead of occupying the bottom control zone.
    phone.AnchorPoint=Vector2.new(1,0)
    if scaler then
        if portrait then
            scaler.Scale=math.clamp(math.min((v.X-18)/326,(v.Y-190)/566),0.62,0.78)
        else
            scaler.Scale=math.clamp(math.min((v.X*0.34)/326,(v.Y-150)/566),0.68,0.90)
        end
    end
    if phone.Visible then
        phone.Position=portrait and UDim2.new(1,-12,0,72) or UDim2.new(1,-18,0,64)
    end
end

applySafeArea()
if camera then camera:GetPropertyChangedSignal('ViewportSize'):Connect(applySafeArea) end
Workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
    camera=Workspace.CurrentCamera
    if camera then camera:GetPropertyChangedSignal('ViewportSize'):Connect(applySafeArea) end
    applySafeArea()
end)

-- The base UI has an open/close tween with bottom anchoring. Re-apply only while visible,
-- at low frequency, so the phone never drifts back over touch controls.
local acc=0
RunService.RenderStepped:Connect(function(dt)
    acc += dt
    if acc < 0.08 then return end
    acc=0
    applySafeArea()
end)

Workspace:SetAttribute('ACC_BecakMobileSafeArea','v1.6')
