local Players = game:GetService("Players")

local TryOnService = {}

local function applyIfValid(description, propertyName, assetId)
    if type(assetId) == "number" and assetId > 0 then
        pcall(function()
            description[propertyName] = assetId
        end)
    end
end

function TryOnService.ApplyLook(player, look)
    if not player or not look or not look.items then
        return false, "INVALID_LOOK"
    end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return false, "NO_HUMANOID"
    end

    local ok, description = pcall(function()
        return humanoid:GetAppliedDescription()
    end)
    if not ok or not description then
        return false, "DESCRIPTION_UNAVAILABLE"
    end

    local items = look.items
    applyIfValid(description, "HairAccessory", items.hair)
    applyIfValid(description, "Face", items.face)
    applyIfValid(description, "Shirt", items.top)
    applyIfValid(description, "Pants", items.bottom)

    local success = pcall(function()
        humanoid:ApplyDescription(description)
    end)

    if not success then
        return false, "APPLY_FAILED"
    end

    return true
end

return TryOnService
