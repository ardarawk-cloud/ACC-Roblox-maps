# WONDERPOCKET QC — v1.3.6 Protected Adventure Abort

## Baseline
- Last verified closed-test publish before this delta: Place version **56**.
- Locked target: Universe `8805231520` → Place `124843214013484`.
- Public release remains closed: `GameConfig.QA.PublishAllowed = false`.
- Registry remains disabled: `maps/registry.json` → `wonderpocket.enabled = false`.
- Dedication opening for **Putu Azya Putri Bintang Hardajaya** remains unchanged.
- No public access or visibility change is part of this delta.

## Code-side delta
- [x] Treasure Island now aborts an active run immediately when the canonical session becomes protected/read-only.
- [x] Protection transition invalidates the current run token so its delayed timeout cannot later act on the aborted run.
- [x] Protection transition clears the ephemeral active-adventure state and deadline without granting rewards.
- [x] `WP_AdventureProtectedAbort=true` exposes the protected abort path for closed-test observation.
- [x] Starting a healthy new run resets `WP_AdventureProtectedAbort=false` through existing run-state initialization.
- [x] Existing treasure collection debounce, deadline enforcement, server-authoritative completion, EconomyAudit, CriticalSave, and reward amounts are unchanged.
- [x] No DataStore, persistence schema, reward, currency amount, RemoteEvent, world part, particle, external asset, or polling loop was added.

## Static/scope checks
- [x] Change is confined to `maps/wonderpocket/wonderpocket.treasure-island.server.lua` plus this QC record and closed-test publish marker/diagnostic when used.
- [x] Locked Universe/Place IDs remain unchanged.
- [x] `wonderpocket.enabled=false` remains unchanged.
- [x] `GameConfig.QA.PublishAllowed=false` remains unchanged.
- [x] Dedication opening remains unchanged.

## Runtime evidence still required
- [ ] Healthy writable Treasure Island run still starts and collects treasure normally on Android closed-test.
- [ ] Entering `WP_DataReadOnly=true` during an active Treasure Island run clears `WP_ActiveAdventure` without a red runtime error.
- [ ] Protected abort exposes `WP_AdventureProtectedAbort=true` and does not grant Coins, Stars, completion count, or quest progress.
- [ ] The old delayed timeout does not mutate the already-aborted run.
- [ ] A later healthy controlled QA run resets `WP_AdventureProtectedAbort=false` and can complete normally.

## Release rule
Do not enable the registry and do not set `PublishAllowed = true` from this code-side pass. Runtime gates remain open until directly observed in Roblox.
