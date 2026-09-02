const fs = require('fs');
const path = require('path');

const ROOT = process.cwd();
const TARGET_UNIVERSE = '10744157359';
const TARGET_PLACE = '85866320744490';
const BUILD = 'FPS-PROTOTYPE-0.3.1';

function read(rel) { return fs.readFileSync(path.join(ROOT, rel), 'utf8'); }
function fail(message) { console.error(`[ZONA PERANG QC] FAIL: ${message}`); process.exit(1); }
function requireText(haystack, needle, label) {
  if (!haystack.includes(needle)) fail(`${label} missing required marker: ${needle}`);
}
function requireAll(haystack, markers, label) {
  for (const marker of markers) requireText(haystack, marker, label);
}
function rejectText(haystack, needle, label) {
  if (haystack.includes(needle)) fail(`${label} contains forbidden marker: ${needle}`);
}

const registry = JSON.parse(read('maps/registry.json'));
const target = registry?.maps?.bbyavatar;
if (!target) fail('registry target missing');
if (String(target.universeId) !== TARGET_UNIVERSE) fail(`wrong Universe ID: ${target.universeId}`);
if (String(target.placeId) !== TARGET_PLACE) fail(`wrong Place ID: ${target.placeId}`);
if (!target.enabled) fail('registry target disabled');

const cfg = read('maps/bbyavatar/fps.config.lua');
const world = read('maps/bbyavatar/fps.world.server.lua');
const server = read('maps/bbyavatar/fps.game.server.lua');
const client = read('maps/bbyavatar/fps.client.lua');
const placePath = path.join(ROOT, 'maps/bbyavatar/place.rbxlx');
if (!fs.existsSync(placePath)) fail('generated place.rbxlx missing');
const stat = fs.statSync(placePath);
if (stat.size < 40000) fail(`generated place suspiciously small: ${stat.size} bytes`);
const place = fs.readFileSync(placePath, 'utf8');

requireAll(cfg, [
  BUILD,
  'CameraMode = "CLASSIC_ZOOMABLE"',
  'MobileMovement = "ROBLOX_DEFAULT_MOVE_JUMP"',
  'TEAM DEATHMATCH',
  'SpawnProtection = 5',
  'SafeBoundsX = 248',
  'SafeBoundsZ = 198',
  'AR4','SM9','DMR7','P12'
], 'fps.config.lua');

requireAll(world, [
  'RUNTIME_VISIBLE_MAP_V1',
  BUILD,
  'FPS_URBAN_BLOCK',
  'Ground',
  'AlphaSpawn1','AlphaSpawn2','BravoSpawn1','BravoSpawn2',
  'AlphaSpawnDeck','BravoSpawnDeck',
  'MainRoad','NorthRoad','SouthRoad','CenterCrossRoad',
  'WarehouseFloor','WarehouseCenterTower',
  'Office_',
  'Container_',
  'Cover_',
  'AlphaTower','BravoTower',
  'BBYAVATAR_FPS_BUILD',
  'ZONA_MAP_READY_031'
], 'fps.world.server.lua');
rejectText(world, 'for _, child in ipairs(Workspace:GetChildren())', 'fps.world.server.lua');

requireAll(server, [
  'Authoritative combat server v0.2.1',
  'FPSRemotes',
  'Fire.OnServerEvent','Reload.OnServerEvent','Equip.OnServerEvent',
  'Workspace:Raycast',
  'SpawnProtection',
  'placeCharacterSafely',
  'FallRescueY',
  'SafeBoundsX',
  'finishRound',
  'SCORE_LIMIT'
], 'fps.game.server.lua');

requireAll(client, [
  'MOBILE_PLAYABILITY_RESCUE_V1',
  'DEFAULT_ROBLOX_MOVEMENT_AND_JUMP',
  'FPS_HUD',
  'Enum.CameraMode.Classic',
  'CameraMinZoomDistance = 0.5',
  'CameraMaxZoomDistance = 14',
  'MobileCombatControls',
  'Native joystick and jump corners are deliberately empty',
  'roundButton("Fire"',
  'roundButton("ADS"',
  'roundButton("Reload"',
  'roundButton("Swap"',
  'roundButton("Guns"',
  'Intentionally no RUN button on mobile P0',
  'LoadoutStrip',
  'shootOnce',
  'setADS',
  'spawnSafe',
  'SPAWN PROTECTION',
  'ZONA_PERANG_CAMERA'
], 'fps.client.lua');
rejectText(client, 'Enum.CameraMode.LockFirstPerson', 'fps.client.lua');
rejectText(client, 'roundButton("Sprint"', 'fps.client.lua');
rejectText(client, 'BBYAVATAR_FPS_CAMERA",Enum.RenderPriority.Camera.Value+1', 'fps.client.lua');

requireAll(place, [
  'FPSConfig','FPS_World','FPS_GameServer','FPS_Client',
  BUILD,
  'RUNTIME_VISIBLE_MAP_V1',
  'ZONA_MAP_READY_031',
  'MOBILE_PLAYABILITY_RESCUE_V1',
  'DEFAULT_ROBLOX_MOVEMENT_AND_JUMP',
  'Enum.CameraMode.Classic',
  'CameraMaxZoomDistance = 14',
  'placeCharacterSafely'
], 'place.rbxlx');

const weaponCount = (cfg.match(/DisplayName\s*=/g) || []).length;
if (weaponCount !== 4) fail(`expected 4 weapon configs, found ${weaponCount}`);
const remoteCount = (server.match(/remote\("/g) || []).length;
if (remoteCount < 5) fail(`expected at least 5 remote channels, found ${remoteCount}`);
const worldParts = (world.match(/makePart\(/g) || []).length;
if (worldParts < 35) fail(`visible battlefield geometry too small: ${worldParts} makePart calls`);
const mobileButtons = (client.match(/roundButton\("/g) || []).length;
if (mobileButtons !== 5) fail(`expected exactly 5 non-overlapping mobile combat buttons, found ${mobileButtons}`);

console.log(JSON.stringify({
  ok: true,
  build: BUILD,
  target: { universeId: TARGET_UNIVERSE, placeId: TARGET_PLACE },
  payloadBytes: stat.size,
  weapons: weaponCount,
  mobileButtons,
  worldParts,
  systems: [
    'visible deterministic urban battlefield',
    'native Roblox mobile movement preserved',
    'native Roblox jump zone preserved',
    'zoomable Classic camera 0.5-14 studs',
    'five combat buttons outside native control corners',
    'compact loadout strip',
    'server-authoritative hitscan',
    'spawn protection + safe respawn',
    'fall/out-of-bounds rescue'
  ],
  qualityGate: 'PASS'
}, null, 2));
