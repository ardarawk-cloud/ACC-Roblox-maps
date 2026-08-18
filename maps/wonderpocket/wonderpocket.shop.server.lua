local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:FindFirstChild("WONDERPOCKET_Remotes") or Instance.new("Folder")
remotes.Name = "WONDERPOCKET_Remotes"
remotes.Parent = ReplicatedStorage

local ShopRemote = remotes:FindFirstChild("Shop") or Instance.new("RemoteEvent")
ShopRemote.Name = "Shop"
ShopRemote.Parent = remotes

local catalog = {
    CloudBed = {price=325, category="Furniture"},
    StarLamp = {price=125, category="Furniture"},
    RainbowSofa = {price=450, category="Furniture"},
    BunnyChair = {price=180, category="Furniture"},
    ToyChest = {price=220, category="Furniture"},
    MiniAquarium = {price=550, category="Furniture"},
}

local function getCoins(player)
    return tonumber(player:GetAttribute("Coins")) or 0
end

local function setCoins(player, value)
    player:SetAttribute("Coins", math.max(0, math.floor(value)))
end

local function inventoryKey(id)
    return "WP_INV_" .. id
end

ShopRemote.OnServerEvent:Connect(function(player, action, itemId)
    if player:GetAttribute("WP_DataLoaded") ~= true then
        ShopRemote:FireClient(player, "RESULT", false, "DATA_NOT_READY", itemId)
        return
    end

    if action == "BUY" or action == "BUY_COINS" then
        itemId = tostring(itemId)
        local item = catalog[itemId]
        if not item then return end

        local coins = getCoins(player)
        if coins < item.price then
            ShopRemote:FireClient(player, "RESULT", false, "NOT_ENOUGH_COINS", itemId)
            return
        end

        setCoins(player, coins - item.price)
        local key = inventoryKey(itemId)
        player:SetAttribute(key, (tonumber(player:GetAttribute(key)) or 0) + 1)
        player:SetAttribute("WP_PurchasedFurnitureCount", (tonumber(player:GetAttribute("WP_PurchasedFurnitureCount")) or 0) + 1)
        ShopRemote:FireClient(player, "RESULT", true, "PURCHASED", itemId)
    elseif action == "GET_CATALOG" then
        ShopRemote:FireClient(player, "CATALOG", catalog)
    end
end)

Players.PlayerAdded:Connect(function(player)
    if player:GetAttribute("WP_PurchasedFurnitureCount") == nil then
        player:SetAttribute("WP_PurchasedFurnitureCount", 0)
    end
end)

print("[WONDERPOCKET] Canonical economy shop loaded")
