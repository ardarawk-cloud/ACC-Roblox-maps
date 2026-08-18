local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local currentTarget = nil
local currentStroke = nil
local currentBadge = nil
local pulseTween = nil
local panelConnections = {}

local function clearGuide()
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

local function findButton(root, text)
    if not root then return nil end
    for _, instance in ipairs(root:GetDescendants()) do
        if instance:IsA("TextButton") and instance.Text == text then
            return instance
        end
    end
    return nil
end

local function attachGuide(button, labelText)
    if not button or not button.Parent then
        clearGuide()
        return
    end
    if currentTarget == button then return end

    clearGuide()
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

local function disconnectPanelSignals()
    for _, connection in ipairs(panelConnections) do
        connection:Disconnect()
    end
    table.clear(panelConnections)
end

local function refresh()
    if player:GetAttribute("WP_OnboardingComplete") == true or player:GetAttribute("WP_TutorialStarted") ~= true then
        clearGuide()
        return
    end

    local premium = playerGui:FindFirstChild("WonderPocketPremiumUI")
    if not premium then
        clearGuide()
        return
    end

    local stepId = tostring(player:GetAttribute("WP_TutorialStepId") or "")
    local shopPanel = premium:FindFirstChild("ShopPanel", true)
    local buildPanel = premium:FindFirstChild("BuildPanel", true)

    if stepId == "BuyFurniture" then
        if shopPanel and shopPanel.Visible then
            clearGuide()
            return
        end
        attachGuide(findButton(premium, "SHOP"), "TAP ME")
        return
    end

    if stepId == "PlaceFurniture" then
        if player:GetAttribute("WP_BuildActive") == true then
            attachGuide(findButton(premium, "PLACE"), "PLACE")
            return
        end
        if buildPanel and buildPanel.Visible then
            clearGuide()
            return
        end
        attachGuide(findButton(premium, "BUILD"), "TAP ME")
        return
    end

    clearGuide()
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

print("[WONDERPOCKET] Tutorial visual guidance ready")
