#!/usr/bin/env python3
import json, os, pathlib, subprocess, time, urllib.request

REPO = pathlib.Path(__file__).resolve().parents[1]
WORK = REPO / '.tmp-bbya-audio'
TARGET = REPO / 'maps' / 'bbya-social-hub' / '85-basement-autodj.server.lua'
STATUS = REPO / 'deploy-status' / 'bbya-basement-drive-inject.json'
API_KEY = os.environ.get('ROBLOX_API_KEY','').strip()
UNIVERSE_ID = os.environ.get('UNIVERSE_ID','8116636513').strip()

TRACKS = [
 {'drive_id':'1pp6GHnoLs-wkmlLcoo33cOou2-uFO4XF','file':'ADXL_SEXY_PAPI_2025.mp3','title':'ADXL - SEXY PAPI 2025','style':'adxl-breakbeat','cut':False},
 {'drive_id':'1smUfcqGV7BlXgZ5Iw8Za4Jxox3eeQrQA','file':'ADXL_BANG_BANG_WIRO_SABLENG.mp3','title':'ADXL - BANG BANG WIRO SABLENG','style':'adxl-breakbeat','cut':False},
 {'drive_id':'13GV4hS1PQV8VIVpX0wQUxtqIEAtZ2RJV','file':'ADXL_SEMATA_KARENAMU_2023.mp3','title':'ADXL - SEMATA KARENAMU 2023','style':'jakarta-bounce','cut':True},
 {'drive_id':'1wGmz1gHTSPW02PueEsgwmtt3ZFVzUQXx','file':'ADXL_CINTA_KITA_2023.mp3','title':'ADXL - CINTA KITA 2023','style':'adxl-breakbeat','cut':True},
 {'drive_id':'1H_m4WH9KM5ruvDMQ5Dz5XQW7Ch93AFuX','file':'ADXL_BUTA_HATI_2023.mp3','title':'ADXL - BUTA HATI 2023','style':'adxl-breakbeat','cut':True},
]


def run(cmd):
    p=subprocess.run(cmd,text=True,capture_output=True)
    if p.returncode!=0:
        raise RuntimeError(f"command failed: {' '.join(cmd)}\n{p.stderr[-3000:]}")
    return p.stdout.strip()


def get_json(url, headers=None, timeout=30):
    req=urllib.request.Request(url,headers=headers or {})
    with urllib.request.urlopen(req,timeout=timeout) as r:
        return r.status,json.loads(r.read().decode('utf-8','replace'))


def post_json(url, payload, headers=None, timeout=30):
    body=json.dumps(payload).encode('utf-8')
    h={'Content-Type':'application/json'}
    if headers: h.update(headers)
    req=urllib.request.Request(url,data=body,headers=h,method='POST')
    with urllib.request.urlopen(req,timeout=timeout) as r:
        return r.status,json.loads(r.read().decode('utf-8','replace'))


def introspect_key():
    _,data=post_json('https://apis.roblox.com/api-keys/v1/introspect',{'apiKey':API_KEY})
    safe={
        'name':data.get('name'),
        'authorizedUserId':str(data.get('authorizedUserId')) if data.get('authorizedUserId') is not None else None,
        'enabled':data.get('enabled'),
        'expired':data.get('expired'),
        'expirationTimeUtc':data.get('expirationTimeUtc'),
        'scopes':[],
    }
    for scope in data.get('scopes') or []:
        if scope.get('name') in ('asset','asset-permissions:write'):
            safe['scopes'].append({
                'name':scope.get('name'),
                'operations':scope.get('operations') or [],
                'userIds':[str(x) for x in (scope.get('userIds') or [])],
                'groupIds':[str(x) for x in (scope.get('groupIds') or [])],
                'universeIds':[str(x) for x in (scope.get('universeIds') or [])],
            })
    return safe


