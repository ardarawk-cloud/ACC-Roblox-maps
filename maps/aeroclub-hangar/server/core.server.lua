-- AEROCLUB HANGAR — CoreServer v1.0
-- RESET FOUNDATION / LAB ONLY
-- Server-authoritative roles, titles, lead sync, DJ effects, carry, corner shop, donor statues.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local CONFIG = {
    StaffGroupId = 0,
    RankRoles = {
        {minRank = 250, role = "Admin"},
        {minRank = 220, role = "DJ"},
        {minRank = 210, role = "Lead"},
        {minRank = 200, role = "Media"},
    },
    ExplicitRoles = {
        -- [123456789] = "DJ",
    },
    VipGamePassId = 0,
    DonationProducts = {
        -- [productId] = robuxAmount,
    },
    GlobalShoutoutProductId = 0,
}

Workspace:SetAttribute("AeroClubHangar", true)
Workspace:SetAttribute("AeroClubBuild", "RESET_FOUNDATION_V1")
Workspace:SetAttribute("AeroClubEnvironmentReady", false)
Workspace:SetAttribute("AeroClubLivePublishAllowed", false)

Lighting.Technology = Enum.Technology.Future
Lighting.GlobalShadows = true
Lighting.Brightness = 2
Lighting.ExposureCompensation = 0.1
Lighting.EnvironmentDiffuseScale = 0.5
Lighting.EnvironmentSpecularScale = 1

local function ensureFolder(parent, name)
    local found = parent:FindFirstChild(name)
    if found and found:IsA("Folder") then return found end
    if found then found:Destroy() end
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = parent
    return folder
end

local environment = ensureFolder(Workspace, "Environment")
local interactiveZones = ensureFolder(Workspace, "InteractiveZones")
local lightingEquipment = ensureFolder(Workspace, "LightingEquipment")
local statues = ensureFolder(Workspace, "Statues")
local network = ensureFolder(ReplicatedStorage, "Network")
ensureFolder(ReplicatedStorage, "Modules")
ensureFolder(ReplicatedStorage, "Assets")

for _, name in ipairs({"MovingHeads", "Lasers", "FogMachines", "StageFireworks"}) do
    ensureFolder(lightingEquipment, name)
end
for _, name in ipairs({"AFKConveyor", "Photobooth", "CornerShop"}) do
    ensureFolder(interactiveZones, name)
end

local function remote(name)
    local r = network:FindFirstChild(name)
    if r and r:IsA("RemoteEvent") then return r end
    if r then r:Destroy() end
    r = Instance.new("RemoteEvent")
    r.Name = name
    r.Parent = network
    return r
end

local UpdateTitleEvent = remote("UpdateTitleEvent")
local ChangeLeadSpeedEvent = remote("ChangeLeadSpeedEvent")
local TriggerDJEffectEvent = remote("TriggerDJEffectEvent")
local CarryRequestEvent = remote("CarryRequestEvent")
local ServerAnnouncementEvent = remote("ServerAnnouncementEvent")
local GlobalDonationEvent = remote("GlobalDonationEvent")

local RATE = {}
local function allow(player, key, interval)
    local uid = player.UserId
    RATE[uid] = RATE[uid] or {}
    local now = os.clock()
    local last = RATE[uid][key] or 0
    if now - last < interval then return false end
    RATE[uid][key] = now
    return true
end

local ROLE_STYLE = {
    Owner = {text = "[OWNER]", color = Color3.fromRGB(255,215,0)},
    Admin = {text = "[ADMIN]", color = Color3.fromRGB(255,50,50)},
    DJ = {text = "[DJ]", color = Color3.fromRGB(0,255,255)},
    Lead = {text = "[LEAD]", color = Color3.fromRGB(255,0,255)},
    Media = {text = "[MEDIA]", color = Color3.fromRGB(100,200,255)},
}

local function resolveRole(player)
    if game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId then
        return "Owner"
    end
    local explicit = CONFIG.ExplicitRoles[player.UserId]
    if explicit then return explicit end
    if CONFIG.StaffGroupId > 0 then
        local ok, rank = pcall(player.GetRankInGroup, player, CONFIG.StaffGroupId)
        if ok then
            for _, row in ipairs(CONFIG.RankRoles) do
                if rank >= row.minRank then return row.role end
            end
        end
    end
    return nil
end

