-- BECAK E-BIKE — reputation passenger rewards v1.48
-- Chapter-based passenger bonuses plus service streak and maintained-vehicle quality bonus.
-- Uses actual completed-trip base fare telemetry and the existing EconomyTransaction bridge.
-- v1.48 hardens completion-delta handling so one attribute signal can reward at most one trip.
-- Additive economy logic only: does not alter vehicle physics, collisions, trip integrity, or save schema.

local Players = game:GetService('Players')
local Workspace = game:GetService('Workspace')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local root = Workspace:WaitForChild('BecakEBike',20)
if not root then return end
local economy = root:WaitForChild('EconomyTransaction',20)
local vehicles = root:WaitForChild('Vehicles',20)
local remotes = ReplicatedStorage:WaitForChild('BecakEBikeRemotes',20)
if not economy or not vehicles or not remotes then return end
local toast = remotes:WaitForChild('Toast')

local STREAK_WINDOW_SECONDS = 300
local MAX_STREAK = 5
local STREAK_BONUS_PER_STEP = 0.02
local MAX_STREAK_BONUS_PCT = math.floor((MAX_STREAK-1)*STREAK_BONUS_PER_STEP*100 + .5)
local QUALITY_GOOD_CONDITION = 90
local QUALITY_PRIME_CONDITION = 98
local QUALITY_GOOD_BONUS = 0.03
local QUALITY_PRIME_BONUS = 0.05
local QUALITY_MAX_BONUS_PCT = math.floor(QUALITY_PRIME_BONUS*100 + .5)

local lastTrips = {}
local lastCompletionAt = {}
local serviceStreak = {}

local function transact(player,amount,reason)
    if amount <= 0 then return true end
    local ok,result = pcall(function()
        return economy:Invoke(player,amount,0,reason)
    end)
    return ok and result == true
end

local function ownedVehicle(player)
    for _,model in ipairs(vehicles:GetChildren()) do
        if model:IsA('Model') and model:GetAttribute('OwnerUserId')==player.UserId then
            return model
        end
    end
    return nil
end

local function rewardReputationBonus(player,baseReward,completedCount)
    if baseReward <= 0 or completedCount <= 0 then return 0 end
    local multiplier = tonumber(player:GetAttribute('StoryPassengerRewardMultiplier')) or 1
    multiplier = math.clamp(multiplier,1,1.15)
    local perTrip = math.max(0,math.floor(baseReward*(multiplier-1)+.5))
    if perTrip <= 0 then return 0 end
    local bonus = perTrip * completedCount
    if transact(player,bonus,'reputation_passenger_bonus') then
        local tier = tostring(player:GetAttribute('StoryJobTier') or 'Pemula')
        toast:FireClient(player,string.format('Bonus layanan penumpang • %s • +Rp%d',tier,bonus))
        return bonus
    end
    return 0
end

local function updateServiceStreak(player,now)
    local previous = lastCompletionAt[player]
    local streak = 1
    if previous and now-previous <= STREAK_WINDOW_SECONDS then
        streak = math.min(MAX_STREAK,(serviceStreak[player] or 1)+1)
    end
    lastCompletionAt[player] = now
    serviceStreak[player] = streak
    player:SetAttribute('PassengerServiceStreak',streak)
    player:SetAttribute('PassengerServiceStreakMax',MAX_STREAK)
    player:SetAttribute('PassengerServiceStreakWindowSeconds',STREAK_WINDOW_SECONDS)
    return streak
end

local function rewardStreakBonus(player,baseReward,streak,completedCount)
    if baseReward <= 0 or streak <= 1 or completedCount <= 0 then return 0 end
    local pct = math.clamp((streak-1)*STREAK_BONUS_PER_STEP,0,(MAX_STREAK-1)*STREAK_BONUS_PER_STEP)
    local perTrip = math.max(0,math.floor(baseReward*pct+.5))
    if perTrip <= 0 then return 0 end
    local bonus = perTrip * completedCount
    if transact(player,bonus,'passenger_service_streak') then
        player:SetAttribute('PassengerServiceStreakBonusPct',math.floor(pct*100+.5))
        player:SetAttribute('PassengerLastStreakBonus',bonus)
        toast:FireClient(player,string.format('Service streak x%d • bonus +%d%% • +Rp%d',streak,math.floor(pct*100+.5),bonus))
        return bonus
    end
    return 0
end

local function rewardVehicleQualityBonus(player,baseReward,completedCount)
    if baseReward <= 0 or completedCount <= 0 then return 0 end
    local vehicle = ownedVehicle(player)
    if not vehicle then
        player:SetAttribute('PassengerVehicleQualityBonusPct',0)
        player:SetAttribute('PassengerLastVehicleQualityBonus',0)
        return 0
    end
    local condition = math.clamp(tonumber(vehicle:GetAttribute('Condition')) or 100,0,100)
    local pct = 0
    if condition >= QUALITY_PRIME_CONDITION then
        pct = QUALITY_PRIME_BONUS
    elseif condition >= QUALITY_GOOD_CONDITION then
        pct = QUALITY_GOOD_BONUS
    end
    local pctInt = math.floor(pct*100+.5)
    player:SetAttribute('PassengerVehicleConditionAtCompletion',math.floor(condition+.5))
    player:SetAttribute('PassengerVehicleQualityBonusPct',pctInt)
    if pct <= 0 then
        player:SetAttribute('PassengerLastVehicleQualityBonus',0)
        return 0
    end
    local perTrip = math.max(0,math.floor(baseReward*pct+.5))
    local bonus = perTrip * completedCount
    if bonus > 0 and transact(player,bonus,'passenger_vehicle_quality') then
        player:SetAttribute('PassengerLastVehicleQualityBonus',bonus)
        toast:FireClient(player,string.format('Becak terawat %d%% • quality bonus +%d%% • +Rp%d',math.floor(condition+.5),pctInt,bonus))
        return bonus
    end
    player:SetAttribute('PassengerLastVehicleQualityBonus',0)
    return 0
