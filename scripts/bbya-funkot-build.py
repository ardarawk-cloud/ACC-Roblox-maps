#!/usr/bin/env python3
import json, pathlib

ROOT=pathlib.Path(__file__).resolve().parents[1]
MAP=ROOT/'maps'/'bbya-social-hub'
REG=MAP/'audio-playlists'/'funkot.json'


def active(reg):
    return [
        t for t in sorted(reg.get('tracks',[]),key=lambda x:int(x.get('index',0)))
        if t.get('assetId') and t.get('bbyaPermission') is True
        and t.get('status') in {'READY_TO_INJECT','LIVE_IN_PLAYLIST'}
    ]


def q(v):
    return json.dumps(str(v),ensure_ascii=False)


def patch_ui():
    p=MAP/'103-music-ui-final.client.lua'
    s=p.read_text(encoding='utf-8')

    if 'local function venueReset(v)' not in s:
        needle='local function resetActive()\n return ReplicatedStorage:GetAttribute("BBYAMusicCatalogReset")==true\nend\n'
        add=needle+'''local function venueReset(v)\n if v=="VIP" and ReplicatedStorage:GetAttribute("BBYAVIPTrack01Enabled")==true then return false end\n if v=="UNDERGROUND" and ReplicatedStorage:GetAttribute("BBYAUndergroundPlaylistEnabled")==true then return false end\n if v=="FUNKOT" and ReplicatedStorage:GetAttribute("BBYAFunkotPlaylistEnabled")==true then return false end\n return resetActive()\nend\n'''
        if needle not in s:
            raise SystemExit('resetActive anchor missing')
        s=s.replace(needle,add,1)

    replacements={
        # Current compact UI v8.
        ' if resetActive() and v~="UNDERGROUND" then return {} end':' if venueReset(v) then return {} end',
        ' local empty=(resetActive() and v~="VIP") or #tracks==0 or (s.title=="" and not vipTrack)':' local empty=venueReset(v) or #tracks==0 or (s.title=="" and not vipTrack)',
        'if kind=="playlist" and type(data)=="table" then state.FUNKOT.tracks=resetActive() and {} or data;if layer.Visible then refreshCard();rebuildPlaylist() end':'if kind=="playlist" and type(data)=="table" then state.FUNKOT.tracks=venueReset("FUNKOT") and {} or data;if layer.Visible then refreshCard();rebuildPlaylist() end',
        ' local vv=currentVenue();local s=((not resetActive()) or vv=="VIP" or vv=="UNDERGROUND") and activeSound() or nil;':' local vv=currentVenue();local s=(not venueReset(vv)) and activeSound() or nil;',
        ' if resetActive() then for key,st in pairs(state) do if key~="VIP" and key~="UNDERGROUND" then st.tracks={};st.title="";st.index=0;st.playing=false end end end':' if resetActive() then for key,st in pairs(state) do if venueReset(key) then st.tracks={};st.title="";st.index=0;st.playing=false end end end',
        # Older compact UI variants kept for idempotent recovery.
        ' if resetActive() then return {} end':' if venueReset(v) then return {} end',
        ' if resetActive() and v~="VIP" then showToast("PLAYLIST MASIH KOSONG");return end':' if venueReset(v) then showToast("PLAYLIST MASIH KOSONG");return end',
        ' if resetActive() and v~="VIP" then return end':' if venueReset(v) then return end',
        'state[v].tracks=resetActive() and {} or data':'state[v].tracks=venueReset(v) and {} or data',
        'state.FUNKOT.tracks=resetActive() and {} or data':'state.FUNKOT.tracks=venueReset("FUNKOT") and {} or data',
        'local vv=currentVenue();local s=((not resetActive()) or vv=="VIP") and activeSound() or nil;':'local vv=currentVenue();local s=(not venueReset(vv)) and activeSound() or nil;',
        'if resetActive() then for key,st in pairs(state) do if key~="VIP" then st.tracks={};st.title="";st.index=0;st.playing=false end end end':'if resetActive() then for key,st in pairs(state) do if venueReset(key) then st.tracks={};st.title="";st.index=0;st.playing=false end end end',
    }
    for a,b in replacements.items():
        s=s.replace(a,b)

    required=[
        'local function venueReset(v)',
        'BBYAFunkotPlaylistEnabled',
        'state.FUNKOT.tracks=venueReset("FUNKOT") and {} or data',
        'local vv=currentVenue();local s=(not venueReset(vv)) and activeSound() or nil;',
    ]
    for token in required:
        if token not in s:
            raise SystemExit('UI v8 Funkot patch missing '+token)
    p.write_text(s,encoding='utf-8')


