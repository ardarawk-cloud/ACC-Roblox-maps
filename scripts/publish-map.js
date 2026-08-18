// ACC Roblox Open Cloud publish probe: V2 secret migration test
const fs = require('fs');
const path = require('path');

const mapId = process.argv[2] || process.env.MAP_ID;
const apiKey = process.env.ROBLOX_API_KEY;

if (!mapId) {
  console.error('Missing map id. Usage: node scripts/publish-map.js <map-id>');
  process.exit(1);
}
if (!apiKey) {
  console.error('Missing ROBLOX_API_KEY secret.');
  process.exit(1);
}

const registry = JSON.parse(fs.readFileSync(path.join(process.cwd(), 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) {
  console.error(`Unknown map id: ${mapId}`);
  process.exit(1);
}
if (!target.enabled) {
  console.error(`Map ${mapId} is disabled in registry.json.`);
  process.exit(1);
}
if (!/^\d+$/.test(String(target.universeId)) || !/^\d+$/.test(String(target.placeId))) {
  console.error(`Map ${mapId} has invalid Universe ID or Place ID.`);
  process.exit(1);
}

const placePath = path.join(process.cwd(), target.file);
if (!fs.existsSync(placePath)) {
  console.error(`Place file not found: ${target.file}`);
  process.exit(1);
}

const body = fs.readFileSync(placePath);
const contentType = target.file.endsWith('.rbxl') ? 'application/octet-stream' : 'application/xml';
const url = `https://apis.roblox.com/universes/v1/${target.universeId}/places/${target.placeId}/versions?versionType=Published`;

(async () => {
  console.log(`Publishing ${target.name} (${mapId})...`);
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'x-api-key': apiKey,
      'Content-Type': contentType
    },
    body
  });

  const text = await response.text();
  let payload;
  try { payload = JSON.parse(text); } catch { payload = { raw: text }; }

  if (!response.ok) {
    console.error('Roblox publish failed:', response.status, payload);
    process.exit(1);
  }

  console.log('Publish success:', payload);
})();
