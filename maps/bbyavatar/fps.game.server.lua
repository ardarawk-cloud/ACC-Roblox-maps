-- BBYAVATAR FPS authoritative game server v0.2.1
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("FPSConfig"))
Players.RespawnTime = Config.RespawnTime

local function ensureTeam(name, color)
    local team = Teams:FindFirstChild(name) or Instance.new("Team")
    team.Name = name
    team.TeamColor = color
    team.AutoAssignable = false
    team.Parent = Teams
    return team
end

local AlphaTeam = ensureTeam("ALPHA", BrickColor.new("Bright blue"))
local BravoTeam = ensureTeam("BRAVO", BrickColor.new("Bright red"))

local remotes = ReplicatedStorage:FindFirstChild("FPSRemotes") or Instance.new("Folder")
remotes.Name = "FPSRemotes"
remotes.Parent = ReplicatedStorage

local function remote(name)
    local r = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
    r.Name = name
    r.Parent = remotes
    return r
end

local Fire = remote("Fire")
local Reload = remote("Reload")
local Equip = remote("Equip")
local State = remote("State")
local FX = remote("FX")

local playerState = {}
local teamScores = {ALPHA = 0, BRAVO = 0}
local roundNumber = 1
local roundEnding = false
local roundEndsAt = Workspace:GetServerTimeNow() + Config.RoundTime
local spawnCursor = {ALPHA = 0, BRAVO = 0}

local spawnNames = {
    ALPHA = {"AlphaSpawn1", "AlphaSpawn2"},
    BRAVO = {"BravoSpawn1", "BravoSpawn2"},
}

local fallbackSpawns = {
    ALPHA = {
        CFrame.new(-194, 6, -45) * CFrame.Angles(0, math.rad(-90), 0),
        CFrame.new(-194, 6, 45) * CFrame.Angles(0, math.rad(-90), 0),
    },
    BRAVO = {
        CFrame.new(194, 6, -45) * CFrame.Angles(0, math.rad(90), 0),
        CFrame.new(194, 6, 45) * CFrame.Angles(0, math.rad(90), 0),
    },
}

local function cloneAmmo()
    local result = {}
    for key, cfg in pairs(Config.Weapons) do
        result[key] = {mag = cfg.Magazine, reserve = cfg.Reserve, reloading = false, token = 0}
    end
    return result
end

local function chooseTeam()
    local alphaCount, bravoCount = 0, 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Team and p.Team.Name == "ALPHA" then alphaCount += 1 end
        if p.Team and p.Team.Name == "BRAVO" then bravoCount += 1 end
    end
    return (alphaCount <= bravoCount) and AlphaTeam or BravoTeam
end

