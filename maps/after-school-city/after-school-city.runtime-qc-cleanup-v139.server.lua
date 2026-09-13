-- AFTER SCHOOL CITY — V1.3.9 Runtime QC Cleanup Batch
-- Screenshot-driven cleanup after LIVE v62.
-- Fixes in one isolated runtime layer:
-- 1) stop school NPC nameplates rendering through walls / across long distances,
-- 2) rebuild oversized blocky BIKE PARKING frontage into compact readable U-racks,
-- 3) remove visual-only tree ground grates and road/skate trash props proven to clutter circulation,
-- 4) remove small loose cylinder debris inside sports/skate activity footprints,
-- 5) add stable invisible collision surfaces to the SportsField / basketball court so avatars do not sink,
-- 6) preserve the restored imported basketball chain-link fence and all gameplay/data/economy/music authorities.

local Workspace = game:GetService("Workspace")

local VERSION = "1.3.9-runtime-qc-cleanup-1"

local function waitUntil(predicate, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 60)
    repeat
        local ok, value = pcall(predicate)
        if ok and value then
            return value
        end
        task.wait(0.1)
    until os.clock() >= deadline
    return nil
end

local root = Workspace:WaitForChild("AfterSchoolCity", 30)
if not root then
    warn("[ASC V139] AfterSchoolCity root missing")
    return
end

if root:GetAttribute("ASC_RuntimeQCCleanupV139") == VERSION then
    return
end

-- V1.3.8 is the exact LIVE v62 visual authority. Do not race its fence/bench correction.
waitUntil(function()
    return Workspace:GetAttribute("ASC_RuntimeCorrectionV138") ~= nil
        or root:GetAttribute("ASC_RuntimeCorrectionV138") ~= nil
end, 60)
task.wait(1.0)

local districts = root:FindFirstChild("Districts")
local school = districts and districts:FindFirstChild("SchoolDistrict")
local skate = districts and districts:FindFirstChild("SkatePark")
local sports = districts and districts:FindFirstChild("SportsField")
local skateGround = skate and skate:FindFirstChild("SkateGround")
local sportsGround = sports and sports:FindFirstChild("SportsGround")
local court = sports and sports:FindFirstChild("BasketballCourt")
local sportsAssets = root:FindFirstChild("V136_SportsAssets")
local basketLayer = sportsAssets and sportsAssets:FindFirstChild("BasketballImportedCourt")

local layer = Instance.new("Model")
layer.Name = "V139_RuntimeQCCleanup"
layer:SetAttribute("ASC_Layer", "RUNTIME_QC_CLEANUP")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

-- -----------------------------------------------------------------------------
-- A. SCHOOL NPC NAMEPLATES: occlusion + compact distance
-- Gameplay prompts and NPC placement remain untouched.
-- -----------------------------------------------------------------------------
local nameplatesFixed = 0
local gameplayLayer = school and school:FindFirstChild("V120_SchoolLifeGameplay")
if gameplayLayer then
    for _, obj in ipairs(gameplayLayer:GetDescendants()) do
        if obj:IsA("BillboardGui") and obj.Name == "Nameplate" then
            obj.AlwaysOnTop = false
            obj.MaxDistance = 28
            obj.Size = UDim2.fromOffset(132, 26)
            obj.StudsOffset = Vector3.new(0, 3.65, 0)
            obj.LightInfluence = math.max(obj.LightInfluence, 0.28)
            obj:SetAttribute("ASC_V139_OcclusionFixed", true)

            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("TextLabel") then
                    child.TextSize = math.min(child.TextSize, 10)
                    child.BackgroundTransparency = math.max(child.BackgroundTransparency, 0.48)
                end
            end
            nameplatesFixed += 1
        end
    end
end

