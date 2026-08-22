-- BBYAVATAR Look Share v1 client
-- Creates a short code from the current Style Board and imports shared looks into Saved Picks + Board.
-- Shared records contain only Roblox asset IDs; metadata is hydrated transiently from Roblox.

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
    b.Activated:Connect(callback)
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

local function importSharedLook(ids)
    if typeof(ids) ~= "table" or #ids == 0 then return false, 0 end
    styleBoard = {}
    local imported = 0
    for _, rawId in ipairs(ids) do
        local id = tonumber(rawId)
        if id and id > 0 then
            if not savedPicks[id] then
                local item = hydrateSharedItem(id)
                local ok = savePick(item)
                if not ok and not savedPicks[id] then
                    -- Saved Picks may be full; skip rather than silently replacing the player's shortlist.
                end
                task.wait(0.36)
            end
            if savedPicks[id] and imported < STYLE_BOARD_MAX then
                styleBoard[id] = true
                imported += 1
            end
        end
    end
    return imported > 0, imported
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
            status.Text = code == "THROTTLED" and "Share-code creation is cooling down • try again shortly." or ("Could not create share code • " .. tostring(code))
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

    makeShareButton(importRow, "IMPORT LOOK", 0, 140, function() end).Position = UDim2.new(1,-140,0,0)
    local importButton = importRow:GetChildren()[#importRow:GetChildren()]
    -- Resolve the button by class instead of depending on child order after UICorner creation.
    for _, child in ipairs(importRow:GetChildren()) do
        if child:IsA("TextButton") and child.Text == "IMPORT LOOK" then importButton = child break end
    end
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
            else
                status.Text = "Could not load that look code."
            end
            return
        end

        local importedOk, count = importSharedLook(response.ids)
        if importedOk then
            shareTrack("SHARE_IMPORT")
            status.Text = string.format("Imported %d item(s) into Saved Picks + Style Board.", count)
            selectTab("BOARD")
        else
            shareTrack("SHARE_FAILED")
            status.Text = "The shared look loaded, but Saved Picks may be full. Remove a few picks and retry."
        end
    end)

    local note = Instance.new("TextLabel")
    note.BackgroundTransparency = 1
    note.Position = UDim2.fromOffset(0,280)
    note.Size = UDim2.new(1,0,0,70)
    note.Font = Enum.Font.Gotham
    note.Text = "Import never deletes your Saved Picks. Shared items are hydrated from Roblox, then added to your shortlist when space is available."
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

print("[BBYAVATAR] Look Share v1 code create/import UI ready")