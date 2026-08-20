-- WONDERPOCKET Contextual Wondi Reactions v1.2
local Players = game:GetService("Players")

local specialByWondi = {
    Bubbi = "Happy",
    Flamo = "Spark",
    Mossy = "Bloom",
    Lumi = "Glow",
    Zappy = "Zap",
    Puffy = "Float",
}

local watched = {
    "WP_PlacedCount",
    "WP_HarvestCount",
    "WP_TreasureProgress",
    "WP_AdventureCompletions",
}

local connections = {}
local pending = {}
local lastValues = {}
local lastReactionAt = {}

local function special(player)
    return specialByWondi[tostring(player:GetAttribute("ActiveWondi") or "Bubbi")] or "Wave"
end

local function trigger(player, preferred)
    if player:GetAttribute("WP_DataLoaded") ~= true then return end
    if player:GetAttribute("WP_DataReadOnly") == true or player:GetAttribute("WP_DataLoadFailed") == true then return end

    local now = os.clock()
    if now - (lastReactionAt[player] or 0) < .65 then return end
    lastReactionAt[player] = now

    local action = preferred or special(player)
    player:SetAttribute("WP_LastWondiEmote", action)
    player:SetAttribute("WP_WondiEmoteSeq", (tonumber(player:GetAttribute("WP_WondiEmoteSeq")) or 0) + 1)
end

local function watchIncrease(player, attribute, preferred)
    lastValues[player][attribute] = tonumber(player:GetAttribute(attribute)) or 0
    table.insert(connections[player], player:GetAttributeChangedSignal(attribute):Connect(function()
        local previous = lastValues[player] and (lastValues[player][attribute] or 0) or 0
        local current = tonumber(player:GetAttribute(attribute)) or 0
        if lastValues[player] then lastValues[player][attribute] = current end
        if current <= previous then return end
        trigger(player, preferred == "SPECIAL" and special(player) or preferred)
    end))
end

local function watchTrue(player, attribute, preferred)
    local previous = player:GetAttribute(attribute) == true
    table.insert(connections[player], player:GetAttributeChangedSignal(attribute):Connect(function()
        local current = player:GetAttribute(attribute) == true
        if current and not previous then
            trigger(player, preferred == "SPECIAL" and special(player) or preferred)
        end
        previous = current
    end))
end

local function armInventoryPurchase(player)
    if player:GetAttribute("WP_WondiPurchaseReactionArmed") == true then return end
    if player:GetAttribute("WP_InventoryLoaded") ~= true then return end
    player:SetAttribute("WP_WondiPurchaseReactionArmed", true)
    watchIncrease(player, "WP_PurchasedFurnitureCount", "SPECIAL")
end

local function arm(player)
    if connections[player] then return end
    connections[player] = {}
    lastValues[player] = {}

    for _, attribute in ipairs(watched) do
        watchIncrease(player, attribute, attribute == "WP_TreasureProgress" and "Wave" or "SPECIAL")
    end

    -- Session-only retention signals are created after the safe main load, so they
    -- cannot celebrate historical rewards from previous joins.
    watchIncrease(player, "WP_OfflineReward", "Happy")
    watchTrue(player, "WP_DailyRewardClaimed", "SPECIAL")
    watchTrue(player, "WP_QuestStarterRewarded", "SPECIAL")

    table.insert(connections[player], player:GetAttributeChangedSignal("WP_InventoryLoaded"):Connect(function()
        armInventoryPurchase(player)
    end))
    armInventoryPurchase(player)
end

local function bind(player)
    if connections[player] or pending[player] then return end
    pending[player] = true
    task.spawn(function()
        while player.Parent and player:GetAttribute("WP_DataLoaded") ~= true do
            if player:GetAttribute("WP_DataLoadFailed") == true then
                pending[player] = nil
                return
            end
            task.wait(.25)
        end
        pending[player] = nil
        if player.Parent and player:GetAttribute("WP_DataLoaded") == true then
            arm(player)
        end
    end)
end

Players.PlayerAdded:Connect(bind)
for _, player in ipairs(Players:GetPlayers()) do bind(player) end

Players.PlayerRemoving:Connect(function(player)
    if connections[player] then
        for _, connection in ipairs(connections[player]) do connection:Disconnect() end
    end
    connections[player] = nil
    pending[player] = nil
    lastValues[player] = nil
    lastReactionAt[player] = nil
end)

print("[WONDERPOCKET] safe-load contextual Wondi progression reactions loaded")
