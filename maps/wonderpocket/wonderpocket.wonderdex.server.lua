local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")

local remotes = ReplicatedStorage:FindFirstChild("WONDERPOCKET_Remotes") or Instance.new("Folder")
remotes.Name = "WONDERPOCKET_Remotes"
remotes.Parent = ReplicatedStorage

local DexRemote = remotes:FindFirstChild("WonderDex") or Instance.new("RemoteEvent")
DexRemote.Name = "WonderDex"
DexRemote.Parent = remotes

local Discover = ServerStorage:FindFirstChild("WONDERPOCKET_Discover") or Instance.new("BindableEvent")
Discover.Name = "WONDERPOCKET_Discover"
Discover.Parent = ServerStorage
local CriticalSave = ServerStorage:WaitForChild("WONDERPOCKET_CriticalSave",20)

local Store = DataStoreService:GetDataStore("WONDERPOCKET_WonderDex_v1")
local MAX_RETRIES = 4
local categories = {
    Wondies = {"Bubbi","Flamo","Mossy","Lumi","Zappy","Puffy"},
    Plants = {"Carrot","Strawberry","Sunflower"},
    Furniture = {"CloudBed","StarLamp","RainbowSofa","BunnyChair","ToyChest","MiniAquarium"},
    Badges = {"TreasureIsland"},
    Biomes = {"MeadowPocket","BeachIsland","SnowWorld","CandyWorld","SpaceWorld"},
}

local allowed = {}
for category,list in pairs(categories) do
    allowed[category]={}
    for _,id in ipairs(list) do allowed[category][id]=true end
end

local state,revision,savedRevision,saving,forcePending,connections = {},{},{},{},{},{}

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

local function key(category,id) return "WP_DEX_"..category.."_"..id end

local function blank()
    local data={schemaVersion=1,found={}}
    for category in pairs(categories) do data.found[category]={} end
    data.found.Wondies.Bubbi=true
    data.found.Biomes.MeadowPocket=true
    return data
end

local function normalize(data)
    if type(data)~="table" then data=blank() end
    if type(data.found)~="table" then data.found={} end
    for category,list in pairs(categories) do
        if type(data.found[category])~="table" then data.found[category]={} end
        for _,id in ipairs(list) do data.found[category][id]=data.found[category][id]==true end
    end
    data.found.Wondies.Bubbi=true
    data.found.Biomes.MeadowPocket=true
    data.schemaVersion=1
    return data
end

