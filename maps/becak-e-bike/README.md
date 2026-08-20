# BECAK E-BIKE — Nusakarya Simulator

Status: PLAYABLE BASELINE / PUBLISH PIPELINE ENABLED

Universe ID: `10745325613`
Place ID: `80994730522893`
Project namespace: `maps/becak-e-bike`

Standalone Roblox experience based on the Becak E-Bike masterplan. This project is isolated from BBYA Social Hub, BBYAVATAR, Mountain Social Adventure and every other ACC Roblox map.

## Current playable baseline
- Nusakarya open-world prototype with 8 named districts.
- Indonesian road network, housing, market, school, hospital, mall, hotel, terminal, beach and industrial zone.
- Player-owned drivable three-wheel electric becak using native VehicleSeat desktop/mobile input.
- Battery consumption and charging station.
- Passenger pickup and randomized destination loop.
- Rupiah rewards, XP, levels, trip count and reputation HUD.
- Garasi Pak Jaya with motor and battery upgrades.
- Persistent player economy/progression through DataStore with safe fallback.
- Mobile-first HUD and interaction prompts.
- 24-minute day-cycle baseline.
- StreamingEnabled place build for mobile performance.

## Masterplan roadmap
Core V1 foundation is represented in runtime and designed to expand without changing the publishing route: richer NPC schedules, cargo jobs, traffic AI, weather, repair/damage, visual customization, contracts, fleet management, story chapters, festivals, achievements, daily missions and multiplayer/social systems.

## Source of truth
- `runtime.server.lua` — world generation, vehicle, economy, missions and persistence.
- `runtime.client.lua` — HUD/mobile feedback.
- `becak.config.lua` — tuning reference.
- `scripts/build-becak-ebike.js` — builds `place.rbxlx`.
- `.github/workflows/becak-ebike-publish.yml` — isolated build/publish pipeline.
- `maps/registry.json` — Roblox Universe/Place routing.

## Publishing
The pipeline builds `maps/becak-e-bike/place.rbxlx` and publishes only to Universe `10745325613`, Place `80994730522893` through `scripts/publish-map.js`. It requires the repository secret `ROBLOX_API_KEY` with Open Cloud write permission for this universe/place.

## Isolation rule
All Becak E-Bike scripts, generated place data and future systems stay inside `maps/becak-e-bike` unless an ACC shared module is explicitly approved. Never reuse another project's Universe ID or Place ID.
