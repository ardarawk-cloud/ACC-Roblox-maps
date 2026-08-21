-- BBYAVATAR Recently Viewed v2.
-- Persists only catalog asset IDs through the server module; details are resolved from Roblox on demand.
-- v2 exposes a privacy-minimal recommendation seed so SIMILAR can work after browsing even before a user saves a pick.

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

-- Shared locally with recommendations.client.lua. It returns only Roblox catalog data already
-- present in the user's recent history; no extra profile or identifier is introduced.
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

local function renderRecent()
    clearContent()
    recentTrack("RECENT_OPEN")
    loadRecent()

    local heading = Instance.new("TextLabel")
    heading.BackgroundTransparency = 1
    heading.Size = UDim2.new(1, 0, 0, 38)
    heading.Font = Enum.Font.GothamBlack
    heading.Text = "RECENTLY VIEWED"
    heading.TextColor3 = Color3.new(1, 1, 1)
    heading.TextSize = 23
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Parent = content

    local note = Instance.new("TextLabel")
    note.BackgroundTransparency = 1
    note.Position = UDim2.fromOffset(0, 38)
    note.Size = UDim2.new(1, 0, 0, 32)
    note.Font = Enum.Font.Gotham
    note.Text = "Jump back into catalog items you inspected recently."
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

-- Loaded after item-detail.client.lua: wrap the finished card so opening DETAILS also
-- updates the user's privacy-minimal recent history without changing item-detail internals.
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

print("[BBYAVATAR] Persistent Recently Viewed v2 + recommendation seed ready")