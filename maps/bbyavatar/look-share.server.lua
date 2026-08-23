-- BBYAVATAR Look Share v2
-- Cross-player Style Board sharing using short codes. Persisted payloads contain only
-- Roblox asset IDs plus creation timestamp; no UserId, names, prices, creator text, or chat data.
-- v2 adds bounded positive/negative caches and rolling per-user budgets so random code scans
-- cannot burn persistent DataStore read budget at one request per second.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local SHARE_STORE = DataStoreService:GetDataStore("BBYAVATAR_LookShare_v1")
local SAVED_STORE = DataStoreService:GetDataStore("BBYAVATAR_SavedPicks_v1")
local MAX_ITEMS = 6
local MAX_ASSET_ID = 9007199254740991
local CODE_LENGTH = 7
local CREATE_COOLDOWN = 30
local LOAD_COOLDOWN = 1
local MAX_AGE_SECONDS = 60 * 60 * 24 * 30
local ALPHABET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ"

-- Budget protection. Short per-action cooldowns keep the UI responsive while rolling windows
-- prevent sustained probing from becoming a DataStore-budget problem.
local LOAD_WINDOW_SECONDS = 60
local LOAD_WINDOW_MAX = 12
local CREATE_WINDOW_SECONDS = 600
local CREATE_WINDOW_MAX = 3

-- Bounded server-local cache. Positive records change only by expiry, so a short cache is safe.
-- Negative cache prevents repeated invalid/missing codes from hammering GetAsync.
local POSITIVE_CACHE_TTL = 120
local NEGATIVE_CACHE_TTL = 15
local CACHE_MAX = 256

local rng = Random.new()

local request = rem:FindFirstChild("LookShareRequest")
if not request then
    request = Instance.new("RemoteFunction")
    request.Name = "LookShareRequest"
    request.Parent = rem
end

local lastByUser = {}
local inFlight = {}
local loadWindows = {}
local createWindows = {}

local shareCache = {}
local cacheOrder = {}
local cacheSerial = 0

local function cleanId(value)
    local id = tonumber(value)
    if not id or id ~= math.floor(id) or id <= 0 or id > MAX_ASSET_ID then return nil end
    return id
end

local function normalizeIds(value, limit)
    local source = value
    if typeof(value) == "table" and typeof(value.ids) == "table" then source = value.ids end
    if typeof(source) ~= "table" then return {} end
    local ids, seen = {}, {}
    for _, raw in ipairs(source) do
        local id = cleanId(raw)
        if id and not seen[id] then
            seen[id] = true
            table.insert(ids, id)
            if #ids >= (limit or MAX_ITEMS) then break end
        end
    end
    return ids
end

