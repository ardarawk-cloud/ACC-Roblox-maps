local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("ASC_Remotes")
local statePush = remotes:WaitForChild("StatePush")
local toastRemote = remotes:WaitForChild("Toast")
local dialogueRemote = remotes:WaitForChild("Dialogue")
local requestState = remotes:WaitForChild("RequestState")

local gui = Instance.new("ScreenGui")
gui.Name = "ASC_GameplayHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 20
gui.Parent = playerGui

local card = Instance.new("Frame")
card.Name = "StatusCard"
card.AnchorPoint = Vector2.new(0.5, 0)
card.Position = UDim2.new(0.5, 0, 0, 14)
card.Size = UDim2.fromOffset(390, 96)
card.BackgroundColor3 = Color3.fromRGB(18, 24, 36)
card.BackgroundTransparency = 0.12
card.BorderSizePixel = 0
card.Visible = false
card.Parent = gui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 12)
cardCorner.Parent = card

local cardStroke = Instance.new("UIStroke")
cardStroke.Thickness = 1
cardStroke.Transparency = 0.55
cardStroke.Color = Color3.fromRGB(255, 255, 255)
cardStroke.Parent = card

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(280, 88)
sizeConstraint.MaxSize = Vector2.new(420, 110)
sizeConstraint.Parent = card

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(16, 8)
title.Size = UDim2.new(1, -32, 0, 20)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(226, 232, 240)
title.Text = "AFTER SCHOOL CITY"
title.Parent = card

local stats = Instance.new("TextLabel")
stats.Name = "Stats"
stats.BackgroundTransparency = 1
stats.Position = UDim2.fromOffset(16, 29)
stats.Size = UDim2.new(1, -32, 0, 23)
stats.Font = Enum.Font.GothamBlack
stats.TextSize = 17
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.TextColor3 = Color3.fromRGB(255, 255, 255)
stats.Text = "250 COINS   •   REP 0   •   LV 1"
stats.Parent = card

local objective = Instance.new("TextLabel")
objective.Name = "Objective"
objective.BackgroundTransparency = 1
objective.Position = UDim2.fromOffset(16, 55)
objective.Size = UDim2.new(1, -32, 0, 30)
objective.Font = Enum.Font.GothamMedium
objective.TextSize = 14
objective.TextWrapped = true
objective.TextXAlignment = Enum.TextXAlignment.Left
objective.TextYAlignment = Enum.TextYAlignment.Top
objective.TextColor3 = Color3.fromRGB(194, 207, 224)
objective.Text = "Loading objective..."
objective.Parent = card

local saveBadge = Instance.new("TextLabel")
saveBadge.Name = "SaveBadge"
saveBadge.AnchorPoint = Vector2.new(1, 0)
saveBadge.Position = UDim2.new(1, -12, 0, 8)
saveBadge.Size = UDim2.fromOffset(72, 18)
saveBadge.BackgroundTransparency = 1
saveBadge.Font = Enum.Font.GothamBold
saveBadge.TextSize = 10
saveBadge.TextXAlignment = Enum.TextXAlignment.Right
saveBadge.TextColor3 = Color3.fromRGB(148, 163, 184)
saveBadge.Text = "SAVE ..."
saveBadge.Parent = card

local toastFrame = Instance.new("Frame")
toastFrame.Name = "Toast"
toastFrame.AnchorPoint = Vector2.new(0.5, 1)
toastFrame.Position = UDim2.new(0.5, 0, 1, -24)
toastFrame.Size = UDim2.fromOffset(340, 62)
toastFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
toastFrame.BackgroundTransparency = 1
toastFrame.BorderSizePixel = 0
toastFrame.Visible = false
toastFrame.Parent = gui

local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = UDim.new(0, 10)
toastCorner.Parent = toastFrame

local toastTitle = Instance.new("TextLabel")
toastTitle.BackgroundTransparency = 1
toastTitle.Position = UDim2.fromOffset(14, 8)
toastTitle.Size = UDim2.new(1, -28, 0, 20)
toastTitle.Font = Enum.Font.GothamBold
toastTitle.TextSize = 14
toastTitle.TextXAlignment = Enum.TextXAlignment.Left
toastTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
toastTitle.TextTransparency = 1
toastTitle.Parent = toastFrame

local toastBody = Instance.new("TextLabel")
toastBody.BackgroundTransparency = 1
toastBody.Position = UDim2.fromOffset(14, 29)
toastBody.Size = UDim2.new(1, -28, 0, 24)
toastBody.Font = Enum.Font.GothamMedium
toastBody.TextSize = 12
toastBody.TextXAlignment = Enum.TextXAlignment.Left
toastBody.TextColor3 = Color3.fromRGB(203, 213, 225)
toastBody.TextTransparency = 1
toastBody.Parent = toastFrame

