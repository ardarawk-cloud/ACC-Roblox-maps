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

    s = s.replace('if v=="VIP" then return {VIP_TRACK} end', 'if v=="VIP" then return VIP_TRACKS end')
    s = s.replace('if v=="VIP" then return VIP_TRACKS end', 'if v=="VIP" then return VIP_TRACKS end', 1)

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

    path.write_text(s, encoding="utf-8")


def write_server(tracks):
    path = MAP / "110-vip-track01.server.lua"
    lua_tracks = build_lua_tracks(tracks)
    text = f'''-- BBYA SOCIAL HUB - VIP AMAPIANO PLAYLIST AUTHORITY v4
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local PLAYLIST={lua_tracks}

if #PLAYLIST==0 then return end

local currentIndex=tonumber(ReplicatedStorage:GetAttribute("BBYAVIPCurrentIndex")) or 1
if currentIndex<1 or currentIndex>#PLAYLIST then currentIndex=1 end
local group
local sound
local endedConnection

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
 print("[BBYA] VIP Amapiano now playing",currentIndex,track.title,track.assetId)
end

local function bindEnded()
 if endedConnection then endedConnection:Disconnect();endedConnection=nil end
 endedConnection=sound.Ended:Connect(function()
  task.defer(function()playIndex(currentIndex%#PLAYLIST+1)end)
 end)
end

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
  if sound and not sound.IsPlaying then
   pcall(function()sound:Play()end)
  end
 end
end)

print("[BBYA] VIP Amapiano playlist authority v4 online; tracks",#PLAYLIST)
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
