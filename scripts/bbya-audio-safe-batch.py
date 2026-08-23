#!/usr/bin/env python3
import hashlib
import json
import os
import pathlib
import re
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone

ROOT = pathlib.Path(__file__).resolve().parents[1]
MAP = ROOT / "maps" / "bbya-social-hub"
CLUB = MAP / "30-club-systems.server.lua"
STATE_PATH = ROOT / "deploy-status" / "bbya-audio-safe-batch.json"
BLACKLIST_PATH = MAP / "audio-blacklist.json"
RECEIPT_PATH = ROOT / "deploy-status" / "a-club.json"

FOLDER_URL = os.environ.get("DRIVE_FOLDER_URL", "https://drive.google.com/drive/folders/1WdYH8ICus8WHPuVDvX0b4LOa9LbbBSCd").strip()
EXPECTED_USERNAME = os.environ.get("EXPECTED_AUDIO_USERNAME", "gudangpet88").strip()
AUDIO_KEY = os.environ.get("AUDIO_KEY", "").strip()
BBYA_UNIVERSE = os.environ.get("BBYA_UNIVERSE", "8116636513").strip()
MAX_MODERATION_WAIT = int(os.environ.get("MAX_MODERATION_WAIT_SECONDS", "360"))

BEGIN = "-- MAIN_PROGRESSIVE_UPLOAD_BEGIN"
END = "-- MAIN_PROGRESSIVE_UPLOAD_END"

# This exact Drive file was previously rejected by Roblox for Sexual Content on 2026-08-21.
# It must never be retried or modified/re-uploaded.
KNOWN_BLACKLIST = {
    "1f5QbInMNeMcrqwkUCpnVrJda-IDHmEGa": {
        "reason": "PREVIOUS_ROBLOX_REJECTION_SEXUAL_CONTENT_2026_08_21",
        "previousAssetId": "139912119687420",
        "title": "1A - 127 - 03. Diego Miranda feat. Liliana - Ibiza For Dreams (Mark Voxx Remix) - www.spaceclubbingdancefloor.com",
    }
}


def now():
    return datetime.now(timezone.utc).isoformat()


def load_json(path, default):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return default


