-- BBYA SOCIAL HUB — VIP PRIVATE CLUB UPGRADE v2
-- VIP-only late finishing pass. Preserves the approved precise inner floor neon,
-- standing/social layout and Main-club audio routing while adding premium material,
-- architectural lighting, entrance framing and local room acoustics.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end
local upper = root:WaitForChild("UpperLevels", 30)
if not upper then return end
local vip = upper:WaitForChild("L2_VIP_Level", 30)
if not vip then return end
local active = vip:WaitForChild("VIPMinimalStanding", 30)
if not active then return end

-- Wait for the current live VIP layers. The late pass must decorate them, not race them.
local triangle = active:WaitForChild("TriangleCeilingNetwork", 30)
local preciseNeon = active:WaitForChild("PreciseInnerFloorNeon", 30)
local enclosure = active:WaitForChild("VIPEnclosureV7", 30)
if not triangle or not preciseNeon or not enclosure then return end

-- VenueLightingBoostV1 is a parallel ServerScript. If it appears, replace only its
-- broad VIP fill; the Skatepark section of that script is never touched here.
local broadBoost = active:FindFirstChild("VIPBrightnessBoostV1") or active:WaitForChild("VIPBrightnessBoostV1", 8)
if broadBoost then broadBoost:Destroy() end

local old = active:FindFirstChild("VIPPrivateClubUpgradeV2")
if old then old:Destroy() end

local out = Instance.new("Model")
out.Name = "VIPPrivateClubUpgradeV2"
out:SetAttribute("Pass", "VIP_PRIVATE_CLUB_UPGRADE_V2")
out:SetAttribute("Scope", "VIP_ONLY")
out:SetAttribute("StandingOnly", true)
out:SetAttribute("FloorNeonPreserved", true)
out:SetAttribute("VisibleDownlightsAdded", false)
out:SetAttribute("AudioGroupUntouched", true)
out:SetAttribute("LightingProfile", "ARCHITECTURAL_WHITE_WARM_V2")
out.Parent = active

local C = {
    black = Color3.fromRGB(9, 9, 12),
    graphite = Color3.fromRGB(28, 29, 34),
    metal = Color3.fromRGB(58, 61, 68),
    smoked = Color3.fromRGB(47, 57, 64),
    brass = Color3.fromRGB(176, 135, 72),
    champagne = Color3.fromRGB(216, 178, 110),
    warm = Color3.fromRGB(255, 235, 205),
    white = Color3.fromRGB(250, 252, 255),
    fabric = Color3.fromRGB(32, 31, 36),
}

local function model(name, parent)
    local m = Instance.new("Model")
    m.Name = name
    m.Parent = parent or out
    return m
end

local function part(name, size, cf, color, material, transparency, collide, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color or C.graphite
    p.Material = material or Enum.Material.SmoothPlastic
    p.Transparency = transparency or 0
    p.Anchored = true
    p.CanCollide = collide == true
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = material ~= Enum.Material.Neon
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or out
    return p
end

local function pointWash(parent, name, pos, color, brightness, range)
    local emitter = part(name, Vector3.new(.18, .18, .18), CFrame.new(pos), C.black, Enum.Material.SmoothPlastic, 1, false, parent)
    local light = Instance.new("PointLight")
    light.Name = "ArchitecturalWash"
    light.Color = color
    light.Brightness = brightness
    light.Range = range
    light.Shadows = false
    light.Parent = emitter
    return emitter
end

-- -----------------------------------------------------------------------------
-- 1) SMOKED-GLASS INNER RAIL + CHAMPAGNE METAL CAP
-- Geometry stays exactly on the existing safety rail. Precise floor neon remains
-- below it and is not moved, recolored or replaced by this pass.
-- -----------------------------------------------------------------------------
local rails = active:FindFirstChild("SafetyRails")
if rails then
    for _, rail in ipairs(rails:GetChildren()) do
        if rail:IsA("BasePart") then
            rail.Color = C.smoked
            rail.Material = Enum.Material.Glass
            rail.Transparency = .24
            rail.Reflectance = .08
            rail.CastShadow = false
        end
    end
end

local railCaps = model("PremiumRailCaps")
part("NorthCap", Vector3.new(70.2, .14, .34), CFrame.new(0, 28.14, 23), C.champagne, Enum.Material.Metal, 0, false, railCaps)
part("SouthCap", Vector3.new(70.2, .14, .34), CFrame.new(0, 28.14, -27), C.champagne, Enum.Material.Metal, 0, false, railCaps)
part("WestCap", Vector3.new(.34, .14, 50.2), CFrame.new(-35, 28.14, -2), C.champagne, Enum.Material.Metal, 0, false, railCaps)
part("EastCap", Vector3.new(.34, .14, 50.2), CFrame.new(35, 28.14, -2), C.champagne, Enum.Material.Metal, 0, false, railCaps)

