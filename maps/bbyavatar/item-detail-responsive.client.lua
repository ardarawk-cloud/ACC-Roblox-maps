-- BBYAVATAR responsive item detail layout.
-- Reflows the detail drawer for narrow phone viewports without changing catalog or purchase logic.

local Workspace = game:GetService("Workspace")

local function applyItemDetailLayout()
    local camera = Workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local width = viewport.X
    local compact = width <= 700
    local narrow = width <= 400

    if compact then
        detailPanel.Size = UDim2.fromScale(0.94, 0.86)
        detailImage.Position = UDim2.fromOffset(16, 16)
        detailImage.Size = UDim2.fromOffset(narrow and 82 or 96, narrow and 82 or 96)

        detailClose.Position = UDim2.new(1, -12, 0, 12)
        detailClose.Size = UDim2.fromOffset(38, 36)

        local textX = narrow and 112 or 126
        detailName.Position = UDim2.fromOffset(textX, 16)
        detailName.Size = UDim2.new(1, -(textX + 54), 0, 50)
        detailName.TextSize = narrow and 15 or 17

        detailMeta.Position = UDim2.fromOffset(textX, 70)
        detailMeta.Size = UDim2.new(1, -(textX + 18), 0, 70)
        detailMeta.TextSize = narrow and 10 or 11

        detailDescription.Position = UDim2.fromOffset(16, 152)
        detailDescription.Size = UDim2.new(1, -32, 1, -238)
        detailDescription.TextSize = narrow and 11 or 12

        actionBar.Position = UDim2.new(0, 16, 1, -14)
        actionBar.Size = UDim2.new(1, -32, 0, 58)
        actionLayout.Padding = UDim.new(0, narrow and 5 or 7)
        detailTry.TextSize = narrow and 9 or 10
        detailSave.TextSize = narrow and 9 or 10
        detailBuy.TextSize = narrow and 9 or 10
    else
        detailPanel.Size = UDim2.fromScale(0.78, 0.72)
        detailImage.Position = UDim2.fromOffset(20, 20)
        detailImage.Size = UDim2.fromOffset(150, 150)

        detailClose.Position = UDim2.new(1, -14, 0, 14)
        detailClose.Size = UDim2.fromOffset(42, 38)

        detailName.Position = UDim2.fromOffset(186, 20)
        detailName.Size = UDim2.new(1, -250, 0, 58)
        detailName.TextSize = 20

        detailMeta.Position = UDim2.fromOffset(186, 86)
        detailMeta.Size = UDim2.new(1, -210, 0, 84)
        detailMeta.TextSize = 13

        detailDescription.Position = UDim2.fromOffset(20, 186)
        detailDescription.Size = UDim2.new(1, -40, 1, -276)
        detailDescription.TextSize = 13

        actionBar.Position = UDim2.new(0, 20, 1, -18)
        actionBar.Size = UDim2.new(1, -40, 0, 54)
        actionLayout.Padding = UDim.new(0, 8)
        detailTry.TextSize = 11
        detailSave.TextSize = 11
        detailBuy.TextSize = 11
    end
end

local watchedCamera = nil
local viewportConnection = nil
local function watchCamera()
    local camera = Workspace.CurrentCamera
    if camera == watchedCamera then return end
    watchedCamera = camera
    if viewportConnection then viewportConnection:Disconnect() end
    viewportConnection = nil
    if camera then
        viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyItemDetailLayout)
    end
    applyItemDetailLayout()
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
watchCamera()

print("[BBYAVATAR] Mobile-responsive item detail layout ready")