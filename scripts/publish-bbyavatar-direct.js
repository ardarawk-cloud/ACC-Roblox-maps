const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const apiKey = process.env.ROBLOX_API_KEY;
if (!apiKey) throw new Error('Missing ROBLOX_API_KEY');

const EXPECTED_UNIVERSE = '10744157359';
const EXPECTED_PLACE = '85866320744490';
const registry = JSON.parse(fs.readFileSync(path.join(process.cwd(),'maps/registry.json'),'utf8'));
const target = registry.maps?.bbyavatar;
if (!target) throw new Error('bbyavatar registry target missing');
if (String(target.universeId) !== EXPECTED_UNIVERSE || String(target.placeId) !== EXPECTED_PLACE) {
  throw new Error('BBYAVATAR target lock mismatch');
}

const placePath = path.join(process.cwd(), target.file);
if (!fs.existsSync(placePath)) throw new Error(`Place file missing: ${target.file}`);
const body = fs.readFileSync(placePath);
if (body.length < 1024) throw new Error(`Refusing suspiciously small BBYAVATAR place payload: ${body.length} bytes`);
const bodySha256 = crypto.createHash('sha256').update(body).digest('hex');
const url = `https://apis.roblox.com/universes/v1/${target.universeId}/places/${target.placeId}/versions?versionType=Published`;
const resultDir = path.join(process.cwd(), 'deploy-status');
fs.mkdirSync(resultDir, { recursive: true });

function classifyFailure(httpStatus, payload) {
  const message = JSON.stringify(payload || {}).toLowerCase();
  if (httpStatus === 403 && message.includes('moderated')) return 'OWNER_MODERATION_BLOCK';
  if (httpStatus === 401 || httpStatus === 403) return 'AUTH_OR_PERMISSION_BLOCK';
  if (httpStatus === 429) return 'TRANSIENT_RATE_LIMIT';
  if (httpStatus >= 500) return 'TRANSIENT_ROBLOX_SERVICE';
  if (httpStatus >= 400) return 'PUBLISH_REQUEST_REJECTED';
  return null;
}

(async()=>{
  const startedAt = new Date().toISOString();
  const response = await fetch(url, {
    method:'POST',
    headers:{'x-api-key':apiKey,'Content-Type':'application/xml'},
    body
  });
  const text = await response.text();
  let payload; try { payload=JSON.parse(text); } catch { payload={raw:text}; }
  const blocker = response.ok ? null : classifyFailure(response.status, payload);
  const status = {
    ok: response.ok,
    httpStatus: response.status,
    universeId: String(target.universeId),
    placeId: String(target.placeId),
    sourceFile: target.file,
    payloadBytes: body.length,
    payloadSha256: bodySha256,
    blocker,
    retrySafe: blocker === 'TRANSIENT_RATE_LIMIT' || blocker === 'TRANSIENT_ROBLOX_SERVICE',
    payload,
    startedAt,
    at: new Date().toISOString()
  };
  fs.writeFileSync(path.join(resultDir,'bbyavatar-direct.json'), JSON.stringify(status,null,2)+'\n');
  if (!response.ok) {
    console.error('BBYAVATAR publish failed', response.status, blocker, payload);
    process.exitCode = 1;
    return;
  }
  console.log('BBYAVATAR publish success', payload, bodySha256);
})();
