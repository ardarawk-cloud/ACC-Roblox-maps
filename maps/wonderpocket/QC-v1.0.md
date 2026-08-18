# WONDERPOCKET QC — v1.0 Closed-Test Build Candidate

## Code-side gate
- [x] WONDERPOCKET isolated branch/workflow
- [x] registry remains disabled
- [x] public publish flag remains false
- [x] foreign-map token guard
- [x] canonical economy uses `Coins` + `Stars`
- [x] gardening rewards use saved economy
- [x] starter quest rewards use saved economy
- [x] retention waits for player data before rewards
- [x] shop uses saved economy
- [x] purchased furniture inventory persists
- [x] furniture placement persists relative to assigned Pocket plot
- [x] placement restricted to owner plot
- [x] every assigned plot receives its own Starter Cottage
- [x] obsolete global Starter Cottage removed
- [x] Android Place / Rotate / Cancel controls
- [x] first-session objective tracker
- [x] Wondi meet interaction
- [x] Adventure Gate activates Treasure Island
- [x] Treasure Island state resets per run
- [x] Treasure rewards are server-authoritative
- [x] legacy client onboarding-complete remote removed
- [x] closed-test health panel includes player/inventory/furniture save health

## Live Roblox runtime gate — REQUIRED
- [ ] DataStore fresh join → earn/spend → leave → rejoin
- [ ] purchased but unplaced furniture survives rejoin
- [ ] placed furniture survives rejoin at correct relative position/rotation
- [ ] placed furniture follows the player if a rejoin assigns a different plot slot
- [ ] personal Starter Cottage appears only on the owner's assigned plot
- [ ] two players cannot place furniture on each other's plots
- [ ] 12-player plot allocation has no duplicate owner slots
- [ ] Android BUILD preview follows center aim and buttons work
- [ ] Wondi Say Hi prompt works after spawn and character reset
- [ ] first-session tutorial completes all six real objectives
- [ ] onboarding does not return after completed rejoin
- [ ] Treasure Island allows independent chest collection for multiple players
- [ ] entering Treasure Island a second time resets chest progress correctly
- [ ] spoofed Adventure `START` / `TREASURE` client events produce no rewards
- [ ] Coins/Stars remain consistent across HUD, Shop, Garden, Quest, Retention, Adventure
- [ ] 20-minute server session produces no red runtime errors

## Release rule
Do **not** set `PublishAllowed = true` and do **not** enable WONDERPOCKET in `maps/registry.json` until all live runtime checks above pass.
