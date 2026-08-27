#!/usr/bin/env python3
"""
AFTER SCHOOL CITY — source spatial audit.

This is intentionally source-driven: it reads the Lua map generators and the
late correction/sanitize passes, reconstructs the effective 2D X/Z footprints
that matter for circulation, and fails on unsafe AABB/clearance relationships.

It does not inspect the saved Roblox instance tree because most ASC geometry is
created at runtime by ServerScriptService scripts.
"""

from __future__ import annotations

import json
import math
import re
import sys
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[2]
MAP = ROOT / "maps" / "after-school-city"

WORLD = MAP / "after-school-city.world.server.lua"
SCHOOL = MAP / "after-school-city.school-life.server.lua"
CITY = MAP / "after-school-city.city-life.server.lua"
STREET = MAP / "after-school-city.street-life.server.lua"
CLEANUP = MAP / "after-school-city.spatial-cleanup.server.lua"
REALIGN = MAP / "after-school-city.structural-realignment.server.lua"
LAYOUT = MAP / "after-school-city.layout-correction.server.lua"
CIRC = MAP / "after-school-city.circulation-sanitize.server.lua"
CLEARANCE = MAP / "after-school-city.clearance-sanitize.server.lua"

REPORT_PATH = ROOT / "spatial-audit-after-school-city.json"

NUM = r"-?(?:\d+(?:\.\d*)?|\.\d+)"
V3 = rf"Vector3\.new\(\s*({NUM})\s*,\s*({NUM})\s*,\s*({NUM})\s*\)"
CF = rf"CFrame\.new\(\s*({NUM})\s*,\s*({NUM})\s*,\s*({NUM})\s*\)"


@dataclass
class Box:
    name: str
    kind: str
    x: float
    z: float
    sx: float
    sz: float
    source: str
    group: str = ""
    active: bool = True
    note: str = ""

    @property
    def xmin(self) -> float:
        return self.x - self.sx / 2

    @property
    def xmax(self) -> float:
        return self.x + self.sx / 2

    @property
    def zmin(self) -> float:
        return self.z - self.sz / 2

    @property
    def zmax(self) -> float:
        return self.z + self.sz / 2


@dataclass
class Finding:
    severity: str
    rule: str
    a: str
    b: str
    detail: str


