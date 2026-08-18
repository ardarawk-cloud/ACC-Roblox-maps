const fs = require('fs');
const path = require('path');

const mapId = process.argv[2];
const injected = process.argv.includes('--injected');
if (mapId !== 'a-club') process.exit(0);

const root = process.cwd();
const read = p => fs.readFileSync(path.join(root,p),'utf8');
const exists = p => fs.existsSync(path.join(root,p));
let failed=false;
const fail=m=>{failed=true;console.error('[BBYA VALIDATE] FAIL:',m)};
const pass=m=>console.log('[BBYA VALIDATE] PASS:',m);

const registry=JSON.parse(read('maps/registry.json'));
const target=registry.maps?.[mapId];
if(!target||!target.enabled) fail('a-club registry target missing/disabled');
else {
  if(!/^\d+$/.test(String(target.universeId))||!/^\d+$/.test(String(target.placeId))) fail('invalid Roblox IDs');
  if(!exists(target.file)) fail(`place file missing: ${target.file}`); else pass(`registry/place valid: ${target.file}`);
}

const zoneFiles=[
  'maps/a-club/v5/00-core.lua',
  'maps/a-club/v5/A1-exterior-spawn.lua','maps/a-club/v5/A2-entrance-facade.lua','maps/a-club/v5/A3-lobby.lua',
  'maps/a-club/v5/A4-main-club.lua','maps/a-club/v5/A5-bar.lua','maps/a-club/v5/A6-chill.lua',
  'maps/a-club/v5/B1-west-stair.lua','maps/a-club/v5/B2-east-stair.lua','maps/a-club/v5/B3-lift.lua',
  'maps/a-club/v5/C1-vip-west.lua','maps/a-club/v5/C2-vip-east.lua','maps/a-club/v5/C3-queen-bridges.lua',
  'maps/a-club/v5/D1-rooftop-arrival.lua','maps/a-club/v5/D2-rooftop-water-zone.lua','maps/a-club/v5/D3-skybar.lua',
  'maps/a-club/v5/D4-rooftop-chill.lua','maps/a-club/v5/D5-cabana-zones.lua','maps/a-club/v5/D6-photo-view.lua',
  'maps/a-club/v5/S1-service.lua','maps/a-club/v5/97-inspection-nav.lua','maps/a-club/v5/98-inspection-polish.lua','maps/a-club/v5/99-finalize.lua'
];
const uiFiles=[
  'maps/a-club/v5/ui-shell.client.lua',
  'maps/a-club/v5/ui-shell-polish.client.lua',
  'maps/a-club/v5/ui-inspection-nav.client.lua',
  'maps/a-club/v5/ui-floating-dock.client.lua',
  'maps/a-club/v5/ui-container-dock.client.lua'
];
for(const p of [...zoneFiles,...uiFiles,'scripts/inject-bbya.js','scripts/publish-map.js']) if(!exists(p)) fail(`required V5 file missing: ${p}`);
if(!failed) pass(`${zoneFiles.length} modular architecture/inspection files + ${uiFiles.length} UI modules present`);

