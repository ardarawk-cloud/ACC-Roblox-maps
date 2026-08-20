local AvatarDescriptionBuilder = {}

local function setNumber(description, propertyName, value)
    if type(value) == "number" and value > 0 then
        pcall(function()
            description[propertyName] = value
        end)
    end
end

local function setAccessoryList(description, propertyName, value)
    if type(value) == "number" and value > 0 then
        value = tostring(value)
    elseif type(value) == "table" then
        local ids = {}
        for _, assetId in ipairs(value) do
            if type(assetId) == "number" and assetId > 0 then
                table.insert(ids, tostring(assetId))
            end
        end
        value = table.concat(ids, ",")
    end

    if type(value) == "string" and value ~= "" then
        pcall(function()
            description[propertyName] = value
        end)
    end
end

function AvatarDescriptionBuilder.ApplyLook(description, look)
    if not description or not look or type(look.items) ~= "table" then
        return false, "INVALID_LOOK"
    end

    local items = look.items

    setNumber(description, "Face", items.face)
    setNumber(description, "Shirt", items.top or items.shirt)
    setNumber(description, "Pants", items.bottom or items.pants)
    setNumber(description, "GraphicTShirt", items.graphicTShirt)

    setAccessoryList(description, "HairAccessory", items.hair)
    setAccessoryList(description, "HatAccessory", items.hats)
    setAccessoryList(description, "FaceAccessory", items.faceAccessories)
    setAccessoryList(description, "NeckAccessory", items.neckAccessories)
    setAccessoryList(description, "FrontAccessory", items.frontAccessories)
    setAccessoryList(description, "BackAccessory", items.backAccessories)
    setAccessoryList(description, "WaistAccessory", items.waistAccessories)

    setNumber(description, "Head", items.head)
    setNumber(description, "Torso", items.torso)
    setNumber(description, "LeftArm", items.leftArm)
    setNumber(description, "RightArm", items.rightArm)
    setNumber(description, "LeftLeg", items.leftLeg)
    setNumber(description, "RightLeg", items.rightLeg)

    return true
end

return AvatarDescriptionBuilder
