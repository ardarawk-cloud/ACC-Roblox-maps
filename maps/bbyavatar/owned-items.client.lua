-- BBYAVATAR Owned Items v1
-- Roblox-native inventory browser. Inventory data is read only after Roblox permission,
-- stays client-side, and is never persisted by BBYAVATAR.

local ownedBusy = false
local ownedPages = nil
local ownedLoaded = 0

local OWNED_ASSET_TYPES = {
    Enum.AvatarAssetType.Hat,
    Enum.AvatarAssetType.HairAccessory,
    Enum.AvatarAssetType.FaceAccessory,
    Enum.AvatarAssetType.NeckAccessory,
    Enum.AvatarAssetType.ShoulderAccessory,
    Enum.AvatarAssetType.FrontAccessory,
    Enum.AvatarAssetType.BackAccessory,
    Enum.AvatarAssetType.WaistAccessory,
    Enum.AvatarAssetType.TShirt,
    Enum.AvatarAssetType.Shirt,
    Enum.AvatarAssetType.Pants,
    Enum.AvatarAssetType.TShirtAccessory,
    Enum.AvatarAssetType.ShirtAccessory,
    Enum.AvatarAssetType.PantsAccessory,
    Enum.AvatarAssetType.JacketAccessory,
    Enum.AvatarAssetType.SweaterAccessory,
    Enum.AvatarAssetType.ShortsAccessory,
    Enum.AvatarAssetType.LeftShoeAccessory,
    Enum.AvatarAssetType.RightShoeAccessory,
    Enum.AvatarAssetType.DressSkirtAccessory,
    Enum.AvatarAssetType.EyebrowAccessory,
    Enum.AvatarAssetType.EyelashAccessory,
}

local function ownedTrack(eventName)
    local remote = root:FindFirstChild("TrackEvent")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(eventName) end)
    end
end

local function normalizeOwnedItem(item)
    if typeof(item) ~= "table" then return nil end
    local id = tonumber(item.Id or item.AssetId or item.id)
    if not id or id <= 0 then return nil end
    return {
        Id = id,
        AssetId = id,
        Name = item.Name or item.name or ("Owned Item " .. tostring(id)),
        AssetType = item.AssetType or item.assetType,
        ItemType = Enum.AvatarItemType.Asset,
        Price = nil,
    }
end

