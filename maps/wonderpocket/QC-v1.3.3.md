# WONDERPOCKET QC — v1.3.3 First-Journey Cohesion Copy Pass

## Baseline
- Previous closed-test publish receipt verified before this batch: Place version **53**, `exit_code=0`.
- Locked target remains Universe `8805231520` → Place `124843214013484`.
- `maps/registry.json` → `wonderpocket.enabled = false` remains required.
- `GameConfig.QA.PublishAllowed = false` remains required.
- No public access or visibility change is authorized.

## Code-side delta
- [x] Changed only the existing first-session tutorial objective copy in `wonderpocket.tutorial.server.lua`.
- [x] Step order remains Meet Wondi → plant → buy decor → place decor → harvest → treasure.
- [x] Wondi, personal Pocket, garden, decor, and discovery/adventure are described as one connected first journey.
- [x] Mobile actions remain explicit (`SAY HI`, `SHOP`, `BUILD`, `PLACE`, `HARVEST`, Adventure Gate).
- [x] Tutorial completion predicates are unchanged.
- [x] Tutorial remote contract is unchanged.
- [x] No DataStore name, schema, save trigger, reward amount, currency, inventory, garden timing, placement validation, WonderDex authority, or retention rule changed.
- [x] No new UI object, loop, remote, DataStore, part, particle, sound, image, or external asset was added.
- [x] Dedication/opening content was not edited by this batch.

## Static/scope gates
- [x] WONDERPOCKET target IDs remain hard-locked.
- [x] Public release gates remain closed.
- [x] Batch is small and reversible: one Lua file plus this QC record.
- [x] No other map/project is intentionally modified.

## Runtime evidence still required
- [ ] Android closed-test shows each revised objective without clipping or unreadable wrapping.
- [ ] Six tutorial steps still advance in the same order from actual gameplay events.
- [ ] Rejoin/resume behavior remains correct with persisted tutorial milestones.
- [ ] Read-only/load-failure mode still prevents tutorial start mutation as designed.
- [ ] No red runtime errors are observed during the first-journey flow.

## Release rule
Do not enable the WONDERPOCKET registry and do not set `PublishAllowed = true` from this pass. The runtime gates above remain open until directly observed in Roblox.
