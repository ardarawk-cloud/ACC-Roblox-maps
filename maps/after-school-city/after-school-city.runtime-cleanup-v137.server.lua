-- AFTER SCHOOL CITY — V1.3.7 Runtime Cleanup Batch
-- Runtime screenshot fixes only:
-- 1) remove duplicate native basketball hoops after the approved imported court is ready,
-- 2) open usable/visible sideline entrances through imported basketball fencing,
-- 3) remove malformed loose imported skate rail pieces,
-- 4) rebuild Student Tote as a recognizable open tote while preserving its live purchase prompt.
-- No gameplay, economy prices, inventory/data authority, music, dedication, quests, or monetization changes.

local Workspace = game:GetService("Workspace")

local VERSION = "1.3.7-runtime-cleanup-batch-1"

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
    warn("[ASC V137] AfterSchoolCity root missing")
    return
end

if root:GetAttribute("ASC_RuntimeCleanupV137") == VERSION then
    return
end

local districts = root:FindFirstChild("Districts")
local sports = districts and districts:FindFirstChild("SportsField")
local court = sports and sports:FindFirstChild("BasketballCourt")

-- SPORTS BATCH ---------------------------------------------------------------
-- V136 owns the approved external skateboard + basketball assets. Wait for it,
-- then clean only the runtime defects proven by screenshots.
waitUntil(function()
    return root:GetAttribute("ASC_SportsAssetsV136") ~= nil
end, 60)

local sportsLayer = root:FindFirstChild("V136_SportsAssets")
local skateLayer = sportsLayer and sportsLayer:FindFirstChild("SkateparkImportedProps")
local basketLayer = sportsLayer and sportsLayer:FindFirstChild("BasketballImportedCourt")

local removedSkateLooseParts = 0
if skateLayer then
    -- Existing native grind rails already serve this function. The imported rail
    -- extraction is a single loose BasePart and reads as an unexplained cylinder/bar.
    for _, name in ipairs({"ImportedStraightRail", "ImportedCurvedRail"}) do
        local prop = skateLayer:FindFirstChild(name, true)
        if prop then
            prop:Destroy()
            removedSkateLooseParts += 1
        end
    end
end

local removedNativeHoops = 0
local basketballReady = root:GetAttribute("ASC_BasketballExternalAssetEnabled") == true
if basketballReady and sports and basketLayer then
    -- The imported court already contains its own regulation pair. Remove only the
    -- two legacy direct-child hoop models so one court does not render four hoops.
    for _, child in ipairs(sports:GetChildren()) do
        if child:IsA("Model") and child.Name == "BasketballHoop" then
            child:Destroy()
            removedNativeHoops += 1
        end
    end
end

local gatePartsHidden = 0
local gatePartsNoCollision = 0
if basketballReady and basketLayer and court and court:IsA("BasePart") then
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = {basketLayer}
    params.RespectCanCollide = false

    local courtTop = court.Position.Y + court.Size.Y * 0.5
    local gateWidth = math.clamp(court.Size.X * 0.18, 16, 22)
    local gateDepth = 9
    local gateHeight = 10
    local processed = {}

    for _, side in ipairs({-1, 1}) do
        local localZ = side * (court.Size.Z * 0.5)
        local gateCF = court.CFrame * CFrame.new(0, (courtTop - court.Position.Y) + gateHeight * 0.5, localZ)
        local hits = Workspace:GetPartBoundsInBox(gateCF, Vector3.new(gateWidth, gateHeight, gateDepth), params)

        for _, hit in ipairs(hits) do
            if hit:IsA("BasePart") and not processed[hit] then
                processed[hit] = true

                -- Every imported piece crossing the entrance must be physically passable.
                if hit.CanCollide then
                    hit.CanCollide = false
                    gatePartsNoCollision += 1
                end
                hit.CanTouch = false

                -- Visually remove only fence/bar/post-like pieces whose own center is
                -- actually on the sideline gate. A giant all-in-one court mesh is not
                -- hidden, preventing accidental disappearance of the whole court asset.
                local localPos = court.CFrame:PointToObjectSpace(hit.Position)
                local centerAtSideline = math.abs(localPos.Z) >= court.Size.Z * 0.34
                local centerAtGate = math.abs(localPos.X) <= gateWidth * 0.72
                local verticalOrBarrier = hit.Size.Y >= 1.35
                local wholeCourtSized = hit.Size.X >= court.Size.X * 0.70 and hit.Size.Z >= court.Size.Z * 0.70

                if centerAtSideline and centerAtGate and verticalOrBarrier and not wholeCourtSized then
                    hit.Transparency = 1
                    hit.CanQuery = false
                    hit:SetAttribute("ASC_V137_GatePieceHidden", true)
                    gatePartsHidden += 1
                else
                    hit:SetAttribute("ASC_V137_GatePassable", true)
                end
            end
        end
    end
end

-- MINI MART TOTE --------------------------------------------------------------
-- Replace only the physical STUDENT_TOTE model. Keep the exact ProximityPrompt
-- instance so its existing Triggered connection remains authoritative.
local toteRebuilt = false
local economyLayer = waitUntil(function()
    return root:FindFirstChild("V130_EconomyFirstShop", true)
end, 60)

