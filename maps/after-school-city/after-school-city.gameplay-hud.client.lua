-- AFTER SCHOOL CITY — V1.3 BAG / COLLECTION UI integration
-- Client-only presentation. Ownership, spending, rewards, equip/use authority, and persistence remain server-authoritative.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalizationService = game:GetService("LocalizationService")

local EconomyConfig = require(ReplicatedStorage:WaitForChild("ASCEconomyConfig"))

local UI_VERSION = "1.3.0-bag-collection-1"

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("ASC_Remotes")
local statePush = remotes:WaitForChild("StatePush")
local toastRemote = remotes:WaitForChild("Toast")
local dialogueRemote = remotes:WaitForChild("Dialogue")
local requestState = remotes:WaitForChild("RequestState")

local localeId = string.lower(LocalizationService.RobloxLocaleId or "en-us")
local language = string.sub(localeId, 1, 2) == "id" and "id" or "en"

local TEXT = {
    en = {
        mission = "MISSION",
        credits = "CREDITS",
        bag = "BAG",
        close = "CLOSE",
        reward = "REWARD",
        complete = "Exploration complete",
        coins = "COINS",
        saveOn = "SAVE ON",
        session = "SESSION",
        missionTitle = "CURRENT MISSION",
        creditsTitle = "CREDITS",
        loading = "Loading mission...",
        cityGuide = "CITY GUIDE",
        collectionTitle = "COLLECTION",
        ownedItems = "OWNED ITEMS",
        owned = "OWNED",
        collectible = "COLLECTIBLE",
        loadingCollection = "Loading collection...",
        emptyCollection = "No items yet.",
        emptyHint = "Buy items around the city and they’ll appear here.",
        saveUnavailable = "SAVE UNAVAILABLE",
        sessionOnly = "This collection cannot be verified as saved in this session.",
        collectionUnavailable = "Collection unavailable.",
        retry = "TRY AGAIN",
        unknownItem = "Unknown Item",
        unknownType = "UNKNOWN",
    },
    id = {
        mission = "MISI",
        credits = "KREDIT",
        bag = "BAG",
        close = "TUTUP",
        reward = "HADIAH",
        complete = "Eksplorasi selesai",
        coins = "KOIN",
        saveOn = "SAVE AKTIF",
        session = "SESI",
        missionTitle = "MISI SAAT INI",
        creditsTitle = "KREDIT",
        loading = "Memuat misi...",
        cityGuide = "PANDUAN KOTA",
        collectionTitle = "KOLEKSI",
        ownedItems = "BARANG DIMILIKI",
        owned = "DIMILIKI",
        collectible = "KOLEKSI",
        loadingCollection = "Memuat koleksi...",
        emptyCollection = "Belum ada barang.",
        emptyHint = "Beli barang di kota dan barang akan muncul di sini.",
        saveUnavailable = "SAVE TIDAK TERSEDIA",
        sessionOnly = "Koleksi sesi ini belum dapat diverifikasi tersimpan.",
        collectionUnavailable = "Koleksi tidak tersedia.",
        retry = "COBA LAGI",
        unknownItem = "Barang Tidak Dikenal",
        unknownType = "TIDAK DIKENAL",
    },
}
local L = TEXT[language]

local ITEM_LOCALIZATION = {
    CAMPUS_NOTEBOOK = {en = "Campus Notebook", id = "Buku Catatan Kampus"},
    CITY_STICKER_PACK = {en = "City Sticker Pack", id = "Paket Stiker Kota"},
    ASC_KEYCHAIN = {en = "ASC Keychain", id = "Gantungan Kunci ASC"},
    STUDENT_TOTE = {en = "Student Tote", id = "Tas Tote Pelajar"},
}

local QUEST_LOCALIZATION = {
    FIRST_STEPS_DOWNTOWN = {
        en = {title = "First Steps", objective = "Visit Downtown"},
        id = {title = "Langkah Pertama", objective = "Pergi ke Downtown"},
    },
    VISIT_SKATEPARK = {
        en = {title = "Find the Skatepark", objective = "Visit the Skatepark"},
        id = {title = "Cari Skatepark", objective = "Pergi ke Skatepark"},
    },
    VISIT_CITY_PARK = {
        en = {title = "City Explorer", objective = "Visit City Park"},
        id = {title = "Penjelajah Kota", objective = "Pergi ke City Park"},
    },
}

local EXACT_LOCALIZATION_ID = {
    ["Profile ready"] = "Profil siap",
    ["Progress will save automatically."] = "Progress akan tersimpan otomatis.",
    ["Save temporarily unavailable"] = "Penyimpanan sementara tidak tersedia",
    ["This session will not overwrite your cloud progress."] = "Sesi ini tidak akan menimpa progress cloud kamu.",
    ["Reward earned"] = "Hadiah diterima",
    ["First Steps complete"] = "Langkah Pertama selesai",
    ["Find the Skatepark complete"] = "Cari Skatepark selesai",
    ["City Explorer complete"] = "Penjelajah Kota selesai",
    ["Visit Downtown"] = "Pergi ke Downtown",
    ["Visit the Skatepark"] = "Pergi ke Skatepark",
    ["Visit City Park"] = "Pergi ke City Park",
    ["Exploration complete. New activities are coming next."] = "Eksplorasi selesai. Aktivitas baru akan hadir berikutnya.",
    ["CITY GUIDE"] = "PANDUAN KOTA",
}

