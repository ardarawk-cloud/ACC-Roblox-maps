local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local DAILY_SECONDS = 86400
local WEEK_SECONDS = 604800
local CriticalSave = ServerStorage:WaitForChild("WONDERPOCKET_CriticalSave", 20)
local EconomyAudit = ServerStorage:WaitForChild("WONDERPOCKET_EconomyAudit", 20)

local function utcDay(t) return math.floor(t / DAILY_SECONDS) end
local function utcWeek(t) return math.floor(t / WEEK_SECONDS) end

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
    if not waitForData(player) or player:GetAttribute("WP_RetentionLoaded") == true then return end

    local now = os.time()
    local offline = math.clamp(tonumber(player:GetAttribute("WP_OfflineSeconds")) or 0, 0, 8 * 60 * 60)
    local offlineCoins = math.floor(offline / 60)
    if offlineCoins > 0 then
        addCoins(player, offlineCoins)
        player:SetAttribute("WP_OfflineReward", offlineCoins)
        if EconomyAudit then EconomyAudit:Fire(player,"OFFLINE_REWARD","Offline",offlineCoins,0,0) end
    else
        player:SetAttribute("WP_OfflineReward", 0)
    end

    local day = utcDay(now)
    if tonumber(player:GetAttribute("WP_LastDailyDay")) ~= day then
        player:SetAttribute("WP_LastDailyDay", day)
        addCoins(player, 50)
        addStars(player, 1)
        player:SetAttribute("WP_DailyRewardClaimed", true)
        player:SetAttribute("WP_DailyQuestProgress", 0)
        if EconomyAudit then EconomyAudit:Fire(player,"DAILY_REWARD",tostring(day),50,1,0) end
    else
        player:SetAttribute("WP_DailyRewardClaimed", false)
    end

    local week = utcWeek(now)
    if tonumber(player:GetAttribute("WP_LastWeeklyWeek")) ~= week then
        player:SetAttribute("WP_LastWeeklyWeek", week)
        player:SetAttribute("WP_WeeklyQuestProgress", 0)
    end

    player:SetAttribute("WP_RetentionLoaded", true)
    if CriticalSave then CriticalSave:Fire(player) end
end

Players.PlayerAdded:Connect(function(player) task.spawn(load, player) end)
for _, player in Players:GetPlayers() do task.spawn(load, player) end

print("[WONDERPOCKET] Audited canonical retention rewards loaded")
