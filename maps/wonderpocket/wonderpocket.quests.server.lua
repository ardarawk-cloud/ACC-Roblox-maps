-- WONDERPOCKET Starter Quest Loop v0.2
local Players = game:GetService("Players")

local function reward(player)
    local stats = player:FindFirstChild("leaderstats")
    local coins = stats and stats:FindFirstChild("Coins")
    if coins then coins.Value += 75 end
    local stars = stats and stats:FindFirstChild("Stars")
    if stars then stars.Value += 2 end
    player:SetAttribute("WP_Quest_Starter", "COMPLETE")
    player:SetAttribute("WP_QuestRewardReady", false)
end

local function watch(player)
    player:GetAttributeChangedSignal("WP_HarvestCount"):Connect(function()
        local count = player:GetAttribute("WP_HarvestCount") or 0
        if count >= 3 and player:GetAttribute("WP_Quest_Starter") ~= "COMPLETE" then
            player:SetAttribute("WP_QuestRewardReady", true)
            reward(player)
        end
    end)
end

Players.PlayerAdded:Connect(watch)
for _,p in Players:GetPlayers() do watch(p) end

print("[WONDERPOCKET] Starter quest loop loaded")
