-- BBYAVATAR try-on conversion actions v1.
-- Extends tryon.client.lua. Keeps avatar changes local until the user explicitly confirms
-- Roblox-native save/create prompts. No ownership is implied for previewed catalog items.

local saveTryOn = Instance.new("TextButton")
saveTryOn.Name = "SaveTryOnLook"
saveTryOn.AnchorPoint = Vector2.new(0, 1)
saveTryOn.Position = UDim2.new(0.03, 126, 0.94, 0)
saveTryOn.Size = UDim2.fromOffset(124, 42)
saveTryOn.BackgroundColor3 = Color3.fromRGB(61, 82, 68)
saveTryOn.TextColor3 = Color3.new(1, 1, 1)
saveTryOn.Font = Enum.Font.GothamBold
saveTryOn.TextSize = 12
saveTryOn.Text = "SAVE LOOK"
saveTryOn.Visible = false
saveTryOn.Parent = gui
Instance.new("UICorner", saveTryOn).CornerRadius = UDim.new(0, 12)

local saveTryOnBusy = false

local function refreshTryOnActions()
    saveTryOn.Visible = undoTryOn.Visible
end

undoTryOn:GetPropertyChangedSignal("Visible"):Connect(refreshTryOnActions)

saveTryOn.Activated:Connect(function()
    if saveTryOnBusy or tryOnBusy or not undoTryOn.Visible then return end
    local humanoid = currentHumanoid()
    if not humanoid then
        status.Text = "Avatar is not ready yet."
        return
    end

    saveTryOnBusy = true
    local ok, err = pcall(function()
        local description = humanoid:GetAppliedDescription()
        AvatarEditorService:PromptCreateOutfit(description, humanoid.RigType)
    end)
    if ok then
        status.Text = "Choose a name in Roblox to save this preview as an outfit."
    else
        status.Text = "Could not open outfit save: " .. tostring(err)
    end
    saveTryOnBusy = false
end)

AvatarEditorService.PromptCreateOutfitCompleted:Connect(function(result)
    if result == Enum.AvatarPromptResult.Success and undoTryOn.Visible then
        status.Text = "Preview saved as an outfit. Unowned items are not granted automatically."
    end
end)

player.CharacterAdded:Connect(function()
    saveTryOnBusy = false
    saveTryOn.Visible = false
end)

refreshTryOnActions()
print("[BBYAVATAR] Try-on SAVE LOOK conversion action ready")
