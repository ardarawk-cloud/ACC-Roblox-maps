-- BBYAVATAR Look Share v3 client
-- Creates short share codes and imports shared looks atomically into Saved Picks + Style Board.
-- A failed import never clears or partially replaces the player's current Style Board.
-- Shared records contain only Roblox asset IDs; catalog metadata is hydrated transiently from Roblox.
-- v3 gives explicit, non-alarming feedback for server budget guards introduced by Look Share v2.

local lookShareRequest = root:WaitForChild("LookShareRequest")

local function shareTrack(eventName)
    local remote = root:FindFirstChild("TrackEvent")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(eventName) end)
    end
end

local function makeShareButton(parent, text, x, width, callback)
    local b = Instance.new("TextButton")
    b.Position = UDim2.fromOffset(x, 0)
    b.Size = UDim2.fromOffset(width, 38)
    b.BackgroundColor3 = Color3.fromRGB(57, 67, 92)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.Text = text
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    if callback then b.Activated:Connect(callback) end
    return b
end

local function hydrateSharedItem(id)
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(id, Enum.InfoType.Asset)
    end)
    if not ok or typeof(info) ~= "table" then
        return {Id=id, AssetId=id, Name="Catalog Item "..tostring(id)}
    end
    return {
        Id=id,
        AssetId=id,
        Name=info.Name or ("Catalog Item "..tostring(id)),
        Price=info.PriceInRobux,
        AssetType=info.AssetTypeId,
    }
end

local function normalizeSharedIds(ids)
    if typeof(ids) ~= "table" then return {} end
    local clean, seen = {}, {}
    for _, rawId in ipairs(ids) do
        local id = tonumber(rawId)
        if id and id > 0 and id == math.floor(id) and not seen[id] then
            seen[id] = true
            table.insert(clean, id)
            if #clean >= STYLE_BOARD_MAX then break end
        end
    end
    return clean
end

local function importSharedLook(ids)
    local clean = normalizeSharedIds(ids)
    if #clean == 0 then return false, 0, "EMPTY" end

    -- Capacity preflight happens before any mutation. This prevents a shared look from
    -- partially filling Saved Picks and then replacing the current board with a partial look.
    local missing = 0
    for _, id in ipairs(clean) do
        if not savedPicks[id] then missing += 1 end
    end
    if #savedPickOrder + missing > MAX_SAVED_PICKS then
        return false, 0, "CAPACITY"
    end

    local nextBoard = {}
    local imported = 0
    for _, id in ipairs(clean) do
        if not savedPicks[id] then
            local item = hydrateSharedItem(id)
            local ok = savePick(item)
            if not ok and not savedPicks[id] then
                return false, 0, "SAVE_FAILED"
            end
            -- Saved Picks server requests are intentionally throttled; keep import polite.
            task.wait(0.36)
        end
        if savedPicks[id] then
            nextBoard[id] = true
            imported += 1
        end
    end

    if imported ~= #clean then
        return false, 0, "INCOMPLETE"
    end

    -- Commit the board only after the full look is ready.
    styleBoard = nextBoard
    return true, imported, "OK"
end

