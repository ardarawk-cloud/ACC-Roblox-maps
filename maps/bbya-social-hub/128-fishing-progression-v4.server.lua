-- BBYA SOCIAL HUB — FISHING PROGRESSION v4
-- Original progression layer inspired by the strengths of modern fishing collection games:
-- cast quality, persistent Fish Index, mutations, size grades, biome discovery,
-- rotating lake events, secret variants, angler XP and rod mastery.
-- Additive over stable Fishing Core v2; does not replace economy, rarity roll, audio, roles or global Lighting.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 35)
if not root then return end
local district = root:WaitForChild("PremiumFishingDistrictV2", 35)
if not district then return end

local v4Folder = ReplicatedStorage:FindFirstChild("BBYAFishingV4") or Instance.new("Folder")
v4Folder.Name = "BBYAFishingV4"
v4Folder.Parent = ReplicatedStorage

local actionRemote = v4Folder:FindFirstChild("Action") or Instance.new("RemoteEvent")
actionRemote.Name = "Action"
actionRemote.Parent = v4Folder

local stateRemote = v4Folder:FindFirstChild("State") or Instance.new("RemoteEvent")
stateRemote.Name = "State"
stateRemote.Parent = v4Folder

local store = DataStoreService:GetDataStore("BBYA_FISHING_PROGRESSION_V4")

local SPECIES = {
    {name="Moon Carp", rarity="COMMON", max=2.4},
    {name="Azure Gourami", rarity="COMMON", max=1.9},
    {name="Jade Peacock Bass", rarity="UNCOMMON", max=4.8},
    {name="Redtail Giant", rarity="UNCOMMON", max=8.5},
    {name="Royal Koi", rarity="RARE", max=5.0},
    {name="Sapphire Barramundi", rarity="RARE", max=11.0},
    {name="Crimson Arowana", rarity="EPIC", max=7.2},
    {name="Obsidian Ray", rarity="EPIC", max=15.0},
    {name="Golden Mahseer", rarity="LEGENDARY", max=18.0},
    {name="Aurora Arapaima", rarity="LEGENDARY", max=31.0},
    {name="Celestial Koi", rarity="MYTHIC", max=10.0},
    {name="Phantom Leviathan", rarity="MYTHIC", max=55.0},
}

local SPECIES_BY_NAME = {}
for _, fish in ipairs(SPECIES) do
    SPECIES_BY_NAME[fish.name] = fish
end

local MUTATIONS = {
    NORMAL={label="NORMAL", mult=1.00, color=Color3.fromRGB(205,210,214)},
    GOLDEN={label="GOLDEN", mult=1.55, color=Color3.fromRGB(244,190,70)},
    MOONLIT={label="MOONLIT", mult=1.65, color=Color3.fromRGB(151,190,255)},
    LOTUS={label="LOTUS", mult=1.60, color=Color3.fromRGB(239,112,178)},
    CRYSTAL={label="CRYSTAL", mult=1.80, color=Color3.fromRGB(99,225,235)},
    SHADOW={label="SHADOW", mult=1.75, color=Color3.fromRGB(121,82,186)},
    AURORA={label="AURORA", mult=1.90, color=Color3.fromRGB(79,229,201)},
    CELESTIAL={label="CELESTIAL", mult=2.20, color=Color3.fromRGB(247,218,127)},
    ABYSSAL={label="ABYSSAL", mult=2.35, color=Color3.fromRGB(84,74,184)},
}

local BIOMES = {
    PUBLIC={label="PUBLIC LAKE", mutations={"GOLDEN","SHADOW"}},
    WATER_GARDEN={label="WATER GARDEN", mutations={"LOTUS","GOLDEN","AURORA"}},
    MOON_COVE={label="MOON COVE", mutations={"MOONLIT","CELESTIAL","SHADOW"}},
    MOONFALL={label="MOONFALL GROTTO", mutations={"CRYSTAL","AURORA","CELESTIAL"}},
    DEEP={label="DEEP WATER", mutations={"ABYSSAL","SHADOW","AURORA"}},
}

