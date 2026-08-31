-- AFTER SCHOOL CITY — Personal Music Player v0.9.0
-- Client-only audio: each player controls only their own music session.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local configModule = ReplicatedStorage:WaitForChild("ASCMusicConfig", 15)
if not configModule or not configModule:IsA("ModuleScript") then
    warn("[ASC Music] ASCMusicConfig missing")
    return
end

local ok, Config = pcall(require, configModule)
if not ok or type(Config) ~= "table" then
    warn("[ASC Music] invalid config")
    return
end

local tracks = {}
for _, entry in ipairs(type(Config.Tracks) == "table" and Config.Tracks or {}) do
    if type(entry) == "table" then
        local assetId = tonumber(entry.AssetId)
        if assetId and assetId > 0 then
            table.insert(tracks, {
                Title = tostring(entry.Title or ("Track " .. tostring(#tracks + 1))),
                Artist = tostring(entry.Artist or "Bintang"),
                AssetId = math.floor(assetId),
            })
        end
    end
end

local defaultVolume = math.clamp(tonumber(Config.DefaultVolume) or 0.45, 0, 1)
local playbackSpeed = tonumber(Config.PlaybackSpeed) or 1.0
-- Panel playback is intentionally normalized even if source preparation used another speed.
playbackSpeed = math.clamp(playbackSpeed, 0.5, 2.0)
if math.abs(playbackSpeed - 1.0) > 0.001 then
    warn("[ASC Music] config PlaybackSpeed overridden to normal 1.0")
    playbackSpeed = 1.0
end

local sound = Instance.new("Sound")
sound.Name = "ASC_PersonalMusicSound"
sound.Volume = defaultVolume
sound.PlaybackSpeed = 1.0
sound.Looped = false
sound.Parent = SoundService

local gui = Instance.new("ScreenGui")
gui.Name = "ASC_PersonalMusic"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 8
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local palette = {
    panel = Color3.fromRGB(24, 31, 43),
    panel2 = Color3.fromRGB(31, 41, 56),
    blue = Color3.fromRGB(64, 111, 162),
    gold = Color3.fromRGB(229, 177, 79),
    white = Color3.fromRGB(241, 244, 248),
    soft = Color3.fromRGB(174, 184, 198),
    muted = Color3.fromRGB(91, 102, 118),
    dark = Color3.fromRGB(15, 20, 28),
}

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function stroke(parent, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or palette.muted
    s.Transparency = transparency == nil and 0.35 or transparency
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function label(parent, name, text, size, position, textSize, color, alignment)
    local t = Instance.new("TextLabel")
    t.Name = name
    t.BackgroundTransparency = 1
    t.Size = size
    t.Position = position
    t.Font = Enum.Font.GothamMedium
    t.Text = text
    t.TextSize = textSize or 14
    t.TextColor3 = color or palette.white
    t.TextXAlignment = alignment or Enum.TextXAlignment.Left
    t.TextTruncate = Enum.TextTruncate.AtEnd
    t.Parent = parent
    return t
end

local function button(parent, name, text, size, position)
    local b = Instance.new("TextButton")
    b.Name = name
    b.AutoButtonColor = true
    b.BackgroundColor3 = palette.panel2
    b.Size = size
    b.Position = position
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.TextSize = 13
    b.TextColor3 = palette.white
    b.Parent = parent
    corner(b, 9)
    stroke(b, palette.muted, 0.55, 1)
    return b
end

local toggle = Instance.new("TextButton")
toggle.Name = "MusicToggle"
toggle.AnchorPoint = Vector2.new(1, 0.5)
toggle.Position = UDim2.new(1, -14, 0.5, 0)
toggle.Size = UDim2.fromOffset(48, 48)
toggle.BackgroundColor3 = palette.panel
toggle.Text = "MUSIC"
toggle.TextSize = 10
toggle.Font = Enum.Font.GothamBold
toggle.TextColor3 = palette.gold
toggle.Parent = gui
corner(toggle, 14)
stroke(toggle, palette.blue, 0.05, 1.5)

local panel = Instance.new("Frame")
panel.Name = "MusicPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.52)
panel.Size = UDim2.fromOffset(336, 206)
panel.BackgroundColor3 = palette.panel
panel.Visible = false
panel.Parent = gui
corner(panel, 14)
stroke(panel, palette.blue, 0.18, 1.5)

local scale = Instance.new("UIScale")
scale.Name = "ResponsiveScale"
scale.Scale = 1
scale.Parent = panel

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundColor3 = palette.panel2
header.Size = UDim2.new(1, 0, 0, 42)
header.Parent = panel
corner(header, 14)

local headerMask = Instance.new("Frame")
headerMask.Name = "HeaderBottomMask"
headerMask.BorderSizePixel = 0
headerMask.BackgroundColor3 = palette.panel2
headerMask.Position = UDim2.new(0, 0, 1, -14)
headerMask.Size = UDim2.new(1, 0, 0, 14)
headerMask.Parent = header

local titleHeader = label(header, "HeaderTitle", "AFTER SCHOOL CITY  ·  MUSIC", UDim2.new(1, -48, 1, 0), UDim2.fromOffset(14, 0), 12, palette.gold)
titleHeader.Font = Enum.Font.GothamBold

local closeButton = button(header, "Close", "X", UDim2.fromOffset(30, 28), UDim2.new(1, -36, 0, 7))
closeButton.TextSize = 12

local trackTitle = label(panel, "TrackTitle", "Playlist belum diisi", UDim2.new(1, -28, 0, 24), UDim2.fromOffset(14, 52), 16, palette.white)
trackTitle.Font = Enum.Font.GothamBold
local artistLabel = label(panel, "Artist", "Tambahkan audio milik/berizin ke ASCMusicConfig", UDim2.new(1, -28, 0, 20), UDim2.fromOffset(14, 76), 11, palette.soft)

local progressHit = Instance.new("Frame")
progressHit.Name = "ProgressHit"
progressHit.Active = true
progressHit.BackgroundTransparency = 1
progressHit.Position = UDim2.fromOffset(14, 101)
progressHit.Size = UDim2.new(1, -28, 0, 18)
progressHit.Parent = panel

local progressBg = Instance.new("Frame")
progressBg.Name = "ProgressBackground"
progressBg.AnchorPoint = Vector2.new(0, 0.5)
progressBg.Position = UDim2.fromScale(0, 0.5)
progressBg.Size = UDim2.new(1, 0, 0, 5)
progressBg.BorderSizePixel = 0
progressBg.BackgroundColor3 = palette.muted
progressBg.Parent = progressHit
corner(progressBg, 3)

local progressFill = Instance.new("Frame")
progressFill.Name = "ProgressFill"
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BorderSizePixel = 0
progressFill.BackgroundColor3 = palette.gold
progressFill.Parent = progressBg
corner(progressFill, 3)

local timeCurrent = label(panel, "CurrentTime", "0:00", UDim2.fromOffset(54, 18), UDim2.fromOffset(14, 116), 10, palette.soft)
local timeTotal = label(panel, "TotalTime", "0:00", UDim2.fromOffset(54, 18), UDim2.new(1, -68, 0, 116), 10, palette.soft, Enum.TextXAlignment.Right)

local prevButton = button(panel, "Previous", "PREV", UDim2.fromOffset(68, 36), UDim2.fromOffset(14, 139))
local playButton = button(panel, "PlayPause", "PLAY", UDim2.fromOffset(92, 36), UDim2.fromOffset(90, 139))
playButton.BackgroundColor3 = palette.blue
local nextButton = button(panel, "Next", "NEXT", UDim2.fromOffset(68, 36), UDim2.fromOffset(190, 139))
local volumeDown = button(panel, "VolumeDown", "-", UDim2.fromOffset(28, 36), UDim2.fromOffset(266, 139))
local volumeUp = button(panel, "VolumeUp", "+", UDim2.fromOffset(28, 36), UDim2.fromOffset(296, 139))

local volumeLabel = label(panel, "Volume", "VOL 45%", UDim2.fromOffset(88, 18), UDim2.fromOffset(246, 180), 10, palette.soft, Enum.TextXAlignment.Right)
local statusLabel = label(panel, "Status", "Player siap", UDim2.new(1, -112, 0, 18), UDim2.fromOffset(14, 180), 10, palette.soft)

local currentIndex = 1
local loadingToken = 0

local function formatTime(seconds)
    seconds = math.max(0, tonumber(seconds) or 0)
    local minutes = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%d:%02d", minutes, secs)
end

local function hasTracks()
    return #tracks > 0
end

local function updateVolumeText()
    volumeLabel.Text = string.format("VOL %d%%", math.floor(sound.Volume * 100 + 0.5))
end

local function setControlsEnabled(enabled)
    for _, b in ipairs({prevButton, playButton, nextButton}) do
        b.Active = enabled
        b.AutoButtonColor = enabled
        b.TextTransparency = enabled and 0 or 0.5
        b.BackgroundTransparency = enabled and 0 or 0.25
    end
end

local function updateTrackLabels()
    if not hasTracks() then
        trackTitle.Text = "Playlist belum diisi"
        artistLabel.Text = "Tambahkan audio milik/berizin ke ASCMusicConfig"
        statusLabel.Text = "Engine siap · menunggu audio ID"
        playButton.Text = "PLAY"
        setControlsEnabled(false)
        return
    end
    setControlsEnabled(true)
    local track = tracks[currentIndex]
    trackTitle.Text = track.Title
    artistLabel.Text = track.Artist .. "  ·  " .. tostring(currentIndex) .. "/" .. tostring(#tracks)
end

local function loadCurrent(autoPlay)
    if not hasTracks() then
        updateTrackLabels()
        return
    end

    loadingToken += 1
    local token = loadingToken
    sound:Stop()
    sound.TimePosition = 0
    sound.PlaybackSpeed = 1.0
    local track = tracks[currentIndex]
    sound.SoundId = "rbxassetid://" .. tostring(track.AssetId)
    updateTrackLabels()
    statusLabel.Text = "Memuat audio..."
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    timeCurrent.Text = "0:00"
    timeTotal.Text = "0:00"

    task.spawn(function()
        pcall(function()
            ContentProvider:PreloadAsync({sound})
        end)
        if token ~= loadingToken then
            return
        end
        if sound.IsLoaded or sound.TimeLength > 0 then
            timeTotal.Text = formatTime(sound.TimeLength)
            statusLabel.Text = "Siap"
            if autoPlay then
                sound:Play()
                playButton.Text = "PAUSE"
                statusLabel.Text = "Playing · personal"
            end
        else
            statusLabel.Text = "Audio belum tersedia/diizinkan"
            playButton.Text = "PLAY"
        end
    end)
end

local function changeTrack(delta, autoPlay)
    if not hasTracks() then return end
    currentIndex += delta
    if currentIndex < 1 then
        currentIndex = #tracks
    elseif currentIndex > #tracks then
        currentIndex = 1
    end
    loadCurrent(autoPlay)
end

local function togglePlayback()
    if not hasTracks() then return end
    if sound.IsPlaying then
        sound:Pause()
        playButton.Text = "PLAY"
        statusLabel.Text = "Paused"
    else
        if sound.SoundId == "" then
            loadCurrent(true)
        else
            sound:Resume()
            playButton.Text = "PAUSE"
            statusLabel.Text = "Playing · personal"
        end
    end
end

toggle.Activated:Connect(function()
    panel.Visible = not panel.Visible
end)
closeButton.Activated:Connect(function()
    panel.Visible = false
end)
playButton.Activated:Connect(togglePlayback)
prevButton.Activated:Connect(function()
    changeTrack(-1, sound.IsPlaying)
end)
nextButton.Activated:Connect(function()
    changeTrack(1, sound.IsPlaying)
end)

volumeDown.Activated:Connect(function()
    sound.Volume = math.clamp(sound.Volume - 0.1, 0, 1)
    updateVolumeText()
end)
volumeUp.Activated:Connect(function()
    sound.Volume = math.clamp(sound.Volume + 0.1, 0, 1)
    updateVolumeText()
end)

progressHit.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end
    if sound.TimeLength <= 0 then return end
    local x = math.clamp(input.Position.X - progressBg.AbsolutePosition.X, 0, progressBg.AbsoluteSize.X)
    local ratio = progressBg.AbsoluteSize.X > 0 and (x / progressBg.AbsoluteSize.X) or 0
    sound.TimePosition = ratio * sound.TimeLength
end)

sound.Ended:Connect(function()
    playButton.Text = "PLAY"
    if not hasTracks() then return end
    if currentIndex < #tracks then
        currentIndex += 1
        loadCurrent(true)
    elseif Config.LoopPlaylist ~= false then
        currentIndex = 1
        loadCurrent(true)
    else
        statusLabel.Text = "Playlist selesai"
    end
end)

RunService.RenderStepped:Connect(function()
    if sound.TimeLength > 0 then
        local ratio = math.clamp(sound.TimePosition / sound.TimeLength, 0, 1)
        progressFill.Size = UDim2.new(ratio, 0, 1, 0)
        timeCurrent.Text = formatTime(sound.TimePosition)
        timeTotal.Text = formatTime(sound.TimeLength)
    end
end)

local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local target = math.min(1, math.max(0.78, (viewport.X - 20) / 356))
    scale.Scale = target
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(updateScale)
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

updateVolumeText()
updateTrackLabels()
updateScale()

if hasTracks() then
    loadCurrent(Config.AutoPlay == true)
end

print(string.format("[AFTER SCHOOL CITY] Personal Music Player v0.9.0 ready; tracks=%d localOnly=true playbackSpeed=1.0", #tracks))
