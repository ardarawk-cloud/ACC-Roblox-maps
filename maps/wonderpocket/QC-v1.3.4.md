# WONDERPOCKET QC — v1.3.4 Protected-Session Wondi Reaction Guard

## Baseline
- Previous closed-test publish receipt verified before this batch: Place version **54**, `exit_code=0`.
- Locked target remains Universe `8805231520` → Place `124843214013484`.
- `maps/registry.json` → `wonderpocket.enabled = false` remains required.
- `GameConfig.QA.PublishAllowed = false` remains required.
- No public access or visibility change is authorized.
- Dedication opening for Putu Azya Putri Bintang Hardajaya remains unchanged.

## Code-side delta
- [x] Changed only `wonderpocket.wondi-reactions.server.lua` plus this QC record.
- [x] Contextual Wondi reactions now refuse to fire unless canonical main data is loaded.
- [x] Contextual Wondi reactions now refuse to fire while `WP_DataReadOnly=true` or `WP_DataLoadFailed=true`.
- [x] Existing reaction cooldown, watched progression attributes, special-emote mapping, and purchase-reaction arming are unchanged.
- [x] No tutorial completion rule, reward, currency, inventory count, garden state, placement state, retention rule, adventure reward, WonderDex authority, save trigger, DataStore, remote, UI, part, particle, sound, image, or external asset changed.

## Static/scope gates
- [x] WONDERPOCKET target IDs remain hard-locked.
- [x] Public release gates remain closed.
- [x] Batch is small and reversible: one server Lua file plus this QC record.
- [x] No other Roblox map/project is intentionally modified.

## Runtime evidence still required
- [ ] Closed-test normal loaded session still shows Wondi reactions after furniture placement, harvest, treasure/adventure progress, daily/offline reward, starter quest reward, and furniture purchase events.
- [ ] A session entering protected/read-only mode does not emit new contextual Wondi reaction sequence increments afterward.
- [ ] Rejoin into a healthy session restores contextual reactions normally.
- [ ] No red runtime errors are observed during the above checks.

## Release rule
Do not enable the WONDERPOCKET registry and do not set `PublishAllowed = true` from this pass. Runtime gates remain open until directly observed in Roblox.
