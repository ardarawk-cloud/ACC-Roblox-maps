# WONDERPOCKET QC — v1.3.1 Protected-Mode Failure UX

## Baseline
- Last verified closed-test publish before this delta: Place version **51**.
- Locked target: Universe `8805231520` → Place `124843214013484`.
- Public release remains closed: `GameConfig.QA.PublishAllowed = false`.
- Registry remains disabled: `maps/registry.json` → `wonderpocket.enabled = false`.
- No public access or visibility changes are part of this delta.

## Code-side delta
- [x] READ-ONLY/protected banner now reports the exact failing persistence subsystem when available.
- [x] Supported labels: Main Data, Furniture Inventory, Placed Furniture, Garden, WonderDex.
- [x] Banner consumes the server-owned `WP_SaveHealthFailure` signal first, then safely falls back to load/save health attributes.
- [x] No client retry, recovery write, reward, purchase, placement, gardening, or discovery mutation was added.
- [x] Existing fail-closed behavior remains authoritative; the client only explains why the session is protected.
- [x] Generic SAVE DATA UNAVAILABLE copy remains as fallback when no precise source is available.
- [x] Mobile footprint remains unchanged at max 520×52 px.

## Runtime evidence still required
- [ ] Simulated/observed Main Data failure shows `MAIN DATA SAVE UNAVAILABLE` and protected mode.
- [ ] Simulated/observed Furniture Inventory failure names that subsystem.
- [ ] Simulated/observed Placed Furniture failure names that subsystem.
- [ ] Simulated/observed Garden failure names that subsystem.
- [ ] Simulated/observed WonderDex failure names that subsystem.
- [ ] Rejoin after service recovery restores normal mode and removes the banner.
- [ ] No red runtime errors on Android landscape while the banner is visible.

## Release rule
Do not enable the registry and do not set `PublishAllowed = true` from this code-side pass. Live/runtime gates remain open until observed in Roblox.
