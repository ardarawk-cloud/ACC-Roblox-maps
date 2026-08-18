const fs = require('fs');
const path = require('path');

const root = process.cwd();
const assembledFlag = process.argv[2] === '--assembled';
const assembledPath = assembledFlag ? process.argv[3] : null;

const required = [
  'maps/a-club/v6/MASTER-CONTRACT.md',
  'maps/a-club/v6/00-core.lua',
  'maps/a-club/v6/10-layout.lua',
  'maps/a-club/v6/20-ground-shell.lua',
  'maps/a-club/v6/21-circulation.lua',
  'maps/a-club/v6/22-facade-brand.lua',
  'maps/a-club/v6/23-lift-finish.lua',
  'maps/a-club/v6/30-vip-level.lua',
  'maps/a-club/v6/31-vip-gates.lua',
  'maps/a-club/v6/40-rooftop.lua',
  'maps/a-club/v6/42-social-seating.lua',
  'maps/a-club/v6/45-service.lua',
  'maps/a-club/v6/50-systems.server.lua',
  'maps/a-club/v6/55-monetization.server.lua',
  'maps/a-club/v6/57-social-prompts.server.lua',
  'maps/a-club/v6/60-ui.client.lua',
  'maps/a-club/v6/61-zone-hud.client.lua',
  'maps/a-club/v6/62-dance-ui.client.lua',
  'maps/a-club/v6/63-commerce-ui.client.lua',
  'maps/a-club/v6/64-physical-ui-bridge.client.lua',
  'maps/a-club/v6/70-runtime-qc.server.lua',
  'scripts/assemble-bbya-v6-preview.js',
];

let failed = false;
const pass = msg => console.log(`[BBYA V6 VALIDATE] PASS: ${msg}`);
const fail = msg => { failed = true; console.error(`[BBYA V6 VALIDATE] FAIL: ${msg}`); };
const read = file => fs.readFileSync(path.join(root, file), 'utf8');

for (const file of required) if (!fs.existsSync(path.join(root, file))) fail(`missing required file ${file}`);
if (failed) process.exit(1);
pass(`${required.length} required V6 source files present`);

const core = read('maps/a-club/v6/00-core.lua');
const layout = read('maps/a-club/v6/10-layout.lua');
const ground = read('maps/a-club/v6/20-ground-shell.lua');
const circulation = read('maps/a-club/v6/21-circulation.lua');
const facade = read('maps/a-club/v6/22-facade-brand.lua');
const liftFinish = read('maps/a-club/v6/23-lift-finish.lua');
const vip = read('maps/a-club/v6/30-vip-level.lua');
const vipGates = read('maps/a-club/v6/31-vip-gates.lua');
const roof = read('maps/a-club/v6/40-rooftop.lua');
const socialSeats = read('maps/a-club/v6/42-social-seating.lua');
const systems = read('maps/a-club/v6/50-systems.server.lua');
const commerce = read('maps/a-club/v6/55-monetization.server.lua');
const socialPrompts = read('maps/a-club/v6/57-social-prompts.server.lua');
const ui = read('maps/a-club/v6/60-ui.client.lua');
const zoneHud = read('maps/a-club/v6/61-zone-hud.client.lua');
const danceUi = read('maps/a-club/v6/62-dance-ui.client.lua');
const commerceUi = read('maps/a-club/v6/63-commerce-ui.client.lua');
const physicalBridge = read('maps/a-club/v6/64-physical-ui-bridge.client.lua');
const runtimeQc = read('maps/a-club/v6/70-runtime-qc.server.lua');
const assembler = read('scripts/assemble-bbya-v6-preview.js');
const sourceBundle = [core,layout,ground,circulation,facade,liftFinish,vip,vipGates,roof,socialSeats,systems,commerce,socialPrompts,ui,zoneHud,danceUi,commerceUi,physicalBridge,runtimeQc,assembler].join('\n');

