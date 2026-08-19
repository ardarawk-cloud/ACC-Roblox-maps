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

let failed=false;
const pass=m=>console.log(`[BBYA V7] PASS: ${m}`);
const fail=m=>{failed=true;console.error(`[BBYA V7] FAIL: ${m}`)};
const src={};
for(const [k,f] of Object.entries(files)){
  const p=path.join(root,f);
  if(!fs.existsSync(p)){fail(`missing ${f}`);continue;}
  src[k]=fs.readFileSync(p,'utf8');
}
if(failed) process.exit(1);

const requireTokens=(key,tokens,label)=>{
  for(const token of tokens) if(!src[key].includes(token)) fail(`${label} missing: ${token}`);
};
const forbidTokens=(key,tokens,label)=>{
  for(const token of tokens) if(src[key].includes(token)) fail(`${label} still contains removed item: ${token}`);
};

if(!src.place.includes('RBXBBYABLANKWORKSPACE')||!src.place.includes('RBXBBYABLANKSSS')) fail('blank BBYA base place contract changed');
else pass('blank place contract locked');

requireTokens('architecture',[
  'LEFT CLUB WING — 3-TIER HERO MASS','CLUB GROUND SLAB','MEZZ LEVEL 1','MEZZ LEVEL 2',
  'DANCE FLOOR','MAIN STAGE','DJ BOOTH','LED WALL','CENTER SOCIAL ATRIUM','VIP FLOOR',
  'ROOFTOP DECK','POOL BASIN','POOL WATER','POOL DJ ISLAND','STAIR G TO MID','STAIR MID TO ROOF',
  'MAIN BBYA WORDMARK','BBYAHeroComposition','LEFT_CLUB_CENTER_SOCIAL_RIGHT_VIP_UPPER_POOL'
],'architecture');
pass('reference hero massing present');

requireTokens('exterior',[
  'ATRIUM HERO GLASS','ATRIUM HERO CANOPY','CLUB FACADE FIN','CLUB TOP CORNICE PINK',
  'VIP FACADE PANEL','VIP PORTAL BRAND','ROOF PERGOLA POST','POOL PARTY BILLBOARD',
  'HERO PALM','HERO PLANTER','BBYAReferenceSilhouette'
],'exterior');
forbidTokens('exterior',['HERO FACADE PLINTH','BRAND TOWER",Vector3','CLUB BALCONY SLAB','INFINITY EDGE LOWER','ROOF FRONT FASCIA",Vector3'],'exterior');
pass('exterior is detail-only, without duplicate structural masses');

requireTokens('furnishing',[
  'ARRIVAL SEAT','ATRIUM SOFA','CLUB WATCH SOFA','VIP BAR BODY','POOL LOUNGER',
  'BBYA QUEEN THRONE','SUPPORT BOARD','ROOFTOP POOL SIGN','CITY BUILDING'
],'furnishing');
pass('social furnishing destinations present');

requireTokens('interior',[
  'WELCOME BAR BODY','SELFIE WALL','CLUB TRUSS X','SHOW LENS','MEZZ PRIVACY PANEL',
  'VIP BACKBAR','VIP QUEEN NICHE FLOOR','SKY BAR BODY','POOL SOCIAL DAYBED','ROOF PHOTO FRAME',
  'BBYAPremiumInterior'
],'interior');
forbidTokens('interior',['COURT FLOOR','COURT FLOOR STRIP'],'interior');
pass('interior keeps reference-relevant hospitality details only');

requireTokens('circulation',[
  'CLEAR ARRIVAL CENTER','CLEAR ATRIUM CENTER','CLEAR CLUB THRESHOLD','CLEAR VIP THRESHOLD',
  'STAIR G EDGE','STAIR ROOF EDGE','CLEAR MID LANDING','CLEAR ROOF LANDING',
  'CLEAR ROOF SOCIAL SPINE','CLEAR POOL WEST WALK','BBYAClearLane','BBYACirculationLight',
  'PHASE_3_LOCKED_CLEAR'
],'circulation');
pass('arrival, club/VIP, stairs and rooftop clear lanes locked');

requireTokens('lighting',[
  'BBYACriticalFill','BBYAShowLight','LED PIXEL','TOWER GLOW','ATRIUM WARM','VIP WARM',
  'POOL GLOW','HERO FACADE WASH','SOCIAL PHOTO KEY','MEZZ LOUNGE WARM','ROOF LIFESTYLE KEY',
  'PREMIUM_NIGHT_PASS_2'
],'lighting');
forbidTokens('lighting',['QUEEN KEY','SUPPORT KEY'],'lighting');
pass('lighting follows club/social/VIP/resort hierarchy');

requireTokens('runtime',['SpawnLocation','root.Position.Y < -28'],'runtime');
requireTokens('assembler',[
  '00-core.lua','10-architecture.lua','15-premium-exterior.lua','20-furnishing.lua','25-premium-interior.lua',
  '35-circulation.lua','30-lighting.lua','40-runtime.server.lua','60-social-systems.server.lua',
  '50-qc.server.lua','80-release-gate.server.lua','70-ui.client.lua','BBYA_CLEAN_REBUILD_RUNTIME'
],'assembler');
if(/maps\/a-club\/v[0-9]+\//.test(src.assembler)) fail('archived versioned source leaked into assembler');
else pass('deterministic clean assembler isolated from archived builds');

requireTokens('inspector',['PHASE_6_PREVIEW_GATE','process.exit(1)'],'preview inspector');
requireTokens('release',['BBYAReleaseGate','BBYAOwnerPlaytestRequired'],'release gate');

if(failed) process.exit(1);
pass('BBYA V7 reference rebuild source gate complete');
