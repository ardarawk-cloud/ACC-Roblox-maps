#!/usr/bin/env python3
import json, os, pathlib, subprocess, sys, time, urllib.request, urllib.error

REPO = pathlib.Path(__file__).resolve().parents[1]
STAGING = REPO / 'maps' / 'bbya-social-hub' / 'audio-staging'
TARGET = REPO / 'maps' / 'bbya-social-hub' / '85-basement-autodj.server.lua'
STATUS = REPO / 'deploy-status' / 'bbya-basement-audio-inject.json'
API_KEY = os.environ.get('ROBLOX_API_KEY', '').strip()
UNIVERSE_ID = os.environ.get('UNIVERSE_ID', '8116636513').strip()

TRACKS = [
    {'file':'ADXL_SEXY_PAPI_2025.mp3','title':'ADXL - SEXY PAPI 2025','style':'adxl-breakbeat'},
    {'file':'ADXL_BANG_BANG_WIRO_SABLENG.mp3','title':'ADXL - BANG BANG WIRO SABLENG','style':'adxl-breakbeat'},
    {'file':'ADXL_SEMATA_KARENAMU_2023.mp3','title':'ADXL - SEMATA KARENAMU 2023','style':'jakarta-bounce'},
    {'file':'ADXL_CINTA_KITA_2023.mp3','title':'ADXL - CINTA KITA 2023','style':'adxl-breakbeat'},
    {'file':'ADXL_BUTA_HATI_2023.mp3','title':'ADXL - BUTA HATI 2023','style':'adxl-breakbeat'},
]

def get_json(url, headers=None, timeout=30):
    req = urllib.request.Request(url, headers=headers or {})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.status, json.loads(r.read().decode('utf-8', 'replace'))

def resolve_creator():
    status, data = get_json(f'https://games.roblox.com/v1/games?universeIds={UNIVERSE_ID}')
    rows = data.get('data') or []
    if not rows:
        raise RuntimeError('Universe creator lookup returned no data')
    c = rows[0].get('creator') or {}
    cid = c.get('id')
    ctype = str(c.get('type') or '').lower()
    if not cid or ctype not in ('user','group'):
        raise RuntimeError(f'Unsupported creator payload: {c!r}')
    return {'type':ctype, 'id':str(cid), 'name':c.get('name')}

def curl_create(file_path, title, creator):
    creator_field = 'groupId' if creator['type']=='group' else 'userId'
    payload = {
        'assetType':'Audio',
        'displayName':title[:50],
        'description':'BBYA Basement Indo / owner supplied club audio',
        'creationContext':{'creator':{creator_field:creator['id']}},
    }
    cmd = [
        'curl','-sS','--location','https://apis.roblox.com/assets/v1/assets',
        '--header',f'x-api-key: {API_KEY}',
        '--form-string',f'request={json.dumps(payload, separators=(",",":"))}',
        '--form',f'fileContent=@{file_path};type=audio/mpeg',
        '--write-out','\n%{http_code}'
    ]
    p = subprocess.run(cmd, text=True, capture_output=True)
    if p.returncode != 0:
        return 0, {'curl_error':p.stderr.strip()}
    body, _, code = p.stdout.rpartition('\n')
    try: parsed = json.loads(body) if body.strip() else {}
    except Exception: parsed = {'raw':body[-4000:]}
    return int(code or 0), parsed

def poll_operation(path, timeout=180):
    url = 'https://apis.roblox.com/assets/v1/' + path.lstrip('/')
    deadline = time.time() + timeout
    last = None
    while time.time() < deadline:
        try:
            _, last = get_json(url, {'x-api-key':API_KEY}, 30)
        except Exception as e:
            last = {'poll_error':str(e)}
        if isinstance(last, dict) and last.get('done'):
            return last
        time.sleep(3)
    return last or {'timeout':True}

def inject_playlist(items):
    source = TARGET.read_text(encoding='utf-8')
    begin = '-- ADXL_OWNER_UPLOAD_BEGIN'
    end = '-- ADXL_OWNER_UPLOAD_END'
    lines = [begin]
    for item in items:
        title = item['title'].replace('\\','\\\\').replace('"','\\"')
        style = item['style'].replace('"','')
        lines.append(f' {{title="{title}",id="{item["assetId"]}",style="{style}"}},')
    lines.append(end)
    block = '\n'.join(lines)
    if begin in source and end in source:
        pre = source.split(begin,1)[0]
        post = source.split(end,1)[1]
        source = pre + block + post
    else:
        needle = 'local PLAYLIST={\n'
        if needle not in source:
            raise RuntimeError('PLAYLIST anchor not found')
        source = source.replace(needle, needle + block + '\n', 1)
    TARGET.write_text(source, encoding='utf-8')

def main():
    STATUS.parent.mkdir(parents=True, exist_ok=True)
    report = {
        'universeId':UNIVERSE_ID,
        'complete':False,
        'required_permission':'Assets: Read + Write',
        'tracks':[],
    }
    if not API_KEY:
        report['error'] = 'ROBLOX_API_KEY missing'
        STATUS.write_text(json.dumps(report, indent=2), encoding='utf-8')
        return 2
    try:
        creator = resolve_creator()
        report['creator'] = creator
    except Exception as e:
        report['error'] = f'creator_lookup_failed: {e}'
        STATUS.write_text(json.dumps(report, indent=2), encoding='utf-8')
        return 2

    completed=[]
    for t in TRACKS:
        fp = STAGING / t['file']
        row = dict(t)
        if not fp.exists():
            row['error']='staging file missing'; report['tracks'].append(row); continue
        row['bytes']=fp.stat().st_size
        if row['bytes'] >= 20*1024*1024:
            row['error']='file >=20MB'; report['tracks'].append(row); continue
        code, created = curl_create(fp, t['title'], creator)
        row['createHttp']=code
        if code not in (200,201,202):
            row['createResponse']=created
            if code == 403:
                row['scopeHint']='Open Cloud key needs Assets Read/Write access for this creator'
            report['tracks'].append(row)
            continue
        op_path = created.get('path')
        row['operation']=op_path
        if not op_path:
            row['createResponse']=created; row['error']='operation path missing'; report['tracks'].append(row); continue
        op = poll_operation(op_path)
        row['operationResult']=op
        response = (op or {}).get('response') or {}
        asset_id = response.get('assetId')
        if asset_id:
            row['assetId']=str(asset_id)
            row['moderationState']=((response.get('moderationResult') or {}).get('moderationState'))
            completed.append({'title':t['title'],'style':t['style'],'assetId':str(asset_id)})
        else:
            row['error']='asset operation did not return assetId'
        report['tracks'].append(row)

    if len(completed)==len(TRACKS):
        inject_playlist(completed)
        report['complete']=True
        report['injectedCount']=len(completed)
    STATUS.write_text(json.dumps(report, indent=2), encoding='utf-8')
    print(json.dumps({'complete':report['complete'],'creator':report.get('creator'),'assets':[x.get('assetId') for x in report['tracks']]}, indent=2))
    return 0 if report['complete'] else 2

if __name__=='__main__':
    raise SystemExit(main())
