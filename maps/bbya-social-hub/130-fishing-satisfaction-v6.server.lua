-- BBYA SOCIAL HUB — FISHING SATISFACTION v6 SERVER
-- Focus: rod feel/presentation, post-V5 fish anatomy polish, and strict gate-side rod authority.
-- No fish chance/probability, progression, economy, audio, role, club, mall, or global Lighting math is changed here.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 35)
if not root then return end
local district = root:WaitForChild("PremiumFishingDistrictV2", 35)
if not district then return end

task.wait(2.3)

district:SetAttribute("FishingSatisfactionPass", "V6")
district:SetAttribute("FishAnatomyPolishV6", true)
district:SetAttribute("RodPremiumDetailV6", true)
district:SetAttribute("GateSideRodAuthorityV6", true)
district:SetAttribute("ChanceMathUntouchedV6", true)

local GATE_Z = 687.5
local MARKET_SIDE_Z = 684.5
local LAKE_CENTER = Vector3.new(
    district:GetAttribute("LakeCenterX") or 0,
    0,
    district:GetAttribute("LakeCenterZ") or 790
)
local DISTRICT_RADIUS = 225
local DISTRICT_RADIUS_SQ = DISTRICT_RADIUS * DISTRICT_RADIUS

local function inLakeSide(player)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    if hrp.Position.Z < GATE_Z then return false end
    local dx = hrp.Position.X - LAKE_CENTER.X
    local dz = hrp.Position.Z - LAKE_CENTER.Z
    return dx * dx + dz * dz <= DISTRICT_RADIUS_SQ
end

local function isFishingRod(item)
    return item and item:IsA("Tool") and item:GetAttribute("BBYAFishingRod") == true
end

local function clearRod(container)
    if not container then return end
    for _, item in ipairs(container:GetChildren()) do
        if isFishingRod(item) then item:Destroy() end
    end
end

local function weldTo(handle, part)
    part.Anchored = false
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Massless = true
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = handle
    weld.Part1 = part
    weld.Parent = part
end

