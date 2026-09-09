-- AFTER SCHOOL CITY â€” V1.3.4 Sports Asset Integration
-- External asset layer only. Existing Skate Line, legacy skate geometry, basketball court,
-- gameplay, economy, persistence, music, dedication, and monetization remain authoritative.

local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local VERSION = "1.3.4-sports-assets-1"
local SKATEBOARD_PACK_ASSET_ID = 111060043204479 -- ASC_WORKFLOW_SKATEBOARD_ASSET_ID
local BASKETBALL_COURT_ASSET_ID = 0 -- LICENSE_HOLD: do not activate until rights are verified.

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V134 SportsAssets] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_SkateparkLightClearance", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V134 SportsAssets] AfterSchoolCity root missing")
    return
end

if root:FindFirstChild("V134_SportsAssets") then
    return
end

local districts = root:FindFirstChild("Districts")
local skate = districts and districts:FindFirstChild("SkatePark")
local deck = skate and skate:FindFirstChild("Deck")
local skateGround = skate and skate:FindFirstChild("SkateGround")
local sports = districts and districts:FindFirstChild("SportsField")
local basketballCourt = sports and sports:FindFirstChild("BasketballCourt")

if not skate or not deck or not deck:IsA("BasePart") or not skateGround or not skateGround:IsA("BasePart") then
    warn("[ASC V134 SportsAssets] protected SkatePark authority missing")
    return
end
if not sports or not basketballCourt or not basketballCourt:IsA("BasePart") then
    warn("[ASC V134 SportsAssets] protected SportsField authority missing")
    return
end

local protected = {
    DeckParent = deck.Parent,
    DeckCFrame = deck.CFrame,
    DeckSize = deck.Size,
    SkateGroundParent = skateGround.Parent,
    SkateGroundCFrame = skateGround.CFrame,
    SkateGroundSize = skateGround.Size,
    CourtParent = basketballCourt.Parent,
    CourtCFrame = basketballCourt.CFrame,
    CourtSize = basketballCourt.Size,
}

local layer = Instance.new("Model")
layer.Name = "V134_SportsAssets"
layer:SetAttribute("ASC_Layer", "SPORTS_EXTERNAL_ASSETS")
layer:SetAttribute("ASC_Version", VERSION)
layer:SetAttribute("ASC_SkateboardPackLicense", "CC-BY-4.0")
layer:SetAttribute("ASC_SkateboardPackAuthor", "Arsen Ismailov")
layer:SetAttribute("ASC_BasketballAssetStatus", "LICENSE_HOLD")
layer.Parent = root

local skateLayer = Instance.new("Model")
skateLayer.Name = "SkateparkImportedProps"
skateLayer.Parent = layer

local function normalize(value)
    return string.lower((value or ""):gsub("[^%w]", ""))
end

local function loadAsset(assetId)
    if not assetId or assetId <= 0 then
        return nil, "ASSET_ID_DISABLED"
    end
    local ok, container = pcall(function()
        return InsertService:LoadAsset(assetId)
    end)
    if not ok or not container then
        return nil, tostring(container)
    end
    return container, nil
end

local function findImportedPart(container, needle)
    local normalizedNeedle = normalize(needle)
    for _, descendant in ipairs(container:GetDescendants()) do
        if descendant:IsA("BasePart") and string.find(normalize(descendant.Name), normalizedNeedle, 1, true) then
            return descendant
        end
    end
    return nil
end

local function rotationOnly(cf)
    return cf - cf.Position
end

