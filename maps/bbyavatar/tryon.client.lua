-- BBYAVATAR live try-on preview v2.
-- Extends catalogCard after catalog-grid.client.lua and before catalog-filters.client.lua.
-- Uses HumanoidDescription only; purchases remain Roblox-native prompts.
-- v2 adds one-pass full-look composition for Style Board so a selected look can be
-- previewed atomically instead of racing several individual ApplyDescriptionAsync calls.

local layeredAccessoryNames = {
    Jacket = true,
    Sweater = true,
    Shirt = true,
    Pants = true,
    TShirt = true,
    Shorts = true,
    DressSkirt = true,
    LeftShoe = true,
    RightShoe = true,
}

local originalTryOnDescription = nil
local tryOnBusy = false

local undoTryOn = Instance.new("TextButton")
undoTryOn.Name = "UndoTryOn"
undoTryOn.AnchorPoint = Vector2.new(0, 1)
undoTryOn.Position = UDim2.fromScale(0.03, 0.94)
undoTryOn.Size = UDim2.fromOffset(118, 42)
undoTryOn.BackgroundColor3 = Color3.fromRGB(52, 54, 68)
undoTryOn.TextColor3 = Color3.new(1, 1, 1)
undoTryOn.Font = Enum.Font.GothamBold
undoTryOn.TextSize = 12
undoTryOn.Text = "UNDO TRY-ON"
undoTryOn.Visible = false
undoTryOn.Parent = gui
Instance.new("UICorner", undoTryOn).CornerRadius = UDim.new(0, 12)

local function currentHumanoid()
    local character = player.Character or player.CharacterAdded:Wait()
    return character:FindFirstChildOfClass("Humanoid")
end

local function assetTypeName(item)
    local value = item and (item.AssetType or item.assetType)
    if typeof(value) == "EnumItem" then return value.Name end
    if value == nil then return nil end
    local text = tostring(value)
    return text:match("([^%.]+)$") or text
end

local function avatarAssetType(item)
    local name = assetTypeName(item)
    if not name then return nil end
    local ok, value = pcall(function()
        return Enum.AvatarAssetType[name]
    end)
    if ok then return value end
    return nil
end

local function replaceAccessory(description, assetId, accessoryType)
    local accessories = description:GetAccessories(true)
    local nextAccessories = {}
    local maxOrder = 0

    for _, info in ipairs(accessories) do
        if info.Order and info.Order > maxOrder then maxOrder = info.Order end
        if info.AccessoryType ~= accessoryType then
            table.insert(nextAccessories, info)
        end
    end

    local newInfo = {
        AssetId = assetId,
        AccessoryType = accessoryType,
    }
    if layeredAccessoryNames[accessoryType.Name] then
        newInfo.Order = math.min(maxOrder + 1, 100)
        newInfo.Puffiness = 0
        newInfo.IsLayered = true
    end
    table.insert(nextAccessories, newInfo)
    description:SetAccessories(nextAccessories, true)
end

-- Mutates a provided HumanoidDescription. Keeping this separate from the single-item
-- path lets a whole board be composed first and applied once, which is both faster and
-- substantially safer than overlapping async avatar applies.
local function applyItemToDescription(description, item, assetId)
    local typeName = assetTypeName(item)

    if typeName == "Shirt" then
        description.Shirt = assetId
        return true
    elseif typeName == "Pants" then
        description.Pants = assetId
        return true
    elseif typeName == "TShirt" then
        description.GraphicTShirt = assetId
        return true
    end

    local avatarType = avatarAssetType(item)
    if not avatarType then return false, "unsupported item type" end

    local ok, accessoryType = pcall(function()
        return AvatarEditorService:GetAccessoryType(avatarType)
    end)
    if not ok or not accessoryType or accessoryType.Name == "Unknown" then
        return false, "unsupported wearable type"
    end

    local changed, err = pcall(function()
        replaceAccessory(description, assetId, accessoryType)
    end)
    if not changed then return false, tostring(err) end
    return true
end

local function buildTryOnDescription(item, assetId, humanoid)
    local description = humanoid:GetAppliedDescription()
    local ok, reason = applyItemToDescription(description, item, assetId)
    if not ok then return nil, reason or "This item type cannot be previewed yet." end
    return description
end

local function fireTryOnTelemetry(eventName)
    local remote = root:FindFirstChild("TrackEvent")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(eventName) end)
    end
end

local function rememberOriginal(humanoid)
    if not originalTryOnDescription then
        originalTryOnDescription = humanoid:GetAppliedDescription()
    end
end

local function applyPreparedDescription(humanoid, description, successEvent, failedEvent, successText)
    local conformed = description
    pcall(function()
        conformed = AvatarEditorService:ConformToAvatarRulesAsync(description)
    end)

    local ok, err = pcall(function()
        humanoid:ApplyDescriptionAsync(conformed)
    end)
    if ok then
        undoTryOn.Visible = true
        status.Text = successText or "Preview applied • use UNDO TRY-ON to restore your join look."
        fireTryOnTelemetry(successEvent or "TRY_ON_SUCCESS")
    else
        status.Text = "Try-on failed: " .. tostring(err)
        fireTryOnTelemetry(failedEvent or "TRY_ON_FAILED")
    end
    return ok
