-- BBYAVATAR Saved Picks shortlist with privacy-safe cloud sync.
-- Server persistence stores only Roblox asset IDs. Catalog metadata remains transient on the client.
-- If DataStore access is temporarily unavailable, the shortlist gracefully falls back to session-only behavior.

local savedPicks = {}
local savedPickOrder = {}
local MAX_SAVED_PICKS = 24
local picksRemote = root:FindFirstChild("SavedPicksRequest")
local picksCloudReady = picksRemote and picksRemote:IsA("RemoteFunction") or false
local picksLoading = false

local function picksTrack(eventName)
    local remote = root:FindFirstChild("TrackEvent")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(eventName) end)
    end
end

local function pickId(item)
    return tonumber(item and (item.Id or item.AssetId or item.id))
end

local function cloudRequest(action, id)
    if not picksCloudReady then return false, nil, "NO_REMOTE" end
    local ok, response = pcall(function()
        return picksRemote:InvokeServer(action, id)
    end)
    if not ok or typeof(response) ~= "table" then return false, nil, "REMOTE_FAILED" end
    return response.ok == true, response, response.code
end

local function addLocalPick(item)
    local id = pickId(item)
    if not id or savedPicks[id] then return false end
    if #savedPickOrder >= MAX_SAVED_PICKS then return false end
    savedPicks[id] = {
        Id = id,
        AssetId = id,
        Name = item.Name or item.name or ("Catalog Item " .. tostring(id)),
        Price = item.Price or item.LowestPrice or item.price,
        ItemType = item.ItemType or item.itemType,
        AssetType = item.AssetType or item.assetType,
    }
    table.insert(savedPickOrder, id)
    return true
end

local function hydratePick(id)
    local item = savedPicks[id]
    if not item then return end
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(id, Enum.InfoType.Asset)
    end)
    if not ok or typeof(info) ~= "table" or not savedPicks[id] then return end
    item.Name = info.Name or item.Name
    item.Price = info.PriceInRobux or item.Price
    item.AssetType = info.AssetTypeId or item.AssetType
end

local function replaceFromCloud(ids)
    if typeof(ids) ~= "table" then return end
    savedPicks = {}
    savedPickOrder = {}
    for _, rawId in ipairs(ids) do
        local id = tonumber(rawId)
        if id and id > 0 and not savedPicks[id] and #savedPickOrder < MAX_SAVED_PICKS then
            savedPicks[id] = {Id = id, AssetId = id, Name = "Loading catalog item…"}
            table.insert(savedPickOrder, id)
        end
    end
    for _, id in ipairs(savedPickOrder) do task.spawn(hydratePick, id) end
end

local function loadCloudPicks()
    if picksLoading or not picksCloudReady then return end
    picksLoading = true
    task.spawn(function()
        local ok, response = cloudRequest("LOAD")
        if ok and response then
            replaceFromCloud(response.ids)
            picksTrack("PICK_CLOUD_LOAD")
        else
            picksCloudReady = false
        end
        picksLoading = false
    end)
end

