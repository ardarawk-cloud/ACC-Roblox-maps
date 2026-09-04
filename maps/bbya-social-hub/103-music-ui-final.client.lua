-- BBYA MUSIC SUITE v1.2 — PREMIUM UI PHASE 2 + NATIVE MALL KPOP
-- Mobile-landscape cleanup: fixed sidebar, compact library, clean Now Playing, bounded Up Next/Queue.
-- Server audio authority is unchanged; only player-facing music UI is replaced.
-- v1.2 removes the full-screen dim backdrop and avoids blocking startup on late Mall remotes.

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
local clubGui = pg:WaitForChild("BBYAClubUI", 30)
if not clubGui then return end
local hub = clubGui:WaitForChild("HubPanel", 30)
if not hub then return end
local remotes = RS:WaitForChild("BBYAClubRemotes", 30)
if not remotes then return end
local music = remotes:WaitForChild("Music", 30)
local stateRemote = remotes:WaitForChild("State", 30)
-- Mall music is optional at initial client startup. Do not stall the entire Music Suite
-- for up to 30 seconds while waiting for this remote; bind it when/if it arrives.
local mallControl = RS:FindFirstChild("BBYAMallMusicControl")

local C = {
    bg = Color3.fromRGB(7, 8, 12),
    panel = Color3.fromRGB(14, 15, 21),
    card = Color3.fromRGB(21, 22, 30),
    card2 = Color3.fromRGB(29, 30, 40),
    line = Color3.fromRGB(68, 71, 86),
    white = Color3.fromRGB(247, 247, 250),
    muted = Color3.fromRGB(146, 150, 164),
    purple = Color3.fromRGB(142, 77, 255),
    pink = Color3.fromRGB(235, 51, 165),
    cyan = Color3.fromRGB(38, 200, 225),
    green = Color3.fromRGB(73, 215, 143),
    gold = Color3.fromRGB(232, 181, 82),
}

local V = {
    MAIN = {label = "MAIN CLUB", accent = C.pink, group = "BBYAClubMaster"},
    UNDERGROUND = {label = "UNDERGROUND", accent = C.cyan, group = "BBYABasementMaster"},
    VIP = {label = "VIP", accent = C.gold, group = "BBYAVIPMaster"},
    FUNKOT = {label = "FUNKOT", accent = C.purple, group = "BBYAFunkotMaster"},
    SKATEPARK = {label = "SKATEPARK", accent = C.cyan, group = "BBYASkateparkMaster"},
    ROOFTOP = {label = "ROOFTOP", accent = C.gold, group = "BBYARooftopMaster"},
    MALL = {label = "MALL", accent = C.gold, group = "BBYAMallMaster"},
    NONE = {label = "BBYA MUSIC", accent = C.purple},
}

local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 9)
    c.Parent = o
    return c
end