local EVENTS = {
    {id="CALM", label="CALM WATERS", mutation=nil, bonus=0.00},
    {id="GOLDEN", label="GOLDEN CURRENT", mutation="GOLDEN", bonus=0.09},
    {id="MOON", label="MOON SURGE", mutation="MOONLIT", bonus=0.09},
    {id="CRYSTAL", label="CRYSTAL RAIN", mutation="CRYSTAL", bonus=0.09},
    {id="DEEP", label="DEEP CURRENT", mutation="ABYSSAL", bonus=0.10},
}
local EVENT_SECONDS = 480

local RARITY_XP = {COMMON=10,UNCOMMON=14,RARE=22,EPIC=38,LEGENDARY=70,MYTHIC=140}
local RARITY_MUTATION_BONUS = {COMMON=0,UNCOMMON=.015,RARE=.035,EPIC=.06,LEGENDARY=.09,MYTHIC=.12}
local QUALITY_BONUS = {GOOD=0,GREAT=.035,PERFECT=.085}
local QUALITY_XP = {GOOD=1,GREAT=1.15,PERFECT=1.35}
local SIZE_XP = {STANDARD=1,LARGE=1.18,GIANT=1.48,TITAN=1.90}

local dataByUser = {}
local castQuality = {}
local lastActionAt = {}
local catchSeen = setmetatable({}, {__mode="k"})
local currentEventId = nil

local function defaultData()
    return {
        xp=0,
        catches=0,
        species={},
        variants={},
        mutations={},
        visited={},
        mastery={},
        secrets={},
    }
end

local function normalize(raw)
    local d = defaultData()
    if type(raw) ~= "table" then return d end
    d.xp = math.max(0, math.floor(tonumber(raw.xp) or 0))
    d.catches = math.max(0, math.floor(tonumber(raw.catches) or 0))
    for _, key in ipairs({"species","variants","mutations","visited","mastery","secrets"}) do
        if type(raw[key]) == "table" then d[key] = raw[key] end
    end
    return d
end

local function countKeys(t)
    local n = 0
    if type(t) == "table" then
        for _ in pairs(t) do n += 1 end
    end
    return n
end

local function anglerLevel(xp)
    return math.max(1, math.floor(math.sqrt(math.max(0,xp) / 50)) + 1)
end

local function masteryLevel(catches)
    catches = tonumber(catches) or 0
    if catches >= 150 then return 5 end
    if catches >= 75 then return 4 end
    if catches >= 30 then return 3 end
    if catches >= 10 then return 2 end
    return 1
end

local function anglerTitle(level, secretCount)
    if secretCount >= 5 or level >= 12 then return "BBYA MASTER ANGLER" end
    if level >= 9 then return "DEEPWATER ACE" end
    if level >= 6 then return "MOON HUNTER" end
    if level >= 3 then return "LAKE REGULAR" end
    return "NEW ANGLER"
end

