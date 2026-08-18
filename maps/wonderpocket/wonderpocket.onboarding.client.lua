local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("WONDERPOCKET_Remotes", 15)
if not remotes then return end
local tutorial = remotes:WaitForChild("Tutorial", 10)

local function waitForData()
    -- Do not let a slow-but-successful DataStore load skip first-session onboarding.
    -- The server is authoritative: continue waiting until it explicitly reports
    -- a safe load or a fail-closed load failure.
    while player.Parent do
        if player:GetAttribute("WP_DataLoadFailed") == true then return false end
        if player:GetAttribute("WP_DataLoaded") == true then return true end
        task.wait(.25)
    end
    return false
end

if not waitForData() or player:GetAttribute("WP_OnboardingComplete") == true then return end

local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("WP_Onboarding")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "WP_Onboarding"
gui.ResetOnSpawn = false
gui.DisplayOrder = 30
gui.Parent = playerGui

local shade = Instance.new("Frame")
shade.Size = UDim2.fromScale(1,1)
shade.BackgroundColor3 = Color3.fromRGB(18,22,42)
shade.BackgroundTransparency = .42
shade.Parent = gui

local card = Instance.new("Frame")
card.AnchorPoint = Vector2.new(.5,.5)
card.Position = UDim2.fromScale(.5,.48)
card.Size = UDim2.new(1,-28,0,350)
card.BackgroundColor3 = Color3.fromRGB(248,250,255)
card.Parent = gui
local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MaxSize = Vector2.new(390,350)
sizeConstraint.MinSize = Vector2.new(292,320)
sizeConstraint.Parent = card
Instance.new("UICorner",card).CornerRadius = UDim.new(0,24)

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Transparency = .7
stroke.Color = Color3.fromRGB(105,130,220)
stroke.Parent = card

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-36,0,50)
title.Position = UDim2.fromOffset(18,10)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 23
title.TextWrapped = true
title.TextColor3 = Color3.fromRGB(42,56,105)
title.Text = "Welcome to WONDERPOCKET"
title.Parent = card

local dedication = Instance.new("TextLabel")
dedication.Position = UDim2.fromOffset(24,58)
dedication.Size = UDim2.new(1,-48,0,44)
dedication.BackgroundTransparency = 1
dedication.Font = Enum.Font.GothamMedium
dedication.TextSize = 14
dedication.TextWrapped = true
dedication.TextColor3 = Color3.fromRGB(92,103,145)
dedication.Text = "This game was made especially for\nPutu Azya Putri Bintang Hardajaya."
dedication.Parent = card

local body = Instance.new("TextLabel")
body.Position = UDim2.fromOffset(24,104)
body.Size = UDim2.new(1,-48,0,142)
body.BackgroundTransparency = 1
body.Font = Enum.Font.GothamMedium
body.TextSize = 15
body.TextWrapped = true
body.TextColor3 = Color3.fromRGB(65,73,110)
body.Text = "Your first Pocket journey:\n\n• Say hi to Bubbi\n• Plant a carrot\n• Buy & place furniture\n• Harvest your carrot\n• Find treasure on Treasure Island"
body.Parent = card

local start = Instance.new("TextButton")
start.AnchorPoint = Vector2.new(.5,1)
start.Position = UDim2.new(.5,0,1,-14)
start.Size = UDim2.new(1,-64,0,50)
start.BackgroundColor3 = Color3.fromRGB(74,100,205)
start.TextColor3 = Color3.new(1,1,1)
start.Font = Enum.Font.GothamBold
start.TextSize = 17
start.Text = "START MY POCKET"
start.Parent = card
local startConstraint = Instance.new("UISizeConstraint")
startConstraint.MaxSize = Vector2.new(240,50)
startConstraint.Parent = start
Instance.new("UICorner",start).CornerRadius = UDim.new(0,16)

local started = false
start.Activated:Connect(function()
    if started then return end
    started = true
    start.Active = false
    start.Text = "STARTING..."
    if tutorial then tutorial:FireServer("START") end
    task.delay(.15,function()
        if gui.Parent then gui:Destroy() end
    end)
end)

print("[WONDERPOCKET] v1.3 dedication onboarding mobile-fit ready")
