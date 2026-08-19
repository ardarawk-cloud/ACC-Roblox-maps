const fs=require('fs');

const preview=process.argv[2]||'/tmp/bbya-clean-rebuild-preview.rbxlx';
let fail=false;
const ok=m=>console.log(`[BBYA V7 PREVIEW] PASS: ${m}`);
const bad=m=>{fail=true;console.error(`[BBYA V7 PREVIEW] FAIL: ${m}`)};

if(!fs.existsSync(preview)){bad(`preview file missing: ${preview}`);process.exit(1);}
const xml=fs.readFileSync(preview,'utf8');
if(xml.length<10000) bad(`preview unexpectedly small: ${xml.length} bytes`); else ok(`preview size ${xml.length} bytes`);

const required=[
  'BBYA_CLEAN_REBUILD_RUNTIME','BBYA_CLEAN_SOCIAL_UI','BBYA CLEAN REBUILD',
  'PHASE_5_REFERENCE_UI_QC','V7_CLEAN_FAIL_CLOSED','PHASE_6_PREVIEW_GATE',
  'BBYAReleaseGate','BBYAPhase5QC','SUPPORT_ORDER={5,10,50,100,500}',
  'BBYAMusicDeckCount','BBYAMusicCrossfadeSeconds','SUPPORT / SAWER',
  'MUSIC CONTROLLER','MINI PLAYER','CLEAN VIEW'
];
for(const token of required) if(!xml.includes(token)) bad(`assembled preview missing token: ${token}`);
if(!fail) ok('V7 runtime/UI/release markers assembled');

for(const forbiddenPath of ['maps/a-club/v5/','maps/a-club/v6/','45-owner-layout-fix.server.lua','65-live-services.server.lua','66-support-receipt-hotfix.server.lua','71-ui-consolidate.client.lua','72-hybrid-ui.client.lua','73-support-ui.client.lua']){
  if(xml.includes(forbiddenPath)) bad(`legacy/duplicate source leak: ${forbiddenPath}`);
}
const xmlObjectsOnly=xml.replace(/<ProtectedString name="Source"><!\[CDATA\[[\s\S]*?\]\]><\/ProtectedString>/g,'');
for(const forbiddenName of ['BBYA Mega Architecture v2','BBYA V6 CLEANROOM ROOT']){
  if(xmlObjectsOnly.includes(`<string name="Name">${forbiddenName}</string>`)) bad(`archived runtime object leak: ${forbiddenName}`);
}

const serverScriptCount=(xml.match(/<Item class="Script"/g)||[]).length;
const localScriptCount=(xml.match(/<Item class="LocalScript"/g)||[]).length;
if(serverScriptCount!==1) bad(`expected exactly one assembled server Script, got ${serverScriptCount}`); else ok('single server runtime');
if(localScriptCount!==1) bad(`expected exactly one assembled LocalScript, got ${localScriptCount}`); else ok('single client runtime');

const supportInline=xml.match(/local SUPPORT_PRODUCTS=\{([^\n}]*)\}/);
if(!supportInline){bad('SUPPORT_PRODUCTS block not found');}
else{
  const amounts=[...supportInline[1].matchAll(/\[(\d+)\]\s*=\s*(\d+)/g)].map(m=>({amount:Number(m[1]),id:Number(m[2])}));
  const tiers=amounts.map(x=>x.amount).sort((a,b)=>a-b).join(',');
  if(tiers!=='5,10,50,100,500') bad(`support tier set mismatch: ${tiers}`); else ok('exact support tier set');
  if(amounts.some(x=>x.id>0)) bad('preview unexpectedly contains live Developer Product IDs'); else ok('support commerce fail-closed');
}

if(!xml.includes('local musicLibraryReady=false')) bad('music fail-closed marker missing');
if(/rbxassetid:\/\/\d+/.test(xml)) bad('preview unexpectedly contains hard-coded Roblox audio IDs');
else ok('authorized audio library remains fail-closed/pending');

if(!xml.includes('RBXBBYACLEANSSS')||!xml.includes('RBXBBYACLEANSTARTERSCRIPTS')) bad('clean runtime referents missing');
else ok('clean runtime referents present');

if(fail) process.exit(1);
ok('assembled BBYA V7 clean preview inspection complete');
