-- BECAK E-BIKE — daily contracts v1.17
-- Lightweight persistent daily goals that extend the passenger/cargo/charging loop.

local Players = game:GetService('Players')
local DataStoreService = game:GetService('DataStoreService')
local Workspace = game:GetService('Workspace')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local root = Workspace:WaitForChild('BecakEBike',20)
if not root then return end
local economy = root:WaitForChild('EconomyTransaction',20)
local remotes = ReplicatedStorage:WaitForChild('BecakEBikeRemotes',20)
if not economy or not remotes then return end
local toast = remotes:WaitForChild('Toast')

local store = DataStoreService:GetDataStore('BecakDailyContractsV1')
local playerState = {}
local lastCounters = {}

local CONTRACTS = {
    passenger = {goal=3, reward=18000, xp=45, label='Antar 3 penumpang'},
    cargo = {goal=2, reward=24000, xp=55, label='Kirim 2 cargo'},
    charge = {goal=1, reward=8000, xp=20, label='Charging 1 kali'},
}

local function utcDay()
    return os.date('!%Y-%m-%d')
end

local function freshState(player)
    return {
        day=utcDay(),
        tripStart=player:GetAttribute('BecakTrips') or 0,
        progress={passenger=0,cargo=0,charge=0},
        claimed={passenger=false,cargo=false,charge=false},
    }
end

local function sanitize(player,raw)
    if type(raw)~='table' or raw.day~=utcDay() then return freshState(player) end
    raw.progress=type(raw.progress)=='table' and raw.progress or {}
    raw.claimed=type(raw.claimed)=='table' and raw.claimed or {}
    raw.tripStart=tonumber(raw.tripStart) or (player:GetAttribute('BecakTrips') or 0)
    for id in pairs(CONTRACTS) do
        raw.progress[id]=math.max(0,math.floor(tonumber(raw.progress[id]) or 0))
        raw.claimed[id]=raw.claimed[id]==true
    end
    return raw
end

local function save(player)
    local state=playerState[player]
    if not state then return end
    local key='u_'..player.UserId
    pcall(function() store:SetAsync(key,state) end)
end

local function transact(player,amount,xp,reason)
    local ok,result=pcall(function() return economy:Invoke(player,amount,xp,reason) end)
    return ok and result==true
end

local function publishAttributes(player,state)
    local completed=0
    for id,c in pairs(CONTRACTS) do
        local progress=math.min(c.goal,state.progress[id] or 0)
        player:SetAttribute('DailyContract_'..id..'_Progress',progress)
        player:SetAttribute('DailyContract_'..id..'_Goal',c.goal)
        player:SetAttribute('DailyContract_'..id..'_Claimed',state.claimed[id]==true)
        if state.claimed[id] then completed+=1 end
    end
    player:SetAttribute('DailyContractDay',state.day)
    player:SetAttribute('DailyContractsCompleted',completed)
    player:SetAttribute('DailyContractsTotal',3)
end

local function tryClaim(player,id)
    local state=playerState[player]
    local c=CONTRACTS[id]
    if not state or not c or state.claimed[id] then return false end
    if (state.progress[id] or 0)<c.goal then return false end
    if not transact(player,c.reward,c.xp,'daily_contract_'..id) then return false end
    state.claimed[id]=true
    publishAttributes(player,state)
    toast:FireClient(player,'Kontrak harian selesai • '..c.label..' • +Rp'..c.reward..' +'..c.xp..' XP')
    save(player)
    return true
end

local function addProgress(player,id,delta)
    local state=playerState[player]
    local c=CONTRACTS[id]
    if not state or not c or state.claimed[id] then return end
    state.progress[id]=math.min(c.goal,(state.progress[id] or 0)+math.max(0,delta or 0))
    publishAttributes(player,state)
    tryClaim(player,id)
end

local function setupPlayer(player)
    local key='u_'..player.UserId
    local raw
    pcall(function() raw=store:GetAsync(key) end)
    local state=sanitize(player,raw)
    playerState[player]=state
    local totalTrips=player:GetAttribute('BecakTrips') or 0
    state.progress.passenger=math.max(state.progress.passenger or 0,totalTrips-state.tripStart)
    lastCounters[player]={trips=totalTrips,cargo=player:GetAttribute('CargoJobs') or 0,charge=player:GetAttribute('ChargingVisits') or 0}
    publishAttributes(player,state)
    for id in pairs(CONTRACTS) do tryClaim(player,id) end
    task.delay(6,function()
        if player.Parent then
            toast:FireClient(player,'Kontrak harian • 3 penumpang • 2 cargo • 1 charging')
        end
    end)
end

for _,player in ipairs(Players:GetPlayers()) do task.spawn(setupPlayer,player) end
Players.PlayerAdded:Connect(function(player) task.spawn(setupPlayer,player) end)
Players.PlayerRemoving:Connect(function(player)
    save(player)
    playerState[player]=nil
    lastCounters[player]=nil
end)

task.spawn(function()
    while root.Parent do
        task.wait(1)
        for _,player in ipairs(Players:GetPlayers()) do
            local state=playerState[player]
            local last=lastCounters[player]
            if state and last then
                if state.day~=utcDay() then
                    state=freshState(player)
                    playerState[player]=state
                    last.trips=player:GetAttribute('BecakTrips') or 0
                    last.cargo=player:GetAttribute('CargoJobs') or 0
                    last.charge=player:GetAttribute('ChargingVisits') or 0
                    publishAttributes(player,state)
                    save(player)
                    toast:FireClient(player,'Kontrak harian baru tersedia.')
                end
                local trips=player:GetAttribute('BecakTrips') or 0
                local cargo=player:GetAttribute('CargoJobs') or 0
                local charge=player:GetAttribute('ChargingVisits') or 0
                if trips>last.trips then addProgress(player,'passenger',trips-last.trips) end
                if cargo>last.cargo then addProgress(player,'cargo',cargo-last.cargo) end
                if charge>last.charge then addProgress(player,'charge',charge-last.charge) end
                last.trips,last.cargo,last.charge=trips,cargo,charge
            end
        end
    end
end)

Workspace:SetAttribute('ACC_BecakDailyContracts','v1.17')
Workspace:SetAttribute('BecakDailyContractCount',3)
Workspace:SetAttribute('BecakDailyContractsPersistent','ON')
print('[BECAK E-BIKE] daily contracts v1.17 ready • passenger + cargo + charging')