local function nextSpawnCFrame(player)
    local teamName = player.Team and player.Team.Name or "ALPHA"
    if not spawnNames[teamName] then teamName = "ALPHA" end
    spawnCursor[teamName] = (spawnCursor[teamName] % #spawnNames[teamName]) + 1
    local index = spawnCursor[teamName]
    local spawnPart = Workspace:FindFirstChild(spawnNames[teamName][index])
    if spawnPart and spawnPart:IsA("BasePart") then
        local facing = teamName == "ALPHA" and -90 or 90
        return CFrame.new(spawnPart.Position + Vector3.new(0, 4.8, 0)) * CFrame.Angles(0, math.rad(facing), 0)
    end
    return fallbackSpawns[teamName][index]
end

local function sendSnapshot(player)
    local ps = playerState[player]
    if not ps then return end
    State:FireClient(player, "snapshot", {
        weapon = ps.weapon,
        ammo = ps.ammo,
        scores = teamScores,
        round = roundNumber,
        scoreLimit = Config.ScoreLimit,
        roundEndsAt = roundEndsAt,
        roundEnding = roundEnding,
        mode = Config.Mode,
        streak = ps.streak,
    })
end

local function broadcastScore()
    State:FireAllClients("score", {
        scores = teamScores,
        round = roundNumber,
        scoreLimit = Config.ScoreLimit,
        roundEndsAt = roundEndsAt,
    })
end

local function winnerFromScore()
    if teamScores.ALPHA > teamScores.BRAVO then return "ALPHA" end
    if teamScores.BRAVO > teamScores.ALPHA then return "BRAVO" end
    return "DRAW"
end

local function finishRound(reason, forcedWinner)
    if roundEnding then return end
    roundEnding = true
    local winner = forcedWinner or winnerFromScore()
    State:FireAllClients("roundEnd", {
        winner = winner,
        reason = reason or "TIME",
        scores = {ALPHA = teamScores.ALPHA, BRAVO = teamScores.BRAVO},
        nextRoundIn = Config.RoundIntermission,
        round = roundNumber,
    })

    task.delay(Config.RoundIntermission, function()
        teamScores.ALPHA = 0
        teamScores.BRAVO = 0
        roundNumber += 1
        roundEndsAt = Workspace:GetServerTimeNow() + Config.RoundTime
        roundEnding = false

        for _, p in ipairs(Players:GetPlayers()) do
            local ps = playerState[p]
            if ps then
                ps.ammo = cloneAmmo()
                ps.weapon = Config.Loadout[1]
                ps.streak = 0
                ps.lastShot = 0
                p:LoadCharacter()
            end
        end

        State:FireAllClients("roundStart", {
            round = roundNumber,
            roundEndsAt = roundEndsAt,
            scores = teamScores,
        })
        broadcastScore()
        for _, p in ipairs(Players:GetPlayers()) do sendSnapshot(p) end
    end)
end

local function isEnemy(attacker, victimPlayer)
    if not attacker or not victimPlayer then return false end
    return attacker.Team ~= nil and victimPlayer.Team ~= nil and attacker.Team ~= victimPlayer.Team
end

local function findHumanoidFromHit(hit)
    local model = hit and hit:FindFirstAncestorOfClass("Model")
    if not model then return nil, nil end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return nil, nil end
    return hum, Players:GetPlayerFromCharacter(model)
end

local function isFiniteNumber(n)
    return typeof(n) == "number" and n == n and n > -1e9 and n < 1e9
end

local function validVector(v)
    return typeof(v) == "Vector3" and isFiniteNumber(v.X) and isFiniteNumber(v.Y) and isFiniteNumber(v.Z)
end

local function validateOrigin(player, origin)
    if not validVector(origin) then return false end
    local char = player.Character
    if not char then return false end
    local head = char:FindFirstChild("Head")
    if not head then return false end
    return (origin - head.Position).Magnitude <= 12
end

local function clearSpawnProtection(character)
    local shield = character and character:FindFirstChild("SpawnProtection")
    if shield then shield:Destroy() end
    if character and character.Parent then character:SetAttribute("SpawnProtectedUntil", nil) end
end

local function applySpawnProtection(character)
    clearSpawnProtection(character)
    local shield = Instance.new("ForceField")
    shield.Name = "SpawnProtection"
    shield.Visible = false
    shield.Parent = character
    character:SetAttribute("SpawnProtectedUntil", Workspace:GetServerTimeNow() + Config.SpawnProtection)
    task.delay(Config.SpawnProtection, function()
        if shield.Parent then shield:Destroy() end
        if character.Parent then character:SetAttribute("SpawnProtectedUntil", nil) end
    end)
end

local function isProtected(player)
    local character = player.Character
    return character and character:FindFirstChild("SpawnProtection") ~= nil
end

local function placeCharacterSafely(player, character, restoreHealth)
    if not character or character ~= player.Character then return false end
    local hum = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return false end

    local target = nextSpawnCFrame(player)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    character:PivotTo(target)
    hum.PlatformStand = false
    hum.Sit = false
    if restoreHealth then hum.Health = hum.MaxHealth end
    applySpawnProtection(character)
    State:FireClient(player, "spawnSafe", {duration = Config.SpawnProtection})
    return true
end

local function isMilestone(count)
    for _, value in ipairs(Config.KillstreakMilestones) do
        if value == count then return true end
    end
    return false
end

local function setupCharacter(player, character)
    local hum = character:WaitForChild("Humanoid", 10)
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not hum or not root then return end
    hum.MaxHealth = Config.MaxHealth
    hum.Health = Config.MaxHealth
    hum.WalkSpeed = Config.WalkSpeed
    hum.JumpPower = 46

    task.defer(function()
        if character.Parent and player.Character == character then
            placeCharacterSafely(player, character, true)
        end
    end)

    local creator = Instance.new("ObjectValue")
    creator.Name = "LastAttacker"
    creator.Parent = hum
    hum:SetAttribute("LastAttackerAt", 0)

    hum.Died:Connect(function()
        local victimState = playerState[player]
        if victimState then
            victimState.deaths += 1
            victimState.streak = 0
        end

        local stats = player:FindFirstChild("leaderstats")
        if stats and stats:FindFirstChild("Deaths") then stats.Deaths.Value += 1 end

        local tag = hum:FindFirstChild("LastAttacker")
        local killer = tag and tag.Value
        local hitAge = Workspace:GetServerTimeNow() - (hum:GetAttribute("LastAttackerAt") or 0)

        if killer and killer:IsA("Player") and killer ~= player and playerState[killer] and hitAge <= 8 then
            local killerState = playerState[killer]
            killerState.kills += 1
            killerState.streak += 1

            local kstats = killer:FindFirstChild("leaderstats")
            if kstats and kstats:FindFirstChild("Kills") then kstats.Kills.Value += 1 end

            if killer.Team then
                teamScores[killer.Team.Name] = (teamScores[killer.Team.Name] or 0) + 1
            end

            State:FireAllClients("killfeed", {
                killer = killer.DisplayName,
                victim = player.DisplayName,
                weapon = killerState.weapon,
                streak = killerState.streak,
            })
            State:FireClient(killer, "kill", {victim = player.DisplayName, streak = killerState.streak})
            State:FireClient(player, "death", {killer = killer.DisplayName})

            if isMilestone(killerState.streak) then
                State:FireAllClients("streak", {
                    player = killer.DisplayName,
                    count = killerState.streak,
                })
            end

            broadcastScore()
            if killer.Team and teamScores[killer.Team.Name] >= Config.ScoreLimit then
                finishRound("SCORE_LIMIT", killer.Team.Name)
            end
        else
            State:FireAllClients("killfeed", {killer = "ENV", victim = player.DisplayName, weapon = ""})
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.Team = chooseTeam()
    player.Neutral = false

    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    local kills = Instance.new("IntValue")
    kills.Name = "Kills"
    kills.Parent = leaderstats
    local deaths = Instance.new("IntValue")
    deaths.Name = "Deaths"
    deaths.Parent = leaderstats

    playerState[player] = {
        weapon = Config.Loadout[1],
        ammo = cloneAmmo(),
        lastShot = 0,
        kills = 0,
        deaths = 0,
        streak = 0,
    }

    player.CharacterAdded:Connect(function(character)
        setupCharacter(player, character)
        task.delay(0.7, function()
            if player.Parent then sendSnapshot(player) end
        end)
    end)

    if player.Character then setupCharacter(player, player.Character) end
    task.delay(0.8, function() if player.Parent then sendSnapshot(player) end end)
end)

Players.PlayerRemoving:Connect(function(player)
    playerState[player] = nil
end)

Equip.OnServerEvent:Connect(function(player, weaponKey)
    if roundEnding then return end
    local ps = playerState[player]
    if not ps or type(weaponKey) ~= "string" or not Config.Weapons[weaponKey] then return end
    local allowed = false
    for _, key in ipairs(Config.Loadout) do
        if key == weaponKey then allowed = true break end
    end
    if not allowed then return end
    ps.weapon = weaponKey
    ps.ammo[weaponKey].reloading = false
    ps.ammo[weaponKey].token += 1
    State:FireClient(player, "weapon", {weapon = weaponKey, ammo = ps.ammo[weaponKey]})
end)

Reload.OnServerEvent:Connect(function(player)
    if roundEnding then return end
    local ps = playerState[player]
    if not ps then return end
    local key = ps.weapon
    local cfg = Config.Weapons[key]
    local ammo = ps.ammo[key]
    if not cfg or not ammo or ammo.reloading or ammo.mag >= cfg.Magazine or ammo.reserve <= 0 then return end

    ammo.reloading = true
    ammo.token += 1
    local token = ammo.token
    State:FireClient(player, "reload", {weapon = key, active = true, duration = cfg.ReloadTime})

    task.delay(cfg.ReloadTime, function()
        local live = playerState[player]
        if not live or live.weapon ~= key then return end
        local a = live.ammo[key]
        if not a or a.token ~= token or not a.reloading then return end
        local need = cfg.Magazine - a.mag
        local take = math.min(need, a.reserve)
        a.mag += take
        a.reserve -= take
        a.reloading = false
        State:FireClient(player, "ammo", {weapon = key, mag = a.mag, reserve = a.reserve})
        State:FireClient(player, "reload", {weapon = key, active = false})
    end)
end)

Fire.OnServerEvent:Connect(function(player, packet)
    if roundEnding then return end
    local ps = playerState[player]
    if not ps or type(packet) ~= "table" then return end
    local key = ps.weapon
    local cfg = Config.Weapons[key]
    local ammo = ps.ammo[key]
    if not cfg or not ammo or ammo.reloading then return end

    local origin = packet.origin
    local direction = packet.direction
    if not validVector(direction) or not validateOrigin(player, origin) then return end
    if direction.Magnitude < 0.9 or direction.Magnitude > 1.1 then return end

    local now = os.clock()
    local minInterval = 60 / cfg.RPM
    if now - ps.lastShot < minInterval * 0.86 then return end
    ps.lastShot = now

    if ammo.mag <= 0 then
        State:FireClient(player, "dry", {weapon = key})
        return
    end

    local char = player.Character
    if not char then return end
    clearSpawnProtection(char)

    ammo.mag -= 1
    State:FireClient(player, "ammo", {weapon = key, mag = ammo.mag, reserve = ammo.reserve})

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}
    params.IgnoreWater = true

    local result = Workspace:Raycast(origin, direction.Unit * cfg.Range, params)
    local hitPos = origin + direction.Unit * cfg.Range
    if result then hitPos = result.Position end
    FX:FireAllClients("shot", {from = origin, to = hitPos, shooter = player.UserId, weapon = key})

    if result then
        local hum, victimPlayer = findHumanoidFromHit(result.Instance)
        if hum and hum.Health > 0 and victimPlayer and isEnemy(player, victimPlayer) and not isProtected(victimPlayer) then
            local damage = cfg.Damage
            local headshot = result.Instance.Name == "Head"
            if headshot then damage *= cfg.HeadMultiplier end

            local tag = hum:FindFirstChild("LastAttacker")
            if tag then tag.Value = player end
            hum:SetAttribute("LastAttackerAt", Workspace:GetServerTimeNow())
            hum:TakeDamage(damage)

            State:FireClient(player, "hit", {
                damage = damage,
                headshot = headshot,
                killed = hum.Health <= 0,
            })
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.25)
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            local hum = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                local p = root.Position
                local outside = p.Y < Config.FallRescueY or math.abs(p.X) > Config.SafeBoundsX or math.abs(p.Z) > Config.SafeBoundsZ
                if outside then
                    placeCharacterSafely(player, character, true)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if not roundEnding and Workspace:GetServerTimeNow() >= roundEndsAt then
            finishRound("TIME", nil)
        end
    end
end)

print("[BBYAVATAR FPS] Authoritative combat server v0.2.1 ready")
