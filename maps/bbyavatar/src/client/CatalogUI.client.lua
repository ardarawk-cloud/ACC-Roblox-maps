local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local root = ReplicatedStorage:WaitForChild("BBYAVATAR")
local remotes = root:WaitForChild("Remotes")
local catalogRequest = remotes:WaitForChild("CatalogRequest")
local openCatalog = remotes:WaitForChild("OpenCatalog")

local gui = Instance.new("ScreenGui")
gui.Name = "BBYAVATAR_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "CatalogPanel"
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.Size = UDim2.fromScale(0.86, 0.76)
frame.Visible = false
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromScale(0.04, 0.03)
title.Size = UDim2.fromScale(0.72, 0.1)
title.Font = Enum.Font.GothamBold
title.Text = "BBYAVATAR"
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromScale(0.04, 0.13)
subtitle.Size = UDim2.fromScale(0.72, 0.06)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Avatar Catalog & Outfit Creator"
subtitle.TextScaled = true
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = frame

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.fromScale(0.96, 0.04)
close.Size = UDim2.fromScale(0.12, 0.08)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextScaled = true
close.Parent = frame
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 14)

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromScale(0.04, 0.22)
list.Size = UDim2.fromScale(0.92, 0.7)
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.ScrollBarThickness = 5
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.Parent = list

local function clearCards()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("GuiObject") and not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

local function addCard(look)
    local card = Instance.new("TextButton")
    card.Name = look.id or "Look"
    card.Size = UDim2.new(1, -8, 0, 90)
    card.Text = ""
    card.Parent = list
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)

    local name = Instance.new("TextLabel")
    name.BackgroundTransparency = 1
    name.Position = UDim2.fromScale(0.04, 0.12)
    name.Size = UDim2.fromScale(0.62, 0.3)
    name.Font = Enum.Font.GothamBold
    name.Text = look.name or "Unnamed Look"
    name.TextScaled = true
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = card

    local category = Instance.new("TextLabel")
    category.BackgroundTransparency = 1
    category.Position = UDim2.fromScale(0.04, 0.52)
    category.Size = UDim2.fromScale(0.48, 0.22)
    category.Font = Enum.Font.Gotham
    category.Text = look.category or "Featured"
    category.TextScaled = true
    category.TextXAlignment = Enum.TextXAlignment.Left
    category.Parent = card

    local try = Instance.new("TextLabel")
    try.BackgroundTransparency = 1
    try.AnchorPoint = Vector2.new(1, 0.5)
    try.Position = UDim2.fromScale(0.95, 0.5)
    try.Size = UDim2.fromScale(0.24, 0.36)
    try.Font = Enum.Font.GothamBold
    try.Text = "TRY LOOK"
    try.TextScaled = true
    try.Parent = card

    card.Activated:Connect(function()
        local response = catalogRequest:InvokeServer("TRY_LOOK", {lookId = look.id})
        if not (response and response.ok) then
            try.Text = "NOT READY"
        else
            try.Text = "APPLIED"
        end
    end)
end

local function refresh()
    clearCards()
    local response = catalogRequest:InvokeServer("LIST_LOOKS", {})
    if response and response.ok then
        for _, look in ipairs(response.looks or {}) do
            addCard(look)
        end
    end
end

openCatalog.OnClientEvent:Connect(function()
    refresh()
    frame.Visible = true
end)

close.Activated:Connect(function()
    frame.Visible = false
end)