-- -----------------------------------------------------------------------------
-- B. BIKE PARKING FRONTAGE: compact sign + real U-racks instead of six slab blocks.
-- -----------------------------------------------------------------------------
local bikeSignFixed = false
local oldBikeRacksRemoved = 0
local bikeRackPartsBuilt = 0
local schoolLife = school and school:FindFirstChild("V03_SchoolLife")
local bikes = schoolLife and schoolLife:FindFirstChild("BikeParking")
if bikes then
    local pad = bikes:FindFirstChild("Pad")
    local sign = bikes:FindFirstChild("Sign")

    if sign and sign:IsA("BasePart") then
        local rotation = sign.CFrame - sign.Position
        sign.Size = Vector3.new(12, 2.2, 0.45)
        sign.CFrame = CFrame.new(sign.Position.X, 5.8, sign.Position.Z) * rotation
        sign.CanCollide = false
        sign.CanTouch = false
        sign.CanQuery = false
        sign:SetAttribute("ASC_V139_CompactBikeSign", true)
        for _, gui in ipairs(sign:GetDescendants()) do
            if gui:IsA("SurfaceGui") then
                gui.AlwaysOnTop = false
                gui.PixelsPerStud = math.max(gui.PixelsPerStud, 42)
                for _, label in ipairs(gui:GetDescendants()) do
                    if label:IsA("TextLabel") then
                        label.TextScaled = true
                        label.TextWrapped = false
                        label.TextStrokeTransparency = math.max(label.TextStrokeTransparency, 0.72)
                    end
                end
            end
        end
        bikeSignFixed = true
    end

    for _, child in ipairs(bikes:GetChildren()) do
        if child:IsA("BasePart") and child.Name == "Rack" then
            child:Destroy()
            oldBikeRacksRemoved += 1
        end
    end

    if pad and pad:IsA("BasePart") then
        local racksModel = bikes:FindFirstChild("V139_URacks")
        if racksModel then
            racksModel:Destroy()
        end
        racksModel = Instance.new("Model")
        racksModel.Name = "V139_URacks"
        racksModel.Parent = bikes

        local function rackPart(name, size, localCF)
            local p = Instance.new("Part")
            p.Name = name
            p.Anchored = true
            p.Size = size
            p.CFrame = pad.CFrame * localCF
            p.Color = Color3.fromRGB(78, 84, 94)
            p.Material = Enum.Material.Metal
            p.TopSurface = Enum.SurfaceType.Smooth
            p.BottomSurface = Enum.SurfaceType.Smooth
            p.CanCollide = false
            p.CanTouch = false
            p.CanQuery = false
            p.CastShadow = true
            p.Parent = racksModel
            bikeRackPartsBuilt += 1
            return p
        end

        -- Four compact U-racks leave a clear pedestrian gap and read as bike parking at avatar scale.
        for _, localX in ipairs({-12, -4, 4, 12}) do
            rackPart("RackPostL", Vector3.new(0.28, 2.5, 0.28), CFrame.new(localX - 1.05, 1.55, 0))
            rackPart("RackPostR", Vector3.new(0.28, 2.5, 0.28), CFrame.new(localX + 1.05, 1.55, 0))
            rackPart("RackTop", Vector3.new(2.38, 0.28, 0.28), CFrame.new(localX, 2.8, 0))
        end
        racksModel:SetAttribute("ASC_V139_CompactBikeRacks", true)
    end
end

-- -----------------------------------------------------------------------------
-- C. REMOVE VISUAL-ONLY STREET CLUTTER PROVEN BY SCREENSHOTS.
-- -----------------------------------------------------------------------------
local treeGratesRemoved = 0
local streetBinsRemoved = 0
local skateBinsRemoved = 0

