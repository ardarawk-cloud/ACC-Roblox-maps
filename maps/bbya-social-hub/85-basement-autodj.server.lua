-- BBYA MUSIC UI TEST — 1.75x NORMALIZATION CONTROL v1
-- TEST ONLY. One approved control asset. No production catalog / no old BBYA tracks.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")

local TEST_UNIVERSE_ID = 10762005984
local ASSET_ID = "132374505628905"
local SPEED_FACTOR = 1.75
local PLAYBACK_SPEED = 0.5714285714

if game.GameId ~= TEST_UNIVERSE_ID then
	warn(string.format("[BBYA/Music175Test] TEST-ONLY guard blocked universe %s", tostring(game.GameId)))
	return
end

local TRACK = {
	trackId = "bbya-normalization-control-175",
	title = "BBYA 1.75x Normalization Control",
	artist = "AM STUDIO",
	id = ASSET_ID,
	assetId = ASSET_ID,
	style = "test",
	order = 1,
	enabled = true,
	speedFactor = SPEED_FACTOR,
	playbackSpeed = PLAYBACK_SPEED,
}
local PLAYLIST = { TRACK }

local folder = ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
folder.Name = "BBYAClubRemotes"
folder.Parent = ReplicatedStorage

local stateRemote = folder:FindFirstChild("State") or Instance.new("RemoteEvent")
stateRemote.Name = "State"
stateRemote.Parent = folder

local basementMusic = folder:FindFirstChild("BasementMusic") or Instance.new("BindableEvent")
basementMusic.Name = "BasementMusic"
basementMusic.Parent = folder

for _, name in ipairs({"BBYABasementDeckA", "BBYABasementDeckB", "BBYAMusic175Control"}) do
	local old = SoundService:FindFirstChild(name)
	if old then old:Destroy() end
end
local oldGroup = SoundService:FindFirstChild("BBYABasementMaster")
if oldGroup then oldGroup:Destroy() end

local group = Instance.new("SoundGroup")
group.Name = "BBYABasementMaster"
group.Volume = 1
group.Parent = SoundService
group:SetAttribute("BBYAAudioMode", "BBYA_MUSIC_175_NORMALIZATION_TEST")
group:SetAttribute("CatalogSource", "CONTROL_175_ONLY")
group:SetAttribute("PlaylistCount", 1)
group:SetAttribute("TestUniverseId", TEST_UNIVERSE_ID)
group:SetAttribute("TestAssetId", ASSET_ID)
group:SetAttribute("TestSpeedFactor", SPEED_FACTOR)
group:SetAttribute("TestPlaybackSpeed", PLAYBACK_SPEED)
group:SetAttribute("TestLoaded", false)
group:SetAttribute("TestPlaying", false)
group:SetAttribute("TestTimeLength", 0)

local sound = Instance.new("Sound")
sound.Name = "BBYAMusic175Control"
sound.SoundId = "rbxassetid://" .. ASSET_ID
sound.Volume = 1
sound.Looped = true
sound.PlaybackSpeed = PLAYBACK_SPEED
sound.SoundGroup = group
sound.Parent = SoundService
sound:SetAttribute("TrackId", TRACK.trackId)
sound:SetAttribute("AssetId", ASSET_ID)
sound:SetAttribute("SpeedFactor", SPEED_FACTOR)
sound:SetAttribute("PlaybackSpeedApplied", PLAYBACK_SPEED)

local paused = false

local function stateData()
	return {
		index = 1,
		title = TRACK.title,
		artist = TRACK.artist,
		style = TRACK.style,
		playing = sound.IsPlaying and not paused,
		queue = 0,
		audioMode = "BBYA_MUSIC_175_NORMALIZATION_TEST",
		venue = "TEST",
		genre = "CONTROL",
		library = 1,
		liveDeck = "CONTROL",
		standbyDeck = "",
		standbyIndex = 0,
		standbyTitle = "",
		mixSeconds = 0,
		catalogSource = "CONTROL_175_ONLY",
		catalogRevision = 175,
		assetId = ASSET_ID,
		speedFactor = SPEED_FACTOR,
		playbackSpeed = PLAYBACK_SPEED,
		timeLength = sound.TimeLength,
	}
end

local function fireState(target)
	if target then
		stateRemote:FireClient(target, "music", stateData())
	else
		for _, player in ipairs(Players:GetPlayers()) do
			stateRemote:FireClient(player, "music", stateData())
		end
	end
end

local function playControl()
	sound.PlaybackSpeed = PLAYBACK_SPEED
	paused = false
	if not sound.IsPlaying then sound:Play() end
	group:SetAttribute("TestPlaying", sound.IsPlaying)
	group:SetAttribute("TestPlaybackSpeed", sound.PlaybackSpeed)
	fireState()
end

basementMusic.Event:Connect(function(action, player)
	if action == "list" and player then
		stateRemote:FireClient(player, "playlist", PLAYLIST)
		fireState(player)
	elseif action == "play" then
		playControl()
	elseif action == "pause" then
		paused = true
		sound:Pause()
		group:SetAttribute("TestPlaying", false)
		fireState()
	elseif action == "resume" then
		paused = false
		sound:Resume()
		group:SetAttribute("TestPlaying", sound.IsPlaying)
		fireState()
	elseif action == "next" then
		sound.TimePosition = 0
		playControl()
	end
end)

Players.PlayerAdded:Connect(function(player)
	task.delay(1, function()
		if player.Parent then
			stateRemote:FireClient(player, "playlist", PLAYLIST)
			fireState(player)
		end
	end)
end)

task.spawn(function()
	local ok, err = pcall(function()
		ContentProvider:PreloadAsync({sound})
	end)
	group:SetAttribute("TestLoaded", ok and sound.IsLoaded)
	group:SetAttribute("TestPreloadOk", ok)
	if not ok then
		group:SetAttribute("TestError", tostring(err))
		warn("[BBYA/Music175Test] preload failed: " .. tostring(err))
		return
	end
	group:SetAttribute("TestTimeLength", sound.TimeLength or 0)
	playControl()
	task.wait(0.35)
	group:SetAttribute("TestPlaying", sound.IsPlaying)
	group:SetAttribute("TestTimeLength", sound.TimeLength or 0)
	print(string.format("[BBYA/Music175Test] asset=%s loaded=%s playing=%s processedLength=%.3f playbackSpeed=%.10f", ASSET_ID, tostring(sound.IsLoaded), tostring(sound.IsPlaying), sound.TimeLength or 0, sound.PlaybackSpeed))
end)

task.spawn(function()
	while task.wait(2) do
		group:SetAttribute("TestLoaded", sound.IsLoaded)
		group:SetAttribute("TestPlaying", sound.IsPlaying)
		group:SetAttribute("TestTimeLength", sound.TimeLength or 0)
		group:SetAttribute("TestPlaybackSpeed", sound.PlaybackSpeed)
		fireState()
	end
end)
