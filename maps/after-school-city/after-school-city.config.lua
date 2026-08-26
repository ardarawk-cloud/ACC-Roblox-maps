local Config = {
    ProjectId = "after-school-city",
    DisplayName = "AFTER SCHOOL CITY",
    Version = "0.4.0-street-density-pass-1",

    Roblox = {
        UniverseId = "10745359869",
        PlaceId = "121603385909425",
    },

    World = {
        RootName = "AfterSchoolCity",
        GroundY = 0,
        Spawn = Vector3.new(0, 2.2, 271),
        DistrictTravelTargetSeconds = 45,
        Districts = {
            School = {Center = Vector3.new(0, 0, 210), Size = Vector3.new(220, 2, 150)},
            Downtown = {Center = Vector3.new(0, 0, 0), Size = Vector3.new(230, 2, 170)},
            SkatePark = {Center = Vector3.new(235, 0, 0), Size = Vector3.new(150, 2, 150)},
            Park = {Center = Vector3.new(0, 0, -210), Size = Vector3.new(220, 2, 150)},
            Residential = {Center = Vector3.new(-235, 0, 0), Size = Vector3.new(150, 2, 150)},
            SportsField = {Center = Vector3.new(235, 0, 210), Size = Vector3.new(150, 2, 130)},
        },
    },

    Gameplay = {
        StartingCoins = 250,
        StartingLifeLevel = 1,
        FirstActivityReward = 100,
        DailyMissionCount = 3,
    },

    Flags = {
        EnableBlockoutScaffold = false,
        EnablePremiumFoundation = true,
        EnableCityLifePass = true,
        EnableStreetDensityPass = true,
        EnableDebugBillboards = false,
        EnableActivities = false,
        EnableEconomy = false,
        EnablePersistence = false,
        EnablePersonalRoom = false,
        EnableClubs = false,
    },
}

return Config
