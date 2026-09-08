# MOUNT BBYA — PROJECT AUTHORITY v2.0

Status: ACTIVE / FULL MAP RESET
Owner / Final Authority: Arda
Reset order date: 8 September 2026

## Latest explicit override
The previous Environment Realism Phase 1 restriction (`Spawn -> CP1 only`, CP2+ forbidden) is RETIRED.

Arda explicitly ordered the existing MOUNT BBYA map to be reset and replaced by the supplied **Visualizer Map Gunung Roblox Realistis WITA** project. The active build scope is now the complete route:

`Spawn Desa -> CP1 -> CP2 -> ... -> CP20 / Summit 3,142 MDPL`

This document supersedes the old Phase 1 scope section.

## Final target identity
- Project: MOUNT BBYA / Gunung BBYA
- Universe ID: `4187755690`
- Place ID: `11832985967`
- Registry key: `mount-bbya`
- Source path: `maps/mount-bbya`

## Forbidden target
Mountain Social remains a separate PAUSED / DO NOT TOUCH project:
- Universe ID: `10744139279`
- Place ID: `82661754996018`

Never publish MOUNT BBYA source to Mountain Social.

## Active architecture v7.0
Source authority: `mount-bbya.phase1v67.environment.server.lua` retained at its existing path for deployment compatibility, but its contents are now the **FULL MAP RESET AUTHORITY v7.0**.

The builder is idempotent and performs a clean world rebuild on startup:
1. destroy prior generated MOUNT BBYA roots;
2. clear Roblox Terrain;
3. construct scaled terrain following all 21 visualizer locations;
4. create village spawn and agricultural terraces;
5. construct a guaranteed walkable route through CP1-CP20;
6. create crater lake around CP14/CP15;
7. create zoned vegetation from foothill to summit;
8. create physical checkpoint shelters and metadata for all CPs;
9. enable checkpoint save/heal/respawn using corrected DataStore pcall handling;
10. create CP20 summit monument, 3,142 MDPL photo seat and Indonesian flag;
11. run realtime WITA lighting at UTC+8.

## Checkpoint architecture
- Spawn: 120 MDPL
- CP1: 280 MDPL
- CP2: 410 MDPL
- CP3: 560 MDPL
- CP4: 720 MDPL
- CP5: 890 MDPL
- CP6: 1,050 MDPL
- CP7: 1,210 MDPL
- CP8: 1,390 MDPL
- CP9: 1,560 MDPL
- CP10: 1,750 MDPL
- CP11: 1,920 MDPL
- CP12: 2,100 MDPL
- CP13: 2,280 MDPL
- CP14: 2,320 MDPL
- CP15 Danau Agung: 2,330 MDPL
- CP16: 2,500 MDPL
- CP17: 2,680 MDPL
- CP18: 2,850 MDPL
- CP19: 3,010 MDPL
- CP20 Summit: 3,142 MDPL

## Current source status
- Baseline retired: v6.7 Spawn->CP1 single-environment authority
- New authority: v7.0.0 FULL MAP RESET
- CP2+ is ALLOWED and part of active scope
- Full-map publishing is authorized by Arda's explicit reset instruction

## Verification rule
A source commit is not automatically LIVE. A LIVE claim still requires a successful Roblox publish receipt/version for Universe `4187755690` / Place `11832985967` plus runtime evidence.
