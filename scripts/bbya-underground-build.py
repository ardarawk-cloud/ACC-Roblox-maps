#!/usr/bin/env python3
import json, pathlib, re

ROOT=pathlib.Path(__file__).resolve().parents[1]
MAP=ROOT/'maps'/'bbya-social-hub'
REGISTRY=MAP/'audio-playlists'/'underground.json'

def lua_string(v): return json.dumps(str(v),ensure_ascii=False)

def active_tracks(reg):
    out=[]
    for t in sorted(reg.get('tracks',[]),key=lambda x:int(x.get('index',0))):
        if t.get('assetId') and t.get('bbyaPermission') is True and t.get('status') in {'READY_TO_INJECT','LIVE_IN_PLAYLIST'}:
            out.append(t)
    return out

def patch_basement(tracks):
    path=MAP/'85-basement-autodj.server.lua'
    s=path.read_text(encoding='utf-8')
    rows=[]
    for t in tracks:
        rows.append(' {title=%s,id=%s,style="underground"}'%(lua_string(t['title']),lua_string(t['assetId'])))
    block='local PLAYLIST={\n'+',\n'.join(rows)+'\n}\n\nlocal MIX_SECONDS='
    s,n=re.subn(r'local PLAYLIST=\{.*?\n\}\n\nlocal MIX_SECONDS=',block,s,count=1,flags=re.S)
    if n!=1: raise SystemExit('Basement PLAYLIST block not found')
    s=s.replace('group:SetAttribute("GenrePolicy","INDO_BREAKBEAT_BOUNCE")','group:SetAttribute("GenrePolicy","UNDERGROUND_OWNER_LIBRARY")',1)
    s=s.replace('group:SetAttribute("BBYAAudioMode","BASEMENT_INDO_DUAL_DECK_V1")','group:SetAttribute("BBYAAudioMode","UNDERGROUND_OWNER_DUAL_DECK_V2")',1)
    path.write_text(s,encoding='utf-8')

