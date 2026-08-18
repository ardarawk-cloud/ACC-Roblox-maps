local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local Audit = ServerStorage:FindFirstChild("WONDERPOCKET_EconomyAudit") or Instance.new("BindableEvent")
Audit.Name = "WONDERPOCKET_EconomyAudit"
Audit.Parent = ServerStorage

local seq = {}
local sessionTransactions = 0

local function cleanInt(v)
    return math.floor(tonumber(v) or 0)
end

local function record(player, action, itemId, deltaCoins, deltaStars, deltaSeeds)
    if typeof(player) ~= "Instance" or not player:IsA("Player") then return end
    local uid = player.UserId
    seq[uid] = (seq[uid] or 0) + 1
    sessionTransactions += 1

    player:SetAttribute("WP_EconTxnSeq", seq[uid])
    player:SetAttribute("WP_LastEconomyAction", tostring(action or "UNKNOWN"))
    player:SetAttribute("WP_LastEconomyItem", tostring(itemId or ""))
    player:SetAttribute("WP_LastEconomyDeltaCoins", cleanInt(deltaCoins))
    player:SetAttribute("WP_LastEconomyDeltaStars", cleanInt(deltaStars))
    player:SetAttribute("WP_LastEconomyDeltaSeeds", cleanInt(deltaSeeds))
    player:SetAttribute("WP_LastEconomyAt", os.time())
    player:SetAttribute("WP_EconBalanceCoins", cleanInt(player:GetAttribute("Coins")))
    player:SetAttribute("WP_EconBalanceStars", cleanInt(player:GetAttribute("Stars")))
    player:SetAttribute("WP_EconBalanceSeeds", cleanInt(player:GetAttribute("CarrotSeed")))

    workspace:SetAttribute("WP_EconomySessionTransactions", sessionTransactions)
end

Audit.Event:Connect(record)

Players.PlayerAdded:Connect(function(player)
    seq[player.UserId] = 0
    player:SetAttribute("WP_EconTxnSeq", 0)
end)

Players.PlayerRemoving:Connect(function(player)
    seq[player.UserId] = nil
end)

for _, player in Players:GetPlayers() do
    seq[player.UserId] = tonumber(player:GetAttribute("WP_EconTxnSeq")) or 0
end

workspace:SetAttribute("WP_EconomySessionTransactions", 0)
print("[WONDERPOCKET] Central server economy audit bus loaded")
