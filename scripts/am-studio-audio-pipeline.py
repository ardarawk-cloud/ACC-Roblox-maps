#!/usr/bin/env python3
"""AM Studio Roblox audio contract v1.0.

Upload is not READY_FOR_MAP_USE until moderation is APPROVED and every selected
Universe returns the uploaded asset ID in successAssetIds. This tool never edits
or publishes a Roblox place.
"""

import argparse
import json
import os
import pathlib
import re
import subprocess
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request

SPEED_FACTOR = 1.75
PLAYBACK_SPEED = 0.5714285714
MAX_AUDIO_SECONDS = 420.0
MAX_AUDIO_BYTES = 20 * 1024 * 1024
ASSETS_API = "https://apis.roblox.com/assets/v1"
PERMISSIONS_API = "https://apis.roblox.com/asset-permissions-api/v1/assets/permissions"


def request_json(url, method="GET", payload=None, headers=None, timeout=45):
    data = None
    actual_headers = dict(headers or {})
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        actual_headers.setdefault("Content-Type", "application/json")
    req = urllib.request.Request(url, data=data, headers=actual_headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as response:
            raw = response.read().decode("utf-8", "replace")
            return response.status, json.loads(raw) if raw.strip() else {}
    except urllib.error.HTTPError as error:
        raw = error.read().decode("utf-8", "replace")
        try:
            body = json.loads(raw) if raw.strip() else {}
        except Exception:
            body = {"raw": raw[-3000:]}
        return error.code, body
    except Exception as error:
        return 0, {"exception": type(error).__name__, "message": str(error)[:1000]}


def save_json(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def probe_duration(path):
    process = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "default=noprint_wrappers=1:nokey=1", str(path)],
        text=True,
        capture_output=True,
    )
    if process.returncode != 0:
        raise RuntimeError("SOURCE_IS_NOT_VALID_AUDIO")
    return float(process.stdout.strip())


def download_drive_file(file_id, destination):
    encoded = urllib.parse.quote(str(file_id))
    attempts = [
        ["gdown", f"https://drive.google.com/uc?id={encoded}", "-O", str(destination), "--quiet"],
        ["curl", "-fL", "--retry", "3", "--retry-delay", "2", "--connect-timeout", "30", f"https://drive.usercontent.google.com/download?id={encoded}&export=download&confirm=t", "-o", str(destination)],
        ["curl", "-fL", "--retry", "3", "--retry-delay", "2", "--connect-timeout", "30", f"https://drive.google.com/uc?export=download&confirm=t&id={encoded}", "-o", str(destination)],
    ]
    for command in attempts:
        destination.unlink(missing_ok=True)
        process = subprocess.run(command, text=True, capture_output=True)
        if process.returncode != 0 or not destination.exists() or destination.stat().st_size < 1000:
            continue
        try:
            probe_duration(destination)
            return
        except Exception:
            pass
    raise RuntimeError("GOOGLE_DRIVE_DOWNLOAD_FAILED_OR_INVALID_AUDIO")


def enumerate_drive_folder(folder_url):
    process = subprocess.run(["gdown", folder_url, "--folder", "--json", "--quiet"], text=True, capture_output=True)
    if process.returncode != 0:
        raise RuntimeError("GOOGLE_DRIVE_FOLDER_ENUMERATION_FAILED")
    entries = json.loads(process.stdout or "[]")
    items = []
    for entry in entries:
        url = str(entry.get("url") or "")
        path = str(entry.get("path") or "")
        name = pathlib.PurePosixPath(path).name
        if not name.lower().endswith((".mp3", ".ogg", ".wav", ".flac", ".m4a")):
            continue
        match = re.search(r"[?&]id=([^&]+)", url)
        if not match:
            continue
        title = re.sub(r"\.(mp3|ogg|wav|flac|m4a)$", "", name, flags=re.I).strip()
        items.append({"drive_file_id": match.group(1), "title": title})
    if not items:
        raise RuntimeError("NO_AUDIO_FILES_FOUND_IN_DRIVE_FOLDER")
    return items


