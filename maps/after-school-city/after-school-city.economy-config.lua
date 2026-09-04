local EconomyConfig = {
    Version = "1.3.0-economy-first-shop-1",
    PurchaseCooldownSeconds = 0.45,

    FirstShop = {
        Id = "STUDENT_MINI_MART",
        DisplayName = "STUDENT MINI MART",
        ModelName = "StudentMiniMart",
        MaxActivationDistance = 8,
        Items = {
            {
                Id = "CAMPUS_NOTEBOOK",
                DisplayName = "Campus Notebook",
                Price = 60,
                MaxOwned = 1,
                Kind = "Collectible",
                Color = Color3.fromRGB(66, 111, 161),
            },
            {
                Id = "CITY_STICKER_PACK",
                DisplayName = "City Sticker Pack",
                Price = 85,
                MaxOwned = 1,
                Kind = "Collectible",
                Color = Color3.fromRGB(225, 170, 73),
            },
            {
                Id = "ASC_KEYCHAIN",
                DisplayName = "ASC Keychain",
                Price = 110,
                MaxOwned = 1,
                Kind = "Collectible",
                Color = Color3.fromRGB(64, 145, 133),
            },
            {
                Id = "STUDENT_TOTE",
                DisplayName = "Student Tote",
                Price = 140,
                MaxOwned = 1,
                Kind = "Collectible",
                Color = Color3.fromRGB(130, 94, 158),
            },
        },
    },
}

return EconomyConfig
