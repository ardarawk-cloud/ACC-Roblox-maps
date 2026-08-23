-- BBYA SOCIAL HUB — FISHING SATISFACTION v6 SERVER
-- Focus: better rod feel, richer fish anatomy, and strict lake-gate authority.
-- Probability/progression/economy/audio/roles/club/mall/global Lighting stay owned by existing systems.

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
local LAKE_CENTER = Vector3.new(
    district:GetAttribute("LakeCenterX") or 0,
    0,
    district:GetAttribute("LakeCenterZ") or 790
)
local DISTRICT_RADIUS_SQ = 225 * 225

local function isFishingRod(item)
    return item and item:IsA("Tool") and item:GetAttribute("BBYAFishingRod") == true
end

local function onLakeSide(player)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or hrp.Position.Z < GATE_Z then return false end
    local dx = hrp.Position.X - LAKE_CENTER.X
    local dz = hrp.Position.Z - LAKE_CENTER.Z
    return dx * dx + dz * dz <= DISTRICT_RADIUS_SQ
end

local function removeRods(container)
    if not container then return end
    for _, item in ipairs(container:GetChildren()) do
        if isFishingRod(item) then item:Destroy() end
    end
end

local function weld(handle, part)
    part.Anchored = false
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Massless = true
    local w = Instance.new("WeldConstraint")
    w.Part0 = handle
    w.Part1 = part
    w.Parent = part
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
    weld(handle, p)
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
    weld(handle, p)
    return p
end

local function polishRod(tool)
    if not isFishingRod(tool) then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle or not handle:IsA("BasePart") then return end

    local skin = tostring(tool:GetAttribute("RodSkin") or "Graphite Core")
    local rarity = tostring(tool:GetAttribute("RodSkinRarity") or "COMMON")
    local old = tool:FindFirstChild("RodPremiumV6")
    if old and old:GetAttribute("Skin") == skin then
        -- Cheap guard: this function is called by the live authority loop, so do not rebuild
        -- dozens of welded parts every half-second when nothing changed.
        return
    end
    if old then old:Destroy() end

    local folder = Instance.new("Folder")
    folder.Name = "RodPremiumV6"
    folder:SetAttribute("Skin", skin)
    folder:SetAttribute("Rarity", rarity)
    folder.Parent = tool

    local tip = tool:FindFirstChild("TipSegment")
    local body = tool:FindFirstChild("RodSegment1")
    local accent = tip and tip:IsA("BasePart") and tip.Color or Color3.fromRGB(226, 188, 95)
    local bodyColor = body and body:IsA("BasePart") and body.Color or Color3.fromRGB(38, 42, 48)

    -- V5 fixed the reversed direction; V6 refines wrist placement so reel/handle sit cleanly.
    tool.Grip = CFrame.new(0.12, -0.58, -0.10)
        * CFrame.Angles(math.rad(-5), math.rad(8), math.rad(248))
    tool:SetAttribute("PremiumGripRefinedV6", true)

    for i = 1, 6 do
        local x = -0.95 + (i - 1) * 0.31
        rodPart(folder, handle, "GripWrap" .. i, Vector3.new(0.11, 0.42, 0.42), CFrame.new(x, 0, 0),
            i % 2 == 0 and Color3.fromRGB(48, 42, 39) or Color3.fromRGB(29, 27, 28),
            Enum.Material.Fabric, Enum.PartType.Cylinder)
    end

    rodPart(folder, handle, "ButtCap", Vector3.new(0.34, 0.48, 0.48), CFrame.new(-1.34, 0, 0), accent, Enum.Material.Metal, Enum.PartType.Cylinder)
    rodPart(folder, handle, "GripCollar", Vector3.new(0.18, 0.46, 0.46), CFrame.new(1.28, 0, 0), accent, Enum.Material.Metal, Enum.PartType.Cylinder)
    rodPart(folder, handle, "ReelFace", Vector3.new(0.16, 1.10, 1.10), CFrame.new(0.34, -0.49, 0), accent, Enum.Material.Metal, Enum.PartType.Cylinder)
    rodPart(folder, handle, "ReelHub", Vector3.new(0.24, 0.46, 0.46), CFrame.new(0.34, -0.49, 0), bodyColor, Enum.Material.Metal, Enum.PartType.Cylinder)
    rodPart(folder, handle, "CrankStem", Vector3.new(0.72, 0.10, 0.10), CFrame.new(-0.04, -0.95, 0) * CFrame.Angles(0, 0, math.rad(28)), accent, Enum.Material.Metal, Enum.PartType.Cylinder)
    rodPart(folder, handle, "CrankKnob", Vector3.new(0.30, 0.30, 0.30), CFrame.new(-0.33, -1.22, 0), Color3.fromRGB(35, 31, 30), Enum.Material.SmoothPlastic, Enum.PartType.Ball)

    for i, x in ipairs({2.15, 3.45, 4.85, 6.15, 7.42}) do
        local h = 0.28 - (i - 1) * 0.025
        rodPart(folder, handle, "GuideFoot" .. i, Vector3.new(0.08, h, 0.08), CFrame.new(x, h * 0.46, 0), accent, Enum.Material.Metal, Enum.PartType.Cylinder)
        rodPart(folder, handle, "GuideEye" .. i, Vector3.new(0.09, 0.23, 0.23), CFrame.new(x, h + 0.10, 0), accent, Enum.Material.Metal, Enum.PartType.Ball)
    end

    if rarity == "EPIC" or rarity == "LEGENDARY" or rarity == "MYTHIC" then
        rodWedge(folder, handle, "ReelGuardL", Vector3.new(0.55, 0.16, 0.46), CFrame.new(0.10, -0.43, 0.52) * CFrame.Angles(0, math.rad(180), math.rad(8)), accent, Enum.Material.Metal)
        rodWedge(folder, handle, "ReelGuardR", Vector3.new(0.55, 0.16, 0.46), CFrame.new(0.10, -0.43, -0.52) * CFrame.Angles(math.rad(180), 0, math.rad(-8)), accent, Enum.Material.Metal)
    end

    if rarity == "LEGENDARY" or rarity == "MYTHIC" then
        for i, x in ipairs({5.60, 6.55, 7.35}) do
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

