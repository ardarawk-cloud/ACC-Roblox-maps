import json
import struct
import sys


def main(path: str) -> None:
    data = open(path, "rb").read()
    if data[:4] != b"glTF":
        raise SystemExit("not a GLB file")

    offset = 12
    metadata = None
    while offset < len(data):
        length, chunk_type = struct.unpack_from("<II", data, offset)
        offset += 8
        chunk = data[offset : offset + length]
        offset += length
        if chunk_type == 0x4E4F534A:
            metadata = json.loads(chunk.decode("utf-8").rstrip(" \t\r\n\x00"))
            break

    if metadata is None:
        raise SystemExit("GLB JSON metadata missing")

    extras = (metadata.get("asset") or {}).get("extras") or {}
    blob = json.dumps(extras, ensure_ascii=False).lower()
    has_license = "cc-by-4.0" in blob or "creativecommons.org/licenses/by/4.0" in blob
    has_author = "arsen ismailov" in blob
    if not has_license:
        raise SystemExit("CC BY 4.0 license metadata missing")
    if not has_author:
        raise SystemExit("Arsen Ismailov attribution metadata missing")

    print("LICENSE PASS CC-BY-4.0 / Arsen Ismailov")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("usage: asc_check_glb_license.py <file.glb>")
    main(sys.argv[1])