def patch_reset():
    p=MAP/'109-music-catalog-reset.server.lua'
    s=p.read_text(encoding='utf-8')

    if 'sg.Name=="BBYAFunkotMaster" and ReplicatedStorage:GetAttribute("BBYAFunkotPlaylistEnabled")==true' not in s:
        anchor=' if UNDERGROUND_REBUILD_ENABLED and sg and sg.Name=="BBYABasementMaster" then return false end\n'
        insert=anchor+' if sg and sg.Name=="BBYAFunkotMaster" and ReplicatedStorage:GetAttribute("BBYAFunkotPlaylistEnabled")==true then return false end\n'
        if anchor not in s:
            raise SystemExit('reset v3 controlledSound anchor missing')
        s=s.replace(anchor,insert,1)

    current_loop=''' for name,g in pairs(groups) do\n  if not (UNDERGROUND_REBUILD_ENABLED and name=="BBYABasementMaster") then\n   g.Volume=0;g:SetAttribute("PlaylistReady",false);g:SetAttribute("PlaylistCount",0);g:SetAttribute("RecoveryActive",false);g:SetAttribute("RecoveryFallbackCount",0);g:SetAttribute("MusicCatalogState","RESET_EMPTY")\n  end\n end'''
    patched_loop=''' for name,g in pairs(groups) do\n  local undergroundActive=UNDERGROUND_REBUILD_ENABLED and name=="BBYABasementMaster"\n  local funkotActive=name=="BBYAFunkotMaster" and ReplicatedStorage:GetAttribute("BBYAFunkotPlaylistEnabled")==true\n  if funkotActive then\n   g.Volume=.62;g:SetAttribute("PlaylistReady",true);g:SetAttribute("MusicCatalogState","FUNKOT_ACTIVE")\n  elseif not undergroundActive then\n   g.Volume=0;g:SetAttribute("PlaylistReady",false);g:SetAttribute("PlaylistCount",0);g:SetAttribute("RecoveryActive",false);g:SetAttribute("RecoveryFallbackCount",0);g:SetAttribute("MusicCatalogState","RESET_EMPTY")\n  end\n end'''
    if current_loop in s:
        s=s.replace(current_loop,patched_loop,1)
    elif 'local funkotActive=name=="BBYAFunkotMaster"' not in s:
        # Compatibility with the older all-reset authority.
        old=''' for _,g in pairs(groups) do\n  g.Volume=0;g:SetAttribute("PlaylistReady",false);g:SetAttribute("PlaylistCount",0);g:SetAttribute("RecoveryActive",false);g:SetAttribute("RecoveryFallbackCount",0);g:SetAttribute("MusicCatalogState","RESET_EMPTY")\n end'''
        older=''' for name,g in pairs(groups) do\n  if name=="BBYAFunkotMaster" and ReplicatedStorage:GetAttribute("BBYAFunkotPlaylistEnabled")==true then\n   g.Volume=.62;g:SetAttribute("PlaylistReady",true);g:SetAttribute("MusicCatalogState","FUNKOT_ACTIVE")\n  else\n   g.Volume=0;g:SetAttribute("PlaylistReady",false);g:SetAttribute("PlaylistCount",0);g:SetAttribute("RecoveryActive",false);g:SetAttribute("RecoveryFallbackCount",0);g:SetAttribute("MusicCatalogState","RESET_EMPTY")\n  end\n end'''
        if old in s:
            s=s.replace(old,older,1)
        else:
            raise SystemExit('reset applyReset loop anchor missing')

    for token in ['BBYAFunkotPlaylistEnabled','FUNKOT_ACTIVE']:
        if token not in s:
            raise SystemExit('reset Funkot patch missing '+token)
    p.write_text(s,encoding='utf-8')


