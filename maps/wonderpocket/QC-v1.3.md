# WONDERPOCKET QC — v1.3 Fail-Closed Data Safety

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
- [x] registry remains disabled
- [x] `PublishAllowed = false`

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
