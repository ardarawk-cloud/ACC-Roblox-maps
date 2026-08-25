#!/usr/bin/env python3
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
MAP = ROOT / 'maps' / 'bbya-social-hub'
REGISTRY = MAP / 'audio-playlists' / 'rooftop-tropical.json'
SERVER = MAP / '134-rooftop-playlist.server.lua'
PROJECT = MAP / 'default.project.json'


def q(v):
    return json.dumps(str(v), ensure_ascii=False)


def active_tracks(reg):
    return [t for t in sorted(reg.get('tracks',[]), key=lambda x:int(x.get('index',0)))
            if t.get('assetId') and t.get('bbyaPermission') is True and t.get('status') in {'READY_TO_INJECT','LIVE_IN_PLAYLIST'}]


def build_server(tracks):
    rows = ',\n'.join(' {title=%s,assetId=%s}' % (q(t.get('title','')), q(t.get('assetId',''))) for t in tracks)
    lua = '''-- BBYA SOCIAL HUB — ROOFTOP TROPICAL PLAYLIST AUTHORITY v3
-- Canonical Rooftop audio is spatial and comes from one physical speaker block near the bar.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local Workspace=game:GetService("Workspace")
local PLAYLIST={
%s
}
if #PLAYLIST==0 then return end

local currentIndex=tonumber(ReplicatedStorage:GetAttribute("BBYARooftopCurrentIndex")) or 1
if currentIndex<1 or currentIndex>#PLAYLIST then currentIndex=1 end
local group
local speaker
local sound
local endedConnection

local function publishCatalog()
 local folder=ReplicatedStorage:FindFirstChild("BBYARooftopPlaylistCatalog")
 if folder and not folder:IsA("Folder") then folder:Destroy();folder=nil end
 if not folder then folder=Instance.new("Folder");folder.Name="BBYARooftopPlaylistCatalog";folder.Parent=ReplicatedStorage end
 folder:SetAttribute("PlaylistId","rooftop-tropical")
 folder:SetAttribute("Count",#PLAYLIST)
 for i,t in ipairs(PLAYLIST) do
  local name="Track"..tostring(i)
  local entry=folder:FindFirstChild(name)
  if entry and not entry:IsA("StringValue") then entry:Destroy();entry=nil end
  if not entry then entry=Instance.new("StringValue");entry.Name=name;entry.Parent=folder end
  entry.Value=t.title
  entry:SetAttribute("Index",i)
  entry:SetAttribute("AssetId",t.assetId)
 end
 for _,entry in ipairs(folder:GetChildren()) do
  local i=tonumber(entry:GetAttribute("Index"))
  if not i or i<1 or i>#PLAYLIST then entry:Destroy() end
 end
end

local function ensureSpeaker()
 speaker=Workspace:FindFirstChild("BBYARooftopSpeakerBlock")
 if speaker and not speaker:IsA("Part") then speaker:Destroy();speaker=nil end
 if not speaker then
  speaker=Instance.new("Part")
  speaker.Name="BBYARooftopSpeakerBlock"
  speaker.Size=Vector3.new(3.4,4.8,3.4)
  speaker.CFrame=CFrame.new(22,47.65,-29)
  speaker.Anchored=true
  speaker.CanCollide=true
  speaker.CanTouch=true
  speaker.CanQuery=true
  speaker.Material=Enum.Material.Metal
  speaker.Color=Color3.fromRGB(29,30,34)
  speaker.TopSurface=Enum.SurfaceType.Smooth
  speaker.BottomSurface=Enum.SurfaceType.Smooth
  speaker:SetAttribute("Venue","ROOFTOP")
  speaker:SetAttribute("Purpose","SPATIAL_MUSIC_EMITTER")
  speaker.Parent=Workspace
 end
 local oldClock=SoundService:FindFirstChild("BBYARooftopPlaylist")
 if oldClock and oldClock:IsA("Sound") then pcall(function()oldClock:Stop()end);oldClock:Destroy() end
 sound=speaker:FindFirstChild("RooftopSpatialSound")
 if sound and not sound:IsA("Sound") then sound:Destroy();sound=nil end
 if not sound then sound=Instance.new("Sound");sound.Name="RooftopSpatialSound";sound.Parent=speaker end
 sound.Looped=false
 sound.Volume=1.35
 sound.RollOffMode=Enum.RollOffMode.InverseTapered
 sound.RollOffMinDistance=18
 sound.RollOffMaxDistance=115
 sound.EmitterSize=22
 sound:SetAttribute("Venue","ROOFTOP")
 sound:SetAttribute("SpatialEmitter",true)
 return speaker,sound
end

local function publishState()
 local t=PLAYLIST[currentIndex]
 ReplicatedStorage:SetAttribute("BBYARooftopPlaylistEnabled",true)
 ReplicatedStorage:SetAttribute("BBYARooftopPlaylistId","rooftop-tropical")
 ReplicatedStorage:SetAttribute("BBYARooftopPlaylistCount",#PLAYLIST)
 ReplicatedStorage:SetAttribute("BBYARooftopCurrentIndex",currentIndex)
 ReplicatedStorage:SetAttribute("BBYARooftopCurrentTitle",t.title)
 ReplicatedStorage:SetAttribute("BBYARooftopCurrentAssetId",t.assetId)
 if group then
  group:SetAttribute("CurrentIndex",currentIndex)
  group:SetAttribute("CurrentTitle",t.title)
  group:SetAttribute("CurrentAssetId",t.assetId)
 end
 if speaker then
  speaker:SetAttribute("CurrentIndex",currentIndex)
  speaker:SetAttribute("CurrentTitle",t.title)
  speaker:SetAttribute("CurrentAssetId",t.assetId)
 end
end

local function ensureCore()
 group=SoundService:FindFirstChild("BBYARooftopMaster")
 if group and not group:IsA("SoundGroup") then group:Destroy();group=nil end
 if not group then group=Instance.new("SoundGroup");group.Name="BBYARooftopMaster";group.Parent=SoundService end
 group.Volume=.82
 group:SetAttribute("Venue","ROOFTOP")
 group:SetAttribute("BBYALocalZoneOnly",true)
 group:SetAttribute("PlaylistReady",true)
 group:SetAttribute("PlaylistCount",#PLAYLIST)
 group:SetAttribute("MusicCatalogState","ROOFTOP_TROPICAL_SPATIAL_ACTIVE")
 ensureSpeaker()
 sound.SoundGroup=group
 publishCatalog()
end

local function playIndex(index)
 currentIndex=((tonumber(index) or 1)-1)%%#PLAYLIST+1
 ensureCore()
 local t=PLAYLIST[currentIndex]
 sound:Stop()
 sound.SoundId="rbxassetid://"..t.assetId
 sound.TimePosition=0
 sound:SetAttribute("Title",t.title)
 sound:SetAttribute("Venue","ROOFTOP")
 sound:SetAttribute("PlaylistIndex",currentIndex)
 sound:SetAttribute("PlaylistId","rooftop-tropical")
 publishState()
 pcall(function()sound:Play()end)
 print("[BBYA] Rooftop spatial speaker now playing",currentIndex,t.title,t.assetId)
end

local function bindEnded()
 if endedConnection then endedConnection:Disconnect();endedConnection=nil end
 endedConnection=sound.Ended:Connect(function()
  task.defer(function()playIndex(currentIndex%%#PLAYLIST+1)end)
 end)
end

ensureCore()
bindEnded()
playIndex(currentIndex)
task.spawn(function()
 while task.wait(1.0) do
  ensureCore();publishState()
  group.Volume=.82
  group:SetAttribute("PlaylistReady",true)
  group:SetAttribute("PlaylistCount",#PLAYLIST)
  if sound and sound.Parent and not sound.IsPlaying then pcall(function()sound:Play()end) end
 end
end)
print("[BBYA] Rooftop tropical playlist authority v3 online; spatial speaker block; tracks",#PLAYLIST)
''' % rows
    SERVER.write_text(lua, encoding='utf-8')


def patch_project():
    d=json.loads(PROJECT.read_text(encoding='utf-8'))
    sss=d['tree']['ServerScriptService']
    sss['RooftopPlaylistAuthorityV1']={'$path':'134-rooftop-playlist.server.lua'}
    PROJECT.write_text(json.dumps(d, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')


def main():
    reg=json.loads(REGISTRY.read_text(encoding='utf-8'))
    tracks=active_tracks(reg)
    if not tracks: raise SystemExit('NO_APPROVED_ROOFTOP_TRACKS')
    build_server(tracks)
    patch_project()
    print(json.dumps({'playlistId':reg.get('playlistId'),'trackCount':len(tracks),'assetIds':[t.get('assetId') for t in tracks]}))

if __name__=='__main__': main()
