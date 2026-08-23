-- BBYA SOCIAL HUB — VISUAL FISH INDEX v7
-- Turns the existing compact Fish Index into a visual collection album.
-- Uses in-game ViewportFrame 3D previews (no generated/uploaded image assets).
-- Undiscovered species use the correct fish silhouette but stay dark/locked.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local fishingGui = playerGui:WaitForChild("BBYAFishingUI", 35)
if not fishingGui then return end

local progressionRoot = fishingGui:WaitForChild("FishingProgressionV4UI", 35)
if not progressionRoot then return end
local journal = progressionRoot:WaitForChild("JournalV4", 20)
if not journal then return end

local v4Folder = ReplicatedStorage:WaitForChild("BBYAFishingV4", 35)
local stateRemote = v4Folder and v4Folder:WaitForChild("State", 10)
if not stateRemote then return end

local C = {
    bg = Color3.fromRGB(14,17,21),
    panel = Color3.fromRGB(24,28,34),
    panel2 = Color3.fromRGB(32,37,44),
    text = Color3.fromRGB(244,245,245),
    muted = Color3.fromRGB(151,158,166),
    gold = Color3.fromRGB(237,185,77),
    locked = Color3.fromRGB(47,52,59),
}

local rarityColors = {
    COMMON=Color3.fromRGB(196,202,207),
    UNCOMMON=Color3.fromRGB(96,213,131),
    RARE=Color3.fromRGB(74,161,242),
    EPIC=Color3.fromRGB(177,102,236),
    LEGENDARY=Color3.fromRGB(246,188,72),
    MYTHIC=Color3.fromRGB(244,99,173),
}

local profiles = {
    ["Moon Carp"]={kind="CARP",body=Color3.fromRGB(146,169,181),accent=Color3.fromRGB(220,231,233)},
    ["Azure Gourami"]={kind="GOURAMI",body=Color3.fromRGB(54,132,176),accent=Color3.fromRGB(80,216,223)},
    ["Jade Peacock Bass"]={kind="BASS",body=Color3.fromRGB(73,126,72),accent=Color3.fromRGB(197,204,63)},
    ["Redtail Giant"]={kind="CATFISH",body=Color3.fromRGB(58,65,73),accent=Color3.fromRGB(220,61,59)},
    ["Royal Koi"]={kind="KOI",body=Color3.fromRGB(236,233,220),accent=Color3.fromRGB(231,104,55)},
    ["Sapphire Barramundi"]={kind="BARRA",body=Color3.fromRGB(92,125,154),accent=Color3.fromRGB(174,218,230)},
    ["Crimson Arowana"]={kind="AROWANA",body=Color3.fromRGB(176,43,58),accent=Color3.fromRGB(247,142,79)},
    ["Obsidian Ray"]={kind="RAY",body=Color3.fromRGB(31,29,40),accent=Color3.fromRGB(111,81,151)},
    ["Golden Mahseer"]={kind="MAHSEER",body=Color3.fromRGB(165,116,40),accent=Color3.fromRGB(245,204,88)},
    ["Aurora Arapaima"]={kind="ARAPAIMA",body=Color3.fromRGB(54,81,121),accent=Color3.fromRGB(74,221,204)},
    ["Celestial Koi"]={kind="CELESTIAL_KOI",body=Color3.fromRGB(235,234,222),accent=Color3.fromRGB(240,193,74)},
    ["Phantom Leviathan"]={kind="LEVIATHAN",body=Color3.fromRGB(36,28,62),accent=Color3.fromRGB(139,84,225)},
}

