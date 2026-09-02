local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ASCConfig = require(ReplicatedStorage:WaitForChild("ASCConfig"))
local GameplayConfig = require(ReplicatedStorage:WaitForChild("ASCGameplayConfig"))

local GameplayService = {}
GameplayService.Version = GameplayConfig.Version

local started = false
local shuttingDown = false
local profiles = {}
local cooldowns = {}
local store = DataStoreService:GetDataStore(GameplayConfig.DataStoreName)

local remotesFolder = ReplicatedStorage:FindFirstChild("ASC_Remotes")
if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "ASC_Remotes"
    remotesFolder.Parent = ReplicatedStorage
end

local function getOrCreateRemote(className, name)
    local existing = remotesFolder:FindFirstChild(name)
    if existing and existing.ClassName == className then
        return existing
    end
    if existing then
        existing:Destroy()
    end
    local remote = Instance.new(className)
    remote.Name = name
    remote.Parent = remotesFolder
    return remote
end

local statePush = getOrCreateRemote("RemoteEvent", "StatePush")
local toast = getOrCreateRemote("RemoteEvent", "Toast")
local dialogue = getOrCreateRemote("RemoteEvent", "Dialogue")
local requestState = getOrCreateRemote("RemoteFunction", "RequestState")

local function clone(value)
    if type(value) ~= "table" then
        return value
    end
    local out = {}
    for key, item in pairs(value) do
        out[key] = clone(item)
    end
    return out
end

local function levelFromRep(rep)
    return math.max(1, math.floor(math.max(0, rep) / GameplayConfig.LevelRepStep) + 1)
end

local function newProfile()
    return {
        SchemaVersion = GameplayConfig.SchemaVersion,
        Coins = GameplayConfig.StartingCoins,
        Rep = GameplayConfig.StartingRep,
        Level = 1,
        CompletedQuests = {},
        CreatedAt = os.time(),
        UpdatedAt = os.time(),
        Sessions = 0,
    }
end

local function reconcile(raw)
    local profile = newProfile()
    if type(raw) ~= "table" then
        return profile
    end

    if type(raw.Coins) == "number" then
        profile.Coins = math.max(0, math.floor(raw.Coins))
    end
    if type(raw.Rep) == "number" then
        profile.Rep = math.max(0, math.floor(raw.Rep))
    end
    if type(raw.CompletedQuests) == "table" then
        for questId, completed in pairs(raw.CompletedQuests) do
            if completed == true and GameplayConfig.Quests[questId] then
                profile.CompletedQuests[questId] = true
            end
        end
    end
    if type(raw.CreatedAt) == "number" then
        profile.CreatedAt = raw.CreatedAt
    end
    if type(raw.Sessions) == "number" then
        profile.Sessions = math.max(0, math.floor(raw.Sessions))
    end

    profile.Level = levelFromRep(profile.Rep)
    profile.SchemaVersion = GameplayConfig.SchemaVersion
    profile.UpdatedAt = os.time()
    return profile
end

local function currentQuestId(profile)
    for _, questId in ipairs(GameplayConfig.QuestOrder) do
        if profile.CompletedQuests[questId] ~= true then
            return questId
        end
    end
    return nil
end

local function publicState(player)
    local entry = profiles[player]
    if not entry then
        return {
            Ready = false,
            Persistent = false,
            Coins = 0,
            Rep = 0,
            Level = 1,
            Quest = nil,
            FoundationVersion = GameplayConfig.Version,
        }
    end

    local profile = entry.Data
    local questId = currentQuestId(profile)
    local quest = questId and GameplayConfig.Quests[questId] or nil

    return {
        Ready = true,
        Persistent = entry.Persistent,
        Coins = profile.Coins,
        Rep = profile.Rep,
        Level = profile.Level,
        Quest = quest and {
            Id = questId,
            Title = quest.Title,
            Objective = quest.Objective,
            RewardCoins = quest.RewardCoins,
            RewardRep = quest.RewardRep,
        } or nil,
        FoundationVersion = GameplayConfig.Version,
    }
end

