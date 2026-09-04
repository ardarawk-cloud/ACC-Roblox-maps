local GameplayConfig = {
    Version = "1.3.0-economy-first-shop-1",
    DataStoreName = "ASC_PlayerProfile_v1",
    SchemaVersion = 2,
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
        "SCHOOL_MEET_TEACHER",
        "SCHOOL_HELP_CANTEEN",
        "SCHOOL_JOIN_CLUB",
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
        SCHOOL_MEET_TEACHER = {
            Title = "School Check-In",
            Objective = "Meet Ms. Maya in Classroom A",
            RewardCoins = 100,
            RewardRep = 30,
        },
        SCHOOL_HELP_CANTEEN = {
            Title = "Canteen Helper",
            Objective = "Help Mr. Budi at the school canteen",
            RewardCoins = 120,
            RewardRep = 35,
        },
        SCHOOL_JOIN_CLUB = {
            Title = "Club Time",
            Objective = "Talk to Naya in the club room",
            RewardCoins = 150,
            RewardRep = 45,
        },
    },
}

return GameplayConfig
