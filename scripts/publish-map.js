// ACC Roblox Open Cloud publisher + deploy receipt writer v1.3
const fs = require('fs');
const path = require('path');

const mapId = process.argv[2] || process.env.MAP_ID;
const apiKey = process.env.ROBLOX_API_KEY;
const receiptDir = process.env.PUBLISH_RECEIPT_DIR || '';
const placeOverride = process.env.PLACE_FILE_OVERRIDE || '';

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

const selectedFile = placeOverride || target.file;
const placePath = path.isAbsolute(selectedFile) ? selectedFile : path.join(process.cwd(), selectedFile);
if (!fs.existsSync(placePath)) {
  console.error(`Place file not found: ${selectedFile}`);
  process.exit(1);
}

const body = fs.readFileSync(placePath);
const contentType = selectedFile.endsWith('.rbxl') ? 'application/octet-stream' : 'application/xml';
const url = `https://apis.roblox.com/universes/v1/${target.universeId}/places/${target.placeId}/versions?versionType=Published`;
const retryableStatuses = new Set([409, 429, 500, 502, 503, 504]);
const retryDelaysMs = [20_000, 45_000, 90_000, 180_000];

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

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
    publishedFile: selectedFile,
    response: safePayload(payload),
  };
  fs.writeFileSync(path.join(outDir, `${mapId}.json`), JSON.stringify(receipt, null, 2) + '\n');
  console.log(`Deploy receipt written: ${receiptDir}/${mapId}.json`);
}

async function publishOnce(attempt, maxAttempts) {
  console.log(`Publish attempt ${attempt}/${maxAttempts}...`);
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'x-api-key': apiKey,
      'Content-Type': contentType,
    },
    body,
  });

  const text = await response.text();
  let payload;
  try { payload = JSON.parse(text); } catch { payload = { raw: text }; }

  return { response, payload };
}

(async () => {
  console.log(`Publishing ${target.name} (${mapId}) from ${selectedFile} as ${contentType}...`);

  const maxAttempts = retryDelaysMs.length + 1;
  let lastFailure = null;

  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    try {
      const { response, payload } = await publishOnce(attempt, maxAttempts);

      if (response.ok) {
        writeReceipt(payload, 'PUBLISHED');
        console.log('Publish success:', payload);
        return;
      }

      lastFailure = { status: response.status, payload };
      console.error('Roblox publish failed:', response.status, payload);

      if (!retryableStatuses.has(response.status) || attempt >= maxAttempts) {
        break;
      }

      const retryAfterHeader = response.headers.get('retry-after');
      const retryAfterSeconds = Number(retryAfterHeader);
      const fallbackDelay = retryDelaysMs[attempt - 1];
      const delayMs = Number.isFinite(retryAfterSeconds) && retryAfterSeconds > 0
        ? Math.max(fallbackDelay, retryAfterSeconds * 1000)
        : fallbackDelay;

      console.log(`Transient Roblox response ${response.status}; retrying in ${Math.round(delayMs / 1000)}s...`);
      await sleep(delayMs);
    } catch (err) {
      lastFailure = { status: 'NETWORK_ERROR', payload: { message: err?.message || String(err) } };
      console.error('Roblox publish request error:', err?.message || err);

      if (attempt >= maxAttempts) {
        break;
      }

      const delayMs = retryDelaysMs[attempt - 1];
      console.log(`Transient network error; retrying in ${Math.round(delayMs / 1000)}s...`);
      await sleep(delayMs);
    }
  }

  console.error('Roblox publish exhausted retries:', lastFailure);
  process.exit(1);
})().catch((err) => {
  console.error('Unexpected Roblox publish error:', err);
  process.exit(1);
});
