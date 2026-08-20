# WONDERPOCKET QC — v1.3.2 Retention Observability

## Baseline
- Last verified closed-test publish before this delta: Place version **52**.
- Locked target: Universe `8805231520` → Place `124843214013484`.
- Public release remains closed: `GameConfig.QA.PublishAllowed = false`.
- Registry remains disabled: `maps/registry.json` → `wonderpocket.enabled = false`.
- No public access or visibility changes are part of this delta.

## Code-side delta
- [x] Retention load now exposes the clamped offline duration as `WP_RetentionOfflineSeconds`.
- [x] Current daily reset key is exposed as `WP_RetentionDayKey`.
- [x] Current weekly reset key is exposed as `WP_RetentionWeekKey`.
- [x] Whether this join executed the daily reset path is exposed as `WP_RetentionDailyReset`.
- [x] Whether this join executed the weekly reset path is exposed as `WP_RetentionWeeklyReset`.
- [x] Existing `WP_OfflineReward`, `WP_DailyRewardClaimed`, daily/weekly progress resets, EconomyAudit events, and CriticalSave behavior are unchanged.
- [x] No reward amounts, reset cadence, quest targets, persistence schema, purchase logic, garden logic, placement logic, adventure rewards, or WonderDex authority changed.
- [x] No new UI, remote, DataStore, loop, part, particle, or external asset was added.

## Runtime evidence still required
- [ ] First eligible join exposes a positive `WP_RetentionOfflineSeconds` matching the canonical offline clamp.
- [ ] Offline coin reward matches `floor(WP_RetentionOfflineSeconds / 60)` without duplicate grant in the same canonical load.
- [ ] Daily reset path exposes `WP_RetentionDailyReset=true` only when the canonical day key changes.
- [ ] Weekly reset path exposes `WP_RetentionWeeklyReset=true` only when the canonical week key changes.
- [ ] Same-day rejoin does not duplicate the daily reward.
- [ ] Same-week rejoin does not reset weekly progress again.
- [ ] Retention attributes remain observable on Android closed-test without red runtime errors.

## Release rule
Do not enable the registry and do not set `PublishAllowed = true` from this code-side pass. Live/runtime gates remain open until observed in Roblox.