local function stroke(o, col, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or C.line
    s.Thickness = 1
    s.Transparency = tr or 0.5
    s.Parent = o
    return s
end

local function label(p, n, t, pos, size, font, ts, col, align)
    local x = Instance.new("TextLabel")
    x.Name = n
    x.BackgroundTransparency = 1
    x.Text = t
    x.Position = pos
    x.Size = size
    x.Font = font or Enum.Font.Gotham
    x.TextSize = ts or 11
    x.TextColor3 = col or C.white
    x.TextXAlignment = align or Enum.TextXAlignment.Left
    x.TextYAlignment = Enum.TextYAlignment.Center
    x.TextTruncate = Enum.TextTruncate.AtEnd
    x.Parent = p
    return x
end

local function btn(p, n, t, pos, size, bg)
    local b = Instance.new("TextButton")
    b.Name = n
    b.Text = t
    b.Position = pos
    b.Size = size
    b.BackgroundColor3 = bg or C.card
    b.BackgroundTransparency = 0.06
    b.BorderSizePixel = 0
    b.TextColor3 = C.white
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.AutoButtonColor = true
    b.Parent = p
    corner(b, 8)
    stroke(b, C.line, 0.55)
    return b
end

local function isAdmin()
    return player:GetAttribute("BBYAAdmin") == true
        or (game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId)
end

local function venueAt(p)
    if p.Y < -4.5 then return "UNDERGROUND" end
    if p.Y >= 40 and p.Y <= 60 and math.abs(p.X) <= 62 and p.Z >= -48 and p.Z <= 48 then return "ROOFTOP" end
    if p.Y >= 20 and p.Y < 40 and math.abs(p.X) <= 58 and p.Z >= -46 and p.Z <= 46 then return "VIP" end
    if p.Y > -4 and p.Y < 34 and math.abs(p.X) < 61 and p.Z > 157 and p.Z < 253 then return "FUNKOT" end
    if p.Y > -4 and p.Y < 20 and math.abs(p.X) <= 61 and p.Z >= 72 and p.Z <= 152 then return "SKATEPARK" end
    if p.Y >= -4 and p.Y <= 70 and p.X >= -96 and p.X <= 96 and p.Z >= 287 and p.Z <= 443 then return "MALL" end
    if p.Y > -4 and p.Y < 18 and math.abs(p.X) <= 61 and p.Z >= 0 and p.Z < 70 then return "MAIN" end
    return "NONE"
end

local function venue()
    local a = tostring(player:GetAttribute("BBYAAudioVenue") or "")
    if V[a] then return a end
    local ch = player.Character
    local h = ch and ch:FindFirstChild("HumanoidRootPart")
    return h and venueAt(h.Position) or "NONE"
end

local legacyCard = hub:FindFirstChild("PlayerCard", true)
local legacy = legacyCard and legacyCard.Parent
if legacy then legacy.Visible=false end
local old = pg:FindFirstChild("BBYAMusicSuiteV1")
if old then old:Destroy() end
local compact = clubGui:FindFirstChild("BBYACompactMusicLayerV7")
if compact then compact:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "BBYAMusicSuiteV1"
gui.ResetOnSpawn = false
gui.DisplayOrder = 930
gui.Enabled = false
gui.Parent = pg

local dim = Instance.new("Frame")
dim.Name = "Backdrop"
dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = Color3.new(0, 0, 0)
dim.BackgroundTransparency = 1
dim.BorderSizePixel = 0
dim.Parent = gui

local shell = Instance.new("Frame")
shell.AnchorPoint = Vector2.new(0.5, 0.5)
shell.Position = UDim2.fromScale(0.5, 0.52)
shell.Size = UDim2.new(0.95, 0, 0.84, 0)
shell.BackgroundColor3 = C.bg
shell.BorderSizePixel = 0
shell.Parent = dim
corner(shell, 14)
local shellStroke = stroke(shell, C.purple, 0.28)

local side = Instance.new("Frame")
side.BackgroundColor3 = C.panel
side.BorderSizePixel = 0
side.Parent = shell
corner(side, 14)

local brand = label(side, "Brand", "BBYA", UDim2.fromOffset(18, 14), UDim2.new(1, -36, 0, 26), Enum.Font.GothamBlack, 22, C.white)
label(side, "Sub", "M U S I C", UDim2.fromOffset(18, 38), UDim2.new(1, -36, 0, 16), Enum.Font.GothamBold, 7, C.muted)

local venueCard = Instance.new("Frame")
venueCard.Position = UDim2.fromOffset(14, 64)
venueCard.Size = UDim2.new(1, -28, 0, 52)
venueCard.BackgroundColor3 = C.card
venueCard.BorderSizePixel = 0
venueCard.Parent = side
corner(venueCard, 9)
local venueStroke = stroke(venueCard, C.cyan, 0.45)
local venueText = label(venueCard, "Venue", "BBYA MUSIC", UDim2.fromOffset(12, 7), UDim2.new(1, -24, 0, 20), Enum.Font.GothamBold, 9, C.white)
label(venueCard, "Hint", "CURRENT VENUE", UDim2.fromOffset(12, 28), UDim2.new(1, -24, 0, 15), Enum.Font.GothamBold, 6, C.muted)

local nav = Instance.new("Frame")
nav.Position = UDim2.fromOffset(14, 130)
nav.Size = UDim2.new(1, -28, 0, 146)
nav.BackgroundTransparency = 1
nav.Parent = side
local navLayout = Instance.new("UIListLayout")
navLayout.Padding = UDim.new(0, 7)
navLayout.Parent = nav

local navB = {}
local function navButton(k, t)
    local b = btn(nav, "Nav" .. k, "   " .. t, UDim2.new(), UDim2.new(1, 0, 0, 44), C.card)
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextSize = 9
    navB[k] = b
    return b
end
navButton("LIBRARY", "LIBRARY")
navButton("NOW", "NOW PLAYING")
navButton("QUEUE", "QUEUE")

local status = Instance.new("Frame")
status.Size = UDim2.new(1, -28, 0, 50)
status.BackgroundColor3 = C.card
status.BorderSizePixel = 0
status.Parent = side
corner(status, 9)
label(status, "SL", "LIBRARY STATUS", UDim2.fromOffset(12, 5), UDim2.new(1, -24, 0, 15), Enum.Font.GothamBold, 6, C.muted)
local statusValue = label(status, "SV", "0 TRACKS READY", UDim2.fromOffset(12, 21), UDim2.new(1, -24, 0, 20), Enum.Font.GothamBold, 8, C.green)

local content = Instance.new("Frame")
content.BackgroundTransparency = 1
content.Parent = shell

local header = Instance.new("Frame")
header.Position = UDim2.fromOffset(22, 14)
header.Size = UDim2.new(1, -44, 0, 42)
header.BackgroundTransparency = 1
header.Parent = content
local sectionTitle = label(header, "SectionTitle", "LIBRARY", UDim2.new(), UDim2.new(0.55, 0, 1, 0), Enum.Font.GothamBlack, 20, C.white)
local close = btn(header, "Close", "×", UDim2.new(1, -36, 0, 3), UDim2.fromOffset(34, 34), C.card2)
close.TextSize = 20

local pages = {}
local function page(n)
    local p = Instance.new("Frame")
    p.Name = n
    p.Position = UDim2.fromOffset(22, 62)
    p.Size = UDim2.new(1, -44, 1, -78)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.Parent = content
    pages[n] = p
    return p
end

local lib = page("LIBRARY")
local now = page("NOW")
local queue = page("QUEUE")

-- LIBRARY
local search = Instance.new("TextBox")
search.Position = UDim2.fromOffset(0, 0)
search.Size = UDim2.new(1, 0, 0, 38)
search.BackgroundColor3 = C.card
search.BorderSizePixel = 0
search.PlaceholderText = "Search songs..."
search.PlaceholderColor3 = C.muted
search.Text = ""
search.TextColor3 = C.white
search.Font = Enum.Font.Gotham
search.TextSize = 10
search.TextXAlignment = Enum.TextXAlignment.Left
search.ClearTextOnFocus = false
search.Parent = lib
corner(search, 8)
stroke(search, C.line, 0.5)
local searchPad = Instance.new("UIPadding")
searchPad.PaddingLeft = UDim.new(0, 13)
searchPad.PaddingRight = UDim.new(0, 13)
searchPad.Parent = search

local chips = Instance.new("Frame")
chips.Position = UDim2.fromOffset(0, 47)
chips.Size = UDim2.new(1, 0, 0, 38)
chips.BackgroundTransparency = 1
chips.Parent = lib
local chipLayout = Instance.new("UIListLayout")
chipLayout.FillDirection = Enum.FillDirection.Horizontal
chipLayout.Padding = UDim.new(0, 8)
chipLayout.Parent = chips

local stat = {}
local function chip(k, h, v, col)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.333, -6, 1, 0)
    f.BackgroundColor3 = C.card
    f.BorderSizePixel = 0
    f.Parent = chips
    corner(f, 8)
    stroke(f, col, 0.68)
    label(f, "H", h, UDim2.fromOffset(10, 3), UDim2.new(0.54, -10, 1, -6), Enum.Font.GothamBold, 6, C.muted)
    stat[k] = label(f, "V", v, UDim2.new(0.54, 0, 0, 3), UDim2.new(0.46, -10, 1, -6), Enum.Font.GothamBlack, 10, col, Enum.TextXAlignment.Right)
