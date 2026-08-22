-- BBYAVATAR persistent Style Board v1
-- Persists only up to six Roblox catalog asset IDs keyed by UserId.
-- No names, prices, search text, creator metadata, outfit descriptions, or external identifiers are stored.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local STORE_NAME = "BBYAVATAR_StyleBoard_v1"
local MAX_ITEMS = 6
local LOAD_COOLDOWN = 0.75
local SET_COOLDOWN = 0.75
local MAX_ASSET_ID = 9007199254740991

local store = DataStoreService:GetDataStore(STORE_NAME)
local request = rem:FindFirstChild("StyleBoardRequest")
if not request then
    request = Instance.new("RemoteFunction")
    request.Name = "StyleBoardRequest"
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
            if #ids >= MAX_ITEMS then break end
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

local function setBoard(player, rawIds)
    local userId = player.UserId
    if mutationInFlight[userId] then
        return false, cloneIds(cache[userId] or {}), "THROTTLED"
    end

    local ids = normalize(rawIds)
    mutationInFlight[userId] = true
    local committed = nil
    local ok = pcall(function()
        store:UpdateAsync(keyFor(player), function()
            committed = cloneIds(ids)
            return {schema = 1, ids = ids}
        end)
    end)
    mutationInFlight[userId] = nil

    if not ok or not committed then
        return false, cloneIds(cache[userId] or {}), "DATASTORE_WRITE_FAILED"
    end

    cache[userId] = normalize(committed)
    return true, cloneIds(cache[userId])
end

request.OnServerInvoke = function(player, action, payload)
    if typeof(action) ~= "string" or (action ~= "LOAD" and action ~= "SET") then
        return {ok = false, code = "INVALID_ACTION"}
    end

    local userId = player.UserId
    local now = os.clock()
    local byAction = lastRequestAt[userId]
    if not byAction then
        byAction = {}
        lastRequestAt[userId] = byAction
    end

    local gap = action == "LOAD" and LOAD_COOLDOWN or SET_COOLDOWN
    local last = byAction[action] or 0
    if now - last < gap then
        return {ok = false, code = "THROTTLED", ids = cloneIds(cache[userId] or {})}
    end
    byAction[action] = now

    if action == "LOAD" then
        local ids, persisted, code, cacheHit = load(player)
        return {ok = persisted, persisted = persisted, ids = ids, code = code, cacheHit = cacheHit == true}
    end

    if typeof(payload) ~= "table" then
        return {ok = false, code = "INVALID_PAYLOAD", ids = cloneIds(cache[userId] or {})}
    end

    local ok, ids, code = setBoard(player, payload)
    return {ok = ok, persisted = ok, ids = ids or {}, code = code}
end

Players.PlayerRemoving:Connect(function(player)
    local userId = player.UserId
    cache[userId] = nil
    lastRequestAt[userId] = nil
    mutationInFlight[userId] = nil
end)

root:SetAttribute("StyleBoardPersistence", "DATASTORE_V1")
root:SetAttribute("StyleBoardPersistMax", MAX_ITEMS)
root:SetAttribute("StyleBoardPrivacy", "USERID_KEY_PLUS_ASSET_IDS_ONLY")
root:SetAttribute("StyleBoardMutationGuard", true)
print("[BBYAVATAR] Persistent Style Board v1 ready")