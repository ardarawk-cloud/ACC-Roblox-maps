local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:FindFirstChild("WONDERPOCKET_Remotes") or Instance.new("Folder")
remotes.Name = "WONDERPOCKET_Remotes"
remotes.Parent = ReplicatedStorage

local AdventureRemote = remotes:FindFirstChild("Adventure") or Instance.new("RemoteEvent")
AdventureRemote.Name = "Adventure"
AdventureRemote.Parent = remotes

local active = {}
local CONFIG = {
    TreasureIsland = {duration=240, rewardCoins=120, rewardStars=1},
}

local function finish(player, success, reason)
    local run = active[player]
    if not run then return end
    active[player] = nil

    if success and not run.rewardGranted then
        run.rewardGranted = true
        player:SetAttribute("Coins", (tonumber(player:GetAttribute("Coins")) or 0) + run.rewardCoins)
        player:SetAttribute("Stars", (tonumber(player:GetAttribute("Stars")) or 0) + run.rewardStars)
        player:SetAttribute("WP_DEX_Badges_TreasureIsland", true)
        player:SetAttribute("WP_AdventureCompleteCount", (tonumber(player:GetAttribute("WP_AdventureCompleteCount")) or 0) + 1)
    end

    AdventureRemote:FireClient(player, "FINISH", success, reason, run.rewardCoins, run.rewardStars)
end

AdventureRemote.OnServerEvent:Connect(function(player, action, adventureId)
    if player:GetAttribute("WP_DataLoaded") ~= true then return end

    if action == "START" then
        adventureId = tostring(adventureId)
        local cfg = CONFIG[adventureId]
        if not cfg or active[player] then return end
        local token = tostring(os.clock()) .. ":" .. tostring(player.UserId)
        active[player] = {
            id = adventureId,
            token = token,
            startedAt = os.clock(),
            deadline = os.clock() + cfg.duration,
            rewardCoins = cfg.rewardCoins,
            rewardStars = cfg.rewardStars,
            treasure = 0,
            rewardGranted = false,
        }
        player:SetAttribute("WP_ActiveAdventure", adventureId)
        AdventureRemote:FireClient(player, "STARTED", adventureId, cfg.duration)
        task.delay(cfg.duration + 1, function()
            local run = active[player]
            if run and run.token == token then
                finish(player, false, "TIME_UP")
                player:SetAttribute("WP_ActiveAdventure", "")
            end
        end)
    elseif action == "TREASURE" then
        local run = active[player]
        if not run or run.id ~= "TreasureIsland" or os.clock() > run.deadline then return end
        run.treasure += 1
        AdventureRemote:FireClient(player, "PROGRESS", run.treasure, 5)
        if run.treasure >= 5 then
            finish(player, true, "TREASURE_COMPLETE")
            player:SetAttribute("WP_ActiveAdventure", "")
        end
    elseif action == "QUIT" then
        finish(player, false, "QUIT")
        player:SetAttribute("WP_ActiveAdventure", "")
    end
end)

Players.PlayerRemoving:Connect(function(player)
    active[player] = nil
end)

print("[WONDERPOCKET] Canonical Treasure Island adventure loop loaded")
