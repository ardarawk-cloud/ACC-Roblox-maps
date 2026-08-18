# WONDERPOCKET QC v0.9 — Closed-Test Experience

Status: CLOSED-TEST CANDIDATE / PUBLIC PUBLISH BLOCKED

Implemented:
- persistent first-session onboarding
- onboarding remote guarded by data-loaded state
- internal session telemetry (joins/current/peak/session timestamps)
- closed-test health panel for DataStore/remotes/plot/onboarding/player count
- all files remain under WONDERPOCKET-only build pipeline
- publish permission remains false in GameConfig

Runtime checks still required in Roblox:
1. Fresh account sees onboarding once; rejoin does not show it again.
2. DataStore load/save stays healthy after repeated reconnects.
3. 2–12 players receive isolated build plots.
4. Android BUILD controls remain usable with onboarding and health UI present.
5. Treasure Island gives one reward per player/session completion.
6. Wondi respawns correctly after reset and reconnect.
7. 20+ minute server run has no red runtime errors or runaway instance growth.
8. Economy and furniture persistence survive server migration/rejoin.

Do not enable public publish until runtime checks pass.
