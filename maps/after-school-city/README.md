# AFTER SCHOOL CITY

Status: PREMIUM FOUNDATION V0.2 IN DEVELOPMENT / CURRENT SOURCE NOT YET PUBLISHED

Universe ID: `10745359869`
Place ID: `121603385909425`
Project namespace: `maps/after-school-city`

Standalone Roblox school-life roleplay/simulation experience for early teens. The game starts when school ends: players explore a compact city, join activities, earn progression rewards, customize style and personal space, and return for rotating events.

## Current deployment state
- A prior source revision is already LIVE on Roblox and includes the dedication intro popup.
- Latest verified dedication publish receipt: Roblox version 6 on Universe `10745359869`, Place `121603385909425`.
- The current branch now contains Premium Map Pass 1 (`0.2.0-premium-pass-1`) and is NOT yet claimed LIVE.
- Never claim a new map revision LIVE until its publish receipt matches the new source commit.

## Product lock
- Genre direction: Role Play & Avatar Simulation / Life.
- Core identity: school-life activities and progression, not a Social Hangout experience.
- Target audience: middle-school / early-teen players.
- Safety direction: no dating-focused gameplay, gambling, alcohol, realistic violence, or mature nightlife systems.
- Mobile-first navigation and compact travel distances.

## World districts — Premium Foundation
1. School District — hero spawn area, school facade, courtyard, school-bus stop and primary onboarding anchor.
2. Downtown — arcade, cafe, style, music and hobby storefronts around a central plaza.
3. Skate Park — quarter pipes, fun box, rail and skate activity space.
4. Park — lake, walking path, trees and seating for photo/treasure routes.
5. Residential — townhouse/apartment massing for future personal-room access.
6. Sports Field — basketball court, hoops, bleachers and challenge space.

## Premium Map Pass 1 goals
- Remove all giant debug BillboardGui labels.
- Replace neon/blockout spawn presentation with a discreet spawn.
- Establish city roads, sidewalks, lane markings and crosswalks.
- Make School District the strongest first-impression area.
- Add readable facades, glass, roofs, signage, trees, benches, streetlights and restrained golden-hour lighting.
- Preserve the six-district compact layout while upgrading visual readability.

## Development order
1. Premium Foundation source build + QC.
2. Publish only after explicit owner approval.
3. Read-only Open Cloud live scan after publish.
4. Visual review from Roblox/mobile screenshots or Studio capture.
5. District refinement and playable interiors.
6. First activities and progression loop.
7. UI/phone shell, clubs, personalization and retention systems.

## Source of truth
- `after-school-city.config.lua` — project/district tuning and feature flags.
- `after-school-city.world.server.lua` — current Premium Map Pass world generator.
- `after-school-city.intro.client.lua` — dedication intro UI.
- `MASTERPLAN.md` — gameplay/product roadmap.
- `maps/registry.json` — Universe/Place routing; registry remains disabled for the generic publisher.

## Publishing safety
Do not use the repository generic `publish-map.yml` for this project. AFTER SCHOOL CITY uses an isolated build/QC path and an externally locked publish workflow for its exact Universe/Place target.

No new LIVE claim is valid without an actual Roblox publish receipt for Universe `10745359869` / Place `121603385909425` containing the matching source revision.
