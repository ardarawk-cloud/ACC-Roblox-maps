-- BBYAVATAR persistent Saved Picks v1.
-- Stores only Roblox catalog asset IDs keyed by UserId. No item names, prices, inventory,
-- chat text, creator data, or external identifiers are persisted.
-- Mutations use UpdateAsync so simultaneous servers cannot silently overwrite each other.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local STORE_NAME = "BBYAVATAR_SavedPicks_v1"
local MAX_PICKS = 24
local REQUEST_COOLDOWN = 0.30
local MAX_ASSET_ID = 9007199254740991 -- exact integer ceiling for Lua number / JSON interoperability

local store = DataStoreService:GetDataStore(STORE_NAME)
local request = rem:FindFirstChild("SavedPicksRequest")
if not request then
    request = Instance.new("RemoteFunction")
    request.Name = "SavedPicksRequest"
    request.Parent = rem
end

local cache = {}
local lastRequestAt = {}

local function cleanId(value)
    local id = tonumber(value)
    if not id or id ~= math.floor(id) or id <= 0 or id > MAX_ASSET_ID then return nil end
    return id
end

local function normalize(value)
    local source = value
    if typeof(value) == "table" and typeof(value.ids) == "table" then source = value.ids end
    if typeof(source) ~= "table" then source = {} end

    local ids, seen = {}, {}
    for _, raw in ipairs(source) do
        local id = cleanId(raw)
        if id and not seen[id] then
            seen[id] = true
            table.insert(ids, id)
            if #ids >= MAX_PICKS then break end
        end
    end
    return ids
end

local function cloneIds(ids)
    local out = table.create(#ids)
    for index, id in ipairs(ids) do out[index] = id end
    return out
end

local function keyFor(player)
    return "u:" .. tostring(player.UserId)
end

local function load(player)
    local existing = cache[player.UserId]
    if existing then return cloneIds(existing), true end

    local ok, value = pcall(function()
        return store:GetAsync(keyFor(player))
    end)
    if not ok then return {}, false, "DATASTORE_READ_FAILED" end

    local ids = normalize(value)
    cache[player.UserId] = ids
    return cloneIds(ids), true
end

local function update(player, action, assetId)
    local id = cleanId(assetId)
    if not id then return false, nil, "INVALID_ASSET_ID" end

    local updatedIds = nil
    local ok = pcall(function()
        store:UpdateAsync(keyFor(player), function(current)
            local ids = normalize(current)
            if action == "ADD" then
                local found = false
                for _, existing in ipairs(ids) do
                    if existing == id then found = true break end
                end
                if not found then
                    if #ids >= MAX_PICKS then
                        updatedIds = ids
                        return {schema = 1, ids = ids}
                    end
                    table.insert(ids, id)
                end
            elseif action == "REMOVE" then
                for index = #ids, 1, -1 do
                    if ids[index] == id then table.remove(ids, index) end
                end
            end
            updatedIds = ids
            return {schema = 1, ids = ids}
        end)
    end)

    if not ok or not updatedIds then return false, nil, "DATASTORE_WRITE_FAILED" end
    cache[player.UserId] = normalize(updatedIds)
    return true, cloneIds(cache[player.UserId])
end

request.OnServerInvoke = function(player, action, assetId)
    if typeof(action) ~= "string" then
        return {ok = false, code = "INVALID_ACTION"}
    end

    local now = os.clock()
    local last = lastRequestAt[player.UserId] or 0
    if now - last < REQUEST_COOLDOWN then
        return {ok = false, code = "THROTTLED"}
    end
    lastRequestAt[player.UserId] = now

    if action == "LOAD" then
        local ids, persisted, code = load(player)
        return {ok = persisted, persisted = persisted, ids = ids, code = code}
    elseif action == "ADD" or action == "REMOVE" then
        local ok, ids, code = update(player, action, assetId)
        return {ok = ok, persisted = ok, ids = ids or {}, code = code}
    end

    return {ok = false, code = "INVALID_ACTION"}
end

Players.PlayerRemoving:Connect(function(player)
    cache[player.UserId] = nil
    lastRequestAt[player.UserId] = nil
end)

root:SetAttribute("SavedPicksPersistence", "DATASTORE_V1_ASSET_IDS_ONLY")
root:SetAttribute("SavedPicksMax", MAX_PICKS)
root:SetAttribute("SavedPicksPrivacy", "USERID_KEY_PLUS_ASSET_IDS_ONLY")
print("[BBYAVATAR] Persistent Saved Picks v1 ready")