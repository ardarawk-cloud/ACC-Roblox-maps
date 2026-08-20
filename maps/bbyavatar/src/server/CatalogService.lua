local CatalogService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local root = ReplicatedStorage:WaitForChild("BBYAVATAR")
local shared = root:WaitForChild("Shared")
local CatalogConfig = require(shared:WaitForChild("CatalogConfig"))

function CatalogService.ListEnabledLooks()
    return CatalogConfig.GetEnabledLooks()
end

function CatalogService.GetLook(lookId)
    local look = CatalogConfig.GetLookById(lookId)
    if not look or not look.enabled then
        return nil, "LOOK_UNAVAILABLE"
    end
    return look
end

function CatalogService.ValidateLookRequest(lookId)
    if type(lookId) ~= "string" or #lookId > 80 then
        return false, "INVALID_LOOK_ID"
    end

    local look, err = CatalogService.GetLook(lookId)
    if not look then
        return false, err
    end

    return true, look
end

return CatalogService
