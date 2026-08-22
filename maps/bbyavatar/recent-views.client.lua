-- BBYAVATAR Recently Viewed v4.
-- Persists only catalog asset IDs through the server module; details are resolved from Roblox on demand.
-- v4 adds a privacy-minimal CONTINUE VIEWING card to Discover using only the most recent Roblox asset ID.

local recentRequest = root:WaitForChild("RecentViewsRequest")
local recentIds = {}
local recentItemCache = {}
local recentLoaded = false
local recentLoadInFlight = false

local function recentTrack(eventName)
    local remote = root:FindFirstChild("TrackEvent")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(eventName) end)
    end
end

local function normalizeRecent(ids)
    local out, seen = {}, {}
    if typeof(ids) ~= "table" then return out end
    for _, raw in ipairs(ids) do
        local id = tonumber(raw)
        if id and id > 0 and id == math.floor(id) and not seen[id] then
            seen[id] = true
            table.insert(out, id)
            if #out >= 12 then break end
        end
    end
    return out
end

local function syncRecent(response)
    if typeof(response) ~= "table" then return false end
    if typeof(response.ids) == "table" then recentIds = normalizeRecent(response.ids) end
    return response.ok == true
end

local function loadRecent()
    if recentLoaded or recentLoadInFlight then return end
    recentLoadInFlight = true
    local ok, response = pcall(function() return recentRequest:InvokeServer("LOAD") end)
    recentLoadInFlight = false
    if ok and typeof(response) == "table" then
        syncRecent(response)
        if response.ok or response.code ~= "DATASTORE_READ_FAILED" then recentLoaded = true end
    end
end

function recordRecentView(item)
    local id = tonumber(item and (item.Id or item.AssetId or item.id))
    if not id or id <= 0 or id ~= math.floor(id) or isBundleItem(item) then return end
    recentItemCache[id] = item

    for i = #recentIds, 1, -1 do if recentIds[i] == id then table.remove(recentIds, i) end end
    table.insert(recentIds, 1, id)
    while #recentIds > 12 do table.remove(recentIds) end

    task.spawn(function()
        local ok, response = pcall(function() return recentRequest:InvokeServer("TOUCH", id) end)
        if ok and typeof(response) == "table" then syncRecent(response) end
    end)
    recentTrack("RECENT_TOUCH")
end

local function resolveRecentItem(id)
    if recentItemCache[id] then return recentItemCache[id] end
    local ok, details = pcall(function()
        return AvatarEditorService:GetItemDetailsAsync(id, Enum.AvatarItemType.Asset)
    end)
    if not ok or typeof(details) ~= "table" then return nil end
    details.Id = id
    details.ItemType = details.ItemType or Enum.AvatarItemType.Asset
    recentItemCache[id] = details
    return details
end

function getRecentRecommendationSeed()
    loadRecent()
    for _, id in ipairs(recentIds) do
        local item = resolveRecentItem(id)
        if item and not isBundleItem(item) then
            return item, id
        end
    end
    return nil, nil
end

local function clearRecentHistory()
    status.Text = "Clearing recent history…"
    local ok, response = pcall(function() return recentRequest:InvokeServer("CLEAR") end)
    if not ok or typeof(response) ~= "table" then
        status.Text = "Could not clear history right now."
        return false
    end
    if not response.ok then
        status.Text = response.code == "THROTTLED" and "Please wait a moment and try again." or "Could not clear history right now."
        return false
    end
    recentIds = {}
    recentItemCache = {}
    recentLoaded = true
    recentTrack("RECENT_CLEAR")
    status.Text = "Recent history cleared."
    return true
end

