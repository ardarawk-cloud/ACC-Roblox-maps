local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local remotes = ReplicatedStorage:FindFirstChild("WONDERPOCKET_Remotes") or Instance.new("Folder")
remotes.Name = "WONDERPOCKET_Remotes"
remotes.Parent = ReplicatedStorage

local ShopRemote = remotes:FindFirstChild("Shop") or Instance.new("RemoteEvent")
ShopRemote.Name = "Shop"
ShopRemote.Parent = remotes
local CriticalSave = ServerStorage:WaitForChild("WONDERPOCKET_CriticalSave",20)

local catalog = {
    CloudBed={price=325,category="Furniture"}, StarLamp={price=125,category="Furniture"},
    RainbowSofa={price=450,category="Furniture"}, BunnyChair={price=180,category="Furniture"},
    ToyChest={price=220,category="Furniture"}, MiniAquarium={price=550,category="Furniture"},
}
local lastPurchase = {}

local function inventoryKey(id) return "WP_INV_"..id end
local function getCoins(player) return tonumber(player:GetAttribute("Coins")) or 0 end
local function setCoins(player,value) player:SetAttribute("Coins",math.max(0,math.floor(value))) end

ShopRemote.OnServerEvent:Connect(function(player,action,itemId)
    if action=="GET_CATALOG" then
        ShopRemote:FireClient(player,"CATALOG",catalog)
        return
    end
    if action~="BUY" and action~="BUY_COINS" then return end
    if player:GetAttribute("WP_DataLoaded")~=true or player:GetAttribute("WP_InventoryLoaded")~=true then
        ShopRemote:FireClient(player,"RESULT",false,"DATA_NOT_READY",itemId)
        return
    end

    local now=os.clock()
    if now-(lastPurchase[player.UserId] or 0)<.15 then return end
    lastPurchase[player.UserId]=now

    itemId=tostring(itemId)
    local item=catalog[itemId]
    if not item then return end
    local coins=getCoins(player)
    if coins<item.price then
        ShopRemote:FireClient(player,"RESULT",false,"NOT_ENOUGH_COINS",itemId)
        return
    end

    setCoins(player,coins-item.price)
    local key=inventoryKey(itemId)
    player:SetAttribute(key,(tonumber(player:GetAttribute(key)) or 0)+1)
    player:SetAttribute("WP_PurchasedFurnitureCount",(tonumber(player:GetAttribute("WP_PurchasedFurnitureCount")) or 0)+1)
    if CriticalSave then CriticalSave:Fire(player) end
    ShopRemote:FireClient(player,"RESULT",true,"PURCHASED",itemId)
end)

Players.PlayerAdded:Connect(function(player)
    if player:GetAttribute("WP_PurchasedFurnitureCount")==nil then player:SetAttribute("WP_PurchasedFurnitureCount",0) end
end)
Players.PlayerRemoving:Connect(function(player) lastPurchase[player.UserId]=nil end)

print("[WONDERPOCKET] Critical-save protected shop loaded")
