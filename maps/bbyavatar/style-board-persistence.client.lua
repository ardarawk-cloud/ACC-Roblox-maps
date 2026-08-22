-- BBYAVATAR Style Board Persistence v1
-- Restores the six-item Style Board across sessions using only Roblox catalog asset IDs.
-- Sync is debounced and server-authoritative; transient failures never erase the active session board.

local styleBoardRequest = root:WaitForChild("StyleBoardRequest", 8)
local boardPersistenceReady = false
local boardSyncInFlight = false
local lastPersistedSignature = nil
local pendingSignature = nil
local pendingSince = 0

local function persistedBoardIds()
    local ids = {}
    for _, id in ipairs(savedPickOrder) do
        if styleBoard[id] then
            table.insert(ids, id)
            if #ids >= STYLE_BOARD_MAX then break end
        end
    end
    -- Preserve restored IDs that may not have hydrated Saved Pick metadata yet.
    if #ids < STYLE_BOARD_MAX then
        for id in pairs(styleBoard) do
            local found = false
            for _, existing in ipairs(ids) do if existing == id then found = true break end end
            if not found then
                table.insert(ids, id)
                if #ids >= STYLE_BOARD_MAX then break end
            end
        end
    end
    table.sort(ids)
    return ids
end

local function persistenceSignature(ids)
    local parts = {}
    for _, id in ipairs(ids) do table.insert(parts, tostring(id)) end
    return table.concat(parts, ":")
end

local function currentPersistenceSignature()
    return persistenceSignature(persistedBoardIds())
end

local function applyRestoredBoard(ids)
    styleBoard = {}
    if typeof(ids) == "table" then
        local count = 0
        for _, raw in ipairs(ids) do
            local id = tonumber(raw)
            if id and id > 0 and id == math.floor(id) and not styleBoard[id] then
                styleBoard[id] = true
                count += 1
                if count >= STYLE_BOARD_MAX then break end
            end
        end
    end
end

local function loadPersistentBoard()
    if not styleBoardRequest or not styleBoardRequest:IsA("RemoteFunction") then
        boardPersistenceReady = true
        lastPersistedSignature = currentPersistenceSignature()
        return
    end

    local ok, response = pcall(function()
        return styleBoardRequest:InvokeServer("LOAD")
    end)
    if ok and typeof(response) == "table" and response.ok and typeof(response.ids) == "table" then
        applyRestoredBoard(response.ids)
        lastPersistedSignature = currentPersistenceSignature()
        status.Text = #response.ids > 0 and "Style Board restored from your last session." or status.Text
        if activeTab == "BOARD" then renderStyleBoard() end
    else
        -- Session-local board remains fully usable when DataStore is unavailable.
        lastPersistedSignature = currentPersistenceSignature()
    end
    boardPersistenceReady = true
end

local function syncPersistentBoard()
    if not boardPersistenceReady or boardSyncInFlight or not styleBoardRequest then return end
    local ids = persistedBoardIds()
    local signature = persistenceSignature(ids)
    if signature == lastPersistedSignature then return end

    boardSyncInFlight = true
    local ok, response = pcall(function()
        return styleBoardRequest:InvokeServer("SET", ids)
    end)
    boardSyncInFlight = false

    if ok and typeof(response) == "table" and response.ok then
        lastPersistedSignature = signature
        pendingSignature = nil
    elseif ok and typeof(response) == "table" and response.code == "THROTTLED" then
        pendingSignature = signature
        pendingSince = os.clock()
    else
        -- Keep the session state and retry after another change/debounce window.
        pendingSignature = signature
        pendingSince = os.clock()
    end
end

task.spawn(function()
    -- Saved Picks may still be hydrating; restoring IDs does not depend on item metadata.
    task.wait(0.35)
    loadPersistentBoard()

    while gui.Parent do
        local signature = currentPersistenceSignature()
        if boardPersistenceReady and signature ~= lastPersistedSignature then
            if pendingSignature ~= signature then
                pendingSignature = signature
                pendingSince = os.clock()
            elseif os.clock() - pendingSince >= 0.9 then
                syncPersistentBoard()
            end
        end
        task.wait(0.25)
    end
end)

print("[BBYAVATAR] Style Board Persistence v1 restore + debounced sync ready")