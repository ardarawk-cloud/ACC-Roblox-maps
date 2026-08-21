-- BECAK E-BIKE — live city events + progression bonus v1.10
-- Dedicated overlay for maps/becak-e-bike. Adds lightweight rotating city events
-- without changing the core passenger/cargo loops or touching other ACC maps.
local Players=game:GetService('Players')
local Workspace=game:GetService('Workspace')
local ReplicatedStorage=game:GetService('ReplicatedStorage')

local root=Workspace:WaitForChild('BecakEBike',20)
if not root then return end
local vehicles=root:WaitForChild('Vehicles',20)
local economy=root:WaitForChild('EconomyTransaction',20)
local remotes=ReplicatedStorage:WaitForChild('BecakEBikeRemotes',20)
local toast=remotes:WaitForChild('Toast',20)
if not vehicles or not economy or not toast then return end

local EVENT_DURATION=135
local BREAK_DURATION=45
local events={
 {id='PASAR_RAMAI',title='Pasar Ramai',desc='Bonus penumpang +Rp8.000 +10 XP',tripBonus=8000,tripXP=10,cargoBonus=0,cargoXP=0},
 {id='CARGO_RUSH',title='Cargo Rush',desc='Bonus cargo +Rp12.000 +15 XP',tripBonus=0,tripXP=0,cargoBonus=12000,cargoXP=15},
 {id='GREEN_HOUR',title='Green Hour',desc='Trip memberi isi ulang baterai 8%',tripBonus=5000,tripXP=8,cargoBonus=5000,cargoXP=8,battery=8},
}
local active=nil
local sequence=0
local lastTrips={}
local lastCargo={}

local function transact(player,amount,xp,reason)
 local ok,result=pcall(function() return economy:Invoke(player,amount,xp or 0,reason or '') end)
 return ok and result==true
end
local function playerBecak(player)
 for _,m in ipairs(vehicles:GetChildren()) do
  if m:IsA('Model') and m:GetAttribute('OwnerUserId')==player.UserId then return m end
 end
end
local function notifyAll(text)
 for _,p in ipairs(Players:GetPlayers()) do toast:FireClient(p,text) end
end
local function recharge(player,amount)
 local b=playerBecak(player);if not b then return end
 local now=tonumber(b:GetAttribute('Battery')) or 0
 local cap=tonumber(b:GetAttribute('BatteryMax')) or 100
 b:SetAttribute('Battery',math.min(cap,now+cap*(amount/100)))
end
local function rewardTrip(player)
 if not active then return end
 if active.tripBonus>0 and transact(player,active.tripBonus,active.tripXP,'event_trip_'..active.id) then
  toast:FireClient(player,active.title..' • bonus trip +Rp'..active.tripBonus)
 end
 if active.battery then recharge(player,active.battery) end
end
local function rewardCargo(player)
 if not active then return end
 if active.cargoBonus>0 and transact(player,active.cargoBonus,active.cargoXP,'event_cargo_'..active.id) then
  toast:FireClient(player,active.title..' • bonus cargo +Rp'..active.cargoBonus)
 end
 if active.battery then recharge(player,active.battery) end
end
local function watchPlayer(player)
 lastTrips[player]=tonumber(player:GetAttribute('BecakTrips')) or 0
 lastCargo[player]=tonumber(player:GetAttribute('CargoJobs')) or 0
 player:GetAttributeChangedSignal('BecakTrips'):Connect(function()
  local n=tonumber(player:GetAttribute('BecakTrips')) or 0
  if n> (lastTrips[player] or 0) then rewardTrip(player) end
  lastTrips[player]=n
 end)
 player:GetAttributeChangedSignal('CargoJobs'):Connect(function()
  local n=tonumber(player:GetAttribute('CargoJobs')) or 0
  if n> (lastCargo[player] or 0) then rewardCargo(player) end
  lastCargo[player]=n
 end)
end
for _,p in ipairs(Players:GetPlayers()) do watchPlayer(p) end
Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(function(p) lastTrips[p]=nil;lastCargo[p]=nil end)

local function activate(e)
 active=e;sequence+=1
 Workspace:SetAttribute('BecakCityEvent',e.id)
 Workspace:SetAttribute('BecakCityEventTitle',e.title)
 Workspace:SetAttribute('BecakCityEventEndsAt',os.time()+EVENT_DURATION)
 Workspace:SetAttribute('BecakCityEventSequence',sequence)
 notifyAll('EVENT KOTA • '..e.title..' — '..e.desc)
end
local function clearEvent()
 active=nil
 Workspace:SetAttribute('BecakCityEvent','NONE')
 Workspace:SetAttribute('BecakCityEventTitle','')
 Workspace:SetAttribute('BecakCityEventEndsAt',0)
 notifyAll('Event kota selesai • Nusakarya kembali normal')
end

Workspace:SetAttribute('ACC_BecakCityEvents','v1.10')
Workspace:SetAttribute('BecakCityEvent','NONE')
print('[BECAK E-BIKE] live city events v1.10 ready')

task.spawn(function()
 task.wait(25)
 local i=0
 while root.Parent do
  i=i%#events+1
  activate(events[i])
  task.wait(EVENT_DURATION)
  clearEvent()
  task.wait(BREAK_DURATION)
 end
end)
