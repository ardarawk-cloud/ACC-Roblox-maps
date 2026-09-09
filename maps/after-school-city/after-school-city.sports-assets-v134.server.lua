-- AFTER SCHOOL CITY — V1.3.6 Skate Overlap Hotfix
-- Runtime-evidence hotfix: keep the approved skate/basket assets, but place imported skate props
-- only in clear deck zones so they do not intersect legacy ramps, rails, walls, or each other.
-- Existing Skate Line, SportsField base geometry, gameplay, economy, persistence, music,
-- dedication, and monetization remain authoritative.

local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local VERSION = "1.3.6-skate-overlap-hotfix-1"
local SKATEBOARD_PACK_ASSET_ID = 111060043204479 -- ASC_WORKFLOW_SKATEBOARD_ASSET_ID
local BASKETBALL_COURT_ASSET_ID = 119323680316690 -- ASC_WORKFLOW_BASKETBALL_ASSET_ID

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V136 SportsAssets] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_SkateparkLightClearance", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V136 SportsAssets] AfterSchoolCity root missing")
    return
end

if root:FindFirstChild("V136_SportsAssets") then
    return
end

local districts = root:FindFirstChild("Districts")
local skate = districts and districts:FindFirstChild("SkatePark")
local deck = skate and skate:FindFirstChild("Deck")
local skateGround = skate and skate:FindFirstChild("SkateGround")
local sports = districts and districts:FindFirstChild("SportsField")
local basketballCourt = sports and sports:FindFirstChild("BasketballCourt")

if not skate or not deck or not deck:IsA("BasePart") or not skateGround or not skateGround:IsA("BasePart") then
    warn("[ASC V136 SportsAssets] protected SkatePark authority missing")
    return
end
if not sports or not basketballCourt or not basketballCourt:IsA("BasePart") then
    warn("[ASC V136 SportsAssets] protected SportsField authority missing")
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
layer.Name = "V136_SportsAssets"
layer:SetAttribute("ASC_Layer", "SPORTS_EXTERNAL_ASSETS")
layer:SetAttribute("ASC_Version", VERSION)
layer:SetAttribute("ASC_SkateboardPackLicense", "CC-BY-4.0")
layer:SetAttribute("ASC_SkateboardPackAuthor", "Arsen Ismailov")
layer:SetAttribute("ASC_BasketballAssetStatus", "ENABLED")
layer:SetAttribute("ASC_SkatePlacementStrategy", "CLEARANCE_AWARE")
layer.Parent = root

local skateLayer = Instance.new("Model")
skateLayer.Name = "SkateparkImportedProps"
skateLayer.Parent = layer

local basketLayer = Instance.new("Model")
basketLayer.Name = "BasketballImportedCourt"
basketLayer.Parent = layer

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

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = {skate, skateLayer}
overlapParams.RespectCanCollide = false

local function skatePlacementClear(candidateCF, propSize)
    local paddedSize = propSize + Vector3.new(5, 4, 5)
    local hits = Workspace:GetPartBoundsInBox(candidateCF, paddedSize, overlapParams)
    for _, hit in ipairs(hits) do
        if hit ~= deck and hit ~= skateGround then
            return false, hit:GetFullName()
        end
    end
    return true, nil
end

local function candidateCFrame(prop, source, localX, localZ, yawDegrees)
    local deckTop = deck.Position.Y + deck.Size.Y * 0.5
    local centerWorld = deck.CFrame:PointToWorldSpace(Vector3.new(localX, 0, localZ))
    local y = deckTop + prop.Size.Y * 0.5 + 0.04
    return CFrame.new(centerWorld.X, y, centerWorld.Z)
        * CFrame.Angles(0, math.rad(yawDegrees or 0), 0)
        * rotationOnly(source.CFrame)
end

