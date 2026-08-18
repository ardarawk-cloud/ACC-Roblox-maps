return {
    GameId = "WONDERPOCKET",
    DisplayName = "WONDERPOCKET",
    Tagline = "Build Your Little World",
    Version = "1.0.0-closed-test-build-candidate",

    Economy = {
        StartingCoins = 250,
        StartingStars = 5,
        PremiumCurrency = "Robux",
        NoPayToWin = true,
        CanonicalCoinAttribute = "Coins",
        CanonicalStarAttribute = "Stars",
    },

    Starter = {
        House = "Starter Cottage",
        Biome = "Meadow Pocket",
        Wondi = "Bubbi",
        Seed = "CarrotSeed",
        SeedCount = 3,
    },

    Wondies = {
        {Id="Bubbi", Element="Joy", Rarity="Common", Emotes={"Wave","Happy","Sleep"}},
        {Id="Flamo", Element="Fire", Rarity="Common", Emotes={"Wave","Spark"}},
        {Id="Mossy", Element="Nature", Rarity="Common", Emotes={"Wave","Bloom"}},
        {Id="Lumi", Element="Light", Rarity="Uncommon", Emotes={"Wave","Glow"}},
        {Id="Zappy", Element="Spark", Rarity="Uncommon", Emotes={"Wave","Zap"}},
        {Id="Puffy", Element="Cloud", Rarity="Rare", Emotes={"Wave","Float"}},
    },

    Gardening = {
        Crops = {
            Carrot = {GrowSeconds=180, Sell=12, XP=5},
            Strawberry = {GrowSeconds=420, Sell=30, XP=10},
            Sunflower = {GrowSeconds=900, Sell=65, XP=20},
        },
        OfflineGrowthCapSeconds = 8 * 60 * 60,
    },

    Quests = {
        Starter = {Id="HARVEST_3", Target=3, RewardCoins=75, RewardStars=2},
        Daily = {
            {Id="DAILY_HARVEST_5", Target=5, RewardCoins=100, RewardStars=1},
            {Id="DAILY_VISIT_1", Target=1, RewardCoins=60, RewardStars=1},
            {Id="DAILY_TREASURE_3", Target=3, RewardCoins=90, RewardStars=1},
        },
        Weekly = {
            {Id="WEEKLY_HARVEST_25", Target=25, RewardCoins=500, RewardStars=5},
            {Id="WEEKLY_ADVENTURE_5", Target=5, RewardCoins=450, RewardStars=5},
        },
    },

    Furniture = {
        Catalog = {
            {Id="CloudBed", Name="Cloud Bed", PriceCoins=325, Rarity="Uncommon"},
            {Id="StarLamp", Name="Star Lamp", PriceCoins=125, Rarity="Common"},
            {Id="RainbowSofa", Name="Rainbow Sofa", PriceCoins=450, Rarity="Rare"},
            {Id="BunnyChair", Name="Bunny Chair", PriceCoins=180, Rarity="Common"},
            {Id="ToyChest", Name="Toy Chest", PriceCoins=220, Rarity="Common"},
            {Id="MiniAquarium", Name="Mini Aquarium", PriceCoins=550, Rarity="Rare"},
        },
        PlacementGrid = 1,
        RotationStepDegrees = 90,
        MaxPlacedStarter = 50,
        SaveEnabled = true,
        GhostPreviewEnabled = true,
        ServerPlotValidation = true,
        PlayerOwnedPlots = true,
        PersonalStarterCottage = true,
        PlotRelativePersistence = true,
        MobilePlaceRotateCancel = true,
    },

    Shop = {
        RotationHours = 24,
        FeaturedSlots = 4,
        CosmeticOnlyRobux = true,
        DeterministicDailyRotation = true,
        RobuxExamples = {
            WondiEmote = 5,
            Trail = 5,
            Hat = 9,
            WondiOutfit = 15,
            DecorPack = 19,
            HouseTheme = 29,
            BiomeCosmeticPack = 39,
            PremiumBundle = 49,
        },
    },

    WonderDex = {
        Categories = {"Wondies", "Plants", "Furniture", "Badges", "Biomes"},
        CompletionRewardsEnabled = true,
    },

    Social = {
        HubName = "Wonder Square",
        MaxPlayersSuggested = 12,
        VisitEnabled = true,
        Gifts = {
            {Id="Balloon", PriceRobux=3},
            {Id="IceCream", PriceRobux=3},
            {Id="Flower", PriceRobux=5},
            {Id="Fireworks", PriceRobux=7},
        },
    },

    MiniAdventures = {
        {Id="TreasureIsland", Name="Treasure Island", DurationSeconds=240, RewardCoins=120, RewardStars=1},
        {Id="EscapeVolcano", Name="Escape Volcano", DurationSeconds=300, RewardCoins=160, RewardStars=1},
        {Id="CloudRace", Name="Cloud Race", DurationSeconds=180, RewardCoins=100, RewardStars=1},
    },

    Retention = {
        OfflineRewardEnabled = true,
        OfflineRewardCapSeconds = 8 * 60 * 60,
        OfflineCoinsPerMinute = 1,
        DailyRewardEnabled = true,
        DailyQuestEnabled = true,
        WeeklyQuestEnabled = true,
    },

    Runtime = {
        DataSchemaVersion = 2,
        DataStoreRetries = 4,
        AutosaveSeconds = 90,
        WondiReconnectSafe = true,
        AdventureRewardDebounce = true,
        ServerAuthoritativeAdventureRewards = true,
        MultiplayerTreasureState = true,
        OnboardingPersistence = true,
        TutorialOwnsOnboardingCompletion = true,
        InternalSessionTelemetry = true,
        ClosedTestHealthPanel = true,
        CanonicalEconomyAttributes = true,
        FirstSessionObjectiveTracking = true,
    },

    Onboarding = {
        Enabled = true,
        PersistCompletion = true,
        FirstSessionTargetMinutes = 10,
        Steps = {
            {Id="MeetWondi", Text="Say hi to your Wondi"},
            {Id="PlantCarrot", Text="Plant your first carrot"},
            {Id="BuyFurniture", Text="Buy one furniture item"},
            {Id="PlaceFurniture", Text="Decorate your Pocket World"},
            {Id="HarvestCarrot", Text="Harvest your carrot"},
            {Id="Treasure", Text="Find one treasure on Treasure Island"},
        },
    },

    PremiumPresentation = {
        DynamicDayNight = true,
        Atmosphere = true,
        Bloom = true,
        ColorCorrection = true,
        AmbientParticles = true,
        MobileFirstUI = true,
        SoftCameraMoments = true,
        FurnitureGhostPreview = true,
        PremiumPanels = true,
    },

    QA = {
        ClosedTestCandidate = true,
        PrePublishHardening = true,
        RuntimeHardening = true,
        ClosedTestExperiencePass = true,
        FirstTenMinuteLoopWired = true,
        CanonicalEconomyAudit = true,
        PersonalPocketWorldAudit = true,
        PlotRelativeFurnitureAudit = true,
        ServerAuthorityAudit = true,
        IsolatedBuildPipeline = true,
        ForeignMapTokenGuard = true,
        PublishAllowed = false,
        RequiresLiveDataStoreTest = true,
        RequiresMultiplayerPlotTest = true,
        RequiresMobilePlacementTest = true,
        RequiresTenMinuteLoopTest = true,
    },

    LiveOps = {
        DailyResetUTC = 0,
        WeeklyResetWeekday = 1,
        MonthlyEventsEnabled = true,
    },
}
