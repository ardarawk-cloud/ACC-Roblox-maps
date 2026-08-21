-- BBYAVATAR analytics-ready foundation v9.
-- Privacy posture: aggregate session counters only; no external endpoint, no PII persistence,
-- no arbitrary client event names, and no per-user metrics exposed as attributes.
-- v9 adds recommendation cache efficiency tracking while preserving server authority and throttles.

local Players = game:GetService("Players")

local trackEvent = rem:FindFirstChild("TrackEvent")
if not trackEvent then
    trackEvent = Instance.new("RemoteEvent")
    trackEvent.Name = "TrackEvent"
    trackEvent.Parent = rem
end

local ALLOWED = {
    CATALOG_OPEN = true,
    SAVE_AVATAR_SUCCESS = true,
    SAVE_AVATAR_DENIED = true,
    SAVE_AVATAR_FAILED = true,
    CREATE_OUTFIT_SUCCESS = true,
    CREATE_OUTFIT_DENIED = true,
    CREATE_OUTFIT_FAILED = true,
    FAVORITE_SUCCESS = true,
    FAVORITE_DENIED = true,
    FAVORITE_FAILED = true,
    PURCHASE_SUCCESS = true,
    PURCHASE_CANCELLED = true,
    TRY_ON_SUCCESS = true,
    TRY_ON_FAILED = true,
    PICK_SAVE = true,
    PICK_REMOVE = true,
    PICKS_OPEN = true,
    PICK_CLOUD_LOAD = true,
    WARDROBE_PREVIEW_SUCCESS = true,
    WARDROBE_PREVIEW_FAILED = true,
    WARDROBE_RESTORE_SUCCESS = true,
    WARDROBE_RESTORE_FAILED = true,
    DISCOVERY_OPEN = true,
    DISCOVERY_CATEGORY = true,
    RECOMMEND_OPEN = true,
    RECOMMEND_RESULT = true,
    RECOMMEND_FAILED = true,
    RECOMMEND_CACHE_HIT = true,
}

local THROTTLE = {
    CATALOG_OPEN = 1.0,
    TRY_ON_SUCCESS = 0.75,
    TRY_ON_FAILED = 0.75,
    PICK_SAVE = 0.5,
    PICK_REMOVE = 0.5,
    PICKS_OPEN = 1.0,
    PICK_CLOUD_LOAD = 5.0,
    DISCOVERY_OPEN = 1.0,
    DISCOVERY_CATEGORY = 0.75,
    RECOMMEND_OPEN = 1.0,
    RECOMMEND_RESULT = 1.0,
    RECOMMEND_FAILED = 1.0,
    RECOMMEND_CACHE_HIT = 1.0,
    FAVORITE_SUCCESS = 1.0,
    FAVORITE_DENIED = 1.0,
    FAVORITE_FAILED = 1.0,
    PURCHASE_SUCCESS = 2.0,
    PURCHASE_CANCELLED = 1.0,
    CREATE_OUTFIT_SUCCESS = 2.0,
    CREATE_OUTFIT_DENIED = 2.0,
    CREATE_OUTFIT_FAILED = 2.0,
    SAVE_AVATAR_SUCCESS = 2.0,
    SAVE_AVATAR_DENIED = 2.0,
    SAVE_AVATAR_FAILED = 2.0,
    WARDROBE_PREVIEW_SUCCESS = 0.75,
    WARDROBE_PREVIEW_FAILED = 0.75,
    WARDROBE_RESTORE_SUCCESS = 1.0,
    WARDROBE_RESTORE_FAILED = 1.0,
}

local DEFAULT_THROTTLE_SECONDS = 0.75
local lastEventAt = {}
local counters = {}
local countedSessions = {}

local function metric(key)
    return counters[key] or 0
end

local function safeRate(numerator, denominator)
    if denominator <= 0 then return 0 end
    return math.floor((numerator / denominator) * 1000 + 0.5) / 10
end

local function refreshDerivedMetrics()
    local sessions = metric("SESSION_START")
    local opens = metric("CATALOG_OPEN")
    local tries = metric("TRY_ON_SUCCESS")
    local picks = metric("PICK_SAVE")
    local restoredPickSessions = metric("PICK_CLOUD_LOAD")
    local favorites = metric("FAVORITE_SUCCESS")
    local outfitSaves = metric("CREATE_OUTFIT_SUCCESS") + metric("SAVE_AVATAR_SUCCESS")
    local purchases = metric("PURCHASE_SUCCESS")
    local recommendationOpens = metric("RECOMMEND_OPEN")
    local recommendationResults = metric("RECOMMEND_RESULT")
    local recommendationCacheHits = metric("RECOMMEND_CACHE_HIT")
    local recommendationServed = recommendationResults + recommendationCacheHits

    root:SetAttribute("Funnel_OpenPerSessionPct", safeRate(opens, sessions))
    root:SetAttribute("Funnel_TryOnPerOpenPct", safeRate(tries, opens))
    root:SetAttribute("Funnel_PickPerOpenPct", safeRate(picks, opens))
    root:SetAttribute("Funnel_PickCloudLoadPerSessionPct", safeRate(restoredPickSessions, sessions))
    root:SetAttribute("Funnel_FavoritePerOpenPct", safeRate(favorites, opens))
    root:SetAttribute("Funnel_SavePerTryOnPct", safeRate(outfitSaves, tries))
    root:SetAttribute("Funnel_PurchasePerOpenPct", safeRate(purchases, opens))
    root:SetAttribute("Funnel_PurchasePerTryOnPct", safeRate(purchases, tries))
    root:SetAttribute("Funnel_RecommendPerPickPct", safeRate(recommendationOpens, picks))
    root:SetAttribute("Funnel_RecommendResultPct", safeRate(recommendationServed, recommendationOpens))
    root:SetAttribute("Funnel_RecommendCacheHitPct", safeRate(recommendationCacheHits, recommendationServed))
end

local function bump(key)
    counters[key] = (counters[key] or 0) + 1
    root:SetAttribute("Metric_" .. key, counters[key])
    refreshDerivedMetrics()
end

local function registerSession(player)
    if not player or countedSessions[player] then return end
    countedSessions[player] = true
    bump("SESSION_START")
end

Players.PlayerAdded:Connect(registerSession)
for _, player in ipairs(Players:GetPlayers()) do
    registerSession(player)
end

trackEvent.OnServerEvent:Connect(function(player, eventName)
    if typeof(eventName) ~= "string" or not ALLOWED[eventName] then return end

    local userId = player.UserId
    local playerTimes = lastEventAt[userId]
    if not playerTimes then
        playerTimes = {}
        lastEventAt[userId] = playerTimes
    end

    local now = os.clock()
    local minimumGap = THROTTLE[eventName] or DEFAULT_THROTTLE_SECONDS
    if now - (playerTimes[eventName] or 0) < minimumGap then return end
    playerTimes[eventName] = now
    bump(eventName)
end)

Players.PlayerRemoving:Connect(function(player)
    lastEventAt[player.UserId] = nil
    countedSessions[player] = nil
end)

root:SetAttribute("TelemetryRevision", "SESSION_COUNTERS_V9_RECOMMEND_CACHE")
root:SetAttribute("TelemetryPrivacy", "NO_PII_NO_EXTERNAL_PERSISTENCE")
root:SetAttribute("TelemetryThrottle", "EVENT_SPECIFIC_PER_USER")
root:SetAttribute("TelemetrySessionAuthority", "SERVER")
root:SetAttribute("TelemetrySchema", 9)
refreshDerivedMetrics()
print("[BBYAVATAR] Privacy-safe telemetry v9 recommendation cache metrics ready")