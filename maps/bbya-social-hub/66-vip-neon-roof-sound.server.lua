-- BBYA SOCIAL HUB — VIP NEON / ROOF LIGHT / HANGING SOUND RESTORE v1.0
-- Restores the active L2 VIP lighting language after VIPMinimalStanding reset.
-- Linear neon trim only (no geometric/triangle ceiling), practical roof downlights,
-- and four suspended corner speaker clusters with restrained spatial audio.
-- Floor 1 / DJ booth / monetization remain untouched.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end
local upper = root:WaitForChild("UpperLevels", 30)
if not upper then return end
local vip = upper:WaitForChild("L2_VIP_Level", 30)
if not vip then return end

-- VIPMinimalStanding is created by pass 60 after it clears the previous VIP children.
-- Waiting for it prevents this restore pass from being deleted by that reset.
local activeVIP = vip:WaitForChild("VIPMinimalStanding", 30)
if not activeVIP then return end
task.wait(0.25)

local old = activeVIP:FindFirstChild("VIPNeonRoofSoundRestore")
if old then old:Destroy() end

local out = Instance.new("Model")
out.Name = "VIPNeonRoofSoundRestore"
out:SetAttribute("Pass", "VIP_NEON_ROOF_SOUND_RESTORE_V1_0")
out:SetAttribute("LinearNeonOnly", true)
out:SetAttribute("GeometricCeiling", false)
out:SetAttribute("Floor1Untouched", true)
out.Parent = activeVIP

local C = {
    black = Color3.fromRGB(8, 8, 11),
    housing = Color3.fromRGB(18, 18, 22),
    grille = Color3.fromRGB(27, 27, 31),
    pink = Color3.fromRGB(255, 42, 157),
    blue = Color3.fromRGB(0, 174, 255),
    warm = Color3.fromRGB(255, 207, 151),
    white = Color3.fromRGB(255, 241, 220),
}

local function part(name, size, cf, color, material, transparency, collide, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color or C.housing
    p.Material = material or Enum.Material.SmoothPlastic
    p.Transparency = transparency or 0
    p.Anchored = true
    p.CanCollide = collide == true
    p.CanTouch = false
    p.CanQuery = true
    p.CastShadow = material ~= Enum.Material.Neon
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or out
    return p
end

local function model(name, parent)
    local m = Instance.new("Model")
    m.Name = name
    m.Parent = parent or out
    return m
end

local function neon(name, size, cf, color, parent)
    local p = part(name, size, cf, color, Enum.Material.Neon, 0, false, parent)
    p.CastShadow = false
    return p
end

-- -----------------------------------------------------------------------------
-- 1) RESTORE LINEAR NEON TRIM UNDER THE ROOF
-- Rooftop slab underside is Y=44.0. Keep trim slightly below the slab.
-- No triangles/polygons: these are clean straight cove/perimeter lines.
-- -----------------------------------------------------------------------------
local neonPass = model("PerimeterNeonTrim")
local NEON_Y = 43.70
local neonSegments = {
    {"NorthNeon", Vector3.new(112, .12, .20), CFrame.new(0, NEON_Y, 42.2), C.pink},
    {"SouthNeon", Vector3.new(112, .12, .20), CFrame.new(0, NEON_Y, -42.2), C.blue},
    {"WestNeon", Vector3.new(.20, .12, 82), CFrame.new(-57.6, NEON_Y, 0), C.blue},
    {"EastNeon", Vector3.new(.20, .12, 82), CFrame.new(57.6, NEON_Y, 0), C.pink},
    -- Short warm linear accents keep the VIP readable without replacing the club palette.
    {"NorthWarmAccent", Vector3.new(28, .10, .16), CFrame.new(0, NEON_Y - .06, 34.0), C.warm},
    {"SouthWarmAccent", Vector3.new(28, .10, .16), CFrame.new(0, NEON_Y - .06, -34.0), C.warm},
}
for _, d in ipairs(neonSegments) do
    local strip = neon(d[1], d[2], d[3], d[4], neonPass)
    local glow = Instance.new("SurfaceLight")
    glow.Name = "NeonWash"
    glow.Face = Enum.NormalId.Bottom
    glow.Color = d[4]
    glow.Brightness = .38
    glow.Range = 10
    glow.Angle = 115
    glow.Shadows = false
    glow.Parent = strip
end

-- -----------------------------------------------------------------------------
-- 2) RESTORE PRACTICAL ROOF LIGHTS
-- 16 warm-white downlights on a regular grid for visibility and premium ambience.
-- -----------------------------------------------------------------------------
local roofLights = model("RoofDownlights")
local downlightCount = 0
for _, x in ipairs({-45, -15, 15, 45}) do
    for _, z in ipairs({-30, -10, 10, 30}) do
        downlightCount += 1
        local fixture = part(
            string.format("DownlightFixture_%02d", downlightCount),
            Vector3.new(2.2, .28, 2.2),
            CFrame.new(x, 43.58, z),
            C.black,
            Enum.Material.Metal,
            0,
            false,
            roofLights
        )
        local lens = neon(
            string.format("DownlightLens_%02d", downlightCount),
            Vector3.new(1.55, .08, 1.55),
            CFrame.new(x, 43.40, z),
            C.white,
            roofLights
        )
        lens.Shape = Enum.PartType.Cylinder
        lens.CFrame = lens.CFrame * CFrame.Angles(0, 0, math.rad(90))

        local light = Instance.new("SurfaceLight")
        light.Name = "RoofDownlight"
        light.Face = Enum.NormalId.Bottom
        light.Color = C.white
        light.Brightness = 1.15
        light.Range = 23
        light.Angle = 105
        light.Shadows = false
        light.Parent = lens

        fixture:SetAttribute("DownlightIndex", downlightCount)
    end
