local Workspace = game:GetService("Workspace")

local function smooth(part)
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    return part
end

local function makePart(parent, name, size, cframe, color, material, collide, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Anchored = true
    p.CanCollide = collide == true
    p.CanTouch = false
    p.CanQuery = collide == true
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    if shape then p.Shape = shape end
    smooth(p)
    p.Parent = parent
    return p
end

local function ball(parent, name, size, position, color, material)
    return makePart(parent, name, Vector3.new(size, size, size), CFrame.new(position), color, material, false, Enum.PartType.Ball)
end

local function cylinder(parent, name, length, diameter, cframe, color, material, collide)
    return makePart(parent, name, Vector3.new(length, diameter, diameter), cframe, color, material, collide, Enum.PartType.Cylinder)
end

local function clearLegacyTreasureVisuals(root)
    for _, obj in ipairs(root:GetChildren()) do
        if obj.Name == "PalmTrunk"
            or obj.Name == "PalmCrown"
            or string.match(obj.Name, "^AncientRuins%d+$") then
            obj:Destroy()
        end
    end
end

local function buildPalm(parent, index, basePos, leanX, leanZ, scale)
    scale = scale or 1
    local model = Instance.new("Model")
    model.Name = "WonderPalm" .. index
    model.Parent = parent

    local trunkColors = {
        Color3.fromRGB(116, 78, 51),
        Color3.fromRGB(135, 91, 57),
        Color3.fromRGB(151, 103, 64),
    }

    local current = basePos + Vector3.new(0, 1.7 * scale, 0)
    local drift = Vector3.new(leanX or 0, 0, leanZ or 0) * scale
    for segment = 1, 3 do
        local length = (3.6 - segment * .18) * scale
        local diameter = (2.15 - segment * .24) * scale
        local pos = current + drift * (segment - 1) * .55
        local tiltZ = 90 + (leanX or 0) * 2.4
        local tiltY = (leanZ or 0) * 3.0
        cylinder(
            model,
            "TrunkSegment" .. segment,
            length,
            diameter,
            CFrame.new(pos) * CFrame.Angles(0, math.rad(tiltY), math.rad(tiltZ)),
            trunkColors[segment],
            Enum.Material.Wood,
            false
        )
        current += Vector3.new((leanX or 0) * .18 * scale, length * .83, (leanZ or 0) * .18 * scale)
    end

    local crownPos = current + Vector3.new(0, .7 * scale, 0)
    ball(model, "CrownCore", 3.1 * scale, crownPos, Color3.fromRGB(54, 132, 69), Enum.Material.Grass)

    local leafColors = {
        Color3.fromRGB(50, 142, 71),
        Color3.fromRGB(64, 161, 78),
        Color3.fromRGB(79, 174, 89),
    }
    for leaf = 1, 6 do
        local yaw = (leaf - 1) * 60 + index * 11
        local length = (6.6 + ((leaf + index) % 2) * 1.0) * scale
        local leafPart = makePart(
            model,
            "PalmFrond" .. leaf,
            Vector3.new(length, .34 * scale, 1.65 * scale),
            CFrame.new(crownPos)
                * CFrame.Angles(0, math.rad(yaw), math.rad((leaf % 2 == 0) and 10 or -10))
                * CFrame.new(length * .42, .05 * scale, 0),
            leafColors[((leaf - 1) % #leafColors) + 1],
            Enum.Material.Grass,
            false
        )
        leafPart.CastShadow = true
    end

    for coconut = 1, 2 do
        local angle = math.rad(index * 31 + coconut * 115)
        ball(
            model,
            "Coconut" .. coconut,
            .85 * scale,
            crownPos + Vector3.new(math.cos(angle) * 1.15, -1.05, math.sin(angle) * 1.15) * scale,
            Color3.fromRGB(111, 75, 48),
            Enum.Material.Wood
        )
    end

    local rootLeaf = ball(model, "RootBush", 2.4 * scale, basePos + Vector3.new(.65, .55, -.4), Color3.fromRGB(82, 156, 77), Enum.Material.Grass)
    rootLeaf.Size = Vector3.new(2.8, 1.35, 2.4) * scale
end

local function buildRuinCluster(parent, index, center)
    local model = Instance.new("Model")
    model.Name = "AncientRuinCluster" .. index
    model.Parent = parent
    local stoneA = Color3.fromRGB(143, 139, 119)
    local stoneB = Color3.fromRGB(167, 159, 132)
    local moss = Color3.fromRGB(86, 139, 74)

    local pillar = makePart(
        model,
        "BrokenPillar",
        Vector3.new(3.8, 6.6, 3.3),
        CFrame.new(center + Vector3.new(-1.2, 2.8, .4)) * CFrame.Angles(math.rad(index * 3), math.rad(index * 37), math.rad((index % 2 == 0) and 8 or -7)),
        stoneA,
        Enum.Material.Slate,
        false
    )
    pillar.CastShadow = true

    makePart(
        model,
        "FallenStone",
        Vector3.new(5.6, 2.1, 3.4),
        CFrame.new(center + Vector3.new(2.1, .7, 1.0)) * CFrame.Angles(math.rad(10), math.rad(index * 49), math.rad(18)),
        stoneB,
        Enum.Material.Rock,
        false
    )
    makePart(
        model,
        "RuinStep",
        Vector3.new(4.8, .85, 4.1),
        CFrame.new(center + Vector3.new(.2, .15, -2.1)) * CFrame.Angles(0, math.rad(index * 17), 0),
        Color3.fromRGB(133, 129, 112),
        Enum.Material.Slate,
        false
    )
    local mossPatch = makePart(
        model,
        "MossPatch",
        Vector3.new(3.2, .18, 2.3),
        CFrame.new(center + Vector3.new(-1.25, 6.15, .3)) * CFrame.Angles(0, math.rad(index * 37), 0),
        moss,
        Enum.Material.Grass,
        false
    )
    mossPatch.Transparency = .08
end

local function buildShrub(parent, index, pos, tint)
    local model = Instance.new("Model")
    model.Name = "IslandShrub" .. index
    model.Parent = parent
    local c1 = tint or Color3.fromRGB(85, 166, 79)
    local c2 = Color3.new(math.min(c1.R + .06, 1), math.min(c1.G + .07, 1), math.min(c1.B + .03, 1))
    local a = ball(model, "LeafA", 2.5, pos + Vector3.new(-.7, .8, 0), c1, Enum.Material.Grass)
    local b = ball(model, "LeafB", 2.1, pos + Vector3.new(.65, .9, .15), c2, Enum.Material.Grass)
    a.Size = Vector3.new(2.7, 1.8, 2.3)
    b.Size = Vector3.new(2.2, 1.55, 2.0)
end

local function buildRock(parent, index, pos, scale)
    scale = scale or 1
    local color = (index % 2 == 0) and Color3.fromRGB(123, 127, 115) or Color3.fromRGB(145, 143, 125)
    local r = makePart(
        parent,
        "EdgeRock" .. index,
        Vector3.new(3.5, 2.3, 3.1) * scale,
        CFrame.new(pos) * CFrame.Angles(math.rad(index * 7), math.rad(index * 43), math.rad(index * 5)),
        color,
        Enum.Material.Rock,
        false
    )
    r.Shape = Enum.PartType.Ball
end

local function upgradeTreasureIsland()
    local root = Workspace:WaitForChild("TreasureIsland", 30)
    if not root then return end
    task.wait(1)

    clearLegacyTreasureVisuals(root)
    local old = root:FindFirstChild("VisualUpgradeV2")
    if old then old:Destroy() end
    local env = Instance.new("Folder")
    env.Name = "VisualUpgradeV2"
    env.Parent = root

    local island = root:FindFirstChild("IslandBase")
    if island and island:IsA("Part") then
        island.Shape = Enum.PartType.Cylinder
        island.Size = Vector3.new(8, 88, 88)
        island.CFrame = CFrame.new(0, 34, -185) * CFrame.Angles(0, 0, math.rad(90))
        island.Color = Color3.fromRGB(83, 164, 82)
    end
    local beach = root:FindFirstChild("BeachRing")
    if beach and beach:IsA("Part") then
        beach.Shape = Enum.PartType.Cylinder
        beach.Size = Vector3.new(3.5, 99, 99)
        beach.CFrame = CFrame.new(0, 29.4, -185) * CFrame.Angles(0, 0, math.rad(90))
        beach.Color = Color3.fromRGB(239, 210, 151)
    end
    local lagoon = root:FindFirstChild("Lagoon")
    if lagoon and lagoon:IsA("Part") then
        lagoon.Shape = Enum.PartType.Cylinder
        lagoon.Size = Vector3.new(2, 164, 164)
        lagoon.CFrame = CFrame.new(0, 25, -185) * CFrame.Angles(0, 0, math.rad(90))
        lagoon.Color = Color3.fromRGB(83, 193, 226)
        lagoon.Transparency = .28
    end

    local palmCount = 12
    for i = 1, palmCount do
        local angle = (i / palmCount) * math.pi * 2 + .18
        local radius = 31 + ((i % 3) - 1) * 4.5
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius - 185
        local leanX = math.cos(angle + 1.1) * 1.15
        local leanZ = math.sin(angle + 1.1) * 1.15
        local scale = .88 + (i % 4) * .055
        buildPalm(env, i, Vector3.new(x, 39, z), leanX, leanZ, scale)
    end

    local ruins = {
        Vector3.new(-18, 39, -190),
        Vector3.new(18, 39, -177),
        Vector3.new(-4, 39, -162),
        Vector3.new(14, 39, -205),
    }
    for i, pos in ipairs(ruins) do buildRuinCluster(env, i, pos) end

    local shrubSpots = {
        Vector3.new(-31,39,-184), Vector3.new(-24,39,-166), Vector3.new(-8,39,-211),
        Vector3.new(9,39,-157), Vector3.new(28,39,-169), Vector3.new(32,39,-196),
        Vector3.new(14,39,-216), Vector3.new(-22,39,-204),
    }
    for i, pos in ipairs(shrubSpots) do
        buildShrub(env, i, pos, (i % 3 == 0) and Color3.fromRGB(73, 151, 91) or Color3.fromRGB(86, 169, 80))
    end

    for i = 1, 12 do
        local angle = i / 12 * math.pi * 2 + .31
        local r = 39 + (i % 2) * 2
        buildRock(env, i, Vector3.new(math.cos(angle) * r, 39.1, -185 + math.sin(angle) * r), .75 + (i % 3) * .12)
    end

    local trailColor = Color3.fromRGB(218, 202, 157)
    for i = 1, 9 do
        local z = -151 - i * 4.1
        local x = math.sin(i * 1.8) * 2.2
        local stone = makePart(
            env,
            "AdventureTrail" .. i,
            Vector3.new(4.2, .18, 2.8),
            CFrame.new(x, 39.08, z) * CFrame.Angles(0, math.rad((i % 2 == 0) and 12 or -13), 0),
            trailColor,
            Enum.Material.Sandstone,
            false
        )
        stone.Transparency = .05
    end

    print("[WONDERPOCKET] Treasure Island visual upgrade v2 loaded")
end

local function upgradeSquareTrees()
    local square = Workspace:WaitForChild("WonderSquare_Premium", 30)
    if not square then return end
    local decor = square:WaitForChild("Decor", 30)
    if not decor then return end
    task.wait(.5)

    local legacy = {}
    for _, obj in ipairs(decor:GetChildren()) do
        if string.match(obj.Name, "^Pocket Tree Trunk") or string.match(obj.Name, "^Pocket Tree Crown") then
            table.insert(legacy, obj)
        end
    end
    for _, obj in ipairs(legacy) do obj:Destroy() end

    local old = decor:FindFirstChild("PremiumTreeUpgrade")
    if old then old:Destroy() end
    local folder = Instance.new("Folder")
    folder.Name = "PremiumTreeUpgrade"
    folder.Parent = decor

    local surfaceY = tonumber(square:GetAttribute("WP_SurfaceY")) or 6.55
    local spots = {
        Vector3.new(-39, surfaceY + 1.75, -39),
        Vector3.new(39, surfaceY + 1.75, -39),
        Vector3.new(-39, surfaceY + 1.75, 39),
        Vector3.new(39, surfaceY + 1.75, 39),
    }
    for i, spot in ipairs(spots) do
        buildPalm(folder, i, spot, ((i % 2 == 0) and .6 or -.55), ((i <= 2) and .45 or -.5), .68)
    end

    print("[WONDERPOCKET] Wonder Square premium foliage upgrade loaded")
end

task.spawn(upgradeTreasureIsland)
task.spawn(upgradeSquareTrees)
