# BBYA SOCIAL HUB — V6 CLEAN-ROOM MASTER CONTRACT

Status: SOURCE OF TRUTH for V6 rebuild. V5 remains live until V6 passes complete internal QC and is switched once.

## 1. PRODUCT IDENTITY
BBYA is a SOCIAL HUB first. Club/dance is one facility, not the identity of the entire experience.
Primary reasons to visit: hangout, conversation, outfit/show-off, photo/camera, social bar, chill, VIP/private social, rooftop lifestyle, and club/dance.

## 2. ARCHITECTURE RULE
No V5 geometry may be reused blindly. V6 is rebuilt from a clean coordinate plan.
No decorative object is placed until circulation, doorways, stairs, lift, landing clearances, sightlines, and room boundaries are locked.
No patch-stack architecture. Each zone owns its geometry and finish.

## 3. MACRO ZONES
A1 Social Arrival Plaza
A2 BBYA Storefront Entrance
A3 Social Commons / Welcome Bar / Outfit-Selfie
A4 Club Facility / Dance Hall
A5 Social Bar
A6 Chill / Conversation Lounge
B1 West Stair
B2 East Stair
B3 Lift Core
C1 VIP West Lounge
C2 VIP East Lounge
C3 Queen / Private Social Bridge
D1 Rooftop Arrival
D2 Infinity Pool + Pool DJ
D3 Sky Bar
D4 Rooftop Chill
D5 Cabanas
D6 Photo / View Deck
S1 Service / Staff / Technical

## 4. MICRO CODES
01 Arrival Plaza
02 Welcome / Reception Host
03 Photo / Selfie
04 Look / Outfit Studio
05 Dance Floor
06 DJ Booth
07 Stage / Lighting
08 Social Bar
09 VIP Lounge
10 Queen Skybox
11 VIP Balcony
12 Private Rooms
13 Infinity Pool
14 Pool DJ
15 Sky Bar
16 Cabanas
17 View Deck / City View

Every runtime object that is useful for inspection must expose BBYA zone/component attributes. A screenshot must be traceable to a single module.

## 5. FRONT ENTRANCE BENCHMARK
Front must read as a modern social/lifestyle storefront, not a formal nightclub gate.
- Large BBYA crown + neon wordmark attached to building facade.
- Canopy/awning below brand wall.
- Ground floor open/transparent enough to see social activity inside.
- Welcome bar, seating, outfit/selfie activity visible from outside.
- Warm-pink hospitality lighting; no bouncer/red-carpet checkpoint language.
- Direct broad sightline from A1 into A3.

## 6. SOCIAL DENSITY BENCHMARK
The venue must feel alive even without entering A4.
- Multiple micro hangout pockets.
- Seating distributed across A1/A3/A5/A6/C/D.
- Visual connection between zones where practical.
- No giant empty rooms whose only purpose is transit.
- No furniture blocking circulation.

## 7. CLUB FACILITY BENCHMARK
A4 may be full neon and energetic, but it is a facility inside the hub.
- Bright enough for outfit visibility and social screenshots.
- Broad neutral/white/warm fill lights + neon accent lighting.
- Dance floor, DJ, stage, side social pockets.
- Club must not visually dominate every other floor.

## 8. ROOFTOP BENCHMARK
Rooftop is a different atmosphere from A4.
- Luxury tropical / resort / warm night ambience.
- Infinity pool, pool DJ, cabanas, sky bar, view deck.
- Palms/planters and warm architectural lighting.
- Neon used only as restrained branding/accent, never full-club lighting.

## 9. CIRCULATION
Architectural flow must be obvious without teleport.
A1 -> A2 -> A3 is the primary arrival.
From A3, Social Bar, Chill, Club, VIP/Lift/Rooftop must read as parallel choices.
Stairs and lift must have clear landings and never terminate inside furniture/geometry.
No obby-like stacked circulation.
Inspection TP exists only for QC and must always land on clear pads.

## 10. UI CONTRACT
One unified UI system only. No old stacked UI runtimes.
The approved visual hierarchy from the BBYA UI concept poster is the target.
- Top status/zone strip.
- Left/right compact launchers or floating shell that preserves Roblox joystick/jump areas.
- Major panels open as floating windows.
- Windows can be dragged.
- Edge parking must NOT set Visible=false; parked windows remain partially visible as a grab tab/edge.
- Dragging upward must never make a window disappear into the main menu.
- Music panel must remain fully recoverable after drag.
- Only one major content window may own focus at once.
- Photo panel includes Outfit Cam, Freecam, Clean View, Reset.
- Mobile-first layout must be validated at phone aspect ratios.

## 11. MUSIC / CAMERA / SOCIAL SYSTEMS
Hybrid Auto-DJ with A4 DJ and D2 Pool DJ both valid.
Dance/sync system uses authorized/built-in assets only.
Outfit camera + mobile freecam are first-class social features.
VIP and Queen access must use authoritative server state.
Sawer/Developer Product purchase buttons remain disabled while IDs are 0; no invented IDs.
Top supporter board uses authoritative receipt data only.

## 12. LIGHTING
A1/A2/A3: warm-pink hospitality, readable avatars.
A4: bright show-off club lighting + neon.
A5/A6/C: premium lounge lighting.
D zones: tropical warm luxury, restrained neon.
Performance mode may reduce decorative lights but must never disable critical avatar fill lights.

## 13. BUILD / RELEASE RULE
V6 work happens on agent/bbya-v6-cleanroom.
Do NOT point live injector to V6 until ALL of the following are complete:
- architecture all zones
- circulation all zones
- finishes all zones
- UI unified and mobile-safe
- music/dance/camera/support systems
- static validator
- legacy-root guard
- component/zone coverage validator
- collision/landing checks
- final source assembly check

Only after all gates pass: one injector switch, one publish, one founder inspection pass.

## 14. FAILURE CONDITIONS
V6 is rejected if any of these occur:
- club becomes the perceived whole product
- entrance looks like a formal nightclub gate
- rooftop uses full-club neon language
- UI layout differs materially from approved hierarchy without explicit owner revision
- floating panel disappears when dragged
- signage is mirrored/backwards or duplicated at one boundary
- furniture/decor intersects stairs/lift/door paths
- old V5 visual roots/runtime names appear in V6 assembly
- founder is required to inspect every incremental commit

## 15. OWNER VISUAL REFERENCE LOCK — 2026-08-19
The owner-supplied BBYA concept set is now translated in `VISUAL-REFERENCE-LOCK-2026-08-19.md` and is binding for the V6 visual/massing pass.

The first concept image is the primary architecture/composition reference. The complete venue must read as one layered premium complex: left multi-level club/social wing, center/lower social activity, visibly legible VIP destination, upper rooftop/infinity-pool lifestyle terrace, foreground Queen/support/social landmarks, palms and city-night depth.

The second concept image is the Support/Sawer UI and leaderboard reference. The third concept image is the Music/DJ UI reference. They are feature/UI references and do not override the physical architecture rules.

The reference must be implemented without fake inaccessible floors, without blocking circulation, without turning the rooftop into a second neon club, and without switching V5/live before the V6 release gate passes.
