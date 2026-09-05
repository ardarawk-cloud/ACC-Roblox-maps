-- Hangar Exclusive Club — server authority v1.0
-- Universe 10745364913 / Place 76001567401911

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local TextService = game:GetService("TextService")

local CONFIG = {
    UniverseId = 10745364913,
    PlaceId = 76001567401911,
    StaffUserIds = {}, -- add explicit Roblox UserIds here when known
    StaffGroupId = 0,  -- optional group ownership/staff gate
    MinimumStaffRank = 200,
    DonationProduct = { Id = 0, Robux = 0 }, -- configure real Developer Product
    ShoutoutProduct = { Id = 0, Robux = 0 }, -- configure real Developer Product
}

local PLAYLIST = {
    { id = "rbxassetid://1848354536", title = "Neon Nights", artist = "DJ Hangar" },
    { id = "rbxassetid://1837879082", title = "Flight Path", artist = "Aero Beats" },
}

local CLUB_COLORS = {
    Color3.fromRGB(138, 43, 226),
    Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(57, 255, 20),
    Color3.fromRGB(255, 20, 147),
}

Workspace:SetAttribute("HangarExclusiveClub", true)
Workspace:SetAttribute("UniverseId", tostring(CONFIG.UniverseId))
Workspace:SetAttribute("PlaceId", tostring(CONFIG.PlaceId))

local function ensureFolder(parent, name)
    local found = parent:FindFirstChild(name)
    if found and found:IsA("Folder") then return found end
    if found then found:Destroy() end
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = parent
    return folder
end

local function ensureModel(parent, name)
    local found = parent:FindFirstChild(name)
    if found and found:IsA("Model") then return found end
    if found then found:Destroy() end
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = parent
    return model
end

local function part(parent, name, size, cframe, color, material, shape)
    local p = parent:FindFirstChild(name)
    if not p or not p:IsA("Part") then
        if p then p:Destroy() end
        p = Instance.new("Part")
        p.Name = name
        p.Parent = parent
    end
    p.Anchored = true
    p.CanCollide = true
    p.Size = size
    p.CFrame = cframe
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    if shape then p.Shape = shape end
    return p
end

local function seat(parent, name, size, cframe, color)
    local s = parent:FindFirstChild(name)
    if not s or not s:IsA("Seat") then
        if s then s:Destroy() end
        s = Instance.new("Seat")
        s.Name = name
        s.Parent = parent
    end
    s.Anchored = true
    s.Size = size
    s.CFrame = cframe
    s.Color = color
    s.Material = Enum.Material.Leather
    return s
end

-- Environment ----------------------------------------------------------------
Lighting.ClockTime = 0.35
Lighting.Brightness = 1.4
Lighting.Ambient = Color3.fromRGB(17, 18, 28)
Lighting.OutdoorAmbient = Color3.fromRGB(8, 9, 16)
Lighting.EnvironmentDiffuseScale = 0.25
Lighting.EnvironmentSpecularScale = 0.8

local map = ensureFolder(Workspace, "Map")
local architecture = ensureFolder(map, "Architecture")
local vehicles = ensureFolder(map, "Vehicles")
local furniture = ensureFolder(map, "Furniture")