-- -----------------------------------------------------------------------------
-- 2) ARCHITECTURAL WALL RHYTHM
-- Thin dark ribs and brass inlays make the enclosure read as a designed private
-- club rather than a plain box. They sit inside the collision walls.
-- -----------------------------------------------------------------------------
local ribs = model("ArchitecturalWallRibs")
for _, z in ipairs({-32, -20, -8, 4, 16, 28, 40}) do
    part("WestRib_"..z, Vector3.new(.24, 13.2, .70), CFrame.new(-56.66, 34.1, z), C.metal, Enum.Material.Metal, 0, false, ribs)
    part("WestInlay_"..z, Vector3.new(.10, 9.8, .18), CFrame.new(-56.50, 34.1, z), C.brass, Enum.Material.Metal, 0, false, ribs)
    part("EastRib_"..z, Vector3.new(.24, 13.2, .70), CFrame.new(56.66, 34.1, z), C.metal, Enum.Material.Metal, 0, false, ribs)
    part("EastInlay_"..z, Vector3.new(.10, 9.8, .18), CFrame.new(56.50, 34.1, z), C.brass, Enum.Material.Metal, 0, false, ribs)
end
for _, x in ipairs({-48, -32, -16, 0, 16, 32, 48}) do
    part("RearRib_"..x, Vector3.new(.70, 13.2, .24), CFrame.new(x, 34.1, 43.60), C.metal, Enum.Material.Metal, 0, false, ribs)
    part("RearInlay_"..x, Vector3.new(.18, 9.8, .10), CFrame.new(x, 34.1, 43.43), C.brass, Enum.Material.Metal, 0, false, ribs)
end

-- Deepen the existing acoustic panels without changing their collision/sound logic.
local wallPanels = enclosure:FindFirstChild("WallAcousticPanels")
if wallPanels then
    local index = 0
    for _, obj in ipairs(wallPanels:GetDescendants()) do
        if obj:IsA("BasePart") then
            index += 1
            obj.Material = Enum.Material.Fabric
            obj.Color = (index % 3 == 0) and Color3.fromRGB(39, 36, 42) or C.fabric
            obj.Reflectance = 0
        end
    end
end

-- -----------------------------------------------------------------------------
-- 3) OPEN PRIVATE-CLUB ENTRANCE PORTAL
-- Keeps the 30-stud central entrance physically open; framing is decorative only.
-- -----------------------------------------------------------------------------
local portal = model("PrivateClubPortal")
part("PortalColumnL", Vector3.new(.60, 15.4, .50), CFrame.new(-14.40, 33.35, -43.65), C.black, Enum.Material.Metal, 0, false, portal)
part("PortalColumnR", Vector3.new(.60, 15.4, .50), CFrame.new(14.40, 33.35, -43.65), C.black, Enum.Material.Metal, 0, false, portal)
part("PortalBrassL", Vector3.new(.10, 12.8, .12), CFrame.new(-14.02, 33.35, -43.37), C.champagne, Enum.Material.Metal, 0, false, portal)
part("PortalBrassR", Vector3.new(.10, 12.8, .12), CFrame.new(14.02, 33.35, -43.37), C.champagne, Enum.Material.Metal, 0, false, portal)
part("PortalLintel", Vector3.new(29.4, .66, .52), CFrame.new(0, 40.72, -43.65), C.black, Enum.Material.Metal, 0, false, portal)
part("PortalLintelInlay", Vector3.new(27.8, .10, .12), CFrame.new(0, 40.34, -43.37), C.champagne, Enum.Material.Metal, 0, false, portal)

local plaque = part("PrivateClubPlaque", Vector3.new(12.8, 1.65, .18), CFrame.new(0, 39.18, -43.31), C.graphite, Enum.Material.Metal, 0, false, portal)
local function plaqueFace(face)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "PrivateClubLabel_"..face.Name
    gui.Face = face
    gui.LightInfluence = .08
    gui.PixelsPerStud = 54
    gui.Parent = plaque
    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.Text = "BBYA  PRIVATE CLUB"
    text.TextColor3 = C.champagne
    text.TextStrokeTransparency = .82
    text.Font = Enum.Font.GothamBold
    text.TextScaled = true
    text.Parent = gui
