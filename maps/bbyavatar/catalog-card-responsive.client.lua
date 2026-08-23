-- BBYAVATAR responsive catalog card layout v1.
-- Runs after all catalog-card decorators so BUY/FAVORITE/TRY ON/SAVE PICK/DETAILS
-- remain usable on narrow phones without changing purchase or avatar behavior.
-- Session-local layout only; no data is persisted or transmitted.
local CARD_MOBILE_BREAKPOINT = 520
local CARD_TABLET_BREAKPOINT = 720

local function findTextChild(card, name)
    for _, child in ipairs(card:GetChildren()) do
        if child:IsA("TextLabel") and child.Name == name then return child end
    end
end

local function findUnnamedText(card, predicate)
    for _, child in ipairs(card:GetChildren()) do
        if child:IsA("TextLabel") and predicate(child) then return child end
    end
end

local function orderedActionButtons(card)
    local priority = {SavePick = 1, TryOn = 2}
    local buttons = {}
    for _, child in ipairs(card:GetChildren()) do
        if child:IsA("TextButton") then
            local rank = priority[child.Name]
            if not rank then
                if child.Text == "BUY" or string.sub(child.Text or "", 1, 3) == "BUY" then rank = 3
                elseif child.Text == "FAVORITE" then rank = 4
                else rank = 20 end
            end
            table.insert(buttons, {button = child, rank = rank})
        end
    end
    table.sort(buttons, function(a, b)
        if a.rank == b.rank then return a.button.Name < b.button.Name end
        return a.rank < b.rank
    end)
    return buttons
end

local function applyCatalogCardLayout(card)
    if not card or not card.Parent then return end
    local width = card.AbsoluteSize.X
    if width <= 0 then
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 900
        width = math.max(280, viewport * 0.82)
    end

    local preview = card:FindFirstChild("Preview")
    local name = findUnnamedText(card, function(label)
        return label.Position.X.Offset >= 110 and label.Position.Y.Offset <= 20
    end)
    local meta = findUnnamedText(card, function(label)
        return label.Position.X.Offset >= 110 and label.Position.Y.Offset >= 40
    end)
    local actions = orderedActionButtons(card)

    if width < CARD_MOBILE_BREAKPOINT then
        card.Size = UDim2.new(1, -4, 0, 214)
        if preview then
            preview.Position = UDim2.fromOffset(10, 10)
            preview.Size = UDim2.fromOffset(86, 86)
        end
        if name then
            name.Position = UDim2.fromOffset(108, 10)
            name.Size = UDim2.new(1, -118, 0, 42)
            name.TextSize = 13
        end
        if meta then
            meta.Position = UDim2.fromOffset(108, 56)
            meta.Size = UDim2.new(1, -118, 0, 42)
            meta.TextSize = 11
        end

        local usable = math.max(240, width - 20)
        local gap = 8
        local columns = 2
        local buttonWidth = math.floor((usable - gap) / columns)
        for index, entry in ipairs(actions) do
            local button = entry.button
            local zero = index - 1
            local row = math.floor(zero / columns)
            local col = zero % columns
            button.AnchorPoint = Vector2.new(0, 0)
            button.Position = UDim2.fromOffset(10 + col * (buttonWidth + gap), 108 + row * 46)
            button.Size = UDim2.fromOffset(buttonWidth, 38)
            button.TextSize = math.min(button.TextSize, 11)
        end
    elseif width < CARD_TABLET_BREAKPOINT then
        card.Size = UDim2.new(1, -4, 0, 172)
        if preview then
            preview.Position = UDim2.fromOffset(10, 10)
            preview.Size = UDim2.fromOffset(96, 96)
        end
        if name then
            name.Position = UDim2.fromOffset(118, 10)
            name.Size = UDim2.new(1, -220, 0, 38)
        end
        if meta then
            meta.Position = UDim2.fromOffset(118, 52)
            meta.Size = UDim2.new(1, -220, 0, 46)
        end

        local count = #actions
        local gap = 8
        local usable = math.max(260, width - 20)
        local buttonWidth = math.floor((usable - math.max(0, count - 1) * gap) / math.max(1, count))
        buttonWidth = math.clamp(buttonWidth, 74, 124)
        for index, entry in ipairs(actions) do
            local button = entry.button
            button.AnchorPoint = Vector2.new(0, 0)
            button.Position = UDim2.fromOffset(10 + (index - 1) * (buttonWidth + gap), 120)
            button.Size = UDim2.fromOffset(buttonWidth, 38)
            button.TextSize = math.min(button.TextSize, 11)
        end
    else
        -- Preserve the established desktop/tablet card arrangement created by the
        -- base decorators; only ensure action labels do not overflow their buttons.
        for _, entry in ipairs(actions) do
            entry.button.TextScaled = false
            entry.button.TextWrapped = false
            entry.button.TextTruncate = Enum.TextTruncate.AtEnd
        end
    end
end

local responsiveBaseCatalogCard = catalogCard
catalogCard = function(parent, item)
    local card = responsiveBaseCatalogCard(parent, item)
    if not card then return card end
    task.defer(function()
        if card.Parent then applyCatalogCardLayout(card) end
    end)
    card:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if card.Parent then applyCatalogCardLayout(card) end
    end)
    return card
end

print("[BBYAVATAR] Responsive catalog cards v1 ready")