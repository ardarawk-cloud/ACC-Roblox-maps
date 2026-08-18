const fs=require('fs');
const path=require('path');
const mapId=process.argv[2];
const injected=process.argv.includes('--injected');
if(mapId!=='a-club')process.exit(0);
const root=process.cwd();const read=p=>fs.readFileSync(path.join(root,p),'utf8');const exists=p=>fs.existsSync(path.join(root,p));
let failed=false;const fail=m=>{failed=true;console.error('[BBYA VALIDATE] FAIL:',m)};const pass=m=>console.log('[BBYA VALIDATE] PASS:',m);

const registry=JSON.parse(read('maps/registry.json'));const target=registry.maps?.[mapId];
if(!target||!target.enabled)fail('a-club registry target missing/disabled');
else{if(!/^\d+$/.test(String(target.universeId))||!/^\d+$/.test(String(target.placeId)))fail('invalid Roblox IDs');if(!exists(target.file))fail(`place file missing: ${target.file}`);else pass(`registry/place valid: ${target.file}`)}

const zoneFiles=[
'maps/a-club/v5/00-core.lua','maps/a-club/v5/10-design-system.lua',
'maps/a-club/v5/A1-exterior-spawn.lua','maps/a-club/v5/A1-premium.lua','maps/a-club/v5/A2-entrance-facade.lua','maps/a-club/v5/A2-premium.lua','maps/a-club/v5/A3-lobby.lua','maps/a-club/v5/A3-premium.lua',
'maps/a-club/v5/S1-service.lua','maps/a-club/v5/S1-premium.lua','maps/a-club/v5/B3-lift.lua','maps/a-club/v5/B3-premium.lua','maps/a-club/v5/A4-main-club.lua','maps/a-club/v5/A4-premium.lua','maps/a-club/v5/A5-bar.lua','maps/a-club/v5/A5-premium.lua','maps/a-club/v5/A6-chill.lua','maps/a-club/v5/A6-premium.lua',
'maps/a-club/v5/B1-west-stair.lua','maps/a-club/v5/B1-premium.lua','maps/a-club/v5/B2-east-stair.lua','maps/a-club/v5/B2-premium.lua','maps/a-club/v5/C1-vip-west.lua','maps/a-club/v5/C1-premium.lua','maps/a-club/v5/C2-vip-east.lua','maps/a-club/v5/C2-premium.lua','maps/a-club/v5/C3-queen-bridges.lua','maps/a-club/v5/C3-premium.lua',
'maps/a-club/v5/D1-rooftop-arrival.lua','maps/a-club/v5/D1-premium.lua','maps/a-club/v5/D2-rooftop-water-zone.lua','maps/a-club/v5/D2-premium.lua','maps/a-club/v5/D3-skybar.lua','maps/a-club/v5/D3-premium.lua','maps/a-club/v5/D4-rooftop-chill.lua','maps/a-club/v5/D4-premium.lua','maps/a-club/v5/D5-cabana-zones.lua','maps/a-club/v5/D5-premium.lua','maps/a-club/v5/D6-photo-view.lua','maps/a-club/v5/D6-premium.lua',
'maps/a-club/v5/90-premium-atmosphere.lua','maps/a-club/v5/97-inspection-nav.lua','maps/a-club/v5/98-inspection-polish.lua','maps/a-club/v5/99-finalize.lua'];
const systemFiles=['maps/a-club/v5/systems/00-core.server.lua','maps/a-club/v5/systems/10-dance.server.lua','maps/a-club/v5/systems/20-lift.server.lua','maps/a-club/v5/systems/30-monetization.server.lua','maps/a-club/v5/systems/40-music.server.lua','maps/a-club/v5/systems/50-venue-state.server.lua','maps/a-club/v5/systems/60-support-board.server.lua','maps/a-club/v5/systems/70-light-control.server.lua','maps/a-club/v5/systems/99-runtime-qc.server.lua'];
const uiFiles=['maps/a-club/v5/ui-shell.client.lua','maps/a-club/v5/ui-shell-polish.client.lua','maps/a-club/v5/ui-inspection-nav.client.lua','maps/a-club/v5/ui-floating-dock.client.lua','maps/a-club/v5/ui-container-dock.client.lua','maps/a-club/v5/ui-live.client.lua','maps/a-club/v5/ui-performance.client.lua'];
for(const p of [...zoneFiles,...systemFiles,...uiFiles,'scripts/inject-bbya.js','scripts/publish-map.js'])if(!exists(p))fail(`required V5.3 file missing: ${p}`);
if(!failed)pass(`${zoneFiles.length} architecture/finish + ${systemFiles.length} systems + ${uiFiles.length} UI modules present`);

