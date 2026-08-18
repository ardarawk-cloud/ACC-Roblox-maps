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
- Quests, persistent WonderDex, daily/weekly retention
- Low-cost cosmetic monetization, no pay-to-win

## Current build
**v1.3.0 — Fail-Closed Data Safety**

First-session loop:
1. Say hi to your Wondi
2. Plant a carrot
3. Buy one furniture item
4. Place it inside your own Pocket plot
5. Harvest your carrot
6. Enter Treasure Island and find treasure

Current hardening includes canonical `Coins` / `Stars` / `CarrotSeed`, DataStore schema v4, revision-safe and critical saves, rate-limited Shop/Build transactions, centralized economy audit, persistent/offline garden growth, personal plots/cottages, plot-relative furniture, server-authoritative Treasure Island and WonderDex, and responsive Android-first UI.

### Fail-closed data safety
If a critical DataStore read fails after retries, WONDERPOCKET does **not** replace that subsystem with blank/default data and then save over the player's previous progress. Main player data becomes read-only, secondary persistent systems stop mutation, Shop/Build are blocked, and the player receives a visible READ-ONLY warning until a safe rejoin succeeds.

Protected fail-closed stores/state:
- main player data
- furniture inventory
- placed furniture
- garden plot state
- WonderDex

## Roblox target
- Universe ID: `8805231520`
- Place ID: `124843214013484`

## Publish safety
This branch remains intentionally non-public. `maps/registry.json` keeps WONDERPOCKET disabled and `GameConfig.QA.PublishAllowed` remains `false`.

A dedicated closed-test publisher is locked to the WONDERPOCKET branch and target IDs and requires the exact confirmation string `WONDERPOCKET:8805231520:124843214013484`. Normal pushes build + QC only and do not publish.

Live runtime checks before release are tracked in `QC-v1.3.md`, including DataStore outage/recovery protection, exact economy/seed persistence, Shop/Build spam tests, 2–12 player plot isolation, Android UI/BUILD behavior, tutorial persistence, timed multiplayer Treasure Island, WonderDex authority, and a 20-minute multiplayer runtime error pass.