local function placeProp(source, name, candidates, targetLongestXZ)
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

    local selectedCF = nil
    local selectedCandidate = nil
    for _, candidate in ipairs(candidates) do
        local cf = candidateCFrame(prop, source, candidate.X, candidate.Z, candidate.Yaw)
        local clear, blocker = skatePlacementClear(cf, prop.Size)
        if clear then
            selectedCF = cf
            selectedCandidate = candidate
            break
        else
            print(string.format(
                "[ASC V136 SportsAssets] reject %s candidate x=%s z=%s blocker=%s",
                name,
                tostring(candidate.X),
                tostring(candidate.Z),
                tostring(blocker)
            ))
        end
    end

    if not selectedCF then
        warn("[ASC V136 SportsAssets] no clear deck position for " .. name .. "; prop skipped instead of overlapping")
        prop:Destroy()
        return nil
    end

    prop.CFrame = selectedCF
    prop:SetAttribute("ASC_ExternalAsset", true)
    prop:SetAttribute("ASC_AssetSource", "SKATEBOARDING_PROPS_PACK")
    prop:SetAttribute("ASC_Attribution", "Arsen Ismailov / CC BY 4.0")
    prop:SetAttribute("ASC_ClearanceChecked", true)
    prop:SetAttribute("ASC_DeckLocalX", selectedCandidate.X)
    prop:SetAttribute("ASC_DeckLocalZ", selectedCandidate.Z)
    prop.Parent = skateLayer
    return prop
end

local skateImportedCount = 0
local pack, skateLoadError = loadAsset(SKATEBOARD_PACK_ASSET_ID)
if pack then
    -- Runtime screenshot evidence from v60 showed the previous ±25/±43 placement colliding with
    -- legacy skate geometry. V1.3.6 uses smaller imported props and multiple clearance-checked
    -- candidate zones. No prop is force-placed if all candidates are obstructed.
    local placements = {
        {
            Key = "InclineRamp",
            Name = "ImportedInclineRamp",
            Longest = 15,
            Candidates = {
                {X = -36, Z = 36, Yaw = 90},
                {X = -18, Z = 40, Yaw = 90},
                {X = 36, Z = -36, Yaw = -90},
            },
        },
        {
            Key = "DoubleRamp",
            Name = "ImportedDoubleRamp",
            Longest = 15,
            Candidates = {
                {X = 36, Z = -36, Yaw = -90},
                {X = 18, Z = -42, Yaw = -90},
                {X = -36, Z = 36, Yaw = 90},
            },
        },
        {
            Key = "RailStraight",
            Name = "ImportedStraightRail",
            Longest = 12,
            Candidates = {
                {X = -34, Z = 12, Yaw = 0},
                {X = -20, Z = 32, Yaw = 0},
                {X = 34, Z = -12, Yaw = 180},
            },
        },
        {
            Key = "RailTurn",
            Name = "ImportedCurvedRail",
            Longest = 10,
            Candidates = {
                {X = 34, Z = -12, Yaw = 180},
                {X = 20, Z = -34, Yaw = 180},
                {X = -34, Z = 12, Yaw = 0},
            },
        },
    }

    for _, placement in ipairs(placements) do
        local source = findImportedPart(pack, placement.Key)
        if source then
            local prop = placeProp(source, placement.Name, placement.Candidates, placement.Longest)
            if prop then
                skateImportedCount += 1
            end
        else
            warn("[ASC V136 SportsAssets] imported skate mesh not found: " .. placement.Key)
        end
    end
    pack:Destroy()
else
    warn("[ASC V136 SportsAssets] skateboard asset unavailable: " .. tostring(skateLoadError))
end

