-- BBYA SOCIAL HUB — PRO DJ RIG VISUAL PROTOTYPE v1
-- TEST BRANCH ONLY. Visual-only replacement for the primitive Main Club DJ hardware.
-- No audio writes. No SoundGroup writes. No global Lighting writes.
-- External/third-party runtime mesh loading remains disabled.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD")

local oldPass = root:FindFirstChild("MeshAssetPass")
if oldPass then oldPass:Destroy() end

local out = Instance.new("Folder")
out.Name = "MeshAssetPass"
out:SetAttribute("Mode", "BBYA_PRO_DJ_RIG_V1_NATIVE_PROTOTYPE")
out:SetAttribute("ExternalRuntimeAssets", false)
out:SetAttribute("VisualOnly", true)
out:SetAttribute("AudioWrites", false)
out:SetAttribute("GlobalLightingWrites", false)
out:SetAttribute("PrototypeOnly", true)
out.Parent = root

-- Wait until 42-main-club-realism has fully assembled its deterministic venue.
-- Planter_RRear is intentionally used as the completion sentinel because it is
-- created at the end of that pass, after the original DJ equipment.
local realism = root:WaitForChild("MainClubRealism", 30)
if not realism then
    warn("[BBYA Pro DJ Rig v1] MainClubRealism unavailable")
    return
end

local dressing = realism:WaitForChild("Dressing", 15)
if dressing then
    dressing:WaitForChild("Planter_RRear", 30)
end

local av = realism:FindFirstChild("AudioVisual")
local booth = av and av:FindFirstChild("DJBoothPremium")
local boothTop = booth and booth:FindFirstChild("BoothTop")
if not booth or not boothTop or not boothTop:IsA("BasePart") then
    warn("[BBYA Pro DJ Rig v1] DJ booth anchor unavailable")
    return
end

local oldGear = booth:FindFirstChild("DJEquipment")
if oldGear then oldGear:Destroy() end
local previous = booth:FindFirstChild("BBYAProDJRigV1")
if previous then previous:Destroy() end

local rig = Instance.new("Model")
rig.Name = "BBYAProDJRigV1"
rig:SetAttribute("Authority", "BBYA_PRO_DJ_RIG_V1")
rig:SetAttribute("VisualTarget", "PROFESSIONAL_REAL_WORLD_DJ_HARDWARE")
rig:SetAttribute("GenericBrandingOnly", true)
rig:SetAttribute("NoAudioWrites", true)
rig:SetAttribute("NoGlobalLightingWrites", true)
rig.Parent = booth

local deckGroup = Instance.new("Folder")
deckGroup.Name = "MediaPlayers"
deckGroup.Parent = rig
local mixerGroup = Instance.new("Folder")
mixerGroup.Name = "FourChannelMixer"
mixerGroup.Parent = rig
local accessoryGroup = Instance.new("Folder")
accessoryGroup.Name = "Accessories"
accessoryGroup.Parent = rig

local C = {
    chassis = Color3.fromRGB(14, 15, 17),
    chassis2 = Color3.fromRGB(23, 24, 27),
    edge = Color3.fromRGB(50, 52, 57),
    metal = Color3.fromRGB(82, 85, 91),
    platter = Color3.fromRGB(29, 31, 35),
    platterRing = Color3.fromRGB(115, 119, 126),
    screen = Color3.fromRGB(4, 9, 12),
    white = Color3.fromRGB(232, 235, 239),
    green = Color3.fromRGB(72, 255, 143),
    cyan = Color3.fromRGB(59, 208, 255),
    blue = Color3.fromRGB(80, 125, 255),
    amber = Color3.fromRGB(255, 185, 66),
    red = Color3.fromRGB(255, 70, 76),
    magenta = Color3.fromRGB(255, 62, 173),
}

