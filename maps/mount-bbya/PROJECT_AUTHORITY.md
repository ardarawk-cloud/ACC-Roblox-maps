# MOUNT BBYA — PROJECT AUTHORITY v4.0

Status: **ACTIVE / ISOLATED VISUAL-LOCK REBUILD**
Owner / Final Authority: Arda
Reopen date: 8 September 2026
Active branch: `mount-bbya-rebuild-visual-lock-v1`
Active candidate: `visual-lock-rebuild-v1.1`

## Latest explicit owner order
Arda explicitly reopened MOUNT BBYA and locked the latest approved mountain concept, then ordered the project to proceed: **“Ok lock.. Gas bikin jng mengecewakan.”**

This satisfies the v3.0 reopen rule. The project is no longer globally stopped, but the old rejected runtime remains forbidden as a continuation baseline.

## Active visual lock
Build one coherent realistic tropical Indonesian mountain, in this progression:

1. Desa Kaki Gunung / Spawn
2. Basecamp
3. Jalur Hutan Tropis
4. Pos 1
5. Lembah & Sungai
6. Pos 2
7. Jalur Tebing
8. Pos 3 / High Camp
9. Zona Pegunungan Tinggi
10. Jalur Summit
11. Puncak

Rules:
- no snow;
- no fantasy/magical terrain;
- terrain and trail must read as one connected mountain;
- route must be physically traversable and mobile-friendly;
- checkpoints must be meaningfully separated;
- no floating/disconnected route geometry;
- do not regenerate concept imagery unless Arda explicitly requests it; implementation now takes priority.

## Active rebuild architecture
- Runtime root: `MOUNT_BBYA_REBUILD_V11`
- Grounding: `FOUNDATION_CARVE_SUBGRADE_TRAIL`
- Route target: > 6,500 studs; current design ~7,100 studs
- Checkpoints: Pos 1 / Pos 2 / Pos 3 / Summit
- Structural runtime QC may become `PASS_CANDIDATE`, but physical in-game visual QC is still required before calling the map approved.

## Rejected historical snapshot — NON-CONTINUATION
The prior Version 23 result remains **REJECTED / NON-CONTINUATION**:
- Roblox Version: `23`
- Build: `v7.0.0-full-map-reset`
- Published source: `9d544c5e02c51119b60f3a55a49e0c22c99df18f`
- Runtime QC: **FAIL / REJECTED**

Do not reuse Version 23 geometry as an approved baseline.

## Publish target lock
MOUNT BBYA only:
- Universe ID: `4187755690`
- Place ID: `11832985967`

## Separate forbidden target
Mountain Social remains separate and must not be touched:
- Universe ID: `10744139279`
- Place ID: `82661754996018`
- Status: **PAUSED / DO NOT TOUCH**

Builder and publisher must hard-fail if the Mountain Social target is detected.

## Approval rule
A successful Roblox publish is not visual approval. Approval requires runtime evidence from the actual MOUNT BBYA place showing the village spawn, grounded route progression, checkpoint spacing, valley/bridge, cliff/high camp, and summit composition.
