-- BBYAVATAR tab rail v1.
-- Converts the growing top-level catalog navigation into a mobile-safe horizontal rail
-- without breaking legacy code that still searches direct children of `tabs`.

local GuiService = game:GetService("GuiService")

local function widthFor(label)
    local text = tostring(label or "")
    if #text >= 11 then return 112 end
    if #text >= 8 then return 100 end
    return 90
end

local rail = Instance.new("ScrollingFrame")
rail.Name = "TabRail"
rail.BackgroundTransparency = 1
rail.BorderSizePixel = 0
rail.Size = UDim2.fromScale(1, 1)
rail.CanvasSize = UDim2.fromOffset(0, 0)
rail.AutomaticCanvasSize = Enum.AutomaticSize.None
rail.ScrollingDirection = Enum.ScrollingDirection.X
rail.ScrollBarThickness = 3
rail.ScrollBarImageTransparency = 0.35
rail.ElasticBehavior = Enum.ElasticBehavior.Always
rail.ScrollingEnabled = true
rail.Parent = tabs

local railPadding = Instance.new("UIPadding")
railPadding.PaddingLeft = UDim.new(0, 2)
railPadding.PaddingRight = UDim.new(0, 14)
railPadding.Parent = rail

local railLayout = Instance.new("UIListLayout")
railLayout.FillDirection = Enum.FillDirection.Horizontal
railLayout.SortOrder = Enum.SortOrder.LayoutOrder
railLayout.Padding = UDim.new(0, 8)
railLayout.VerticalAlignment = Enum.VerticalAlignment.Center
railLayout.Parent = rail

local proxies = {}

local function updateCanvas()
    rail.CanvasSize = UDim2.fromOffset(math.max(0, railLayout.AbsoluteContentSize.X + 20), 0)
end

local function addProxy(original)
    if not original:IsA("TextButton") or original == rail or proxies[original] then return end

    local proxy = Instance.new("TextButton")
    proxy.Name = "TabProxy_" .. original.Name
    proxy.Size = UDim2.fromOffset(widthFor(original.Text), math.max(36, original.Size.Y.Offset))
    proxy.BackgroundColor3 = original.BackgroundColor3
    proxy.BackgroundTransparency = original.BackgroundTransparency
    proxy.TextColor3 = original.TextColor3
    proxy.Font = original.Font
    proxy.TextSize = math.max(11, original.TextSize)
    proxy.Text = original.Text
    proxy.AutoButtonColor = true
    proxy.LayoutOrder = original.LayoutOrder
    proxy.Parent = rail
    Instance.new("UICorner", proxy).CornerRadius = UDim.new(0, 10)

    proxy.Activated:Connect(function()
        if original.Parent then original:Activate() end
    end)

    proxies[original] = proxy
    original.Visible = false
    updateCanvas()
end

-- Preserve original buttons under `tabs` so existing code that does tabs:GetChildren()
-- and calls :Activate() continues to work, while users interact with the scroll rail.
for _, child in ipairs(tabs:GetChildren()) do
    addProxy(child)
end

-- Disable the authored layout only after proxies exist; originals stay addressable but hidden.
for _, child in ipairs(tabs:GetChildren()) do
    if child:IsA("UIListLayout") and child ~= railLayout then
        child.Parent = nil
        child:Destroy()
    end
end

tabs.ChildAdded:Connect(function(child)
    if child == rail then return end
    task.defer(function()
        if child.Parent == tabs then addProxy(child) end
    end)
end)

railLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
GuiService:GetPropertyChangedSignal("PreferredTextSize"):Connect(function()
    -- Keep controls usable when the player raises Roblox text-size accessibility.
    local pref = GuiService.PreferredTextSize
    local bump = (pref == Enum.PreferredTextSize.Larger or pref == Enum.PreferredTextSize.Largest) and 8 or 0
    for original, proxy in pairs(proxies) do
        if original.Parent and proxy.Parent then
            proxy.Size = UDim2.fromOffset(widthFor(proxy.Text) + bump, 38 + math.floor(bump / 2))
        end
    end
    updateCanvas()
end)

updateCanvas()
print("[BBYAVATAR] Mobile-safe horizontal tab rail v1 ready")