local function part(name, size, localCF, color, material, parent, className)
    local p = Instance.new(className or "Part")
    p.Name = name
    p.Size = size
    p.CFrame = boothTop.CFrame * localCF
    p.Color = color or C.chassis
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = true
    p.CastShadow = size.X > .16 and size.Y > .08 and size.Z > .16
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or rig
    return p
end

local function neon(name, size, localCF, color, parent, transparency)
    local p = part(name, size, localCF, color, Enum.Material.Neon, parent)
    p.Transparency = transparency or 0
    p.CastShadow = false
    return p
end

-- Roblox cylinders are X-axis aligned by default; rotate them so the axis is Y,
-- producing real horizontal platters and vertical rotary controls.
local function discY(name, diameter, height, localCF, color, material, parent)
    local p = part(name, Vector3.new(height, diameter, diameter), localCF * CFrame.Angles(0, 0, math.rad(90)), color, material, parent)
    p.Shape = Enum.PartType.Cylinder
    return p
end

local function topLabel(host, text, textColor, backgroundColor, font)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "HardwareDisplay"
    gui.Face = Enum.NormalId.Top
    gui.AlwaysOnTop = false
    gui.LightInfluence = .18
    gui.PixelsPerStud = 90
    gui.Parent = host

    local label = Instance.new("TextLabel")
    label.BackgroundColor3 = backgroundColor or C.screen
    label.BackgroundTransparency = .05
    label.BorderSizePixel = 0
    label.Size = UDim2.fromScale(1, 1)
    label.Text = text
    label.TextColor3 = textColor or C.white
    label.Font = font or Enum.Font.GothamMedium
    label.TextScaled = true
    label.TextWrapped = true
    label.Parent = gui
    return label
end

local function ledDot(name, x, y, z, color, parent)
    return neon(name, Vector3.new(.12, .035, .12), CFrame.new(x, y, z), color, parent, .02)
end

local TOP_Y = .34

