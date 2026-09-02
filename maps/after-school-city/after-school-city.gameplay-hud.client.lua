-- AFTER SCHOOL CITY — V1.0.1 compact gameplay HUD + locale-aware mission/credits UI
-- Client-only presentation pass. Server-authoritative gameplay/rewards/persistence remain unchanged.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalizationService = game:GetService("LocalizationService")

local UI_VERSION = "1.0.1-ui-localization-1"

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
    },
    id = {
        mission = "MISI",
        credits = "KREDIT",
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
    },
}
local L = TEXT[language]

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
    button.Position = UDim2.fromOffset(x, 49)
    button.Size = UDim2.fromOffset(92, 21)
    button.BackgroundColor3 = Color3.fromRGB(38, 51, 72)
    button.BackgroundTransparency = 0.12
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

local function applyState(state)
    if type(state) ~= "table" or state.Ready ~= true then
        return
    end

    latestState = state
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
    refreshMissionPanel()
    missionPanel.Visible = not missionPanel.Visible
end)

missionClose.Activated:Connect(function()
    missionPanel.Visible = false
end)

creditsButton.Activated:Connect(function()
    missionPanel.Visible = false
    creditsPanel.Visible = not creditsPanel.Visible
end)

creditsClose.Activated:Connect(function()
    creditsPanel.Visible = false
end)

statePush.OnClientEvent:Connect(applyState)
toastRemote.OnClientEvent:Connect(showToast)
dialogueRemote.OnClientEvent:Connect(showDialogue)

for attempt = 1, 8 do
    local ok, state = pcall(function()
        return requestState:InvokeServer()
    end)
    if ok and type(state) == "table" and state.Ready then
        applyState(state)
        break
    end
    task.wait(0.5)
end
