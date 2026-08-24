// BECAK E-BIKE dedicated Open Cloud publisher v1.1
// Hard-locked to Universe 10745325613 / Place 80994730522893.
const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const apiKey = process.env.ROBLOX_API_KEY;
if (!apiKey) throw new Error('Missing ROBLOX_API_KEY');

const registry = JSON.parse(fs.readFileSync(path.join(process.cwd(),'maps/registry.json'),'utf8'));
const target = registry.maps?.['becak-e-bike'];
if (!target) throw new Error('becak-e-bike registry target missing');
if (String(target.universeId) !== '10745325613' || String(target.placeId) !== '80994730522893') {
  throw new Error('BECAK E-BIKE target lock mismatch');
}
if (!target.enabled) throw new Error('BECAK E-BIKE target disabled');

const placePath = path.join(process.cwd(), target.file);
if (!fs.existsSync(placePath)) throw new Error(`Place file missing: ${target.file}`);
const contentType = target.file.endsWith('.rbxl') ? 'application/octet-stream' : 'application/xml';
const url = `https://apis.roblox.com/universes/v1/${target.universeId}/places/${target.placeId}/versions?versionType=Published`;
const resultDir = path.join(process.cwd(), 'deploy-status');
const resultPath = path.join(resultDir, 'becak-e-bike-direct.json');
fs.mkdirSync(resultDir, { recursive: true });

const retryableStatuses = new Set([409, 429, 500, 502, 503, 504]);
const retryDelaysMs = [15_000, 30_000, 60_000, 120_000];
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

function safePayload(payload) {
  if (!payload || typeof payload !== 'object') return payload;
  const clone = JSON.parse(JSON.stringify(payload));
  for (const key of ['apiKey', 'token', 'authorization', 'secret']) {
    if (key in clone) delete clone[key];
  }
  return clone;
}

function writeStatus(ok, httpStatus, payload, attempts) {
  const status = {
    ok,
    httpStatus,
    universeId: String(target.universeId),
    placeId: String(target.placeId),
    payload: safePayload(payload),
    attempts,
    publisher: 'becak-direct-curl-v1.1',
    sourceCommit: process.env.GITHUB_SHA || '',
    at: new Date().toISOString()
  };
  fs.writeFileSync(resultPath, JSON.stringify(status, null, 2) + '\n');
  return status;
}

function publishOnce(attempt, maxAttempts) {
  console.log(`BECAK E-BIKE publish attempt ${attempt}/${maxAttempts} via curl...`);
  const marker = '__BECAK_HTTP_STATUS__:';
  const result = spawnSync('curl', [
    '--silent', '--show-error', '--location',
    '--connect-timeout', '30', '--max-time', '300',
    '--request', 'POST',
    '--header', `x-api-key: ${apiKey}`,
    '--header', `Content-Type: ${contentType}`,
    '--data-binary', `@${placePath}`,
    '--write-out', `\n${marker}%{http_code}`,
    url,
  ], { encoding: 'utf8', maxBuffer: 20 * 1024 * 1024 });

  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error((result.stderr || '').trim() || `curl exited ${result.status}`);
  }

  const out = result.stdout || '';
  const markerLine = `\n${marker}`;
  const idx = out.lastIndexOf(markerLine);
  if (idx < 0) throw new Error('curl response missing HTTP status');

  const text = out.slice(0, idx).trim();
  const status = Number(out.slice(idx + markerLine.length).trim());
  let payload;
  try { payload = JSON.parse(text); } catch { payload = { raw: text }; }
  return { status, ok: status >= 200 && status < 300, payload };
}

(async () => {
  const maxAttempts = retryDelaysMs.length + 1;
  let lastFailure = { status: 'NO_ATTEMPT', payload: {} };

  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    try {
      const result = publishOnce(attempt, maxAttempts);
      if (result.ok) {
        const receipt = writeStatus(true, result.status, result.payload, attempt);
        console.log('BECAK E-BIKE publish success', receipt.payload);
        return;
      }

      lastFailure = result;
      console.error('BECAK E-BIKE publish failed', result.status, result.payload);
      if (!retryableStatuses.has(result.status) || attempt >= maxAttempts) break;
    } catch (err) {
      lastFailure = { status: 'NETWORK_ERROR', payload: { message: err?.message || String(err) } };
      console.error('BECAK E-BIKE publish request error', lastFailure.payload.message);
      if (attempt >= maxAttempts) break;
    }

    const delayMs = retryDelaysMs[attempt - 1];
    console.log(`Retrying dedicated Becak publish in ${Math.round(delayMs / 1000)}s...`);
    await sleep(delayMs);
  }

  writeStatus(false, lastFailure.status, lastFailure.payload, maxAttempts);
  process.exitCode = 1;
})().catch((err) => {
  writeStatus(false, 'UNEXPECTED_ERROR', { message: err?.message || String(err) }, 0);
  console.error('Unexpected BECAK E-BIKE publish error', err);
  process.exitCode = 1;
});
