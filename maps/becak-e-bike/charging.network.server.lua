-- BECAK E-BIKE — charging network v1.17
-- Expands charging beyond HQ with lightweight, economy-backed public chargers.
-- Uses the isolated Becak EconomyTransaction BindableFunction and vehicle Battery attributes.
-- v1.17 hardens public charger prompts with LOS, 10-stud range and per-station cooldown.

local Players = game:GetService('Players')
local Workspace = game:GetService('Workspace')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local root = Workspace:WaitForChild('BecakEBike',20)
if not root then return end
local vehicles = root:WaitForChild('Vehicles',20)
local interactives = root:WaitForChild('Interactives',20)
local economy = root:WaitForChild('EconomyTransaction',20)
local remotes = ReplicatedStorage:WaitForChild('BecakEBikeRemotes',20)
if not vehicles or not interactives or not economy or not remotes then return end
local toast = remotes:WaitForChild('Toast')

local PRICE_PER_UNIT = 55
local EMERGENCY_THRESHOLD = 10
local EMERGENCY_GRANT = 12
local PROMPT_HOLD_SECONDS = 0.55
local PROMPT_MAX_DISTANCE = 10
local PROMPT_COOLDOWN_SECONDS = 1.0

local function playerBecak(player)
    for _,m in ipairs(vehicles:GetChildren()) do
        if m:IsA('Model') and m:GetAttribute('OwnerUserId') == player.UserId then return m end
    end
end

local function transact(player,amount,reason)
    local ok,result = pcall(function()
        return economy:Invoke(player,amount,0,reason)
    end)
    return ok and result == true
end

local function label(part,text)
    local g=Instance.new('BillboardGui')
    g.Size=UDim2.fromOffset(180,46)
    g.StudsOffset=Vector3.new(0,4,0)
    g.AlwaysOnTop=false
    g.MaxDistance=70
    g.Parent=part
    local t=Instance.new('TextLabel')
    t.Size=UDim2.fromScale(1,1)
    t.BackgroundTransparency=.18
    t.BackgroundColor3=Color3.fromRGB(12,24,20)
    t.TextColor3=Color3.fromRGB(225,255,235)
    t.TextSize=13
    t.TextWrapped=true
    t.Font=Enum.Font.GothamBold
    t.Text=text
    t.Parent=g
end

local network = interactives:FindFirstChild('ChargingNetwork')
if network then network:Destroy() end
network = Instance.new('Folder')
network.Name='ChargingNetwork'
network.Parent=interactives

local stations={
    {name='HQ',pos=Vector3.new(-45,.55,-112)},
    {name='Pasar Nusantara',pos=Vector3.new(-335,.55,330)},
    {name='Pusat Kota',pos=Vector3.new(190,.55,120)},
    {name='Terminal Raya',pos=Vector3.new(420,.55,35)},
    {name='Pantai Bahari',pos=Vector3.new(305,.55,-330)},
}

local function chargePlayer(player,stationName)
    local b=playerBecak(player)
    if not b then toast:FireClient(player,'Becak E-Bike belum tersedia.') return end
    local max=tonumber(b:GetAttribute('BatteryMax')) or 100
    local current=math.clamp(tonumber(b:GetAttribute('Battery')) or max,0,max)
    local missing=math.max(0,max-current)
    if missing < .5 then toast:FireClient(player,'Baterai sudah penuh.') return end

    -- Emergency assist prevents a stranded player from being trapped by economy state.
    if current <= EMERGENCY_THRESHOLD then
        local grant=math.min(EMERGENCY_GRANT,missing)
        b:SetAttribute('Battery',math.min(max,current+grant))
        current=tonumber(b:GetAttribute('Battery')) or current
        missing=math.max(0,max-current)
        toast:FireClient(player,'Emergency charge +'..math.floor(grant)..'% • gratis')
        if missing < .5 then return end
    end

    local cost=math.max(1,math.ceil(missing*PRICE_PER_UNIT))
    if not transact(player,-cost,'public_charge') then
        toast:FireClient(player,'Charging penuh butuh Rp'..cost..'. Saldo belum cukup.')
        return
    end
    b:SetAttribute('Battery',max)
    player:SetAttribute('ChargingVisits',(player:GetAttribute('ChargingVisits') or 0)+1)
    player:SetAttribute('LastChargingStation',stationName)
    toast:FireClient(player,'Charging '..stationName..' selesai • Rp'..cost..' • 100%')
