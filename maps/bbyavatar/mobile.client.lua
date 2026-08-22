-- BBYAVATAR adaptive mobile/accessibility layer.
-- Honors Roblox player UI preferences and avoids periodic layout polling.

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("BBYAVATAR_UI")

local baseTransparency = setmetatable({}, {__mode = "k"})
local viewportConnection = nil

local function preferredTextRank()
    local value = GuiService.PreferredTextSize
    if value == Enum.PreferredTextSize.Largest then return 4 end
    if value == Enum.PreferredTextSize.Larger then return 3 end
    if value == Enum.PreferredTextSize.Large then return 2 end
    return 1
end

local function rememberTransparency(object)
    if not object:IsA("GuiObject") or baseTransparency[object] ~= nil then return end
    local ok, value = pcall(function() return object.BackgroundTransparency end)
    if ok and type(value) == "number" then
        baseTransparency[object] = value
    end
end

local function applyPreferredTransparency()
    local preference = math.clamp(GuiService.PreferredTransparency, 0, 1)
    for object, defaultTransparency in pairs(baseTransparency) do
        if object.Parent then
            pcall(function()
                -- Roblox recommends multiplying the authored transparency by the
                -- player's preference, making panels more opaque when requested.
                object.BackgroundTransparency = defaultTransparency * preference
            end)
        end
    end
end

local function registerGuiTree()
    rememberTransparency(gui)
    for _, descendant in ipairs(gui:GetDescendants()) do
        rememberTransparency(descendant)
    end
    applyPreferredTransparency()
end

local function applyResponsiveLayout()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local compact = viewport.X < 900 or viewport.Y < 600
    local textRank = preferredTextRank()
    local largeText = textRank >= 3

    local panel = gui:FindFirstChild("CatalogPanel")
    local openButton = gui:FindFirstChild("OpenCatalog")

    if panel then
        if compact then
            panel.Size = largeText and UDim2.fromScale(0.98, 0.94) or UDim2.fromScale(0.97, 0.88)
            panel.Position = UDim2.fromScale(0.5, largeText and 0.515 or 0.53)
        else
            panel.Size = largeText and UDim2.fromScale(0.94, 0.88) or UDim2.fromScale(0.92, 0.82)
            panel.Position = UDim2.fromScale(0.5, 0.5)
        end

        -- Preserve vertical room when Roblox text-size accessibility is raised.
        local header = panel:FindFirstChildWhichIsA("Frame")
        if header then
            for _, object in ipairs(header:GetDescendants()) do
                if object:IsA("TextLabel") and object.Text == "Discover • Create • Save • Shop" then
                    object.Visible = not compact and not largeText
                end
            end
        end
    end

    if openButton then
        openButton.AnchorPoint = Vector2.new(1, 1)
        if compact then
            -- Keep the primary action clear of Roblox's bottom-right touch controls.
            openButton.Position = UDim2.new(1, -18, 1, -92)
            openButton.Size = largeText and UDim2.fromOffset(132, 50) or UDim2.fromOffset(118, 44)
        else
            openButton.Position = UDim2.fromScale(0.97, 0.94)
            openButton.Size = largeText and UDim2.fromOffset(148, 52) or UDim2.fromOffset(132, 48)
        end
    end
end

local function bindCamera()
    if viewportConnection then
        viewportConnection:Disconnect()
        viewportConnection = nil
    end
    local camera = workspace.CurrentCamera
    if camera then
        viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveLayout)
    end
    applyResponsiveLayout()
end

registerGuiTree()
bindCamera()

-- Dynamic catalog cards inherit the same readability preference without rescanning.
gui.DescendantAdded:Connect(function(object)
    task.defer(function()
        if not object.Parent then return end
        rememberTransparency(object)
        applyPreferredTransparency()
    end)
end)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
GuiService:GetPropertyChangedSignal("PreferredTextSize"):Connect(applyResponsiveLayout)
GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(applyPreferredTransparency)

-- No positional animation is introduced here; ReducedMotionEnabled is therefore
-- respected by construction. Future UI tweens should branch on that preference.

print("[BBYAVATAR] Mobile accessibility layer v2 ready")
