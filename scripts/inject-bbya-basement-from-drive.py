#!/usr/bin/env python3
import concurrent.futures
import hashlib
import json
import os
import pathlib
import re
import subprocess
import threading
import time
import urllib.parse
import urllib.request
from datetime import datetime, timezone

REPO = pathlib.Path(__file__).resolve().parents[1]
WORK = REPO / ".tmp-bbya-audio-full"
TARGET = REPO / "maps" / "bbya-social-hub" / "85-basement-autodj.server.lua"
MAIN_CLUB = REPO / "maps" / "bbya-social-hub" / "30-club-systems.server.lua"
STATUS = REPO / "deploy-status" / "bbya-basement-drive-inject.json"
REGISTRY = REPO / "deploy-status" / "bbya-basement-drive-registry.json"

API_KEY = os.environ.get("ROBLOX_API_KEY", "").strip()
UNIVERSE_ID = os.environ.get("UNIVERSE_ID", "8116636513").strip()
WORKERS = max(1, min(8, int(os.environ.get("AUDIO_UPLOAD_WORKERS", "5"))))
MAX_NEW_UPLOADS = int(os.environ.get("MAX_NEW_AUDIO_UPLOADS", "0"))  # 0 = no local cap
ALLOWED_EXTENSIONS = {".mp3", ".ogg", ".wav", ".flac"}

# Priority order: the four genre folders first, then the remaining owner library.
SOURCE_FOLDERS = [
    {"name": "FUNKOT", "id": "1YB4xGNjTPk9f01D38NfQ4590DB8rBADS", "style": "funkot"},
    {"name": "BREAKBEAT CAMPUR", "id": "1Dfng7YAgz7kcH0Qz3hyeXdwHzqYOR0Hs", "style": "breakbeat"},
    {"name": "TEMBAK LANGIT REMIX", "id": "1rwTIqIKdgai3EbU4AFhUGTIaZkwxkBwE", "style": "tembak-langit"},
    {"name": "PROGRESIVE", "id": "1WdYH8ICus8WHPuVDvX0b4LOa9LbbBSCd", "style": "progressive"},
    {"name": "ADXL", "id": "1iEejJxtEUfT0aZOdO95qLfrNRiKQS-SN", "style": "adxl-breakbeat"},
    {"name": "AGUS ZERO NINE", "id": "1YVEHy5zquX2JoOfqTQwQq-ybwrVOQT2u", "style": "indo-dj"},
    {"name": "BLB", "id": "1R32-IgWMnLiPZkgwSG37EfdUFKsL3yB7", "style": "indo-dj"},
    {"name": "DINAR KONAY", "id": "1SZ-zVws-QnYkysS8zncckt058KQDB1Q7", "style": "indo-dj"},
    {"name": "EVERT EVRAIN", "id": "1DxBHntae-bkrAtBdURwvUacqgIGVhhkc", "style": "indo-dj"},
    {"name": "EXEL SACK", "id": "1-8_GFHcCi9-LmSEquEJ5T1_XbYrHJWT1", "style": "indo-dj"},
    {"name": "HARRY PANGALILA", "id": "1TN_ZzrS1zhim6PXa5DOKMdhHTHBdKL49", "style": "indo-dj"},
    {"name": "IVAN CELLO", "id": "1SmcUU34b5Qi_XVjVfXxLpNj0K6kHkXVh", "style": "indo-dj"},
    {"name": "IANMUSICK", "id": "1tL1IxyyBglFTyB5YD4FPYf93dnFj0G_4", "style": "indo-dj"},
    {"name": "MIXTAPE FAZAR FADILLAH", "id": "17fB5-fuTYJ3koh9oc7kBarendYFGGLGJ", "style": "indo-dj"},
    {"name": "RENAL ALVARO", "id": "17nmfj9VVJ0eelLyJ1NwFGwiEqixNG2H3", "style": "indo-dj"},
    {"name": "REY LIMITLESS", "id": "1Qx_SBSWi8u68MnKemNdvZzczQWh15kC1", "style": "indo-dj"},
    {"name": "RONALD 3D", "id": "1x71Db6dC-pBBWJS_yhKZ1kxkPJZZxdJB", "style": "indo-dj"},
    {"name": "RR", "id": "1uhhPEO3lMdV9ptGqqDt923q_d7-GuJX5", "style": "indo-dj"},
    {"name": "SET LIST FAZAR FADILLAH", "id": "1ukwoQNlDl7VMhA0BSg_DVUe3qwojfTJk", "style": "indo-dj"},
    {"name": "KHOIR WIRAWINATA", "id": "1vhVGvH2wyRcRSMuyFH3MapPxp8_WEOfw", "style": "indo-dj"},
]

