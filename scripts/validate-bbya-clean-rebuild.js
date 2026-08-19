const fs=require('fs');
const path=require('path');
const root=process.cwd();

const files={
  place:'maps/a-club/place.rbxlx',
  core:'maps/a-club/rebuild/00-core.lua',
  architecture:'maps/a-club/rebuild/10-architecture.lua',
  exterior:'maps/a-club/rebuild/15-premium-exterior.lua',
  furnishing:'maps/a-club/rebuild/20-furnishing.lua',
  interior:'maps/a-club/rebuild/25-premium-interior.lua',
  circulation:'maps/a-club/rebuild/35-circulation.lua',
  lighting:'maps/a-club/rebuild/30-lighting.lua',
  runtime:'maps/a-club/rebuild/40-runtime.server.lua',
  social:'maps/a-club/rebuild/60-social-systems.server.lua',
  qc:'maps/a-club/rebuild/50-qc.server.lua',
  release:'maps/a-club/rebuild/80-release-gate.server.lua',
  ui:'maps/a-club/rebuild/70-ui.client.lua',
  assembler:'scripts/assemble-bbya-v6-preview.js',
  inspector:'scripts/inspect-bbya-clean-preview.js',
};

let fail=false;
const ok=m=>console.log(`[BBYA CLEAN VALIDATE] PASS: ${m}`);
const bad=m=>{fail=true;console.error(`[BBYA CLEAN VALIDATE] FAIL: ${m}`)};
const read=f=>fs.readFileSync(path.join(root,f),'utf8');
for(const [key,file] of Object.entries(files)) if(!fs.existsSync(path.join(root,file))) bad(`missing ${key}: ${file}`);
if(fail) process.exit(1);
const s=Object.fromEntries(Object.entries(files).map(([k,f])=>[k,read(f)]));

if(!s.place.includes('RBXBBYACARRIERWORKSPACE')||!s.place.includes('RBXBBYACARRIERLIGHTING')) bad('Roblox-accepted carrier anchors missing');
if(s.place.includes('RBXBBYABLANKSSS')||s.place.includes('RBXBBYABLANKSTARTERPLAYER')) bad('obsolete blank service anchors leaked into carrier');
else ok('Roblox-accepted clean carrier locked');

for(const token of ['BBYA CLEAN REBUILD','BBYAReferenceImage1','PHASE_5_REFERENCE_UI_QC']) if(!s.core.includes(token)) bad(`core token missing: ${token}`);
for(const token of ['CLUB GROUND SLAB','MEZZ LEVEL 1','MEZZ LEVEL 2','DANCE FLOOR','DJ BOOTH','VIP FLOOR','ROOFTOP DECK','POOL BASIN','POOL WATER','MAIN BBYA WORDMARK']) if(!s.architecture.includes(token)) bad(`architecture token missing: ${token}`);
for(const token of ['HERO FACADE PLINTH','BRAND TOWER','CLUB WING BRAND','VIP PORTAL BRAND','POOL PARTY BILLBOARD','LEFT_CLUB_CENTER_SOCIAL_RIGHT_VIP_UPPER_POOL']) if(!s.exterior.includes(token)) bad(`exterior token missing: ${token}`);
for(const token of ['BBYA QUEEN THRONE','SUPPORT BOARD','ROOFTOP POOL SIGN','VIP SIGN']) if(!s.furnishing.includes(token)) bad(`furnishing token missing: ${token}`);
for(const token of ['WELCOME BAR BODY','SELFIE WALL','VIP BACKBAR','SKY BAR BODY','POOL SOCIAL DAYBED']) if(!s.interior.includes(token)) bad(`interior token missing: ${token}`);
for(const token of ['CLEAR ARRIVAL CENTER','CLEAR CLUB THRESHOLD','CLEAR VIP THRESHOLD','CLEAR ROOF SOCIAL SPINE','PHASE_3_LOCKED_CLEAR']) if(!s.circulation.includes(token)) bad(`circulation token missing: ${token}`);
if(!s.lighting.includes('PREMIUM_NIGHT_PASS_2')||!s.runtime.includes('SpawnLocation')||!s.runtime.includes('root.Position.Y < -28')) bad('lighting/runtime safety contract incomplete');
else ok('physical build, circulation, lighting and safety contracts present');

for(const token of ['SUPPORT_ORDER={5,10,50,100,500}','[5]=0','[500]=0','GetSupportConfig','GetSupportBoard','GetSupportSelf','BBYA CLUB GROUP','BBYA ROOFTOP GROUP','CLUB DECK A','CLUB DECK B','ROOFTOP DECK A','ROOFTOP DECK B','CROSSFADE_SECONDS=3.5','MUSIC_LIBRARY={club={},rooftop={}}','PHASE_5_REFERENCE_FIDELITY']) if(!s.social.includes(token)) bad(`social token missing: ${token}`);
if(s.social.includes('[25]=0')) bad('non-reference R$25 support tier leaked');
for(const token of ['BBYA SOCIAL UI','MINI PLAYER','SUPPORT / SAWER','MUSIC CONTROLLER','AUTO DJ','DJ MODE','EQUALIZER','CROSSFADE','QUEUE','CLEAN VIEW']) if(!s.ui.includes(token)) bad(`UI token missing: ${token}`);
else ok('support/music/mobile UI reference systems present');

for(const token of ['BBYAPhase5QC','blocked clear lane','expected exactly one clean rebuild root']) if(!s.qc.includes(token)) bad(`QC token missing: ${token}`);
for(const token of ['PHASE_6_PREVIEW_GATE','BBYAReleaseGate','BBYAOwnerPlaytestRequired','RUNTIME_QC_PASS_PENDING_EXTERNAL_IDS_AND_OWNER_PLAYTEST']) if(!s.release.includes(token)) bad(`release-gate token missing: ${token}`);
else ok('runtime QC and release gate present');

if(/maps\/a-club\/v[0-9]+\//.test(s.assembler)) bad('archived V5/V6 source path leaked into assembler');
for(const token of ['RBXBBYACARRIERWORKSPACE','RBXBBYACARRIERLIGHTING','BBYA_CLEAN_RUNTIME_BEGIN','BBYA_CLEAN_REBUILD_RUNTIME','RBXBBYACLEANSTARTERPLAYER','BBYA_CLEAN_SOCIAL_UI']) if(!s.assembler.includes(token)) bad(`assembler token missing: ${token}`);
if(!s.assembler.includes("xml = xml.replace('</roblox>', `${runtime}</roblox>`)") && !s.assembler.includes("xml = xml.replace('</roblox>', `${runtime}</roblox>`);")) bad('assembler does not append clean runtime to carrier');
else ok('clean deterministic carrier assembly present');

for(const token of ['PHASE_6_PREVIEW_GATE','SUPPORT_ORDER={5,10,50,100,500}','MUSIC_LIBRARY={club={},rooftop={}}','expected exactly one assembled server Script','preview unexpectedly contains live Developer Product IDs']) if(!s.inspector.includes(token)) bad(`preview inspector token missing: ${token}`);
if(!s.inspector.includes('process.exit(1)')) bad('preview inspector cannot fail CI');
else ok('assembled preview inspector present');

if(fail) process.exit(1);
ok('BBYA clean rebuild carrier static gate complete');