end

local hardenedPrompts=0
for i,s in ipairs(stations) do
    local pad=Instance.new('Part')
    pad.Name='PublicCharger_'..i
    pad.Size=Vector3.new(18,.45,13)
    pad.CFrame=CFrame.new(s.pos)
    pad.Anchored=true
    pad.CanCollide=false
    pad.CanTouch=false
    pad.CanQuery=true
    pad.Material=Enum.Material.Neon
    pad.Color=Color3.fromRGB(45,185,105)
    pad.Transparency=.25
    pad:SetAttribute('StationName',s.name)
    pad.Parent=network
    label(pad,'CHARGING • '..s.name)

    local p=Instance.new('ProximityPrompt')
    p.ActionText='Isi Baterai'
    p.ObjectText='E-Bike Charger • Rp'..PRICE_PER_UNIT..'/%'
    p.HoldDuration=PROMPT_HOLD_SECONDS
    p.MaxActivationDistance=PROMPT_MAX_DISTANCE
    p.RequiresLineOfSight=true
    p:SetAttribute('BecakEconomyInteractionSafety','v1.17')
    p:SetAttribute('BecakChargingStationName',s.name)
    p.Parent=pad

    local locked=false
    local token=0
    p.Triggered:Connect(function(player)
        if locked then return end
        locked=true
        token+=1
        local myToken=token
        p.Enabled=false
        player:SetAttribute('BecakPublicChargingGuard',s.name..':COOLDOWN')
        player:SetAttribute('BecakPublicChargingLastGuardedAt',Workspace:GetServerTimeNow())
        chargePlayer(player,s.name)
        task.delay(PROMPT_COOLDOWN_SECONDS,function()
            if token~=myToken then return end
            locked=false
            if p.Parent then p.Enabled=true end
            if player.Parent then player:SetAttribute('BecakPublicChargingGuard','READY') end
        end)
    end)
    hardenedPrompts+=1
end

local function setupPlayer(player)
    if player:GetAttribute('ChargingVisits')==nil then player:SetAttribute('ChargingVisits',0) end
    if player:GetAttribute('BecakPublicChargingGuard')==nil then player:SetAttribute('BecakPublicChargingGuard','READY') end
end
for _,p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerAdded:Connect(setupPlayer)

-- Preserve the v1.16 compatibility marker while exposing the additive safety enhancement separately.
Workspace:SetAttribute('ACC_BecakChargingNetwork','v1.16')
Workspace:SetAttribute('ACC_BecakChargingNetworkSafety','v1.17')
Workspace:SetAttribute('BecakChargingStationCount',#stations)
Workspace:SetAttribute('BecakEmergencyCharging','ON')
Workspace:SetAttribute('BecakChargingPricePerUnit',PRICE_PER_UNIT)
Workspace:SetAttribute('BecakPublicChargingPromptSafety','ON')
Workspace:SetAttribute('BecakPublicChargingPromptHardenedCount',hardenedPrompts)
Workspace:SetAttribute('BecakPublicChargingPromptHoldSeconds',PROMPT_HOLD_SECONDS)
Workspace:SetAttribute('BecakPublicChargingPromptMaxDistance',PROMPT_MAX_DISTANCE)
Workspace:SetAttribute('BecakPublicChargingPromptRequiresLineOfSight','ON')
Workspace:SetAttribute('BecakPublicChargingPromptCooldownSeconds',PROMPT_COOLDOWN_SECONDS)
print('[BECAK E-BIKE] charging network v1.17 ready • '..#stations..' stations • public prompt safety ON')