end

local function applyTryOn(item)
    if tryOnBusy then return end
    local assetId = tonumber(item and (item.Id or item.AssetId or item.id))
    if not assetId or isBundleItem(item) then
        status.Text = "Try-on currently supports individual wearable assets."
        return
    end

    local humanoid = currentHumanoid()
    if not humanoid then
        status.Text = "Avatar is not ready yet."
        return
    end

    rememberOriginal(humanoid)
    tryOnBusy = true
    status.Text = "Applying try-on preview…"
    task.spawn(function()
        local description, reason = buildTryOnDescription(item, assetId, humanoid)
        if not description then
            status.Text = reason or "Try-on unavailable for this item."
            fireTryOnTelemetry("TRY_ON_FAILED")
            tryOnBusy = false
            return
        end

        applyPreparedDescription(humanoid, description, "TRY_ON_SUCCESS", "TRY_ON_FAILED")
        tryOnBusy = false
    end)
end

-- Public within the concatenated BBYAVATAR client chunk. Style Board is loaded after
-- this module and can call it directly without RemoteEvents or client-controlled IDs.
-- Only item tables already sourced from authoritative Roblox catalog/Saved Picks state
-- are consumed. Unsupported entries are skipped; no purchase is ever triggered here.
local function applyTryOnBatch(items)
    if tryOnBusy then
        status.Text = "Finish the current avatar preview first."
        return false
    end
    if typeof(items) ~= "table" or #items == 0 then
        status.Text = "Add wearable items to your Style Board first."
        return false
    end

    local humanoid = currentHumanoid()
    if not humanoid then
        status.Text = "Avatar is not ready yet."
        return false
    end

    rememberOriginal(humanoid)
    tryOnBusy = true
    status.Text = "Composing full-look preview…"
    fireTryOnTelemetry("BOARD_TRY_ALL_START")

    task.spawn(function()
        local description = humanoid:GetAppliedDescription()
        local applied = 0
        local skipped = 0

        for _, item in ipairs(items) do
            local assetId = tonumber(item and (item.Id or item.AssetId or item.id))
            if assetId and not isBundleItem(item) then
                local ok = applyItemToDescription(description, item, assetId)
                if ok then applied += 1 else skipped += 1 end
            else
                skipped += 1
            end
        end

        if applied == 0 then
            status.Text = "No selected Style Board items can be previewed together yet."
            fireTryOnTelemetry("BOARD_TRY_ALL_FAILED")
            tryOnBusy = false
            return
        end

        local suffix = skipped > 0 and string.format(" • %d unsupported skipped", skipped) or ""
        applyPreparedDescription(
            humanoid,
            description,
            "BOARD_TRY_ALL_SUCCESS",
            "BOARD_TRY_ALL_FAILED",
            string.format("Full look previewed • %d item%s applied%s", applied, applied == 1 and "" or "s", suffix)
        )
        tryOnBusy = false
    end)
    return true
end

undoTryOn.Activated:Connect(function()
    if tryOnBusy or not originalTryOnDescription then return end
    local humanoid = currentHumanoid()
    if not humanoid then return end
    tryOnBusy = true
    status.Text = "Restoring avatar…"
    task.spawn(function()
        local ok, err = pcall(function()
            humanoid:ApplyDescriptionAsync(originalTryOnDescription)
        end)
        if ok then
            undoTryOn.Visible = false
            originalTryOnDescription = nil
            status.Text = "Avatar restored."
        else
            status.Text = "Could not restore avatar: " .. tostring(err)
        end
        tryOnBusy = false
    end)
end)

player.CharacterAdded:Connect(function()
    originalTryOnDescription = nil
    undoTryOn.Visible = false
    tryOnBusy = false
end)

local baseCatalogCard = catalogCard
catalogCard = function(parent, item)
    local card = baseCatalogCard(parent, item)
    if not card then return card end

    card.Size = UDim2.new(1, -4, 0, 158)
    local itemId = tonumber(item and (item.Id or item.AssetId or item.id))
    if not itemId or isBundleItem(item) then return card end

    local tryButton = Instance.new("TextButton")
    tryButton.Name = "TryOn"
    tryButton.AnchorPoint = Vector2.new(1, 0)
    tryButton.Position = UDim2.new(1, -12, 0, 110)
    tryButton.Size = UDim2.fromOffset(84, 38)
    tryButton.BackgroundColor3 = Color3.fromRGB(62, 76, 112)
    tryButton.Text = "TRY ON"
    tryButton.TextColor3 = Color3.new(1, 1, 1)
    tryButton.Font = Enum.Font.GothamBold
    tryButton.TextSize = 12
    tryButton.Parent = card
    Instance.new("UICorner", tryButton).CornerRadius = UDim.new(0, 10)
    tryButton.Activated:Connect(function()
        applyTryOn(item)
    end)

    return card
end

print("[BBYAVATAR] Live wearable try-on v2 + atomic full-look batch preview ready")