local function localizeServerText(value)
    local text = tostring(value or "")
    if language ~= "id" then
        return text
    end
    local exact = EXACT_LOCALIZATION_ID[text]
    if exact then
        return exact
    end
    text = string.gsub(text, " Coins", " Koin")
    return text
end

local function questCopy(quest)
    if type(quest) ~= "table" then
        return nil
    end
    local localized = QUEST_LOCALIZATION[quest.Id]
    if localized and localized[language] then
        return localized[language]
    end
    return {
        title = localizeServerText(quest.Title or ""),
        objective = localizeServerText(quest.Objective or quest.Title or ""),
    }
end

local catalog = {}
local catalogById = {}
if EconomyConfig.FirstShop and type(EconomyConfig.FirstShop.Items) == "table" then
    for index, item in ipairs(EconomyConfig.FirstShop.Items) do
        if type(item) == "table" and type(item.Id) == "string" then
            catalog[index] = item
            catalogById[item.Id] = item
        end
    end
end

local function localizedItemName(itemId, metadata)
    local localized = ITEM_LOCALIZATION[itemId]
    if localized and localized[language] then
        return localized[language]
    end
    if metadata and metadata.DisplayName then
        return tostring(metadata.DisplayName)
    end
    return L.unknownItem
end

local function localizedKind(metadata)
    if not metadata then
        return L.unknownType
    end
    if metadata.Kind == "Collectible" then
        return L.collectible
    end
    return tostring(metadata.Kind or L.unknownType)
end

local gui = Instance.new("ScreenGui")
gui.Name = "ASC_GameplayHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 20
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui:SetAttribute("ASC_UIVersion", UI_VERSION)
gui:SetAttribute("ASC_Locale", localeId)
gui.Parent = playerGui

local card = Instance.new("Frame")
card.Name = "StatusCard"
card.AnchorPoint = Vector2.new(0.5, 0)
card.Position = UDim2.new(0.5, 0, 0, 18)
card.Size = UDim2.fromOffset(336, 76)
card.BackgroundColor3 = Color3.fromRGB(18, 24, 36)
card.BackgroundTransparency = 0.10
card.BorderSizePixel = 0
card.Visible = false
card.Parent = gui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 11)
cardCorner.Parent = card

local cardStroke = Instance.new("UIStroke")
cardStroke.Thickness = 1
cardStroke.Transparency = 0.58
cardStroke.Color = Color3.fromRGB(255, 255, 255)
cardStroke.Parent = card

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(13, 6)
title.Size = UDim2.new(1, -104, 0, 16)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(226, 232, 240)
title.Text = "AFTER SCHOOL CITY"
title.Parent = card

local saveBadge = Instance.new("TextLabel")
saveBadge.Name = "SaveBadge"
saveBadge.AnchorPoint = Vector2.new(1, 0)
saveBadge.Position = UDim2.new(1, -12, 0, 6)
saveBadge.Size = UDim2.fromOffset(82, 16)
saveBadge.BackgroundTransparency = 1
saveBadge.Font = Enum.Font.GothamBold
saveBadge.TextSize = 9
saveBadge.TextXAlignment = Enum.TextXAlignment.Right
saveBadge.TextColor3 = Color3.fromRGB(148, 163, 184)
saveBadge.Text = "..."
saveBadge.Parent = card

local stats = Instance.new("TextLabel")
stats.Name = "Stats"
stats.BackgroundTransparency = 1
stats.Position = UDim2.fromOffset(13, 23)
stats.Size = UDim2.new(1, -26, 0, 21)
stats.Font = Enum.Font.GothamBlack
stats.TextSize = 15
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.TextColor3 = Color3.fromRGB(255, 255, 255)
stats.Text = "250 " .. L.coins .. "  •  REP 0  •  LV 1"
stats.Parent = card

local function smallButton(name, text, x)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Position = UDim2.fromOffset(x, 46)
    button.Size = UDim2.fromOffset(92, 28)
    button.BackgroundColor3 = Color3.fromRGB(38, 51, 72)
    button.BackgroundTransparency = 0.40
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.TextSize = 10
    button.TextColor3 = Color3.fromRGB(232, 238, 247)
    button.Text = text
    button.AutoButtonColor = true
    button.Parent = card
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button
    return button
end

local missionButton = smallButton("MissionButton", L.mission, 13)
local creditsButton = smallButton("CreditsButton", L.credits, 111)
local bagButton = smallButton("BagButton", L.bag, 209)