-- Full-scale hangar shell. Geometry is intentionally replaceable by MeshParts.
part(architecture, "Mesh_HangarFloor", Vector3.new(220, 2, 170), CFrame.new(0, 0, 0), Color3.fromRGB(32, 34, 38), Enum.Material.Concrete)
part(architecture, "Apron", Vector3.new(260, 2, 150), CFrame.new(0, -0.25, -160), Color3.fromRGB(42, 44, 47), Enum.Material.Concrete)
part(architecture, "Mesh_HangarBackWall", Vector3.new(220, 52, 3), CFrame.new(0, 26, 84), Color3.fromRGB(43, 45, 50), Enum.Material.Metal)
part(architecture, "Mesh_HangarLeftWall", Vector3.new(3, 52, 170), CFrame.new(-109, 26, 0), Color3.fromRGB(43, 45, 50), Enum.Material.Metal)
part(architecture, "Mesh_HangarRightWall", Vector3.new(3, 52, 170), CFrame.new(109, 26, 0), Color3.fromRGB(43, 45, 50), Enum.Material.Metal)
part(architecture, "Mesh_HangarRoofLeft", Vector3.new(114, 3, 174), CFrame.new(-54, 50, 0) * CFrame.Angles(0, 0, math.rad(-8)), Color3.fromRGB(28, 30, 35), Enum.Material.Metal)
part(architecture, "Mesh_HangarRoofRight", Vector3.new(114, 3, 174), CFrame.new(54, 50, 0) * CFrame.Angles(0, 0, math.rad(8)), Color3.fromRGB(28, 30, 35), Enum.Material.Metal)

for i = -4, 4 do
    local x = i * 22
    part(architecture, "RoofTruss_" .. tostring(i + 5), Vector3.new(2, 3, 166), CFrame.new(x, 45, 0), Color3.fromRGB(73, 76, 82), Enum.Material.Metal)
end

local spawn = Workspace:FindFirstChild("HangarSpawn")
if not spawn or not spawn:IsA("SpawnLocation") then
    if spawn then spawn:Destroy() end
    spawn = Instance.new("SpawnLocation")
    spawn.Name = "HangarSpawn"
    spawn.Parent = Workspace
end
spawn.Anchored = true
spawn.Neutral = true
spawn.Size = Vector3.new(12, 1, 12)
spawn.CFrame = CFrame.new(0, 1.5, -68)
spawn.Transparency = 0.35
spawn.Color = Color3.fromRGB(0, 210, 255)
spawn.Material = Enum.Material.Neon

-- Private jet proxy ------------------------------------------------------------
local jet = ensureModel(vehicles, "Mesh_PrivateJet")
part(jet, "Fuselage", Vector3.new(12, 12, 72), CFrame.new(-53, 8, -12), Color3.fromRGB(220, 223, 228), Enum.Material.Metal)
part(jet, "Nose", Vector3.new(10, 10, 14), CFrame.new(-53, 8, -55), Color3.fromRGB(225, 228, 233), Enum.Material.Metal)
part(jet, "Wing", Vector3.new(62, 2, 18), CFrame.new(-53, 8, -5), Color3.fromRGB(190, 194, 201), Enum.Material.Metal)
part(jet, "TailWing", Vector3.new(30, 2, 10), CFrame.new(-53, 11, 24), Color3.fromRGB(190, 194, 201), Enum.Material.Metal)
part(jet, "TailFin", Vector3.new(2, 15, 11), CFrame.new(-53, 17, 25), Color3.fromRGB(64, 67, 76), Enum.Material.Metal)

-- Helicopter proxy -------------------------------------------------------------
local heli = ensureModel(vehicles, "Mesh_Helicopter")
part(heli, "Cabin", Vector3.new(18, 12, 24), CFrame.new(57, 10, 9), Color3.fromRGB(29, 31, 36), Enum.Material.Metal)
part(heli, "Glass", Vector3.new(16, 7, 8), CFrame.new(57, 12, -7), Color3.fromRGB(14, 47, 59), Enum.Material.Glass).Transparency = 0.25
part(heli, "TailBoom", Vector3.new(5, 5, 38), CFrame.new(57, 12, 39), Color3.fromRGB(42, 44, 49), Enum.Material.Metal)
part(heli, "RotorA", Vector3.new(70, 0.6, 2), CFrame.new(57, 21, 8), Color3.fromRGB(92, 95, 101), Enum.Material.Metal)
part(heli, "RotorB", Vector3.new(2, 0.6, 70), CFrame.new(57, 21, 8), Color3.fromRGB(92, 95, 101), Enum.Material.Metal)

