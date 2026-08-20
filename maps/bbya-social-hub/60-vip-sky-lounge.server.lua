-- BBYA SOCIAL HUB — VIP MINIMAL STANDING LOUNGE v5
-- Clean standing/social VIP with safe rails, triangle ceiling lighting,
-- continuous floor-boundary neon and four wall-corner suspended speakers.
-- No sofas, booths, bar, plants, gates, signs, ceiling strip grids or small white downlights.
-- Floor 1 / DJ systems / monetization are untouched.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 20)
if not root then return end
local upper = root:WaitForChild("UpperLevels", 20)
if not upper then return end
local vip = upper:WaitForChild("L2_VIP_Level", 20)
if not vip then return end

-- Hard reset L2 VIP only. This replaces previous VIP dressing.
for _, child in ipairs(vip:GetChildren()) do
    child:Destroy()
end

local out = Instance.new("Model")
out.Name = "VIPMinimalStanding"
out:SetAttribute("Pass", "VIP_MINIMAL_STANDING_V5")
out:SetAttribute("FurnitureCount", 0)
out:SetAttribute("DecorCount", 0)
out:SetAttribute("StandingOnly", true)
out:SetAttribute("Floor1Untouched", true)
out:SetAttribute("SafetyRails", true)
out:SetAttribute("TriangleCeilingLighting", true)
out:SetAttribute("CeilingLinearStrips", false)
out:SetAttribute("SmallWhiteDownlights", false)
out:SetAttribute("FloorBoundaryNeon", true)
out:SetAttribute("SuspendedCornerSound", true)
out.Parent = vip

local DARK = Color3.fromRGB(18, 16, 20)
local FLOOR = Color3.fromRGB(43, 39, 45)
local RAIL = Color3.fromRGB(48, 52, 58)
local SPEAKER = Color3.fromRGB(10, 10, 12)
local GRILLE = Color3.fromRGB(25, 25, 29)
local METAL = Color3.fromRGB(70, 72, 78)
local PINK = Color3.fromRGB(255, 42, 157)
local BLUE = Color3.fromRGB(0, 174, 255)

