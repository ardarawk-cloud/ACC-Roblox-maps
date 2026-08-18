# BBYA SOCIAL HUB — V5.3 ZONE INDEX

Source of truth for architecture inspection, bug fixing, and experience hierarchy.

## Experience hierarchy — HARD LOCK

BBYA is a **SOCIAL HUB first**. The club/dance hall is only one facility inside the venue.

Primary experience order:
1. Arrive and be seen.
2. Meet, talk, hang out, show outfits, take photos.
3. Choose a facility: Social Bar, Chill/Conversation Lounge, Club/Dance, VIP/Private Social, Rooftop Pool/Sky Bar/Cabanas/View Deck.
4. No circulation or signage should imply that every visitor must pass through the club to enjoy BBYA.
5. The visual identity at the entrance is **BBYA SOCIAL HUB**, not “nightclub”.

| Code | Zone | Level | Source file |
|---|---|---|---|
| A1 | Exterior / Spawn | Ground | `A1-exterior-spawn.lua` |
| A2 | Main Entrance / Open Social Facade | Ground | `A2-entrance-facade.lua` |
| A3 | Social Commons / Lobby | Ground | `A3-lobby.lua` |
| A4 | Club Facility / Dance Hall | Ground | `A4-main-club.lua` |
| A5 | Social Bar | Ground | `A5-bar.lua` |
| A6 | Chill / Conversation Lounge | Ground | `A6-chill.lua` |
| B1 | West Stair Core | Ground → VIP → Roof | `B1-west-stair.lua` |
| B2 | East Stair Core | Ground → VIP → Roof | `B2-east-stair.lua` |
| B3 | Lift Core | Ground → VIP → Roof | `B3-lift.lua` |
| C1 | VIP West Social Mezzanine | VIP | `C1-vip-west.lua` |
| C2 | VIP East Social Mezzanine | VIP | `C2-vip-east.lua` |
| C3 | Queen / VIP Private Social | VIP | `C3-queen-bridges.lua` |
| D1 | Rooftop Arrival / Circulation | Roof | `D1-rooftop-arrival.lua` |
| D2 | Infinity Pool / Pool Social | Roof | `D2-rooftop-water-zone.lua` |
| D3 | Sky Bar | Roof | `D3-skybar.lua` |
| D4 | Rooftop Chill / Sunset Social | Roof | `D4-rooftop-chill.lua` |
| D5 | Cabana Social Zones | Roof | `D5-cabana-zones.lua` |
| D6 | Photo / City View Deck | Roof | `D6-photo-view.lua` |
| S1 | Service / Restroom / Backstage | Ground + VIP | `S1-service.lua` |

## Inspection rule

1. Every geometry object must have `BBYAZoneCode` and `BBYAZoneName` attributes.
2. The current zone code is shown in the top HUD; oversized in-world inspection boards stay disabled.
3. A screenshot issue is assigned to a zone code before code changes are made.
4. Fix only that zone source file unless the issue is explicitly a shared-core or circulation dependency.
5. `00-core.lua` contains shared helpers only; zone geometry must not be added there.
6. `99-finalize.lua` contains status/validation attributes only; no geometry.
7. The injector concatenates modular architecture files into one Roblox server Script, preventing parallel builders and layer races.
8. The TP panel is an inspection helper only. `97-inspection-nav.lua` owns explicit safe landing coordinates for A1–A6, B1–B3, C1–C3, D1–D6 and S1. Never derive QC teleports from furniture positions.
9. UI remains one LocalScript shell. Top drawers open DOWN, left drawers open RIGHT, and right drawers open LEFT.
10. Facility naming in HUD/signage must preserve the Social Hub hierarchy: A4 is `CLUB FACILITY`, not the identity of the whole venue.

## Current build lock

V5.3 is in premium master-build phase. Furniture, lighting, music, camera, social systems and monetization shells are allowed, but they must preserve the coded zone boundaries, entrances, stair/lift cores, inspection addresses, and the Social Hub-first hierarchy above.