def patch_project():
    p=MAP/'default.project.json'
    data=json.loads(p.read_text(encoding='utf-8'))
    services=data.setdefault('tree',{}).setdefault('ServerScriptService',{})
    services['FunkotPlaylistAuthorityV1']={'$path':'121-funkot-playlist.server.lua'}
    p.write_text(json.dumps(data,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')


def write_server(tracks):
    rows=',\n'.join(' {title=%s,id=%s,style="funkot"}'%(q(t['title']),q(t['assetId'])) for t in tracks)
    text='''-- BBYA SOCIAL HUB — FUNKOT PLAYLIST AUTHORITY v2\nlocal Players=game:GetService("Players")\nlocal ReplicatedStorage=game:GetService("ReplicatedStorage")\nlocal SoundService=game:GetService("SoundService")\nlocal ContentProvider=game:GetService("ContentProvider")\nlocal PLAYLIST={\n%s\n}\nif #PLAYLIST==0 then return end\nlocal remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder");remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage\nlocal remote=remotes:FindFirstChild("FunkotMusic");if remote and not remote:IsA("RemoteEvent") then remote:Destroy();remote=nil end;if not remote then remote=Instance.new("RemoteEvent");remote.Name="FunkotMusic";remote.Parent=remotes end\nlocal group=SoundService:FindFirstChild("BBYAFunkotMaster");if group and not group:IsA("SoundGroup") then group:Destroy();group=nil end;if not group then group=Instance.new("SoundGroup");group.Name="BBYAFunkotMaster";group.Parent=SoundService end\ngroup.Volume=.62;group:SetAttribute("Venue","FUNKOT");group:SetAttribute("GenrePolicy","FUNKOT_ONLY");group:SetAttribute("BBYALocalZoneOnly",true);group:SetAttribute("PlaylistReady",true);group:SetAttribute("PlaylistCount",#PLAYLIST);group:SetAttribute("MusicCatalogState","FUNKOT_ACTIVE")\nReplicatedStorage:SetAttribute("BBYAFunkotPlaylistEnabled",true);ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistId","funkot");ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistCount",#PLAYLIST)\nfor _,n in ipairs({"BBYAFunkotClubFeed","BBYAFunkotDeck","BBYAFunkotPlaylistV1"}) do local o=SoundService:FindFirstChild(n);if o then pcall(function()o:Stop();o:Destroy()end) end end\nlocal sound=Instance.new("Sound");sound.Name="BBYAFunkotPlaylistV2";sound.SoundGroup=group;sound.Volume=.78;sound.Looped=false;sound.Parent=SoundService\nlocal current=0;local paused=false;local bad={};local queue={};local cooldown={};local rng=Random.new(math.max(1,os.time()%%2147483646))\nlocal function inZone(p)local c=p and p.Character;local h=c and c:FindFirstChild("HumanoidRootPart");if not h then return false end;local x=h.Position;return x.Y>-4 and x.Y<34 and math.abs(x.X)<61 and x.Z>157 and x.Z<253 end\nlocal function admin(p)return p and (p:GetAttribute("BBYAAdmin")==true or (game.CreatorType==Enum.CreatorType.User and p.UserId==game.CreatorId)) end\nlocal function state()local t=PLAYLIST[current];return {venue="FUNKOT",genre="FUNKOT",index=current,title=t and t.title or "",style="funkot",playing=sound.IsPlaying and not paused,library=#PLAYLIST,queue=#queue,audioMode="FUNKOT_APPROVED_V2"} end\nlocal function fire(p)if p then remote:FireClient(p,"state",state());return end;for _,pl in ipairs(Players:GetPlayers()) do if inZone(pl) then remote:FireClient(pl,"state",state()) end end end\nlocal function valid(i)return PLAYLIST[i] and not bad[i] end\nlocal function play(i)i=tonumber(i);if not i or not valid(i) then return false end;local t=PLAYLIST[i];sound:Stop();sound.SoundId="rbxassetid://"..t.id;sound.TimePosition=0;local ok=pcall(function()ContentProvider:PreloadAsync({sound})end);if not ok then bad[i]=true;return false end;sound:Play();task.wait(.3);if not sound.IsPlaying or (sound.TimeLength or 0)<=1 then sound:Stop();bad[i]=true;return false end;current=i;paused=false;group:SetAttribute("CurrentAssetId",t.id);group:SetAttribute("CurrentTitle",t.title);ReplicatedStorage:SetAttribute("BBYAFunkotCurrentTitle",t.title);ReplicatedStorage:SetAttribute("BBYAFunkotCurrentAssetId",t.id);fire();return true end\nlocal function nextTrack()local cand={};for i=1,#PLAYLIST do if valid(i) and i~=current then table.insert(cand,i) end end;if #cand==0 then for i=1,#PLAYLIST do if valid(i) then table.insert(cand,i) end end end;if #queue>0 then local qv=table.remove(queue,1);if play(qv.index) then return end end;while #cand>0 do local k=rng:NextInteger(1,#cand);local i=table.remove(cand,k);if play(i) then return end end end\nsound.Ended:Connect(function()task.defer(nextTrack)end)\nremote.OnServerEvent:Connect(function(p,a,v)if a=="list" then remote:FireClient(p,"playlist",PLAYLIST);fire(p);return elseif a=="state" then fire(p);return end;if not inZone(p) then return end;if a=="request" then local i=tonumber(v);if not i or not valid(i) then return end;local n=os.clock();if n-(cooldown[p.UserId] or 0)<12 then return end;cooldown[p.UserId]=n;table.insert(queue,{index=i,userId=p.UserId});fire(p) elseif admin(p) and a=="next" then nextTrack() elseif admin(p) and a=="play" then play(tonumber(v) or current) end end)\nPlayers.PlayerRemoving:Connect(function(p)cooldown[p.UserId]=nil end)\ntask.delay(2,nextTrack)\nprint("[BBYA] Funkot approved playlist authority v2 online; tracks",#PLAYLIST)\n'''%rows
    (MAP/'121-funkot-playlist.server.lua').write_text(text,encoding='utf-8')


def main():
    reg=json.loads(REG.read_text(encoding='utf-8'))
    tracks=active(reg)
    if not tracks:
        raise SystemExit('No approved Funkot tracks')
    patch_ui()
    patch_reset()
    patch_project()
    write_server(tracks)
    print(json.dumps({'playlistId':'funkot','trackCount':len(tracks),'assetIds':[t['assetId'] for t in tracks]},ensure_ascii=False))


if __name__=='__main__':
    main()
