const fs = require('fs');
const path = require('path');

const EXPECTED = {
  mapId: 'wonderpocket',
  universeId: '8805231520',
  placeId: '124843214013484',
  file: 'maps/wonderpocket/place.rbxlx',
  branch: 'agent/wonderpocket-target',
  confirmation: 'WONDERPOCKET:8805231520:124843214013484',
  buildVersion: '1.3.0-fail-closed-data-safety',
};

function fail(message) {
  console.error(`[WONDERPOCKET CLOSED TEST] BLOCKED: ${message}`);
  process.exit(1);
}

const apiKey = process.env.ROBLOX_API_KEY;
const confirmation = process.env.WONDERPOCKET_CONFIRM_TARGET;
const refName = process.env.GITHUB_REF_NAME;

if (!apiKey) fail('ROBLOX_API_KEY is missing.');
if (confirmation !== EXPECTED.confirmation) fail('target confirmation string does not match the locked WONDERPOCKET target.');
if (refName && refName !== EXPECTED.branch) fail(`workflow branch must be ${EXPECTED.branch}, got ${refName}.`);

const registryPath = path.join(process.cwd(), 'maps/registry.json');
const registry = JSON.parse(fs.readFileSync(registryPath, 'utf8'));
const target = registry.maps?.[EXPECTED.mapId];
if (!target) fail('wonderpocket registry entry is missing.');
if (String(target.universeId) !== EXPECTED.universeId) fail(`unexpected Universe ID ${target.universeId}.`);
if (String(target.placeId) !== EXPECTED.placeId) fail(`unexpected Place ID ${target.placeId}.`);
if (target.file !== EXPECTED.file) fail(`unexpected place file ${target.file}.`);
if (target.enabled !== false) fail('registry must remain disabled for the closed-test branch.');

const configPath = path.join(process.cwd(), 'maps/wonderpocket/GameConfig.lua');
const config = fs.readFileSync(configPath, 'utf8');
if (!config.includes('PublishAllowed = false')) fail('GameConfig.QA.PublishAllowed must remain false for closed-test publishing.');
if (!config.includes(`Version = "${EXPECTED.buildVersion}"`)) fail(`only WONDERPOCKET ${EXPECTED.buildVersion} is accepted by this publisher.`);
if (!config.includes('FailClosedDataLoads = true')) fail('fail-closed DataStore protection must remain enabled.');
if (!config.includes('NoDefaultOverwriteOnReadFailure = true')) fail('no-default-overwrite protection must remain enabled.');

const placePath = path.join(process.cwd(), EXPECTED.file);
if (!fs.existsSync(placePath)) fail('place.rbxlx is missing; run build + QC first.');
const body = fs.readFileSync(placePath);
const text = body.toString('utf8');
if (!text.includes('</roblox>')) fail('place.rbxlx is not valid Roblox XML.');
if (text.includes('BBYA') || text.includes('a-club')) fail('foreign-map token detected in assembled WONDERPOCKET place.');
if (!text.includes(EXPECTED.buildVersion)) fail('assembled place does not contain the locked WONDERPOCKET v1.3 build marker.');

const url = `https://apis.roblox.com/universes/v1/${EXPECTED.universeId}/places/${EXPECTED.placeId}/versions?versionType=Published`;

(async () => {
  console.log('[WONDERPOCKET CLOSED TEST] Locked target verified.');
  console.log(`[WONDERPOCKET CLOSED TEST] Build ${EXPECTED.buildVersion}`);
  console.log(`[WONDERPOCKET CLOSED TEST] Universe ${EXPECTED.universeId} / Place ${EXPECTED.placeId}`);
  console.log('[WONDERPOCKET CLOSED TEST] This updates place code only; it does not change Roblox access/public visibility settings.');

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'x-api-key': apiKey,
      'Content-Type': 'application/xml',
    },
    body,
  });

  const raw = await response.text();
  let payload;
  try { payload = JSON.parse(raw); } catch { payload = { raw }; }
  if (!response.ok) {
    console.error('[WONDERPOCKET CLOSED TEST] Roblox publish failed:', response.status, payload);
    process.exit(1);
  }
  console.log('[WONDERPOCKET CLOSED TEST] Place version publish success:', payload);
})().catch(error => {
  console.error('[WONDERPOCKET CLOSED TEST] Unexpected publish error:', error);
  process.exit(1);
});
