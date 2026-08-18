local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:FindFirstChild("WonderPocket_Remotes") or Instance.new("Folder")
remotes.Name = "WonderPocket_Remotes"
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
    return tonumber(player:GetAttribute("WP_Coins")) or 0
end

local function setCoins(player, value)
    player:SetAttribute("WP_Coins", math.max(0, math.floor(value)))
end

local function inventoryKey(id)
    return "WP_INV_" .. id
end

ShopRemote.OnServerEvent:Connect(function(player, action, itemId)
    if action == "BUY_COINS" then
        local item = catalog[tostring(itemId)]
        if not item then return end
        local coins = getCoins(player)
        if coins < item.price then
            ShopRemote:FireClient(player, "RESULT", false, "NOT_ENOUGH_COINS", itemId)
            return
        end
        setCoins(player, coins - item.price)
        local key = inventoryKey(itemId)
        player:SetAttribute(key, (tonumber(player:GetAttribute(key)) or 0) + 1)
        ShopRemote:FireClient(player, "RESULT", true, "PURCHASED", itemId)
    elseif action == "GET_CATALOG" then
        ShopRemote:FireClient(player, "CATALOG", catalog)
    end
end)

Players.PlayerAdded:Connect(function(player)
    if player:GetAttribute("WP_Coins") == nil then
        player:SetAttribute("WP_Coins", 250)
    end
end)

print("[WONDERPOCKET] Premium coin shop loaded")
