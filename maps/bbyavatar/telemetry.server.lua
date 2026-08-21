-- BBYAVATAR analytics-ready foundation.
-- Session-only counters: no external endpoint, no PII persistence, no arbitrary client keys.

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
    WARDROBE_PREVIEW_SUCCESS = true,
    WARDROBE_PREVIEW_FAILED = true,
    WARDROBE_RESTORE_SUCCESS = true,
    WARDROBE_RESTORE_FAILED = true,
}

local lastEventAt = {}
local counters = {}

local function bump(key)
    counters[key] = (counters[key] or 0) + 1
    root:SetAttribute("Metric_" .. key, counters[key])
end

trackEvent.OnServerEvent:Connect(function(player, eventName)
    if typeof(eventName) ~= "string" or not ALLOWED[eventName] then return end
    local now = os.clock()
    local userId = player.UserId
    if now - (lastEventAt[userId] or 0) < 0.15 then return end
    lastEventAt[userId] = now
    bump(eventName)
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    lastEventAt[player.UserId] = nil
end)

root:SetAttribute("TelemetryRevision", "SESSION_COUNTERS_V2_TRYON_WARDROBE")
root:SetAttribute("TelemetryPrivacy", "NO_PII_NO_EXTERNAL_PERSISTENCE")
print("[BBYAVATAR] Privacy-safe session telemetry v2 ready")
