#!/usr/bin/env python3
import datetime
import json
import os
import pathlib
import subprocess
import time
import urllib.error
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[1]
REGISTRY = ROOT / 'maps' / 'bbya-social-hub' / 'audio-playlists' / 'funkot.json'
BLACKLIST = ROOT / 'maps' / 'bbya-social-hub' / 'audio-playlists' / 'funkot-blacklist.json'
TRACK_INDEX = int(os.environ['TRACK_INDEX'])
REPORT = ROOT / 'deploy-status' / f'bbya-funkot-track{TRACK_INDEX:02d}.json'
AUDIO_PATH = pathlib.Path(os.environ.get('AUDIO_PATH', '/tmp/bbya-funkot-none.mp3'))
SOURCE_SHA256 = os.environ.get('SOURCE_SHA256', '').strip().lower()
NORMALIZED_SHA256 = os.environ.get('NORMALIZED_SHA256', '').strip().lower()
AUDIO_KEY = os.environ.get('AUDIO_KEY', '').strip()
EXPECTED_UPLOADER = os.environ.get('EXPECTED_UPLOADER_USERNAME', 'gudangpet88').strip().lower()
BBYA_UNIVERSE = os.environ.get('BBYA_UNIVERSE', '8116636513').strip()
WAIT_SECONDS = int(os.environ.get('MODERATION_WAIT_SECONDS', '480'))
REPORT.parent.mkdir(parents=True, exist_ok=True)

TERMINAL_BLACKLIST = {'BLACKLISTED_MODERATION_REJECTED', 'BLACKLISTED_DUPLICATE_SOURCE', 'BLACKLISTED_PLATFORM_DURATION_LIMIT_AFTER_TRIM'}


def now_iso():
    return datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).isoformat()


def load(path):
    return json.loads(path.read_text(encoding='utf-8'))


