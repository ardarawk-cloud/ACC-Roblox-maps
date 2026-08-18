# BBYA SOCIAL HUB V6 — VISUAL REFERENCE LOCK — 2026-08-19

Status: **OWNER VISUAL DIRECTION / HARD REFERENCE LOCK**

This lock translates the owner-supplied BBYA concept images into build rules for the V6 clean-room implementation. It does not authorize copying third-party branded assets. BBYA remains an original ACC/BBYA Roblox experience.

## 1. PRIMARY SHAPE REFERENCE

The first supplied image is the PRIMARY architectural/massing reference.

The venue must read as one premium, multi-level social resort/nightlife complex from a single hero view, with several destinations visible at the same time rather than as unrelated sealed rooms.

Required silhouette and composition:

- **Left / left-center:** a strong multi-level BBYA club wing with glass, dark structure, pink/cyan light, visible activity and a clearly integrated DJ/dance facility.
- **Center / lower-middle:** an open social/dance terrace or commons that visually connects the main public floor to the club wing.
- **Right / lower level:** a premium VIP-facing frontage/lounge destination that is visually legible without dominating the entrance.
- **Right / upper level:** the infinity-pool / rooftop-party lifestyle zone must be visible as an upper terrace in the overall composition.
- **Front / foreground:** BBYA social landmarks such as Queen identity, supporter/social presence, photo moments and hangout pockets create a layered foreground instead of an empty plaza.
- **Background:** tropical palms, warm architectural lighting and a city-night skyline create depth.

The composition must feel **terraced, layered and vertical**, not like a flat box with separate rooms hidden behind walls.

## 2. HERO-VIEW RULE

At least one intentional arrival/preview sightline must visually communicate all of the following without teleporting:

1. BBYA brand/crown.
2. Active social commons.
3. Club/dance destination.
4. VIP destination.
5. Upper rooftop/pool destination.
6. A premium tropical/city-night setting.

The player must understand within seconds that BBYA is a large multi-destination hangout venue.

## 3. SOCIAL-HUB FIRST

The first image is a shape and atmosphere reference, not permission to turn the entire map into one nightclub.

- Social Commons remains the primary arrival experience.
- Club/dance remains one facility inside the hub.
- Outfit/show-off, selfie/photo, conversation, bar, chill, VIP/private social and rooftop lifestyle remain first-class reasons to stay.
- Seating and social pockets must exist throughout the venue.

## 4. LIGHTING / MATERIAL LANGUAGE

### Main public / club architecture
- dark premium structure
- black / graphite / glass
- vivid BBYA pink, cyan and purple accents
- readable avatar skin/outfits; never a black void
- strong depth through layered edge lighting and glass

### Rooftop
- luxury tropical resort first
- turquoise/cyan pool water
- wood / stone / glass
- warm indirect lighting
- palms / planters / cabanas
- restrained pink/cyan BBYA accents only

Rooftop must not become a second full-neon indoor club.

## 5. QUEEN / VIP VISUAL ROLE

- BBYA Queen identity is a premium signature landmark.
- Queen/private access remains authoritative and server-controlled.
- A public-facing visual/photo landmark may reference BBYA Queen identity, but it must not grant private access.
- VIP should be visually recognizable from the hero composition and have a premium physical entrance/landing rather than only a menu button.

## 6. SUPPORT / SAWER REFERENCE

The second supplied image is the UI/feature reference for Support/Sawer, not the building shape reference.

Target hierarchy:
- Support/Sawer launcher
- denomination cards
- purchase confirmation
- total support amount
- rank
- Top Supporter leaderboard
- history
- club-wide celebration/notification for successful support
- mobile-safe presentation

Developer Product IDs must remain disabled while configured as `0`. No invented product IDs. Leaderboards and totals must use authoritative receipt data.

## 7. MUSIC / DJ REFERENCE

The third supplied image is the UI/feature reference for music and DJ control.

Target hierarchy:
- Auto DJ
- DJ Mode
- Radio/stream mode only where Roblox/platform policy and the actual implementation permit it
- Now Playing
- playlist / queue
- volume
- crossfade
- club effects controls
- DJ booth control
- mobile-safe mini player

Only authorized Roblox audio/assets may be used. UI may look premium and dense but must remain readable on phones.

## 8. MOBILE-FIRST RULE

The map and UI must be usable on phone without the interface covering Roblox movement/jump controls.

- Compact launchers.
- One focused major panel at a time.
- Draggable/recoverable windows.
- No permanent oversized center-screen panels during normal play.
- Social/photo/music/support flows require no precision mouse interaction.

## 9. QUALITY BAR

Reject the build if any of these are true:

- the exterior is a flat rectangular box with all destinations hidden inside
- the pool cannot be visually understood as an upper lifestyle terrace
- the club consumes the identity of the whole hub
- the VIP/Queen features are only UI labels with no physical destination
- the arrival plaza is empty filler
- rooftop looks like the same neon language as the club
- lighting makes avatars difficult to see
- decorative massing creates inaccessible fake floors that look playable
- major architecture blocks stairs, lift, doors or the main social circulation spine

## 10. IMPLEMENTATION / RELEASE

Implementation stays on `agent/bbya-v6-cleanroom` until architecture, circulation, finishes, systems, UI and validators pass.

V5/live must not be replaced merely to preview this reference pass. V6 switches live only once the complete QC/release gate is satisfied.