end

local function rewardPassengerCompletion(player,completedCount)
    local baseReward = math.max(0,math.floor(tonumber(player:GetAttribute('BecakLastTripBaseReward')) or 0))
    if baseReward <= 0 or completedCount <= 0 then return end

    local streak = updateServiceStreak(player,os.clock())
    local repBonus = rewardReputationBonus(player,baseReward,completedCount)
    local streakBonus = rewardStreakBonus(player,baseReward,streak,completedCount)
    local qualityBonus = rewardVehicleQualityBonus(player,baseReward,completedCount)

    player:SetAttribute('PassengerLastBonusTotal',repBonus+streakBonus+qualityBonus)
    player:SetAttribute('PassengerLastBaseFare',baseReward)
end

local function setup(player)
    lastTrips[player] = math.max(0,tonumber(player:GetAttribute('BecakTrips')) or 0)
    serviceStreak[player] = 0
    player:SetAttribute('PassengerServiceStreak',0)
    player:SetAttribute('PassengerServiceStreakMax',MAX_STREAK)
    player:SetAttribute('PassengerServiceStreakWindowSeconds',STREAK_WINDOW_SECONDS)
    player:SetAttribute('PassengerServiceStreakBonusPct',0)
    player:SetAttribute('PassengerLastStreakBonus',0)
    player:SetAttribute('PassengerLastBonusTotal',0)
    player:SetAttribute('PassengerLastBaseFare',0)
    player:SetAttribute('PassengerVehicleConditionAtCompletion',0)
    player:SetAttribute('PassengerVehicleQualityBonusPct',0)
    player:SetAttribute('PassengerLastVehicleQualityBonus',0)
    player:SetAttribute('PassengerReputationDeltaAnomalies',0)
    player:SetAttribute('PassengerReputationLastObservedDelta',0)

    player:GetAttributeChangedSignal('BecakTrips'):Connect(function()
        if not player.Parent then return end
        local current = math.max(0,tonumber(player:GetAttribute('BecakTrips')) or 0)
        local previous = lastTrips[player] or current
        if current > previous then
            local observedDelta = current-previous
            player:SetAttribute('PassengerReputationLastObservedDelta',observedDelta)
            if observedDelta > 1 then
                player:SetAttribute('PassengerReputationDeltaAnomalies',(player:GetAttribute('PassengerReputationDeltaAnomalies') or 0)+1)
            end
            -- One BecakTrips attribute-change signal may produce at most one bonus payout.
            -- The canonical trip system is responsible for one increment per validated passenger completion.
            rewardPassengerCompletion(player,1)
        end
        lastTrips[player] = current
    end)
end

for _,player in ipairs(Players:GetPlayers()) do setup(player) end
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(function(player)
    lastTrips[player]=nil
    lastCompletionAt[player]=nil
    serviceStreak[player]=nil
end)

-- Keep the v1.46 compatibility marker for existing build/publish checks; v1.48 is additive.
Workspace:SetAttribute('ACC_BecakReputationPassenger','v1.46')
Workspace:SetAttribute('ACC_BecakReputationPassengerEnhancement','v1.48')
Workspace:SetAttribute('BecakReputationPassengerBonusMaxPct',15)
Workspace:SetAttribute('BecakReputationPassengerUsesActualFare','ON')
Workspace:SetAttribute('BecakPassengerServiceStreak','ON')
Workspace:SetAttribute('BecakPassengerServiceStreakMax',MAX_STREAK)
Workspace:SetAttribute('BecakPassengerServiceStreakWindowSeconds',STREAK_WINDOW_SECONDS)
Workspace:SetAttribute('BecakPassengerServiceStreakBonusMaxPct',MAX_STREAK_BONUS_PCT)
Workspace:SetAttribute('BecakPassengerVehicleQualityBonus','ON')
Workspace:SetAttribute('BecakPassengerVehicleQualityGoodCondition',QUALITY_GOOD_CONDITION)
Workspace:SetAttribute('BecakPassengerVehicleQualityPrimeCondition',QUALITY_PRIME_CONDITION)
Workspace:SetAttribute('BecakPassengerVehicleQualityMaxBonusPct',QUALITY_MAX_BONUS_PCT)
Workspace:SetAttribute('BecakPassengerReputationDeltaGuard','ON')
Workspace:SetAttribute('BecakPassengerReputationMaxRewardPerSignal',1)
print('[BECAK E-BIKE] reputation passenger v1.48 ready • delta guard + chapter + streak + maintained-vehicle quality bonus')