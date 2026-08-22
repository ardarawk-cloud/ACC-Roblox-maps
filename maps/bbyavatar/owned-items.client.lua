-- BBYAVATAR Owned Items v2
-- Roblox-native wardrobe browser with mobile category filters and local name search.
-- Inventory metadata remains client-side and is never persisted by BBYAVATAR.

local ownedBusy = false
local ownedActiveFilter = "ALL"
local ownedQuery = ""
local ownedCaches = {}

local OWNED_FILTERS = {
    {name="ALL", types={
        Enum.AvatarAssetType.Hat, Enum.AvatarAssetType.HairAccessory, Enum.AvatarAssetType.FaceAccessory,
        Enum.AvatarAssetType.NeckAccessory, Enum.AvatarAssetType.ShoulderAccessory, Enum.AvatarAssetType.FrontAccessory,
        Enum.AvatarAssetType.BackAccessory, Enum.AvatarAssetType.WaistAccessory, Enum.AvatarAssetType.TShirt,
        Enum.AvatarAssetType.Shirt, Enum.AvatarAssetType.Pants, Enum.AvatarAssetType.TShirtAccessory,
        Enum.AvatarAssetType.ShirtAccessory, Enum.AvatarAssetType.PantsAccessory, Enum.AvatarAssetType.JacketAccessory,
        Enum.AvatarAssetType.SweaterAccessory, Enum.AvatarAssetType.ShortsAccessory, Enum.AvatarAssetType.LeftShoeAccessory,
        Enum.AvatarAssetType.RightShoeAccessory, Enum.AvatarAssetType.DressSkirtAccessory,
        Enum.AvatarAssetType.EyebrowAccessory, Enum.AvatarAssetType.EyelashAccessory,
    }},
    {name="HAIR", types={Enum.AvatarAssetType.HairAccessory}},
    {name="FACE", types={Enum.AvatarAssetType.FaceAccessory, Enum.AvatarAssetType.EyebrowAccessory, Enum.AvatarAssetType.EyelashAccessory}},
    {name="TOPS", types={Enum.AvatarAssetType.TShirt, Enum.AvatarAssetType.Shirt, Enum.AvatarAssetType.TShirtAccessory, Enum.AvatarAssetType.ShirtAccessory, Enum.AvatarAssetType.JacketAccessory, Enum.AvatarAssetType.SweaterAccessory}},
    {name="BOTTOMS", types={Enum.AvatarAssetType.Pants, Enum.AvatarAssetType.PantsAccessory, Enum.AvatarAssetType.ShortsAccessory, Enum.AvatarAssetType.DressSkirtAccessory}},
    {name="SHOES", types={Enum.AvatarAssetType.LeftShoeAccessory, Enum.AvatarAssetType.RightShoeAccessory}},
    {name="ACCESSORIES", types={Enum.AvatarAssetType.Hat, Enum.AvatarAssetType.NeckAccessory, Enum.AvatarAssetType.ShoulderAccessory, Enum.AvatarAssetType.FrontAccessory, Enum.AvatarAssetType.BackAccessory, Enum.AvatarAssetType.WaistAccessory}},
}

local FILTER_BY_NAME = {}
for _, filter in ipairs(OWNED_FILTERS) do FILTER_BY_NAME[filter.name] = filter end

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
        Id = id, AssetId = id,
        Name = item.Name or item.name or ("Owned Item " .. tostring(id)),
        AssetType = item.AssetType or item.assetType,
        ItemType = Enum.AvatarItemType.Asset,
        Price = nil,
    }
end

local function cacheFor(name)
    local cache = ownedCaches[name]
    if not cache then
        cache = {items={}, seen={}, pages=nil, finished=false, initialized=false}
        ownedCaches[name] = cache
    end
    return cache
end

