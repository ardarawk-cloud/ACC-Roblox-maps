# BBYA SOCIAL HUB — V5.2 ZONE INDEX

Source of truth for architecture inspection and bug fixing.

| Code | Zone | Level | Source file |
|---|---|---|---|
| A1 | Exterior / Spawn | Ground | `A1-exterior-spawn.lua` |
| A2 | Main Entrance / Facade | Ground | `A2-entrance-facade.lua` |
| A3 | Lobby / Orientation | Ground | `A3-lobby.lua` |
| A4 | Main Club / Dance Hall | Ground | `A4-main-club.lua` |
| A5 | Bar Room | Ground | `A5-bar.lua` |
| A6 | Chill Lounge | Ground | `A6-chill.lua` |
| B1 | West Stair Core | Ground → VIP → Roof | `B1-west-stair.lua` |
| B2 | East Stair Core | Ground → VIP → Roof | `B2-east-stair.lua` |
| B3 | Lift Core | Ground → VIP → Roof | `B3-lift.lua` |
| C1 | VIP West Mezzanine | VIP | `C1-vip-west.lua` |
| C2 | VIP East Mezzanine | VIP | `C2-vip-east.lua` |
| C3 | Queen / VIP Bridges | VIP | `C3-queen-bridges.lua` |
| D1 | Rooftop Arrival / Circulation | Roof | `D1-rooftop-arrival.lua` |
| D2 | Rooftop Water / Pool Footprint | Roof | `D2-rooftop-water-zone.lua` |
| D3 | Sky Bar Program | Roof | `D3-skybar.lua` |
| D4 | Rooftop Chill / Sunset Social | Roof | `D4-rooftop-chill.lua` |
| D5 | Cabana Program Zones | Roof | `D5-cabana-zones.lua` |
| D6 | Photo / View Deck | Roof | `D6-photo-view.lua` |
| S1 | Service / Restroom / Backstage | Ground + VIP | `S1-service.lua` |

## Inspection rule

1. Every geometry object must have `BBYAZoneCode` and `BBYAZoneName` attributes.
2. Greybox inspection tags display `[CODE] ZONE NAME` in-world.
3. A screenshot issue is assigned to a zone code before code changes are made.
4. Fix only that zone source file unless the issue is explicitly a shared-core or circulation dependency.
5. `00-core.lua` contains shared helpers only; zone geometry must not be added there.
6. `99-finalize.lua` contains status/validation attributes only; no geometry.
7. The injector concatenates all modular files into one Roblox server Script, preventing parallel builders and layer races.

## Architectural lock

No decor/furniture/UI/music/monetization is allowed in this V5.2 architecture review runtime. Mood/material/decor phases are added only after circulation approval and must preserve the zone boundaries and access clearances defined here.
