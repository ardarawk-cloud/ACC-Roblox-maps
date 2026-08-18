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
  'maps/a-club/v6/40-rooftop.lua',
  'maps/a-club/v6/45-service.lua',
  'maps/a-club/v6/50-systems.server.lua',
  'maps/a-club/v6/60-ui.client.lua',
  'maps/a-club/v6/61-zone-hud.client.lua',
  'maps/a-club/v6/70-runtime-qc.server.lua',
  'scripts/assemble-bbya-v6-preview.js',
];

let failed = false;
const pass = msg => console.log(`[BBYA V6 VALIDATE] PASS: ${msg}`);
const fail = msg => { failed = true; console.error(`[BBYA V6 VALIDATE] FAIL: ${msg}`); };
const read = file => fs.readFileSync(path.join(root, file), 'utf8');

for (const file of required) {
  if (!fs.existsSync(path.join(root, file))) fail(`missing required file ${file}`);
}
if (failed) process.exit(1);
pass(`${required.length} required V6 source files present`);

const core = read('maps/a-club/v6/00-core.lua');
const layout = read('maps/a-club/v6/10-layout.lua');
const ground = read('maps/a-club/v6/20-ground-shell.lua');
const circulation = read('maps/a-club/v6/21-circulation.lua');
const liftFinish = read('maps/a-club/v6/23-lift-finish.lua');
const vip = read('maps/a-club/v6/30-vip-level.lua');
const roof = read('maps/a-club/v6/40-rooftop.lua');
const systems = read('maps/a-club/v6/50-systems.server.lua');
const ui = read('maps/a-club/v6/60-ui.client.lua');
const zoneHud = read('maps/a-club/v6/61-zone-hud.client.lua');
const runtimeQc = read('maps/a-club/v6/70-runtime-qc.server.lua');
const assembler = read('scripts/assemble-bbya-v6-preview.js');
const sourceBundle = [core,layout,ground,circulation,liftFinish,vip,roof,systems,ui,zoneHud,runtimeQc,assembler].join('\n');

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

for (const token of ['D2 POOL BASIN','D2 POOL WATER','D2 POOL DJ ISLAND','D3 SKY BAR COUNTER','D5 CABANA ROOF','D6 VIEW PLATFORM']) {
  if (!roof.includes(token)) fail(`rooftop physical feature missing: ${token}`);
}
if (!failed) pass('rooftop programmed as physical lifestyle deck');

if (/\bpart\s*\(/.test(systems) || /\bP\./.test(systems)) fail('systems runtime depends on architecture-local helper/P palette');
else pass('systems runtime is self-contained');
if (!systems.includes('local moveLift') || !systems.includes('CALL LIFT') || !systems.includes('insideCab') || !systems.includes('HumanoidRootPart')) fail('physical lift runtime contract incomplete');
else pass('physical lift call/cab/occupant transport runtime present');

if (!ui.includes('ScrollingFrame')) fail('major panel body is not scrollable on mobile');
if (!ui.includes('positionPull') || !ui.includes('side=="LEFT"') || !ui.includes('side=="RIGHT"') || !ui.includes('side=="TOP"')) fail('edge recovery grab-tab logic missing');
if (!ui.includes('RETURN UI') || !ui.includes('CLEAN VIEW')) fail('clean-view recovery missing');
if (!ui.includes('TouchMoved') || !ui.includes('MouseButton2')) fail('freecam look input missing for touch/desktop');
if (!failed) pass('unified floating UI recovery/mobile camera contract present');

if (!zoneHud.includes('BBYAV6CurrentZone') || !zoneHud.includes('BBYAV6CurrentComponent') || !zoneHud.includes('findAddress')) fail('live zone/component inspection address HUD missing');
else pass('top status bar is wired to live macro/micro inspection address');

for (const token of ['BBYAV6RuntimeQC','BBYAV6RuntimeIssueCount','blocked clear landing','legacy Workspace object survived','BBYAV6CriticalFillCount']) {
  if (!runtimeQc.includes(token)) fail(`runtime QC contract missing: ${token}`);
}
if (!failed) pass('runtime QC checks clean slate, physical features, avatar fill and clear landings');

if (!assembler.includes('BBYA_V6_CLEANROOM_ARCHITECTURE') || !assembler.includes('BBYA_V6_UNIFIED_UI')) fail('V6 preview assembler runtime names missing');
if (/v5\//.test(assembler)) fail('V6 assembler references V5 source files');
if (!assembler.includes('23-lift-finish.lua') || !assembler.includes('61-zone-hud.client.lua') || !assembler.includes('70-runtime-qc.server.lua')) fail('V6 assembler missing final lift/QC/HUD modules');
else pass('preview assembler isolated and includes current V6 modules');

if (assembledFlag) {
  if (!assembledPath || !fs.existsSync(assembledPath)) fail(`assembled preview not found: ${assembledPath || '(none)'}`);
  else {
    const xml = fs.readFileSync(assembledPath, 'utf8');
    if (!xml.includes('BBYA_V6_PREVIEW_RUNTIME_BEGIN')) fail('assembled preview missing V6 runtime block');
    if (!xml.includes('BBYA_V6_CLEANROOM_ARCHITECTURE')) fail('assembled preview missing V6 architecture runtime');
    if (!xml.includes('BBYA_V6_CLEANROOM_SYSTEMS')) fail('assembled preview missing V6 systems runtime');
    if (!xml.includes('BBYA_V6_UNIFIED_UI')) fail('assembled preview missing V6 UI runtime');
    if (xml.includes('BBYA_V5_3_MASTER_ARCHITECTURE')) fail('assembled preview contains active V5.3 injected runtime');
    if (!xml.includes('SOURCE FILE: maps/a-club/v6/23-lift-finish.lua')) fail('assembled preview missing lift finish source');
    if (!xml.includes('SOURCE FILE: maps/a-club/v6/61-zone-hud.client.lua')) fail('assembled preview missing zone HUD source');
    if (!xml.includes('SOURCE FILE: maps/a-club/v6/70-runtime-qc.server.lua')) fail('assembled preview missing runtime QC source');
    if (!failed) pass('assembled RBXLX contains only current V6 injected runtime block');
  }
}

if (failed) {
  console.error('[BBYA V6 VALIDATE] BUILD REJECTED');
  process.exit(1);
}
console.log('[BBYA V6 VALIDATE] BUILD ACCEPTED FOR CLEANROOM PREVIEW ONLY — NOT LIVE PUBLISH');
