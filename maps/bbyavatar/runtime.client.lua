local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AvatarEditorService = game:GetService("AvatarEditorService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local root = ReplicatedStorage:WaitForChild("BBYAVATAR")
local openEvent = root:WaitForChild("OpenCatalog")

local gui = Instance.new("ScreenGui")
gui.Name = "BBYAVATAR_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local openButton = Instance.new("TextButton")
openButton.Name = "OpenCatalog"
openButton.AnchorPoint = Vector2.new(1, 1)
openButton.Position = UDim2.fromScale(0.97, 0.94)
openButton.Size = UDim2.fromOffset(132, 48)
openButton.BackgroundColor3 = Color3.fromRGB(24, 25, 31)
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 15
openButton.Text = "BBYAVATAR"
openButton.Parent = gui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 14)

local frame = Instance.new("Frame")
frame.Name = "CatalogPanel"
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.Size = UDim2.fromScale(0.92, 0.82)
frame.Visible = false
frame.BackgroundColor3 = Color3.fromRGB(17, 18, 23)
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 18)

local header = Instance.new("Frame")
header.BackgroundTransparency = 1
header.Position = UDim2.fromScale(0.035, 0.025)
header.Size = UDim2.fromScale(0.93, 0.13)
header.Parent = frame

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.fromScale(0.64, 0.5)
title.Font = Enum.Font.GothamBlack
title.Text = "BBYAVATAR"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromScale(0, 0.54)
subtitle.Size = UDim2.fromScale(0.75, 0.35)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Discover • Create • Save • Shop"
subtitle.TextColor3 = Color3.fromRGB(170,174,190)
subtitle.TextScaled = true
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.fromScale(1, 0)
close.Size = UDim2.fromOffset(52, 40)
close.BackgroundColor3 = Color3.fromRGB(45,47,56)
close.Text = "×"
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 28
close.Parent = header
Instance.new("UICorner", close).CornerRadius = UDim.new(0,12)

local tabs = Instance.new("Frame")
tabs.BackgroundTransparency = 1
tabs.Position = UDim2.fromScale(0.035, 0.16)
tabs.Size = UDim2.fromScale(0.93, 0.09)
tabs.Parent = frame
local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 8)
tabLayout.Parent = tabs

local content = Instance.new("Frame")
content.BackgroundTransparency = 1
content.Position = UDim2.fromScale(0.035, 0.27)
content.Size = UDim2.fromScale(0.93, 0.69)
content.Parent = frame

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.AnchorPoint = Vector2.new(0,1)
status.Position = UDim2.fromScale(0,1)
status.Size = UDim2.fromScale(1,0.07)
status.Font = Enum.Font.Gotham
status.Text = ""
status.TextColor3 = Color3.fromRGB(160,164,180)
status.TextScaled = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = content

local activeCategory = "FEATURED"
local activeTab = "DISCOVER"
local pagesCache = nil

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if child ~= status then child:Destroy() end
    end
end

local function makeAction(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 48)
    b.BackgroundColor3 = Color3.fromRGB(38,40,50)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 15
    b.Text = text
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)
    b.Activated:Connect(callback)
    return b
end

