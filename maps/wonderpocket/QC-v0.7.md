# WONDERPOCKET QC v0.7 — PRE-PUBLISH HARDENING

Status: **CLOSED-TEST BUILD PIPELINE READY / LIVE RUNTIME TEST STILL REQUIRED**

## Passed in repository design
- WONDERPOCKET remains isolated on `agent/wonderpocket-target`.
- Registry target remains Universe `8805231520`, Place `124843214013484`, and disabled by default.
- Dedicated assembler `scripts/build-wonderpocket.js` creates `maps/wonderpocket/place.rbxlx` from WONDERPOCKET scripts only.
- Assembler normalizes the Remote folder to `WONDERPOCKET_Remotes`.
- Dedicated QC `scripts/qc-wonderpocket.js` rejects foreign BBYA / a-club tokens.
- Dedicated workflow `.github/workflows/wonderpocket-prepublish.yml` builds + QC's without publishing by default.
- Publishing requires explicit manual workflow dispatch with `publish=true`.
- BBYA injector is not part of the dedicated WONDERPOCKET workflow.
- Player-owned build plots, server placement validation, furniture persistence, and mobile build controls are implemented.

## Still requires Roblox runtime verification
1. DataStore read/write on target Experience.
2. Two-or-more-player plot ownership and collision test.
3. Android touch placement / rotate / cancel test.
4. Full server/client runtime error scan after assembled RBXLX is loaded.
5. Treasure Island entry/return and rewards test.
6. Wondi follow + interaction under respawn and reconnect.
7. Economy and quest save/reconnect sanity test.

## Release gate
**PUBLIC PUBLISH: BLOCKED** until runtime checks above pass.

Closed-test target may be published only after explicit owner approval.
