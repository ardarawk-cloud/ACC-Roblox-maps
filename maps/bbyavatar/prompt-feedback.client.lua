-- Native Roblox prompt completion feedback + privacy-safe funnel events.
local trackEvent = root:WaitForChild("TrackEvent")

local function track(name)
    pcall(function() trackEvent:FireServer(name) end)
end

track("SESSION_START")
openEvent.OnClientEvent:Connect(function()
    track("CATALOG_OPEN")
end)

local function resultSuffix(result)
    if result == Enum.AvatarPromptResult.Success then return "SUCCESS", "Saved successfully." end
    if result == Enum.AvatarPromptResult.PermissionDenied then return "DENIED", "Action cancelled." end
    return "FAILED", "Roblox could not complete that action."
end

AvatarEditorService.PromptSaveAvatarCompleted:Connect(function(result)
    local suffix, message = resultSuffix(result)
    status.Text = message
    track("SAVE_AVATAR_" .. suffix)
end)

AvatarEditorService.PromptCreateOutfitCompleted:Connect(function(result)
    local suffix, message = resultSuffix(result)
    status.Text = message
    track("CREATE_OUTFIT_" .. suffix)
end)

AvatarEditorService.PromptSetFavoriteCompleted:Connect(function(result)
    local suffix, message = resultSuffix(result)
    status.Text = message
    track("FAVORITE_" .. suffix)
end)

MarketplaceService.PromptPurchaseFinished:Connect(function(userId, assetId, isPurchased)
    if userId ~= player.UserId then return end
    status.Text = isPurchased and "Purchase completed." or "Purchase cancelled."
    track(isPurchased and "PURCHASE_SUCCESS" or "PURCHASE_CANCELLED")
end)

local ok = pcall(function()
    MarketplaceService.PromptBundlePurchaseFinished:Connect(function(userId, bundleId, isPurchased)
        if userId ~= player.UserId then return end
        status.Text = isPurchased and "Bundle purchase completed." or "Bundle purchase cancelled."
        track(isPurchased and "PURCHASE_SUCCESS" or "PURCHASE_CANCELLED")
    end)
end)
if not ok then
    warn("[BBYAVATAR] Bundle purchase completion event unavailable on this client")
end

print("[BBYAVATAR] Native prompt feedback + funnel tracking ready")
