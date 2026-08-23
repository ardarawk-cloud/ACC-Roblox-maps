const fs = require('fs');
const path = require('path');

const ROOT = process.cwd();
const TARGET_UNIVERSE = '10744157359';
const TARGET_PLACE = '85866320744490';
const BUILD = 'FPS-PROTOTYPE-0.2';

function read(rel) { return fs.readFileSync(path.join(ROOT, rel), 'utf8'); }
function fail(message) { console.error(`[BBYAVATAR FPS QC] FAIL: ${message}`); process.exit(1); }
function requireText(haystack, needle, label) {
  if (!haystack.includes(needle)) fail(`${label} missing required marker: ${needle}`);
}
function requireAll(haystack, markers, label) {
  for (const marker of markers) requireText(haystack, marker, label);
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
if (stat.size < 45000) fail(`generated place suspiciously small: ${stat.size} bytes`);
const place = fs.readFileSync(placePath, 'utf8');

requireAll(cfg, [
  BUILD,
  'TEAM DEATHMATCH',
  'RoundTime = 480',
  'SpawnProtection = 2.5',
  'SprintSpeed = 22',
  'KillstreakMilestones',
  'AR4','SM9','DMR7','P12',
  'RecoilRecover','CrosshairKick'
], 'fps.config.lua');

requireAll(world, [
  'FPS_URBAN_BLOCK',
  'AlphaSpawn1','AlphaSpawn2','BravoSpawn1','BravoSpawn2',
  'Warehouse','Container','Catwalk','Cover_',
  'BBYAVATAR_FPS_BUILD'
], 'fps.world.server.lua');

requireAll(server, [
  'Authoritative combat server v0.2',
  'FPSRemotes',
  'Fire.OnServerEvent','Reload.OnServerEvent','Equip.OnServerEvent',
  'Workspace:Raycast',
  'HeadMultiplier',
  'SpawnProtection',
  'roundEndsAt',
  'finishRound',
  'KillstreakMilestones',
  'killfeed',
  'SCORE_LIMIT'
], 'fps.game.server.lua');

requireAll(client, [
  'FPS_HUD',
  'LockFirstPerson',
  'MobileControls',
  'MATCH SCOREBOARD',
  'SELECT LOADOUT',
  'toggleLoadout',
  'toggleScoreboard',
  'shootOnce',
  'setADS',
  'RecoilRecover',
  'MuzzleFlash',
  'Tracer',
  'SPAWN PROTECTION',
  'TDM PROTOTYPE v0.2'
], 'fps.client.lua');

requireAll(place, [
  'FPSConfig','FPS_World','FPS_GameServer','FPS_Client',
  BUILD,
  'FPS_URBAN_BLOCK',
  'MATCH SCOREBOARD',
  'SELECT LOADOUT'
], 'place.rbxlx');

const weaponCount = (cfg.match(/DisplayName\s*=/g) || []).length;
if (weaponCount !== 4) fail(`expected 4 weapon configs, found ${weaponCount}`);
const remoteCount = (server.match(/remote\("/g) || []).length;
if (remoteCount < 5) fail(`expected at least 5 remote channels, found ${remoteCount}`);
const worldParts = (world.match(/part\("/g) || []).length;
if (worldParts < 20) fail(`world geometry bootstrap too small: ${worldParts} direct part calls`);
const mobileButtons = (client.match(/roundButton\("/g) || []).length;
if (mobileButtons < 6) fail(`expected at least 6 mobile controls, found ${mobileButtons}`);

console.log(JSON.stringify({
  ok: true,
  build: BUILD,
  target: { universeId: TARGET_UNIVERSE, placeId: TARGET_PLACE },
  payloadBytes: stat.size,
  weapons: weaponCount,
  mobileButtons,
  systems: [
    'TDM timed rounds',
    'server-authoritative hitscan',
    'spawn protection',
    'killstreaks',
    'ADS + recoil recovery',
    'dynamic crosshair',
    'loadout selector',
    'scoreboard',
    'HUD + damage feedback',
    'mobile controls',
    'killfeed'
  ],
  world: 'FPS_URBAN_BLOCK',
  qualityGate: 'PASS'
}, null, 2));
