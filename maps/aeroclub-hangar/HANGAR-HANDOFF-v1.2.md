# HANGAR — PROJECT HANDOFF v1.2

Status: ACTIVE / CONTINUE IN NEW CHAT
Owner / Final Authority: Arda
Project name: HANGAR
Repository: ardarawk-cloud/ACC-Roblox-maps
Branch: aeroclub-hangar-rebuild-v1-lab
Map path: maps/aeroclub-hangar
LIVE Universe: 10745364913
LIVE Place: 76001567401911
Continuation command: HANGAR START

## AUTHORITY
Latest explicit Arda instruction > this handoff > README/GDD > latest verified deploy receipt > fresh-read source > assumption.
A new chat MUST NOT ask Arda to brief the project again. Fresh-read this handoff, README.md, default.project.json, active v1.3 runtime, active workflow, and deploy-status/hangar-live.json.

## HARD WORKSTYLE LOCK
- Official name is HANGAR. Do not call it AeroClub user-facing.
- NO image generation for Roblox implementation unless Arda explicitly reverses this.
- One problem = one root cause. Do not stack rescue/failsafe scripts.
- Do not improvise layout beyond the supplied GDD/reference.
- Do not call Part/primitive fallback full mesh.
- Do not call visual PASS from CI alone. Owner in-game evidence is mandatory.

## PRODUCT / LAYOUT LOCK
Large luxury aviation hangar social club with real aircraft-hangar scale for large avatars and vehicles.
Outdoor: classic cars left, hypercars right, Corner Shop, outdoor photobooth, steel entrance, donor LED + top-3 statues.
Indoor: perimeter mobility track, baggage AFK left, photobooth right, large central dance floor.
Focal point: one medium business jet rear-middle. Jet interior VIP. Left wing DJ booth/control. Right wing Lead Dancer stage. Partially open door frames night exterior.
Final art target: true MeshPart environment, polished concrete/PBR feel, believable industrial roof/truss, readable mobile lighting, no placeholder boxes, no fake static laser bars.

## VERIFIED LIVE CHECKPOINT — 8 SEP 2026
HANGAR v1.3 full-mesh architecture has been published successfully to MAIN HANGAR.
Verified deployment receipt:
- Roblox Version: 14
- Universe: 10745364913
- Place: 76001567401911
- Source commit: ffe43eb622a6b20fdaf761e5f92754fc837e63d2
- Static model asset: 99386261031802
- Model moderation: Approved
- Mode: HANGAR_V13_LIVE_OWNER_FULL_MESH
- Spawn: FAR_OUTDOOR_FACE_CENTRAL_JET
- Visible fallback: NONE
- Workflow run: 34227302915 — SUCCESS

The previous asset-loading root cause was creator/permission mismatch. v1.3 uploads the mesh using the LIVE-owner Open Cloud key and explicitly grants model use/dependencies to the LIVE universe before publish. Build/upload/grant/build-place/publish/server-restart all passed.

## ACTIVE SOURCE
- maps/aeroclub-hangar/default.project.json mounts only HangarSpawnSafetyV1_1 + HangarFullMeshV1_3 for environment QC.
- maps/aeroclub-hangar/server/spawn-safety.server.lua: spawn at Vector3.new(0,6,-325), facing central jet around Vector3.new(0,10,58).
- maps/aeroclub-hangar/server/visual-bootstrap-v1_3.server.lua: full-mesh runtime authority, no visible fallback.
- scripts/aeroclub-hangar-v1_2-glb.js: deterministic static GLB generator.
- .github/workflows/hangar-v1_3-live-owner.yml: successful v14 publish pipeline.
- deploy-status/hangar-live.json: latest verified deploy receipt.
Old v1.2 pipelines and old BBYA Test Lab are not active HANGAR authorities.

## CURRENT PHASE
ENVIRONMENT RUNTIME OWNER QC.
Do NOT add roles, dance, monetization, DJ UI, Media UI, party effects, or other feature systems until the environment is visibly owner-verified.

## PASS GATE
Only call ENVIRONMENT PASS after Arda sends in-game evidence showing:
- spawn is farther out and faces the hangar/central jet,
- intended ground is present,
- hangar shell/roof/truss is visible,
- layout orientation is readable,
- central jet is visible in the correct position,
- no void/freefall,
- no primitive visible fallback,
- no obvious cockpit/geometry placeholder artifacts,
- scale matches the large-hangar intent.

Until owner screenshot: DEPLOY = VERIFIED; VISUAL QC = PENDING.