local premium091 = root:FindFirstChild("V091_PremiumEnvironment")
local streetPremium = premium091 and premium091:FindFirstChild("StreetPremiumFurniture")
if streetPremium then
    for _, obj in ipairs(streetPremium:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "TreeGroundGrate" then
            obj:Destroy()
            treeGratesRemoved += 1
        elseif obj:IsA("BasePart") and (string.sub(obj.Name, 1, 10) == "StreetBin_" or obj.Name == "StreetBinLid") then
            obj:Destroy()
            streetBinsRemoved += 1
        end
    end
end

local final093 = root:FindFirstChild("V093_FinalEnvironmentPolish")
local recreation = final093 and final093:FindFirstChild("RecreationFinalFurniture")
if recreation then
    for _, obj in ipairs(recreation:GetChildren()) do
        if obj:IsA("BasePart") and (
            obj.Name == "SkateWasteBin"
            or obj.Name == "SkateBinTop"
            or obj.Name == "SkateBinAccent"
        ) then
            obj:Destroy()
            skateBinsRemoved += 1
        end
    end
end

-- -----------------------------------------------------------------------------
-- D. SMALL LOOSE CYLINDER DEBRIS IN SPORTS / SKATE FOOTPRINTS.
-- Narrow heuristic: only low, small cylinder Parts, never poles/rims/trunks/wheels/known rail.
-- Imported basketball court is excluded so its approved fence/hoops remain untouched.
-- -----------------------------------------------------------------------------
local looseCylindersRemoved = 0

local function insideFootprint(part, reference, margin)
    if not reference or not reference:IsA("BasePart") then
        return false
    end
    local localPos = reference.CFrame:PointToObjectSpace(part.Position)
    margin = margin or 0
    return math.abs(localPos.X) <= reference.Size.X * 0.5 + margin
        and math.abs(localPos.Z) <= reference.Size.Z * 0.5 + margin
end

local function protectedCylinderName(name)
    local n = string.lower(name or "")
    return string.find(n, "trunk", 1, true)
        or string.find(n, "pole", 1, true)
        or string.find(n, "rim", 1, true)
        or string.find(n, "wheel", 1, true)
        or string.find(n, "lamp", 1, true)
        or n == "grindrail"
end

for _, obj in ipairs(root:GetDescendants()) do
    if obj:IsA("Part") and obj.Shape == Enum.PartType.Cylinder and not protectedCylinderName(obj.Name) then
        local maxDim = math.max(obj.Size.X, obj.Size.Y, obj.Size.Z)
        local minDim = math.min(obj.Size.X, obj.Size.Y, obj.Size.Z)
        local inActivity = insideFootprint(obj, skateGround, 5) or insideFootprint(obj, sportsGround, 5)
        local insideApprovedBasketAsset = basketLayer and obj:IsDescendantOf(basketLayer)
        local insideLandscaping = root:FindFirstChild("Landscaping") and obj:IsDescendantOf(root.Landscaping)
        local lowLoose = obj.Position.Y <= 5.5 and maxDim <= 6 and minDim <= 2.6

        if inActivity and lowLoose and not insideApprovedBasketAsset and not insideLandscaping then
            obj:Destroy()
            looseCylindersRemoved += 1
        end
    end
end

-- -----------------------------------------------------------------------------
-- E. SPORTS COLLISION SAFETY.
-- Imported court visual geometry stays visible. A flat authoritative collision plane prevents
-- avatar sinking caused by complex mesh collision while preserving the restored fence.
-- -----------------------------------------------------------------------------
local importedFloorCollisionDisabled = 0
local basketballColliderBuilt = false
local sportsGroundColliderBuilt = false
local chosenCourtSurfaceY = nil

local function makeCollider(name, size, cf)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Transparency = 1
    p.Material = Enum.Material.SmoothPlastic
    p.CanCollide = true
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = false
    p.Parent = layer
    p:SetAttribute("ASC_V139_SafetyCollider", true)
    return p
end

if sportsGround and sportsGround:IsA("BasePart") then
    sportsGround.CanCollide = true
    local top = sportsGround.Position.Y + sportsGround.Size.Y * 0.5
    local rotation = sportsGround.CFrame - sportsGround.Position
    makeCollider(
        "SportsGroundSafetyCollider",
        Vector3.new(math.max(8, sportsGround.Size.X - 2), 0.24, math.max(8, sportsGround.Size.Z - 2)),
        CFrame.new(sportsGround.Position.X, top + 0.12, sportsGround.Position.Z) * rotation
    )
    sportsGroundColliderBuilt = true
end

if court and court:IsA("BasePart") then
    court.CanCollide = true
    local nativeTop = court.Position.Y + court.Size.Y * 0.5
    local surfaceY = nativeTop + 0.08
    local bestDelta = math.huge

    if basketLayer then
        for _, obj in ipairs(basketLayer:GetDescendants()) do
            if obj:IsA("BasePart") then
                local long = math.max(obj.Size.X, obj.Size.Z)
                local short = math.min(obj.Size.X, obj.Size.Z)
                local horizontal = math.abs(obj.CFrame.UpVector.Y) >= 0.82
                local largeFloor = horizontal
                    and long >= court.Size.X * 0.48
                    and short >= court.Size.Z * 0.42
                    and obj.Size.Y <= 6

                if largeFloor then
                    local top = obj.Position.Y + obj.Size.Y * 0.5
                    local delta = math.abs(top - nativeTop)
                    if delta < bestDelta and top <= nativeTop + 8 then
                        bestDelta = delta
                        surfaceY = math.max(surfaceY, top + 0.04)
                    end
                    if obj.CanCollide then
                        obj.CanCollide = false
                        obj.CanTouch = false
                        obj:SetAttribute("ASC_V139_FlatColliderAuthority", true)
                        importedFloorCollisionDisabled += 1
                    end
                end
            end
        end
    end

    local rotation = court.CFrame - court.Position
    makeCollider(
        "BasketballSurfaceCollider",
        Vector3.new(math.max(8, court.Size.X - 3), 0.32, math.max(8, court.Size.Z - 3)),
        CFrame.new(court.Position.X, surfaceY + 0.16, court.Position.Z) * rotation
    )
    basketballColliderBuilt = true
    chosenCourtSurfaceY = surfaceY
end

-- The imported chain-link fence restored in V1.3.8 is intentionally untouched.
local restoredFencePreserved = 0
if basketLayer then
    for _, obj in ipairs(basketLayer:GetDescendants()) do
        if obj:IsA("BasePart") and obj:GetAttribute("ASC_V138_RestoredBasketFence") == true then
            restoredFencePreserved += 1
        end
    end
end

layer:SetAttribute("ASC_V139_NameplatesFixed", nameplatesFixed)
layer:SetAttribute("ASC_V139_BikeSignFixed", bikeSignFixed)
layer:SetAttribute("ASC_V139_OldBikeRacksRemoved", oldBikeRacksRemoved)
layer:SetAttribute("ASC_V139_BikeRackPartsBuilt", bikeRackPartsBuilt)
layer:SetAttribute("ASC_V139_TreeGratesRemoved", treeGratesRemoved)
layer:SetAttribute("ASC_V139_StreetBinsRemoved", streetBinsRemoved)
layer:SetAttribute("ASC_V139_SkateBinsRemoved", skateBinsRemoved)
layer:SetAttribute("ASC_V139_LooseCylindersRemoved", looseCylindersRemoved)
layer:SetAttribute("ASC_V139_ImportedFloorCollisionDisabled", importedFloorCollisionDisabled)
layer:SetAttribute("ASC_V139_BasketballColliderBuilt", basketballColliderBuilt)
layer:SetAttribute("ASC_V139_SportsGroundColliderBuilt", sportsGroundColliderBuilt)
layer:SetAttribute("ASC_V139_RestoredFencePreserved", restoredFencePreserved)
if chosenCourtSurfaceY then
    layer:SetAttribute("ASC_V139_CourtSurfaceY", chosenCourtSurfaceY)
end

root:SetAttribute("ASC_RuntimeQCCleanupV139", VERSION)
Workspace:SetAttribute("ASC_RuntimeQCCleanupV139", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V1.3.9 runtime QC cleanup complete; nameplates=%d bikeSign=%s oldRacks=%d newRackParts=%d treeGrates=%d streetBins=%d skateBins=%d looseCylinders=%d importedFloorCollisionDisabled=%d basketballCollider=%s sportsCollider=%s restoredFencePreserved=%d",
    nameplatesFixed,
    tostring(bikeSignFixed),
    oldBikeRacksRemoved,
    bikeRackPartsBuilt,
    treeGratesRemoved,
    streetBinsRemoved,
    skateBinsRemoved,
    looseCylindersRemoved,
    importedFloorCollisionDisabled,
    tostring(basketballColliderBuilt),
    tostring(sportsGroundColliderBuilt),
    restoredFencePreserved
))