local function buildDeck(name, centerX, accent, parent)
    local m = Instance.new("Model")
    m.Name = name
    m:SetAttribute("HardwareClass", "ProfessionalMediaPlayer")
    m.Parent = parent

    -- Layered chassis: the hardware silhouette is intentionally distinct from a
    -- flat button box, with rails, recessed top deck, platter and raised screen.
    part("LowerChassis", Vector3.new(4.75, .38, 5.45), CFrame.new(centerX, TOP_Y, .08), C.chassis, Enum.Material.Metal, m)
    part("TopDeck", Vector3.new(4.52, .13, 5.18), CFrame.new(centerX, TOP_Y + .245, .08), C.chassis2, Enum.Material.SmoothPlastic, m)
    part("FrontBezel", Vector3.new(4.56, .30, .20), CFrame.new(centerX, TOP_Y + .12, -2.63), C.edge, Enum.Material.Metal, m)
    part("LeftRail", Vector3.new(.16, .20, 5.10), CFrame.new(centerX - 2.28, TOP_Y + .19, .08), C.edge, Enum.Material.Metal, m)
    part("RightRail", Vector3.new(.16, .20, 5.10), CFrame.new(centerX + 2.28, TOP_Y + .19, .08), C.edge, Enum.Material.Metal, m)

    -- Three-layer mechanical jog wheel/platter.
    discY("JogOuter", 2.78, .16, CFrame.new(centerX - .28, TOP_Y + .43, .38), C.platterRing, Enum.Material.Metal, m)
    discY("JogPlatter", 2.54, .18, CFrame.new(centerX - .28, TOP_Y + .53, .38), C.platter, Enum.Material.Metal, m)
    discY("JogTop", 2.18, .08, CFrame.new(centerX - .28, TOP_Y + .66, .38), Color3.fromRGB(19, 20, 23), Enum.Material.SmoothPlastic, m)
    discY("JogCenter", .46, .055, CFrame.new(centerX - .28, TOP_Y + .715, .38), accent, Enum.Material.Neon, m)
    discY("JogCenterCap", .27, .04, CFrame.new(centerX - .28, TOP_Y + .75, .38), C.chassis, Enum.Material.Metal, m)

    -- Raised rear display housing; from player camera it reads as a real media-player screen.
    part("ScreenHousing", Vector3.new(3.86, .22, 1.27), CFrame.new(centerX, TOP_Y + .80, 1.92) * CFrame.Angles(math.rad(-13), 0, 0), C.chassis, Enum.Material.Metal, m)
    local screen = part("Screen", Vector3.new(3.55, .055, 1.00), CFrame.new(centerX, TOP_Y + .93, 1.83) * CFrame.Angles(math.rad(-13), 0, 0), C.screen, Enum.Material.Glass, m)
    screen.Reflectance = .08
    topLabel(screen, "BBYA  PLAYER\n128.0 BPM   01:42", accent, C.screen, Enum.Font.GothamBold)

    -- Browse encoder + navigation controls at the screen edge.
    discY("BrowseEncoder", .30, .18, CFrame.new(centerX + 1.82, TOP_Y + .69, 1.31), C.metal, Enum.Material.Metal, m)
    ledDot("BrowseLED", centerX + 1.82, TOP_Y + .80, 1.31, accent, m)
    for i = 1, 3 do
        part("NavKey" .. i, Vector3.new(.30, .075, .22), CFrame.new(centerX + 1.25 + (i - 1) * .38, TOP_Y + .66, 1.28), C.edge, Enum.Material.SmoothPlastic, m)
    end

    -- Pitch/tempo rail with a physical slot and cap.
    part("PitchSlot", Vector3.new(.10, .055, 2.04), CFrame.new(centerX + 1.88, TOP_Y + .66, -.18), Color3.fromRGB(5, 5, 6), Enum.Material.SmoothPlastic, m)
    part("PitchCap", Vector3.new(.34, .14, .28), CFrame.new(centerX + 1.88, TOP_Y + .75, -.40), C.metal, Enum.Material.Metal, m)
    neon("PitchZero", Vector3.new(.22, .03, .04), CFrame.new(centerX + 1.88, TOP_Y + .70, .35), accent, m, .15)

    -- Performance pad bank: 2 x 4 physical pads rather than random surface dots.
    local padColors = {C.cyan, C.blue, C.magenta, C.amber, C.green, C.red, C.blue, C.cyan}
    local n = 0
    for row = 1, 2 do
        for col = 1, 4 do
            n += 1
            local px = centerX - 1.57 + (col - 1) * .52
            local pz = -1.64 + (row - 1) * .48
            part("PerformancePad" .. n, Vector3.new(.43, .105, .37), CFrame.new(px, TOP_Y + .70, pz), padColors[n], Enum.Material.Neon, m)
        end
    end

    -- Transport keys: large PLAY and CUE controls with illuminated rings.
    discY("PlayRing", .60, .09, CFrame.new(centerX + .90, TOP_Y + .69, -1.77), C.green, Enum.Material.Neon, m)
    discY("PlayKey", .43, .10, CFrame.new(centerX + .90, TOP_Y + .76, -1.77), C.chassis, Enum.Material.Metal, m)
    discY("CueRing", .60, .09, CFrame.new(centerX + 1.55, TOP_Y + .69, -1.77), C.amber, Enum.Material.Neon, m)
    discY("CueKey", .43, .10, CFrame.new(centerX + 1.55, TOP_Y + .76, -1.77), C.chassis, Enum.Material.Metal, m)

    -- Loop / beat controls and status indicators.
    for i = 1, 4 do
        local bx = centerX - 1.58 + (i - 1) * .46
        part("LoopKey" .. i, Vector3.new(.34, .08, .26), CFrame.new(bx, TOP_Y + .68, -.94), C.edge, Enum.Material.SmoothPlastic, m)
        ledDot("LoopLED" .. i, bx, TOP_Y + .735, -.94, (i == 2) and accent or C.white, m)
    end

    -- Small tempo/level LEDs beside platter.
    for i = 1, 7 do
        local c = i <= 4 and C.green or (i <= 6 and C.amber or C.red)
        neon("LevelLED" .. i, Vector3.new(.07, .035, .19), CFrame.new(centerX + 1.46, TOP_Y + .70, .15 + (i - 1) * .25), c, m, .04)
    end

    -- Front headphone/USB-style detailing.
    part("FrontPort", Vector3.new(.62, .15, .055), CFrame.new(centerX - 1.43, TOP_Y + .11, -2.75), Color3.fromRGB(4, 4, 5), Enum.Material.SmoothPlastic, m)
    neon("FrontStatus", Vector3.new(.15, .04, .04), CFrame.new(centerX + 1.50, TOP_Y + .20, -2.76), accent, m, .05)

    return m
