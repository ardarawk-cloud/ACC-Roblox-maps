-- BBYA SOCIAL HUB — DONATION NOTIFICATION SFX v1.2 + QA SIMULATOR CLIENT
-- Audio-only runtime consumer plus TEST-place-only QA controls.
-- Production behavior: DonationNotification -> one global/non-positional Sound.
-- TEST instrumentation never opens purchase UI and never infers purchase success.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local TEST_UNIVERSE = 10762005984
local TEST_PLACE = 124607344716828

local remotes = ReplicatedStorage:WaitForChild("BBYAClubRemotes", 30)
if not remotes then
	warn("[BBYA Audio] BBYAClubRemotes unavailable; donation notification SFX disabled")
	return
end

local monetizationRemote = remotes:WaitForChild("Monetization", 30)
if not monetizationRemote or not monetizationRemote:IsA("RemoteEvent") then
	warn("[BBYA Audio] Monetization RemoteEvent unavailable; donation notification SFX disabled")
	return
end

local donationSound = Instance.new("Sound")
donationSound.Name = "BBYADonationNotificationSFX"
donationSound.SoundId = "rbxassetid://138169036950863"
donationSound.Volume = 0.58
donationSound.PlaybackSpeed = 0.5714285714
donationSound.Looped = false
donationSound.Parent = SoundService

local pendingCount = 0
local playing = false
local destroyed = false

local function playNext()
	if destroyed or playing or pendingCount <= 0 then
		return
	end

	pendingCount -= 1
	playing = true
	donationSound.TimePosition = 0
	donationSound:Play()
end

local endedConnection = donationSound.Ended:Connect(function()
	playing = false
	playNext()
end)

local remoteConnection = monetizationRemote.OnClientEvent:Connect(function(action, _payload)
	if action ~= "DonationNotification" then
		return
	end

	pendingCount += 1
	playNext()
end)

-- -----------------------------------------------------------------------------
-- QA DONATION SIMULATOR CONTROLS — TEST PLACE ONLY / ZERO ROBUX
-- Kept here only on the QA integration branch so the UI revision candidate can
-- remain byte-exact to 04's approved source. This block must never enter Production.
-- -----------------------------------------------------------------------------
if game.GameId == TEST_UNIVERSE and game.PlaceId == TEST_PLACE then
	task.spawn(function()
		local player = Players.LocalPlayer
		if not player then return end
		local playerGui = player:WaitForChild("PlayerGui")
		local qaRemote = ReplicatedStorage:WaitForChild("BBYAQADonationSimulatorV1", 30)
		if not qaRemote or not qaRemote:IsA("RemoteEvent") then
			warn("[BBYA QA] Donation simulator remote unavailable")
			return
		end

		local old = playerGui:FindFirstChild("BBYAQADonationSimulatorUI")
		if old then old:Destroy() end

		local function addCorner(parent, radius)
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, radius)
			c.Parent = parent
		end
		local function addStroke(parent, color, transparency)
			local s = Instance.new("UIStroke")
			s.Color = color
			s.Thickness = 1
			s.Transparency = transparency or 0
			s.Parent = parent
		end

		local gui = Instance.new("ScreenGui")
		gui.Name = "BBYAQADonationSimulatorUI"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = false
		gui.DisplayOrder = 940
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.Parent = playerGui
		pcall(function()
			gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
			gui.ClipToDeviceSafeArea = true
		end)

		local toggle = Instance.new("TextButton")
		toggle.Name = "Toggle"
		toggle.AnchorPoint = Vector2.new(0, 0.5)
		toggle.Position = UDim2.new(0, 10, 0.5, -5)
		toggle.Size = UDim2.fromOffset(104, 36)
		toggle.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
		toggle.TextColor3 = Color3.fromRGB(255, 214, 103)
		toggle.Text = "QA DONATE"
		toggle.Font = Enum.Font.GothamBold
		toggle.TextSize = 12
		toggle.AutoButtonColor = true
		toggle.Parent = gui
		addCorner(toggle, 10)
		addStroke(toggle, Color3.fromRGB(232, 184, 93), 0.28)

		local panel = Instance.new("Frame")
		panel.Name = "Panel"
		panel.Position = UDim2.new(0, 122, 0.5, -94)
		panel.Size = UDim2.fromOffset(216, 188)
		panel.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
		panel.BackgroundTransparency = 0.03
		panel.BorderSizePixel = 0
		panel.Visible = false
		panel.Parent = gui
		addCorner(panel, 12)
		addStroke(panel, Color3.fromRGB(232, 184, 93), 0.28)

		local title = Instance.new("TextLabel")
		title.BackgroundTransparency = 1
		title.Position = UDim2.fromOffset(12, 8)
		title.Size = UDim2.new(1, -24, 0, 22)
		title.Text = "QA DONATION SIM"
		title.TextColor3 = Color3.fromRGB(232, 184, 93)
		title.Font = Enum.Font.GothamBlack
		title.TextSize = 12
		title.TextXAlignment = Enum.TextXAlignment.Center
		title.Parent = panel

		local sub = Instance.new("TextLabel")
		sub.BackgroundTransparency = 1
		sub.Position = UDim2.fromOffset(12, 28)
		sub.Size = UDim2.new(1, -24, 0, 18)
		sub.Text = "TEST ONLY · 0 ROBUX"
		sub.TextColor3 = Color3.fromRGB(166, 169, 181)
		sub.Font = Enum.Font.GothamMedium
		sub.TextSize = 9
		sub.TextXAlignment = Enum.TextXAlignment.Center
		sub.Parent = panel

		local function qaButton(text, y, action)
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(1, -24, 0, 30)
			b.Position = UDim2.fromOffset(12, y)
			b.BackgroundColor3 = Color3.fromRGB(27, 29, 38)
			b.TextColor3 = Color3.fromRGB(247, 247, 250)
			b.Text = text
			b.Font = Enum.Font.GothamBold
			b.TextSize = 11
			b.AutoButtonColor = true
			b.Parent = panel
			addCorner(b, 8)
			addStroke(b, Color3.fromRGB(72, 75, 88), 0.48)
			b.Activated:Connect(function()
				qaRemote:FireServer(action)
			end)
		end

		qaButton("10R · NO MESSAGE", 52, "NO_MSG_10")
		qaButton("10R · WITH MESSAGE", 86, "WITH_MSG_10")
		qaButton("25R · NO MESSAGE", 120, "NO_MSG_25")
		qaButton("BURST · 10 / 25 / 50", 154, "BURST")

		toggle.Activated:Connect(function()
			panel.Visible = not panel.Visible
		end)

		print("[BBYA QA] Donation simulator controls online — TEST PLACE ONLY / ZERO ROBUX")
	end)
end

local destroyingConnection
destroyingConnection = script.Destroying:Connect(function()
	destroyed = true
	if remoteConnection then remoteConnection:Disconnect() end
	if endedConnection then endedConnection:Disconnect() end
	if destroyingConnection then destroyingConnection:Disconnect() end
	if donationSound then donationSound:Destroy() end
end)

print("[BBYA Audio] DonationNotification SFX v1.2 online; server event only; SoundId 138169036950863; PlaybackSpeed 0.5714285714")