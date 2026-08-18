# WONDERPOCKET QC v0.8 — Runtime Hardening

Status: CLOSED-TEST PREP / PUBLIC PUBLISH BLOCKED

## Hardened in code
- Player DataStore uses v2 schema.
- Get/Update operations retry up to 4 times with backoff.
- Autosave runs every 90 seconds for dirty player state.
- Save health and load state exposed as player attributes.
- Wondi respawns safely after character respawn/reconnect and active Wondi changes.
- Treasure Island uses per-player collection state.
- Treasure prompts remain multiplayer-safe and do not globally disappear after one player collects.
- Treasure completion reward is debounced per player session.
- Treasure rewards use canonical Coins/Stars attributes.
- Public publish remains disabled in config.

## Must be verified in Roblox runtime before public release
1. DataStore load/save/rejoin with real API Services enabled.
2. Forced server close and reconnect persistence.
3. 2–12 player plot allocation and cleanup.
4. Two players collect the same Treasure Island chest independently.
5. Treasure Island cannot reward twice in one session.
6. Wondi returns after Reset Character and reconnect.
7. Android BUILD controls: rotate/place/cancel and out-of-plot rejection.
8. Economy consistency after shop purchase, harvest, offline reward, adventure reward, and reconnect.
9. Runtime output contains no red errors for a 20-minute test session.

## Gate
Do not set `QA.PublishAllowed = true` until all runtime checks above pass.
