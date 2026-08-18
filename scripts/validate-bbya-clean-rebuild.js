const fs=require('fs');
const path=require('path');
const root=process.cwd();
const files=[
  'maps/a-club/place.rbxlx',
  'maps/a-club/rebuild/00-core.lua',
  'maps/a-club/rebuild/10-architecture.lua',
  'maps/a-club/rebuild/15-premium-exterior.lua',
  'maps/a-club/rebuild/20-furnishing.lua',
  'maps/a-club/rebuild/25-premium-interior.lua',
  'maps/a-club/rebuild/30-lighting.lua',
  'maps/a-club/rebuild/40-runtime.server.lua',
  'maps/a-club/rebuild/50-qc.server.lua',
  'scripts/assemble-bbya-v6-preview.js',
];
let fail=false;
const ok=m=>console.log(`[BBYA CLEAN VALIDATE] PASS: ${m}`);
const bad=m=>{fail=true;console.error(`[BBYA CLEAN VALIDATE] FAIL: ${m}`)};
for(const f of files){if(!fs.existsSync(path.join(root,f))) bad(`missing ${f}`)}
if(fail) process.exit(1);
const read=f=>fs.readFileSync(path.join(root,f),'utf8');
const place=read(files[0]);
const core=read(files[1]);
const architecture=read(files[2]);
const exterior=read(files[3]);
const furnishing=read(files[4]);
const interior=read(files[5]);
const lighting=read(files[6]);
const runtime=read(files[7]);
const qc=read(files[8]);
const assembler=read(files[9]);

if(!place.includes('RBXBBYABLANKWORKSPACE')||!place.includes('RBXBBYABLANKSSS')) bad('base place is not the known blank BBYA file'); else ok('blank base place locked');
if(!core.includes('BBYA CLEAN REBUILD')||!core.includes('BBYAReferenceImage1')) bad('fresh clean rebuild core/reference lock missing'); else ok('fresh core and owner reference lock present');

for(const token of ['CLUB GROUND SLAB','MEZZ LEVEL 1','MEZZ LEVEL 2','DANCE FLOOR','DJ BOOTH','VIP FLOOR','ROOFTOP DECK','POOL BASIN','POOL WATER','STAIR G TO MID','STAIR MID TO ROOF','MAIN BBYA WORDMARK']) if(!architecture.includes(token)) bad(`architecture token missing: ${token}`);
if(!fail) ok('reference-shaped physical architecture present');
if(!architecture.includes('STAIR G TO MID",Vector3.new(94,1.1,72),28,8,.55,.75,0')||!architecture.includes('STAIR MID TO ROOF",Vector3.new(88,16.7,47),28,8,.55,.75,180')) bad('switchback stair directions are not locked to corrected circulation'); else ok('ground-to-roof switchback stair direction locked');

for(const token of ['HERO FACADE PLINTH','ATRIUM HERO GLASS','BRAND TOWER','CLUB BALCONY SLAB','CLUB WING BRAND','VIP FACADE PANEL','VIP PORTAL BRAND','POOL PARTY BILLBOARD','ROOF FRONT FASCIA','BBYAPremiumExterior']) if(!exterior.includes(token)) bad(`phase 2 exterior token missing: ${token}`);
if(!exterior.includes('LEFT_CLUB_CENTER_SOCIAL_RIGHT_VIP_UPPER_POOL')) bad('owner-reference hero silhouette marker missing');
else ok('phase 2 exterior preserves owner-reference hero silhouette');

for(const token of ['BBYA QUEEN THRONE','SUPPORT BOARD','ROOFTOP POOL SIGN','VIP SIGN','CITY BUILDING']) if(!furnishing.includes(token)) bad(`furnishing token missing: ${token}`);
if(!fail) ok('Queen/support/VIP/rooftop/city landmarks present');

for(const token of ['WELCOME BAR BODY','SELFIE WALL','CLUB TRUSS X','SHOW LENS','MEZZ PRIVACY PANEL','VIP BACKBAR','VIP QUEEN NICHE FLOOR','SKY BAR BODY','POOL SOCIAL DAYBED','COURT FLOOR','BBYAPremiumInterior']) if(!interior.includes(token)) bad(`phase 2 interior token missing: ${token}`);
if(!fail) ok('phase 2 premium social/hospitality interior present');

if(!lighting.includes('BBYACriticalFill')||!lighting.includes('BBYAShowLight')||!lighting.includes('POOL GLOW')||!lighting.includes('HERO FACADE WASH')||!lighting.includes('PREMIUM_NIGHT_PASS_2')) bad('phase 2 lighting safety/show/resort/facade layers incomplete'); else ok('club + avatar + facade + rooftop lighting layers present');
if(!runtime.includes('SpawnLocation')||!runtime.includes('root.Position.Y < -28')) bad('spawn/fall safety runtime incomplete'); else ok('spawn and fall safety runtime present');
if(!qc.includes('BBYAPhase2QC')||!qc.includes('social seat count below 28')||!qc.includes('expected exactly one clean rebuild root')||!qc.includes('premium exterior marker missing')) bad('runtime phase-two QC missing'); else ok('runtime phase-two QC and legacy-root guard present');

if(/maps\/a-club\/v[0-9]+\//.test(assembler)) bad('assembler still references archived v5/v6 source folder'); else ok('assembler has no archived V5/V6 source path');
for(const f of files.slice(1,9)) if(!assembler.includes(f)) bad(`assembler missing fresh module ${f}`);
if(!assembler.includes('RBXBBYABLANKSSS')||!assembler.includes('BBYA_CLEAN_REBUILD_RUNTIME')) bad('assembler does not replace blank SSS with clean runtime'); else ok('clean deterministic assembly target present');
const order=['00-core.lua','10-architecture.lua','15-premium-exterior.lua','20-furnishing.lua','25-premium-interior.lua','30-lighting.lua','40-runtime.server.lua','50-qc.server.lua'];
let last=-1;
for(const token of order){const i=assembler.indexOf(token);if(i<=last) bad(`assembler order invalid at ${token}`);last=i;}
if(!fail) ok('phase 2 clean rebuild source order locked');

if(fail) process.exit(1);
ok('BBYA clean rebuild phase 2 static gate complete');