end

local function buildMixer(centerX, parent)
    local m = Instance.new("Model")
    m.Name = "BBYA_4CH_MIXER"
    m:SetAttribute("HardwareClass", "ProfessionalFourChannelMixer")
    m.Parent = parent

    part("LowerChassis", Vector3.new(5.15, .40, 5.45), CFrame.new(centerX, TOP_Y, .08), C.chassis, Enum.Material.Metal, m)
    part("TopPanel", Vector3.new(4.93, .13, 5.18), CFrame.new(centerX, TOP_Y + .25, .08), Color3.fromRGB(20, 21, 24), Enum.Material.SmoothPlastic, m)
    part("FrontBezel", Vector3.new(4.96, .30, .20), CFrame.new(centerX, TOP_Y + .12, -2.63), C.edge, Enum.Material.Metal, m)

    -- Four actual channel strips: GAIN + 3-band EQ + FILTER + fader + CUE.
    local channelX = {-1.62, -.55, .55, 1.62}
    local knobZ = {1.52, 1.03, .54, .05, -.48}
    for ch, dx in ipairs(channelX) do
        local x = centerX + dx
        part("ChannelRail" .. ch, Vector3.new(.78, .035, 3.98), CFrame.new(x, TOP_Y + .68, .34), Color3.fromRGB(35, 36, 40), Enum.Material.Metal, m)

        for k, z in ipairs(knobZ) do
            local knobColor = (k == 5) and C.metal or Color3.fromRGB(104, 107, 113)
            discY("CH" .. ch .. "_Knob" .. k, .28, .18, CFrame.new(x, TOP_Y + .73, z), knobColor, Enum.Material.Metal, m)
            local pointerColor = (k == 5) and C.cyan or C.white
            neon("CH" .. ch .. "_Pointer" .. k, Vector3.new(.035, .025, .11), CFrame.new(x, TOP_Y + .84, z - .06), pointerColor, m, .04)
        end

        part("CH" .. ch .. "_FaderSlot", Vector3.new(.09, .045, 1.12), CFrame.new(x, TOP_Y + .69, -1.32), Color3.fromRGB(3, 3, 4), Enum.Material.SmoothPlastic, m)
        part("CH" .. ch .. "_FaderCap", Vector3.new(.38, .15, .25), CFrame.new(x, TOP_Y + .78, -1.48 + (ch % 2) * .25), C.metal, Enum.Material.Metal, m)
        discY("CH" .. ch .. "_CueRing", .34, .07, CFrame.new(x, TOP_Y + .70, -2.02), (ch % 2 == 0) and C.cyan or C.amber, Enum.Material.Neon, m)
        discY("CH" .. ch .. "_CueKey", .23, .08, CFrame.new(x, TOP_Y + .76, -2.02), C.chassis, Enum.Material.Metal, m)
    end

    -- Dual stereo VU meter ladders through the center.
    for side = -1, 1, 2 do
        for i = 1, 10 do
            local z = 1.57 - (i - 1) * .245
            local color = i <= 6 and C.green or (i <= 8 and C.amber or C.red)
            neon("MasterMeter_" .. side .. "_" .. i, Vector3.new(.10, .035, .16), CFrame.new(centerX + side * .16, TOP_Y + .72, z), color, m, .02)
        end
    end

    -- Master / booth section and compact information display.
    local info = part("MixerDisplay", Vector3.new(.78, .055, .60), CFrame.new(centerX, TOP_Y + .70, 1.92), C.screen, Enum.Material.Glass, m)
    topLabel(info, "BBYA\n4CH", C.white, C.screen, Enum.Font.GothamBold)
    discY("MasterEncoder", .30, .18, CFrame.new(centerX + .55, TOP_Y + .73, 1.92), C.metal, Enum.Material.Metal, m)
    discY("BoothEncoder", .30, .18, CFrame.new(centerX - .55, TOP_Y + .73, 1.92), C.metal, Enum.Material.Metal, m)

    -- Horizontal crossfader at the front edge.
    part("CrossfaderSlot", Vector3.new(2.30, .05, .10), CFrame.new(centerX, TOP_Y + .70, -2.36), Color3.fromRGB(3, 3, 4), Enum.Material.SmoothPlastic, m)
    part("CrossfaderCap", Vector3.new(.30, .16, .34), CFrame.new(centerX + .30, TOP_Y + .79, -2.36), C.metal, Enum.Material.Metal, m)

    -- FX bank with physical select keys and illuminated beat controls.
    for i = 1, 4 do
        part("FXKey" .. i, Vector3.new(.34, .08, .24), CFrame.new(centerX - .76 + (i - 1) * .50, TOP_Y + .70, -1.94), C.edge, Enum.Material.SmoothPlastic, m)
        ledDot("FXLED" .. i, centerX - .76 + (i - 1) * .50, TOP_Y + .755, -1.94, (i == 3) and C.magenta or C.cyan, m)
    end

    return m
