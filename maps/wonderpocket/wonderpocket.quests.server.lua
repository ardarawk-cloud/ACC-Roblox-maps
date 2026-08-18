-- WONDERPOCKET Starter Quest Loop v1.1
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local CriticalSave = ServerStorage:WaitForChild("WONDERPOCKET_CriticalSave", 20)

local function reward(player)
    if player:GetAttribute("WP_QuestStarterRewarded") == true then
        player:SetAttribute("WP_Quest_Starter", "COMPLETE")
        return
    end
    player:SetAttribute("WP_QuestStarterRewarded", true)
    player:SetAttribute("WP_Quest_Starter", "COMPLETE")
    player:SetAttribute("WP_QuestRewardReady", false)
    player:SetAttribute("Coins", (tonumber(player:GetAttribute("Coins")) or 0) + 75)
    player:SetAttribute("Stars", (tonumber(player:GetAttribute("Stars")) or 0) + 2)
    if CriticalSave then CriticalSave:Fire(player) end
end

local function evaluate(player)
    if player:GetAttribute("WP_DataLoaded") ~= true then return end
    if player:GetAttribute("WP_QuestStarterRewarded") == true then
        player:SetAttribute("WP_Quest_Starter", "COMPLETE")
        player:SetAttribute("WP_QuestRewardReady", false)
        return
    end
    local count = tonumber(player:GetAttribute("WP_HarvestCount")) or 0
    if count >= 3 then
        player:SetAttribute("WP_QuestRewardReady", true)
        reward(player)
    end
end

local function watch(player)
    local deadline = os.clock() + 20
    while player.Parent and os.clock() < deadline and player:GetAttribute("WP_DataLoaded") ~= true do task.wait(.25) end
    if not player.Parent then return end
    player:GetAttributeChangedSignal("WP_HarvestCount"):Connect(function() evaluate(player) end)
    evaluate(player)
end

Players.PlayerAdded:Connect(function(player) task.spawn(watch, player) end)
for _, player in Players:GetPlayers() do task.spawn(watch, player) end

print("[WONDERPOCKET] Persistent idempotent starter quest loaded")