local dialogueFrame = Instance.new("Frame")
dialogueFrame.Name = "Dialogue"
dialogueFrame.AnchorPoint = Vector2.new(0.5, 1)
dialogueFrame.Position = UDim2.new(0.5, 0, 1, -96)
dialogueFrame.Size = UDim2.fromOffset(390, 84)
dialogueFrame.BackgroundColor3 = Color3.fromRGB(17, 24, 39)
dialogueFrame.BackgroundTransparency = 0.08
dialogueFrame.BorderSizePixel = 0
dialogueFrame.Visible = false
dialogueFrame.Parent = gui

local dialogueCorner = Instance.new("UICorner")
dialogueCorner.CornerRadius = UDim.new(0, 12)
dialogueCorner.Parent = dialogueFrame

local speakerLabel = Instance.new("TextLabel")
speakerLabel.BackgroundTransparency = 1
speakerLabel.Position = UDim2.fromOffset(16, 10)
speakerLabel.Size = UDim2.new(1, -32, 0, 18)
speakerLabel.Font = Enum.Font.GothamBold
speakerLabel.TextSize = 12
speakerLabel.TextXAlignment = Enum.TextXAlignment.Left
speakerLabel.TextColor3 = Color3.fromRGB(147, 197, 253)
speakerLabel.Parent = dialogueFrame

local dialogueText = Instance.new("TextLabel")
dialogueText.BackgroundTransparency = 1
dialogueText.Position = UDim2.fromOffset(16, 31)
dialogueText.Size = UDim2.new(1, -32, 0, 42)
dialogueText.Font = Enum.Font.GothamMedium
dialogueText.TextSize = 14
dialogueText.TextWrapped = true
dialogueText.TextXAlignment = Enum.TextXAlignment.Left
dialogueText.TextYAlignment = Enum.TextYAlignment.Top
dialogueText.TextColor3 = Color3.fromRGB(241, 245, 249)
dialogueText.Parent = dialogueFrame

local toastToken = 0
local dialogueToken = 0

local function applyState(state)
    if type(state) ~= "table" or state.Ready ~= true then
        return
    end

    card.Visible = true
    stats.Text = string.format("%d COINS   •   REP %d   •   LV %d", state.Coins or 0, state.Rep or 0, state.Level or 1)

    if state.Quest then
        objective.Text = "OBJECTIVE  •  " .. tostring(state.Quest.Objective or state.Quest.Title or "Explore the city")
    else
        objective.Text = "OBJECTIVE  •  Exploration complete"
    end

    if state.Persistent then
        saveBadge.Text = "SAVE ON"
        saveBadge.TextColor3 = Color3.fromRGB(134, 239, 172)
    else
        saveBadge.Text = "SESSION"
        saveBadge.TextColor3 = Color3.fromRGB(253, 186, 116)
    end
end

local function showToast(headline, body)
    toastToken += 1
    local token = toastToken
    toastFrame.Visible = true
    toastTitle.Text = tostring(headline or "AFTER SCHOOL CITY")
    toastBody.Text = tostring(body or "")
    toastFrame.BackgroundTransparency = 1
    toastTitle.TextTransparency = 1
    toastBody.TextTransparency = 1

    TweenService:Create(toastFrame, TweenInfo.new(0.18), {BackgroundTransparency = 0.08}):Play()
    TweenService:Create(toastTitle, TweenInfo.new(0.18), {TextTransparency = 0}):Play()
    TweenService:Create(toastBody, TweenInfo.new(0.18), {TextTransparency = 0}):Play()

    task.delay(3.2, function()
        if token ~= toastToken then
            return
        end
        TweenService:Create(toastFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        TweenService:Create(toastTitle, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        TweenService:Create(toastBody, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        task.wait(0.22)
        if token == toastToken then
            toastFrame.Visible = false
        end
    end)
end

local function showDialogue(payload)
    if type(payload) ~= "table" then
        return
    end
    dialogueToken += 1
    local token = dialogueToken
    speakerLabel.Text = tostring(payload.Speaker or "CITY GUIDE")
    dialogueText.Text = tostring(payload.Text or "")
    dialogueFrame.Visible = true

    task.delay(4.5, function()
        if token == dialogueToken then
            dialogueFrame.Visible = false
        end
    end)
end

statePush.OnClientEvent:Connect(applyState)
toastRemote.OnClientEvent:Connect(showToast)
dialogueRemote.OnClientEvent:Connect(showDialogue)

for attempt = 1, 8 do
    local ok, state = pcall(function()
        return requestState:InvokeServer()
    end)
    if ok and type(state) == "table" and state.Ready then
        applyState(state)
        break
    end
    task.wait(0.5)
end
