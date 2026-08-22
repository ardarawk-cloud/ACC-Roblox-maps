-- BBYAVATAR daily style challenge v1.
-- Retention loop: BROWSE -> TRY ON -> SAVE. Persists only coarse daily progress per UserId.

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

local function defaultState(day)
    return {day=day, browse=false, tryOn=false, save=false, completed=false}
end

local function sanitize(raw, day)
    if typeof(raw) ~= "table" or tonumber(raw.day) ~= day then return defaultState(day) end
    return {
        day=day,
        browse=raw.browse == true,
        tryOn=raw.tryOn == true,
        save=raw.save == true,
        completed=raw.completed == true,
    }
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

local function persist(player, state)
    local now = os.clock()
    if now - (lastPersist[player] or 0) < 1 then return end
    lastPersist[player] = now
    local snapshot = {day=state.day, browse=state.browse, tryOn=state.tryOn, save=state.save, completed=state.completed}
    task.spawn(function()
        pcall(function()
            store:UpdateAsync("u:" .. tostring(player.UserId), function(old)
                local current = sanitize(old, snapshot.day)
                current.browse = current.browse or snapshot.browse
                current.tryOn = current.tryOn or snapshot.tryOn
                current.save = current.save or snapshot.save
                current.completed = current.completed or snapshot.completed
                return current
            end)
        end)
    end)
end

local function mark(player, field)
    local state = loadState(player)
    if state[field] then return end
    state[field] = true
    local wasCompleted = state.completed
    state.completed = state.browse and state.tryOn and state.save
    if state.completed and not wasCompleted then
        completedCount += 1
        root:SetAttribute("Metric_DAILY_STYLE_COMPLETE", completedCount)
    end
    persist(player, state)
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
    if state then persist(player, state) end
    cache[player] = nil
    loading[player] = nil
    lastPersist[player] = nil
end)

root:SetAttribute("DailyStyleChallengeRevision", "V1_BROWSE_TRY_SAVE")
root:SetAttribute("DailyStyleChallengePrivacy", "USERID_KEYED_COARSE_PROGRESS_ONLY")
root:SetAttribute("Metric_DAILY_STYLE_COMPLETE", 0)
print("[BBYAVATAR] persistent daily style challenge v1 ready")