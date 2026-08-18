local Players = game:GetService("Players")

local SAVE_HEALTH_ATTRIBUTES = {
    "WP_DataSaveHealthy",
    "WP_InventorySaveHealthy",
    "WP_FurnitureSaveHealthy",
    "WP_GardenSaveHealthy",
    "WP_DexSaveHealthy",
}

local connections = {}

local function degraded(player)
    for _, attribute in ipairs(SAVE_HEALTH_ATTRIBUTES) do
        if player:GetAttribute(attribute) == false then return true, attribute end
    end
    return false, nil
end

local function evaluate(player)
    if player:GetAttribute("WP_DataLoaded") ~= true then return end
    if player:GetAttribute("WP_SaveHealthReadOnly") == true then return end

    local bad, attribute = degraded(player)
    if not bad then return end

    player:SetAttribute("WP_SaveHealthReadOnly", true)
    player:SetAttribute("WP_SaveHealthFailure", tostring(attribute or "UNKNOWN"))
    player:SetAttribute("WP_DataReadOnly", true)
    warn("[WONDERPOCKET] Persistence save health degraded; session frozen until rejoin", player.UserId, attribute)
end

local function bind(player)
    connections[player] = {}
    for _, attribute in ipairs(SAVE_HEALTH_ATTRIBUTES) do
        table.insert(connections[player], player:GetAttributeChangedSignal(attribute):Connect(function()
            evaluate(player)
        end))
    end
    table.insert(connections[player], player:GetAttributeChangedSignal("WP_DataLoaded"):Connect(function()
        evaluate(player)
    end))
    evaluate(player)
end

Players.PlayerAdded:Connect(bind)
for _, player in Players:GetPlayers() do bind(player) end
Players.PlayerRemoving:Connect(function(player)
    for _, connection in ipairs(connections[player] or {}) do connection:Disconnect() end
    connections[player] = nil
end)

print("[WONDERPOCKET] Save-health fail-closed session guard loaded")
