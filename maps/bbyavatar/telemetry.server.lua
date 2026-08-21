-- BBYAVATAR analytics-ready foundation v6.
-- Privacy posture: aggregate session counters only; no external endpoint, no PII persistence,
-- no arbitrary client event names, and no per-user metrics exposed as attributes.

local trackEvent = rem:FindFirstChild("TrackEvent")
if not trackEvent then
    trackEvent = Instance.new("RemoteEvent")
    trackEvent.Name = "TrackEvent"
    trackEvent.Parent = rem
end

local ALLOWED = {
    SESSION_START = true,
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
}

-- Per-player, per-event throttling avoids a noisy event suppressing an unrelated funnel event
-- that happens in the same frame (for example TRY_ON_SUCCESS followed by PICK_SAVE).
local lastEventAt = {}
local counters = {}
local THROTTLE_SECONDS = 0.12

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

    root:SetAttribute("Funnel_OpenPerSessionPct", safeRate(opens, sessions))
    root:SetAttribute("Funnel_TryOnPerOpenPct", safeRate(tries, opens))
    root:SetAttribute("Funnel_PickPerOpenPct", safeRate(picks, opens))
    root:SetAttribute("Funnel_PickCloudLoadPerSessionPct", safeRate(restoredPickSessions, sessions))
    root:SetAttribute("Funnel_FavoritePerOpenPct", safeRate(favorites, opens))
    root:SetAttribute("Funnel_SavePerTryOnPct", safeRate(outfitSaves, tries))
    root:SetAttribute("Funnel_PurchasePerOpenPct", safeRate(purchases, opens))
    root:SetAttribute("Funnel_PurchasePerTryOnPct", safeRate(purchases, tries))
end

local function bump(key)
    counters[key] = (counters[key] or 0) + 1
    root:SetAttribute("Metric_" .. key, counters[key])
    refreshDerivedMetrics()
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
    if now - (playerTimes[eventName] or 0) < THROTTLE_SECONDS then return end
    playerTimes[eventName] = now
    bump(eventName)
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    lastEventAt[player.UserId] = nil
end)

-- Stable schema markers make production receipts/audits able to distinguish telemetry revisions.
root:SetAttribute("TelemetryRevision", "SESSION_COUNTERS_V6_PERSISTED_PICKS_FUNNEL")
root:SetAttribute("TelemetryPrivacy", "NO_PII_NO_EXTERNAL_PERSISTENCE")
root:SetAttribute("TelemetryThrottle", "PER_USER_PER_EVENT")
root:SetAttribute("TelemetrySchema", 6)
refreshDerivedMetrics()
print("[BBYAVATAR] Privacy-safe telemetry v6 + persisted-picks funnel ready")