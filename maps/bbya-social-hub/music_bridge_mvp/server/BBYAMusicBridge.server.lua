-- BBYA Music Bridge MVP
-- Integration target: ServerScriptService/BBYAMusicBridge
-- Requires ReplicatedStorage/BBYAMusicConfig.
--
-- Security rule: this server only READS public/sanitized music state.
-- Never place the APK/admin write token in Roblox.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage:WaitForChild("BBYAMusicConfig"))

local remote = ReplicatedStorage:FindFirstChild(Config.RemoteName)
if not remote then
	remote = Instance.new("RemoteEvent")
	remote.Name = Config.RemoteName
	remote.Parent = ReplicatedStorage
end

local sound = SoundService:FindFirstChild(Config.SoundName)
if not sound then
	sound = Instance.new("Sound")
	sound.Name = Config.SoundName
	sound.Looped = false
	sound.Volume = Config.Volume
	sound.Parent = SoundService
end

local lastState = nil
local lastSignature = nil
local currentTrackKey = nil

local function debugLog(...)
	if Config.Debug then
		print("[BBYAMusicBridge]", ...)
	end
end

local function boundedString(value, maxLength)
	if value == nil then
		return ""
	end

	local text = tostring(value)
	if #text > maxLength then
		text = string.sub(text, 1, maxLength)
	end
	return text
end

local function normalizeAssetId(value)
	if value == nil then
		return nil
	end

	local text = tostring(value)
	local digits = string.match(text, "^%d+$")
	if not digits then
		return nil
	end
	return digits
end

local function normalizeCover(value)
	local cover = boundedString(value, Config.MaxCoverLength)
	if cover == "" then
		return ""
	end

	local digits = string.match(cover, "^rbxassetid://(%d+)$") or string.match(cover, "^(%d+)$")
	if not digits then
		return ""
	end
	return "rbxassetid://" .. digits
end

local function sanitizeState(data)
	if type(data) ~= "table" then
		return nil, "payload is not a table"
	end

	local state = {
		revision = tonumber(data.revision) or 0,
		isPlaying = data.isPlaying == true,
		currentTrack = nil,
	}

	if data.currentTrack == nil then
		return state
	end

	if type(data.currentTrack) ~= "table" then
		return nil, "currentTrack is not a table"
	end

	local assetId = normalizeAssetId(data.currentTrack.robloxAssetId)
	if not assetId then
		return nil, "currentTrack.robloxAssetId must contain digits only"
	end

	state.currentTrack = {
		id = boundedString(data.currentTrack.id, Config.MaxTrackIdLength),
		title = boundedString(data.currentTrack.title, Config.MaxTitleLength),
		artist = boundedString(data.currentTrack.artist, Config.MaxArtistLength),
		robloxAssetId = assetId,
		coverImage = normalizeCover(data.currentTrack.coverImage),
	}

	return state
end

local function fetchState()
	local ok, response = pcall(function()
		return HttpService:RequestAsync({
			Url = Config.Endpoint,
			Method = "GET",
			Headers = {
				["Accept"] = "application/json",
			},
		})
	end)

	if not ok then
		warn("[BBYAMusicBridge] request failed:", response)
		return nil
	end

	if not response.Success then
		warn("[BBYAMusicBridge] backend returned HTTP", response.StatusCode, response.StatusMessage)
		return nil
	end

	local decodedOk, decoded = pcall(function()
		return HttpService:JSONDecode(response.Body)
	end)

	if not decodedOk then
		warn("[BBYAMusicBridge] invalid JSON payload")
		return nil
	end

	local state, err = sanitizeState(decoded)
	if not state then
		warn("[BBYAMusicBridge] rejected payload:", err)
		return nil
	end

	return state
end

local function applyAudioState(state)
	local track = state.currentTrack
	if not track then
		if sound.IsPlaying then
			sound:Stop()
		end
		currentTrackKey = nil
		return
	end

	local trackKey = track.id .. ":" .. track.robloxAssetId
	local isNewTrack = trackKey ~= currentTrackKey

	if isNewTrack then
		sound:Stop()
		sound.SoundId = "rbxassetid://" .. track.robloxAssetId
		sound.TimePosition = 0
		currentTrackKey = trackKey

		if state.isPlaying then
			sound:Play()
		end
		return
	end

	if state.isPlaying then
		if not sound.IsPlaying then
			if sound.IsPaused then
				sound:Resume()
			else
				sound:Play()
			end
		end
	elseif sound.IsPlaying then
		sound:Pause()
	end
end

local function publishState(state)
	local signature = HttpService:JSONEncode(state)
	if signature == lastSignature then
		return
	end

	lastState = state
	lastSignature = signature
	applyAudioState(state)
	remote:FireAllClients(state)

	if state.currentTrack then
		debugLog("state", state.revision, state.currentTrack.title, state.isPlaying and "PLAYING" or "PAUSED")
	else
		debugLog("state", state.revision, "NO TRACK")
	end
end

Players.PlayerAdded:Connect(function(player)
	if lastState then
		remote:FireClient(player, lastState)
	end
end)

task.spawn(function()
	local pollSeconds = math.max(5, tonumber(Config.PollSeconds) or 10)
	while true do
		local state = fetchState()
		if state then
			publishState(state)
		end
		task.wait(pollSeconds)
	end
end)
