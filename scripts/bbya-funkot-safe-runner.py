#!/usr/bin/env python3
import json, os, pathlib, subprocess, sys, datetime

ROOT=pathlib.Path(__file__).resolve().parents[1]
REG=ROOT/'maps'/'bbya-social-hub'/'audio-playlists'/'funkot.json'
BLACK=ROOT/'maps'/'bbya-social-hub'/'audio-playlists'/'funkot-blacklist.json'
IDX=int(os.environ['TRACK_INDEX'])
REPORT=ROOT/'deploy-status'/f'bbya-funkot-track{IDX:02d}.json'

def load(p,default=None):
    if not p.exists(): return {} if default is None else default
    return json.loads(p.read_text(encoding='utf-8'))

def save(p,d):
    p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(json.dumps(d,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')

def now(): return datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).isoformat()

proc=subprocess.run([sys.executable,str(ROOT/'scripts'/'bbya-funkot-single-inject.py')],env=os.environ.copy())
report=load(REPORT,{})
if report:
    print(json.dumps(report,ensure_ascii=False))

err=((report.get('operationResult') or {}).get('error') or {}) if isinstance(report,dict) else {}
msg=str(err.get('message') or '')
code=str(err.get('code') or '')
if report.get('status')=='HALTED_ASSET_ID_MISSING' and code=='InvalidArgument' and 'audio duration too long' in msg.lower():
    reg=load(REG)
    track=next((t for t in reg.get('tracks',[]) if int(t.get('index',0))==IDX),None)
    if not track: raise SystemExit('TRACK_MISSING_FOR_DURATION_BLACKLIST')
    track['sourceSha256']=report.get('sourceSha256') or track.get('sourceSha256')
    track['status']='BLACKLISTED_PLATFORM_DURATION_LIMIT'
    track['bbyaPermission']=False
    track['moderationLastKnown']=None
    track['platformRejectCode']=code
    track['platformRejectMessage']=msg
    op=report.get('operationResult') or report.get('uploadResponse') or {}
    track['platformOperationId']=op.get('operationId')
    track['blacklistedAt']=now()
    save(REG,reg)
    bl=load(BLACK,{'playlistId':'funkot','entries':[]})
    entries=bl.setdefault('entries',[])
    if not any(int(x.get('index',0))==IDX and x.get('reason')=='ROBLOX_PLATFORM_AUDIO_DURATION_TOO_LONG' for x in entries):
        entries.append({
            'index':IDX,'title':track.get('title'),'driveFileId':track.get('driveFileId'),'assetId':None,
            'sourceSha256':track.get('sourceSha256'),'reason':'ROBLOX_PLATFORM_AUDIO_DURATION_TOO_LONG',
            'platformCode':code,'platformMessage':msg,'operationId':track.get('platformOperationId'),'blacklistedAt':track['blacklistedAt']
        })
    save(BLACK,bl)
    report['status']='BLACKLISTED_PLATFORM_DURATION_LIMIT'
    report['safeContinue']=True
    report['readyToInject']=False
    report['updatedAt']=now()
    save(REPORT,report)
    print(json.dumps({'trackIndex':IDX,'status':'BLACKLISTED_PLATFORM_DURATION_LIMIT','reason':msg},ensure_ascii=False))
    raise SystemExit(0)

raise SystemExit(proc.returncode)