def write_reset_authority():
    path=MAP/'109-music-catalog-reset.server.lua'
    text='''-- BBYA SOCIAL HUB — MIXED MUSIC RESET AUTHORITY v3\n-- MAIN/FUNKOT stay reset; UNDERGROUND owner library is explicitly active.\nlocal ReplicatedStorage=game:GetService("ReplicatedStorage")\nlocal ServerScriptService=game:GetService("ServerScriptService")\nlocal SoundService=game:GetService("SoundService")\nlocal Workspace=game:GetService("Workspace")\nlocal UNDERGROUND_REBUILD_ENABLED=true\n\nReplicatedStorage:SetAttribute("BBYAMusicCatalogReset",true)\nReplicatedStorage:SetAttribute("BBYAMusicCatalogVersion","RESET_WITH_UNDERGROUND_V3")\nReplicatedStorage:SetAttribute("BBYAUndergroundPlaylistEnabled",UNDERGROUND_REBUILD_ENABLED)\n\nlocal remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")\nremotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage\nlocal function ensureRemote(name,className)\n local x=remotes:FindFirstChild(name)\n if x and x.ClassName~=className then x:Destroy();x=nil end\n if not x then x=Instance.new(className);x.Name=name;x.Parent=remotes end\n return x\nend\nensureRemote("Music","RemoteEvent")\nensureRemote("State","RemoteEvent")\nensureRemote("FunkotMusic","RemoteEvent")\nensureRemote("InternalMusic","BindableEvent")\nensureRemote("BasementMusic","BindableEvent")\n\nlocal function ensureGroup(name,venue,active)\n local g=SoundService:FindFirstChild(name)\n if g and not g:IsA("SoundGroup") then g:Destroy();g=nil end\n if not g then g=Instance.new("SoundGroup");g.Name=name;g.Parent=SoundService end\n if active then\n  g.Volume=1\n  g:SetAttribute("Venue",venue)\n  g:SetAttribute("BBYALocalZoneOnly",true)\n  g:SetAttribute("MusicCatalogState","OWNER_LIBRARY_ACTIVE")\n  return g\n end\n g.Volume=0\n g:SetAttribute("Venue",venue)\n g:SetAttribute("BBYALocalZoneOnly",true)\n g:SetAttribute("PlaylistReady",false)\n g:SetAttribute("PlaylistCount",0)\n g:SetAttribute("RecoveryActive",false)\n g:SetAttribute("RecoveryFallbackCount",0)\n g:SetAttribute("MusicCatalogState","RESET_EMPTY")\n return g\nend\n\nlocal groups={\n ["BBYAClubMaster"]=ensureGroup("BBYAClubMaster","MAIN",false),\n ["BBYABasementMaster"]=ensureGroup("BBYABasementMaster","UNDERGROUND",UNDERGROUND_REBUILD_ENABLED),\n ["BBYAFunkotMaster"]=ensureGroup("BBYAFunkotMaster","FUNKOT",false),\n ["BBYAVIPMaster"]=ensureGroup("BBYAVIPMaster","VIP",false),\n ["BBYASkateparkMaster"]=ensureGroup("BBYASkateparkMaster","SKATEPARK",false),\n ["BBYARooftopMaster"]=ensureGroup("BBYARooftopMaster","ROOFTOP",false),\n}\n\nlocal knownSounds={\n BBYAClubDeckA=true,BBYAClubDeckB=true,BBYABasementDeckA=true,BBYABasementDeckB=true,\n BBYAFunkotDeck=true,BBYAFunkotClubFeed=true,BBYAMainPublicFallbackV4=true,\n BBYAUndergroundBreakbeatFallbackV4=true,BBYAClubFeed=true,BBYAClubSound=true,\n}\nlocal function controlledSound(s)\n if not s:IsA("Sound") then return false end\n local sg=s.SoundGroup\n if UNDERGROUND_REBUILD_ENABLED and sg and sg.Name=="BBYABasementMaster" then return false end\n if knownSounds[s.Name] or s:GetAttribute("BBYARecovery")==true then return true end\n if sg and sg.Name=="BBYAVIPMaster" and ReplicatedStorage:GetAttribute("BBYAVIPTrack01Enabled")==true then return false end\n return sg and groups[sg.Name]~=nil or false\nend\nlocal function scrubSound(s,destroy)\n if not controlledSound(s) then return end\n pcall(function()s:Stop()end);pcall(function()s.SoundId=""end);pcall(function()s.TimePosition=0 end);pcall(function()s.Volume=0 end)\n if destroy then pcall(function()s:Destroy()end) end\nend\nlocal function scrubWorkspaceVIP()\n if ReplicatedStorage:GetAttribute("BBYAVIPTrack01Enabled")==true then return end\n local vipGroup=groups.BBYAVIPMaster\n for _,o in ipairs(Workspace:GetDescendants()) do\n  if o:IsA("Sound") and o.Name=="CornerSpatialAudio" then pcall(function()o:Stop();o.SoundId="";o.TimePosition=0;o.Volume=0;o.SoundGroup=vipGroup end) end\n end\nend\n\nlocal engineNames={"BasementIndoAutoDJ","FunkotVenueMusicV2","AudioWatchdog","AudioHealthGuardV3"}\nlocal function disableOldAudioEngines()\n for _,name in ipairs(engineNames) do\n  if not (UNDERGROUND_REBUILD_ENABLED and name=="BasementIndoAutoDJ") then\n   local s=ServerScriptService:FindFirstChild(name)\n   if s and s:IsA("BaseScript") and s~=script then pcall(function()s.Disabled=true end) end\n  end\n end\nend\n\nlocal resetActive=true\nSoundService.DescendantAdded:Connect(function(o)\n if not resetActive or not o:IsA("Sound") then return end\n task.defer(function()if o.Parent and controlledSound(o) then scrubSound(o,true) end end)\nend)\nWorkspace.DescendantAdded:Connect(function(o)\n if not resetActive or not o:IsA("Sound") or o.Name~="CornerSpatialAudio" then return end\n task.defer(function()if o.Parent then pcall(function()o:Stop();o.SoundId="";o.Volume=0;o.SoundGroup=groups.BBYAVIPMaster end) end end)\nend)\n\nlocal function applyReset()\n disableOldAudioEngines()\n for _,o in ipairs(SoundService:GetDescendants()) do if o:IsA("Sound") and controlledSound(o) then scrubSound(o,true) end end\n scrubWorkspaceVIP()\n for name,g in pairs(groups) do\n  if not (UNDERGROUND_REBUILD_ENABLED and name=="BBYABasementMaster") then\n   g.Volume=0;g:SetAttribute("PlaylistReady",false);g:SetAttribute("PlaylistCount",0);g:SetAttribute("RecoveryActive",false);g:SetAttribute("RecoveryFallbackCount",0);g:SetAttribute("MusicCatalogState","RESET_EMPTY")\n  end\n end\n Workspace:SetAttribute("BBYAMusicCatalogReset",true)\nend\n\ntask.defer(applyReset);task.delay(4,applyReset);task.delay(8,applyReset)\nprint("[BBYA] Mixed catalog authority v3: UNDERGROUND active; other reset channels preserved")\n'''
    path.write_text(text,encoding='utf-8')

def patch_ui():
    path=MAP/'103-music-ui-final.client.lua'
    s=path.read_text(encoding='utf-8')
    replacements=[
      ('if resetActive() then return {} end','if resetActive() and v~="UNDERGROUND" then return {} end'),
      ('if resetActive() and v~="VIP" then showToast("PLAYLIST MASIH KOSONG");return end','if resetActive() and v~="VIP" and v~="UNDERGROUND" then showToast("PLAYLIST MASIH KOSONG");return end'),
      ('if resetActive() and v~="VIP" then return end','if resetActive() and v~="VIP" and v~="UNDERGROUND" then return end'),
      ('local empty=(resetActive() and v~="VIP") or #tracks==0','local empty=(resetActive() and v~="VIP" and v~="UNDERGROUND") or #tracks==0'),
      ('local vv=currentVenue();local s=((not resetActive()) or vv=="VIP") and activeSound() or nil;local loud=','local vv=currentVenue();local s=((not resetActive()) or vv=="VIP" or vv=="UNDERGROUND") and activeSound() or nil;local loud='),
    ]
    for old,new in replacements:
        if old in s: s=s.replace(old,new,1)
    path.write_text(s,encoding='utf-8')

def main():
    reg=json.loads(REGISTRY.read_text(encoding='utf-8'))
    tracks=active_tracks(reg)
    if not tracks: raise SystemExit('No approved Underground tracks to build')
    patch_basement(tracks)
    write_reset_authority()
    patch_ui()
    print(json.dumps({'playlistId':'underground','trackCount':len(tracks),'assetIds':[t['assetId'] for t in tracks]}))

if __name__=='__main__': main()
