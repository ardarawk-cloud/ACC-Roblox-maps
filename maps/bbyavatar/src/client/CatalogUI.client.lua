local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local root = ReplicatedStorage:WaitForChild("BBYAVATAR")
local remotes = root:WaitForChild("Remotes")
local catalogRequest = remotes:WaitForChild("CatalogRequest")
local openCatalog = remotes:WaitForChild("OpenCatalog")

local state = {
    looks = {},
    favorites = {},
    category = "All",
    search = "",
    favoritesOnly = false,
}

local gui = Instance.new("ScreenGui")
gui.Name = "BBYAVATAR_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "CatalogPanel"
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.Size = UDim2.fromScale(0.92, 0.82)
frame.Visible = false
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 18)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromScale(0.04, 0.025)
title.Size = UDim2.fromScale(0.62, 0.075)
title.Font = Enum.Font.GothamBold
title.Text = "BBYAVATAR"
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromScale(0.04, 0.1)
subtitle.Size = UDim2.fromScale(0.62, 0.045)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Avatar Catalog & Outfit Creator"
subtitle.TextScaled = true
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = frame

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.fromScale(0.965, 0.035)
close.Size = UDim2.fromScale(0.1, 0.07)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextScaled = true
close.Parent = frame
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 14)

local searchBox = Instance.new("TextBox")
searchBox.Position = UDim2.fromScale(0.04, 0.165)
searchBox.Size = UDim2.fromScale(0.58, 0.065)
searchBox.PlaceholderText = "Search looks or tags..."
searchBox.ClearTextOnFocus = false
searchBox.Font = Enum.Font.Gotham
searchBox.TextScaled = true
searchBox.Parent = frame
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 14)

local favoriteToggle = Instance.new("TextButton")
favoriteToggle.Position = UDim2.fromScale(0.64, 0.165)
favoriteToggle.Size = UDim2.fromScale(0.32, 0.065)
favoriteToggle.Text = "Favorites: OFF"
favoriteToggle.Font = Enum.Font.GothamBold
favoriteToggle.TextScaled = true
favoriteToggle.Parent = frame
Instance.new("UICorner", favoriteToggle).CornerRadius = UDim.new(0, 14)

local categories = Instance.new("ScrollingFrame")
categories.Position = UDim2.fromScale(0.04, 0.245)
categories.Size = UDim2.fromScale(0.92, 0.085)
categories.AutomaticCanvasSize = Enum.AutomaticSize.X
categories.CanvasSize = UDim2.new()
categories.ScrollBarThickness = 0
categories.ScrollingDirection = Enum.ScrollingDirection.X
categories.Parent = frame

local catLayout = Instance.new("UIListLayout")
catLayout.FillDirection = Enum.FillDirection.Horizontal
catLayout.Padding = UDim.new(0, 8)
catLayout.Parent = categories

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromScale(0.04, 0.345)
list.Size = UDim2.fromScale(0.92, 0.605)
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.ScrollBarThickness = 5
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.Parent = list

local function favoriteSet()
    local result = {}
    for _, lookId in ipairs(state.favorites) do
        result[lookId] = true
    end
    return result
end

local function matches(look)
    if state.category ~= "All" and look.category ~= state.category then
        return false
    end

    local fav = favoriteSet()
    if state.favoritesOnly and not fav[look.id] then
        return false
    end

    local query = string.lower(state.search or "")
    if query == "" then
        return true
    end

    local haystack = string.lower((look.name or "") .. " " .. (look.category or ""))
    for _, tag in ipairs(look.tags or {}) do
        haystack ..= " " .. string.lower(tostring(tag))
    end
    return string.find(haystack, query, 1, true) ~= nil
end

local function clearCards()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("GuiObject") and not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

local render

local function addCard(look)
    local fav = favoriteSet()
    local card = Instance.new("Frame")
    card.Name = look.id or "Look"
    card.Size = UDim2.new(1, -8, 0, 104)
    card.Parent = list
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)

    local name = Instance.new("TextLabel")
    name.BackgroundTransparency = 1
    name.Position = UDim2.fromScale(0.04, 0.1)
    name.Size = UDim2.fromScale(0.52, 0.28)
    name.Font = Enum.Font.GothamBold
    name.Text = look.name or "Unnamed Look"
    name.TextScaled = true
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = card

    local category = Instance.new("TextLabel")
    category.BackgroundTransparency = 1
    category.Position = UDim2.fromScale(0.04, 0.48)
    category.Size = UDim2.fromScale(0.46, 0.2)
    category.Font = Enum.Font.Gotham
    category.Text = look.category or "Featured"
    category.TextScaled = true
    category.TextXAlignment = Enum.TextXAlignment.Left
    category.Parent = card

    local tryButton = Instance.new("TextButton")
    tryButton.Position = UDim2.fromScale(0.58, 0.18)
    tryButton.Size = UDim2.fromScale(0.22, 0.58)
    tryButton.Text = "TRY LOOK"
    tryButton.Font = Enum.Font.GothamBold
    tryButton.TextScaled = true
    tryButton.Parent = card
    Instance.new("UICorner", tryButton).CornerRadius = UDim.new(0, 12)

    local favButton = Instance.new("TextButton")
    favButton.Position = UDim2.fromScale(0.82, 0.18)
    favButton.Size = UDim2.fromScale(0.14, 0.58)
    favButton.Text = fav[look.id] and "SAVED" or "SAVE"
    favButton.Font = Enum.Font.GothamBold
    favButton.TextScaled = true
    favButton.Parent = card
    Instance.new("UICorner", favButton).CornerRadius = UDim.new(0, 12)

    tryButton.Activated:Connect(function()
        local response = catalogRequest:InvokeServer("TRY_LOOK", {lookId = look.id})
        tryButton.Text = response and response.ok and "APPLIED" or "NOT READY"
    end)

    favButton.Activated:Connect(function()
        local response = catalogRequest:InvokeServer("TOGGLE_FAVORITE", {lookId = look.id})
        if response and response.ok then
            state.favorites = response.favorites or {}
            render()
        end
    end)
end

render = function()
    clearCards()
    for _, look in ipairs(state.looks) do
        if matches(look) then
            addCard(look)
        end
    end
end

local function rebuildCategories()
    for _, child in ipairs(categories:GetChildren()) do
        if child:IsA("GuiObject") and not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    local seen = {All = true}
    local names = {"All"}
    for _, look in ipairs(state.looks) do
        local name = look.category or "Featured"
        if not seen[name] then
            seen[name] = true
            table.insert(names, name)
        end
    end

    for _, categoryName in ipairs(names) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.fromOffset(120, 44)
        button.Text = categoryName
        button.Font = Enum.Font.GothamBold
        button.TextScaled = true
        button.Parent = categories
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 12)
        button.Activated:Connect(function()
            state.category = categoryName
            render()
        end)
    end
end

local function refresh()
    local response = catalogRequest:InvokeServer("LIST_LOOKS", {})
    if response and response.ok then
        state.looks = response.looks or {}
        state.favorites = response.favorites or {}
        rebuildCategories()
        render()
    end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    state.search = searchBox.Text
    render()
end)

favoriteToggle.Activated:Connect(function()
    state.favoritesOnly = not state.favoritesOnly
    favoriteToggle.Text = state.favoritesOnly and "Favorites: ON" or "Favorites: OFF"
    render()
end)

openCatalog.OnClientEvent:Connect(function()
    refresh()
    frame.Visible = true
end)

close.Activated:Connect(function()
    frame.Visible = false
end)
