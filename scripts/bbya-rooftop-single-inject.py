#!/usr/bin/env python3
import datetime
import hashlib
import json
import os
import pathlib
import subprocess
import time
import urllib.error
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[1]
REGISTRY = ROOT / 'maps' / 'bbya-social-hub' / 'audio-playlists' / 'rooftop-tropical.json'
BLACKLIST = ROOT / 'maps' / 'bbya-social-hub' / 'audio-playlists' / 'rooftop-tropical-blacklist.json'
TRACK_INDEX = int(os.environ['TRACK_INDEX'])
REPORT = ROOT / 'deploy-status' / f'bbya-rooftop-track{TRACK_INDEX:02d}.json'
AUDIO_PATH = pathlib.Path(os.environ.get('AUDIO_PATH', '/tmp/bbya-rooftop-none.mp3'))
SOURCE_SHA256 = os.environ.get('SOURCE_SHA256', '').strip().lower()
AUDIO_KEY = os.environ.get('AUDIO_KEY', '').strip()
EXPECTED_UPLOADER = os.environ.get('EXPECTED_UPLOADER_USERNAME', 'gudangpet88').strip().lower()
BBYA_UNIVERSE = os.environ.get('BBYA_UNIVERSE', '8116636513').strip()
WAIT_SECONDS = int(os.environ.get('MODERATION_WAIT_SECONDS', '420'))
REPORT.parent.mkdir(parents=True, exist_ok=True)


def now_iso():
    return datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).isoformat()


def load(path, default=None):
    if not path.exists():
        return {} if default is None else default
    return json.loads(path.read_text(encoding='utf-8'))


