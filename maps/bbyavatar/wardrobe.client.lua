-- BBYAVATAR saved wardrobe browser.
-- Uses Roblox-native AvatarEditorService inventory permission and outfit APIs.
-- This module extends the STUDIO tab without persisting private inventory data server-side.

local wardrobeBusy = false
local wardrobeRestoreDescription = nil

local function wardrobeTrack(eventName)
    local remote = root:FindFirstChild("TrackEvent")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(eventName) end)
    end
end

local function wardrobeHumanoid()
    local character = player.Character or player.CharacterAdded:Wait()
    return character:FindFirstChildOfClass("Humanoid")
end

local function renderWardrobeStudio()
    clearContent()

    local heading = Instance.new("TextLabel")
    heading.BackgroundTransparency = 1
    heading.Size = UDim2.new(1, 0, 0, 42)
    heading.Font = Enum.Font.GothamBlack
    heading.Text = "AVATAR STUDIO • WARDROBE"
    heading.TextColor3 = Color3.new(1, 1, 1)
    heading.TextSize = 24
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Parent = content

    local actions = Instance.new("ScrollingFrame")
    actions.Name = "WardrobeActions"
    actions.BackgroundTransparency = 1
    actions.Position = UDim2.fromOffset(0, 50)
    actions.Size = UDim2.new(1, 0, 0, 48)
    actions.AutomaticCanvasSize = Enum.AutomaticSize.X
    actions.CanvasSize = UDim2.new()
    actions.ScrollBarThickness = 0
    actions.ScrollingDirection = Enum.ScrollingDirection.X
    actions.Parent = content
    local actionLayout = Instance.new("UIListLayout")
    actionLayout.FillDirection = Enum.FillDirection.Horizontal
    actionLayout.Padding = UDim.new(0, 8)
    actionLayout.Parent = actions

    local function compact(text, width, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(width, 42)
        b.BackgroundColor3 = Color3.fromRGB(39, 42, 53)
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.Text = text
        b.Parent = actions
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
        b.Activated:Connect(callback)
        return b
    end

    local list = Instance.new("ScrollingFrame")
    list.Name = "SavedOutfits"
    list.BackgroundTransparency = 1
    list.Position = UDim2.fromOffset(0, 104)
    list.Size = UDim2.new(1, 0, 1, -148)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.CanvasSize = UDim2.new()
    list.ScrollBarThickness = 4
    list.Parent = content
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = list

    local function clearWardrobe()
        for _, child in ipairs(list:GetChildren()) do
            if child ~= listLayout then child:Destroy() end
        end
    end

    local function applyOutfit(outfitId, outfitName)
        if wardrobeBusy then return end
        local humanoid = wardrobeHumanoid()
        if not humanoid then status.Text = "Avatar is not ready yet." return end
        wardrobeBusy = true
        status.Text = "Previewing saved outfit…"
        task.spawn(function()
            if not wardrobeRestoreDescription then
                wardrobeRestoreDescription = humanoid:GetAppliedDescription()
            end
            local ok, description = pcall(function()
                return Players:GetHumanoidDescriptionFromOutfitIdAsync(outfitId)
            end)
            if not ok or not description then
                status.Text = "Could not load this outfit."
                wardrobeTrack("WARDROBE_PREVIEW_FAILED")
                wardrobeBusy = false
                return
            end
            local applied, err = pcall(function()
                humanoid:ApplyDescriptionAsync(description)
            end)
            if applied then
                status.Text = "Previewing “" .. tostring(outfitName or "Saved Outfit") .. "” • RESTORE returns to your previous look."
                wardrobeTrack("WARDROBE_PREVIEW_SUCCESS")
            else
                status.Text = "Outfit preview failed: " .. tostring(err)
                wardrobeTrack("WARDROBE_PREVIEW_FAILED")
            end
            wardrobeBusy = false
        end)
    end

    local function outfitCard(outfit)
        local outfitId = tonumber(outfit.Id or outfit.id)
        if not outfitId then return false end
        local name = tostring(outfit.Name or outfit.name or "Saved Outfit")
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -4, 0, 78)
        card.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        card.Parent = list
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Position = UDim2.fromOffset(14, 9)
        title.Size = UDim2.new(1, -122, 0, 28)
        title.Font = Enum.Font.GothamBold
        title.Text = name
        title.TextColor3 = Color3.new(1, 1, 1)
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.Parent = card

        local meta = Instance.new("TextLabel")
        meta.BackgroundTransparency = 1
        meta.Position = UDim2.fromOffset(14, 39)
        meta.Size = UDim2.new(1, -122, 0, 24)
        meta.Font = Enum.Font.Gotham
        meta.Text = "Roblox saved outfit • ID " .. tostring(outfitId)
        meta.TextColor3 = Color3.fromRGB(158, 163, 181)
        meta.TextSize = 11
        meta.TextXAlignment = Enum.TextXAlignment.Left
        meta.Parent = card

        local use = Instance.new("TextButton")
        use.AnchorPoint = Vector2.new(1, .5)
        use.Position = UDim2.new(1, -12, .5, 0)
        use.Size = UDim2.fromOffset(92, 38)
        use.BackgroundColor3 = Color3.fromRGB(62, 76, 112)
        use.TextColor3 = Color3.new(1, 1, 1)
        use.Font = Enum.Font.GothamBold
        use.TextSize = 11
        use.Text = "PREVIEW"
        use.Parent = card
        Instance.new("UICorner", use).CornerRadius = UDim.new(0, 10)
        use.Activated:Connect(function() applyOutfit(outfitId, name) end)
        return true
    end

    local outfitPages = nil
    local loadedCount = 0
    local loadMoreButton = nil

    local function refreshLoadMoreState()
        if not loadMoreButton then return end
        local finished = not outfitPages or outfitPages.IsFinished
        loadMoreButton.Visible = not finished
        loadMoreButton.Active = not finished and not wardrobeBusy
        loadMoreButton.AutoButtonColor = not wardrobeBusy
        loadMoreButton.Text = wardrobeBusy and "LOADING…" or "LOAD MORE"
    end

    local function appendCurrentPage()
        if not outfitPages then return 0 end
        local added = 0
        for _, outfit in ipairs(outfitPages:GetCurrentPage()) do
            if outfitCard(outfit) then
                added += 1
                loadedCount += 1
            end
        end
        return added
    end

    local function loadMore()
        if wardrobeBusy or not outfitPages or outfitPages.IsFinished then return end
        wardrobeBusy = true
        refreshLoadMoreState()
        status.Text = "Loading more saved outfits…"
        task.spawn(function()
            local ok, err = pcall(function()
                outfitPages:AdvanceToNextPageAsync()
            end)
            if not ok then
                status.Text = "Could not load more outfits: " .. tostring(err)
                wardrobeTrack("WARDROBE_PAGE_FAILED")
                wardrobeBusy = false
                refreshLoadMoreState()
                return
            end
            local added = appendCurrentPage()
            status.Text = string.format("%d saved outfits loaded • %d added", loadedCount, added)
            wardrobeTrack("WARDROBE_PAGE_LOADED")
            wardrobeBusy = false
            refreshLoadMoreState()
        end)
    end

    local function loadOutfits()
        if wardrobeBusy then return end
        wardrobeBusy = true
        outfitPages = nil
        loadedCount = 0
        clearWardrobe()
        status.Text = "Loading your Roblox saved outfits…"
        refreshLoadMoreState()
        task.spawn(function()
            local ok, pages = pcall(function()
                return AvatarEditorService:GetOutfitsAsync(Enum.OutfitSource.All, Enum.OutfitType.All)
            end)
            if not ok or not pages then
                status.Text = "Wardrobe access needs Roblox inventory permission • tap ALLOW INVENTORY, then LOAD OUTFITS again."
                wardrobeBusy = false
                refreshLoadMoreState()
                return
            end
            outfitPages = pages
            local count = appendCurrentPage()
            if count == 0 then
                status.Text = "No saved outfits found yet • SAVE CURRENT creates one through Roblox."
            else
                status.Text = string.format("%d saved outfits loaded • inventory stays on Roblox", loadedCount)
            end
            wardrobeTrack("WARDROBE_LOADED")
            wardrobeBusy = false
            refreshLoadMoreState()
        end)
    end

    compact("ALLOW INVENTORY", 132, function()
        status.Text = "Requesting Roblox inventory permission…"
        pcall(function() AvatarEditorService:PromptAllowInventoryReadAccess() end)
    end)
    compact("LOAD OUTFITS", 112, loadOutfits)
    compact("SAVE CURRENT", 112, function()
        local humanoid = wardrobeHumanoid(); if not humanoid then return end
        pcall(function() AvatarEditorService:PromptCreateOutfit(humanoid:GetAppliedDescription(), humanoid.RigType) end)
    end)
    compact("RESTORE", 92, function()
        if wardrobeBusy or not wardrobeRestoreDescription then status.Text = "No wardrobe preview to restore." return end
        local humanoid = wardrobeHumanoid(); if not humanoid then return end
        wardrobeBusy = true
        task.spawn(function()
            local ok, err = pcall(function() humanoid:ApplyDescriptionAsync(wardrobeRestoreDescription) end)
            if ok then
                wardrobeRestoreDescription = nil
                status.Text = "Previous look restored."
                wardrobeTrack("WARDROBE_RESTORE_SUCCESS")
            else
                status.Text = "Restore failed: " .. tostring(err)
                wardrobeTrack("WARDROBE_RESTORE_FAILED")
            end
            wardrobeBusy = false
        end)
    end)

    loadMoreButton = Instance.new("TextButton")
    loadMoreButton.Size = UDim2.new(1, -4, 0, 44)
    loadMoreButton.BackgroundColor3 = Color3.fromRGB(49, 54, 70)
    loadMoreButton.TextColor3 = Color3.new(1, 1, 1)
    loadMoreButton.Font = Enum.Font.GothamBold
    loadMoreButton.TextSize = 12
    loadMoreButton.Text = "LOAD MORE"
    loadMoreButton.Visible = false
    loadMoreButton.Parent = list
    Instance.new("UICorner", loadMoreButton).CornerRadius = UDim.new(0, 11)
    loadMoreButton.Activated:Connect(loadMore)

    loadOutfits()
end

renderers.STUDIO = renderWardrobeStudio
player.CharacterAdded:Connect(function()
    wardrobeRestoreDescription = nil
    wardrobeBusy = false
end)
print("[BBYAVATAR] saved wardrobe pagination + preview telemetry ready")
