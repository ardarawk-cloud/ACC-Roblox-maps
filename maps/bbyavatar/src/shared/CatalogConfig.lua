local CatalogConfig = {}

CatalogConfig.Version = 1
CatalogConfig.Project = "BBYAVATAR"

CatalogConfig.Categories = {
    "Featured",
    "Streetwear",
    "Cyber",
    "Luxury",
    "Cute",
    "Bali",
    "Seasonal",
}

-- Asset IDs are intentionally placeholders until approved Roblox assets exist.
CatalogConfig.Looks = {
    {
        id = "featured_001",
        name = "Starter Look",
        category = "Featured",
        enabled = false,
        featured = true,
        tags = {"starter", "full-look"},
        thumbnailAssetId = 0,
        items = {
            hair = 0,
            head = 0,
            face = 0,
            top = 0,
            bottom = 0,
            shoes = 0,
            accessory1 = 0,
            accessory2 = 0,
        },
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

return CatalogConfig
