# BBYA CINEMA MASTERPLAN v1

Status: CONCEPT LOCKED / PLACE-FIRST / VIDEO LATER

## Core Vision
BBYA Cinema is a premium in-world cinema destination inside BBYA Social Hub. Phase 1 focuses entirely on building the physical cinema experience and guest flow. Full-movie playback is intentionally deferred to a later phase.

The cinema must feel like a real destination, not a decorative room.

## Phase 1 — Site & Architecture
1. Choose the final BBYA Cinema location, preferably integrated with the Mall district unless a better dedicated footprint is identified during layout audit.
2. Define cinema footprint, exterior facade, entrance visibility, pedestrian flow, and separation from nearby venues.
3. Build a premium cinema facade with readable BBYA CINEMA identity, marquee area, poster/display bays, and controlled entrance lighting.
4. Create a proper lobby with clear circulation and enough space for groups.
5. Add box office / ticket counter as a visual and future interaction anchor.
6. Add concession area with popcorn, drinks, snack display, queue line, counter, menu boards, and standing/social space.
7. Add waiting lounge with functional seating.
8. Add corridor to auditoriums with clear studio numbering and wayfinding.
9. Add toilets only if existing shared restroom placement is not practical; otherwise route to shared BBYA restroom.

## Phase 2 — Auditorium Prototype
Start with one complete premium auditorium before cloning more studios.

Required elements:
- acoustic wall treatment / dark interior shell;
- large cinema screen with correct viewing proportions;
- stepped or gently raked seating layout;
- native sit interactions on cinema seats;
- center and side aisles with safe walking clearance;
- low aisle / step lighting;
- entrance vestibule so daylight or lobby light does not spill directly onto the screen;
- rear projection/control booth visual treatment;
- emergency-exit visual language without breaking immersion;
- ceiling treatment and subtle auditorium practical lights;
- premium front rows / couple seats only if they improve the layout rather than crowd it.

## Phase 3 — Cinema Interaction Flow
The physical venue should already support the future movie system even before video is implemented.

Planned guest flow:
1. Player enters BBYA Cinema.
2. Lobby shows currently available / coming-soon titles using placeholder BBYA-owned content.
3. Player chooses a studio/session later through a simple cinema UI or physical kiosk.
4. Player walks to the correct auditorium.
5. Auditorium seating auto-sits naturally.
6. Pre-show state: house lights on low, screen idle, ambient room tone.
7. Session start state: doors visually close/dim, house lights fade down, screen activates.
8. During screening: auditorium stays dark, UI distraction minimized where practical.
9. End state: credits/session end, lights fade up, exit route becomes visually clear.

## Phase 4 — Multi-Auditorium Expansion
After Studio 1 is approved:
- clone architecture into additional studios with different capacities;
- suggested initial target: 3 auditoriums total;
- Studio 1: flagship / largest screen;
- Studio 2: standard cinema;
- Studio 3: smaller premiere / private screening room.

Do not build multiple auditoriums before the first one passes live mobile QC.

## Phase 5 — Future Full Movie Engine (NOT IMPLEMENTED YET)
Design the place so it is ready for a later BBYA Cinema Stream Engine.

Future technical concept:
- only video content that BBYA/AM STUDIO has rights to use;
- long-form content can be segmented into Roblox-supported video assets;
- two-player / dual-VideoFrame handoff architecture can preload the next segment and switch seamlessly;
- synchronized session timeline for all viewers in one auditorium;
- late joiners can be aligned to current session time where technically reliable;
- separate subtitle / title / session metadata layer;
- intro, trailers, feature, credits, and auditorium light cues controlled by one session state machine.

YouTube Premium, Netflix, or other consumer streaming accounts are NOT treated as a movie backend or licensing source.

## Phase 6 — Premiere & AM STUDIO Integration
Long-term use cases:
- AM STUDIO original short-film premieres;
- trailers and teasers;
- episodic screenings;
- virtual premiere nights;
- creator/community screenings where rights are verified;
- special BBYA event screenings.

## Design Language
Premium modern cinema with a believable hospitality feel:
- exterior: dark stone / metal / glass / warm marquee lighting;
- lobby: cinematic but clean, not excessive neon;
- auditorium: deep charcoal / black / muted burgundy or warm fabric accents;
- restrained brass / warm practical details where useful;
- mobile readability first;
- no oversized UI panels;
- avoid primitive box-only appearance where layered architecture can solve it.

## Hard Rules
- No full-movie/video implementation during the first place-building phase.
- No copyrighted film upload or playback without rights.
- Do not use YouTube Premium as a Roblox playback source.
- Keep cinema runtime isolated from Main Club, Funkot Diskotik, Underground, Rooftop, VIP, fishing, and other unrelated systems.
- Preserve global WITA clock unless a cinema-specific interior lighting state is explicitly required; auditorium darkness should be achieved locally/architecturally, not by breaking the world clock.
- Build one auditorium to premium/live-QC quality before expanding.
- Mobile screenshots are the final visual QC reference after source/cloud checks.

## Implementation Order
1. Location audit.
2. Footprint + exterior massing.
3. Facade / marquee.
4. Lobby shell.
5. Ticket/concession/waiting zones.
6. Auditorium 1 shell and screen proportions.
7. Seating + aisles + vestibule.
8. Local cinema lighting states.
9. Live mobile QC.
10. Auditorium 1 polish.
11. Expand to Studios 2–3 if approved.
12. Add ticket/session interaction framework.
13. Only then design and implement video/session engine.

## Current Decision
Cinema concept is approved for future BBYA development. Next cinema work should begin with physical place design and implementation only. Movie/video playback remains a separate later workstream.