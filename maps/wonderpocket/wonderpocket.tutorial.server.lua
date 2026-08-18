local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:FindFirstChild("WONDERPOCKET_Remotes") or Instance.new("Folder")
remotes.Name = "WONDERPOCKET_Remotes"
remotes.Parent = ReplicatedStorage

local Tutorial = remotes:FindFirstChild("Tutorial") or Instance.new("RemoteEvent")
Tutorial.Name = "Tutorial"
Tutorial.Parent = remotes

local STEPS = {
    {id="MeetWondi", text="Say hi to your Wondi", done=function(p) return p:GetAttribute("WP_Tutorial_MetWondi") == true end},
    {id="PlantCarrot", text="Plant your first carrot", done=function(p) return (tonumber(p:GetAttribute("WP_PlantedCount")) or 0) >= 1 end},
    {id="BuyFurniture", text="Buy one furniture item from Wonder Shop", done=function(p) return (tonumber(p:GetAttribute("WP_PurchasedFurnitureCount")) or 0) >= 1 end},
    {id="PlaceFurniture", text="Place furniture inside your Pocket plot", done=function(p) return (tonumber(p:GetAttribute("WP_PlacedCount")) or 0) >= 1 end},
    {id="HarvestCarrot", text="Harvest your first carrot", done=function(p) return (tonumber(p:GetAttribute("WP_HarvestCount")) or 0) >= 1 end},
    {id="Treasure", text="Use Adventure Gate and find one treasure", done=function(p) return (tonumber(p:GetAttribute("WP_TreasureProgress")) or 0) >= 1 or p:GetAttribute("WP_TreasureIslandComplete") == true end},
}

local watchedAttributes = {
    "WP_Tutorial_MetWondi",
    "WP_PlantedCount",
    "WP_PurchasedFurnitureCount",
    "WP_PlacedCount",
    "WP_HarvestCount",
    "WP_TreasureProgress",
    "WP_TreasureIslandComplete",
}

local connections = {}

local function evaluate(player)
    if player:GetAttribute("WP_OnboardingComplete") == true then
        player:SetAttribute("WP_TutorialComplete", true)
        player:SetAttribute("WP_TutorialStep", 0)
        player:SetAttribute("WP_TutorialObjective", "Pocket ready!")
        return
    end
    if player:GetAttribute("WP_TutorialStarted") ~= true then return end

    for index, step in ipairs(STEPS) do
        if not step.done(player) then
            player:SetAttribute("WP_TutorialStep", index)
            player:SetAttribute("WP_TutorialStepId", step.id)
            player:SetAttribute("WP_TutorialObjective", step.text)
            Tutorial:FireClient(player, "STEP", index, #STEPS, step.id, step.text)
            return
        end
    end

    player:SetAttribute("WP_TutorialComplete", true)
    player:SetAttribute("WP_TutorialStep", 0)
    player:SetAttribute("WP_TutorialStepId", "COMPLETE")
    player:SetAttribute("WP_TutorialObjective", "Pocket ready!")
    player:SetAttribute("WP_OnboardingComplete", true)
    Tutorial:FireClient(player, "COMPLETE", #STEPS, #STEPS, "COMPLETE", "Your Pocket journey has begun!")
end

local function setup(player)
    local deadline = os.clock() + 20
    while player.Parent and os.clock() < deadline and player:GetAttribute("WP_DataLoaded") ~= true do
        task.wait(.25)
    end
    if not player.Parent then return end

    player:SetAttribute("WP_TutorialComplete", player:GetAttribute("WP_OnboardingComplete") == true)
    if player:GetAttribute("WP_TutorialStarted") == nil then
        player:SetAttribute("WP_TutorialStarted", false)
    end

    connections[player] = {}
    for _, attr in ipairs(watchedAttributes) do
        table.insert(connections[player], player:GetAttributeChangedSignal(attr):Connect(function()
            evaluate(player)
        end))
    end

    if player:GetAttribute("WP_TutorialStarted") == true then evaluate(player) end
end

Tutorial.OnServerEvent:Connect(function(player, action)
    if action ~= "START" or player:GetAttribute("WP_DataLoaded") ~= true then return end
    if player:GetAttribute("WP_OnboardingComplete") == true then return end
    player:SetAttribute("WP_TutorialStarted", true)
    if player:GetAttribute("WP_TutorialStartedAt") == nil then
        player:SetAttribute("WP_TutorialStartedAt", os.time())
    end
    evaluate(player)
end)

Players.PlayerAdded:Connect(function(player) task.spawn(setup, player) end)
for _, player in Players:GetPlayers() do task.spawn(setup, player) end
Players.PlayerRemoving:Connect(function(player)
    for _, connection in ipairs(connections[player] or {}) do connection:Disconnect() end
    connections[player] = nil
end)

print("[WONDERPOCKET] First-session tutorial progression loaded")
