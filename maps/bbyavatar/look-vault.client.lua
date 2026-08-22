-- BBYAVATAR Look Vault v1
-- Three fixed cloud slots for persistent Style Board combinations.
-- Uses only asset IDs already present in Saved Picks/Style Board.

local lookVaultRequest = root:WaitForChild("LookVaultRequest", 8)
local lookVaultSlots = {{}, {}, {}}
local lookVaultLoaded = false
local lookVaultBusy = false

local function vaultTrack(eventName)
    local remote = root:FindFirstChild("TrackEvent")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(eventName) end)
    end
end

local function currentBoardIdsForVault()
    local ids = {}
    for _, id in ipairs(savedPickOrder) do
        if styleBoard[id] then
            table.insert(ids, id)
            if #ids >= STYLE_BOARD_MAX then break end
        end
    end
    return ids
end

local function normalizeVaultSlots(value)
    local slots = {{}, {}, {}}
    if typeof(value) ~= "table" then return slots end
    for index = 1, 3 do
        if typeof(value[index]) == "table" then
            local seen = {}
            for _, raw in ipairs(value[index]) do
                local id = tonumber(raw)
                if id and id > 0 and id == math.floor(id) and not seen[id] then
                    seen[id] = true
                    table.insert(slots[index], id)
                    if #slots[index] >= STYLE_BOARD_MAX then break end
                end
            end
        end
    end
    return slots
end

local function loadVaultFromServer(force)
    if lookVaultBusy or not lookVaultRequest or not lookVaultRequest:IsA("RemoteFunction") then return false end
    if lookVaultLoaded and not force then return true end
    lookVaultBusy = true
    local ok, response = pcall(function()
        return lookVaultRequest:InvokeServer("LOAD")
    end)
    lookVaultBusy = false
    if ok and typeof(response) == "table" and response.ok and typeof(response.slots) == "table" then
        lookVaultSlots = normalizeVaultSlots(response.slots)
        lookVaultLoaded = true
        return true
    end
    return false
end

