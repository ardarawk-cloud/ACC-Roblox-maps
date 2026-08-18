local Config = {
    ProjectId = "becak-e-bike",
    DisplayName = "BECAK E-BIKE",
    Version = "0.1.0",

    World = {
        Spawn = Vector3.new(0, 6, 0),
        RoadLength = 900,
        RoadWidth = 34,
        TestAreaSize = Vector3.new(220, 2, 180),
    },

    Vehicle = {
        MaxSpeed = 42,
        ReverseSpeed = 12,
        Acceleration = 7,
        BrakeStrength = 12,
        CargoCapacityKg = 150,
    },

    Gameplay = {
        StartingCoins = 250,
        DeliveryBaseReward = 40,
        DeliveryDistanceBonus = 0.08,
        CheckpointRadius = 14,
    },

    Flags = {
        EnableDeliveryPrototype = true,
        EnableCargoPrototype = true,
        EnableTraffic = false,
        EnablePersistence = false,
    },
}

return Config