local function renderDiscover()
    clearContent()
    local category = Instance.new("TextLabel")
    category.BackgroundTransparency = 1
    category.Size = UDim2.new(1,0,0,46)
    category.Font = Enum.Font.GothamBlack
    category.Text = activeCategory
    category.TextColor3 = Color3.new(1,1,1)
    category.TextSize = 28
    category.TextXAlignment = Enum.TextXAlignment.Left
    category.Parent = content

    local desc = Instance.new("TextLabel")
    desc.BackgroundTransparency = 1
    desc.Position = UDim2.fromOffset(0,54)
    desc.Size = UDim2.new(1,0,0,92)
    desc.Font = Enum.Font.Gotham
    desc.Text = "Curated full looks and creator drops live here. Browse the Roblox Marketplace from SEARCH, save your avatar in STUDIO, and build collections that can grow with BBYAVATAR."
    desc.TextColor3 = Color3.fromRGB(215,218,228)
    desc.TextWrapped = true
    desc.TextSize = 17
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.Parent = content

    local quick = Instance.new("Frame")
    quick.BackgroundTransparency = 1
    quick.Position = UDim2.fromOffset(0,160)
    quick.Size = UDim2.new(1,0,0,180)
    quick.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,10)
    layout.Parent = quick

    makeAction(quick, "SEARCH MARKETPLACE", function()
        activeTab = "SEARCH"
        renderDiscover()
        task.defer(function()
            for _, btn in ipairs(tabs:GetChildren()) do
                if btn:IsA("TextButton") and btn.Text == "SEARCH" then btn:Activate() end
            end
        end)
    end)
    makeAction(quick, "SAVE CURRENT AVATAR AS OUTFIT", function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        status.Text = "Opening Roblox outfit save prompt…"
        local ok, err = pcall(function()
            local description = humanoid:GetAppliedDescription()
            AvatarEditorService:PromptCreateOutfit(description, humanoid.RigType)
        end)
        if not ok then status.Text = "Save outfit unavailable: " .. tostring(err) end
    end)
    makeAction(quick, "ALLOW INVENTORY ACCESS", function()
        status.Text = "Requesting inventory access…"
        pcall(function() AvatarEditorService:PromptAllowInventoryReadAccess() end)
    end)
end

