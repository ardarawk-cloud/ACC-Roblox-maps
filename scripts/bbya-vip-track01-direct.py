#!/usr/bin/env python3
import json
import os
import pathlib
import subprocess
import time
import urllib.error
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[1]
MAP = ROOT / "maps" / "bbya-social-hub"
REPORT = ROOT / "deploy-status" / "bbya-vip-track01.json"
KEY_REPORT = ROOT / "deploy-status" / "bbya-vip-track01-key.json"

TRACK_TITLE = os.environ.get("TRACK_TITLE", "Wonder Girls - Nobody (ROOKIE Amapiano Edit)").strip()
BBYA_UNIVERSE = os.environ.get("BBYA_UNIVERSE", "8116636513").strip()
AM_STUDIO_UNIVERSE = os.environ.get("AM_STUDIO_UNIVERSE", "4187755690").strip()
DRIVE_FILE_ID = os.environ.get("DRIVE_FILE_ID", "1_E34wIMN6YNHyZmpyy8kybTD7bIbNDmO").strip()
AUDIO_KEY = os.environ.get("AUDIO_KEY", "").strip()
AM_STUDIO_KEY = os.environ.get("AM_STUDIO_KEY", "").strip()
AUDIO_PATH = pathlib.Path(os.environ.get("AUDIO_PATH", "/tmp/bbya-vip-track01-ready.mp3"))

REPORT.parent.mkdir(parents=True, exist_ok=True)


def write_report(report):
    REPORT.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


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


def introspect(key):
    if not key:
        return {"present": False, "scopes": []}
    code, info = req_json(
        "https://apis.roblox.com/api-keys/v1/introspect",
        "POST",
        {"apiKey": key},
    )
    info = info if isinstance(info, dict) else {}
    scopes = []
    for s in info.get("scopes") or []:
        scopes.append({
            "name": s.get("name"),
            "operations": s.get("operations") or [],
            "userIds": [str(x) for x in (s.get("userIds") or [])],
            "groupIds": [str(x) for x in (s.get("groupIds") or [])],
            "universeIds": [str(x) for x in (s.get("universeIds") or [])],
        })
    return {
        "present": True,
        "http": code,
        "keyName": info.get("name"),
        "authorizedUserId": str(info.get("authorizedUserId")) if info.get("authorizedUserId") is not None else None,
        "enabled": info.get("enabled"),
        "expired": info.get("expired"),
        "scopes": scopes,
        "assetReadWrite": any(
            s.get("name") == "asset"
            and "read" in (s.get("operations") or [])
            and "write" in (s.get("operations") or [])
            for s in scopes
        ),
        "assetPermissionsWrite": any(
            s.get("name") == "asset-permissions:write"
            or (s.get("name") == "asset-permissions" and "write" in (s.get("operations") or []))
            for s in scopes
        ),
    }


