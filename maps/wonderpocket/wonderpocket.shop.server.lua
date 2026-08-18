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
local EconomyAudit = ServerStorage:WaitForChild("WONDERPOCKET_EconomyAudit",20)

local catalog = {
    CloudBed={price=325,category="Furniture"}, StarLamp={price=125,category="Furniture"},
    RainbowSofa={price=450,category="Furniture"}, BunnyChair={price=180,category="Furniture"},
    ToyChest={price=220,category="Furniture"}, MiniAquarium={price=550,category="Furniture"},
}

local lastPurchase = {}
local purchaseBusy = {}

local function inventoryKey(id) return "WP_INV_"..id end
local function getCoins(player) return math.max(0, math.floor(tonumber(player:GetAttribute("Coins")) or 0)) end
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

    local uid = player.UserId
    local now = os.clock()
    if purchaseBusy[uid] then
        ShopRemote:FireClient(player,"RESULT",false,"BUSY",itemId)
        return
    end
    if now-(lastPurchase[uid] or 0)<.25 then
        ShopRemote:FireClient(player,"RESULT",false,"RATE_LIMITED",itemId)
        return
    end
    lastPurchase[uid]=now
    purchaseBusy[uid]=true

    local ok, err = pcall(function()
        itemId=tostring(itemId)
        local item=catalog[itemId]
        if not item then
            ShopRemote:FireClient(player,"RESULT",false,"INVALID_ITEM",itemId)
            return
        end

        local coins=getCoins(player)
        if coins<item.price then
            ShopRemote:FireClient(player,"RESULT",false,"NOT_ENOUGH_COINS",itemId)
            return
        end

        setCoins(player,coins-item.price)
        local key=inventoryKey(itemId)
        player:SetAttribute(key,(tonumber(player:GetAttribute(key)) or 0)+1)
        player:SetAttribute("WP_PurchasedFurnitureCount",(tonumber(player:GetAttribute("WP_PurchasedFurnitureCount")) or 0)+1)
        if EconomyAudit then EconomyAudit:Fire(player,"BUY_FURNITURE",itemId,-item.price,0,0) end
        if CriticalSave then CriticalSave:Fire(player) end
        ShopRemote:FireClient(player,"RESULT",true,"PURCHASED",itemId)
    end)

    purchaseBusy[uid]=nil
    if not ok then
        warn("[WONDERPOCKET] Shop transaction failed", uid, err)
        ShopRemote:FireClient(player,"RESULT",false,"SERVER_ERROR",itemId)
    end
end)

Players.PlayerAdded:Connect(function(player)
    if player:GetAttribute("WP_PurchasedFurnitureCount")==nil then player:SetAttribute("WP_PurchasedFurnitureCount",0) end
end)
Players.PlayerRemoving:Connect(function(player)
    local uid=player.UserId
    lastPurchase[uid]=nil
    purchaseBusy[uid]=nil
end)

print("[WONDERPOCKET] Audited locked critical-save shop transactions loaded")