end
chip("TRACKS", "TRACKS", "0", C.purple)
chip("VENUE", "VENUE", "--", C.cyan)
chip("QUEUE", "QUEUE", "0", C.gold)

local libMeta = label(lib, "Meta", "0 TRACKS", UDim2.fromOffset(0, 90), UDim2.new(1, 0, 0, 18), Enum.Font.GothamBold, 7, C.muted, Enum.TextXAlignment.Right)
local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(0, 110)
list.Size = UDim2.new(1, 0, 1, -110)
list.BackgroundColor3 = C.panel
list.BackgroundTransparency = 0.12
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.fromOffset(0, 0)
list.Parent = lib
corner(list, 10)
stroke(list, C.line, 0.6)
local lp = Instance.new("UIPadding")
lp.PaddingTop = UDim.new(0, 6)
lp.PaddingBottom = UDim.new(0, 6)
lp.PaddingLeft = UDim.new(0, 6)
lp.PaddingRight = UDim.new(0, 6)
lp.Parent = list
local ll = Instance.new("UIListLayout")
ll.Padding = UDim.new(0, 4)
ll.Parent = list

-- NOW PLAYING
local nowCard = Instance.new("Frame")
nowCard.Position = UDim2.new(0, 0, 0, 0)
nowCard.Size = UDim2.new(0.64, -6, 1, 0)
nowCard.BackgroundColor3 = C.panel
nowCard.BorderSizePixel = 0
nowCard.Parent = now
corner(nowCard, 12)
stroke(nowCard, C.purple, 0.55)

