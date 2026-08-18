// ACC Roblox Open Cloud publisher + deploy receipt writer v1.1
const fs = require('fs');
const path = require('path');

const mapId = process.argv[2] || process.env.MAP_ID;
const apiKey = process.env.ROBLOX_API_KEY;
const receiptDir = process.env.PUBLISH_RECEIPT_DIR || '';

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

function safePayload(payload) {
  if (!payload || typeof payload !== 'object') return payload;
  const clone = JSON.parse(JSON.stringify(payload));
  for (const key of ['apiKey', 'token', 'authorization', 'secret']) {
    if (key in clone) delete clone[key];
  }
  return clone;
}

function writeReceipt(payload, status) {
  if (!receiptDir) return;
  const outDir = path.join(process.cwd(), receiptDir);
  fs.mkdirSync(outDir, { recursive: true });
  const receipt = {
    status,
    mapId,
    name: target.name,
    universeId: String(target.universeId),
    placeId: String(target.placeId),
    sourceCommit: process.env.GITHUB_SHA || '',
    publishedAt: new Date().toISOString(),
    response: safePayload(payload),
  };
  fs.writeFileSync(path.join(outDir, `${mapId}.json`), JSON.stringify(receipt, null, 2) + '\n');
  console.log(`Deploy receipt written: ${receiptDir}/${mapId}.json`);
}

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

  writeReceipt(payload, 'PUBLISHED');
  console.log('Publish success:', payload);
})().catch((err) => {
  console.error('Unexpected Roblox publish error:', err);
  process.exit(1);
});
