const fs = require('fs');
const path = require('path');

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
const body = fs.readFileSync(placePath);
const url = `https://apis.roblox.com/universes/v1/${target.universeId}/places/${target.placeId}/versions?versionType=Published`;
const resultDir = path.join(process.cwd(), 'deploy-status');
fs.mkdirSync(resultDir, { recursive: true });

(async()=>{
  const response = await fetch(url, {
    method:'POST',
    headers:{'x-api-key':apiKey,'Content-Type':'application/xml'},
    body
  });
  const text = await response.text();
  let payload; try { payload=JSON.parse(text); } catch { payload={raw:text}; }
  const status = {
    ok: response.ok,
    httpStatus: response.status,
    universeId: String(target.universeId),
    placeId: String(target.placeId),
    payload,
    at: new Date().toISOString()
  };
  fs.writeFileSync(path.join(resultDir,'becak-e-bike-direct.json'), JSON.stringify(status,null,2)+'\n');
  if (!response.ok) {
    console.error('BECAK E-BIKE publish failed', response.status, payload);
    process.exitCode = 1;
    return;
  }
  console.log('BECAK E-BIKE publish success', payload);
})();
