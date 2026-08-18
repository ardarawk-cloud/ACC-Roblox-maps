return {
    GameId = "WONDERPOCKET",
    DisplayName = "WONDERPOCKET",
    Tagline = "Build Your Little World",
    Version = "0.1.0-foundation",

    Economy = {
        StartingCoins = 250,
        StartingStars = 5,
        PremiumCurrency = "Robux",
    },

    Starter = {
        House = "Starter Cottage",
        Biome = "Meadow Pocket",
        Wondi = "Bubbi",
        Seed = "CarrotSeed",
        SeedCount = 3,
    },

    Wondies = {
        {Id="Bubbi", Element="Joy", Rarity="Common"},
        {Id="Flamo", Element="Fire", Rarity="Common"},
        {Id="Mossy", Element="Nature", Rarity="Common"},
        {Id="Lumi", Element="Light", Rarity="Uncommon"},
        {Id="Zappy", Element="Spark", Rarity="Uncommon"},
        {Id="Puffy", Element="Cloud", Rarity="Rare"},
    },

    Gardening = {
        Crops = {
            Carrot = {GrowSeconds=180, Sell=12, XP=5},
            Strawberry = {GrowSeconds=420, Sell=30, XP=10},
            Sunflower = {GrowSeconds=900, Sell=65, XP=20},
        },
        OfflineGrowthCapSeconds = 8 * 60 * 60,
    },

    Social = {
        HubName = "Wonder Square",
        MaxPlayersSuggested = 16,
        Gifts = {"Balloon", "IceCream", "Flower", "Fireworks"},
    },

    MiniAdventures = {
        "Escape Volcano",
        "Treasure Island",
        "Cloud Race",
    },

    LiveOps = {
        DailyResetUTC = 0,
        WeeklyResetWeekday = 1,
        MonthlyEventsEnabled = true,
    },
}
