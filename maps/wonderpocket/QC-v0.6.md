# WONDERPOCKET QC v0.6 — CLOSED TEST CANDIDATE

Status: CLOSED-TEST CANDIDATE / NOT CLEARED FOR PUBLIC PUBLISH

## PASS — CODE LAYER
- WONDERPOCKET-only branch isolation remains active.
- Player-owned build plots generated server-side.
- Furniture placement rejects coordinates outside the player's assigned plot.
- Furniture placement snaps to 1-stud grid and 90-degree rotation.
- Furniture layout persists through WONDERPOCKET_Furniture_v1 DataStore.
- Mobile Build panel is wired to furniture ghost preview.
- Mobile controls include ROTATE / PLACE / CANCEL.
- Ghost preview changes cyan when valid and red when outside own plot.
- Existing retention systems remain: offline reward, daily reward, daily/weekly quests, shop rotation.
- Existing Wondi, gardening, WonderDex, Treasure Island and social layers remain in project scope.

## REQUIRED BEFORE PUBLIC PUBLISH
1. Live Roblox DataStore save/load test on target Universe/Place.
2. Two-player+ multiplayer plot ownership collision test.
3. Android placement test for BUILD > furniture > rotate/place/cancel.
4. Verify all required scripts are injected by WONDERPOCKET publishing pipeline, not BBYA injector assumptions.
5. Verify target Place is backed up/approved for reuse before overwriting anything legacy.
6. Full runtime error log pass in Roblox Studio/live closed server.

## HARD RULE
Do not publish to public users until all REQUIRED checks pass.
Do not touch BBYA, Mountain Social Adventure, ACC Avatar Catalog, or any other map from this WONDERPOCKET branch/workflow.
