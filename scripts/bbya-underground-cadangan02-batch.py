#!/usr/bin/env python3
import json, os, pathlib, runpy, time

ROOT = pathlib.Path(__file__).resolve().parents[1]
REGISTRY = ROOT / 'maps' / 'bbya-social-hub' / 'audio-playlists' / 'underground.json'
SUMMARY = ROOT / 'deploy-status' / 'bbya-underground-cadangan02-batch-last.json'
BATCH_SIZE = max(1, min(10, int(os.environ.get('BATCH_SIZE', '10'))))

helpers = runpy.run_path(str(ROOT / 'scripts' / 'bbya-underground-serial-batch.py'))
prepare_source = helpers['prepare_source']
invoke_injector = helpers['invoke_injector']
load = helpers['load']
save = helpers['save']

RETRYABLE_NO_ASSET = {
    'PREPARED_LOCAL',
    'UPLOAD_FAILED',
    'SECRET_MISSING',
    'KEY_SCOPE_FAILED',
    'UPLOADER_ID_MISMATCH',
    'AUDIO_FILE_MISSING',
}


def main():
    reg = load(REGISTRY)
    candidates = []
    for t in sorted(reg.get('tracks', []), key=lambda x: int(x.get('index', 999999))):
        if len(candidates) >= BATCH_SIZE:
            break
        if t.get('blacklisted') or t.get('terminal'):
            continue
        if str(t.get('assetId') or '').strip():
            continue
        if t.get('status') not in RETRYABLE_NO_ASSET:
            continue
        candidates.append(int(t['index']))

    print(json.dumps({'uploaderMode':'CADANGAN_02_NEW_ASSETS_ONLY','selectedTrackIndexes':candidates}, indent=2))
    summary = []

    for idx in candidates:
        reg = load(REGISTRY)
        track = next(t for t in reg.get('tracks', []) if int(t.get('index', 0)) == idx)
        if track.get('assetId') or track.get('blacklisted') or track.get('terminal'):
            continue
        report_path = ROOT / 'deploy-status' / f'bbya-underground-track{idx:03d}.json'
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
            'readyToInject': report.get('readyToInject', False),
            'blacklisted': report.get('blacklisted', False),
            'uploaderUserId': ((report.get('key') or {}).get('authorizedUserId')),
        })
        print(json.dumps(summary[-1], indent=2, ensure_ascii=False), flush=True)

    save(SUMMARY, {
        'status': 'BATCH_COMPLETE',
        'uploaderMode': 'CADANGAN_02_NEW_ASSETS_ONLY',
        'processedCount': len(summary),
        'batchSizeLimit': BATCH_SIZE,
        'tracks': summary,
        'recordedAtUnix': int(time.time()),
    })

if __name__ == '__main__':
    main()