local missionPanel = Instance.new("Frame")
missionPanel.Name = "MissionPanel"
missionPanel.AnchorPoint = Vector2.new(0.5, 0)
missionPanel.Position = UDim2.new(0.5, 0, 0, 101)
missionPanel.Size = UDim2.fromOffset(336, 112)
missionPanel.BackgroundColor3 = Color3.fromRGB(15, 22, 34)
missionPanel.BackgroundTransparency = 0.06
missionPanel.BorderSizePixel = 0
missionPanel.Visible = false
missionPanel.ZIndex = 30
missionPanel.Parent = gui

local missionCorner = Instance.new("UICorner")
missionCorner.CornerRadius = UDim.new(0, 11)
missionCorner.Parent = missionPanel
local missionStroke = Instance.new("UIStroke")
missionStroke.Thickness = 1
missionStroke.Transparency = 0.58
missionStroke.Color = Color3.fromRGB(255, 255, 255)
missionStroke.Parent = missionPanel

local missionHeading = Instance.new("TextLabel")
missionHeading.BackgroundTransparency = 1
missionHeading.Position = UDim2.fromOffset(14, 9)
missionHeading.Size = UDim2.new(1, -88, 0, 16)
missionHeading.Font = Enum.Font.GothamBold
missionHeading.TextSize = 11
missionHeading.TextXAlignment = Enum.TextXAlignment.Left
missionHeading.TextColor3 = Color3.fromRGB(147, 197, 253)
missionHeading.Text = L.missionTitle
missionHeading.ZIndex = 31
missionHeading.Parent = missionPanel

local missionClose = Instance.new("TextButton")
missionClose.AnchorPoint = Vector2.new(1, 0)
missionClose.Position = UDim2.new(1, -10, 0, 7)
missionClose.Size = UDim2.fromOffset(60, 20)
missionClose.BackgroundColor3 = Color3.fromRGB(35, 45, 62)
missionClose.BackgroundTransparency = 0.40
missionClose.BorderSizePixel = 0
missionClose.Font = Enum.Font.GothamBold
missionClose.TextSize = 9
missionClose.TextColor3 = Color3.fromRGB(226, 232, 240)
missionClose.Text = L.close
missionClose.ZIndex = 31
missionClose.Parent = missionPanel
local missionCloseCorner = Instance.new("UICorner")
missionCloseCorner.CornerRadius = UDim.new(0, 7)
missionCloseCorner.Parent = missionClose

local missionTitle = Instance.new("TextLabel")
missionTitle.BackgroundTransparency = 1
missionTitle.Position = UDim2.fromOffset(14, 32)
missionTitle.Size = UDim2.new(1, -28, 0, 20)
missionTitle.Font = Enum.Font.GothamBlack
missionTitle.TextSize = 14
missionTitle.TextXAlignment = Enum.TextXAlignment.Left
missionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
missionTitle.Text = L.loading
missionTitle.ZIndex = 31
missionTitle.Parent = missionPanel

local missionObjective = Instance.new("TextLabel")
missionObjective.BackgroundTransparency = 1
missionObjective.Position = UDim2.fromOffset(14, 54)
missionObjective.Size = UDim2.new(1, -28, 0, 25)
missionObjective.Font = Enum.Font.GothamMedium
missionObjective.TextSize = 12
missionObjective.TextWrapped = true
missionObjective.TextXAlignment = Enum.TextXAlignment.Left
missionObjective.TextYAlignment = Enum.TextYAlignment.Top
missionObjective.TextColor3 = Color3.fromRGB(203, 213, 225)
missionObjective.Text = ""
missionObjective.ZIndex = 31
missionObjective.Parent = missionPanel

local missionReward = Instance.new("TextLabel")
missionReward.BackgroundTransparency = 1
missionReward.Position = UDim2.fromOffset(14, 84)
missionReward.Size = UDim2.new(1, -28, 0, 18)
missionReward.Font = Enum.Font.GothamBold
missionReward.TextSize = 10
missionReward.TextXAlignment = Enum.TextXAlignment.Left
missionReward.TextColor3 = Color3.fromRGB(134, 239, 172)
missionReward.Text = ""
missionReward.ZIndex = 31
missionReward.Parent = missionPanel

local creditsPanel = Instance.new("Frame")
creditsPanel.Name = "CreditsPanel"
creditsPanel.AnchorPoint = Vector2.new(0.5, 0.5)
creditsPanel.Position = UDim2.fromScale(0.5, 0.5)
creditsPanel.Size = UDim2.fromOffset(360, 236)
creditsPanel.BackgroundColor3 = Color3.fromRGB(14, 20, 31)
creditsPanel.BackgroundTransparency = 0.03
creditsPanel.BorderSizePixel = 0
creditsPanel.Visible = false
creditsPanel.ZIndex = 40
creditsPanel.Parent = gui

local creditsCorner = Instance.new("UICorner")
creditsCorner.CornerRadius = UDim.new(0, 14)
creditsCorner.Parent = creditsPanel
local creditsStroke = Instance.new("UIStroke")
creditsStroke.Thickness = 1.5
creditsStroke.Transparency = 0.3
creditsStroke.Color = Color3.fromRGB(255, 198, 76)
creditsStroke.Parent = creditsPanel

