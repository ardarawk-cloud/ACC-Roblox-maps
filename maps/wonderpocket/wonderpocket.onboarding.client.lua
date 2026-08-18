local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("WONDERPOCKET_Remotes", 15)
if not remotes then return end
local tutorial = remotes:WaitForChild("Tutorial", 10)

local function waitForData()
    local deadline = os.clock() + 15
    while os.clock() < deadline do
        if player:GetAttribute("WP_DataLoaded") == true then return true end
        task.wait(.25)
    end
    return false
end

if not waitForData() or player:GetAttribute("WP_OnboardingComplete") == true then return end

local gui = Instance.new("ScreenGui")
gui.Name = "WP_Onboarding"
gui.ResetOnSpawn = false
gui.DisplayOrder = 30
gui.Parent = player:WaitForChild("PlayerGui")

local card = Instance.new("Frame")
card.AnchorPoint = Vector2.new(.5,.5)
card.Position = UDim2.fromScale(.5,.5)
card.Size = UDim2.fromOffset(390,330)
card.BackgroundColor3 = Color3.fromRGB(248,250,255)
card.Parent = gui
Instance.new("UICorner",card).CornerRadius = UDim.new(0,24)

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Transparency = .7
stroke.Color = Color3.fromRGB(105,130,220)
stroke.Parent = card

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-40,0,54)
title.Position = UDim2.fromOffset(20,18)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 27
title.TextColor3 = Color3.fromRGB(42,56,105)
title.Text = "Welcome to WONDERPOCKET"
title.Parent = card

local body = Instance.new("TextLabel")
body.Position = UDim2.fromOffset(28,78)
body.Size = UDim2.new(1,-56,0,165)
body.BackgroundTransparency = 1
body.Font = Enum.Font.GothamMedium
body.TextSize = 17
body.TextWrapped = true
body.TextColor3 = Color3.fromRGB(65,73,110)
body.Text = "Your first Pocket journey:\n\n• Say hi to Bubbi\n• Plant a carrot\n• Buy & place furniture\n• Harvest your carrot\n• Find treasure on Treasure Island"
body.Parent = card

local start = Instance.new("TextButton")
start.AnchorPoint = Vector2.new(.5,1)
start.Position = UDim2.new(.5,0,1,-22)
start.Size = UDim2.fromOffset(220,52)
start.BackgroundColor3 = Color3.fromRGB(74,100,205)
start.TextColor3 = Color3.new(1,1,1)
start.Font = Enum.Font.GothamBold
start.TextSize = 18
start.Text = "START MY POCKET"
start.Parent = card
Instance.new("UICorner",start).CornerRadius = UDim.new(0,16)

start.Activated:Connect(function()
    if tutorial then tutorial:FireServer("START") end
    gui:Destroy()
end)

print("[WONDERPOCKET] First-session onboarding client ready")