def save(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


def req(url, method='GET', payload=None, headers=None, timeout=30):
    body = None if payload is None else json.dumps(payload).encode('utf-8')
    h = dict(headers or {})
    if payload is not None and 'Content-Type' not in h:
        h['Content-Type'] = 'application/json'
    r = urllib.request.Request(url, data=body, headers=h, method=method)
    try:
        with urllib.request.urlopen(r, timeout=timeout) as x:
            raw = x.read().decode('utf-8', 'replace')
            return x.status, json.loads(raw) if raw.strip() else {}
    except urllib.error.HTTPError as e:
        raw = e.read().decode('utf-8', 'replace')
        try: data = json.loads(raw) if raw.strip() else {}
        except Exception: data = {'raw': raw[-4000:]}
        return e.code, data
    except Exception as e:
        return 0, {'error': repr(e)}


def moderation_value(data):
    if not isinstance(data, dict): return ''
    candidates = [data]
    if isinstance(data.get('response'), dict): candidates.append(data['response'])
    for d in candidates:
        mr = d.get('moderationResult') or {}
        v = mr.get('moderationState') or d.get('moderationState')
        if v: return str(v)
    return ''


def moderation_class(state):
    s = str(state or '').upper()
    if 'APPROVED' in s: return 'APPROVED'
    if any(x in s for x in ('REJECT', 'DENIED', 'BLOCK', 'FAILED')): return 'REJECTED'
    return 'PENDING'


def introspect():
    code, d = req('https://apis.roblox.com/api-keys/v1/introspect', 'POST', {'apiKey': AUDIO_KEY})
    scopes = d.get('scopes') or [] if isinstance(d, dict) else []
    asset = any(s.get('name') == 'asset' and {'read','write'}.issubset(set(s.get('operations') or [])) for s in scopes)
    perm = any(s.get('name') == 'asset-permissions:write' or (s.get('name') == 'asset-permissions' and 'write' in (s.get('operations') or [])) for s in scopes)
    return code, d, asset, perm


def resolve_user(uid):
    return req(f'https://users.roblox.com/v1/users/{uid}')


def create_asset(title, uid):
    request = {
        'assetType': 'Audio',
        'displayName': (title or f'BBYA Rooftop {TRACK_INDEX:02d}')[:50],
        'description': f'BBYA Social Hub Rooftop Track {TRACK_INDEX:02d}',
        'creationContext': {'creator': {'userId': str(uid)}},
    }
    p = subprocess.run([
        'curl','-sS','--location','https://apis.roblox.com/assets/v1/assets',
        '--header',f'x-api-key: {AUDIO_KEY}',
        '--form-string','request=' + json.dumps(request, separators=(',', ':'), ensure_ascii=False),
        '--form',f'fileContent=@{AUDIO_PATH};type=audio/mpeg',
        '--write-out','\n%{http_code}'
    ], text=True, capture_output=True)
    body, _, code_text = p.stdout.rpartition('\n')
    try: code = int(code_text.strip())
    except Exception: code = 0
    try: data = json.loads(body) if body.strip() else {}
    except Exception: data = {'raw': body[-4000:], 'stderr': p.stderr[-2000:]}
    return code, data


def poll_operation(path, timeout=300):
    end = time.time() + timeout
    last = {}
    while time.time() < end:
        _, last = req('https://apis.roblox.com/assets/v1/' + str(path).lstrip('/'), headers={'x-api-key': AUDIO_KEY})
        if isinstance(last, dict) and last.get('done'): return last
        time.sleep(3)
    return last


def fetch_asset(asset_id):
    for url in (f'https://apis.roblox.com/assets/v1/assets/{asset_id}?readMask=moderationResult,state,displayName', f'https://apis.roblox.com/assets/v1/assets/{asset_id}'):
        code, d = req(url, headers={'x-api-key': AUDIO_KEY})
        if code == 200: return code, d
    return code, d


def wait_moderation(asset_id, initial=''):
    state = initial
    history = []
    end = time.time() + WAIT_SECONDS
    while moderation_class(state) == 'PENDING' and time.time() < end:
        code, d = fetch_asset(asset_id)
        state = moderation_value(d) or state
        history.append({'http': code, 'state': state or 'Reviewing', 'checkedAt': now_iso()})
        if moderation_class(state) != 'PENDING': break
        time.sleep(15)
    return state or 'Reviewing', history[-20:]


def grant(asset_id):
    payload = {'subjectType':'Universe','subjectId':str(BBYA_UNIVERSE),'action':'Use','requests':[{'assetId':int(asset_id)}]}
    code, d = req('https://apis.roblox.com/asset-permissions-api/v1/assets/permissions','PATCH',payload,{'x-api-key':AUDIO_KEY,'Content-Type':'application/json-patch+json'})
    ids = [str(x) for x in (d.get('successAssetIds') or [])] if isinstance(d, dict) else []
    return code in (200,201,204) or str(asset_id) in ids, code, d


def add_blacklist(track, reason, moderation=None, duplicate_of=None):
    d = load(BLACKLIST, {'playlistId':'rooftop-tropical','entries':[]})
    entries = d.setdefault('entries', [])
    if not any(int(x.get('index',0)) == TRACK_INDEX and x.get('reason') == reason for x in entries):
        entries.append({
            'index': TRACK_INDEX,
            'title': track.get('title'),
            'driveFileId': track.get('driveFileId'),
            'assetId': track.get('assetId'),
            'sourceSha256': track.get('sourceSha256'),
            'reason': reason,
            'moderationState': moderation,
            'duplicateOfIndex': duplicate_of,
            'blacklistedAt': now_iso(),
        })
    save(BLACKLIST, d)


def finish(reg, track, report, status, safe_continue, code=0):
    track['status'] = status
    report['status'] = status
    report['safeContinue'] = bool(safe_continue)
    report['updatedAt'] = now_iso()
    save(REGISTRY, reg)
    save(REPORT, report)
    raise SystemExit(code)


def main():
    reg = load(REGISTRY)
    track = next((t for t in reg.get('tracks',[]) if int(t.get('index',0)) == TRACK_INDEX), None)
    if not track: raise SystemExit('ROOFTOP_TRACK_MISSING')
    report = {
        'status':'STARTED','playlistId':reg.get('playlistId'),'trackIndex':TRACK_INDEX,'title':track.get('title'),
        'driveFileId':track.get('driveFileId'),'assetId':track.get('assetId'),'bbyaUniverseId':BBYA_UNIVERSE,
        'expectedUploaderUsername':EXPECTED_UPLOADER,'safeContinue':False,'startedAt':now_iso()
    }
    if track.get('status') == 'READY_TO_INJECT' and track.get('assetId') and track.get('bbyaPermission') is True:
        report.update({'status':'READY_TO_INJECT','safeContinue':True,'readyToInject':True})
        save(REPORT, report); return
    if not AUDIO_KEY: finish(reg, track, report, 'HALTED_SECRET_MISSING', False, 2)
    key_code, key, asset_rw, perm_w = introspect()
    uid = str(key.get('authorizedUserId') or '') if isinstance(key, dict) else ''
    report['key'] = {'http':key_code,'authorizedUserId':uid,'assetReadWrite':asset_rw,'assetPermissionsWrite':perm_w,'enabled':key.get('enabled'),'expired':key.get('expired')}
    if key_code != 200 or not uid or not asset_rw or not perm_w or key.get('enabled') is False or key.get('expired') is True:
        finish(reg, track, report, 'HALTED_KEY_SCOPE_FAILED', False, 2)
    user_code, user = resolve_user(uid)
    report['uploader'] = {'http':user_code,'userId':uid,'name':user.get('name') if isinstance(user,dict) else None}
    if user_code != 200 or str(user.get('name') or '').lower() != EXPECTED_UPLOADER:
        finish(reg, track, report, 'HALTED_UPLOADER_ACCOUNT_MISMATCH', False, 2)

    asset_id = str(track.get('assetId') or '').strip()
    state = str(track.get('moderationLastKnown') or '')
    if not asset_id:
        if not SOURCE_SHA256: finish(reg, track, report, 'HALTED_SOURCE_HASH_MISSING', False, 2)
        track['sourceSha256'] = SOURCE_SHA256
        report['sourceSha256'] = SOURCE_SHA256
        duplicate = next((t for t in reg.get('tracks',[]) if int(t.get('index',0)) != TRACK_INDEX and str(t.get('sourceSha256') or '').lower() == SOURCE_SHA256 and str(t.get('status') or '') not in ('PENDING_UPLOAD','PREPARED_LOCAL')), None)
        if duplicate:
            dup_idx = int(duplicate.get('index',0))
            track['duplicateOfIndex'] = dup_idx
            add_blacklist(track,'EXACT_SOURCE_AUDIO_DUPLICATE',duplicate_of=dup_idx)
            finish(reg, track, report, 'BLACKLISTED_DUPLICATE_SOURCE', True, 0)
        if not AUDIO_PATH.exists() or AUDIO_PATH.stat().st_size < 10000:
            finish(reg, track, report, 'HALTED_AUDIO_FILE_MISSING', False, 2)
        actual = hashlib.sha256(AUDIO_PATH.read_bytes()).hexdigest()
        report['uploadFileSha256'] = actual
        code, data = create_asset(track.get('title'), uid)
        report['uploadHttp'] = code; report['uploadResponse'] = data
        if code not in (200,201,202) or not data.get('path'):
            finish(reg, track, report, 'HALTED_UPLOAD_FAILED', False, 2)
        op = poll_operation(data['path'])
        report['operationResult'] = op
        response = (op or {}).get('response') or {}
        asset_id = str(response.get('assetId') or '')
        state = moderation_value(response)
        if not asset_id: finish(reg, track, report, 'HALTED_ASSET_ID_MISSING', False, 2)
        track['assetId'] = asset_id; track['moderationLastKnown'] = state or None; track['status'] = 'UPLOADED_MODERATION_PENDING'
        report['assetId'] = asset_id
        save(REGISTRY, reg); save(REPORT, report)

    state, history = wait_moderation(asset_id, state)
    report['moderationState'] = state; report['moderationChecks'] = history
    track['moderationLastKnown'] = state
    cls = moderation_class(state)
    if cls == 'REJECTED':
        add_blacklist(track,'ROBLOX_MODERATION_REJECTED',moderation=state)
        finish(reg, track, report, 'BLACKLISTED_MODERATION_REJECTED', True, 0)
    if cls != 'APPROVED':
        finish(reg, track, report, 'MODERATION_PENDING', True, 0)
    ok, perm_code, perm_data = grant(asset_id)
    report['bbyaPermission'] = {'ok':ok,'http':perm_code,'response':perm_data}
    track['bbyaPermission'] = bool(ok)
    if not ok: finish(reg, track, report, 'HALTED_PERMISSION_FAILED', False, 2)
    track['status'] = 'READY_TO_INJECT'
    report.update({'status':'READY_TO_INJECT','readyToInject':True,'safeContinue':True,'updatedAt':now_iso()})
    save(REGISTRY, reg); save(REPORT, report)

if __name__ == '__main__':
    main()
