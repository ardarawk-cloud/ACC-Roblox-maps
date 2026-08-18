const fs = require('fs');
const path = require('path');

const mapId = process.argv[2];
const injected = process.argv.includes('--injected');
if (mapId !== 'a-club') process.exit(0);

const root = process.cwd();
const read = p => fs.readFileSync(path.join(root, p), 'utf8');
const exists = p => fs.existsSync(path.join(root, p));
let failed = false;
const fail = m => { failed = true; console.error('[BBYA VALIDATE] FAIL:', m); };
const pass = m => console.log('[BBYA VALIDATE] PASS:', m);
const warn = m => console.warn('[BBYA VALIDATE] WARN:', m);

const registry = JSON.parse(read('maps/registry.json'));
const target = registry.maps?.[mapId];
if (!target || !target.enabled) fail('a-club registry target missing/disabled');
else {
 if (!/^\d+$/.test(String(target.universeId)) || !/^\d+$/.test(String(target.placeId))) fail('invalid Roblox IDs');
 if (!exists(target.file)) fail(`place file missing: ${target.file}`); else pass(`registry/place valid: ${target.file}`);
}

const serverSources = [
 'maps/a-club/bbya.core.server.lua',
 'maps/a-club/bbya.visual-rebuild-v4.server.lua',
 'maps/a-club/bbya.visual-polish-v4.server.lua',
 'maps/a-club/bbya.phase3-premium.server.lua',
 'maps/a-club/bbya.phase4-experience.server.lua',
 'maps/a-club/bbya.phase5-finish.server.lua',
 'maps/a-club/bbya.phase6-wayfinding.server.lua',
 'maps/a-club/bbya.production-qc-v4.server.lua',
 'maps/a-club/bbya.livefix-4.7.server.lua',
 'maps/a-club/bbya.front-lobby-v4.9.server.lua',
 'maps/a-club/bbya.build-validation.server.lua',
 'maps/a-club/bbya.playtest.server.lua',
 'maps/a-club/bbya.systems.server.lua',
 'maps/a-club/bbya.monetization.server.lua',
 'maps/a-club/bbya.music.server.lua',
 'maps/a-club/bbya.support-panel.server.lua',
 'maps/a-club/bbya.dj.server.lua',
 'maps/a-club/bbya.title-size.server.lua',
 'maps/a-club/bbya.rank-system.server.lua',
 'maps/a-club/bbya.queen-access-hotfix.server.lua',
 'maps/a-club/bbya.spawn-final.server.lua',
];
const clientSources = [
 'maps/a-club/bbya.client.lua','maps/a-club/bbya.music.client.lua','maps/a-club/bbya.support-panel.client.lua',
 'maps/a-club/bbya.monetization.client.lua','maps/a-club/bbya.support-celebration.client.lua',
 'maps/a-club/bbya.performance.client.lua','maps/a-club/bbya.ui-coordinator.client.lua',
 'maps/a-club/bbya.livefix-4.7.client.lua','maps/a-club/bbya.health.client.lua','maps/a-club/bbya.queen.client.lua',
];
const required = [...serverSources, ...clientSources, 'scripts/inject-bbya.js', 'scripts/publish-map.js'];
const missing = required.filter(p => !exists(p));
if (missing.length) fail(`missing source files: ${missing.join(', ')}`); else pass(`${required.length} required files present`);

const injector = read('scripts/inject-bbya.js');
for (const needle of ['bbya.front-lobby-v4.9.server.lua','BBYA_Front_Lobby_Final_v4_9','bbya.livefix-4.7.client.lua']) {
 if (!injector.includes(needle)) fail(`injector missing ${needle}`);
}
for (const retired of ['bbya.lobby-reference-v4.8.server.lua','BBYA_Front_Lobby_Reference_v4_8','bbya.server.lua','bbya.qc.server.lua','bbya.spawn-entry-hotfix.server.lua']) {
 if (injector.includes(retired)) fail(`retired runtime returned: ${retired}`);
}
pass('injector uses clean v4.9 lobby only');

const receiptOwners = serverSources.filter(p => exists(p) && /MarketplaceService\.ProcessReceipt\s*=/.test(read(p)));
if (receiptOwners.length !== 1) fail(`ProcessReceipt owners=${receiptOwners.length}: ${receiptOwners.join(', ') || 'none'}`);
else pass(`single ProcessReceipt owner: ${receiptOwners[0]}`);

if (target && exists(target.file)) {
 const xml = read(target.file);
 if (!xml.includes('</roblox>')) fail('RBXLX missing closing tag');
 if (injected) {
  const begin='<!-- BBYA_RUNTIME_BEGIN -->', end='<!-- BBYA_RUNTIME_END -->';
  const bc=xml.split(begin).length-1, ec=xml.split(end).length-1;
  if (bc!==1 || ec!==1) fail(`runtime markers invalid begin=${bc} end=${ec}`);
  const runtime = bc===1 && ec===1 ? xml.slice(xml.indexOf(begin), xml.indexOf(end)+end.length) : '';
  const runtimeNames = [
   'BBYA_Clean_Functional_Core_v3','BBYA_Premium_Visual_Rebuild_v4','BBYA_Live_Playtest_Fix_v4_7',
   'BBYA_Front_Lobby_Final_v4_9','BBYA_Build_Validation','BBYA_Queen_Playtest_System_Test_v1',
   'BBYA_Functional_Systems_v2','BBYA_Monetization_Backend','BBYA_Master_Music_Vault',
   'BBYA_Final_Arrival_Spawn','BBYA_Dance_Studio_Client','BBYA_Music_Client',
   'BBYA_UI_Coordinator_Client','BBYA_Adaptive_Performance_Client','BBYA_Live_Mobile_UI_Fix_v4_7'
  ];
  for (const name of runtimeNames) if (!runtime.includes(`<string name="Name">${name}</string>`)) fail(`runtime missing ${name}`);
  for (const retired of ['BBYA_Front_Lobby_Reference_v4_8','BBYA_Runtime_Core','BBYA_Functional_QC','BBYA_Spawn_Entry']) {
   if (runtime.includes(retired)) fail(`retired injected script present: ${retired}`);
  }
  const receipts=(runtime.match(/MarketplaceService\.ProcessReceipt\s*=/g)||[]).length;
  if (receipts!==1) fail(`injected ProcessReceipt count=${receipts}`);
  if (!runtime.includes('RunPlaytestCheck')) fail('playtest harness missing');
  if (!runtime.includes('BBYAFrontLobbyClean')) fail('v4.9 clean-lobby marker missing');
  if (!failed) pass('post-injection v4.9 runtime structure valid');
 }
}

if (exists('maps/a-club/bbya.monetization.server.lua') && /=\s*0\b/.test(read('maps/a-club/bbya.monetization.server.lua'))) {
 warn('VIP / Developer Product IDs still pending; purchases remain disabled.');
}

if (failed) {
 console.error(`[BBYA VALIDATE] ${injected ? 'POST-INJECTION' : 'SOURCE'} BUILD REJECTED`);
 process.exit(1);
}
console.log(`[BBYA VALIDATE] ${injected ? 'POST-INJECTION' : 'SOURCE'} CHECKS PASSED • FRONT LOBBY v4.9`);
