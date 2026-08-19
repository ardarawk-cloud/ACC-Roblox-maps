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
  ownerFix:'maps/a-club/rebuild/45-owner-layout-fix.server.lua',
  social:'maps/a-club/rebuild/60-social-systems.server.lua',
  liveServices:'maps/a-club/rebuild/65-live-services.server.lua',
  receiptSafety:'maps/a-club/rebuild/66-support-receipt-hotfix.server.lua',
  qc:'maps/a-club/rebuild/50-qc.server.lua',
  release:'maps/a-club/rebuild/80-release-gate.server.lua',
  ui:'maps/a-club/rebuild/70-ui.client.lua',
  uiConsolidate:'maps/a-club/rebuild/71-ui-consolidate.client.lua',
  hybridUI:'maps/a-club/rebuild/72-hybrid-ui.client.lua',
  assembler:'scripts/assemble-bbya-v6-preview.js',
  inspector:'scripts/inspect-bbya-clean-preview.js',
  prep:'scripts/prepare-bbya-rojo-live.js',
  resolver:'scripts/resolve-bbya-commerce.js',
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

for(const token of ['WELCOME BAR SIGN','MAIN BBYA WORDMARK','BBYA SOCIAL HUB','VIP ACCESS DOOR','VIP ACCESS PROMPT','PromptGamePassPurchase','BBYAFacadeGlassSolid','BBYARooftopStairwellOpen','ROOFTOP DECK WEST','ROOF STAIR BRIDGE']) if(!s.ownerFix.includes(token)) bad(`owner-layout token missing: ${token}`);
else ok('owner-requested signage, glass, VIP door and rooftop stairwell fixes present');

// Phase-5 source remains intentionally fail-closed. Live overlay is validated separately below.
for(const token of ['SUPPORT_ORDER={5,10,50,100,500}','[5]=0','[500]=0','GetSupportConfig','GetSupportBoard','GetSupportSelf','BBYA CLUB GROUP','BBYA ROOFTOP GROUP','CLUB DECK A','CLUB DECK B','ROOFTOP DECK A','ROOFTOP DECK B','CROSSFADE_SECONDS=3.5','MUSIC_LIBRARY={club={},rooftop={}}','PHASE_5_REFERENCE_FIDELITY']) if(!s.social.includes(token)) bad(`social token missing: ${token}`);
if(s.social.includes('[25]=0')) bad('non-reference R$25 support tier leaked');

for(const token of [
  'SUPPORT_ORDER_LIVE={5,10,50,100,500}',
  'MusicCommand',
  'HYBRID_AUTO',
  'DJ_IDLE_TIMEOUT=45',
  '134073539670673','116255319981650','110691393637838','85427648559465','100787734732008','103491797412309',
  'BBYAHybridTrackCount',
]) if(!s.liveServices.includes(token)) bad(`live-services token missing: ${token}`);
else ok('five-tier live support resolver and six-track Hybrid Auto DJ present');

for(const token of ['BBYA_SupportLedger_v2','MarketplaceServiceReceipt.ProcessReceipt','PurchaseGranted','BBYASupportReceiptLedger','IDEMPOTENT_V2']) if(!s.receiptSafety.includes(token)) bad(`receipt-safety token missing: ${token}`);
else ok('idempotent support receipt ledger present');

for(const token of ['BBYA SOCIAL UI','MINI PLAYER','SUPPORT / SAWER','MUSIC CONTROLLER','AUTO DJ','DJ MODE','EQUALIZER','CROSSFADE','QUEUE','CLEAN VIEW']) if(!s.ui.includes(token)) bad(`UI token missing: ${token}`);
for(const token of ['BBYA MENU','MENU','BBYAUISingleLauncher','keepHidden(musicLaunch)','keepHidden(photoLaunch)','keepHidden(mini)']) if(!s.uiConsolidate.includes(token)) bad(`single-menu token missing: ${token}`);
for(const token of ['MusicCommand','NEXT TRACK','TOGGLE_DJ','applyMusicMix=function()','BBYAHybridDJUI']) if(!s.hybridUI.includes(token)) bad(`hybrid UI token missing: ${token}`);
else ok('single MENU launcher and functional Hybrid DJ controls present');

for(const token of ['BBYAPhase5QC','blocked clear lane','expected exactly one clean rebuild root']) if(!s.qc.includes(token)) bad(`QC token missing: ${token}`);
for(const token of ['PHASE_6_PREVIEW_GATE','BBYAReleaseGate','BBYAOwnerPlaytestRequired','RUNTIME_QC_PASS_PENDING_EXTERNAL_IDS_AND_OWNER_PLAYTEST']) if(!s.release.includes(token)) bad(`release-gate token missing: ${token}`);
else ok('runtime QC and release gate present');

if(/maps\/a-club\/v[0-9]+\//.test(s.assembler)) bad('archived V5/V6 source path leaked into assembler');
for(const token of ['RBXBBYACARRIERWORKSPACE','RBXBBYACARRIERLIGHTING','BBYA_CLEAN_RUNTIME_BEGIN','BBYA_CLEAN_REBUILD_RUNTIME','RBXBBYACLEANSTARTERPLAYER','BBYA_CLEAN_SOCIAL_UI','45-owner-layout-fix.server.lua','65-live-services.server.lua','66-support-receipt-hotfix.server.lua','72-hybrid-ui.client.lua']) if(!s.assembler.includes(token)) bad(`assembler token missing: ${token}`);
if(!s.assembler.includes("xml = xml.replace('</roblox>', `${runtime}</roblox>`)") && !s.assembler.includes("xml = xml.replace('</roblox>', `${runtime}</roblox>`);")) bad('assembler does not append clean runtime to carrier');
else ok('clean deterministic carrier assembly present');

for(const token of ['45-owner-layout-fix.server.lua','65-live-services.server.lua','66-support-receipt-hotfix.server.lua','72-hybrid-ui.client.lua','BBYA_COMMERCE_RESOLVED','BBYA_COMMERCE_JSON']) if(!s.prep.includes(token)) bad(`live-prep token missing: ${token}`);
for(const token of ['/game-passes/v1/universes/','/developer-products/v2/universes/','supportProducts','vipGamePassId','[5,10,50,100,500]']) if(!s.resolver.includes(token)) bad(`commerce-resolver token missing: ${token}`);
else ok('direct-live commerce resolution and binary build wiring present');

for(const token of ['PHASE_6_PREVIEW_GATE','SUPPORT_ORDER={5,10,50,100,500}','MUSIC_LIBRARY={club={},rooftop={}}','expected exactly one assembled server Script','preview unexpectedly contains live Developer Product IDs']) if(!s.inspector.includes(token)) bad(`preview inspector token missing: ${token}`);
if(!s.inspector.includes('process.exit(1)')) bad('preview inspector cannot fail CI');
else ok('assembled preview inspector present');

if(fail) process.exit(1);
ok('BBYA clean rebuild carrier static gate complete');
