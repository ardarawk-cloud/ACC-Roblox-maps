local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local store = DataStoreService:GetDataStore("WP_Retention_v1")
local DAILY_SECONDS = 86400
local WEEK_SECONDS = 604800

local function utcDay(t)
    return math.floor(t / DAILY_SECONDS)
end

local function utcWeek(t)
    return math.floor(t / WEEK_SECONDS)
end

local function waitForData(player)
    local deadline = os.clock() + 20
    while player.Parent and os.clock() < deadline do
        if player:GetAttribute("WP_DataLoaded") == true then return true end
        task.wait(.25)
    end
    return false
end

local function addCoins(player, amount)
    player:SetAttribute("Coins", (tonumber(player:GetAttribute("Coins")) or 0) + math.max(0, math.floor(amount)))
end

local function addStars(player, amount)
    player:SetAttribute("Stars", (tonumber(player:GetAttribute("Stars")) or 0) + math.max(0, math.floor(amount)))
end

local function load(player)
    if not waitForData(player) then
        warn("[WONDERPOCKET] Retention skipped because player data was not ready", player.UserId)
        return
    end

    local now = os.time()
    local key = "u_" .. player.UserId
    local data = nil
    pcall(function() data = store:GetAsync(key) end)
    data = type(data) == "table" and data or {}

    local lastSeen = tonumber(data.lastSeen) or now
    local offline = math.clamp(now - lastSeen, 0, 8 * 60 * 60)
    local offlineCoins = math.floor(offline / 60)
    if offlineCoins > 0 then
        addCoins(player, offlineCoins)
        player:SetAttribute("WP_OfflineReward", offlineCoins)
    end

    local day = utcDay(now)
    if tonumber(data.lastDailyDay) ~= day then
        data.lastDailyDay = day
        addCoins(player, 50)
        addStars(player, 1)
        player:SetAttribute("WP_DailyRewardClaimed", true)
        player:SetAttribute("WP_DailyQuestProgress", 0)
    end

    local week = utcWeek(now)
    if tonumber(data.lastWeeklyWeek) ~= week then
        data.lastWeeklyWeek = week
        player:SetAttribute("WP_WeeklyQuestProgress", 0)
    end

    player:SetAttribute("WP_RetentionLoaded", true)
    player:SetAttribute("WP_LastDailyDay", data.lastDailyDay or day)
    player:SetAttribute("WP_LastWeeklyWeek", data.lastWeeklyWeek or week)
end

local function save(player)
    if player:GetAttribute("WP_RetentionLoaded") ~= true then return end
    local now = os.time()
    local key = "u_" .. player.UserId
    local payload = {
        lastSeen = now,
        lastDailyDay = player:GetAttribute("WP_LastDailyDay") or utcDay(now),
        lastWeeklyWeek = player:GetAttribute("WP_LastWeeklyWeek") or utcWeek(now),
        dailyProgress = player:GetAttribute("WP_DailyQuestProgress") or 0,
        weeklyProgress = player:GetAttribute("WP_WeeklyQuestProgress") or 0,
    }
    pcall(function() store:SetAsync(key, payload) end)
end

Players.PlayerAdded:Connect(function(player)
    task.spawn(load, player)
end)
Players.PlayerRemoving:Connect(save)
game:BindToClose(function()
    for _, player in Players:GetPlayers() do save(player) end
end)

print("[WONDERPOCKET] Canonical retention + offline rewards loaded")
