-- BBYA SOCIAL HUB — DONATION NOTIFICATION SFX v1.2 + QA SIMULATOR CLIENT
-- Audio runtime consumer with preload/readiness diagnostics plus TEST-only QA controls.
-- Production behavior: DonationNotification -> one global/non-positional Sound.
-- TEST instrumentation never opens purchase UI and never infers purchase success.

local ContentProvider = game:GetService("ContentProvider")
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

donationSound:SetAttribute("BBYAAudioAssetId", "138169036950863")
donationSound:SetAttribute("BBYAAudioLoaded", false)
donationSound:SetAttribute("BBYAAudioTimeLength", 0)
donationSound:SetAttribute("BBYAAudioLastPlayAttempt", 0)
donationSound:SetAttribute("BBYAAudioLastFailure", "")
donationSound:SetAttribute("BBYAAudioPreloadStatus", "Pending")
donationSound:SetAttribute("BBYAAudioPreloadFetchStatus", "Pending")

local pendingCount = 0
local playing = false
local loadReady = false
local destroyed = false
local preloadFinished = false
local playNext

local function recordFailure(message)
	if destroyed then
		return
	end
	local text = tostring(message or "Unknown audio failure")
	donationSound:SetAttribute("BBYAAudioLastFailure", text)
	warn("[BBYA Audio] Donation SFX: " .. text)
end

local function refreshLoadState()
	if destroyed then
		return false
	end

	local isLoaded = donationSound.IsLoaded
	local timeLength = donationSound.TimeLength
	donationSound:SetAttribute("BBYAAudioLoaded", isLoaded)
	donationSound:SetAttribute("BBYAAudioTimeLength", timeLength)

	if isLoaded and timeLength > 0 then
		loadReady = true
		donationSound:SetAttribute("BBYAAudioLastFailure", "")
	end

	return loadReady
end

playNext = function()
	if destroyed or playing or pendingCount <= 0 then
		return
	end

	if not refreshLoadState() then
		return
	end

	pendingCount -= 1
	playing = true
	donationSound:SetAttribute("BBYAAudioLastPlayAttempt", os.clock())
	donationSound.TimePosition = 0

	local ok, err = pcall(function()
		donationSound:Play()
	end)
	if not ok then
		pendingCount += 1
		playing = false
		recordFailure("Play() error: " .. tostring(err))
		return
	end

	task.delay(0.35, function()
		if destroyed or not playing then
			return
		end
		if not donationSound.Playing then
			pendingCount += 1
			playing = false
			recordFailure("Play() returned but Sound.Playing remained false")
		end
	end)
end

local loadedConnection = donationSound.Loaded:Connect(function()
	task.defer(function()
		if destroyed then
			return
		end
		if refreshLoadState() then
			donationSound:SetAttribute("BBYAAudioPreloadStatus", preloadFinished and "Success" or "Loaded")
			playNext()
		end
	end)
end)

local endedConnection = donationSound.Ended:Connect(function()
	playing = false
	refreshLoadState()
	playNext()
end)

local remoteConnection = monetizationRemote.OnClientEvent:Connect(function(action, _payload)
	if action ~= "DonationNotification" then
		return
	end

	pendingCount += 1
	playNext()
end)

-- Preload asynchronously so client startup and donation UI/backend never block.
task.spawn(function()
	local finalFetchStatus = "Unknown"
	local ok, err = pcall(function()
		ContentProvider:PreloadAsync({ donationSound }, function(_contentId, assetFetchStatus)
			finalFetchStatus = assetFetchStatus.Name
			if not destroyed then
				donationSound:SetAttribute("BBYAAudioPreloadFetchStatus", finalFetchStatus)
			end
		end)
	end)

	if destroyed then
		return
	end

	preloadFinished = true
	if not ok then
		donationSound:SetAttribute("BBYAAudioPreloadStatus", "Failed")
		recordFailure("PreloadAsync error: " .. tostring(err))
		return
	end

	if refreshLoadState() then
		donationSound:SetAttribute("BBYAAudioPreloadStatus", "Success")
		playNext()
	else
		donationSound:SetAttribute("BBYAAudioPreloadStatus", "FinishedNotLoaded")
		recordFailure("PreloadAsync resolved (" .. finalFetchStatus .. ") but Sound.IsLoaded=false or TimeLength=0")
	end
end)

-- Diagnostic timeout only; never blocks or mutates donation/backend/UI flow.
task.delay(10, function()
	if destroyed or refreshLoadState() then
		return
	end
	if preloadFinished then
		recordFailure("Audio still not loadable after preload; verify asset experience permission")
	else
		recordFailure("Audio preload still pending after 10s; verify asset availability/permission")
	end
end)

-- -----------------------------------------------------------------------------
-- QA DONATION SIMULATOR CONTROLS — TEST PLACE ONLY / ZERO ROBUX
-- This block is QA integration only and must never enter Production.
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
	if loadedConnection then loadedConnection:Disconnect() end
	if endedConnection then endedConnection:Disconnect() end
	if destroyingConnection then destroyingConnection:Disconnect() end
	if donationSound then donationSound:Destroy() end
end)

refreshLoadState()
print("[BBYA Audio] DonationNotification SFX v1.2 QA integration online; preload + early-event queue diagnostics; SoundId 138169036950863")
