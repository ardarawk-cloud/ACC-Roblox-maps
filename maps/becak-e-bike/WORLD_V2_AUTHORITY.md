# Becak E-Bike — World V2 Visual Authority

World V2 replaces the legacy visible blockout layer while preserving gameplay/collision authority.

Current authority:
- Buildings: `city.realism.architecture.server.lua` World V2 remesh.
- Streetscape/vegetation: `world.details.server.lua` World V2 streetscape authority v2.2.
- Ambient traffic visuals: `traffic.npc.server.lua` World V2 remesh while retaining existing AI/routes.
- Vehicle gameplay/physics remain governed by the existing dedicated Becak systems.

Legacy giant sphere-tree generation is disabled in the authoritative streetscape source.
