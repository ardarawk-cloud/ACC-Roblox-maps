-- BBYAVATAR persistent Saved Picks v2.
-- Stores only Roblox catalog asset IDs keyed by UserId. No item names, prices, inventory,
-- chat text, creator data, or external identifiers are persisted.
-- v2 protects same-user mutations from response-order races and preserves a safe cache fallback.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local STORE_NAME = "BBYAVATAR_SavedPicks_v1"
local MAX_PICKS = 24
local LOAD_COOLDOWN = 0.75
local MUTATION_COOLDOWN = 0.30
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
local mutationInFlight = {}

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
    if existing then return cloneIds(existing), true, nil, true end

    local ok, value = pcall(function()
        return store:GetAsync(keyFor(player))
    end)
    if not ok then return {}, false, "DATASTORE_READ_FAILED", false end

    local ids = normalize(value)
    cache[player.UserId] = ids
    return cloneIds(ids), true, nil, false
end

local function update(player, action, assetId)
    local id = cleanId(assetId)
    if not id then return false, nil, "INVALID_ASSET_ID" end

    local userId = player.UserId
    if mutationInFlight[userId] then
        return false, cloneIds(cache[userId] or {}), "THROTTLED"
    end
    mutationInFlight[userId] = true

    local updatedIds = nil
    local ok = pcall(function()
        store:UpdateAsync(keyFor(player), function(current)
            local ids = normalize(current)
            if action == "ADD" then
                local found = false
                for _, existing in ipairs(ids) do
                    if existing == id then found = true break end
                end
                if not found and #ids < MAX_PICKS then table.insert(ids, id) end
            elseif action == "REMOVE" then
                for index = #ids, 1, -1 do
                    if ids[index] == id then table.remove(ids, index) end
                end
            end
            updatedIds = ids
            return {schema = 1, ids = ids}
        end)
    end)

    mutationInFlight[userId] = nil

    if not ok or not updatedIds then
        -- Do not destroy a previously-good session cache on a transient DataStore failure.
        return false, cloneIds(cache[userId] or {}), "DATASTORE_WRITE_FAILED"
    end

    cache[userId] = normalize(updatedIds)
    return true, cloneIds(cache[userId])
end

local function requestGap(action)
    return action == "LOAD" and LOAD_COOLDOWN or MUTATION_COOLDOWN
end

request.OnServerInvoke = function(player, action, assetId)
    if typeof(action) ~= "string" or #action > 12 then
        return {ok = false, code = "INVALID_ACTION"}
    end

    if action ~= "LOAD" and action ~= "ADD" and action ~= "REMOVE" then
        return {ok = false, code = "INVALID_ACTION"}
    end

    local userId = player.UserId
    local now = os.clock()
    local byAction = lastRequestAt[userId]
    if not byAction then
        byAction = {}
        lastRequestAt[userId] = byAction
    end
    local last = byAction[action] or 0
    if now - last < requestGap(action) then
        return {ok = false, code = "THROTTLED", ids = cloneIds(cache[userId] or {})}
    end
    byAction[action] = now

    if action == "LOAD" then
        local ids, persisted, code, cacheHit = load(player)
        return {ok = persisted, persisted = persisted, ids = ids, code = code, cacheHit = cacheHit == true}
    end

    local ok, ids, code = update(player, action, assetId)
    return {ok = ok, persisted = ok, ids = ids or {}, code = code}
end

Players.PlayerRemoving:Connect(function(player)
    local userId = player.UserId
    cache[userId] = nil
    lastRequestAt[userId] = nil
    mutationInFlight[userId] = nil
end)

root:SetAttribute("SavedPicksPersistence", "DATASTORE_V2_CONCURRENCY_SAFE")
root:SetAttribute("SavedPicksMax", MAX_PICKS)
root:SetAttribute("SavedPicksPrivacy", "USERID_KEY_PLUS_ASSET_IDS_ONLY")
root:SetAttribute("SavedPicksMutationGuard", true)
root:SetAttribute("SavedPicksCacheFallback", true)
print("[BBYAVATAR] Persistent Saved Picks v2 concurrency-safe sync ready")