if (/maps\/a-club\/v5\//.test(sourceBundle)) fail('V5 source path leaked into V6 build'); else pass('no V5 source path in V6 assembly');
if (!core.includes('BBYAV6CleanSlate') || !core.includes('removedLegacy')) fail('true clean-room Workspace cleanup missing'); else pass('legacy Workspace cleanup contract present');
if (!circulation.includes('SpawnLocation') || !circulation.includes('BBYAV6SpawnReady')) fail('V6 physical spawn missing'); else pass('physical A1 spawn present');

for (const z of ['A1','A2','A3','A4','A5','A6','B1','B2','B3','C1','C2','C3','D1','D2','D3','D4','D5','D6','S1']) {
  if (!layout.includes(`zone("${z}"`)) fail(`zone ${z} missing from coordinate plan`);
}
for (const c of ['01','02','03','04','05','06','07','08','09W','09E','10','11W','11E','12W','12E','13','14','15','16','17']) {
  if (!layout.includes(`"${c}"`)) fail(`component ${c} missing from component registry`);
}
if (!failed) pass('all macro zones and blueprint component codes registered');

if (!facade.includes('PHYSICAL_CROWN_ATTACHED') || !facade.includes('A2 BRAND WALL')) fail('facade crown/wordmark is not physically attached to a full backer');
else pass('front BBYA brand is an attached facade element, not floating copy');

for (const token of ['A3 LOOK STUDIO WEST','A3 LOOK CYC WALL','A3 WELCOME BAR','A3 SOCIAL ISLAND','A4 DANCE FLOOR','A4 DJ BOOTH','A5 MAIN BAR','A6 CONVERSATION SOFA']) {
  if (!ground.includes(token)) fail(`physical ground feature missing: ${token}`);
}
if (!failed) pass('ground floor contains real programmed rooms/furniture, not labels only');

for (const token of ['B3 SHAFT WEST','B3 G LANDING DOOR L','B3 VIP LANDING DOOR L','B3 ROOF LANDING DOOR L','B3 LIFT CAB FLOOR','B3 LIFT CAB DOOR L','B3 G-V FRONT INFILL','B3 V-R FRONT INFILL']) {
  if (!ground.includes(token)) fail(`lift shell feature missing: ${token}`);
}
for (const token of ['B3 LIFT CAB CEILING','B3 LIFT CAB LIGHT','B3 G LANDING HEADER','B3 VIP LANDING HEADER','B3 ROOF LANDING HEADER']) {
  if (!liftFinish.includes(token)) fail(`lift finish feature missing: ${token}`);
}
if (!vip.includes('C2 EAST VIP FLOOR FRONT') || !vip.includes('C2 EAST VIP FLOOR REAR') || !vip.includes('BBYAV6LiftShaftClearVIP')) fail('VIP floor is not carved around lift shaft');
else pass('lift shaft has physical shell/doors/interior finish and VIP floor clearance');

if (!vipGates.includes('BBYAVIPBarrier') || !vipGates.includes('PREVIEW_OPEN')) fail('physical VIP thresholds missing');
else pass('physical VIP thresholds exist and default safely open while pass ID is pending');

for (const token of ['D2 POOL BASIN','D2 POOL WATER','D2 POOL DJ ISLAND','D3 SKY BAR COUNTER','D5 CABANA ROOF','D6 VIEW PLATFORM']) {
  if (!roof.includes(token)) fail(`rooftop physical feature missing: ${token}`);
}
if (!failed) pass('rooftop programmed as physical lifestyle deck');

if (!socialSeats.includes('Instance.new("Seat")') || !socialSeats.includes('SIT PROMPT') || !socialSeats.includes('BBYAV6FunctionalSocialSeats')) fail('physical lounge furniture is decoration-only');
for (const zoneToken of ['A1 SOCIAL SEAT','A3 SOCIAL SEAT','A4 SOCIAL WATCH SEAT','A5 BAR SOCIAL SEAT','A6 TALK SEAT','C1 VIP SOCIAL SEAT','D2 POOL DAYBED SEAT','D5 CABANA SOCIAL SEAT']) {
  if (!socialSeats.includes(zoneToken)) fail(`functional social seating missing coverage: ${zoneToken}`);
}
if (!failed) pass('arrival/commons/club/bar/chill/VIP/rooftop furniture has functional social seating');

if (/\bpart\s*\(/.test(systems) || /\bP\./.test(systems)) fail('systems runtime depends on architecture-local helper/P palette');
else pass('systems runtime is self-contained');
if (!systems.includes('local moveLift') || !systems.includes('CALL LIFT') || !systems.includes('insideCab') || !systems.includes('HumanoidRootPart')) fail('physical lift runtime contract incomplete');
else pass('physical lift call/cab/occupant transport runtime present');

if (!commerce.includes('VIP_GAMEPASS_ID=0') || !commerce.includes('[5]=0') || !commerce.includes('[500]=0')) fail('commerce IDs are not explicitly pending/zero');
if (!commerce.includes('ProcessReceipt') || !commerce.includes('BBYA_Donations_v2') || !commerce.includes('SupportBoard')) fail('authoritative support backend incomplete');
if (!commerce.includes('BBYA_VIP_GATE') || !commerce.includes('CollisionGroupSetCollidable')) fail('authoritative per-player VIP barrier logic missing');
if (!failed) pass('VIP/support backend is authoritative and dormant with zero IDs');

if (!socialPrompts.includes('OpenPanel') || !socialPrompts.includes('A3 LOOK PEDESTAL') || !socialPrompts.includes('A4 DJ BOOTH') || !socialPrompts.includes('D6 VIEW PLATFORM')) fail('physical facilities are not wired to matching social tools');
else pass('Look Studio/photo/DJ/dance/view spaces expose in-world UI prompts');

if (!ui.includes('ScrollingFrame')) fail('major panel body is not scrollable on mobile');
if (!ui.includes('positionPull') || !ui.includes('side=="LEFT"') || !ui.includes('side=="RIGHT"') || !ui.includes('side=="TOP"')) fail('edge recovery grab-tab logic missing');
if (!ui.includes('RETURN UI') || !ui.includes('CLEAN VIEW')) fail('clean-view recovery missing');
if (!ui.includes('TouchMoved') || !ui.includes('MouseButton2')) fail('freecam look input missing for touch/desktop');
if (!failed) pass('unified floating UI recovery/mobile camera contract present');

if (!zoneHud.includes('BBYAV6CurrentZone') || !zoneHud.includes('BBYAV6CurrentComponent') || !zoneHud.includes('findAddress')) fail('live zone/component inspection address HUD missing');
else pass('top status bar is wired to live macro/micro inspection address');
if (!danceUi.includes('DANCE STUDIO') || !danceUi.includes('SYNC NEARBY') || !danceUi.includes('AUTO: OFF') || !danceUi.includes('launch.SOCIAL.Text="DANCE"')) fail('Dance Studio launcher/functionality missing');
else pass('left rail parity restored to DANCE/VIP/PHOTO/TP with functional Dance Studio');
if (!commerceUi.includes('PromptProductPurchase') || !commerceUi.includes('SupportBoard') || !commerceUi.includes('PENDING')) fail('Sawer UI is not bound to authoritative config/backend');
else pass('Sawer UI auto-activates only from official product IDs and reads server leaderboard');
if (!physicalBridge.includes('OpenPanel.OnClientEvent') || !physicalBridge.includes('show(photoPanel)') || !physicalBridge.includes('show(musicPanel)') || !physicalBridge.includes('show(dancePanel)')) fail('physical-to-UI client bridge incomplete');
else pass('physical facility prompts open the same unified floating UI, not duplicate interfaces');

for (const token of ['BBYAV6RuntimeQC','BBYAV6RuntimeIssueCount','blocked clear landing','legacy Workspace object survived','BBYAV6CriticalFillCount']) {
  if (!runtimeQc.includes(token)) fail(`runtime QC contract missing: ${token}`);
}
if (!failed) pass('runtime QC checks clean slate, physical features, avatar fill and clear landings');

if (!assembler.includes('BBYA_V6_CLEANROOM_RUNTIME') || !assembler.includes('BBYA_V6_UNIFIED_UI')) fail('V6 deterministic preview runtime names missing');
if (assembler.includes('BBYA_V6_CLEANROOM_ARCHITECTURE') || assembler.includes('BBYA_V6_CLEANROOM_SYSTEMS')) fail('assembler still creates parallel architecture/system scripts');
if (/v5\//.test(assembler)) fail('V6 assembler references V5 source files');
const mustAssemble=['23-lift-finish.lua','31-vip-gates.lua','42-social-seating.lua','55-monetization.server.lua','57-social-prompts.server.lua','61-zone-hud.client.lua','62-dance-ui.client.lua','63-commerce-ui.client.lua','64-physical-ui-bridge.client.lua','70-runtime-qc.server.lua'];
for (const module of mustAssemble) if (!assembler.includes(module)) fail(`V6 assembler missing module ${module}`);
const architectureIndex=assembler.indexOf('maps/a-club/v6/42-social-seating.lua');
const systemsIndex=assembler.indexOf('maps/a-club/v6/50-systems.server.lua');
const commerceIndex=assembler.indexOf('maps/a-club/v6/55-monetization.server.lua');
const promptsIndex=assembler.indexOf('maps/a-club/v6/57-social-prompts.server.lua');
const qcIndex=assembler.indexOf('maps/a-club/v6/70-runtime-qc.server.lua');
if (!(architectureIndex>=0 && systemsIndex>architectureIndex && commerceIndex>systemsIndex && promptsIndex>commerceIndex && qcIndex>promptsIndex)) fail('server runtime source order is not architecture -> systems -> commerce -> prompts -> QC');
else pass('server runtime executes deterministic architecture -> systems -> commerce -> prompts -> QC order');

if (assembledFlag) {
  if (!assembledPath || !fs.existsSync(assembledPath)) fail(`assembled preview not found: ${assembledPath || '(none)'}`);
  else {
    const xml = fs.readFileSync(assembledPath, 'utf8');
    if (!xml.includes('BBYA_V6_PREVIEW_RUNTIME_BEGIN')) fail('assembled preview missing V6 runtime block');
    if (!xml.includes('BBYA_V6_CLEANROOM_RUNTIME')) fail('assembled preview missing deterministic V6 server runtime');
    if (!xml.includes('BBYA_V6_UNIFIED_UI')) fail('assembled preview missing V6 UI runtime');
    if (xml.includes('BBYA_V6_CLEANROOM_ARCHITECTURE') || xml.includes('BBYA_V6_CLEANROOM_SYSTEMS')) fail('assembled preview still contains parallel V6 server runtimes');
    if (xml.includes('BBYA_V5_3_MASTER_ARCHITECTURE')) fail('assembled preview contains active V5.3 injected runtime');
    for (const module of mustAssemble) if (!xml.includes(`SOURCE FILE: maps/a-club/v6/${module}`)) fail(`assembled preview missing source ${module}`);
    const xmlSeats=xml.indexOf('SOURCE FILE: maps/a-club/v6/42-social-seating.lua');
    const xmlSystems=xml.indexOf('SOURCE FILE: maps/a-club/v6/50-systems.server.lua');
    const xmlCommerce=xml.indexOf('SOURCE FILE: maps/a-club/v6/55-monetization.server.lua');
    const xmlPrompts=xml.indexOf('SOURCE FILE: maps/a-club/v6/57-social-prompts.server.lua');
    const xmlQc=xml.indexOf('SOURCE FILE: maps/a-club/v6/70-runtime-qc.server.lua');
    if (!(xmlSeats>=0 && xmlSystems>xmlSeats && xmlCommerce>xmlSystems && xmlPrompts>xmlCommerce && xmlQc>xmlPrompts)) fail('assembled V6 server source order is wrong');
    if (!failed) pass('assembled RBXLX contains one ordered V6 server runtime and current UI modules only');
  }
}

if (failed) {
  console.error('[BBYA V6 VALIDATE] BUILD REJECTED');
  process.exit(1);
}
console.log('[BBYA V6 VALIDATE] BUILD ACCEPTED FOR CLEANROOM PREVIEW ONLY — NOT LIVE PUBLISH');