def resolve_creator():
    _,data=get_json(f'https://games.roblox.com/v1/games?universeIds={UNIVERSE_ID}')
    rows=data.get('data') or []
    if not rows: raise RuntimeError('Universe creator lookup returned no data')
    c=rows[0].get('creator') or {}
    cid=c.get('id'); ctype=str(c.get('type') or '').lower()
    if not cid or ctype not in ('user','group'): raise RuntimeError(f'Unsupported creator: {c!r}')
    return {'type':ctype,'id':str(cid),'name':c.get('name')}


def download_drive(track):
    WORK.mkdir(parents=True,exist_ok=True)
    raw=WORK/('raw_'+track['file'])
    if raw.exists(): raw.unlink()
    run(['gdown',track['drive_id'],'-O',str(raw)])
    if not raw.exists() or raw.stat().st_size<100000:
        raise RuntimeError(f'Drive download failed for {track["title"]}')
    return raw


def prepare_audio(raw, track):
    out=WORK/track['file']
    if out.exists(): out.unlink()
    cmd=['ffmpeg','-y','-hide_banner','-loglevel','error','-i',str(raw)]
    if track['cut']:
        cmd += ['-t','410']
    cmd += ['-vn','-ac','2','-ar','44100','-b:a','128k','-codec:a','libmp3lame',str(out)]
    run(cmd)
    duration=float(run(['ffprobe','-v','error','-show_entries','format=duration','-of','default=noprint_wrappers=1:nokey=1',str(out)]))
    size=out.stat().st_size
    if duration>419.5: raise RuntimeError(f'Prepared audio over 7-minute limit: {duration}')
    if size>=20*1024*1024: raise RuntimeError(f'Prepared audio over 20MB limit: {size}')
    return out,duration,size


def creator_candidates(universe_creator, key_info):
    out=[]
    seen=set()
    asset_scopes=[s for s in key_info.get('scopes',[]) if s.get('name')=='asset' and 'write' in (s.get('operations') or [])]
    allowed_users=set()
    allowed_groups=set()
    for s in asset_scopes:
        allowed_users.update(s.get('userIds') or [])
        allowed_groups.update(s.get('groupIds') or [])

    def add(kind,cid,label):
        if not cid: return
        k=(kind,str(cid))
        if k in seen: return
        seen.add(k); out.append({'type':kind,'id':str(cid),'name':label})

    if universe_creator['type']=='user' and (universe_creator['id'] in allowed_users or '*' in allowed_users):
        add('user',universe_creator['id'],universe_creator.get('name') or 'universe-owner')
    if universe_creator['type']=='group' and (universe_creator['id'] in allowed_groups or '*' in allowed_groups):
        add('group',universe_creator['id'],universe_creator.get('name') or 'universe-owner')

    auth=key_info.get('authorizedUserId')
    if auth and (auth in allowed_users or '*' in allowed_users):
        add('user',auth,'api-key-owner')

    if not out:
        if auth: add('user',auth,'api-key-owner-fallback')
        add(universe_creator['type'],universe_creator['id'],universe_creator.get('name') or 'universe-owner-fallback')
    return out


def create_asset(file_path,title,creator):
    creator_field='groupId' if creator['type']=='group' else 'userId'
    payload={'assetType':'Audio','displayName':title[:50],'description':'BBYA Basement Indo / owner Drive upload','creationContext':{'creator':{creator_field:creator['id']}}}
    cmd=['curl','-sS','--location','https://apis.roblox.com/assets/v1/assets','--header',f'x-api-key: {API_KEY}','--form-string',f'request={json.dumps(payload,separators=(",",":"))}','--form',f'fileContent=@{file_path};type=audio/mpeg','--write-out','\n%{http_code}']
    p=subprocess.run(cmd,text=True,capture_output=True)
    body,_,code=p.stdout.rpartition('\n')
    try: data=json.loads(body) if body.strip() else {}
    except Exception: data={'raw':body[-4000:]}
    return int(code or 0),data


