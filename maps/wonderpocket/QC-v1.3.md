# WONDERPOCKET QC — v1.3 Fail-Closed Data Safety

## Current closed-test baseline
- Place version: **45**
- Target: Universe `8805231520` → Place `124843214013484`
- Public release: **closed** (`PublishAllowed = false`)
- Registry: **disabled**
- v45 includes persistent tutorial resume, Android placement/UI polish, low-part Wonder Square ambience, state-driven Retention/Starter Quest/WonderDex startup, save-health fail-closed protection, first-journey runtime checklist/timing, gameplay-first compact HUD, focused placement mode, one-button Android landscape `MENU`, and tutorial guidance fallback that points to MENU whenever SHOP/BUILD is temporarily hidden.
- v42 focused placement mode hides the normal dock, top HUD, and TEST button while positioning furniture; only ROTATE / PLACE / CANCEL plus a compact tutorial tracker remain.
- v43 replaces the full-width top HUD with small identity/economy pills and reduces the normal Android landscape dock footprint.
- v44 collapses SHOP / DEX / BUILD / SOCIAL into one `MENU` button during normal short-landscape play. Tutorial SHOP/BUILD steps auto-expand the dock so first-time guidance remains discoverable.
- v45 hardens guidance against UI timing races: if the intended SHOP/BUILD action is not visible yet, the pulse moves to `MENU` with `OPEN MENU`, then switches to the intended action once visible.
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
- [x] banner also reacts to degraded main/inventory/furniture/garden/WonderDex save health
- [x] save-health guard freezes the session into `WP_DataReadOnly` after a persistence save-health failure is reported
- [x] Shop rejects purchases when main/inventory save health is degraded
- [x] Adventure Gate and Treasure rewards reject protected/read-only sessions
- [x] health panel exposes main/inventory/furniture/garden/Dex load and save status
- [x] health panel exposes first-journey milestones `S/B/P/Buy/Pl/H/T/C`
- [x] TEST button shows `TEST...` while loading, `TEST OK` when core subsystems are healthy, and `TEST !` when protected/read-only
- [x] first-session QA timer reads the target from master `GameConfig` rather than hardcoding it
- [x] completed clean-run timing records `WP_FirstJourneySeconds` and `WP_FirstJourneyWithinTarget`
- [x] v1.2 economy integrity, seed economy, rate limits, and audit bus remain active
- [x] responsive premium UI has no invalid `Frame.PaddingTop`
- [x] responsive panel content is isolated from header/close layout
- [x] core HUD remains mobile-safe and shows canonical CarrotSeed
- [x] short Android landscape top HUD is reduced to compact identity/economy pills
- [x] short Android landscape normal dock collapses to one `MENU` button outside guided SHOP/BUILD tutorial steps
- [x] opening MENU reveals SHOP / DEX / BUILD / SOCIAL; opening any panel or entering placement collapses/hides it again
- [x] tutorial SHOP/BUILD steps auto-expand the action dock so guidance never targets an inaccessible hidden action
- [x] tutorial guidance falls back to pulsing `MENU` if SHOP/BUILD is hidden during a timing race
- [x] placement mode hides top HUD, TEST button, and normal dock; only ROTATE / PLACE / CANCEL remain
- [x] slow successful startup no longer false-times-out onboarding/tutorial/inventory/furniture/garden/Retention/Starter Quest/WonderDex
- [x] `WP_TutorialStarted` is persisted in canonical main player data and critical-saved on first START
- [x] v31-and-earlier persisted milestones migrate into resumed tutorial state, including purchase-only progress after inventory resolves
- [x] incomplete tutorial resumes after rejoin instead of replaying the Welcome card
- [x] Bubbi Say Hi prompt waits for authoritative data state and critical-saves the milestone
- [x] tutorial completion critical-saves `WP_OnboardingComplete`
- [x] Android build preview uses own Pocket ground/cottage floor and mirrors server footprint validation
- [x] server placement owns vertical placement height; client cannot place furniture at arbitrary Y
- [x] tutorial guidance targets SHOP → Star Lamp → BUILD → owned furniture → PLACE
- [x] Treasure tutorial waypoint switches from Adventure Gate to a Treasure chest after entering Treasure Island
- [x] short Android screens hide bottom dock while modal panels are open and compact SHOP grid height
- [x] tutorial-time toast is moved below the objective tracker
- [x] closed-test TEST panel is resized for short Android screens
- [x] low-part Wonder Square decor adds paths, seating, stylized pocket trees, fountain heart, and `Build Your Little World` tagline without external assets
- [x] Adventure remote API does not grant Treasure Island rewards; chest system is the sole reward authority
- [x] closed-test build includes health TEST panel; normal release build excludes it
- [x] registry remains disabled
- [x] `PublishAllowed = false`

## v45 Android clean first-session timing run — REQUIRED
1. Use a fresh test account and join v45. `START MY POCKET` must be fully visible and TEST should move from `TEST...` to `TEST OK` after safe loading.
2. Tap `START MY POCKET` and complete the six objectives **without rejoining**: Bubbi → Plant → SHOP/Buy → BUILD/Place → Harvest → Treasure.
3. TEST panel journey bits must advance in order: `S/B/P/Buy/Pl/H/T/C`.
4. During SHOP/BUILD tutorial steps, the compact dock may auto-expand so the guided action remains visible. If it is temporarily hidden due to timing, guidance must pulse `MENU` with `OPEN MENU`, then switch to SHOP/BUILD after opening.
5. Outside guided SHOP/BUILD steps, normal Android landscape play should show one bottom `MENU` button instead of four persistent action buttons.
6. During placement, the top HUD, TEST button, and normal dock must be hidden; only ROTATE / PLACE / CANCEL and the compact tutorial tracker should remain.
7. SHOP guidance must highlight Star Lamp; BUILD guidance must highlight owned furniture; PLACE must pulse during placement.
8. Android placement preview and server placement must agree on own Pocket ground/cottage floor; furniture must not sink or float.
9. Treasure waypoint must switch from Adventure Gate to a chest after entering Treasure Island.
10. On completion, TEST must report the journey time against the master target `10:00`; target result should be evaluated as `ON TARGET` or `OVER TARGET` from the runtime measurement, not assumed.
11. No red runtime errors.

## v45 Android rejoin persistence run — REQUIRED
1. Fresh test account: START, then exit/rejoin before Say Hi. Welcome must not return; step 1/6 resumes.
2. Say Hi → rejoin. Next unfinished objective resumes.
3. Plant → rejoin. Crop state and CarrotSeed must persist.
4. Buy Star Lamp → rejoin before placement. Inventory and Coins must persist; tutorial resumes at BUILD/PLACE.
5. Place furniture → rejoin. Furniture must return relative to the newly assigned plot.
6. Harvest → verify exactly +12 Coins and +1 CarrotSeed.
7. Collect one Treasure → tutorial completion must survive immediate rejoin.
8. After tutorial completion, Android landscape normal play should return to the compact one-button MENU state.
9. Open TEST and confirm main/inventory/furniture/garden/WonderDex load/save states are healthy and the panel fits the Android viewport.

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
- [ ] any observed persistence save-health failure shows the READ-ONLY/protected banner
- [ ] after a save-health failure, new Shop/Build/Garden/Dex/Adventure reward mutations are blocked until rejoin
- [ ] health panel identifies the exact subsystem that failed
- [ ] after DataStore service recovers, rejoin loads the original last-safe data intact
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