local function placeBasketballCourt(container)
    if not container then
        return false, 0
    end

    for _, child in ipairs(container:GetChildren()) do
        child.Parent = basketLayer
    end
    container:Destroy()

    local partCount = 0
    for _, descendant in ipairs(basketLayer:GetDescendants()) do
        if descendant:IsA("BasePart") then
            partCount += 1
            descendant.Anchored = true
            descendant.CanTouch = false
            descendant.CanQuery = true
            descendant.CastShadow = true
            descendant:SetAttribute("ASC_ExternalAsset", true)
            descendant:SetAttribute("ASC_AssetSource", "BASKETBALL_COURT_GAME_READY_ASSET")
            if descendant:IsA("MeshPart") then
                pcall(function()
                    descendant.CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition
                end)
            end
        end
    end

    if partCount == 0 then
        return false, 0
    end

    local bboxCF, bboxSize = basketLayer:GetBoundingBox()
    if bboxSize.X <= 0.01 or bboxSize.Z <= 0.01 then
        return false, partCount
    end

    local targetLong = math.max(8, basketballCourt.Size.X - 4)
    local targetShort = math.max(8, basketballCourt.Size.Z - 4)
    local sourceLong = math.max(bboxSize.X, bboxSize.Z)
    local sourceShort = math.min(bboxSize.X, bboxSize.Z)
    local scale = math.min(targetLong / sourceLong, targetShort / sourceShort)
    scale = math.clamp(scale, 0.05, 20)
    basketLayer:ScaleTo(scale)

    local scaledCF, scaledSize = basketLayer:GetBoundingBox()
    local rotate90 = scaledSize.Z > scaledSize.X
    local courtTop = basketballCourt.Position.Y + basketballCourt.Size.Y * 0.5
    local targetCF = basketballCourt.CFrame
        * CFrame.new(0, scaledSize.Y * 0.5 + basketballCourt.Size.Y * 0.5 + 0.06, 0)
        * CFrame.Angles(0, rotate90 and math.rad(90) or 0, 0)

    local delta = targetCF * scaledCF:Inverse()
    for _, descendant in ipairs(basketLayer:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.CFrame = delta * descendant.CFrame
        end
    end

    basketLayer:SetAttribute("ASC_BasketballAssetId", BASKETBALL_COURT_ASSET_ID)
    basketLayer:SetAttribute("ASC_ImportedPartCount", partCount)
    basketLayer:SetAttribute("ASC_FittedToProtectedCourt", true)
    basketLayer:SetAttribute("ASC_ProtectedCourtTopY", courtTop)
    return true, partCount
end

local basketballReady = false
local basketballPartCount = 0
local basketPack, basketLoadError = loadAsset(BASKETBALL_COURT_ASSET_ID)
if basketPack then
    basketballReady, basketballPartCount = placeBasketballCourt(basketPack)
    if not basketballReady then
        warn("[ASC V136 SportsAssets] basketball asset loaded but placement failed")
    end
else
    warn("[ASC V136 SportsAssets] basketball asset unavailable: " .. tostring(basketLoadError))
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
    warn("[ASC V136 SportsAssets] HARD LOCK FAILED: protected skate/court geometry changed")
    layer:Destroy()
    return
end

layer:SetAttribute("ASC_SkateImportedPropCount", skateImportedCount)
layer:SetAttribute("ASC_SkateboardPackAssetId", SKATEBOARD_PACK_ASSET_ID)
layer:SetAttribute("ASC_BasketballAssetId", BASKETBALL_COURT_ASSET_ID)
layer:SetAttribute("ASC_BasketballImportedPartCount", basketballPartCount)
layer:SetAttribute("ASC_ProtectedGeometryUnchanged", true)
layer:SetAttribute("ASC_SkateOverlapHotfix", true)
root:SetAttribute("ASC_SportsAssetsV134", "1.3.4-compatible")
root:SetAttribute("ASC_SportsAssetsV135", "1.3.5-compatible")
root:SetAttribute("ASC_SportsAssetsV136", VERSION)
root:SetAttribute("ASC_SkateExternalPropsReady", skateImportedCount == 4)
root:SetAttribute("ASC_BasketballExternalAssetEnabled", basketballReady)
Workspace:SetAttribute("ASC_SportsAssetsV134", "1.3.4-compatible")
Workspace:SetAttribute("ASC_SportsAssetsV135", "1.3.5-compatible")
Workspace:SetAttribute("ASC_SportsAssetsV136", VERSION)

if skateImportedCount == 4 and basketballReady then
    print(string.format(
        "[AFTER SCHOOL CITY] V1.3.6 sports assets ready; skateboardProps=%d basketballParts=%d overlapHotfix=true protectedUnchanged=true",
        skateImportedCount,
        basketballPartCount
    ))
else
    warn(string.format(
        "[ASC V136 SportsAssets] partial external integration; skateboard=%d/4 basketballReady=%s basketballParts=%d",
        skateImportedCount,
        tostring(basketballReady),
        basketballPartCount
    ))
end