local function rodPart(folder, handle, name, size, localCF, color, material, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = handle.CFrame * localCF
    p.Color = color
    p.Material = material or Enum.Material.Metal
    p.Shape = shape or Enum.PartType.Block
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.CastShadow = true
    p:SetAttribute("RodDetailV6", true)
    p.Parent = folder
    weldTo(handle, p)
    return p
end

local function rodWedge(folder, handle, name, size, localCF, color, material)
    local p = Instance.new("WedgePart")
    p.Name = name
    p.Size = size
    p.CFrame = handle.CFrame * localCF
    p.Color = color
    p.Material = material or Enum.Material.Metal
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.CastShadow = true
    p:SetAttribute("RodDetailV6", true)
    p.Parent = folder
    weldTo(handle, p)
    return p
end

local function polishRod(tool)
    if not isFishingRod(tool) then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle or not handle:IsA("BasePart") then return end

    local old = tool:FindFirstChild("RodPremiumV6")
    if old then old:Destroy() end

    local folder = Instance.new("Folder")
    folder.Name = "RodPremiumV6"
    folder.Parent = tool

    local tip = tool:FindFirstChild("TipSegment")
    local reel = tool:FindFirstChild("ReelSpool")
    local body = tool:FindFirstChild("RodSegment1")
    local accent = (tip and tip:IsA("BasePart")) and tip.Color or Color3.fromRGB(226, 188, 95)
    local bodyColor = (body and body:IsA("BasePart")) and body.Color or Color3.fromRGB(38, 42, 48)
    local rarity = tostring(tool:GetAttribute("RodSkinRarity") or "COMMON")

    -- Keep the V5 corrected direction but refine wrist offset so the reel sits beside the hand,
    -- not inside the avatar torso. Geometry still points in the corrected direction.
    tool.Grip = CFrame.new(0.12, -0.58, -0.10)
        * CFrame.Angles(math.rad(-5), math.rad(8), math.rad(248))
    tool:SetAttribute("PremiumGripRefinedV6", true)

    -- Layered grip wraps make the handle read as a real rod handle instead of one cylinder.
    for i = 1, 6 do
        local x = -0.95 + (i - 1) * 0.31
        rodPart(
            folder, handle, "GripWrap" .. i,
            Vector3.new(0.11, 0.42, 0.42),
            CFrame.new(x, 0, 0),
            i % 2 == 0 and Color3.fromRGB(48, 42, 39) or Color3.fromRGB(29, 27, 28),
            Enum.Material.Fabric,
            Enum.PartType.Cylinder
        )
    end

    -- Butt cap and metal collar visually anchor the rod in the player's hand.
    rodPart(folder, handle, "ButtCap", Vector3.new(0.34, 0.48, 0.48), CFrame.new(-1.34, 0, 0), accent, Enum.Material.Metal, Enum.PartType.Cylinder)
    rodPart(folder, handle, "GripCollar", Vector3.new(0.18, 0.46, 0.46), CFrame.new(1.28, 0, 0), accent, Enum.Material.Metal, Enum.PartType.Cylinder)

    -- Reel face + crank detail. It intentionally overlays the core reel rather than replacing it,
    -- so the stable fishing tool behavior remains untouched.
    rodPart(folder, handle, "ReelFace", Vector3.new(0.16, 1.10, 1.10), CFrame.new(0.34, -0.49, 0), accent, Enum.Material.Metal, Enum.PartType.Cylinder)
    rodPart(folder, handle, "ReelHub", Vector3.new(0.24, 0.46, 0.46), CFrame.new(0.34, -0.49, 0), bodyColor, Enum.Material.Metal, Enum.PartType.Cylinder)
    rodPart(folder, handle, "CrankStem", Vector3.new(0.72, 0.10, 0.10), CFrame.new(-0.04, -0.95, 0) * CFrame.Angles(0, 0, math.rad(28)), accent, Enum.Material.Metal, Enum.PartType.Cylinder)
    rodPart(folder, handle, "CrankKnob", Vector3.new(0.30, 0.30, 0.30), CFrame.new(-0.33, -1.22, 0), Color3.fromRGB(35, 31, 30), Enum.Material.SmoothPlastic, Enum.PartType.Ball)

    -- Slim guide feet/eyelets create the silhouette expected from a proper fishing rod.
    for i, x in ipairs({2.15, 3.45, 4.85, 6.15, 7.42}) do
        local height = 0.28 - (i - 1) * 0.025
        rodPart(folder, handle, "GuideFoot" .. i, Vector3.new(0.08, height, 0.08), CFrame.new(x, height * 0.46, 0), accent, Enum.Material.Metal, Enum.PartType.Cylinder)
        rodPart(folder, handle, "GuideEye" .. i, Vector3.new(0.09, 0.23, 0.23), CFrame.new(x, height + 0.10, 0), accent, Enum.Material.Metal, Enum.PartType.Ball)
    end

    -- High-tier skins receive geometry, not just glow/recolor.
    if rarity == "EPIC" or rarity == "LEGENDARY" or rarity == "MYTHIC" then
        rodWedge(folder, handle, "ReelGuardL", Vector3.new(0.55, 0.16, 0.46), CFrame.new(0.10, -0.43, 0.52) * CFrame.Angles(0, math.rad(180), math.rad(8)), accent, Enum.Material.Metal)
        rodWedge(folder, handle, "ReelGuardR", Vector3.new(0.55, 0.16, 0.46), CFrame.new(0.10, -0.43, -0.52) * CFrame.Angles(math.rad(180), 0, math.rad(-8)), accent, Enum.Material.Metal)
    end
    if rarity == "LEGENDARY" or rarity == "MYTHIC" then
        for i, x in ipairs({5.6, 6.55, 7.35}) do
            local gem = rodPart(folder, handle, "SignatureGem" .. i, Vector3.new(0.18, 0.18, 0.18), CFrame.new(x, 0.23, 0), accent, Enum.Material.Neon, Enum.PartType.Ball)
            local light = Instance.new("PointLight")
            light.Color = accent
            light.Brightness = rarity == "MYTHIC" and 0.28 or 0.18
            light.Range = rarity == "MYTHIC" and 3.6 or 2.7
            light.Shadows = false
            light.Parent = gem
        end
    end

    tool:SetAttribute("RodPremiumDetailV6", true)
end

local function polishRodsIn(container)
    if not container then return end
    for _, item in ipairs(container:GetChildren()) do
        if isFishingRod(item) then polishRod(item) end
    end
end

-- =============================================================================
-- FISH ANATOMY V6 — POST-PROCESS THE V5 SPECIES ART
-- =============================================================================
local function fishPart(model, name, size, localCF, color, material, shape)
    if not model.PrimaryPart then return nil end
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = model.PrimaryPart.CFrame * localCF
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Shape = shape or Enum.PartType.Block
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p:SetAttribute("FishAnatomyV6", true)
    p.Parent = model
    return p
end

local function fishWedge(model, name, size, localCF, color, material)
    if not model.PrimaryPart then return nil end
    local p = Instance.new("WedgePart")
    p.Name = name
    p.Size = size
    p.CFrame = model.PrimaryPart.CFrame * localCF
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p:SetAttribute("FishAnatomyV6", true)
    p.Parent = model
    return p
end

local function getScale(model)
    local body = model:FindFirstChild("Body", true)
    if body and body:IsA("BasePart") then
        return math.clamp(body.Size.X / 5.2, 0.72, 2.35)
    end
    return 1
end

local function palette(model)
    local body = model:FindFirstChild("Body", true)
    local accentPart = model:FindFirstChild("Dorsal", true)
        or model:FindFirstChild("TailUpper", true)
        or model:FindFirstChild("TailTop", true)
    local base = body and body:IsA("BasePart") and body.Color or Color3.fromRGB(120, 145, 155)
    local accent = accentPart and accentPart:IsA("BasePart") and accentPart.Color or Color3.fromRGB(213, 191, 112)
    return base, accent
end

local function scaleDisc(model, x, y, z, s, color, neon)
    local p = fishPart(
        model, "ScalePlateV6",
        Vector3.new(0.42, 0.30, 0.09) * s,
        CFrame.new(x * s, y * s, z * s),
        color,
        neon and Enum.Material.Neon or Enum.Material.SmoothPlastic,
        Enum.PartType.Ball
    )
    if p then p.Transparency = neon and 0.08 or 0.02 end
end

local function addScaleRows(model, s, color, rows, columns, startX, stepX, z)
    for row = 1, rows do
        local yy = (row - (rows + 1) / 2) * 0.36
        local offset = row % 2 == 0 and 0.18 or 0
        for col = 1, columns do
            scaleDisc(model, startX - (col - 1) * stepX + offset, yy, z, s, color, false)
        end
    end
end

local function addBarbel(model, name, x, y, z, length, yaw, accent, s)
    fishPart(
        model, name,
        Vector3.new(length, 0.055, 0.055) * s,
        CFrame.new(x * s, y * s, z * s) * CFrame.Angles(0, math.rad(yaw), math.rad(4)),
        accent,
        Enum.Material.SmoothPlastic,
        Enum.PartType.Cylinder
    )
end

local function addGenericFinish(model, s, base, accent)
    -- Narrow caudal peduncle between body and tail removes the "ball + triangle" look.
    fishPart(model, "CaudalPeduncleV6", Vector3.new(1.15, 1.05, 1.05) * s, CFrame.new(-2.55 * s, 0, 0), base, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    -- Soft belly/shoulder volumes create a less toy-like silhouette.
    local belly = fishPart(model, "BellyVolumeV6", Vector3.new(3.7, 1.0, 1.62) * s, CFrame.new(-0.10 * s, -0.48 * s, 0), base, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    if belly then belly.Color = base:Lerp(Color3.fromRGB(235, 239, 238), 0.16) end
    fishWedge(model, "PelvicFinLV6", Vector3.new(1.05, 0.18, 0.78) * s, CFrame.new(0.15 * s, -0.72 * s, 0.73 * s) * CFrame.Angles(math.rad(-28), 0, math.rad(15)), accent)
    fishWedge(model, "PelvicFinRV6", Vector3.new(1.05, 0.18, 0.78) * s, CFrame.new(0.15 * s, -0.72 * s, -0.73 * s) * CFrame.Angles(math.rad(208), 0, math.rad(-15)), accent)
end

local function addKoiFinish(model, s, base, accent, celestial)
    addGenericFinish(model, s, base, accent)
    addBarbel(model, "KoiBarbelLV6", 2.45, -0.12, 0.34, 1.05, 16, accent, s)
    addBarbel(model, "KoiBarbelRV6", 2.45, -0.12, -0.34, 1.05, -16, accent, s)
    fishWedge(model, "FlowFinLV6", Vector3.new(1.55, 0.18, 1.18) * s, CFrame.new(0.75 * s, -0.12 * s, 0.98 * s) * CFrame.Angles(math.rad(-30), 0, math.rad(9)), accent, celestial and Enum.Material.Neon or Enum.Material.SmoothPlastic)
    fishWedge(model, "FlowFinRV6", Vector3.new(1.55, 0.18, 1.18) * s, CFrame.new(0.75 * s, -0.12 * s, -0.98 * s) * CFrame.Angles(math.rad(210), 0, math.rad(-9)), accent, celestial and Enum.Material.Neon or Enum.Material.SmoothPlastic)
    if celestial then
        for i, x in ipairs({1.45, 0.35, -0.80}) do
            local pearl = fishPart(model, "CelestialPearlV6_" .. i, Vector3.new(0.26, 0.26, 0.26) * s, CFrame.new(x * s, 1.10 * s, 0), accent, Enum.Material.Neon, Enum.PartType.Ball)
            if pearl then
                local l = Instance.new("PointLight")
                l.Color = accent;l.Brightness = 0.24;l.Range = 2.6;l.Shadows = false;l.Parent = pearl
            end
        end
    end
end

local function addGouramiFinish(model, s, base, accent)
    addGenericFinish(model, s, base, accent)
    addBarbel(model, "GouramiFeelerLV6", 0.65, -0.78, 0.55, 2.15, 8, accent, s)
    addBarbel(model, "GouramiFeelerRV6", 0.65, -0.78, -0.55, 2.15, -8, accent, s)
    fishWedge(model, "LongAnalFinV6", Vector3.new(2.8, 0.48, 0.22) * s, CFrame.new(-0.35 * s, -1.12 * s, 0) * CFrame.Angles(math.rad(180), math.rad(90), 0), accent)
end

local function addBassFinish(model, s, base, accent)
    addGenericFinish(model, s, base, accent)
    fishPart(model, "BassJawV6", Vector3.new(0.62, 0.48, 0.92) * s, CFrame.new(2.75 * s, -0.28 * s, 0), base:Lerp(Color3.new(0,0,0),0.2), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    for i, x in ipairs({1.15, 0.1, -0.95}) do
        fishPart(model, "BassSpotV6_" .. i, Vector3.new(0.48, 0.48, 0.12) * s, CFrame.new(x * s, 0.12 * s, 0.93 * s), Color3.fromRGB(36, 56, 40), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    end
end

local function addCatfishFinish(model, s, base, accent)
    addGenericFinish(model, s, base, accent)
    addBarbel(model, "CatBarbelLongLV6", 2.30, -0.18, 0.62, 2.40, 22, accent, s)
    addBarbel(model, "CatBarbelLongRV6", 2.30, -0.18, -0.62, 2.40, -22, accent, s)
    addBarbel(model, "CatBarbelShortLV6", 2.18, -0.34, 0.34, 1.35, 36, accent, s)
    addBarbel(model, "CatBarbelShortRV6", 2.18, -0.34, -0.34, 1.35, -36, accent, s)
    fishWedge(model, "AdiposeFinV6", Vector3.new(0.85, 0.52, 0.24) * s, CFrame.new(-1.55 * s, 0.92 * s, 0) * CFrame.Angles(0, math.rad(90), 0), accent)
end

local function addBarraFinish(model, s, base, accent)
    addGenericFinish(model, s, base, accent)
    fishPart(model, "SilverShoulderV6", Vector3.new(0.40, 1.45, 1.58) * s, CFrame.new(1.72 * s, 0.02 * s, 0), accent, Enum.Material.Metal, Enum.PartType.Ball)
    for i = 1, 6 do
        fishPart(model, "LateralLineV6_" .. i, Vector3.new(0.48, 0.10, 0.10) * s, CFrame.new((1.15 - i * 0.58) * s, 0.08 * s, 0.92 * s), accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    end
end

local function addArowanaFinish(model, s, base, accent, arapaima)
    addGenericFinish(model, s, base, accent)
    addBarbel(model, "ArowanaBarbelLV6", 3.10, -0.05, 0.22, 1.05, 8, accent, s)
    addBarbel(model, "ArowanaBarbelRV6", 3.10, -0.05, -0.22, 1.05, -8, accent, s)
    addScaleRows(model, s, arapaima and accent or base:Lerp(accent, 0.45), arapaima and 3 or 2, arapaima and 7 or 6, 1.55, 0.58, 0.94)
    if arapaima then
        addScaleRows(model, s, Color3.fromRGB(184, 78, 76), 2, 6, 1.10, 0.63, -0.94)
        fishWedge(model, "ArapaimaTailEdgeV6", Vector3.new(1.25, 1.25, 0.18) * s, CFrame.new(-3.85 * s, 0.18 * s, 0) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(199, 75, 78))
    end
end

local function addRayFinish(model, s, base, accent)
    -- Ray gets no generic fish belly; broaden the wing silhouette and make the head/tail intentional.
    fishPart(model, "RayHeadV6", Vector3.new(1.75, 0.68, 1.95) * s, CFrame.new(1.75 * s, 0.05 * s, 0), base, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    fishWedge(model, "RayWingEdgeLV6", Vector3.new(3.0, 0.28, 1.85) * s, CFrame.new(-0.20 * s, -0.05 * s, 2.60 * s) * CFrame.Angles(0, math.rad(180), 0), accent)
    fishWedge(model, "RayWingEdgeRV6", Vector3.new(3.0, 0.28, 1.85) * s, CFrame.new(-0.20 * s, -0.05 * s, -2.60 * s), accent)
    fishPart(model, "RayEyeLV6", Vector3.new(0.24, 0.24, 0.24) * s, CFrame.new(1.35 * s, 0.38 * s, 0.72 * s), Color3.fromRGB(7,8,10), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    fishPart(model, "RayEyeRV6", Vector3.new(0.24, 0.24, 0.24) * s, CFrame.new(1.35 * s, 0.38 * s, -0.72 * s), Color3.fromRGB(7,8,10), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    fishPart(model, "RayStingerV6", Vector3.new(3.8, 0.08, 0.08) * s, CFrame.new(-4.0 * s, 0, 0), accent, Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
end

local function addMahseerFinish(model, s, base, accent)
    addGenericFinish(model, s, base, accent)
    addScaleRows(model, s, accent:Lerp(Color3.fromRGB(255, 232, 150), 0.35), 3, 6, 1.35, 0.57, 0.90)
    fishPart(model, "GoldGillV6", Vector3.new(0.34, 1.35, 1.58) * s, CFrame.new(1.68 * s, 0.02 * s, 0), accent, Enum.Material.Metal, Enum.PartType.Ball)
end

local function addLeviathanFinish(model, s, base, accent)
    fishPart(model, "LeviathanNeckV6", Vector3.new(2.2, 1.55, 1.55) * s, CFrame.new(1.7 * s, 0, 0), base, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    fishPart(model, "LeviathanJawV6", Vector3.new(1.75, 0.62, 1.62) * s, CFrame.new(3.35 * s, -0.45 * s, 0), Color3.fromRGB(24,18,38), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    for i, z in ipairs({-0.58, -0.20, 0.20, 0.58}) do
        fishWedge(model, "LeviathanToothV6_" .. i, Vector3.new(0.34, 0.54, 0.16) * s, CFrame.new(4.02 * s, -0.22 * s, z * s) * CFrame.Angles(0, math.rad(90), math.rad(180)), Color3.fromRGB(235, 232, 218), Enum.Material.SmoothPlastic)
    end
    for i, x in ipairs({1.25, 0.35, -0.65, -1.65}) do
        fishWedge(model, "LeviathanCrownSpineV6_" .. i, Vector3.new(0.82, 1.25 + i * 0.12, 0.26) * s, CFrame.new(x * s, 1.12 * s, 0) * CFrame.Angles(0, math.rad(90), 0), accent, Enum.Material.Neon)
    end
    fishPart(model, "LeviathanEyeLV6", Vector3.new(0.36,0.36,0.28) * s, CFrame.new(2.75*s,0.34*s,0.72*s), accent, Enum.Material.Neon, Enum.PartType.Ball)
    fishPart(model, "LeviathanEyeRV6", Vector3.new(0.36,0.36,0.28) * s, CFrame.new(2.75*s,0.34*s,-0.72*s), accent, Enum.Material.Neon, Enum.PartType.Ball)
end

local function decorateCatch(model)
    if not model:IsA("Model") or not string.find(model.Name, "^Catch_") or model:GetAttribute("FishAnatomyV6") then return end
    task.spawn(function()
        local deadline = os.clock() + 1.25
        while model.Parent and os.clock() < deadline do
            if model.PrimaryPart and model:GetAttribute("FishVisualV5") == true then break end
            task.wait(0.035)
        end
        if not model.Parent or not model.PrimaryPart or model:GetAttribute("FishVisualV5") ~= true then return end

        local fishName = model:GetAttribute("FishName")
        if type(fishName) ~= "string" then return end
        local s = getScale(model)
        local base, accent = palette(model)

        if fishName == "Royal Koi" then
            addKoiFinish(model, s, base, accent, false)
        elseif fishName == "Celestial Koi" then
            addKoiFinish(model, s, base, accent, true)
        elseif fishName == "Azure Gourami" then
            addGouramiFinish(model, s, base, accent)
        elseif fishName == "Jade Peacock Bass" then
            addBassFinish(model, s, base, accent)
        elseif fishName == "Redtail Giant" then
            addCatfishFinish(model, s, base, accent)
        elseif fishName == "Sapphire Barramundi" then
            addBarraFinish(model, s, base, accent)
        elseif fishName == "Crimson Arowana" then
            addArowanaFinish(model, s, base, accent, false)
        elseif fishName == "Aurora Arapaima" then
            addArowanaFinish(model, s, base, accent, true)
        elseif fishName == "Obsidian Ray" then
            addRayFinish(model, s, base, accent)
        elseif fishName == "Golden Mahseer" then
            addMahseerFinish(model, s, base, accent)
        elseif fishName == "Phantom Leviathan" then
            addLeviathanFinish(model, s * 1.05, base, accent)
        else
            addGenericFinish(model, s, base, accent)
        end

        -- Mutation colors remain owned by v4/v5. V6 only adds geometry and inherits the visible palette.
        local rarity = tostring(model:GetAttribute("Rarity") or "COMMON")
        if rarity == "LEGENDARY" or rarity == "MYTHIC" then
            local light = Instance.new("PointLight")
            light.Name = "TrophyLightV6"
            light.Color = accent
            light.Brightness = rarity == "MYTHIC" and 0.42 or 0.26
            light.Range = rarity == "MYTHIC" and 5.5 or 4.0
            light.Shadows = false
            light.Parent = model.PrimaryPart
        end

        model:SetAttribute("FishAnatomyV6", true)
        model:SetAttribute("CollectibleSilhouetteV6", fishName)
    end)
end

district.ChildAdded:Connect(decorateCatch)
for _, child in ipairs(district:GetChildren()) do decorateCatch(child) end

local function hookContainer(container)
    if not container then return end
    polishRodsIn(container)
    container.ChildAdded:Connect(function(item)
        if isFishingRod(item) then
            task.delay(0.08, function()
                if item.Parent then polishRod(item) end
            end)
        end
    end)
end

local function setupPlayer(player)
    task.spawn(function()
        task.wait(1.0)
        hookContainer(player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack", 8))
        if player.Character then hookContainer(player.Character) end
    end)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.8)
        hookContainer(char)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)

-- Strict gate-side authority: market-side players cannot carry the fishing rod or accidentally
-- keep a fishing-mode silhouette while browsing Pasar Malam.
task.spawn(function()
    while task.wait(0.45) do
        for _, player in ipairs(Players:GetPlayers()) do
            if inLakeSide(player) then
                player:SetAttribute("BBYAFishingGateSideV6", true)
                polishRodsIn(player.Character)
                polishRodsIn(player:FindFirstChildOfClass("Backpack"))
            else
                player:SetAttribute("BBYAFishingGateSideV6", false)
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:UnequipTools() end
                    clearRod(char)
                end
                clearRod(player:FindFirstChildOfClass("Backpack"))
            end
        end
    end
end)

print("[BBYA] Fishing Satisfaction v6 server online: gate authority + premium rod detail + fish anatomy polish")
