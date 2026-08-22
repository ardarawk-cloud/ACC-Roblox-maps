-- BBYAVATAR Style Board v3
-- Session-local mix-and-match board built from persistent Saved Picks.
-- v3 adds a server-authoritative BUY MISSING flow through MarketplaceService:PromptBulkPurchase.

local STYLE_BOARD_MAX = 6
local styleBoard = {}
local bulkPurchaseRequest = root:WaitForChild("BulkPurchaseRequest")

local function boardTrack(eventName)
    local remote = root:FindFirstChild("TrackEvent")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(eventName) end)
    end
end

local function boardCount()
    local count = 0
    for _ in pairs(styleBoard) do count += 1 end
    return count
end

local function selectedBoardItems()
    local items = {}
    for _, id in ipairs(savedPickOrder) do
        if styleBoard[id] then
            local item = savedPicks[id]
            if item then table.insert(items, item) end
        end
    end
    return items
end

local function selectedBoardIds()
    local ids = {}
    for _, id in ipairs(savedPickOrder) do
        if styleBoard[id] then table.insert(ids, id) end
    end
    return ids
end

local function totalKnownPrice()
    local total, known = 0, 0
    for id in pairs(styleBoard) do
        local item = savedPicks[id]
        local price = item and tonumber(item.Price)
        if price then total += price; known += 1 end
    end
    return total, known
end

local bulkFinishedConnected = false
local function ensureBulkFinishedTelemetry()
    if bulkFinishedConnected then return end
    bulkFinishedConnected = true
    MarketplaceService.PromptBulkPurchaseFinished:Connect(function(finishedPlayer, purchaseStatus)
        if finishedPlayer ~= player then return end
        local statusName = tostring(purchaseStatus)
        if statusName:find("Success") then
            boardTrack("BOARD_BUY_SUCCESS")
            status.Text = "Purchase flow completed. Your Roblox inventory may take a moment to refresh."
        elseif statusName:find("Cancelled") or statusName:find("Aborted") then
            boardTrack("BOARD_BUY_CANCELLED")
            status.Text = "Purchase closed without completing the full look."
        else
            boardTrack("BOARD_BUY_FAILED")
            status.Text = "Roblox could not complete the full-look purchase."
        end
    end)
end
ensureBulkFinishedTelemetry()

local function requestBulkPurchase()
    local ids = selectedBoardIds()
    if #ids == 0 then return end
    boardTrack("BOARD_BUY_REQUEST")
    status.Text = "Checking which selected items you still need…"
    local ok, result = pcall(function()
        return bulkPurchaseRequest:InvokeServer(ids)
    end)
    if not ok or typeof(result) ~= "table" then
        boardTrack("BOARD_BUY_FAILED")
        status.Text = "Could not open Roblox purchase flow right now."
        return
    end
    if result.ok then
        boardTrack("BOARD_BUY_PROMPT")
        local count = tonumber(result.count) or 0
        local owned = tonumber(result.owned) or 0
        status.Text = string.format("Roblox purchase prompt opened for %d missing item(s)%s.", count, owned > 0 and (" • " .. owned .. " already owned") or "")
    elseif result.code == "ALL_OWNED" then
        status.Text = "You already own all selected purchasable items."
    elseif result.code == "THROTTLED" then
        status.Text = "Purchase check is cooling down • try again in a few seconds."
    else
        boardTrack("BOARD_BUY_FAILED")
        status.Text = "No eligible missing avatar assets were found in this board."
    end
end

