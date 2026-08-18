# WONDERPOCKET

**Build Your Little World.**

Primary genre: Simulation  
Positioning: Social Life & Collection Adventure

## Core pillars
- Personal Pocket World + owned player plots
- Wondi companion collection and interaction
- Gardening and retention loops
- Home decoration and persistent furniture
- Wonder Square social hub
- Mini Adventures, starting with Treasure Island
- Quests, WonderDex, daily/weekly retention
- Low-cost cosmetic monetization, no pay-to-win

## Current build
**v1.0.0 — Closed-Test Build Candidate**

First-session loop:
1. Say hi to your Wondi
2. Plant a carrot
3. Buy one furniture item
4. Place it inside your own Pocket plot
5. Harvest your carrot
6. Enter Treasure Island and find treasure

Runtime hardening includes canonical `Coins` / `Stars`, player DataStore retry + autosave, furniture save/load, purchased furniture inventory persistence, plot-bound placement validation, Android Place/Rotate/Cancel controls, onboarding persistence, test telemetry, and closed-test health UI.

## Roblox target
- Universe ID: `8805231520`
- Place ID: `124843214013484`

## Publish safety
This branch remains intentionally non-publishing. `maps/registry.json` keeps WONDERPOCKET disabled and `GameConfig.QA.PublishAllowed` remains `false` until live Roblox runtime checks pass.

Required live checks before publish:
- DataStore save/rejoin
- purchased furniture inventory rejoin
- furniture placement rejoin
- 2–12 player plot ownership/isolation
- Android BUILD controls
- first 10-minute tutorial loop
- Treasure Island multiplayer/reset
- Wondi respawn/rejoin
- 20-minute runtime with no red errors
