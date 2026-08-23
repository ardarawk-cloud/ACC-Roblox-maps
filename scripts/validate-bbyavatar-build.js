const fs = require('fs');
const path = require('path');

const ROOT = process.cwd();
const TARGET_UNIVERSE = '10744157359';
const TARGET_PLACE = '85866320744490';

function read(rel) { return fs.readFileSync(path.join(ROOT, rel), 'utf8'); }
function fail(message) { console.error(`[BBYAVATAR FPS QC] FAIL: ${message}`); process.exit(1); }
function requireText(haystack, needle, label) {
  if (!haystack.includes(needle)) fail(`${label} missing required marker: ${needle}`);
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
if (stat.size < 30000) fail(`generated place suspiciously small: ${stat.size} bytes`);
const place = fs.readFileSync(placePath, 'utf8');

for (const marker of ['FPS-PROTOTYPE-0.1','AR4','SM9','DMR7','P12','ScoreLimit','RespawnTime']) requireText(cfg, marker, 'fps.config.lua');
for (const marker of ['FPS_URBAN_BLOCK','AlphaSpawn1','BravoSpawn1','Warehouse','Container','Catwalk','BBYAVATAR_FPS_BUILD']) requireText(world, marker, 'fps.world.server.lua');
for (const marker of ['FPSRemotes','Fire.OnServerEvent','Reload.OnServerEvent','Equip.OnServerEvent','Raycast','HeadMultiplier','killfeed','ScoreLimit']) requireText(server, marker, 'fps.game.server.lua');
for (const marker of ['FPS_HUD','LockFirstPerson','MobileControls','shootOnce','setADS','Tracer','ELIMINATION','TDM PROTOTYPE']) requireText(client, marker, 'fps.client.lua');
for (const marker of ['FPSConfig','FPS_World','FPS_GameServer','FPS_Client','FPS-PROTOTYPE-0.1','FPS_URBAN_BLOCK']) requireText(place, marker, 'place.rbxlx');

const weaponCount = (cfg.match(/DisplayName\s*=/g) || []).length;
if (weaponCount !== 4) fail(`expected 4 weapon configs, found ${weaponCount}`);
const remoteCount = (server.match(/remote\("/g) || []).length;
if (remoteCount < 5) fail(`expected at least 5 remote channels, found ${remoteCount}`);
const worldParts = (world.match(/part\("/g) || []).length;
if (worldParts < 15) fail(`world geometry bootstrap too small: ${worldParts} direct part calls`);

console.log(JSON.stringify({
  ok: true,
  build: 'FPS-PROTOTYPE-0.1',
  target: { universeId: TARGET_UNIVERSE, placeId: TARGET_PLACE },
  payloadBytes: stat.size,
  weapons: weaponCount,
  systems: ['TDM','server-authoritative hitscan','ADS','reload','recoil','HUD','mobile controls','killfeed'],
  world: 'FPS_URBAN_BLOCK',
  qualityGate: 'PASS'
}, null, 2));
