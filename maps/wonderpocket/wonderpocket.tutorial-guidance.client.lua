local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local currentTarget = nil
local currentStroke = nil
local currentBadge = nil
local pulseTween = nil
local panelConnections = {}

local worldTarget = nil
local worldHighlight = nil
local worldBillboard = nil

local function clearButtonGuide()
    if pulseTween then
        pcall(function() pulseTween:Cancel() end)
        pulseTween = nil
    end
    if currentStroke then
        currentStroke:Destroy()
        currentStroke = nil
    end
    if currentBadge then
        currentBadge:Destroy()
        currentBadge = nil
    end
    currentTarget = nil
end

local function clearWorldGuide()
    if worldHighlight then
        worldHighlight:Destroy()
        worldHighlight = nil
    end
    if worldBillboard then
        worldBillboard:Destroy()
        worldBillboard = nil
    end
    worldTarget = nil
end

local function findButton(root, text)
    if not root then return nil end
    for _, instance in ipairs(root:GetDescendants()) do
        if instance:IsA("TextButton") and instance.Text == text then
            return instance
        end
    end
    return nil
end

local function attachButtonGuide(button, labelText)
    if not button or not button.Parent then
        clearButtonGuide()
        return
    end
    if currentTarget == button then return end

    clearButtonGuide()
    currentTarget = button

    local stroke = Instance.new("UIStroke")
    stroke.Name = "WP_TutorialGuideStroke"
    stroke.Thickness = 3
    stroke.Transparency = .1
    stroke.Color = Color3.fromRGB(255, 221, 92)
    stroke.Parent = button
    currentStroke = stroke

    local badge = Instance.new("TextLabel")
    badge.Name = "WP_TutorialGuideBadge"
    badge.AnchorPoint = Vector2.new(.5, 1)
    badge.Position = UDim2.new(.5, 0, 0, -5)
    badge.Size = UDim2.fromOffset(76, 24)
    badge.BackgroundColor3 = Color3.fromRGB(255, 221, 92)
    badge.TextColor3 = Color3.fromRGB(42, 47, 72)
    badge.Font = Enum.Font.GothamBold
    badge.TextSize = 11
    badge.Text = labelText or "NEXT"
    badge.ZIndex = math.max(button.ZIndex + 4, 10)
    badge.Parent = button
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = badge
    currentBadge = badge

    pulseTween = TweenService:Create(
        stroke,
        TweenInfo.new(.65, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Transparency = .75, Thickness = 1.5}
    )
    pulseTween:Play()
end

local function attachWorldGuide(part, labelText)
    if not part or not part:IsA("BasePart") or not part.Parent then
        clearWorldGuide()
        return
    end
    if worldTarget == part and worldBillboard and worldBillboard.Parent then
        local label = worldBillboard:FindFirstChild("Label")
        if label and label:IsA("TextLabel") then label.Text = labelText end
        return
    end

    clearWorldGuide()
    worldTarget = part

    local highlight = Instance.new("Highlight")
    highlight.Name = "WP_TutorialWorldHighlight"
    highlight.Adornee = part
    highlight.FillColor = Color3.fromRGB(255, 221, 92)
    highlight.FillTransparency = .78
    highlight.OutlineColor = Color3.fromRGB(255, 240, 170)
    highlight.OutlineTransparency = .05
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = workspace
    worldHighlight = highlight

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "WP_TutorialWorldGuide"
    billboard.Adornee = part
    billboard.Size = UDim2.fromOffset(148, 34)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, math.max(3, part.Size.Y * .5 + 2.2), 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 180
    billboard.Parent = playerGui

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(35, 45, 85)
    label.BackgroundTransparency = .08
    label.TextColor3 = Color3.fromRGB(255, 229, 118)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Text = labelText
    label.Parent = billboard
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = label
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Transparency = .35
    stroke.Color = Color3.fromRGB(255, 221, 92)
    stroke.Parent = label

    worldBillboard = billboard
end

local function findOwnedWondiBody()
    local root = workspace:FindFirstChild("WONDERPOCKET")
    local folder = root and root:FindFirstChild("ActiveWondies")
    if not folder then return nil end
    for _, model in ipairs(folder:GetChildren()) do
        if tonumber(model:GetAttribute("OwnerUserId")) == player.UserId then
            local body = model:FindFirstChild("Body") or model.PrimaryPart
            if body and body:IsA("BasePart") then return body end
        end
    end
    return nil
