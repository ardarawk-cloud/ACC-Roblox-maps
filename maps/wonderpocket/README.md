# WONDERPOCKET

**Build Your Little World.**

Primary genre: Simulation  
Positioning: Social Life & Collection Adventure

## Core pillars
- Personal Pocket World + owned player plots
- Wondi companion collection and interaction
- Persistent gardening + offline growth
- Home decoration and persistent furniture
- Wonder Square social hub
- Mini Adventures, starting with Treasure Island
- Quests, WonderDex, daily/weekly retention
- Low-cost cosmetic monetization, no pay-to-win

## Current build
**v1.1.0 — Release-Candidate Hardening**

First-session loop:
1. Say hi to your Wondi
2. Plant a carrot
3. Buy one furniture item
4. Place it inside your own Pocket plot
5. Harvest your carrot
6. Enter Treasure Island and find treasure

v1.1 hardening adds player-data schema v3, revision-safe saving, critical-save flushing, persistent starter-quest reward state, canonical retention state, persistent garden growth across rejoins, plot-relative furniture persistence, full-footprint plot validation, matching Android ghost validation, and a server-enforced 240-second Treasure Island session.

## Roblox target
- Universe ID: `8805231520`
- Place ID: `124843214013484`

## Publish safety
This branch remains intentionally non-publishing. `maps/registry.json` keeps WONDERPOCKET disabled and `GameConfig.QA.PublishAllowed` remains `false` until live Roblox runtime checks pass.

Required live checks before publish are tracked in `QC-v1.1.md`, including DataStore rejoin, persistent/offline garden growth, one-time quest reward integrity, 2–12 player plot isolation, Android BUILD controls, save-race stress, timed Treasure Island, Wondi reset/rejoin, first 10-minute tutorial, and a 20-minute multiplayer runtime error pass.
