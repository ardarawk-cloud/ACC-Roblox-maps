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
    b.Size = UDim2.fromOffset(150, 46)
    b.Position = pos
    b.AnchorPoint = Vector2.new(1,1)
    b.BackgroundTransparency = 0.18
    b.TextScaled = true
    b.Parent = gui
    return b
end

local carryBtn = mkButton("CarryButton", "Carry", UDim2.new(1,-18,1,-72))
local dropBtn = mkButton("DropButton", "Drop", UDim2.new(1,-18,1,-18))
local photoBtn = mkButton("PhotoButton", "Photo", UDim2.new(0,168,1,-18))
photoBtn.AnchorPoint = Vector2.new(1,1)

local weatherLabel = Instance.new("TextLabel")
weatherLabel.Name = "WeatherLabel"
weatherLabel.Size = UDim2.fromOffset(170,34)
weatherLabel.Position = UDim2.new(0,16,0,16)
weatherLabel.BackgroundTransparency = 0.25
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
local previous = {}
local function setPhotoMode(on)
    if on == inPhoto then return end
    inPhoto = on
    local cam = workspace.CurrentCamera
    if on then
        previous.fov = cam.FieldOfView
        previous.core = gui.Enabled
        cam.FieldOfView = 62
        weatherLabel.Visible = false
        carryBtn.Visible = false
        dropBtn.Visible = false
        photoBtn.Text = "Exit Photo"
    else
        cam.FieldOfView = previous.fov or 70
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
    if rainEmitter then return rainEmitter end
    local cam = workspace.CurrentCamera
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
    rain.Rate = state == "RAIN" and 650 or 0
end
weatherRemote.OnClientEvent:Connect(applyWeather)

-- Mobile-friendly: no mandatory keyboard input, but P toggles photo mode on desktop.
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.P then setPhotoMode(not inPhoto) end
end)

-- Keep rain attachment tracking current camera after respawn/camera replacement.
RunService.RenderStepped:Connect(function()
    if rainEmitter and rainEmitter.Parent and rainEmitter.Parent.Parent ~= workspace.CurrentCamera then
        local old = rainEmitter.Parent
        old.Parent = workspace.CurrentCamera
    end
end)
