#!/usr/bin/env python3
"""BBYA Music Manager v1.3: Drive -> 1.75x -> Roblox asset -> moderation.

This uploader deliberately does not grant Universe permissions, edit an audio bank,
inject a playlist, or publish a map. Those actions happen only after Arda names the
approved bank entries and selects a target map.
"""

import argparse
import json
import os
import pathlib
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
    attempts = [
        ["gdown", f"https://drive.google.com/uc?id={file_id}", "-O", str(destination)],
        ["curl", "-fL", "--retry", "3", "--retry-delay", "2", "--connect-timeout", "30", f"https://drive.usercontent.google.com/download?id={urllib.parse.quote(file_id)}&export=download&confirm=t", "-o", str(destination)],
        ["curl", "-fL", "--retry", "3", "--retry-delay", "2", "--connect-timeout", "30", f"https://drive.google.com/uc?export=download&confirm=t&id={urllib.parse.quote(file_id)}", "-o", str(destination)],
    ]
    last_error = "GOOGLE_DRIVE_DOWNLOAD_FAILED"
    for command in attempts:
        destination.unlink(missing_ok=True)
        process = subprocess.run(command, text=True, capture_output=True)
        if process.returncode != 0:
            last_error = (process.stderr or process.stdout or last_error)[-1000:]
            continue
        if not destination.exists() or destination.stat().st_size < 1000:
            continue
        try:
            probe_duration(destination)
            return
        except Exception:
            last_error = "DOWNLOADED_FILE_IS_NOT_VALID_AUDIO"
    raise RuntimeError(last_error)


def prepare_audio(source, destination):
    # 44.1 kHz * 1.75 = 77,175 Hz. Resampling back to 44.1 kHz stores
    # a 1.75x speed/pitch version; Roblox PlaybackSpeed 1/1.75 restores it.
    process = subprocess.run(
        ["ffmpeg", "-y", "-hide_banner", "-loglevel", "error", "-i", str(source), "-vn", "-af", "aresample=44100,asetrate=77175,aresample=44100", "-ac", "2", "-ar", "44100", "-codec:a", "libmp3lame", "-b:a", "192k", str(destination)],
        text=True,
        capture_output=True,
    )
    if process.returncode != 0:
        raise RuntimeError((process.stderr or "FFMPEG_PREPROCESS_FAILED")[-2000:])
    duration = probe_duration(destination)
    size = destination.stat().st_size
    if duration > MAX_AUDIO_SECONDS:
        raise RuntimeError(f"PREPARED_AUDIO_OVER_420_SECONDS:{duration:.3f}")
    if size > MAX_AUDIO_BYTES:
        raise RuntimeError(f"PREPARED_AUDIO_OVER_20MB:{size}")
    return duration, size


def introspect_key(key):
    code, info = request_json("https://apis.roblox.com/api-keys/v1/introspect", "POST", {"apiKey": key})
    if code != 200:
        raise RuntimeError(f"ROBLOX_KEY_INTROSPECT_FAILED_HTTP_{code}")
    owner = str(info.get("authorizedUserId") or "")
    scopes = info.get("scopes") or []
    asset_rw = any(scope.get("name") == "asset" and {"read", "write"}.issubset(set(scope.get("operations") or [])) for scope in scopes)
    if not owner:
        raise RuntimeError("ROBLOX_AUDIO_OWNER_MISSING")
    if not asset_rw:
        raise RuntimeError("ROBLOX_KEY_MISSING_ASSET_READ_WRITE")
    if info.get("expired") is True:
        raise RuntimeError("ROBLOX_AUDIO_KEY_EXPIRED")
    if info.get("enabled") is False:
        raise RuntimeError("ROBLOX_AUDIO_KEY_DISABLED")
    return owner