local function renderOwnedItems()
    clearContent()
    ownedTrack("OWNED_OPEN")

    local heading = Instance.new("TextLabel")
    heading.BackgroundTransparency = 1
    heading.Size = UDim2.new(1, 0, 0, 38)
    heading.Font = Enum.Font.GothamBlack
    heading.Text = "MY ITEMS"
    heading.TextColor3 = Color3.new(1, 1, 1)
    heading.TextSize = 23
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Parent = content

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(0, 37)
    sub.Size = UDim2.new(1, -220, 0, 30)
    sub.Font = Enum.Font.Gotham
    sub.Text = "Style with avatar items you already own • inventory stays on Roblox"
    sub.TextColor3 = Color3.fromRGB(156, 162, 182)
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = content

    local allow = Instance.new("TextButton")
    allow.AnchorPoint = Vector2.new(1, 0)
    allow.Position = UDim2.new(1, 0, 0, 0)
    allow.Size = UDim2.fromOffset(112, 36)
    allow.BackgroundColor3 = Color3.fromRGB(55, 67, 98)
    allow.TextColor3 = Color3.new(1, 1, 1)
    allow.Font = Enum.Font.GothamBold
    allow.TextSize = 10
    allow.Text = "ALLOW INVENTORY"
    allow.Parent = content
    Instance.new("UICorner", allow).CornerRadius = UDim.new(0, 10)

    local reload = Instance.new("TextButton")
    reload.AnchorPoint = Vector2.new(1, 0)
    reload.Position = UDim2.new(1, -120, 0, 0)
    reload.Size = UDim2.fromOffset(92, 36)
    reload.BackgroundColor3 = Color3.fromRGB(42, 47, 61)
    reload.TextColor3 = Color3.new(1, 1, 1)
    reload.Font = Enum.Font.GothamBold
    reload.TextSize = 10
    reload.Text = "LOAD ITEMS"
    reload.Parent = content
    Instance.new("UICorner", reload).CornerRadius = UDim.new(0, 10)

    local list = Instance.new("ScrollingFrame")
    list.Name = "OwnedItemsList"
    list.BackgroundTransparency = 1
    list.Position = UDim2.fromOffset(0, 72)
    list.Size = UDim2.new(1, 0, 1, -108)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.CanvasSize = UDim2.new()
    list.ScrollBarThickness = 4
    list.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = list

    local loadMore = Instance.new("TextButton")
    loadMore.Size = UDim2.new(1, -4, 0, 44)
    loadMore.BackgroundColor3 = Color3.fromRGB(49, 54, 70)
    loadMore.TextColor3 = Color3.new(1, 1, 1)
    loadMore.Font = Enum.Font.GothamBold
    loadMore.TextSize = 11
    loadMore.Text = "LOAD MORE"
    loadMore.Visible = false
    loadMore.Parent = list
    Instance.new("UICorner", loadMore).CornerRadius = UDim.new(0, 11)

    local function clearCards()
        for _, child in ipairs(list:GetChildren()) do
            if child ~= layout and child ~= loadMore then child:Destroy() end
        end
    end

    local function updateLoadMore()
        local finished = not ownedPages or ownedPages.IsFinished
        loadMore.Visible = not finished
        loadMore.Active = not finished and not ownedBusy
        loadMore.AutoButtonColor = not ownedBusy
        loadMore.Text = ownedBusy and "LOADING…" or "LOAD MORE"
    end

    local function addCard(raw)
        local item = normalizeOwnedItem(raw)
        if not item then return false end
        local id = item.Id

        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -4, 0, 96)
        card.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        card.Parent = list
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

        local preview = Instance.new("ImageLabel")
        preview.Position = UDim2.fromOffset(8, 8)
        preview.Size = UDim2.fromOffset(80, 80)
        preview.BackgroundColor3 = Color3.fromRGB(21, 23, 29)
        preview.Image = itemThumb(item, id)
        preview.ScaleType = Enum.ScaleType.Fit
        preview.Parent = card
        Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 9)

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Position = UDim2.fromOffset(98, 10)
        title.Size = UDim2.new(1, -300, 0, 34)
        title.Font = Enum.Font.GothamBold
        title.Text = tostring(item.Name)
        title.TextColor3 = Color3.new(1, 1, 1)
        title.TextSize = 12
        title.TextWrapped = true
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = card

        local meta = Instance.new("TextLabel")
        meta.BackgroundTransparency = 1
        meta.Position = UDim2.fromOffset(98, 50)
        meta.Size = UDim2.new(1, -300, 0, 24)
        meta.Font = Enum.Font.Gotham
        meta.Text = "OWNED • ID " .. tostring(id)
        meta.TextColor3 = Color3.fromRGB(160, 165, 182)
        meta.TextSize = 10
        meta.TextXAlignment = Enum.TextXAlignment.Left
        meta.Parent = card

        local save = Instance.new("TextButton")
        save.AnchorPoint = Vector2.new(1, .5)
        save.Position = UDim2.new(1, -10, .5, 0)
        save.Size = UDim2.fromOffset(86, 36)
        save.BackgroundColor3 = savedPicks[id] and Color3.fromRGB(54, 87, 67) or Color3.fromRGB(55, 67, 86)
        save.TextColor3 = Color3.new(1, 1, 1)
        save.Font = Enum.Font.GothamBold
        save.TextSize = 10
        save.Text = savedPicks[id] and "SAVED ✓" or "SAVE PICK"
        save.Parent = card
        Instance.new("UICorner", save).CornerRadius = UDim.new(0, 10)
        save.Activated:Connect(function()
            if savedPicks[id] then status.Text = "Already in Saved Picks." return end
            local ok, message = savePick(item)
            status.Text = message
            if ok then
                save.Text = "SAVED ✓"
                save.BackgroundColor3 = Color3.fromRGB(54, 87, 67)
                ownedTrack("OWNED_SAVE")
            end
        end)

        local try = Instance.new("TextButton")
        try.AnchorPoint = Vector2.new(1, .5)
        try.Position = UDim2.new(1, -104, .5, 0)
        try.Size = UDim2.fromOffset(82, 36)
        try.BackgroundColor3 = Color3.fromRGB(62, 76, 112)
        try.TextColor3 = Color3.new(1, 1, 1)
        try.Font = Enum.Font.GothamBold
        try.TextSize = 10
        try.Text = "TRY ON"
        try.Parent = card
        Instance.new("UICorner", try).CornerRadius = UDim.new(0, 10)
        try.Activated:Connect(function()
            ownedTrack("OWNED_TRY")
            applyTryOn(item)
        end)
        return true
    end

    local function appendCurrentPage()
        if not ownedPages then return 0 end
        local added = 0
        for _, raw in ipairs(ownedPages:GetCurrentPage()) do
            if addCard(raw) then added += 1; ownedLoaded += 1 end
        end
        return added
    end

    local function loadOwned(reset)
        if ownedBusy then return end
        ownedBusy = true
        if reset then
            clearCards()
            ownedPages = nil
            ownedLoaded = 0
        end
        status.Text = "Loading owned avatar items from Roblox…"
        updateLoadMore()
        task.spawn(function()
            local ok, pages = pcall(function()
                return AvatarEditorService:GetInventoryAsync(OWNED_ASSET_TYPES)
            end)
            if not ok or not pages then
                status.Text = "Inventory permission is required • tap ALLOW INVENTORY."
                ownedTrack("OWNED_LOAD_FAILED")
                ownedBusy = false
                updateLoadMore()
                return
            end
            ownedPages = pages
            local added = appendCurrentPage()
            status.Text = string.format("%d owned items loaded • %d on this page", ownedLoaded, added)
            ownedTrack("OWNED_LOADED")
            ownedBusy = false
            updateLoadMore()
        end)
    end

    allow.Activated:Connect(function()
        status.Text = "Requesting Roblox inventory permission…"
        pcall(function() AvatarEditorService:PromptAllowInventoryReadAccess() end)
    end)
    reload.Activated:Connect(function() loadOwned(true) end)
    loadMore.Activated:Connect(function()
        if ownedBusy or not ownedPages or ownedPages.IsFinished then return end
        ownedBusy = true
        updateLoadMore()
        status.Text = "Loading more owned items…"
        task.spawn(function()
            local ok = pcall(function() ownedPages:AdvanceToNextPageAsync() end)
            if ok then
                local added = appendCurrentPage()
                status.Text = string.format("%d owned items loaded • %d added", ownedLoaded, added)
                ownedTrack("OWNED_PAGE")
            else
                status.Text = "Could not load more owned items right now."
                ownedTrack("OWNED_LOAD_FAILED")
            end
            ownedBusy = false
            updateLoadMore()
        end)
    end)

    loadOwned(true)
end

renderers.OWNED = renderOwnedItems
local ownedTab = Instance.new("TextButton")
ownedTab.Name = "OwnedTab"
ownedTab.Size = UDim2.fromOffset(94, 38)
ownedTab.BackgroundColor3 = Color3.fromRGB(35, 37, 46)
ownedTab.TextColor3 = Color3.new(1, 1, 1)
ownedTab.Font = Enum.Font.GothamBold
ownedTab.TextSize = 12
ownedTab.Text = "MY ITEMS"
ownedTab.Parent = tabs
Instance.new("UICorner", ownedTab).CornerRadius = UDim.new(0, 10)
ownedTab.Activated:Connect(function() selectTab("OWNED") end)

AvatarEditorService.PromptAllowInventoryReadAccessCompleted:Connect(function(result)
    if result == Enum.AvatarPromptResult.Success then
        ownedTrack("OWNED_PERMISSION_SUCCESS")
        if frame.Visible and activeTab == "OWNED" then renderOwnedItems() end
    else
        ownedTrack("OWNED_PERMISSION_DENIED")
        if frame.Visible and activeTab == "OWNED" then status.Text = "Inventory access was not granted." end
    end
end)

print("[BBYAVATAR] Owned Items v1 Roblox-native inventory styling ready")