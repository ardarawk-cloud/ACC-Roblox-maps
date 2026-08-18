local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")
local Lighting = game:GetService("Lighting")

local Config = require(script.Parent:WaitForChild("GameConfig"))
-- Keep the existing store name so earlier player data migrates in-place.
local Store = DataStoreService:GetDataStore("WONDERPOCKET_PlayerData_v2")

local DATA_SCHEMA = 4
local AUTOSAVE_SECONDS = (Config.Runtime and Config.Runtime.AutosaveSeconds) or 90
local MAX_RETRIES = (Config.Runtime and Config.Runtime.DataStoreRetries) or 4

local root = workspace:FindFirstChild("WONDERPOCKET") or Instance.new("Folder")
root.Name = "WONDERPOCKET"
root.Parent = workspace

local remotes = ReplicatedStorage:FindFirstChild("WONDERPOCKET_Remotes") or Instance.new("Folder")
remotes.Name = "WONDERPOCKET_Remotes"
remotes.Parent = ReplicatedStorage

local StateRemote = remotes:FindFirstChild("State") or Instance.new("RemoteEvent")
StateRemote.Name = "State"
StateRemote.Parent = remotes

local CriticalSave = ServerStorage:FindFirstChild("WONDERPOCKET_CriticalSave") or Instance.new("BindableEvent")
CriticalSave.Name = "WONDERPOCKET_CriticalSave"
CriticalSave.Parent = ServerStorage

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
        schemaVersion = DATA_SCHEMA,
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
        onboardingComplete = false,
        tutorialMetWondi = false,
        plantedCount = 0,
        harvestCount = 0,
        placedCount = 0,
        questStarter = "HARVEST_3",
        questStarterRewarded = false,
        lastDailyDay = 0,
        lastWeeklyWeek = 0,
        dailyQuestProgress = 0,
        weeklyQuestProgress = 0,
    }
end

local function migrateData(data)
    local defaults = defaultData()
    if type(data) ~= "table" then return defaults end
    for key, value in pairs(defaults) do
        if data[key] == nil then data[key] = value end
    end
    if type(data.inventory) ~= "table" then data.inventory = {} end
    if data.inventory[Config.Starter.Seed] == nil then
        data.inventory[Config.Starter.Seed] = Config.Starter.SeedCount
    end
    data.inventory[Config.Starter.Seed] = math.max(0, math.floor(tonumber(data.inventory[Config.Starter.Seed]) or 0))
    data.schemaVersion = DATA_SCHEMA
    if data.questStarterRewarded == true then data.questStarter = "COMPLETE" end
    return data
end

local session = {}
local revision = {}
local savedRevision = {}
local saving = {}
local forcePending = {}
local connections = {}

local function retry(label, fn)
    local lastErr
    for attempt=1,MAX_RETRIES do
        local ok, result = pcall(fn)
        if ok then return true, result end
        lastErr = result
        warn(string.format("[WONDERPOCKET] %s attempt %d failed: %s", label, attempt, tostring(result)))
        task.wait(math.min(2^(attempt-1), 6))
    end
    return false, lastErr
end

local function markDirty(player)
    if session[player] then
        revision[player] = (revision[player] or 0) + 1
    end
end

