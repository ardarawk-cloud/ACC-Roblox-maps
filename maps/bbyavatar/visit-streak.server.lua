-- BBYAVATAR daily Style Streak v1.
-- Server-authoritative return streak with no rewards, economy value, or client-controlled progress.
-- Persistence is intentionally minimal: UTC day index + current/best streak + distinct visit-day count,
-- keyed only by Roblox UserId. No item history, search terms, chat, creator data, or external IDs.

local visitStreakStore = DataStoreService:GetDataStore("BBYAVATAR_VisitStreak_v1")
local VISIT_STREAK_RETRY_SECONDS = 8
local VISIT_STREAK_MAX_ATTEMPTS = 2

local visitStreakCache = {}

local function utcDayIndex()
    return math.floor(os.time() / 86400)
end

local function sanitizeStreakState(value)
    local day = 0
    local streak = 0
    local best = 0
    local visits = 0
    if typeof(value) == "table" then
        day = math.max(0, math.floor(tonumber(value.day) or 0))
        streak = math.clamp(math.floor(tonumber(value.streak) or 0), 0, 100000)
        best = math.clamp(math.floor(tonumber(value.best) or 0), 0, 100000)
        visits = math.clamp(math.floor(tonumber(value.visits) or 0), 0, 1000000)
    end
    if best < streak then best = streak end
    return {schema = 1, day = day, streak = streak, best = best, visits = visits}
end

local function applyVisitForDay(current, today)
    local state = sanitizeStreakState(current)
    if state.day == today then return state end

    if state.day == today - 1 then
        state.streak = math.max(1, state.streak + 1)
    else
        state.streak = 1
    end
    state.day = today
    state.best = math.max(state.best, state.streak)
    state.visits += 1
    return state
end

local function publishVisitState(player, state, persisted)
    if not player or player.Parent ~= Players then return end
    local clean = sanitizeStreakState(state)
    visitStreakCache[player.UserId] = clean
    player:SetAttribute("BBYAVATAR_VisitStreak", clean.streak)
    player:SetAttribute("BBYAVATAR_BestStreak", clean.best)
    player:SetAttribute("BBYAVATAR_DistinctVisitDays", clean.visits)
    player:SetAttribute("BBYAVATAR_VisitStreakPersisted", persisted == true)
end

local function recordVisit(player, attempt)
    if not player or player.Parent ~= Players then return end
    attempt = attempt or 1
    local today = utcDayIndex()
    local updatedState
    local ok = pcall(function()
        updatedState = visitStreakStore:UpdateAsync("u:" .. tostring(player.UserId), function(current)
            return applyVisitForDay(current, today)
        end)
    end)

    if ok and typeof(updatedState) == "table" then
        publishVisitState(player, updatedState, true)
        return
    end

    -- A failed UpdateAsync response can be ambiguous. Retrying the same UTC-day transform is
    -- idempotent because an already-written day does not increment again.
    if attempt < VISIT_STREAK_MAX_ATTEMPTS then
        task.delay(VISIT_STREAK_RETRY_SECONDS, function()
            recordVisit(player, attempt + 1)
        end)
        return
    end

    -- Fail soft: catalog/try-on remains usable and no unverified streak number is presented.
    local fallback = visitStreakCache[player.UserId] or {schema = 1, day = today, streak = 0, best = 0, visits = 0}
    publishVisitState(player, fallback, false)
end

Players.PlayerAdded:Connect(function(player)
    task.spawn(recordVisit, player, 1)
end)
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(recordVisit, player, 1)
end

Players.PlayerRemoving:Connect(function(player)
    visitStreakCache[player.UserId] = nil
end)

root:SetAttribute("VisitStreakRevision", "UTC_DAY_DATASTORE_V1")
root:SetAttribute("VisitStreakAuthority", "SERVER_JOIN_ONLY")
root:SetAttribute("VisitStreakPrivacy", "USERID_KEY_DAY_STREAK_BEST_VISITCOUNT_ONLY")
root:SetAttribute("VisitStreakRewardValue", "NONE")
print("[BBYAVATAR] Privacy-minimal daily Style Streak v1 ready")