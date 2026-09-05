-- Hangar Exclusive Club — client UI v1.0

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local events = ReplicatedStorage:WaitForChild("ClubEvents")
local DJCommand = events:WaitForChild("DJCommand")
local GlobalNotification = events:WaitForChild("GlobalNotification")
local SongRequest = events:WaitForChild("SongRequest")
local DJRequest = events:WaitForChild("DJRequest")
local ClubState = events:WaitForChild("ClubState")
local music = Workspace:WaitForChild("AudioSystem"):WaitForChild("MainSpeakers"):WaitForChild("DJMusic")

local PLAYLIST = {
    { id = "1848354536", title = "Neon Nights", artist = "DJ Hangar" },
    { id = "1837879082", title = "Flight Path", artist = "Aero Beats" },
}

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
end

local function text(parent, name, value, size, pos, fontSize, align)
    local t = Instance.new("TextLabel")
    t.Name = name
    t.BackgroundTransparency = 1
    t.Text = value
    t.TextColor3 = Color3.fromRGB(238, 241, 245)
    t.TextSize = fontSize or 15
    t.Font = Enum.Font.Gotham
    t.TextXAlignment = align or Enum.TextXAlignment.Left
    t.Size = size
    t.Position = pos
    t.Parent = parent
    return t
end

local function button(parent, name, value, size, pos)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Text = value
    b.TextColor3 = Color3.fromRGB(242, 245, 248)
    b.TextSize = 14
    b.Font = Enum.Font.GothamSemibold
    b.BackgroundColor3 = Color3.fromRGB(31, 34, 40)
    b.AutoButtonColor = true
    b.Size = size
    b.Position = pos
    b.Parent = parent
    corner(b, 8)
    return b
end

local gui = Instance.new("ScreenGui")
gui.Name = "MusicPlayerGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 20
gui.Parent = playerGui

local toggle = button(gui, "MusicToggleButton", "MUSIC", UDim2.fromOffset(88, 38), UDim2.fromOffset(16, 16))
toggle.BackgroundColor3 = Color3.fromRGB(16, 18, 22)

local panel = Instance.new("Frame")
panel.Name = "MainFrame"
panel.Size = UDim2.fromOffset(340, 430)
panel.Position = UDim2.fromOffset(16, -470)
panel.BackgroundColor3 = Color3.fromRGB(15, 17, 21)
panel.BorderSizePixel = 0
panel.Parent = gui
corner(panel, 14)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(52, 58, 68)
stroke.Transparency = 0.25
stroke.Parent = panel

text(panel, "Header", "HANGAR / NOW PLAYING", UDim2.new(1, -28, 0, 26), UDim2.fromOffset(14, 12), 13).Font = Enum.Font.GothamBold
local title = text(panel, "SongTitle", "Loading...", UDim2.new(1, -28, 0, 28), UDim2.fromOffset(14, 50), 21)
title.Font = Enum.Font.GothamBold
local artist = text(panel, "ArtistName", "Hangar Exclusive Club", UDim2.new(1, -28, 0, 22), UDim2.fromOffset(14, 80), 13)
artist.TextColor3 = Color3.fromRGB(153, 160, 170)

local progressBack = Instance.new("Frame")
progressBack.Name = "ProgressBar"
progressBack.Size = UDim2.new(1, -28, 0, 5)
progressBack.Position = UDim2.fromOffset(14, 116)
progressBack.BackgroundColor3 = Color3.fromRGB(50, 54, 61)
progressBack.BorderSizePixel = 0
progressBack.Parent = panel
corner(progressBack, 4)
local progress = Instance.new("Frame")
progress.Name = "Fill"
progress.Size = UDim2.new(0, 0, 1, 0)
progress.BackgroundColor3 = Color3.fromRGB(0, 225, 255)
progress.BorderSizePixel = 0
progress.Parent = progressBack
corner(progress, 4)

local currentTime = text(panel, "CurrentTime", "0:00", UDim2.fromOffset(60, 18), UDim2.fromOffset(14, 126), 11)
local totalTime = text(panel, "TotalTime", "0:00", UDim2.fromOffset(60, 18), UDim2.new(1, -74, 0, 126), 11, Enum.TextXAlignment.Right)
local mute = button(panel, "LocalMute", "MUTE", UDim2.fromOffset(76, 30), UDim2.new(1, -90, 0, 151))

