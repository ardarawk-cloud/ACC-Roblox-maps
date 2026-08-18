local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:FindFirstChild("WonderPocket_Remotes") or Instance.new("Folder")
remotes.Name = "WonderPocket_Remotes"
remotes.Parent = ReplicatedStorage

local PlacementRemote = remotes:FindFirstChild("Placement") or Instance.new("RemoteEvent")
PlacementRemote.Name = "Placement"
PlacementRemote.Parent = remotes

local templates = {
    CloudBed = Vector3.new(6,2,4),
    StarLamp = Vector3.new(1.5,4,1.5),
    RainbowSofa = Vector3.new(6,2.5,2.5),
    BunnyChair = Vector3.new(2.5,3,2.5),
    ToyChest = Vector3.new(3,2,2),
    MiniAquarium = Vector3.new(4,3,2),
}

local function snap(n)
    return math.floor(n + 0.5)
end

local function getPlacedFolder(player)
    local root = workspace:FindFirstChild("WonderPocket_Placed") or Instance.new("Folder")
    root.Name = "WonderPocket_Placed"
    root.Parent = workspace
    local folder = root:FindFirstChild(tostring(player.UserId)) or Instance.new("Folder")
    folder.Name = tostring(player.UserId)
    folder.Parent = root
    return folder
end

PlacementRemote.OnServerEvent:Connect(function(player, action, itemId, cf)
    if action ~= "PLACE" or typeof(cf) ~= "CFrame" then return end
    itemId = tostring(itemId)
    local size = templates[itemId]
    if not size then return end

    local invKey = "WP_INV_" .. itemId
    local owned = tonumber(player:GetAttribute(invKey)) or 0
    if owned <= 0 then
        PlacementRemote:FireClient(player, "RESULT", false, "NOT_OWNED")
        return
    end

    local folder = getPlacedFolder(player)
    if #folder:GetChildren() >= 50 then
        PlacementRemote:FireClient(player, "RESULT", false, "PLACEMENT_LIMIT")
        return
    end

    local p = cf.Position
    local _, yaw, _ = cf:ToOrientation()
    local quarterTurn = math.pi / 2
    local snappedYaw = math.floor((yaw / quarterTurn) + 0.5) * quarterTurn
    local snapped = CFrame.new(snap(p.X), math.max(1, snap(p.Y)), snap(p.Z)) * CFrame.Angles(0, snappedYaw, 0)

    local part = Instance.new("Part")
    part.Name = itemId
    part.Size = size
    part.Anchored = true
    part.CanCollide = true
    part.Material = Enum.Material.SmoothPlastic
    part.CFrame = snapped
    part:SetAttribute("WP_Owner", player.UserId)
    part:SetAttribute("WP_ItemId", itemId)
    part.Parent = folder

    player:SetAttribute(invKey, owned - 1)
    PlacementRemote:FireClient(player, "RESULT", true, "PLACED", itemId)
end)

print("[WONDERPOCKET] Furniture placement loaded")