local function renderLookShare()
    clearContent()
    shareTrack("SHARE_OPEN")

    local heading = Instance.new("TextLabel")
    heading.BackgroundTransparency = 1
    heading.Size = UDim2.new(1,0,0,38)
    heading.Font = Enum.Font.GothamBlack
    heading.Text = "SHARE LOOK"
    heading.TextColor3 = Color3.new(1,1,1)
    heading.TextSize = 23
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Parent = content

    local intro = Instance.new("TextLabel")
    intro.BackgroundTransparency = 1
    intro.Position = UDim2.fromOffset(0,40)
    intro.Size = UDim2.new(1,0,0,54)
    intro.Font = Enum.Font.Gotham
    intro.Text = "Turn your current Style Board into a short code, or import a friend's look. Codes contain only Roblox asset IDs and expire after 30 days."
    intro.TextWrapped = true
    intro.TextColor3 = Color3.fromRGB(170,175,193)
    intro.TextSize = 12
    intro.TextXAlignment = Enum.TextXAlignment.Left
    intro.TextYAlignment = Enum.TextYAlignment.Top
    intro.Parent = content

    local createRow = Instance.new("Frame")
    createRow.BackgroundTransparency = 1
    createRow.Position = UDim2.fromOffset(0,104)
    createRow.Size = UDim2.new(1,0,0,42)
    createRow.Parent = content

    local codeOutput = Instance.new("TextBox")
    codeOutput.Position = UDim2.fromOffset(150,0)
    codeOutput.Size = UDim2.new(1,-150,0,38)
    codeOutput.BackgroundColor3 = Color3.fromRGB(29,31,39)
    codeOutput.TextColor3 = Color3.fromRGB(235,237,244)
    codeOutput.PlaceholderColor3 = Color3.fromRGB(126,131,149)
    codeOutput.PlaceholderText = "Your share code appears here"
    codeOutput.ClearTextOnFocus = false
    codeOutput.Font = Enum.Font.GothamBold
    codeOutput.TextSize = 16
    codeOutput.Text = ""
    codeOutput.Parent = createRow
    Instance.new("UICorner", codeOutput).CornerRadius = UDim.new(0,10)

    makeShareButton(createRow, "CREATE CODE", 0, 140, function()
        local ids = selectedBoardIds()
        if #ids == 0 then
            status.Text = "Add items to STYLE BOARD before creating a share code."
            return
        end
        status.Text = "Creating privacy-minimal look code…"
        local ok, response = pcall(function()
            return lookShareRequest:InvokeServer("CREATE", ids)
        end)
        if ok and typeof(response) == "table" and response.ok and response.code then
            codeOutput.Text = tostring(response.code)
            shareTrack("SHARE_CREATE")
            status.Text = string.format("Share code ready • %d item(s) • valid for 30 days", tonumber(response.count) or #ids)
        else
            shareTrack("SHARE_FAILED")
            local code = ok and typeof(response) == "table" and response.code or "FAILED"
            if code == "THROTTLED" then
                status.Text = "Share-code creation is cooling down • try again shortly."
            elseif code == "RATE_LIMITED" then
                status.Text = "Share-code limit reached for now • keep styling and try again later."
            else
                status.Text = "Could not create share code • " .. tostring(code)
            end
        end
    end)

    local divider = Instance.new("Frame")
    divider.Position = UDim2.fromOffset(0,164)
    divider.Size = UDim2.new(1,0,0,1)
    divider.BackgroundColor3 = Color3.fromRGB(55,58,70)
    divider.BorderSizePixel = 0
    divider.Parent = content

    local importTitle = Instance.new("TextLabel")
    importTitle.BackgroundTransparency = 1
    importTitle.Position = UDim2.fromOffset(0,184)
    importTitle.Size = UDim2.new(1,0,0,28)
    importTitle.Font = Enum.Font.GothamBold
    importTitle.Text = "IMPORT A LOOK"
    importTitle.TextColor3 = Color3.new(1,1,1)
    importTitle.TextSize = 14
    importTitle.TextXAlignment = Enum.TextXAlignment.Left
    importTitle.Parent = content

    local importRow = Instance.new("Frame")
    importRow.BackgroundTransparency = 1
    importRow.Position = UDim2.fromOffset(0,220)
    importRow.Size = UDim2.new(1,0,0,42)
    importRow.Parent = content

    local codeInput = Instance.new("TextBox")
    codeInput.Size = UDim2.new(1,-150,0,38)
    codeInput.BackgroundColor3 = Color3.fromRGB(29,31,39)
    codeInput.TextColor3 = Color3.new(1,1,1)
    codeInput.PlaceholderColor3 = Color3.fromRGB(126,131,149)
    codeInput.PlaceholderText = "7-character code"
    codeInput.ClearTextOnFocus = false
    codeInput.Font = Enum.Font.GothamBold
    codeInput.TextSize = 16
    codeInput.Text = ""
    codeInput.Parent = importRow
    Instance.new("UICorner", codeInput).CornerRadius = UDim.new(0,10)

    local importButton = makeShareButton(importRow, "IMPORT LOOK", 0, 140, nil)
    importButton.Position = UDim2.new(1,-140,0,0)
    importButton.Activated:Connect(function()
        local code = string.upper(codeInput.Text or ""):gsub("%s+", "")
        status.Text = "Loading shared look…"
        local ok, response = pcall(function()
            return lookShareRequest:InvokeServer("LOAD", code)
        end)
        if not ok or typeof(response) ~= "table" or not response.ok then
            shareTrack("SHARE_FAILED")
            local reason = ok and typeof(response) == "table" and response.code or "FAILED"
            if reason == "NOT_FOUND" or reason == "EXPIRED" then
                status.Text = "That look code is unavailable or expired."
            elseif reason == "THROTTLED" then
                status.Text = "Look import is cooling down • try again in a moment."
            elseif reason == "RATE_LIMITED" then
                status.Text = "Too many look-code checks in a short time • browse for a bit, then try again."
            else
                status.Text = "Could not load that look code."
            end
            return
        end

        shareTrack("SHARE_LOAD")
        local importedOk, count, reason = importSharedLook(response.ids)
        if importedOk then
            shareTrack("SHARE_IMPORT")
            status.Text = string.format("Imported full look • %d item(s) in Saved Picks + Style Board.", count)
            selectTab("BOARD")
        elseif reason == "CAPACITY" then
            shareTrack("SHARE_CAPACITY_BLOCK")
            status.Text = "Not enough Saved Picks space for the full shared look • nothing on your current board was changed."
        else
            shareTrack("SHARE_FAILED")
            status.Text = "Shared look could not be imported completely • your current Style Board was kept unchanged."
        end
    end)

    local note = Instance.new("TextLabel")
    note.BackgroundTransparency = 1
    note.Position = UDim2.fromOffset(0,280)
    note.Size = UDim2.new(1,0,0,70)
    note.Font = Enum.Font.Gotham
    note.Text = "Safe import: BBYAVATAR checks Saved Picks capacity first and only replaces your Style Board after the entire shared look is ready."
    note.TextWrapped = true
    note.TextColor3 = Color3.fromRGB(151,156,174)
    note.TextSize = 11
    note.TextXAlignment = Enum.TextXAlignment.Left
    note.TextYAlignment = Enum.TextYAlignment.Top
    note.Parent = content
end

renderers.SHARE = renderLookShare
local shareTab = Instance.new("TextButton")
shareTab.Name = "ShareTab"
shareTab.Size = UDim2.fromOffset(88,38)
shareTab.BackgroundColor3 = Color3.fromRGB(35,37,46)
shareTab.TextColor3 = Color3.new(1,1,1)
shareTab.Font = Enum.Font.GothamBold
shareTab.TextSize = 12
shareTab.Text = "SHARE"
shareTab.Parent = tabs
Instance.new("UICorner", shareTab).CornerRadius = UDim.new(0,10)
shareTab.Activated:Connect(function() selectTab("SHARE") end)

print("[BBYAVATAR] Look Share v3 budget-aware client feedback ready")