def prepare_175(source, destination):
    # 44.1kHz * 1.75 = 77,175Hz. PlaybackSpeed 1/1.75 restores runtime tempo/pitch.
    process = subprocess.run(
        ["ffmpeg", "-y", "-hide_banner", "-loglevel", "error", "-i", str(source), "-vn", "-af", "aresample=44100,asetrate=77175,aresample=44100", "-ac", "2", "-ar", "44100", "-codec:a", "libmp3lame", "-b:a", "192k", str(destination)],
        text=True,
        capture_output=True,
    )
    if process.returncode != 0:
        raise RuntimeError((process.stderr or "FFMPEG_175_PREPROCESS_FAILED")[-1500:])
    duration = probe_duration(destination)
    size = destination.stat().st_size
    if duration <= 0 or duration > MAX_AUDIO_SECONDS:
        raise RuntimeError(f"PREPARED_AUDIO_DURATION_INVALID:{duration:.3f}")
    if size <= 0 or size > MAX_AUDIO_BYTES:
        raise RuntimeError(f"PREPARED_AUDIO_SIZE_INVALID:{size}")
    return duration, size


def permission_scope_present(scopes):
    for scope in scopes:
        name = str(scope.get("name") or "")
        operations = set(scope.get("operations") or [])
        if name == "asset-permissions:write" or (name == "asset-permissions" and "write" in operations):
            return True
    return False


def introspect_key(key, secret_name):
    code, info = request_json("https://apis.roblox.com/api-keys/v1/introspect", "POST", {"apiKey": key})
    if code != 200:
        raise RuntimeError(f"ROBLOX_KEY_INTROSPECT_FAILED_HTTP_{code}")
    scopes = info.get("scopes") or []
    asset_rw = any(
        scope.get("name") == "asset" and {"read", "write"}.issubset(set(scope.get("operations") or []))
        for scope in scopes
    )
    permission_write = permission_scope_present(scopes)
    user_id = str(info.get("authorizedUserId") or "")
    if not user_id:
        raise RuntimeError("ROBLOX_AUTHORIZED_USER_MISSING")
    if not asset_rw:
        raise RuntimeError("ROBLOX_KEY_MISSING_ASSET_READ_WRITE")
    if not permission_write:
        raise RuntimeError("ROBLOX_KEY_MISSING_ASSET_PERMISSIONS_WRITE")
    if info.get("expired") is True:
        raise RuntimeError("ROBLOX_KEY_EXPIRED")
    if info.get("enabled") is False:
        raise RuntimeError("ROBLOX_KEY_DISABLED")
    return {
        "secretName": secret_name,
        "keyName": info.get("name"),
        "authorizedUserId": user_id,
        "enabled": info.get("enabled"),
        "expired": info.get("expired"),
        "assetReadWrite": True,
        "assetPermissionsWrite": True,
    }


def load_registry(path):
    data = json.loads(path.read_text(encoding="utf-8"))
    projects = data.get("projects") or {}
    if not projects:
        raise RuntimeError("UNIVERSE_REGISTRY_EMPTY")
    return data


def enabled_registry_projects(registry):
    return {
        name: str(cfg.get("universeId"))
        for name, cfg in (registry.get("projects") or {}).items()
        if cfg.get("enabled") is True and cfg.get("audioShared") is True and str(cfg.get("universeId") or "").isdigit()
    }


def parse_csv_or_json(value):
    raw = str(value or "").strip()
    if not raw:
        return []
    if raw.startswith("["):
        parsed = json.loads(raw)
        return [str(x).strip() for x in parsed if str(x).strip()]
    return [part.strip() for part in raw.split(",") if part.strip()]


