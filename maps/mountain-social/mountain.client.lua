-- Mountain Social Adventure client systems
-- Master-plan locked: hiking + exploration + social hangout + cinematic ambience + secrets

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("ACC_MountainRemotes")
local carryRemote = remotes:WaitForChild("Carry")
local weatherRemote = remotes:WaitForChild("Weather")
local photoRemote = remotes:WaitForChild("PhotoMode")

local gui = Instance.new("ScreenGui")
gui.Name = "ACC_MountainHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local function mkButton(name, text, pos)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Text = text
    b.Size = UDim2.fromOffset(132, 42)
    b.Position = pos
    b.AnchorPoint = Vector2.new(1,1)
    b.BackgroundTransparency = 0.2
    b.TextScaled = true
    b.Parent = gui
    return b
end

local carryBtn = mkButton("CarryButton", "Carry", UDim2.new(1,-18,1,-66))
local dropBtn = mkButton("DropButton", "Drop", UDim2.new(1,-18,1,-18))
local photoBtn = mkButton("PhotoButton", "Photo", UDim2.new(0,150,1,-18))

local weatherLabel = Instance.new("TextLabel")
weatherLabel.Name = "WeatherLabel"
weatherLabel.Size = UDim2.fromOffset(165,32)
weatherLabel.Position = UDim2.new(0,14,0,14)
weatherLabel.BackgroundTransparency = 0.28
weatherLabel.TextScaled = true
weatherLabel.Text = "Weather: CLEAR"
weatherLabel.Parent = gui

local function nearestPlayer(maxDist)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best, bestD
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position-root.Position).Magnitude
            if d <= maxDist and (not bestD or d < bestD) then best,bestD=p,d end
        end
    end
    return best
end

carryBtn.Activated:Connect(function()
    local target = nearestPlayer(12)
    if target then carryRemote:FireServer("carry", target.UserId) end
end)

dropBtn.Activated:Connect(function()
    carryRemote:FireServer("drop")
end)

local inPhoto = false
local previousFov = 70
local function setPhotoMode(on)
    if on == inPhoto then return end
    inPhoto = on
    local cam = workspace.CurrentCamera
    if on then
        previousFov = cam.FieldOfView
        cam.FieldOfView = 62
        weatherLabel.Visible = false
        carryBtn.Visible = false
        dropBtn.Visible = false
        photoBtn.Text = "Exit Photo"
    else
        cam.FieldOfView = previousFov
        weatherLabel.Visible = true
        carryBtn.Visible = true
        dropBtn.Visible = true
        photoBtn.Text = "Photo"
    end
    photoRemote:FireServer(on)
end
photoBtn.Activated:Connect(function() setPhotoMode(not inPhoto) end)

local rainEmitter
local function ensureRain()
    if rainEmitter and rainEmitter.Parent then return rainEmitter end
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local att = Instance.new("Attachment")
    att.Name = "ACC_RainAttachment"
    att.Position = Vector3.new(0,22,-8)
    att.Parent = cam
    local p = Instance.new("ParticleEmitter")
    p.Name = "ACC_Rain"
    p.Rate = 0
    p.Lifetime = NumberRange.new(0.5,0.7)
    p.Speed = NumberRange.new(55,68)
    p.EmissionDirection = Enum.NormalId.Bottom
    p.SpreadAngle = Vector2.new(8,8)
    p.Size = NumberSequence.new(0.08)
    p.LightInfluence = 1
    p.Parent = att
    rainEmitter = p
    return p
end

local function applyWeather(state)
    state = tostring(state or "CLEAR")
    weatherLabel.Text = "Weather: "..state
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmosphere then
        if state == "FOG" then
            atmosphere.Density = 0.48
            atmosphere.Haze = 2.7
        elseif state == "RAIN" then
            atmosphere.Density = 0.30
            atmosphere.Haze = 1.6
        else
            atmosphere.Density = 0.16
            atmosphere.Haze = 0.8
        end
    end
    local rain = ensureRain()
    if rain then rain.Rate = state == "RAIN" and 650 or 0 end
end
weatherRemote.OnClientEvent:Connect(applyWeather)
applyWeather(workspace:GetAttribute("ACC_Weather") or "CLEAR")

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.P then setPhotoMode(not inPhoto) end
end)

RunService.RenderStepped:Connect(function()
    if rainEmitter and rainEmitter.Parent and workspace.CurrentCamera and rainEmitter.Parent.Parent ~= workspace.CurrentCamera then
        rainEmitter.Parent.Parent = workspace.CurrentCamera
    end
end)
