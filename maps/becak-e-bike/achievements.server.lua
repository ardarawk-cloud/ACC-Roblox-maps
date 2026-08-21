-- BECAK E-BIKE — persistent achievements v1.22
-- One-time trip milestones backed by a dedicated Becak-only DataStore.
-- Rewards are persisted before payout to prevent rejoin farming.

local Players = game:GetService('Players')
local DataStoreService = game:GetService('DataStoreService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Workspace = game:GetService('Workspace')

local root = Workspace:WaitForChild('BecakEBike',20)
if not root then return end
local economy = root:WaitForChild('EconomyTransaction',20)
local remotes = ReplicatedStorage:WaitForChild('BecakEBikeRemotes',20)
if not economy or not remotes then return end
local toast = remotes:WaitForChild('Toast')
local store = DataStoreService:GetDataStore('ACC_BecakAchievements_v1')

local ACHIEVEMENTS = {
    {id='trip_1', trips=1, title='Perjalanan Pertama', money=5000, xp=20},
    {id='trip_10', trips=10, title='Pengemudi Lokal', money=15000, xp=50},
    {id='trip_25', trips=25, title='Andalan Nusakarya', money=30000, xp=90},
    {id='trip_50', trips=50, title='Pengemudi Profesional', money=60000, xp=160},
    {id='trip_100', trips=100, title='Legenda Jalanan', money=125000, xp=300},
}

local state = {}
local checking = {}

local function key(player)
    return 'u_'..player.UserId
end

local function setSummary(player,data)
    local count=0
    for _,a in ipairs(ACHIEVEMENTS) do if data[a.id] then count+=1 end end
    player:SetAttribute('BecakAchievementsUnlocked',count)
    player:SetAttribute('BecakAchievementsTotal',#ACHIEVEMENTS)
end

local function persistUnlock(player,achievement)
    local unlocked = false
    local ok, result = pcall(function()
        return store:UpdateAsync(key(player),function(old)
            old = type(old)=='table' and old or {}
            old.awarded = type(old.awarded)=='table' and old.awarded or {}
            if old.awarded[achievement.id] then return old end
            old.awarded[achievement.id] = os.time()
            unlocked = true
            return old
        end)
    end)
    return ok and result ~= nil, unlocked
end

local function reward(player,a)
    local ok,result = pcall(function()
        return economy:Invoke(player,a.money,a.xp,'achievement_'..a.id)
    end)
    if ok and result == true then
        toast:FireClient(player,'Achievement: '..a.title..' • +Rp'..a.money..' +'..a.xp..' XP')
        return true
    end
    return false
end

local function check(player)
    if checking[player] or not player.Parent then return end
    local data=state[player]
    if not data or data.disabled then return end
    checking[player]=true
    local trips=tonumber(player:GetAttribute('BecakTrips')) or 0
    for _,a in ipairs(ACHIEVEMENTS) do
        if trips>=a.trips and not data.awarded[a.id] then
            local persisted,newUnlock=persistUnlock(player,a)
            if not persisted then
                data.disabled=true
                player:SetAttribute('BecakAchievementsPersistence','UNAVAILABLE')
                break
            end
            data.awarded[a.id]=true
            if newUnlock then reward(player,a) end
            setSummary(player,data.awarded)
        end
    end
    checking[player]=nil
end

local function setup(player)
    player:SetAttribute('BecakAchievementsPersistence','LOADING')
    local ok,saved=pcall(function() return store:GetAsync(key(player)) end)
    if not ok then
        state[player]={awarded={},disabled=true}
        player:SetAttribute('BecakAchievementsPersistence','UNAVAILABLE')
        setSummary(player,{})
        return
    end
    local awarded = type(saved)=='table' and type(saved.awarded)=='table' and saved.awarded or {}
    state[player]={awarded=awarded,disabled=false}
    player:SetAttribute('BecakAchievementsPersistence','READY')
    setSummary(player,awarded)
    player:GetAttributeChangedSignal('BecakTrips'):Connect(function() check(player) end)
    task.defer(check,player)
end

for _,player in ipairs(Players:GetPlayers()) do task.spawn(setup,player) end
Players.PlayerAdded:Connect(function(player) task.spawn(setup,player) end)
Players.PlayerRemoving:Connect(function(player) state[player]=nil;checking[player]=nil end)

Workspace:SetAttribute('ACC_BecakAchievements','v1.22')
Workspace:SetAttribute('BecakAchievementCount',#ACHIEVEMENTS)
Workspace:SetAttribute('BecakAchievementsPersistent','ON')
Workspace:SetAttribute('BecakAchievementRewardGuard','PERSIST_BEFORE_PAYOUT')
print('[BECAK E-BIKE] achievements v1.22 ready • '..#ACHIEVEMENTS..' persistent trip milestones')
