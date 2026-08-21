-- BBYAVATAR context-aware recommendation lane v4.
-- Uses Roblox-native recommendation APIs from a Saved Pick, falling back to the user's
-- most recent viewed wearable so SIMILAR remains useful before a pick is saved.
-- No external profiling, no PII, and no fabricated ranking signals.
-- v4 preserves resilient asset-type resolution, in-flight request coalescing, cooldowns,
-- and per-seed caching to reduce AvatarEditorService throttling pressure.

local RECOMMEND_CACHE_TTL = 120
local RECOMMEND_FAILURE_COOLDOWN = 20
local recommendationCache = {}
local recommendationInflight = {}
local recommendationFailureAt = {}
local assetTypeCache = {}

local function recommendationTrack(eventName)
    local remote = root:FindFirstChild("TrackEvent")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(eventName) end)
    end
end

local function resolveEnumAvatarAssetType(raw)
    if typeof(raw) == "EnumItem" and raw.EnumType == Enum.AvatarAssetType then
        return raw
    end
    if typeof(raw) == "string" and raw ~= "" then
        local ok, value = pcall(function()
            return Enum.AvatarAssetType[raw]
        end)
        if ok then return value end
    end
    return nil
end

local function resolveAvatarAssetType(item, itemId)
    if not item then return nil end
    local direct = resolveEnumAvatarAssetType(item.AssetType or item.assetType)
    if direct then
        if itemId then assetTypeCache[itemId] = direct end
        return direct
    end

    if itemId and assetTypeCache[itemId] then
        return assetTypeCache[itemId]
    end

    if itemId then
        local ok, details = pcall(function()
            return AvatarEditorService:GetItemDetailsAsync(itemId, Enum.AvatarItemType.Asset)
        end)
        if ok and typeof(details) == "table" then
            local resolved = resolveEnumAvatarAssetType(details.AssetType or details.assetType)
            if resolved then
                assetTypeCache[itemId] = resolved
                return resolved
            end
        end
    end

    return nil
end

local function newestRecommendationSeed()
    for index = #savedPickOrder, 1, -1 do
        local id = savedPickOrder[index]
        local item = savedPicks[id]
        if item and not isBundleItem(item) then
            local assetType = resolveAvatarAssetType(item, id)
            if assetType then return item, id, assetType, "saved" end
        end
    end

    -- Recent history is a second-party signal created only from the user's own in-experience
    -- browsing. If that module is unavailable or cannot resolve a wearable, fail closed.
    if typeof(getRecentRecommendationSeed) == "function" then
        local item, id = getRecentRecommendationSeed()
        if item and id then
            local assetType = resolveAvatarAssetType(item, id)
            if assetType then return item, id, assetType, "recent" end
        end
    end

    return nil, nil, nil, nil
end

local function normalizeRecommendedAsset(entry)
    if typeof(entry) ~= "table" then return nil end
    local source = entry.Item or entry.item or entry
    if typeof(source) ~= "table" then return nil end

    local item = {}
    for key, value in pairs(source) do item[key] = value end
    for _, key in ipairs({"Price", "LowestPrice", "ProductId", "ItemStatus", "ItemRestrictions", "CreatorName", "CreatorType", "AssetType"}) do
        if item[key] == nil and entry[key] ~= nil then item[key] = entry[key] end
    end

    local id = tonumber(item.Id or item.AssetId or item.id)
    if not id then return nil end
    item.Id = id
    if item.ItemType == nil and item.itemType == nil then item.ItemType = Enum.AvatarItemType.Asset end
    local resolved = resolveEnumAvatarAssetType(item.AssetType or item.assetType)
    if resolved then assetTypeCache[id] = resolved end
    return item
end

local function cachedRecommendations(seedId)
    local cached = recommendationCache[seedId]
    if not cached then return nil end
    if os.clock() - cached.at > RECOMMEND_CACHE_TTL then
        recommendationCache[seedId] = nil
        return nil
    end
    return cached.items
end

local function saveRecommendationCache(seedId, items)
    recommendationCache[seedId] = {at = os.clock(), items = items}
    recommendationFailureAt[seedId] = nil
end

local function inFailureCooldown(seedId)
    local at = recommendationFailureAt[seedId]
    return at and (os.clock() - at < RECOMMEND_FAILURE_COOLDOWN)
end

