-- BBYAVATAR Photo Studio analytics v1.
-- Anonymous in-server counters only. No capture content, asset IDs, UserIds, filenames,
-- gallery state, device identifiers, or external telemetry are persisted.

local trackEvent = rem:WaitForChild("TrackEvent")

local ALLOWED = {
    PHOTO_OPEN=true,
    PHOTO_CAPTURE_REQUEST=true,
    PHOTO_CAPTURE_SUCCESS=true,
    PHOTO_CAPTURE_FAILED=true,
    PHOTO_SAVE_ACCEPTED=true,
    PHOTO_SAVE_DENIED=true,
    PHOTO_SHARE_ACCEPTED=true,
    PHOTO_SHARE_DENIED=true,
}

local THROTTLE = {
    PHOTO_OPEN=1,
    PHOTO_CAPTURE_REQUEST=1.5,
    PHOTO_CAPTURE_SUCCESS=1.5,
    PHOTO_CAPTURE_FAILED=1.5,
    PHOTO_SAVE_ACCEPTED=2,
    PHOTO_SAVE_DENIED=2,
    PHOTO_SHARE_ACCEPTED=2,
    PHOTO_SHARE_DENIED=2,
}

local counters = {}
local lastByPlayer = setmetatable({}, {__mode="k"})

local function metric(name)
    return counters[name] or 0
end

local function rate(numerator, denominator)
    if denominator <= 0 then return 0 end
    return math.floor((numerator / denominator) * 1000 + .5) / 10
end

local function refresh()
    local requested = metric("PHOTO_CAPTURE_REQUEST")
    local captured = metric("PHOTO_CAPTURE_SUCCESS")
    local saveDecisions = metric("PHOTO_SAVE_ACCEPTED") + metric("PHOTO_SAVE_DENIED")
    local shareDecisions = metric("PHOTO_SHARE_ACCEPTED") + metric("PHOTO_SHARE_DENIED")

    root:SetAttribute("PhotoHealth_CaptureSuccessPct", rate(captured, requested))
    root:SetAttribute("PhotoConv_SaveAcceptedPct", rate(metric("PHOTO_SAVE_ACCEPTED"), saveDecisions))
    root:SetAttribute("PhotoConv_ShareAcceptedPct", rate(metric("PHOTO_SHARE_ACCEPTED"), shareDecisions))
    root:SetAttribute("PhotoMetric_Open", metric("PHOTO_OPEN"))
    root:SetAttribute("PhotoMetric_CaptureRequest", requested)
    root:SetAttribute("PhotoMetric_CaptureSuccess", captured)
    root:SetAttribute("PhotoMetric_CaptureFailed", metric("PHOTO_CAPTURE_FAILED"))
end

trackEvent.OnServerEvent:Connect(function(player, eventName)
    if typeof(eventName) ~= "string" or not ALLOWED[eventName] then return end

    local times = lastByPlayer[player]
    if not times then
        times = {}
        lastByPlayer[player] = times
    end

    local now = os.clock()
    local minimumGap = THROTTLE[eventName] or 1
    if now - (times[eventName] or 0) < minimumGap then return end
    times[eventName] = now

    counters[eventName] = (counters[eventName] or 0) + 1
    refresh()
end)

root:SetAttribute("PhotoAnalyticsRevision", "V1_NATIVE_CAPTURE")
root:SetAttribute("PhotoAnalyticsPrivacy", "NO_CAPTURE_CONTENT_NO_PII_NO_EXTERNAL_PERSISTENCE")
refresh()
print("[BBYAVATAR] Photo analytics v1 native-capture funnel ready")