local function currentEvent()
    local now = os.time()
    local index = (math.floor(now / EVENT_SECONDS) % #EVENTS) + 1
    local remaining = EVENT_SECONDS - (now % EVENT_SECONDS)
    return EVENTS[index], remaining
end

local function determineBiome(position)
    if not position then return "PUBLIC" end
    if position.Z > 831 and math.abs(position.X) < 40 then
        return "MOONFALL"
    end
    if position.X > 56 and position.Z > 778 then
        return "MOON_COVE"
    end
    if math.abs(position.X) < 22 and position.Z > 728 and position.Z < 825 then
        return "DEEP"
    end
    if position.X < -56 and position.Z > 786 then
        return "DEEP"
    end
    if math.abs(position.X) > 24 and position.Z > 780 and position.Z < 838 then
        return "WATER_GARDEN"
    end
    return "PUBLIC"
end

local function isNearDistrict(player)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local dx = hrp.Position.X
    local dz = hrp.Position.Z - 790
    return dx*dx + dz*dz <= 235*235
end

local function publishAttributes(player, d)
    local speciesCount = countKeys(d.species)
    local variantCount = countKeys(d.variants)
    local level = anglerLevel(d.xp)
    local skin = player:GetAttribute("BBYAFishingSkin") or "Graphite Core"
    local masteryCatches = tonumber(d.mastery[skin]) or 0
    player:SetAttribute("BBYAAnglerXP", d.xp)
    player:SetAttribute("BBYAAnglerLevel", level)
    player:SetAttribute("BBYAFishIndex", speciesCount)
    player:SetAttribute("BBYAFishIndexTotal", #SPECIES)
    player:SetAttribute("BBYAVariantIndex", variantCount)
    player:SetAttribute("BBYARodMastery", masteryLevel(masteryCatches))
    player:SetAttribute("BBYAAnglerTitle", anglerTitle(level, countKeys(d.secrets)))
end

local function saveData(player)
    local d = dataByUser[player.UserId]
    if not d then return end
    pcall(function()
        store:SetAsync("u_"..player.UserId, d)
    end)
end

local function loadData(player)
    local raw
    local ok = pcall(function()
        raw = store:GetAsync("u_"..player.UserId)
    end)
    local d = normalize(ok and raw or nil)
    dataByUser[player.UserId] = d
    publishAttributes(player, d)
end

local function journalSnapshot(player)
    local d = dataByUser[player.UserId]
    if not d then return nil end
    local species = {}
    for _, fish in ipairs(SPECIES) do
        local record = d.species[fish.name]
        table.insert(species, {
            name=fish.name,
            rarity=fish.rarity,
            discovered=type(record)=="table",
            count=type(record)=="table" and math.max(0,math.floor(tonumber(record.count) or 0)) or 0,
            best=type(record)=="table" and math.max(0,tonumber(record.best) or 0) or 0,
            bestMutation=type(record)=="table" and tostring(record.bestMutation or "NORMAL") or "",
        })
    end
    local event, remaining = currentEvent()
    local skin = player:GetAttribute("BBYAFishingSkin") or "Graphite Core"
    local masteryCatches = tonumber(d.mastery[skin]) or 0
    return {
        xp=d.xp,
        level=anglerLevel(d.xp),
        title=anglerTitle(anglerLevel(d.xp), countKeys(d.secrets)),
        catches=d.catches,
        speciesCount=countKeys(d.species),
        speciesTotal=#SPECIES,
        variantCount=countKeys(d.variants),
        mutationCount=countKeys(d.mutations),
        secretCount=countKeys(d.secrets),
        visitedCount=countKeys(d.visited),
        rodSkin=skin,
        rodMastery=masteryLevel(masteryCatches),
        rodMasteryCatches=masteryCatches,
        event={id=event.id,label=event.label,remaining=remaining},
        species=species,
    }
end

local function sendSnapshot(player)
    local snap = journalSnapshot(player)
    if snap then stateRemote:FireClient(player, "Snapshot", snap) end
end

local function getSizeGrade(fishName, weight)
    local spec = SPECIES_BY_NAME[fishName]
    if not spec or not spec.max or spec.max <= 0 then return "STANDARD" end
    local ratio = math.clamp((tonumber(weight) or 0) / spec.max, 0, 2)
    if ratio >= .96 then return "TITAN" end
    if ratio >= .82 then return "GIANT" end
    if ratio >= .60 then return "LARGE" end
    return "STANDARD"
end

local function weightedMutation(player, biomeKey, rarity)
    local event = currentEvent()
    local qualityInfo = castQuality[player]
    local quality = qualityInfo and qualityInfo.expires > os.clock() and qualityInfo.quality or "GOOD"
    local chance = .11 + (RARITY_MUTATION_BONUS[rarity] or 0) + (QUALITY_BONUS[quality] or 0) + (event.bonus or 0)
    if biomeKey ~= "PUBLIC" then chance += .025 end
    chance = math.clamp(chance, .08, .48)
    if math.random() > chance then return "NORMAL", quality end

    local pool = {}
    local biome = BIOMES[biomeKey] or BIOMES.PUBLIC
    for _, mutation in ipairs(biome.mutations) do
        table.insert(pool, mutation)
    end
    if event.mutation then
        table.insert(pool, event.mutation)
        table.insert(pool, event.mutation)
    end
    if rarity == "LEGENDARY" or rarity == "MYTHIC" then
        table.insert(pool, "CELESTIAL")
        if biomeKey == "DEEP" then table.insert(pool, "ABYSSAL") end
    end
    if #pool == 0 then return "NORMAL", quality end
    return pool[math.random(1,#pool)], quality
end

local function specialVariantName(fishName, mutation)
    if mutation == "NORMAL" then return fishName, false end
    local combos = {
        ["Royal Koi|LOTUS"]="Lotus Crown Koi",
        ["Royal Koi|CELESTIAL"]="Celestial Royal Koi",
        ["Crimson Arowana|CRYSTAL"]="Crystal Arowana",
        ["Phantom Leviathan|ABYSSAL"]="Abyssal Leviathan",
        ["Aurora Arapaima|AURORA"]="Aurora King Arapaima",
        ["Golden Mahseer|GOLDEN"]="Sunken Gold Mahseer",
        ["Celestial Koi|MOONLIT"]="Moonborn Koi",
        ["Obsidian Ray|SHADOW"]="Eclipse Ray",
    }
    local key = fishName.."|"..mutation
    if combos[key] then return combos[key], true end
    return string.gsub(mutation, "_", " ").." "..fishName, false
end

local function mutationRank(name)
    local rank = {NORMAL=1,GOLDEN=2,MOONLIT=3,LOTUS=3,CRYSTAL=4,SHADOW=4,AURORA=5,CELESTIAL=6,ABYSSAL=7}
    return rank[name] or 1
end

local function applyMutationVisual(model, mutation, sizeGrade)
    local spec = MUTATIONS[mutation] or MUTATIONS.NORMAL
    model:SetAttribute("MutationV4", mutation)
    model:SetAttribute("SizeGradeV4", sizeGrade)
    model:SetAttribute("ProgressionV4", true)

    if sizeGrade == "GIANT" then
        pcall(function() model:ScaleTo(model:GetScale() * 1.10) end)
    elseif sizeGrade == "TITAN" then
        pcall(function() model:ScaleTo(model:GetScale() * 1.20) end)
    end

    if mutation == "NORMAL" then return end

    local index = 0
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            index += 1
            if mutation == "GOLDEN" then
                part.Color = index % 3 == 0 and Color3.fromRGB(255,225,139) or spec.color
                if index % 3 == 0 then part.Material = Enum.Material.Metal end
            elseif mutation == "MOONLIT" then
                part.Color = index % 2 == 0 and Color3.fromRGB(196,214,255) or spec.color
            elseif mutation == "LOTUS" then
                part.Color = index % 3 == 0 and Color3.fromRGB(105,176,116) or spec.color
            elseif mutation == "CRYSTAL" then
                part.Color = spec.color
                part.Material = index % 2 == 0 and Enum.Material.Glass or Enum.Material.Neon
                part.Transparency = math.max(part.Transparency, index % 2 == 0 and .16 or 0)
            elseif mutation == "SHADOW" then
                part.Color = index % 3 == 0 and spec.color or Color3.fromRGB(24,22,35)
            elseif mutation == "AURORA" then
                part.Color = index % 2 == 0 and Color3.fromRGB(153,111,235) or spec.color
                if index % 4 == 0 then part.Material = Enum.Material.Neon end
            elseif mutation == "CELESTIAL" then
                part.Color = index % 2 == 0 and Color3.fromRGB(245,241,222) or spec.color
                if index % 3 == 0 then part.Material = Enum.Material.Neon end
            elseif mutation == "ABYSSAL" then
                part.Color = index % 3 == 0 and Color3.fromRGB(76,83,211) or Color3.fromRGB(29,22,58)
                if index % 4 == 0 then part.Material = Enum.Material.Neon end
            end
        end
    end

    local highlight = model:FindFirstChild("ProgressionHighlightV4")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ProgressionHighlightV4"
        highlight.FillTransparency = .88
        highlight.OutlineTransparency = .14
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
        highlight.Parent = model
    end
    highlight.FillColor = spec.color
    highlight.OutlineColor = spec.color
end

local function nearestPlayer(position)
    local winner, best = nil, 18
    for _, player in ipairs(Players:GetPlayers()) do
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local distance = (hrp.Position - position).Magnitude
            if distance < best then
                best = distance
                winner = player
            end
        end
    end
    return winner
end

local function awardCatch(player, model)
    if catchSeen[model] then return end
    catchSeen[model] = true
    model:SetAttribute("ProcessedProgressionV4", true)

    local fishName = model:GetAttribute("FishName")
    local rarity = model:GetAttribute("Rarity")
    local weight = tonumber(model:GetAttribute("Weight"))
    if type(fishName) ~= "string" or not SPECIES_BY_NAME[fishName] or type(rarity) ~= "string" or not weight then return end

    local d = dataByUser[player.UserId]
    if not d then return end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local biomeKey = determineBiome(hrp.Position)
    local biome = BIOMES[biomeKey] or BIOMES.PUBLIC
    local mutation, quality = weightedMutation(player, biomeKey, rarity)
    local sizeGrade = getSizeGrade(fishName, weight)
    local variantName, secret = specialVariantName(fishName, mutation)
    local event = currentEvent()

    local firstSpecies = d.species[fishName] == nil
    local variantKey = fishName.."|"..mutation
    local firstVariant = d.variants[variantKey] == nil
    local firstMutation = mutation ~= "NORMAL" and d.mutations[mutation] == nil
    local firstSecret = secret and d.secrets[variantName] == nil

    local record = d.species[fishName]
    if type(record) ~= "table" then record = {count=0,best=0,bestMutation="NORMAL"};d.species[fishName]=record end
    record.count = math.max(0,math.floor(tonumber(record.count) or 0)) + 1
    record.best = math.max(tonumber(record.best) or 0, weight)
    if mutationRank(mutation) >= mutationRank(record.bestMutation or "NORMAL") then record.bestMutation = mutation end

    d.variants[variantKey] = math.max(0,math.floor(tonumber(d.variants[variantKey]) or 0)) + 1
    if mutation ~= "NORMAL" then d.mutations[mutation] = math.max(0,math.floor(tonumber(d.mutations[mutation]) or 0)) + 1 end
    if secret then d.secrets[variantName] = math.max(0,math.floor(tonumber(d.secrets[variantName]) or 0)) + 1 end
    d.catches += 1

    local skin = player:GetAttribute("BBYAFishingSkin") or "Graphite Core"
    d.mastery[skin] = math.max(0,math.floor(tonumber(d.mastery[skin]) or 0)) + 1

    local xp = (RARITY_XP[rarity] or 10)
    xp *= (SIZE_XP[sizeGrade] or 1)
    xp *= (MUTATIONS[mutation] and MUTATIONS[mutation].mult or 1)
    xp *= (QUALITY_XP[quality] or 1)
    if event.id ~= "CALM" then xp *= 1.08 end
    if firstSpecies then xp += 40 end
    if firstVariant and mutation ~= "NORMAL" then xp += 28 end
    if firstSecret then xp += 120 end
    xp = math.max(1, math.floor(xp))
    d.xp += xp

    applyMutationVisual(model, mutation, sizeGrade)
    model:SetAttribute("VariantNameV4", variantName)
    model:SetAttribute("BiomeV4", biomeKey)
    model:SetAttribute("CastQualityV4", quality)

    publishAttributes(player, d)

    stateRemote:FireClient(player, "CatchEnhanced", {
        fish=fishName,
        variant=variantName,
        rarity=rarity,
        mutation=mutation,
        size=sizeGrade,
        weight=weight,
        biome=biomeKey,
        biomeLabel=biome.label,
        quality=quality,
        xp=xp,
        level=anglerLevel(d.xp),
        newSpecies=firstSpecies,
        newVariant=firstVariant and mutation ~= "NORMAL",
        newMutation=firstMutation,
        secret=firstSecret,
        speciesCount=countKeys(d.species),
        speciesTotal=#SPECIES,
        variantCount=countKeys(d.variants),
        event=event.label,
        rodMastery=masteryLevel(d.mastery[skin]),
    })

    castQuality[player] = nil
    if d.catches % 4 == 0 or firstSpecies or firstSecret then task.spawn(saveData, player) end
end

local function processCatchModel(model)
    if not model:IsA("Model") or not string.find(model.Name, "^Catch_") then return end
    task.spawn(function()
        local deadline = os.clock() + 1.4
        while model.Parent and os.clock() < deadline do
            if model.PrimaryPart and model:GetAttribute("FishName") and model:GetAttribute("Weight") then break end
            task.wait(.03)
        end
        if not model.Parent or not model.PrimaryPart then return end
        local player = nearestPlayer(model.PrimaryPart.Position)
        if player then awardCatch(player, model) end
    end)
end

district.ChildAdded:Connect(processCatchModel)
for _, child in ipairs(district:GetChildren()) do processCatchModel(child) end

actionRemote.OnServerEvent:Connect(function(player, action, payload)
    if type(action) ~= "string" then return end
    local now = os.clock()
    if now - (lastActionAt[player] or 0) < .08 then return end
    lastActionAt[player] = now

    if action == "CastQuality" then
        if not isNearDistrict(player) or type(payload) ~= "table" then return end
        local quality = payload.quality
        local power = tonumber(payload.power) or 0
        if quality ~= "GOOD" and quality ~= "GREAT" and quality ~= "PERFECT" then return end
        power = math.clamp(power, 0, 1.4)
        castQuality[player] = {quality=quality,power=power,expires=now+10}
        stateRemote:FireClient(player, "CastQualityAck", {quality=quality,power=power})
        return
    end

    if action == "RequestJournal" or action == "RequestSnapshot" then
        local snap = journalSnapshot(player)
        if snap then stateRemote:FireClient(player, action=="RequestJournal" and "Journal" or "Snapshot", snap) end
        return
    end
end)

local function setupPlayer(player)
    task.spawn(function()
        loadData(player)
        task.wait(.35)
        sendSnapshot(player)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
    saveData(player)
    dataByUser[player.UserId] = nil
    castQuality[player] = nil
    lastActionAt[player] = nil
end)

-- Exploration loop: five readable fishing biomes, each discovered once for a small XP reward.
task.spawn(function()
    while task.wait(1.2) do
        for _, player in ipairs(Players:GetPlayers()) do
            local d = dataByUser[player.UserId]
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if d and hrp and isNearDistrict(player) then
                local biomeKey = determineBiome(hrp.Position)
                local biome = BIOMES[biomeKey] or BIOMES.PUBLIC
                player:SetAttribute("BBYALakeBiome", biome.label)
                if not d.visited[biomeKey] then
                    d.visited[biomeKey] = true
                    d.xp += 20
                    publishAttributes(player, d)
                    stateRemote:FireClient(player, "AreaDiscovered", {biome=biome.label,xp=20,visited=countKeys(d.visited),total=5})
                end
            else
                player:SetAttribute("BBYALakeBiome", nil)
            end
        end
    end
end)

-- Deterministic rotating lake events shared by all servers. No global weather/Lighting mutation.
task.spawn(function()
    while task.wait(3) do
        local event, remaining = currentEvent()
        district:SetAttribute("LakeEventV4", event.label)
        district:SetAttribute("LakeEventRemainingV4", remaining)
        if currentEventId ~= event.id then
            currentEventId = event.id
            for _, player in ipairs(Players:GetPlayers()) do
                player:SetAttribute("BBYALakeEvent", event.label)
                stateRemote:FireClient(player, "LakeEvent", {id=event.id,label=event.label,remaining=remaining})
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                player:SetAttribute("BBYALakeEvent", event.label)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(100) do
        for _, player in ipairs(Players:GetPlayers()) do task.spawn(saveData, player) end
    end
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do saveData(player) end
end)

district:SetAttribute("FishingProgressionV4", true)
district:SetAttribute("FishIndexSpeciesV4", #SPECIES)
district:SetAttribute("MutationTypesV4", 8)
district:SetAttribute("FishingBiomesV4", 5)
district:SetAttribute("LakeEventsV4", #EVENTS)
print("[BBYA] Fishing Progression v4 online: cast quality + Fish Index + mutations + biomes + events + mastery")
