-- BBYAVATAR catalog UX enhancement: visual cards, bundle-safe purchase, pagination.
-- Appended into the existing BBYAVATAR client chunk so it can extend shared locals safely.

local function isBundleItem(item)
    local itemType = item and (item.ItemType or item.itemType)
    return itemType == Enum.AvatarItemType.Bundle or tostring(itemType):find("Bundle") ~= nil
end

local function itemThumb(item, itemId)
    if not itemId then return "" end
    if isBundleItem(item) then
        return string.format("rbxthumb://type=BundleThumbnail&id=%d&w=150&h=150", itemId)
    end
    return string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", itemId)
end

local function catalogCard(parent, item)
    local itemId = tonumber(item.Id or item.AssetId or item.id)
    local bundle = isBundleItem(item)
    local price = item.Price or item.LowestPrice or item.price

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -4, 0, 118)
    card.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    local preview = Instance.new("ImageLabel")
    preview.Name = "Preview"
    preview.Position = UDim2.fromOffset(10, 10)
    preview.Size = UDim2.fromOffset(98, 98)
    preview.BackgroundColor3 = Color3.fromRGB(21, 23, 29)
    preview.Image = itemThumb(item, itemId)
    preview.ScaleType = Enum.ScaleType.Fit
    preview.Parent = card
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 10)

    local name = Instance.new("TextLabel")
    name.BackgroundTransparency = 1
    name.Position = UDim2.fromOffset(120, 10)
    name.Size = UDim2.new(1, -320, 0, 38)
    name.Font = Enum.Font.GothamBold
    name.Text = tostring(item.Name or item.name or "Catalog Item")
    name.TextColor3 = Color3.new(1, 1, 1)
    name.TextSize = 15
    name.TextWrapped = true
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextYAlignment = Enum.TextYAlignment.Top
    name.Parent = card

    local meta = Instance.new("TextLabel")
    meta.BackgroundTransparency = 1
    meta.Position = UDim2.fromOffset(120, 52)
    meta.Size = UDim2.new(1, -320, 0, 48)
    meta.Font = Enum.Font.Gotham
    local typeText = bundle and "Bundle" or "Asset"
    local priceText = price and (tostring(price) .. " R$") or "View details"
    meta.Text = itemId and string.format("%s  •  %s\nID %d", priceText, typeText, itemId) or typeText
    meta.TextColor3 = Color3.fromRGB(165, 169, 183)
    meta.TextSize = 13
    meta.TextXAlignment = Enum.TextXAlignment.Left
    meta.TextYAlignment = Enum.TextYAlignment.Top
    meta.Parent = card

    if not itemId then return card end

    local buy = Instance.new("TextButton")
    buy.AnchorPoint = Vector2.new(1, 0)
    buy.Position = UDim2.new(1, -12, 0, 14)
    buy.Size = UDim2.fromOffset(84, 38)
    buy.BackgroundColor3 = Color3.fromRGB(64, 91, 72)
    buy.Text = "BUY"
    buy.TextColor3 = Color3.new(1, 1, 1)
    buy.Font = Enum.Font.GothamBold
    buy.TextSize = 13
    buy.Parent = card
    Instance.new("UICorner", buy).CornerRadius = UDim.new(0, 10)
    buy.Activated:Connect(function()
        status.Text = bundle and "Opening bundle purchase…" or "Opening purchase…"
        local ok, err = pcall(function()
            if bundle then
                MarketplaceService:PromptBundlePurchase(player, itemId)
            else
                MarketplaceService:PromptPurchase(player, itemId)
            end
        end)
        if not ok then status.Text = "Purchase prompt unavailable: " .. tostring(err) end
    end)

    local fav = Instance.new("TextButton")
    fav.AnchorPoint = Vector2.new(1, 0)
    fav.Position = UDim2.new(1, -12, 0, 62)
    fav.Size = UDim2.fromOffset(84, 38)
    fav.BackgroundColor3 = Color3.fromRGB(67, 61, 91)
    fav.Text = "FAVORITE"
    fav.TextColor3 = Color3.new(1, 1, 1)
    fav.Font = Enum.Font.GothamBold
    fav.TextSize = 11
    fav.Parent = card
    Instance.new("UICorner", fav).CornerRadius = UDim.new(0, 10)
    fav.Activated:Connect(function()
        status.Text = "Opening favorite prompt…"
        local ok, err = pcall(function()
            AvatarEditorService:PromptSetFavorite(itemId, bundle and Enum.AvatarItemType.Bundle or Enum.AvatarItemType.Asset, true)
        end)
        if not ok then status.Text = "Favorite unavailable: " .. tostring(err) end
    end)

    return card