local creditsHeading = Instance.new("TextLabel")
creditsHeading.BackgroundTransparency = 1
creditsHeading.Position = UDim2.fromOffset(18, 12)
creditsHeading.Size = UDim2.new(1, -100, 0, 18)
creditsHeading.Font = Enum.Font.GothamBold
creditsHeading.TextSize = 12
creditsHeading.TextXAlignment = Enum.TextXAlignment.Left
creditsHeading.TextColor3 = Color3.fromRGB(118, 192, 255)
creditsHeading.Text = L.creditsTitle
creditsHeading.ZIndex = 41
creditsHeading.Parent = creditsPanel

local creditsClose = Instance.new("TextButton")
creditsClose.AnchorPoint = Vector2.new(1, 0)
creditsClose.Position = UDim2.new(1, -12, 0, 9)
creditsClose.Size = UDim2.fromOffset(64, 22)
creditsClose.BackgroundColor3 = Color3.fromRGB(39, 49, 67)
creditsClose.BackgroundTransparency = 0.40
creditsClose.BorderSizePixel = 0
creditsClose.Font = Enum.Font.GothamBold
creditsClose.TextSize = 9
creditsClose.TextColor3 = Color3.fromRGB(240, 244, 250)
creditsClose.Text = L.close
creditsClose.ZIndex = 41
creditsClose.Parent = creditsPanel
local creditsCloseCorner = Instance.new("UICorner")
creditsCloseCorner.CornerRadius = UDim.new(0, 7)
creditsCloseCorner.Parent = creditsClose

local creditBody = Instance.new("TextLabel")
creditBody.BackgroundTransparency = 1
creditBody.Position = UDim2.fromOffset(20, 43)
creditBody.Size = UDim2.new(1, -40, 1, -58)
creditBody.Font = Enum.Font.GothamMedium
creditBody.TextSize = 14
creditBody.TextWrapped = true
creditBody.TextXAlignment = Enum.TextXAlignment.Center
creditBody.TextYAlignment = Enum.TextYAlignment.Center
creditBody.TextColor3 = Color3.fromRGB(232, 237, 245)
creditBody.Text = "AFTER SCHOOL CITY\n\nA GAME MADE FOR\nPUTU AZYA PUTRI BINTANG HARDAJAYA\n\nThis game was made especially for you.\n\nWITH LOVE, DAD\n\nENTER THE CITY."
creditBody.ZIndex = 41
creditBody.Parent = creditsPanel

local bagPanel = Instance.new("Frame")
bagPanel.Name = "BagPanel"
bagPanel.AnchorPoint = Vector2.new(0.5, 0)
bagPanel.Position = UDim2.new(0.5, 0, 0, 101)
bagPanel.Size = UDim2.fromOffset(336, 308)
bagPanel.BackgroundColor3 = Color3.fromRGB(15, 22, 34)
bagPanel.BackgroundTransparency = 0.46
bagPanel.BorderSizePixel = 0
bagPanel.Visible = false
bagPanel.ZIndex = 35
bagPanel.Parent = gui

local bagCorner = Instance.new("UICorner")
bagCorner.CornerRadius = UDim.new(0, 11)
bagCorner.Parent = bagPanel
local bagStroke = Instance.new("UIStroke")
bagStroke.Thickness = 1
bagStroke.Transparency = 0.70
bagStroke.Color = Color3.fromRGB(255, 255, 255)
bagStroke.Parent = bagPanel

local bagHeading = Instance.new("TextLabel")
bagHeading.Name = "CollectionHeading"
bagHeading.BackgroundTransparency = 1
bagHeading.Position = UDim2.fromOffset(14, 10)
bagHeading.Size = UDim2.new(1, -158, 0, 18)
bagHeading.Font = Enum.Font.GothamBold
bagHeading.TextSize = 12
bagHeading.TextXAlignment = Enum.TextXAlignment.Left
bagHeading.TextColor3 = Color3.fromRGB(147, 197, 253)
bagHeading.Text = L.collectionTitle
bagHeading.ZIndex = 36
bagHeading.Parent = bagPanel

local bagCount = Instance.new("TextLabel")
bagCount.Name = "CollectionCount"
bagCount.AnchorPoint = Vector2.new(1, 0)
bagCount.Position = UDim2.new(1, -84, 0, 11)
bagCount.Size = UDim2.fromOffset(90, 16)
bagCount.BackgroundTransparency = 1
bagCount.Font = Enum.Font.GothamMedium
bagCount.TextSize = 9
bagCount.TextXAlignment = Enum.TextXAlignment.Right
bagCount.TextColor3 = Color3.fromRGB(148, 163, 184)
bagCount.Text = ""
bagCount.ZIndex = 36
bagCount.Parent = bagPanel

local bagClose = Instance.new("TextButton")
bagClose.Name = "CloseButton"
bagClose.AnchorPoint = Vector2.new(1, 0)
bagClose.Position = UDim2.new(1, -10, 0, 7)
bagClose.Size = UDim2.fromOffset(64, 28)
bagClose.BackgroundColor3 = Color3.fromRGB(35, 45, 62)
bagClose.BackgroundTransparency = 0.40
bagClose.BorderSizePixel = 0
bagClose.Font = Enum.Font.GothamBold
bagClose.TextSize = 9
bagClose.TextColor3 = Color3.fromRGB(226, 232, 240)
bagClose.Text = L.close
bagClose.ZIndex = 36
bagClose.Parent = bagPanel
local bagCloseCorner = Instance.new("UICorner")
bagCloseCorner.CornerRadius = UDim.new(0, 7)
bagCloseCorner.Parent = bagClose

