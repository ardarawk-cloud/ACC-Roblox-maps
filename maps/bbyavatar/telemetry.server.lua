-- BBYAVATAR analytics-ready foundation v13.
-- Aggregate counters only: no external endpoint, no persistent user identifiers, and
-- no arbitrary client event names. v13 adds Recently Viewed / Continue Viewing funnel
-- coverage so the return-browsing loop can be measured without persisting analytics identity.

local Players = game:GetService("Players")

local trackEvent = rem:FindFirstChild("TrackEvent")
if not trackEvent then
    trackEvent = Instance.new("RemoteEvent")
    trackEvent.Name = "TrackEvent"
    trackEvent.Parent = rem
end

local ALLOWED = {
    CATALOG_OPEN=true, SAVE_AVATAR_SUCCESS=true, SAVE_AVATAR_DENIED=true, SAVE_AVATAR_FAILED=true,
    CREATE_OUTFIT_SUCCESS=true, CREATE_OUTFIT_DENIED=true, CREATE_OUTFIT_FAILED=true,
    FAVORITE_SUCCESS=true, FAVORITE_DENIED=true, FAVORITE_FAILED=true,
    PURCHASE_SUCCESS=true, PURCHASE_CANCELLED=true, TRY_ON_SUCCESS=true, TRY_ON_FAILED=true,
    PICK_SAVE=true, PICK_REMOVE=true, PICKS_OPEN=true, PICK_CLOUD_LOAD=true,
    WARDROBE_PREVIEW_SUCCESS=true, WARDROBE_PREVIEW_FAILED=true,
    WARDROBE_RESTORE_SUCCESS=true, WARDROBE_RESTORE_FAILED=true,
    DISCOVERY_OPEN=true, DISCOVERY_CATEGORY=true,
    RECOMMEND_OPEN=true, RECOMMEND_RESULT=true, RECOMMEND_FAILED=true,
    RECOMMEND_CACHE_HIT=true, RECOMMEND_JOIN_WAIT=true, RECOMMEND_JOINED=true, RECOMMEND_COOLDOWN=true,
    DETAIL_OPEN=true, DETAIL_RESULT=true, DETAIL_FAILED=true, DETAIL_CACHE_HIT=true,
    RECENT_OPEN=true, RECENT_RESULT=true, RECENT_TOUCH=true, RECENT_CLEAR=true, RECENT_CONTINUE=true,
}

local THROTTLE = {
    CATALOG_OPEN=1.0, TRY_ON_SUCCESS=.75, TRY_ON_FAILED=.75,
    PICK_SAVE=.5, PICK_REMOVE=.5, PICKS_OPEN=1.0, PICK_CLOUD_LOAD=5.0,
    DISCOVERY_OPEN=1.0, DISCOVERY_CATEGORY=.75,
    RECOMMEND_OPEN=1.0, RECOMMEND_RESULT=1.0, RECOMMEND_FAILED=1.0,
    RECOMMEND_CACHE_HIT=1.0, RECOMMEND_JOIN_WAIT=1.0, RECOMMEND_JOINED=1.0, RECOMMEND_COOLDOWN=2.0,
    DETAIL_OPEN=.5, DETAIL_RESULT=.5, DETAIL_FAILED=1.0, DETAIL_CACHE_HIT=.5,
    RECENT_OPEN=1.0, RECENT_RESULT=1.0, RECENT_TOUCH=.5, RECENT_CLEAR=2.0, RECENT_CONTINUE=1.0,
    FAVORITE_SUCCESS=1.0, FAVORITE_DENIED=1.0, FAVORITE_FAILED=1.0,
    PURCHASE_SUCCESS=2.0, PURCHASE_CANCELLED=1.0,
    CREATE_OUTFIT_SUCCESS=2.0, CREATE_OUTFIT_DENIED=2.0, CREATE_OUTFIT_FAILED=2.0,
    SAVE_AVATAR_SUCCESS=2.0, SAVE_AVATAR_DENIED=2.0, SAVE_AVATAR_FAILED=2.0,
    WARDROBE_PREVIEW_SUCCESS=.75, WARDROBE_PREVIEW_FAILED=.75,
    WARDROBE_RESTORE_SUCCESS=1.0, WARDROBE_RESTORE_FAILED=1.0,
}

-- First occurrence of these milestones is counted once per live player session.
-- The table lives only in server memory and is deleted on PlayerRemoving.
local SESSION_MILESTONES = {
    CATALOG_OPEN="OPEN",
    DETAIL_OPEN="DETAIL",
    TRY_ON_SUCCESS="TRY_ON",
    PICK_SAVE="PICK",
    FAVORITE_SUCCESS="FAVORITE",
    CREATE_OUTFIT_SUCCESS="SAVE",
    SAVE_AVATAR_SUCCESS="SAVE",
    RECOMMEND_OPEN="RECOMMEND",
    RECENT_OPEN="RECENT",
    RECENT_CONTINUE="CONTINUE",
    PURCHASE_SUCCESS="PURCHASE",
}

local DEFAULT_THROTTLE_SECONDS=.75
local lastEventAt={}
local counters={}
local countedSessions={}
local sessionMilestones={}

local function metric(key) return counters[key] or 0 end
local function safeRate(numerator, denominator)
    if denominator <= 0 then return 0 end
    return math.floor((numerator / denominator) * 1000 + .5) / 10
end

