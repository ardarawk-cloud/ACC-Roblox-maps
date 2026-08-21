-- BBYAVATAR item detail drawer.
-- Adds an intentional inspection step before try-on/save/purchase without storing creator or description data.
-- Marketplace metadata is fetched only when the player opens a detail view.
-- v3 adds purchase-state gating so stale/off-sale metadata never presents a misleading active BUY action.

local DETAIL_CACHE_TTL = 120
local DETAIL_CACHE_MAX = 24
local detailInfoCache = {}
local detailCacheOrder = {}

local BUY_ENABLED_COLOR = Color3.fromRGB(64, 91, 72)
local BUY_DISABLED_COLOR = Color3.fromRGB(55, 57, 65)

local function detailTrack(eventName)
    local remote = root:FindFirstChild("TrackEvent")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(eventName) end)
    end
end

local function detailCacheKey(id, bundle)
    return (bundle and "B:" or "A:") .. tostring(id)
end

local function detailCacheGet(id, bundle)
    local key = detailCacheKey(id, bundle)
    local entry = detailInfoCache[key]
    if not entry then return nil end
    if os.clock() - entry.at > DETAIL_CACHE_TTL then
        detailInfoCache[key] = nil
        return nil
    end
    return entry.info
end

local function detailCachePut(id, bundle, info)
    local key = detailCacheKey(id, bundle)
    if not detailInfoCache[key] then
        table.insert(detailCacheOrder, key)
    end
    detailInfoCache[key] = {at = os.clock(), info = info}
    while #detailCacheOrder > DETAIL_CACHE_MAX do
        local oldest = table.remove(detailCacheOrder, 1)
        detailInfoCache[oldest] = nil
    end
end

local detailShade = Instance.new("Frame")
detailShade.Name = "ItemDetailShade"
detailShade.Size = UDim2.fromScale(1, 1)
detailShade.BackgroundColor3 = Color3.new(0, 0, 0)
detailShade.BackgroundTransparency = 0.35
detailShade.Visible = false
detailShade.ZIndex = 80
detailShade.Parent = gui

local detailPanel = Instance.new("Frame")
detailPanel.Name = "ItemDetailPanel"
detailPanel.AnchorPoint = Vector2.new(0.5, 0.5)
detailPanel.Position = UDim2.fromScale(0.5, 0.5)
detailPanel.Size = UDim2.fromScale(0.78, 0.72)
detailPanel.BackgroundColor3 = Color3.fromRGB(20, 22, 29)
detailPanel.ZIndex = 81
detailPanel.Parent = detailShade
Instance.new("UICorner", detailPanel).CornerRadius = UDim.new(0, 18)
local detailLimit = Instance.new("UISizeConstraint")
detailLimit.MaxSize = Vector2.new(720, 560)
detailLimit.MinSize = Vector2.new(290, 360)
detailLimit.Parent = detailPanel

local detailClose = Instance.new("TextButton")
detailClose.AnchorPoint = Vector2.new(1, 0)
detailClose.Position = UDim2.new(1, -14, 0, 14)
detailClose.Size = UDim2.fromOffset(42, 38)
detailClose.BackgroundColor3 = Color3.fromRGB(45, 48, 59)
detailClose.TextColor3 = Color3.new(1, 1, 1)
detailClose.Font = Enum.Font.GothamBold
detailClose.TextSize = 22
detailClose.Text = "×"
detailClose.ZIndex = 83
detailClose.Parent = detailPanel
Instance.new("UICorner", detailClose).CornerRadius = UDim.new(0, 10)

local detailImage = Instance.new("ImageLabel")
detailImage.Position = UDim2.fromOffset(20, 20)
detailImage.Size = UDim2.fromOffset(150, 150)
detailImage.BackgroundColor3 = Color3.fromRGB(27, 30, 38)
detailImage.ScaleType = Enum.ScaleType.Fit
detailImage.ZIndex = 82
detailImage.Parent = detailPanel
Instance.new("UICorner", detailImage).CornerRadius = UDim.new(0, 14)

local detailName = Instance.new("TextLabel")
detailName.BackgroundTransparency = 1
detailName.Position = UDim2.fromOffset(186, 20)
detailName.Size = UDim2.new(1, -250, 0, 58)
detailName.Font = Enum.Font.GothamBlack
detailName.TextColor3 = Color3.new(1, 1, 1)
detailName.TextSize = 20
detailName.TextWrapped = true
detailName.TextXAlignment = Enum.TextXAlignment.Left
detailName.TextYAlignment = Enum.TextYAlignment.Top
detailName.ZIndex = 82
detailName.Parent = detailPanel