-- Stage / bar / lounge ---------------------------------------------------------
part(furniture, "Stage", Vector3.new(84, 3, 26), CFrame.new(0, 2.5, 65), Color3.fromRGB(17, 18, 22), Enum.Material.Metal)
part(furniture, "DJBooth", Vector3.new(25, 5, 5), CFrame.new(0, 7, 59), Color3.fromRGB(16, 17, 20), Enum.Material.Metal)
local djFace = part(furniture, "DJBoothNeon", Vector3.new(20, 2, 0.35), CFrame.new(0, 7.4, 56.4), Color3.fromRGB(0, 235, 255), Enum.Material.Neon)
djFace.CanCollide = false
part(furniture, "Mesh_BarCounter", Vector3.new(38, 5, 7), CFrame.new(83, 3.5, 45), Color3.fromRGB(42, 28, 24), Enum.Material.WoodPlanks)
for i = 1, 5 do
    seat(furniture, "BarStool_" .. i, Vector3.new(3, 1, 3), CFrame.new(67 + i * 6, 3, 38), Color3.fromRGB(31, 31, 35))
end
for row = 0, 1 do
    for i = 0, 2 do
        seat(furniture, "Mesh_LeatherSofa_" .. row .. "_" .. i, Vector3.new(13, 3, 5), CFrame.new(-85 + i * 18, 2.5, 33 - row * 15), Color3.fromRGB(26, 27, 32))
    end
end
for i = -4, 4 do
    part(furniture, "Mesh_MetalFencing_" .. tostring(i + 5), Vector3.new(1, 5, 12), CFrame.new(i * 12, 2.5, 45), Color3.fromRGB(85, 88, 93), Enum.Material.DiamondPlate)
end

-- Lighting system --------------------------------------------------------------
local lightingSystem = ensureFolder(Workspace, "LightingSystem")
local stageLights = ensureFolder(lightingSystem, "StageLights")
local lasers = ensureFolder(lightingSystem, "Lasers")

