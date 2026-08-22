-- BBYAVATAR deterministic daily discovery spotlight.
-- No user data is stored; the selected category changes once per UTC day.

local categories = {
    "STREETWEAR",
    "CYBER",
    "LUXURY",
    "CUTE",
    "BALI",
    "CREATORS",
    "TRENDING",
    "NEW DROPS",
}

local function utcDayNumber()
    local ok, value = pcall(function()
        return math.floor(DateTime.now().UnixTimestamp / 86400)
    end)
    if not ok then return 0 end
    return value
end

local function todayCategory()
    return categories[(utcDayNumber() % #categories) + 1]
end

local function track(eventName)
    local remote = root:FindFirstChild("TrackEvent")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function()
            remote:FireServer(eventName)
        end)
    end
end

local function renderDailySpotlightButton(parent)
    local category = todayCategory()
    local button = Instance.new("TextButton")
    button.Name = "DailySpotlight"
    button.Size = UDim2.new(1, -4, 0, 66)
    button.BackgroundColor3 = Color3.fromRGB(76, 62, 108)
    button.Text = "TODAY'S SPOTLIGHT  •  " .. category
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 13)

    button.Activated:Connect(function()
        activeCategory = category
        track("DISCOVERY_DAILY_SPOTLIGHT")
        selectTab("SEARCH")
    end)

    return button
end

_G.BBYAVATAR_DailySpotlight = {
    Category = todayCategory,
    RenderButton = renderDailySpotlightButton,
}

print("[BBYAVATAR] Daily spotlight helper ready")