local art = Instance.new("Frame")
art.Position = UDim2.fromOffset(18, 18)
art.Size = UDim2.new(0.28, -10, 0, 150)
art.BackgroundColor3 = Color3.fromRGB(27, 16, 47)
art.BorderSizePixel = 0
art.Parent = nowCard
corner(art, 11)
local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new(Color3.fromRGB(70, 30, 120), Color3.fromRGB(17, 18, 27))
grad.Rotation = 135
grad.Parent = art
label(art, "Brand", "BBYA", UDim2.new(0.1, 0, 0.28, 0), UDim2.new(0.8, 0, 0, 34), Enum.Font.GothamBlack, 23, C.white, Enum.TextXAlignment.Center)
local artVenue = label(art, "Venue", "BBYA MUSIC", UDim2.new(0.08, 0, 0.55, 0), UDim2.new(0.84, 0, 0, 18), Enum.Font.GothamBold, 7, C.cyan, Enum.TextXAlignment.Center)

local nowInfo = Instance.new("Frame")
nowInfo.Position = UDim2.new(0.31, 8, 0, 18)
nowInfo.Size = UDim2.new(0.69, -26, 0, 150)
nowInfo.BackgroundTransparency = 1
nowInfo.Parent = nowCard
local nowState = label(nowInfo, "State", "STANDBY", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 20), Enum.Font.GothamBold, 8, C.green)
local nowTitle = label(nowInfo, "Track", "BELUM ADA LAGU", UDim2.fromOffset(0, 24), UDim2.new(1, 0, 0, 62), Enum.Font.GothamBlack, 16, C.white)
nowTitle.TextWrapped = true
nowTitle.TextYAlignment = Enum.TextYAlignment.Top
nowTitle.TextTruncate = Enum.TextTruncate.AtEnd
local nowMeta = label(nowInfo, "Meta", "BBYA MUSIC", UDim2.fromOffset(0, 90), UDim2.new(1, 0, 0, 18), Enum.Font.GothamBold, 7, C.muted)

local wave = Instance.new("Frame")
wave.Position = UDim2.fromOffset(0, 116)
wave.Size = UDim2.new(1, 0, 0, 28)
wave.BackgroundTransparency = 1
wave.Parent = nowInfo
local bars = {}
for i = 1, 16 do
    local b = Instance.new("Frame")
    b.AnchorPoint = Vector2.new(0.5, 1)
    b.Position = UDim2.new((i - 0.5) / 16, 0, 1, 0)
    b.Size = UDim2.new(0.034, 0, 0, 4)
    b.BackgroundColor3 = i % 4 == 0 and C.cyan or C.purple
    b.BorderSizePixel = 0
    b.Parent = wave
    corner(b, 3)
    bars[i] = b
end

local pb = Instance.new("Frame")
pb.Position = UDim2.new(0, 18, 1, -91)
pb.Size = UDim2.new(1, -36, 0, 5)
pb.BackgroundColor3 = C.card2
pb.BorderSizePixel = 0
pb.Parent = nowCard
corner(pb, 4)
local pf = Instance.new("Frame")
pf.Size = UDim2.new(0, 0, 1, 0)
pf.BackgroundColor3 = C.purple
pf.BorderSizePixel = 0
pf.Parent = pb
corner(pf, 4)
local elapsed = label(nowCard, "Elapsed", "00:00", UDim2.new(0, 18, 1, -82), UDim2.new(0.2, 0, 0, 16), Enum.Font.GothamBold, 7, C.muted)
local duration = label(nowCard, "Duration", "00:00", UDim2.new(0.8, -18, 1, -82), UDim2.new(0.2, 0, 0, 16), Enum.Font.GothamBold, 7, C.muted, Enum.TextXAlignment.Right)

local controls = Instance.new("Frame")
controls.Position = UDim2.new(0, 18, 1, -58)
controls.Size = UDim2.new(1, -36, 0, 40)
controls.BackgroundTransparency = 1
controls.Parent = nowCard
local controlLayout = Instance.new("UIListLayout")
controlLayout.FillDirection = Enum.FillDirection.Horizontal
controlLayout.Padding = UDim.new(0, 8)
controlLayout.Parent = controls
local mute = btn(controls, "Mute", "MUTE", UDim2.new(), UDim2.new(0.32, -5, 1, 0), C.card2)
local prev = btn(controls, "Prev", "PREV", UDim2.new(), UDim2.new(0.32, -5, 1, 0), C.card2)
local nextB = btn(controls, "Next", "NEXT", UDim2.new(), UDim2.new(0.36, -6, 1, 0), Color3.fromRGB(57, 33, 92))

local up = Instance.new("Frame")
up.Position = UDim2.new(0.64, 6, 0, 0)
up.Size = UDim2.new(0.36, -6, 1, 0)
up.BackgroundColor3 = C.panel
up.BorderSizePixel = 0
up.Parent = now
corner(up, 12)
stroke(up, C.line, 0.58)
label(up, "Title", "UP NEXT", UDim2.fromOffset(14, 10), UDim2.new(1, -28, 0, 24), Enum.Font.GothamBlack, 11, C.white)
local upList = Instance.new("ScrollingFrame")
upList.Position = UDim2.fromOffset(12, 40)
upList.Size = UDim2.new(1, -24, 1, -52)
upList.BackgroundTransparency = 1
upList.BorderSizePixel = 0
upList.ScrollBarThickness = 2
upList.AutomaticCanvasSize = Enum.AutomaticSize.Y
upList.CanvasSize = UDim2.fromOffset(0, 0)
upList.Parent = up
local ul = Instance.new("UIListLayout")
ul.Padding = UDim.new(0, 5)
ul.Parent = upList

