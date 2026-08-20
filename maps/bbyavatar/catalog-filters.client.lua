-- BBYAVATAR advanced Marketplace discovery filters.
-- Extends the existing catalog grid with native CatalogSearchParams filtering.
local searchSequence = 0
local lastSearchAt = 0
local FILTER_COOLDOWN = 0.7

local filterModes = {
    {label = "ALL", value = Enum.CatalogCategoryFilter.None},
    {label = "UGC", value = Enum.CatalogCategoryFilter.CommunityCreations},
    {label = "RECOMMENDED", value = Enum.CatalogCategoryFilter.Recommended},
    {label = "FEATURED", value = Enum.CatalogCategoryFilter.Featured},
}
local filterIndex = 1

local function compactField(parent, placeholder, width)
    local box = Instance.new("TextBox")
    box.Size = UDim2.fromOffset(width, 36)
    box.BackgroundColor3 = Color3.fromRGB(29, 31, 39)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.PlaceholderColor3 = Color3.fromRGB(130, 134, 150)
    box.PlaceholderText = placeholder
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
    return box
end

local function compactButton(parent, text, width)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(width, 36)
    button.BackgroundColor3 = Color3.fromRGB(39, 42, 53)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.Text = text
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)
    return button
end

renderSearch = function()
    clearContent()
    pagesCache = nil

    local top = Instance.new("Frame")
    top.BackgroundTransparency = 1
    top.Size = UDim2.new(1, 0, 0, 46)
    top.Parent = content

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -112, 0, 46)
    searchBox.BackgroundColor3 = Color3.fromRGB(29, 31, 39)
    searchBox.TextColor3 = Color3.new(1, 1, 1)
    searchBox.PlaceholderColor3 = Color3.fromRGB(135, 139, 155)
    searchBox.PlaceholderText = "Search hair, jacket, wings, streetwear…"
    searchBox.ClearTextOnFocus = false
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 15
    searchBox.Parent = top
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 12)

    local searchButton = compactButton(top, "SEARCH", 102)
    searchButton.AnchorPoint = Vector2.new(1, 0)
    searchButton.Position = UDim2.new(1, 0, 0, 0)
    searchButton.Size = UDim2.fromOffset(102, 46)
    searchButton.BackgroundColor3 = Color3.fromRGB(70, 76, 110)

    local filters = Instance.new("ScrollingFrame")
    filters.Name = "AdvancedFilters"
    filters.BackgroundTransparency = 1
    filters.Position = UDim2.fromOffset(0, 52)
    filters.Size = UDim2.new(1, 0, 0, 40)
    filters.AutomaticCanvasSize = Enum.AutomaticSize.X
    filters.CanvasSize = UDim2.new()
    filters.ScrollBarThickness = 0
    filters.ScrollingDirection = Enum.ScrollingDirection.X
    filters.Parent = content
    local fl = Instance.new("UIListLayout")
    fl.FillDirection = Enum.FillDirection.Horizontal
    fl.Padding = UDim.new(0, 6)
    fl.Parent = filters

    local modeButton = compactButton(filters, "FILTER: " .. filterModes[filterIndex].label, 128)
    local creatorBox = compactField(filters, "Creator", 116)
    local minBox = compactField(filters, "Min R$", 76)
    local maxBox = compactField(filters, "Max R$", 76)
    local resetButton = compactButton(filters, "RESET", 72)

    local chips = Instance.new("ScrollingFrame")
    chips.BackgroundTransparency = 1
    chips.Position = UDim2.fromOffset(0, 96)
    chips.Size = UDim2.new(1, 0, 0, 38)
    chips.AutomaticCanvasSize = Enum.AutomaticSize.X
    chips.CanvasSize = UDim2.new()
    chips.ScrollBarThickness = 0
    chips.ScrollingDirection = Enum.ScrollingDirection.X
    chips.Parent = content
    local cl = Instance.new("UIListLayout")
    cl.FillDirection = Enum.FillDirection.Horizontal
    cl.Padding = UDim.new(0, 6)
    cl.Parent = chips

    local results = Instance.new("ScrollingFrame")
    results.Name = "CatalogResults"
    results.BackgroundTransparency = 1
    results.Position = UDim2.fromOffset(0, 140)
    results.Size = UDim2.new(1, 0, 1, -182)
    results.AutomaticCanvasSize = Enum.AutomaticSize.Y
    results.CanvasSize = UDim2.new()
    results.ScrollBarThickness = 4
    results.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = results

    local loading = false
    local loadedCount = 0
    local mySequence = 0

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
        status.Text = string.format("%d Marketplace items loaded", loadedCount)
        if pagesCache.IsFinished then return end

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
            local ok = pcall(function() pagesCache:AdvanceToNextPageAsync() end)
            more:Destroy()
            if ok then appendCurrentPage() else status.Text = "Could not load more right now." end
            loading = false
        end)
    end

    local function runSearch()
        if loading then return end
        local now = os.clock()
        if now - lastSearchAt < FILTER_COOLDOWN then
            status.Text = "Please wait a moment before searching again."
            return
        end
        lastSearchAt = now
        loading = true
        searchSequence += 1
        mySequence = searchSequence

        local query = searchBox.Text
        if query == "" then query = activeCategory ~= "FEATURED" and activeCategory or "avatar" end
        status.Text = "Searching Roblox Marketplace…"
        clearResults()
        pagesCache = nil

        local ok, pages = pcall(function()
            local params = CatalogSearchParams.new()
            params.SearchKeyword = query
            params.SortType = Enum.CatalogSortType.Relevance
            params.IncludeOffSale = false
            params.CategoryFilter = filterModes[filterIndex].value
            local minPrice = tonumber(minBox.Text)
            local maxPrice = tonumber(maxBox.Text)
            if minPrice and minPrice >= 0 then params.MinPrice = math.floor(minPrice) end
            if maxPrice and maxPrice >= 0 then params.MaxPrice = math.floor(maxPrice) end
            if creatorBox.Text ~= "" then params.CreatorName = creatorBox.Text end
            params.Limit = 20
            return AvatarEditorService:SearchCatalogAsync(params)
        end)

        if mySequence ~= searchSequence then
            loading = false
            return
        end
        if not ok or not pages then
            status.Text = "Marketplace search unavailable right now."
            loading = false
            return
        end
        pagesCache = pages
        appendCurrentPage()
        loading = false
    end

    modeButton.Activated:Connect(function()
        filterIndex = (filterIndex % #filterModes) + 1
        modeButton.Text = "FILTER: " .. filterModes[filterIndex].label
    end)

    resetButton.Activated:Connect(function()
        creatorBox.Text = ""
        minBox.Text = ""
        maxBox.Text = ""
        filterIndex = 1
        modeButton.Text = "FILTER: ALL"
        status.Text = "Filters reset."
    end)

    for _, chip in ipairs({"HAIR", "JACKETS", "PANTS", "ACCESSORIES", "STREETWEAR", "CUTE", "CYBER", "BALI"}) do
        local button = compactButton(chips, chip, 88)
        button.Activated:Connect(function()
            searchBox.Text = string.lower(chip)
            runSearch()
        end)
    end

    searchButton.Activated:Connect(runSearch)
    searchBox.FocusLost:Connect(function(enterPressed) if enterPressed then runSearch() end end)
end

renderers.SEARCH = renderSearch
print("[BBYAVATAR] Advanced UGC/creator/price catalog filters ready")
