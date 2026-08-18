local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local remotes = ReplicatedStorage:FindFirstChild("WONDERPOCKET_Remotes") or Instance.new("Folder")
remotes.Name = "WONDERPOCKET_Remotes"
remotes.Parent = ReplicatedStorage

local PlacementRemote = remotes:FindFirstChild("Placement") or Instance.new("RemoteEvent")
PlacementRemote.Name = "Placement"
PlacementRemote.Parent = remotes

local Store = DataStoreService:GetDataStore("WONDERPOCKET_Furniture_v1")
local templates = {
    CloudBed = Vector3.new(6,2,4), StarLamp = Vector3.new(1.5,4,1.5), RainbowSofa = Vector3.new(6,2.5,2.5),
    BunnyChair = Vector3.new(2.5,3,2.5), ToyChest = Vector3.new(3,2,2), MiniAquarium = Vector3.new(4,3,2),
}

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
    local deadline = os.clock() + 12
    while player.Parent and os.clock() < deadline do
        if (tonumber(player:GetAttribute("WP_PlotIndex")) or 0) > 0 then return true end
        task.wait(.25)
    end
    return false
end

local function insideOwnPlot(player, position)
    local cx = tonumber(player:GetAttribute("WP_PlotCenterX"))
    local cz = tonumber(player:GetAttribute("WP_PlotCenterZ"))
    local hx = tonumber(player:GetAttribute("WP_PlotHalfX"))
    local hz = tonumber(player:GetAttribute("WP_PlotHalfZ"))
    if not (cx and cz and hx and hz) then return false end
    return math.abs(position.X-cx) <= hx and math.abs(position.Z-cz) <= hz
end

local function makeFurniture(player,itemId,cf)
    local size = templates[itemId]
    if not size then return nil end
    local part = Instance.new("Part")
    part.Name=itemId
    part.Size=size
    part.Anchored=true
    part.CanCollide=true
    part.Material=Enum.Material.SmoothPlastic
    part.CFrame=cf
    part:SetAttribute("WP_Owner",player.UserId)
    part:SetAttribute("WP_ItemId",itemId)
    part.Parent=getPlacedFolder(player)
    return part
end

local function serialize(player)
    local out={}
    for _,obj in ipairs(getPlacedFolder(player):GetChildren()) do
        if obj:IsA("BasePart") then
            local _,yaw,_=obj.CFrame:ToOrientation()
            table.insert(out,{id=obj:GetAttribute("WP_ItemId") or obj.Name,x=obj.Position.X,y=obj.Position.Y,z=obj.Position.Z,yaw=math.deg(yaw)})
        end
    end
    return out
end

local function save(player)
    local data=serialize(player)
    local ok, err = pcall(function() Store:SetAsync("u_"..player.UserId,data) end)
    player:SetAttribute("WP_FurnitureSaveHealthy", ok)
    if not ok then warn("[WONDERPOCKET] Furniture save failed", player.UserId, err) end
end

local function load(player)
    if not waitForPlot(player) then
        player:SetAttribute("WP_FurnitureSaveHealthy", false)
        return
    end
    local ok,data=pcall(function() return Store:GetAsync("u_"..player.UserId) end)
    player:SetAttribute("WP_FurnitureSaveHealthy", ok)
    if not ok or type(data)~="table" then return end
    for _,entry in ipairs(data) do
        if templates[entry.id] then
            local pos=Vector3.new(tonumber(entry.x) or 0,tonumber(entry.y) or 1,tonumber(entry.z) or 0)
            if insideOwnPlot(player,pos) then
                makeFurniture(player,entry.id,CFrame.new(pos)*CFrame.Angles(0,math.rad(tonumber(entry.yaw) or 0),0))
            end
        end
    end
end

PlacementRemote.OnServerEvent:Connect(function(player,action,itemId,cf)
    if action=="REQUEST_STATE" then
        PlacementRemote:FireClient(player,"STATE",serialize(player))
        return
    end
    if action~="PLACE" or typeof(cf)~="CFrame" then return end
    if player:GetAttribute("WP_DataLoaded") ~= true then
        PlacementRemote:FireClient(player,"RESULT",false,"DATA_NOT_READY")
        return
    end

    itemId=tostring(itemId)
    if not templates[itemId] then return end

    local p=cf.Position
    if not insideOwnPlot(player,p) then
        PlacementRemote:FireClient(player,"RESULT",false,"OUTSIDE_OWN_PLOT")
        return
    end

    local invKey="WP_INV_"..itemId
    local owned=tonumber(player:GetAttribute(invKey)) or 0
    if owned<=0 then
        PlacementRemote:FireClient(player,"RESULT",false,"NOT_OWNED")
        return
    end

    local folder=getPlacedFolder(player)
    if #folder:GetChildren()>=50 then
        PlacementRemote:FireClient(player,"RESULT",false,"PLACEMENT_LIMIT")
        return
    end

    local _,yaw,_=cf:ToOrientation()
    local q=math.pi/2
    local snappedYaw=math.floor((yaw/q)+0.5)*q
    local snapped=CFrame.new(snap(p.X),math.max(1,snap(p.Y)),snap(p.Z))*CFrame.Angles(0,snappedYaw,0)
    if not insideOwnPlot(player,snapped.Position) then
        PlacementRemote:FireClient(player,"RESULT",false,"OUTSIDE_OWN_PLOT")
        return
    end

    makeFurniture(player,itemId,snapped)
    player:SetAttribute(invKey,owned-1)
    player:SetAttribute("WP_PlacedCount", (tonumber(player:GetAttribute("WP_PlacedCount")) or 0) + 1)
    task.spawn(save,player)
    PlacementRemote:FireClient(player,"RESULT",true,"PLACED",itemId)
end)

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("WP_PlacedCount", tonumber(player:GetAttribute("WP_PlacedCount")) or 0)
    task.spawn(load, player)
end)
Players.PlayerRemoving:Connect(function(player)
    save(player)
    local root=workspace:FindFirstChild("WONDERPOCKET_Placed")
    local folder=root and root:FindFirstChild(tostring(player.UserId))
    if folder then folder:Destroy() end
end)

game:BindToClose(function()
    for _,player in ipairs(Players:GetPlayers()) do save(player) end
end)

print("[WONDERPOCKET] Hardened persistent furniture placement loaded")
