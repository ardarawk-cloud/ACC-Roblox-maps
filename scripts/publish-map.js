// ACC Roblox Open Cloud publisher + deploy receipt writer v1.5
const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

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

const contentType = selectedFile.endsWith('.rbxl') ? 'application/octet-stream' : 'application/xml';
const url = `https://apis.roblox.com/universes/v1/${target.universeId}/places/${target.placeId}/versions?versionType=Published`;
const retryableStatuses = new Set([409, 429, 500, 502, 503, 504]);
const retryDelaysMs = [10_000, 20_000, 45_000];

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

function publishOnce(attempt, maxAttempts) {
  console.log(`Publish attempt ${attempt}/${maxAttempts}...`);
  const marker = '__ACC_HTTP_STATUS__:';
  const result = spawnSync('curl', [
    '--silent', '--show-error', '--location',
    '--http1.1', '--ipv4',
    '--connect-timeout', '30', '--max-time', '300',
    '--request', 'POST',
    '--header', `x-api-key: ${apiKey}`,
    '--header', `Content-Type: ${contentType}`,
    '--header', 'Expect:',
    '--header', 'Connection: close',
    '--data-binary', `@${placePath}`,
    '--write-out', `\n${marker}%{http_code}`,
    url,
  ], { encoding: 'utf8', maxBuffer: 20 * 1024 * 1024 });

  if (result.error) throw result.error;
  if (result.status !== 0) {
    const msg = (result.stderr || '').trim() || `curl exited ${result.status}`;
    throw new Error(msg);
  }

  const out = result.stdout || '';
  const idx = out.lastIndexOf(`\n${marker}`);
  if (idx < 0) throw new Error('curl response missing HTTP status');
  const text = out.slice(0, idx).trim();
  const status = Number(out.slice(idx + marker.length + 1).trim());
  let payload;
  try { payload = JSON.parse(text); } catch { payload = { raw: text }; }

  return { status, ok: status >= 200 && status < 300, payload };
}

(async () => {
  console.log(`Publishing ${target.name} (${mapId}) from ${selectedFile} as ${contentType} via curl/http1.1...`);

  const maxAttempts = retryDelaysMs.length + 1;
  let lastFailure = null;

  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    try {
      const { status, ok, payload } = publishOnce(attempt, maxAttempts);

      if (ok) {
        writeReceipt(payload, 'PUBLISHED');
        console.log('Publish success:', payload);
        return;
      }

      lastFailure = { status, payload };
      console.error('Roblox publish failed:', status, payload);

      if (!retryableStatuses.has(status) || attempt >= maxAttempts) break;
      const delayMs = retryDelaysMs[attempt - 1];
      console.log(`Transient Roblox response ${status}; retrying in ${Math.round(delayMs / 1000)}s...`);
      await sleep(delayMs);
    } catch (err) {
      lastFailure = { status: 'NETWORK_ERROR', payload: { message: err?.message || String(err) } };
      console.error('Roblox publish request error:', err?.message || err);
      if (attempt >= maxAttempts) break;
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
