#!/usr/bin/env python3
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[1]
MAP = ROOT / "maps" / "bbya-social-hub"
REGISTRY = MAP / "audio-playlists" / "vip-amapiano.json"


def lua_string(value):
    return json.dumps(str(value), ensure_ascii=False)


def active_tracks(registry):
    out = []
    for t in sorted(registry.get("tracks", []), key=lambda x: int(x.get("index", 0))):
        if t.get("assetId") and t.get("bbyaPermission") is True and t.get("status") in {"READY_TO_INJECT", "LIVE_IN_PLAYLIST"}:
            out.append(t)
    return out


def build_lua_tracks(tracks):
    rows = []
    for t in tracks:
        rows.append(" {title=%s,assetId=%s,key=%s,camelot=%s}" % (
            lua_string(t["title"]), lua_string(t["assetId"]), lua_string(t.get("musicalKey", "")), lua_string(t.get("camelot", ""))
        ))
    return "{\n" + ",\n".join(rows) + "\n}"


def patch_ui(tracks):
    path = MAP / "103-music-ui-final.client.lua"
    s = path.read_text(encoding="utf-8")
    lua_tracks = build_lua_tracks(tracks)

    s, n = re.subn(
        r'local VIP_TRACK(?:S)?=\{.*?\}\nlocal state=\{\}',
        'local VIP_TRACKS=' + lua_tracks + '\nlocal state={}',
        s,
        count=1,
        flags=re.S,
    )
    if n != 1:
        raise SystemExit("VIP track table block not found in 103 UI")

    if 'local vipRemote=remotes:WaitForChild("VIPMusic",30)' not in s:
        needle='local funkotRemote=remotes:WaitForChild("FunkotMusic",30)'
        if needle not in s:
            raise SystemExit("Funkot remote declaration not found")
        s=s.replace(needle, needle+'\nlocal vipRemote=remotes:WaitForChild("VIPMusic",30)',1)

    s=s.replace('if v=="VIP" then return {VIP_TRACK} end', 'if v=="VIP" then return VIP_TRACKS end')

    pattern = re.compile(r'local function refreshCard\(\).*?\nend\n\nlocal function clearRows\(\)', re.S)
    repl = '''local function refreshCard()
 local v,spec=currentSpec();local s=state[v] or state.NONE;local tracks=effectiveTracks(v)
 local vipIndex=tonumber(ReplicatedStorage:GetAttribute("BBYAVIPCurrentIndex")) or 1
 local vipTrack=(v=="VIP" and tracks[vipIndex]) or nil
 if v=="VIP" and not vipTrack and #tracks>0 then vipTrack=tracks[1] end
 local vipTitle=tostring(ReplicatedStorage:GetAttribute("BBYAVIPCurrentTitle") or (vipTrack and vipTrack.title) or "")
 local empty=(resetActive() and v~="VIP") or #tracks==0 or (s.title=="" and not vipTrack)
 cardStroke.Color=spec.accent;coverStroke.Color=spec.accent;drawerStroke.Color=spec.accent;nowSmall.TextColor3=spec.accent;coverVenue.TextColor3=spec.accent
 coverVenue.Text=spec.short
 nowTitle.Text=(v=="VIP" and vipTitle~="") and vipTitle or (empty and "BELUM ADA LAGU" or s.title)
 nowMeta.Text=v=="VIP" and ("VIP • "..tostring(#tracks)..(#tracks==1 and " TRACK" or " TRACKS")) or (empty and (spec.short.." • PLAYLIST EMPTY") or (spec.short..(s.playing and " • PLAYING" or " • READY")))
 local item=vipTrack or ((s.index>0 and tracks[s.index]) or nil);setCover(v,item,s)
 drawerTitle.Text=spec.short.." PLAYLIST";drawerCount.Text=tostring(#tracks)..(#tracks==1 and " TRACK" or " TRACKS")
 muteBtn.Text=player:GetAttribute("BBYAMusicMuted")==true and "UNMUTE" or "MUTE"
 refreshAdmin()
end

local function clearRows()'''
    s, n = pattern.subn(repl, s, count=1)
    if n != 1:
        raise SystemExit("refreshCard block not found in 103 UI")

    s, n = re.subn(
        r'local function requestTrack\(v,index\).*?\nend\nlocal function rebuildPlaylist\(\)',
        '''local function requestTrack(v,index)
 if resetActive() and v~="VIP" then showToast("PLAYLIST MASIH KOSONG");return end
 if v=="VIP" then vipRemote:FireServer("request",index)
 elseif v=="FUNKOT" then funkotRemote:FireServer("request",index)
 elseif v=="MAIN" or v=="UNDERGROUND" then musicRemote:FireServer("request",index)
 else showToast("REQUEST VENUE INI BELUM AKTIF") end
end
local function rebuildPlaylist()''',
        s, count=1, flags=re.S)
    if n != 1:
        raise SystemExit("requestTrack block not found")

    s, n = re.subn(
        r'local function requestList\(v\).*?\nend\nlocal function openMusic\(\)',
        '''local function requestList(v)
 if resetActive() and v~="VIP" then return end
 if v=="VIP" then vipRemote:FireServer("list")
 elseif v=="FUNKOT" then funkotRemote:FireServer("list")
 elseif v=="MAIN" or v=="UNDERGROUND" then musicRemote:FireServer("list") end
end
local function openMusic()''',
        s, count=1, flags=re.S)
    if n != 1:
        raise SystemExit("requestList block not found")

    s, n = re.subn(
        r'local function playPrevious\(\).*?adminPrev\.Activated:Connect\(playPrevious\);adminNext\.Activated:Connect\(playNext\)',
        '''local function playPrevious()
 if not isAdmin() then return end
 local v=currentVenue();local s=state[v];local tracks=effectiveTracks(v);if not s or #tracks==0 then return end
 if v=="VIP" then vipRemote:FireServer("previous");return end
 local prev=table.remove(s.history)
 if not prev then prev=((math.max(s.index,1)-2)%#tracks)+1 end
 if v=="FUNKOT" then funkotRemote:FireServer("play",prev)
 elseif v=="MAIN" or v=="UNDERGROUND" then musicRemote:FireServer("play",prev) end
end
local function playNext()
 if not isAdmin() then return end
 local v=currentVenue();if #effectiveTracks(v)==0 then return end
 if v=="VIP" then vipRemote:FireServer("next")
 elseif v=="FUNKOT" then funkotRemote:FireServer("next")
 elseif v=="MAIN" or v=="UNDERGROUND" then musicRemote:FireServer("next") end
end
adminPrev.Activated:Connect(playPrevious);adminNext.Activated:Connect(playNext)''',
        s, count=1, flags=re.S)
    if n != 1:
        raise SystemExit("prev/next block not found")

    if 'vipRemote.OnClientEvent:Connect' not in s:
        marker='local function activeSound()'
        handler='''vipRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="state" and type(data)=="table" then ingestState("VIP",data)
 elseif kind=="toast" then showToast(data)
 elseif kind=="playlist" and layer.Visible and currentVenue()=="VIP" then refreshCard();if drawer.Visible then rebuildPlaylist() end end
end)

'''
        if marker not in s:
            raise SystemExit("activeSound marker not found")
        s=s.replace(marker,handler+marker,1)

    s=s.replace('local s=(not resetActive()) and activeSound() or nil;local loud=',
                'local vv=currentVenue();local s=((not resetActive()) or vv=="VIP") and activeSound() or nil;local loud=',1)
    s=s.replace('if resetActive() then for _,s in pairs(state) do s.tracks={};s.title="";s.index=0;s.playing=false end end',
                'if resetActive() then for key,st in pairs(state) do if key~="VIP" then st.tracks={};st.title="";st.index=0;st.playing=false end end end',1)

    path.write_text(s, encoding="utf-8")