local function saveVaultSlot(slotIndex)
    if lookVaultBusy or not lookVaultRequest then return end
    local ids = currentBoardIdsForVault()
    if #ids == 0 then
        status.Text = "Add Saved Picks to the Style Board before saving a Look Vault slot."
        return
    end
    lookVaultBusy = true
    status.Text = "Saving Look Vault slot " .. tostring(slotIndex) .. "…"
    local ok, response = pcall(function()
        return lookVaultRequest:InvokeServer("SAVE_SLOT", {slot = slotIndex, ids = ids})
    end)
    lookVaultBusy = false
    if ok and typeof(response) == "table" and response.ok and typeof(response.slots) == "table" then
        lookVaultSlots = normalizeVaultSlots(response.slots)
        lookVaultLoaded = true
        vaultTrack("VAULT_SAVE")
        status.Text = string.format("Look Vault slot %d saved with %d items.", slotIndex, #ids)
        return true
    end
    status.Text = "Look Vault could not save right now. Your active Style Board is unchanged."
    return false
end

local function applyVaultSlot(slotIndex)
    local ids = lookVaultSlots[slotIndex] or {}
    if #ids == 0 then
        status.Text = "That Look Vault slot is empty."
        return
    end

    local nextBoard = {}
    local restored, unavailable = 0, 0
    for _, id in ipairs(ids) do
        if savedPicks[id] then
            nextBoard[id] = true
            restored += 1
        else
            unavailable += 1
        end
    end
    if restored == 0 then
        status.Text = "This saved look no longer has matching Saved Picks in your shortlist."
        return
    end
    styleBoard = nextBoard
    vaultTrack("VAULT_LOAD")
    if unavailable > 0 then
        status.Text = string.format("Loaded %d items; %d are no longer in Saved Picks.", restored, unavailable)
    else
        status.Text = string.format("Loaded Look Vault slot %d into Style Board.", slotIndex)
    end
    selectTab("BOARD")
end

local function renderLookVault()
    clearContent()
    vaultTrack("VAULT_OPEN")

    local heading = Instance.new("TextLabel")
    heading.BackgroundTransparency = 1
    heading.Size = UDim2.new(1, 0, 0, 36)
    heading.Font = Enum.Font.GothamBlack
    heading.Text = "LOOK VAULT"
    heading.TextColor3 = Color3.new(1, 1, 1)
    heading.TextSize = 23
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Parent = content

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(0, 38)
    sub.Size = UDim2.new(1, 0, 0, 40)
    sub.Font = Enum.Font.Gotham
    sub.Text = "Keep three cloud-saved Style Board combinations. Slots store only Roblox asset IDs."
    sub.TextColor3 = Color3.fromRGB(163, 169, 188)
    sub.TextSize = 12
    sub.TextWrapped = true
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = content

    local refresh = Instance.new("TextButton")
    refresh.AnchorPoint = Vector2.new(1, 0)
    refresh.Position = UDim2.new(1, 0, 0, 2)
    refresh.Size = UDim2.fromOffset(86, 30)
    refresh.BackgroundColor3 = Color3.fromRGB(45, 48, 59)
    refresh.TextColor3 = Color3.new(1, 1, 1)
    refresh.Font = Enum.Font.GothamBold
    refresh.TextSize = 10
    refresh.Text = "REFRESH"
    refresh.Parent = content
    Instance.new("UICorner", refresh).CornerRadius = UDim.new(0, 9)
    refresh.Activated:Connect(function()
        lookVaultLoaded = false
        loadVaultFromServer(true)
        renderLookVault()
    end)

    local list = Instance.new("Frame")
    list.BackgroundTransparency = 1
    list.Position = UDim2.fromOffset(0, 88)
    list.Size = UDim2.new(1, 0, 1, -120)
    list.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = list

    if not lookVaultLoaded then loadVaultFromServer(false) end

    for slotIndex = 1, 3 do
        local ids = lookVaultSlots[slotIndex] or {}
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 78)
        card.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        card.Parent = list
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

        local titleLabel = Instance.new("TextLabel")
        titleLabel.BackgroundTransparency = 1
        titleLabel.Position = UDim2.fromOffset(14, 10)
        titleLabel.Size = UDim2.new(1, -230, 0, 25)
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Text = "LOOK SLOT " .. tostring(slotIndex)
        titleLabel.TextColor3 = Color3.new(1, 1, 1)
        titleLabel.TextSize = 14
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = card

        local meta = Instance.new("TextLabel")
        meta.BackgroundTransparency = 1
        meta.Position = UDim2.fromOffset(14, 38)
        meta.Size = UDim2.new(1, -230, 0, 24)
        meta.Font = Enum.Font.Gotham
        meta.Text = #ids == 0 and "Empty slot" or string.format("%d/%d items saved", #ids, STYLE_BOARD_MAX)
        meta.TextColor3 = Color3.fromRGB(160, 165, 182)
        meta.TextSize = 11
        meta.TextXAlignment = Enum.TextXAlignment.Left
        meta.Parent = card

        local save = Instance.new("TextButton")
        save.AnchorPoint = Vector2.new(1, .5)
        save.Position = UDim2.new(1, -104, .5, 0)
        save.Size = UDim2.fromOffset(92, 36)
        save.BackgroundColor3 = Color3.fromRGB(54, 78, 73)
        save.TextColor3 = Color3.new(1, 1, 1)
        save.Font = Enum.Font.GothamBold
        save.TextSize = 10
        save.Text = "SAVE BOARD"
        save.Parent = card
        Instance.new("UICorner", save).CornerRadius = UDim.new(0, 10)
        save.Activated:Connect(function()
            if saveVaultSlot(slotIndex) then renderLookVault() end
        end)

        local load = Instance.new("TextButton")
        load.AnchorPoint = Vector2.new(1, .5)
        load.Position = UDim2.new(1, -8, .5, 0)
        load.Size = UDim2.fromOffset(88, 36)
        load.BackgroundColor3 = #ids > 0 and Color3.fromRGB(61, 73, 108) or Color3.fromRGB(46, 48, 57)
        load.TextColor3 = #ids > 0 and Color3.new(1, 1, 1) or Color3.fromRGB(126, 130, 143)
        load.Font = Enum.Font.GothamBold
        load.TextSize = 10
        load.Text = "LOAD"
        load.Active = #ids > 0
        load.AutoButtonColor = #ids > 0
        load.Parent = card
        Instance.new("UICorner", load).CornerRadius = UDim.new(0, 10)
        load.Activated:Connect(function() applyVaultSlot(slotIndex) end)
    end

    status.Text = string.format("Current Style Board: %d/%d selected • save it into any Look Vault slot", boardCount(), STYLE_BOARD_MAX)
end

renderers.VAULT = renderLookVault

local vaultTab = Instance.new("TextButton")
vaultTab.Name = "VaultTab"
vaultTab.Size = UDim2.fromOffset(94, 38)
vaultTab.BackgroundColor3 = Color3.fromRGB(35, 37, 46)
vaultTab.TextColor3 = Color3.new(1, 1, 1)
vaultTab.Font = Enum.Font.GothamBold
vaultTab.TextSize = 12
vaultTab.Text = "VAULT"
vaultTab.Parent = tabs
Instance.new("UICorner", vaultTab).CornerRadius = UDim.new(0, 10)
vaultTab.Activated:Connect(function() selectTab("VAULT") end)

print("[BBYAVATAR] Look Vault v1 three persistent Style Board slots ready")