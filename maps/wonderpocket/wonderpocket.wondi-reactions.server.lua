-- WONDERPOCKET Contextual Wondi Reactions v1.1
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

local function trigger(player, preferred)
    local now = os.clock()
    if now - (lastReactionAt[player] or 0) < .65 then return end
    lastReactionAt[player] = now

    local wondi = tostring(player:GetAttribute("ActiveWondi") or "Bubbi")
    local action = preferred or specialByWondi[wondi] or "Wave"
    player:SetAttribute("WP_LastWondiEmote", action)
    player:SetAttribute("WP_WondiEmoteSeq", (tonumber(player:GetAttribute("WP_WondiEmoteSeq")) or 0) + 1)
end

local function arm(player)
    if connections[player] then return end
    connections[player] = {}
    lastValues[player] = {}

    for _, attribute in ipairs(watched) do
        lastValues[player][attribute] = tonumber(player:GetAttribute(attribute)) or 0
        table.insert(connections[player], player:GetAttributeChangedSignal(attribute):Connect(function()
            local previous = lastValues[player] and (lastValues[player][attribute] or 0) or 0
            local current = tonumber(player:GetAttribute(attribute)) or 0
            if lastValues[player] then lastValues[player][attribute] = current end
            if current <= previous then return end

            if attribute == "WP_TreasureProgress" then
                trigger(player, "Wave")
            else
                trigger(player, specialByWondi[tostring(player:GetAttribute("ActiveWondi") or "Bubbi")])
            end
        end))
    end
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

print("[WONDERPOCKET] safe-load contextual Wondi milestone reactions loaded")
