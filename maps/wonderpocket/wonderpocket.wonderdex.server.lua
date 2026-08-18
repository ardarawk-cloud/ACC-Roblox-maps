local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:FindFirstChild("WONDERPOCKET_Remotes") or Instance.new("Folder")
remotes.Name = "WONDERPOCKET_Remotes"
remotes.Parent = ReplicatedStorage

local DexRemote = remotes:FindFirstChild("WonderDex") or Instance.new("RemoteEvent")
DexRemote.Name = "WonderDex"
DexRemote.Parent = remotes

local categories = {
    Wondies = {"Bubbi","Flamo","Mossy","Lumi","Zappy","Puffy"},
    Plants = {"Carrot","Strawberry","Sunflower"},
    Furniture = {"CloudBed","StarLamp","RainbowSofa","BunnyChair","ToyChest","MiniAquarium"},
    Biomes = {"MeadowPocket","BeachIsland","SnowWorld","CandyWorld","SpaceWorld"},
}

local function key(category, id)
    return "WP_DEX_" .. category .. "_" .. id
end

local function countCategory(player, category)
    local found = 0
    local list = categories[category] or {}
    for _, id in ipairs(list) do
        if player:GetAttribute(key(category, id)) == true then
            found += 1
        end
    end
    return found, #list
end

local function snapshot(player)
    local data = {}
    for category in pairs(categories) do
        local found, total = countCategory(player, category)
        data[category] = {found=found,total=total}
    end
    return data
end

DexRemote.OnServerEvent:Connect(function(player, action, category, id)
    if action == "GET" then
        DexRemote:FireClient(player, "SNAPSHOT", snapshot(player))
    elseif action == "DISCOVER" then
        category = tostring(category)
        id = tostring(id)
        local allowed = false
        for _, candidate in ipairs(categories[category] or {}) do
            if candidate == id then allowed = true break end
        end
        if not allowed then return end
        local attr = key(category, id)
        if player:GetAttribute(attr) ~= true then
            player:SetAttribute(attr, true)
            DexRemote:FireClient(player, "DISCOVERED", category, id, snapshot(player))
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute(key("Wondies", "Bubbi"), true)
    player:SetAttribute(key("Biomes", "MeadowPocket"), true)
end)

print("[WONDERPOCKET] WonderDex collection system loaded")
