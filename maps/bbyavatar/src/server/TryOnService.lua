local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TryOnService = {}

local root = ReplicatedStorage:WaitForChild("BBYAVATAR")
local shared = root:WaitForChild("Shared")
local AvatarDescriptionBuilder = require(shared:WaitForChild("AvatarDescriptionBuilder"))

function TryOnService.ApplyLook(player, look)
    if not player or not look or type(look.items) ~= "table" then
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

    local buildOk, buildError = AvatarDescriptionBuilder.ApplyLook(description, look)
    if not buildOk then
        return false, buildError
    end

    local success, applyError = pcall(function()
        humanoid:ApplyDescription(description)
    end)

    if not success then
        warn("[BBYAVATAR] Try-on failed:", applyError)
        return false, "APPLY_FAILED"
    end

    return true
end

return TryOnService