local function part(name, size, cf, color, material, transparency, collide, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color or DARK
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

local function addGlow(strip, color, brightness, range)
    local glow = Instance.new("SurfaceLight")
    glow.Name = "NeonWash"
    glow.Face = Enum.NormalId.Bottom
    glow.Color = color
    glow.Brightness = brightness or 0.45
    glow.Range = range or 9
    glow.Angle = 120
    glow.Shadows = false
    glow.Parent = strip
end

-- Open standing ring around the central club void.
part("NorthStandingFloor", Vector3.new(116, 1, 22), CFrame.new(0, 24.5, 34), FLOOR, Enum.Material.Slate, 0, true)
part("SouthStandingFloor", Vector3.new(116, 1, 18), CFrame.new(0, 24.5, -36), FLOOR, Enum.Material.Slate, 0, true)
part("WestStandingFloor", Vector3.new(24, 1, 52), CFrame.new(-46, 24.5, -1), FLOOR, Enum.Material.Slate, 0, true)
part("EastStandingFloor", Vector3.new(24, 1, 52), CFrame.new(46, 24.5, -1), FLOOR, Enum.Material.Slate, 0, true)

-- Safety rails around the central opening. Keep them visually quiet;
-- the actual floor limit is communicated by continuous neon at foot level.
local rails = model("SafetyRails")
local function rail(name, size, cf)
    local r = part(name, size, cf, RAIL, Enum.Material.Glass, 0.42, true, rails)
    r.Reflectance = 0.05
    return r
end
rail("NorthInnerRail", Vector3.new(70, 3.2, 0.24), CFrame.new(0, 26.5, 23))
rail("SouthInnerRail", Vector3.new(70, 3.2, 0.24), CFrame.new(0, 26.5, -27))
rail("WestInnerRail", Vector3.new(0.24, 3.2, 50), CFrame.new(-35, 26.5, -2))
rail("EastInnerRail", Vector3.new(0.24, 3.2, 50), CFrame.new(35, 26.5, -2))

-- -----------------------------------------------------------------------------
-- FLOOR-BOUNDARY NEON
-- Continuous trim is placed at the actual walking-floor edges, not on the ceiling.
-- This makes both the outer perimeter and the central void edge obvious to players.
-- -----------------------------------------------------------------------------
local floorNeon = model("FloorBoundaryNeon")
local FLOOR_NEON_Y = 25.04
local boundarySegments = {
    -- Outer perimeter.
    {"OuterNorth", Vector3.new(116, 0.10, 0.16), CFrame.new(0, FLOOR_NEON_Y, 44.92), PINK},
    {"OuterSouth", Vector3.new(116, 0.10, 0.16), CFrame.new(0, FLOOR_NEON_Y, -44.92), BLUE},
    {"OuterWest", Vector3.new(0.16, 0.10, 90), CFrame.new(-57.92, FLOOR_NEON_Y, 0), BLUE},
    {"OuterEast", Vector3.new(0.16, 0.10, 90), CFrame.new(57.92, FLOOR_NEON_Y, 0), PINK},

    -- Inner opening / drop boundary under the safety rails.
    {"InnerNorth", Vector3.new(70, 0.10, 0.16), CFrame.new(0, FLOOR_NEON_Y, 22.86), BLUE},
    {"InnerSouth", Vector3.new(70, 0.10, 0.16), CFrame.new(0, FLOOR_NEON_Y, -26.86), PINK},
    {"InnerWest", Vector3.new(0.16, 0.10, 50), CFrame.new(-34.86, FLOOR_NEON_Y, -2), PINK},
    {"InnerEast", Vector3.new(0.16, 0.10, 50), CFrame.new(34.86, FLOOR_NEON_Y, -2), BLUE},
}
for _, d in ipairs(boundarySegments) do
    local strip = neon(d[1], d[2], d[3], d[4], floorNeon)
    addGlow(strip, d[4], 0.34, 6)
end

-- -----------------------------------------------------------------------------
-- TRIANGLE CEILING LIGHT
-- One clean geometric fixture only. No extra straight ceiling strips and no
-- small white square/downlight grid.
-- -----------------------------------------------------------------------------
local triangle = model("TriangleCeilingLight")
local TRI_Y = 43.48
local triA = Vector3.new(0, TRI_Y, -18)
local triB = Vector3.new(-26, TRI_Y, 20)
local triC = Vector3.new(26, TRI_Y, 20)

local function neonBeam(name, a, b, color)
    local delta = b - a
    local length = delta.Magnitude
    local mid = (a + b) / 2
    local cf = CFrame.lookAt(mid, b) * CFrame.Angles(0, math.rad(90), 0)
    local beam = neon(name, Vector3.new(length, 0.18, 0.24), cf, color, triangle)
    addGlow(beam, color, 0.72, 15)
    return beam
end

neonBeam("TriangleLeft", triA, triB, BLUE)
neonBeam("TriangleRight", triA, triC, PINK)
neonBeam("TriangleBase", triB, triC, PINK)

-- Small dark mounting nodes keep the triangle visually believable without
-- introducing extra white fixtures.
for i, v in ipairs({triA, triB, triC}) do
    part("TriangleMount" .. i, Vector3.new(0.55, 0.28, 0.55), CFrame.new(v), DARK, Enum.Material.Metal, 0, false, triangle)
end

-- -----------------------------------------------------------------------------
-- SUSPENDED CORNER SOUND
-- One compact speaker array at every far corner, pushed close to the walls and
-- hung high from the ceiling. Nothing stands on the floor.
-- -----------------------------------------------------------------------------
local soundRig = model("SuspendedCornerSound")
local corners = {
    {name = "NW", pos = Vector3.new(-54.5, 38.1, 40.5)},
    {name = "NE", pos = Vector3.new(54.5, 38.1, 40.5)},
    {name = "SW", pos = Vector3.new(-54.5, 38.1, -40.5)},
    {name = "SE", pos = Vector3.new(54.5, 38.1, -40.5)},
}

local soundObjects = {}
local function addSpeakerCluster(corner)
    local cluster = model("CornerSpeaker_" .. corner.name, soundRig)
    local target = Vector3.new(0, 28, 0)
    local cf = CFrame.lookAt(corner.pos, Vector3.new(target.X, corner.pos.Y - 1.0, target.Z))

    local cabinet = part(
        "Cabinet",
        Vector3.new(5.2, 7.0, 3.0),
        cf,
        SPEAKER,
        Enum.Material.Metal,
        0,
        false,
        cluster
    )
    cabinet:SetAttribute("Suspended", true)
    cabinet:SetAttribute("WallCorner", corner.name)

    local grille = part(
        "FrontGrille",
        Vector3.new(4.65, 6.4, 0.12),
        cf * CFrame.new(0, 0, -1.56),
        GRILLE,
        Enum.Material.SmoothPlastic,
        0,
        false,
        cluster
    )
    grille.CastShadow = false

    for i, dy in ipairs({-1.55, 1.20}) do
        local driver = part(
            "Driver" .. i,
            Vector3.new(0.18, 2.35, 2.35),
            cf * CFrame.new(0, dy, -1.64) * CFrame.Angles(0, math.rad(90), 0),
            Color3.fromRGB(14, 14, 16),
            Enum.Material.SmoothPlastic,
            0,
            false,
            cluster
        )
        driver.Shape = Enum.PartType.Cylinder
    end

    -- Two suspension rods from the roof down to the cabinet.
    local roofY = 43.72
    local cabinetTopY = corner.pos.Y + 3.5
    local rodLength = math.max(0.35, roofY - cabinetTopY)
    local right = cf.RightVector
    for i, offset in ipairs({-1.45, 1.45}) do
        local anchorPos = corner.pos + right * offset
        part(
            "Hanger" .. i,
            Vector3.new(0.16, rodLength, 0.16),
            CFrame.new(anchorPos.X, cabinetTopY + rodLength / 2, anchorPos.Z),
            METAL,
            Enum.Material.Metal,
            0,
            false,
            cluster
        )
    end

    local sound = Instance.new("Sound")
    sound.Name = "CornerSpatialAudio"
    sound.SoundId = "rbxassetid://1846869595"
    sound.Volume = 0.055
    sound.Looped = true
    sound.RollOffMode = Enum.RollOffMode.InverseTapered
    sound.RollOffMinDistance = 12
    sound.RollOffMaxDistance = 76
    sound.EmitterSize = 14
    sound.Parent = cabinet
    table.insert(soundObjects, sound)
end

for _, corner in ipairs(corners) do
    addSpeakerCluster(corner)
end

-- Start all four emitters together after the rig is built.
task.defer(function()
    for _, sound in ipairs(soundObjects) do
        sound.TimePosition = 0
        sound:Play()
    end
end)

-- Minimal roof access kept at east side.
local roofPad = part("RooftopAccess", Vector3.new(7, 0.35, 7), CFrame.new(48, 25.2, -19), Color3.fromRGB(28, 25, 30), Enum.Material.Slate, 0, true)
local prompt = Instance.new("ProximityPrompt")
prompt.Name = "RooftopAccessPrompt"
prompt.ActionText = "Go Up"
prompt.ObjectText = "Rooftop"
prompt.HoldDuration = 0
prompt.MaxActivationDistance = 7
prompt.RequiresLineOfSight = false
prompt.Parent = roofPad
prompt.Triggered:Connect(function(player)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(43, 47, -28)
    end
end)

out:SetAttribute("FloorBoundaryNeonSegments", #boundarySegments)
out:SetAttribute("TriangleFixtureCount", 1)
out:SetAttribute("SpeakerClusterCount", #corners)
out:SetAttribute("SoundLayout", "Four suspended wall-corner speakers")
out:SetAttribute("LightingLayout", "Single triangle ceiling fixture + continuous floor boundary neon")

print(string.format(
    "[BBYA] VIP Minimal Standing v5 online: triangle ceiling / %d floor-neon segments / %d suspended corner speakers",
    #boundarySegments,
    #corners
))
