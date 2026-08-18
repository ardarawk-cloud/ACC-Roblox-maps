local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Lighting = game:GetService("Lighting")

local Config = require(script.Parent:WaitForChild("GameConfig"))
local Store = DataStoreService:GetDataStore("WONDERPOCKET_PlayerData_v1")

local root = workspace:FindFirstChild("WONDERPOCKET") or Instance.new("Folder")
root.Name = "WONDERPOCKET"
root.Parent = workspace

local remotes = ReplicatedStorage:FindFirstChild("WONDERPOCKET_Remotes") or Instance.new("Folder")
remotes.Name = "WONDERPOCKET_Remotes"
remotes.Parent = ReplicatedStorage

local StateRemote = remotes:FindFirstChild("State") or Instance.new("RemoteEvent")
StateRemote.Name = "State"
StateRemote.Parent = remotes

local function part(name, size, position, color, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = Enum.Material.SmoothPlastic
    p.Parent = parent
    return p
end

local function buildWorld()
    if root:FindFirstChild("Generated") then return end
    local generated = Instance.new("Folder")
    generated.Name = "Generated"
    generated.Parent = root

    local base = part("PocketIsland", Vector3.new(220,8,220), Vector3.new(0,0,0), Color3.fromRGB(112,194,85), generated)
    base.Material = Enum.Material.Grass

    local square = part("WonderSquare", Vector3.new(100,2,100), Vector3.new(0,5,0), Color3.fromRGB(232,223,202), generated)
    square.Material = Enum.Material.Sandstone

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "WonderSpawn"
    spawn.Size = Vector3.new(12,1,12)
    spawn.Position = Vector3.new(0,7,0)
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Parent = generated

    local cottage = Instance.new("Model")
    cottage.Name = "Starter Cottage"
    cottage.Parent = generated
    part("Floor", Vector3.new(28,1,22), Vector3.new(52,6,20), Color3.fromRGB(235,213,174), cottage)
    part("WallBack", Vector3.new(28,14,1), Vector3.new(52,13,30.5), Color3.fromRGB(255,244,218), cottage)
    part("WallLeft", Vector3.new(1,14,22), Vector3.new(38.5,13,20), Color3.fromRGB(255,244,218), cottage)
    part("WallRight", Vector3.new(1,14,22), Vector3.new(65.5,13,20), Color3.fromRGB(255,244,218), cottage)
    part("Roof", Vector3.new(32,2,26), Vector3.new(52,21,20), Color3.fromRGB(232,92,132), cottage)

    local garden = Instance.new("Folder")
    garden.Name = "StarterGarden"
    garden.Parent = generated
    for i=1,6 do
        local x = -55 + ((i-1)%3)*12
        local z = 18 + math.floor((i-1)/3)*12
        local plot = part("Plot"..i, Vector3.new(9,1,9), Vector3.new(x,5,z), Color3.fromRGB(105,69,45), garden)
        plot:SetAttribute("Crop", "")
        plot:SetAttribute("ReadyAt", 0)
    end

    local wondi = Instance.new("Part")
    wondi.Name = "Bubbi"
    wondi.Shape = Enum.PartType.Ball
    wondi.Size = Vector3.new(5,5,5)
    wondi.Position = Vector3.new(15,9,5)
    wondi.Anchored = true
    wondi.Color = Color3.fromRGB(255,211,88)
    wondi.Parent = generated

    Lighting.Brightness = 2.2
    Lighting.ClockTime = 9.5
    Lighting.GlobalShadows = true
    Lighting.OutdoorAmbient = Color3.fromRGB(140,150,170)
    Lighting.Ambient = Color3.fromRGB(120,130,150)

    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
    atmosphere.Density = 0.22
    atmosphere.Haze = 1.2
    atmosphere.Glare = 0.1
    atmosphere.Parent = Lighting

    root:SetAttribute("BuildVersion", Config.Version)
end

local function defaultData()
    return {
        coins = Config.Economy.StartingCoins,
        stars = Config.Economy.StartingStars,
        level = 1,
        xp = 0,
        ownedWondies = {Config.Starter.Wondi},
        activeWondi = Config.Starter.Wondi,
        inventory = {[Config.Starter.Seed] = Config.Starter.SeedCount},
        lastSeen = os.time(),
        pocketBiome = Config.Starter.Biome,
        house = Config.Starter.House,
    }
end

local session = {}

local function loadPlayer(player)
    local data
    local ok, result = pcall(function()
        return Store:GetAsync("u_"..player.UserId)
    end)
    data = ok and result or nil
    if type(data) ~= "table" then data = defaultData() end

    local elapsed = math.clamp(os.time() - (tonumber(data.lastSeen) or os.time()), 0, Config.Gardening.OfflineGrowthCapSeconds)
    data.lastSeen = os.time()
    data.offlineSeconds = elapsed
    session[player] = data

    player:SetAttribute("Coins", data.coins or 0)
    player:SetAttribute("Stars", data.stars or 0)
    player:SetAttribute("ActiveWondi", data.activeWondi or Config.Starter.Wondi)
    player:SetAttribute("PocketBiome", data.pocketBiome or Config.Starter.Biome)
    StateRemote:FireClient(player, "INIT", data)
end

local function savePlayer(player)
    local data = session[player]
    if not data then return end
    data.coins = player:GetAttribute("Coins") or data.coins or 0
    data.stars = player:GetAttribute("Stars") or data.stars or 0
    data.activeWondi = player:GetAttribute("ActiveWondi") or data.activeWondi
    data.lastSeen = os.time()
    pcall(function()
        Store:SetAsync("u_"..player.UserId, data)
    end)
end

buildWorld()
Players.PlayerAdded:Connect(loadPlayer)
Players.PlayerRemoving:Connect(function(player)
    savePlayer(player)
    session[player] = nil
end)

game:BindToClose(function()
    for _, player in Players:GetPlayers() do
        savePlayer(player)
    end
end)

for _, player in Players:GetPlayers() do
    task.spawn(loadPlayer, player)
end

print("[WONDERPOCKET] Foundation loaded", Config.Version)