local function renderSearch()
    clearContent()

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1,-110,0,46)
    searchBox.BackgroundColor3 = Color3.fromRGB(29,31,39)
    searchBox.TextColor3 = Color3.new(1,1,1)
    searchBox.PlaceholderColor3 = Color3.fromRGB(135,139,155)
    searchBox.PlaceholderText = "Search hair, jacket, wings, streetwear…"
    searchBox.ClearTextOnFocus = false
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 16
    searchBox.Parent = content
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0,12)

    local searchButton = Instance.new("TextButton")
    searchButton.AnchorPoint = Vector2.new(1,0)
    searchButton.Position = UDim2.new(1,0,0,0)
    searchButton.Size = UDim2.fromOffset(100,46)
    searchButton.BackgroundColor3 = Color3.fromRGB(70,76,110)
    searchButton.TextColor3 = Color3.new(1,1,1)
    searchButton.Font = Enum.Font.GothamBold
    searchButton.TextSize = 14
    searchButton.Text = "SEARCH"
    searchButton.Parent = content
    Instance.new("UICorner", searchButton).CornerRadius = UDim.new(0,12)

    local chips = Instance.new("Frame")
    chips.BackgroundTransparency = 1
    chips.Position = UDim2.fromOffset(0,52)
    chips.Size = UDim2.new(1,0,0,34)
    chips.Parent = content
    local chipLayout = Instance.new("UIListLayout")
    chipLayout.FillDirection = Enum.FillDirection.Horizontal
    chipLayout.Padding = UDim.new(0,6)
    chipLayout.Parent = chips

    local results = Instance.new("ScrollingFrame")
    results.BackgroundTransparency = 1
    results.Position = UDim2.fromOffset(0,92)
    results.Size = UDim2.new(1,0,1,-132)
    results.AutomaticCanvasSize = Enum.AutomaticSize.Y
    results.CanvasSize = UDim2.new()
    results.ScrollBarThickness = 4
    results.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.Parent = results

    local function clearResults()
        for _, child in ipairs(results:GetChildren()) do
            if child ~= layout then child:Destroy() end
        end
    end

    local function addResult(item)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1,-4,0,108)
        card.BackgroundColor3 = Color3.fromRGB(28,30,38)
        card.Parent = results
        Instance.new("UICorner", card).CornerRadius = UDim.new(0,12)

        local itemId = tonumber(item.Id or item.AssetId or item.id)
        local thumb = Instance.new("ImageLabel")
        thumb.BackgroundColor3 = Color3.fromRGB(40,42,51)
        thumb.Position = UDim2.fromOffset(10,10)
        thumb.Size = UDim2.fromOffset(88,88)
        thumb.ScaleType = Enum.ScaleType.Fit
        if itemId then thumb.Image = "rbxthumb://type=Asset&id=" .. tostring(itemId) .. "&w=150&h=150" end
        thumb.Parent = card
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(0,10)

        local name = Instance.new("TextLabel")
        name.BackgroundTransparency = 1
        name.Position = UDim2.fromOffset(110,10)
        name.Size = UDim2.new(1,-310,0,30)
        name.Font = Enum.Font.GothamBold
        name.Text = tostring(item.Name or item.name or "Catalog Item")
        name.TextColor3 = Color3.new(1,1,1)
        name.TextSize = 15
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.TextTruncate = Enum.TextTruncate.AtEnd
        name.Parent = card

        local price = item.Price or item.LowestPrice or item.price
        local assetType = tostring(item.AssetType or item.assetType or "Avatar item")
        local meta = Instance.new("TextLabel")
        meta.BackgroundTransparency = 1
        meta.Position = UDim2.fromOffset(110,43)
        meta.Size = UDim2.new(1,-310,0,46)
        meta.Font = Enum.Font.Gotham
        meta.Text = (price and (tostring(price) .. " R$") or "Catalog item") .. "  •  " .. assetType .. (itemId and ("\nID " .. tostring(itemId)) or "")
        meta.TextColor3 = Color3.fromRGB(165,169,183)
        meta.TextSize = 12
        meta.TextWrapped = true
        meta.TextXAlignment = Enum.TextXAlignment.Left
        meta.TextYAlignment = Enum.TextYAlignment.Top
        meta.Parent = card

        if itemId then
            local buy = Instance.new("TextButton")
            buy.AnchorPoint = Vector2.new(1,0)
            buy.Position = UDim2.new(1,-10,0,12)
            buy.Size = UDim2.fromOffset(82,36)
            buy.BackgroundColor3 = Color3.fromRGB(64,91,72)
            buy.Text = "BUY"
            buy.TextColor3 = Color3.new(1,1,1)
            buy.Font = Enum.Font.GothamBold
            buy.TextSize = 13
            buy.Parent = card
            Instance.new("UICorner", buy).CornerRadius = UDim.new(0,10)
            buy.Activated:Connect(function()
                pcall(function() MarketplaceService:PromptPurchase(player, itemId) end)
            end)

            local fav = Instance.new("TextButton")
            fav.AnchorPoint = Vector2.new(1,0)
            fav.Position = UDim2.new(1,-10,0,58)
            fav.Size = UDim2.fromOffset(82,36)
            fav.BackgroundColor3 = Color3.fromRGB(67,61,91)
            fav.Text = "FAVORITE"
            fav.TextColor3 = Color3.new(1,1,1)
            fav.Font = Enum.Font.GothamBold
            fav.TextSize = 11
            fav.Parent = card
            Instance.new("UICorner", fav).CornerRadius = UDim.new(0,10)
            fav.Activated:Connect(function()
                status.Text = "Opening favorite prompt…"
                pcall(function() AvatarEditorService:PromptSetFavorite(itemId, Enum.AvatarItemType.Asset, true) end)
            end)
        end
    end

    local function appendCurrentPage()
        if not pagesCache then return end
        local current = pagesCache:GetCurrentPage()
        for _, item in ipairs(current) do addResult(item) end
        return #current
    end

    local function runSearch()
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
            params.Limit = 20
            return AvatarEditorService:SearchCatalogAsync(params)
        end)
        if not ok or not pages then status.Text = "Marketplace search unavailable right now." return end
        pagesCache = pages
        local count = appendCurrentPage() or 0
        status.Text = string.format("%d results loaded • scroll down for more", count)
    end

    for _, chip in ipairs({"HAIR","JACKETS","PANTS","ACCESSORIES","CUTE","CYBER"}) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(82,30)
        b.BackgroundColor3 = Color3.fromRGB(36,38,48)
        b.TextColor3 = Color3.fromRGB(220,222,230)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10
        b.Text = chip
        b.Parent = chips
        Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
        b.Activated:Connect(function() searchBox.Text = string.lower(chip); runSearch() end)
    end

    local loadingMore = false
    results:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        if loadingMore or not pagesCache or pagesCache.IsFinished then return end
        local nearBottom = results.CanvasPosition.Y + results.AbsoluteWindowSize.Y >= results.AbsoluteCanvasSize.Y - 180
        if not nearBottom then return end
        loadingMore = true
        status.Text = "Loading more…"
        local ok = pcall(function() pagesCache:AdvanceToNextPageAsync() end)
        if ok then
            local added = appendCurrentPage() or 0
            status.Text = added > 0 and ("More looks loaded • keep scrolling") or "No more results"
        else
            status.Text = "Could not load more right now."
        end
        loadingMore = false
    end)

    searchButton.Activated:Connect(runSearch)
    searchBox.FocusLost:Connect(function(enterPressed) if enterPressed then runSearch() end end)
