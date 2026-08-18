import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "exports" / "legacy" / "manifest.json"
OUT_DIR = ROOT / "assets" / "bbya"
OUT = OUT_DIR / "legacy-purchased-assets.json"


def normalize_asset_id(value):
    if not isinstance(value, str):
        return None
    digits = "".join(ch for ch in value if ch.isdigit())
    return digits or None


def main():
    if not MANIFEST.exists():
        raise SystemExit(f"Missing extraction manifest: {MANIFEST}")

    data = json.loads(MANIFEST.read_text(encoding="utf-8"))
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    audio = []
    seen_audio = set()
    for sound in data.get("sounds", []):
        asset_id = normalize_asset_id(sound.get("soundId"))
        if not asset_id or asset_id in seen_audio:
            continue
        seen_audio.add(asset_id)
        audio.append({
            "assetId": asset_id,
            "name": sound.get("name"),
            "sourcePath": sound.get("path"),
            "volume": sound.get("volume"),
            "looped": sound.get("looped"),
            "playbackSpeed": sound.get("playbackSpeed"),
            "source": "legacy-place-8805231520-124843214013484",
            "status": "IMPORTED_REFERENCE"
        })

    payload = {
        "schemaVersion": 1,
        "targetProject": "BBYA Social Hub",
        "sourceUniverseId": str(data.get("sourceUniverseId") or data.get("requestedUniverseId") or "8805231520"),
        "sourcePlaceId": str(data.get("sourcePlaceId") or data.get("requestedPlaceId") or "124843214013484"),
        "audioAssetIds": audio,
        "lighting": data.get("lighting", {}),
        "notes": [
            "Generated from legacy place backup.",
            "Geometry is intentionally excluded.",
            "UI image/decal IDs remain preserved inside the exported RBXM package and can be selectively migrated after QC.",
            "Audio references should be tested for Roblox permission/availability before being promoted into BBYA Auto-DJ VAULT."
        ]
    }

    OUT.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Wrote {OUT} with {len(audio)} unique audio asset IDs")


if __name__ == "__main__":
    main()
