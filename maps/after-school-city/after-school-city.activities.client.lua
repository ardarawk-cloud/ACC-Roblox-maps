-- AFTER SCHOOL CITY — V1.1.3 activity presentation
-- Keeps the compact V1.1 HUD and adds one local-only active checkpoint marker for Skate Line.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

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
        boardLost = "SKATEBOARD LOST",
        busy = "Finish your current activity first",
        cooldown = "Activity cooling down",
        profile = "Profile is still loading",
        board = "SKATEBOARD",
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
        boardLost = "SKATEBOARD LEPAS",
        busy = "Selesaikan aktivitas yang sedang berjalan",
        cooldown = "Aktivitas masih cooldown",
        profile = "Profil masih dimuat",
        board = "SKATEBOARD",
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

local markerModel
local markerRing
local markerBeam
local markerLabel
local pulseStarted = os.clock()

local function clearCheckpointMarker()
    if markerModel then
        markerModel:Destroy()
        markerModel = nil
        markerRing = nil
        markerBeam = nil
        markerLabel = nil
    end
end

local function ensureCheckpointMarker()
    if markerModel and markerModel.Parent then return end

    markerModel = Instance.new("Model")
    markerModel.Name = "ASC_ActiveSkateCheckpoint_Local"
    markerModel.Parent = Workspace

    markerRing = Instance.new("Part")
    markerRing.Name = "CheckpointRing"
    markerRing.Shape = Enum.PartType.Cylinder
    markerRing.Size = Vector3.new(0.28, 7, 7)
    markerRing.Anchored = true
    markerRing.CanCollide = false
    markerRing.CanTouch = false
    markerRing.CanQuery = false
    markerRing.Material = Enum.Material.Neon
    markerRing.Color = Color3.fromRGB(255, 196, 72)
    markerRing.Transparency = 0.18
    markerRing.Parent = markerModel

    markerBeam = Instance.new("Part")
    markerBeam.Name = "CheckpointBeam"
    markerBeam.Size = Vector3.new(0.24, 10, 0.24)
    markerBeam.Anchored = true
    markerBeam.CanCollide = false
    markerBeam.CanTouch = false
    markerBeam.CanQuery = false
    markerBeam.Material = Enum.Material.Neon
    markerBeam.Color = Color3.fromRGB(255, 214, 108)
    markerBeam.Transparency = 0.42
    markerBeam.Parent = markerModel

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CheckpointBillboard"
    billboard.Size = UDim2.fromOffset(170, 34)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = 220
    billboard.Parent = markerBeam

    markerLabel = Instance.new("TextLabel")
    markerLabel.BackgroundColor3 = Color3.fromRGB(18, 24, 36)
    markerLabel.BackgroundTransparency = 0.28
    markerLabel.BorderSizePixel = 0
    markerLabel.Size = UDim2.fromScale(1, 1)
    markerLabel.Font = Enum.Font.GothamBold
    markerLabel.TextSize = 12
    markerLabel.TextColor3 = Color3.fromRGB(255, 226, 145)
    markerLabel.Parent = billboard

    local labelCorner = Instance.new("UICorner")
    labelCorner.CornerRadius = UDim.new(0, 8)
    labelCorner.Parent = markerLabel
end

local function showCheckpointMarker(target, step, total)
    if typeof(target) ~= "Vector3" then
        clearCheckpointMarker()
        return
    end
    ensureCheckpointMarker()
    markerRing.CFrame = CFrame.new(target + Vector3.new(0, 0.35, 0)) * CFrame.Angles(0, 0, math.rad(90))
    markerBeam.CFrame = CFrame.new(target + Vector3.new(0, 5.2, 0))
    markerLabel.Text = string.format("▼ %s %d/%d", L.checkpoint, tonumber(step) or 1, tonumber(total) or 1)
end

RunService.RenderStepped:Connect(function()
    if markerRing and markerBeam then
        local wave = (math.sin((os.clock() - pulseStarted) * 4) + 1) * 0.5
        markerRing.Transparency = 0.12 + wave * 0.24
        markerBeam.Transparency = 0.36 + wave * 0.22
    end
end)

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
        if activityId == "SKATE_LINE" then
            detail.Text = string.format("%s • %s %d/%d  •  %ds", L.board, label, tonumber(data.Step) or 1, tonumber(data.Total) or 1, tonumber(data.Remaining) or 0)
            showCheckpointMarker(data.Target, data.Step, data.Total)
        else
            detail.Text = string.format("%s %d/%d  •  %ds", label, tonumber(data.Step) or 1, tonumber(data.Total) or 1, tonumber(data.Remaining) or 0)
            clearCheckpointMarker()
        end
        card.Visible = true
        hideToken += 1
    elseif data.State == "COMPLETE" then
        clearCheckpointMarker()
        detail.Text = string.format("%s  •  +%d KOIN/COINS  +%d REP", L.complete, tonumber(data.RewardCoins) or 0, tonumber(data.RewardRep) or 0)
        card.Visible = true
        scheduleHide(3.5)
    elseif data.State == "FAILED" then
        clearCheckpointMarker()
        detail.Text = data.Reason == "SKATEBOARD_LOST" and L.boardLost or L.failed
        card.Visible = true
        scheduleHide(3)
    elseif data.State == "BLOCKED" then
        clearCheckpointMarker()
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

player.CharacterAdded:Connect(function()
    clearCheckpointMarker()
end)

print("[AFTER SCHOOL CITY] V1.1.3 activity HUD ready locale=" .. localeId)
