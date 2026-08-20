local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local root = Workspace:WaitForChild("ACC_TRACK01",20)
if not root then return end

local lights = root:WaitForChild("DynamicLights",10)
if lights then
    local pulseLights={}
    for _,obj in ipairs(lights:GetDescendants()) do
        if obj:IsA("PointLight") or obj:IsA("SpotLight") then
            table.insert(pulseLights,obj)
        end
    end
    local phase = 0
    RunService.RenderStepped:Connect(function(dt)
        phase = phase + dt
        local pulse = 0.72 + (math.sin(phase*2.4)+1)*0.24
        for _,obj in ipairs(pulseLights) do
            if obj.Parent then
                obj.Brightness = math.max(0.25, pulse * 1.45)
            end
        end
    end)
end

-- Minimal arrival card; no gamey permanent HUD.
local gui=Instance.new("ScreenGui")
gui.Name="TRACK01_Arrival"
gui.IgnoreGuiInset=true
gui.ResetOnSpawn=false
gui.DisplayOrder=20
gui.Parent=player:WaitForChild("PlayerGui")
local panel=Instance.new("Frame")
panel.Size=UDim2.fromOffset(390,118)
panel.Position=UDim2.new(0.5,-195,0,48)
panel.BackgroundColor3=Color3.fromRGB(7,8,9)
panel.BackgroundTransparency=0.12
panel.BorderSizePixel=0
panel.Parent=gui
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,-28,0,52)
title.Position=UDim2.fromOffset(14,10)
title.BackgroundTransparency=1
title.Text="TRACK 01"
title.TextColor3=Color3.fromRGB(239,237,229)
title.TextXAlignment=Enum.TextXAlignment.Left
title.Font=Enum.Font.GothamBlack
title.TextSize=34
title.Parent=panel
local sub=Instance.new("TextLabel")
sub.Size=UDim2.new(1,-28,0,34)
sub.Position=UDim2.fromOffset(14,63)
sub.BackgroundTransparency=1
sub.Text="NO DESTINATION. JUST THE NIGHT."
sub.TextColor3=Color3.fromRGB(255,169,72)
sub.TextXAlignment=Enum.TextXAlignment.Left
sub.Font=Enum.Font.GothamMedium
sub.TextSize=15
sub.Parent=panel
local line=Instance.new("Frame")
line.Size=UDim2.new(1,0,0,2)
line.Position=UDim2.new(0,0,1,-2)
line.BackgroundColor3=Color3.fromRGB(214,48,38)
line.BorderSizePixel=0
line.Parent=panel

task.delay(4.5,function()
    if not panel.Parent then return end
    TweenService:Create(panel,TweenInfo.new(0.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=1,Position=UDim2.new(0.5,-195,0,28)}):Play()
    TweenService:Create(title,TweenInfo.new(0.6),{TextTransparency=1}):Play()
    TweenService:Create(sub,TweenInfo.new(0.6),{TextTransparency=1}):Play()
    TweenService:Create(line,TweenInfo.new(0.6),{BackgroundTransparency=1}):Play()
    task.wait(0.9)
    gui:Destroy()
end)