end

-- Professional club layout: media player — 4-channel mixer — media player.
buildDeck("BBYA_MEDIA_PLAYER_L", -5.55, C.cyan, deckGroup)
buildMixer(0, mixerGroup)
buildDeck("BBYA_MEDIA_PLAYER_R", 5.55, C.magenta, deckGroup)

-- Headphones: physical headband + earcups resting at the front-left of the booth.
local phones = Instance.new("Model")
phones.Name = "BBYA_Headphones"
phones.Parent = accessoryGroup
local band = part("Headband", Vector3.new(.18, 1.25, 1.25), CFrame.new(-8.55, TOP_Y + .88, -1.20) * CFrame.Angles(0, 0, math.rad(90)), C.edge, Enum.Material.Metal, phones)
band.Shape = Enum.PartType.Cylinder
part("HeadbandCut", Vector3.new(.75, .24, .75), CFrame.new(-8.55, TOP_Y + .97, -1.20), C.chassis, Enum.Material.SmoothPlastic, phones)
discY("EarCupL", .56, .26, CFrame.new(-9.08, TOP_Y + .68, -1.20), C.chassis, Enum.Material.Metal, phones)
discY("EarCupR", .56, .26, CFrame.new(-8.02, TOP_Y + .68, -1.20), C.chassis, Enum.Material.Metal, phones)

-- A restrained BBYA equipment badge; deliberately no third-party hardware logo/trademark.
local badge = part("BBYAHardwareBadge", Vector3.new(2.15, .045, .34), CFrame.new(0, TOP_Y + .72, -2.55), C.screen, Enum.Material.Glass, accessoryGroup)
topLabel(badge, "BBYA PRO AUDIO", C.white, C.screen, Enum.Font.GothamBold)

out:SetAttribute("RigReady", true)
out:SetAttribute("RigName", rig.Name)
out:SetAttribute("Layout", "2_MEDIA_PLAYERS_PLUS_4CH_MIXER")

print("[BBYA] PRO DJ RIG v1 ready — professional media-player + 4CH mixer visual prototype; audio/global lighting untouched")