def resolve_targets(registry, mode, target_projects, universe_ids):
    mode = str(mode or "AM_STUDIO_SHARED").strip().upper()
    enabled = enabled_registry_projects(registry)
    by_id = {uid: name for name, uid in enabled.items()}
    if mode == "AM_STUDIO_SHARED":
        targets = list(enabled.items())
    elif mode == "TARGET_PROJECT":
        names = parse_csv_or_json(target_projects)
        if not names:
            raise RuntimeError("TARGET_PROJECT_REQUIRES_PROJECT_NAME")
        unknown = [name for name in names if name not in enabled]
        if unknown:
            raise RuntimeError("TARGET_PROJECT_NOT_ENABLED:" + ",".join(unknown))
        targets = [(name, enabled[name]) for name in names]
    elif mode == "CUSTOM":
        ids = parse_csv_or_json(universe_ids)
        if not ids:
            raise RuntimeError("CUSTOM_REQUIRES_UNIVERSE_IDS")
        unknown = [uid for uid in ids if uid not in by_id]
        if unknown and (registry.get("policy") or {}).get("customMustBeRegistered", True):
            raise RuntimeError("CUSTOM_UNIVERSE_NOT_REGISTERED:" + ",".join(unknown))
        targets = [(by_id.get(uid, "CUSTOM_" + uid), uid) for uid in ids]
    else:
        raise RuntimeError("INVALID_PERMISSION_MODE:" + mode)
    deduped = []
    seen = set()
    for name, uid in targets:
        if uid in seen:
            continue
        seen.add(uid)
        deduped.append({"project": name, "universeId": uid})
    if not deduped:
        raise RuntimeError("NO_PERMISSION_TARGETS_RESOLVED")
    return mode, deduped


def creator_context(key_info, creator_type, creator_id):
    ctype = str(creator_type or "User").strip().title()
    if ctype == "User":
        cid = str(creator_id or key_info["authorizedUserId"]).strip()
        if cid != key_info["authorizedUserId"]:
            raise RuntimeError("USER_CREATOR_ID_MUST_MATCH_AUTHORIZED_KEY_USER")
        return "User", cid, {"userId": cid}
    if ctype == "Group":
        cid = str(creator_id or "").strip()
        if not cid.isdigit():
            raise RuntimeError("GROUP_CREATOR_REQUIRES_NUMERIC_GROUP_ID")
        return "Group", cid, {"groupId": cid}
    raise RuntimeError("CREATOR_TYPE_MUST_BE_USER_OR_GROUP")


def create_asset(key, title, audio_path, creator_payload):
    request = {
        "assetType": "Audio",
        "displayName": title[:50] or "AM Studio Audio",
        "description": "AM Studio shared Roblox audio pipeline v1.0",
        "creationContext": {"creator": creator_payload},
    }
    process = subprocess.run(
        ["curl", "-sS", "--location", f"{ASSETS_API}/assets", "--header", f"x-api-key: {key}", "--form-string", "request=" + json.dumps(request, separators=(",", ":"), ensure_ascii=False), "--form", f"fileContent=@{audio_path};type=audio/mpeg", "--write-out", "\n%{http_code}"],
        text=True,
        capture_output=True,
    )
    body, _, code_text = process.stdout.rpartition("\n")
    try:
        code = int(code_text.strip())
    except Exception:
        code = 0
    try:
        response = json.loads(body) if body.strip() else {}
    except Exception:
        response = {"raw": body[-2000:]}
    if code not in (200, 201, 202):
        raise RuntimeError(f"ROBLOX_AUDIO_UPLOAD_FAILED_HTTP_{code}:{json.dumps(response)[:1200]}")
    operation = response.get("path")
    if not operation:
        raise RuntimeError("ROBLOX_UPLOAD_OPERATION_PATH_MISSING")
    return operation


def poll_operation(key, operation_path, timeout=300):
    deadline = time.time() + timeout
    while time.time() < deadline:
        code, operation = request_json(f"{ASSETS_API}/" + str(operation_path).lstrip("/"), headers={"x-api-key": key})
        if code == 200 and operation.get("done"):
            if operation.get("error"):
                raise RuntimeError("ROBLOX_ASSET_OPERATION_FAILED:" + json.dumps(operation["error"])[:1200])
            response = operation.get("response") or {}
            asset_id = str(response.get("assetId") or "")
            if not asset_id.isdigit():
                raise RuntimeError("ROBLOX_ASSET_ID_NOT_RETURNED")
            state = str((response.get("moderationResult") or {}).get("moderationState") or "")
            return asset_id, state
        time.sleep(3)
    raise RuntimeError("ROBLOX_ASSET_OPERATION_TIMEOUT")


