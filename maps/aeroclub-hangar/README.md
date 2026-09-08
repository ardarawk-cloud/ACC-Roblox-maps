# HANGAR — MASTER GDD & TECHNICAL BLUEPRINT v1.2

Status: ACTIVE / MAIN HANGAR DEVELOPMENT
Owner / final authority: Arda
Continuation authority: `maps/aeroclub-hangar/HANGAR-HANDOFF-v1.1.md`

## NAMING LOCK
- Official project / experience name: **HANGAR**.
- Do not use "AeroClub" as the project name in user-facing discussion or documentation.
- Legacy internal identifiers containing `aeroclub-hangar` may remain temporarily only to avoid breaking branch/path/workflow references.
- Continuation command: **HANGAR START**.

This document supersedes every previous Hangar Exclusive Club foundation, v7/v8/v9/v10 runtime, visual fallback, geometry authority, and old publish workflow for the rebuilt experience.

## Release discipline
- Main HANGAR is now the active target by owner directive; do not use the old BBYA Test Lab for HANGAR.
- One problem = one root cause. Do not stack rescue/failsafe scripts as the production architecture.
- Visual/runtime QC must be owner-verified in-game before PASS.
- No legacy Hangar geometry or scripts may be mounted in the HANGAR build.
- No primitive fallback may be presented as final mesh art.
- If runtime asset insertion is unreliable, bake/import the MeshParts directly into the published place artifact instead of adding more runtime rescue layers.

Current LIVE target:
- Universe: 10745364913
- Place: 76001567401911

## Concept lock
Luxury commercial/business-jet hangar converted into a cyberpunk-industrial social club. Partially open steel hangar door reveals a starry night exterior. Interior uses polished concrete PBR, Future lighting, subtle volumetric fog, moving-head/spotlight/laser show equipment, and audio-reactive neon accents.

## Layout lock
Outdoor/front: classic-car display, hypercar display, Corner Shop UGC kiosk, outdoor photobooth, steel hangar gate, curved donor LED board, top-3 donor statues.

Indoor: perimeter skateboard/hoverboard track, AFK baggage conveyor, indoor photobooth, main dance floor, central private jet. Jet interior is VIP lounge. Left wing carries DJ booth/lighting control; right wing carries Lead Dancer stage.

## Role lock
Owner/Admin: master server controls. DJ: DJ/effects panel. Lead: choreography speed control. Media: cinematic/freecam controls. Regular player: filtered custom title.

## Social systems
Sync dance, carry, in-game avatar editing, profile viewer, skateboard/hoverboard, money gun, glow sticks, AFK baggage ride.

## Monetization
Donation leaderboard + top-3 avatar statues, global shoutout developer product, donation notification/confetti, Corner Shop purchase prompts, VIP gamepass for jet lounge/tag/chat/aura.

Developer Product IDs, VIP GamePass ID, UGC asset IDs, staff UserIds/Group ranks, and approved audio/dance asset IDs are configuration data and MUST NOT be fabricated.

## Roblox hierarchy
Workspace/{Environment,InteractiveZones,LightingEquipment,Statues}
ReplicatedStorage/{Network,Modules,Assets}
ServerScriptService/{CoreServer,Systems,Security}
StarterPlayer/StarterPlayerScripts/Controllers
StarterGui/MainHUD

## Required network contract
- UpdateTitleEvent
- ChangeLeadSpeedEvent
- TriggerDJEffectEvent
- CarryRequestEvent

Server remains authoritative for permissions, filtering, carry validation, purchases, donation data, and effect control.

## Current phase lock
ENVIRONMENT RUNTIME ROOT-CAUSE FIX.

Do not proceed to feature systems or polish until the actual HANGAR environment is visibly present in the published Main Hangar and Arda verifies it in-game.