const combined=zoneFiles.filter(exists).map(read).join('\n');
for(const code of ['A1','A2','A3','A4','A5','A6','B1','B2','B3','C1','C2','C3','D1','D2','D3','D4','D5','D6','S1']) {
  if(!combined.includes(`registerZone("${code}"`)) fail(`zone registration missing: ${code}`);
}
for(const marker of ['BBYAV5ZoneSchema','BBYAV5InspectionReady','BBYAV5Layout","5.2-modular-greybox','INSPECTION TAG','BBYAV5WorldInspectionTags','BBYAV5InspectionNav','BBYA_V5_InspectionNav','CODED_SAFE_LANDINGS']) {
  if(!combined.includes(marker)) fail(`modular architecture/inspection marker missing: ${marker}`);
}
for(const forbidden of ['palm(', 'sofa(', 'daybed(', 'PointLight', 'ParticleEmitter', 'MarketplaceService', 'TextButton']) {
  if(combined.includes(forbidden)) fail(`non-architectural system/decor leaked into V5.2 architecture: ${forbidden}`);
}
const remoteConstructors=(combined.match(/Instance\.new\(["']RemoteEvent["']\)/g)||[]).length;
if(remoteConstructors!==1) fail(`expected exactly 1 inspection RemoteEvent constructor; found ${remoteConstructors}`);

const ui=uiFiles.filter(exists).map(read).join('\n');
for(const marker of [
  'BBYA_V5_UI','TOP controls/panels open DOWN','LEFT rail panels open RIGHT','RIGHT rail panels open LEFT',
  'BBYACurrentZone','BBYAUIDrawerRule','BBYAV5UIPolish','BBYAUIThumbControlClearance','BBYAV5TPPanel','BBYA_V5_InspectionNav',
  'BBYAUIFloatingDock','BBYAUIDockEdges','LEFT/RIGHT/TOP_ONLY','FloatingMoveGrip','FloatingDockTabs',
  'BBYAUIContainerDock','BBYAUIContainerDockRule','TOP_UP/LEFT_LEFT/RIGHT_RIGHT/PEEK_ONLY','BBYAContainerDockHandles'
]) {
  if(!ui.includes(marker)) fail(`UI shell marker missing: ${marker}`);
}
if(ui.includes('MarketplaceService')||ui.includes('PromptProductPurchase')) fail('UI shell must not activate real monetization during greybox');

const injector=exists('scripts/inject-bbya.js')?read('scripts/inject-bbya.js'):'';
for(const p of zoneFiles) if(!injector.includes(p)) fail(`injector missing modular source: ${p}`);
for(const p of uiFiles) if(!injector.includes(p)) fail(`injector missing UI source: ${p}`);
if(!injector.includes('BBYA_V5_2_MODULAR_ARCHITECTURE')) fail('injector missing V5.2 architecture runtime');
if(!injector.includes('BBYA_V5_Mobile_Safe_UI_Shell')) fail('injector missing mobile-safe UI runtime');
for(const retired of [
  'bbya.v5-layout.server.lua','bbya.visual-rebuild-v4.server.lua','bbya.visual-polish-v4.server.lua',
  'bbya.phase3-premium.server.lua','bbya.phase4-experience.server.lua','bbya.phase5-finish.server.lua',
  'bbya.phase6-wayfinding.server.lua','bbya.livefix-4.7.server.lua','bbya.front-lobby-v4.9.server.lua',
  'bbya.client.lua','bbya.music.client.lua','bbya.monetization.client.lua','bbya.ui-coordinator.client.lua'
]) if(injector.includes(retired)) fail(`retired runtime still referenced: ${retired}`);
if(!failed) pass('injector = 1 modular architecture/inspection Script + 1 floating/dockable unified UI LocalScript');

if(target&&exists(target.file)) {
  const xml=read(target.file);
  if(!xml.includes('</roblox>')) fail('RBXLX missing closing tag');
  if(injected) {
    const begin='<!-- BBYA_RUNTIME_BEGIN -->',end='<!-- BBYA_RUNTIME_END -->';
    const bc=xml.split(begin).length-1,ec=xml.split(end).length-1;
    if(bc!==1||ec!==1) fail(`runtime markers invalid begin=${bc} end=${ec}`);
    const runtime=bc===1&&ec===1?xml.slice(xml.indexOf(begin),xml.indexOf(end)+end.length):'';
    if(!runtime.includes('<string name="Name">BBYA_V5_2_MODULAR_ARCHITECTURE</string>')) fail('V5.2 modular runtime missing after injection');
    if(!runtime.includes('<string name="Name">BBYA_V5_Mobile_Safe_UI_Shell</string>')) fail('V5 mobile-safe UI shell missing after injection');
    const scripts=(runtime.match(/<Item class="Script"/g)||[]).length;
    const locals=(runtime.match(/<Item class="LocalScript"/g)||[]).length;
    if(scripts!==1) fail(`expected exactly 1 architecture runtime Script; found ${scripts}`);
    if(locals!==1) fail(`expected exactly 1 unified UI LocalScript; found ${locals}`);
    for(const code of ['A1','A2','A3','A4','A5','A6','B1','B2','B3','C1','C2','C3','D1','D2','D3','D4','D5','D6','S1']) {
      if(!runtime.includes(`registerZone("${code}"`)) fail(`injected runtime missing zone ${code}`);
    }
    for(const marker of [
      'TOP_DOWN/LEFT_RIGHT/RIGHT_LEFT','BBYACurrentZone','MOBILE_SAFE','BBYAV5UIPolish','BBYAUIThumbControlClearance',
      'BBYAV5WorldInspectionTags','BBYA_V5_InspectionNav','CODED_SAFE_LANDINGS','BBYAV5TPPanel',
      'BBYAUIFloatingDock','LEFT/RIGHT/TOP_ONLY','FloatingMoveGrip','FloatingDockTabs',
      'BBYAUIContainerDock','TOP_UP/LEFT_LEFT/RIGHT_RIGHT/PEEK_ONLY','BBYAContainerDockHandles'
    ]) {
      if(!runtime.includes(marker)) fail(`injected dockable runtime missing marker: ${marker}`);
    }
    if(!runtime.includes('5.2-modular-greybox')) fail('V5.2 status marker missing after injection');
    if(!failed) pass('post-injection architecture + coded inspection nav + dockable floating mobile UI valid');
  }
}

if(failed){console.error(`[BBYA VALIDATE] ${injected?'POST-INJECTION':'SOURCE'} BUILD REJECTED`);process.exit(1)}
console.log(`[BBYA VALIDATE] ${injected?'POST-INJECTION':'SOURCE'} CHECKS PASSED • V5.2 MODULAR + CODED INSPECTION NAV + DOCKABLE FLOATING UI`);
