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
  'maps/a-club/rebuild/35-circulation.lua',
  'maps/a-club/rebuild/30-lighting.lua',
  'maps/a-club/rebuild/40-runtime.server.lua',
  'maps/a-club/rebuild/60-social-systems.server.lua',
  'maps/a-club/rebuild/50-qc.server.lua',
  'maps/a-club/rebuild/70-ui.client.lua',
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
const circulation=read(files[6]);
const lighting=read(files[7]);
const runtime=read(files[8]);
const social=read(files[9]);
const qc=read(files[10]);
const ui=read(files[11]);
const assembler=read(files[12]);

if(!place.includes('RBXBBYABLANKWORKSPACE')||!place.includes('RBXBBYABLANKSSS')||!place.includes('RBXBBYABLANKSTARTERPLAYER')) bad('base place is not the known blank BBYA file'); else ok('blank base place locked');
if(!core.includes('BBYA CLEAN REBUILD')||!core.includes('BBYAReferenceImage1')||!core.includes('PHASE_5_REFERENCE_UI_QC')) bad('fresh clean rebuild phase 5 core/reference lock missing'); else ok('fresh phase 5 core and owner reference lock present');

for(const token of ['CLUB GROUND SLAB','MEZZ LEVEL 1','MEZZ LEVEL 2','DANCE FLOOR','DJ BOOTH','VIP FLOOR','ROOFTOP DECK','POOL BASIN','POOL WATER','STAIR G TO MID','STAIR MID TO ROOF','MAIN BBYA WORDMARK']) if(!architecture.includes(token)) bad(`architecture token missing: ${token}`);
if(!fail) ok('reference-shaped physical architecture present');
if(!architecture.includes('STAIR G TO MID",Vector3.new(94,1.1,72),28,8,.55,.75,0')||!architecture.includes('STAIR MID TO ROOF",Vector3.new(88,16.7,47),28,8,.55,.75,180')) bad('switchback stair directions are not locked to corrected circulation'); else ok('ground-to-roof switchback stair direction locked');

for(const token of ['HERO FACADE PLINTH','ATRIUM HERO GLASS','BRAND TOWER','CLUB BALCONY SLAB','CLUB WING BRAND','VIP FACADE PANEL','VIP PORTAL BRAND','POOL PARTY BILLBOARD','ROOF FRONT FASCIA','BBYAPremiumExterior']) if(!exterior.includes(token)) bad(`premium exterior token missing: ${token}`);
if(!exterior.includes('LEFT_CLUB_CENTER_SOCIAL_RIGHT_VIP_UPPER_POOL')) bad('owner-reference hero silhouette marker missing');
else ok('premium exterior preserves owner-reference hero silhouette');

for(const token of ['BBYA QUEEN THRONE','SUPPORT BOARD','ROOFTOP POOL SIGN','VIP SIGN','CITY BUILDING']) if(!furnishing.includes(token)) bad(`furnishing token missing: ${token}`);
if(!fail) ok('Queen/support/VIP/rooftop/city landmarks present');

for(const token of ['WELCOME BAR BODY','SELFIE WALL','CLUB TRUSS X','SHOW LENS','MEZZ PRIVACY PANEL','VIP BACKBAR','VIP QUEEN NICHE FLOOR','SKY BAR BODY','POOL SOCIAL DAYBED','COURT FLOOR','BBYAPremiumInterior']) if(!interior.includes(token)) bad(`premium interior token missing: ${token}`);
if(!fail) ok('premium social/hospitality interior present');

for(const token of ['CLEAR ARRIVAL CENTER','CLEAR ATRIUM CENTER','CLEAR CLUB THRESHOLD','CLEAR VIP THRESHOLD','CLEAR MID LANDING','CLEAR ROOF LANDING','CLEAR ROOF SOCIAL SPINE','CLEAR POOL WEST WALK','MID LANDING RAIL WEST','ROOF LANDING RAIL EAST','STAIR G EDGE','STAIR ROOF EDGE','BBYACirculation','PHASE_3_LOCKED_CLEAR']) if(!circulation.includes(token)) bad(`circulation token missing: ${token}`);
if(!circulation.includes('BBYAClearLane')||!circulation.includes('BBYACirculationLight')) bad('clear-lane/light attributes missing');
else ok('circulation lanes, landing safety and route lighting present');

