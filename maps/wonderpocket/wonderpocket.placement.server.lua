local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")

local remotes = ReplicatedStorage:FindFirstChild("WONDERPOCKET_Remotes") or Instance.new("Folder")
remotes.Name = "WONDERPOCKET_Remotes"
remotes.Parent = ReplicatedStorage

local PlacementRemote = remotes:FindFirstChild("Placement") or Instance.new("RemoteEvent")
PlacementRemote.Name = "Placement"
PlacementRemote.Parent = remotes

local CriticalSave = ServerStorage:WaitForChild("WONDERPOCKET_CriticalSave",20)
local EconomyAudit = ServerStorage:WaitForChild("WONDERPOCKET_EconomyAudit",20)
local Store = DataStoreService:GetDataStore("WONDERPOCKET_Furniture_v1")
local MAX_RETRIES = 4
local AUTOSAVE_SECONDS = 60

local templates = {
    CloudBed = Vector3.new(6,2,4), StarLamp = Vector3.new(1.5,4,1.5), RainbowSofa = Vector3.new(6,2.5,2.5),
    BunnyChair = Vector3.new(2.5,3,2.5), ToyChest = Vector3.new(3,2,2), MiniAquarium = Vector3.new(4,3,2),
}

local revision = {}
local savedRevision = {}
local saving = {}
local forcePending = {}
local placeBusy = {}
local lastPlace = {}
local lastStateRequest = {}

local function retry(label, fn)
    local lastErr
    for attempt=1,MAX_RETRIES do
        local ok, result = pcall(fn)
        if ok then return true, result end
        lastErr = result
        warn(string.format("[WONDERPOCKET] %s attempt %d failed: %s", label, attempt, tostring(result)))
        task.wait(math.min(2^(attempt-1),6))
    end
    return false,lastErr
end

local function snap(n) return math.floor(n + 0.5) end

local function getPlacedFolder(player)
    local root = workspace:FindFirstChild("WONDERPOCKET_Placed") or Instance.new("Folder")
    root.Name = "WONDERPOCKET_Placed"
    root.Parent = workspace
    local folder = root:FindFirstChild(tostring(player.UserId)) or Instance.new("Folder")
    folder.Name = tostring(player.UserId)
    folder.Parent = root
    return folder
end

local function waitForPlot(player)
    -- Plot assignment is authoritative. Avoid treating scheduler/DataStore delay as
    -- a furniture load failure; stop only on a real data failure or no available plot.
    while player.Parent do
        if player:GetAttribute("WP_DataLoadFailed")==true then return false end
        if player:GetAttribute("WP_HomeReady")==false then return false end
        if (tonumber(player:GetAttribute("WP_PlotIndex")) or 0) > 0 then return true end
        task.wait(.25)
    end
    return false
end

local function plotInfo(player)
    local cx = tonumber(player:GetAttribute("WP_PlotCenterX"))
    local cy = tonumber(player:GetAttribute("WP_PlotCenterY")) or 5
    local cz = tonumber(player:GetAttribute("WP_PlotCenterZ"))
    local hx = tonumber(player:GetAttribute("WP_PlotHalfX"))
    local hz = tonumber(player:GetAttribute("WP_PlotHalfZ"))
    if not (cx and cz and hx and hz) then return nil end
    return cx,cy,cz,hx,hz
end

local function footprintFor(size,yaw)
    local quarter = math.floor((yaw / (math.pi/2)) + 0.5)
    if math.abs(quarter) % 2 == 1 then return size.Z,size.X end
    return size.X,size.Z
end

local function footprintInsideOwnPlot(player, position, size, yaw)
    local cx,_,cz,hx,hz = plotInfo(player)
    if not cx then return false end
    local sx,sz = footprintFor(size,yaw)
    return math.abs(position.X-cx) + sx/2 <= hx and math.abs(position.Z-cz) + sz/2 <= hz
end

local function makeFurniture(player,itemId,cf)
    local size = templates[itemId]
    if not size then return nil end
    local p = Instance.new("Part")
    p.Name=itemId
    p.Size=size
    p.Anchored=true
    p.CanCollide=true
    p.Material=Enum.Material.SmoothPlastic
    p.CFrame=cf
    p:SetAttribute("WP_Owner",player.UserId)
    p:SetAttribute("WP_ItemId",itemId)
    p.Parent=getPlacedFolder(player)
    return p
end