def save(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


def req(url, method='GET', payload=None, headers=None, timeout=30):
    body = None if payload is None else json.dumps(payload).encode()
    h = dict(headers or {})
    if payload is not None and 'Content-Type' not in h:
        h['Content-Type'] = 'application/json'
    request = urllib.request.Request(url, data=body, headers=h, method=method)
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            raw = response.read().decode('utf-8', 'replace')
            return response.status, json.loads(raw) if raw.strip() else {}
    except urllib.error.HTTPError as exc:
        raw = exc.read().decode('utf-8', 'replace')
        try:
            data = json.loads(raw) if raw.strip() else {}
        except Exception:
            data = {'raw': raw[-4000:]}
        return exc.code, data
    except Exception as exc:
        return 0, {'error': repr(exc)}


def introspect():
    code, info = req('https://apis.roblox.com/api-keys/v1/introspect', 'POST', {'apiKey': AUDIO_KEY})
    scopes = info.get('scopes') or [] if isinstance(info, dict) else []
    asset = any(s.get('name') == 'asset' and {'read', 'write'}.issubset(set(s.get('operations') or [])) for s in scopes)
    perm = any(s.get('name') == 'asset-permissions:write' or (s.get('name') == 'asset-permissions' and 'write' in (s.get('operations') or [])) for s in scopes)
    return {
        'http': code,
        'keyName': info.get('name') if isinstance(info, dict) else None,
        'authorizedUserId': str(info.get('authorizedUserId')) if isinstance(info, dict) and info.get('authorizedUserId') is not None else None,
        'enabled': info.get('enabled') if isinstance(info, dict) else None,
        'expired': info.get('expired') if isinstance(info, dict) else None,
        'assetReadWrite': asset,
        'assetPermissionsWrite': perm,
    }


def resolve_uploader(user_id):
    code, data = req(f'https://users.roblox.com/v1/users/{user_id}')
    return {'http': code, 'userId': str(user_id), 'name': data.get('name') if isinstance(data, dict) else None, 'displayName': data.get('displayName') if isinstance(data, dict) else None}


def create_asset(title, creator):
    payload = {
        'assetType': 'Audio',
        'displayName': title[:50],
        'description': f'BBYA Funkot Track {TRACK_INDEX:02d}',
        'creationContext': {'creator': {'userId': str(creator)}},
    }
    process = subprocess.run([
        'curl', '-sS', '--location', 'https://apis.roblox.com/assets/v1/assets',
        '--header', f'x-api-key: {AUDIO_KEY}',
        '--form-string', 'request=' + json.dumps(payload, separators=(',', ':')),
        '--form', f'fileContent=@{AUDIO_PATH};type=audio/mpeg',
        '--write-out', '\n%{http_code}',
    ], text=True, capture_output=True)
    body, _, code = process.stdout.rpartition('\n')
    try:
        data = json.loads(body) if body.strip() else {}
    except Exception:
        data = {'raw': body[-4000:], 'stderr': process.stderr[-2000:]}
    try:
        code = int(code)
    except Exception:
        code = 0
    return code, data


def poll(path, timeout=300):
    end = time.time() + timeout
    last = {}
    while time.time() < end:
        _, last = req('https://apis.roblox.com/assets/v1/' + path.lstrip('/'), headers={'x-api-key': AUDIO_KEY})
        if isinstance(last, dict) and last.get('done'):
            return last
        time.sleep(3)
    return last or {'timeout': True}


def modval(data):
    return str(((data or {}).get('moderationResult') or {}).get('moderationState') or '')


def approved(state):
    return 'APPROVED' in str(state).upper()


def rejected(state):
    return any(token in str(state).upper() for token in ('REJECTED', 'DENIED', 'FAILED'))


def fetch_asset(asset_id):
    last_code, last_data = 0, {}
    for url in (f'https://apis.roblox.com/assets/v1/assets/{asset_id}?readMask=moderationResult,state,displayName', f'https://apis.roblox.com/assets/v1/assets/{asset_id}'):
        last_code, last_data = req(url, headers={'x-api-key': AUDIO_KEY})
        if last_code == 200:
            return last_code, last_data
    return last_code, last_data


def wait_mod(asset_id, state):
    history = []
    end = time.time() + WAIT_SECONDS
    while not approved(state) and not rejected(state) and time.time() < end:
        code, data = fetch_asset(asset_id)
        new_state = modval(data)
        state = new_state or state
        history.append({'http': code, 'state': state, 'checkedAt': now_iso()})
        if approved(state) or rejected(state):
            break
        time.sleep(15)
    return state, history[-20:]


def grant(asset_id):
    payload = {'subjectType': 'Universe', 'subjectId': str(BBYA_UNIVERSE), 'action': 'Use', 'requests': [{'assetId': int(asset_id)}]}
    code, data = req('https://apis.roblox.com/asset-permissions-api/v1/assets/permissions', 'PATCH', payload, {'x-api-key': AUDIO_KEY, 'Content-Type': 'application/json-patch+json'})
    ok = str(asset_id) in [str(x) for x in (data.get('successAssetIds') or [])] or code in (200, 201, 204)
    return {'http': code, 'ok': ok, 'response': data}


def append_blacklist(track, reason, moderation_state=None, duplicate_of=None):
    data = load(BLACKLIST) if BLACKLIST.exists() else {'playlistId': 'funkot', 'entries': []}
    entries = data.setdefault('entries', [])
    if not any(int(x.get('index', 0)) == TRACK_INDEX and x.get('reason') == reason for x in entries):
        entries.append({
            'index': TRACK_INDEX,
            'title': track.get('title'),
            'driveFileId': track.get('driveFileId'),
            'assetId': track.get('assetId'),
            'sourceSha256': track.get('sourceSha256'),
            'normalizedSha256': track.get('normalizedSha256'),
            'reason': reason,
            'moderationState': moderation_state,
            'duplicateOfIndex': duplicate_of,
            'blacklistedAt': now_iso(),
        })
    save(BLACKLIST, data)


def finish(reg, track, report, status, safe_continue, exit_code=0):
    track['status'] = status
    report['status'] = status
    report['safeContinue'] = bool(safe_continue)
    report['updatedAt'] = now_iso()
    save(REGISTRY, reg)
    save(REPORT, report)
    raise SystemExit(exit_code)


def main():
    reg = load(REGISTRY)
    track = next((t for t in reg.get('tracks', []) if int(t.get('index', 0)) == TRACK_INDEX), None)
    if not track:
        raise SystemExit(f'Track {TRACK_INDEX} missing')

    report = {
        'status': 'STARTED',
        'readyToInject': False,
        'safeContinue': False,
        'playlistId': reg.get('playlistId'),
        'trackIndex': TRACK_INDEX,
        'title': track.get('title'),
        'driveFileId': track.get('driveFileId'),
        'bbyaUniverseId': BBYA_UNIVERSE,
        'expectedUploaderUsername': EXPECTED_UPLOADER,
        'assetId': track.get('assetId'),
        'uploadReused': bool(track.get('assetId')),
        'sourceSha256': track.get('sourceSha256') or SOURCE_SHA256 or None,
        'normalizedSha256': track.get('normalizedSha256') or NORMALIZED_SHA256 or None,
        'startedAt': now_iso(),
    }

    if track.get('status') == 'READY_TO_INJECT' and track.get('assetId') and track.get('bbyaPermission') is True:
        report['status'] = 'READY_TO_INJECT'
        report['readyToInject'] = True
        report['safeContinue'] = True
        report['moderationState'] = track.get('moderationLastKnown')
        save(REPORT, report)
        return

    if not AUDIO_KEY:
        finish(reg, track, report, 'HALTED_SECRET_MISSING', False, 2)

    key = introspect()
    report['key'] = key
    if key['http'] != 200 or not key['authorizedUserId'] or not key['assetReadWrite'] or not key['assetPermissionsWrite'] or key['enabled'] is False or key['expired'] is True:
        finish(reg, track, report, 'HALTED_KEY_SCOPE_FAILED', False, 2)

    uploader = resolve_uploader(key['authorizedUserId'])
    report['uploader'] = uploader
    if uploader['http'] != 200 or str(uploader.get('name') or '').lower() != EXPECTED_UPLOADER:
        finish(reg, track, report, 'HALTED_UPLOADER_ACCOUNT_MISMATCH', False, 2)

    asset_id = str(track.get('assetId') or '').strip()
    state = str(track.get('moderationLastKnown') or '')

    if not asset_id:
        if not SOURCE_SHA256:
            finish(reg, track, report, 'HALTED_SOURCE_HASH_MISSING', False, 2)
        track['sourceSha256'] = SOURCE_SHA256
        if NORMALIZED_SHA256:
            track['normalizedSha256'] = NORMALIZED_SHA256
        report['sourceSha256'] = SOURCE_SHA256
        report['normalizedSha256'] = NORMALIZED_SHA256 or None
        fingerprint = NORMALIZED_SHA256 or SOURCE_SHA256
        duplicate = next((t for t in reg.get('tracks', []) if int(t.get('index', 0)) != TRACK_INDEX and (t.get('normalizedSha256') or t.get('sourceSha256')) == fingerprint and t.get('status') != 'PREPARED_LOCAL'), None)
        if duplicate:
            track['duplicateOfIndex'] = int(duplicate.get('index', 0))
            append_blacklist(track, 'EXACT_NORMALIZED_AUDIO_DUPLICATE', duplicate_of=track['duplicateOfIndex'])
            finish(reg, track, report, 'BLACKLISTED_DUPLICATE_SOURCE', True, 0)

        if not AUDIO_PATH.exists() or AUDIO_PATH.stat().st_size < 10000:
            finish(reg, track, report, 'HALTED_AUDIO_FILE_MISSING', False, 2)

        code, data = create_asset(track['title'], key['authorizedUserId'])
        report['uploadHttp'] = code
        report['uploadResponse'] = data
        if code not in (200, 201, 202) or not data.get('path'):
            finish(reg, track, report, 'HALTED_UPLOAD_FAILED', False, 2)

        operation = poll(data['path'])
        report['operationResult'] = operation
        response = (operation or {}).get('response') or {}
        asset_id = str(response.get('assetId') or '')
        state = modval(response)
        if not asset_id:
            finish(reg, track, report, 'HALTED_ASSET_ID_MISSING', False, 2)

        track['assetId'] = asset_id
        track['moderationLastKnown'] = state or None
        track['status'] = 'UPLOADED_MODERATION_PENDING'
        report['assetId'] = asset_id
        report['uploadReused'] = False
        save(REGISTRY, reg)
        save(REPORT, report)

    state, history = wait_mod(asset_id, state)
    report['moderationState'] = state
    report['moderationChecks'] = history
    track['moderationLastKnown'] = state or track.get('moderationLastKnown')

    if rejected(state):
        append_blacklist(track, 'ROBLOX_MODERATION_REJECTED', moderation_state=state)
        finish(reg, track, report, 'BLACKLISTED_MODERATION_REJECTED', True, 0)

    if not approved(state):
        finish(reg, track, report, 'MODERATION_PENDING', True, 0)

    permission = grant(asset_id)
    report['bbyaPermission'] = permission
    track['bbyaPermission'] = bool(permission['ok'])
    if not permission['ok']:
        finish(reg, track, report, 'HALTED_PERMISSION_FAILED', False, 2)

    track['status'] = 'READY_TO_INJECT'
    report['status'] = 'READY_TO_INJECT'
    report['readyToInject'] = True
    report['safeContinue'] = True
    report['updatedAt'] = now_iso()
    save(REGISTRY, reg)
    save(REPORT, report)


if __name__ == '__main__':
    main()
