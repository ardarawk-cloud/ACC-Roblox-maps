import json
import os
import pathlib
import time
import urllib.error
import urllib.request
import zipfile

ROOT = pathlib.Path(__file__).resolve().parents[2]
SCRIPT_PATH = pathlib.Path(__file__).with_name("extract.luau")
EXPORT_DIR = ROOT / "exports" / "legacy"

API_KEY = os.environ["ROBLOX_API_KEY"].strip()
UNIVERSE_ID = os.environ.get("ROBLOX_UNIVERSE_ID", "8805231520").strip()
PLACE_ID = os.environ.get("ROBLOX_PLACE_ID", "124843214013484").strip()


def request(url, method="GET", json_body=None, headers=None):
    headers = dict(headers or {})
    data = None
    if json_body is not None:
        data = json.dumps(json_body).encode("utf-8")
        headers.setdefault("content-type", "application/json")
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        return urllib.request.urlopen(req, timeout=120)
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", "replace")
        raise RuntimeError(f"HTTP {exc.code} for {url}: {body}") from exc


def create_task(script_source):
    url = (
        f"https://apis.roblox.com/cloud/v2/universes/{UNIVERSE_ID}/"
        f"places/{PLACE_ID}/luau-execution-session-tasks"
    )
    with request(
        url,
        method="POST",
        json_body={"script": script_source, "enableBinaryOutput": True, "timeout": "300s"},
        headers={"x-api-key": API_KEY},
    ) as response:
        return json.loads(response.read())


def get_json(url, with_key=True):
    headers = {"x-api-key": API_KEY} if with_key else {}
    with request(url, headers=headers) as response:
        return json.loads(response.read())


def poll_task(task_path):
    url = f"https://apis.roblox.com/cloud/v2/{task_path}"
    for _ in range(120):
        task = get_json(url)
        if task.get("state") != "PROCESSING":
            return task
        time.sleep(2)
    raise RuntimeError("Luau extraction task timed out while polling")


def fetch_logs(task_path):
    try:
        payload = get_json(f"https://apis.roblox.com/cloud/v2/{task_path}/logs")
        groups = payload.get("luauExecutionSessionTaskLogs") or []
        lines = []
        for group in groups:
            lines.extend(group.get("messages") or [])
        return "\n".join(lines)
    except Exception as exc:
        return f"Could not retrieve logs: {exc}"


def download_binary(uri, output_path):
    with request(uri, with_key=False) if False else urllib.request.urlopen(uri, timeout=120) as response:
        output_path.write_bytes(response.read())


def main():
    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    script_source = SCRIPT_PATH.read_text(encoding="utf-8")

    print(f"Extracting legacy UI/music/lighting from universe {UNIVERSE_ID}, place {PLACE_ID}")
    task = create_task(script_source)
    task_path = task["path"]
    completed = poll_task(task_path)

    logs = fetch_logs(task_path)
    (EXPORT_DIR / "extraction.log").write_text(logs, encoding="utf-8")
    (EXPORT_DIR / "task.json").write_text(json.dumps(completed, indent=2), encoding="utf-8")

    state = completed.get("state")
    if state != "COMPLETE":
        raise RuntimeError(f"Roblox Luau extraction failed: state={state}, error={completed.get('error')}")

    binary_uri = completed.get("binaryOutputUri")
    if not binary_uri:
        raise RuntimeError("Roblox task completed without binaryOutputUri")

    package_path = EXPORT_DIR / "legacy-ui-music-lighting.rbxm"
    with urllib.request.urlopen(binary_uri, timeout=120) as response:
        package_path.write_bytes(response.read())

    results = (completed.get("output") or {}).get("results") or []
    manifest = {}
    if results:
        try:
            manifest = json.loads(results[0])
        except Exception:
            manifest = {"rawReturnValue": results[0]}

    manifest.update(
        {
            "requestedUniverseId": UNIVERSE_ID,
            "requestedPlaceId": PLACE_ID,
            "packageFile": package_path.name,
        }
    )
    manifest_path = EXPORT_DIR / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8")

    readme = f"""# ACC Legacy Roblox Material Backup\n\nSource Universe ID: {UNIVERSE_ID}\nSource Place ID: {PLACE_ID}\n\nThis backup intentionally contains only:\n- UI material from StarterGui plus additional UI roots/templates\n- Music/audio objects and their Roblox asset references\n- Lighting service settings, Lighting effects/Sky/Atmosphere, and Clouds\n\nIt intentionally excludes the old map geometry/world.\n\nPrimary reusable package: `legacy-ui-music-lighting.rbxm`\nMetadata: `manifest.json`\n"""
    (EXPORT_DIR / "README.md").write_text(readme, encoding="utf-8")

    zip_path = EXPORT_DIR / f"legacy-ui-music-lighting-{UNIVERSE_ID}-{PLACE_ID}.zip"
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for filename in ["legacy-ui-music-lighting.rbxm", "manifest.json", "README.md", "extraction.log", "task.json"]:
            path = EXPORT_DIR / filename
            archive.write(path, arcname=filename)

    print(f"Created {zip_path}")


if __name__ == "__main__":
    main()