text(panel, "PlaylistHeader", "PLAYLIST", UDim2.new(1, -28, 0, 20), UDim2.fromOffset(14, 158), 12).Font = Enum.Font.GothamBold
local list = Instance.new("Frame")
list.Name = "PlaylistFrame"
list.Size = UDim2.new(1, -28, 0, 100)
list.Position = UDim2.fromOffset(14, 184)
list.BackgroundTransparency = 1
list.Parent = panel
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = list
for _, song in ipairs(PLAYLIST) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(23, 26, 31)
    row.BorderSizePixel = 0
    row.Parent = list
    corner(row, 8)
    text(row, "SongTitleText", song.title, UDim2.new(1, -88, 0, 20), UDim2.fromOffset(10, 4), 13).Font = Enum.Font.GothamSemibold
    local ar = text(row, "ArtistText", song.artist, UDim2.new(1, -88, 0, 16), UDim2.fromOffset(10, 24), 11)
    ar.TextColor3 = Color3.fromRGB(145, 151, 160)
    local request = button(row, "RequestButton", "REQ", UDim2.fromOffset(60, 28), UDim2.new(1, -70, 0, 8))
    request.MouseButton1Click:Connect(function() SongRequest:FireServer(song.id) end)
end

text(panel, "RequestHeader", "REQUEST ASSET ID", UDim2.new(1, -28, 0, 20), UDim2.fromOffset(14, 300), 11).Font = Enum.Font.GothamBold
local input = Instance.new("TextBox")
input.Name = "RequestInput"
input.PlaceholderText = "Roblox audio asset ID"
input.Text = ""
input.ClearTextOnFocus = false
input.TextColor3 = Color3.fromRGB(236, 240, 244)
input.PlaceholderColor3 = Color3.fromRGB(108, 115, 126)
input.BackgroundColor3 = Color3.fromRGB(24, 27, 32)
input.Font = Enum.Font.Gotham
input.TextSize = 13
input.Size = UDim2.new(1, -114, 0, 36)
input.Position = UDim2.fromOffset(14, 326)
input.Parent = panel
corner(input, 8)
local send = button(panel, "SubmitRequestBtn", "SEND", UDim2.fromOffset(78, 36), UDim2.new(1, -92, 0, 326))
send.MouseButton1Click:Connect(function()
    local id = input.Text:match("^(%d+)$")
    if id then SongRequest:FireServer(id); input.Text = "" end
end)

local supportInfo = text(panel, "SupportInfo", "Support products: waiting for Developer Product IDs", UDim2.new(1, -28, 0, 42), UDim2.fromOffset(14, 374), 11)
supportInfo.TextWrapped = true
supportInfo.TextColor3 = Color3.fromRGB(142, 148, 158)

local open = false
toggle.MouseButton1Click:Connect(function()
    open = not open
    TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = open and UDim2.fromOffset(16, 64) or UDim2.fromOffset(16, -470)
    }):Play()
end)

local locallyMuted = false
local baseVolume = music.Volume
mute.MouseButton1Click:Connect(function()
    locallyMuted = not locallyMuted
    if locallyMuted then baseVolume = music.Volume; music.Volume = 0 else music.Volume = math.max(baseVolume, 0.01) end
    mute.Text = locallyMuted and "UNMUTE" or "MUTE"
end)

