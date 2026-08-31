-- BBYA Music UI MVP
-- Integration target: StarterPlayerScripts/BBYAMusicUI
-- Receives sanitized state from ReplicatedStorage/BBYAMusicState.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("BBYAMusicState")

local existing = playerGui:FindFirstChild("BBYAMusicUI")
if existing then
	existing:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "BBYAMusicUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 30
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "NowPlayingPanel"
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UDim2.new(0.5, 0, 1, -24)
panel.Size = UDim2.fromOffset(520, 88)
panel.BackgroundColor3 = Color3.fromRGB(12, 14, 19)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(78, 86, 105)
stroke.Transparency = 0.35
stroke.Thickness = 1
stroke.Parent = panel

local cover = Instance.new("ImageLabel")
cover.Name = "Cover"
cover.Position = UDim2.fromOffset(12, 12)
cover.Size = UDim2.fromOffset(64, 64)
cover.BackgroundColor3 = Color3.fromRGB(26, 29, 37)
cover.BorderSizePixel = 0
cover.ScaleType = Enum.ScaleType.Crop
cover.Parent = panel

local coverCorner = Instance.new("UICorner")
coverCorner.CornerRadius = UDim.new(0, 10)
coverCorner.Parent = cover

local eyebrow = Instance.new("TextLabel")
eyebrow.Name = "Eyebrow"
eyebrow.Position = UDim2.fromOffset(92, 11)
eyebrow.Size = UDim2.new(1, -190, 0, 17)
eyebrow.BackgroundTransparency = 1
eyebrow.Font = Enum.Font.GothamMedium
eyebrow.Text = "BBYA  •  NOW PLAYING"
eyebrow.TextColor3 = Color3.fromRGB(166, 174, 194)
eyebrow.TextSize = 11
eyebrow.TextXAlignment = Enum.TextXAlignment.Left
eyebrow.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.fromOffset(92, 30)
title.Size = UDim2.new(1, -190, 0, 26)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Waiting for playlist…"
title.TextColor3 = Color3.fromRGB(245, 247, 252)
title.TextSize = 18
title.TextTruncate = Enum.TextTruncate.AtEnd
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local artist = Instance.new("TextLabel")
artist.Name = "Artist"
artist.Position = UDim2.fromOffset(92, 57)
artist.Size = UDim2.new(1, -190, 0, 18)
artist.BackgroundTransparency = 1
artist.Font = Enum.Font.Gotham
artist.Text = "Music bridge MVP"
artist.TextColor3 = Color3.fromRGB(166, 174, 194)
artist.TextSize = 12
artist.TextTruncate = Enum.TextTruncate.AtEnd
artist.TextXAlignment = Enum.TextXAlignment.Left
artist.Parent = panel

local status = Instance.new("TextLabel")
status.Name = "Status"
status.AnchorPoint = Vector2.new(1, 0.5)
status.Position = UDim2.new(1, -14, 0.5, 0)
status.Size = UDim2.fromOffset(84, 28)
status.BackgroundColor3 = Color3.fromRGB(28, 33, 43)
status.BorderSizePixel = 0
status.Font = Enum.Font.GothamBold
status.Text = "OFFLINE"
status.TextColor3 = Color3.fromRGB(185, 191, 206)
status.TextSize = 11
status.Parent = panel

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(1, 0)
statusCorner.Parent = status

local function setState(state)
	if type(state) ~= "table" then
		return
	end

	local track = state.currentTrack
	if type(track) ~= "table" then
		title.Text = "No track selected"
		artist.Text = "Choose a track from the BBYA Music controller"
		cover.Image = ""
		status.Text = "IDLE"
		return
	end

	title.Text = track.title ~= "" and track.title or "Untitled track"
	artist.Text = track.artist ~= "" and track.artist or "Unknown artist"
	cover.Image = track.coverImage or ""
	status.Text = state.isPlaying and "PLAYING" or "PAUSED"
end

remote.OnClientEvent:Connect(setState)