end

renderSearch = function()
    clearContent()
    pagesCache = nil

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -110, 0, 48)
    searchBox.BackgroundColor3 = Color3.fromRGB(29, 31, 39)
    searchBox.TextColor3 = Color3.new(1, 1, 1)
    searchBox.PlaceholderColor3 = Color3.fromRGB(135, 139, 155)
    searchBox.PlaceholderText = "Search hair, jacket, wings, streetwear…"
    searchBox.ClearTextOnFocus = false
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 16
    searchBox.Parent = content
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 12)

    local searchButton = Instance.new("TextButton")
    searchButton.AnchorPoint = Vector2.new(1, 0)
    searchButton.Position = UDim2.new(1, 0, 0, 0)
    searchButton.Size = UDim2.fromOffset(100, 48)
    searchButton.BackgroundColor3 = Color3.fromRGB(70, 76, 110)
    searchButton.TextColor3 = Color3.new(1, 1, 1)
    searchButton.Font = Enum.Font.GothamBold
    searchButton.TextSize = 14
    searchButton.Text = "SEARCH"
    searchButton.Parent = content
    Instance.new("UICorner", searchButton).CornerRadius = UDim.new(0, 12)

    local results = Instance.new("ScrollingFrame")
    results.Name = "CatalogResults"
    results.BackgroundTransparency = 1
    results.Position = UDim2.fromOffset(0, 60)
    results.Size = UDim2.new(1, 0, 1, -102)
    results.AutomaticCanvasSize = Enum.AutomaticSize.Y
    results.CanvasSize = UDim2.new()
    results.ScrollBarThickness = 4
    results.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = results

    local loading = false
    local loadedCount = 0

    local function clearResults()
        for _, child in ipairs(results:GetChildren()) do
            if child ~= layout then child:Destroy() end
        end
        loadedCount = 0
    end

    local function appendCurrentPage()
        if not pagesCache then return end
        local current = pagesCache:GetCurrentPage()
        for _, item in ipairs(current) do
            catalogCard(results, item)
            loadedCount += 1
        end
        status.Text = string.format("%d items loaded", loadedCount)

        if not pagesCache.IsFinished then
            local more = Instance.new("TextButton")
            more.Name = "LoadMore"
            more.Size = UDim2.new(1, -4, 0, 46)
            more.BackgroundColor3 = Color3.fromRGB(42, 45, 57)
            more.TextColor3 = Color3.new(1, 1, 1)
            more.Font = Enum.Font.GothamBold
            more.TextSize = 13
            more.Text = "LOAD MORE"
            more.Parent = results
            Instance.new("UICorner", more).CornerRadius = UDim.new(0, 12)
            more.Activated:Connect(function()
                if loading or not pagesCache or pagesCache.IsFinished then return end
                loading = true
                more.Text = "LOADING…"
                status.Text = "Loading more Marketplace items…"
                local ok, err = pcall(function() pagesCache:AdvanceToNextPageAsync() end)
                more:Destroy()
                if ok then
                    appendCurrentPage()
                else
                    status.Text = "Could not load more: " .. tostring(err)
                end
                loading = false
            end)
        end
    end

    local function runSearch()
        if loading then return end
        loading = true
        local query = searchBox.Text
        if query == "" then query = activeCategory ~= "FEATURED" and activeCategory or "avatar" end
        status.Text = "Searching Roblox Marketplace…"
        clearResults()

        local ok, pages = pcall(function()
            local params = CatalogSearchParams.new()
            params.SearchKeyword = query
            params.SortType = Enum.CatalogSortType.Relevance
            params.IncludeOffSale = false
            params.Limit = 20
            return AvatarEditorService:SearchCatalogAsync(params)
        end)
        if not ok or not pages then
            status.Text = "Marketplace search unavailable right now."
            loading = false
            return
        end
        pagesCache = pages
        appendCurrentPage()
        loading = false
    end

    searchButton.Activated:Connect(runSearch)
    searchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then runSearch() end
    end)
end

renderers.SEARCH = renderSearch
print("[BBYAVATAR] Catalog visual cards + pagination ready")
