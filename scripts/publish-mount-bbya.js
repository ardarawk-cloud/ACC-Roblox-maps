const fs = require('fs');
const path = require('path');

const apiKey = process.env.ROBLOX_API_KEY;
if (!apiKey) throw new Error('Missing ROBLOX_API_KEY');

const root = process.cwd();
const registry = JSON.parse(fs.readFileSync(path.join(root,'maps/registry.json'),'utf8'));
const target = registry.maps?.['mount-bbya'];
if (!target) throw new Error('mount-bbya registry target missing');
if (String(target.universeId) !== '4187755690' || String(target.placeId) !== '11832985967') {
  throw new Error('MOUNT BBYA target lock mismatch');
}
if (target.file !== 'maps/mount-bbya/place.rbxlx') throw new Error(`Unexpected MOUNT BBYA place path: ${target.file}`);

const config = JSON.parse(fs.readFileSync(path.join(root,'maps/mount-bbya/mount-bbya.config.json'),'utf8'));
if (config.publish?.enabled !== true) throw new Error('MOUNT BBYA publish is not explicitly enabled by config');
if (config.sourceVersion !== '7.0.0-full-map-reset') throw new Error('Unexpected MOUNT BBYA sourceVersion');
if (String(config.publishTarget?.universeId) !== String(target.universeId) || String(config.publishTarget?.placeId) !== String(target.placeId)) {
  throw new Error('MOUNT BBYA config/registry target mismatch');
}

const placePath = path.join(root,target.file);
if (!fs.existsSync(placePath)) throw new Error(`Place file missing: ${target.file}`);
const body = fs.readFileSync(placePath);
if (body.length < 20000) throw new Error(`Place file unexpectedly small: ${body.length}`);
const text = body.toString('utf8');
for (const marker of ['7.0.0-full-map-reset','VISUALIZER_20CP_WITA','MOUNT_BBYA_V70_FullMapAuthority','CP 20 - PUNCAK GUNUNG NUSANTARA','SummitPhotoSpot_3142MDPL']) {
  if (!text.includes(marker)) throw new Error(`Missing v7.0 publish marker: ${marker}`);
}
if (text.includes('ACC_Mountain_V64_Terrain') || text.includes('v6.4-phase1-multiscript-runtime')) {
  throw new Error('Legacy v6.4 runtime found in v7.0 place; refusing publish');
}

const url = `https://apis.roblox.com/universes/v1/${target.universeId}/places/${target.placeId}/versions?versionType=Published`;
(async()=>{
  const response = await fetch(url,{method:'POST',headers:{'x-api-key':apiKey,'Content-Type':'application/xml'},body});
  const responseText = await response.text();
  let payload;
  try { payload=JSON.parse(responseText); } catch { payload={raw:responseText}; }
  if (!response.ok) {
    console.error('MOUNT BBYA v7.0 publish failed',response.status,payload);
    process.exit(1);
  }
  console.log('MOUNT BBYA v7.0 publish success',JSON.stringify(payload));
})();
