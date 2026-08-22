-- BBYAVATAR session-personalized discovery hub.
-- Keeps preference signals local to the current session; no user profile or browsing history is persisted.

local discoveryVisits = {}
local discoveryLastCategory = "FEATURED"

local function discoveryTrack(eventName)
    local remote = root:FindFirstChild("TrackEvent")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(eventName) end)
    end
end

local function discoveryRemember(category)
    category = tostring(category or "FEATURED")
    if category == "STUDIO" or category == "PHOTO" then return end
    discoveryLastCategory = category
    discoveryVisits[category] = (discoveryVisits[category] or 0) + 1
end

openEvent.OnClientEvent:Connect(function(category)
    discoveryRemember(category)
end)

local function discoveryButton(parent, label, subtitleText, category, accent)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -4, 0, 66)
    b.BackgroundColor3 = accent or Color3.fromRGB(34, 37, 47)
    b.Text = ""
    b.AutoButtonColor = true
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 13)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.fromOffset(14, 8)
    titleLabel.Size = UDim2.new(1, -28, 0, 25)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = label
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = b

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(14, 34)
    sub.Size = UDim2.new(1, -28, 0, 20)
    sub.Font = Enum.Font.Gotham
    sub.Text = subtitleText
    sub.TextColor3 = Color3.fromRGB(185, 190, 207)
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.TextTruncate = Enum.TextTruncate.AtEnd
    sub.Parent = b

    b.Activated:Connect(function()
        activeCategory = category
        discoveryRemember(category)
        discoveryTrack("DISCOVERY_CATEGORY")
        selectTab("SEARCH")
    end)
    return b
end

local function topVisitedCategories()
    local ranked = {}
    for category, count in pairs(discoveryVisits) do
        table.insert(ranked, {category = category, count = count})
    end
    table.sort(ranked, function(a, b)
        if a.count == b.count then return a.category < b.category end
        return a.count > b.count
    end)
    return ranked
end

local function renderDiscoveryHub()
    clearContent()
    discoveryTrack("DISCOVERY_OPEN")

    local heading = Instance.new("TextLabel")
    heading.BackgroundTransparency = 1
    heading.Size = UDim2.new(1, 0, 0, 38)
    heading.Font = Enum.Font.GothamBlack
    heading.Text = "DISCOVER YOUR NEXT LOOK"
    heading.TextColor3 = Color3.new(1, 1, 1)
    heading.TextSize = 23
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Parent = content

    local subhead = Instance.new("TextLabel")
    subhead.BackgroundTransparency = 1
    subhead.Position = UDim2.fromOffset(0, 37)
    subhead.Size = UDim2.new(1, 0, 0, 31)
    subhead.Font = Enum.Font.Gotham
    subhead.Text = "Session-personalized discovery • nothing here is stored after you leave"
    subhead.TextColor3 = Color3.fromRGB(156, 162, 182)
    subhead.TextSize = 11
    subhead.TextXAlignment = Enum.TextXAlignment.Left
    subhead.Parent = content

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "DiscoveryFeed"
    scroll.BackgroundTransparency = 1
    scroll.Position = UDim2.fromOffset(0, 73)
    scroll.Size = UDim2.new(1, 0, 1, -108)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new()
    scroll.ScrollBarThickness = 4
    scroll.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = scroll

    local ranked = topVisitedCategories()
    if #ranked > 0 then
        local preferred = ranked[1].category
        discoveryButton(scroll, "FOR YOU • " .. preferred, "Based only on what you explored this session", preferred, Color3.fromRGB(55, 58, 84))
    elseif discoveryLastCategory ~= "FEATURED" then
        discoveryButton(scroll, "CONTINUE • " .. discoveryLastCategory, "Jump back into your latest category", discoveryLastCategory, Color3.fromRGB(55, 58, 84))
    else
        discoveryButton(scroll, "START WITH FEATURED", "Curated entry point for a first visit", "FEATURED", Color3.fromRGB(55, 58, 84))
    end

    -- Deterministic daily editorial lane. The helper stores no player data and rotates by UTC day.
    local spotlight = _G.BBYAVATAR_DailySpotlight
    if spotlight and typeof(spotlight.RenderButton) == "function" then
        local ok = pcall(function()
            spotlight.RenderButton(scroll)
        end)
        if not ok then
            status.Text = "Discovery loaded • daily spotlight temporarily unavailable"
        end
    end

    discoveryButton(scroll, "HOT NOW", "Explore currently promoted discovery lane", "TRENDING", Color3.fromRGB(73, 52, 101))
    discoveryButton(scroll, "NEW DROPS", "Fresh-item discovery lane", "NEW DROPS", Color3.fromRGB(43, 75, 103))
    discoveryButton(scroll, "CREATOR PICKS", "Creator-focused discovery lane", "CREATORS", Color3.fromRGB(46, 78, 61))

    for _, category in ipairs({"STREETWEAR", "CYBER", "LUXURY", "CUTE", "BALI"}) do
        discoveryButton(scroll, category, "Browse Roblox Marketplace results for " .. string.lower(category), category)
    end

    status.Text = "Discover → daily spotlight → try on → save → shop → return"
end

renderers.DISCOVER = renderDiscoveryHub
print("[BBYAVATAR] Session-personalized discovery hub + daily spotlight ready")