def create_audio_asset(creator_user_id):
    payload = {
        "assetType": "Audio",
        "displayName": TRACK_TITLE[:50],
        "description": "BBYA VIP Track 01",
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
        data = {"raw": body[-4000:]}
    try:
        code = int(code_text)
    except Exception:
        code = 0
    return code, data


def poll_asset_operation(path, timeout=300):
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


def grant_use(key, asset_id, universe_id, key_label):
    if not key:
        return {"key": key_label, "ok": False, "result": "KEY_MISSING"}
    payload = {
        "subjectType": "Universe",
        "subjectId": str(universe_id),
        "action": "Use",
        "requests": [{"assetId": int(asset_id)}],
    }
    code, data = req_json(
        "https://apis.roblox.com/asset-permissions-api/v1/assets/permissions",
        "PATCH",
        payload,
        {"x-api-key": key, "Content-Type": "application/json-patch+json"},
    )
    success = [str(x) for x in (data.get("successAssetIds") or [])] if isinstance(data, dict) else []
    return {
        "key": key_label,
        "http": code,
        "successAssetIds": success,
        "ok": str(asset_id) in success or code in (200, 201, 204),
        "response": data,
    }


def patch_reset():
    path = MAP / "109-music-catalog-reset.server.lua"
    text = path.read_text(encoding="utf-8")
    old = ' local sg=s.SoundGroup\n return sg and groups[sg.Name]~=nil or false'
    new = (
        ' local sg=s.SoundGroup\n'
        ' if sg and sg.Name=="BBYAVIPMaster" and ReplicatedStorage:GetAttribute("BBYAVIPTrack01Enabled")==true then return false end\n'
        ' return sg and groups[sg.Name]~=nil or false'
    )
    if old in text:
        text = text.replace(old, new, 1)
    old2 = "local function scrubWorkspaceVIP()\n local vipGroup=groups.BBYAVIPMaster"
    new2 = (
        'local function scrubWorkspaceVIP()\n'
        ' if ReplicatedStorage:GetAttribute("BBYAVIPTrack01Enabled")==true then return end\n'
        ' local vipGroup=groups.BBYAVIPMaster'
    )
    if old2 in text:
        text = text.replace(old2, new2, 1)
    path.write_text(text, encoding="utf-8")


def write_vip_authority(asset_id):
    title_lua = json.dumps(TRACK_TITLE, ensure_ascii=False)
    asset_lua = json.dumps(str(asset_id))
    text = f'''-- BBYA SOCIAL HUB - VIP TRACK 01 AUTHORITY v2
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local TRACK={{title={title_lua},assetId={asset_lua}}}

ReplicatedStorage:SetAttribute("BBYAVIPTrack01Enabled",true)
ReplicatedStorage:SetAttribute("BBYAVIPTrack01Title",TRACK.title)
ReplicatedStorage:SetAttribute("BBYAVIPTrack01AssetId",TRACK.assetId)

task.delay(9.25,function()
 local group=SoundService:FindFirstChild("BBYAVIPMaster")
 if not group or not group:IsA("SoundGroup") then
  group=Instance.new("SoundGroup")
  group.Name="BBYAVIPMaster"
  group.Parent=SoundService
 end
 group.Volume=.62
 group:SetAttribute("Venue","VIP")
 group:SetAttribute("BBYALocalZoneOnly",true)
 group:SetAttribute("PlaylistReady",true)
 group:SetAttribute("PlaylistCount",1)
 group:SetAttribute("MusicCatalogState","VIP_TRACK01_ACTIVE")
 local oldSound=SoundService:FindFirstChild("BBYAVIPTrack01")
 if oldSound then oldSound:Destroy() end
 local s=Instance.new("Sound")
 s.Name="BBYAVIPTrack01"
 s.SoundId="rbxassetid://"..TRACK.assetId
 s.Volume=.72
 s.Looped=true
 s.SoundGroup=group
 s:SetAttribute("Title",TRACK.title)
 s:SetAttribute("Venue","VIP")
 s:SetAttribute("PlaylistIndex",1)
 s.Parent=SoundService
 s:Play()
 print("[BBYA] VIP Track 01 active:",TRACK.title,TRACK.assetId)
end)
'''
    (MAP / "110-vip-track01.server.lua").write_text(text, encoding="utf-8")


def patch_project():
    path = MAP / "default.project.json"
    project = json.loads(path.read_text(encoding="utf-8"))
    scripts = project["tree"]["ServerScriptService"]
    scripts.pop("VIPTrack01AuthorityV1", None)
    scripts["VIPTrack01AuthorityV2"] = {"$path": "110-vip-track01.server.lua"}
    path.write_text(json.dumps(project, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def patch_ui():
    path = MAP / "109-music-catalog-reset-ui.client.lua"
    text = path.read_text(encoding="utf-8")
    if 'local vipActive=v=="VIP"' not in text:
        anchor = " local v=currentVenue();local spec=VENUES[v] or VENUES.NONE\n local musicFrame=playerCard.Parent"
        repl = (
            " local v=currentVenue();local spec=VENUES[v] or VENUES.NONE\n"
            ' local vipActive=v=="VIP" and ReplicatedStorage:GetAttribute("BBYAVIPTrack01Enabled")==true\n'
            ' local vipTitle=tostring(ReplicatedStorage:GetAttribute("BBYAVIPTrack01Title") or "VIP Track 01")\n'
            " local musicFrame=playerCard.Parent"
        )
        text = text.replace(anchor, repl, 1)
        text = text.replace(
            ' if emptyTitle then emptyTitle.Text=spec.short.." PLAYLIST • 0 TRACKS" end\n if emptySub then emptySub.Text="Playlist dikosongkan. Susun ulang lagu untuk venue ini secara terpisah." end',
            ' if emptyTitle then emptyTitle.Text=vipActive and "VIP PLAYLIST • 1 TRACK" or (spec.short.." PLAYLIST • 0 TRACKS") end\n if emptySub then emptySub.Text=vipActive and vipTitle or "Playlist dikosongkan. Susun ulang lagu untuk venue ini secara terpisah." end',
            1,
        )
        text = text.replace(
            ' panel:SetAttribute("BBYAMusicPlaylistCount",0)',
            ' panel:SetAttribute("BBYAMusicPlaylistCount",vipActive and 1 or 0)',
            1,
        )
        text = text.replace(
            " syncPlayerCard(playerCard,spec)\n syncVenueChip(musicFrame,spec)",
            ''' syncPlayerCard(playerCard,spec)
 if vipActive then
  local biggest=nil
  for _,d in ipairs(playerCard:GetDescendants()) do
   if d:IsA("TextLabel") then
    local up=string.upper(d.Text or "")
    if up~="NOW PLAYING" and (not biggest or d.TextSize>biggest.TextSize) then biggest=d end
    if up:find("0 TRACKS",1,true) then d.Text="VIP • 1 TRACK" end
   end
  end
  if biggest then biggest.Text=vipTitle end
 end
 syncVenueChip(musicFrame,spec)''',
            1,
        )
    path.write_text(text, encoding="utf-8")


def prior_asset():
    if not REPORT.exists():
        return None, None
    try:
        old = json.loads(REPORT.read_text(encoding="utf-8"))
    except Exception:
        return None, None
    if old.get("track") != TRACK_TITLE or not old.get("assetId"):
        return None, None
    return str(old["assetId"]), old


def main():
    report = {
        "track": TRACK_TITLE,
        "driveFileId": DRIVE_FILE_ID,
        "target": "BBYA Social Hub VIP",
        "bbyaUniverseId": BBYA_UNIVERSE,
        "amStudioUniverseId": AM_STUDIO_UNIVERSE,
        "status": "STARTED",
    }
    if not AUDIO_KEY:
        report["status"] = "SECRET_MISSING"
        write_report(report)
        raise SystemExit("AMSTUDIO_AUDIO_UPLOADER_01 missing")

    key_info = introspect(AUDIO_KEY)
    report.update({
        "keyName": key_info.get("keyName"),
        "authorizedUserId": key_info.get("authorizedUserId"),
        "assetReadWrite": key_info.get("assetReadWrite"),
        "assetPermissionsWrite": key_info.get("assetPermissionsWrite"),
    })
    KEY_REPORT.write_text(json.dumps(key_info, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    if (
        key_info.get("http") != 200
        or not key_info.get("authorizedUserId")
        or not key_info.get("assetReadWrite")
        or not key_info.get("assetPermissionsWrite")
        or key_info.get("enabled") is False
        or key_info.get("expired") is True
    ):
        report["status"] = "KEY_SCOPE_FAILED"
        write_report(report)
        raise SystemExit("audio key scope check failed")

    asset_id, old = prior_asset()
    moderation = None
    if asset_id:
        report["assetId"] = asset_id
        report["uploadReused"] = True
        moderation = old.get("moderationState")
        report["moderationState"] = moderation
        report["previousUploadStatus"] = old.get("status")
    else:
        if not AUDIO_PATH.exists() or AUDIO_PATH.stat().st_size < 10000:
            report["status"] = "AUDIO_FILE_MISSING"
            write_report(report)
            raise SystemExit("prepared Track 01 audio missing")
        create_http, create_data = create_audio_asset(key_info["authorizedUserId"])
        report["uploadHttp"] = create_http
        report["uploadResponse"] = create_data
        if create_http not in (200, 201, 202):
            report["status"] = "UPLOAD_FAILED"
            write_report(report)
            raise SystemExit(f"Roblox audio upload failed HTTP {create_http}")
        op_path = (create_data or {}).get("path")
        if not op_path:
            report["status"] = "UPLOAD_OPERATION_MISSING"
            write_report(report)
            raise SystemExit("upload operation path missing")
        operation = poll_asset_operation(op_path)
        report["operationPath"] = op_path
        report["operationResult"] = operation
        response = (operation or {}).get("response") or {}
        asset_id = response.get("assetId")
        moderation = (response.get("moderationResult") or {}).get("moderationState")
        if not asset_id:
            report["status"] = "ASSET_ID_MISSING"
            write_report(report)
            raise SystemExit("asset upload returned no assetId")
        asset_id = str(asset_id)
        report["assetId"] = asset_id
        report["moderationState"] = moderation
        report["uploadReused"] = False

    bbya_grant = grant_use(AUDIO_KEY, asset_id, BBYA_UNIVERSE, "AMSTUDIO_AUDIO_UPLOADER_01")
    if not bbya_grant["ok"]:
        report["permissions"] = {"bbya": bbya_grant}
        report["status"] = "BBYA_PERMISSION_FAILED"
        write_report(report)
        raise SystemExit("BBYA audio permission grant failed")

    am_attempts = [grant_use(AUDIO_KEY, asset_id, AM_STUDIO_UNIVERSE, "AMSTUDIO_AUDIO_UPLOADER_01")]
    if not am_attempts[-1]["ok"] and AM_STUDIO_KEY:
        am_attempts.append(grant_use(AM_STUDIO_KEY, asset_id, AM_STUDIO_UNIVERSE, "AM_STUDIO"))
    am_ok = any(x.get("ok") for x in am_attempts)
    report["permissions"] = {
        "bbya": bbya_grant,
        "amStudioCreativeLab": {"ok": am_ok, "attempts": am_attempts},
    }

    patch_reset()
    write_vip_authority(asset_id)
    patch_project()
    patch_ui()

    report["status"] = "READY_TO_PUBLISH" if am_ok else "READY_TO_PUBLISH_AM_STUDIO_PERMISSION_PENDING"
    write_report(report)
    print(json.dumps({
        "status": report["status"],
        "assetId": asset_id,
        "uploadReused": report.get("uploadReused"),
        "moderationState": moderation,
        "bbyaPermission": True,
        "amStudioPermission": am_ok,
    }, ensure_ascii=False))


if __name__ == "__main__":
    main()
