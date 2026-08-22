-- BBYAVATAR Look Share analytics v1
-- Session/runtime aggregate only. No UserIds, share codes, item IDs, names, or look contents are stored.
-- This listener is intentionally separate from the core telemetry allowlist so share analytics can evolve
-- without broadening arbitrary client event acceptance.

local Players = game:GetService("Players")
local trackEvent = rem:WaitForChild("TrackEvent")

local ALLOWED = {
    SHARE_OPEN=true,
    SHARE_CREATE=true,
    SHARE_LOAD=true,
    SHARE_IMPORT=true,
    SHARE_CAPACITY_BLOCK=true,
    SHARE_FAILED=true,
}

local THROTTLE = {
    SHARE_OPEN=1.0,
    SHARE_CREATE=2.0,
    SHARE_LOAD=1.0,
    SHARE_IMPORT=1.0,
    SHARE_CAPACITY_BLOCK=1.0,
    SHARE_FAILED=1.0,
}

local counters = {}
local lastByPlayer = setmetatable({}, {__mode="k"})
local sessionMilestones = setmetatable({}, {__mode="k"})

local function metric(name)
    return counters[name] or 0
end

local function rate(numerator, denominator)
    if denominator <= 0 then return 0 end
    return math.floor((numerator / denominator) * 1000 + 0.5) / 10
end

local function refresh()
    local opens = metric("SHARE_OPEN")
    local creates = metric("SHARE_CREATE")
    local loads = metric("SHARE_LOAD")
    local imports = metric("SHARE_IMPORT")
    root:SetAttribute("ShareMetric_Open", opens)
    root:SetAttribute("ShareMetric_Create", creates)
    root:SetAttribute("ShareMetric_Load", loads)
    root:SetAttribute("ShareMetric_Import", imports)
    root:SetAttribute("ShareMetric_CapacityBlock", metric("SHARE_CAPACITY_BLOCK"))
    root:SetAttribute("ShareMetric_Failed", metric("SHARE_FAILED"))
    root:SetAttribute("ShareConv_CreatePerOpenPct", rate(creates, opens))
    root:SetAttribute("ShareConv_LoadPerOpenPct", rate(loads, opens))
    root:SetAttribute("ShareConv_ImportPerLoadPct", rate(imports, loads))
    root:SetAttribute("ShareHealth_FailurePerLoadPct", rate(metric("SHARE_FAILED"), loads))
end

local function bump(name)
    counters[name] = (counters[name] or 0) + 1
    refresh()
end

trackEvent.OnServerEvent:Connect(function(player, eventName)
    if typeof(eventName) ~= "string" or not ALLOWED[eventName] then return end
    local times = lastByPlayer[player]
    if not times then times = {}; lastByPlayer[player] = times end
    local now = os.clock()
    local gap = THROTTLE[eventName] or 1
    if now - (times[eventName] or 0) < gap then return end
    times[eventName] = now
    bump(eventName)

    local milestones = sessionMilestones[player]
    if not milestones then milestones = {}; sessionMilestones[player] = milestones end
    if not milestones[eventName] then
        milestones[eventName] = true
        root:SetAttribute("ShareSessionUnique_" .. eventName, (tonumber(root:GetAttribute("ShareSessionUnique_" .. eventName)) or 0) + 1)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    lastByPlayer[player] = nil
    sessionMilestones[player] = nil
end)

root:SetAttribute("LookShareAnalyticsRevision", "V1_AGGREGATE_NO_CONTENT")
root:SetAttribute("LookShareAnalyticsPrivacy", "NO_USERID_NO_CODES_NO_ITEM_IDS_NO_LOOK_CONTENTS")
refresh()
print("[BBYAVATAR] Look Share analytics v1 aggregate funnel ready")