local function syncAttributesToData(player, data)
    data.coins = tonumber(player:GetAttribute("Coins")) or data.coins or 0
    data.stars = tonumber(player:GetAttribute("Stars")) or data.stars or 0
    data.activeWondi = player:GetAttribute("ActiveWondi") or data.activeWondi or Config.Starter.Wondi
    data.pocketBiome = player:GetAttribute("PocketBiome") or data.pocketBiome or Config.Starter.Biome
    data.onboardingComplete = player:GetAttribute("WP_OnboardingComplete") == true
    data.tutorialMetWondi = player:GetAttribute("WP_Tutorial_MetWondi") == true
    data.plantedCount = math.max(0, math.floor(tonumber(player:GetAttribute("WP_PlantedCount")) or data.plantedCount or 0))
    data.harvestCount = math.max(0, math.floor(tonumber(player:GetAttribute("WP_HarvestCount")) or data.harvestCount or 0))
    data.placedCount = math.max(0, math.floor(tonumber(player:GetAttribute("WP_PlacedCount")) or data.placedCount or 0))
    data.questStarter = tostring(player:GetAttribute("WP_Quest_Starter") or data.questStarter or "HARVEST_3")
    data.questStarterRewarded = player:GetAttribute("WP_QuestStarterRewarded") == true
    data.lastDailyDay = tonumber(player:GetAttribute("WP_LastDailyDay")) or data.lastDailyDay or 0
    data.lastWeeklyWeek = tonumber(player:GetAttribute("WP_LastWeeklyWeek")) or data.lastWeeklyWeek or 0
    data.dailyQuestProgress = math.max(0, math.floor(tonumber(player:GetAttribute("WP_DailyQuestProgress")) or data.dailyQuestProgress or 0))
    data.weeklyQuestProgress = math.max(0, math.floor(tonumber(player:GetAttribute("WP_WeeklyQuestProgress")) or data.weeklyQuestProgress or 0))
    if type(data.inventory) ~= "table" then data.inventory = {} end
    data.inventory[Config.Starter.Seed] = math.max(0, math.floor(tonumber(player:GetAttribute("CarrotSeed")) or data.inventory[Config.Starter.Seed] or 0))
    data.lastSeen = os.time()
    data.schemaVersion = DATA_SCHEMA
end

local function savePlayer(player, force)
    local data = session[player]
    if not data then return false end

    if saving[player] then
        if force then forcePending[player] = true end
        return false
    end

    local currentRevision = revision[player] or 0
    if not force and currentRevision <= (savedRevision[player] or 0) then return true end

    saving[player] = true
    syncAttributesToData(player, data)
    local snapshot = table.clone(data)
    snapshot.inventory = table.clone(data.inventory or {})
    local targetRevision = currentRevision

    local ok = retry("save u_"..player.UserId, function()
        Store:UpdateAsync("u_"..player.UserId, function()
            return snapshot
        end)
    end)

    saving[player] = nil
    if ok then
        savedRevision[player] = math.max(savedRevision[player] or 0, targetRevision)
        player:SetAttribute("WP_DataSaveHealthy", true)
    else
        player:SetAttribute("WP_DataSaveHealthy", false)
    end

    local needsAnother = forcePending[player] == true or (revision[player] or 0) > (savedRevision[player] or 0)
    local nextForce = forcePending[player] == true
    forcePending[player] = nil
    if needsAnother and player.Parent and session[player] then
        task.defer(savePlayer, player, nextForce)
    end

    return ok
end

local function flushPlayer(player)
    local deadline = os.clock() + 10
    if saving[player] then forcePending[player] = true end
    while saving[player] and os.clock() < deadline do task.wait(.1) end
    if session[player] then savePlayer(player, true) end
    while saving[player] and os.clock() < deadline do task.wait(.1) end
end

local function watchAttribute(player, attribute)
    local connection = player:GetAttributeChangedSignal(attribute):Connect(function()
        markDirty(player)
    end)
    table.insert(connections[player], connection)
end

