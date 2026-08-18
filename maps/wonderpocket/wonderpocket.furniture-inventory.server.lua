local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local Store = DataStoreService:GetDataStore("WONDERPOCKET_FurnitureInventory_v1")
local IDS = {"CloudBed","StarLamp","RainbowSofa","BunnyChair","ToyChest","MiniAquarium"}
local connections = {}
local dirty = {}

local function key(id) return "WP_INV_" .. id end

local function waitForData(player)
    local deadline = os.clock() + 20
    while player.Parent and os.clock() < deadline do
        if player:GetAttribute("WP_DataLoaded") == true then return true end
        task.wait(.25)
    end
    return false
end

local function snapshot(player)
    local data = {items={}, purchased=tonumber(player:GetAttribute("WP_PurchasedFurnitureCount")) or 0}
    for _, id in ipairs(IDS) do
        data.items[id] = math.max(0, math.floor(tonumber(player:GetAttribute(key(id))) or 0))
    end
    return data
end

local function save(player, force)
    if not force and not dirty[player] then return true end
    local payload = snapshot(player)
    local ok, err = pcall(function()
        Store:UpdateAsync("u_"..player.UserId, function()
            return payload
        end)
    end)
    player:SetAttribute("WP_InventorySaveHealthy", ok)
    if ok then dirty[player] = nil else warn("[WONDERPOCKET] Furniture inventory save failed", player.UserId, err) end
    return ok
end

local function setup(player)
    if not waitForData(player) then
        player:SetAttribute("WP_InventorySaveHealthy", false)
        return
    end

    local ok, data = pcall(function() return Store:GetAsync("u_"..player.UserId) end)
    data = ok and type(data)=="table" and data or {items={}, purchased=0}
    local items = type(data.items)=="table" and data.items or {}
    for _, id in ipairs(IDS) do
        player:SetAttribute(key(id), math.max(0, math.floor(tonumber(items[id]) or 0)))
    end
    player:SetAttribute("WP_PurchasedFurnitureCount", math.max(0, math.floor(tonumber(data.purchased) or 0)))
    player:SetAttribute("WP_InventoryLoaded", true)
    player:SetAttribute("WP_InventorySaveHealthy", ok)

    connections[player] = {}
    for _, id in ipairs(IDS) do
        table.insert(connections[player], player:GetAttributeChangedSignal(key(id)):Connect(function() dirty[player]=true end))
    end
    table.insert(connections[player], player:GetAttributeChangedSignal("WP_PurchasedFurnitureCount"):Connect(function() dirty[player]=true end))
end

Players.PlayerAdded:Connect(function(player) task.spawn(setup, player) end)
for _, player in Players:GetPlayers() do task.spawn(setup, player) end

Players.PlayerRemoving:Connect(function(player)
    save(player, true)
    for _, c in ipairs(connections[player] or {}) do c:Disconnect() end
    connections[player]=nil
    dirty[player]=nil
end)

task.spawn(function()
    while task.wait(60) do
        for _, player in Players:GetPlayers() do
            if dirty[player] then task.spawn(save, player, false) end
        end
    end
end)

game:BindToClose(function()
    for _, player in Players:GetPlayers() do task.spawn(save, player, true) end
    task.wait(3)
end)

print("[WONDERPOCKET] Persistent furniture inventory loaded")
