local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("WONDERPOCKET_Remotes")
local StateRemote = remotes:WaitForChild("State")

local gui = Instance.new("ScreenGui")
gui.Name = "WONDERPOCKET_UI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1,0,0,62)
top.BackgroundTransparency = 0.2
top.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0,280,1,0)
title.Position = UDim2.new(0,16,0,0)
title.BackgroundTransparency = 1
title.Text = "WONDERPOCKET"
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.Parent = top

local stats = Instance.new("TextLabel")
stats.Size = UDim2.new(0,320,1,0)
stats.Position = UDim2.new(1,-336,0,0)
stats.BackgroundTransparency = 1
stats.TextScaled = true
stats.Font = Enum.Font.GothamBold
stats.Parent = top

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(0,420,0,46)
hint.Position = UDim2.new(0.5,-210,1,-70)
hint.BackgroundTransparency = 0.25
hint.Text = "Build • Care • Explore • Connect"
hint.TextScaled = true
hint.Font = Enum.Font.GothamBold
hint.Parent = gui

local function refresh()
    local coins = player:GetAttribute("Coins") or 0
    local stars = player:GetAttribute("Stars") or 0
    local wondi = player:GetAttribute("ActiveWondi") or "Bubbi"
    stats.Text = string.format("🪙 %s   ⭐ %s   Wondi: %s", coins, stars, wondi)
end

player:GetAttributeChangedSignal("Coins"):Connect(refresh)
player:GetAttributeChangedSignal("Stars"):Connect(refresh)
player:GetAttributeChangedSignal("ActiveWondi"):Connect(refresh)
StateRemote.OnClientEvent:Connect(function(kind)
    if kind == "INIT" then refresh() end
end)

refresh()
