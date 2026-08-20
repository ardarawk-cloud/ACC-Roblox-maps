local DataStoreService = game:GetService("DataStoreService")

local FavoritesService = {}
local store = DataStoreService:GetDataStore("BBYAVATAR_FAVORITES_V1")
local cache = {}

local function keyFor(player)
    return "u_" .. tostring(player.UserId)
end

local function sanitize(list)
    local result = {}
    local seen = {}
    if type(list) == "table" then
        for _, lookId in ipairs(list) do
            if type(lookId) == "string" and not seen[lookId] then
                seen[lookId] = true
                table.insert(result, lookId)
                if #result >= 100 then
                    break
                end
            end
        end
    end
    return result
end

function FavoritesService.Get(player)
    if cache[player.UserId] then
        return cache[player.UserId]
    end

    local data = {}
    local ok, value = pcall(function()
        return store:GetAsync(keyFor(player))
    end)
    if ok then
        data = sanitize(value)
    end
    cache[player.UserId] = data
    return data
end

function FavoritesService.Toggle(player, lookId)
    if type(lookId) ~= "string" or lookId == "" then
        return false, "INVALID_LOOK_ID"
    end

    local list = FavoritesService.Get(player)
    local foundIndex
    for i, value in ipairs(list) do
        if value == lookId then
            foundIndex = i
            break
        end
    end

    local enabled
    if foundIndex then
        table.remove(list, foundIndex)
        enabled = false
    else
        table.insert(list, lookId)
        enabled = true
    end

    cache[player.UserId] = sanitize(list)
    task.spawn(function()
        pcall(function()
            store:SetAsync(keyFor(player), cache[player.UserId])
        end)
    end)

    return true, enabled, cache[player.UserId]
end

function FavoritesService.Clear(player)
    cache[player.UserId] = nil
end

return FavoritesService