# Five already-created assets from the first successful ADXL owner batch.
LEGACY_EXISTING = {
    "1pp6GHnoLs-wkmlLcoo33cOou2-uFO4XF": {
        "assetId": "140514006350666", "title": "ADXL - SEXY PAPI 2025", "style": "adxl-breakbeat"
    },
    "1smUfcqGV7BlXgZ5Iw8Za4Jxox3eeQrQA": {
        "assetId": "129311447065112", "title": "ADXL - BANG BANG WIRO SABLENG", "style": "adxl-breakbeat"
    },
    "13GV4hS1PQV8VIVpX0wQUxtqIEAtZ2RJV": {
        "assetId": "113513851570966", "title": "ADXL - SEMATA KARENAMU 2023", "style": "jakarta-bounce"
    },
    "1wGmz1gHTSPW02PueEsgwmtt3ZFVzUQXx": {
        "assetId": "103346687856740", "title": "ADXL - CINTA KITA 2023", "style": "adxl-breakbeat"
    },
    "1H_m4WH9KM5ruvDMQ5Dz5XQW7Ch93AFuX": {
        "assetId": "78901521795281", "title": "ADXL - BUTA HATI 2023", "style": "adxl-breakbeat"
    },
}

print_lock = threading.Lock()
claim_lock = threading.Lock()
claimed_hashes = {}


def utc_now():
    return datetime.now(timezone.utc).isoformat()


def log(msg):
    with print_lock:
        print(msg, flush=True)


def run(cmd, timeout=None):
    p = subprocess.run(cmd, text=True, capture_output=True, timeout=timeout)
    if p.returncode != 0:
        raise RuntimeError(f"command failed: {' '.join(map(str, cmd))}\n{p.stderr[-4000:]}")
    return p.stdout.strip()


def get_json(url, headers=None, timeout=30):
    req = urllib.request.Request(url, headers=headers or {})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.status, json.loads(r.read().decode("utf-8", "replace"))


def post_json(url, payload, headers=None, timeout=30):
    body = json.dumps(payload).encode("utf-8")
    h = {"Content-Type": "application/json"}
    if headers:
        h.update(headers)
    req = urllib.request.Request(url, data=body, headers=h, method="POST")
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.status, json.loads(r.read().decode("utf-8", "replace"))


def introspect_key():
    _, data = post_json("https://apis.roblox.com/api-keys/v1/introspect", {"apiKey": API_KEY})
    safe = {
        "name": data.get("name"),
        "authorizedUserId": str(data.get("authorizedUserId")) if data.get("authorizedUserId") is not None else None,
        "enabled": data.get("enabled"),
        "expired": data.get("expired"),
        "expirationTimeUtc": data.get("expirationTimeUtc"),
        "scopes": [],
    }
    for scope in data.get("scopes") or []:
        if scope.get("name") in ("asset", "asset-permissions:write"):
            safe["scopes"].append({
                "name": scope.get("name"),
                "operations": scope.get("operations") or [],
                "userIds": [str(x) for x in (scope.get("userIds") or [])],
                "groupIds": [str(x) for x in (scope.get("groupIds") or [])],
                "universeIds": [str(x) for x in (scope.get("universeIds") or [])],
            })
    return safe


def resolve_creator():
    _, data = get_json(f"https://games.roblox.com/v1/games?universeIds={UNIVERSE_ID}")
    rows = data.get("data") or []
    if not rows:
        raise RuntimeError("Universe creator lookup returned no data")
    c = rows[0].get("creator") or {}
    cid = c.get("id")
    ctype = str(c.get("type") or "").lower()
    if not cid or ctype not in ("user", "group"):
        raise RuntimeError(f"Unsupported creator: {c!r}")
    return {"type": ctype, "id": str(cid), "name": c.get("name")}