for i = 1, 8 do
    local m = ensureModel(stageLights, string.format("StageLight%02d", i))
    local x = -42 + (i - 1) * 12
    local housing = part(m, "Housing", Vector3.new(4, 3, 4), CFrame.new(x, 37, 56) * CFrame.Angles(math.rad(-35), 0, 0), Color3.fromRGB(24, 25, 28), Enum.Material.Metal)
    housing.CanCollide = false
    local lens = part(m, "Lens", Vector3.new(2.5, 0.5, 2.5), housing.CFrame * CFrame.new(0, -1.5, -0.5), CLUB_COLORS[((i - 1) % #CLUB_COLORS) + 1], Enum.Material.Neon)
    lens.CanCollide = false
    local spot = lens:FindFirstChildOfClass("SpotLight") or Instance.new("SpotLight")
    spot.Name = "Beam"
    spot.Angle = 38
    spot.Brightness = 8
    spot.Range = 75
    spot.Face = Enum.NormalId.Bottom
    spot.Color = lens.Color
    spot.Parent = lens
end

for i = 1, 6 do
    local x = -45 + (i - 1) * 18
    local beam = part(lasers, string.format("Laser%02d", i), Vector3.new(0.25, 0.25, 76), CFrame.new(x, 20, 25) * CFrame.Angles(math.rad(-14), math.rad((i - 3.5) * 4), 0), CLUB_COLORS[((i - 1) % #CLUB_COLORS) + 1], Enum.Material.Neon)
    beam.CanCollide = false
    beam.CastShadow = false
    beam.Transparency = 0.25
end

-- Audio system -----------------------------------------------------------------
local audioSystem = ensureFolder(Workspace, "AudioSystem")
local speakers = ensureModel(audioSystem, "MainSpeakers")
part(speakers, "SpeakerLeft", Vector3.new(8, 14, 6), CFrame.new(-35, 9, 62), Color3.fromRGB(12, 12, 14), Enum.Material.Metal)
part(speakers, "SpeakerRight", Vector3.new(8, 14, 6), CFrame.new(35, 9, 62), Color3.fromRGB(12, 12, 14), Enum.Material.Metal)
local music = speakers:FindFirstChild("DJMusic")
if not music or not music:IsA("Sound") then
    if music then music:Destroy() end
    music = Instance.new("Sound")
    music.Name = "DJMusic"
    music.Parent = speakers
end
music.Volume = 0.72
music.RollOffMode = Enum.RollOffMode.InverseTapered
music.RollOffMaxDistance = 220
music.RollOffMinDistance = 18

-- Remote contract --------------------------------------------------------------
local clubEvents = ensureFolder(ReplicatedStorage, "ClubEvents")
local function remote(name)
    local r = clubEvents:FindFirstChild(name)
    if r and r:IsA("RemoteEvent") then return r end
    if r then r:Destroy() end
    r = Instance.new("RemoteEvent")
    r.Name = name
    r.Parent = clubEvents
    return r
end
local DJCommand = remote("DJCommand")
local SetPendingMessage = remote("SetPendingMessage")
local GlobalNotification = remote("GlobalNotification")
local SongRequest = remote("SongRequest")
local DJRequest = remote("DJRequest")
local ClubState = remote("ClubState")

local function isDJ(player)
    if CONFIG.StaffUserIds[player.UserId] then return true end
    if game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId then return true end
    if CONFIG.StaffGroupId > 0 then
        local ok, rank = pcall(player.GetRankInGroup, player, CONFIG.StaffGroupId)
        if ok and rank >= CONFIG.MinimumStaffRank then return true end
    end
    return false
end

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("HangarDJ", isDJ(player))
end)
for _, player in Players:GetPlayers() do
    player:SetAttribute("HangarDJ", isDJ(player))
end

-- Music authority --------------------------------------------------------------
local currentSongIndex = 1
local autoAdvance = true
local endedConnection

local function broadcastState()
    local entry
    for _, song in ipairs(PLAYLIST) do
        if song.id == music.SoundId then entry = song break end
    end
    ClubState:FireAllClients({
        soundId = music.SoundId,
        title = entry and entry.title or "DJ Selection",
        artist = entry and entry.artist or "Hangar Exclusive Club",
        playing = music.IsPlaying,
    })
end

local function playIndex(index)
    currentSongIndex = ((index - 1) % #PLAYLIST) + 1
    local song = PLAYLIST[currentSongIndex]
    music.SoundId = song.id
    music.TimePosition = 0
    music:Play()
    autoAdvance = true
    broadcastState()
end

endedConnection = music.Ended:Connect(function()
    if autoAdvance then playIndex(currentSongIndex + 1) end
end)

local remoteRate = {}
local function rateOK(player, bucket, seconds)
    local key = tostring(player.UserId) .. ":" .. bucket
    local now = os.clock()
    if remoteRate[key] and now - remoteRate[key] < seconds then return false end
    remoteRate[key] = now
    return true
end

local manualLightUntil = 0
DJCommand.OnServerEvent:Connect(function(player, command, argument)
    if not isDJ(player) or not rateOK(player, "dj", 0.12) then return end
    if command == "PlaySong" then
        local numeric = tostring(argument or ""):match("^(%d+)$")
        if not numeric or #numeric > 20 then return end
        music.SoundId = "rbxassetid://" .. numeric
        music.TimePosition = 0
        music:Play()
        autoAdvance = true
        broadcastState()
    elseif command == "StopMusic" then
        autoAdvance = false
        music:Stop()
        broadcastState()
    elseif command == "ResumePlaylist" then
        playIndex(currentSongIndex)
    elseif command == "ChangeLightColor" and typeof(argument) == "Color3" then
        manualLightUntil = os.clock() + 20
        for _, lightModel in ipairs(stageLights:GetChildren()) do
            local lens = lightModel:FindFirstChild("Lens")
            if lens and lens:IsA("BasePart") then
                lens.Color = argument
                local spot = lens:FindFirstChildOfClass("SpotLight")
                if spot then spot.Color = argument end
            end
        end
    end
end)

SongRequest.OnServerEvent:Connect(function(player, assetId)
    if not rateOK(player, "request", 2) then return end
    local numeric = tostring(assetId or ""):match("^(%d+)$")
    if not numeric or #numeric > 20 then return end
    for _, target in Players:GetPlayers() do
        if isDJ(target) then DJRequest:FireClient(target, player.DisplayName, numeric) end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if os.clock() >= manualLightUntil then
            for _, lightModel in ipairs(stageLights:GetChildren()) do
                local lens = lightModel:FindFirstChild("Lens")
                if lens and lens:IsA("BasePart") then
                    local c = CLUB_COLORS[math.random(1, #CLUB_COLORS)]
                    lens.Color = c
                    local spot = lens:FindFirstChildOfClass("SpotLight")
                    if spot then spot.Color = c end
                end
            end
        end
    end
end)

-- Donation / shoutout ----------------------------------------------------------
local donations = DataStoreService:GetDataStore("HangarClubDonations_v2")
local pendingMessages = {}

SetPendingMessage.OnServerEvent:Connect(function(player, message)
    if not rateOK(player, "message", 1) or type(message) ~= "string" then return end
    message = message:sub(1, 100)
    local ok, filtered = pcall(function()
        local result = TextService:FilterStringAsync(message, player.UserId)
        return result:GetNonChatStringForBroadcastAsync()
    end)
    if ok and filtered and filtered ~= "" then
        pendingMessages[player.UserId] = { text = filtered, at = os.time() }
    end
end)

local productById = {}
if CONFIG.DonationProduct.Id > 0 then productById[CONFIG.DonationProduct.Id] = { kind = "donation", robux = CONFIG.DonationProduct.Robux } end
if CONFIG.ShoutoutProduct.Id > 0 then productById[CONFIG.ShoutoutProduct.Id] = { kind = "shoutout", robux = CONFIG.ShoutoutProduct.Robux } end

local function updateDonation(playerId, purchaseId, amount)
    local key = "UserDonation_" .. tostring(playerId)
    local added = false
    local total = 0
    local ok = pcall(function()
        local saved = donations:UpdateAsync(key, function(old)
            local data = type(old) == "table" and old or { total = 0, receipts = {} }
            data.receipts = type(data.receipts) == "table" and data.receipts or {}
            if not data.receipts[purchaseId] then
                data.total = (tonumber(data.total) or 0) + amount
                data.receipts[purchaseId] = os.time()
                added = true
                local keys = {}
                for id, stamp in pairs(data.receipts) do table.insert(keys, { id = id, stamp = stamp }) end
                table.sort(keys, function(a, b) return a.stamp > b.stamp end)
                for i = 61, #keys do data.receipts[keys[i].id] = nil end
            end
            total = tonumber(data.total) or 0
            return data
        end)
    end)
    return ok, added, total
end

MarketplaceService.ProcessReceipt = function(receiptInfo)
    local product = productById[receiptInfo.ProductId]
    if not product then return Enum.ProductPurchaseDecision.NotProcessedYet end
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
    local ok, added, total = updateDonation(receiptInfo.PlayerId, tostring(receiptInfo.PurchaseId), product.robux)
    if not ok then return Enum.ProductPurchaseDecision.NotProcessedYet end
    if added then
        local message = "Mendukung Hangar Exclusive Club!"
        if product.kind == "shoutout" then
            local pending = pendingMessages[player.UserId]
            if pending and os.time() - pending.at <= 600 then message = pending.text end
            pendingMessages[player.UserId] = nil
        end
        local avatar = ""
        pcall(function()
            avatar = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)
        GlobalNotification:FireAllClients(player.DisplayName, message, product.robux, total, avatar, player.Character)
    end
    return Enum.ProductPurchaseDecision.PurchaseGranted
end

playIndex(1)
print("[HangarExclusiveClub] v1 server ready", CONFIG.UniverseId, CONFIG.PlaceId)
