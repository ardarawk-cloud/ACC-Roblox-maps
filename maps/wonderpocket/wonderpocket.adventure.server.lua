local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:FindFirstChild("WONDERPOCKET_Remotes") or Instance.new("Folder")
remotes.Name = "WONDERPOCKET_Remotes"
remotes.Parent = ReplicatedStorage

local AdventureRemote = remotes:FindFirstChild("Adventure") or Instance.new("RemoteEvent")
AdventureRemote.Name = "Adventure"
AdventureRemote.Parent = remotes

local CONFIG = {
    TreasureIsland = {duration=240, rewardCoins=120, rewardStars=1, serverAuthoritative=true},
}

AdventureRemote.OnServerEvent:Connect(function(player, action, adventureId)
    if player:GetAttribute("WP_DataLoaded") ~= true then return end

    if action == "GET_CATALOG" then
        AdventureRemote:FireClient(player, "CATALOG", CONFIG)
    elseif action == "GET_STATUS" then
        AdventureRemote:FireClient(
            player,
            "STATUS",
            tostring(player:GetAttribute("WP_ActiveAdventure") or ""),
            tonumber(player:GetAttribute("WP_TreasureProgress")) or 0,
            player:GetAttribute("WP_TreasureIslandComplete") == true
        )
    elseif action == "QUIT" then
        local id = tostring(player:GetAttribute("WP_ActiveAdventure") or "")
        if id ~= "" then
            player:SetAttribute("WP_ActiveAdventure", "")
            AdventureRemote:FireClient(player, "FINISH", false, "QUIT", 0, 0)
        end
    elseif action == "START" or action == "TREASURE" then
        -- Intentionally rejected. Adventure start/progress/rewards are server-authoritative.
        -- START comes from the in-world Adventure Gate and TREASURE comes from server-owned chest prompts.
        AdventureRemote:FireClient(player, "NOTICE", "SERVER_AUTHORITATIVE")
    end
end)

Players.PlayerRemoving:Connect(function(player)
    player:SetAttribute("WP_ActiveAdventure", nil)
end)

print("[WONDERPOCKET] Server-authoritative adventure API loaded")
