local MarketplaceService = game:GetService("MarketplaceService")

local PurchaseService = {}

local function validAssetId(value)
    return type(value) == "number" and value > 0
end

function PurchaseService.GetPurchasableAssets(look)
    local result = {}
    local purchase = look and look.purchase
    if not purchase or purchase.enabled ~= true then
        return result
    end

    for _, assetId in ipairs(purchase.assetIds or {}) do
        if validAssetId(assetId) then
            table.insert(result, assetId)
        end
    end

    return result
end

function PurchaseService.PromptAsset(player, assetId)
    if not player or not validAssetId(assetId) then
        return false, "INVALID_ASSET"
    end

    local success, err = pcall(function()
        MarketplaceService:PromptPurchase(player, assetId)
    end)

    if not success then
        return false, tostring(err)
    end

    return true
end

return PurchaseService
