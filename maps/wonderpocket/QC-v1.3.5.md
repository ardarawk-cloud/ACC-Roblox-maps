# WONDERPOCKET QC — v1.3.5 Protected Wondi Meet Prompt

## Baseline
- Last verified closed-test publish before this delta: Place version **55**.
- Locked target: Universe `8805231520` → Place `124843214013484`.
- Public release remains closed: `GameConfig.QA.PublishAllowed = false`.
- Registry remains disabled: `maps/registry.json` → `wonderpocket.enabled = false`.
- Dedication opening for **Putu Azya Putri Bintang Hardajaya** remains unchanged.
- No public access or visibility change is part of this delta.

## Code-side delta
- [x] Wondi meet prompt visibility now requires canonical data to be loaded and writable.
- [x] `WP_DataReadOnly=true` immediately hides/disables the owner Wondi `Say Hi` prompt.
- [x] `WP_DataLoadFailed=true` keeps the prompt disabled.
- [x] Prompt visibility now resynchronizes when `WP_Tutorial_MetWondi`, `WP_DataLoaded`, `WP_DataReadOnly`, or `WP_DataLoadFailed` changes.
- [x] Existing server-side trigger guards remain intact.
- [x] Existing tutorial completion predicate, CriticalSave behavior, Wondi Wave trigger, cooldowns, persistence, economy, garden, placement, retention, adventure, and WonderDex authority are unchanged.
- [x] No new RemoteEvent, DataStore, reward, currency mutation, world part, particle, loop, or external asset was added.

## Static/scope checks
- [x] Change is confined to `maps/wonderpocket/wonderpocket.wondi-meet.server.lua` plus this QC record and closed-test publish diagnostics/marker when used.
- [x] Locked Universe/Place IDs remain unchanged.
- [x] `wonderpocket.enabled=false` remains unchanged.
- [x] `GameConfig.QA.PublishAllowed=false` remains unchanged.

## Runtime evidence still required
- [ ] On Android closed-test, `Say Hi` prompt is visible in a healthy writable first-session state before meeting the Wondi.
- [ ] Toggling/entering protected read-only state makes the prompt disappear without a red runtime error.
- [ ] Returning to a healthy writable state in a controlled QA session resynchronizes prompt visibility correctly when the tutorial milestone is still incomplete.
- [ ] Triggering `Say Hi` in a healthy session still produces the visible Wave and advances the tutorial exactly once.
- [ ] Rejoin after the persisted milestone does not re-enable the prompt.

## Release rule
Do not enable the registry and do not set `PublishAllowed = true` from this code-side pass. Runtime gates remain open until directly observed in Roblox.
