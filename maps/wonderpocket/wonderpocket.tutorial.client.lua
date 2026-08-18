local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("WONDERPOCKET_Remotes", 15)
if not remotes then return end
local Tutorial = remotes:WaitForChild("Tutorial", 10)

local gui = Instance.new("ScreenGui")
gui.Name = "WP_TutorialObjective"
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Parent = player:WaitForChild("PlayerGui")

local card = Instance.new("Frame")
card.Name = "ObjectiveCard"
card.Position = UDim2.fromOffset(14, 86)
card.Size = UDim2.fromOffset(310, 86)
card.BackgroundColor3 = Color3.fromRGB(30, 39, 78)
card.BackgroundTransparency = .08
card.Visible = false
card.Parent = gui
Instance.new("UICorner", card).CornerRadius = UDim.new(0, 18)

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Transparency = .6
stroke.Color = Color3.fromRGB(127, 174, 255)
stroke.Parent = card

local kicker = Instance.new("TextLabel")
kicker.Position = UDim2.fromOffset(16, 10)
kicker.Size = UDim2.new(1, -32, 0, 20)
kicker.BackgroundTransparency = 1
kicker.Font = Enum.Font.GothamBold
kicker.TextSize = 12
kicker.TextColor3 = Color3.fromRGB(157, 197, 255)
kicker.TextXAlignment = Enum.TextXAlignment.Left
kicker.Text = "FIRST POCKET JOURNEY"
kicker.Parent = card

local objective = Instance.new("TextLabel")
objective.Position = UDim2.fromOffset(16, 31)
objective.Size = UDim2.new(1, -32, 0, 42)
objective.BackgroundTransparency = 1
objective.Font = Enum.Font.GothamSemibold
objective.TextSize = 17
objective.TextWrapped = true
objective.TextColor3 = Color3.fromRGB(255,255,255)
objective.TextXAlignment = Enum.TextXAlignment.Left
objective.TextYAlignment = Enum.TextYAlignment.Top
objective.Parent = card

local function refresh()
    local complete = player:GetAttribute("WP_OnboardingComplete") == true
    local started = player:GetAttribute("WP_TutorialStarted") == true
    card.Visible = started and not complete
    if complete then return end

    local step = tonumber(player:GetAttribute("WP_TutorialStep")) or 1
    local text = tostring(player:GetAttribute("WP_TutorialObjective") or "Start your Pocket journey")
    kicker.Text = string.format("FIRST POCKET JOURNEY  •  %d/6", math.clamp(step,1,6))
    objective.Text = text
end

for _, attr in ipairs({"WP_OnboardingComplete","WP_TutorialStarted","WP_TutorialStep","WP_TutorialObjective"}) do
    player:GetAttributeChangedSignal(attr):Connect(refresh)
end

Tutorial.OnClientEvent:Connect(function(action, step, total, _, text)
    if action == "STEP" then
        card.Visible = true
        kicker.Text = string.format("FIRST POCKET JOURNEY  •  %d/%d", step, total)
        objective.Text = text
    elseif action == "COMPLETE" then
        card.Visible = true
        kicker.Text = "FIRST POCKET JOURNEY  •  COMPLETE"
        objective.Text = text or "Your Pocket journey has begun!"
        task.delay(3.5, function()
            if card then card.Visible = false end
        end)
    end
end)

refresh()
print("[WONDERPOCKET] First-session objective tracker ready")
