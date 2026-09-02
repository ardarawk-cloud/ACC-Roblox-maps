local SchoolLifeConfig = {
    Version = "1.2.0-school-life-foundation-1",

    QuestIds = {
        Teacher = "SCHOOL_MEET_TEACHER",
        Canteen = "SCHOOL_HELP_CANTEEN",
        Club = "SCHOOL_JOIN_CLUB",
    },

    Repeatables = {
        CANTEEN_SHIFT = {
            RewardCoins = 75,
            RewardRep = 20,
            CooldownSeconds = 120,
        },
        CLUB_PRACTICE = {
            RewardCoins = 90,
            RewardRep = 25,
            CooldownSeconds = 90,
        },
    },

    NPCs = {
        Teacher = {
            DisplayName = "MS. MAYA",
            PromptId = "TEACHER",
        },
        Canteen = {
            DisplayName = "MR. BUDI",
            PromptId = "CANTEEN",
        },
        Club = {
            DisplayName = "NAYA",
            PromptId = "CLUB",
        },
    },
}

return SchoolLifeConfig
