#!/usr/bin/env python3
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
MAP = ROOT / 'maps' / 'bbya-social-hub'
REGISTRY = MAP / 'audio-playlists' / 'rooftop-tropical.json'
SERVER = MAP / '134-rooftop-playlist.server.lua'
PROJECT = MAP / 'default.project.json'


def q(v):
    return json.dumps(str(v), ensure_ascii=False)


def active_tracks(reg):
    return [t for t in sorted(reg.get('tracks', []), key=lambda x: int(x.get('index', 0)))
            if t.get('assetId') and t.get('bbyaPermission') is True
            and t.get('status') in {'READY_TO_INJECT', 'LIVE_IN_PLAYLIST'}]


def build_server(tracks):
    if not SERVER.exists():
        raise SystemExit('ROOFTOP_SERVER_TEMPLATE_MISSING')
    text = SERVER.read_text(encoding='utf-8')
    marker_start = 'local PLAYLIST={\n'
    marker_end = '\n}\nif #PLAYLIST==0 then return end'
    start = text.find(marker_start)
    if start < 0:
        raise SystemExit('ROOFTOP_PLAYLIST_START_MARKER_MISSING')
    end = text.find(marker_end, start)
    if end < 0:
        raise SystemExit('ROOFTOP_PLAYLIST_END_MARKER_MISSING')
    rows = ',\n'.join(
        ' {title=%s,assetId=%s}' % (q(t.get('title', '')), q(t.get('assetId', '')))
        for t in tracks
    )
    replacement = marker_start + rows
    text = text[:start] + replacement + text[end:]
    SERVER.write_text(text, encoding='utf-8')


def patch_project():
    d = json.loads(PROJECT.read_text(encoding='utf-8'))
    sss = d['tree']['ServerScriptService']
    sss['RooftopPlaylistAuthorityV1'] = {'$path': '134-rooftop-playlist.server.lua'}
    PROJECT.write_text(json.dumps(d, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


def main():
    reg = json.loads(REGISTRY.read_text(encoding='utf-8'))
    tracks = active_tracks(reg)
    if not tracks:
        raise SystemExit('NO_APPROVED_ROOFTOP_TRACKS')
    build_server(tracks)
    patch_project()
    print(json.dumps({
        'playlistId': reg.get('playlistId'),
        'trackCount': len(tracks),
        'assetIds': [t.get('assetId') for t in tracks],
        'runtimePreserved': True,
    }))


if __name__ == '__main__':
    main()
