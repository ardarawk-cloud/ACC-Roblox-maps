const fs = require('fs');
const path = require('path');

const apiKey = process.env.ROBLOX_API_KEY;
if (!apiKey) throw new Error('Missing ROBLOX_API_KEY');

const registry = JSON.parse(fs.readFileSync(path.join(process.cwd(),'maps/registry.json'),'utf8'));
const target = registry.maps?.['mountain-social'];
if (!target) throw new Error('mountain-social registry target missing');
if (String(target.universeId) !== '10744139279' || String(target.placeId) !== '82661754996018') throw new Error('Mountain target lock mismatch');

const placePath = path.join(process.cwd(), target.file);
if (!fs.existsSync(placePath)) throw new Error(`Place file missing: ${target.file}`);
const body = fs.readFileSync(placePath);
const url = `https://apis.roblox.com/universes/v1/${target.universeId}/places/${target.placeId}/versions?versionType=Published`;

(async()=>{
  const response = await fetch(url, {method:'POST', headers:{'x-api-key':apiKey,'Content-Type':'application/xml'}, body});
  const text = await response.text();
  let payload; try { payload=JSON.parse(text); } catch { payload={raw:text}; }
  if (!response.ok) { console.error('Mountain closed-test publish failed', response.status, payload); process.exit(1); }
  console.log('Mountain closed-test publish success', payload);
})();
