-- BBYAVATAR context-aware recommendation lane.
-- Uses Roblox-native recommendation APIs from a Saved Pick as the context seed.
-- No external profiling, no PII, and no fabricated ranking signals.

local function recommendationTrack(eventName)
    local remote = root:FindFirstChild("TrackEvent")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(eventName) end)
    end
end

local function resolveAvatarAssetType(item)
    if not item then return nil end
    local raw = item.AssetType or item.assetType
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

local function newestRecommendationSeed()
    for index = #savedPickOrder, 1, -1 do
        local id = savedPickOrder[index]
        local item = savedPicks[id]
        if item and not isBundleItem(item) then
            local assetType = resolveAvatarAssetType(item)
            if assetType then return item, id, assetType end
        end
    end
    return nil, nil, nil
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

    local seed, seedId, assetType = newestRecommendationSeed()
    if not seed then
        local empty = Instance.new("TextLabel")
        empty.Position = UDim2.fromOffset(0, 52)
        empty.Size = UDim2.new(1, 0, 0, 120)
        empty.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        empty.Font = Enum.Font.Gotham
        empty.Text = "Save at least one wearable item to PICKS first.\nBBYAVATAR will then ask Roblox for visually/category-related catalog recommendations from that item."
        empty.TextWrapped = true
        empty.TextColor3 = Color3.fromRGB(205, 208, 219)
        empty.TextSize = 14
        empty.Parent = content
        Instance.new("UICorner", empty).CornerRadius = UDim.new(0, 12)
        status.Text = "No recommendation seed yet."
        return
    end

    local seedLabel = Instance.new("TextLabel")
    seedLabel.BackgroundTransparency = 1
    seedLabel.Position = UDim2.fromOffset(0, 38)
    seedLabel.Size = UDim2.new(1, 0, 0, 34)
    seedLabel.Font = Enum.Font.Gotham
    seedLabel.Text = "Inspired by: " .. tostring(seed.Name or ("Item " .. tostring(seedId)))
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

    status.Text = "Loading Roblox recommendations…"
    task.spawn(function()
        local ok, recommended = pcall(function()
            return AvatarEditorService:GetRecommendedAssetsAsync(assetType, seedId)
        end)
        if not ok or typeof(recommended) ~= "table" then
            recommendationTrack("RECOMMEND_FAILED")
            if list.Parent then
                status.Text = "Recommendations are temporarily unavailable."
            end
            return
        end

        local shown = 0
        for _, item in ipairs(recommended) do
            if shown >= 18 then break end
            local id = tonumber(item.Id or item.AssetId or item.id)
            if id and id ~= seedId then
                catalogCard(list, item)
                shown += 1
            end
        end

        if list.Parent then
            if shown > 0 then
                recommendationTrack("RECOMMEND_RESULT")
                status.Text = tostring(shown) .. " Roblox recommendations loaded • seed ID " .. tostring(seedId)
            else
                status.Text = "No similar items returned for this pick yet."
            end
        end
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

print("[BBYAVATAR] Roblox-native contextual recommendations ready")