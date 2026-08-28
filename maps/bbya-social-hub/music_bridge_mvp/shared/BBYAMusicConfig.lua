-- BBYA Music Bridge MVP
-- Keep this module in ReplicatedStorage as BBYAMusicConfig when integrating.

return {
	-- Replace this with the HTTPS endpoint exposed by the BBYA Music backend.
	Endpoint = "https://YOUR-BACKEND.example.com/api/bbya/music/state",

	-- Roblox HttpService polling interval. Keep this conservative for MVP.
	PollSeconds = 10,

	RemoteName = "BBYAMusicState",
	SoundName = "BBYAMusicSound",
	Volume = 0.45,

	-- Prevent absurd payload strings from reaching the UI.
	MaxTitleLength = 80,
	MaxArtistLength = 80,
	MaxTrackIdLength = 80,
	MaxCoverLength = 120,

	Debug = true,
}