end
plaqueFace(Enum.NormalId.Front)
plaqueFace(Enum.NormalId.Back)

-- -----------------------------------------------------------------------------
-- 4) DIMENSIONAL WHITE + WARM ARCHITECTURAL LIGHTING
-- Reduce the previous flat broad fill and let the triangle network remain the
-- visual hero, supported by warm perimeter washes. No visible square downlights.
-- -----------------------------------------------------------------------------
local wash = model("ArchitecturalLightWash")
local washPositions = {
    Vector3.new(-52, 34, -28), Vector3.new(-52, 34, -4), Vector3.new(-52, 34, 20), Vector3.new(-52, 34, 38),
    Vector3.new(52, 34, -28), Vector3.new(52, 34, -4), Vector3.new(52, 34, 20), Vector3.new(52, 34, 38),
    Vector3.new(-32, 34, 40), Vector3.new(0, 34, 40), Vector3.new(32, 34, 40),
}
for i, pos in ipairs(washPositions) do
    local color = (i % 4 == 0) and C.white or C.warm
    pointWash(wash, "WallWash_"..i, pos, color, (i % 4 == 0) and .72 or .88, 21)
end

local tubeIndex = 0
for _, obj in ipairs(triangle:GetDescendants()) do
    if obj:IsA("SurfaceLight") and obj.Name == "WhiteTubeWash" then
        tubeIndex += 1
        obj.Color = C.white
        obj.Brightness = (tubeIndex % 3 == 0) and .78 or .68
        obj.Range = 15
        obj.Angle = 126
        obj.Shadows = false
    elseif obj:IsA("BasePart") and obj.Name:match("^TriangleTube_") then
        obj.Color = C.white
    end
end

-- -----------------------------------------------------------------------------
-- 5) VIP-LOCAL ROOM ACOUSTICS
-- Effects are children of the four positional sounds. SoundGroup, SoundId,
-- TimePosition and volume remain owned by the v7 Main AutoDJ sync loop.
-- -----------------------------------------------------------------------------
local rig = active:FindFirstChild("SuspendedCornerSound")
local tunedSounds = 0
if rig then
    for _, sound in ipairs(rig:GetDescendants()) do
        if sound:IsA("Sound") and sound.Name == "CornerSpatialAudio" then
            tunedSounds += 1
            local oldEQ = sound:FindFirstChild("VIPRoomEQV2")
            if oldEQ then oldEQ:Destroy() end
            local oldVerb = sound:FindFirstChild("VIPRoomReverbV2")
            if oldVerb then oldVerb:Destroy() end

            local eq = Instance.new("EqualizerSoundEffect")
            eq.Name = "VIPRoomEQV2"
            eq.LowGain = 1.4
            eq.MidGain = -.35
            eq.HighGain = -.8
            eq.Parent = sound

            local verb = Instance.new("ReverbSoundEffect")
            verb.Name = "VIPRoomReverbV2"
            verb.DecayTime = .8
            verb.Density = .75
            verb.Diffusion = .82
            verb.DryLevel = 0
            verb.WetLevel = -15
            verb.Parent = sound
        end
    end
end

-- Guard against the legacy rail neon being recreated late. Never delete the
-- approved PreciseInnerFloorNeon model.
for _, obj in ipairs(vip:GetDescendants()) do
    if obj:IsA("BasePart") and not obj:IsDescendantOf(preciseNeon) then
        local n = obj.Name
        if n:match("^BalconyRailZ") or n:match("^BalconyRailX") or n == "QueenCrownLine" then
            obj:Destroy()
        end
    end
end

active:SetAttribute("VIPUpgradeProfile", "PRIVATE_CLUB_V2")
active:SetAttribute("LightingBrightnessProfile", "ARCHITECTURAL_PREMIUM_V2")
active:SetAttribute("PreciseInnerFloorNeonPreserved", preciseNeon.Parent == active)
active:SetAttribute("VIPRoomTunedSpeakerCount", tunedSounds)
out:SetAttribute("WallWashCount", #washPositions)
out:SetAttribute("RailCapCount", 4)
out:SetAttribute("PortalOpenWidth", 28.2)
out:SetAttribute("RoomTunedSpeakerCount", tunedSounds)

print(string.format(
    "[BBYA] VIP Private Club v2 online: smoked rails / architectural walls / open portal / %d washes / %d tuned speakers",
    #washPositions,
    tunedSounds
))