def read(path: Path) -> str:
    if not path.exists():
        raise SystemExit(f"required source missing: {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


SRC = {p.name: read(p) for p in [WORLD, SCHOOL, CITY, STREET, CLEANUP, REALIGN, LAYOUT, CIRC, CLEARANCE]}


def source(path: Path) -> str:
    return SRC[path.name]


def floats(groups: Iterable[str]) -> tuple[float, ...]:
    return tuple(float(x) for x in groups)


def find_required(text: str, pattern: str, label: str, flags: int = re.S) -> re.Match[str]:
    m = re.search(pattern, text, flags)
    if not m:
        raise SystemExit(f"spatial audit parser contract missing: {label}")
    return m


def add(boxes: list[Box], name: str, kind: str, x: float, z: float, sx: float, sz: float,
        src: Path, group: str = "", note: str = "") -> None:
    boxes.append(Box(name, kind, float(x), float(z), abs(float(sx)), abs(float(sz)),
                     src.name, group=group, note=note))


def direct_named_part(text: str, part_name: str, src: Path, kind: str,
                      boxes: list[Box], group: str = "") -> None:
    pat = rf'part\([^,\n]+,\s*"{re.escape(part_name)}"\s*,\s*{V3}\s*,\s*{CF}'
    m = find_required(text, pat, f"{src.name}:{part_name}", re.S)
    sx, _sy, sz, x, _y, z = floats(m.groups())
    add(boxes, part_name, kind, x, z, sx, sz, src, group)


def overlap(a: Box, b: Box, pad: float = 0.0) -> bool:
    return (
        a.xmin - pad < b.xmax and a.xmax + pad > b.xmin and
        a.zmin - pad < b.zmax and a.zmax + pad > b.zmin
    )


def separation(a: Box, b: Box) -> float:
    dx = max(b.xmin - a.xmax, a.xmin - b.xmax, 0.0)
    dz = max(b.zmin - a.zmax, a.zmin - b.zmax, 0.0)
    return math.hypot(dx, dz)


def parse_world(boxes: list[Box]) -> None:
    text = source(WORLD)

    direct_named_part(text, "EastWestRoad", WORLD, "road", boxes)

    # These are created in v0.2 but their effective runtime geometry is
    # replaced by later source passes. Parse replacement values, not stale
    # constructor values.
    m = find_required(source(REALIGN),
        rf'nsRoad\.Size\s*=\s*{V3}.*?nsRoad\.CFrame\s*=\s*{CF}',
        "effective NorthSouthRoad override")
    sx, _sy, sz, x, _y, z = floats(m.groups())
    add(boxes, "NorthSouthRoad", "road", x, z, sx, sz, REALIGN, note="effective override")

    m = find_required(source(CLEANUP),
        rf'schoolSportsRoad\.Size\s*=\s*{V3}.*?schoolSportsRoad\.CFrame\s*=\s*{CF}',
        "effective SchoolSportsRoad override")
    sx, _sy, sz, x, _y, z = floats(m.groups())
    add(boxes, "SchoolSportsRoad", "road", x, z, sx, sz, CLEANUP, note="effective override")

    for name in ("MainBuilding", "LeftWing", "RightWing"):
        direct_named_part(text, name, WORLD, "building", boxes, group="school-core")

    # Downtown shop row: fixed 34x40 footprint, X positions are source data.
    xs = find_required(text, r'local\s+shopXs\s*=\s*\{([^}]+)\}', "shopXs").group(1)
    shop_xs = [float(v) for v in re.findall(NUM, xs)]
    shop_names_raw = find_required(text, r'local\s+shopNames\s*=\s*\{([^}]+)\}', "shopNames").group(1)
    shop_names = re.findall(r'"([^"]+)"', shop_names_raw)
    if len(shop_xs) != len(shop_names):
        raise SystemExit("shop source arrays have different lengths")
    for x, name in zip(shop_xs, shop_names):
        add(boxes, f"Shop_{name}", "building", x, -56, 34, 40, WORLD)

    # Layout v0.4.3 destroys Townhouse_2 at Z=0; model the two edge houses.
    zraw = find_required(text, r'for\s+i,\s*z\s+in\s+ipairs\(\{([^}]+)\}\)\s+do\s+local\s+house',
                         "townhouse z list").group(1)
    town_z = [float(v) for v in re.findall(NUM, zraw)]
    if 'centerHouse = residential:FindFirstChild("Townhouse_2")' not in source(LAYOUT):
        raise SystemExit("Townhouse_2 removal contract missing")
    for i, z in enumerate(town_z, 1):
        if i == 2:
            continue
        add(boxes, f"Townhouse_{i}", "building", -235, z, 70, 34, WORLD)

    direct_named_part(text, "BasketballCourt", WORLD, "court", boxes)


def parse_street_grid(boxes: list[Box]) -> None:
    text = source(STREET)
    if 'for _, x in ipairs({-126, 126}) do' not in text:
        raise SystemExit("side-street source contract missing")
    for x in (-126.0, 126.0):
        add(boxes, f"SideStreet@{int(x)}", "road", x, 98, 28, 190, STREET)

    if 'for _, z in ipairs({62, 132}) do' not in text:
        raise SystemExit("cross-street source contract missing")
    if 'child.Position.Z > 100' not in source(CLEANUP):
        raise SystemExit("cross-street cleanup contract missing")
    add(boxes, "CrossStreet@62", "road", 0, 62, 280, 24, STREET,
        note="Z=132 source road removed by v0.4.1")


def parse_school_life(boxes: list[Box]) -> None:
    text = source(SCHOOL)
    m = find_required(text, rf'local\s+canteenX,\s*canteenZ\s*=\s*({NUM})\s*,\s*({NUM})',
                      "canteen center")
    cx, cz = floats(m.groups())
    m2 = find_required(text, rf'part\(canteen,\s*"Floor",\s*{V3}', "canteen footprint")
    sx, _sy, sz = floats(m2.groups())
    add(boxes, "StudentCanteen", "building", cx, cz, sx, sz, SCHOOL)

    # ClubHub from v0.3 is destroyed and rebuilt in v0.4.4.
    circ = source(CIRC)
    if 'oldClub:Destroy()' not in circ:
        raise SystemExit("old ClubHub destroy contract missing")
    m = find_required(circ, rf'local\s+cx,\s*cz\s*=\s*({NUM})\s*,\s*({NUM})', "ClubHubV044 center")
    cx, cz = floats(m.groups())
    m = find_required(circ, rf'local\s+width,\s*depth,\s*height\s*=\s*({NUM})\s*,\s*({NUM})\s*,\s*({NUM})',
                      "ClubHubV044 footprint")
    width, depth, _height = floats(m.groups())
    add(boxes, "ClubHubV044", "building", cx, cz, width, depth, CIRC)

    # Locker breezeway floor is a circulation footprint.
    direct_named_part(text, "Floor", SCHOOL, "access", boxes, group="locker-breezeway")


def parse_student_row(boxes: list[Box]) -> None:
    text = source(STREET)
    pat = re.compile(rf'lowRise\(infill,\s*"([^"]+)",\s*{V3}\s*,\s*{V3}', re.S)
    rows: dict[str, tuple[float, float, float, float]] = {}
    for m in pat.finditer(text):
        name = m.group(1)
        px, _py, pz, sx, _sy, sz = floats(m.groups()[1:])
        rows[name] = (px, pz, sx, sz)

    for required in ("StudentMiniMart", "StudyLounge", "CommunityLibrary", "YouthStudio",
                     "CornerBakery", "CornerTech"):
        if required not in rows:
            raise SystemExit(f"lowRise source missing: {required}")

    cleanup = source(CLEANUP)
    layout = source(LAYOUT)
    if "if bakery then bakery:Destroy() end" not in cleanup or "if tech then tech:Destroy() end" not in cleanup:
        raise SystemExit("corner kiosk cleanup contract missing")
    if "youth:Destroy()" not in layout:
        raise SystemExit("YouthStudio removal contract missing")

    placement_block = find_required(cleanup, r'local\s+placement\s*=\s*\{(.*?)\n\s*\}', "student row placement").group(1)
    placements = {
        name: (float(z), float(yaw))
        for name, z, yaw in re.findall(
            rf'(\w+)\s*=\s*\{{\s*z\s*=\s*({NUM})\s*,\s*yaw\s*=\s*({NUM})\s*\}}',
            placement_block,
        )
    }

    for name in ("StudentMiniMart", "StudyLounge", "CommunityLibrary"):
        x, original_z, sx, sz = rows[name]
        z, yaw = placements.get(name, (original_z, 0.0))
        if int(abs(yaw)) % 180 == 90:
            sx, sz = sz, sx
        add(boxes, name, "building", x, z, sx, sz, STREET,
            note=f"effective yaw={yaw:g} from v0.4.1")


def parse_parking_and_vehicles(boxes: list[Box]) -> None:
    text = source(CLEANUP)

    lot_pat = re.compile(rf'parkingLot\(parking,\s*"([^"]+)",\s*{V3}\s*,\s*{V3}\s*\)')
    for m in lot_pat.finditer(text):
        name = m.group(1)
        x, _y, z, sx, _sy, sz = floats(m.groups()[1:])
        add(boxes, name, "parking", x, z, sx, sz, CLEANUP)

    car_pat = re.compile(rf'parkedCar\(parking,\s*"([^"]+)",\s*{V3}\s*,\s*({NUM})\s*,')
    for m in car_pat.finditer(text):
        name = m.group(1)
        x, _y, z, yaw = floats(m.groups()[1:])
        sx, sz = 9.5, 17.0
        if int(abs(yaw)) % 180 == 90:
            sx, sz = sz, sx
        add(boxes, name, "vehicle", x, z, sx, sz, CLEANUP)

    m = find_required(text, rf'local\s+bcf\s*=\s*CFrame\.new\(\s*({NUM})\s*,\s*({NUM})\s*,\s*({NUM})\s*\)'
                            rf'\s*\*\s*CFrame\.Angles\(0,\s*math\.rad\(\s*({NUM})\s*\),\s*0\)',
                      "effective school bus")
    x, _y, z, yaw = floats(m.groups())
    sx, sz = 11.0, 30.0
    if int(abs(yaw)) % 180 == 90:
        sx, sz = sz, sx
    add(boxes, "SchoolBusParked", "vehicle", x, z, sx, sz, CLEANUP)


def parse_effective_trees_and_hedges(boxes: list[Box], notes: list[str]) -> None:
    # Model trunk footprint only; tree crowns are non-collidable in ASC.
    tree_call = re.compile(rf'(?:safeTree|tree)\([^,\n]+,\s*Vector3\.new\(\s*({NUM})\s*,\s*({NUM})\s*,\s*({NUM})\s*\)\s*,\s*({NUM})\s*\)')
    sanitized = 0
    for path in (WORLD, STREET, CLEANUP, LAYOUT):
        text = source(path)
        for idx, m in enumerate(tree_call.finditer(text), 1):
            x, _y, z, scale = floats(m.groups())
            if 214 <= z <= 286 and abs(x) <= 116:
                sanitized += 1
                continue
            if path == STREET and x > 145 and z > 145:
                sanitized += 1
                continue
            add(boxes, f"{path.stem}:Tree#{idx}", "tree", x, z, 1.8 * scale, 1.8 * scale, path)

    notes.append(f"{sanitized} literal source tree placements are removed by late sanitize/correction passes")

    city = source(CITY)
    m = find_required(city, rf'for\s+z\s*=\s*({NUM})\s*,\s*({NUM})\s*,\s*({NUM})\s*do\s+'
                            rf'local\s+hedge\s*=\s*part\(r,\s*"Hedge",\s*Vector3\.new\(\s*({NUM})\s*,\s*({NUM})\s*,\s*({NUM})\s*\),\s*'
                            rf'CFrame\.new\(\s*({NUM})\s*,\s*({NUM})\s*,\s*z\s*\)',
                      "residential hedge loop")
    start, stop, step, sx, _sy, sz, x, _y = floats(m.groups())
    if 'math.abs(obj.Position.Z) <= 24' not in source(CLEARANCE):
        raise SystemExit("v0.4.5 residential hedge sanitize contract missing")
    z = start
    i = 0
    while z <= stop + 1e-9:
        i += 1
        if abs(z) > 24:
            add(boxes, f"ResidentialHedge#{i}", "hedge", x, z, sx, sz, CITY)
        z += step


def check_contracts(boxes: list[Box]) -> tuple[list[Finding], list[str]]:
    findings: list[Finding] = []
    notes: list[str] = []

    roads = [b for b in boxes if b.kind == "road"]
    buildings = [b for b in boxes if b.kind == "building"]
    trees = [b for b in boxes if b.kind == "tree"]
    vehicles = [b for b in boxes if b.kind == "vehicle"]
    hedges = [b for b in boxes if b.kind == "hedge"]
    accesses = [b for b in boxes if b.kind == "access"]
    courts = [b for b in boxes if b.kind == "court"]
    parkings = [b for b in boxes if b.kind == "parking"]

    for a in buildings:
        for b in roads:
            if overlap(a, b):
                findings.append(Finding("ERROR", "building-road-overlap", a.name, b.name,
                                        f"AABB overlap; separation={separation(a,b):.2f}"))
            elif separation(a, b) < 1.0:
                findings.append(Finding("ERROR", "building-road-clearance", a.name, b.name,
                                        f"clearance {separation(a,b):.2f} < 1.0"))

    for i, a in enumerate(buildings):
        for b in buildings[i + 1:]:
            if a.group and a.group == b.group:
                continue
            if overlap(a, b):
                findings.append(Finding("ERROR", "building-building-overlap", a.name, b.name, "AABB overlap"))

    for a in trees + hedges:
        for b in roads:
            if overlap(a, b):
                findings.append(Finding("ERROR", f"{a.kind}-road-overlap", a.name, b.name, "AABB overlap"))

    for v in vehicles:
        for b in buildings:
            d = separation(v, b)
            if overlap(v, b) or d < 4.0:
                findings.append(Finding("ERROR", "vehicle-building-clearance", v.name, b.name,
                                        f"clearance {d:.2f} < 4.0"))
        for t in trees:
            d = separation(v, t)
            if overlap(v, t) or d < 6.0:
                findings.append(Finding("ERROR", "tree-vehicle-clearance", t.name, v.name,
                                        f"clearance {d:.2f} < 6.0"))
        for r in roads:
            if overlap(v, r):
                findings.append(Finding("ERROR", "vehicle-road-overlap", v.name, r.name,
                                        "parked vehicle intrudes into road envelope"))

    door_zone = Box("SchoolMainDoorCirculation", "zone", 0, 250, 232, 72, "policy")
    for obj in trees + vehicles:
        if overlap(obj, door_zone):
            findings.append(Finding("ERROR", "school-entrance-circulation", obj.name, door_zone.name,
                                    "tree/vehicle enters x±116, z214..286 hard-clear zone"))

    for access in accesses:
        for obj in trees + vehicles:
            if overlap(access, obj):
                findings.append(Finding("ERROR", "access-clearance", obj.name, access.name,
                                        "object penetrates access footprint"))

    for court in courts:
        for b in buildings:
            if b.group == "school-core":
                continue
            d = separation(court, b)
            if overlap(court, b) or d < 6.0:
                findings.append(Finding("ERROR", "sports-court-building-clearance", b.name, court.name,
                                        f"clearance {d:.2f} < 6.0"))

    for p in parkings:
        for b in buildings:
            if overlap(p, b):
                findings.append(Finding("ERROR", "parking-building-overlap", p.name, b.name, "AABB overlap"))
        for r in roads:
            if overlap(p, r):
                findings.append(Finding("ERROR", "parking-road-overlap", p.name, r.name, "AABB overlap"))

    return findings, notes


def main() -> int:
    boxes: list[Box] = []
    notes: list[str] = []

    parse_world(boxes)
    parse_street_grid(boxes)
    parse_school_life(boxes)
    parse_student_row(boxes)
    parse_parking_and_vehicles(boxes)
    parse_effective_trees_and_hedges(boxes, notes)

    findings, more_notes = check_contracts(boxes)
    notes.extend(more_notes)

    chain = [
        (CLEANUP, 'root:WaitForChild("V04_StreetLife", 20)'),
        (REALIGN, 'root:WaitForChild("V041_SpatialCleanup", 20)'),
        (LAYOUT, 'root:WaitForChild("V042_StructuralRealignment", 20)'),
        (CIRC, 'root:WaitForChild("V043_LayoutCorrection", 20)'),
        (CLEARANCE, 'root:WaitForChild("V044_CirculationSanitize", 20)'),
    ]
    for path, token in chain:
        if token not in source(path):
            findings.append(Finding("ERROR", "late-pass-order", path.name, token,
                                    "required dependency wait missing"))

    counts: dict[str, int] = {}
    for b in boxes:
        counts[b.kind] = counts.get(b.kind, 0) + 1

    report = {
        "project": "AFTER SCHOOL CITY",
        "audit": "CLOUD_SOURCE_SPATIAL_AUDIT_V1",
        "status": "PASS" if not findings else "FAIL",
        "counts": counts,
        "notes": notes,
        "findings": [asdict(f) for f in findings],
        "geometry": [asdict(b) for b in boxes],
    }
    REPORT_PATH.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    print("AFTER SCHOOL CITY — CLOUD SOURCE SPATIAL AUDIT V1")
    print("geometry:", ", ".join(f"{k}={v}" for k, v in sorted(counts.items())))
    for note in notes:
        print("NOTE:", note)
    if findings:
        for f in findings:
            print(f"{f.severity}: {f.rule}: {f.a} <-> {f.b}: {f.detail}")
        print(f"FAIL: {len(findings)} spatial conflict(s)")
        return 1
    print("PASS: no modeled collision/clearance conflicts")
    return 0


if __name__ == "__main__":
    sys.exit(main())
