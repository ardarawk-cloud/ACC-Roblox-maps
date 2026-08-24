-- BECAK E-BIKE — reputation cargo rewards v1.21
-- Chapter-based cargo bonuses use the actual completed cargo payout telemetry.
-- Additive economy logic only: does not alter cargo integrity, vehicle physics, collisions, or save schema.

local Players = game:GetService('Players')
local Workspace = game:GetService('Workspace')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local root = Workspace:WaitForChild('BecakEBike',20)
if not root then return end
local economy = root:WaitForChild('EconomyTransaction',20)
local remotes = ReplicatedStorage:WaitForChild('BecakEBikeRemotes',20)
if not economy or not remotes then return end
local toast = remotes:WaitForChild('Toast')

local LEGACY_BASE_CARGO_REWARD = 35000
local lastCargo = {}

local function transact(player,amount,reason)
    if amount <= 0 then return true end
    local ok,result = pcall(function()
        return economy:Invoke(player,amount,0,reason)
    end)
    return ok and result == true
end

local function completedCargoBaseReward(player)
    local actual = math.max(0,math.floor(tonumber(player:GetAttribute('CargoLastReward')) or 0))
    if actual > 0 then return actual end
    return LEGACY_BASE_CARGO_REWARD
end

local function rewardBonus(player,completedCount)
    if completedCount <= 0 then return 0 end
    local baseReward = completedCargoBaseReward(player)
    local multiplier = tonumber(player:GetAttribute('StoryCargoRewardMultiplier')) or 1
    multiplier = math.clamp(multiplier,1,1.25)
    local perJob = math.max(0,math.floor(baseReward*(multiplier-1)+.5))
    if perJob <= 0 then
        player:SetAttribute('CargoLastReputationBonus',0)
        player:SetAttribute('CargoReputationBaseReward',baseReward)
        return 0
    end
    local bonus = perJob * completedCount
    if transact(player,bonus,'reputation_cargo_bonus') then
        local tier = tostring(player:GetAttribute('StoryJobTier') or 'Pemula')
        player:SetAttribute('CargoLastReputationBonus',bonus)
        player:SetAttribute('CargoReputationBaseReward',baseReward)
        toast:FireClient(player,string.format('Bonus reputasi cargo • %s • +Rp%d',tier,bonus))
        return bonus
    end
    player:SetAttribute('CargoLastReputationBonus',0)
    player:SetAttribute('CargoReputationBaseReward',baseReward)
    return 0
end

local function setup(player)
    lastCargo[player] = math.max(0,tonumber(player:GetAttribute('CargoJobs')) or 0)
    player:SetAttribute('CargoLastReputationBonus',0)
    player:SetAttribute('CargoReputationBaseReward',0)
    player:GetAttributeChangedSignal('CargoJobs'):Connect(function()
        if not player.Parent then return end
        local current = math.max(0,tonumber(player:GetAttribute('CargoJobs')) or 0)
        local previous = lastCargo[player] or current
        if current > previous then rewardBonus(player,current-previous) end
        lastCargo[player] = current
    end)
end

for _,player in ipairs(Players:GetPlayers()) do setup(player) end
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(function(player) lastCargo[player]=nil end)

-- Keep v1.20 compatibility for existing build/publish checks; v1.21 is additive.
Workspace:SetAttribute('ACC_BecakReputationCargo','v1.20')
Workspace:SetAttribute('ACC_BecakReputationCargoEnhancement','v1.21')
Workspace:SetAttribute('BecakReputationCargoBaseReward',LEGACY_BASE_CARGO_REWARD)
Workspace:SetAttribute('BecakReputationCargoUsesActualReward','ON')
Workspace:SetAttribute('BecakReputationCargoBonusMaxPct',25)
print('[BECAK E-BIKE] reputation cargo v1.21 ready • actual dynamic payout telemetry + chapter bonus up to +25%')