const architecture=zoneFiles.filter(exists).map(read).join('\n');
for(const code of ['A1','A2','A3','A4','A5','A6','B1','B2','B3','C1','C2','C3','D1','D2','D3','D4','D5','D6','S1'])if(!architecture.includes(`registerZone("${code}"`))fail(`zone registration missing: ${code}`);
for(const marker of ['BBYAV5DesignSystem','PREMIUM EXTERIOR','PREMIUM MAIN CLUB','PREMIUM INFINITY POOL','PREMIUM SKY BAR','PREMIUM CABANAS','BBYAV5Atmosphere','5.3-master-plan','BBYAV5WorldInspectionTags','BBYA_V5_InspectionNav','CODED_SAFE_LANDINGS'])if(!architecture.includes(marker))fail(`architecture/finish marker missing: ${marker}`);
if(architecture.includes('MarketplaceService')||architecture.includes('ProcessReceipt'))fail('commerce leaked into architecture runtime');
const archRemoteCount=(architecture.match(/Instance\.new\(["']RemoteEvent["']\)/g)||[]).length;if(archRemoteCount!==1)fail(`expected exactly one architecture inspection RemoteEvent; found ${archRemoteCount}`);

const systems=systemFiles.filter(exists).map(read).join('\n');
for(const marker of ['BBYASystemCore','BBYASystemDance','BBYASystemLift','BBYASystemMoney','BBYASystemMusic','BBYASystemVenue','BBYASystemSupportBoard','BBYASystemLights','BBYAV5QCStatus'])if(!systems.includes(marker))fail(`system marker missing: ${marker}`);
const receiptCount=(systems.match(/ProcessReceipt\s*=/g)||[]).length;if(receiptCount!==1)fail(`expected exactly one ProcessReceipt owner; found ${receiptCount}`);
if(!systems.includes('VIP_GAMEPASS_ID=0')||!systems.includes('[500]=0'))fail('monetization placeholders changed without explicit IDs');
if(!systems.includes('SKIP UNAVAILABLE')||!systems.includes('BBYARealCrowdCount'))fail('Auto-DJ/crowd safeguards missing');

const ui=uiFiles.filter(exists).map(read).join('\n');
for(const marker of ['BBYA_V5_UI','BBYACurrentZone','BBYAUIFloatingDock','BBYAUIContainerDock','BBYAUILiveSystems','BBYAClientPerformanceProfile','BBYAV5TPPanel','TOP_UP/LEFT_LEFT/RIGHT_RIGHT/PEEK_ONLY'])if(!ui.includes(marker))fail(`UI marker missing: ${marker}`);
if(!ui.includes('idv.Value>0')||!ui.includes('vipId.Value>0'))fail('UI commerce zero-ID guards missing');

const injector=exists('scripts/inject-bbya.js')?read('scripts/inject-bbya.js'):'';
for(const p of zoneFiles)if(!injector.includes(p))fail(`injector missing architecture source: ${p}`);
for(const p of systemFiles)if(!injector.includes(p))fail(`injector missing system source: ${p}`);
for(const p of uiFiles)if(!injector.includes(p))fail(`injector missing UI source: ${p}`);
for(const runtimeName of ['BBYA_V5_3_MASTER_ARCHITECTURE','BBYA_V5_3_MASTER_SYSTEMS','BBYA_V5_3_UNIFIED_UI'])if(!injector.includes(runtimeName))fail(`injector missing runtime ${runtimeName}`);
for(const retired of ['bbya.server.lua','bbya.qc.server.lua','bbya.visual-rebuild-v4.server.lua','bbya.visual-polish-v4.server.lua','bbya.phase3-premium.server.lua','bbya.phase4-experience.server.lua','bbya.phase5-finish.server.lua','bbya.phase6-wayfinding.server.lua','bbya.client.lua','bbya.music.client.lua','bbya.monetization.client.lua','bbya.ui-coordinator.client.lua'])if(injector.includes(retired))fail(`retired runtime referenced: ${retired}`);
if(!failed)pass('injector contract = 1 master architecture + 1 master systems + 1 unified UI');

if(target&&exists(target.file)){
 const xml=read(target.file);if(!xml.includes('</roblox>'))fail('RBXLX missing closing tag');
 if(injected){const begin='<!-- BBYA_RUNTIME_BEGIN -->',end='<!-- BBYA_RUNTIME_END -->';const bc=xml.split(begin).length-1,ec=xml.split(end).length-1;if(bc!==1||ec!==1)fail(`runtime markers invalid begin=${bc} end=${ec}`);const runtime=bc===1&&ec===1?xml.slice(xml.indexOf(begin),xml.indexOf(end)+end.length):'';
  for(const n of ['BBYA_V5_3_MASTER_ARCHITECTURE','BBYA_V5_3_MASTER_SYSTEMS','BBYA_V5_3_UNIFIED_UI'])if(!runtime.includes(`<string name="Name">${n}</string>`))fail(`injected runtime missing ${n}`);
  const scripts=(runtime.match(/<Item class="Script"/g)||[]).length,locals=(runtime.match(/<Item class="LocalScript"/g)||[]).length;if(scripts!==2)fail(`expected 2 server Scripts; found ${scripts}`);if(locals!==1)fail(`expected 1 unified LocalScript; found ${locals}`);
  for(const code of ['A1','A2','A3','A4','A5','A6','B1','B2','B3','C1','C2','C3','D1','D2','D3','D4','D5','D6','S1'])if(!runtime.includes(`registerZone("${code}"`))fail(`injected runtime missing zone ${code}`);
  for(const marker of ['5.3-master-plan','BBYAV5Atmosphere','BBYASystemMusic','BBYASystemMoney','BBYASystemLift','BBYAUILiveSystems','BBYAUIFloatingDock','BBYAUIContainerDock','BBYAClientPerformanceProfile'])if(!runtime.includes(marker))fail(`injected master marker missing: ${marker}`);
  const injectedReceipts=(runtime.match(/ProcessReceipt\s*=/g)||[]).length;if(injectedReceipts!==1)fail(`injected runtime ProcessReceipt owners=${injectedReceipts}`);
  if(!failed)pass('post-injection V5.3 master runtime valid');
 }
}
if(failed){console.error(`[BBYA VALIDATE] ${injected?'POST-INJECTION':'SOURCE'} BUILD REJECTED`);process.exit(1)}
console.log(`[BBYA VALIDATE] ${injected?'POST-INJECTION':'SOURCE'} CHECKS PASSED • V5.3 MASTER PLAN • CODED ZONES • LIVE SYSTEMS • UNIFIED UI`);
