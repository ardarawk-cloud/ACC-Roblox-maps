const fs=require('fs');

const preview=process.argv[2]||'/tmp/bbya-clean-rebuild-preview.rbxlx';
let fail=false;
const ok=m=>console.log(`[BBYA PREVIEW INSPECT] PASS: ${m}`);
const bad=m=>{fail=true;console.error(`[BBYA PREVIEW INSPECT] FAIL: ${m}`)};

if(!fs.existsSync(preview)){
  bad(`preview file missing: ${preview}`);
  process.exit(1);
}
const xml=fs.readFileSync(preview,'utf8');
if(xml.length<10000) bad(`preview unexpectedly small: ${xml.length} bytes`); else ok(`preview size ${xml.length} bytes`);

const required=[
  'BBYA_CLEAN_REBUILD_RUNTIME',
  'BBYA_CLEAN_SOCIAL_UI',
  'BBYA CLEAN REBUILD',
  'PHASE_5_REFERENCE_UI_QC',
  'PHASE_5_REFERENCE_FIDELITY',
  'PHASE_6_PREVIEW_GATE',
  'BBYAReleaseGate',
  'BBYAPhase5QC',
  'SUPPORT_ORDER={5,10,50,100,500}',
  'MUSIC_LIBRARY={club={},rooftop={}}',
  'CROSSFADE_SECONDS=3.5',
  'SUPPORT / SAWER',
  'MUSIC CONTROLLER',
  'MINI PLAYER',
  'CLEAN VIEW',
];
for(const token of required){
  if(!xml.includes(token)) bad(`assembled preview missing token: ${token}`);
}
if(!fail) ok('phase 5 runtime/UI plus phase 6 release-gate markers assembled');

// Source paths must be clean. Runtime-name checks must ignore Lua source text because QC intentionally
// contains old root names as rejection strings. Strip ProtectedString source before inspecting XML object names.
for(const forbiddenPath of ['maps/a-club/v5/','maps/a-club/v6/']){
  if(xml.includes(forbiddenPath)) bad(`archived source path leak: ${forbiddenPath}`);
}
const xmlObjectsOnly=xml.replace(/<ProtectedString name="Source"><!\[CDATA\[[\s\S]*?\]\]><\/ProtectedString>/g,'');
for(const forbiddenName of ['BBYA Mega Architecture v2','BBYA V6 CLEANROOM ROOT']){
  const needle=`<string name="Name">${forbiddenName}</string>`;
  if(xmlObjectsOnly.includes(needle)) bad(`archived runtime object leak: ${forbiddenName}`);
}
if(!fail) ok('no archived BBYA source path or runtime object detected');

const serverScriptCount=(xml.match(/<Item class="Script"/g)||[]).length;
const localScriptCount=(xml.match(/<Item class="LocalScript"/g)||[]).length;
if(serverScriptCount!==1) bad(`expected exactly one assembled server Script, got ${serverScriptCount}`); else ok('single assembled server runtime');
if(localScriptCount!==1) bad(`expected exactly one assembled LocalScript, got ${localScriptCount}`); else ok('single assembled client UI runtime');

const supportBlock=xml.match(/local SUPPORT_PRODUCTS=\{([\s\S]*?)\n\}/);
if(!supportBlock){
  bad('SUPPORT_PRODUCTS block not found');
}else{
  const amounts=[...supportBlock[1].matchAll(/\[(\d+)\]\s*=\s*(\d+)/g)].map(m=>({amount:Number(m[1]),id:Number(m[2])}));
  const tiers=amounts.map(x=>x.amount).sort((a,b)=>a-b).join(',');
  if(tiers!=='5,10,50,100,500') bad(`support tier set mismatch: ${tiers}`); else ok('exact owner-reference support tier set');
  const live=amounts.filter(x=>x.id>0);
  if(live.length>0) bad('preview unexpectedly contains live Developer Product IDs'); else ok('support commerce remains fail-closed');
}

const musicBlock=xml.match(/local MUSIC_LIBRARY=\{club=\{([\s\S]*?)\},rooftop=\{([\s\S]*?)\}\}/);
if(!musicBlock){
  bad('MUSIC_LIBRARY block not found');
}else if(musicBlock[1].trim()!==''||musicBlock[2].trim()!==''){
  bad('preview unexpectedly contains unverified music library entries');
}else{
  ok('authorized music library remains fail-closed/pending');
}

if(!xml.includes('RBXBBYACLEANSSS')||!xml.includes('RBXBBYACLEANSTARTERSCRIPTS')) bad('clean runtime referents missing');
else ok('clean server/client referents present');

if(fail) process.exit(1);
ok('assembled BBYA clean preview inspection complete');
