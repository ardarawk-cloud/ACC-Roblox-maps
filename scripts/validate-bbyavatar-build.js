const fs = require('fs');
const path = require('path');

const ROOT = process.cwd();
const TARGET_UNIVERSE = '10744157359';
const TARGET_PLACE = '85866320744490';

function read(rel) {
  return fs.readFileSync(path.join(ROOT, rel), 'utf8');
}
function fail(message) {
  console.error(`[BBYAVATAR QC] FAIL: ${message}`);
  process.exit(1);
}
function requireText(haystack, needle, label) {
  if (!haystack.includes(needle)) fail(`${label} missing required marker: ${needle}`);
}

const registry = JSON.parse(read('maps/registry.json'));
const target = registry?.maps?.bbyavatar;
if (!target) fail('registry target missing');
if (String(target.universeId) !== TARGET_UNIVERSE) fail(`wrong Universe ID: ${target.universeId}`);
if (String(target.placeId) !== TARGET_PLACE) fail(`wrong Place ID: ${target.placeId}`);
if (!target.enabled) fail('registry target disabled');

const runtime = read('maps/bbyavatar/runtime.server.lua');
const client = read('maps/bbyavatar/runtime.client.lua');
const placePath = path.join(ROOT, 'maps/bbyavatar/place.rbxlx');
if (!fs.existsSync(placePath)) fail('generated place.rbxlx missing');
const placeStat = fs.statSync(placePath);
if (placeStat.size < 50000) fail(`generated place suspiciously small: ${placeStat.size} bytes`);
const place = fs.readFileSync(placePath, 'utf8');

// World bootstrap invariants: these catch accidental blank-map regressions before publish.
for (const marker of [
  'BBYAVATAR_SHOWROOM',
  'BBYAVATAR_Spawn',
  'Runway',
  'Brand',
  'FEATURED',
  'TRENDING',
  'NEW DROPS',
  'STREETWEAR',
  'CYBER',
  'LUXURY',
  'CUTE',
  'BALI',
  'CREATORS'
]) requireText(runtime, marker, 'runtime.server.lua');

requireText(runtime, 'OpenCatalog', 'runtime.server.lua');
requireText(client, 'OpenCatalog', 'runtime.client.lua');
requireText(place, 'BBYAVATAR_Runtime', 'place.rbxlx');
requireText(place, 'BBYAVATAR_Client', 'place.rbxlx');
requireText(place, 'BBYAVATAR_SHOWROOM', 'place.rbxlx');
requireText(place, 'BBYAVATAR_Spawn', 'place.rbxlx');

// Guard against publishing an empty shell with only scripts/services.
const partConstructors = (runtime.match(/Instance\.new\("Part"\)/g) || []).length;
if (partConstructors < 1) fail('runtime has no Part constructor');
const spawnConstructors = (runtime.match(/Instance\.new\("SpawnLocation"\)/g) || []).length;
if (spawnConstructors !== 1) fail(`expected exactly one explicit SpawnLocation constructor, found ${spawnConstructors}`);

console.log(JSON.stringify({
  ok: true,
  target: { universeId: TARGET_UNIVERSE, placeId: TARGET_PLACE },
  payloadBytes: placeStat.size,
  worldMarkers: 14,
  bootstrap: 'PASS',
  clientRemote: 'PASS'
}, null, 2));
