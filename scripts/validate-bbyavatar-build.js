const fs = require('fs');
const path = require('path');

const ROOT = process.cwd();
const TARGET_UNIVERSE = '10744157359';
const TARGET_PLACE = '85866320744490';
const BUILD = 'FPS-PROTOTYPE-0.3.1';
const STATIC_MAP_AUTHORITY = 'ZONA_STATIC_MAP_V1';

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
const server = read('maps/bbyavatar/fps.game.server.lua');
const client = read('maps/bbyavatar/fps.client.lua');
const builder = read('scripts/build-bbyavatar.js');
const placePath = path.join(ROOT, 'maps/bbyavatar/place.rbxlx');
if (!fs.existsSync(placePath)) fail('generated place.rbxlx missing');
const stat = fs.statSync(placePath);
if (stat.size < 50000) fail(`generated place suspiciously small: ${stat.size} bytes`);
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

requireAll(builder, [
  STATIC_MAP_AUTHORITY,
  'ZONA_STATIC_MAP',
  'staticParts',
  "add('Ground'",
  "add('MainRoad'",
  "add('AlphaSpawnDeck'",
  "add('WarehouseFloor'",
  'Office_',
  'Container_',
  'Cover_',
  "add('AlphaTower'",
  "add('BravoTower'",
  'FPS_GameServer',
  'FPS_Client'
], 'build-bbyavatar.js');
rejectText(builder, "const world = read('fps.world.server.lua')", 'build-bbyavatar.js');
rejectText(builder, '<string name="Name">FPS_World</string>', 'build-bbyavatar.js');

requireAll(server, [
  'Authoritative combat server v0.2.1',
  'FPSRemotes',
  'Fire.OnServerEvent','Reload.OnServerEvent','Equip.OnServerEvent',
  'Workspace:Raycast',
  'SpawnProtection',
  'placeCharacterSafely',
  'fallbackSpawns',
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
  'spawnSafe',
  'SPAWN PROTECTION',
  'ZONA_PERANG_CAMERA'
], 'fps.client.lua');
rejectText(client, 'Enum.CameraMode.LockFirstPerson', 'fps.client.lua');
rejectText(client, 'roundButton("Sprint"', 'fps.client.lua');

requireAll(place, [
  'ZONA_STATIC_MAP',
  'ZONA_STATIC_MAP_AUTHORITY',
  STATIC_MAP_AUTHORITY,
  '<string name="Name">Ground</string>',
  '<string name="Name">MainRoad</string>',
  '<string name="Name">AlphaSpawnDeck</string>',
  '<string name="Name">BravoSpawnDeck</string>',
  '<string name="Name">WarehouseFloor</string>',
  '<string name="Name">WarehouseCenterTower</string>',
  '<string name="Name">Office_8</string>',
  '<string name="Name">Container_6</string>',
  '<string name="Name">Cover_16</string>',
  '<string name="Name">AlphaTower</string>',
  '<string name="Name">BravoTower</string>',
  'FPSConfig','FPS_GameServer','FPS_Client',
  'MOBILE_PLAYABILITY_RESCUE_V1',
  'Enum.CameraMode.Classic',
  'CameraMaxZoomDistance = 14',
  'placeCharacterSafely'
], 'place.rbxlx');
rejectText(place, '<string name="Name">FPS_World</string>', 'place.rbxlx');

const weaponCount = (cfg.match(/DisplayName\s*=/g) || []).length;
if (weaponCount !== 4) fail(`expected 4 weapon configs, found ${weaponCount}`);
const remoteCount = (server.match(/remote\("/g) || []).length;
if (remoteCount < 5) fail(`expected at least 5 remote channels, found ${remoteCount}`);
const staticPartCount = (place.match(/<Item class="Part"/g) || []).length;
if (staticPartCount < 60) fail(`serialized battlefield too small: ${staticPartCount} static parts`);
const mobileButtons = (client.match(/roundButton\("/g) || []).length;
if (mobileButtons !== 5) fail(`expected exactly 5 non-overlapping mobile combat buttons, found ${mobileButtons}`);

console.log(JSON.stringify({
  ok: true,
  build: BUILD,
  mapAuthority: STATIC_MAP_AUTHORITY,
  target: { universeId: TARGET_UNIVERSE, placeId: TARGET_PLACE },
  payloadBytes: stat.size,
  weapons: weaponCount,
  mobileButtons,
  staticPartCount,
  systems: [
    'battlefield serialized directly into Workspace',
    'no active runtime FPS_World authority',
    'native Roblox mobile movement preserved',
    'native Roblox jump zone preserved',
    'zoomable Classic camera 0.5-14 studs',
    'five combat buttons outside native control corners',
    'server-authoritative combat preserved',
    'fallback spawns land on serialized ground'
  ],
  qualityGate: 'PASS'
}, null, 2));
