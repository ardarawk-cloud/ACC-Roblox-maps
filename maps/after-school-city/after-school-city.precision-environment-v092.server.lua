-- AFTER SCHOOL CITY — Precision Environment Cleanup v0.9.2
-- Exact-map cleanup after V0.9.1: readable signage, clear sightlines,
-- normalize core-corridor vegetation, and declutter skate/park presentation.
-- No road, pool-water, gameplay, economy, persistence, monetization, music, or dedication authority.

local Workspace = game:GetService("Workspace")

local VERSION = "0.9.2-precision-environment-cleanup-2"
local NEW_PART_BUDGET = 64

local function waitForAttribute(name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if Workspace:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    warn("[ASC V092 Precision] completion attribute timeout: " .. name)
    return false
end

if not waitForAttribute("ASC_PremiumEnvironmentPass", 45) then
    return
end

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC V092 Precision] AfterSchoolCity root missing")
    return
end
if root:FindFirstChild("V092_PrecisionEnvironmentCleanup") then
    return
end

local districts = root:FindFirstChild("Districts")
local roads = root:FindFirstChild("RoadsAndPaths")
local landscaping = root:FindFirstChild("Landscaping")
local cityLife = root:FindFirstChild("V03_CityLife")
local premium060 = root:FindFirstChild("V060_PremiumExterior")
local premium091 = root:FindFirstChild("V091_PremiumEnvironment")
local poolLayer = root:FindFirstChild("V088_SwimmablePool")

if not districts or not roads or not premium091 then
    warn("[ASC V092 Precision] required district/road/V091 authority missing")
    return
end

local northSouthRoad = roads:FindFirstChild("NorthSouthRoad")
local eastWestRoad = roads:FindFirstChild("EastWestRoad")
local schoolSportsRoad = roads:FindFirstChild("SchoolSportsRoad")
if not northSouthRoad or not eastWestRoad or not schoolSportsRoad then
    warn("[ASC V092 Precision] protected road authority missing")
    return
end

local protectedRoadSnapshot = {
    NS = {Ref = northSouthRoad, CFrame = northSouthRoad.CFrame, Size = northSouthRoad.Size, Material = northSouthRoad.Material, Color = northSouthRoad.Color},
    EW = {Ref = eastWestRoad, CFrame = eastWestRoad.CFrame, Size = eastWestRoad.Size, Material = eastWestRoad.Material, Color = eastWestRoad.Color},
    SS = {Ref = schoolSportsRoad, CFrame = schoolSportsRoad.CFrame, Size = schoolSportsRoad.Size, Material = schoolSportsRoad.Material, Color = schoolSportsRoad.Color},
}

local protectedPoolSnapshot = {}
if poolLayer then
    for _, name in ipairs({"PoolWallWest", "PoolWallEast", "PoolWallNorth", "PoolWallSouth"}) do
        local wall = poolLayer:FindFirstChild(name)
        if wall and wall:IsA("BasePart") then
            protectedPoolSnapshot[name] = {Ref = wall, CFrame = wall.CFrame, Size = wall.Size, Material = wall.Material}
        end
    end
end

local layer = Instance.new("Model")
layer.Name = "V092_PrecisionEnvironmentCleanup"
layer:SetAttribute("ASC_Layer", "PRECISION_ENVIRONMENT_CLEANUP")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

local C = {
    navy = Color3.fromRGB(31, 45, 68),
    charcoal = Color3.fromRGB(48, 53, 62),
    metal = Color3.fromRGB(82, 88, 98),
    green = Color3.fromRGB(67, 111, 70),
    warmGreen = Color3.fromRGB(75, 122, 75),
    gold = Color3.fromRGB(224, 168, 70),
}

local newPartCount = 0
local compactedSigns = 0
local movedFurnitureGroups = 0
local refinedCanopies = 0

local function newVisualPart(parent, name, size, cf, color, material)
    if newPartCount >= NEW_PART_BUDGET then
        return nil
    end
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Color = color or C.charcoal
    p.Material = material or Enum.Material.Metal
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = true
    p.Parent = parent
    newPartCount += 1
    return p