local function polishRods(container)
    if not container then return end
    for _, item in ipairs(container:GetChildren()) do
        if isFishingRod(item) then polishRod(item) end
    end
end

-- =============================================================================
-- FISH ANATOMY V6
-- V5 owns the base species silhouette. V6 adds anatomy that makes catches read as trophies.
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

local function fishScale(model)
    local body = model:FindFirstChild("Body", true)
    if body and body:IsA("BasePart") then
        return math.clamp(body.Size.X / 5.2, 0.72, 2.35)
    end
    return 1
end

local function colors(model)
    local body = model:FindFirstChild("Body", true)
    local accentPart = model:FindFirstChild("Dorsal", true)
        or model:FindFirstChild("TailUpper", true)
        or model:FindFirstChild("TailTop", true)
    local base = body and body:IsA("BasePart") and body.Color or Color3.fromRGB(120, 145, 155)
    local accent = accentPart and accentPart:IsA("BasePart") and accentPart.Color or Color3.fromRGB(213, 191, 112)
    return base, accent
end

local function barbel(model, name, x, y, z, length, yaw, accent, s)
    fishPart(model, name, Vector3.new(length, 0.055, 0.055) * s,
        CFrame.new(x * s, y * s, z * s) * CFrame.Angles(0, math.rad(yaw), math.rad(4)),
        accent, Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
end

local function genericFinish(model, s, base, accent)
    fishPart(model, "CaudalPeduncleV6", Vector3.new(1.15, 1.05, 1.05) * s, CFrame.new(-2.55 * s, 0, 0), base, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    local belly = fishPart(model, "BellyVolumeV6", Vector3.new(3.7, 1.0, 1.62) * s, CFrame.new(-0.10 * s, -0.48 * s, 0), base, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    if belly then belly.Color = base:Lerp(Color3.fromRGB(235, 239, 238), 0.16) end
    fishWedge(model, "PelvicFinLV6", Vector3.new(1.05, 0.18, 0.78) * s, CFrame.new(0.15 * s, -0.72 * s, 0.73 * s) * CFrame.Angles(math.rad(-28), 0, math.rad(15)), accent)
    fishWedge(model, "PelvicFinRV6", Vector3.new(1.05, 0.18, 0.78) * s, CFrame.new(0.15 * s, -0.72 * s, -0.73 * s) * CFrame.Angles(math.rad(208), 0, math.rad(-15)), accent)
end

local function scaleRow(model, s, color, y, z, count, startX, step)
    for i = 1, count do
        local disc = fishPart(model, "ScalePlateV6", Vector3.new(0.42, 0.30, 0.09) * s,
            CFrame.new((startX - (i - 1) * step) * s, y * s, z * s),
            color, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
        if disc then disc.Transparency = 0.02 end
    end
end

local function koiFinish(model, s, base, accent, celestial)
    genericFinish(model, s, base, accent)
    barbel(model, "KoiBarbelLV6", 2.45, -0.12, 0.34, 1.05, 16, accent, s)
    barbel(model, "KoiBarbelRV6", 2.45, -0.12, -0.34, 1.05, -16, accent, s)
    fishWedge(model, "FlowFinLV6", Vector3.new(1.55, 0.18, 1.18) * s, CFrame.new(0.75 * s, -0.12 * s, 0.98 * s) * CFrame.Angles(math.rad(-30), 0, math.rad(9)), accent, celestial and Enum.Material.Neon or Enum.Material.SmoothPlastic)
    fishWedge(model, "FlowFinRV6", Vector3.new(1.55, 0.18, 1.18) * s, CFrame.new(0.75 * s, -0.12 * s, -0.98 * s) * CFrame.Angles(math.rad(210), 0, math.rad(-9)), accent, celestial and Enum.Material.Neon or Enum.Material.SmoothPlastic)
    if celestial then
        for i, x in ipairs({1.45, 0.35, -0.80}) do
            fishPart(model, "CelestialPearlV6_" .. i, Vector3.new(0.26, 0.26, 0.26) * s, CFrame.new(x * s, 1.10 * s, 0), accent, Enum.Material.Neon, Enum.PartType.Ball)
        end
    end
end

local function gouramiFinish(model, s, base, accent)
    genericFinish(model, s, base, accent)
    barbel(model, "GouramiFeelerLV6", 0.65, -0.78, 0.55, 2.15, 8, accent, s)
    barbel(model, "GouramiFeelerRV6", 0.65, -0.78, -0.55, 2.15, -8, accent, s)
    fishWedge(model, "LongAnalFinV6", Vector3.new(2.8, 0.48, 0.22) * s, CFrame.new(-0.35 * s, -1.12 * s, 0) * CFrame.Angles(math.rad(180), math.rad(90), 0), accent)
end

local function bassFinish(model, s, base, accent)
    genericFinish(model, s, base, accent)
    fishPart(model, "BassJawV6", Vector3.new(0.62, 0.48, 0.92) * s, CFrame.new(2.75 * s, -0.28 * s, 0), base:Lerp(Color3.new(0,0,0),0.20), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    for i, x in ipairs({1.15, 0.10, -0.95}) do
        fishPart(model, "BassSpotV6_" .. i, Vector3.new(0.48, 0.48, 0.12) * s, CFrame.new(x * s, 0.12 * s, 0.93 * s), Color3.fromRGB(36, 56, 40), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    end
end

local function catfishFinish(model, s, base, accent)
    genericFinish(model, s, base, accent)
    barbel(model, "CatBarbelLongLV6", 2.30, -0.18, 0.62, 2.40, 22, accent, s)
    barbel(model, "CatBarbelLongRV6", 2.30, -0.18, -0.62, 2.40, -22, accent, s)
    barbel(model, "CatBarbelShortLV6", 2.18, -0.34, 0.34, 1.35, 36, accent, s)
    barbel(model, "CatBarbelShortRV6", 2.18, -0.34, -0.34, 1.35, -36, accent, s)
    fishWedge(model, "AdiposeFinV6", Vector3.new(0.85, 0.52, 0.24) * s, CFrame.new(-1.55 * s, 0.92 * s, 0) * CFrame.Angles(0, math.rad(90), 0), accent)
end

local function barraFinish(model, s, base, accent)
    genericFinish(model, s, base, accent)
    fishPart(model, "SilverShoulderV6", Vector3.new(0.40, 1.45, 1.58) * s, CFrame.new(1.72 * s, 0.02 * s, 0), accent, Enum.Material.Metal, Enum.PartType.Ball)
    scaleRow(model, s, accent, 0.08, 0.92, 6, 0.75, 0.55)
end

local function arowanaFinish(model, s, base, accent, arapaima)
    genericFinish(model, s, base, accent)
    barbel(model, "ArowanaBarbelLV6", 3.10, -0.05, 0.22, 1.05, 8, accent, s)
    barbel(model, "ArowanaBarbelRV6", 3.10, -0.05, -0.22, 1.05, -8, accent, s)
    scaleRow(model, s, base:Lerp(accent, 0.48), 0.28, 0.94, arapaima and 8 or 6, 1.55, 0.57)
    scaleRow(model, s, base:Lerp(accent, 0.62), -0.18, 0.94, arapaima and 8 or 6, 1.72, 0.57)
    if arapaima then
        scaleRow(model, s, Color3.fromRGB(184, 78, 76), -0.20, -0.94, 7, 1.45, 0.60)
        fishWedge(model, "ArapaimaTailEdgeV6", Vector3.new(1.25, 1.25, 0.18) * s, CFrame.new(-3.85 * s, 0.18 * s, 0) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(199, 75, 78))
    end
end

local function rayFinish(model, s, base, accent)
    fishPart(model, "RayHeadV6", Vector3.new(1.75, 0.68, 1.95) * s, CFrame.new(1.75 * s, 0.05 * s, 0), base, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    fishWedge(model, "RayWingEdgeLV6", Vector3.new(3.0, 0.28, 1.85) * s, CFrame.new(-0.20 * s, -0.05 * s, 2.60 * s) * CFrame.Angles(0, math.rad(180), 0), accent)
    fishWedge(model, "RayWingEdgeRV6", Vector3.new(3.0, 0.28, 1.85) * s, CFrame.new(-0.20 * s, -0.05 * s, -2.60 * s), accent)
    fishPart(model, "RayEyeLV6", Vector3.new(0.24, 0.24, 0.24) * s, CFrame.new(1.35 * s, 0.38 * s, 0.72 * s), Color3.fromRGB(7,8,10), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    fishPart(model, "RayEyeRV6", Vector3.new(0.24, 0.24, 0.24) * s, CFrame.new(1.35 * s, 0.38 * s, -0.72 * s), Color3.fromRGB(7,8,10), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    fishPart(model, "RayStingerV6", Vector3.new(3.8, 0.08, 0.08) * s, CFrame.new(-4.0 * s, 0, 0), accent, Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
end

local function mahseerFinish(model, s, base, accent)
    genericFinish(model, s, base, accent)
    scaleRow(model, s, accent:Lerp(Color3.fromRGB(255, 232, 150), 0.35), 0.30, 0.90, 7, 1.45, 0.55)
    scaleRow(model, s, accent, -0.16, 0.90, 7, 1.62, 0.55)
    fishPart(model, "GoldGillV6", Vector3.new(0.34, 1.35, 1.58) * s, CFrame.new(1.68 * s, 0.02 * s, 0), accent, Enum.Material.Metal, Enum.PartType.Ball)
end

local function leviathanFinish(model, s, base, accent)
    fishPart(model, "LeviathanNeckV6", Vector3.new(2.2, 1.55, 1.55) * s, CFrame.new(1.7 * s, 0, 0), base, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    fishPart(model, "LeviathanJawV6", Vector3.new(1.75, 0.62, 1.62) * s, CFrame.new(3.35 * s, -0.45 * s, 0), Color3.fromRGB(24,18,38), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    for i, z in ipairs({-0.58, -0.20, 0.20, 0.58}) do
        fishWedge(model, "LeviathanToothV6_" .. i, Vector3.new(0.34, 0.54, 0.16) * s, CFrame.new(4.02 * s, -0.22 * s, z * s) * CFrame.Angles(0, math.rad(90), math.rad(180)), Color3.fromRGB(235, 232, 218))
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
        local s = fishScale(model)
        local base, accent = colors(model)

        if fishName == "Royal Koi" then koiFinish(model, s, base, accent, false)
        elseif fishName == "Celestial Koi" then koiFinish(model, s, base, accent, true)
        elseif fishName == "Azure Gourami" then gouramiFinish(model, s, base, accent)
        elseif fishName == "Jade Peacock Bass" then bassFinish(model, s, base, accent)
        elseif fishName == "Redtail Giant" then catfishFinish(model, s, base, accent)
        elseif fishName == "Sapphire Barramundi" then barraFinish(model, s, base, accent)
        elseif fishName == "Crimson Arowana" then arowanaFinish(model, s, base, accent, false)
        elseif fishName == "Aurora Arapaima" then arowanaFinish(model, s, base, accent, true)
        elseif fishName == "Obsidian Ray" then rayFinish(model, s, base, accent)
        elseif fishName == "Golden Mahseer" then mahseerFinish(model, s, base, accent)
        elseif fishName == "Phantom Leviathan" then leviathanFinish(model, s * 1.05, base, accent)
        else genericFinish(model, s, base, accent) end

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

local hooked = setmetatable({}, {__mode = "k"})
local function hookContainer(container)
    if not container or hooked[container] then return end
    hooked[container] = true
    polishRods(container)
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
        task.wait(1)
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

-- Final server authority: rods are a lakeside activity and cannot be carried back into Pasar Malam.
task.spawn(function()
    while task.wait(0.45) do
        for _, player in ipairs(Players:GetPlayers()) do
            if onLakeSide(player) then
                player:SetAttribute("BBYAFishingGateSideV6", true)
                polishRods(player.Character)
                polishRods(player:FindFirstChildOfClass("Backpack"))
            else
                player:SetAttribute("BBYAFishingGateSideV6", false)
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:UnequipTools() end
                    removeRods(char)
                end
                removeRods(player:FindFirstChildOfClass("Backpack"))
            end
        end
    end
end)

print("[BBYA] Fishing Satisfaction v6 server online: gate authority + premium rods + collectible fish anatomy")
