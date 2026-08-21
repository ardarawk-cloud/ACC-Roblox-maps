-- BECAK E-BIKE — reputation passenger rewards v1.21
-- Adds chapter-based passenger service bonuses using the actual completed trip base reward.

local Players = game:GetService('Players')
local Workspace = game:GetService('Workspace')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local root = Workspace:WaitForChild('BecakEBike',20)
if not root then return end
local economy = root:WaitForChild('EconomyTransaction',20)
local remotes = ReplicatedStorage:WaitForChild('BecakEBikeRemotes',20)
if not economy or not remotes then return end
local toast = remotes:WaitForChild('Toast')

local lastTrips = {}

local function transact(player,amount,reason)
    if amount <= 0 then return true end
    local ok,result = pcall(function()
        return economy:Invoke(player,amount,0,reason)
    end)
    return ok and result == true
end

local function rewardBonus(player,completedCount)
    local baseReward = math.max(0,math.floor(tonumber(player:GetAttribute('BecakLastTripBaseReward')) or 0))
    if baseReward <= 0 or completedCount <= 0 then return end
    local multiplier = tonumber(player:GetAttribute('StoryPassengerRewardMultiplier')) or 1
    multiplier = math.clamp(multiplier,1,1.15)
    local perTrip = math.max(0,math.floor(baseReward*(multiplier-1)+.5))
    if perTrip <= 0 then return end
    local bonus = perTrip * completedCount
    if transact(player,bonus,'reputation_passenger_bonus') then
        local tier = tostring(player:GetAttribute('StoryJobTier') or 'Pemula')
        toast:FireClient(player,string.format('Bonus layanan penumpang • %s • +Rp%d',tier,bonus))
    end
end

local function setup(player)
    lastTrips[player] = math.max(0,tonumber(player:GetAttribute('BecakTrips')) or 0)
    player:GetAttributeChangedSignal('BecakTrips'):Connect(function()
        if not player.Parent then return end
        local current = math.max(0,tonumber(player:GetAttribute('BecakTrips')) or 0)
        local previous = lastTrips[player] or current
        if current > previous then rewardBonus(player,current-previous) end
        lastTrips[player] = current
    end)
end

for _,player in ipairs(Players:GetPlayers()) do setup(player) end
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(function(player) lastTrips[player]=nil end)

Workspace:SetAttribute('ACC_BecakReputationPassenger','v1.21')
Workspace:SetAttribute('BecakReputationPassengerBonusMaxPct',15)
Workspace:SetAttribute('BecakReputationPassengerUsesActualFare','ON')
print('[BECAK E-BIKE] reputation passenger v1.21 ready • actual-fare chapter bonus up to +15%')
