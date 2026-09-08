const fs = require('fs');
const path = require('path');

const apiKey = process.env.ROBLOX_API_KEY;
if (!apiKey) throw new Error('Missing ROBLOX_API_KEY');
const registry = JSON.parse(fs.readFileSync(path.join(process.cwd(),'maps/registry.json'),'utf8'));
const target = registry.maps?.['mount-bbya'];
if (!target) throw new Error('mount-bbya registry target missing');
if (String(target.universeId) !== '4187755690' || String(target.placeId) !== '11832985967') throw new Error('MOUNT BBYA target lock mismatch');
if (String(target.universeId) === '10744139279' || String(target.placeId) === '82661754996018') throw new Error('FORBIDDEN Mountain Social target');

const placePath = path.join(process.cwd(),target.file);
if (!fs.existsSync(placePath)) throw new Error(`Place missing: ${target.file}`);
const body = fs.readFileSync(placePath);
for (const marker of ['MOUNT_BBYA_V11_World','visual-lock-rebuild-v1.1']) {
  if (!body.includes(Buffer.from(marker))) throw new Error(`Generated place marker absent: ${marker}`);
}
if (body.includes(Buffer.from('ACC_MountainSocial'))) throw new Error('Legacy Mountain Social marker detected');

const url=`https://apis.roblox.com/universes/v1/${target.universeId}/places/${target.placeId}/versions?versionType=Published`;
(async()=>{
  const response=await fetch(url,{method:'POST',headers:{'x-api-key':apiKey,'Content-Type':'application/xml'},body});
  const text=await response.text();
  let payload;try{payload=JSON.parse(text)}catch{payload={raw:text}}
  if(!response.ok){console.error('MOUNT BBYA v1.1 publish failed',response.status,payload);process.exit(1)}
  console.log('MOUNT BBYA v1.1 publish success',payload);
})();
