local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("WONDERPOCKET_Remotes", 15)
if not remotes then return end
local Tutorial = remotes:WaitForChild("Tutorial", 10)

local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("WP_TutorialObjective")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "WP_TutorialObjective"
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Parent = playerGui

local card = Instance.new("Frame")
card.Name = "ObjectiveCard"
card.Position = UDim2.fromOffset(12,70)
card.Size = UDim2.new(1,-24,0,84)
card.BackgroundColor3 = Color3.fromRGB(30,39,78)
card.BackgroundTransparency = .08
card.Visible = false
card.Parent = gui
local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MaxSize = Vector2.new(320,84)
sizeConstraint.MinSize = Vector2.new(250,84)
sizeConstraint.Parent = card
Instance.new("UICorner", card).CornerRadius = UDim.new(0,18)

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Transparency = .6
stroke.Color = Color3.fromRGB(127,174,255)
stroke.Parent = card

local kicker = Instance.new("TextLabel")
kicker.Position = UDim2.fromOffset(14,8)
kicker.Size = UDim2.new(1,-28,0,20)
kicker.BackgroundTransparency = 1
kicker.Font = Enum.Font.GothamBold
kicker.TextSize = 11
kicker.TextColor3 = Color3.fromRGB(157,197,255)
kicker.TextXAlignment = Enum.TextXAlignment.Left
kicker.Text = "FIRST POCKET JOURNEY"
kicker.Parent = card

local objective = Instance.new("TextLabel")
objective.Position = UDim2.fromOffset(14,29)
objective.Size = UDim2.new(1,-28,0,43)
objective.BackgroundTransparency = 1
objective.Font = Enum.Font.GothamSemibold
objective.TextSize = 15
objective.TextWrapped = true
objective.TextColor3 = Color3.fromRGB(255,255,255)
objective.TextXAlignment = Enum.TextXAlignment.Left
objective.TextYAlignment = Enum.TextYAlignment.Top
objective.Parent = card

local panelNames = {"ShopPanel","DexPanel","BuildPanel","SocialPanel"}
local function modalOpen()
    local premium = playerGui:FindFirstChild("WonderPocketPremiumUI")
    if not premium then return false end
    for _,name in ipairs(panelNames) do
        local panel = premium:FindFirstChild(name)
        if panel and panel:IsA("GuiObject") and panel.Visible then
            return true
        end
    end
    return false
end

local function applyVisibility(forceComplete)
    local complete = player:GetAttribute("WP_OnboardingComplete") == true
    local started = player:GetAttribute("WP_TutorialStarted") == true
    if forceComplete then
        card.Visible = not modalOpen()
    else
        card.Visible = started and not complete and not modalOpen()
    end
end

local function refresh()
    local complete = player:GetAttribute("WP_OnboardingComplete") == true
    if complete then
        card.Visible = false
        return
    end

    local step = tonumber(player:GetAttribute("WP_TutorialStep")) or 1
    local text = tostring(player:GetAttribute("WP_TutorialObjective") or "Start your Pocket journey")
    kicker.Text = string.format("FIRST POCKET JOURNEY  •  %d/6", math.clamp(step,1,6))
    objective.Text = text
    applyVisibility(false)
end

for _, attr in ipairs({"WP_OnboardingComplete","WP_TutorialStarted","WP_TutorialStep","WP_TutorialObjective"}) do
    player:GetAttributeChangedSignal(attr):Connect(refresh)
end

Tutorial.OnClientEvent:Connect(function(action, step, total, _, text)
    if action == "STEP" then
        kicker.Text = string.format("FIRST POCKET JOURNEY  •  %d/%d", step, total)
        objective.Text = text
        applyVisibility(false)
    elseif action == "COMPLETE" then
        kicker.Text = "FIRST POCKET JOURNEY  •  COMPLETE"
        objective.Text = text or "Your Pocket journey has begun!"
        applyVisibility(true)
        task.delay(3.5, function()
            if card.Parent then card.Visible = false end
        end)
    end
end)

-- While the first-session tutorial is active, keep the tracker out of the way of
-- full-size SHOP / DEX / BUILD / SOCIAL panels. It reappears as soon as they close.
task.spawn(function()
    while gui.Parent do
        if player:GetAttribute("WP_OnboardingComplete") == true then break end
        applyVisibility(false)
        task.wait(.15)
    end
end)

refresh()
print("[WONDERPOCKET] tutorial tracker modal-overlap guard ready")