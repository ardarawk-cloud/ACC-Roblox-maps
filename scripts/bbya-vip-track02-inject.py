#!/usr/bin/env python3
import json
import os
import pathlib
import subprocess
import time
import urllib.error
import urllib.parse
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "maps" / "bbya-social-hub" / "audio-playlists" / "vip-amapiano.json"
REPORT = ROOT / "deploy-status" / "bbya-vip-track02.json"
AUDIO_PATH = pathlib.Path(os.environ.get("AUDIO_PATH", "/tmp/bbya-vip-track02-ready.mp3"))
AUDIO_KEY = os.environ.get("AUDIO_KEY", "").strip()
BBYA_UNIVERSE = os.environ.get("BBYA_UNIVERSE", "8116636513").strip()
TRACK_INDEX = 2
WAIT_SECONDS = int(os.environ.get("MODERATION_WAIT_SECONDS", "480"))

REPORT.parent.mkdir(parents=True, exist_ok=True)


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def req_json(url, method="GET", payload=None, headers=None, timeout=30):
    body = None if payload is None else json.dumps(payload).encode("utf-8")
    h = dict(headers or {})
    if payload is not None and "Content-Type" not in h:
        h["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=body, headers=h, method=method)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            raw = r.read().decode("utf-8", "replace")
            return r.status, json.loads(raw) if raw.strip() else {}
    except urllib.error.HTTPError as e:
        raw = e.read().decode("utf-8", "replace")
        try:
            data = json.loads(raw) if raw.strip() else {}
        except Exception:
            data = {"raw": raw[-4000:]}
        return e.code, data
    except Exception as e:
        return 0, {"error": repr(e)}


def introspect_key():
    code, info = req_json(
        "https://apis.roblox.com/api-keys/v1/introspect",
        "POST",
        {"apiKey": AUDIO_KEY},
    )
    scopes = info.get("scopes") or [] if isinstance(info, dict) else []
    asset_rw = any(
        s.get("name") == "asset"
        and "read" in (s.get("operations") or [])
        and "write" in (s.get("operations") or [])
        for s in scopes
    )
    perm_w = any(
        s.get("name") == "asset-permissions:write"
        or (s.get("name") == "asset-permissions" and "write" in (s.get("operations") or []))
        for s in scopes
    )
    return {
        "http": code,
        "keyName": info.get("name") if isinstance(info, dict) else None,
        "authorizedUserId": str(info.get("authorizedUserId")) if isinstance(info, dict) and info.get("authorizedUserId") is not None else None,
        "enabled": info.get("enabled") if isinstance(info, dict) else None,
        "expired": info.get("expired") if isinstance(info, dict) else None,
        "assetReadWrite": asset_rw,
        "assetPermissionsWrite": perm_w,
    }


def create_asset(title, creator_user_id):
    payload = {
        "assetType": "Audio",
        "displayName": title[:50],
        "description": "BBYA VIP Amapiano Track 02",
        "creationContext": {"creator": {"userId": str(creator_user_id)}},
    }
    cmd = [
        "curl", "-sS", "--location", "https://apis.roblox.com/assets/v1/assets",
        "--header", f"x-api-key: {AUDIO_KEY}",
        "--form-string", "request=" + json.dumps(payload, separators=(",", ":")),
        "--form", f"fileContent=@{AUDIO_PATH};type=audio/mpeg",
        "--write-out", "\n%{http_code}",
    ]
    p = subprocess.run(cmd, text=True, capture_output=True)
    body, _, code_text = p.stdout.rpartition("\n")
    try:
        data = json.loads(body) if body.strip() else {}
    except Exception:
        data = {"raw": body[-4000:], "stderr": p.stderr[-2000:]}
    try:
        code = int(code_text)
    except Exception:
        code = 0
    return code, data


def poll_operation(path, timeout=300):
    deadline = time.time() + timeout
    last = {}
    while time.time() < deadline:
        _, last = req_json(
            "https://apis.roblox.com/assets/v1/" + path.lstrip("/"),
            headers={"x-api-key": AUDIO_KEY},
        )
        if isinstance(last, dict) and last.get("done"):
            return last
        time.sleep(3)
    return last or {"timeout": True}


def moderation_value(data):
    if not isinstance(data, dict):
        return ""
    return str((data.get("moderationResult") or {}).get("moderationState") or "")


def is_approved(state):
    return "APPROVED" in str(state).upper()


def is_rejected(state):
    s = str(state).upper()
    return "REJECTED" in s or "DENIED" in s or "FAILED" in s


def fetch_asset(asset_id):
    urls = [
        f"https://apis.roblox.com/assets/v1/assets/{asset_id}?readMask=moderationResult,state,displayName",
        f"https://apis.roblox.com/assets/v1/assets/{asset_id}",
    ]
    last = (0, {})
    for url in urls:
        code, data = req_json(url, headers={"x-api-key": AUDIO_KEY})
        last = (code, data)
        if code == 200:
            return code, data
    return last


def wait_for_moderation(asset_id, initial_state):
    state = str(initial_state or "")
    history = []
    if is_approved(state) or is_rejected(state):
        return state, history
    deadline = time.time() + WAIT_SECONDS
    while time.time() < deadline:
        code, data = fetch_asset(asset_id)
        new_state = moderation_value(data)
        history.append({"http": code, "state": new_state or state})
        if new_state:
            state = new_state
        if is_approved(state) or is_rejected(state):
            break
        time.sleep(15)
    return state, history[-20:]


def grant_use(asset_id):
    payload = {
        "subjectType": "Universe",
        "subjectId": str(BBYA_UNIVERSE),
        "action": "Use",
        "requests": [{"assetId": int(asset_id)}],
    }
    code, data = req_json(
        "https://apis.roblox.com/asset-permissions-api/v1/assets/permissions",
        "PATCH",
        payload,
        {"x-api-key": AUDIO_KEY, "Content-Type": "application/json-patch+json"},
    )
    success = [str(x) for x in (data.get("successAssetIds") or [])] if isinstance(data, dict) else []
    return {
        "http": code,
        "successAssetIds": success,
        "ok": str(asset_id) in success or code in (200, 201, 204),
        "response": data,
    }


def main():
    registry = read_json(REGISTRY)
    track = next((t for t in registry.get("tracks", []) if int(t.get("index", 0)) == TRACK_INDEX), None)
    if not track:
        raise SystemExit("Track 02 missing from VIP Amapiano registry")

    report = {
        "status": "STARTED",
        "readyToInject": False,
        "playlistId": registry.get("playlistId"),
        "trackIndex": TRACK_INDEX,
        "title": track.get("title"),
        "driveFileId": track.get("driveFileId"),
        "musicalKey": track.get("musicalKey"),
        "camelot": track.get("camelot"),
        "bbyaUniverseId": BBYA_UNIVERSE,
        "assetId": track.get("assetId"),
        "uploadReused": bool(track.get("assetId")),
    }

    if not AUDIO_KEY:
        track["status"] = "SECRET_MISSING"
        report["status"] = "SECRET_MISSING"
        write_json(REGISTRY, registry); write_json(REPORT, report); return

    key = introspect_key()
    report["key"] = key
    if key.get("http") != 200 or not key.get("authorizedUserId") or not key.get("assetReadWrite") or not key.get("assetPermissionsWrite") or key.get("enabled") is False or key.get("expired") is True:
        track["status"] = "KEY_SCOPE_FAILED"
        report["status"] = "KEY_SCOPE_FAILED"
        write_json(REGISTRY, registry); write_json(REPORT, report); return

    asset_id = str(track.get("assetId") or "").strip()
    moderation = str(track.get("moderationLastKnown") or "")

    if not asset_id:
        if not AUDIO_PATH.exists() or AUDIO_PATH.stat().st_size < 10000:
            track["status"] = "AUDIO_FILE_MISSING"
            report["status"] = "AUDIO_FILE_MISSING"
            write_json(REGISTRY, registry); write_json(REPORT, report); return
        code, created = create_asset(track["title"], key["authorizedUserId"])
        report["uploadHttp"] = code
        report["uploadResponse"] = created
        if code not in (200, 201, 202) or not (created or {}).get("path"):
            track["status"] = "UPLOAD_FAILED"
            report["status"] = "UPLOAD_FAILED"
            write_json(REGISTRY, registry); write_json(REPORT, report); return
        op = poll_operation(created["path"])
        report["operationResult"] = op
        response = (op or {}).get("response") or {}
        asset_id = str(response.get("assetId") or "")
        moderation = moderation_value(response)
        if not asset_id:
            track["status"] = "ASSET_ID_MISSING"
            report["status"] = "ASSET_ID_MISSING"
            write_json(REGISTRY, registry); write_json(REPORT, report); return
        track["assetId"] = asset_id
        track["moderationLastKnown"] = moderation or None
        track["status"] = "UPLOADED_MODERATION_PENDING"
        report["assetId"] = asset_id
        report["uploadReused"] = False

    moderation, moderation_history = wait_for_moderation(asset_id, moderation)
    report["moderationState"] = moderation
    report["moderationChecks"] = moderation_history
    track["moderationLastKnown"] = moderation or track.get("moderationLastKnown")

    if is_rejected(moderation):
        track["status"] = "MODERATION_REJECTED"
        report["status"] = "MODERATION_REJECTED"
        write_json(REGISTRY, registry); write_json(REPORT, report); return

    if not is_approved(moderation):
        track["status"] = "MODERATION_PENDING"
        report["status"] = "MODERATION_PENDING"
        write_json(REGISTRY, registry); write_json(REPORT, report); return

    grant = grant_use(asset_id)
    report["bbyaPermission"] = grant
    track["bbyaPermission"] = bool(grant["ok"])
    if not grant["ok"]:
        track["status"] = "PERMISSION_FAILED"
        report["status"] = "PERMISSION_FAILED"
        write_json(REGISTRY, registry); write_json(REPORT, report); return

    track["status"] = "READY_TO_INJECT"
    report["status"] = "READY_TO_INJECT"
    report["readyToInject"] = True
    write_json(REGISTRY, registry)
    write_json(REPORT, report)


if __name__ == "__main__":
    main()