local persistenceWarning = Instance.new("Frame")
persistenceWarning.Name = "PersistenceWarning"
persistenceWarning.Position = UDim2.fromOffset(12, 42)
persistenceWarning.Size = UDim2.new(1, -24, 0, 48)
persistenceWarning.BackgroundColor3 = Color3.fromRGB(73, 50, 28)
persistenceWarning.BackgroundTransparency = 0.50
persistenceWarning.BorderSizePixel = 0
persistenceWarning.Visible = false
persistenceWarning.ZIndex = 36
persistenceWarning.Parent = bagPanel
local warningCorner = Instance.new("UICorner")
warningCorner.CornerRadius = UDim.new(0, 8)
warningCorner.Parent = persistenceWarning

local warningTitle = Instance.new("TextLabel")
warningTitle.BackgroundTransparency = 1
warningTitle.Position = UDim2.fromOffset(10, 5)
warningTitle.Size = UDim2.new(1, -20, 0, 15)
warningTitle.Font = Enum.Font.GothamBold
warningTitle.TextSize = 10
warningTitle.TextXAlignment = Enum.TextXAlignment.Left
warningTitle.TextColor3 = Color3.fromRGB(253, 186, 116)
warningTitle.Text = L.saveUnavailable
warningTitle.ZIndex = 37
warningTitle.Parent = persistenceWarning

local warningBody = Instance.new("TextLabel")
warningBody.BackgroundTransparency = 1
warningBody.Position = UDim2.fromOffset(10, 20)
warningBody.Size = UDim2.new(1, -20, 0, 23)
warningBody.Font = Enum.Font.GothamMedium
warningBody.TextSize = 9
warningBody.TextWrapped = true
warningBody.TextXAlignment = Enum.TextXAlignment.Left
warningBody.TextYAlignment = Enum.TextYAlignment.Top
warningBody.TextColor3 = Color3.fromRGB(226, 232, 240)
warningBody.Text = L.sessionOnly
warningBody.ZIndex = 37
warningBody.Parent = persistenceWarning

local stateMessage = Instance.new("TextLabel")
stateMessage.Name = "StateMessage"
stateMessage.AnchorPoint = Vector2.new(0.5, 0.5)
stateMessage.Position = UDim2.fromScale(0.5, 0.55)
stateMessage.Size = UDim2.new(1, -38, 0, 72)
stateMessage.BackgroundTransparency = 1
stateMessage.Font = Enum.Font.GothamMedium
stateMessage.TextSize = 12
stateMessage.TextWrapped = true
stateMessage.TextXAlignment = Enum.TextXAlignment.Center
stateMessage.TextYAlignment = Enum.TextYAlignment.Center
stateMessage.TextColor3 = Color3.fromRGB(203, 213, 225)
stateMessage.Text = L.loadingCollection
stateMessage.ZIndex = 36
stateMessage.Parent = bagPanel

local retryButton = Instance.new("TextButton")
retryButton.Name = "RetryButton"
retryButton.AnchorPoint = Vector2.new(0.5, 0.5)
retryButton.Position = UDim2.fromScale(0.5, 0.70)
retryButton.Size = UDim2.fromOffset(104, 30)
retryButton.BackgroundColor3 = Color3.fromRGB(38, 51, 72)
retryButton.BackgroundTransparency = 0.40
retryButton.BorderSizePixel = 0
retryButton.Font = Enum.Font.GothamBold
retryButton.TextSize = 10
retryButton.TextColor3 = Color3.fromRGB(232, 238, 247)
retryButton.Text = L.retry
retryButton.Visible = false
retryButton.ZIndex = 37
retryButton.Parent = bagPanel
local retryCorner = Instance.new("UICorner")
retryCorner.CornerRadius = UDim.new(0, 7)
retryCorner.Parent = retryButton

local itemScroll = Instance.new("ScrollingFrame")
itemScroll.Name = "ItemScroll"
itemScroll.Position = UDim2.fromOffset(12, 46)
itemScroll.Size = UDim2.new(1, -24, 1, -58)
itemScroll.BackgroundTransparency = 1
itemScroll.BorderSizePixel = 0
itemScroll.CanvasSize = UDim2.fromOffset(0, 0)
itemScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
itemScroll.ScrollBarThickness = 4
itemScroll.ScrollingDirection = Enum.ScrollingDirection.Y
itemScroll.Visible = false
itemScroll.ZIndex = 36
itemScroll.Parent = bagPanel

local itemLayout = Instance.new("UIListLayout")
itemLayout.Padding = UDim.new(0, 8)
itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
itemLayout.Parent = itemScroll