def moderation_class(state):
    upper = str(state or "").upper()
    if "APPROVED" in upper:
        return "APPROVED"
    if any(token in upper for token in ("REJECTED", "DENIED", "FAILED", "BLOCKED")):
        return "REJECTED"
    return "PENDING"


def read_asset_metadata(key, asset_id):
    urls = [
        f"{ASSETS_API}/assets/{asset_id}?readMask=moderationResult,creationContext,displayName,state",
        f"{ASSETS_API}/assets/{asset_id}",
    ]
    last = (0, {})
    for url in urls:
        last = request_json(url, headers={"x-api-key": key})
        if last[0] == 200:
            return last
    return last


def resolve_metadata_owner(metadata, fallback_type, fallback_id):
    creator = ((metadata.get("creationContext") or {}).get("creator") or {}) if isinstance(metadata, dict) else {}
    if creator.get("groupId") is not None:
        return "Group", str(creator.get("groupId")), "METADATA_VERIFIED"
    if creator.get("userId") is not None:
        return "User", str(creator.get("userId")), "METADATA_VERIFIED"
    return fallback_type, fallback_id, "CREATE_CONTEXT_ASSERTED"


def await_moderation(key, asset_id, initial_state, seconds):
    deadline = time.time() + max(0, seconds)
    state = initial_state
    last_http = None
    while True:
        classification = moderation_class(state)
        if classification != "PENDING":
            return classification, state, last_http, {}
        if time.time() >= deadline:
            return "PENDING", state or "Reviewing", last_http, {}
        code, metadata = read_asset_metadata(key, asset_id)
        last_http = code
        if code == 200:
            state = str((metadata.get("moderationResult") or {}).get("moderationState") or state)
            classification = moderation_class(state)
            if classification != "PENDING":
                return classification, state, code, metadata
        time.sleep(15)


def grant_use(key, asset_id, target):
    payload = {
        "subjectType": "Universe",
        "subjectId": str(target["universeId"]),
        "action": "Use",
        "requests": [{"assetId": int(asset_id)}],
    }
    code, response = request_json(
        PERMISSIONS_API,
        "PATCH",
        payload,
        {"x-api-key": key, "Content-Type": "application/json-patch+json"},
    )
    success_ids = [str(value) for value in (response.get("successAssetIds") or [])] if isinstance(response, dict) else []
    ok = str(asset_id) in success_ids
    failure_text = ""
    if not ok:
        failure_text = json.dumps(response, ensure_ascii=False)[:1800]
    return {
        "project": target["project"],
        "universeId": str(target["universeId"]),
        "http": code,
        "successAssetIds": success_ids,
        "verified": ok,
        "failure": failure_text,
    }


def normalize_items(items):
    if not isinstance(items, list) or not 1 <= len(items) <= 100:
        raise RuntimeError("BATCH_MUST_CONTAIN_1_TO_100_ITEMS")
    normalized = []
    seen = set()
    for index, item in enumerate(items, 1):
        file_id = str(item.get("drive_file_id") or "").strip()
        title = str(item.get("title") or "").strip()
        if not file_id or not title:
            raise RuntimeError(f"INVALID_BATCH_ITEM_{index}")
        if file_id in seen:
            raise RuntimeError("DUPLICATE_DRIVE_FILE_ID:" + file_id)
        seen.add(file_id)
        normalized.append({"drive_file_id": file_id, "title": title})
    return normalized


def final_status_for(row):
    if row.get("moderation") != "APPROVED":
        return row.get("status") or "NOT_READY"
    granted = row.get("grantedUniverses") or []
    failed = row.get("failedUniverses") or []
    if failed and granted:
        return "PARTIAL_PERMISSION"
    if failed or not row.get("permissionVerified"):
        return "PERMISSION_FAILED"
    return "READY_FOR_MAP_USE"