local function ensureLeaderstats(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
    end

    local coins = leaderstats:FindFirstChild("ASC Coins")
    if not coins then
        coins = Instance.new("IntValue")
        coins.Name = "ASC Coins"
        coins.Parent = leaderstats
    end

    local rep = leaderstats:FindFirstChild("City Rep")
    if not rep then
        rep = Instance.new("IntValue")
        rep.Name = "City Rep"
        rep.Parent = leaderstats
    end

    return coins, rep
end

local function syncPlayer(player)
    local entry = profiles[player]
    if not entry then
        return
    end

    local profile = entry.Data
    profile.Level = levelFromRep(profile.Rep)
    local coinsValue, repValue = ensureLeaderstats(player)
    coinsValue.Value = profile.Coins
    repValue.Value = profile.Rep

    player:SetAttribute("ASC_ProfileReady", true)
    player:SetAttribute("ASC_ProfilePersistent", entry.Persistent)
    player:SetAttribute("ASC_Coins", profile.Coins)
    player:SetAttribute("ASC_Rep", profile.Rep)
    player:SetAttribute("ASC_Level", profile.Level)
    player:SetAttribute("ASC_FoundationVersion", GameplayConfig.Version)

    statePush:FireClient(player, publicState(player))
end

local function profileKey(player)
    return "u_" .. tostring(player.UserId)
end

local function loadProfile(player)
    player:SetAttribute("ASC_ProfileReady", false)
    player:SetAttribute("ASC_ProfilePersistent", false)

    local loadedData = nil
    local success = false
    local lastError = nil

    for attempt = 1, GameplayConfig.LoadRetries do
        local ok, result = pcall(function()
            return store:GetAsync(profileKey(player))
        end)
        if ok then
            loadedData = result
            success = true
            break
        end
        lastError = result
        task.wait(attempt)
    end

    if player.Parent ~= Players then
        return
    end

    local profile = reconcile(loadedData)
    profile.Sessions += 1
    profile.UpdatedAt = os.time()

    profiles[player] = {
        Data = profile,
        Persistent = success,
        Dirty = true,
        LastSave = 0,
    }

    syncPlayer(player)

    if success then
        toast:FireClient(player, "Profile ready", "Progress will save automatically.")
    else
        warn("[ASC V1.0] DataStore load failed; session-only profile for", player.UserId, lastError)
        toast:FireClient(player, "Save temporarily unavailable", "This session will not overwrite your cloud progress.")
    end
end

local function snapshot(entry)
    local data = clone(entry.Data)
    data.SchemaVersion = GameplayConfig.SchemaVersion
    data.Level = levelFromRep(data.Rep)
    data.UpdatedAt = os.time()
    return data
end

local function saveProfile(player, reason)
    local entry = profiles[player]
    if not entry or not entry.Persistent or not entry.Dirty then
        return true
    end

    local payload = snapshot(entry)
    local success = false
    local lastError = nil

    for attempt = 1, GameplayConfig.SaveRetries do
        local ok, result = pcall(function()
            return store:UpdateAsync(profileKey(player), function(_old)
                return payload
            end)
        end)
        if ok then
            success = true
            break
        end
        lastError = result
        task.wait(attempt)
    end

    if success then
        entry.Dirty = false
        entry.LastSave = os.time()
        entry.Data.UpdatedAt = payload.UpdatedAt
        return true
    end

    warn("[ASC V1.0] DataStore save failed", player.UserId, reason, lastError)
    return false
end

local function isInsideDistrict(position, districtName)
    local district = ASCConfig.World.Districts[districtName]
    if not district then
        return false
    end
    local halfX = district.Size.X * 0.5
    local halfZ = district.Size.Z * 0.5
    return math.abs(position.X - district.Center.X) <= halfX
        and math.abs(position.Z - district.Center.Z) <= halfZ
end

function GameplayService.GetState(player)
    return publicState(player)
end

function GameplayService.ShowDialogue(player, speaker, text)
    if player and player.Parent == Players then
        dialogue:FireClient(player, {
            Speaker = tostring(speaker or "AFTER SCHOOL CITY"),
            Text = tostring(text or ""),
        })
    end
end

function GameplayService.Award(player, coins, rep, reason)
    local entry = profiles[player]
    if not entry then
        return false, "PROFILE_NOT_READY"
    end

    coins = math.max(0, math.floor(tonumber(coins) or 0))
    rep = math.max(0, math.floor(tonumber(rep) or 0))
    entry.Data.Coins += coins
    entry.Data.Rep += rep
    entry.Data.Level = levelFromRep(entry.Data.Rep)
    entry.Data.UpdatedAt = os.time()
    entry.Dirty = true
    syncPlayer(player)

    if coins > 0 or rep > 0 then
        toast:FireClient(player, tostring(reason or "Reward earned"), string.format("+%d Coins  +%d Rep", coins, rep))
    end
    return true
end

function GameplayService.CanUseCooldown(player, key, seconds)
    local now = os.clock()
    local playerCooldowns = cooldowns[player]
    if not playerCooldowns then
        playerCooldowns = {}
        cooldowns[player] = playerCooldowns
    end
    local untilTime = playerCooldowns[key] or 0
    if now < untilTime then
        return false, untilTime - now
    end
    playerCooldowns[key] = now + math.max(0, tonumber(seconds) or 0)
    return true, 0
end

function GameplayService.CompleteQuest(player, questId)
    local entry = profiles[player]
    if not entry then
        return false, "PROFILE_NOT_READY"
    end

    local profile = entry.Data
    if currentQuestId(profile) ~= questId then
        return false, "QUEST_NOT_ACTIVE"
    end
    if profile.CompletedQuests[questId] == true then
        return false, "ALREADY_COMPLETE"
    end

    local quest = GameplayConfig.Quests[questId]
    if not quest then
        return false, "UNKNOWN_QUEST"
    end

    profile.CompletedQuests[questId] = true
    profile.Coins += quest.RewardCoins
    profile.Rep += quest.RewardRep
    profile.Level = levelFromRep(profile.Rep)
    profile.UpdatedAt = os.time()
    entry.Dirty = true
    syncPlayer(player)

    toast:FireClient(player, quest.Title .. " complete", string.format("+%d Coins  +%d Rep", quest.RewardCoins, quest.RewardRep))

    local nextQuestId = currentQuestId(profile)
    if nextQuestId then
        local nextQuest = GameplayConfig.Quests[nextQuestId]
        task.delay(1.2, function()
            if player.Parent == Players then
                GameplayService.ShowDialogue(player, "CITY GUIDE", nextQuest.Objective)
            end
        end)
    else
        task.delay(1.2, function()
            if player.Parent == Players then
                GameplayService.ShowDialogue(player, "CITY GUIDE", "Exploration complete. New activities are coming next.")
            end
        end)
    end

    return true
end

local function questTrackerLoop()
    while not shuttingDown do
        for player, entry in pairs(profiles) do
            if player.Parent == Players and entry then
                local questId = currentQuestId(entry.Data)
                local quest = questId and GameplayConfig.Quests[questId] or nil
                if quest and quest.District then
                    local character = player.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    if root and isInsideDistrict(root.Position, quest.District) then
                        GameplayService.CompleteQuest(player, questId)
                    end
                end
            end
        end
        task.wait(1)
    end
end

local function autosaveLoop()
    while not shuttingDown do
        task.wait(GameplayConfig.AutosaveSeconds)
        if shuttingDown then
            break
        end
        for player in pairs(profiles) do
            if player.Parent == Players then
                task.spawn(saveProfile, player, "AUTOSAVE")
            end
        end
    end
end

function GameplayService.Start()
    if started then
        return
    end
    started = true

    requestState.OnServerInvoke = function(player)
        return publicState(player)
    end

    Players.PlayerAdded:Connect(function(player)
        task.spawn(loadProfile, player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        saveProfile(player, "PLAYER_REMOVING")
        profiles[player] = nil
        cooldowns[player] = nil
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(loadProfile, player)
    end

    task.spawn(questTrackerLoop)
    task.spawn(autosaveLoop)

    game:BindToClose(function()
        shuttingDown = true
        local pending = 0
        for player in pairs(profiles) do
            pending += 1
            task.spawn(function()
                saveProfile(player, "SERVER_SHUTDOWN")
                pending -= 1
            end)
        end

        local deadline = os.clock() + 8
        while pending > 0 and os.clock() < deadline do
            task.wait(0.1)
        end
    end)

    workspace:SetAttribute("ASC_GameplayFoundationVersion", GameplayConfig.Version)
    workspace:SetAttribute("ASC_GameplayFoundationReady", true)
    print("[ASC V1.0] Gameplay Foundation ready", GameplayConfig.Version)
end

return GameplayService
