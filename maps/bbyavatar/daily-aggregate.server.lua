-- BBYAVATAR persistent daily aggregate analytics v1.
-- Stores only anonymous per-day event totals. No UserIds, item IDs, queries, creator names,
-- prices, outfit contents, or other player metadata are persisted.
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local store = DataStoreService:GetDataStore("BBYAVATAR_DailyAggregate_v1")
local trackEvent = rem:WaitForChild("TrackEvent")

local ALLOWED = {
    CATALOG_OPEN=true, DETAIL_OPEN=true, TRY_ON_SUCCESS=true, PICK_SAVE=true,
    BOARD_OPEN=true, BOARD_TRY_ALL_SUCCESS=true, OWNED_OPEN=true, OWNED_TRY=true,
    OWNED_SAVE=true, DISCOVERY_OPEN=true, RECOMMEND_OPEN=true, RECENT_CONTINUE=true,
    CHALLENGE_OPEN=true, PHOTO_OPEN=true, PHOTO_PRESET=true, PHOTO_CLEAN_VIEW=true,
    CREATE_OUTFIT_SUCCESS=true, SAVE_AVATAR_SUCCESS=true, FAVORITE_SUCCESS=true,
    PURCHASE_SUCCESS=true,
}

local THROTTLE = {
    CATALOG_OPEN=1, DETAIL_OPEN=.5, TRY_ON_SUCCESS=.75, PICK_SAVE=.5,
    BOARD_OPEN=1, BOARD_TRY_ALL_SUCCESS=.75, OWNED_OPEN=1, OWNED_TRY=.5,
    OWNED_SAVE=.5, DISCOVERY_OPEN=1, RECOMMEND_OPEN=1, RECENT_CONTINUE=1,
    CHALLENGE_OPEN=2, PHOTO_OPEN=1, PHOTO_PRESET=.5, PHOTO_CLEAN_VIEW=2,
    CREATE_OUTFIT_SUCCESS=2, SAVE_AVATAR_SUCCESS=2, FAVORITE_SUCCESS=1,
    PURCHASE_SUCCESS=2,
}

local pending = {}
local lastByPlayer = setmetatable({}, {__mode="k"})
local flushBusy = false
local FLUSH_SECONDS = 180

local function utcDay()
    return os.date("!%Y-%m-%d")
end

local function bump(name, amount)
    pending[name] = (pending[name] or 0) + (amount or 1)
end

local function snapshotPending()
    local snap = pending
    pending = {}
    return snap
end

local function restoreSnapshot(snap)
    for key, value in pairs(snap) do
        pending[key] = (pending[key] or 0) + value
    end
end

local function flush()
    if flushBusy or next(pending) == nil then return true end
    flushBusy = true
    local snap = snapshotPending()
    local day = utcDay()
    local ok, err = pcall(function()
        store:UpdateAsync("DAY_" .. day, function(current)
            current = typeof(current) == "table" and current or {}
            current.schema = 1
            current.day = day
            current.updatedAt = os.time()
            current.events = typeof(current.events) == "table" and current.events or {}
            for key, value in pairs(snap) do
                current.events[key] = (tonumber(current.events[key]) or 0) + value
            end
            return current
        end)
    end)
    if not ok then
        restoreSnapshot(snap)
        root:SetAttribute("DailyAggregateLastError", tostring(err):sub(1,120))
    else
        root:SetAttribute("DailyAggregateLastFlush", os.time())
        root:SetAttribute("DailyAggregateLastDay", day)
        root:SetAttribute("DailyAggregateLastBatchEvents", (function()
            local n=0; for _,v in pairs(snap) do n += v end; return n
        end)())
        root:SetAttribute("DailyAggregateLastError", "")
    end
    flushBusy = false
    return ok
end

local function registerSession(player)
    if not player then return end
    bump("SESSION_START")
end
Players.PlayerAdded:Connect(registerSession)
for _, player in ipairs(Players:GetPlayers()) do registerSession(player) end

trackEvent.OnServerEvent:Connect(function(player, eventName)
    if typeof(eventName) ~= "string" or not ALLOWED[eventName] then return end
    local times = lastByPlayer[player]
    if not times then times = {}; lastByPlayer[player] = times end
    local now = os.clock()
    local gap = THROTTLE[eventName] or 1
    if now - (times[eventName] or 0) < gap then return end
    times[eventName] = now
    bump(eventName)
end)

Players.PlayerRemoving:Connect(function(player)
    lastByPlayer[player] = nil
end)

task.spawn(function()
    while true do
        task.wait(FLUSH_SECONDS)
        flush()
    end
end)

game:BindToClose(function()
    flush()
end)

root:SetAttribute("DailyAggregateRevision", "V1_ANONYMOUS_DAILY_TOTALS")
root:SetAttribute("DailyAggregatePrivacy", "NO_USER_IDS_NO_ITEM_IDS_NO_QUERY_TEXT")
root:SetAttribute("DailyAggregateFlushSeconds", FLUSH_SECONDS)
print("[BBYAVATAR] Daily aggregate analytics v1 ready")