def creator_candidates(universe_creator, key_info):
    out = []
    seen = set()
    asset_scopes = [
        s for s in key_info.get("scopes", [])
        if s.get("name") == "asset" and "write" in (s.get("operations") or [])
    ]
    allowed_users = set()
    allowed_groups = set()
    for s in asset_scopes:
        allowed_users.update(s.get("userIds") or [])
        allowed_groups.update(s.get("groupIds") or [])

    def add(kind, cid, label):
        if not cid:
            return
        k = (kind, str(cid))
        if k in seen:
            return
        seen.add(k)
        out.append({"type": kind, "id": str(cid), "name": label})

    if universe_creator["type"] == "user" and (
        universe_creator["id"] in allowed_users or "*" in allowed_users
    ):
        add("user", universe_creator["id"], universe_creator.get("name") or "universe-owner")
    if universe_creator["type"] == "group" and (
        universe_creator["id"] in allowed_groups or "*" in allowed_groups
    ):
        add("group", universe_creator["id"], universe_creator.get("name") or "universe-owner")

    auth = key_info.get("authorizedUserId")
    if auth and (auth in allowed_users or "*" in allowed_users):
        add("user", auth, "api-key-owner")

    if not out:
        if auth:
            add("user", auth, "api-key-owner-fallback")
        add(
            universe_creator["type"],
            universe_creator["id"],
            universe_creator.get("name") or "universe-owner-fallback",
        )
    return out


def drive_id_from_url(url):
    m = re.search(r"/d/([^/]+)", url or "")
    if m:
        return m.group(1)
    q = urllib.parse.parse_qs(urllib.parse.urlparse(url or "").query)
    if q.get("id"):
        return q["id"][0]
    return None


def enumerate_source(source):
    raw = run(["gdown", source["id"], "--folder", "--json", "--quiet"], timeout=180)
    rows = json.loads(raw or "[]")
    out = []
    for row in rows:
        url = row.get("url") or ""
        relpath = str(row.get("path") or "").replace("\\", "/")
        ext = pathlib.PurePosixPath(relpath).suffix.lower()
        if ext not in ALLOWED_EXTENSIONS:
            continue
        drive_id = drive_id_from_url(url)
        if not drive_id:
            continue
        title = pathlib.PurePosixPath(relpath).stem.strip()
        if not title:
            title = f"BBYA Basement {drive_id[:8]}"
        out.append({
            "driveId": drive_id,
            "url": url,
            "path": relpath,
            "title": title,
            "style": source["style"],
            "sourceFolder": source["name"],
        })
    return out


def load_registry():
    if REGISTRY.exists():
        try:
            d = json.loads(REGISTRY.read_text(encoding="utf-8"))
        except Exception:
            d = {}
    else:
        d = {}
    if not isinstance(d, dict):
        d = {}
    d.setdefault("version", 2)
    d.setdefault("universeId", UNIVERSE_ID)
    d.setdefault("items", {})
    for drive_id, seed in LEGACY_EXISTING.items():
        if drive_id not in d["items"]:
            d["items"][drive_id] = {
                **seed,
                "driveId": drive_id,
                "sourceFolder": "ADXL",
                "legacy": True,
                "moderationState": "Reviewing",
                "uploadedAt": "2026-08-21T05:24:23+00:00",
            }
    return d


def save_registry(registry):
    registry["updatedAt"] = utc_now()
    REGISTRY.parent.mkdir(parents=True, exist_ok=True)
    REGISTRY.write_text(json.dumps(registry, ensure_ascii=False, indent=2), encoding="utf-8")


def sanitize_filename(value):
    value = re.sub(r"[^A-Za-z0-9._-]+", "_", value)
    return value[:100] or "audio"


def download_drive(item):
    WORK.mkdir(parents=True, exist_ok=True)
    ext = pathlib.PurePosixPath(item["path"]).suffix.lower() or ".bin"
    raw = WORK / f"raw_{sanitize_filename(item['driveId'])}{ext}"
    if raw.exists():
        raw.unlink()
    run(["gdown", item["url"], "-O", str(raw), "--quiet"], timeout=600)
    if not raw.exists() or raw.stat().st_size < 10000:
        raise RuntimeError(f"Drive download failed for {item['title']}")
    return raw


def prepare_audio(raw, item):
    out = WORK / f"ready_{sanitize_filename(item['driveId'])}.mp3"
    if out.exists():
        out.unlink()
    # Technical compatibility only: cap to 6m50s and transcode to a stable Roblox-safe MP3.
    cmd = [
        "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
        "-i", str(raw), "-t", "410", "-vn", "-ac", "2", "-ar", "44100",
        "-b:a", "128k", "-codec:a", "libmp3lame", str(out),
    ]
    run(cmd, timeout=600)
    duration = float(run([
        "ffprobe", "-v", "error", "-show_entries", "format=duration",
        "-of", "default=noprint_wrappers=1:nokey=1", str(out),
    ]))
    size = out.stat().st_size
    if duration > 419.5:
        raise RuntimeError(f"Prepared audio over 7-minute limit: {duration}")
    if size >= 20 * 1024 * 1024:
        raise RuntimeError(f"Prepared audio over 20MB limit: {size}")
    digest = hashlib.sha256(out.read_bytes()).hexdigest()
    return out, duration, size, digest