local function loadPlayer(player)
    player:SetAttribute("WP_DataLoaded", false)
    player:SetAttribute("WP_DataSaveHealthy", true)

    local ok, result = retry("load u_"..player.UserId, function()
        return Store:GetAsync("u_"..player.UserId)
    end)
    local data = migrateData(ok and result or nil)
    if not ok then player:SetAttribute("WP_DataSaveHealthy", false) end

    local now = os.time()
    local elapsed = math.clamp(now - (tonumber(data.lastSeen) or now), 0, Config.Gardening.OfflineGrowthCapSeconds)
    data.offlineSeconds = elapsed
    data.lastSeen = now
    session[player] = data
    revision[player] = 0
    savedRevision[player] = 0
    connections[player] = {}

    player:SetAttribute("Coins", tonumber(data.coins) or 0)
    player:SetAttribute("Stars", tonumber(data.stars) or 0)
    player:SetAttribute("ActiveWondi", data.activeWondi or Config.Starter.Wondi)
    player:SetAttribute("PocketBiome", data.pocketBiome or Config.Starter.Biome)
    player:SetAttribute("CarrotSeed", math.max(0, math.floor(tonumber(data.inventory and data.inventory[Config.Starter.Seed]) or Config.Starter.SeedCount)))
    player:SetAttribute("WP_OnboardingComplete", data.onboardingComplete == true)
    player:SetAttribute("WP_Tutorial_MetWondi", data.tutorialMetWondi == true)
    player:SetAttribute("WP_PlantedCount", math.max(0, math.floor(tonumber(data.plantedCount) or 0)))
    player:SetAttribute("WP_HarvestCount", math.max(0, math.floor(tonumber(data.harvestCount) or 0)))
    player:SetAttribute("WP_PlacedCount", math.max(0, math.floor(tonumber(data.placedCount) or 0)))
    player:SetAttribute("WP_Quest_Starter", data.questStarterRewarded == true and "COMPLETE" or tostring(data.questStarter or "HARVEST_3"))
    player:SetAttribute("WP_QuestStarterRewarded", data.questStarterRewarded == true)
    player:SetAttribute("WP_OfflineSeconds", elapsed)
    player:SetAttribute("WP_LastDailyDay", tonumber(data.lastDailyDay) or 0)
    player:SetAttribute("WP_LastWeeklyWeek", tonumber(data.lastWeeklyWeek) or 0)
    player:SetAttribute("WP_DailyQuestProgress", math.max(0, math.floor(tonumber(data.dailyQuestProgress) or 0)))
    player:SetAttribute("WP_WeeklyQuestProgress", math.max(0, math.floor(tonumber(data.weeklyQuestProgress) or 0)))

    for _, attribute in ipairs({
        "Coins","Stars","ActiveWondi","PocketBiome","CarrotSeed","WP_OnboardingComplete",
        "WP_Tutorial_MetWondi","WP_PlantedCount","WP_HarvestCount","WP_PlacedCount",
        "WP_Quest_Starter","WP_QuestStarterRewarded","WP_LastDailyDay","WP_LastWeeklyWeek",
        "WP_DailyQuestProgress","WP_WeeklyQuestProgress",
    }) do
        watchAttribute(player, attribute)
    end

    player:SetAttribute("WP_DataLoaded", true)
    StateRemote:FireClient(player, "INIT", data)
end

CriticalSave.Event:Connect(function(player)
    if typeof(player) == "Instance" and player:IsA("Player") and session[player] then
        task.spawn(savePlayer, player, true)
    end
end)

buildWorld()
Players.PlayerAdded:Connect(loadPlayer)
Players.PlayerRemoving:Connect(function(player)
    flushPlayer(player)
    for _, connection in ipairs(connections[player] or {}) do connection:Disconnect() end
    connections[player] = nil
    session[player] = nil
    revision[player] = nil
    savedRevision[player] = nil
    saving[player] = nil
    forcePending[player] = nil
end)

for _, player in Players:GetPlayers() do task.spawn(loadPlayer, player) end

task.spawn(function()
    while task.wait(AUTOSAVE_SECONDS) do
        for _, player in Players:GetPlayers() do
            task.spawn(savePlayer, player, false)
        end
    end
end)

game:BindToClose(function()
    local players = Players:GetPlayers()
    local remaining = #players
    for _, player in ipairs(players) do
        task.spawn(function()
            flushPlayer(player)
            remaining -= 1
        end)
    end
    local deadline = os.clock() + 12
    while remaining > 0 and os.clock() < deadline do task.wait(.1) end
end)

print("[WONDERPOCKET] v1.2 seed-persistent revision-safe foundation loaded", Config.Version)