local mutationNames = {
    NORMAL="NORMAL", GOLDEN="GOLDEN", MOONLIT="MOONLIT", LOTUS="LOTUS",
    CRYSTAL="CRYSTAL", SHADOW="SHADOW", AURORA="AURORA",
    CELESTIAL="CELESTIAL", ABYSSAL="ABYSSAL",
}

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function stroke(parent, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(74,81,89)
    s.Transparency = transparency or .3
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function label(parent, text, size, font, color)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Text = text or ""
    t.TextSize = size or 12
    t.Font = font or Enum.Font.Gotham
    t.TextColor3 = color or C.text
    t.TextWrapped = true
    t.Parent = parent
    return t
end

-- Hide the text-only v4 species list. Header/stats/close button remain intact.
local oldScroll
for _, child in ipairs(journal:GetChildren()) do
    if child:IsA("ScrollingFrame") then
        oldScroll = child
        break
    end
end
if oldScroll then oldScroll.Visible = false end

local oldVisual = journal:FindFirstChild("VisualIndexV7")
if oldVisual then oldVisual:Destroy() end

local visualScroll = Instance.new("ScrollingFrame")
visualScroll.Name = "VisualIndexV7"
visualScroll.Position = UDim2.fromOffset(14,140)
visualScroll.Size = UDim2.new(1,-28,1,-154)
visualScroll.BackgroundTransparency = 1
visualScroll.BorderSizePixel = 0
visualScroll.ScrollBarThickness = 3
visualScroll.ScrollBarImageColor3 = C.muted
visualScroll.CanvasSize = UDim2.fromOffset(0,0)
visualScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
visualScroll.ZIndex = 86
visualScroll.Parent = journal

local grid = Instance.new("UIGridLayout")
grid.Name = "VisualFishGridV7"
grid.CellSize = UDim2.new(.5,-4,0,148)
grid.CellPadding = UDim2.fromOffset(8,8)
grid.FillDirectionMaxCells = 2
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = visualScroll

local pad = Instance.new("UIPadding")
pad.PaddingBottom = UDim.new(0,8)
pad.Parent = visualScroll

local function part(parent, name, size, cf, color, shape, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
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
    p.Parent = parent
    return p
end

local function wedge(parent, name, size, cf, color, material)
    local p = Instance.new("WedgePart")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function eye(parent, x, y, z, locked)
    local col = locked and C.locked or Color3.fromRGB(8,9,11)
    part(parent,"Eye",Vector3.new(.23,.23,.18),CFrame.new(x,y,z),col,Enum.PartType.Ball)
end

local function forkTail(parent, x, h, accent)
    wedge(parent,"TailTop",Vector3.new(1.55,h,.22),CFrame.new(x,h*.42,0)*CFrame.Angles(0,math.rad(90),0),accent)
    wedge(parent,"TailBottom",Vector3.new(1.55,h,.22),CFrame.new(x,-h*.42,0)*CFrame.Angles(math.rad(180),math.rad(90),0),accent)
end

local function standardFish(parent, body, accent, kind, locked)
    local length = kind=="BASS" and 4.7 or (kind=="BARRA" and 5.2 or 4.3)
    local height = kind=="BASS" and 2.25 or 1.85
    part(parent,"Body",Vector3.new(length,height,1.45),CFrame.new(-.15,0,0),body,Enum.PartType.Ball)
    part(parent,"Head",Vector3.new(1.45,1.52,1.35),CFrame.new(length*.40,0,0),body,Enum.PartType.Ball)
    forkTail(parent,-length*.61,1.05,accent)
    wedge(parent,"Dorsal",Vector3.new(1.7,.62,.18),CFrame.new(-.3,height*.50,0)*CFrame.Angles(0,math.rad(90),0),accent)
    wedge(parent,"Fin",Vector3.new(.95,.16,.75),CFrame.new(.55,-.15,.72)*CFrame.Angles(math.rad(-22),0,math.rad(10)),accent)
    eye(parent,length*.42,.30,.60,locked)
    if kind=="BASS" and not locked then
        for i,x in ipairs({.75,-.25,-1.22}) do
            part(parent,"Band"..i,Vector3.new(.22,1.72,1.48),CFrame.new(x,0,0),Color3.fromRGB(39,62,42),Enum.PartType.Ball)
        end
    end
end

local function koi(parent, body, accent, locked, celestial)
    part(parent,"Body",Vector3.new(4.25,2.05,1.55),CFrame.new(-.1,0,0),body,Enum.PartType.Ball)
    part(parent,"Head",Vector3.new(1.42,1.62,1.42),CFrame.new(1.85,.02,0),body,Enum.PartType.Ball)
    forkTail(parent,-2.55,1.22,accent)
    wedge(parent,"Dorsal",Vector3.new(1.55,.62,.18),CFrame.new(-.35,1.02,0)*CFrame.Angles(0,math.rad(90),0),accent)
    wedge(parent,"FlowFinL",Vector3.new(1.25,.14,.92),CFrame.new(.55,-.18,.86)*CFrame.Angles(math.rad(-25),0,math.rad(10)),accent,celestial and Enum.Material.Neon or nil)
    wedge(parent,"FlowFinR",Vector3.new(1.25,.14,.92),CFrame.new(.55,-.18,-.86)*CFrame.Angles(math.rad(205),0,math.rad(-10)),accent,celestial and Enum.Material.Neon or nil)
    eye(parent,1.98,.34,.61,locked)
    if not locked then
        for i,cf in ipairs({CFrame.new(.88,.36,.68),CFrame.new(-.12,-.18,.72),CFrame.new(-1.05,.33,.69)}) do
            part(parent,"Patch"..i,Vector3.new(.58,.45,.11),cf,accent,Enum.PartType.Ball)
        end
    end
    if celestial and not locked then
        for i,x in ipairs({.85,-.10,-1.0}) do
            part(parent,"Pearl"..i,Vector3.new(.18,.18,.18),CFrame.new(x,1.04,0),accent,Enum.PartType.Ball,Enum.Material.Neon)
        end
    end
end

local function gourami(parent, body, accent, locked)
    part(parent,"Body",Vector3.new(3.95,2.65,1.42),CFrame.new(-.2,0,0),body,Enum.PartType.Ball)
    part(parent,"Head",Vector3.new(1.38,1.85,1.30),CFrame.new(1.62,.02,0),body,Enum.PartType.Ball)
    forkTail(parent,-2.35,1.15,accent)
    wedge(parent,"Dorsal",Vector3.new(1.65,.65,.18),CFrame.new(-.25,1.22,0)*CFrame.Angles(0,math.rad(90),0),accent)
    wedge(parent,"Anal",Vector3.new(2.15,.42,.18),CFrame.new(-.15,-1.23,0)*CFrame.Angles(math.rad(180),math.rad(90),0),accent)
    part(parent,"FeelerL",Vector3.new(2.0,.045,.045),CFrame.new(.45,-1.08,.45)*CFrame.Angles(0,0,math.rad(-8)),accent,Enum.PartType.Cylinder)
    part(parent,"FeelerR",Vector3.new(2.0,.045,.045),CFrame.new(.45,-1.08,-.45)*CFrame.Angles(0,0,math.rad(-8)),accent,Enum.PartType.Cylinder)
    eye(parent,1.72,.38,.56,locked)
end

local function catfish(parent, body, accent, locked)
    part(parent,"Body",Vector3.new(4.65,1.75,1.50),CFrame.new(-.15,0,0),body,Enum.PartType.Ball)
    part(parent,"Head",Vector3.new(1.75,1.55,1.62),CFrame.new(1.92,-.02,0),body,Enum.PartType.Ball)
    forkTail(parent,-2.78,1.05,accent)
    wedge(parent,"Dorsal",Vector3.new(1.25,.68,.18),CFrame.new(.15,.92,0)*CFrame.Angles(0,math.rad(90),0),accent)
    for i,z in ipairs({-.55,-.25,.25,.55}) do
        part(parent,"Whisker"..i,Vector3.new(1.7,.045,.045),CFrame.new(2.55,-.20,z)*CFrame.Angles(0,math.rad(z>0 and -18 or 18),0),accent,Enum.PartType.Cylinder)
    end
    eye(parent,2.05,.30,.66,locked)
end

local function longFish(parent, body, accent, locked, arapaima)
    local len = arapaima and 5.65 or 5.35
    part(parent,"Body",Vector3.new(len,1.55,1.28),CFrame.new(-.30,0,0),body,Enum.PartType.Ball)
    part(parent,"Head",Vector3.new(1.45,1.32,1.22),CFrame.new(len*.40,.02,0),body,Enum.PartType.Ball)
    forkTail(parent,-len*.60,.92,accent)
    wedge(parent,"LongDorsal",Vector3.new(2.25,.46,.16),CFrame.new(-1.0,.78,0)*CFrame.Angles(0,math.rad(90),0),accent)
    eye(parent,len*.42,.25,.52,locked)
    if not locked then
        for i=1,7 do
            local x = 1.1-(i-1)*.55
            part(parent,"Scale"..i,Vector3.new(.34,.28,.08),CFrame.new(x,.22,.65),accent:Lerp(body,.35),Enum.PartType.Ball)
        end
    end
    if arapaima then
        wedge(parent,"TailEdge",Vector3.new(1.15,.95,.16),CFrame.new(-3.45,.10,0)*CFrame.Angles(0,math.rad(90),0),accent)
    end
end

local function ray(parent, body, accent, locked)
    part(parent,"Body",Vector3.new(4.25,.62,4.85),CFrame.new(-.25,0,0),body,Enum.PartType.Ball)
    part(parent,"Head",Vector3.new(1.45,.58,1.72),CFrame.new(1.55,.02,0),body,Enum.PartType.Ball)
    wedge(parent,"WingL",Vector3.new(2.35,.18,1.55),CFrame.new(-.15,-.05,2.55)*CFrame.Angles(0,math.rad(180),0),accent)
    wedge(parent,"WingR",Vector3.new(2.35,.18,1.55),CFrame.new(-.15,-.05,-2.55),accent)
    part(parent,"Stinger",Vector3.new(3.25,.06,.06),CFrame.new(-3.55,0,0),accent,Enum.PartType.Cylinder)
    eye(parent,1.22,.34,.60,locked)
end

local function leviathan(parent, body, accent, locked)
    part(parent,"Body",Vector3.new(5.35,2.10,1.75),CFrame.new(-.45,0,0),body,Enum.PartType.Ball)
    part(parent,"Neck",Vector3.new(1.75,1.55,1.48),CFrame.new(1.75,.04,0),body,Enum.PartType.Ball)
    part(parent,"Head",Vector3.new(1.75,1.62,1.58),CFrame.new(3.05,.02,0),body,Enum.PartType.Ball)
    part(parent,"Jaw",Vector3.new(1.45,.52,1.48),CFrame.new(3.48,-.46,0),locked and C.locked or Color3.fromRGB(24,18,38),Enum.PartType.Ball)
    forkTail(parent,-3.55,1.35,accent)
    for i,x in ipairs({1.15,.25,-.70,-1.62}) do
        wedge(parent,"Spine"..i,Vector3.new(.72,.85+i*.14,.22),CFrame.new(x,1.15,0)*CFrame.Angles(0,math.rad(90),0),accent,locked and Enum.Material.SmoothPlastic or Enum.Material.Neon)
    end
    eye(parent,3.12,.36,.68,locked)
end

local function buildPreview(world, fishName, discovered)
    local profile = profiles[fishName] or {kind="CARP",body=Color3.fromRGB(120,140,150),accent=Color3.fromRGB(205,210,215)}
    local locked = not discovered
    local body = locked and C.locked or profile.body
    local accent = locked and Color3.fromRGB(61,66,74) or profile.accent

    if profile.kind=="KOI" then koi(world,body,accent,locked,false)
    elseif profile.kind=="CELESTIAL_KOI" then koi(world,body,accent,locked,true)
    elseif profile.kind=="GOURAMI" then gourami(world,body,accent,locked)
    elseif profile.kind=="CATFISH" then catfish(world,body,accent,locked)
    elseif profile.kind=="AROWANA" then longFish(world,body,accent,locked,false)
    elseif profile.kind=="ARAPAIMA" then longFish(world,body,accent,locked,true)
    elseif profile.kind=="RAY" then ray(world,body,accent,locked)
    elseif profile.kind=="LEVIATHAN" then leviathan(world,body,accent,locked)
    elseif profile.kind=="MAHSEER" then standardFish(world,body,accent,"BARRA",locked)
    elseif profile.kind=="BASS" then standardFish(world,body,accent,"BASS",locked)
    elseif profile.kind=="BARRA" then standardFish(world,body,accent,"BARRA",locked)
    else standardFish(world,body,accent,"CARP",locked) end
end

local function makePreview(parent, fish)
    local viewport = Instance.new("ViewportFrame")
    viewport.Name = "FishPreviewV7"
    viewport.Position = UDim2.fromOffset(7,7)
    viewport.Size = UDim2.new(1,-14,0,82)
    viewport.BackgroundColor3 = fish.discovered and Color3.fromRGB(18,27,34) or Color3.fromRGB(19,22,26)
    viewport.BackgroundTransparency = 0
    viewport.BorderSizePixel = 0
    viewport.Ambient = fish.discovered and Color3.fromRGB(125,130,138) or Color3.fromRGB(42,45,49)
    viewport.LightColor = fish.discovered and Color3.fromRGB(255,244,222) or Color3.fromRGB(70,73,78)
    viewport.LightDirection = Vector3.new(-.5,-1,-.7)
    viewport.ZIndex = 89
    viewport.Parent = parent
    corner(viewport,9)

    local world = Instance.new("WorldModel")
    world.Name = "FishWorldV7"
    world.Parent = viewport
    buildPreview(world, fish.name, fish.discovered)

    local camera = Instance.new("Camera")
    camera.Name = "FishCameraV7"
    camera.FieldOfView = 33
    local profile = profiles[fish.name]
    local far = profile and profile.kind=="RAY" and 10.8 or (profile and profile.kind=="LEVIATHAN" and 11.2 or 9.2)
    camera.CFrame = CFrame.new(0,.15,far) * CFrame.Angles(0,0,0)
    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, Vector3.new(0,0,0))
    camera.Parent = viewport
    viewport.CurrentCamera = camera

    if not fish.discovered then
        local lock = label(viewport,"?",24,Enum.Font.GothamBlack,Color3.fromRGB(105,111,120))
        lock.AnchorPoint = Vector2.new(.5,.5)
        lock.Position = UDim2.fromScale(.5,.5)
        lock.Size = UDim2.fromOffset(34,34)
        lock.ZIndex = 91
    end
end

local function fishCard(fish, order)
    local card = Instance.new("Frame")
    card.Name = "FishCardV7_" .. string.gsub(fish.name or "Fish","%s+","")
    card.LayoutOrder = order
    card.BackgroundColor3 = C.panel
    card.BorderSizePixel = 0
    card.ZIndex = 87
    card.Parent = visualScroll
    corner(card,11)
    stroke(card, fish.discovered and (rarityColors[fish.rarity] or C.muted) or Color3.fromRGB(60,66,73), fish.discovered and .42 or .68, 1)

    makePreview(card, fish)

    local name = label(card, fish.discovered and fish.name or "???", 11, Enum.Font.GothamBlack, fish.discovered and C.text or C.muted)
    name.Position = UDim2.fromOffset(9,93)
    name.Size = UDim2.new(1,-18,0,18)
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.ZIndex = 89

    local rarity = label(card, fish.rarity or "", 8, Enum.Font.GothamBlack, rarityColors[fish.rarity] or C.muted)
    rarity.AnchorPoint = Vector2.new(1,0)
    rarity.Position = UDim2.new(1,-9,0,94)
    rarity.Size = UDim2.fromOffset(75,14)
    rarity.TextXAlignment = Enum.TextXAlignment.Right
    rarity.ZIndex = 90

    local detail
    if fish.discovered then
        detail = string.format("BEST %.2f kg  •  x%d", tonumber(fish.best) or 0, tonumber(fish.count) or 0)
    else
        detail = "NOT DISCOVERED"
    end
    local meta = label(card, detail, 8, Enum.Font.GothamBold, fish.discovered and C.gold or C.muted)
    meta.Position = UDim2.fromOffset(9,116)
    meta.Size = UDim2.new(1,-18,0,14)
    meta.TextXAlignment = Enum.TextXAlignment.Left
    meta.TextTruncate = Enum.TextTruncate.AtEnd
    meta.ZIndex = 89

    if fish.discovered and fish.bestMutation and fish.bestMutation ~= "" and fish.bestMutation ~= "NORMAL" then
        local mut = label(card, mutationNames[fish.bestMutation] or fish.bestMutation, 8, Enum.Font.GothamBlack, C.muted)
        mut.Position = UDim2.fromOffset(9,132)
        mut.Size = UDim2.new(1,-18,0,11)
        mut.TextXAlignment = Enum.TextXAlignment.Left
        mut.ZIndex = 89
    end
end

local function clearCards()
    for _, child in ipairs(visualScroll:GetChildren()) do
        if child ~= grid and child ~= pad then child:Destroy() end
    end
end

local lastSnapshot
local function renderVisualIndex(data)
    if type(data) ~= "table" or type(data.species) ~= "table" then return end
    lastSnapshot = data
    clearCards()
    for i, fish in ipairs(data.species) do
        fishCard(fish, i)
    end
    visualScroll.CanvasPosition = Vector2.new(0,0)
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Snapshot" then
        task.defer(renderVisualIndex, payload)
    end
end)

-- If v4 already received a snapshot before this script loaded, request a fresh one only when
-- the journal becomes visible. This keeps network traffic negligible.
local actionRemote = v4Folder:FindFirstChild("Action")
local lastVisible = journal.Visible
journal:GetPropertyChangedSignal("Visible"):Connect(function()
    if journal.Visible and not lastVisible and actionRemote then
        actionRemote:FireServer("RequestJournal")
    end
    lastVisible = journal.Visible
end)

journal:SetAttribute("VisualFishIndexV7", true)
journal:SetAttribute("IndexUsesViewportFishImagesV7", true)
journal:SetAttribute("LockedFishUseSilhouetteV7", true)
journal:SetAttribute("VisualIndexSimpleTwoColumnV7", true)

print("[BBYA] Visual Fish Index v7 online: 3D fish thumbnails + locked silhouettes")