end

local function renderStudio()
    clearContent()
    local h = Instance.new("TextLabel")
    h.BackgroundTransparency = 1
    h.Size = UDim2.new(1,0,0,50)
    h.Font = Enum.Font.GothamBlack
    h.Text = "AVATAR STUDIO"
    h.TextColor3 = Color3.new(1,1,1)
    h.TextSize = 28
    h.TextXAlignment = Enum.TextXAlignment.Left
    h.Parent = content

    local actions = Instance.new("Frame")
    actions.BackgroundTransparency = 1
    actions.Position = UDim2.fromOffset(0,65)
    actions.Size = UDim2.new(1,0,0,250)
    actions.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,10)
    layout.Parent = actions

    makeAction(actions, "SAVE CURRENT AVATAR TO ROBLOX", function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local desc = humanoid:GetAppliedDescription()
        pcall(function() AvatarEditorService:PromptSaveAvatar(desc, humanoid.RigType) end)
    end)
    makeAction(actions, "CREATE SAVED OUTFIT", function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local desc = humanoid:GetAppliedDescription()
        pcall(function() AvatarEditorService:PromptCreateOutfit(desc, humanoid.RigType) end)
    end)
    makeAction(actions, "SEARCH MORE ITEMS", function()
        for _, btn in ipairs(tabs:GetChildren()) do if btn:IsA("TextButton") and btn.Text == "SEARCH" then btn:Activate() end end
    end)
end

local function renderPhoto()
    clearContent()
    local h = Instance.new("TextLabel")
    h.BackgroundTransparency = 1
    h.Size = UDim2.new(1,0,0,50)
    h.Font = Enum.Font.GothamBlack
    h.Text = "PHOTO STUDIO"
    h.TextColor3 = Color3.new(1,1,1)
    h.TextSize = 28
    h.TextXAlignment = Enum.TextXAlignment.Left
    h.Parent = content

    local d = Instance.new("TextLabel")
    d.BackgroundTransparency = 1
    d.Position = UDim2.fromOffset(0,60)
    d.Size = UDim2.new(1,0,0,130)
    d.Font = Enum.Font.Gotham
    d.Text = "Dedicated avatar photo tools, poses, backgrounds and shareable look cards are being built here. The physical Photo Studio in the showroom is already reserved for this system."
    d.TextWrapped = true
    d.TextColor3 = Color3.fromRGB(210,214,225)
    d.TextSize = 17
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.TextYAlignment = Enum.TextYAlignment.Top
    d.Parent = content
end

local renderers = {DISCOVER=renderDiscover,SEARCH=renderSearch,STUDIO=renderStudio,PHOTO=renderPhoto}
local function selectTab(name)
    activeTab=name;status.Text="";(renderers[name] or renderDiscover)()
end

for _, name in ipairs({"DISCOVER", "SEARCH", "STUDIO", "PHOTO"}) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(94,38)
    b.BackgroundColor3 = Color3.fromRGB(35,37,46)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Text = name
    b.Parent = tabs
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    b.Activated:Connect(function() selectTab(name) end)
end

openButton.Activated:Connect(function() activeCategory="FEATURED";frame.Visible=true;selectTab("DISCOVER") end)
close.Activated:Connect(function() frame.Visible=false end)
openEvent.OnClientEvent:Connect(function(selectedCategory)
    activeCategory=tostring(selectedCategory or "FEATURED");frame.Visible=true
    if activeCategory=="STUDIO" then selectTab("STUDIO") elseif activeCategory=="PHOTO" then selectTab("PHOTO") else selectTab("DISCOVER") end
end)

selectTab("DISCOVER")