def create_asset(key, owner, title, audio_path):
    create_request = {
        "assetType": "Audio",
        "displayName": title[:50],
        "description": "BBYA Music Manager simple upload v1.3",
        "creationContext": {"creator": {"userId": owner}},
    }
    process = subprocess.run(
        ["curl", "-sS", "--location", "https://apis.roblox.com/assets/v1/assets", "--header", f"x-api-key: {key}", "--form-string", "request=" + json.dumps(create_request, separators=(",", ":")), "--form", f"fileContent=@{audio_path};type=audio/mpeg", "--write-out", "\n%{http_code}"],
        text=True,
        capture_output=True,
    )
    body, _, http_code_text = process.stdout.rpartition("\n")
    try:
        http_code = int(http_code_text)
    except Exception:
        http_code = 0
    try:
        response = json.loads(body) if body.strip() else {}
    except Exception:
        response = {"raw": body[-3000:]}
    if http_code not in (200, 201, 202):
        raise RuntimeError(f"ROBLOX_AUDIO_UPLOAD_FAILED_HTTP_{http_code}:{json.dumps(response)[:1500]}")
    operation_path = response.get("path")
    if not operation_path:
        raise RuntimeError("ROBLOX_OPERATION_PATH_MISSING")
    return operation_path


def poll_operation(key, operation_path, timeout=300):
    end = time.time() + timeout
    while time.time() < end:
        code, operation = request_json("https://apis.roblox.com/assets/v1/" + operation_path.lstrip("/"), headers={"x-api-key": key})
        if code == 200 and operation.get("done"):
            if operation.get("error"):
                raise RuntimeError("ROBLOX_ASSET_OPERATION_REJECTED:" + json.dumps(operation.get("error"))[:1500])
            response = operation.get("response") or {}
            asset_id = response.get("assetId")
            if not asset_id:
                raise RuntimeError("ROBLOX_ASSET_ID_NOT_RETURNED")
            moderation = str((response.get("moderationResult") or {}).get("moderationState") or "")
            return str(asset_id), moderation
        time.sleep(3)
    raise RuntimeError("ROBLOX_ASSET_OPERATION_TIMEOUT")


def moderation_class(state):
    upper = str(state or "").upper()
    if "APPROVED" in upper:
        return "APPROVED"
    if any(word in upper for word in ("REJECTED", "DENIED", "FAILED")):
        return "REJECTED"
    return "PENDING"


def read_moderation(key, asset_id, fallback=""):
    urls = [
        f"https://apis.roblox.com/assets/v1/assets/{asset_id}?readMask=moderationResult,state,displayName",
        f"https://apis.roblox.com/assets/v1/assets/{asset_id}",
    ]
    last_code = None
    for url in urls:
        code, body = request_json(url, headers={"x-api-key": key})
        last_code = code
        state = str((body.get("moderationResult") or {}).get("moderationState") or "")
        if state:
            return state, code
    return fallback, last_code


