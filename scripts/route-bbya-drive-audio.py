#!/usr/bin/env python3
import json
import pathlib

REPO = pathlib.Path(__file__).resolve().parents[1]
REGISTRY = REPO / "deploy-status" / "bbya-basement-drive-registry.json"
BASEMENT = REPO / "maps" / "bbya-social-hub" / "85-basement-autodj.server.lua"
MAIN = REPO / "maps" / "bbya-social-hub" / "30-club-systems.server.lua"
REPORT = REPO / "deploy-status" / "bbya-audio-routing.json"

BASE_BEGIN = "-- DRIVE_LIBRARY_UPLOAD_BEGIN"
BASE_END = "-- DRIVE_LIBRARY_UPLOAD_END"
MAIN_BEGIN = "-- MAIN_PROGRESSIVE_UPLOAD_BEGIN"
MAIN_END = "-- MAIN_PROGRESSIVE_UPLOAD_END"


def esc(value):
    return str(value).replace("\\", "\\\\").replace('"', '\\"').replace("\n", " ")


def replace_or_insert(source, begin, end, lines, anchor="local PLAYLIST={\n", after_marker=None):
    block = "\n".join([begin, *lines, end])
    if begin in source and end in source:
        return source.split(begin, 1)[0] + block + source.split(end, 1)[1]
    if after_marker and after_marker in source:
        return source.replace(after_marker, after_marker + "\n" + block, 1)
    if anchor not in source:
        raise RuntimeError(f"Playlist anchor not found for {begin}")
    return source.replace(anchor, anchor + block + "\n", 1)


def lua_line(item):
    return f' {{title="{esc(item.get("title") or "BBYA Track")}",id="{item["assetId"]}",style="{esc(item.get("style") or "club")}"}},'


def sort_key(pair):
    drive_id, item = pair
    return (
        int(item.get("sourceOrder", 999)),
        str(item.get("sourceFolder", "")).lower(),
        str(item.get("title", "")).lower(),
        drive_id,
    )


def main():
    if not REGISTRY.exists():
        raise SystemExit("Registry missing: " + str(REGISTRY))

    registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
    pairs = [
        (drive_id, item)
        for drive_id, item in (registry.get("items") or {}).items()
        if item.get("assetId") and not item.get("legacy")
    ]
    pairs.sort(key=sort_key)

    progressive = []
    basement = []
    for drive_id, item in pairs:
        normalized = str(item.get("sourceFolder") or "").strip().upper()
        if normalized == "PROGRESIVE":
            progressive.append((drive_id, item))
        else:
            basement.append((drive_id, item))

    basement_source = BASEMENT.read_text(encoding="utf-8")
    main_source = MAIN.read_text(encoding="utf-8")

    basement_source = replace_or_insert(
        basement_source,
        BASE_BEGIN,
        BASE_END,
        [lua_line(item) for _, item in basement],
        after_marker="-- ADXL_OWNER_UPLOAD_END",
    )
    main_source = replace_or_insert(
        main_source,
        MAIN_BEGIN,
        MAIN_END,
        [lua_line(item) for _, item in progressive],
    )

    # Hard routing assertions: PROGRESIVE only Main Club; everything else only Basement.
    base_block = basement_source.split(BASE_BEGIN, 1)[1].split(BASE_END, 1)[0]
    main_block = main_source.split(MAIN_BEGIN, 1)[1].split(MAIN_END, 1)[0]

    errors = []
    for drive_id, item in progressive:
        aid = str(item["assetId"])
        if aid in base_block:
            errors.append(f"Progressive asset leaked into Basement: {aid}")
        if aid not in main_block:
            errors.append(f"Progressive asset missing from Main Club: {aid}")
    for drive_id, item in basement:
        aid = str(item["assetId"])
        if aid not in base_block:
            errors.append(f"Basement asset missing from Basement: {aid}")
        if aid in main_block:
            errors.append(f"Non-progressive asset leaked into Main Club: {aid}")

    report = {
        "routing": {
            "PROGRESIVE": "MAIN_CLUB",
            "ALL_OTHER_DRIVE_FOLDERS": "BASEMENT",
        },
        "mainProgressiveCount": len(progressive),
        "basementDriveCount": len(basement),
        "mainProgressiveAssetIds": [str(item["assetId"]) for _, item in progressive],
        "errors": errors,
        "valid": not errors,
    }
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")

    if errors:
        raise SystemExit("Routing guard failed: " + "; ".join(errors[:10]))

    BASEMENT.write_text(basement_source, encoding="utf-8")
    MAIN.write_text(main_source, encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