end

-- -----------------------------------------------------------------------------
-- 3) HANG FOUR SOUND CLUSTERS IN THE CORNERS
-- Each corner gets twin cabinets, ceiling hangers, visible drivers and low-volume
-- spatial audio. Existing center VIP audio is reduced so the room does not stack loud.
-- -----------------------------------------------------------------------------
local soundPass = model("SuspendedCornerSound")

local oldEmitter = activeVIP:FindFirstChild("VIPSoundEmitter")
if oldEmitter then
    local oldSound = oldEmitter:FindFirstChild("VIPAmbientSound")
    if oldSound and oldSound:IsA("Sound") then
        oldSound.Volume = .10
    end
end

local corners = {
    {name="NW", pos=Vector3.new(-49, 37.2, 32)},
    {name="NE", pos=Vector3.new(49, 37.2, 32)},
    {name="SW", pos=Vector3.new(-49, 37.2, -32)},
    {name="SE", pos=Vector3.new(49, 37.2, -32)},
}

local speakerCount = 0
local function addCabinet(parent, name, center, target, yOffset)
    speakerCount += 1
    local pos = center + Vector3.new(0, yOffset, 0)
    local cf = CFrame.lookAt(pos, Vector3.new(target.X, pos.Y - .5, target.Z))
    local cab = part(name, Vector3.new(4.8, 5.6, 2.7), cf, C.black, Enum.Material.Metal, 0, false, parent)

    local grille = part(name.."_Grille", Vector3.new(4.25, 5.05, .12), cf * CFrame.new(0, 0, -1.41), C.grille, Enum.Material.SmoothPlastic, 0, false, parent)
    grille.CastShadow = false

    for i, dy in ipairs({-1.35, 1.05}) do
        local driver = part(
            name.."_Driver"..i,
            Vector3.new(.18, 2.25, 2.25),
            cf * CFrame.new(0, dy, -1.50) * CFrame.Angles(0, math.rad(90), 0),
            Color3.fromRGB(12,12,14),
            Enum.Material.SmoothPlastic,
            0,
            false,
            parent
        )
        driver.Shape = Enum.PartType.Cylinder
    end

    return cab
end

for _, c in ipairs(corners) do
    local cluster = model("CornerCluster_"..c.name, soundPass)
    local target = Vector3.new(0, 30, 0)

    -- twin cabinets form a compact hanging array rather than floor stacks
    local upperCab = addCabinet(cluster, "SpeakerUpper", c.pos, target, 2.65)
    local lowerCab = addCabinet(cluster, "SpeakerLower", c.pos, target, -2.65)

    -- two slim ceiling suspension rods per cluster
    local topY = c.pos.Y + 2.65 + 2.8
    local hangerBottomY = math.min(40.4, topY)
    local hangerTopY = 43.72
    local hangerLen = hangerTopY - hangerBottomY
    for i, dx in ipairs({-1.35, 1.35}) do
        part(
            "Hanger"..i,
            Vector3.new(.16, hangerLen, .16),
            CFrame.new(c.pos.X + dx, hangerBottomY + hangerLen/2, c.pos.Z),
            Color3.fromRGB(66,66,72),
            Enum.Material.Metal,
            0,
            false,
            cluster
        )
    end

    -- restrained spatial audio from the lower cabinet; four corners share the load
    local sound = Instance.new("Sound")
    sound.Name = "CornerSpatialAudio"
    sound.SoundId = "rbxassetid://1846869595"
    sound.Volume = .055
    sound.Looped = true
    sound.RollOffMode = Enum.RollOffMode.InverseTapered
    sound.RollOffMinDistance = 12
    sound.RollOffMaxDistance = 72
    sound.EmitterSize = 14
    sound.Parent = lowerCab
    sound:Play()

    upperCab:SetAttribute("SuspendedArray", true)
    lowerCab:SetAttribute("SuspendedArray", true)
end

out:SetAttribute("NeonSegmentCount", #neonSegments)
out:SetAttribute("RoofDownlightCount", downlightCount)
out:SetAttribute("SpeakerCabinetCount", speakerCount)
out:SetAttribute("SpeakerClusterCount", #corners)
out:SetAttribute("SoundLayout", "Four suspended corner clusters")
out:SetAttribute("LightingLayout", "Linear neon perimeter + regular roof downlights")

print(string.format(
    "[BBYA] VIP restore online: %d neon strips / %d roof downlights / %d hanging speaker cabinets in %d corners",
    #neonSegments,
    downlightCount,
    speakerCount,
    #corners
))