local function setupNameTag(player, character)
    local head = character:WaitForChild("Head", 8)
    if not head then return end
    local old = head:FindFirstChild("TitleBillboard")
    if old then old:Destroy() end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TitleBillboard"
    billboard.Size = UDim2.fromOffset(220, 52)
    billboard.StudsOffset = Vector3.new(0, 2.7, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 90
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Name = "TitleLabel"
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.TextStrokeTransparency = 0.55
    label.Font = Enum.Font.GothamBold
    label.Text = ""
    label.TextColor3 = Color3.new(1,1,1)
    label.Parent = billboard

    local role = player:GetAttribute("Role")
    local style = role and ROLE_STYLE[role]
    if style then
        label.Text = style.text
        label.TextColor3 = style.color
    elseif player:GetAttribute("HasVIP") then
        label.Text = "[VIP]"
        label.TextColor3 = Color3.fromRGB(255,215,0)
    end
end

local function filteredBroadcast(player, text)
    text = tostring(text or "")
    text = string.sub(text, 1, 28)
    local ok, result = pcall(TextService.FilterStringAsync, TextService, text, player.UserId)
    if not ok then return "###" end
    local ok2, filtered = pcall(result.GetNonChatStringForBroadcastAsync, result)
    return ok2 and filtered or "###"
end

UpdateTitleEvent.OnServerEvent:Connect(function(player, newTitleText, textColor)
    if not allow(player, "title", 1.5) then return end
    if player:GetAttribute("Role") ~= nil then return end
    if typeof(textColor) ~= "Color3" then return end
    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    local billboard = head and head:FindFirstChild("TitleBillboard")
    local label = billboard and billboard:FindFirstChild("TitleLabel")
    if not label then return end
    label.Text = filteredBroadcast(player, newTitleText)
    label.TextColor3 = textColor
end)

ChangeLeadSpeedEvent.OnServerEvent:Connect(function(player, speedValue)
    if player:GetAttribute("Role") ~= "Lead" then return end
    if typeof(speedValue) ~= "number" or speedValue ~= speedValue then return end
    if not allow(player, "leadSpeed", 0.2) then return end
    local speed = math.clamp(speedValue, 0.5, 2.0)
    player:SetAttribute("CurrentDanceSpeed", speed)
    for _, target in ipairs(Players:GetPlayers()) do
        if target == player or target:GetAttribute("SyncedToUserId") == player.UserId then
            local char = target.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(speed)
                end
            end
        end
    end
end)

local function hasDJAccess(player)
    local role = player:GetAttribute("Role")
    return role == "DJ" or role == "Owner" or role == "Admin"
end

TriggerDJEffectEvent.OnServerEvent:Connect(function(player, effectType, value)
    if not hasDJAccess(player) then return end
    if not allow(player, "djEffect", 0.12) then return end
    if effectType == "Smoke" then
        if typeof(value) ~= "boolean" then return end
        for _, d in ipairs(lightingEquipment.FogMachines:GetDescendants()) do
            if d:IsA("ParticleEmitter") then d.Enabled = value end
        end
    elseif effectType == "Fireworks" then
        for _, d in ipairs(lightingEquipment.StageFireworks:GetDescendants()) do
            if d:IsA("ParticleEmitter") then d:Emit(100) end
        end
    elseif effectType == "Pitch" then
        if typeof(value) ~= "number" then return end
        local audio = Workspace:FindFirstChild("MainClubAudio", true)
        if audio and audio:IsA("Sound") then
            audio.PlaybackSpeed = math.clamp(value, 0.5, 1.5)
        end
    elseif effectType == "Volume" then
        if typeof(value) ~= "number" then return end
        local audio = Workspace:FindFirstChild("MainClubAudio", true)
        if audio and audio:IsA("Sound") then
            audio.Volume = math.clamp(value, 0, 2)
        end
    end
end)

local carriesByCarrier = {}
local carriedByTarget = {}

local function clearCarry(carrier)
    local data = carriesByCarrier[carrier]
    if not data then return end
    carriesByCarrier[carrier] = nil
    if data.target then carriedByTarget[data.target] = nil end
    if data.weld and data.weld.Parent then data.weld:Destroy() end
    local targetChar = data.target and data.target.Character
    local hum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

CarryRequestEvent.OnServerEvent:Connect(function(carrier, targetRef)
    if not allow(carrier, "carry", 0.6) then return end
    if targetRef == nil or targetRef == false then clearCarry(carrier) return end

    local target
    if typeof(targetRef) == "Instance" and targetRef:IsA("Player") then
        target = targetRef
    elseif typeof(targetRef) == "number" then
        target = Players:GetPlayerByUserId(targetRef)
    end
    if not target or target == carrier then return end
    if target:GetAttribute("DisableCarry") == true then return end
    if carriedByTarget[target] and carriedByTarget[target] ~= carrier then return end

    local carrierChar, targetChar = carrier.Character, target.Character
    local carrierHum = carrierChar and carrierChar:FindFirstChildOfClass("Humanoid")
    local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
    local carrierRoot = carrierChar and carrierChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    if not carrierHum or not targetHum or not carrierRoot or not targetRoot then return end
    if carrierHum.Health <= 0 or targetHum.Health <= 0 then return end
    if (carrierRoot.Position - targetRoot.Position).Magnitude > 12 then return end

    clearCarry(carrier)
    targetRoot.CFrame = carrierRoot.CFrame * CFrame.new(0, 0.5, 1.25)
    local weld = Instance.new("WeldConstraint")
    weld.Name = "AeroClubCarryWeld"
    weld.Part0 = carrierRoot
    weld.Part1 = targetRoot
    weld.Parent = carrierRoot
    targetHum.PlatformStand = true
    for _, p in ipairs(targetChar:GetDescendants()) do
        if p:IsA("BasePart") then p.Massless = true end
    end
    carriesByCarrier[carrier] = {target = target, weld = weld}
    carriedByTarget[target] = carrier
end)

local function connectCornerStand(stand)
    if stand:GetAttribute("AeroClubConnected") then return end
    local touch = stand:FindFirstChild("TouchPart")
    local assetId = tonumber(stand:GetAttribute("AssetId"))
    local itemType = stand:GetAttribute("ItemType")
    if not touch or not touch:IsA("BasePart") or not assetId or assetId <= 0 then return end
    stand:SetAttribute("AeroClubConnected", true)
    local lastByUser = {}
    touch.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if not player then return end
        local now = os.clock()
        if now - (lastByUser[player.UserId] or 0) < 3 then return end
        lastByUser[player.UserId] = now
        if itemType == "GamePass" then
            MarketplaceService:PromptGamePassPurchase(player, assetId)
        else
            MarketplaceService:PromptPurchase(player, assetId)
        end
    end)
