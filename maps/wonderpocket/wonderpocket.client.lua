local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("WONDERPOCKET_Remotes")
local StateRemote = remotes:WaitForChild("State")

local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("WONDERPOCKET_UI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "WONDERPOCKET_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1,-20,0,50)
top.Position = UDim2.fromOffset(10,8)
top.BackgroundColor3 = Color3.fromRGB(25,31,65)
top.BackgroundTransparency = .08
top.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,16)
corner.Parent = top

local title = Instance.new("TextLabel")
title.Size = UDim2.new(.42,-12,1,0)
title.Position = UDim2.fromOffset(12,0)
title.BackgroundTransparency = 1
title.Text = "WONDERPOCKET"
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(245,248,255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBlack
title.Parent = top

local stats = Instance.new("TextLabel")
stats.Size = UDim2.new(.58,-18,1,0)
stats.Position = UDim2.new(.42,6,0,0)
stats.BackgroundTransparency = 1
stats.TextSize = 13
stats.TextColor3 = Color3.fromRGB(235,242,255)
stats.TextXAlignment = Enum.TextXAlignment.Right
stats.Font = Enum.Font.GothamBold
stats.Parent = top

local function refresh()
    local coins = math.max(0, math.floor(tonumber(player:GetAttribute("Coins")) or 0))
    local stars = math.max(0, math.floor(tonumber(player:GetAttribute("Stars")) or 0))
    local seeds = math.max(0, math.floor(tonumber(player:GetAttribute("CarrotSeed")) or 0))
    local wondi = tostring(player:GetAttribute("ActiveWondi") or "Bubbi")
    title.Text = "WONDERPOCKET • " .. wondi
    stats.Text = string.format("C %s   S %s   Seeds %s", coins, stars, seeds)
end

for _,attribute in ipairs({"Coins","Stars","CarrotSeed","ActiveWondi"}) do
    player:GetAttributeChangedSignal(attribute):Connect(refresh)
end
StateRemote.OnClientEvent:Connect(function(kind)
    if kind == "INIT" then refresh() end
end)

refresh()
print("[WONDERPOCKET] v1.2 mobile-safe canonical HUD loaded")
