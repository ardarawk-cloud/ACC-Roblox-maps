local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("WONDERPOCKET_Remotes", 15)
if not remotes then return end
local tutorial = remotes:WaitForChild("Tutorial", 10)

local function waitForData()
    -- Do not let a slow-but-successful DataStore load skip the opening dedication.
    -- The server is authoritative: continue waiting until it explicitly reports
    -- a safe load or a fail-closed load failure.
    while player.Parent do
        if player:GetAttribute("WP_DataLoadFailed") == true then return false end
        if player:GetAttribute("WP_DataLoaded") == true then return true end
        task.wait(.25)
    end
    return false
end

local function waitForResumeState()
    -- Furniture purchase progress is persisted separately. Resolve it before
    -- deciding whether the player is genuinely new or returning mid-journey.
    while player.Parent do
        if player:GetAttribute("WP_InventoryLoadFailed") == true then return false end
        if player:GetAttribute("WP_InventoryLoaded") == true then return true end
        task.wait(.25)
    end
    return false
end

local function hasTutorialProgress()
    return player:GetAttribute("WP_TutorialStarted") == true
        or player:GetAttribute("WP_Tutorial_MetWondi") == true
        or (tonumber(player:GetAttribute("WP_PlantedCount")) or 0) >= 1
        or (tonumber(player:GetAttribute("WP_PurchasedFurnitureCount")) or 0) >= 1
        or (tonumber(player:GetAttribute("WP_PlacedCount")) or 0) >= 1
        or (tonumber(player:GetAttribute("WP_HarvestCount")) or 0) >= 1
end

if not waitForData() then return end
local onboardingComplete = player:GetAttribute("WP_OnboardingComplete") == true
if not onboardingComplete and not waitForResumeState() then return end
onboardingComplete = player:GetAttribute("WP_OnboardingComplete") == true
local tutorialProgress = not onboardingComplete and hasTutorialProgress()
local firstJourney = not onboardingComplete and not tutorialProgress

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
title.Text = onboardingComplete and "Welcome back to WONDERPOCKET" or "Welcome to WONDERPOCKET"
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
if firstJourney then
    body.Text = "Your first Pocket journey:\n\n• Say hi to Bubbi\n• Plant a carrot\n• Buy & place furniture\n• Harvest your carrot\n• Find treasure on Treasure Island"
elseif tutorialProgress then
    local objective = tostring(player:GetAttribute("WP_TutorialObjective") or "Continue your first Pocket journey")
    body.Text = "Your Pocket journey is waiting.\n\nNext objective:\n" .. objective
else
    body.Text = "Your little world is waiting.\n\nVisit your Pocket, spend time with your Wondi, decorate, garden, explore, and keep building your world."
end
body.Parent = card

local start = Instance.new("TextButton")
start.AnchorPoint = Vector2.new(.5,1)
start.Position = UDim2.new(.5,0,1,-14)
start.Size = UDim2.new(1,-64,0,50)
start.BackgroundColor3 = Color3.fromRGB(74,100,205)
start.TextColor3 = Color3.new(1,1,1)
start.Font = Enum.Font.GothamBold
start.TextSize = 17
if firstJourney then
    start.Text = "START MY POCKET"
elseif tutorialProgress then
    start.Text = "CONTINUE JOURNEY"
else
    start.Text = "ENTER MY POCKET"
end
start.Parent = card
local startConstraint = Instance.new("UISizeConstraint")
startConstraint.MaxSize = Vector2.new(240,50)
startConstraint.Parent = start
Instance.new("UICorner",start).CornerRadius = UDim.new(0,16)

local entered = false
start.Activated:Connect(function()
    if entered then return end
    entered = true
    start.Active = false
    if firstJourney then
        start.Text = "STARTING..."
        if tutorial then tutorial:FireServer("START") end
    else
        start.Text = "ENTERING..."
    end
    task.delay(.15,function()
        if gui.Parent then gui:Destroy() end
    end)
end)

print("[WONDERPOCKET] dedication opening restored for every safe join")
