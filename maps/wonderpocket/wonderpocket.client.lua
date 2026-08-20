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

-- Gameplay-first HUD: keep the world visible instead of covering the screen
-- with one full-width banner. TopBar is a transparent container so mobile polish
-- can hide the whole HUD while the player is actively placing furniture.
local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1,-20,0,36)
top.Position = UDim2.fromOffset(10,6)
top.BackgroundTransparency = 1
top.Parent = gui

local brand = Instance.new("Frame")
brand.Name = "BrandPill"
brand.Size = UDim2.new(.46,0,1,0)
brand.Position = UDim2.fromOffset(0,0)
brand.BackgroundColor3 = Color3.fromRGB(25,31,65)
brand.BackgroundTransparency = .08
brand.Parent = top
local brandLimit = Instance.new("UISizeConstraint")
brandLimit.MinSize = Vector2.new(150,36)
brandLimit.MaxSize = Vector2.new(230,36)
brandLimit.Parent = brand
local brandCorner = Instance.new("UICorner")
brandCorner.CornerRadius = UDim.new(0,13)
brandCorner.Parent = brand

local economy = Instance.new("Frame")
economy.Name = "EconomyPill"
economy.AnchorPoint = Vector2.new(1,0)
economy.Position = UDim2.new(1,0,0,0)
economy.Size = UDim2.new(.46,0,1,0)
economy.BackgroundColor3 = Color3.fromRGB(25,31,65)
economy.BackgroundTransparency = .08
economy.Parent = top
local economyLimit = Instance.new("UISizeConstraint")
economyLimit.MinSize = Vector2.new(150,36)
economyLimit.MaxSize = Vector2.new(200,36)
economyLimit.Parent = economy
local economyCorner = Instance.new("UICorner")
economyCorner.CornerRadius = UDim.new(0,13)
economyCorner.Parent = economy

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-20,1,0)
title.Position = UDim2.fromOffset(10,0)
title.BackgroundTransparency = 1
title.Text = "WONDERPOCKET"
title.TextSize = 13
title.TextColor3 = Color3.fromRGB(245,248,255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBlack
title.TextTruncate = Enum.TextTruncate.AtEnd
title.Parent = brand

local stats = Instance.new("TextLabel")
stats.Size = UDim2.new(1,-18,1,0)
stats.Position = UDim2.fromOffset(9,0)
stats.BackgroundTransparency = 1
stats.TextSize = 11
stats.TextColor3 = Color3.fromRGB(235,242,255)
stats.TextXAlignment = Enum.TextXAlignment.Right
stats.Font = Enum.Font.GothamBold
stats.TextTruncate = Enum.TextTruncate.AtEnd
stats.Parent = economy

local function refresh()
    local coins = math.max(0, math.floor(tonumber(player:GetAttribute("Coins")) or 0))
    local stars = math.max(0, math.floor(tonumber(player:GetAttribute("Stars")) or 0))
    local seeds = math.max(0, math.floor(tonumber(player:GetAttribute("CarrotSeed")) or 0))
    local wondi = tostring(player:GetAttribute("ActiveWondi") or "Bubbi")
    title.Text = "WONDERPOCKET • " .. wondi
    stats.Text = string.format("C %s  •  S %s  •  Seeds %s", coins, stars, seeds)
end

for _,attribute in ipairs({"Coins","Stars","CarrotSeed","ActiveWondi"}) do
    player:GetAttributeChangedSignal(attribute):Connect(refresh)
end
StateRemote.OnClientEvent:Connect(function(kind)
    if kind == "INIT" then refresh() end
end)

refresh()
print("[WONDERPOCKET] v1.3 compact gameplay-first HUD loaded")
