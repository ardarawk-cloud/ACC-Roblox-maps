# WONDERPOCKET QC — v1.3 Fail-Closed Data Safety

## Current closed-test baseline
- Place version: **31**
- Target: Universe `8805231520` → Place `124843214013484`
- Public release: **closed** (`PublishAllowed = false`)
- Registry: **disabled**
- v31 includes tutorial rejoin-resume inference, state-driven Bubbi/Say Hi startup, tutorial SHOP/BUILD/PLACE guidance, Android placement surface/height hardening, and mobile-fit onboarding.
- Live/runtime gates below remain intentionally unchecked until observed in Roblox; code-side review is not treated as a runtime pass.

## Code-side gate
- [x] main player DataStore fails closed after retry exhaustion
- [x] failed main read sets `WP_DataLoadFailed` + `WP_DataReadOnly`
- [x] failed main read does not create/save default player session
- [x] furniture inventory fails closed on read failure
- [x] placed furniture fails closed on read failure
- [x] garden fails closed on read failure
- [x] WonderDex fails closed on read failure
- [x] Shop explicitly rejects read-only sessions
- [x] placement explicitly rejects read-only sessions
- [x] read-only banner is player-facing and mobile-safe
- [x] health panel exposes main/inventory/furniture/garden/Dex failure flags
- [x] v1.2 economy integrity, seed economy, rate limits, and audit bus remain active
- [x] responsive premium UI has no invalid `Frame.PaddingTop`
- [x] responsive panel content is isolated from header/close layout
- [x] core HUD remains mobile-safe and shows canonical CarrotSeed
- [x] slow successful startup no longer times out onboarding/tutorial/inventory/furniture/garden into a false failure
- [x] incomplete tutorial with persisted progress resumes after rejoin instead of replaying the Welcome card
- [x] Bubbi Say Hi prompt waits for authoritative data state and critical-saves the milestone
- [x] tutorial completion critical-saves `WP_OnboardingComplete`
- [x] Android build preview uses own Pocket ground/cottage floor and mirrors server footprint validation
- [x] server placement owns vertical placement height; client cannot place furniture at arbitrary Y
- [x] tutorial guidance targets SHOP → Star Lamp → BUILD → owned furniture → PLACE
- [x] Treasure tutorial waypoint switches from Adventure Gate to a Treasure chest after entering Treasure Island
- [x] closed-test build includes health TEST panel; normal release build excludes it
- [x] registry remains disabled
- [x] `PublishAllowed = false`

## v31 Android first-10-minutes live script — REQUIRED
1. Fresh test account joins v31 and receives the Welcome card with fully visible `START MY POCKET`.
2. Tap `START MY POCKET`; tracker shows step 1/6 and Bubbi gets `NEXT • SAY HI` guidance.
3. Say Hi to Bubbi; exit/rejoin immediately. Welcome card must **not** return; tutorial resumes at the next unfinished objective.
4. Plant one carrot. Verify CarrotSeed decreases by exactly 1 and garden remains planted after rejoin.
5. Open SHOP from the tutorial pulse. Verify Star Lamp receives `BUY THIS`; buy once and verify Coins decrease exactly once.
6. Exit/rejoin before placing. Purchased Star Lamp must remain owned and tutorial must resume at BUILD/PLACE.
7. Open BUILD; owned furniture receives `SELECT`. Begin placement; `PLACE` pulses. Rotate/place on own Pocket ground and cottage floor. Preview/server must agree and furniture must not sink/float.
8. Exit/rejoin. Placed furniture must reappear relative to the newly assigned plot position.
9. Harvest when ready. Verify +12 Coins and +1 CarrotSeed exactly once.
10. Follow Adventure Gate guidance, enter Treasure Island, then verify waypoint moves to a chest. Collect one treasure; tutorial completes and completion survives immediate rejoin.
11. Open `TEST` during closed-test and confirm Data/Inventory/Furniture/Garden/WonderDex report healthy. No red runtime errors during the run.

## Live Roblox failure/recovery gate — REQUIRED
- [ ] normal DataStore availability loads exact prior Coins / Stars / CarrotSeed
- [ ] simulated/observed main DataStore read failure shows READ-ONLY banner
- [ ] main read failure does not grant fresh-player defaults over an existing account
- [ ] main read failure blocks Shop purchase
- [ ] main read failure blocks furniture placement
- [ ] main read failure prevents garden mutation/reward
- [ ] main read failure prevents WonderDex mutation
- [ ] leaving during main read failure creates no replacement/default save
- [ ] furniture-inventory read failure leaves old inventory untouched and blocks Shop/Build mutation
- [ ] placed-furniture read failure does not save an empty furniture list
- [ ] garden read failure does not save blank crop state
- [ ] WonderDex read failure does not save blank discovery state
- [ ] health panel identifies the exact subsystem that failed
- [ ] after DataStore service recovers, rejoin loads the original pre-failure data intact
- [ ] READ-ONLY banner disappears after a successful safe rejoin

## Normal runtime regression gate
- [ ] fresh player starts with 250 Coins / 5 Stars / 3 CarrotSeed before retention rewards
- [ ] plant consumes exactly 1 seed; harvest returns 1 seed + 12 Coins
- [ ] persistent/offline garden growth works across rejoin
- [ ] starter quest reward remains one-time across rejoins
- [ ] daily reward cannot duplicate on the same UTC day
- [ ] rapid Shop taps cannot double-charge
- [ ] rapid Place taps cannot duplicate furniture or consume inventory twice
- [ ] purchased unplaced furniture survives rejoin
- [ ] placed furniture survives rejoin on a different assigned plot slot
- [ ] 2–12 players receive unique plots and personal cottages
- [ ] Android BUILD preview matches server footprint validation
- [ ] first-session six-step tutorial completes and stays completed after rejoin
- [ ] Treasure Island independent multiplayer progress + 240s deadline + exact 120 Coins/1 Star reward
- [ ] WonderDex cannot be unlocked by client `DISCOVER`
- [ ] 20-minute 12-player session produces no red runtime errors

## Release rule
Closed-test publishing may update only the locked WONDERPOCKET Place. Do **not** enable `maps/registry.json` and do **not** set `GameConfig.QA.PublishAllowed = true` until every applicable live gate above passes.