if economyLayer then
    local toteModel = economyLayer:FindFirstChild("Display_STUDENT_TOTE")
    local oldBody = toteModel and toteModel:FindFirstChild("BagBody")
    local prompt = toteModel and toteModel:FindFirstChild("Buy_STUDENT_TOTE", true)

    if toteModel and oldBody and oldBody:IsA("BasePart") and prompt and prompt:IsA("ProximityPrompt") then
        local bodyCF = oldBody.CFrame
        local bodyAttributes = oldBody:GetAttributes()
        local fabric = oldBody.Color
        local handleColor = Color3.fromRGB(93, 72, 116)
        local gold = Color3.fromRGB(225, 170, 73)
        local inside = Color3.fromRGB(35, 29, 43)

        -- Detaching the same prompt preserves its connected purchase callback.
        prompt.Parent = nil
        for _, child in ipairs(toteModel:GetChildren()) do
            child:Destroy()
        end

        local function makePart(name, size, offsetCF, color, material)
            local part = Instance.new("Part")
            part.Name = name
            part.Size = size
            part.CFrame = bodyCF * offsetCF
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            part.CastShadow = true
            part.TopSurface = Enum.SurfaceType.Smooth
            part.BottomSurface = Enum.SurfaceType.Smooth
            part.Color = color
            part.Material = material or Enum.Material.Fabric
            part.Parent = toteModel
            return part
        end

        -- Open tote shell: front/back faces + gussets + bottom + dark visible opening.
        local front = makePart("ToteFront", Vector3.new(1.78, 1.28, 0.12), CFrame.new(0, 0, 0.34), fabric, Enum.Material.Fabric)
        makePart("ToteBack", Vector3.new(1.78, 1.28, 0.12), CFrame.new(0, 0, -0.34), fabric, Enum.Material.Fabric)
        makePart("ToteSideL", Vector3.new(0.12, 1.20, 0.58), CFrame.new(-0.83, -0.03, 0), fabric, Enum.Material.Fabric)
        makePart("ToteSideR", Vector3.new(0.12, 1.20, 0.58), CFrame.new(0.83, -0.03, 0), fabric, Enum.Material.Fabric)
        makePart("ToteBottom", Vector3.new(1.72, 0.12, 0.64), CFrame.new(0, -0.59, 0), handleColor, Enum.Material.Fabric)
        makePart("ToteOpening", Vector3.new(1.54, 0.055, 0.48), CFrame.new(0, 0.65, 0), inside, Enum.Material.SmoothPlastic)

        -- Two complete U-shaped handles, one on each face, make the silhouette read as a bag.
        for _, z in ipairs({-0.40, 0.40}) do
            local suffix = z < 0 and "Back" or "Front"
            makePart("Handle" .. suffix .. "L", Vector3.new(0.12, 0.82, 0.12), CFrame.new(-0.51, 0.91, z), handleColor, Enum.Material.Fabric)
            makePart("Handle" .. suffix .. "R", Vector3.new(0.12, 0.82, 0.12), CFrame.new(0.51, 0.91, z), handleColor, Enum.Material.Fabric)
            makePart("Handle" .. suffix .. "Top", Vector3.new(1.14, 0.12, 0.12), CFrame.new(0, 1.28, z), handleColor, Enum.Material.Fabric)
        end

        -- Small physical front badge; no replacement of pricing/purchase UI.
        makePart("ASC_Badge", Vector3.new(0.56, 0.28, 0.055), CFrame.new(0, 0.05, 0.43), gold, Enum.Material.SmoothPlastic)

        for key, value in pairs(bodyAttributes) do
            front:SetAttribute(key, value)
        end
        front:SetAttribute("ASC_ShapedProductDisplay", true)
        front:SetAttribute("ASC_V137_ToteRebuilt", true)
        front.CanQuery = true
        prompt.Parent = front
        toteModel:SetAttribute("ASC_V137_RecognizableTote", true)
        toteRebuilt = true
    end
end

root:SetAttribute("ASC_RuntimeCleanupV137", VERSION)
root:SetAttribute("ASC_V137_RemovedNativeBasketballHoops", removedNativeHoops)
root:SetAttribute("ASC_V137_BasketGateHiddenPieces", gatePartsHidden)
root:SetAttribute("ASC_V137_BasketGatePassablePieces", gatePartsNoCollision)
root:SetAttribute("ASC_V137_RemovedLooseSkateParts", removedSkateLooseParts)
root:SetAttribute("ASC_V137_ToteRebuilt", toteRebuilt)
Workspace:SetAttribute("ASC_RuntimeCleanupV137", VERSION)

print(string.format(
    "[AFTER SCHOOL CITY] V1.3.7 runtime cleanup complete; nativeHoopsRemoved=%d gateHidden=%d gateNoCollision=%d looseSkateRemoved=%d toteRebuilt=%s",
    removedNativeHoops,
    gatePartsHidden,
    gatePartsNoCollision,
    removedSkateLooseParts,
    tostring(toteRebuilt)
))
