#!/usr/bin/env python3
import hashlib
import json
import os
import pathlib
import shutil
import subprocess
import time

ROOT = pathlib.Path(__file__).resolve().parents[1]
REGISTRY = ROOT / 'maps' / 'bbya-social-hub' / 'audio-playlists' / 'underground.json'
BATCH_SIZE = max(1, min(10, int(os.environ.get('BATCH_SIZE', '10'))))
WAIT_SECONDS = max(0, int(os.environ.get('MODERATION_WAIT_SECONDS', '180')))
MAX_DURATION = float(os.environ.get('ROBLOX_AUDIO_MAX_SECONDS', '420'))
TMP = pathlib.Path(os.environ.get('RUNNER_TEMP', '/tmp'))
ELIGIBLE = {
    'PREPARED_LOCAL', 'UPLOADED_MODERATION_PENDING', 'MODERATION_PENDING',
    'PERMISSION_FAILED', 'READY_TO_INJECT'
}


def load(path):
    return json.loads(path.read_text(encoding='utf-8'))


def save(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


def run(cmd, *, cwd=None, env=None, capture=False):
    print('+', ' '.join(str(x) for x in cmd), flush=True)
    return subprocess.run(
        [str(x) for x in cmd], cwd=cwd, env=env, check=True,
        text=True, capture_output=capture
    )


def rel(path):
    return str(path.relative_to(ROOT))


def persist_checkpoint(idx, report_path):
    run(['git', 'add', rel(REGISTRY), rel(report_path)], cwd=ROOT)
    staged = subprocess.run(['git', 'diff', '--cached', '--quiet'], cwd=ROOT)
    if staged.returncode == 0:
        print(f'No checkpoint delta for Underground Track {idx:03d}')
        return
    run(['git', 'commit', '-m', f'Checkpoint Underground Track {idx} serial batch [skip ci]'], cwd=ROOT)
    run(['git', 'pull', '--rebase', 'origin', 'main'], cwd=ROOT)
    run(['git', 'push', 'origin', 'HEAD:main'], cwd=ROOT)


def probe(path):
    d = run([
        'ffprobe', '-v', 'error', '-show_entries', 'format=duration',
        '-show_entries', 'stream=codec_name', '-of', 'json', path
    ], capture=True)
    info = json.loads(d.stdout or '{}')
    duration = float(((info.get('format') or {}).get('duration') or 0) or 0)
    streams = info.get('streams') or []
    codec = str((streams[0] if streams else {}).get('codec_name') or '')
    return duration, codec


def sha256(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def mark_source_terminal(track, status, reason, report_path, extra=None):
    reg = load(REGISTRY)
    t = next(x for x in reg.get('tracks', []) if int(x.get('index', 0)) == int(track['index']))
    t['status'] = status
    t['terminal'] = True
    t['terminalReason'] = reason
    t['doNotRetryUnmodified'] = True
    if extra:
        t.update(extra)
    report = {
        'status': status,
        'readyToInject': False,
        'playlistId': reg.get('playlistId'),
        'trackIndex': int(t['index']),
        'title': t.get('title'),
        'driveFileId': t.get('driveFileId'),
        'assetId': t.get('assetId'),
        'terminal': True,
        'terminalReason': reason,
    }
    if extra:
        report.update(extra)
    save(REGISTRY, reg)
    save(report_path, report)
    persist_checkpoint(int(t['index']), report_path)
    return report


def prepare_source(track, report_path):
    idx = int(track['index'])
    raw = TMP / f'bbya-underground-{idx:03d}.source'
    out = TMP / f'bbya-underground-{idx:03d}.mp3'
    for p in (raw, out):
        try:
            p.unlink()
        except FileNotFoundError:
            pass
    run(['gdown', f'https://drive.google.com/uc?id={track["driveFileId"]}', '-O', raw])
    if not raw.exists() or raw.stat().st_size < 1000:
        raise RuntimeError(f'SOURCE_DOWNLOAD_EMPTY track={idx}')
    digest = sha256(raw)
    duration, codec = probe(raw)
    print(json.dumps({'trackIndex': idx, 'duration': duration, 'codec': codec, 'sha256': digest}, indent=2))

    reg = load(REGISTRY)
    current = next(x for x in reg.get('tracks', []) if int(x.get('index', 0)) == idx)
    current['sourceSha256'] = digest
    duplicate = next((
        x for x in reg.get('tracks', [])
        if int(x.get('index', 0)) != idx and x.get('sourceSha256') == digest
        and (x.get('assetId') or x.get('terminal') or x.get('blacklisted'))
    ), None)
    save(REGISTRY, reg)
    if duplicate:
        return None, mark_source_terminal(
            current, 'SOURCE_DUPLICATE_SKIPPED',
            f'DUPLICATE_OF_TRACK_{int(duplicate.get("index", 0)):03d}', report_path,
            {'sourceSha256': digest, 'duplicateOfTrack': int(duplicate.get('index', 0))}
        )
    if duration <= 0 or duration > MAX_DURATION:
        return None, mark_source_terminal(
            current, 'SOURCE_INVALID_DURATION_TOO_LONG',
            'ROBLOX_AUDIO_DURATION_LIMIT_PRECHECK', report_path,
            {'sourceSha256': digest, 'sourceDurationSeconds': duration}
        )

    if codec == 'mp3':
        shutil.copy2(raw, out)
        print('Original MP3 bytes retained; no pitch/speed/key processing.')
    else:
        run([
            'ffmpeg', '-y', '-hide_banner', '-loglevel', 'error', '-i', raw,
            '-vn', '-ac', '2', '-ar', '44100', '-codec:a', 'libmp3lame', '-b:a', '192k', out
        ])
        print('Compatibility transcode only; no pitch/speed/key processing.')
    if not out.exists() or out.stat().st_size < 10000:
        raise RuntimeError(f'AUDIO_FILE_MISSING track={idx}')
    return out, None


def invoke_injector(track, audio_path):
    idx = int(track['index'])
    report_path = ROOT / 'deploy-status' / f'bbya-underground-track{idx:03d}.json'
    env = os.environ.copy()
    env.update({
        'TRACK_INDEX': str(idx),
        'AUDIO_PATH': str(audio_path),
        'MODERATION_WAIT_SECONDS': str(WAIT_SECONDS),
    })
    run(['python3', 'scripts/bbya-underground-single-inject.py'], cwd=ROOT, env=env)
    if not report_path.exists():
        raise RuntimeError(f'REPORT_MISSING track={idx}')
    report = load(report_path)
    persist_checkpoint(idx, report_path)
    return report


def main():
    reg = load(REGISTRY)
    candidates = [
        int(t['index']) for t in sorted(reg.get('tracks', []), key=lambda x: int(x.get('index', 999999)))
        if t.get('status') in ELIGIBLE and not t.get('blacklisted')
    ][:BATCH_SIZE]
    print(json.dumps({'batchSize': BATCH_SIZE, 'selectedTrackIndexes': candidates}, indent=2))
    summary = []

    for idx in candidates:
        reg = load(REGISTRY)
        track = next((t for t in reg.get('tracks', []) if int(t.get('index', 0)) == idx), None)
        if not track or track.get('blacklisted'):
            continue
        report_path = ROOT / 'deploy-status' / f'bbya-underground-track{idx:03d}.json'
        if track.get('status') == 'READY_TO_INJECT':
            summary.append({'trackIndex': idx, 'status': 'READY_TO_INJECT', 'reusedReady': True})
            continue

        asset_id = str(track.get('assetId') or '').strip()
        if asset_id:
            placeholder = TMP / f'bbya-underground-{idx:03d}-recheck.mp3'
            placeholder.write_bytes(b'')
            report = invoke_injector(track, placeholder)
        else:
            audio_path, terminal_report = prepare_source(track, report_path)
            if terminal_report is not None:
                report = terminal_report
            else:
                report = invoke_injector(track, audio_path)

        summary.append({
            'trackIndex': idx,
            'title': track.get('title'),
            'status': report.get('status'),
            'assetId': report.get('assetId'),
            'moderationState': report.get('moderationState'),
            'blacklisted': report.get('blacklisted', False),
            'readyToInject': report.get('readyToInject', False),
        })
        print(json.dumps(summary[-1], indent=2, ensure_ascii=False), flush=True)

    save(ROOT / 'deploy-status' / 'bbya-underground-serial-batch-last.json', {
        'status': 'BATCH_COMPLETE',
        'processedCount': len(summary),
        'batchSizeLimit': BATCH_SIZE,
        'moderationWaitSecondsPerTrack': WAIT_SECONDS,
        'tracks': summary,
        'recordedAtUnix': int(time.time()),
    })
    print(json.dumps({'processedCount': len(summary), 'tracks': summary}, indent=2, ensure_ascii=False))


if __name__ == '__main__':
    main()
