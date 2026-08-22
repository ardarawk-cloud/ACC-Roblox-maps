-- BBYAVATAR persistent Recent Views v3.
-- Stores only Roblox catalog asset IDs keyed by UserId. Intentionally minimal:
-- no item names, creator metadata, prices, search terms, chat text, or external identifiers.
-- v3 keeps TOUCH operations memory-first and batches persistence to protect DataStore budgets.
-- CLEAR remains an immediate persisted privacy action.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local STORE_NAME = "BBYAVATAR_RecentViews_v1"
local MAX_RECENT = 12
local LOAD_COOLDOWN = 1.0
local TOUCH_COOLDOWN = 0.45
local CLEAR_COOLDOWN = 2.0
local FLUSH_INTERVAL = 15
local MAX_ASSET_ID = 9007199254740991

local store = DataStoreService:GetDataStore(STORE_NAME)
local request = root:FindFirstChild("RecentViewsRequest")
if request then request:Destroy() end
request = Instance.new("RemoteFunction")
request.Name = "RecentViewsRequest"
request.Parent = root

local cache = {}
local loaded = {}
local dirty = {}
local lastRequestAt = {}
local mutationInFlight = {}
local shuttingDown = false

local function cleanId(value)
    local id = tonumber(value)
    if not id or id ~= math.floor(id) or id < 1 or id > MAX_ASSET_ID then return nil end
    return id
end

local function normalize(value)
    local source = typeof(value) == "table" and (value.ids or value) or {}
    local ids, seen = {}, {}
    for _, raw in ipairs(source) do
        local id = cleanId(raw)
        if id and not seen[id] then
            seen[id] = true
            table.insert(ids, id)
            if #ids >= MAX_RECENT then break end
        end
    end
    return ids
end

local function cloneIds(ids)
    local out = {}
    for i, id in ipairs(ids or {}) do out[i] = id end
    return out
end

local function keyFor(player)
    return "u:" .. tostring(player.UserId)
end

local function beginMutation(userId)
    if mutationInFlight[userId] then return false end
    mutationInFlight[userId] = true
    return true
end

local function finishMutation(userId)
    mutationInFlight[userId] = nil
end

local function load(player)
    local userId = player.UserId
    if loaded[userId] then return cloneIds(cache[userId] or {}), true, nil, true end

    local ok, value = pcall(function()
        return store:GetAsync(keyFor(player))
    end)
    if not ok then return cloneIds(cache[userId] or {}), false, "DATASTORE_READ_FAILED", false end

    cache[userId] = normalize(value)
    loaded[userId] = true
    return cloneIds(cache[userId]), true, nil, false
end

local function ensureLoaded(player)
    if loaded[player.UserId] then return true end
    local _, ok = load(player)
    return ok
end

local function flush(player)
    local userId = player.UserId
    if not dirty[userId] then return true, cloneIds(cache[userId] or {}) end
    if not loaded[userId] then return false, cloneIds(cache[userId] or {}), "NOT_LOADED" end
    if not beginMutation(userId) then return false, cloneIds(cache[userId] or {}), "THROTTLED" end

    local snapshot = cloneIds(cache[userId] or {})
    local ok = pcall(function()
        store:UpdateAsync(keyFor(player), function()
            return {schema = 1, ids = snapshot}
        end)
    end)
    finishMutation(userId)

    if not ok then
        return false, cloneIds(cache[userId] or {}), "DATASTORE_WRITE_FAILED"
    end

    -- Only clear dirty if no newer memory mutation happened while this snapshot was writing.
    local current = cache[userId] or {}
    local same = #current == #snapshot
    if same then
        for i, id in ipairs(snapshot) do
            if current[i] ~= id then same = false break end
        end
    end
    if same then dirty[userId] = nil end
    return true, cloneIds(current)
end

