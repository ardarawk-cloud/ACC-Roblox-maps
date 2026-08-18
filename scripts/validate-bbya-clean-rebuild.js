const fs=require('fs');
const path=require('path');
const root=process.cwd();
const files=[
  'maps/a-club/place.rbxlx',
  'maps/a-club/rebuild/00-core.lua',
  'maps/a-club/rebuild/10-architecture.lua',
  'maps/a-club/rebuild/20-furnishing.lua',
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
const furnishing=read(files[3]);
const lighting=read(files[4]);
const runtime=read(files[5]);
const qc=read(files[6]);
const assembler=read(files[7]);
if(!place.includes('RBXBBYABLANKWORKSPACE')||!place.includes('RBXBBYABLANKSSS')) bad('base place is not the known blank BBYA file'); else ok('blank base place locked');
if(!core.includes('BBYA CLEAN REBUILD')||!core.includes('BBYAReferenceImage1')) bad('fresh clean rebuild core/reference lock missing'); else ok('fresh core and owner reference lock present');
for(const token of ['CLUB GROUND SLAB','MEZZ LEVEL 1','MEZZ LEVEL 2','DANCE FLOOR','DJ BOOTH','VIP FLOOR','ROOFTOP DECK','POOL BASIN','POOL WATER','STAIR G TO MID','STAIR MID TO ROOF','MAIN BBYA WORDMARK']){
  if(!architecture.includes(token)) bad(`architecture token missing: ${token}`);
}
if(!fail) ok('reference-shaped physical architecture present');
for(const token of ['BBYA QUEEN THRONE','SUPPORT BOARD','ROOFTOP POOL SIGN','VIP SIGN','CITY BUILDING']) if(!furnishing.includes(token)) bad(`furnishing token missing: ${token}`);
if(!fail) ok('Queen/support/VIP/rooftop/city landmarks present');
if(!lighting.includes('BBYACriticalFill')||!lighting.includes('BBYAShowLight')||!lighting.includes('POOL GLOW')) bad('lighting safety/show/resort layers incomplete'); else ok('club + avatar + rooftop lighting layers present');
if(!runtime.includes('SpawnLocation')||!runtime.includes('root.Position.Y < -28')) bad('spawn/fall safety runtime incomplete'); else ok('spawn and fall safety runtime present');
if(!qc.includes('BBYAPhase1QC')||!qc.includes('social seat count below 24')) bad('runtime phase-one QC missing'); else ok('runtime QC present');
if(/maps\/a-club\/v[0-9]+\//.test(assembler)) bad('assembler still references archived v5/v6 source folder'); else ok('assembler has no archived V5/V6 source path');
for(const f of files.slice(1,7)) if(!assembler.includes(f)) bad(`assembler missing fresh module ${f}`);
if(!assembler.includes('RBXBBYABLANKSSS')||!assembler.includes('BBYA_CLEAN_REBUILD_RUNTIME')) bad('assembler does not replace blank SSS with clean runtime'); else ok('clean deterministic assembly target present');
if(fail) process.exit(1);
ok('BBYA clean rebuild static gate complete');