-- QUEUE
local queueMeta = label(queue, "Meta", "0 REQUESTS", UDim2.new(0.5, 0, 0, 0), UDim2.new(0.5, 0, 0, 20), Enum.Font.GothamBold, 7, C.muted, Enum.TextXAlignment.Right)
local qp = Instance.new("Frame")
qp.Position = UDim2.fromOffset(0, 28)
qp.Size = UDim2.new(1, 0, 1, -28)
qp.BackgroundColor3 = C.panel
qp.BorderSizePixel = 0
qp.Parent = queue
corner(qp, 11)
stroke(qp, C.line, 0.58)
local qList = Instance.new("ScrollingFrame")
qList.Position = UDim2.fromOffset(14, 14)
qList.Size = UDim2.new(1, -28, 1, -28)
qList.BackgroundTransparency = 1
qList.BorderSizePixel = 0
qList.ScrollBarThickness = 2
qList.AutomaticCanvasSize = Enum.AutomaticSize.Y
qList.CanvasSize = UDim2.fromOffset(0, 0)
qList.Parent = qp
local ql = Instance.new("UIListLayout")
ql.Padding = UDim.new(0, 6)
ql.Parent = qList

local S = {tracks = {}, title = "", index = 0, playing = false, queue = 0, nextRequest = 0, autoNext = 0}

local function mallTracks()
    local folder = RS:FindFirstChild("BBYAMallPlaylistCatalog")
    if not folder then return {} end
    local indexed = {}
    for _, row in ipairs(folder:GetChildren()) do
        if row:IsA("StringValue") then
            local i = tonumber(row:GetAttribute("Index"))
            if i then
                indexed[i] = {
                    title = row.Value,
                    assetId = tostring(row:GetAttribute("AssetId") or ""),
                    playbackSpeed = tonumber(row:GetAttribute("PlaybackSpeed")) or 1,
                    style = "KPOP • RANDOM MIX",
                }
            end
        end
    end
    local out = {}
    for i=1,#indexed do if indexed[i] then table.insert(out,indexed[i]) end end
    return out
end

local function syncMall()
    if venue() ~= "MALL" then return false end
    local tracks = mallTracks()
    if #tracks > 0 then S.tracks = tracks end
    S.index = tonumber(RS:GetAttribute("BBYAMallCurrentIndex")) or 1
    S.title = tostring(RS:GetAttribute("BBYAMallCurrentTitle") or "")
    S.queue = tonumber(RS:GetAttribute("BBYAMallQueueCount")) or 0
    S.nextRequest = tonumber(RS:GetAttribute("BBYAMallNextRequestIndex")) or 0
    S.autoNext = tonumber(RS:GetAttribute("BBYAMallAutoNextIndex")) or 0
    local sound = SS:FindFirstChild("BBYAMallMasterSound")
    S.playing = sound and sound:IsA("Sound") and sound.IsPlaying or false
    return true
end

