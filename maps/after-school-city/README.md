# AFTER SCHOOL CITY

Status: SOURCE SCAFFOLD / NOT PUBLISHED

Universe ID: `10745359869`
Place ID: `121603385909425`
Project namespace: `maps/after-school-city`

Standalone Roblox school-life roleplay/simulation experience for early teens. The game starts when school ends: players explore a compact city, join activities, earn progression rewards, customize style and personal space, and return for rotating events.

## Product lock
- Genre direction: Role Play & Avatar Simulation / Life.
- Core identity: school-life activities and progression, not a Social Hangout experience.
- Target audience: middle-school / early-teen players.
- Safety direction: no dating-focused gameplay, gambling, alcohol, realistic violence, or mature nightlife systems.
- Mobile-first navigation and compact travel distances.

## World districts — Scaffold V1
1. School District — spawn, courtyard, club rooms, cafeteria, school activity hub.
2. Downtown — arcade, cafe, fashion, convenience retail, plaza.
3. Skate Park — skateboard challenges and street-style activity space.
4. Park — lake/green space, photo missions, treasure-hunt routes.
5. Residential — future personal bedroom/studio-room access.
6. Sports Field — basketball/futsal and timed challenges.

## Development order
1. World blockout and traversal validation.
2. Visual capture from Studio/self-hosted runner.
3. Map audit and district adjustment.
4. First playable activities and progression loop.
5. UI/phone shell and onboarding.
6. Personalization, clubs and retention systems.
7. Dedicated QC/build/publish pipeline.

## Source of truth
- `after-school-city.config.lua` — project and district tuning.
- `after-school-city.world.server.lua` — non-destructive V1 world scaffold.
- `MASTERPLAN.md` — gameplay/product roadmap.
- `maps/registry.json` — Universe/Place routing; remains disabled until a dedicated publisher and QC gate exist.

## Publishing safety
Do not use the repository generic `publish-map.yml` for this project. That workflow explicitly refuses generic assemblers. AFTER SCHOOL CITY must receive its own isolated build/QC/publish path before registry enablement.

No LIVE claim is valid without an actual Roblox publish receipt for Universe `10745359869` / Place `121603385909425`.
