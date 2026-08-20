const fs=require('fs');
const path=require('path');
const apiKey=process.env.ROBLOX_API_KEY;
if(!apiKey) throw new Error('Missing ROBLOX_API_KEY');
const root=process.cwd();
const cfg=JSON.parse(fs.readFileSync(path.join(root,'maps/track-01/track01.config.json'),'utf8'));
if(String(cfg.universeId)!=='10745349805') throw new Error('TRACK 01 Universe ID lock mismatch');
if(String(cfg.placeId)!=='79748872921213') throw new Error('TRACK 01 Place ID lock mismatch');
if(!cfg.enabled) throw new Error('TRACK 01 target disabled');
const placePath=path.join(root,cfg.file);
if(!fs.existsSync(placePath)) throw new Error(`Place file missing: ${cfg.file}`);
const body=fs.readFileSync(placePath);
const url=`https://apis.roblox.com/universes/v1/${cfg.universeId}/places/${cfg.placeId}/versions?versionType=Published`;
const resultDir=path.join(root,'deploy-status');
fs.mkdirSync(resultDir,{recursive:true});
(async()=>{
  const response=await fetch(url,{method:'POST',headers:{'x-api-key':apiKey,'Content-Type':'application/xml'},body});
  const text=await response.text();
  let payload; try{payload=JSON.parse(text);}catch{payload={raw:text};}
  const status={ok:response.ok,httpStatus:response.status,universeId:String(cfg.universeId),placeId:String(cfg.placeId),payload,at:new Date().toISOString(),previewUrl:cfg.previewUrl};
  fs.writeFileSync(path.join(resultDir,'track01-direct.json'),JSON.stringify(status,null,2)+'\n');
  if(!response.ok){console.error('TRACK 01 publish failed',response.status,payload);process.exitCode=1;return;}
  console.log('TRACK 01 publish success',payload);
})();
