local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "WP_ClosedTestHealth"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.AnchorPoint = Vector2.new(1,0)
button.Position = UDim2.new(1,-10,0,72)
button.Size = UDim2.fromOffset(74,34)
button.BackgroundColor3 = Color3.fromRGB(35,45,80)
button.TextColor3 = Color3.new(1,1,1)
button.Text = "TEST"
button.Font = Enum.Font.GothamBold
button.TextSize = 13
button.Parent = gui
Instance.new("UICorner",button).CornerRadius = UDim.new(0,10)

local panel = Instance.new("TextLabel")
panel.AnchorPoint = Vector2.new(1,0)
panel.Position = UDim2.new(1,-10,0,112)
panel.Size = UDim2.fromOffset(310,310)
panel.BackgroundColor3 = Color3.fromRGB(20,25,45)
panel.BackgroundTransparency = .08
panel.TextColor3 = Color3.fromRGB(235,242,255)
panel.TextXAlignment = Enum.TextXAlignment.Left
panel.TextYAlignment = Enum.TextYAlignment.Top
panel.Font = Enum.Font.Code
panel.TextSize = 13
panel.TextWrapped = true
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,12)

local function yes(v) return v and "OK" or "WAIT" end
local function refresh()
    local remotes=ReplicatedStorage:FindFirstChild("WONDERPOCKET_Remotes")
    local plotId=tonumber(player:GetAttribute("WP_PlotIndex")) or 0
    local tutorialStep=tonumber(player:GetAttribute("WP_TutorialStep")) or 0
    local coins=tonumber(player:GetAttribute("Coins")) or 0
    local stars=tonumber(player:GetAttribute("Stars")) or 0
    local deadline=tonumber(player:GetAttribute("WP_AdventureDeadline")) or 0
    local secondsLeft=deadline>0 and math.max(0,deadline-os.time()) or 0

    panel.Text=string.format(
        " WONDERPOCKET v1.1 RC\n\n Data Load: %s\n Player Save: %s\n Inventory Load: %s\n Inventory Save: %s\n Furniture Save: %s\n Garden Save: %s\n Remotes: %s\n Plot/Home: %s / %s\n Garden Ready: %s\n Economy: %sC / %sS\n Harvests: %s\n Starter Quest: %s\n Tutorial Step: %s\n Onboarding: %s\n Adventure: %s (%ss)\n Players: %s / Peak %s",
        yes(player:GetAttribute("WP_DataLoaded")==true),
        yes(player:GetAttribute("WP_DataSaveHealthy")~=false),
        yes(player:GetAttribute("WP_InventoryLoaded")==true),
        yes(player:GetAttribute("WP_InventorySaveHealthy")~=false),
        yes(player:GetAttribute("WP_FurnitureSaveHealthy")~=false),
        yes(player:GetAttribute("WP_GardenSaveHealthy")~=false),
        yes(remotes~=nil),
        plotId>0 and tostring(plotId) or "WAIT",
        yes(player:GetAttribute("WP_HomeReady")==true),
        yes(player:GetAttribute("WP_GardenReady")==true),
        tostring(coins),tostring(stars),
        tostring(tonumber(player:GetAttribute("WP_HarvestCount")) or 0),
        tostring(player:GetAttribute("WP_Quest_Starter") or "-"),
        tostring(tutorialStep),
        yes(player:GetAttribute("WP_OnboardingComplete")==true),
        tostring(player:GetAttribute("WP_ActiveAdventure") or "-"),tostring(secondsLeft),
        tostring(workspace:GetAttribute("WP_CurrentPlayers") or 0),
        tostring(workspace:GetAttribute("WP_PeakPlayers") or 0)
    )
end

button.Activated:Connect(function()
    panel.Visible=not panel.Visible
    if panel.Visible then refresh() end
end)

task.spawn(function()
    while task.wait(2) do if panel.Visible then refresh() end end
end)

print("[WONDERPOCKET] v1.1 release-candidate health UI ready")