local function clear(p, prefix)
    for _, x in ipairs(p:GetChildren()) do
        if x.Name:sub(1, #prefix) == prefix then x:Destroy() end
    end
end

local function mini(p, n, no, titleText, meta, col)
    local r = Instance.new("Frame")
    r.Name = n
    r.Size = UDim2.new(1, -2, 0, 46)
    r.BackgroundColor3 = C.card
    r.BackgroundTransparency = 0.08
    r.BorderSizePixel = 0
    r.Parent = p
    corner(r, 8)
    label(r, "No", tostring(no), UDim2.fromOffset(4, 0), UDim2.fromOffset(28, 46), Enum.Font.GothamBlack, 8, col, Enum.TextXAlignment.Center)
    label(r, "T", titleText, UDim2.fromOffset(38, 4), UDim2.new(1, -44, 0, 22), Enum.Font.GothamBold, 8, C.white)
    label(r, "M", meta, UDim2.fromOffset(38, 24), UDim2.new(1, -44, 0, 16), Enum.Font.GothamBold, 6, C.muted)
    return r
end

local function accent()
    return (V[venue()] or V.NONE).accent
end

local function requestList()
    local v = venue()
    if v == "MAIN" or v == "UNDERGROUND" then
        music:FireServer("list")
    elseif v == "MALL" then
        syncMall()
    end
end

local function request(i)
    local v = venue()
    if v == "MAIN" or v == "UNDERGROUND" then
        music:FireServer("request",i)
    elseif v == "MALL" and mallControl then
        mallControl:FireServer("request",i)
    end
end

local function refreshChrome()
    local v = venue()
    local s = V[v] or V.NONE
    venueText.Text = s.label
    venueStroke.Color = s.accent
    shellStroke.Color = s.accent
    stat.VENUE.Text = s.label
    stat.VENUE.TextColor3 = s.accent
    artVenue.Text = s.label
    artVenue.TextColor3 = s.accent
end

local function rebuildLibrary()
    clear(list, "Track_")
    local q = string.lower(search.Text or "")
    local shown = 0
    local a = accent()
    for i, item in ipairs(S.tracks) do
        local titleText = tostring(item.title or ("Track " .. i))
        local meta = tostring(item.style or item.genre or "BBYA MUSIC")
        if q == "" or string.find(string.lower(titleText .. " " .. meta), q, 1, true) then
            shown += 1
            local r = Instance.new("Frame")
            r.Name = "Track_" .. i
            r.LayoutOrder = i
            r.Size = UDim2.new(1, -2, 0, 42)
            r.BackgroundColor3 = C.card
            r.BorderSizePixel = 0
            r.Parent = list
            corner(r, 8)
            local playing = S.playing and S.index == i
            if playing then stroke(r, a, 0.25) end
            label(r, "No", string.format("%02d", i), UDim2.fromOffset(5, 0), UDim2.fromOffset(34, 42), Enum.Font.GothamBold, 7, playing and a or C.muted, Enum.TextXAlignment.Center)
            label(r, "Title", titleText, UDim2.fromOffset(45, 3), UDim2.new(1, -180, 0, 21), Enum.Font.GothamBold, 9, C.white)
            label(r, "Meta", string.upper(meta), UDim2.fromOffset(45, 22), UDim2.new(1, -180, 0, 15), Enum.Font.GothamBold, 6, C.muted)
            if playing then
                label(r, "Playing", "PLAYING", UDim2.new(1, -204, 0, 0), UDim2.fromOffset(70, 42), Enum.Font.GothamBold, 6, a, Enum.TextXAlignment.Center)
            end
            local b = btn(r, "Req", "REQUEST", UDim2.new(1, -118, 0, 6), UDim2.fromOffset(104, 30), Color3.fromRGB(49, 32, 70))
            b.TextSize = 7
            if playing then
                b.Active = false
                b.AutoButtonColor = false
                b.TextColor3 = C.muted
            else
                b.Activated:Connect(function() request(i) end)
            end
        end
    end
    libMeta.Text = string.format("%d / %d TRACKS", shown, #S.tracks)
    statusValue.Text = tostring(#S.tracks) .. " TRACKS READY"
    stat.TRACKS.Text = tostring(#S.tracks)
    stat.QUEUE.Text = tostring(S.queue or 0)
end

local function rebuildUp()
    clear(upList, "Next_")
    if #S.tracks == 0 then
        mini(upList, "Next_Empty", "--", "PLAYLIST KOSONG", "Belum ada track tersedia", C.muted)
        return
    end
    local used = {}
    local order = 0
    local first = tonumber(S.nextRequest) or 0
    if first > 0 and S.tracks[first] then
        order += 1
        used[first] = true
        mini(upList, "Next_" .. order, order, tostring(S.tracks[first].title or "Request"), "REQUEST QUEUE", C.gold)
    end
    local cur = math.max(S.index or 0, 0)
    while order < 5 and order < #S.tracks do
        cur = (cur % #S.tracks) + 1
        if not used[cur] then
            order += 1
            used[cur] = true
            mini(upList, "Next_" .. order, order, tostring(S.tracks[cur].title or ("Track " .. cur)), "AUTO DJ", accent())
        end
    end
end

local function rebuildQueue()
    clear(qList, "Queue_")
    queueMeta.Text = tostring(S.queue or 0) .. " REQUESTS"
    if (S.queue or 0) == 0 then
        mini(qList, "Queue_Empty", "--", "REQUEST QUEUE KOSONG", "Pilih lagu di Library lalu tekan REQUEST", C.muted)
    elseif (S.nextRequest or 0) > 0 and S.tracks[S.nextRequest] then
        mini(qList, "Queue_1", "01", tostring(S.tracks[S.nextRequest].title or "Requested track"), "NEXT REQUEST", C.gold)
        mini(qList, "Queue_Info", "+", tostring(math.max(0, S.queue - 1)) .. " REQUEST LAIN", "Urutan disimpan server", accent())
    else
        mini(qList, "Queue_Info", "+", tostring(S.queue) .. " REQUEST", "Antrean aktif di server", accent())
    end
end

local function refreshNow()
    local s = V[venue()] or V.NONE
    local t = S.title
    if t == "" and S.index > 0 and S.tracks[S.index] then
        t = tostring(S.tracks[S.index].title or "")
    end
    if t == "" then t = "BELUM ADA LAGU" end
    nowTitle.Text = t
    nowMeta.Text = s.label .. "  •  " .. tostring(#S.tracks) .. " TRACKS"
    nowState.Text = S.playing and "LIVE • PLAYING" or "STANDBY"
    nowState.TextColor3 = S.playing and C.green or C.muted
    mute.Text = player:GetAttribute("BBYAMusicMuted") == true and "UNMUTE" or "MUTE"
    prev.Visible = isAdmin()
    nextB.Visible = isAdmin()
    rebuildUp()
    rebuildQueue()
end

local function refresh()
    refreshChrome()
    rebuildLibrary()
    refreshNow()
end

local function switch(k)
    for n, p in pairs(pages) do p.Visible = n == k end
    for n, b in pairs(navB) do
        b.BackgroundColor3 = n == k and Color3.fromRGB(54, 32, 84) or C.card
        b.TextColor3 = n == k and C.white or C.muted
    end
    sectionTitle.Text = k == "NOW" and "NOW PLAYING" or k
end

local activeSound
local lastSoundScan = 0
local function findSound()
    local nowClock = os.clock()
    if activeSound and activeSound.Parent and activeSound.IsPlaying then return activeSound end
    if nowClock - lastSoundScan < 0.5 then return activeSound end
    lastSoundScan = nowClock

    local v = venue()
    local info = V[v]
    if not info or not info.group then
        activeSound = nil
        return nil
    end

    local group = SS:FindFirstChild(info.group)
    local known = {
        MAIN = {"BBYAClubDeckA", "BBYAClubDeckB"},
        UNDERGROUND = {"BBYABasementDeckA", "BBYABasementDeckB"},
        FUNKOT = {"BBYAFunkotDeck"},
        MALL = {"BBYAMallMasterSound"},
    }
    for _, n in ipairs(known[v] or {}) do
        local x = SS:FindFirstChild(n, true) or workspace:FindFirstChild(n, true)
        if x and x:IsA("Sound") and x.IsPlaying then
            activeSound = x
            return x
        end
    end

    for _, root in ipairs({SS, workspace}) do
        for _, x in ipairs(root:GetDescendants()) do
            if x:IsA("Sound") and x.IsPlaying and (x.SoundGroup == group or x.Name:find("BBYA")) then
                activeSound = x
                return x
            end
        end
    end
    activeSound = nil
    return nil
end

local function fmt(sec)
    sec = math.max(0, math.floor(tonumber(sec) or 0))
    return string.format("%02d:%02d", math.floor(sec / 60), sec % 60)
end

navB.LIBRARY.Activated:Connect(function() switch("LIBRARY") end)
navB.NOW.Activated:Connect(function() switch("NOW") end)
navB.QUEUE.Activated:Connect(function() switch("QUEUE") end)
search:GetPropertyChangedSignal("Text"):Connect(rebuildLibrary)

mute.Activated:Connect(function()
    player:SetAttribute("BBYAMusicMuted", not (player:GetAttribute("BBYAMusicMuted") == true))
    refreshNow()
end)

prev.Activated:Connect(function()
    local v = venue()
    if not isAdmin() then return end
    if v == "MALL" and mallControl then
        mallControl:FireServer("prev")
    elseif (v == "MAIN" or v == "UNDERGROUND") and #S.tracks > 0 then
        local i = ((math.max(S.index, 1) - 2) % #S.tracks) + 1
        music:FireServer("play", i)
    end
end)

nextB.Activated:Connect(function()
    local v = venue()
    if not isAdmin() then return end
    if v == "MALL" and mallControl then
        mallControl:FireServer("next")
    elseif v == "MAIN" or v == "UNDERGROUND" then
        music:FireServer("next")
    end
end)

close.Activated:Connect(function() gui.Enabled = false end)

local function open()
    if legacy then legacy.Visible=false end
    hub.Visible = false
    gui.Enabled = true
    requestList()
    refresh()
    switch("LIBRARY")
end

stateRemote.OnClientEvent:Connect(function(kind, data)
    if kind == "playlist" and type(data) == "table" then
        if venue() ~= "MALL" then S.tracks = data end
        if gui.Enabled then refresh() end
    elseif kind == "music" and type(data) == "table" then
        local v = tostring(data.venue or venue())
        if v == "BASEMENT" then v = "UNDERGROUND" end
        if v == venue() or venue() == "NONE" then
            S.index = tonumber(data.index) or S.index
            S.title = tostring(data.title or S.title or "")
            S.playing = data.playing == true
            S.queue = tonumber(data.queue) or 0
            S.nextRequest = tonumber(data.nextRequest) or 0
            activeSound = nil
            if gui.Enabled then refresh() end
        end
    end
end)

player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()
    activeSound = nil
    if gui.Enabled then requestList(); refresh() end
end)
player:GetAttributeChangedSignal("BBYAAdmin"):Connect(function() if gui.Enabled then refreshNow() end end)
player:GetAttributeChangedSignal("BBYAMusicMuted"):Connect(function() if gui.Enabled then refreshNow() end end)

for _, attr in ipairs({
    "BBYAMallPlaylistCount", "BBYAMallCurrentIndex", "BBYAMallCurrentTitle",
    "BBYAMallCurrentAssetId", "BBYAMallQueueCount", "BBYAMallNextRequestIndex",
    "BBYAMallAutoNextIndex", "BBYAMallShuffleRemaining",
}) do
    RS:GetAttributeChangedSignal(attr):Connect(function()
        if venue() == "MALL" then
            syncMall()
            if gui.Enabled then refresh() end
        end
    end)
end

RS.ChildAdded:Connect(function(child)
    if child.Name == "BBYAMallMusicControl" then
        mallControl = child
    elseif child.Name == "BBYAMallPlaylistCatalog" and venue() == "MALL" then
        task.defer(function()
            syncMall()
            if gui.Enabled then refresh() end
        end)
    end
end)

local bound = {}
local function bind()
    local m = pg:FindFirstChild("BBYACommandMenuUI")
    local d = m and m:FindFirstChild("FeatureDrawer")
    local slot = d and d:FindFirstChild("Slot_MUSIC", true)
    if not slot then return end
    for _, x in ipairs(slot:GetDescendants()) do
        if x:IsA("TextButton") and not bound[x] then
            bound[x] = true
            x.Activated:Connect(function() task.defer(open) end)
        end
    end
end

pg.DescendantAdded:Connect(function(obj)
    if obj.Name == "BBYACommandMenuUI" or obj.Name == "FeatureDrawer" or obj.Name == "Slot_MUSIC" or obj:IsA("TextButton") then
        task.defer(bind)
    end
end)
if legacy then
    legacy:GetPropertyChangedSignal("Visible"):Connect(function()
        if legacy.Visible then task.defer(open) end
    end)
end

local cam = workspace.CurrentCamera
local function layout()
    cam = workspace.CurrentCamera or cam
    local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
    local sideW = vp.X < 1000 and 156 or 180
    local shellH = vp.Y < 620 and 0.88 or 0.84
    shell.Size = UDim2.new(0.95, 0, shellH, 0)
    side.Size = UDim2.new(0, sideW, 1, 0)
    content.Position = UDim2.fromOffset(sideW, 0)
    content.Size = UDim2.new(1, -sideW, 1, 0)
    brand.TextSize = vp.X < 900 and 18 or 22
    nowTitle.TextSize = vp.X < 900 and 13 or 16
    status.Position = UDim2.new(0, 14, 1, -64)
    art.Visible = vp.X >= 820
    if art.Visible then
        nowInfo.Position = UDim2.new(0.31, 8, 0, 18)
        nowInfo.Size = UDim2.new(0.69, -26, 0, 150)
    else
        nowInfo.Position = UDim2.fromOffset(18, 18)
        nowInfo.Size = UDim2.new(1, -36, 0, 150)
    end
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    cam = workspace.CurrentCamera
    if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(layout) end
    layout()
end)
if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(layout) end

local acc = 0
RunService.RenderStepped:Connect(function(dt)
    if not gui.Enabled then return end
    acc += dt
    if acc < 0.1 then return end
    acc = 0
    if venue() == "MALL" then syncMall() end
    local s = findSound()
    local loud = s and s.PlaybackLoudness or 0
    local norm = math.clamp(loud / 600, 0, 1)
    for i, b in ipairs(bars) do
        local center = 1 - math.abs((i - 8.5) / 8.5)
        b.Size = UDim2.new(0.034, 0, 0, 4 + math.floor(norm * 24 * (0.55 + 0.45 * center)))
    end
    if s then
        local len = tonumber(s.TimeLength) or 0
        local pos = tonumber(s.TimePosition) or 0
        pf.Size = UDim2.new(len > 0 and math.clamp(pos / len, 0, 1) or 0, 0, 1, 0)
        elapsed.Text = fmt(pos)
        duration.Text = fmt(len)
    else
        pf.Size = UDim2.new(0, 0, 1, 0)
        elapsed.Text = "00:00"
        duration.Text = "00:00"
    end
end)

task.defer(function()
    bind()
    layout()
    refresh()
    switch("LIBRARY")
    task.delay(0.8, bind)
    task.delay(1.6, bind)
    task.delay(3.2, bind)
end)

print("[BBYA] MUSIC SUITE v1.2 online — no backdrop + nonblocking Mall remote + resilient launcher bind")