local ActivityConfig = {
    Version = "1.1.3-skate-mission-completion-1",
    Activities = {
        SKATE_LINE = {
            Title = "Skate Line",
            RewardCoins = 180,
            RewardRep = 55,
            CooldownSeconds = 60,
            TimeLimitSeconds = 60,
            Radius = 11,
            RequireSkateboard = true,
        },
        POOL_LAPS = {
            Title = "Pool Laps",
            RewardCoins = 160,
            RewardRep = 50,
            CooldownSeconds = 60,
            TimeLimitSeconds = 75,
            Radius = 10,
            RequireSwimming = true,
        },
        CITY_DELIVERY = {
            Title = "City Delivery",
            RewardCoins = 220,
            RewardRep = 65,
            CooldownSeconds = 75,
            TimeLimitSeconds = 120,
            Radius = 12,
        },
    },
}

return ActivityConfig
