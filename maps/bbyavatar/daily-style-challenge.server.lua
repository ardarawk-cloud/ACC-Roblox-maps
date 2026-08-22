-- BBYAVATAR daily style challenge v2.
-- Retention loop: BROWSE -> TRY ON -> SAVE, with a privacy-safe completion streak.
-- Persists only UserId-keyed coarse progress and day counters; no item IDs, search text, creator data, or PII.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local store = DataStoreService:GetDataStore("BBYAVATAR_DailyStyleChallenge_v1")
local getChallenge = rem:FindFirstChild("GetDailyStyleChallenge") or Instance.new("RemoteFunction")
getChallenge.Name = "GetDailyStyleChallenge"
getChallenge.Parent = rem
local challengeUpdated = rem:FindFirstChild("DailyStyleChallengeUpdated") or Instance.new("RemoteEvent")
challengeUpdated.Name = "DailyStyleChallengeUpdated"
challengeUpdated.Parent = rem

local trackEvent = rem:WaitForChild("TrackEvent")
local cache = {}
local loading = {}
local lastPersist = {}
local completedCount = 0

local themes = {
    {name="STREET SIGNAL", category="STREETWEAR", prompt="Build one street-ready look."},
    {name="CYBER SHIFT", category="CYBER", prompt="Try something futuristic."},
    {name="SOFT MODE", category="CUTE", prompt="Make a softer, playful look."},
    {name="ISLAND EDIT", category="BALI", prompt="Build a Bali-inspired fit."},
    {name="LUXE FRAME", category="LUXURY", prompt="Try a polished premium look."},
    {name="CREATOR RADAR", category="CREATORS", prompt="Discover a creator-led style."},
    {name="TREND CHECK", category="TRENDING", prompt="Test a look from what is hot now."},
}

local function dayNumber()
    return math.floor(os.time() / 86400)
end

local function themeFor(day)
    return themes[(day % #themes) + 1]
end

local function clampInt(value, minimum, maximum)
    value = math.floor(tonumber(value) or 0)
    return math.clamp(value, minimum, maximum)
end

local function defaultState(day)
    return {
        day=day,
        browse=false,
        tryOn=false,
        save=false,
        completed=false,
        streak=0,
        lastCompletedDay=0,
    }
end

local function sanitize(raw, day)
    local state = defaultState(day)
    if typeof(raw) ~= "table" then return state end

    state.streak = clampInt(raw.streak, 0, 3650)
    state.lastCompletedDay = clampInt(raw.lastCompletedDay, 0, 1000000)

    if tonumber(raw.day) == day then
        state.browse = raw.browse == true
        state.tryOn = raw.tryOn == true
        state.save = raw.save == true
        state.completed = raw.completed == true
    end

    -- Old v1 records have no streak metadata. Preserve completion as a one-day seed.
    if state.streak == 0 and state.lastCompletedDay == 0 and raw.completed == true and tonumber(raw.day) then
        state.streak = 1
        state.lastCompletedDay = clampInt(raw.day, 0, 1000000)
    end

    return state
end

local function publicState(state)
    local theme = themeFor(state.day)
    local progress = (state.browse and 1 or 0) + (state.tryOn and 1 or 0) + (state.save and 1 or 0)
    return {
        day=state.day,
        theme=theme.name,
        category=theme.category,
        prompt=theme.prompt,
        browse=state.browse,
        tryOn=state.tryOn,
        save=state.save,
        completed=state.completed,
        progress=progress,
        total=3,
        streak=state.streak,
    }
end

local function loadState(player)
    local day = dayNumber()
    local cached = cache[player]
    if cached and cached.day == day then return cached end

    if loading[player] then
        local started = os.clock()
        while loading[player] and os.clock() - started < 3 do task.wait(.05) end
        cached = cache[player]
        if cached and cached.day == day then return cached end
    end

    loading[player] = true
    local ok, raw = pcall(function()
        return store:GetAsync("u:" .. tostring(player.UserId))
    end)
    local state = sanitize(ok and raw or nil, day)
    cache[player] = state
    loading[player] = nil
    return state
end

local function writeSnapshot(player, snapshot)
    local ok = pcall(function()
        store:UpdateAsync("u:" .. tostring(player.UserId), function(old)
            local current = sanitize(old, snapshot.day)
            current.browse = current.browse or snapshot.browse
            current.tryOn = current.tryOn or snapshot.tryOn
            current.save = current.save or snapshot.save
            current.completed = current.completed or snapshot.completed

            if snapshot.lastCompletedDay > current.lastCompletedDay then
                current.lastCompletedDay = snapshot.lastCompletedDay
                current.streak = snapshot.streak
            elseif snapshot.lastCompletedDay == current.lastCompletedDay then
                current.streak = math.max(current.streak, snapshot.streak)
            end

            return current
        end)
    end)
    return ok
end

local function persist(player, state, force, synchronous)
    local now = os.clock()
    if not force and now - (lastPersist[player] or 0) < 1 then return false end
    lastPersist[player] = now

    local snapshot = {
        day=state.day,
        browse=state.browse,
        tryOn=state.tryOn,
        save=state.save,
        completed=state.completed,
        streak=state.streak,
        lastCompletedDay=state.lastCompletedDay,
    }

    if synchronous then
        return writeSnapshot(player, snapshot)
    end

    task.spawn(function()
        writeSnapshot(player, snapshot)
    end)
    return true
end

local function applyCompletionStreak(state)
    if state.lastCompletedDay == state.day then return end
    if state.lastCompletedDay == state.day - 1 then
        state.streak = math.min((state.streak or 0) + 1, 3650)
    else
        state.streak = 1
    end
    state.lastCompletedDay = state.day
end

local function mark(player, field)
    local state = loadState(player)
    if state[field] then return end

    state[field] = true
    local wasCompleted = state.completed
    state.completed = state.browse and state.tryOn and state.save

    if state.completed and not wasCompleted then
        applyCompletionStreak(state)
        completedCount += 1
        root:SetAttribute("Metric_DAILY_STYLE_COMPLETE", completedCount)
    end

    persist(player, state, false, false)
    challengeUpdated:FireClient(player, publicState(state))
end

trackEvent.OnServerEvent:Connect(function(player, eventName)
    if eventName == "CATALOG_OPEN" or eventName == "DETAIL_OPEN" or eventName == "DISCOVERY_CATEGORY" then
        mark(player, "browse")
    elseif eventName == "TRY_ON_SUCCESS" or eventName == "WARDROBE_PREVIEW_SUCCESS" then
        mark(player, "tryOn")
    elseif eventName == "PICK_SAVE" or eventName == "CREATE_OUTFIT_SUCCESS" or eventName == "SAVE_AVATAR_SUCCESS" then
        mark(player, "save")
    end
end)

getChallenge.OnServerInvoke = function(player)
    return publicState(loadState(player))
end

Players.PlayerRemoving:Connect(function(player)
    local state = cache[player]
    if state then persist(player, state, true, true) end
    cache[player] = nil
    loading[player] = nil
    lastPersist[player] = nil
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        local state = cache[player]
        if state then persist(player, state, true, true) end
    end
end)

root:SetAttribute("DailyStyleChallengeRevision", "V2_STREAK_SAFE_PERSIST")
root:SetAttribute("DailyStyleChallengePrivacy", "USERID_KEYED_COARSE_PROGRESS_DAY_COUNTERS_ONLY")
root:SetAttribute("Metric_DAILY_STYLE_COMPLETE", 0)
print("[BBYAVATAR] persistent daily style challenge v2 + streak ready")