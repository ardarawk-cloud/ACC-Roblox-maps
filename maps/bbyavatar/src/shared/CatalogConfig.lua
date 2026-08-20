local CatalogConfig = {}

CatalogConfig.Version = 2
CatalogConfig.Project = "BBYAVATAR"

CatalogConfig.Categories = {
    "Featured",
    "Streetwear",
    "Cyber",
    "Luxury",
    "Cute",
    "Bali",
    "Seasonal",
    "Creators",
    "Trending",
}

-- Asset IDs intentionally remain placeholders until approved Roblox assets exist.
-- Looks stay disabled until every required asset has been validated.
CatalogConfig.Looks = {
    {
        id = "street_001",
        name = "Midnight Street",
        category = "Streetwear",
        enabled = false,
        featured = true,
        tags = {"streetwear", "black", "urban", "full-look"},
        thumbnailAssetId = 0,
        items = {
            hair = 0, face = 0, shirt = 0, pants = 0,
            hatAccessory = {}, hairAccessory = {}, faceAccessory = {},
            neckAccessory = {}, frontAccessory = {}, backAccessory = {}, waistAccessory = {},
        },
        purchase = {enabled = false, assetIds = {}},
    },
    {
        id = "cyber_001",
        name = "Neon Runner",
        category = "Cyber",
        enabled = false,
        featured = true,
        tags = {"cyber", "neon", "techwear", "full-look"},
        thumbnailAssetId = 0,
        items = {
            hair = 0, face = 0, shirt = 0, pants = 0,
            hatAccessory = {}, hairAccessory = {}, faceAccessory = {},
            neckAccessory = {}, frontAccessory = {}, backAccessory = {}, waistAccessory = {},
        },
        purchase = {enabled = false, assetIds = {}},
    },
    {
        id = "luxury_001",
        name = "Velvet Gold",
        category = "Luxury",
        enabled = false,
        featured = false,
        tags = {"luxury", "formal", "gold", "full-look"},
        thumbnailAssetId = 0,
        items = {
            hair = 0, face = 0, shirt = 0, pants = 0,
            hatAccessory = {}, hairAccessory = {}, faceAccessory = {},
            neckAccessory = {}, frontAccessory = {}, backAccessory = {}, waistAccessory = {},
        },
        purchase = {enabled = false, assetIds = {}},
    },
    {
        id = "cute_001",
        name = "Cloud Pop",
        category = "Cute",
        enabled = false,
        featured = false,
        tags = {"cute", "soft", "pastel", "full-look"},
        thumbnailAssetId = 0,
        items = {
            hair = 0, face = 0, shirt = 0, pants = 0,
            hatAccessory = {}, hairAccessory = {}, faceAccessory = {},
            neckAccessory = {}, frontAccessory = {}, backAccessory = {}, waistAccessory = {},
        },
        purchase = {enabled = false, assetIds = {}},
    },
    {
        id = "bali_001",
        name = "Island Afterdark",
        category = "Bali",
        enabled = false,
        featured = true,
        tags = {"bali", "island", "nightlife", "full-look"},
        thumbnailAssetId = 0,
        items = {
            hair = 0, face = 0, shirt = 0, pants = 0,
            hatAccessory = {}, hairAccessory = {}, faceAccessory = {},
            neckAccessory = {}, frontAccessory = {}, backAccessory = {}, waistAccessory = {},
        },
        purchase = {enabled = false, assetIds = {}},
    },
    {
        id = "seasonal_001",
        name = "Rain Season",
        category = "Seasonal",
        enabled = false,
        featured = false,
        tags = {"seasonal", "rain", "layered", "full-look"},
        thumbnailAssetId = 0,
        items = {
            hair = 0, face = 0, shirt = 0, pants = 0,
            hatAccessory = {}, hairAccessory = {}, faceAccessory = {},
            neckAccessory = {}, frontAccessory = {}, backAccessory = {}, waistAccessory = {},
        },
        purchase = {enabled = false, assetIds = {}},
    },
}

function CatalogConfig.GetLookById(lookId)
    for _, look in ipairs(CatalogConfig.Looks) do
        if look.id == lookId then
            return look
        end
    end
    return nil
end

function CatalogConfig.GetEnabledLooks()
    local result = {}
    for _, look in ipairs(CatalogConfig.Looks) do
        if look.enabled then
            table.insert(result, look)
        end
    end
    return result
end

function CatalogConfig.GetLooksByCategory(category)
    local result = {}
    for _, look in ipairs(CatalogConfig.Looks) do
        if look.enabled and look.category == category then
            table.insert(result, look)
        end
    end
    return result
end

return CatalogConfig
