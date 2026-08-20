# WONDERPOCKET QC — v1.3.7 Protected Adventure Observability

## Baseline
- Last verified closed-test publish before this delta: Place version **57**.
- Locked target: Universe `8805231520` → Place `124843214013484`.
- Public release remains closed: `GameConfig.QA.PublishAllowed = false`.
- Registry remains disabled: `maps/registry.json` → `wonderpocket.enabled = false`.
- Dedication opening for **Putu Azya Putri Bintang Hardajaya** remains unchanged.
- No public access or visibility change is part of this delta.

## Code-side delta
- [x] Existing closed-test health panel now reads `WP_AdventureProtectedAbort`.
- [x] Adventure status line exposes the protected-abort flag as `Abort:Y` / `Abort:-`.
- [x] Existing health refresh loop is reused; no new polling loop was added.
- [x] No gameplay state, reward, currency, quest progress, DataStore, persistence schema, RemoteEvent, garden, placement, WonderDex, Wondi, world part, particle, or external asset changed.
- [x] The protected-abort flag remains server-owned; this client delta is observation-only.

## Static/scope checks
- [x] Change is confined to `maps/wonderpocket/wonderpocket.health.client.lua` plus this QC record and closed-test publish marker/diagnostic when used.
- [x] Locked Universe/Place IDs remain unchanged.
- [x] `wonderpocket.enabled=false` remains unchanged.
- [x] `GameConfig.QA.PublishAllowed=false` remains unchanged.
- [x] Dedication opening remains unchanged.

## Runtime evidence still required
- [ ] On Android closed-test, health panel fits without clipping/regression and shows `Abort:-` during a normal adventure session.
- [ ] Triggering the protected/read-only abort path shows `Abort:Y` without a red runtime error.
- [ ] Protected abort still grants no Coins, Stars, completion count, or quest progress.
- [ ] A later healthy controlled Treasure Island run resets the flag and health panel returns to `Abort:-`.

## Release rule
Do not enable the registry and do not set `PublishAllowed = true` from this code-side pass. Runtime gates remain open until directly observed in Roblox.