local function layoutBagPanel()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local width = math.min(336, math.max(240, viewport.X - 24))
    local maxHeight = math.max(190, viewport.Y - 113)
    local height = math.min(308, maxHeight)
    local desiredOffset = math.clamp(math.floor(viewport.X * 0.045), 48, 78)
    local maxOffset = math.max(0, ((viewport.X - width) * 0.5) - 12)
    local offset = math.min(desiredOffset, maxOffset)
    bagPanel.Size = UDim2.fromOffset(width, height)
    bagPanel.Position = UDim2.new(0.5, offset, 0, 101)
end

layoutBagPanel()
local bagCamera = workspace.CurrentCamera
if bagCamera then
    bagCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutBagPanel)
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    bagCamera = workspace.CurrentCamera
    layoutBagPanel()
    if bagCamera then
        bagCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutBagPanel)
    end
end)

local toastFrame = Instance.new("Frame")
toastFrame.Name = "Toast"
toastFrame.AnchorPoint = Vector2.new(0.5, 1)
toastFrame.Position = UDim2.new(0.5, 0, 1, -24)
toastFrame.Size = UDim2.fromOffset(340, 62)
toastFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
toastFrame.BackgroundTransparency = 1
toastFrame.BorderSizePixel = 0
toastFrame.Visible = false
toastFrame.Parent = gui

local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = UDim.new(0, 10)
toastCorner.Parent = toastFrame

local toastTitle = Instance.new("TextLabel")
toastTitle.BackgroundTransparency = 1
toastTitle.Position = UDim2.fromOffset(14, 8)
toastTitle.Size = UDim2.new(1, -28, 0, 20)
toastTitle.Font = Enum.Font.GothamBold
toastTitle.TextSize = 14
toastTitle.TextXAlignment = Enum.TextXAlignment.Left
toastTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
toastTitle.TextTransparency = 1
toastTitle.Parent = toastFrame

local toastBody = Instance.new("TextLabel")
toastBody.BackgroundTransparency = 1
toastBody.Position = UDim2.fromOffset(14, 29)
toastBody.Size = UDim2.new(1, -28, 0, 24)
toastBody.Font = Enum.Font.GothamMedium
toastBody.TextSize = 12
toastBody.TextXAlignment = Enum.TextXAlignment.Left
toastBody.TextColor3 = Color3.fromRGB(203, 213, 225)
toastBody.TextTransparency = 1
toastBody.Parent = toastFrame

local dialogueFrame = Instance.new("Frame")
dialogueFrame.Name = "Dialogue"
dialogueFrame.AnchorPoint = Vector2.new(0.5, 1)
dialogueFrame.Position = UDim2.new(0.5, 0, 1, -96)
dialogueFrame.Size = UDim2.fromOffset(390, 84)
dialogueFrame.BackgroundColor3 = Color3.fromRGB(17, 24, 39)
dialogueFrame.BackgroundTransparency = 0.08
dialogueFrame.BorderSizePixel = 0
dialogueFrame.Visible = false
dialogueFrame.Parent = gui

local dialogueCorner = Instance.new("UICorner")
dialogueCorner.CornerRadius = UDim.new(0, 12)
dialogueCorner.Parent = dialogueFrame

local speakerLabel = Instance.new("TextLabel")
speakerLabel.BackgroundTransparency = 1
speakerLabel.Position = UDim2.fromOffset(16, 10)
speakerLabel.Size = UDim2.new(1, -32, 0, 18)
speakerLabel.Font = Enum.Font.GothamBold
speakerLabel.TextSize = 12
speakerLabel.TextXAlignment = Enum.TextXAlignment.Left
speakerLabel.TextColor3 = Color3.fromRGB(147, 197, 253)
speakerLabel.Parent = dialogueFrame

local dialogueText = Instance.new("TextLabel")
dialogueText.BackgroundTransparency = 1
dialogueText.Position = UDim2.fromOffset(16, 31)
dialogueText.Size = UDim2.new(1, -32, 0, 42)
dialogueText.Font = Enum.Font.GothamMedium
dialogueText.TextSize = 14
dialogueText.TextWrapped = true
dialogueText.TextXAlignment = Enum.TextXAlignment.Left
dialogueText.TextYAlignment = Enum.TextYAlignment.Top
dialogueText.TextColor3 = Color3.fromRGB(241, 245, 249)
dialogueText.Parent = dialogueFrame

local toastToken = 0
local dialogueToken = 0
local latestState = nil
local collectionRequestFailed = false
local applyState

local function refreshMissionPanel()
    local state = latestState
    if not state or state.Ready ~= true then
        missionTitle.Text = L.loading
        missionObjective.Text = ""
        missionReward.Text = ""
        return
    end

    if state.Quest then
        local copy = questCopy(state.Quest)
        missionTitle.Text = copy and copy.title or localizeServerText(state.Quest.Title or L.mission)
        missionObjective.Text = copy and copy.objective or localizeServerText(state.Quest.Objective or "")
        missionReward.Text = string.format("%s  •  +%d %s  •  +%d REP", L.reward, state.Quest.RewardCoins or 0, L.coins, state.Quest.RewardRep or 0)
    else
        missionTitle.Text = L.complete
        missionObjective.Text = language == "id" and "Semua misi eksplorasi awal sudah selesai." or "All starter exploration missions are complete."
        missionReward.Text = ""
    end
