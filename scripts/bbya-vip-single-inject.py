#!/usr/bin/env python3
import json, os, pathlib, subprocess, time, urllib.error, urllib.request

ROOT=pathlib.Path(__file__).resolve().parents[1]
REGISTRY=ROOT/'maps'/'bbya-social-hub'/'audio-playlists'/'vip-amapiano.json'
TRACK_INDEX=int(os.environ['TRACK_INDEX'])
REPORT=ROOT/'deploy-status'/f'bbya-vip-track{TRACK_INDEX:02d}.json'
AUDIO_PATH=pathlib.Path(os.environ['AUDIO_PATH'])
AUDIO_KEY=os.environ.get('AUDIO_KEY','').strip()
BBYA_UNIVERSE=os.environ.get('BBYA_UNIVERSE','8116636513').strip()
WAIT_SECONDS=int(os.environ.get('MODERATION_WAIT_SECONDS','480'))
REPORT.parent.mkdir(parents=True,exist_ok=True)

def load(p): return json.loads(p.read_text(encoding='utf-8'))
def save(p,d): p.write_text(json.dumps(d,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')

def req(url,method='GET',payload=None,headers=None,timeout=30):
    body=None if payload is None else json.dumps(payload).encode()
    h=dict(headers or {})
    if payload is not None and 'Content-Type' not in h: h['Content-Type']='application/json'
    r=urllib.request.Request(url,data=body,headers=h,method=method)
    try:
        with urllib.request.urlopen(r,timeout=timeout) as x:
            raw=x.read().decode('utf-8','replace')
            return x.status,json.loads(raw) if raw.strip() else {}
    except urllib.error.HTTPError as e:
        raw=e.read().decode('utf-8','replace')
        try: data=json.loads(raw) if raw.strip() else {}
        except Exception: data={'raw':raw[-4000:]}
        return e.code,data
    except Exception as e: return 0,{'error':repr(e)}

def introspect():
    code,info=req('https://apis.roblox.com/api-keys/v1/introspect','POST',{'apiKey':AUDIO_KEY})
    scopes=info.get('scopes') or [] if isinstance(info,dict) else []
    asset=any(s.get('name')=='asset' and {'read','write'}.issubset(set(s.get('operations') or [])) for s in scopes)
    perm=any(s.get('name')=='asset-permissions:write' or (s.get('name')=='asset-permissions' and 'write' in (s.get('operations') or [])) for s in scopes)
    return {'http':code,'keyName':info.get('name'),'authorizedUserId':str(info.get('authorizedUserId')) if info.get('authorizedUserId') is not None else None,'enabled':info.get('enabled'),'expired':info.get('expired'),'assetReadWrite':asset,'assetPermissionsWrite':perm}

def create_asset(title,creator):
    payload={'assetType':'Audio','displayName':title[:50],'description':f'BBYA VIP Amapiano Track {TRACK_INDEX:02d}','creationContext':{'creator':{'userId':str(creator)}}}
    p=subprocess.run(['curl','-sS','--location','https://apis.roblox.com/assets/v1/assets','--header',f'x-api-key: {AUDIO_KEY}','--form-string','request='+json.dumps(payload,separators=(',',':')),'--form',f'fileContent=@{AUDIO_PATH};type=audio/mpeg','--write-out','\n%{http_code}'],text=True,capture_output=True)
    body,_,code=p.stdout.rpartition('\n')
    try: data=json.loads(body) if body.strip() else {}
    except Exception: data={'raw':body[-4000:],'stderr':p.stderr[-2000:]}
    try: code=int(code)
    except Exception: code=0
    return code,data

def poll(path,timeout=300):
    end=time.time()+timeout; last={}
    while time.time()<end:
        _,last=req('https://apis.roblox.com/assets/v1/'+path.lstrip('/'),headers={'x-api-key':AUDIO_KEY})
        if isinstance(last,dict) and last.get('done'): return last
        time.sleep(3)
    return last or {'timeout':True}

def modval(d): return str(((d or {}).get('moderationResult') or {}).get('moderationState') or '')
def approved(s): return 'APPROVED' in str(s).upper()
def rejected(s): return any(x in str(s).upper() for x in ('REJECTED','DENIED','FAILED'))
def fetch_asset(aid):
    for u in (f'https://apis.roblox.com/assets/v1/assets/{aid}?readMask=moderationResult,state,displayName',f'https://apis.roblox.com/assets/v1/assets/{aid}'):
        c,d=req(u,headers={'x-api-key':AUDIO_KEY})
        if c==200:return c,d
    return c,d

def wait_mod(aid,state):
    hist=[]; end=time.time()+WAIT_SECONDS
    while not approved(state) and not rejected(state) and time.time()<end:
        c,d=fetch_asset(aid); n=modval(d); state=n or state; hist.append({'http':c,'state':state});
        if approved(state) or rejected(state): break
        time.sleep(15)
    return state,hist[-20:]

def grant(aid):
    payload={'subjectType':'Universe','subjectId':str(BBYA_UNIVERSE),'action':'Use','requests':[{'assetId':int(aid)}]}
    c,d=req('https://apis.roblox.com/asset-permissions-api/v1/assets/permissions','PATCH',payload,{'x-api-key':AUDIO_KEY,'Content-Type':'application/json-patch+json'})
    ok=str(aid) in [str(x) for x in (d.get('successAssetIds') or [])] or c in (200,201,204)
    return {'http':c,'ok':ok,'response':d}

def stop(reg,track,report,status):
    track['status']=status; report['status']=status; save(REGISTRY,reg); save(REPORT,report); raise SystemExit(0)

def main():
    reg=load(REGISTRY); track=next((t for t in reg['tracks'] if int(t.get('index',0))==TRACK_INDEX),None)
    if not track: raise SystemExit(f'Track {TRACK_INDEX} missing')
    report={'status':'STARTED','readyToInject':False,'playlistId':reg.get('playlistId'),'trackIndex':TRACK_INDEX,'title':track.get('title'),'driveFileId':track.get('driveFileId'),'musicalKey':track.get('musicalKey'),'camelot':track.get('camelot'),'bbyaUniverseId':BBYA_UNIVERSE,'assetId':track.get('assetId'),'uploadReused':bool(track.get('assetId'))}
    if not AUDIO_KEY: stop(reg,track,report,'SECRET_MISSING')
    key=introspect(); report['key']=key
    if key['http']!=200 or not key['authorizedUserId'] or not key['assetReadWrite'] or not key['assetPermissionsWrite'] or key['enabled'] is False or key['expired'] is True: stop(reg,track,report,'KEY_SCOPE_FAILED')
    aid=str(track.get('assetId') or '').strip(); state=str(track.get('moderationLastKnown') or '')
    if not aid:
        if not AUDIO_PATH.exists() or AUDIO_PATH.stat().st_size<10000: stop(reg,track,report,'AUDIO_FILE_MISSING')
        c,d=create_asset(track['title'],key['authorizedUserId']); report['uploadHttp']=c; report['uploadResponse']=d
        if c not in (200,201,202) or not d.get('path'): stop(reg,track,report,'UPLOAD_FAILED')
        op=poll(d['path']); report['operationResult']=op; r=(op or {}).get('response') or {}; aid=str(r.get('assetId') or ''); state=modval(r)
        if not aid: stop(reg,track,report,'ASSET_ID_MISSING')
        track['assetId']=aid; track['moderationLastKnown']=state or None; track['status']='UPLOADED_MODERATION_PENDING'; report['assetId']=aid; report['uploadReused']=False
    state,hist=wait_mod(aid,state); report['moderationState']=state; report['moderationChecks']=hist; track['moderationLastKnown']=state or track.get('moderationLastKnown')
    if rejected(state): stop(reg,track,report,'MODERATION_REJECTED')
    if not approved(state): stop(reg,track,report,'MODERATION_PENDING')
    g=grant(aid); report['bbyaPermission']=g; track['bbyaPermission']=bool(g['ok'])
    if not g['ok']: stop(reg,track,report,'PERMISSION_FAILED')
    track['status']='READY_TO_INJECT'; report['status']='READY_TO_INJECT'; report['readyToInject']=True; save(REGISTRY,reg); save(REPORT,report)

if __name__=='__main__': main()