def poll_operation(path,timeout=240):
    url='https://apis.roblox.com/assets/v1/'+path.lstrip('/')
    deadline=time.time()+timeout; last={}
    while time.time()<deadline:
        try: _,last=get_json(url,{'x-api-key':API_KEY},30)
        except Exception as e: last={'poll_error':str(e)}
        if isinstance(last,dict) and last.get('done'): return last
        time.sleep(4)
    return last or {'timeout':True}


def inject_playlist(items):
    source=TARGET.read_text(encoding='utf-8')
    begin='-- ADXL_OWNER_UPLOAD_BEGIN'; end='-- ADXL_OWNER_UPLOAD_END'
    lines=[begin]
    for item in items:
        title=item['title'].replace('\\','\\\\').replace('"','\\"')
        lines.append(f' {{title="{title}",id="{item["assetId"]}",style="{item["style"]}"}},')
    lines.append(end)
    block='\n'.join(lines)
    if begin in source and end in source:
        source=source.split(begin,1)[0]+block+source.split(end,1)[1]
    else:
        anchor='local PLAYLIST={\n'
        if anchor not in source: raise RuntimeError('PLAYLIST anchor not found')
        source=source.replace(anchor,anchor+block+'\n',1)
    TARGET.write_text(source,encoding='utf-8')


def main():
    STATUS.parent.mkdir(parents=True,exist_ok=True)
    report={'universeId':UNIVERSE_ID,'source':'CONNECTED_GOOGLE_DRIVE','complete':False,'tracks':[]}
    if not API_KEY:
        report['error']='ROBLOX_API_KEY missing'; STATUS.write_text(json.dumps(report,indent=2)); return 2
    try:
        key_info=introspect_key()
        report['apiKey']=key_info
        creator=resolve_creator(); report['universeCreator']=creator
        candidates=creator_candidates(creator,key_info)
        report['creatorCandidates']=candidates
        completed=[]
        for t in TRACKS:
            row={'title':t['title'],'driveId':t['drive_id'],'cut':t['cut']}
            try:
                raw=download_drive(t)
                prepared,duration,size=prepare_audio(raw,t)
                row.update({'preparedDuration':round(duration,3),'preparedBytes':size})
                created=None; code=0; chosen=None; attempts=[]
                for candidate in candidates:
                    code,created=create_asset(prepared,t['title'],candidate)
                    attempts.append({'creator':candidate,'http':code,'response':created if code not in (200,201,202) else None})
                    if code in (200,201,202):
                        chosen=candidate
                        break
                row['createAttempts']=attempts
                row['createHttp']=code
                row['assetCreator']=chosen
                if code not in (200,201,202):
                    row['createResponse']=created
                    if code==403:
                        row['scopeHint']='Check introspected asset write scope and creator target; API key secret itself is still valid.'
                    report['tracks'].append(row); continue
                op_path=created.get('path'); row['operation']=op_path
                if not op_path:
                    row['error']='operation path missing'; row['createResponse']=created; report['tracks'].append(row); continue
                op=poll_operation(op_path); row['operationResult']=op
                response=(op or {}).get('response') or {}; asset_id=response.get('assetId')
                if not asset_id:
                    row['error']='asset operation returned no assetId'; report['tracks'].append(row); continue
                row['assetId']=str(asset_id)
                row['moderationState']=((response.get('moderationResult') or {}).get('moderationState'))
                completed.append({'title':t['title'],'style':t['style'],'assetId':str(asset_id)})
            except Exception as e:
                row['error']=str(e)
            report['tracks'].append(row)
        if len(completed)==len(TRACKS):
            inject_playlist(completed); report['complete']=True; report['injectedCount']=len(completed)
    except Exception as e:
        report['error']=str(e)
    STATUS.write_text(json.dumps(report,indent=2),encoding='utf-8')
    print(json.dumps(report,indent=2))
    return 0 if report.get('complete') else 2

if __name__=='__main__':
    raise SystemExit(main())