def write_json(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def run(cmd, *, check=True, capture=False, env=None, cwd=ROOT):
    p = subprocess.run(
        cmd,
        cwd=str(cwd),
        env=env,
        text=True,
        capture_output=capture,
    )
    if check and p.returncode != 0:
        if capture:
            print(p.stdout)
            print(p.stderr, file=sys.stderr)
        raise RuntimeError(f"command failed ({p.returncode}): {' '.join(map(str, cmd))}")
    return p


def git_commit(paths, message):
    run(["git", "config", "user.name", "ACC Roblox Audio Safety Bot"])
    run(["git", "config", "user.email", "actions@users.noreply.github.com"])
    existing = [str(p.relative_to(ROOT) if isinstance(p, pathlib.Path) else p) for p in paths if (ROOT / str(p.relative_to(ROOT) if isinstance(p, pathlib.Path) and p.is_absolute() else p)).exists()]
    if not existing:
        return run(["git", "rev-parse", "HEAD"], capture=True).stdout.strip()
    run(["git", "add", "--", *existing])
    diff = run(["git", "diff", "--cached", "--quiet"], check=False)
    if diff.returncode == 0:
        return run(["git", "rev-parse", "HEAD"], capture=True).stdout.strip()
    run(["git", "commit", "-m", message])
    run(["git", "pull", "--rebase", "origin", "main"])
    run(["git", "push", "origin", "HEAD:main"])
    return run(["git", "rev-parse", "HEAD"], capture=True).stdout.strip()


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
        return 0, {"exception": repr(e)}


def introspect_key():
    if not AUDIO_KEY:
        return {"ok": False, "reason": "AUDIO_KEY_MISSING"}
    code, data = req_json(
        "https://apis.roblox.com/api-keys/v1/introspect",
        "POST",
        {"apiKey": AUDIO_KEY},
    )
    scopes = []
    for s in (data.get("scopes") or []) if isinstance(data, dict) else []:
        scopes.append({
            "name": s.get("name"),
            "operations": s.get("operations") or [],
            "userIds": [str(x) for x in (s.get("userIds") or [])],
        })
    asset_rw = any(s["name"] == "asset" and "read" in s["operations"] and "write" in s["operations"] for s in scopes)
    permission_w = any(s["name"] == "asset-permissions:write" or (s["name"] == "asset-permissions" and "write" in s["operations"]) for s in scopes)
    uid = str(data.get("authorizedUserId") or "") if isinstance(data, dict) else ""
    result = {
        "ok": code == 200 and bool(uid) and asset_rw and permission_w and data.get("enabled") is not False and data.get("expired") is not True,
        "http": code,
        "keyName": data.get("name") if isinstance(data, dict) else None,
        "authorizedUserId": uid,
        "enabled": data.get("enabled") if isinstance(data, dict) else None,
        "expired": data.get("expired") if isinstance(data, dict) else None,
        "assetReadWrite": asset_rw,
        "assetPermissionsWrite": permission_w,
        "scopes": scopes,
    }
    return result


def verify_expected_account(key_info):
    uid = key_info.get("authorizedUserId") or ""
    code, profile = req_json(f"https://users.roblox.com/v1/users/{urllib.parse.quote(uid)}")
    name = str(profile.get("name") or "") if isinstance(profile, dict) else ""
    banned = bool(profile.get("isBanned")) if isinstance(profile, dict) else True
    return {
        "ok": code == 200 and name.casefold() == EXPECTED_USERNAME.casefold() and not banned,
        "http": code,
        "expectedUsername": EXPECTED_USERNAME,
        "resolvedUsername": name,
        "userId": uid,
        "isBanned": banned,
        "displayName": profile.get("displayName") if isinstance(profile, dict) else None,
    }


def enumerate_drive_folder():
    p = run(["gdown", FOLDER_URL, "--folder", "--json", "--quiet"], capture=True)
    entries = json.loads(p.stdout)
    out = []
    for index, e in enumerate(entries):
        url = str(e.get("url") or "")
        path = str(e.get("path") or "")
        m = re.search(r"[?&]id=([^&]+)", url)
        drive_id = m.group(1) if m else ""
        name = pathlib.PurePosixPath(path).name
        if not drive_id or not name.lower().endswith((".mp3", ".ogg", ".wav", ".flac")):
            continue
        title = re.sub(r"\.(mp3|ogg|wav|flac)$", "", name, flags=re.I).strip()
        out.append({"order": index, "driveId": drive_id, "url": url, "filename": name, "title": title})
    return out


def normalize_audio(entry, workdir):
    source = pathlib.Path(workdir) / "source"
    ready = pathlib.Path(workdir) / "ready.mp3"
    p = run(["gdown", entry["url"], "-O", str(source), "--quiet"], check=False, capture=True)
    if p.returncode != 0 or not source.exists() or source.stat().st_size < 1000:
        return None, {"status": "SOURCE_DOWNLOAD_FAILED", "stderr": p.stderr[-1500:]}
    probe = run(["ffprobe", "-v", "error", "-show_entries", "format=duration,size", "-of", "json", str(source)], check=False, capture=True)
    if probe.returncode != 0:
        return None, {"status": "SOURCE_INVALID", "stderr": probe.stderr[-1500:]}
    trans = run([
        "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
        "-i", str(source), "-t", "410", "-vn", "-ac", "2", "-ar", "44100",
        "-b:a", "128k", "-codec:a", "libmp3lame", str(ready)
    ], check=False, capture=True)
    if trans.returncode != 0 or not ready.exists() or ready.stat().st_size < 1000:
        return None, {"status": "NORMALIZE_FAILED", "stderr": trans.stderr[-1500:]}
    final_probe = run(["ffprobe", "-v", "error", "-show_entries", "format=duration,size", "-of", "json", str(ready)], capture=True)
    meta = json.loads(final_probe.stdout or "{}")
    fmt = meta.get("format") or {}
    duration = float(fmt.get("duration") or 0)
    size = int(fmt.get("size") or ready.stat().st_size)
    if duration <= 0 or duration >= 420 or size >= 20_000_000:
        return None, {"status": "ROBLOX_LIMIT_PRECHECK_FAILED", "duration": duration, "size": size}
    digest = hashlib.sha256(ready.read_bytes()).hexdigest()
    return ready, {"status": "READY", "duration": duration, "size": size, "sha256": digest}


def create_audio_asset(path, title, creator_user_id):
    request = {
        "assetType": "Audio",
        "displayName": title[:50] or "BBYA Club Track",
        "description": "BBYA Social Hub Main Club — sequential safety upload",
        "creationContext": {"creator": {"userId": str(creator_user_id)}},
    }
    cmd = [
        "curl", "-sS", "--location", "https://apis.roblox.com/assets/v1/assets",
        "--header", f"x-api-key: {AUDIO_KEY}",
        "--form-string", "request=" + json.dumps(request, separators=(",", ":"), ensure_ascii=False),
        "--form", f"fileContent=@{path};type=audio/mpeg",
        "--write-out", "\n%{http_code}",
    ]
    p = run(cmd, check=False, capture=True)
    body, _, code_text = p.stdout.rpartition("\n")
    try:
        code = int(code_text.strip())
    except Exception:
        code = 0
    try:
        data = json.loads(body) if body.strip() else {}
    except Exception:
        data = {"raw": body[-4000:]}
    return code, data


def get_operation(path):
    return req_json(
        "https://apis.roblox.com/assets/v1/" + str(path).lstrip("/"),
        headers={"x-api-key": AUDIO_KEY},
    )


def get_asset_metadata(asset_id):
    candidates = [
        f"https://apis.roblox.com/assets/v1/assets/{asset_id}?readMask=moderationResult,displayName,creationContext",
        f"https://apis.roblox.com/assets/v1/assets/{asset_id}",
    ]
    last = (0, {})
    for url in candidates:
        last = req_json(url, headers={"x-api-key": AUDIO_KEY})
        if last[0] == 200:
            return last
    return last


def moderation_state_from(obj):
    if not isinstance(obj, dict):
        return ""
    candidates = [obj]
    if isinstance(obj.get("response"), dict):
        candidates.append(obj["response"])
    for c in candidates:
        mr = c.get("moderationResult") or c.get("moderation_result") or {}
        value = mr.get("moderationState") or mr.get("moderation_state") or c.get("moderationState") or c.get("moderation_state")
        if value:
            return str(value)
    return ""


def moderation_class(value):
    v = str(value or "").upper()
    if "APPROVED" in v:
        return "APPROVED"
    if any(x in v for x in ("REJECT", "DENIED", "BLOCK", "FAILED")):
        return "REJECTED"
    return "PENDING"


def wait_for_moderation(asset_id, operation_path=None):
    deadline = time.time() + MAX_MODERATION_WAIT
    last_state = ""
    last_obj = {}
    while time.time() < deadline:
        if operation_path:
            _, op = get_operation(operation_path)
            s = moderation_state_from(op)
            if s:
                last_state, last_obj = s, op
                cls = moderation_class(s)
                if cls != "PENDING":
                    return cls, s, op
        code, meta = get_asset_metadata(asset_id)
        if code == 200:
            s = moderation_state_from(meta)
            if s:
                last_state, last_obj = s, meta
                cls = moderation_class(s)
                if cls != "PENDING":
                    return cls, s, meta
        time.sleep(10)
    return "PENDING", last_state or "Reviewing", last_obj


def grant_bbya(asset_id):
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
    return {"ok": str(asset_id) in success or code in (200, 201, 204), "http": code, "successAssetIds": success, "response": data}


def lua_quote(s):
    return json.dumps(str(s), ensure_ascii=False)


def parse_lua_title(line):
    m = re.search(r'title=("(?:\\.|[^"\\])*")', line)
    if not m:
        return None
    try:
        return json.loads(m.group(1))
    except Exception:
        return None


def norm_title(s):
    return re.sub(r"[^a-z0-9]+", " ", str(s).casefold()).strip()


def inject_main_track(title, asset_id, state):
    text = CLUB.read_text(encoding="utf-8")
    pattern = re.compile(re.escape(BEGIN) + r"(.*?)" + re.escape(END), re.S)
    m = pattern.search(text)
    if not m:
        raise RuntimeError("Main Club playlist markers missing")
    body = m.group(1)
    lines = [x for x in body.splitlines() if x.strip()]
    entry = f' {{title={lua_quote(title)},id={lua_quote(str(asset_id))},style="progressive"}},'
    if not state.get("legacyMainCleared"):
        lines = [entry]
        state["legacyMainCleared"] = True
        state["legacyMainClearedAt"] = now()
    else:
        target = norm_title(title)
        new_lines = []
        replaced = False
        asset_already = False
        for line in lines:
            old_title = parse_lua_title(line)
            old_id_match = re.search(r'id="(\d+)"', line)
            old_id = old_id_match.group(1) if old_id_match else ""
            if old_id == str(asset_id):
                asset_already = True
            if old_title is not None and norm_title(old_title) == target:
                if not replaced:
                    new_lines.append(entry)
                    replaced = True
                continue
            new_lines.append(line)
        if not replaced and not asset_already:
            new_lines.append(entry)
        lines = new_lines
    replacement = BEGIN + "\n" + "\n".join(lines) + ("\n" if lines else "") + END
    new_text, n = pattern.subn(replacement, text, count=1)
    if n != 1:
        raise RuntimeError("failed to patch Main Club playlist")
    CLUB.write_text(new_text, encoding="utf-8")


def publish_live():
    out = pathlib.Path("/tmp/bbya-audio-safe-live.rbxl")
    run(["rojo", "build", "maps/bbya-social-hub/default.project.json", "-o", str(out)])
    if not out.exists() or out.stat().st_size < 1000:
        raise RuntimeError("Rojo build output missing")
    env = os.environ.copy()
    env["PLACE_FILE_OVERRIDE"] = str(out)
    env["PUBLISH_RECEIPT_DIR"] = "deploy-status"
    run(["node", "scripts/publish-map.js", "a-club"], env=env)
    receipt = load_json(RECEIPT_PATH, {})
    if receipt.get("status") != "PUBLISHED":
        raise RuntimeError("BBYA publish receipt is not PUBLISHED")
    return receipt


def persist_state(state, blacklist, message, include_club=False):
    write_json(STATE_PATH, state)
    write_json(BLACKLIST_PATH, blacklist)
    paths = [STATE_PATH, BLACKLIST_PATH]
    if include_club:
        paths.append(CLUB)
    return git_commit(paths, message)


def blacklist_item(blacklist, entry, reason, asset_id=None, moderation_state=None):
    item = {
        "driveId": entry["driveId"],
        "title": entry["title"],
        "reason": reason,
        "blacklistedAt": now(),
    }
    if asset_id:
        item["assetId"] = str(asset_id)
    if moderation_state:
        item["moderationState"] = str(moderation_state)
    blacklist.setdefault("items", {})[entry["driveId"]] = item
    return item


def main():
    state = load_json(STATE_PATH, {"version": 1, "status": "NEW", "items": {}, "folderUrl": FOLDER_URL})
    state.setdefault("items", {})
    blacklist = load_json(BLACKLIST_PATH, {"version": 1, "items": {}})
    blacklist.setdefault("items", {})
    for drive_id, info in KNOWN_BLACKLIST.items():
        blacklist["items"].setdefault(drive_id, {"driveId": drive_id, **info, "blacklistedAt": "2026-08-21T00:00:00+00:00"})

    key_info = introspect_key()
    state["keyCheck"] = key_info
    if not key_info.get("ok"):
        state["status"] = "BLOCKED_KEY_CHECK"
        state["updatedAt"] = now()
        persist_state(state, blacklist, "Record BBYA audio key safety block [skip ci]")
        raise SystemExit("Audio key failed safety check")

    account = verify_expected_account(key_info)
    state["accountCheck"] = account
    if not account.get("ok"):
        state["status"] = "BLOCKED_ACCOUNT_MISMATCH_OR_BANNED"
        state["updatedAt"] = now()
        persist_state(state, blacklist, "Record BBYA audio account safety block [skip ci]")
        raise SystemExit("Audio key is not a live gudangpet88 account")

    queue = enumerate_drive_folder()
    state["folderItemCount"] = len(queue)
    state["status"] = "RUNNING_SEQUENTIAL"
    state["updatedAt"] = now()
    persist_state(state, blacklist, "Start BBYA gudangpet88 sequential audio run [skip ci]")

    live_hashes = {}
    for did, item in state["items"].items():
        if item.get("status") in ("LIVE", "DUPLICATE_REUSED") and item.get("normalizedSha256") and item.get("assetId"):
            live_hashes[item["normalizedSha256"]] = {"driveId": did, "assetId": str(item["assetId"]), "title": item.get("title")}

    for seq, entry in enumerate(queue, start=1):
        did = entry["driveId"]
        rec = state["items"].setdefault(did, {"driveId": did, "title": entry["title"], "filename": entry["filename"], "sequence": seq})
        rec.update({"title": entry["title"], "filename": entry["filename"], "sequence": seq})
        if did in blacklist["items"]:
            rec["status"] = "BLACKLISTED"
            rec["blacklistReason"] = blacklist["items"][did].get("reason")
            rec["updatedAt"] = now()
            persist_state(state, blacklist, f"Blacklist BBYA audio {seq:02d} known rejection [skip ci]")
            continue
        if rec.get("status") in ("LIVE", "BLACKLISTED", "DUPLICATE_REUSED", "SOURCE_INVALID"):
            continue

        asset_id = str(rec.get("assetId") or "")
        operation_path = rec.get("operationPath")

        if not asset_id:
            with tempfile.TemporaryDirectory(prefix=f"bbya-audio-{seq:02d}-") as td:
                ready, prep = normalize_audio(entry, td)
                rec["preflight"] = prep
                rec["updatedAt"] = now()
                if ready is None:
                    rec["status"] = prep.get("status", "SOURCE_INVALID")
                    persist_state(state, blacklist, f"Record BBYA audio {seq:02d} source rejection [skip ci]")
                    if rec["status"] in ("SOURCE_DOWNLOAD_FAILED",):
                        state["status"] = "STOPPED_SOURCE_ACCESS"
                        persist_state(state, blacklist, "Stop BBYA audio batch on source access failure [skip ci]")
                        raise SystemExit("Drive source could not be downloaded safely")
                    continue

                rec["normalizedSha256"] = prep["sha256"]
                if prep["sha256"] in live_hashes:
                    prior = live_hashes[prep["sha256"]]
                    rec["status"] = "DUPLICATE_REUSED"
                    rec["assetId"] = prior["assetId"]
                    rec["duplicateOfDriveId"] = prior["driveId"]
                    rec["updatedAt"] = now()
                    persist_state(state, blacklist, f"Deduplicate BBYA audio {seq:02d} safely [skip ci]")
                    continue

                upload_http, upload_data = create_audio_asset(ready, entry["title"], key_info["authorizedUserId"])
                rec["uploadHttp"] = upload_http
                rec["uploadResponse"] = upload_data
                rec["uploadedAt"] = now()
                if upload_http == 429:
                    rec["status"] = "UPLOAD_QUOTA_BLOCKED"
                    state["status"] = "STOPPED_UPLOAD_QUOTA"
                    persist_state(state, blacklist, f"Record BBYA audio {seq:02d} quota stop [skip ci]")
                    raise SystemExit("Roblox audio upload quota reached")
                if upload_http in (401, 403):
                    rec["status"] = "UPLOAD_AUTH_BLOCKED"
                    state["status"] = "STOPPED_AUTHORIZATION"
                    persist_state(state, blacklist, f"Record BBYA audio {seq:02d} auth stop [skip ci]")
                    raise SystemExit("Roblox upload authorization failed")
                if upload_http >= 500 or upload_http == 0:
                    rec["status"] = "UPLOAD_TRANSIENT_FAILED"
                    state["status"] = "STOPPED_TRANSIENT_UPLOAD"
                    persist_state(state, blacklist, f"Record BBYA audio {seq:02d} transient stop [skip ci]")
                    raise SystemExit("Roblox upload transient failure")
                if upload_http not in (200, 201, 202):
                    rec["status"] = "BLACKLISTED"
                    blacklist_item(blacklist, entry, f"ROBLOX_UPLOAD_REJECTED_HTTP_{upload_http}")
                    persist_state(state, blacklist, f"Blacklist BBYA audio {seq:02d} upload rejection [skip ci]")
                    continue

                operation_path = (upload_data or {}).get("path")
                if not operation_path:
                    rec["status"] = "UPLOAD_OPERATION_MISSING"
                    state["status"] = "STOPPED_UPLOAD_PROTOCOL"
                    persist_state(state, blacklist, f"Record BBYA audio {seq:02d} protocol stop [skip ci]")
                    raise SystemExit("Roblox upload operation path missing")
                rec["operationPath"] = operation_path

                deadline = time.time() + 300
                op = {}
                while time.time() < deadline:
                    _, op = get_operation(operation_path)
                    if isinstance(op, dict) and op.get("done"):
                        break
                    time.sleep(3)
                response = (op.get("response") or {}) if isinstance(op, dict) else {}
                asset_id = str(response.get("assetId") or "")
                rec["operationResult"] = op
                if not asset_id:
                    status_obj = (op.get("status") or {}) if isinstance(op, dict) else {}
                    rec["status"] = "BLACKLISTED"
                    blacklist_item(blacklist, entry, "ROBLOX_ASSET_CREATION_REJECTED", moderation_state=json.dumps(status_obj, ensure_ascii=False)[:1000])
                    persist_state(state, blacklist, f"Blacklist BBYA audio {seq:02d} asset creation rejection [skip ci]")
                    continue
                rec["assetId"] = asset_id
                rec["initialModerationState"] = moderation_state_from(response)
                rec["status"] = "PENDING_MODERATION"
                persist_state(state, blacklist, f"Record BBYA audio {seq:02d} moderation pending [skip ci]")

        cls, mod_state, mod_obj = wait_for_moderation(asset_id, operation_path)
        rec["moderationState"] = mod_state
        rec["moderationProbe"] = mod_obj
        rec["moderationCheckedAt"] = now()
        if cls == "PENDING":
            rec["status"] = "PENDING_MODERATION"
            state["status"] = "STOPPED_PENDING_MODERATION"
            state["blockedOnDriveId"] = did
            state["blockedOnSequence"] = seq
            persist_state(state, blacklist, f"Pause BBYA audio {seq:02d} until Roblox moderation final [skip ci]")
            raise SystemExit("Moderation still pending; next audio intentionally not uploaded")
        if cls == "REJECTED":
            rec["status"] = "BLACKLISTED"
            rec["updatedAt"] = now()
            blacklist_item(blacklist, entry, "ROBLOX_MODERATION_REJECTED", asset_id=asset_id, moderation_state=mod_state)
            persist_state(state, blacklist, f"Blacklist BBYA audio {seq:02d} moderation rejection [skip ci]")
            continue

        rec["status"] = "APPROVED"
        rec["approvedAt"] = now()
        perm = grant_bbya(asset_id)
        rec["permission"] = perm
        if not perm.get("ok"):
            rec["status"] = "PERMISSION_FAILED"
            state["status"] = "STOPPED_PERMISSION_FAILURE"
            persist_state(state, blacklist, f"Record BBYA audio {seq:02d} permission stop [skip ci]")
            raise SystemExit("Approved audio could not be granted to BBYA universe")

        inject_main_track(entry["title"], asset_id, state)
        rec["status"] = "APPROVED_PENDING_PUBLISH"
        rec["updatedAt"] = now()
        code_commit = persist_state(state, blacklist, f"Stage approved BBYA Club audio {seq:02d} [skip ci]", include_club=True)
        rec["stagedCommit"] = code_commit

        try:
            receipt = publish_live()
        except Exception as exc:
            rec["status"] = "PUBLISH_FAILED"
            rec["publishError"] = repr(exc)
            state["status"] = "STOPPED_PUBLISH_FAILURE"
            persist_state(state, blacklist, f"Record BBYA audio {seq:02d} publish failure [skip ci]")
            raise

        rec["status"] = "LIVE"
        rec["liveAt"] = now()
        rec["publishReceipt"] = receipt
        rec["updatedAt"] = now()
        state["lastLiveSequence"] = seq
        state["lastLiveDriveId"] = did
        state["lastLiveAssetId"] = asset_id
        state["lastLiveVersion"] = ((receipt.get("response") or {}).get("versionNumber"))
        state["status"] = "RUNNING_SEQUENTIAL"
        state.pop("blockedOnDriveId", None)
        state.pop("blockedOnSequence", None)
        persist_state(state, blacklist, f"Record BBYA Club audio {seq:02d} live [skip ci]")
        if rec.get("normalizedSha256"):
            live_hashes[rec["normalizedSha256"]] = {"driveId": did, "assetId": asset_id, "title": entry["title"]}

    counts = {}
    for item in state["items"].values():
        counts[item.get("status", "UNKNOWN")] = counts.get(item.get("status", "UNKNOWN"), 0) + 1
    state["counts"] = counts
    state["status"] = "FINISHED"
    state["finishedAt"] = now()
    state["updatedAt"] = now()
    persist_state(state, blacklist, "Finish BBYA gudangpet88 sequential audio batch [skip ci]")
    print(json.dumps({"status": state["status"], "counts": counts, "lastLiveVersion": state.get("lastLiveVersion")}, ensure_ascii=False))


if __name__ == "__main__":
    main()
