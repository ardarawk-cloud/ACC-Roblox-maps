local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")

local Store = DataStoreService:GetDataStore("WONDERPOCKET_FurnitureInventory_v1")
local CriticalSave = ServerStorage:WaitForChild("WONDERPOCKET_CriticalSave",20)
local IDS = {"CloudBed","StarLamp","RainbowSofa","BunnyChair","ToyChest","MiniAquarium"}
local MAX_RETRIES = 4
local AUTOSAVE_SECONDS = 60

local connections = {}
local revision = {}
local savedRevision = {}
local saving = {}
local forcePending = {}

local function key(id) return "WP_INV_"..id end

local function retry(label,fn)
    local lastErr
    for attempt=1,MAX_RETRIES do
        local ok,result=pcall(fn)
        if ok then return true,result end
        lastErr=result
        warn(string.format("[WONDERPOCKET] %s attempt %d failed: %s",label,attempt,tostring(result)))
        task.wait(math.min(2^(attempt-1),6))
    end
    return false,lastErr
end

local function waitForData(player)
    local deadline=os.clock()+20
    while player.Parent and os.clock()<deadline do
        if player:GetAttribute("WP_DataLoadFailed")==true then return false end
        if player:GetAttribute("WP_DataLoaded")==true then return true end
        task.wait(.25)
    end
    return false
end

local function snapshot(player)
    local data={items={},purchased=math.max(0,math.floor(tonumber(player:GetAttribute("WP_PurchasedFurnitureCount")) or 0))}
    for _,id in ipairs(IDS) do
        data.items[id]=math.max(0,math.floor(tonumber(player:GetAttribute(key(id))) or 0))
    end
    return data
end

local function markDirty(player)
    revision[player]=(revision[player] or 0)+1
end

local function save(player,force)
    if revision[player]==nil or player:GetAttribute("WP_InventoryLoadFailed")==true then return false end
    if saving[player] then
        if force then forcePending[player]=true end
        return false
    end
    local currentRevision=revision[player] or 0
    if not force and currentRevision<=(savedRevision[player] or 0) then return true end

    saving[player]=true
    local targetRevision=currentRevision
    local payload=snapshot(player)
    local ok=retry("inventory save u_"..player.UserId,function()
        Store:UpdateAsync("u_"..player.UserId,function() return payload end)
    end)
    saving[player]=nil
    player:SetAttribute("WP_InventorySaveHealthy",ok)
    if ok then savedRevision[player]=math.max(savedRevision[player] or 0,targetRevision) end

    local rerun=forcePending[player]==true or (revision[player] or 0)>(savedRevision[player] or 0)
    local nextForce=forcePending[player]==true
    forcePending[player]=nil
    if rerun and player.Parent then task.defer(save,player,nextForce) end
    return ok
end

local function setup(player)
    player:SetAttribute("WP_InventoryLoaded",false)
    player:SetAttribute("WP_InventoryLoadFailed",false)
    if not waitForData(player) then
        player:SetAttribute("WP_InventorySaveHealthy",false)
        return
    end

    local ok,data=retry("inventory load u_"..player.UserId,function() return Store:GetAsync("u_"..player.UserId) end)
    if not ok then
        player:SetAttribute("WP_InventoryLoadFailed",true)
        player:SetAttribute("WP_InventorySaveHealthy",false)
        warn("[WONDERPOCKET] Furniture inventory load failed closed",player.UserId)
        return
    end

    data=type(data)=="table" and data or {items={},purchased=0}
    local items=type(data.items)=="table" and data.items or {}

    revision[player]=0
    savedRevision[player]=0
    connections[player]={}
    for _,id in ipairs(IDS) do
        player:SetAttribute(key(id),math.max(0,math.floor(tonumber(items[id]) or 0)))
    end
    player:SetAttribute("WP_PurchasedFurnitureCount",math.max(0,math.floor(tonumber(data.purchased) or 0)))
    player:SetAttribute("WP_InventoryLoaded",true)
    player:SetAttribute("WP_InventorySaveHealthy",true)

    for _,id in ipairs(IDS) do
        table.insert(connections[player],player:GetAttributeChangedSignal(key(id)):Connect(function() markDirty(player) end))
    end
    table.insert(connections[player],player:GetAttributeChangedSignal("WP_PurchasedFurnitureCount"):Connect(function() markDirty(player) end))
end

CriticalSave.Event:Connect(function(player)
    if typeof(player)=="Instance" and player:IsA("Player") and revision[player]~=nil then
        task.spawn(save,player,true)
    end
end)

Players.PlayerAdded:Connect(function(player) task.spawn(setup,player) end)
for _,player in Players:GetPlayers() do task.spawn(setup,player) end

Players.PlayerRemoving:Connect(function(player)
    local deadline=os.clock()+8
    if saving[player] then forcePending[player]=true end
    while saving[player] and os.clock()<deadline do task.wait(.1) end
    if revision[player]~=nil then save(player,true) end
    for _,c in ipairs(connections[player] or {}) do c:Disconnect() end
    connections[player]=nil
    revision[player]=nil
    savedRevision[player]=nil
    saving[player]=nil
    forcePending[player]=nil
end)

task.spawn(function()
    while task.wait(AUTOSAVE_SECONDS) do
        for _,player in Players:GetPlayers() do task.spawn(save,player,false) end
    end
end)

game:BindToClose(function()
    for _,player in Players:GetPlayers() do task.spawn(save,player,true) end
    task.wait(4)
end)

print("[WONDERPOCKET] Fail-closed revision-safe furniture inventory loaded")