def create_asset(file_path, title, creator):
    creator_field = "groupId" if creator["type"] == "group" else "userId"
    payload = {
        "assetType": "Audio",
        "displayName": title[:50],
        "description": "BBYA Basement owner Drive library",
        "creationContext": {"creator": {creator_field: creator["id"]}},
    }
    cmd = [
        "curl", "-sS", "--location", "https://apis.roblox.com/assets/v1/assets",
        "--header", f"x-api-key: {API_KEY}",
        "--form-string", f"request={json.dumps(payload, separators=(',', ':'))}",
        "--form", f"fileContent=@{file_path};type=audio/mpeg",
        "--write-out", "\n%{http_code}",
    ]
    p = subprocess.run(cmd, text=True, capture_output=True)
    body, _, code = p.stdout.rpartition("\n")
    try:
        data = json.loads(body) if body.strip() else {}
    except Exception:
        data = {"raw": body[-4000:]}
    return int(code or 0), data


def poll_operation(path, timeout=300):
    url = "https://apis.roblox.com/assets/v1/" + path.lstrip("/")
    deadline = time.time() + timeout
    last = {}
    while time.time() < deadline:
        try:
            _, last = get_json(url, {"x-api-key": API_KEY}, 30)
        except Exception as e:
            last = {"poll_error": str(e)}
        if isinstance(last, dict) and last.get("done"):
            return last
        time.sleep(3)
    return last or {"timeout": True}


def looks_like_quota_or_rate_limit(code, payload):
    text = json.dumps(payload, ensure_ascii=False).lower()
    return code == 429 or "quota" in text or "rate limit" in text or "too many" in text


def process_item(item, candidates, hash_index):
    row = {
        "driveId": item["driveId"],
        "title": item["title"],
        "style": item["style"],
        "sourceFolder": item["sourceFolder"],
        "path": item["path"],
    }
    raw = None
    prepared = None
    try:
        raw = download_drive(item)
        prepared, duration, size, digest = prepare_audio(raw, item)
        row.update({
            "preparedDuration": round(duration, 3),
            "preparedBytes": size,
            "sha256": digest,
        })

        with claim_lock:
            if digest in hash_index:
                existing = hash_index[digest]
                row.update({
                    "result": "deduplicated",
                    "assetId": existing["assetId"],
                    "duplicateOfDriveId": existing.get("driveId"),
                    "moderationState": existing.get("moderationState"),
                })
                return row
            if digest in claimed_hashes:
                row.update({"result": "duplicate-pending", "error": "identical audio is already being uploaded in this run"})
                return row
            claimed_hashes[digest] = item["driveId"]

        created = None
        code = 0
        chosen = None
        attempts = []
        for candidate in candidates:
            code, created = create_asset(prepared, item["title"], candidate)
            attempts.append({
                "creator": candidate,
                "http": code,
                "response": created if code not in (200, 201, 202) else None,
            })
            if code in (200, 201, 202):
                chosen = candidate
                break
        row["createAttempts"] = attempts
        row["createHttp"] = code
        row["assetCreator"] = chosen

        if code not in (200, 201, 202):
            row["createResponse"] = created
            row["result"] = "failed"
            row["quotaOrRateLimit"] = looks_like_quota_or_rate_limit(code, created)
            return row

        op_path = (created or {}).get("path")
        row["operation"] = op_path
        if not op_path:
            row["result"] = "failed"
            row["error"] = "operation path missing"
            row["createResponse"] = created
            return row

        op = poll_operation(op_path)
        row["operationResult"] = op
        response = (op or {}).get("response") or {}
        asset_id = response.get("assetId")
        if not asset_id:
            row["result"] = "failed"
            row["error"] = "asset operation returned no assetId"
            return row

        row["assetId"] = str(asset_id)
        row["moderationState"] = ((response.get("moderationResult") or {}).get("moderationState"))
        row["result"] = "uploaded"
        with claim_lock:
            hash_index[digest] = {
                "assetId": str(asset_id),
                "driveId": item["driveId"],
                "moderationState": row.get("moderationState"),
            }
        return row
    except Exception as e:
        row["result"] = "failed"
        row["error"] = str(e)
        return row
    finally:
        for path in (raw, prepared):
            try:
                if path and pathlib.Path(path).exists():
                    pathlib.Path(path).unlink()
            except Exception:
                pass


