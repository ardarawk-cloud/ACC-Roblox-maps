const fs=require('fs');
const path=require('path');
const root=process.cwd();

const files={
  place:'maps/a-club/place.rbxlx',core:'maps/a-club/rebuild/00-core.lua',architecture:'maps/a-club/rebuild/10-architecture.lua',
  exterior:'maps/a-club/rebuild/15-premium-exterior.lua',furnishing:'maps/a-club/rebuild/20-furnishing.lua',interior:'maps/a-club/rebuild/25-premium-interior.lua',
  circulation:'maps/a-club/rebuild/35-circulation.lua',lighting:'maps/a-club/rebuild/30-lighting.lua',runtime:'maps/a-club/rebuild/40-runtime.server.lua',
  social:'maps/a-club/rebuild/60-social-systems.server.lua',qc:'maps/a-club/rebuild/50-qc.server.lua',release:'maps/a-club/rebuild/80-release-gate.server.lua',
  ui:'maps/a-club/rebuild/70-ui.client.lua',assembler:'scripts/assemble-bbya-v6-preview.js',inspector:'scripts/inspect-bbya-clean-preview.js',
};
let failed=false;
const pass=m=>console.log(`[BBYA V7 CLEAN] PASS: ${m}`);
const fail=m=>{failed=true;console.error(`[BBYA V7 CLEAN] FAIL: ${m}`)};
const src={};
for(const [k,f] of Object.entries(files)){const p=path.join(root,f);if(!fs.existsSync(p)){fail(`missing ${f}`);continue;}src[k]=fs.readFileSync(p,'utf8');}
if(failed) process.exit(1);
const requireTokens=(key,tokens,label)=>{for(const token of tokens) if(!src[key].includes(token)) fail(`${label} missing: ${token}`);};
const forbidTokens=(key,tokens,label)=>{for(const token of tokens) if(src[key].includes(token)) fail(`${label} contains forbidden item: ${token}`);};

if(!src.place.includes('RBXBBYACARRIERWORKSPACE')||!src.place.includes('RBXBBYACARRIERLIGHTING')) fail('minimal BBYA carrier contract changed'); else pass('minimal carrier place locked');
requireTokens('architecture',['CLUB GROUND SLAB','MEZZ LEVEL 1','MEZZ LEVEL 2','DANCE FLOOR','MAIN STAGE','DJ BOOTH','LED WALL','ATRIUM FLOOR','VIP FLOOR','ROOFTOP DECK','POOL BASIN','POOL WATER','POOL DJ ISLAND','STAIR G TO MID','STAIR MID TO ROOF','MAIN BBYA WORDMARK'],'architecture');
requireTokens('exterior',['ATRIUM HERO GLASS','CLUB FACADE FIN','CLUB TOP CORNICE PINK','VIP FACADE PANEL','VIP PORTAL BRAND','ROOF PERGOLA POST','POOL PARTY BILLBOARD','HERO PALM','HERO PLANTER','BBYAReferenceSilhouette'],'exterior');
forbidTokens('exterior',['HERO FACADE PLINTH','BRAND TOWER",Vector3','CLUB BALCONY SLAB','INFINITY EDGE LOWER','ROOF FRONT FASCIA",Vector3'],'exterior');
requireTokens('furnishing',['BBYA QUEEN DECK','BBYA QUEEN THRONE','BBYA QUEEN SIGN','SUPPORT WALL PANEL','SUPPORT BOARD','VIP BAR BODY','POOL LOUNGER','CABANA DAYBED','CITY BUILDING'],'furnishing');
forbidTokens('furnishing',['QUEEN PODIUM','SUPPORT BOARD BODY'],'furnishing');
requireTokens('interior',['WELCOME BAR BODY','SELFIE WALL','CLUB TRUSS X','SHOW LENS','VIP BACKBAR','VIP QUEEN NICHE FLOOR','SKY BAR BODY','POOL SOCIAL DAYBED','ROOF PHOTO FRAME','BBYAPremiumInterior'],'interior');
forbidTokens('interior',['COURT FLOOR','COURT FLOOR STRIP'],'interior');
requireTokens('circulation',['CLEAR ARRIVAL CENTER','CLEAR ATRIUM CENTER','CLEAR CLUB THRESHOLD','CLEAR VIP THRESHOLD','STAIR G EDGE','STAIR ROOF EDGE','CLEAR MID LANDING','CLEAR ROOF LANDING','CLEAR ROOF SOCIAL SPINE','CLEAR POOL WEST WALK','BBYAClearLane','BBYACirculationLight','PHASE_3_LOCKED_CLEAR'],'circulation');
requireTokens('lighting',['BBYACriticalFill','BBYAShowLight','LED PIXEL','TOWER GLOW','ATRIUM WARM','SUPPORT WALL KEY','VIP WARM','BBYA QUEEN KEY','POOL GLOW','HERO FACADE WASH','SOCIAL PHOTO KEY','ROOF LIFESTYLE KEY','V7_CLEAN_REFERENCE_NIGHT'],'lighting');
forbidTokens('lighting',['light(A7,"QUEEN KEY"','light(A7,"SUPPORT KEY"'],'lighting');
requireTokens('runtime',['SpawnLocation','root.Position.Y < -28','V7_CLEAN_PREVIEW'],'runtime');
requireTokens('social',['SUPPORT WALL PANEL','V7_CLEAN_FAIL_CLOSED','BBYASupportTierCount','BBYAMusicDeckCount'],'social');
requireTokens('qc',['removed legacy object survived','BBYAPhase5QC'],'qc');
requireTokens('release',['BBYAReleaseGate','BBYAOwnerPlaytestRequired','V7_CLEAN_FAIL_CLOSED'],'release');
requireTokens('ui',['BBYA SOCIAL UI','SUPPORT','MUSIC','PHOTO'],'ui');
requireTokens('assembler',['00-core.lua','10-architecture.lua','15-premium-exterior.lua','20-furnishing.lua','25-premium-interior.lua','35-circulation.lua','30-lighting.lua','40-runtime.server.lua','60-social-systems.server.lua','50-qc.server.lua','80-release-gate.server.lua','70-ui.client.lua','BBYA_CLEAN_REBUILD_RUNTIME'],'assembler');
forbidTokens('assembler',["'maps/a-club/rebuild/45-owner-layout-fix.server.lua',","'maps/a-club/rebuild/65-live-services.server.lua',","'maps/a-club/rebuild/66-support-receipt-hotfix.server.lua',","'maps/a-club/rebuild/71-ui-consolidate.client.lua',","'maps/a-club/rebuild/72-hybrid-ui.client.lua',","'maps/a-club/rebuild/73-support-ui.client.lua',"],'assembler');
if(/maps\/a-club\/v[0-9]+\//.test(src.assembler)) fail('archived versioned source leaked into assembler');
requireTokens('inspector',['PHASE_6_PREVIEW_GATE','process.exit(1)'],'preview inspector');
if(failed) process.exit(1);
pass('BBYA V7 clean reference source gate complete');
