# AEROCLUB HANGAR — PROJECT HANDOFF v1.0

Status: ACTIVE / CONTINUE IN NEW CHAT
Owner / Final Authority: Arda
Project: AeroClub Hangar
Repository: ardarawk-cloud/ACC-Roblox-maps
Branch: aeroclub-hangar-rebuild-v1-lab
Map path: maps/aeroclub-hangar
LIVE Universe: 10745364913
LIVE Place: 76001567401911

## AUTHORITY ORDER
1. Latest explicit instruction from Arda
2. This handoff
3. maps/aeroclub-hangar/README.md Master GDD
4. Latest verified deploy receipt
5. Fresh-read source
6. Assumption — forbidden when a fresh-read can answer it

## CONTINUATION RULE
A new chat MUST NOT ask Arda to re-explain the project. Fresh-read this file, README.md, default.project.json, active runtime scripts, active workflow, and deploy-status/aeroclub-hangar-live.json before making changes.

## OWNER WORKSTYLE LOCK
- Do not restart concept unless Arda explicitly says reset.
- Do not improvise geometry/layout beyond the supplied GDD/reference.
- Do not use image generation for Roblox implementation.
- Do not call primitive/Part fallback "full mesh".
- Do not claim PASS from CI alone; in-game owner screenshot/runtime evidence is required for visual PASS.
- Do not diagnose cache/server issues without evidence.
- One problem = one root cause. Do not stack rescue scripts over rescue scripts.
- Temporary diagnostic fallbacks are allowed only to isolate a failure and must not become the production architecture.

## PRODUCT / VISUAL LOCK
AeroClub Hangar is a large luxury commercial/business-jet hangar converted into a cyberpunk-industrial social club. It must feel genuinely large enough for large Roblox avatars and vehicles.

Mandatory layout:
- Outdoor: classic cars left, hypercars right, Corner Shop, outdoor photobooth, steel hangar entrance, donor LED + top-3 statues.
- Indoor: perimeter mobility track, baggage AFK zone left, photobooth right, large central dance floor.
- Main focal point: one medium business jet centered toward rear-middle.
- Jet interior = VIP lounge.
- Left wing = DJ booth/control.
- Right wing = Lead Dancer stage.
- Partially open hangar door frames night exterior.

Visual target:
- TRUE imported/static MeshPart art for final environment.
- Polished concrete / PBR feel.
- Industrial hangar truss/roof with believable aviation scale.
- Lighting must be readable on mobile; dark club mood is not permission to hide geometry.
- No obvious placeholder boxes on aircraft or environment.

## CURRENT VERIFIED CHECKPOINT
Latest owner evidence after LIVE v11/v12: player still sees sky/void and the actual AeroClub environment is not visible. Therefore current visual state is FAIL.

Latest deployment receipt before this handoff reported:
- Universe 10745364913
- Place 76001567401911
- staticModelAssetId 89579886424411
- Roblox version 12
- serversRestarted true

Those deployment facts do NOT prove the environment loaded in runtime.

## CURRENT ROOT PROBLEM
The place publishes successfully, but runtime does not visibly load/render the intended AeroClub environment for the owner. Spawn-safety and visible failsafe attempts are symptoms/diagnostics, not the final fix.

Before any further visual feature work, determine exactly why the map is absent. Verify in this order:
1. Built rbxlx actually contains and mounts the intended bootstrap/runtime scripts.
2. Runtime script executes in the published place.
3. InsertService/asset loading for model 89579886424411 succeeds in the published experience context.
4. Loaded model contains the expected MeshParts and passes bounds/pivot guards.
5. Environment is parented into Workspace and stays present.
6. Spawn position is on actual loaded geometry.

If runtime InsertService is the failure, stop using runtime asset insertion for the final environment. Bake/import the MeshParts directly into the published place source/artifact so the map exists at server start without a network/runtime asset load dependency.

## ACTIVE SOURCE NOTES
maps/aeroclub-hangar/default.project.json currently mounts the visual bootstrap and spawn safety, not the full core systems. That isolation is intentional until environment runtime is visibly PASS.

Files of interest:
- maps/aeroclub-hangar/README.md
- maps/aeroclub-hangar/default.project.json
- maps/aeroclub-hangar/server/visual-bootstrap-v1_2.server.lua
- maps/aeroclub-hangar/server/spawn-safety.server.lua
- maps/aeroclub-hangar/server/environment.server.lua
- .github/workflows/aeroclub-hangar-v1_2-live.yml
- deploy-status/aeroclub-hangar-live.json

## NEXT PHASE
ENVIRONMENT RUNTIME ROOT-CAUSE FIX.

Do NOT add roles, dance systems, monetization, DJ UI, media UI, vehicles, effects, or polish until the base environment is visibly present and owner-verified.

Preferred final architecture if runtime model insertion remains unreliable:
GLB/source mesh generation -> deterministic import/bake into place artifact -> Rojo/build artifact contains actual MeshParts -> publish -> runtime starts with environment already present.

## PASS GATE
Environment phase can be called PASS only when Arda provides in-game evidence showing:
- player standing on intended ground,
- hangar shell visible,
- entrance/outdoor orientation readable,
- central jet visible,
- no sky/void freefall,
- no obvious placeholder cockpit/block artifacts,
- scale matches the large-hangar intent.

Until then: ENVIRONMENT RUNTIME = FAIL / ACTIVE FIX.
