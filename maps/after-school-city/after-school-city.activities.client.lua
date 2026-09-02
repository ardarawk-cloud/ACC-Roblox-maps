-- AFTER SCHOOL CITY — V1.1 activity presentation

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("ASC_Remotes")
local activityState = remotes:WaitForChild("ActivityState")

local localeId = string.lower(LocalizationService.RobloxLocaleId or "en-us")
local lang = string.sub(localeId, 1, 2) == "id" and "id" or "en"

local T = {
    en = {
        start = "START",
        skate = "SKATE LINE",
        pool = "POOL LAPS",
        delivery = "CITY DELIVERY",
        checkpoint = "CHECKPOINT",
        destination = "DESTINATION",
        complete = "COMPLETE",
        failed = "TIME UP",
        busy = "Finish your current activity first",
        cooldown = "Activity cooling down",
        profile = "Profile is still loading",
    },
    id = {
        start = "MULAI",
        skate = "TANTANGAN SKATE",
        pool = "RENANG KELILING",
        delivery = "ANTARAN KOTA",
        checkpoint = "TITIK",
        destination = "TUJUAN",
        complete = "SELESAI",
        failed = "WAKTU HABIS",
        busy = "Selesaikan aktivitas yang sedang berjalan",
        cooldown = "Aktivitas masih cooldown",
        profile = "Profil masih dimuat",
    },
}
local L = T[lang]

local titles = {
    SKATE_LINE = L.skate,
    POOL_LAPS = L.pool,
    CITY_DELIVERY = L.delivery,
}

local gui = Instance.new("ScreenGui")
gui.Name = "ASC_ActivityHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 24
gui.Parent = playerGui

local card = Instance.new("Frame")
card.Name = "ActivityCard"
card.AnchorPoint = Vector2.new(0.5, 0)
card.Position = UDim2.new(0.5, 58, 0, 106)
card.Size = UDim2.fromOffset(292, 50)
card.BackgroundColor3 = Color3.fromRGB(18, 24, 36)
card.BackgroundTransparency = 0.46
card.BorderSizePixel = 0
card.Visible = false
card.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = card

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Transparency = 0.62
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Parent = card

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(12, 6)
title.Size = UDim2.new(1, -24, 0, 17)
title.Font = Enum.Font.GothamBold
title.TextSize = 11
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(238, 242, 248)
title.Parent = card

local detail = Instance.new("TextLabel")
detail.BackgroundTransparency = 1
detail.Position = UDim2.fromOffset(12, 24)
detail.Size = UDim2.new(1, -24, 0, 18)
detail.Font = Enum.Font.GothamMedium
detail.TextSize = 10
detail.TextXAlignment = Enum.TextXAlignment.Left
detail.TextColor3 = Color3.fromRGB(190, 205, 224)
detail.Parent = card

local hideToken = 0
local function scheduleHide(seconds)
    hideToken += 1
    local token = hideToken
    task.delay(seconds, function()
        if token == hideToken then card.Visible = false end
    end)
end

local function showActivity(data)
    local activityId = data.ActivityId
    title.Text = titles[activityId] or tostring(activityId or "ACTIVITY")
    if data.State == "STARTED" or data.State == "PROGRESS" or data.State == "TICK" then
        local label = activityId == "CITY_DELIVERY" and L.destination or L.checkpoint
        detail.Text = string.format("%s %d/%d  •  %ds", label, tonumber(data.Step) or 1, tonumber(data.Total) or 1, tonumber(data.Remaining) or 0)
        card.Visible = true
        hideToken += 1
    elseif data.State == "COMPLETE" then
        detail.Text = string.format("%s  •  +%d KOIN/COINS  +%d REP", L.complete, tonumber(data.RewardCoins) or 0, tonumber(data.RewardRep) or 0)
        card.Visible = true
        scheduleHide(3.5)
    elseif data.State == "FAILED" then
        detail.Text = L.failed
        card.Visible = true
        scheduleHide(3)
    elseif data.State == "BLOCKED" then
        local reason = data.Reason
        if reason == "BUSY" then detail.Text = L.busy
        elseif reason == "COOLDOWN" then detail.Text = L.cooldown .. " · " .. tostring(data.Remaining or 0) .. "s"
        else detail.Text = L.profile end
        card.Visible = true
        scheduleHide(3)
    end
end

activityState.OnClientEvent:Connect(showActivity)

ProximityPromptService.PromptShown:Connect(function(prompt)
    local activityId = prompt:GetAttribute("ASCActivityId")
    if not activityId then return end
    prompt.ActionText = L.start
    prompt.ObjectText = titles[activityId] or prompt.ObjectText
end)

print("[AFTER SCHOOL CITY] V1.1 activity HUD ready locale=" .. localeId)