local function renderOwnedItems()
    clearContent()
    ownedTrack("OWNED_OPEN")

    local heading = Instance.new("TextLabel")
    heading.BackgroundTransparency = 1
    heading.Size = UDim2.new(1, -220, 0, 34)
    heading.Font = Enum.Font.GothamBlack
    heading.Text = "MY ITEMS"
    heading.TextColor3 = Color3.new(1, 1, 1)
    heading.TextSize = 23
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Parent = content

    local allow = Instance.new("TextButton")
    allow.AnchorPoint = Vector2.new(1, 0)
    allow.Position = UDim2.new(1, 0, 0, 0)
    allow.Size = UDim2.fromOffset(108, 34)
    allow.BackgroundColor3 = Color3.fromRGB(55, 67, 98)
    allow.TextColor3 = Color3.new(1, 1, 1)
    allow.Font = Enum.Font.GothamBold
    allow.TextSize = 9
    allow.Text = "ALLOW INVENTORY"
    allow.Parent = content
    Instance.new("UICorner", allow).CornerRadius = UDim.new(0, 10)

    local reload = Instance.new("TextButton")
    reload.AnchorPoint = Vector2.new(1, 0)
    reload.Position = UDim2.new(1, -116, 0, 0)
    reload.Size = UDim2.fromOffset(92, 34)
    reload.BackgroundColor3 = Color3.fromRGB(42, 47, 61)
    reload.TextColor3 = Color3.new(1, 1, 1)
    reload.Font = Enum.Font.GothamBold
    reload.TextSize = 9
    reload.Text = "REFRESH"
    reload.Parent = content
    Instance.new("UICorner", reload).CornerRadius = UDim.new(0, 10)

    local filters = Instance.new("ScrollingFrame")
    filters.Name = "OwnedFilters"
    filters.BackgroundTransparency = 1
    filters.Position = UDim2.fromOffset(0, 42)
    filters.Size = UDim2.new(1, 0, 0, 36)
    filters.AutomaticCanvasSize = Enum.AutomaticSize.X
    filters.CanvasSize = UDim2.new()
    filters.ScrollBarThickness = 0
    filters.ScrollingDirection = Enum.ScrollingDirection.X
    filters.Parent = content
    local filterLayout = Instance.new("UIListLayout")
    filterLayout.FillDirection = Enum.FillDirection.Horizontal
    filterLayout.Padding = UDim.new(0, 6)
    filterLayout.Parent = filters

    local searchBox = Instance.new("TextBox")
    searchBox.Position = UDim2.fromOffset(0, 86)
    searchBox.Size = UDim2.new(1, 0, 0, 38)
    searchBox.BackgroundColor3 = Color3.fromRGB(29, 31, 39)
    searchBox.TextColor3 = Color3.new(1, 1, 1)
    searchBox.PlaceholderColor3 = Color3.fromRGB(135, 139, 155)
    searchBox.PlaceholderText = "Search loaded owned items…"
    searchBox.Text = ownedQuery
    searchBox.ClearTextOnFocus = false
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 12
    searchBox.Parent = content
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 10)

    local list = Instance.new("ScrollingFrame")
    list.Name = "OwnedItemsList"
    list.BackgroundTransparency = 1
    list.Position = UDim2.fromOffset(0, 132)
    list.Size = UDim2.new(1, 0, 1, -168)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.CanvasSize = UDim2.new()
    list.ScrollBarThickness = 4
    list.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = list

    local loadMore = Instance.new("TextButton")
    loadMore.Size = UDim2.new(1, -4, 0, 42)
    loadMore.BackgroundColor3 = Color3.fromRGB(49, 54, 70)
    loadMore.TextColor3 = Color3.new(1, 1, 1)
    loadMore.Font = Enum.Font.GothamBold
    loadMore.TextSize = 10
    loadMore.Text = "LOAD MORE"
    loadMore.Visible = false
    loadMore.Parent = list
    Instance.new("UICorner", loadMore).CornerRadius = UDim.new(0, 11)

    local function clearCards()
        for _, child in ipairs(list:GetChildren()) do
            if child ~= layout and child ~= loadMore then child:Destroy() end
        end
    end

    local function addCard(item)
        local id = item.Id
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -4, 0, 94)
        card.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        card.Parent = list
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

        local preview = Instance.new("ImageLabel")
        preview.Position = UDim2.fromOffset(8, 8)
        preview.Size = UDim2.fromOffset(78, 78)
        preview.BackgroundColor3 = Color3.fromRGB(21, 23, 29)
        preview.Image = itemThumb(item, id)
        preview.ScaleType = Enum.ScaleType.Fit
        preview.Parent = card
        Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 9)

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Position = UDim2.fromOffset(96, 9)
        title.Size = UDim2.new(1, -292, 0, 35)
        title.Font = Enum.Font.GothamBold
        title.Text = tostring(item.Name)
        title.TextColor3 = Color3.new(1, 1, 1)
        title.TextSize = 12
        title.TextWrapped = true
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = card

        local meta = Instance.new("TextLabel")
        meta.BackgroundTransparency = 1
        meta.Position = UDim2.fromOffset(96, 49)
        meta.Size = UDim2.new(1, -292, 0, 22)
        meta.Font = Enum.Font.Gotham
        meta.Text = "OWNED • ID " .. tostring(id)
        meta.TextColor3 = Color3.fromRGB(160, 165, 182)
        meta.TextSize = 9
        meta.TextXAlignment = Enum.TextXAlignment.Left
        meta.Parent = card

        local save = Instance.new("TextButton")
        save.AnchorPoint = Vector2.new(1, .5)
        save.Position = UDim2.new(1, -10, .5, 0)
        save.Size = UDim2.fromOffset(82, 34)
        save.BackgroundColor3 = savedPicks[id] and Color3.fromRGB(54, 87, 67) or Color3.fromRGB(55, 67, 86)
        save.TextColor3 = Color3.new(1, 1, 1)
        save.Font = Enum.Font.GothamBold
        save.TextSize = 9
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
        try.Position = UDim2.new(1, -100, .5, 0)
        try.Size = UDim2.fromOffset(78, 34)
        try.BackgroundColor3 = Color3.fromRGB(62, 76, 112)
        try.TextColor3 = Color3.new(1, 1, 1)
        try.Font = Enum.Font.GothamBold
        try.TextSize = 9
        try.Text = "TRY ON"
        try.Parent = card
        Instance.new("UICorner", try).CornerRadius = UDim.new(0, 10)
        try.Activated:Connect(function()
            ownedTrack("OWNED_TRY")
            applyTryOn(item)
        end)
    end

    local function renderCache()
        clearCards()
        local cache = cacheFor(ownedActiveFilter)
        local needle = string.lower(ownedQuery or "")
        local shown = 0
        for _, item in ipairs(cache.items) do
            if needle == "" or string.find(string.lower(tostring(item.Name)), needle, 1, true) then
                addCard(item)
                shown += 1
            end
        end
        loadMore.Visible = cache.initialized and not cache.finished
        loadMore.Active = not ownedBusy
        loadMore.AutoButtonColor = not ownedBusy
        loadMore.Text = ownedBusy and "LOADING…" or "LOAD MORE"
        if cache.initialized then
            status.Text = string.format("%d shown • %d loaded • %s", shown, #cache.items, ownedActiveFilter)
        end
    end

    local function appendCurrentPage(cache)
        if not cache.pages then return 0 end
        local added = 0
        for _, raw in ipairs(cache.pages:GetCurrentPage()) do
            local item = normalizeOwnedItem(raw)
            if item and not cache.seen[item.Id] then
                cache.seen[item.Id] = true
                table.insert(cache.items, item)
                added += 1
            end
        end
        cache.finished = cache.pages.IsFinished
        return added
    end

    local function loadFilter(reset)
        if ownedBusy then return end
        ownedBusy = true
        local cache = cacheFor(ownedActiveFilter)
        if reset then
            cache.items = {}; cache.seen = {}; cache.pages = nil; cache.finished = false; cache.initialized = false
        elseif cache.initialized then
            ownedBusy = false
            renderCache()
            return
        end
        status.Text = "Loading " .. ownedActiveFilter .. " items from Roblox…"
        renderCache()
        local filter = FILTER_BY_NAME[ownedActiveFilter] or FILTER_BY_NAME.ALL
        task.spawn(function()
            local ok, pages = pcall(function()
                return AvatarEditorService:GetInventoryAsync(filter.types)
            end)
            if not ok or not pages then
                ownedBusy = false
                status.Text = "Inventory permission is required • tap ALLOW INVENTORY."
                ownedTrack("OWNED_LOAD_FAILED")
                renderCache()
                return
            end
            cache.pages = pages
            cache.initialized = true
            appendCurrentPage(cache)
            ownedBusy = false
            ownedTrack("OWNED_LOADED")
            renderCache()
        end)
    end

    for _, filter in ipairs(OWNED_FILTERS) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(math.max(66, #filter.name * 8 + 24), 32)
        b.BackgroundColor3 = filter.name == ownedActiveFilter and Color3.fromRGB(72, 81, 116) or Color3.fromRGB(35, 37, 46)
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 9
        b.Text = filter.name
        b.Parent = filters
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
        b.Activated:Connect(function()
            if ownedBusy or ownedActiveFilter == filter.name then return end
            ownedActiveFilter = filter.name
            ownedQuery = ""
            ownedTrack("OWNED_FILTER")
            renderOwnedItems()
        end)
    end

    allow.Activated:Connect(function()
        status.Text = "Requesting Roblox inventory permission…"
        pcall(function() AvatarEditorService:PromptAllowInventoryReadAccess() end)
    end)
    reload.Activated:Connect(function() loadFilter(true) end)
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        ownedQuery = searchBox.Text
        ownedTrack("OWNED_SEARCH")
        renderCache()
    end)
    loadMore.Activated:Connect(function()
        if ownedBusy then return end
        local cache = cacheFor(ownedActiveFilter)
        if not cache.pages or cache.finished then return end
        ownedBusy = true
        renderCache()
        status.Text = "Loading more " .. ownedActiveFilter .. " items…"
        task.spawn(function()
            local ok = pcall(function() cache.pages:AdvanceToNextPageAsync() end)
            if ok then
                appendCurrentPage(cache)
                ownedTrack("OWNED_PAGE")
            else
                status.Text = "Could not load more owned items right now."
                ownedTrack("OWNED_LOAD_FAILED")
            end
            ownedBusy = false
            renderCache()
        end)
    end)

    loadFilter(false)
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
        ownedCaches = {}
        if frame.Visible and activeTab == "OWNED" then renderOwnedItems() end
    else
        ownedTrack("OWNED_PERMISSION_DENIED")
        if frame.Visible and activeTab == "OWNED" then status.Text = "Inventory access was not granted." end
    end
end)

print("[BBYAVATAR] Owned Items v2 mobile filters + local search ready")