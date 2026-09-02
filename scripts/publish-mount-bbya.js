const fs=require('fs');
const path=require('path');
const crypto=require('crypto');

const apiKey=process.env.ROBLOX_API_KEY;
if(!apiKey) throw new Error('Missing ROBLOX_API_KEY');

const root=process.cwd();
const registry=JSON.parse(fs.readFileSync(path.join(root,'maps/registry.json'),'utf8'));
const target=registry.maps?.['mount-bbya'];
if(!target) throw new Error('Missing mount-bbya registry entry');
if(String(target.universeId)!=='4187755690'||String(target.placeId)!=='11832985967') throw new Error('MOUNT BBYA TARGET LOCK MISMATCH');
if(String(target.file)!=='maps/mount-bbya/place.rbxlx') throw new Error('MOUNT BBYA FILE LOCK MISMATCH');

const identity=JSON.parse(fs.readFileSync(path.join(root,'maps/mount-bbya/IDENTITY.json'),'utf8'));
if(String(identity.universeId)!=='4187755690'||String(identity.placeId)!=='11832985967') throw new Error('MOUNT BBYA IDENTITY LOCK MISMATCH');

const placePath=path.join(root,target.file);
if(!fs.existsSync(placePath)) throw new Error('Generated RBXLX missing');
const body=fs.readFileSync(placePath);
const sha256=crypto.createHash('sha256').update(body).digest('hex');
const expected=String(process.env.EXPECTED_RBXLX_SHA256||'').trim();
if(expected && sha256!==expected) throw new Error(`RBXLX SHA256 mismatch: expected ${expected}, got ${sha256}`);

const sourceCommit=String(process.env.SOURCE_COMMIT||'UNKNOWN');
const url=`https://apis.roblox.com/universes/v1/${target.universeId}/places/${target.placeId}/versions?versionType=Published`;

(async()=>{
  const response=await fetch(url,{method:'POST',headers:{'x-api-key':apiKey,'Content-Type':'application/xml'},body});
  const text=await response.text();
  let payload;try{payload=JSON.parse(text)}catch{payload={raw:text}}
  const receipt={
    project:'MOUNT BBYA',
    status:response.ok?'DEPLOY_SUCCESS':'DEPLOY_FAILED',
    universeId:String(target.universeId),
    placeId:String(target.placeId),
    sourceCommit,
    rbxlxSha256:sha256,
    rbxlxBytes:body.length,
    httpStatus:response.status,
    robloxResponse:payload,
    publishedAt:new Date().toISOString()
  };
  fs.mkdirSync(path.join(root,'deploy-status'),{recursive:true});
  fs.writeFileSync(path.join(root,'deploy-status/mount-bbya-publish-receipt.json'),JSON.stringify(receipt,null,2)+'\n');
  console.log('[MOUNT BBYA PUBLISH RECEIPT]',JSON.stringify(receipt));
  if(!response.ok) process.exit(1);
})();