end

local function findOwnedGardenPlot()
    local root = workspace:FindFirstChild("WONDERPOCKET")
    local folder = root and root:FindFirstChild("GardenPlots")
    if not folder then return nil end
    for _, plot in ipairs(folder:GetChildren()) do
        if plot:IsA("BasePart") and tonumber(plot:GetAttribute("OwnerUserId")) == player.UserId then
            return plot
        end
    end
    return nil
end

local function findAdventureGate()
    local square = workspace:FindFirstChild("WonderSquare_Premium")
    local gate = square and square:FindFirstChild("Adventure Gate")
    if gate and gate:IsA("BasePart") then return gate end
    return nil
end

local function refreshWorldGuide(stepId)
    if stepId == "MeetWondi" then
        attachWorldGuide(findOwnedWondiBody(), "NEXT • SAY HI")
    elseif stepId == "PlantCarrot" then
        attachWorldGuide(findOwnedGardenPlot(), "NEXT • PLANT HERE")
    elseif stepId == "HarvestCarrot" then
        attachWorldGuide(findOwnedGardenPlot(), "HARVEST HERE WHEN READY")
    elseif stepId == "Treasure" then
        attachWorldGuide(findAdventureGate(), "NEXT • GO HERE")
    else
        clearWorldGuide()
    end
end

local function refreshButtonGuide(stepId)
    local premium = playerGui:FindFirstChild("WonderPocketPremiumUI")
    if not premium then
        clearButtonGuide()
        return
    end

    local shopPanel = premium:FindFirstChild("ShopPanel", true)
    local buildPanel = premium:FindFirstChild("BuildPanel", true)

    if stepId == "BuyFurniture" then
        if shopPanel and shopPanel.Visible then
            clearButtonGuide()
            return
        end
        attachButtonGuide(findButton(premium, "SHOP"), "TAP ME")
        return
    end

    if stepId == "PlaceFurniture" then
        if player:GetAttribute("WP_BuildActive") == true then
            attachButtonGuide(findButton(premium, "PLACE"), "PLACE")
            return
        end
        if buildPanel and buildPanel.Visible then
            clearButtonGuide()
            return
        end
        attachButtonGuide(findButton(premium, "BUILD"), "TAP ME")
        return
    end

    clearButtonGuide()
end

local function refresh()
    if player:GetAttribute("WP_OnboardingComplete") == true or player:GetAttribute("WP_TutorialStarted") ~= true then
        clearButtonGuide()
        clearWorldGuide()
        return
    end

    local stepId = tostring(player:GetAttribute("WP_TutorialStepId") or "")
    refreshButtonGuide(stepId)
    refreshWorldGuide(stepId)
end

local function disconnectPanelSignals()
    for _, connection in ipairs(panelConnections) do
        connection:Disconnect()
    end
    table.clear(panelConnections)
end

local function bindPremiumUI(gui)
    disconnectPanelSignals()
    for _, panelName in ipairs({"ShopPanel", "BuildPanel", "DexPanel", "SocialPanel"}) do
        local panel = gui:FindFirstChild(panelName, true)
        if panel and panel:IsA("GuiObject") then
            table.insert(panelConnections, panel:GetPropertyChangedSignal("Visible"):Connect(refresh))
        end
    end
    refresh()
end

for _, attr in ipairs({
    "WP_OnboardingComplete",
    "WP_TutorialStarted",
    "WP_TutorialStepId",
    "WP_BuildActive",
}) do
    player:GetAttributeChangedSignal(attr):Connect(refresh)
end

playerGui.ChildAdded:Connect(function(child)
    if child.Name == "WonderPocketPremiumUI" then
        task.defer(function() bindPremiumUI(child) end)
    end
end)

local premium = playerGui:FindFirstChild("WonderPocketPremiumUI") or playerGui:WaitForChild("WonderPocketPremiumUI", 15)
if premium then bindPremiumUI(premium) end

-- Runtime objects such as personal gardens/Wondies may appear after this LocalScript.
task.spawn(function()
    while player.Parent do
        if player:GetAttribute("WP_TutorialStarted") == true and player:GetAttribute("WP_OnboardingComplete") ~= true then
            refresh()
        end
        task.wait(1.5)
    end
end)

print("[WONDERPOCKET] Tutorial button guidance + world waypoints ready")