end

local cornerShop = interactiveZones.CornerShop
for _, stand in ipairs(cornerShop:GetChildren()) do connectCornerStand(stand) end
cornerShop.ChildAdded:Connect(function(stand)
    task.defer(connectCornerStand, stand)
end)

local DonationStore = DataStoreService:GetOrderedDataStore("AeroClubTopDonators_v1")

local function findPedestal(name)
    return statues:FindFirstChild(name)
end

local function applyAvatarToDummy(container, userId)
    if not container or userId <= 0 then return end
    local humanoid = container:FindFirstChildOfClass("Humanoid") or container:FindFirstChild("Humanoid", true)
    if not humanoid then return end
    local ok, desc = pcall(Players.GetHumanoidDescriptionFromUserId, Players, userId)
    if ok and desc then pcall(humanoid.ApplyDescription, humanoid, desc) end
end

local function updateDonorHall()
    local ok, pages = pcall(DonationStore.GetSortedAsync, DonationStore, false, 3)
    if not ok or not pages then return end
    local entries = pages:GetCurrentPage()
    local names = {"GoldPedestal", "SilverPedestal", "BronzePedestal"}
    for i = 1, 3 do
        local entry = entries[i]
        if entry then
            local uid = tonumber(entry.key)
            if uid then applyAvatarToDummy(findPedestal(names[i]), uid) end
        end
    end
end

task.spawn(function()
    while task.wait(60) do
        updateDonorHall()
    end
end)

local function checkVIP(player)
    if CONFIG.VipGamePassId <= 0 then return false end
    local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, CONFIG.VipGamePassId)
    return ok and owns or false
end

local function initializePlayer(player)
    player:SetAttribute("Role", resolveRole(player))
    player:SetAttribute("CurrentDanceSpeed", 1)
    player:SetAttribute("DisableCarry", false)
    player:SetAttribute("HasVIP", checkVIP(player))
    player.CharacterAdded:Connect(function(character)
        task.defer(setupNameTag, player, character)
        local hum = character:WaitForChild("Humanoid", 8)
        if hum then hum.Died:Connect(function() clearCarry(player) end) end
    end)
    if player.Character then task.defer(setupNameTag, player, player.Character) end
end

Players.PlayerAdded:Connect(initializePlayer)
for _, player in ipairs(Players:GetPlayers()) do initializePlayer(player) end
Players.PlayerRemoving:Connect(function(player)
    clearCarry(player)
    local carrier = carriedByTarget[player]
    if carrier then clearCarry(carrier) end
    RATE[player.UserId] = nil
end)

ServerAnnouncementEvent.OnServerEvent:Connect(function(player, text)
    local role = player:GetAttribute("Role")
    if role ~= "Owner" and role ~= "Admin" then return end
    if not allow(player, "announce", 4) then return end
    ServerAnnouncementEvent:FireAllClients(filteredBroadcast(player, text))
end)

-- Donation receipt integration is intentionally gated until real product IDs are configured.
if next(CONFIG.DonationProducts) ~= nil or CONFIG.GlobalShoutoutProductId > 0 then
    MarketplaceService.ProcessReceipt = function(receipt)
        local player = Players:GetPlayerByUserId(receipt.PlayerId)
        if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
        local amount = CONFIG.DonationProducts[receipt.ProductId]
        if amount then
            pcall(DonationStore.IncrementAsync, DonationStore, tostring(player.UserId), amount)
            GlobalDonationEvent:FireAllClients(player.DisplayName, amount)
            task.defer(updateDonorHall)
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
end

print("[AEROCLUB] CoreServer v1.0 ready — reset foundation / LAB authority")
