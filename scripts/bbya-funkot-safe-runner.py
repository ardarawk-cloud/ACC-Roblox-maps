#!/usr/bin/env python3
import json, os, pathlib, subprocess, sys, datetime

ROOT=pathlib.Path(__file__).resolve().parents[1]
REG=ROOT/'maps'/'bbya-social-hub'/'audio-playlists'/'funkot.json'
BLACK=ROOT/'maps'/'bbya-social-hub'/'audio-playlists'/'funkot-blacklist.json'
IDX=int(os.environ['TRACK_INDEX'])
REPORT=ROOT/'deploy-status'/f'bbya-funkot-track{IDX:02d}.json'
TRIM_APPLIED=str(os.environ.get('TRIM_APPLIED','')).strip().lower() in {'1','true','yes'}
NORMALIZED_SHA256=str(os.environ.get('NORMALIZED_SHA256','')).strip().lower()
UPLOAD_DURATION_SECONDS=str(os.environ.get('UPLOAD_DURATION_SECONDS','')).strip()
UPLOAD_SIZE_BYTES=str(os.environ.get('UPLOAD_SIZE_BYTES','')).strip()

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
    if not track: raise SystemExit('TRACK_MISSING_FOR_DURATION_LIMIT')
    track['sourceSha256']=report.get('sourceSha256') or track.get('sourceSha256')
    if NORMALIZED_SHA256:
        track['normalizedSha256']=NORMALIZED_SHA256
    if UPLOAD_DURATION_SECONDS:
        try: track['uploadDurationSeconds']=float(UPLOAD_DURATION_SECONDS)
        except ValueError: pass
    if UPLOAD_SIZE_BYTES:
        try: track['uploadSizeBytes']=int(UPLOAD_SIZE_BYTES)
        except ValueError: pass
    track['bbyaPermission']=False
    track['moderationLastKnown']=None
    track['platformRejectCode']=code
    track['platformRejectMessage']=msg
    op=report.get('operationResult') or report.get('uploadResponse') or {}
    track['platformOperationId']=op.get('operationId')
    track['durationLimitAt']=now()

    bl=load(BLACK,{'playlistId':'funkot','entries':[]})
    entries=bl.setdefault('entries',[])

    if TRIM_APPLIED:
        status='BLACKLISTED_PLATFORM_DURATION_LIMIT_AFTER_TRIM'
        reason='ROBLOX_PLATFORM_AUDIO_DURATION_TOO_LONG_AFTER_SAFE_TRIM'
        track['status']=status
        track['durationTrimApplied']=True
        track['blacklistedAt']=now()
        if not any(int(x.get('index',0))==IDX and x.get('reason')==reason for x in entries):
            entries.append({
                'index':IDX,'title':track.get('title'),'driveFileId':track.get('driveFileId'),'assetId':None,
                'sourceSha256':track.get('sourceSha256'),'normalizedSha256':track.get('normalizedSha256'),
                'reason':reason,'platformCode':code,'platformMessage':msg,
                'operationId':track.get('platformOperationId'),'blacklistedAt':track['blacklistedAt']
            })
    else:
        status='RETRY_WITH_DURATION_TRIM'
        track['status']=status
        track['durationTrimRequired']=True
        entries[:]=[x for x in entries if not (int(x.get('index',0))==IDX and x.get('reason')=='ROBLOX_PLATFORM_AUDIO_DURATION_TOO_LONG')]

    save(REG,reg)
    save(BLACK,bl)
    report['status']=status
    report['safeContinue']=True
    report['readyToInject']=False
    report['trimApplied']=TRIM_APPLIED
    report['normalizedSha256']=NORMALIZED_SHA256 or None
    report['updatedAt']=now()
    save(REPORT,report)
    print(json.dumps({'trackIndex':IDX,'status':status,'reason':msg,'trimApplied':TRIM_APPLIED},ensure_ascii=False))
    raise SystemExit(0)

raise SystemExit(proc.returncode)
