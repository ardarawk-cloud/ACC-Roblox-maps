local GameplayConfig = {
    Version = "1.0.0-gameplay-foundation-1",
    DataStoreName = "ASC_PlayerProfile_v1",
    SchemaVersion = 1,
    AutosaveSeconds = 60,
    LoadRetries = 3,
    SaveRetries = 3,
    LevelRepStep = 250,
    StartingCoins = 250,
    StartingRep = 0,

    QuestOrder = {
        "FIRST_STEPS_DOWNTOWN",
        "VISIT_SKATEPARK",
        "VISIT_CITY_PARK",
    },

    Quests = {
        FIRST_STEPS_DOWNTOWN = {
            Title = "First Steps",
            Objective = "Visit Downtown",
            District = "Downtown",
            RewardCoins = 100,
            RewardRep = 25,
        },
        VISIT_SKATEPARK = {
            Title = "Find the Skatepark",
            Objective = "Visit the Skatepark",
            District = "SkatePark",
            RewardCoins = 125,
            RewardRep = 35,
        },
        VISIT_CITY_PARK = {
            Title = "City Explorer",
            Objective = "Visit City Park",
            District = "Park",
            RewardCoins = 150,
            RewardRep = 50,
        },
    },
}

return GameplayConfig
