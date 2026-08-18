# WONDERPOCKET QC v0.5

Status: PRE-PUBLISH / BRANCH ONLY

## Core checks
- Project isolated from BBYA and other Roblox projects.
- No live publish performed from this branch.
- Coins/Stars economy remains non-pay-to-win.
- Furniture placement is server-authoritative and ownership-gated.
- Placement cap exists to avoid unbounded world clutter.
- Shop rotation is deterministic by UTC day.
- Offline reward has an 8-hour cap.
- Daily/weekly state uses server time.
- Wondi emotes are allowlisted and rate-limited.
- Treasure Island rewards are bounded.

## Known pre-publish tasks
- Validate DataStore calls in a Roblox test universe.
- Wire BUILD panel to WP_StartBuildPreview bind/event path.
- Add touch buttons for rotate/place/cancel on mobile build preview.
- Persist placed furniture transforms and inventory changes.
- Validate all UI scaling on phone/tablet aspect ratios.
- Add server-side distance/plot ownership validation before final placement.
- Run live Roblox asset/audio permission checks before launch.
- Build generated place.rbxlx from source and inspect visually before publish.

## Gate
Do not publish until known pre-publish tasks are resolved or explicitly waived for an internal closed test.