local function renderRecommendations()
    clearContent()
    recommendationTrack("RECOMMEND_OPEN")

    local heading = Instance.new("TextLabel")
    heading.BackgroundTransparency = 1
    heading.Size = UDim2.new(1, 0, 0, 38)
    heading.Font = Enum.Font.GothamBlack
    heading.Text = "SIMILAR PICKS"
    heading.TextColor3 = Color3.new(1, 1, 1)
    heading.TextSize = 23
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Parent = content

    status.Text = "Finding a recommendation seed…"
    local seed, seedId, assetType, seedSource = newestRecommendationSeed()
    if not seed then
        local empty = Instance.new("TextLabel")
        empty.Position = UDim2.fromOffset(0, 52)
        empty.Size = UDim2.new(1, 0, 0, 120)
        empty.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        empty.Font = Enum.Font.Gotham
        empty.Text = "Browse a wearable item or save one to PICKS first.\nBBYAVATAR will then ask Roblox for related catalog recommendations from that item."
        empty.TextWrapped = true
        empty.TextColor3 = Color3.fromRGB(205, 208, 219)
        empty.TextSize = 14
        empty.Parent = content
        Instance.new("UICorner", empty).CornerRadius = UDim.new(0, 12)
        status.Text = "No compatible recommendation seed yet."
        return
    end

    local seedLabel = Instance.new("TextLabel")
    seedLabel.BackgroundTransparency = 1
    seedLabel.Position = UDim2.fromOffset(0, 38)
    seedLabel.Size = UDim2.new(1, 0, 0, 34)
    seedLabel.Font = Enum.Font.Gotham
    local prefix = seedSource == "recent" and "Based on recent: " or "Inspired by saved: "
    seedLabel.Text = prefix .. tostring(seed.Name or ("Item " .. tostring(seedId)))
    seedLabel.TextColor3 = Color3.fromRGB(157, 164, 184)
    seedLabel.TextSize = 12
    seedLabel.TextXAlignment = Enum.TextXAlignment.Left
    seedLabel.TextTruncate = Enum.TextTruncate.AtEnd
    seedLabel.Parent = content

    local list = Instance.new("ScrollingFrame")
    list.Name = "RecommendedItems"
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

    local function renderItems(items, source)
        if not list.Parent then return end
        local shown = 0
        local seen = {}
        for _, raw in ipairs(items) do
            if shown >= 18 then break end
            local item = normalizeRecommendedAsset(raw)
            local id = item and tonumber(item.Id)
            if item and id and id ~= seedId and not seen[id] then
                seen[id] = true
                catalogCard(list, item)
                shown += 1
            end
        end

        if shown > 0 then
            recommendationTrack(source == "cache" and "RECOMMEND_CACHE_HIT" or (source == "joined" and "RECOMMEND_JOINED" or "RECOMMEND_RESULT"))
            local suffix = source == "cache" and " • cached" or (source == "joined" and " • shared request" or "")
            status.Text = string.format("%d Roblox recommendations loaded%s", shown, suffix)
        else
            status.Text = "No similar items returned for this pick yet."
        end
    end

    local cached = cachedRecommendations(seedId)
    if cached then
        renderItems(cached, "cache")
        return
    end

    if inFailureCooldown(seedId) then
        recommendationTrack("RECOMMEND_COOLDOWN")
        status.Text = "Recommendations are cooling down briefly. Try again in a moment."
        return
    end

    if recommendationInflight[seedId] then
        recommendationTrack("RECOMMEND_JOIN_WAIT")
        status.Text = "Joining the current Roblox recommendation request…"
        task.spawn(function()
            local waited = 0
            while recommendationInflight[seedId] and waited < 8 do
                task.wait(0.2)
                waited += 0.2
            end
            if not list.Parent then return end
            local joined = cachedRecommendations(seedId)
            if joined then renderItems(joined, "joined")
            else status.Text = "Recommendations are temporarily unavailable." end
        end)
        return
    end

    recommendationInflight[seedId] = true
    status.Text = "Loading Roblox recommendations…"
    task.spawn(function()
        local ok, recommended = pcall(function()
            return AvatarEditorService:GetRecommendedAssetsAsync(assetType, seedId)
        end)
        recommendationInflight[seedId] = nil

        if not ok or typeof(recommended) ~= "table" then
            recommendationFailureAt[seedId] = os.clock()
            recommendationTrack("RECOMMEND_FAILED")
            if list.Parent then status.Text = "Recommendations are temporarily unavailable." end
            return
        end

        saveRecommendationCache(seedId, recommended)
        renderItems(recommended, "live")
    end)
end

renderers.RECOMMEND = renderRecommendations

local recommendationTab = Instance.new("TextButton")
recommendationTab.Name = "RecommendTab"
recommendationTab.Size = UDim2.fromOffset(104, 38)
recommendationTab.BackgroundColor3 = Color3.fromRGB(35, 37, 46)
recommendationTab.TextColor3 = Color3.new(1, 1, 1)
recommendationTab.Font = Enum.Font.GothamBold
recommendationTab.TextSize = 11
recommendationTab.Text = "SIMILAR"
recommendationTab.Parent = tabs
Instance.new("UICorner", recommendationTab).CornerRadius = UDim.new(0, 10)
recommendationTab.Activated:Connect(function() selectTab("RECOMMEND") end)

print("[BBYAVATAR] Roblox-native contextual recommendations v4 saved + recent fallback ready")