local function snapshot(player)
    local data=state[player]
    local out={}
    if not data then return out end
    for category,list in pairs(categories) do
        local found=0
        local ids={}
        for _,id in ipairs(list) do
            local has=data.found[category][id]==true
            if has then found+=1 end
            ids[id]=has
        end
        out[category]={found=found,total=#list,ids=ids}
    end
    return out
end

local function markDirty(player) revision[player]=(revision[player] or 0)+1 end

local function save(player,force)
    local data=state[player]
    if not data or player:GetAttribute("WP_DexLoadFailed")==true then return false end
    if saving[player] then if force then forcePending[player]=true end return false end
    local currentRevision=revision[player] or 0
    if not force and currentRevision<=(savedRevision[player] or 0) then return true end

    saving[player]=true
    local targetRevision=currentRevision
    local payload={schemaVersion=1,found={}}
    for category,list in pairs(categories) do
        payload.found[category]={}
        for _,id in ipairs(list) do payload.found[category][id]=data.found[category][id]==true end
    end
    local ok=retry("WonderDex save u_"..player.UserId,function()
        Store:UpdateAsync("u_"..player.UserId,function() return payload end)
    end)
    saving[player]=nil
    player:SetAttribute("WP_DexSaveHealthy",ok)
    if ok then savedRevision[player]=math.max(savedRevision[player] or 0,targetRevision) end

    local rerun=forcePending[player]==true or (revision[player] or 0)>(savedRevision[player] or 0)
    local nextForce=forcePending[player]==true
    forcePending[player]=nil
    if rerun and player.Parent then task.defer(save,player,nextForce) end
    return ok
end

local function discover(player,category,id)
    if not player or not player.Parent then return false end
    if player:GetAttribute("WP_DataReadOnly")==true or player:GetAttribute("WP_DexLoadFailed")==true or player:GetAttribute("WP_DexLoaded")~=true then return false end
    category=tostring(category or "");id=tostring(id or "")
    if not (allowed[category] and allowed[category][id]) then return false end
    local data=state[player]
    if not data or data.found[category][id] then return false end
    data.found[category][id]=true
    player:SetAttribute(key(category,id),true)
    markDirty(player)
    task.spawn(save,player,false)
    DexRemote:FireClient(player,"DISCOVERED",category,id,snapshot(player))
    return true
end

local function scanFurniture(player)
    if player:GetAttribute("WP_DexLoaded")~=true then return end
    for _,id in ipairs(categories.Furniture) do
        if (tonumber(player:GetAttribute("WP_INV_"..id)) or 0)>0 then discover(player,"Furniture",id) end
    end
    local root=workspace:FindFirstChild("WONDERPOCKET_Placed")
    local folder=root and root:FindFirstChild(tostring(player.UserId))
    if folder then
        for _,obj in ipairs(folder:GetChildren()) do
            local id=tostring(obj:GetAttribute("WP_ItemId") or obj.Name)
            discover(player,"Furniture",id)
        end
    end
end

local function syncVerifiedGameplay(player)
    discover(player,"Wondies",player:GetAttribute("ActiveWondi") or "Bubbi")
    discover(player,"Biomes",player:GetAttribute("PocketBiome") or "MeadowPocket")
    if (tonumber(player:GetAttribute("WP_HarvestCount")) or 0)>0 then discover(player,"Plants","Carrot") end
    if player:GetAttribute("WP_TreasureIslandComplete")==true then discover(player,"Badges","TreasureIsland") end
    scanFurniture(player)
end

local function watch(player,attribute,callback)
    table.insert(connections[player],player:GetAttributeChangedSignal(attribute):Connect(callback))
end

local function setup(player)
    player:SetAttribute("WP_DexLoaded",false)
    player:SetAttribute("WP_DexLoadFailed",false)
    local deadline=os.clock()+20
    while player.Parent and os.clock()<deadline do
        if player:GetAttribute("WP_DataLoadFailed")==true then
            player:SetAttribute("WP_DexLoadFailed",true)
            player:SetAttribute("WP_DexSaveHealthy",false)
            return
        end
        if player:GetAttribute("WP_DataLoaded")==true then break end
        task.wait(.25)
    end
    if not player.Parent or player:GetAttribute("WP_DataLoaded")~=true then
        player:SetAttribute("WP_DexLoadFailed",true)
        player:SetAttribute("WP_DexSaveHealthy",false)
        return
    end

    local ok,data=retry("WonderDex load u_"..player.UserId,function() return Store:GetAsync("u_"..player.UserId) end)
    if not ok then
        player:SetAttribute("WP_DexLoadFailed",true)
        player:SetAttribute("WP_DexSaveHealthy",false)
        warn("[WONDERPOCKET] WonderDex load failed closed",player.UserId)
        return
    end

    data=normalize(data)
    state[player]=data;revision[player]=0;savedRevision[player]=0;connections[player]={}
    player:SetAttribute("WP_DexSaveHealthy",true)

    for category,list in pairs(categories) do
        for _,id in ipairs(list) do player:SetAttribute(key(category,id),data.found[category][id]==true) end
    end
    player:SetAttribute("WP_DexLoaded",true)

    watch(player,"ActiveWondi",function() discover(player,"Wondies",player:GetAttribute("ActiveWondi")) end)
    watch(player,"PocketBiome",function() discover(player,"Biomes",player:GetAttribute("PocketBiome")) end)
    watch(player,"WP_HarvestCount",function()
        if (tonumber(player:GetAttribute("WP_HarvestCount")) or 0)>0 then discover(player,"Plants","Carrot") end
    end)
    watch(player,"WP_TreasureIslandComplete",function()
        if player:GetAttribute("WP_TreasureIslandComplete")==true then discover(player,"Badges","TreasureIsland") end
    end)
    watch(player,"WP_PlacedCount",function() task.defer(scanFurniture,player) end)
    for _,id in ipairs(categories.Furniture) do
        watch(player,"WP_INV_"..id,function()
            if (tonumber(player:GetAttribute("WP_INV_"..id)) or 0)>0 then discover(player,"Furniture",id) end
        end)
    end

    task.delay(2,function() if player.Parent then syncVerifiedGameplay(player) end end)
end

Discover.Event:Connect(function(player,category,id)
    if typeof(player)=="Instance" and player:IsA("Player") then discover(player,category,id) end
end)

CriticalSave.Event:Connect(function(player)
    if typeof(player)=="Instance" and player:IsA("Player") and state[player] then task.spawn(save,player,true) end
end)

DexRemote.OnServerEvent:Connect(function(player,action)
    if action=="GET" then
        if player:GetAttribute("WP_DexLoadFailed")==true or player:GetAttribute("WP_DataReadOnly")==true then
            DexRemote:FireClient(player,"NOTICE","DATA_READ_ONLY")
        elseif player:GetAttribute("WP_DexLoaded")==true then
            DexRemote:FireClient(player,"SNAPSHOT",snapshot(player))
        else
            DexRemote:FireClient(player,"NOTICE","DATA_NOT_READY")
        end
    elseif action=="DISCOVER" then
        DexRemote:FireClient(player,"NOTICE","SERVER_AUTHORITATIVE")
    end
end)

Players.PlayerAdded:Connect(function(player) task.spawn(setup,player) end)
for _,player in Players:GetPlayers() do task.spawn(setup,player) end
Players.PlayerRemoving:Connect(function(player)
    local deadline=os.clock()+8
    if saving[player] then forcePending[player]=true end
    while saving[player] and os.clock()<deadline do task.wait(.1) end
    if state[player] then save(player,true) end
    for _,c in ipairs(connections[player] or {}) do c:Disconnect() end
    state[player]=nil;revision[player]=nil;savedRevision[player]=nil;saving[player]=nil;forcePending[player]=nil;connections[player]=nil
end)

game:BindToClose(function()
    for _,player in Players:GetPlayers() do task.spawn(save,player,true) end
    task.wait(4)
end)

print("[WONDERPOCKET] Fail-closed persistent server-authoritative WonderDex loaded")
