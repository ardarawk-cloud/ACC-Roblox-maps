#!/usr/bin/env python3
import json, pathlib, re

ROOT=pathlib.Path(__file__).resolve().parents[1]
MAP=ROOT/'maps'/'bbya-social-hub'
REG=MAP/'audio-playlists'/'funkot.json'
RUNTIME=MAP/'93-funkot-music.server.lua'
SHIM=MAP/'121-funkot-playlist.server.lua'

# Asset routed away by owner; never regenerate it into Funkot.
ROUTED_AWAY={'134073539670673'}


def q(v):
    return json.dumps(str(v),ensure_ascii=False)


def active(reg):
    out=[]
    seen=set()
    for t in sorted(reg.get('tracks',[]),key=lambda x:int(x.get('index',0))):
        aid=str(t.get('assetId') or '')
        if not aid or aid in ROUTED_AWAY or aid in seen:
            continue
        if t.get('bbyaPermission') is not True:
            continue
        if t.get('moderationLastKnown') != 'Approved':
            continue
        if t.get('status') not in {'READY_TO_INJECT','LIVE_IN_PLAYLIST'}:
            continue
        out.append((str(t.get('title') or ('Funkot '+aid)),aid))
        seen.add(aid)
    return out


def patch_runtime(tracks):
    if not RUNTIME.exists():
        raise SystemExit('Missing Funkot runtime authority')
    text=RUNTIME.read_text(encoding='utf-8')
    rows='\n'.join(' {title=%s,id=%s,style="funkot"},'%(q(title),q(aid)) for title,aid in tracks)
    new_block='local PLAYLIST={\n'+rows+'\n}'
    text2,n=re.subn(r'local PLAYLIST=\{.*?\n\}',new_block,text,count=1,flags=re.S)
    if n!=1:
        raise SystemExit('Could not patch Funkot PLAYLIST block')
    text2=text2.replace('Only verified LIVE + permissioned assets are exposed.','Only verified Approved + permissioned registry assets are exposed.')
    RUNTIME.write_text(text2,encoding='utf-8')


def write_shim(count):
    SHIM.write_text('''-- BBYA SOCIAL HUB — FUNKOT UPLOADER REGISTRY SHIM v6
-- Intentionally no playback. Runtime authority is 93-funkot-music.server.lua.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
ReplicatedStorage:SetAttribute("BBYAFunkotUploaderRegistryShim",true)
ReplicatedStorage:SetAttribute("BBYAFunkotRegistryTrackCount",%d)
print("[BBYA] Funkot uploader registry shim v6; verified registry only")
'''%count,encoding='utf-8')


def main():
    reg=json.loads(REG.read_text(encoding='utf-8'))
    tracks=active(reg)
    if not tracks:
        raise SystemExit('No verified Funkot runtime tracks')
    patch_runtime(tracks)
    write_shim(len(tracks))
    print(json.dumps({
        'playlistId':'funkot',
        'runtimeAuthority':'93-funkot-music.server.lua',
        'runtimeVersion':6,
        'trackCount':len(tracks),
        'assetIds':[aid for _,aid in tracks],
        'policy':'approved_permissioned_registry_only'
    },ensure_ascii=False))


if __name__=='__main__':
    main()