local function serialize(player)
    local cx,cy,cz = plotInfo(player)
    if not cx then return {schemaVersion=3,items={}} end
    local items={}
    for _,obj in ipairs(getPlacedFolder(player):GetChildren()) do
        if obj:IsA("BasePart") then
            local _,yaw,_=obj.CFrame:ToOrientation()
            table.insert(items,{
                id=obj:GetAttribute("WP_ItemId") or obj.Name,
                relX=obj.Position.X-cx,
                relY=obj.Position.Y-cy,
                relZ=obj.Position.Z-cz,
                yaw=math.deg(yaw),
            })
        end
    end
    return {schemaVersion=3,items=items}
end

local function markDirty(player)
    revision[player] = (revision[player] or 0) + 1
end

local function save(player, force)
    if not player or player:GetAttribute("WP_FurnitureLoadFailed")==true then return false end
    if saving[player] then
        if force then forcePending[player] = true end
        return false
    end
    local currentRevision = revision[player] or 0
    if not force and currentRevision <= (savedRevision[player] or 0) then return true end

    saving[player] = true
    local targetRevision = currentRevision
    local data=serialize(player)
    local ok = retry("furniture save u_"..player.UserId,function()
        Store:UpdateAsync("u_"..player.UserId,function() return data end)
    end)
    saving[player] = nil
    player:SetAttribute("WP_FurnitureSaveHealthy",ok)
    if ok then savedRevision[player]=math.max(savedRevision[player] or 0,targetRevision) end

    local rerun = forcePending[player] == true or (revision[player] or 0) > (savedRevision[player] or 0)
    local nextForce = forcePending[player] == true
    forcePending[player] = nil
    if rerun and player.Parent then task.defer(save,player,nextForce) end
    return ok
end

local function resolveSavedPosition(player, entry)
    local cx,cy,cz = plotInfo(player)
    if not cx then return nil end
    if entry.relX ~= nil and entry.relZ ~= nil then
        return Vector3.new(
            cx + (tonumber(entry.relX) or 0),
            cy + (tonumber(entry.relY) or ((tonumber(entry.y) or 6)-cy)),
            cz + (tonumber(entry.relZ) or 0)
        )
    end
    if entry.x ~= nil and entry.z ~= nil then
        local pos=Vector3.new(tonumber(entry.x) or 0,tonumber(entry.y) or 6,tonumber(entry.z) or 0)
        local size=templates[entry.id]
        local yaw=math.rad(tonumber(entry.yaw) or 0)
        if size and footprintInsideOwnPlot(player,pos,size,yaw) then return pos end
    end
    return nil
end

local function load(player)
    player:SetAttribute("WP_FurnitureLoaded",false)
    player:SetAttribute("WP_FurnitureLoadFailed",false)
    if not waitForPlot(player) then
        player:SetAttribute("WP_FurnitureLoadFailed",true)
        player:SetAttribute("WP_FurnitureSaveHealthy",false)
        return
    end
    local ok,data=retry("furniture load u_"..player.UserId,function() return Store:GetAsync("u_"..player.UserId) end)
    if not ok then
        player:SetAttribute("WP_FurnitureLoadFailed",true)
        player:SetAttribute("WP_FurnitureSaveHealthy",false)
        warn("[WONDERPOCKET] Placed furniture load failed closed",player.UserId)
        return
    end

    player:SetAttribute("WP_FurnitureSaveHealthy",true)
    revision[player]=0
    savedRevision[player]=0
    data=type(data)=="table" and data or {schemaVersion=3,items={}}

    local items = type(data.items)=="table" and data.items or data
    local loadedCount=0
    for _,entry in ipairs(items) do
        if type(entry)=="table" and templates[entry.id] then
            local pos=resolveSavedPosition(player,entry)
            local yaw=math.rad(tonumber(entry.yaw) or 0)
            if pos and footprintInsideOwnPlot(player,pos,templates[entry.id],yaw) then
                makeFurniture(player,entry.id,CFrame.new(pos)*CFrame.Angles(0,yaw,0))
                loadedCount+=1
            end
        end
    end
    player:SetAttribute("WP_PlacedCount",math.max(tonumber(player:GetAttribute("WP_PlacedCount")) or 0,loadedCount))
    player:SetAttribute("WP_FurnitureLoaded",true)
end