end

local function clearItemCards()
    for _, child in ipairs(itemScroll:GetChildren()) do
        if child:IsA("Frame") and child:GetAttribute("ASC_BagItemCard") == true then
            child:Destroy()
        end
    end
end

local function makeItemCard(itemId, count, metadata, layoutOrder)
    local cardFrame = Instance.new("Frame")
    cardFrame.Name = "Item_" .. string.gsub(itemId, "[^%w_]", "_")
    cardFrame.Size = UDim2.new(1, -4, 0, 66)
    cardFrame.BackgroundColor3 = Color3.fromRGB(27, 36, 51)
    cardFrame.BackgroundTransparency = 0.52
    cardFrame.BorderSizePixel = 0
    cardFrame.LayoutOrder = layoutOrder
    cardFrame.ZIndex = 36
    cardFrame:SetAttribute("ASC_BagItemCard", true)
    cardFrame:SetAttribute("ASC_ItemId", itemId)
    cardFrame.Parent = itemScroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = cardFrame

    local swatch = Instance.new("Frame")
    swatch.Name = "ColorIdentity"
    swatch.Position = UDim2.fromOffset(10, 13)
    swatch.Size = UDim2.fromOffset(40, 40)
    swatch.BackgroundColor3 = metadata and metadata.Color or Color3.fromRGB(100, 116, 139)
    swatch.BackgroundTransparency = 0.12
    swatch.BorderSizePixel = 0
    swatch.ZIndex = 37
    swatch.Parent = cardFrame
    local swatchCorner = Instance.new("UICorner")
    swatchCorner.CornerRadius = UDim.new(0, 8)
    swatchCorner.Parent = swatch

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "ItemName"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Position = UDim2.fromOffset(60, 10)
    nameLabel.Size = UDim2.new(1, -142, 0, 22)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextColor3 = Color3.fromRGB(241, 245, 249)
    nameLabel.Text = localizedItemName(itemId, metadata)
    nameLabel.ZIndex = 37
    nameLabel.Parent = cardFrame

    local kindLabel = Instance.new("TextLabel")
    kindLabel.Name = "Category"
    kindLabel.BackgroundTransparency = 1
    kindLabel.Position = UDim2.fromOffset(60, 34)
    kindLabel.Size = UDim2.new(1, -142, 0, 18)
    kindLabel.Font = Enum.Font.GothamMedium
    kindLabel.TextSize = 9
    kindLabel.TextXAlignment = Enum.TextXAlignment.Left
    kindLabel.TextColor3 = Color3.fromRGB(148, 163, 184)
    if metadata then
        kindLabel.Text = localizedKind(metadata)
    else
        kindLabel.Text = string.format("%s  •  %s", L.unknownType, itemId)
    end
    kindLabel.ZIndex = 37
    kindLabel.Parent = cardFrame

    local ownedBadge = Instance.new("TextLabel")
    ownedBadge.Name = "OwnedBadge"
    ownedBadge.AnchorPoint = Vector2.new(1, 0.5)
    ownedBadge.Position = UDim2.new(1, -10, 0.5, 0)
    ownedBadge.Size = UDim2.fromOffset(72, 24)
    ownedBadge.BackgroundColor3 = Color3.fromRGB(30, 74, 59)
    ownedBadge.BackgroundTransparency = 0.42
    ownedBadge.BorderSizePixel = 0
    ownedBadge.Font = Enum.Font.GothamBold
    ownedBadge.TextSize = 9
    ownedBadge.TextColor3 = Color3.fromRGB(134, 239, 172)
    ownedBadge.Text = count > 1 and string.format("%s ×%d", L.owned, count) or L.owned
    ownedBadge.ZIndex = 37
    ownedBadge.Parent = cardFrame
    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 7)
    badgeCorner.Parent = ownedBadge
end

