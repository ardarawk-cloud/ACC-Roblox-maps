# WONDERPOCKET QC — v1.1 Release-Candidate Hardening

## Code-side gate
- [x] Data schema v3 with in-place migration from earlier player data
- [x] revision-safe main player save loop
- [x] critical-save bus for reward/purchase/placement transactions
- [x] starter quest completion + reward flag persisted
- [x] retention day/week state moved onto canonical player data
- [x] garden plot state persists by absolute `readyAt`
- [x] garden continues growing while player is offline
- [x] garden save health exposed to closed-test UI
- [x] furniture inventory save loop revision-safe
- [x] furniture placement save loop revision-safe
- [x] furniture position stored relative to assigned Pocket plot
- [x] full furniture footprint validated inside owner plot
- [x] mobile ghost preview mirrors full-footprint validation
- [x] personal Starter Cottage follows player plot assignment
- [x] WonderDex is persistent and server-authoritative
- [x] WonderDex client `DISCOVER` path cannot unlock entries
- [x] WonderDex follows verified Wondi/biome/harvest/furniture/adventure state
- [x] Treasure Island progress/reward remains server-authoritative
- [x] Treasure Island hard deadline = 240 seconds
- [x] critical adventure rewards request immediate save
- [x] dedicated WONDERPOCKET closed-test publisher locks Universe `8805231520` / Place `124843214013484`
- [x] closed-test publish requires exact confirmation `WONDERPOCKET:8805231520:124843214013484`
- [x] closed-test publisher requires branch `agent/wonderpocket-target`
- [x] closed-test publishing does not temporarily enable the registry
- [x] automatic branch pushes build/QC only and never publish
- [x] WONDERPOCKET remains isolated from BBYA/a-club tokens
- [x] registry remains disabled
- [x] `PublishAllowed = false`

## Live Roblox runtime gate — REQUIRED
- [ ] fresh join gets exactly 250 Coins / 5 Stars before retention rewards
- [ ] earn/spend Coins → leave → rejoin preserves exact balance
- [ ] starter quest rewards only once across multiple rejoins
- [ ] daily reward cannot be claimed twice on same UTC day
- [ ] plant carrot → leave before 180s → rejoin after maturity → harvest is available
- [ ] garden crop state survives normal leave/rejoin
- [ ] purchased but unplaced furniture survives rejoin
- [ ] placed furniture survives rejoin at correct relative location/rotation even when assigned a different plot slot
- [ ] furniture touching plot edge is rejected if any part of its footprint crosses boundary
- [ ] two players cannot place furniture on each other's plots
- [ ] 12-player plot allocation has no duplicate owner slots
- [ ] personal cottage/garden/decor stay inside each player's plot
- [ ] rapid repeated Shop taps do not double-charge or corrupt inventory
- [ ] rapid Place taps do not duplicate furniture or lose inventory
- [ ] Android BUILD preview matches server acceptance at plot edges
- [ ] Wondi Say Hi works after spawn and character reset
- [ ] first-session tutorial completes all six real objectives
- [ ] onboarding does not return after completed rejoin
- [ ] WonderDex starts with Bubbi + Meadow Pocket only on a fresh account
- [ ] harvesting first carrot permanently discovers Carrot
- [ ] buying/placing furniture permanently discovers the correct furniture ID
- [ ] Treasure Island completion permanently discovers its badge
- [ ] forged client `WonderDex DISCOVER` event does not unlock anything
- [ ] WonderDex discoveries survive leave/rejoin
- [ ] Treasure Island chest progress is independent for simultaneous players
- [ ] Treasure Island second run starts at 0/5
- [ ] Treasure Island stops accepting treasure after 240 seconds
- [ ] Treasure Island completion gives exactly 120 Coins + 1 Star per completed run
- [ ] manual closed-test publish refuses any confirmation string except the locked target string
- [ ] closed-test publish updates only Universe `8805231520` / Place `124843214013484`
- [ ] closed-test publish does not change Roblox public/private access settings
- [ ] 20-minute 12-player server produces no red runtime errors

## Release rule
Do **not** enable WONDERPOCKET in `maps/registry.json` and do **not** set `GameConfig.QA.PublishAllowed = true` until every live runtime gate above passes.
