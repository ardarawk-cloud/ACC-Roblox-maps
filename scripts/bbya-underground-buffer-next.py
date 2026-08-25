#!/usr/bin/env python3
import json
from pathlib import Path

REGISTRY = Path('maps/bbya-social-hub/audio-playlists/underground.json')

NEXT = [
    ('[ IRSA ] GATHEL - NDX 2025 ( BKB ) Album DJ  STAR VOL. 2', '1xPUrqCT-typPBDmqEsmhKpJqDK--589K', 'audio/mpeg', 10340366),
    ('YOU ARE MY SUNSHINE - Cookies Minor - BKB', '1m1xAHuM1YTvulyjHJC34NGh0C1c4DBhK', 'audio/mpeg', 10525045),
    ('Where Have You Been {Crypton} BKB Edit', '1ZMbc8qmy6yporywUPFGDHX9FC69VjeT7', 'audio/mpeg', 11793658),
    ('VOICES IN MY HEAD _ CRYSHEILA BKB REMIX _ - CRYSHEILA - SoundLoadMate.com', '1aLXWtWlCpVAru0zwmsDDl2BcV_SV2LQF', 'audio/mpeg', 3902755),
    ('TOR MONITOR KETUA - QMUNK AMSTRONG#BKB PRIVAT', '1Q70S8uQfKHe6h6UjwmYz5l5l7Le4jxun', 'audio/mpeg', 12320211),
    ('TIMELESS - Nathalie Holscher x Derina Derin x Ajun Perwira (BKB EDIT)  Bpm -132', '1wIejDDinHeWov-gxfMpeqUhP58Zqh0ED', 'audio/mpeg', 10463184),
    ('Thank You - El kiyano (Bkb edit)', '1O79L86kYD8XU5smlK4GD5KeS4vR_c2yq', 'audio/mpeg', 14405288),
    ('TANPA CINTA V2 2025 - Alka Flow BKB', '16KpxIPS9E9r-F_pkGWehuNmbWyOy8y5c', 'audio/mpeg', 14405347),
    ('SOMEWHERE - RC BKB REMIX -', '13v_mfcgbzaTujpKfzmXfe8H_Kc6TbpyT', 'audio/mpeg', 10249819),
]

reg = json.loads(REGISTRY.read_text(encoding='utf-8'))
tracks = reg.setdefault('tracks', [])
known = {str(t.get('driveFileId') or '') for t in tracks}
next_index = max([int(t.get('index', 0)) for t in tracks] or [0]) + 1
added = []
for title, drive_id, mime, size in NEXT:
    if drive_id in known:
        continue
    tracks.append({
        'index': next_index,
        'title': title,
        'driveFileId': drive_id,
        'sourceMimeType': mime,
        'sourceSizeBytes': size,
        'assetId': None,
        'bbyaPermission': False,
        'status': 'PREPARED_LOCAL',
        'moderationLastKnown': None,
    })
    added.append({'index': next_index, 'driveFileId': drive_id, 'title': title})
    known.add(drive_id)
    next_index += 1

REGISTRY.write_text(json.dumps(reg, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
print(json.dumps({'addedCount': len(added), 'added': added}, indent=2, ensure_ascii=False))