if(!lighting.includes('BBYACriticalFill')||!lighting.includes('BBYAShowLight')||!lighting.includes('POOL GLOW')||!lighting.includes('HERO FACADE WASH')||!lighting.includes('PREMIUM_NIGHT_PASS_2')) bad('premium lighting safety/show/resort/facade layers incomplete'); else ok('club + avatar + facade + rooftop lighting layers present');
if(!runtime.includes('SpawnLocation')||!runtime.includes('root.Position.Y < -28')) bad('spawn/fall safety runtime incomplete'); else ok('spawn and fall safety runtime present');

for(const token of ['SUPPORT_PRODUCTS','SUPPORT_ORDER={5,10,50,100,500}','[5]=0','[500]=0','GetSupportConfig','GetSupportBoard','GetSupportSelf','SupportChanged','GetMusicState','MusicStateChanged','BBYA MUSIC','BBYA CLUB GROUP','BBYA ROOFTOP GROUP','CLUB DECK A','CLUB DECK B','ROOFTOP DECK A','ROOFTOP DECK B','EqualizerSoundEffect','CROSSFADE_SECONDS=3.5','MUSIC_LIBRARY={club={},rooftop={}}','ProcessReceipt','BBYA PANEL PROMPT','PHASE_5_REFERENCE_FIDELITY']) if(!social.includes(token)) bad(`phase 5 social-system token missing: ${token}`);
if(social.includes('[25]=0')) bad('non-reference R$25 support tier leaked into phase 5');
if(!social.includes('if supportEnabled then')||!social.includes('Support products pending official IDs')) bad('support commerce is not fail-closed while IDs are zero');
if(!social.includes('Authorized Roblox audio IDs only')||!social.includes('musicLibraryReady=(#MUSIC_LIBRARY.club>0 or #MUSIC_LIBRARY.rooftop>0)')) bad('music authorization/library guard missing');
else ok('exact 5-tier support + dual-deck music backend are fail-closed');

for(const token of ['BBYA SOCIAL UI','MINI PLAYER','SUPPORT / SAWER','YOUR SUPPORT','YOUR RANK','MUSIC CONTROLLER','AUTO DJ','ROOFTOP','DJ MODE','LIBRARY PENDING','EQUALIZER','CROSSFADE','QUEUE','SFX • SAFE MODE','PromptProductPurchase','GetSupportSelf','GetSupportBoard','GetMusicState','SupportChanged','MusicStateChanged','CLEAN VIEW','ViewportSize','math.clamp']) if(!ui.includes(token)) bad(`phase 5 UI token missing: ${token}`);
if(!ui.includes('supportLaunch')||!ui.includes('musicLaunch')||!ui.includes('photoLaunch')||!ui.includes('mini.MouseButton1Click')||!ui.includes('panel.Position=UDim2.fromOffset(x,y)')) bad('mobile launcher/mini-player/recovery layout incomplete');
else ok('reference-fidelity Support/Music/Photo mobile shell present');

if(!qc.includes('BBYAPhase5QC')||!qc.includes('support tier count is not exact reference count 5')||!qc.includes('music deck count is not 4')||!qc.includes('music crossfade value is not 3.5')||!qc.includes('blocked clear lane')||!qc.includes('BBYA REMOTES missing')||!qc.includes('expected exactly one clean rebuild root')) bad('runtime phase-five QC missing'); else ok('runtime phase-five systems/circulation/legacy guard present');

if(/maps\/a-club\/v[0-9]+\//.test(assembler)) bad('assembler still references archived v5/v6 source folder'); else ok('assembler has no archived V5/V6 source path');
for(const f of files.slice(1,12)) if(!assembler.includes(f)) bad(`assembler missing fresh module ${f}`);
if(!assembler.includes('RBXBBYABLANKSSS')||!assembler.includes('BBYA_CLEAN_REBUILD_RUNTIME')) bad('assembler does not replace blank SSS with clean runtime');
if(!assembler.includes('RBXBBYABLANKSTARTERPLAYER')||!assembler.includes('BBYA_CLEAN_SOCIAL_UI')||!assembler.includes('StarterPlayerScripts')) bad('assembler does not inject client UI');
else ok('clean deterministic server + client assembly target present');
const order=['00-core.lua','10-architecture.lua','15-premium-exterior.lua','20-furnishing.lua','25-premium-interior.lua','35-circulation.lua','30-lighting.lua','40-runtime.server.lua','60-social-systems.server.lua','50-qc.server.lua'];
let last=-1;
for(const token of order){const i=assembler.indexOf(token);if(i<=last) bad(`server assembler order invalid at ${token}`);last=i;}
if(assembler.indexOf('70-ui.client.lua')<0) bad('client UI not assembled');
if(!fail) ok('phase 5 clean rebuild source order locked');

if(fail) process.exit(1);
ok('BBYA clean rebuild phase 5 static gate complete');