def escape_lua_string(value):
    return str(value).replace("\\", "\\\\").replace('"', '\\"').replace("\n", " ")


def inject_playlist(registry):
    source = TARGET.read_text(encoding="utf-8")
    begin = "-- DRIVE_LIBRARY_UPLOAD_BEGIN"
    end = "-- DRIVE_LIBRARY_UPLOAD_END"

    entries = []
    for drive_id, item in registry.get("items", {}).items():
        if item.get("legacy") or not item.get("assetId"):
            continue
        entries.append((item.get("sourceOrder", 999), item.get("sourceFolder", ""), item.get("title", ""), drive_id, item))
    entries.sort(key=lambda x: (x[0], x[1].lower(), x[2].lower(), x[3]))

    lines = [begin]
    for _, _, _, _, item in entries:
        title = escape_lua_string(item.get("title") or "BBYA Basement Track")
        style = escape_lua_string(item.get("style") or "indo-dj")
        asset_id = str(item["assetId"])
        lines.append(f' {{title="{title}",id="{asset_id}",style="{style}"}},')
    lines.append(end)
    block = "\n".join(lines)

    if begin in source and end in source:
        source = source.split(begin, 1)[0] + block + source.split(end, 1)[1]
    else:
        adxl_end = "-- ADXL_OWNER_UPLOAD_END"
        if adxl_end in source:
            source = source.replace(adxl_end, adxl_end + "\n" + block, 1)
        else:
            anchor = "local PLAYLIST={\n"
            if anchor not in source:
                raise RuntimeError("PLAYLIST anchor not found")
            source = source.replace(anchor, anchor + block + "\n", 1)

    TARGET.write_text(source, encoding="utf-8")
    return len(entries)


