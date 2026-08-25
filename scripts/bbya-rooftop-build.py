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
    lua = '''-- BBYA SOCIAL HUB — ROOFTOP TROPICAL PLAYLIST AUTHORITY v2
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local PLAYLIST={
%s
}
if #PLAYLIST==0 then return end

local currentIndex=tonumber(ReplicatedStorage:GetAttribute("BBYARooftopCurrentIndex")) or 1
if currentIndex<1 or currentIndex>#PLAYLIST then currentIndex=1 end
local group
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
end

local function ensureCore()
 group=SoundService:FindFirstChild("BBYARooftopMaster")
 if group and not group:IsA("SoundGroup") then group:Destroy();group=nil end
 if not group then group=Instance.new("SoundGroup");group.Name="BBYARooftopMaster";group.Parent=SoundService end
 group.Volume=.68
 group:SetAttribute("Venue","ROOFTOP")
 group:SetAttribute("BBYALocalZoneOnly",true)
 group:SetAttribute("PlaylistReady",true)
 group:SetAttribute("PlaylistCount",#PLAYLIST)
 group:SetAttribute("MusicCatalogState","ROOFTOP_TROPICAL_ACTIVE")
 sound=SoundService:FindFirstChild("BBYARooftopPlaylist")
 if sound and not sound:IsA("Sound") then sound:Destroy();sound=nil end
 if not sound then sound=Instance.new("Sound");sound.Name="BBYARooftopPlaylist";sound.Parent=SoundService end
 sound.SoundGroup=group
 sound.Looped=false
 sound.Volume=.72
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
 print("[BBYA] Rooftop now playing",currentIndex,t.title,t.assetId)
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
 while task.wait(1.5) do
  ensureCore();publishState()
  group.Volume=.68
  group:SetAttribute("PlaylistReady",true)
  group:SetAttribute("PlaylistCount",#PLAYLIST)
  if sound and not sound.IsPlaying then pcall(function()sound:Play()end) end
 end
end)
print("[BBYA] Rooftop tropical playlist authority v2 online; tracks",#PLAYLIST)
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