def main():
    parser = argparse.ArgumentParser()
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--batch")
    source.add_argument("--drive-folder-url")
    parser.add_argument("--result", required=True)
    parser.add_argument("--registry", default="config/am-studio-roblox-universes.json")
    parser.add_argument("--permission-mode", default=os.environ.get("PERMISSION_MODE", "AM_STUDIO_SHARED"))
    parser.add_argument("--target-projects", default=os.environ.get("TARGET_PROJECTS", ""))
    parser.add_argument("--universe-ids", default=os.environ.get("CUSTOM_UNIVERSE_IDS", ""))
    parser.add_argument("--creator-type", default=os.environ.get("AUDIO_CREATOR_TYPE", "User"))
    parser.add_argument("--creator-id", default=os.environ.get("AUDIO_CREATOR_ID", ""))
    parser.add_argument("--moderation-wait-seconds", type=int, default=int(os.environ.get("MAX_MODERATION_WAIT_SECONDS", "14400")))
    args = parser.parse_args()

    result_path = pathlib.Path(args.result)
    registry_path = pathlib.Path(args.registry)
    key = os.environ.get("AUDIO_KEY", "").strip()
    secret_name = os.environ.get("AUDIO_KEY_SECRET_NAME", "AUDIO_KEY").strip() or "AUDIO_KEY"
    if not key:
        raise SystemExit("AUDIO_KEY_MISSING")

    registry = load_registry(registry_path)
    mode, targets = resolve_targets(registry, args.permission_mode, args.target_projects, args.universe_ids)
    key_info = introspect_key(key, secret_name)
    creator_type, creator_id, creator_payload = creator_context(key_info, args.creator_type, args.creator_id)

    if args.batch:
        items = json.loads(pathlib.Path(args.batch).read_text(encoding="utf-8"))
    else:
        items = enumerate_drive_folder(args.drive_folder_url)
    items = normalize_items(items)

    result = {
        "pipeline": "AM_STUDIO_ROBLOX_AUDIO_PIPELINE_V1",
        "status": "RUNNING",
        "assetType": "Audio",
        "uploadedSpeed": SPEED_FACTOR,
        "playbackSpeed": PLAYBACK_SPEED,
        "permissionMode": mode,
        "permissionTargets": targets,
        "creatorType": creator_type,
        "creatorId": creator_id,
        "uploaderKeyIdentity": key_info,
        "permissionKeyIdentity": key_info,
        "sameCredentialForUploadAndPermission": True,
        "bankUpdated": False,
        "mapInjected": False,
        "mapPublished": False,
        "startedAtEpoch": int(time.time()),
        "items": [],
    }
    save_json(result_path, result)

    for index, item in enumerate(items, 1):
        row = {
            "index": index,
            "sourceTitle": item["title"],
            "driveFileId": item["drive_file_id"],
            "assetType": "Audio",
            "uploadedSpeed": SPEED_FACTOR,
            "playbackSpeed": PLAYBACK_SPEED,
            "creatorType": creator_type,
            "creatorId": creator_id,
            "permissionMode": mode,
            "status": "STARTED",
            "grantedUniverses": [],
            "failedUniverses": [],
            "permissionVerified": False,
        }
        result["items"].append(row)
        save_json(result_path, result)
        try:
            with tempfile.TemporaryDirectory(prefix=f"amstudio-audio-{index:02d}-") as tmp:
                tmpdir = pathlib.Path(tmp)
                original = tmpdir / "source-audio"
                prepared = tmpdir / "upload-175.mp3"
                download_drive_file(item["drive_file_id"], original)
                original_duration = probe_duration(original)
                prepared_duration, prepared_size = prepare_175(original, prepared)
                row.update({
                    "originalDurationSeconds": round(original_duration, 3),
                    "preparedDurationSeconds": round(prepared_duration, 3),
                    "preparedSizeBytes": prepared_size,
                    "status": "PREPROCESSED_175",
                })
                save_json(result_path, result)
                operation = create_asset(key, item["title"], prepared, creator_payload)
                row["operationPath"] = operation
                row["status"] = "UPLOAD_OPERATION_CREATED"
                save_json(result_path, result)
                asset_id, initial_state = poll_operation(key, operation)
                row["assetId"] = asset_id
                row["moderationState"] = initial_state
                row["status"] = "ASSET_ID_READY"
                save_json(result_path, result)

                moderation, state, moderation_http, metadata = await_moderation(
                    key, asset_id, initial_state, args.moderation_wait_seconds
                )
                row["moderation"] = moderation
                row["moderationState"] = state
                row["moderationHttp"] = moderation_http
                if moderation != "APPROVED":
                    row["status"] = "MODERATION_PENDING" if moderation == "PENDING" else "MODERATION_REJECTED"
                    save_json(result_path, result)
                    continue

                if not metadata:
                    _, metadata = read_asset_metadata(key, asset_id)
                owner_type, owner_id, owner_verification = resolve_metadata_owner(metadata, creator_type, creator_id)
                row["assetOwnerType"] = owner_type
                row["assetOwnerId"] = owner_id
                row["assetOwnerVerification"] = owner_verification
                if owner_type != creator_type or owner_id != creator_id:
                    row["status"] = "PERMISSION_FAILED"
                    row["failedUniverses"] = [dict(target, reason="ASSET_OWNER_MISMATCH") for target in targets]
                    save_json(result_path, result)
                    continue

                row["permissionResults"] = []
                for target in targets:
                    permission = grant_use(key, asset_id, target)
                    row["permissionResults"].append(permission)
                    if permission["verified"]:
                        row["grantedUniverses"].append(str(target["universeId"]))
                    else:
                        reason = "CannotManageAsset" if "CannotManageAsset" in permission.get("failure", "") else "PERMISSION_API_DID_NOT_VERIFY_ASSET_ID"
                        row["failedUniverses"].append({"universeId": str(target["universeId"]), "project": target["project"], "reason": reason})
                row["permissionVerified"] = len(row["failedUniverses"]) == 0 and len(row["grantedUniverses"]) == len(targets)
                row["status"] = final_status_for(row)
                save_json(result_path, result)
        except Exception as error:
            row["status"] = "PERMISSION_FAILED" if "PERMISSION" in str(error).upper() or "MANAGE" in str(error).upper() else "UPLOAD_FAILED"
            row["error"] = str(error)[:2400]
            save_json(result_path, result)

    statuses = [row.get("status") for row in result["items"]]
    ready = sum(1 for status in statuses if status == "READY_FOR_MAP_USE")
    partial = sum(1 for status in statuses if status == "PARTIAL_PERMISSION")
    permission_failed = sum(1 for status in statuses if status == "PERMISSION_FAILED")
    if ready == len(statuses) and statuses:
        result["status"] = "READY_FOR_MAP_USE"
    elif partial or (ready and ready < len(statuses)):
        result["status"] = "PARTIAL_PERMISSION"
    elif permission_failed:
        result["status"] = "PERMISSION_FAILED"
    else:
        result["status"] = "NOT_READY_FOR_MAP_USE"
    result["permissionVerified"] = result["status"] == "READY_FOR_MAP_USE"
    result["summary"] = {
        "requested": len(statuses),
        "readyForMapUse": ready,
        "partialPermission": partial,
        "permissionFailed": permission_failed,
        "notReady": sum(1 for status in statuses if status not in ("READY_FOR_MAP_USE", "PARTIAL_PERMISSION", "PERMISSION_FAILED")),
    }
    result["finishedAtEpoch"] = int(time.time())
    save_json(result_path, result)
    print(json.dumps({"status": result["status"], **result["summary"]}, indent=2))
    if result["status"] != "READY_FOR_MAP_USE":
        raise SystemExit(2)


if __name__ == "__main__":
    main()