def main():
    STATUS.parent.mkdir(parents=True, exist_ok=True)
    WORK.mkdir(parents=True, exist_ok=True)

    report = {
        "universeId": UNIVERSE_ID,
        "source": "CONNECTED_GOOGLE_DRIVE_FULL_LIBRARY",
        "target": "BASEMENT_ONLY",
        "complete": False,
        "startedAt": utc_now(),
        "workers": WORKERS,
        "sources": [],
        "tracks": [],
    }

    if not API_KEY:
        report["error"] = "ROBLOX_API_KEY missing"
        STATUS.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
        return 2

    if not TARGET.exists() or not MAIN_CLUB.exists():
        report["error"] = "BBYA audio targets missing"
        STATUS.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
        return 2

    main_club_before = hashlib.sha256(MAIN_CLUB.read_bytes()).hexdigest()
    registry = load_registry()
    save_registry(registry)

    try:
        key_info = introspect_key()
        report["apiKey"] = key_info
        creator = resolve_creator()
        report["universeCreator"] = creator
        candidates = creator_candidates(creator, key_info)
        report["creatorCandidates"] = candidates

        discovered = []
        seen_drive_ids = set()
        for source_order, source in enumerate(SOURCE_FOLDERS):
            src_report = {"name": source["name"], "folderId": source["id"], "style": source["style"]}
            try:
                rows = enumerate_source(source)
                src_report["audioFiles"] = len(rows)
                for row in rows:
                    if row["driveId"] in seen_drive_ids:
                        continue
                    seen_drive_ids.add(row["driveId"])
                    row["sourceOrder"] = source_order
                    discovered.append(row)
            except Exception as e:
                src_report["error"] = str(e)
            report["sources"].append(src_report)

        report["discoveredCount"] = len(discovered)
        existing_items = registry.get("items", {})
        pending = [x for x in discovered if not (existing_items.get(x["driveId"]) or {}).get("assetId")]
        report["alreadyRegisteredCount"] = len(discovered) - len(pending)

        if MAX_NEW_UPLOADS > 0:
            pending = pending[:MAX_NEW_UPLOADS]
            report["localUploadCap"] = MAX_NEW_UPLOADS

        hash_index = {}
        for drive_id, item in existing_items.items():
            if item.get("sha256") and item.get("assetId"):
                hash_index[item["sha256"]] = {**item, "driveId": drive_id}

        log(f"[BBYA/FullDrive] discovered={len(discovered)} pending={len(pending)} workers={WORKERS}")

        quota_stop = False
        newly_uploaded = 0
        deduplicated = 0
        failed = 0

        with concurrent.futures.ThreadPoolExecutor(max_workers=WORKERS) as pool:
            futures = {
                pool.submit(process_item, item, candidates, hash_index): item
                for item in pending
            }
            for future in concurrent.futures.as_completed(futures):
                item = futures[future]
                try:
                    row = future.result()
                except Exception as e:
                    row = {
                        "driveId": item["driveId"], "title": item["title"],
                        "sourceFolder": item["sourceFolder"], "style": item["style"],
                        "result": "failed", "error": str(e),
                    }

                report["tracks"].append(row)
                result = row.get("result")
                if result == "uploaded":
                    newly_uploaded += 1
                    reg_item = {
                        "driveId": row["driveId"],
                        "assetId": row["assetId"],
                        "title": row["title"],
                        "style": row["style"],
                        "sourceFolder": row["sourceFolder"],
                        "sourceOrder": item["sourceOrder"],
                        "path": item["path"],
                        "sha256": row.get("sha256"),
                        "moderationState": row.get("moderationState"),
                        "uploadedAt": utc_now(),
                    }
                    registry["items"][row["driveId"]] = reg_item
                    if row.get("sha256"):
                        hash_index[row["sha256"]] = reg_item
                    log(f"[BBYA/FullDrive] UPLOADED {row['assetId']} :: {row['title']}")
                elif result == "deduplicated":
                    deduplicated += 1
                    existing = None
                    for _, e in registry["items"].items():
                        if str(e.get("assetId")) == str(row.get("assetId")):
                            existing = e
                            break
                    registry["items"][row["driveId"]] = {
                        "driveId": row["driveId"],
                        "assetId": row["assetId"],
                        "title": row["title"],
                        "style": row["style"],
                        "sourceFolder": row["sourceFolder"],
                        "sourceOrder": item["sourceOrder"],
                        "path": item["path"],
                        "sha256": row.get("sha256"),
                        "moderationState": row.get("moderationState") or (existing or {}).get("moderationState"),
                        "duplicateOfDriveId": row.get("duplicateOfDriveId"),
                        "deduplicatedAt": utc_now(),
                    }
                    log(f"[BBYA/FullDrive] DEDUP {row['assetId']} :: {row['title']}")
                else:
                    failed += 1
                    if row.get("quotaOrRateLimit"):
                        quota_stop = True
                    registry["items"].setdefault(row["driveId"], {}).update({
                        "driveId": row["driveId"],
                        "title": row["title"],
                        "style": row["style"],
                        "sourceFolder": row["sourceFolder"],
                        "sourceOrder": item["sourceOrder"],
                        "path": item["path"],
                        "lastError": row.get("error") or row.get("createResponse"),
                        "lastAttemptAt": utc_now(),
                    })
                    log(f"[BBYA/FullDrive] FAILED :: {row['title']} :: {row.get('error') or row.get('createResponse')}")

                save_registry(registry)

        injected_count = inject_playlist(registry)
        report["newlyUploadedCount"] = newly_uploaded
        report["deduplicatedCount"] = deduplicated
        report["failedCount"] = failed
        report["injectedLibraryCount"] = injected_count
        report["quotaOrRateLimitSeen"] = quota_stop

        registered_discovered = sum(
            1 for x in discovered if (registry["items"].get(x["driveId"]) or {}).get("assetId")
        )
        report["registeredDiscoveredCount"] = registered_discovered
        report["complete"] = registered_discovered == len(discovered)
        if not report["complete"]:
            report["remainingCount"] = len(discovered) - registered_discovered

    except Exception as e:
        report["error"] = str(e)

    main_club_after = hashlib.sha256(MAIN_CLUB.read_bytes()).hexdigest()
    report["mainClubUntouched"] = main_club_before == main_club_after
    if not report["mainClubUntouched"]:
        report["complete"] = False
        report["error"] = "HARD GUARD: Main Club audio file changed; refusing Basement library run."

    save_registry(registry)
    report["finishedAt"] = utc_now()
    STATUS.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0 if report.get("mainClubUntouched") else 3


if __name__ == "__main__":
    raise SystemExit(main())
