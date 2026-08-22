-- BBYAVATAR keyboard/gamepad navigation layer.
-- Keeps the catalog usable without touch or mouse while leaving Roblox-native
-- GuiButton activation behavior intact.

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("BBYAVATAR_UI")
local panel = gui:WaitForChild("CatalogPanel")
local openButton = gui:WaitForChild("OpenCatalog")

local selectionCounter = 0

local function isNavigationInput(inputType)
    return inputType == Enum.UserInputType.Keyboard
        or inputType == Enum.UserInputType.Gamepad1
        or inputType == Enum.UserInputType.Gamepad2
        or inputType == Enum.UserInputType.Gamepad3
        or inputType == Enum.UserInputType.Gamepad4
        or inputType == Enum.UserInputType.Gamepad5
        or inputType == Enum.UserInputType.Gamepad6
        or inputType == Enum.UserInputType.Gamepad7
        or inputType == Enum.UserInputType.Gamepad8
end

local function registerButton(object)
    if not object:IsA("GuiButton") then return end
    object.Selectable = true
    selectionCounter += 1
    object.SelectionOrder = selectionCounter
end

for _, object in ipairs(gui:GetDescendants()) do
    registerButton(object)
end

gui.DescendantAdded:Connect(function(object)
    registerButton(object)
end)

local function firstUsableButton(container)
    local best = nil
    local bestOrder = math.huge
    for _, object in ipairs(container:GetDescendants()) do
        if object:IsA("GuiButton")
            and object.Visible
            and object.Active
            and object.Selectable
            and object.AbsoluteSize.X > 0
            and object.AbsoluteSize.Y > 0
        then
            local order = object.SelectionOrder
            if order < bestOrder then
                best = object
                bestOrder = order
            end
        end
    end
    return best
end

local function findCloseButton()
    for _, object in ipairs(panel:GetDescendants()) do
        if object:IsA("TextButton") and (object.Name == "Close" or object.Text == "×" or object.Text == "CLOSE") then
            return object
        end
    end
    return nil
end

local function refreshSelection()
    if not isNavigationInput(UserInputService:GetLastInputType()) then
        return
    end

    if panel.Visible then
        local selected = GuiService.SelectedObject
        if not selected or not selected:IsDescendantOf(panel) or not selected.Visible then
            GuiService.SelectedObject = firstUsableButton(panel)
        end
    else
        GuiService.SelectedObject = openButton
    end
end

panel:GetPropertyChangedSignal("Visible"):Connect(function()
    task.defer(refreshSelection)
end)

UserInputService.LastInputTypeChanged:Connect(function(inputType)
    if isNavigationInput(inputType) then
        task.defer(refreshSelection)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not panel.Visible then return end

    local backPressed = input.KeyCode == Enum.KeyCode.Escape
        or input.KeyCode == Enum.KeyCode.ButtonB

    if not backPressed then return end

    local closeButton = findCloseButton()
    if closeButton and closeButton.Active and closeButton.Visible then
        closeButton:Activate()
    else
        panel.Visible = false
    end
    task.defer(refreshSelection)
end)

openButton.SelectionOrder = 1
refreshSelection()

print("[BBYAVATAR] Keyboard/gamepad navigation v1 ready")
