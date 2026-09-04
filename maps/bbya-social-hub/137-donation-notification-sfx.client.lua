-- BBYA SOCIAL HUB — DONATION NOTIFICATION SFX v1
-- Audio-only client consumer for the server-authoritative DonationNotification contract.
-- No purchase inference, no UI authority, no venue music routing.

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
donationSound.SoundId = "rbxassetid://9126072044"
donationSound.Volume = 0.58
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

local destroyingConnection
destroyingConnection = script.Destroying:Connect(function()
	destroyed = true

	if remoteConnection then
		remoteConnection:Disconnect()
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

print("[BBYA Audio] DonationNotification SFX v1 online; server event only; SoundId 9126072044")
