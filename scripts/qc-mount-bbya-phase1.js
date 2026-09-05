const fs=require('fs');
const path=require('path');
const root=process.cwd();
const registry=JSON.parse(fs.readFileSync(path.join(root,'maps/registry.json'),'utf8'));
const t=registry.maps?.['mount-bbya'];
const fail=m=>{throw new Error('[MOUNT BBYA QC] '+m)};
if(!t) fail('registry entry missing');
if(String(t.universeId)!=='4187755690') fail('Universe ID mismatch');
if(String(t.placeId)!=='11832985967') fail('Place ID mismatch');
if(String(t.file)!=='maps/mount-bbya/place.rbxlx') fail('file target mismatch');
const identity=JSON.parse(fs.readFileSync(path.join(root,'maps/mount-bbya/IDENTITY.json'),'utf8'));
if(String(identity.universeId)!=='4187755690'||String(identity.placeId)!=='11832985967') fail('IDENTITY.json mismatch');

const required=['mount-bbya.phase1v67.environment.server.lua','systems/checkpoint.server.lua','systems/ambience.server.lua','mountain.performance.client.lua'];
for(const rel of required){const p=path.join(root,'maps/mount-bbya',rel);if(!fs.existsSync(p)||fs.statSync(p).size<500) fail('missing/too small '+rel)}

const env=fs.readFileSync(path.join(root,'maps/mount-bbya/mount-bbya.phase1v67.environment.server.lua'),'utf8');
for(const marker of [
 'V6.7_RESEARCH_GROUNDED_SINGLE_SOURCE',
 'SPAWN_TO_CP1_ONLY',
 'Terrain:FillWedge',
 'HighlandHouse_',
 'CoffeeShrub',
 'CitrusTree',
 'MatureHighlandTree',
 'JALUR PENDAKIAN  •  POS 1',
 'POS 1  •  MOUNT BBYA',
 'TrailRiseStuds',
 'EnvironmentResearchReady'
]) if(!env.includes(marker)) fail('v6.7 environment marker missing '+marker);
if(env.includes('CP02_POS2')||env.includes('CheckpointIndex",2')) fail('CP2+ content detected in environment authority');
if(/RiceBlade|Enum\.Material\.Water/.test(env)) fail('wet-rice visual language leaked into Kintamani-inspired v6.7 environment');
if(!/FillWedge/.test(env)||/shallowMound|FillBall\(Vector3\.new\([^\n]*top-r/.test(env)) fail('layered ridge terrain authority missing or dome terrain helper leaked');

const injector=fs.readFileSync(path.join(root,'scripts/inject-mount-bbya.js'),'utf8');
for(const retired of ['MountBBYA_Phase1_Visual61','MountBBYA_Phase1_Premium65','MountBBYA_SignFacingFix']) if(injector.includes(retired)) fail('retired visual patch chain still active: '+retired);
for(const marker of ['MountBBYA_Phase1_Environment67','V67_RESEARCH_GROUNDED_SINGLE_ENVIRONMENT_AUTHORITY','EnvironmentResearchReady']) if(!injector.includes(marker)) fail('injector missing '+marker);

const rbxlx=fs.readFileSync(path.join(root,t.file),'utf8');
for(const marker of ['<roblox','MountBBYA_Bootstrap','MountBBYA_Phase1_Environment67','MountBBYA_Checkpoint','MountBBYA_Ambience','MountBBYA_Release','MountBBYA_QC','V6.7_RESEARCH_GROUNDED_SINGLE_SOURCE','EnvironmentResearchReady','mount-bbya-v6.7-research-grounded']) if(!rbxlx.includes(marker)) fail('generated RBXLX missing '+marker);
for(const retired of ['MountBBYA_Phase1_Visual61','MountBBYA_Phase1_Premium65','MountBBYA_SignFacingFix']) if(rbxlx.includes(retired)) fail('retired runtime script still packaged: '+retired);
if(rbxlx.includes('10744139279')||rbxlx.includes('82661754996018')) fail('Mountain Social target leaked into candidate');
if(rbxlx.includes('CP02_POS2')||rbxlx.includes('CheckpointIndex\",2')) fail('CP2+ content detected');

console.log('[MOUNT BBYA QC] PASS');
console.log(JSON.stringify({
 target:{universeId:String(t.universeId),placeId:String(t.placeId)},
 bytes:Buffer.byteLength(rbxlx),
 scope:'SPAWN_TO_CP1_ONLY',
 environmentAuthority:'V6.7_RESEARCH_GROUNDED_SINGLE_SOURCE',
 agriculture:'KINTAMANI_INSPIRED_COFFEE_CITRUS',
 trail:'CONTINUOUS_GRADE_NO_OBBY',
 publish:false
},null,2));