local function cloneIds(ids)
    local out = table.create(#ids)
    for index, id in ipairs(ids) do out[index] = id end
    return out
end

local function normalizeCode(value)
    if typeof(value) ~= "string" then return nil end
    local code = string.upper(value):gsub("%s+", "")
    if #code ~= CODE_LENGTH then return nil end
    for index = 1, #code do
        if not string.find(ALPHABET, code:sub(index,index), 1, true) then return nil end
    end
    return code
end

local function makeCode()
    local chars = table.create(CODE_LENGTH)
    for index = 1, CODE_LENGTH do
        local pick = rng:NextInteger(1, #ALPHABET)
        chars[index] = ALPHABET:sub(pick,pick)
    end
    return table.concat(chars)
end

local function keyForSaved(player)
    return "u:" .. tostring(player.UserId)
end

local function withinRollingBudget(store, userId, now, windowSeconds, maxRequests)
    local state = store[userId]
    if not state or now - state.startedAt >= windowSeconds then
        store[userId] = {startedAt = now, count = 1}
        return true
    end
    if state.count >= maxRequests then return false end
    state.count += 1
    return true
end

local function cachePut(code, result, ttl)
    cacheSerial += 1
    local serial = cacheSerial
    shareCache[code] = {
        value = result,
        expiresAt = os.clock() + ttl,
        serial = serial,
    }
    table.insert(cacheOrder, {code = code, serial = serial})

    while #cacheOrder > CACHE_MAX do
        local oldest = table.remove(cacheOrder, 1)
        local current = shareCache[oldest.code]
        if current and current.serial == oldest.serial then
            shareCache[oldest.code] = nil
        end
    end
end

local function cacheGet(code)
    local entry = shareCache[code]
    if not entry then return nil end
    if os.clock() >= entry.expiresAt then
        shareCache[code] = nil
        return nil
    end
    local value = entry.value
    if typeof(value) ~= "table" then return nil end
    local copy = {}
    for key, item in pairs(value) do
        if key == "ids" and typeof(item) == "table" then
            copy.ids = cloneIds(item)
        else
            copy[key] = item
        end
    end
    copy.cacheHit = true
    return copy
end

local function validateOwnedSavedPicks(player, submitted)
    local ok, raw = pcall(function()
        return SAVED_STORE:GetAsync(keyForSaved(player))
    end)
    if not ok then return nil, "SAVED_PICKS_READ_FAILED" end

    local allowed = {}
    for _, id in ipairs(normalizeIds(raw, 24)) do allowed[id] = true end
    local ids = normalizeIds(submitted, MAX_ITEMS)
    if #ids == 0 then return nil, "EMPTY_LOOK" end
    for _, id in ipairs(ids) do
        if not allowed[id] then return nil, "UNSAVED_ASSET" end
    end
    return ids
end

local function createShare(player, submitted)
    local ids, validationCode = validateOwnedSavedPicks(player, submitted)
    if not ids then return {ok=false, code=validationCode} end

    for _ = 1, 5 do
        local code = makeCode()
        local nonce = rng:NextInteger(1, 2147483646)
        local createdAt = os.time()
        local wrote = false
        local ok, result = pcall(function()
            return SHARE_STORE:UpdateAsync("c:" .. code, function(current)
                if current ~= nil then return current end
                wrote = true
                return {schema=1, ids=ids, createdAt=createdAt, nonce=nonce}
            end)
        end)
        if ok and wrote and typeof(result) == "table" and result.nonce == nonce then
            local response = {ok=true, code=code, count=#ids}
            cachePut(code, {ok=true, code=code, ids=cloneIds(ids), count=#ids}, POSITIVE_CACHE_TTL)
            return response
        end
    end
    return {ok=false, code="CODE_ALLOCATION_FAILED"}
end

local function loadShare(rawCode)
    local code = normalizeCode(rawCode)
    if not code then return {ok=false, code="INVALID_CODE"} end

    local cached = cacheGet(code)
    if cached then return cached end

    local ok, value = pcall(function()
        return SHARE_STORE:GetAsync("c:" .. code)
    end)
    if not ok then return {ok=false, code="DATASTORE_READ_FAILED"} end
    if typeof(value) ~= "table" then
        local miss = {ok=false, code="NOT_FOUND"}
        cachePut(code, miss, NEGATIVE_CACHE_TTL)
        return miss
    end

    local createdAt = tonumber(value.createdAt) or 0
    if createdAt <= 0 or os.time() - createdAt > MAX_AGE_SECONDS then
        local expired = {ok=false, code="EXPIRED"}
        cachePut(code, expired, NEGATIVE_CACHE_TTL)
        return expired
    end

    local ids = normalizeIds(value.ids, MAX_ITEMS)
    if #ids == 0 then
        local empty = {ok=false, code="EMPTY_LOOK"}
        cachePut(code, empty, NEGATIVE_CACHE_TTL)
        return empty
    end

    local response = {ok=true, code=code, ids=ids, count=#ids}
    cachePut(code, response, POSITIVE_CACHE_TTL)
    return response
end

request.OnServerInvoke = function(player, action, payload)
    if typeof(action) ~= "string" then return {ok=false, code="INVALID_ACTION"} end
    action = string.upper(action)
    if action ~= "CREATE" and action ~= "LOAD" then return {ok=false, code="INVALID_ACTION"} end

    local userId = player.UserId
    local state = lastByUser[userId]
    if not state then state = {}; lastByUser[userId] = state end
    local now = os.clock()
    local cooldown = action == "CREATE" and CREATE_COOLDOWN or LOAD_COOLDOWN
    if now - (state[action] or 0) < cooldown then return {ok=false, code="THROTTLED"} end

    local budgetOk
    if action == "CREATE" then
        budgetOk = withinRollingBudget(createWindows, userId, now, CREATE_WINDOW_SECONDS, CREATE_WINDOW_MAX)
    else
        budgetOk = withinRollingBudget(loadWindows, userId, now, LOAD_WINDOW_SECONDS, LOAD_WINDOW_MAX)
    end
    if not budgetOk then return {ok=false, code="RATE_LIMITED"} end

    if inFlight[userId] then return {ok=false, code="BUSY"} end
    state[action] = now
    inFlight[userId] = true

    local ok, result = pcall(function()
        if action == "CREATE" then return createShare(player, payload) end
        return loadShare(payload)
    end)
    inFlight[userId] = nil
    if not ok or typeof(result) ~= "table" then return {ok=false, code="SERVER_ERROR"} end
    return result
end

Players.PlayerRemoving:Connect(function(player)
    local userId = player.UserId
    lastByUser[userId] = nil
    inFlight[userId] = nil
    loadWindows[userId] = nil
    createWindows[userId] = nil
end)

root:SetAttribute("LookShareRevision", "V2_BUDGET_GUARDED_CACHE")
root:SetAttribute("LookShareMaxItems", MAX_ITEMS)
root:SetAttribute("LookShareCodeLength", CODE_LENGTH)
root:SetAttribute("LookShareMaxAgeDays", math.floor(MAX_AGE_SECONDS / 86400))
root:SetAttribute("LookSharePrivacy", "ASSET_IDS_AND_TIMESTAMP_ONLY_NO_USERID")
root:SetAttribute("LookSharePositiveCacheTTL", POSITIVE_CACHE_TTL)
root:SetAttribute("LookShareNegativeCacheTTL", NEGATIVE_CACHE_TTL)
root:SetAttribute("LookShareCacheMax", CACHE_MAX)
root:SetAttribute("LookShareLoadBudgetPerMinute", LOAD_WINDOW_MAX)
root:SetAttribute("LookShareCreateBudgetPer10Minutes", CREATE_WINDOW_MAX)
print("[BBYAVATAR] Look Share v2 budget-guarded cache ready")