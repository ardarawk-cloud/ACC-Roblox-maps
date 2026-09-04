-- BBYA SOCIAL HUB — DONATION NOTIFICATION SFX v1.2
-- Audio-only client consumer for the server-authoritative DonationNotification contract.
-- No purchase inference, no UI authority, no venue music routing.

local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

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
donationSound.SoundId = "rbxassetid://131641367206235"
donationSound.Volume = 0.58
donationSound.PlaybackSpeed = 0.5714285714
donationSound.Looped = false
donationSound.Parent = SoundService

donationSound:SetAttribute("BBYAAudioAssetId", "131641367206235")
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
		-- Restore this event to the FIFO. Do not auto-loop retries.
		pendingCount += 1
		playing = false
		recordFailure("Play() error: " .. tostring(err))
		return
	end

	-- Prevent a failed Play() from permanently stalling the FIFO.
	task.delay(0.35, function()
		if destroyed or not playing then
			return
		end
		if not donationSound.Playing then
			-- Restore this event to the FIFO. A later load/event may retry it.
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

local destroyingConnection
destroyingConnection = script.Destroying:Connect(function()
	destroyed = true

	if remoteConnection then
		remoteConnection:Disconnect()
	end
	if loadedConnection then
		loadedConnection:Disconnect()
	end
	if endedConnection then
		endedConnection:Disconnect()
	end
	if destroyingConnection then
		destroyingConnection:Disconnect()
	end
	if donationSound then
		donationSound:Destroy()
	end
end)

refreshLoadState()
print("[BBYA Audio] DonationNotification SFX v1.2 online; preload + early-event queue diagnostics; SoundId 131641367206235")