local detailMeta = Instance.new("TextLabel")
detailMeta.BackgroundTransparency = 1
detailMeta.Position = UDim2.fromOffset(186, 86)
detailMeta.Size = UDim2.new(1, -210, 0, 84)
detailMeta.Font = Enum.Font.Gotham
detailMeta.TextColor3 = Color3.fromRGB(169, 175, 194)
detailMeta.TextSize = 13
detailMeta.TextWrapped = true
detailMeta.TextXAlignment = Enum.TextXAlignment.Left
detailMeta.TextYAlignment = Enum.TextYAlignment.Top
detailMeta.ZIndex = 82
detailMeta.Parent = detailPanel

local detailDescription = Instance.new("TextLabel")
detailDescription.BackgroundColor3 = Color3.fromRGB(27, 30, 38)
detailDescription.Position = UDim2.fromOffset(20, 186)
detailDescription.Size = UDim2.new(1, -40, 1, -276)
detailDescription.Font = Enum.Font.Gotham
detailDescription.TextColor3 = Color3.fromRGB(215, 218, 228)
detailDescription.TextSize = 13
detailDescription.TextWrapped = true
detailDescription.TextXAlignment = Enum.TextXAlignment.Left
detailDescription.TextYAlignment = Enum.TextYAlignment.Top
detailDescription.ZIndex = 82
detailDescription.Parent = detailPanel
Instance.new("UICorner", detailDescription).CornerRadius = UDim.new(0, 12)
local descriptionPadding = Instance.new("UIPadding")
descriptionPadding.PaddingLeft = UDim.new(0, 14)
descriptionPadding.PaddingRight = UDim.new(0, 14)
descriptionPadding.PaddingTop = UDim.new(0, 12)
descriptionPadding.PaddingBottom = UDim.new(0, 12)
descriptionPadding.Parent = detailDescription

local actionBar = Instance.new("Frame")
actionBar.BackgroundTransparency = 1
actionBar.AnchorPoint = Vector2.new(0, 1)
actionBar.Position = UDim2.new(0, 20, 1, -18)
actionBar.Size = UDim2.new(1, -40, 0, 54)
actionBar.ZIndex = 82
actionBar.Parent = detailPanel
local actionLayout = Instance.new("UIListLayout")
actionLayout.FillDirection = Enum.FillDirection.Horizontal
actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
actionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
actionLayout.Padding = UDim.new(0, 8)
actionLayout.Parent = actionBar

local function detailButton(name, text, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.31, -6, 0, 42)
    button.BackgroundColor3 = color
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.Text = text
    button.ZIndex = 83
    button.Parent = actionBar
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)
    return button
end

local detailTry = detailButton("TryOn", "TRY ON", Color3.fromRGB(62, 76, 112))
local detailSave = detailButton("SavePick", "SAVE PICK", Color3.fromRGB(55, 67, 86))
local detailBuy = detailButton("Buy", "BUY", BUY_ENABLED_COLOR)

local activeDetailItem = nil
local activeDetailId = nil
local detailLoadSerial = 0
local detailPurchasable = nil

local function setDetailPurchaseState(state, price)
    detailPurchasable = state
    if state == false then
        detailBuy.Active = false
        detailBuy.AutoButtonColor = false
        detailBuy.BackgroundColor3 = BUY_DISABLED_COLOR
        detailBuy.Text = "OFF SALE"
    elseif state == true then
        detailBuy.Active = true
        detailBuy.AutoButtonColor = true
        detailBuy.BackgroundColor3 = BUY_ENABLED_COLOR
        detailBuy.Text = price and ("BUY • " .. tostring(price) .. " R$") or "BUY"
    else
        detailBuy.Active = false
        detailBuy.AutoButtonColor = false
        detailBuy.BackgroundColor3 = BUY_DISABLED_COLOR
        detailBuy.Text = "CHECKING…"
    end
end

local function closeDetail()
    detailShade.Visible = false
    activeDetailItem = nil
    activeDetailId = nil
    detailPurchasable = nil
    detailLoadSerial += 1
end

detailClose.Activated:Connect(closeDetail)
detailShade.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position then
        -- Panel itself consumes its own button input; shade click remains intentionally inert.
    end
end)

local function safeCreatorText(info)
    if typeof(info) ~= "table" then return "Creator unavailable" end
    if info.Creator and typeof(info.Creator) == "table" then
        return tostring(info.Creator.Name or info.Creator.CreatorTargetId or "Creator unavailable")
    end
    return "Creator unavailable"
end

local function applyDetailInfo(id, bundle, info)
    local currentName = info.Name or detailName.Text
    local price = info.PriceInRobux
    local creator = safeCreatorText(info)
    local isForSale = info.IsForSale ~= false
    local saleText = isForSale and (price and (tostring(price) .. " R$") or "Price confirmed in Roblox purchase prompt") or "Not currently for sale"
    detailName.Text = tostring(currentName)
    detailMeta.Text = saleText .. " • " .. (bundle and "Bundle" or "Asset") .. "\nBy " .. creator .. " • ID " .. tostring(id)
    local description = tostring(info.Description or "No catalog description provided.")
    if #description > 900 then description = string.sub(description, 1, 897) .. "…" end
    detailDescription.Text = description
    setDetailPurchaseState(isForSale, price)