end

local function normalizeSignText(plate, text, textSize)
    if not plate or not plate:IsA("BasePart") then return end
    for _, gui in ipairs(plate:GetChildren()) do
        if gui:IsA("SurfaceGui") then
            gui.AlwaysOnTop = false
            gui.LightInfluence = math.max(gui.LightInfluence, 0.35)
            gui.PixelsPerStud = math.max(gui.PixelsPerStud, 30)
            for _, child in ipairs(gui:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.Text = text or child.Text
                    child.TextScaled = false
                    child.TextWrapped = false
                    child.TextSize = textSize or 20
                    child.Font = Enum.Font.GothamBold
                    child.TextTruncate = Enum.TextTruncate.AtEnd
                end
            end
        end
    end
end

local function maximizeSignText(plate, text)
    if not plate or not plate:IsA("BasePart") then return end
    for _, gui in ipairs(plate:GetChildren()) do
        if gui:IsA("SurfaceGui") then
            gui.AlwaysOnTop = false
            gui.LightInfluence = 0.3
            gui.PixelsPerStud = math.max(gui.PixelsPerStud, 42)
            for _, child in ipairs(gui:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.Text = text or child.Text
                    child.Size = UDim2.fromScale(1, 1)
                    child.Position = UDim2.fromScale(0, 0)
                    child.TextScaled = true
                    child.TextWrapped = false
                    child.Font = Enum.Font.GothamBold
                    child.TextXAlignment = Enum.TextXAlignment.Center
                    child.TextYAlignment = Enum.TextYAlignment.Center
                    child.TextTruncate = Enum.TextTruncate.None
                end
            end
        end
    end
end

local function snapshotTransform(part)
    return part and part:IsA("BasePart") and {CFrame = part.CFrame, Size = part.Size} or nil
end

-- =========================================================
-- A. CITY PARK: keep the original V060 board scale/placement; fix text readability only.
-- Source authority: V060_PremiumExterior/V060_ParkExterior.
-- =========================================================
local parkExterior = premium060 and premium060:FindFirstChild("V060_ParkExterior")
if parkExterior then
    local sign = parkExterior:FindFirstChild("ParkEntrySign")
    local postL = parkExterior:FindFirstChild("ParkSignPostL")
    local postR = parkExterior:FindFirstChild("ParkSignPostR")
    if sign and sign:IsA("BasePart") and postL and postL:IsA("BasePart") and postR and postR:IsA("BasePart") then
        sign.Size = Vector3.new(22, 4.2, 0.55)
        sign.CFrame = CFrame.new(-70, 7.2, -145)
        sign.CanCollide = false
        sign.CanTouch = false
        sign.CanQuery = false
        postL.Size = Vector3.new(0.7, 5.5, 0.7)
        postR.Size = Vector3.new(0.7, 5.5, 0.7)
        postL.CFrame = CFrame.new(-81, 4.1, -145)
        postR.CFrame = CFrame.new(-59, 4.1, -145)
        postL.CanCollide = false
        postR.CanCollide = false
        maximizeSignText(sign, "CITY PARK")
        compactedSigns += 1
    end
end

-- =========================================================
-- B. CORE WAYFINDING: move away from tree crowns and shrink to pedestrian scale.
-- Existing V091 plates at (-62,92) and (62,166) overlap the avenue tree rhythm.
-- =========================================================
local streetPremium = premium091:FindFirstChild("StreetPremiumFurniture")
if streetPremium then
    local plates = {}
    local posts = {}
    for _, obj in ipairs(streetPremium:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name == "WayfindingPlate" then
            table.insert(plates, obj)
        elseif obj:IsA("BasePart") and obj.Name == "WayfindingPost" then
            table.insert(posts, obj)
        end
    end

    table.sort(plates, function(a, b) return a.Position.Z < b.Position.Z end)
    table.sort(posts, function(a, b) return a.Position.Z < b.Position.Z end)

    local targets = {
        {x = -78, z = 92, text = "SCHOOL ↑    CITY ↓"},
        {x = 78, z = 166, text = "PARK ←    SPORTS →"},
    }
    for i, target in ipairs(targets) do
        local plate = plates[i]
        local post = posts[i]
        if plate and post then
            plate.Size = Vector3.new(10.8, 2.2, 0.48)
            plate.CFrame = CFrame.new(target.x, 6.55, target.z)
            plate.CanCollide = false
            plate.CanTouch = false
            plate.CanQuery = false
            post.Size = Vector3.new(0.55, 4.5, 0.55)
            post.CFrame = CFrame.new(target.x, 3.45, target.z)
            post.CanCollide = false
            post.CanTouch = false
            post.CanQuery = false
            normalizeSignText(plate, target.text, 16)
            compactedSigns += 1
        end
    end
end

-- =========================================================
-- C. SKATE ENTRY: compact original 34x8 sign and clear the spectator bench from its sightline.
-- =========================================================
local skate = districts:FindFirstChild("SkatePark")
if skate then
    local skateSign = skate:FindFirstChild("SkateSign")
    if skateSign and skateSign:IsA("BasePart") then
        skateSign.Size = Vector3.new(21, 4.4, 0.72)
        skateSign.CFrame = CFrame.new(235, 8.6, 67)
        skateSign.CanCollide = false
        skateSign.CanTouch = false
        skateSign.CanQuery = false
        normalizeSignText(skateSign, "AFTER SCHOOL SKATE", 20)
        newVisualPart(layer, "SkateSignPostL", Vector3.new(0.62, 6.2, 0.62), CFrame.new(226.5, 4.45, 67), C.metal, Enum.Material.Metal)
        newVisualPart(layer, "SkateSignPostR", Vector3.new(0.62, 6.2, 0.62), CFrame.new(243.5, 4.45, 67), C.metal, Enum.Material.Metal)
        compactedSigns += 1
    end

    local skateLife = skate:FindFirstChild("V03_SkateLife")
    if skateLife then
        local moved = 0
        for _, obj in ipairs(skateLife:GetChildren()) do
            if obj:IsA("BasePart") and (obj.Name == "BenchSeat" or obj.Name == "BenchBack" or obj.Name == "BenchLegL" or obj.Name == "BenchLegR") then
                if math.abs(obj.Position.X - 235) < 8 and math.abs(obj.Position.Z - 58) < 8 then
                    obj.CFrame = obj.CFrame + Vector3.new(-32, 0, -3)
                    moved += 1
                end
            end
        end
        if moved > 0 then
            movedFurnitureGroups += 1
        end
    end
end

-- =========================================================
-- D. CORE CORRIDOR VEGETATION: break repeated spherical silhouette without increasing collision.
-- Keep legacy crown as center mass, shrink it slightly, then add two lightweight lobes.
-- =========================================================
local corridor = cityLife and cityLife:FindFirstChild("SchoolDowntownCorridor")
if corridor then
    local crownIndex = 0
    for _, crown in ipairs(corridor:GetChildren()) do
        if crown:IsA("BasePart") and crown.Name == "TreeCrown" then
            crownIndex += 1
            local originalSize = crown.Size
            local center = crown.Position
            crown.Size = Vector3.new(originalSize.X * 0.78, originalSize.Y * 0.88, originalSize.Z * 0.78)
            crown.CanCollide = false
            crown.CanTouch = false
            crown.CanQuery = false
            crown.Material = Enum.Material.Grass

            local sx = math.max(3.2, originalSize.X * 0.58)
            local sy = math.max(3.4, originalSize.Y * 0.62)
            local sz = math.max(3.2, originalSize.Z * 0.58)
            local direction = crownIndex % 2 == 0 and 1 or -1
            local lobeA = newVisualPart(layer, "CoreCanopyLobeA", Vector3.new(sx, sy, sz), CFrame.new(center + Vector3.new(direction * originalSize.X * 0.28, originalSize.Y * 0.03, originalSize.Z * 0.10)), crown.Color, Enum.Material.Grass)
            local lobeB = newVisualPart(layer, "CoreCanopyLobeB", Vector3.new(sx * 0.86, sy * 0.88, sz * 0.86), CFrame.new(center + Vector3.new(-direction * originalSize.X * 0.24, originalSize.Y * 0.12, -originalSize.Z * 0.16)), crown.Color:Lerp(C.warmGreen, 0.18), Enum.Material.Grass)
            if lobeA then lobeA.Shape = Enum.PartType.Ball end
            if lobeB then lobeB.Shape = Enum.PartType.Ball end
            refinedCanopies += 1
        end
    end
end

-- =========================================================
-- E. TARGET SIGN AUDIT: Park retains original scale; pedestrian/skate signs stay normalized.
-- =========================================================
local oversizedTargetSigns = 0
local function auditSign(part, maxWidth, maxHeight)
    if part and part:IsA("BasePart") and (part.Size.X > maxWidth or part.Size.Y > maxHeight) then
        oversizedTargetSigns += 1
    end
end
if parkExterior then auditSign(parkExterior:FindFirstChild("ParkEntrySign"), 22.5, 4.5) end
if streetPremium then
    for _, obj in ipairs(streetPremium:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name == "WayfindingPlate" then auditSign(obj, 11, 2.5) end
    end
end
if skate then auditSign(skate:FindFirstChild("SkateSign"), 22, 5) end

local roadsUnchanged = true
for _, snapshot in pairs(protectedRoadSnapshot) do
    local p = snapshot.Ref
    if p.CFrame ~= snapshot.CFrame or p.Size ~= snapshot.Size or p.Material ~= snapshot.Material or p.Color ~= snapshot.Color then
        roadsUnchanged = false
        break
    end
end

local poolUnchanged = true
for _, snapshot in pairs(protectedPoolSnapshot) do
    local p = snapshot.Ref
    if p.CFrame ~= snapshot.CFrame or p.Size ~= snapshot.Size or p.Material ~= snapshot.Material then
        poolUnchanged = false
        break
    end
end

if oversizedTargetSigns > 0 or not roadsUnchanged or not poolUnchanged then
    layer:SetAttribute("ASC_V092Pass", false)
    layer:SetAttribute("ASC_V092OversizedTargetSigns", oversizedTargetSigns)
    layer:SetAttribute("ASC_V092RoadsUnchanged", roadsUnchanged)
    layer:SetAttribute("ASC_V092PoolUnchanged", poolUnchanged)
    warn(string.format("[ASC V092 Precision] HARD LOCK FAILED oversizedSigns=%d roads=%s pool=%s", oversizedTargetSigns, tostring(roadsUnchanged), tostring(poolUnchanged)))
    return
end

layer:SetAttribute("ASC_V092Pass", true)
layer:SetAttribute("ASC_V092RoadsUnchanged", true)
layer:SetAttribute("ASC_V092PoolUnchanged", true)
layer:SetAttribute("ASC_V092OversizedTargetSigns", 0)
layer:SetAttribute("ASC_V092CompactedSigns", compactedSigns)
layer:SetAttribute("ASC_V092MovedFurnitureGroups", movedFurnitureGroups)
layer:SetAttribute("ASC_V092RefinedCanopies", refinedCanopies)
layer:SetAttribute("ASC_V092NewPartCount", newPartCount)
layer:SetAttribute("ASC_V092CityParkTextScaled", true)
root:SetAttribute("ASC_PrecisionEnvironmentV092", true)
Workspace:SetAttribute("ASC_PrecisionEnvironmentPass", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V0.9.2 precision environment initialized; signs=%d furnitureGroups=%d canopies=%d newParts=%d oversized=0 cityParkTextScaled=true",
    compactedSigns,
    movedFurnitureGroups,
    refinedCanopies,
    newPartCount
))