local function placeProp(source, name, localX, localZ, yawDegrees, targetLongestXZ)
    if not source or not source:IsA("BasePart") then
        return nil
    end

    local prop = source:Clone()
    prop.Name = name
    prop.Anchored = true
    prop.CanCollide = true
    prop.CanTouch = false
    prop.CanQuery = true
    prop.CastShadow = true

    local longest = math.max(source.Size.X, source.Size.Z)
    if longest <= 0.01 then
        prop:Destroy()
        return nil
    end
    local scale = targetLongestXZ / longest
    prop.Size = source.Size * scale

    if prop:IsA("MeshPart") then
        pcall(function()
            prop.CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition
        end)
    end

    local deckTop = deck.Position.Y + deck.Size.Y * 0.5
    local centerWorld = deck.CFrame:PointToWorldSpace(Vector3.new(localX, 0, localZ))
    local y = deckTop + prop.Size.Y * 0.5 + 0.04
    prop.CFrame = CFrame.new(centerWorld.X, y, centerWorld.Z)
        * CFrame.Angles(0, math.rad(yawDegrees or 0), 0)
        * rotationOnly(source.CFrame)
    prop:SetAttribute("ASC_ExternalAsset", true)
    prop:SetAttribute("ASC_AssetSource", "SKATEBOARDING_PROPS_PACK")
    prop:SetAttribute("ASC_Attribution", "Arsen Ismailov / CC BY 4.0")
    prop.Parent = skateLayer
    return prop
end

local importedCount = 0
local pack, loadError = loadAsset(SKATEBOARD_PACK_ASSET_ID)
if pack then
    local placements = {
        {Key = "InclineRamp", Name = "ImportedInclineRamp", X = -25, Z = -43, Yaw = 0, Longest = 20},
        {Key = "DoubleRamp", Name = "ImportedDoubleRamp", X = 25, Z = 43, Yaw = 180, Longest = 20},
        {Key = "RailStraight", Name = "ImportedStraightRail", X = -25, Z = 0, Yaw = 90, Longest = 15},
        {Key = "RailTurn", Name = "ImportedCurvedRail", X = 25, Z = 0, Yaw = -90, Longest = 12},
    }

    for _, placement in ipairs(placements) do
        local source = findImportedPart(pack, placement.Key)
        if source then
            local prop = placeProp(
                source,
                placement.Name,
                placement.X,
                placement.Z,
                placement.Yaw,
                placement.Longest
            )
            if prop then
                importedCount += 1
            end
        else
            warn("[ASC V134 SportsAssets] imported mesh not found: " .. placement.Key)
        end
    end
    pack:Destroy()
else
    warn("[ASC V134 SportsAssets] skateboard asset unavailable: " .. tostring(loadError))
end

-- Basketball source has been optimized and evaluated separately, but intentionally remains
-- disabled until its redistribution/use license is positively verified. Existing court stays live.
if BASKETBALL_COURT_ASSET_ID > 0 then
    warn("[ASC V134 SportsAssets] basketball asset ID present unexpectedly while LICENSE_HOLD is active")
end

local protectedUnchanged = deck.Parent == protected.DeckParent
    and deck.CFrame == protected.DeckCFrame
    and deck.Size == protected.DeckSize
    and skateGround.Parent == protected.SkateGroundParent
    and skateGround.CFrame == protected.SkateGroundCFrame
    and skateGround.Size == protected.SkateGroundSize
    and basketballCourt.Parent == protected.CourtParent
    and basketballCourt.CFrame == protected.CourtCFrame
    and basketballCourt.Size == protected.CourtSize

if not protectedUnchanged then
    warn("[ASC V134 SportsAssets] HARD LOCK FAILED: protected skate/court geometry changed")
    layer:Destroy()
    return
end

layer:SetAttribute("ASC_SkateImportedPropCount", importedCount)
layer:SetAttribute("ASC_SkateboardPackAssetId", SKATEBOARD_PACK_ASSET_ID)
layer:SetAttribute("ASC_ProtectedGeometryUnchanged", true)
root:SetAttribute("ASC_SportsAssetsV134", VERSION)
root:SetAttribute("ASC_SkateExternalPropsReady", importedCount == 4)
root:SetAttribute("ASC_BasketballExternalAssetEnabled", false)
Workspace:SetAttribute("ASC_SportsAssetsV134", VERSION)

if importedCount == 4 then
    print(string.format("[AFTER SCHOOL CITY] V1.3.4 sports assets ready; skateboardProps=%d basketball=LICENSE_HOLD protectedUnchanged=true", importedCount))
else
    warn(string.format("[ASC V134 SportsAssets] partial skateboard import; expected=4 actual=%d", importedCount))
end

