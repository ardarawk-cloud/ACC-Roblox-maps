-- BBYAVATAR persistent Recent Views v1.
-- Stores only Roblox catalog asset IDs keyed by UserId. This is intentionally minimal:
-- no item names, creator metadata, prices, search terms, chat text, or external identifiers.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local STORE_NAME = "BBYAVATAR_RecentViews_v1"
local MAX_RECENT = 12
local LOAD_COOLDOWN = 1.0
local TOUCH_COOLDOWN = 0.45
local MAX_ASSET_ID = 9007199254740991

local store = DataStoreService:GetDataStore(STORE_NAME)
local request = root:FindFirstChild("RecentViewsRequest")
if request then request:Destroy() end
request = Instance.new("RemoteFunction")
request.Name = "RecentViewsRequest"
request.Parent = root

local cache = {}
local lastRequestAt = {}
local mutationInFlight = {}

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

local function load(player)
    local userId = player.UserId
    if cache[userId] then return cloneIds(cache[userId]), true, nil, true end
    local ok, value = pcall(function() return store:GetAsync(keyFor(player)) end)
    if not ok then return {}, false, "DATASTORE_READ_FAILED", false end
    local ids = normalize(value)
    cache[userId] = ids
    return cloneIds(ids), true, nil, false
end

local function touch(player, assetId)
    local id = cleanId(assetId)
    if not id then return false, cloneIds(cache[player.UserId] or {}), "INVALID_ASSET_ID" end
    local userId = player.UserId
    if mutationInFlight[userId] then return false, cloneIds(cache[userId] or {}), "THROTTLED" end
    mutationInFlight[userId] = true

    local updated
    local ok = pcall(function()
        store:UpdateAsync(keyFor(player), function(current)
            local ids = normalize(current)
            for i = #ids, 1, -1 do
                if ids[i] == id then table.remove(ids, i) end
            end
            table.insert(ids, 1, id)
            while #ids > MAX_RECENT do table.remove(ids) end
            updated = cloneIds(ids)
            return {schema = 1, ids = ids}
        end)
    end)
    mutationInFlight[userId] = nil

    if not ok or not updated then
        return false, cloneIds(cache[userId] or {}), "DATASTORE_WRITE_FAILED"
    end
    cache[userId] = normalize(updated)
    return true, cloneIds(cache[userId])
end

local function requestGap(action)
    return action == "LOAD" and LOAD_COOLDOWN or TOUCH_COOLDOWN
end

request.OnServerInvoke = function(player, action, assetId)
    if typeof(action) ~= "string" or #action > 8 or (action ~= "LOAD" and action ~= "TOUCH") then
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

    local ok, ids, code = touch(player, assetId)
    return {ok = ok, persisted = ok, ids = ids or {}, code = code}
end

Players.PlayerRemoving:Connect(function(player)
    local userId = player.UserId
    cache[userId] = nil
    lastRequestAt[userId] = nil
    mutationInFlight[userId] = nil
end)

root:SetAttribute("RecentViewsPersistence", "DATASTORE_V1_ASSET_IDS_ONLY")
root:SetAttribute("RecentViewsMax", MAX_RECENT)
root:SetAttribute("RecentViewsPrivacy", "USERID_KEY_PLUS_ASSET_IDS_ONLY")
print("[BBYAVATAR] Persistent Recent Views v1 ready")