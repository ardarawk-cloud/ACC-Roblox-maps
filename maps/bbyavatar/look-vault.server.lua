-- BBYAVATAR Look Vault v1
-- Three fixed persistent look slots, each storing only Roblox catalog asset IDs.
-- No names, prices, creator metadata, search text, outfit descriptions, or external identifiers.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local STORE_NAME = "BBYAVATAR_LookVault_v1"
local SLOT_COUNT = 3
local MAX_ITEMS = 6
local REQUEST_COOLDOWN = 0.75
local MAX_ASSET_ID = 9007199254740991

local store = DataStoreService:GetDataStore(STORE_NAME)
local request = rem:FindFirstChild("LookVaultRequest")
if not request then
    request = Instance.new("RemoteFunction")
    request.Name = "LookVaultRequest"
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

local function normalizeIds(value)
    if typeof(value) ~= "table" then return {} end
    local ids, seen = {}, {}
    for _, raw in ipairs(value) do
        local id = cleanId(raw)
        if id and not seen[id] then
            seen[id] = true
            table.insert(ids, id)
            if #ids >= MAX_ITEMS then break end
        end
    end
    return ids
end

local function normalizeVault(value)
    local slots = {{}, {}, {}}
    local source = typeof(value) == "table" and value.slots or nil
    if typeof(source) == "table" then
        for index = 1, SLOT_COUNT do slots[index] = normalizeIds(source[index]) end
    end
    return slots
end

local function cloneSlots(slots)
    local out = {{}, {}, {}}
    for index = 1, SLOT_COUNT do
        local source = slots[index] or {}
        for _, id in ipairs(source) do table.insert(out[index], id) end
    end
    return out
end

local function keyFor(player)
    return "u:" .. tostring(player.UserId)
end

local function loadVault(player)
    local existing = cache[player.UserId]
    if existing then return cloneSlots(existing), true, nil, true end

    local ok, value = pcall(function()
        return store:GetAsync(keyFor(player))
    end)
    if not ok then return {{}, {}, {}}, false, "DATASTORE_READ_FAILED", false end

    local slots = normalizeVault(value)
    cache[player.UserId] = slots
    return cloneSlots(slots), true, nil, false
end

local function saveSlot(player, slotIndex, rawIds)
    local userId = player.UserId
    if mutationInFlight[userId] then return false, nil, "THROTTLED" end
    if slotIndex < 1 or slotIndex > SLOT_COUNT then return false, nil, "INVALID_SLOT" end

    local ids = normalizeIds(rawIds)
    mutationInFlight[userId] = true
    local committed
    local ok = pcall(function()
        store:UpdateAsync(keyFor(player), function(old)
            local slots = normalizeVault(old)
            slots[slotIndex] = ids
            committed = cloneSlots(slots)
            return {schema = 1, slots = slots}
        end)
    end)
    mutationInFlight[userId] = nil

    if not ok or not committed then return false, nil, "DATASTORE_WRITE_FAILED" end
    cache[userId] = normalizeVault({slots = committed})
    return true, cloneSlots(cache[userId]), nil
end

request.OnServerInvoke = function(player, action, payload)
    if typeof(action) ~= "string" or (action ~= "LOAD" and action ~= "SAVE_SLOT") then
        return {ok = false, code = "INVALID_ACTION"}
    end

    local userId = player.UserId
    local now = os.clock()
    if now - (lastRequestAt[userId] or 0) < REQUEST_COOLDOWN then
        return {ok = false, code = "THROTTLED", slots = cloneSlots(cache[userId] or {{}, {}, {}})}
    end
    lastRequestAt[userId] = now

    if action == "LOAD" then
        local slots, persisted, code, cacheHit = loadVault(player)
        return {ok = persisted, persisted = persisted, slots = slots, code = code, cacheHit = cacheHit == true}
    end

    if typeof(payload) ~= "table" then return {ok = false, code = "INVALID_PAYLOAD"} end
    local slotIndex = tonumber(payload.slot)
    if not slotIndex or slotIndex ~= math.floor(slotIndex) then return {ok = false, code = "INVALID_SLOT"} end
    local ok, slots, code = saveSlot(player, slotIndex, payload.ids)
    return {ok = ok, persisted = ok, slots = slots or cloneSlots(cache[userId] or {{}, {}, {}}), code = code}
end

Players.PlayerRemoving:Connect(function(player)
    cache[player.UserId] = nil
    lastRequestAt[player.UserId] = nil
    mutationInFlight[player.UserId] = nil
end)

root:SetAttribute("LookVaultRevision", "THREE_FIXED_SLOTS_V1")
root:SetAttribute("LookVaultSlotCount", SLOT_COUNT)
root:SetAttribute("LookVaultMaxItemsPerSlot", MAX_ITEMS)
root:SetAttribute("LookVaultPrivacy", "USERID_KEY_PLUS_ASSET_IDS_ONLY")
print("[BBYAVATAR] Look Vault v1 three privacy-minimal slots ready")