local function fmt(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end
RunService.RenderStepped:Connect(function()
    local length = music.TimeLength
    currentTime.Text = fmt(music.TimePosition)
    totalTime.Text = fmt(length)
    if length > 0 then progress.Size = UDim2.new(math.clamp(music.TimePosition / length, 0, 1), 0, 1, 0) else progress.Size = UDim2.new(0, 0, 1, 0) end
end)

ClubState.OnClientEvent:Connect(function(state)
    if type(state) ~= "table" then return end
    title.Text = tostring(state.title or "DJ Selection")
    artist.Text = tostring(state.artist or "Hangar Exclusive Club")
end)

-- DJ panel ---------------------------------------------------------------------
local djGui = Instance.new("ScreenGui")
djGui.Name = "DJPanelGui"
djGui.ResetOnSpawn = false
djGui.DisplayOrder = 30
djGui.Parent = playerGui
local djPanel = Instance.new("Frame")
djPanel.Size = UDim2.fromOffset(290, 210)
djPanel.Position = UDim2.new(1, -306, 0, 16)
djPanel.BackgroundColor3 = Color3.fromRGB(14, 16, 20)
djPanel.BorderSizePixel = 0
djPanel.Visible = player:GetAttribute("HangarDJ") == true
djPanel.Parent = djGui
corner(djPanel, 12)
text(djPanel, "Title", "DJ CONTROL", UDim2.new(1, -24, 0, 26), UDim2.fromOffset(12, 10), 14).Font = Enum.Font.GothamBold
local djInput = Instance.new("TextBox")
djInput.PlaceholderText = "Audio asset ID"
djInput.Text = ""
djInput.ClearTextOnFocus = false
djInput.TextColor3 = Color3.new(1,1,1)
djInput.BackgroundColor3 = Color3.fromRGB(25, 28, 34)
djInput.Size = UDim2.new(1, -24, 0, 34)
djInput.Position = UDim2.fromOffset(12, 44)
djInput.Font = Enum.Font.Gotham
djInput.TextSize = 13
djInput.Parent = djPanel
corner(djInput, 8)
local play = button(djPanel, "Play", "PLAY ID", UDim2.fromOffset(82, 32), UDim2.fromOffset(12, 88))
local stop = button(djPanel, "Stop", "STOP", UDim2.fromOffset(70, 32), UDim2.fromOffset(102, 88))
local resume = button(djPanel, "Resume", "AUTO", UDim2.fromOffset(70, 32), UDim2.fromOffset(180, 88))
play.MouseButton1Click:Connect(function() local id = djInput.Text:match("^(%d+)$"); if id then DJCommand:FireServer("PlaySong", id) end end)
stop.MouseButton1Click:Connect(function() DJCommand:FireServer("StopMusic") end)
resume.MouseButton1Click:Connect(function() DJCommand:FireServer("ResumePlaylist") end)
local colors = {
    Color3.fromRGB(138,43,226), Color3.fromRGB(0,255,255), Color3.fromRGB(57,255,20), Color3.fromRGB(255,20,147)
}
for i, c in ipairs(colors) do
    local swatch = button(djPanel, "Color"..i, "", UDim2.fromOffset(54, 30), UDim2.fromOffset(12 + (i-1)*64, 132))
    swatch.BackgroundColor3 = c
    swatch.MouseButton1Click:Connect(function() DJCommand:FireServer("ChangeLightColor", c) end)
end
local reqLabel = text(djPanel, "Request", "Requests appear here", UDim2.new(1,-24,0,28), UDim2.fromOffset(12, 172), 11)
reqLabel.TextColor3 = Color3.fromRGB(160,166,176)
DJRequest.OnClientEvent:Connect(function(displayName, id) reqLabel.Text = tostring(displayName) .. " requested " .. tostring(id) end)
player:GetAttributeChangedSignal("HangarDJ"):Connect(function() djPanel.Visible = player:GetAttribute("HangarDJ") == true end)

-- Donation interaction UI ------------------------------------------------------
local interaction = Instance.new("ScreenGui")
interaction.Name = "InteractionGui"
interaction.ResetOnSpawn = false
interaction.DisplayOrder = 40
interaction.Parent = playerGui
local notif = Instance.new("Frame")
notif.Name = "NotificationFrame"
notif.Size = UDim2.fromOffset(360, 110)
notif.Position = UDim2.new(0.5, -180, 0, -130)
notif.BackgroundColor3 = Color3.fromRGB(16, 18, 22)
notif.BorderSizePixel = 0
notif.Parent = interaction
corner(notif, 14)
local avatar = Instance.new("ImageLabel")
avatar.Name = "AvatarImage"
avatar.Size = UDim2.fromOffset(72,72)
avatar.Position = UDim2.fromOffset(16,19)
avatar.BackgroundColor3 = Color3.fromRGB(29,32,38)
avatar.BorderSizePixel = 0
avatar.Parent = notif
corner(avatar, 36)
local donor = text(notif, "DonatorNameLabel", "SUPPORTER", UDim2.new(1,-112,0,22), UDim2.fromOffset(100,14), 15)
donor.Font = Enum.Font.GothamBold
local message = text(notif, "MessageLabel", "", UDim2.new(1,-112,0,38), UDim2.fromOffset(100,38), 12)
message.TextWrapped = true
local total = text(notif, "TotalDonatedLabel", "", UDim2.new(1,-112,0,20), UDim2.fromOffset(100,80), 11)
total.TextColor3 = Color3.fromRGB(0,225,255)

local function cashSound()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://7112275565"
    s.Volume = 1
    s.Parent = SoundService
    s:Play()
    s.Ended:Connect(function() s:Destroy() end)
end
local function fireworks(character)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local att = Instance.new("Attachment")
    att.Parent = root
    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxassetid://1084991217"
    emitter.Color = ColorSequence.new(Color3.fromRGB(255,215,0), Color3.fromRGB(0,255,255))
    emitter.Lifetime = NumberRange.new(1,2)
    emitter.Speed = NumberRange.new(15,25)
    emitter.Rate = 0
    emitter.SpreadAngle = Vector2.new(180,180)
    emitter.Parent = att
    emitter:Emit(70)
    task.delay(2.5, function() att:Destroy() end)
end
GlobalNotification.OnClientEvent:Connect(function(name, msg, robux, totalRobux, avatarUrl, character)
    cashSound(); fireworks(character)
    donor.Text = tostring(name)
    message.Text = '"' .. tostring(msg) .. '"'
    total.Text = "Total Kontribusi: R$ " .. tostring(totalRobux)
    if avatarUrl and avatarUrl ~= "" then avatar.Image = avatarUrl end
    TweenService:Create(notif, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5,-180,0,32)}):Play()
    task.delay(5, function()
        TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0.5,-180,0,-130)}):Play()
    end)
end)

print("[HangarExclusiveClub] v1 client ready")
