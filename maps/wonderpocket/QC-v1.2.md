# WONDERPOCKET QC — v1.2 Closed-Test Ops + Economy Integrity

## Code-side gate
- [x] main player data schema v4
- [x] canonical `Coins` / `Stars` / `CarrotSeed`
- [x] starter player receives 3 canonical CarrotSeed from saved main data
- [x] inventory folder is mirror-only, not a second authority
- [x] planting consumes exactly 1 CarrotSeed
- [x] harvesting returns exactly 1 CarrotSeed + 12 Coins
- [x] garden state persists with absolute `readyAt`
- [x] garden joins critical-save bus
- [x] Shop has per-player transaction lock + 0.25s rate limit
- [x] Placement has per-player transaction lock + 0.20s rate limit
- [x] placement state requests are throttled
- [x] Shop transactions emit audit metadata (`WP_EconTxnSeq`, last action/item/delta)
- [x] furniture inventory participates in critical saves
- [x] furniture placement participates in critical saves
- [x] WonderDex remains persistent + server-authoritative
- [x] Treasure Island remains server-authoritative + 240s deadline
- [x] dedicated closed-test publisher target remains locked
- [x] registry remains disabled
- [x] `PublishAllowed = false`

## Live Roblox runtime gate — REQUIRED
- [ ] fresh player starts with exactly 250 Coins / 5 Stars / 3 CarrotSeed before retention rewards
- [ ] planting once changes seed count 3 → 2
- [ ] harvesting that crop changes seed count 2 → 3 and adds exactly 12 Coins
- [ ] plant → leave → rejoin before maturity keeps crop growing and seed count unchanged
- [ ] plant → leave → rejoin after maturity allows immediate harvest
- [ ] CarrotSeed count survives multiple rejoins exactly
- [ ] player cannot plant at 0 CarrotSeed
- [ ] rapid repeated plant prompt cannot consume more than one seed for one empty plot transition
- [ ] rapid repeated harvest prompt cannot award duplicate Coins/seeds
- [ ] rapid Shop taps cannot double-charge or add duplicate item beyond accepted purchases
- [ ] Shop BUSY/RATE_LIMITED responses do not corrupt balance or inventory
- [ ] rapid Place taps cannot duplicate furniture or consume inventory twice
- [ ] placement BUSY/RATE_LIMITED responses leave inventory unchanged
- [ ] transaction sequence increases for accepted Shop purchases
- [ ] health panel shows correct Coins / Stars / seeds / last transaction
- [ ] starter quest rewards exactly once across rejoins
- [ ] daily retention reward cannot duplicate on same UTC day
- [ ] purchased unplaced furniture survives rejoin
- [ ] placed furniture survives rejoin even if player receives another plot slot
- [ ] furniture footprint crossing plot border is rejected
- [ ] 2–12 players receive unique plots and personal cottages
- [ ] Android BUILD preview matches server placement acceptance
- [ ] Wondi Say Hi works after spawn/reset/rejoin
- [ ] first-session tutorial completes all six real objectives
- [ ] Treasure Island simultaneous players keep independent progress
- [ ] Treasure Island second run starts at 0/5
- [ ] Treasure Island stops accepting treasure after 240 seconds
- [ ] Treasure Island gives exactly 120 Coins + 1 Star per completed run
- [ ] WonderDex cannot be unlocked by client `DISCOVER`
- [ ] 20-minute 12-player session produces no red runtime errors

## Release rule
Closed-test publishing may update only the locked WONDERPOCKET Place for testing. Do **not** enable `maps/registry.json` and do **not** set `GameConfig.QA.PublishAllowed = true` until every live runtime gate above passes.
