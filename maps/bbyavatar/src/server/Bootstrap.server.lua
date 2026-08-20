local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getOrCreate(parent, className, name)
    local existing = parent:FindFirstChild(name)
    if existing then
        return existing
    end

    local instance = Instance.new(className)
    instance.Name = name
    instance.Parent = parent
    return instance
end

local root = getOrCreate(ReplicatedStorage, "Folder", "BBYAVATAR")
local remotes = getOrCreate(root, "Folder", "Remotes")
local catalogRequest = getOrCreate(remotes, "RemoteFunction", "CatalogRequest")
getOrCreate(remotes, "RemoteEvent", "OpenCatalog")

local CatalogService = require(script.Parent:WaitForChild("CatalogService"))
local TryOnService = require(script.Parent:WaitForChild("TryOnService"))
local FavoritesService = require(script.Parent:WaitForChild("FavoritesService"))
local PurchaseService = require(script.Parent:WaitForChild("PurchaseService"))

catalogRequest.OnServerInvoke = function(player, action, payload)
    if action == "LIST_LOOKS" then
        return {
            ok = true,
            looks = CatalogService.ListEnabledLooks(),
            favorites = FavoritesService.Get(player),
        }
    end

    if action == "GET_LOOK" then
        local lookId = payload and payload.lookId
        local ok, value = CatalogService.ValidateLookRequest(lookId)
        if not ok then
            return {ok = false, error = value}
        end
        return {ok = true, look = value}
    end

    if action == "TRY_LOOK" then
        local lookId = payload and payload.lookId
        local ok, value = CatalogService.ValidateLookRequest(lookId)
        if not ok then
            return {ok = false, error = value}
        end

        local applied, err = TryOnService.ApplyLook(player, value)
        if not applied then
            return {ok = false, error = err}
        end

        return {ok = true}
    end

    if action == "TOGGLE_FAVORITE" then
        local lookId = payload and payload.lookId
        local ok = CatalogService.ValidateLookRequest(lookId)
        if not ok then
            return {ok = false, error = "LOOK_NOT_AVAILABLE"}
        end

        local toggled, enabled, favorites = FavoritesService.Toggle(player, lookId)
        if not toggled then
            return {ok = false, error = enabled}
        end
        return {ok = true, enabled = enabled, favorites = favorites}
    end

    if action == "GET_PURCHASE_ASSETS" then
        local lookId = payload and payload.lookId
        local ok, value = CatalogService.ValidateLookRequest(lookId)
        if not ok then
            return {ok = false, error = value}
        end

        local assets = PurchaseService.GetPurchasableAssets(value)
        return {ok = true, assetIds = assets, enabled = #assets > 0}
    end

    if action == "PROMPT_PURCHASE" then
        local lookId = payload and payload.lookId
        local assetId = payload and payload.assetId
        local ok, value = CatalogService.ValidateLookRequest(lookId)
        if not ok then
            return {ok = false, error = value}
        end

        local allowed = false
        for _, candidate in ipairs(PurchaseService.GetPurchasableAssets(value)) do
            if candidate == assetId then
                allowed = true
                break
            end
        end
        if not allowed then
            return {ok = false, error = "ASSET_NOT_IN_LOOK"}
        end

        local prompted, err = PurchaseService.PromptAsset(player, assetId)
        if not prompted then
            return {ok = false, error = err}
        end
        return {ok = true}
    end

    return {ok = false, error = "UNKNOWN_ACTION"}
end

Players.PlayerRemoving:Connect(function(player)
    FavoritesService.Clear(player)
end)

print("[BBYAVATAR] Bootstrap ready")