local function renderRecent()
    clearContent()
    recentTrack("RECENT_OPEN")
    loadRecent()

    local heading = Instance.new("TextLabel")
    heading.BackgroundTransparency = 1
    heading.Size = UDim2.new(1, -132, 0, 38)
    heading.Font = Enum.Font.GothamBlack
    heading.Text = "RECENTLY VIEWED"
    heading.TextColor3 = Color3.new(1, 1, 1)
    heading.TextSize = 23
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Parent = content

    local clearButton = Instance.new("TextButton")
    clearButton.AnchorPoint = Vector2.new(1, 0)
    clearButton.Position = UDim2.new(1, 0, 0, 0)
    clearButton.Size = UDim2.fromOffset(124, 34)
    clearButton.BackgroundColor3 = Color3.fromRGB(47, 49, 60)
    clearButton.TextColor3 = Color3.fromRGB(224, 226, 234)
    clearButton.Font = Enum.Font.GothamBold
    clearButton.TextSize = 11
    clearButton.Text = "CLEAR HISTORY"
    clearButton.Parent = content
    Instance.new("UICorner", clearButton).CornerRadius = UDim.new(0, 9)

    local note = Instance.new("TextLabel")
    note.BackgroundTransparency = 1
    note.Position = UDim2.fromOffset(0, 38)
    note.Size = UDim2.new(1, 0, 0, 32)
    note.Font = Enum.Font.Gotham
    note.Text = "Jump back into catalog items you inspected recently. Stored as Roblox asset IDs only."
    note.TextColor3 = Color3.fromRGB(157, 164, 184)
    note.TextSize = 12
    note.TextXAlignment = Enum.TextXAlignment.Left
    note.Parent = content

    local list = Instance.new("ScrollingFrame")
    list.Name = "RecentItems"
    list.BackgroundTransparency = 1
    list.Position = UDim2.fromOffset(0, 76)
    list.Size = UDim2.new(1, 0, 1, -112)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.CanvasSize = UDim2.new()
    list.ScrollBarThickness = 4
    list.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = list

    clearButton.Activated:Connect(function()
        if clearRecentHistory() and list.Parent then
            for _, child in ipairs(list:GetChildren()) do
                if child ~= layout then child:Destroy() end
            end
        end
    end)

    task.spawn(function()
        if not recentLoaded then
            local waited = 0
            while recentLoadInFlight and waited < 5 do task.wait(0.1); waited += 0.1 end
        end
        if not list.Parent then return end
        if #recentIds == 0 then
            status.Text = "Open item DETAILS and they will appear here."
            return
        end

        local shown = 0
        for _, id in ipairs(recentIds) do
            if not list.Parent then return end
            local item = resolveRecentItem(id)
            if item then
                catalogCard(list, item)
                shown += 1
            end
            if shown >= 12 then break end
        end
        status.Text = shown > 0 and string.format("%d recent items ready", shown) or "Recent item details are temporarily unavailable."
        if shown > 0 then recentTrack("RECENT_RESULT") end
    end)
end

renderers.RECENT = renderRecent

local recentTab = Instance.new("TextButton")
recentTab.Name = "RecentTab"
recentTab.Size = UDim2.fromOffset(104, 38)
recentTab.BackgroundColor3 = Color3.fromRGB(35, 37, 46)
recentTab.TextColor3 = Color3.new(1, 1, 1)
recentTab.Font = Enum.Font.GothamBold
recentTab.TextSize = 11
recentTab.Text = "RECENT"
recentTab.Parent = tabs
Instance.new("UICorner", recentTab).CornerRadius = UDim.new(0, 10)
recentTab.Activated:Connect(function() selectTab("RECENT") end)

local recentBaseCatalogCard = catalogCard
catalogCard = function(parent, item)
    local card = recentBaseCatalogCard(parent, item)
    if not card then return card end
    local preview = card:FindFirstChild("Preview")
    local inspect = preview and preview:FindFirstChild("Inspect")
    if inspect and inspect:IsA("TextButton") then
        inspect.Activated:Connect(function() recordRecentView(item) end)
    end
    return card
end

-- Return-loop integration: add one persisted Continue Viewing entry to the top of Discover.
-- Only the asset ID is persisted; current item metadata is resolved from Roblox on demand.
local recentBaseDiscovery = renderers.DISCOVER
if recentBaseDiscovery then
    renderers.DISCOVER = function()
        recentBaseDiscovery()
        task.spawn(function()
            loadRecent()
            local waited = 0
            while recentLoadInFlight and waited < 5 do task.wait(0.1); waited += 0.1 end
            if #recentIds == 0 then return end

            local item = resolveRecentItem(recentIds[1])
            if not item then return end
            local feed = content:FindFirstChild("DiscoveryFeed")
            if not feed or feed.Parent ~= content then return end

            local button = Instance.new("TextButton")
            button.Name = "ContinueViewing"
            button.LayoutOrder = -100
            button.Size = UDim2.new(1, -4, 0, 74)
            button.BackgroundColor3 = Color3.fromRGB(58, 61, 91)
            button.Text = ""
            button.AutoButtonColor = true
            button.Parent = feed
            Instance.new("UICorner", button).CornerRadius = UDim.new(0, 13)

            local title = Instance.new("TextLabel")
            title.BackgroundTransparency = 1
            title.Position = UDim2.fromOffset(14, 8)
            title.Size = UDim2.new(1, -28, 0, 26)
            title.Font = Enum.Font.GothamBold
            title.Text = "CONTINUE VIEWING"
            title.TextColor3 = Color3.new(1, 1, 1)
            title.TextSize = 14
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Parent = button

            local itemName = tostring(item.Name or item.name or ("Catalog Item " .. tostring(recentIds[1])))
            local sub = Instance.new("TextLabel")
            sub.BackgroundTransparency = 1
            sub.Position = UDim2.fromOffset(14, 36)
            sub.Size = UDim2.new(1, -28, 0, 24)
            sub.Font = Enum.Font.Gotham
            sub.Text = itemName
            sub.TextColor3 = Color3.fromRGB(196, 201, 220)
            sub.TextSize = 11
            sub.TextXAlignment = Enum.TextXAlignment.Left
            sub.TextTruncate = Enum.TextTruncate.AtEnd
            sub.Parent = button

            button.Activated:Connect(function()
                recentTrack("RECENT_CONTINUE")
                recordRecentView(item)
                openItemDetail(item)
            end)
        end)
    end
end

print("[BBYAVATAR] Persistent Recently Viewed v4 + Continue Viewing return loop ready")