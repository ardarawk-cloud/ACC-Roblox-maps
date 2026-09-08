# AEROCLUB HANGAR — MASTER GDD & TECHNICAL BLUEPRINT v1.0

Status: ACTIVE / RESET FROM ZERO / LAB ONLY
Owner / final authority: Arda

This document supersedes every previous Hangar Exclusive Club foundation, v7/v8/v9/v10 runtime, visual fallback, geometry authority, laser/no-laser lock, and publish workflow for the rebuilt experience.

## Release discipline
- Build and publish to TEST LAB first.
- Visual/runtime QC must PASS before any live publish.
- No legacy Hangar geometry or scripts may be mounted in the AeroClub build.
- No primitive fallback is allowed to masquerade as final mesh art.
- Live Hangar target remains untouched until explicit owner approval.

Current targets:
- TEST LAB Universe: 10762005984
- TEST LAB Place: 124607344716828
- Existing LIVE Hangar Universe: 10745364913
- Existing LIVE Hangar Place: 76001567401911

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
