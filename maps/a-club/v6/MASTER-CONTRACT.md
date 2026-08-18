# BBYA SOCIAL HUB — CLEAN REBUILD MASTER CONTRACT

Status: SOURCE OF TRUTH after owner reset on 2026-08-19. The old map geometry was rejected and the repository place base was intentionally cleaned. Live Roblox remains untouched until the new build passes QC and owner inspection.

## 1. PRODUCT IDENTITY
BBYA is a premium SOCIAL HUB first. Club/dance is one major attraction, not the entire product.
Primary reasons to visit: hangout, conversation, outfit/show-off, photo/camera, social bar, chill, VIP/private social, rooftop lifestyle, pool party, and club/dance.

## 2. OWNER VISUAL REFERENCE LOCK
The first owner-supplied concept image is the primary physical architecture/composition reference.
The venue must read as one layered nightlife/social complex:
- left multi-level club/social wing with visible glass/neon tiers;
- central social/dance activity;
- visibly legible VIP destination on the right;
- upper rooftop/infinity-pool terrace;
- foreground BBYA Queen and Support/Top Supporter landmarks;
- palms, premium night lighting, and city depth.

The second owner image is the Support/Sawer UI reference.
The third owner image is the Music/DJ UI reference.
UI references do not override physical circulation or architecture.

## 3. RESET RULE
Archived `maps/a-club/v5/` and `maps/a-club/v6/` implementation modules are NOT runtime authority for the clean rebuild.
The fresh runtime authority is only:
- `maps/a-club/place.rbxlx` as the clean blank base;
- `maps/a-club/rebuild/00-core.lua`;
- `maps/a-club/rebuild/10-architecture.lua`;
- `maps/a-club/rebuild/20-furnishing.lua`;
- `maps/a-club/rebuild/30-lighting.lua`;
- `maps/a-club/rebuild/40-runtime.server.lua`;
- `maps/a-club/rebuild/50-qc.server.lua`;
- `scripts/assemble-bbya-v6-preview.js` as the preview assembler.

No old geometry, old UI stack, or patch-stack runtime may be reintroduced into assembly without explicit owner approval.

## 4. PHYSICAL ZONES
01 Arrival Plaza
02 Social Atrium
03 Main Club / Dance Floor / DJ Stage
04 Left Social Mezzanines
05 VIP Wing
06 Rooftop Infinity Pool / Pool DJ / Cabanas
07 Queen + Support Court
08 City Backdrop

All playable levels must be real and reachable. No fake decorative floor that visually promises an inaccessible destination.

## 5. ARCHITECTURE
Architecture is built from a clean coordinate composition, not by stacking patches over rejected geometry.
The hero read from spawn must make the reference hierarchy obvious: LEFT CLUB + CENTER SOCIAL + RIGHT VIP + UPPER POOL.
Circulation, stairs, landings, safety rails, and avatar clearance take priority over decoration.

## 6. CLUB BENCHMARK
Main club must contain a real dance floor, raised DJ/stage, LED/show-light wall, side social seating, and bright avatar fill lighting.
It may use energetic pink/cyan show lighting but cannot turn every other social zone into the same visual language.

## 7. VIP BENCHMARK
VIP is a premium lounge destination under/adjacent to the upper resort terrace.
Use warm hospitality lighting, glass frontage, lounge groups, bar furniture, and restrained neon accents.

## 8. ROOFTOP BENCHMARK
Rooftop is tropical luxury, not a duplicate indoor club.
Required physical features: infinity pool basin/water, real roof deck, Pool DJ, loungers/cabanas, palms, warm light, safety glass, and city-view depth.

## 9. SOCIAL DENSITY
The venue must feel alive even when the dance floor is empty.
Functional seating should be distributed across arrival, atrium, club edge, mezzanines, VIP, rooftop, and Queen court.
Do not block the main center approach or stair circulation.

## 10. UI / SYSTEMS — LATER PHASE
One unified mobile-first UI only.
Support/Sawer follows owner image 2.
Music/Auto-DJ/DJ Mode follows owner image 3.
Developer Product and VIP IDs remain zero/disabled until official IDs are supplied. Never invent commerce IDs.

## 11. LIGHTING
Avatars must remain readable.
Club: white fill + pink/cyan show accents.
Arrival/social: warm/pink hospitality.
VIP: premium warm accent.
Rooftop: warm tropical resort with cyan pool light.

## 12. RELEASE RULE
Development remains isolated on `agent/bbya-v6-cleanroom`.
Do NOT merge/publish the clean rebuild until architecture, circulation, runtime QC, mobile UI, music/social/support systems, and owner inspection are complete.

## 13. FAILURE CONDITIONS
Reject the build if:
- old rejected geometry appears;
- the shape no longer reads like the owner reference hierarchy;
- rooftop becomes a second neon club;
- floors are inaccessible/fake;
- stairs/landings terminate in geometry;
- the dance floor or social paths are blocked;
- UI stacks or disappears on mobile;
- commerce IDs are invented;
- live Roblox is changed before owner approval.

## 14. CURRENT BUILD STATE
Current phase: PHASE 1 — physical architecture + social furnishing + lighting + spawn/safety + runtime QC.
Next phase after the physical preview is accepted: detailed materials/interior polish, then Support and Music UI/system implementation.