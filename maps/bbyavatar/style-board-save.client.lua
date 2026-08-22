-- BBYAVATAR Style Board Save v1
-- Adds SAVE FULL LOOK only after the exact current Style Board selection has been
-- successfully previewed. No new user data is persisted; Roblox owns the save flow.

local lastSuccessfulBoardSignature = nil
local pendingBoardSignature = nil
local boardSavePending = false

local function boardItemSignature(items)
    if typeof(items) ~= "table" then return "" end
    local ids = {}
    for _, item in ipairs(items) do
        local id = tonumber(item and (item.Id or item.AssetId or item.id))
        if id then table.insert(ids, tostring(id)) end
    end
    return table.concat(ids, ":")
end

local function currentBoardSignature()
    return boardItemSignature(selectedBoardItems())
end

local baseApplyTryOnBatchForSave = applyTryOnBatch
applyTryOnBatch = function(items)
    local signature = boardItemSignature(items)
    pendingBoardSignature = signature ~= "" and signature or nil
    local started = baseApplyTryOnBatchForSave(items)
    if not started then pendingBoardSignature = nil end
    return started
end

local baseApplyPreparedDescriptionForSave = applyPreparedDescription
applyPreparedDescription = function(humanoid, description, successEvent, failedEvent, successText)
    local ok = baseApplyPreparedDescriptionForSave(humanoid, description, successEvent, failedEvent, successText)
    if successEvent == "BOARD_TRY_ALL_SUCCESS" then
        lastSuccessfulBoardSignature = (ok and pendingBoardSignature) or nil
        pendingBoardSignature = nil
    end
    return ok
end

local baseApplyTryOnForSave = applyTryOn
applyTryOn = function(item)
    lastSuccessfulBoardSignature = nil
    pendingBoardSignature = nil
    return baseApplyTryOnForSave(item)
end

undoTryOn.Activated:Connect(function()
    lastSuccessfulBoardSignature = nil
    pendingBoardSignature = nil
end)

player.CharacterAdded:Connect(function()
    lastSuccessfulBoardSignature = nil
    pendingBoardSignature = nil
    boardSavePending = false
end)

local saveBoardLook = Instance.new("TextButton")
saveBoardLook.Name = "SaveBoardLook"
saveBoardLook.AnchorPoint = Vector2.new(1, 1)
saveBoardLook.Position = UDim2.new(1, -18, 1, -18)
saveBoardLook.Size = UDim2.fromOffset(132, 40)
saveBoardLook.BackgroundColor3 = Color3.fromRGB(47, 52, 65)
saveBoardLook.TextColor3 = Color3.fromRGB(134, 138, 151)
saveBoardLook.Font = Enum.Font.GothamBold
saveBoardLook.TextSize = 11
saveBoardLook.Text = "SAVE FULL LOOK"
saveBoardLook.Visible = false
saveBoardLook.Active = false
saveBoardLook.AutoButtonColor = false
saveBoardLook.ZIndex = 20
saveBoardLook.Parent = frame
Instance.new("UICorner", saveBoardLook).CornerRadius = UDim.new(0, 11)

local function saveReady()
    if activeTab ~= "BOARD" or boardSavePending then return false end
    local signature = currentBoardSignature()
    return signature ~= "" and signature == lastSuccessfulBoardSignature
end

local function refreshSaveButton()
    local onBoard = activeTab == "BOARD"
    saveBoardLook.Visible = onBoard
    local ready = saveReady()
    saveBoardLook.Active = ready
    saveBoardLook.AutoButtonColor = ready
    if boardSavePending then
        saveBoardLook.Text = "SAVING..."
        saveBoardLook.BackgroundColor3 = Color3.fromRGB(47, 52, 65)
        saveBoardLook.TextColor3 = Color3.fromRGB(154, 158, 170)
    elseif ready then
        saveBoardLook.Text = "SAVE FULL LOOK"
        saveBoardLook.BackgroundColor3 = Color3.fromRGB(55, 82, 70)
        saveBoardLook.TextColor3 = Color3.new(1, 1, 1)
    else
        saveBoardLook.Text = "TRY LOOK TO SAVE"
        saveBoardLook.BackgroundColor3 = Color3.fromRGB(47, 52, 65)
        saveBoardLook.TextColor3 = Color3.fromRGB(134, 138, 151)
    end
end

saveBoardLook.Activated:Connect(function()
    if not saveReady() then
        status.Text = "Preview this exact Style Board with TRY FULL LOOK before saving it."
        return
    end
    local humanoid = currentHumanoid()
    if not humanoid then status.Text = "Avatar is not ready yet." return end

    boardSavePending = true
    refreshSaveButton()
    status.Text = "Opening Roblox outfit save prompt..."
    local ok, err = pcall(function()
        AvatarEditorService:PromptCreateOutfit(humanoid:GetAppliedDescription(), humanoid.RigType)
    end)
    if not ok then
        boardSavePending = false
        status.Text = "Could not open outfit save: " .. tostring(err)
        refreshSaveButton()
    end
end)

AvatarEditorService.PromptCreateOutfitCompleted:Connect(function(result, failureType)
    if not boardSavePending then return end
    boardSavePending = false
    if result == Enum.AvatarPromptResult.Success then
        status.Text = "Full look saved to your Roblox outfits."
    elseif result == Enum.AvatarPromptResult.PermissionDenied then
        status.Text = "Outfit save cancelled. Your preview is still active."
    else
        status.Text = "Outfit save failed" .. (failureType and (" • " .. tostring(failureType)) or ".")
    end
    refreshSaveButton()
end)

task.spawn(function()
    while gui.Parent do
        refreshSaveButton()
        task.wait(0.25)
    end
end)

print("[BBYAVATAR] Style Board Save v1 exact-preview conversion ready")