local function renderStyleBoard()
    clearContent()
    boardTrack("BOARD_OPEN")

    local heading = Instance.new("TextLabel")
    heading.BackgroundTransparency = 1
    heading.Size = UDim2.new(1, 0, 0, 36)
    heading.Font = Enum.Font.GothamBlack
    heading.Text = "STYLE BOARD"
    heading.TextColor3 = Color3.new(1, 1, 1)
    heading.TextSize = 23
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Parent = content

    local count = boardCount()
    local total, known = totalKnownPrice()
    local summary = Instance.new("TextLabel")
    summary.BackgroundTransparency = 1
    summary.Position = UDim2.fromOffset(0, 36)
    summary.Size = UDim2.new(1, -220, 0, 34)
    summary.Font = Enum.Font.Gotham
    summary.TextColor3 = Color3.fromRGB(163, 169, 188)
    summary.TextSize = 11
    summary.TextXAlignment = Enum.TextXAlignment.Left
    summary.Text = string.format("Mix up to %d Saved Picks • %d selected • known subtotal %d R$ (%d priced)", STYLE_BOARD_MAX, count, total, known)
    summary.Parent = content

    local clear = Instance.new("TextButton")
    clear.AnchorPoint = Vector2.new(1, 0)
    clear.Position = UDim2.new(1, 0, 0, 34)
    clear.Size = UDim2.fromOffset(96, 32)
    clear.BackgroundColor3 = Color3.fromRGB(71, 50, 58)
    clear.TextColor3 = Color3.new(1, 1, 1)
    clear.Font = Enum.Font.GothamBold
    clear.TextSize = 10
    clear.Text = "CLEAR BOARD"
    clear.Parent = content
    Instance.new("UICorner", clear).CornerRadius = UDim.new(0, 9)
    clear.Activated:Connect(function()
        styleBoard = {}
        boardTrack("BOARD_CLEAR")
        renderStyleBoard()
    end)

    local tryAll = Instance.new("TextButton")
    tryAll.AnchorPoint = Vector2.new(1, 0)
    tryAll.Position = UDim2.new(1, -104, 0, 34)
    tryAll.Size = UDim2.fromOffset(106, 32)
    tryAll.BackgroundColor3 = count > 0 and Color3.fromRGB(61, 73, 108) or Color3.fromRGB(46, 48, 57)
    tryAll.TextColor3 = count > 0 and Color3.new(1, 1, 1) or Color3.fromRGB(126, 130, 143)
    tryAll.Font = Enum.Font.GothamBold
    tryAll.TextSize = 10
    tryAll.Text = "TRY FULL LOOK"
    tryAll.AutoButtonColor = count > 0
    tryAll.Active = count > 0
    tryAll.Parent = content
    Instance.new("UICorner", tryAll).CornerRadius = UDim.new(0, 9)
    tryAll.Activated:Connect(function()
        if boardCount() == 0 then return end
        boardTrack("BOARD_TRY_ALL_CLICK")
        applyTryOnBatch(selectedBoardItems())
    end)

    local buyMissing = Instance.new("TextButton")
    buyMissing.Position = UDim2.fromOffset(0, 72)
    buyMissing.Size = UDim2.fromOffset(132, 32)
    buyMissing.BackgroundColor3 = count > 0 and Color3.fromRGB(55, 91, 68) or Color3.fromRGB(46, 48, 57)
    buyMissing.TextColor3 = count > 0 and Color3.new(1, 1, 1) or Color3.fromRGB(126, 130, 143)
    buyMissing.Font = Enum.Font.GothamBold
    buyMissing.TextSize = 10
    buyMissing.Text = "BUY MISSING"
    buyMissing.AutoButtonColor = count > 0
    buyMissing.Active = count > 0
    buyMissing.Parent = content
    Instance.new("UICorner", buyMissing).CornerRadius = UDim.new(0, 9)
    buyMissing.Activated:Connect(requestBulkPurchase)

    local buyHint = Instance.new("TextLabel")
    buyHint.BackgroundTransparency = 1
    buyHint.Position = UDim2.fromOffset(142, 72)
    buyHint.Size = UDim2.new(1, -142, 0, 32)
    buyHint.Font = Enum.Font.Gotham
    buyHint.TextColor3 = Color3.fromRGB(150, 155, 171)
    buyHint.TextSize = 10
    buyHint.TextXAlignment = Enum.TextXAlignment.Left
    buyHint.Text = "Roblox-native prompt • server validates Saved Picks and skips owned items"
    buyHint.Parent = content

    local list = Instance.new("ScrollingFrame")
    list.Name = "StyleBoardList"
    list.BackgroundTransparency = 1
    list.Position = UDim2.fromOffset(0, 112)
    list.Size = UDim2.new(1, 0, 1, -148)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.CanvasSize = UDim2.new()
    list.ScrollBarThickness = 4
    list.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = list

    if #savedPickOrder == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, -4, 0, 96)
        empty.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        empty.Font = Enum.Font.Gotham
        empty.Text = "Save a few catalog items first.\nYour Style Board is assembled from Saved Picks."
        empty.TextWrapped = true
        empty.TextColor3 = Color3.fromRGB(202, 205, 216)
        empty.TextSize = 14
        empty.Parent = list
        Instance.new("UICorner", empty).CornerRadius = UDim.new(0, 12)
        status.Text = "Style Board needs Saved Picks."
        return
    end

    for _, id in ipairs(savedPickOrder) do
        local item = savedPicks[id]
        if item then
            local selected = styleBoard[id] == true
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, -4, 0, 96)
            card.BackgroundColor3 = selected and Color3.fromRGB(38, 45, 58) or Color3.fromRGB(28, 30, 38)
            card.Parent = list
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

            local preview = Instance.new("ImageLabel")
            preview.Position = UDim2.fromOffset(8, 8)
            preview.Size = UDim2.fromOffset(80, 80)
            preview.BackgroundColor3 = Color3.fromRGB(21, 23, 29)
            preview.Image = itemThumb(item, id)
            preview.ScaleType = Enum.ScaleType.Fit
            preview.Parent = card
            Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 9)

            local name = Instance.new("TextLabel")
            name.BackgroundTransparency = 1
            name.Position = UDim2.fromOffset(98, 9)
            name.Size = UDim2.new(1, -300, 0, 36)
            name.Font = Enum.Font.GothamBold
            name.Text = tostring(item.Name or ("Catalog Item " .. tostring(id)))
            name.TextColor3 = Color3.new(1, 1, 1)
            name.TextSize = 12
            name.TextWrapped = true
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = card

            local meta = Instance.new("TextLabel")
            meta.BackgroundTransparency = 1
            meta.Position = UDim2.fromOffset(98, 49)
            meta.Size = UDim2.new(1, -300, 0, 28)
            meta.Font = Enum.Font.Gotham
            meta.Text = item.Price and (tostring(item.Price) .. " R$ • ID " .. tostring(id)) or ("ID " .. tostring(id))
            meta.TextColor3 = Color3.fromRGB(160, 165, 182)
            meta.TextSize = 10
            meta.TextXAlignment = Enum.TextXAlignment.Left
            meta.Parent = card

            local toggle = Instance.new("TextButton")
            toggle.AnchorPoint = Vector2.new(1, .5)
            toggle.Position = UDim2.new(1, -10, .5, 0)
            toggle.Size = UDim2.fromOffset(86, 36)
            toggle.BackgroundColor3 = selected and Color3.fromRGB(80, 57, 65) or Color3.fromRGB(54, 78, 73)
            toggle.TextColor3 = Color3.new(1, 1, 1)
            toggle.Font = Enum.Font.GothamBold
            toggle.TextSize = 10
            toggle.Text = selected and "REMOVE" or "ADD BOARD"
            toggle.Parent = card
            Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)
            toggle.Activated:Connect(function()
                if styleBoard[id] then
                    styleBoard[id] = nil
                    boardTrack("BOARD_REMOVE")
                elseif boardCount() < STYLE_BOARD_MAX then
                    styleBoard[id] = true
                    boardTrack("BOARD_ADD")
                else
                    status.Text = "Style Board is full • remove one of the 6 selected items first."
                    return
                end
                renderStyleBoard()
            end)

            if selected and not isBundleItem(item) then
                local try = Instance.new("TextButton")
                try.AnchorPoint = Vector2.new(1, .5)
                try.Position = UDim2.new(1, -104, .5, 0)
                try.Size = UDim2.fromOffset(82, 36)
                try.BackgroundColor3 = Color3.fromRGB(61, 73, 108)
                try.TextColor3 = Color3.new(1, 1, 1)
                try.Font = Enum.Font.GothamBold
                try.TextSize = 10
                try.Text = "TRY ONE"
                try.Parent = card
                Instance.new("UICorner", try).CornerRadius = UDim.new(0, 10)
                try.Activated:Connect(function()
                    boardTrack("BOARD_TRY_ONE")
                    applyTryOn(item)
                end)
            end
        end
    end

    status.Text = string.format("%d/%d selected • TRY FULL LOOK previews • BUY MISSING opens one Roblox-native purchase prompt", boardCount(), STYLE_BOARD_MAX)
end

renderers.BOARD = renderStyleBoard

local boardTab = Instance.new("TextButton")
boardTab.Name = "BoardTab"
boardTab.Size = UDim2.fromOffset(94, 38)
boardTab.BackgroundColor3 = Color3.fromRGB(35, 37, 46)
boardTab.TextColor3 = Color3.new(1, 1, 1)
boardTab.Font = Enum.Font.GothamBold
boardTab.TextSize = 12
boardTab.Text = "BOARD"
boardTab.Parent = tabs
Instance.new("UICorner", boardTab).CornerRadius = UDim.new(0, 10)
boardTab.Activated:Connect(function() selectTab("BOARD") end)

print("[BBYAVATAR] Style Board v3 + server-validated BUY MISSING ready")