end

local function openItemDetail(item)
    local id = tonumber(item and (item.Id or item.AssetId or item.id))
    if not id then return end
    activeDetailItem = item
    activeDetailId = id
    detailLoadSerial += 1
    local serial = detailLoadSerial
    local bundle = isBundleItem(item)
    detailImage.Image = itemThumb(item, id)
    detailName.Text = tostring(item.Name or item.name or ("Catalog Item " .. tostring(id)))
    detailMeta.Text = "Loading Roblox catalog details…\nID " .. tostring(id)
    detailDescription.Text = "Fetching current Marketplace information."
    detailTry.Visible = not bundle
    detailSave.Text = savedPicks[id] and "SAVED ✓" or "SAVE PICK"
    setDetailPurchaseState(nil)
    detailShade.Visible = true
    detailTrack("DETAIL_OPEN")

    local cached = detailCacheGet(id, bundle)
    if cached then
        applyDetailInfo(id, bundle, cached)
        detailTrack("DETAIL_CACHE_HIT")
        return
    end

    task.spawn(function()
        local ok, info = pcall(function()
            return MarketplaceService:GetProductInfoAsync(id, bundle and Enum.InfoType.Bundle or Enum.InfoType.Asset)
        end)
        if serial ~= detailLoadSerial or not detailShade.Visible then return end
        if not ok or typeof(info) ~= "table" then
            detailMeta.Text = (bundle and "Bundle" or "Asset") .. " • ID " .. tostring(id)
            detailDescription.Text = "Live catalog metadata is temporarily unavailable. Try-on and Saved Picks remain available; purchase is paused here until Roblox confirms current sale status."
            setDetailPurchaseState(nil)
            detailTrack("DETAIL_FAILED")
            return
        end
        detailCachePut(id, bundle, info)
        applyDetailInfo(id, bundle, info)
        detailTrack("DETAIL_RESULT")
    end)
end

detailTry.Activated:Connect(function()
    if activeDetailItem then applyTryOn(activeDetailItem) end
end)

detailSave.Activated:Connect(function()
    if not activeDetailItem or not activeDetailId then return end
    if savedPicks[activeDetailId] then
        status.Text = "Already in Saved Picks."
        detailSave.Text = "SAVED ✓"
        return
    end
    local ok, message = savePick(activeDetailItem)
    status.Text = message
    if ok then detailSave.Text = "SAVED ✓" end
end)

detailBuy.Activated:Connect(function()
    if not activeDetailItem or not activeDetailId then return end
    if detailPurchasable ~= true then
        status.Text = detailPurchasable == false and "This item is not currently for sale." or "Checking current Roblox sale status…"
        return
    end
    local bundle = isBundleItem(activeDetailItem)
    local ok, err = pcall(function()
        if bundle then
            MarketplaceService:PromptBundlePurchase(player, activeDetailId)
        else
            MarketplaceService:PromptPurchase(player, activeDetailId)
        end
    end)
    if not ok then status.Text = "Purchase prompt unavailable: " .. tostring(err) end
end)

local baseDetailCatalogCard = catalogCard
catalogCard = function(parent, item)
    local card = baseDetailCatalogCard(parent, item)
    if not card then return card end
    local id = tonumber(item and (item.Id or item.AssetId or item.id))
    local preview = card:FindFirstChild("Preview")
    if not id or not preview then return card end

    local inspect = Instance.new("TextButton")
    inspect.Name = "Inspect"
    inspect.Size = UDim2.fromScale(1, 1)
    inspect.BackgroundTransparency = 1
    inspect.Text = ""
    inspect.ZIndex = preview.ZIndex + 1
    inspect.Parent = preview
    inspect.Activated:Connect(function()
        openItemDetail(item)
    end)

    local hint = Instance.new("TextLabel")
    hint.AnchorPoint = Vector2.new(0.5, 1)
    hint.Position = UDim2.fromScale(0.5, 0.96)
    hint.Size = UDim2.new(1, -10, 0, 20)
    hint.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    hint.BackgroundTransparency = 0.16
    hint.TextColor3 = Color3.new(1, 1, 1)
    hint.Font = Enum.Font.GothamBold
    hint.TextSize = 9
    hint.Text = "DETAILS"
    hint.ZIndex = inspect.ZIndex + 1
    hint.Parent = preview
    Instance.new("UICorner", hint).CornerRadius = UDim.new(0, 7)
    return card
end

print("[BBYAVATAR] Item detail v3 purchase-state gating ready")