local function refreshDerivedMetrics()
    local sessions=metric("SESSION_START")
    local opens=metric("CATALOG_OPEN")
    local tries=metric("TRY_ON_SUCCESS")
    local picks=metric("PICK_SAVE")
    local favorites=metric("FAVORITE_SUCCESS")
    local saves=metric("CREATE_OUTFIT_SUCCESS")+metric("SAVE_AVATAR_SUCCESS")
    local purchases=metric("PURCHASE_SUCCESS")
    local recommendOpen=metric("RECOMMEND_OPEN")
    local recommendServed=metric("RECOMMEND_RESULT")+metric("RECOMMEND_CACHE_HIT")+metric("RECOMMEND_JOINED")
    local detailOpen=metric("DETAIL_OPEN")
    local detailServed=metric("DETAIL_RESULT")+metric("DETAIL_CACHE_HIT")
    local recentOpen=metric("RECENT_OPEN")
    local recentServed=metric("RECENT_RESULT")

    -- Activity intensity metrics may legitimately exceed 100 because a session can act repeatedly.
    root:SetAttribute("Activity_OpenPerSession", safeRate(opens,sessions))
    root:SetAttribute("Activity_DetailPerOpenPct", safeRate(detailOpen,opens))
    root:SetAttribute("Activity_TryOnPerOpenPct", safeRate(tries,opens))
    root:SetAttribute("Activity_PickPerOpenPct", safeRate(picks,opens))
    root:SetAttribute("Activity_FavoritePerOpenPct", safeRate(favorites,opens))
    root:SetAttribute("Activity_SavePerTryOnPct", safeRate(saves,tries))
    root:SetAttribute("Activity_PurchasePerTryOnPct", safeRate(purchases,tries))
    root:SetAttribute("Activity_RecentContinuePerRecentOpenPct", safeRate(metric("RECENT_CONTINUE"),recentOpen))
    root:SetAttribute("Health_RecommendServedPct", safeRate(recommendServed,recommendOpen))
    root:SetAttribute("Health_DetailServedPct", safeRate(detailServed,detailOpen))
    root:SetAttribute("Health_RecentServedPct", safeRate(recentServed,recentOpen))
    root:SetAttribute("Health_RecommendCacheHitPct", safeRate(metric("RECOMMEND_CACHE_HIT"),recommendServed))
    root:SetAttribute("Health_DetailCacheHitPct", safeRate(metric("DETAIL_CACHE_HIT"),detailServed))

    -- True session conversion: every milestone contributes at most once per session, capped by design.
    root:SetAttribute("SessionConv_OpenPct", safeRate(metric("SESSION_UNIQUE_OPEN"),sessions))
    root:SetAttribute("SessionConv_DetailPct", safeRate(metric("SESSION_UNIQUE_DETAIL"),sessions))
    root:SetAttribute("SessionConv_TryOnPct", safeRate(metric("SESSION_UNIQUE_TRY_ON"),sessions))
    root:SetAttribute("SessionConv_PickPct", safeRate(metric("SESSION_UNIQUE_PICK"),sessions))
    root:SetAttribute("SessionConv_FavoritePct", safeRate(metric("SESSION_UNIQUE_FAVORITE"),sessions))
    root:SetAttribute("SessionConv_SavePct", safeRate(metric("SESSION_UNIQUE_SAVE"),sessions))
    root:SetAttribute("SessionConv_RecommendPct", safeRate(metric("SESSION_UNIQUE_RECOMMEND"),sessions))
    root:SetAttribute("SessionConv_RecentPct", safeRate(metric("SESSION_UNIQUE_RECENT"),sessions))
    root:SetAttribute("SessionConv_ContinuePct", safeRate(metric("SESSION_UNIQUE_CONTINUE"),sessions))
    root:SetAttribute("SessionConv_PurchasePct", safeRate(metric("SESSION_UNIQUE_PURCHASE"),sessions))
end

local function bump(key, deferRefresh)
    counters[key]=(counters[key] or 0)+1
    root:SetAttribute("Metric_"..key,counters[key])
    if not deferRefresh then refreshDerivedMetrics() end
end

local function registerSession(player)
    if not player or countedSessions[player] then return end
    countedSessions[player]=true
    sessionMilestones[player]={}
    bump("SESSION_START")
end

local function markSessionMilestone(player,eventName)
    local milestone=SESSION_MILESTONES[eventName]
    if not milestone then return end
    local seen=sessionMilestones[player]
    if not seen then
        seen={}
        sessionMilestones[player]=seen
    end
    if seen[milestone] then return end
    seen[milestone]=true
    bump("SESSION_UNIQUE_"..milestone,true)
end

Players.PlayerAdded:Connect(registerSession)
for _,player in ipairs(Players:GetPlayers()) do registerSession(player) end

trackEvent.OnServerEvent:Connect(function(player,eventName)
    if typeof(eventName)~="string" or not ALLOWED[eventName] then return end
    local userId=player.UserId
    local playerTimes=lastEventAt[userId]
    if not playerTimes then playerTimes={};lastEventAt[userId]=playerTimes end
    local now=os.clock()
    local minimumGap=THROTTLE[eventName] or DEFAULT_THROTTLE_SECONDS
    if now-(playerTimes[eventName] or 0)<minimumGap then return end
    playerTimes[eventName]=now
    markSessionMilestone(player,eventName)
    bump(eventName)
end)

Players.PlayerRemoving:Connect(function(player)
    lastEventAt[player.UserId]=nil
    countedSessions[player]=nil
    sessionMilestones[player]=nil
end)

root:SetAttribute("TelemetryRevision","SESSION_COUNTERS_V13_RECENT_CONTINUE")
root:SetAttribute("TelemetryPrivacy","NO_PII_NO_EXTERNAL_PERSISTENCE")
root:SetAttribute("TelemetryThrottle","EVENT_SPECIFIC_PER_USER")
root:SetAttribute("TelemetrySessionAuthority","SERVER")
root:SetAttribute("TelemetrySchema",13)
refreshDerivedMetrics()
print("[BBYAVATAR] Privacy-safe telemetry v13 Recent/Continue conversion ready")