-- WONDERPOCKET Starter Quest Loop v1.0
local Players = game:GetService("Players")

local function reward(player)
    if player:GetAttribute("WP_Quest_Starter") == "COMPLETE" then return end
    player:SetAttribute("Coins", (tonumber(player:GetAttribute("Coins")) or 0) + 75)
    player:SetAttribute("Stars", (tonumber(player:GetAttribute("Stars")) or 0) + 2)
    player:SetAttribute("WP_Quest_Starter", "COMPLETE")
    player:SetAttribute("WP_QuestRewardReady", false)
end

local function evaluate(player)
    local count = tonumber(player:GetAttribute("WP_HarvestCount")) or 0
    if count >= 3 and player:GetAttribute("WP_Quest_Starter") ~= "COMPLETE" then
        player:SetAttribute("WP_QuestRewardReady", true)
        reward(player)
    end
end

local function watch(player)
    if player:GetAttribute("WP_Quest_Starter") == nil then
        player:SetAttribute("WP_Quest_Starter", "HARVEST_3")
    end
    player:GetAttributeChangedSignal("WP_HarvestCount"):Connect(function()
        evaluate(player)
    end)
    task.defer(evaluate, player)
end

Players.PlayerAdded:Connect(watch)
for _, player in Players:GetPlayers() do watch(player) end

print("[WONDERPOCKET] Canonical starter quest loop loaded")