def write_server(tracks):
    path = MAP / "110-vip-track01.server.lua"
    lua_tracks = build_lua_tracks(tracks)
    text = f'''-- BBYA SOCIAL HUB - VIP AMAPIANO PLAYLIST AUTHORITY v5
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local Players=game:GetService("Players")
local PLAYLIST={lua_tracks}

if #PLAYLIST==0 then return end

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
if not remotes then remotes=Instance.new("Folder");remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage end
local vipRemote=remotes:FindFirstChild("VIPMusic")
if vipRemote and not vipRemote:IsA("RemoteEvent") then vipRemote:Destroy();vipRemote=nil end
if not vipRemote then vipRemote=Instance.new("RemoteEvent");vipRemote.Name="VIPMusic";vipRemote.Parent=remotes end

local currentIndex=tonumber(ReplicatedStorage:GetAttribute("BBYAVIPCurrentIndex")) or 1
if currentIndex<1 or currentIndex>#PLAYLIST then currentIndex=1 end
local group
local sound
local endedConnection
local lastControl={{}}

local function currentData()
 local track=PLAYLIST[currentIndex]
 return {{venue="VIP",index=currentIndex,title=track.title,assetId=track.assetId,playing=sound and sound.IsPlaying or false,count=#PLAYLIST}}
end

local function publishState()
 local track=PLAYLIST[currentIndex]
 ReplicatedStorage:SetAttribute("BBYAVIPTrack01Enabled",true)
 ReplicatedStorage:SetAttribute("BBYAVIPPlaylistId","vip-amapiano")
 ReplicatedStorage:SetAttribute("BBYAVIPPlaylistCount",#PLAYLIST)
 ReplicatedStorage:SetAttribute("BBYAVIPCurrentIndex",currentIndex)
 ReplicatedStorage:SetAttribute("BBYAVIPCurrentTitle",track.title)
 ReplicatedStorage:SetAttribute("BBYAVIPCurrentAssetId",track.assetId)
 ReplicatedStorage:SetAttribute("BBYAVIPTrack01Title",PLAYLIST[1].title)
 ReplicatedStorage:SetAttribute("BBYAVIPTrack01AssetId",PLAYLIST[1].assetId)
end

local function ensureCore()
 group=SoundService:FindFirstChild("BBYAVIPMaster")
 if group and not group:IsA("SoundGroup") then group:Destroy();group=nil end
 if not group then group=Instance.new("SoundGroup");group.Name="BBYAVIPMaster";group.Parent=SoundService end
 group.Volume=.62
 group:SetAttribute("Venue","VIP")
 group:SetAttribute("BBYALocalZoneOnly",true)
 group:SetAttribute("PlaylistReady",true)
 group:SetAttribute("PlaylistCount",#PLAYLIST)
 group:SetAttribute("RecoveryActive",false)
 group:SetAttribute("RecoveryFallbackCount",0)
 group:SetAttribute("MusicCatalogState","VIP_AMAPIANO_ACTIVE")

 local old=SoundService:FindFirstChild("BBYAVIPTrack01")
 if old then old:Destroy() end
 sound=SoundService:FindFirstChild("BBYAVIPPlaylist")
 if sound and not sound:IsA("Sound") then sound:Destroy();sound=nil end
 if not sound then
  sound=Instance.new("Sound")
  sound.Name="BBYAVIPPlaylist"
  sound.Looped=false
  sound.Volume=.72
  sound.Parent=SoundService
 end
 sound.SoundGroup=group
 sound.Looped=false
 sound.Volume=.72
end

local function broadcastState()
 publishState()
 vipRemote:FireAllClients("state",currentData())
end

local function playIndex(index)
 if #PLAYLIST==0 then return end
 currentIndex=((tonumber(index) or 1)-1)%#PLAYLIST+1
 ensureCore()
 local track=PLAYLIST[currentIndex]
 sound:Stop()
 sound.SoundId="rbxassetid://"..track.assetId
 sound.TimePosition=0
 sound:SetAttribute("Title",track.title)
 sound:SetAttribute("Venue","VIP")
 sound:SetAttribute("PlaylistIndex",currentIndex)
 sound:SetAttribute("PlaylistId","vip-amapiano")
 publishState()
 pcall(function()sound:Play()end)
 task.delay(.15,broadcastState)
 print("[BBYA] VIP Amapiano now playing",currentIndex,track.title,track.assetId)
end

local function bindEnded()
 if endedConnection then endedConnection:Disconnect();endedConnection=nil end
 endedConnection=sound.Ended:Connect(function()
  task.defer(function()playIndex(currentIndex%#PLAYLIST+1)end)
 end)
end

local function canControl(player)
 if not player then return false end
 if player:GetAttribute("BBYAAdmin")==true then return true end
 if game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId then return true end
 return false
end

vipRemote.OnServerEvent:Connect(function(player,action,value)
 action=tostring(action or "")
 if action=="list" then
  vipRemote:FireClient(player,"playlist",PLAYLIST)
  vipRemote:FireClient(player,"state",currentData())
  return
 end
 if not canControl(player) then vipRemote:FireClient(player,"toast","REQUEST KHUSUS HOST VIP");return end
 local now=os.clock();if now-(lastControl[player] or 0)<.45 then return end;lastControl[player]=now
 if action=="request" or action=="play" then playIndex(tonumber(value) or currentIndex)
 elseif action=="next" then playIndex(currentIndex%#PLAYLIST+1)
 elseif action=="previous" then playIndex(((currentIndex-2)%#PLAYLIST)+1) end
end)
Players.PlayerRemoving:Connect(function(p)lastControl[p]=nil end)

ensureCore()
bindEnded()
playIndex(currentIndex)

task.spawn(function()
 while task.wait(1) do
  ensureCore()
  publishState()
  group.Volume=.62
  group:SetAttribute("PlaylistReady",true)
  group:SetAttribute("PlaylistCount",#PLAYLIST)
  if sound and not sound.IsPlaying then pcall(function()sound:Play()end) end
 end
end)

print("[BBYA] VIP Amapiano playlist authority v5 online; tracks",#PLAYLIST)
'''
    path.write_text(text, encoding="utf-8")


def main():
    registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
    tracks = active_tracks(registry)
    if not tracks:
        raise SystemExit("No active VIP Amapiano tracks in registry")
    patch_ui(tracks)
    write_server(tracks)
    print(json.dumps({"playlistId": registry.get("playlistId"), "trackCount": len(tracks), "assetIds": [t["assetId"] for t in tracks]}))


if __name__ == "__main__":
    main()