local function handlePlace(player,itemId,cf)
    local uid = player.UserId
    if placeBusy[uid] then
        PlacementRemote:FireClient(player,"RESULT",false,"BUSY")
        return
    end
    local now = os.clock()
    if now-(lastPlace[uid] or 0)<.2 then
        PlacementRemote:FireClient(player,"RESULT",false,"RATE_LIMITED")
        return
    end
    lastPlace[uid]=now
    placeBusy[uid]=true

    local ok,err=pcall(function()
        if player:GetAttribute("WP_DataLoaded")~=true or player:GetAttribute("WP_InventoryLoaded")~=true or player:GetAttribute("WP_FurnitureLoaded")~=true then
            PlacementRemote:FireClient(player,"RESULT",false,"DATA_NOT_READY")
            return
        end
        if player:GetAttribute("WP_DataReadOnly")==true or player:GetAttribute("WP_InventoryLoadFailed")==true or player:GetAttribute("WP_FurnitureLoadFailed")==true then
            PlacementRemote:FireClient(player,"RESULT",false,"DATA_READ_ONLY")
            return
        end

        itemId=tostring(itemId)
        local size=templates[itemId]
        if not size then
            PlacementRemote:FireClient(player,"RESULT",false,"INVALID_ITEM")
            return
        end

        local p=cf.Position
        local _,yaw,_=cf:ToOrientation()
        local q=math.pi/2
        local snappedYaw=math.floor((yaw/q)+0.5)*q
        local snapped=CFrame.new(snap(p.X),math.max(5.6,snap(p.Y)),snap(p.Z))*CFrame.Angles(0,snappedYaw,0)
        if not footprintInsideOwnPlot(player,snapped.Position,size,snappedYaw) then
            PlacementRemote:FireClient(player,"RESULT",false,"OUTSIDE_OWN_PLOT")
            return
        end

        local invKey="WP_INV_"..itemId
        local owned=math.max(0,math.floor(tonumber(player:GetAttribute(invKey)) or 0))
        if owned<=0 then
            PlacementRemote:FireClient(player,"RESULT",false,"NOT_OWNED")
            return
        end

        local folder=getPlacedFolder(player)
        if #folder:GetChildren()>=50 then
            PlacementRemote:FireClient(player,"RESULT",false,"PLACEMENT_LIMIT")
            return
        end

        makeFurniture(player,itemId,snapped)
        player:SetAttribute(invKey,owned-1)
        player:SetAttribute("WP_PlacedCount",(tonumber(player:GetAttribute("WP_PlacedCount")) or 0)+1)
        markDirty(player)
        if EconomyAudit then EconomyAudit:Fire(player,"PLACE_FURNITURE",itemId,0,0,0) end
        if CriticalSave then CriticalSave:Fire(player) end
        task.spawn(save,player,true)
        PlacementRemote:FireClient(player,"RESULT",true,"PLACED",itemId)
    end)

    placeBusy[uid]=nil
    if not ok then
        warn("[WONDERPOCKET] Placement transaction failed",uid,err)
        PlacementRemote:FireClient(player,"RESULT",false,"SERVER_ERROR")
    end
end

PlacementRemote.OnServerEvent:Connect(function(player,action,itemId,cf)
    if action=="REQUEST_STATE" then
        local uid=player.UserId
        local now=os.clock()
        if now-(lastStateRequest[uid] or 0)<.5 then return end
        lastStateRequest[uid]=now
        if player:GetAttribute("WP_FurnitureLoaded")==true then PlacementRemote:FireClient(player,"STATE",serialize(player)) end
        return
    end
    if action~="PLACE" or typeof(cf)~="CFrame" then return end
    handlePlace(player,itemId,cf)
end)

CriticalSave.Event:Connect(function(player)
    if typeof(player)=="Instance" and player:IsA("Player") and revision[player]~=nil then
        task.spawn(save,player,true)
    end
end)

Players.PlayerAdded:Connect(function(player)
    revision[player]=0
    savedRevision[player]=0
    task.spawn(load,player)
end)

Players.PlayerRemoving:Connect(function(player)
    local deadline=os.clock()+8
    if saving[player] then forcePending[player]=true end
    while saving[player] and os.clock()<deadline do task.wait(.1) end
    if revision[player]~=nil then save(player,true) end
    local root=workspace:FindFirstChild("WONDERPOCKET_Placed")
    local folder=root and root:FindFirstChild(tostring(player.UserId))
    if folder then folder:Destroy() end
    revision[player]=nil
    savedRevision[player]=nil
    saving[player]=nil
    forcePending[player]=nil
    local uid=player.UserId
    placeBusy[uid]=nil
    lastPlace[uid]=nil
    lastStateRequest[uid]=nil
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

print("[WONDERPOCKET] Fail-closed audited furniture placement loaded")
