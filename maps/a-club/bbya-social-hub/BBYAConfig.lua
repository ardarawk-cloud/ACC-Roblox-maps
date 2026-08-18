local Config = {}

Config.Roles = {
	Hierarchy = {
		PLAYER = 1,
		VIP = 2,
		DJ = 3,
		ADMIN = 4,
		BBYA_QUEEN = 5,
		ACC_MASTER_OWNER = 6,
	},
	UserRoles = {
		[4271188557] = "BBYA_QUEEN",
		-- [YOUR_USER_ID] = "ACC_MASTER_OWNER",
	},
}

Config.Music = {
	DefaultVolume = 0.55,
	FallbackSoundId = 0,
	Playlists = {
		EDM = {}, HOUSE = {}, TECH_HOUSE = {}, BREAKBEAT = {},
		INDO_BOUNCE = {}, FUNKOT = {}, ELECTRONIC = {}, CHILL = {}, POOL_PARTY = {},
	},
}

Config.Lighting = {
	NORMAL_CLUB = {Brightness = 2, ClockTime = 0.4, FogEnd = 850},
	PARTY = {Brightness = 2.3, ClockTime = 0.4, FogEnd = 700},
	EDM_DROP = {Brightness = 2.8, ClockTime = 0.4, FogEnd = 650},
	BREAKBEAT = {Brightness = 2.5, ClockTime = 0.4, FogEnd = 650},
	FUNKOT = {Brightness = 2.6, ClockTime = 0.4, FogEnd = 680},
	CHILL = {Brightness = 1.7, ClockTime = 0.5, FogEnd = 900},
	POOL_PARTY = {Brightness = 2.2, ClockTime = 0.35, FogEnd = 1000},
	BBYA_QUEEN = {Brightness = 2.4, ClockTime = 0.4, FogEnd = 750},
	SPECIAL_EVENT = {Brightness = 3, ClockTime = 0.35, FogEnd = 700},
}

Config.SupportProducts = {
	[5] = 0, [10] = 0, [25] = 0, [50] = 0,
	[100] = 0, [250] = 0, [500] = 0,
}

Config.Event = {
	Name = "BBYA Night",
	Date = "",
	StartTime = "",
	FeaturedDJ = "BBYA",
	Theme = "NORMAL_CLUB",
	Playlist = "EDM",
}

return Config
