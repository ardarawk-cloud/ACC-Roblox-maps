# MOUNT BBYA — PROJECT AUTHORITY

Status: ACTIVE / PHASE 1 CANDIDATE BUILD
Priority: Mount BBYA only

## Final target identity
- Project: MOUNT BBYA / Gunung BBYA
- Universe ID: `4187755690`
- Place ID: `11832985967`
- Registry key: `mount-bbya`
- Source path: `maps/mount-bbya`

## Forbidden target
Mountain Social is a separate project and remains PAUSED / DO NOT TOUCH:
- Universe ID: `10744139279`
- Place ID: `82661754996018`

Do not publish Mount BBYA source to the Mountain Social target.

## Donor continuation
The latest relevant Mount BBYA runtime donor is:
- branch: `agent/mountain-master-v3`
- source commit: `08dc1c083289a6505808607546fbfb788ea21d36`
- build marker: `v6.4-phase1-multiscript-runtime`

The donor lived under the stale folder name `maps/mountain-social`, but its active injector hard-locked publishing to Mount BBYA `4187755690 / 11832985967`. The stale folder/config naming is retired as authority; the runtime package is transplanted coherently into `maps/mount-bbya`.

## Phase 1 scope
Only:
`Spawn → Village → Road → Trail Entrance → CP1`

No CP2+ until Phase 1 is accepted.

Build order:
1. Terrain foundation
2. Road corridor
3. Terrain freeze
4. Village foundations / houses
5. Roadside / drainage
6. Vegetation / depth
7. Trail entrance
8. CP1
9. Lighting / ambience
10. Mobile/static QC
11. User runtime visual QC

## Current candidate
- Baseline donor: v6.4 Phase 1
- New pass: v6.5 visual depth / premium foothill pass
- New pass is visual-only after terrain freeze; it does not call Terrain Fill APIs.
- Adds road shoulder/drain detail, utility line, Indonesian village cues, denser non-spherical tropical vegetation, trail-edge detail, and clearer CP1 arrival.
- Existing checkpoint datastore name is preserved for compatibility.

## Publishing gate
Publishing remains disabled for this candidate.

Required sequence:
1. Exact target verification
2. Static/build QC
3. Generated RBXLX artifact verification
4. User visual/runtime approval
5. Publish to Universe `4187755690` / Place `11832985967`
6. Verify Roblox receipt/version
7. Runtime verify
8. Only then claim LIVE

Merge != LIVE.