local function touch(player, assetId)
    local id = cleanId(assetId)
    if not id then return false, cloneIds(cache[player.UserId] or {}), "INVALID_ASSET_ID" end
    local userId = player.UserId

    if not ensureLoaded(player) then
        return false, cloneIds(cache[userId] or {}), "DATASTORE_READ_FAILED"
    end

    local ids = cache[userId]
    for i = #ids, 1, -1 do
        if ids[i] == id then table.remove(ids, i) end
    end
    table.insert(ids, 1, id)
    while #ids > MAX_RECENT do table.remove(ids) end
    dirty[userId] = true

    return true, cloneIds(ids)
end

local function clear(player)
    local userId = player.UserId
    if not beginMutation(userId) then return false, cloneIds(cache[userId] or {}), "THROTTLED" end

    local ok = pcall(function()
        store:UpdateAsync(keyFor(player), function()
            return {schema = 1, ids = {}}
        end)
    end)
    finishMutation(userId)

    if not ok then
        return false, cloneIds(cache[userId] or {}), "DATASTORE_WRITE_FAILED"
    end

    cache[userId] = {}
    loaded[userId] = true
    dirty[userId] = nil
    return true, {}
end

local function requestGap(action)
    if action == "LOAD" then return LOAD_COOLDOWN end
    if action == "CLEAR" then return CLEAR_COOLDOWN end
    return TOUCH_COOLDOWN
end

request.OnServerInvoke = function(player, action, assetId)
    if typeof(action) ~= "string" or #action > 8 or (action ~= "LOAD" and action ~= "TOUCH" and action ~= "CLEAR") then
        return {ok = false, code = "INVALID_ACTION", ids = {}}
    end

    local userId = player.UserId
    local byAction = lastRequestAt[userId]
    if not byAction then byAction = {}; lastRequestAt[userId] = byAction end
    local now, last = os.clock(), byAction[action] or 0
    if now - last < requestGap(action) then
        return {ok = false, code = "THROTTLED", ids = cloneIds(cache[userId] or {})}
    end
    byAction[action] = now

    if action == "LOAD" then
        local ids, persisted, code, cacheHit = load(player)
        return {ok = persisted, persisted = persisted, ids = ids, code = code, cacheHit = cacheHit == true}
    end

    if action == "CLEAR" then
        local ok, ids, code = clear(player)
        return {ok = ok, persisted = ok, ids = ids or {}, code = code}
    end

    local ok, ids, code = touch(player, assetId)
    return {
        ok = ok,
        persisted = false,
        queued = ok,
        ids = ids or {},
        code = code,
    }
end

-- Batch dirty history instead of spending one DataStore write per viewed item.
task.spawn(function()
    while not shuttingDown do
        task.wait(FLUSH_INTERVAL)
        for _, player in ipairs(Players:GetPlayers()) do
            if dirty[player.UserId] then
                task.spawn(function()
                    flush(player)
                end)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    local userId = player.UserId
    if dirty[userId] then flush(player) end
    cache[userId] = nil
    loaded[userId] = nil
    dirty[userId] = nil
    lastRequestAt[userId] = nil
    mutationInFlight[userId] = nil
end)

game:BindToClose(function()
    shuttingDown = true
    for _, player in ipairs(Players:GetPlayers()) do
        if dirty[player.UserId] then flush(player) end
    end
end)

root:SetAttribute("RecentViewsPersistence", "DATASTORE_V3_BATCHED_TOUCH_WRITES")
root:SetAttribute("RecentViewsMax", MAX_RECENT)
root:SetAttribute("RecentViewsPrivacy", "USERID_KEY_PLUS_ASSET_IDS_ONLY_CLEARABLE")
root:SetAttribute("RecentViewsUserClear", true)
root:SetAttribute("RecentViewsFlushInterval", FLUSH_INTERVAL)
root:SetAttribute("RecentViewsBudgetGuard", true)
print("[BBYAVATAR] Persistent Recent Views v3 batched persistence ready")