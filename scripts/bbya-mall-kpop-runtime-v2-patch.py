from pathlib import Path

p = Path('maps/bbya-social-hub/103-music-ui-final.client.lua')
s = p.read_text()

def once(old, new, label):
    global s
    count = s.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected 1 token, got {count}')
    s = s.replace(old, new, 1)

once(
'''    ROOFTOP = {label = "ROOFTOP", accent = C.gold, group = "BBYARooftopMaster"},
    NONE = {label = "BBYA MUSIC", accent = C.purple},''',
'''    ROOFTOP = {label = "ROOFTOP", accent = C.gold, group = "BBYARooftopMaster"},
    MALL = {label = "MALL", accent = C.gold, group = "BBYAMallMaster"},
    NONE = {label = "BBYA MUSIC", accent = C.purple},''',
'V_MALL')

once(
'local stateRemote = remotes:WaitForChild("State", 30)\n',
'local stateRemote = remotes:WaitForChild("State", 30)\nlocal mallControl = RS:WaitForChild("BBYAMallMusicControl", 30)\n',
'MALL_REMOTE')

once(
'''    if p.Y > -4 and p.Y < 20 and math.abs(p.X) <= 61 and p.Z >= 72 and p.Z <= 152 then return "SKATEPARK" end
    if p.Y > -4 and p.Y < 18 and math.abs(p.X) <= 61 and p.Z >= 0 and p.Z < 70 then return "MAIN" end''',
'''    if p.Y > -4 and p.Y < 20 and math.abs(p.X) <= 61 and p.Z >= 72 and p.Z <= 152 then return "SKATEPARK" end
    if p.Y >= -4 and p.Y <= 70 and p.X >= -96 and p.X <= 96 and p.Z >= 287 and p.Z <= 443 then return "MALL" end
    if p.Y > -4 and p.Y < 18 and math.abs(p.X) <= 61 and p.Z >= 0 and p.Z < 70 then return "MAIN" end''',
'VENUE_AT')

once(
'local S = {tracks = {}, title = "", index = 0, playing = false, queue = 0, nextRequest = 0}\n',
'''local S = {tracks = {}, title = "", index = 0, playing = false, queue = 0, nextRequest = 0, autoNext = 0}

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
''',
'MALL_SYNC')

once(
'''local function requestList()
    local v = venue()
    if v == "MAIN" or v == "UNDERGROUND" then music:FireServer("list") end
end''',
'''local function requestList()
    local v = venue()
    if v == "MAIN" or v == "UNDERGROUND" then
        music:FireServer("list")
    elseif v == "MALL" then
        syncMall()
    end
end''',
'REQUEST_LIST')

once(
'''local function request(i)
    local v = venue()
    if v == "MAIN" or v == "UNDERGROUND" then music:FireServer("request",i) end
end''',
'''local function request(i)
    local v = venue()
    if v == "MAIN" or v == "UNDERGROUND" then
        music:FireServer("request",i)
    elseif v == "MALL" and mallControl then
        mallControl:FireServer("request",i)
    end
end''',
'REQUEST_MALL')

once(
'''        FUNKOT = {"BBYAFunkotDeck"},
    }''',
'''        FUNKOT = {"BBYAFunkotDeck"},
        MALL = {"BBYAMallMasterSound"},
    }''',
'FIND_SOUND')

once(
'''prev.Activated:Connect(function()
    if isAdmin() and (venue() == "MAIN" or venue() == "UNDERGROUND") and #S.tracks > 0 then
        local i = ((math.max(S.index, 1) - 2) % #S.tracks) + 1
        music:FireServer("play", i)
    end
end)''',
'''prev.Activated:Connect(function()
    local v = venue()
    if not isAdmin() then return end
    if v == "MALL" and mallControl then
        mallControl:FireServer("prev")
    elseif (v == "MAIN" or v == "UNDERGROUND") and #S.tracks > 0 then
        local i = ((math.max(S.index, 1) - 2) % #S.tracks) + 1
        music:FireServer("play", i)
    end
end)''',
'PREV_MALL')

once(
'''nextB.Activated:Connect(function()
    if isAdmin() and (venue() == "MAIN" or venue() == "UNDERGROUND") then
        music:FireServer("next")
    end
end)''',
'''nextB.Activated:Connect(function()
    local v = venue()
    if not isAdmin() then return end
    if v == "MALL" and mallControl then
        mallControl:FireServer("next")
    elseif v == "MAIN" or v == "UNDERGROUND" then
        music:FireServer("next")
    end
end)''',
'NEXT_MALL')

once(
'''    if kind == "playlist" and type(data) == "table" then
        S.tracks = data
        if gui.Enabled then refresh() end''',
'''    if kind == "playlist" and type(data) == "table" then
        if venue() ~= "MALL" then S.tracks = data end
        if gui.Enabled then refresh() end''',
'IGNORE_CLUB_PLAYLIST_IN_MALL')

once(
'local bound = {}\n',
'''for _, attr in ipairs({
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
    if child.Name == "BBYAMallPlaylistCatalog" and venue() == "MALL" then
        task.defer(function()
            syncMall()
            if gui.Enabled then refresh() end
        end)
    end
end)

local bound = {}
''',
'MALL_ATTRIBUTE_BIND')

once(
'    local s = findSound()\n',
'    if venue() == "MALL" then syncMall() end\n    local s = findSound()\n',
'RENDER_SYNC')

s = s.replace('-- BBYA MUSIC SUITE v1 — PREMIUM UI PHASE 2', '-- BBYA MUSIC SUITE v1.1 — PREMIUM UI PHASE 2 + NATIVE MALL KPOP', 1)
s = s.replace('print("[BBYA] MUSIC SUITE v1 online — premium mobile Phase 2 Library / Now Playing / Queue")', 'print("[BBYA] MUSIC SUITE v1.1 online — native MALL KPOP + premium mobile Library / Now Playing / Queue")', 1)

p.write_text(s)
print('PATCH_OK')