def save_result(path, result):
    path.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--batch", required=True)
    parser.add_argument("--result", required=True)
    parser.add_argument("--moderation-wait-seconds", type=int, default=int(os.environ.get("MAX_MODERATION_WAIT_SECONDS", "14400")))
    args = parser.parse_args()

    result_path = pathlib.Path(args.result)
    items = json.loads(pathlib.Path(args.batch).read_text(encoding="utf-8"))
    if not isinstance(items, list) or not 1 <= len(items) <= 100:
        raise SystemExit("BATCH_MUST_CONTAIN_1_TO_100_ITEMS")
    normalized = []
    seen = set()
    for index, item in enumerate(items, 1):
        file_id = str(item.get("drive_file_id") or "").strip()
        title = str(item.get("title") or "").strip()
        if not file_id or not title:
            raise SystemExit(f"INVALID_BATCH_ITEM_{index}")
        if file_id in seen:
            raise SystemExit(f"DUPLICATE_DRIVE_FILE_ID_{file_id}")
        seen.add(file_id)
        normalized.append({"drive_file_id": file_id, "sourceTitle": title})

    key = os.environ.get("AUDIO_KEY", "").strip()
    if not key:
        raise SystemExit("AUDIO_UPLOAD_KEY_MISSING")
    owner = introspect_key(key)
    result = {
        "pipeline": "BBYA_MUSIC_MANAGER_SIMPLE_UPLOAD_V1_3",
        "speedFactor": SPEED_FACTOR,
        "playbackSpeed": PLAYBACK_SPEED,
        "uploaderUserId": owner,
        "permissionGranted": False,
        "bankUpdated": False,
        "mapInjected": False,
        "mapPublished": False,
        "startedAtEpoch": int(time.time()),
        "items": [],
    }
    save_result(result_path, result)

    for index, item in enumerate(normalized, 1):
        row = {"index": index, "driveFileId": item["drive_file_id"], "sourceTitle": item["sourceTitle"], "speedFactor": SPEED_FACTOR, "playbackSpeed": PLAYBACK_SPEED, "status": "STARTED"}
        result["items"].append(row)
        save_result(result_path, result)
        print(f"[{index}/{len(normalized)}] {item['sourceTitle']}: downloading", flush=True)
        try:
            with tempfile.TemporaryDirectory(prefix=f"bbya-music-{index:02d}-") as tmp:
                tmpdir = pathlib.Path(tmp)
                original = tmpdir / "original-audio"
                prepared = tmpdir / "bbya-upload-175.mp3"
                download_drive_file(item["drive_file_id"], original)
                original_duration = probe_duration(original)
                prepared_duration, prepared_size = prepare_audio(original, prepared)
                row.update({"originalDurationSeconds": round(original_duration, 3), "preparedDurationSeconds": round(prepared_duration, 3), "preparedSizeBytes": prepared_size, "status": "PREPROCESSED"})
                save_result(result_path, result)
                print(f"[{index}/{len(normalized)}] {item['sourceTitle']}: uploading", flush=True)
                operation_path = create_asset(key, owner, item["sourceTitle"], prepared)
                row["operationPath"] = operation_path
                row["status"] = "OPERATION_CREATED"
                save_result(result_path, result)
                asset_id, operation_moderation = poll_operation(key, operation_path)
                row["assetId"] = asset_id
                row["moderationState"] = operation_moderation
                row["moderation"] = moderation_class(operation_moderation)
                row["status"] = "ASSET_ID_READY"
                save_result(result_path, result)
                print(f"[{index}/{len(normalized)}] {item['sourceTitle']}: assetId={asset_id}", flush=True)
        except Exception as error:
            row["status"] = "STOPPED_FOR_THIS_SONG"
            row["error"] = str(error)[:3000]
            save_result(result_path, result)
            print(f"[{index}/{len(normalized)}] {item['sourceTitle']}: STOP {error}", flush=True)

    pending = [row for row in result["items"] if row.get("assetId") and moderation_class(row.get("moderationState")) == "PENDING"]
    deadline = time.time() + max(0, args.moderation_wait_seconds)
    while pending and time.time() < deadline:
        next_pending = []
        for row in pending:
            try:
                state, code = read_moderation(key, row["assetId"], row.get("moderationState", ""))
                row["moderationState"] = state
                row["moderationHttp"] = code
                classification = moderation_class(state)
                row["moderation"] = classification
                if classification == "APPROVED":
                    row["status"] = "APPROVED"
                elif classification == "REJECTED":
                    row["status"] = "REJECTED_STOPPED"
                else:
                    row["status"] = "MODERATION_PENDING"
                    next_pending.append(row)
            except Exception as error:
                row["moderationReadError"] = str(error)[:1500]
                next_pending.append(row)
        pending = next_pending
        save_result(result_path, result)
        if pending and time.time() < deadline:
            print(f"Moderation pending for {len(pending)} asset(s)", flush=True)
            time.sleep(30)

    for row in pending:
        row["status"] = "MODERATION_PENDING_TIMEOUT"
        row["moderation"] = "PENDING"
    for row in result["items"]:
        if row.get("assetId") and row.get("status") == "ASSET_ID_READY":
            classification = moderation_class(row.get("moderationState"))
            row["moderation"] = classification
            row["status"] = "APPROVED" if classification == "APPROVED" else "REJECTED_STOPPED"

    result["finishedAtEpoch"] = int(time.time())
    result["summary"] = {
        "requested": len(result["items"]),
        "assetIds": sum(1 for row in result["items"] if row.get("assetId")),
        "approved": sum(1 for row in result["items"] if row.get("moderation") == "APPROVED"),
        "rejected": sum(1 for row in result["items"] if row.get("moderation") == "REJECTED"),
        "pending": sum(1 for row in result["items"] if row.get("moderation") == "PENDING"),
        "stoppedBeforeAssetId": sum(1 for row in result["items"] if not row.get("assetId")),
    }
    save_result(result_path, result)
    print(json.dumps(result["summary"], indent=2), flush=True)


if __name__ == "__main__":
    main()
