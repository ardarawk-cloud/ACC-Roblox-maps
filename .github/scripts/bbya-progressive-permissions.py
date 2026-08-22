#!/usr/bin/env python3
import json
import os
import pathlib
import re
import urllib.error
import urllib.request

ROOT=pathlib.Path(__file__).resolve().parents[2]
SOURCE=ROOT/'maps'/'bbya-social-hub'/'30-club-systems.server.lua'
REPORT=ROOT/'deploy-status'/'bbya-progressive-permissions.json'
UNIVERSE_ID=os.environ.get('UNIVERSE_ID','8116636513').strip()


def request_json(url,method='GET',payload=None,headers=None):
    body=None if payload is None else json.dumps(payload).encode('utf-8')
    h=dict(headers or {})
    if payload is not None and 'Content-Type' not in h:
        h['Content-Type']='application/json'
    req=urllib.request.Request(url,data=body,headers=h,method=method)
    try:
        with urllib.request.urlopen(req,timeout=30) as r:
            raw=r.read().decode('utf-8','replace')
            return r.status,json.loads(raw) if raw.strip() else {}
    except urllib.error.HTTPError as e:
        raw=e.read().decode('utf-8','replace')
        try:
            data=json.loads(raw) if raw.strip() else {}
        except Exception:
            data={'raw':raw[-2000:]}
        return e.code,data


def key_info(key):
    if not key:
        return {'present':False}
    code,data=request_json('https://apis.roblox.com/api-keys/v1/introspect','POST',{'apiKey':key})
    if not isinstance(data,dict):
        data={}
    out={
        'present':True,
        'http':code,
        'name':data.get('name'),
        'authorizedUserId':str(data.get('authorizedUserId')) if data.get('authorizedUserId') is not None else None,
        'enabled':data.get('enabled'),
        'expired':data.get('expired'),
        'scopes':[],
    }
    for scope in data.get('scopes') or []:
        out['scopes'].append({'name':scope.get('name'),'operations':scope.get('operations') or []})
    uid=out.get('authorizedUserId')
    if uid:
        ucode,udata=request_json(f'https://users.roblox.com/v1/users/{uid}')
        if ucode==200 and isinstance(udata,dict):
            out['authorizedUsername']=udata.get('name')
    return out


def can_grant(info):
    if not info.get('present') or info.get('http')!=200:
        return False
    if info.get('enabled') is False or info.get('expired') is True:
        return False
    return any(s.get('name')=='asset-permissions:write' for s in info.get('scopes',[]))


def main():
    text=SOURCE.read_text(encoding='utf-8')
    block=text.split('-- MAIN_PROGRESSIVE_UPLOAD_BEGIN',1)[1].split('-- MAIN_PROGRESSIVE_UPLOAD_END',1)[0]
    ids=[]
    for value in re.findall(r'id="(\d+)"',block):
        if value not in ids:
            ids.append(value)

    report={
        'status':'STARTED',
        'universeId':UNIVERSE_ID,
        'playlistAssetCount':len(ids),
        'playlistAssetIds':ids,
        'uploadAttempted':False,
        'attempts':[],
    }

    granted=set()
    candidates=[
        ('ROBLOX_AUDIO_API_KEY',os.environ.get('AUDIO_KEY','').strip()),
        ('AM_STUDIO',os.environ.get('AM_STUDIO_KEY','').strip()),
    ]
    for label,key in candidates:
        info=key_info(key)
        attempt={'key':label,'keyInfo':info,'permissionAttempted':False}
        if not can_grant(info):
            attempt['result']='NO_PERMISSION_SCOPE_OR_KEY_UNAVAILABLE'
            report['attempts'].append(attempt)
            continue
        remaining=[x for x in ids if x not in granted]
        if not remaining:
            attempt['result']='NOT_NEEDED'
            report['attempts'].append(attempt)
            continue
        payload={
            'subjectType':'Universe',
            'subjectId':UNIVERSE_ID,
            'action':'Use',
            'requests':[{'assetId':int(x)} for x in remaining],
        }
        code,data=request_json(
            'https://apis.roblox.com/asset-permissions-api/v1/assets/permissions',
            'PATCH',payload,
            {'x-api-key':key,'Content-Type':'application/json-patch+json'},
        )
        attempt['permissionAttempted']=True
        attempt['http']=code
        attempt['response']=data
        success=[str(x) for x in (data.get('successAssetIds') or [])] if isinstance(data,dict) else []
        granted.update(success)
        attempt['successCount']=len(success)
        attempt['result']='SUCCESS' if code in (200,201,204) else 'FAILED'
        report['attempts'].append(attempt)
        if len(granted)==len(ids):
            break

    report['grantedAssetIds']=sorted(granted,key=int)
    report['grantedCount']=len(granted)
    report['missingAssetIds']=[x for x in ids if x not in granted]
    report['status']='GRANTED_ALL' if ids and len(granted)==len(ids) else 'PARTIAL_OR_FAILED'
    REPORT.parent.mkdir(parents=True,exist_ok=True)
    REPORT.write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    print(json.dumps({'status':report['status'],'assets':len(ids),'granted':len(granted),'uploadAttempted':False}))
    return 0 if report['status']=='GRANTED_ALL' else 3


if __name__=='__main__':
    raise SystemExit(main())
