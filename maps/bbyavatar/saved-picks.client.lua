-- BBYAVATAR session Saved Picks shortlist.
-- Keeps a lightweight client-only shortlist so users can compare items before saving an outfit or buying.
-- Nothing here persists after the player leaves; persistent final looks remain Roblox-native saved outfits.

local savedPicks = {}
local savedPickOrder = {}
local MAX_SAVED_PICKS = 24

local function picksTrack(eventName)
    local remote = root:FindFirstChild("TrackEvent")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(eventName) end)
    end
end

local function pickId(item)
    return tonumber(item and (item.Id or item.AssetId or item.id))
end

local function savePick(item)
    local id = pickId(item)
    if not id then return false, "This catalog item cannot be shortlisted." end
    if savedPicks[id] then return false, "Already in Saved Picks." end
    if #savedPickOrder >= MAX_SAVED_PICKS then return false, "Saved Picks is full • remove one before adding another." end

    savedPicks[id] = {
        Id = id,
        AssetId = id,
        Name = item.Name or item.name or "Catalog Item",
        Price = item.Price or item.LowestPrice or item.price,
        ItemType = item.ItemType or item.itemType,
        AssetType = item.AssetType or item.assetType,
    }
    table.insert(savedPickOrder, id)
    picksTrack("PICK_SAVE")
    return true, "Saved to Picks • " .. tostring(#savedPickOrder) .. "/" .. tostring(MAX_SAVED_PICKS)
end

local function removePick(id)
    id = tonumber(id)
    if not id or not savedPicks[id] then return end
    savedPicks[id] = nil
    for index, value in ipairs(savedPickOrder) do
        if value == id then
            table.remove(savedPickOrder, index)
            break
        end
    end
    picksTrack("PICK_REMOVE")
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
    sub.Text = "Shortlist while you browse • session only • final outfits stay in Roblox Wardrobe"
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
        status.Text = "Saved Picks is empty."
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
                removePick(id)
                status.Text = "Removed from Saved Picks."
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

    status.Text = tostring(#savedPickOrder) .. " Saved Picks • shortlist resets when you leave"
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

print("[BBYAVATAR] Session Saved Picks shortlist ready")