local function savePick(item)
    local id = pickId(item)
    if not id then return false, "This catalog item cannot be shortlisted." end
    if savedPicks[id] then return false, "Already in Saved Picks." end
    if #savedPickOrder >= MAX_SAVED_PICKS then return false, "Saved Picks is full • remove one before adding another." end

    local persisted = false
    if picksCloudReady then
        local ok, response, code = cloudRequest("ADD", id)
        if ok and response then
            persisted = true
            if typeof(response.ids) == "table" then
                -- Preserve current metadata while honoring authoritative order from the server.
                local previous = savedPicks
                local previousOrder = savedPickOrder
                savedPicks = {}
                savedPickOrder = {}
                for _, cloudId in ipairs(response.ids) do
                    cloudId = tonumber(cloudId)
                    if cloudId and #savedPickOrder < MAX_SAVED_PICKS then
                        savedPicks[cloudId] = previous[cloudId] or {Id = cloudId, AssetId = cloudId, Name = "Loading catalog item…"}
                        table.insert(savedPickOrder, cloudId)
                    end
                end
            end
        elseif code ~= "THROTTLED" then
            picksCloudReady = false
        end
    end

    if not savedPicks[id] then addLocalPick(item) else
        local existing = savedPicks[id]
        existing.Name = item.Name or item.name or existing.Name
        existing.Price = item.Price or item.LowestPrice or item.price or existing.Price
        existing.ItemType = item.ItemType or item.itemType or existing.ItemType
        existing.AssetType = item.AssetType or item.assetType or existing.AssetType
    end

    picksTrack("PICK_SAVE")
    if persisted then
        return true, "Saved to Picks • synced across sessions • " .. tostring(#savedPickOrder) .. "/" .. tostring(MAX_SAVED_PICKS)
    end
    return true, "Saved for this session • cloud sync unavailable • " .. tostring(#savedPickOrder) .. "/" .. tostring(MAX_SAVED_PICKS)
end

local function removePick(id)
    id = tonumber(id)
    if not id or not savedPicks[id] then return false, "Pick not found." end

    local persisted = false
    if picksCloudReady then
        local ok, response, code = cloudRequest("REMOVE", id)
        if ok and response then
            persisted = true
        elseif code ~= "THROTTLED" then
            picksCloudReady = false
        end
    end

    savedPicks[id] = nil
    for index, value in ipairs(savedPickOrder) do
        if value == id then table.remove(savedPickOrder, index) break end
    end
    picksTrack("PICK_REMOVE")
    if persisted then return true, "Removed from Saved Picks and cloud sync." end
    return true, "Removed for this session • cloud sync unavailable."
end

local basePickCatalogCard = catalogCard
catalogCard = function(parent, item)
    local card = basePickCatalogCard(parent, item)
    if not card then return card end

    local id = pickId(item)
    if not id then return card end

    local save = Instance.new("TextButton")
    save.Name = "SavePick"
    save.Position = UDim2.fromOffset(120, 110)
    save.Size = UDim2.fromOffset(106, 38)
    save.BackgroundColor3 = Color3.fromRGB(55, 67, 86)
    save.TextColor3 = Color3.new(1, 1, 1)
    save.Font = Enum.Font.GothamBold
    save.TextSize = 11
    save.Text = savedPicks[id] and "SAVED ✓" or "SAVE PICK"
    save.Parent = card
    Instance.new("UICorner", save).CornerRadius = UDim.new(0, 10)

    save.Activated:Connect(function()
        if savedPicks[id] then
            status.Text = "Already in Saved Picks. Open PICKS to review it."
            return
        end
        status.Text = "Saving pick…"
        local ok, message = savePick(item)
        status.Text = message
        if ok then
            save.Text = "SAVED ✓"
            save.BackgroundColor3 = Color3.fromRGB(54, 87, 67)
        end
    end)

    return card
end

local function renderSavedPicks()
    clearContent()
    picksTrack("PICKS_OPEN")

    local heading = Instance.new("TextLabel")
    heading.BackgroundTransparency = 1
    heading.Size = UDim2.new(1, 0, 0, 38)
    heading.Font = Enum.Font.GothamBlack
    heading.Text = "SAVED PICKS"
    heading.TextColor3 = Color3.new(1, 1, 1)
    heading.TextSize = 23
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Parent = content

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(0, 37)
    sub.Size = UDim2.new(1, 0, 0, 30)
    sub.Font = Enum.Font.Gotham
    sub.Text = picksCloudReady and "Shortlist while you browse • synced across sessions • final outfits stay in Roblox Wardrobe" or "Shortlist while you browse • session fallback • final outfits stay in Roblox Wardrobe"
    sub.TextColor3 = Color3.fromRGB(156, 162, 182)
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = content

    local list = Instance.new("ScrollingFrame")
    list.Name = "SavedPicksList"
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

    if #savedPickOrder == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, -4, 0, 100)
        empty.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        empty.Font = Enum.Font.Gotham
        empty.Text = "No Saved Picks yet.\nBrowse SEARCH and tap SAVE PICK on items you want to compare."
        empty.TextWrapped = true
        empty.TextColor3 = Color3.fromRGB(202, 205, 216)
        empty.TextSize = 14
        empty.Parent = list
        Instance.new("UICorner", empty).CornerRadius = UDim.new(0, 12)
        status.Text = picksLoading and "Syncing Saved Picks…" or "Saved Picks is empty."
        return
    end

    for _, id in ipairs(savedPickOrder) do
        local item = savedPicks[id]
        if item then
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

            local name = Instance.new("TextLabel")
            name.BackgroundTransparency = 1
            name.Position = UDim2.fromOffset(96, 10)
            name.Size = UDim2.new(1, -292, 0, 34)
            name.Font = Enum.Font.GothamBold
            name.Text = tostring(item.Name or "Catalog Item")
            name.TextColor3 = Color3.new(1, 1, 1)
            name.TextSize = 13
            name.TextWrapped = true
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = card

            local meta = Instance.new("TextLabel")
            meta.BackgroundTransparency = 1
            meta.Position = UDim2.fromOffset(96, 50)
            meta.Size = UDim2.new(1, -292, 0, 24)
            meta.Font = Enum.Font.Gotham
            meta.Text = item.Price and (tostring(item.Price) .. " R$ • ID " .. tostring(id)) or ("ID " .. tostring(id))
            meta.TextColor3 = Color3.fromRGB(160, 165, 182)
            meta.TextSize = 11
            meta.TextXAlignment = Enum.TextXAlignment.Left
            meta.Parent = card

            local remove = Instance.new("TextButton")
            remove.AnchorPoint = Vector2.new(1, .5)
            remove.Position = UDim2.new(1, -10, .5, 0)
            remove.Size = UDim2.fromOffset(82, 36)
            remove.BackgroundColor3 = Color3.fromRGB(83, 53, 60)
            remove.TextColor3 = Color3.new(1, 1, 1)
            remove.Font = Enum.Font.GothamBold
            remove.TextSize = 10
            remove.Text = "REMOVE"
            remove.Parent = card
            Instance.new("UICorner", remove).CornerRadius = UDim.new(0, 10)
            remove.Activated:Connect(function()
                status.Text = "Removing pick…"
                local _, message = removePick(id)
                status.Text = message
                renderSavedPicks()
            end)

            if not isBundleItem(item) then
                local try = Instance.new("TextButton")
                try.AnchorPoint = Vector2.new(1, .5)
                try.Position = UDim2.new(1, -100, .5, 0)
                try.Size = UDim2.fromOffset(82, 36)
                try.BackgroundColor3 = Color3.fromRGB(62, 76, 112)
                try.TextColor3 = Color3.new(1, 1, 1)
                try.Font = Enum.Font.GothamBold
                try.TextSize = 10
                try.Text = "TRY ON"
                try.Parent = card
                Instance.new("UICorner", try).CornerRadius = UDim.new(0, 10)
                try.Activated:Connect(function() applyTryOn(item) end)
            end
        end
    end

    status.Text = tostring(#savedPickOrder) .. " Saved Picks • " .. (picksCloudReady and "cloud sync active" or "session fallback")
end

renderers.PICKS = renderSavedPicks

local picksTab = Instance.new("TextButton")
picksTab.Name = "PicksTab"
picksTab.Size = UDim2.fromOffset(94, 38)
picksTab.BackgroundColor3 = Color3.fromRGB(35, 37, 46)
picksTab.TextColor3 = Color3.new(1, 1, 1)
picksTab.Font = Enum.Font.GothamBold
picksTab.TextSize = 12
picksTab.Text = "PICKS"
picksTab.Parent = tabs
Instance.new("UICorner", picksTab).CornerRadius = UDim.new(0, 10)
picksTab.Activated:Connect(function() selectTab("PICKS") end)

loadCloudPicks()
print("[BBYAVATAR] Saved Picks persistent sync + safe session fallback ready")