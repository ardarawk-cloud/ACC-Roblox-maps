# Mountain Social Adventure

Isolated development project for the ACC Roblox Portfolio.

## Safety
This project is developed on `agent/mountain-social-adventure-v1` and the world generator only creates `Workspace.ACC_MountainSocial`. Other map roots are not modified.

The registry remains disabled until a dedicated Mountain Universe ID and Place ID are supplied and verified.

## Files
- `MASTER-LOCK.md` — concept firewall / source of truth.
- `mountain.config.json` — world, biome, journey and system configuration.
- `mountain.world.server.lua` — isolated Roblox world generator.

## Current v1 world
- Original ACC mountain mass using Roblox Terrain.
- 12 named journey checkpoints.
- Basecamp and three camp zones.
- Lower forest, mist route, upper ridge and summit progression.
- Waterfall landmark.
- Four photo spots.
- Summit platform and ACC monument.
- Hidden trail and secret summit.
- Lighting/Atmosphere foundation for cinematic ambience.
- Readiness attributes for save/checkpoint, weather, carry, leaderboard and summit counter modules.
- Lightweight decorative proxies intended to remain mobile-friendly.

## Next build modules
1. Persistent checkpoint/save service.
2. Day/night clock + sunrise/sunset controller.
3. Weather controller: fog/rain with biome-aware intensity.
4. Campfire interaction + seating/social anchors.
5. Carry/social module.
6. Summit counter, title and leaderboard.
7. Photo-mode interaction.
8. Streaming/performance QC and device budget pass.
9. Dedicated publish target verification.

## Hard rule
Do not merge or publish to another Roblox place as a substitute for the Mountain target.