local function refreshBagPanel()
    clearItemCards()
    retryButton.Visible = false
    itemScroll.Visible = false
    stateMessage.Visible = true
    bagCount.Text = ""

    local state = latestState
    if not state then
        persistenceWarning.Visible = false
        if collectionRequestFailed then
            stateMessage.Text = L.collectionUnavailable
            retryButton.Visible = true
        else
            stateMessage.Text = L.loadingCollection
        end
        return
    end

    persistenceWarning.Visible = state.Persistent == false
    local topY = persistenceWarning.Visible and 98 or 46
    itemScroll.Position = UDim2.fromOffset(12, topY)
    itemScroll.Size = UDim2.new(1, -24, 1, -(topY + 12))

    if type(state.Inventory) ~= "table" then
        stateMessage.Text = L.collectionUnavailable
        retryButton.Visible = true
        return
    end

    local entries = {}
    local seen = {}
    for index, metadata in ipairs(catalog) do
        local count = math.max(0, math.floor(tonumber(state.Inventory[metadata.Id]) or 0))
        if count > 0 then
            table.insert(entries, {Id = metadata.Id, Count = count, Metadata = metadata, Order = index})
            seen[metadata.Id] = true
        end
    end

    local unknownIds = {}
    for itemId, rawCount in pairs(state.Inventory) do
        local count = math.max(0, math.floor(tonumber(rawCount) or 0))
        if count > 0 and type(itemId) == "string" and not seen[itemId] then
            table.insert(unknownIds, itemId)
        end
    end
    table.sort(unknownIds)
    for _, itemId in ipairs(unknownIds) do
        table.insert(entries, {
            Id = itemId,
            Count = math.max(0, math.floor(tonumber(state.Inventory[itemId]) or 0)),
            Metadata = catalogById[itemId],
            Order = #catalog + #entries + 1,
        })
    end

    bagCount.Text = string.format("%d %s", #entries, L.ownedItems)

    if #entries == 0 then
        stateMessage.Text = L.emptyCollection .. "\n" .. L.emptyHint
        return
    end

    stateMessage.Visible = false
    itemScroll.Visible = true
    for index, entry in ipairs(entries) do
        makeItemCard(entry.Id, entry.Count, entry.Metadata, index)
    end
end

applyState = function(state)
    if type(state) ~= "table" or state.Ready ~= true then
        return
    end

    latestState = state
    collectionRequestFailed = false
    card.Visible = true
    stats.Text = string.format("%d %s  •  REP %d  •  LV %d", state.Coins or 0, L.coins, state.Rep or 0, state.Level or 1)

    if state.Persistent then
        saveBadge.Text = L.saveOn
        saveBadge.TextColor3 = Color3.fromRGB(134, 239, 172)
    else
        saveBadge.Text = L.session
        saveBadge.TextColor3 = Color3.fromRGB(253, 186, 116)
    end

    refreshMissionPanel()
    refreshBagPanel()
end

local function requestAuthoritativeState()
    local ok, state = pcall(function()
        return requestState:InvokeServer()
    end)
    if ok and type(state) == "table" and state.Ready == true then
        applyState(state)
        return true
    end
    return false
end

local function showToast(headline, body)
    toastToken += 1
    local token = toastToken
    toastFrame.Visible = true
    toastTitle.Text = localizeServerText(headline or "AFTER SCHOOL CITY")
    toastBody.Text = localizeServerText(body or "")
    toastFrame.BackgroundTransparency = 1
    toastTitle.TextTransparency = 1
    toastBody.TextTransparency = 1

    TweenService:Create(toastFrame, TweenInfo.new(0.18), {BackgroundTransparency = 0.08}):Play()
    TweenService:Create(toastTitle, TweenInfo.new(0.18), {TextTransparency = 0}):Play()
    TweenService:Create(toastBody, TweenInfo.new(0.18), {TextTransparency = 0}):Play()

    task.delay(3.2, function()
        if token ~= toastToken then
            return
        end
        TweenService:Create(toastFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        TweenService:Create(toastTitle, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        TweenService:Create(toastBody, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        task.wait(0.22)
        if token == toastToken then
            toastFrame.Visible = false
        end
    end)
end

local function showDialogue(payload)
    if type(payload) ~= "table" then
        return
    end
    dialogueToken += 1
    local token = dialogueToken
    speakerLabel.Text = localizeServerText(payload.Speaker or L.cityGuide)
    dialogueText.Text = localizeServerText(payload.Text or "")
    dialogueFrame.Visible = true

    task.delay(4.5, function()
        if token == dialogueToken then
            dialogueFrame.Visible = false
        end
    end)
end

missionButton.Activated:Connect(function()
    creditsPanel.Visible = false
    bagPanel.Visible = false
    refreshMissionPanel()
    missionPanel.Visible = not missionPanel.Visible
end)

missionClose.Activated:Connect(function()
    missionPanel.Visible = false
end)

creditsButton.Activated:Connect(function()
    missionPanel.Visible = false
    bagPanel.Visible = false
    creditsPanel.Visible = not creditsPanel.Visible
end)

creditsClose.Activated:Connect(function()
    creditsPanel.Visible = false
end)

bagButton.Activated:Connect(function()
    missionPanel.Visible = false
    creditsPanel.Visible = false
    layoutBagPanel()
    refreshBagPanel()
    bagPanel.Visible = not bagPanel.Visible
end)

bagClose.Activated:Connect(function()
    bagPanel.Visible = false
end)

retryButton.Activated:Connect(function()
    collectionRequestFailed = false
    stateMessage.Text = L.loadingCollection
    retryButton.Visible = false
    if not requestAuthoritativeState() then
        collectionRequestFailed = true
        refreshBagPanel()
    end
end)

statePush.OnClientEvent:Connect(applyState)
toastRemote.OnClientEvent:Connect(showToast)
dialogueRemote.OnClientEvent:Connect(showDialogue)

for attempt = 1, 8 do
    if requestAuthoritativeState() then
        break
    end
    if attempt == 8 then
        collectionRequestFailed = true
        refreshBagPanel()
    else
        task.wait(0.5)
    end
end
