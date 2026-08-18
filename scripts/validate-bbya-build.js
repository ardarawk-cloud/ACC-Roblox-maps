const fs = require('fs');
const path = require('path');

const mapId = process.argv[2];
const validateInjected = process.argv.includes('--injected');
if (mapId !== 'a-club') {
  console.log(`[BBYA VALIDATE] ${mapId || '(none)'} is not a-club; skipped.`);
  process.exit(0);
}

const root = process.cwd();
const read = (p) => fs.readFileSync(path.join(root, p), 'utf8');
const exists = (p) => fs.existsSync(path.join(root, p));
const fail = (msg) => { console.error(`[BBYA VALIDATE] FAIL: ${msg}`); process.exitCode = 1; };
const pass = (msg) => console.log(`[BBYA VALIDATE] PASS: ${msg}`);
const warn = (msg) => console.warn(`[BBYA VALIDATE] WARN: ${msg}`);

const registryPath = 'maps/registry.json';
if (!exists(registryPath)) {
  fail('maps/registry.json missing');
  process.exit(1);
}
const registry = JSON.parse(read(registryPath));
const target = registry.maps?.[mapId];
if (!target) fail('a-club missing from registry');
else {
  if (!target.enabled) fail('a-club is disabled');
  if (!/^\d+$/.test(String(target.universeId))) fail('invalid universeId');
  if (!/^\d+$/.test(String(target.placeId))) fail('invalid placeId');
  if (!exists(target.file)) fail(`place file missing: ${target.file}`);
  else pass(`registry target valid: ${target.file}`);
}

const requiredSources = [
  'maps/a-club/bbya.core.server.lua',
  'maps/a-club/bbya.visual-rebuild-v4.server.lua',
  'maps/a-club/bbya.visual-polish-v4.server.lua',
  'maps/a-club/bbya.phase3-premium.server.lua',
  'maps/a-club/bbya.phase4-experience.server.lua',
  'maps/a-club/bbya.phase5-finish.server.lua',
  'maps/a-club/bbya.phase6-wayfinding.server.lua',
  'maps/a-club/bbya.production-qc-v4.server.lua',
  'maps/a-club/bbya.build-validation.server.lua',
  'maps/a-club/bbya.playtest.server.lua',
  'maps/a-club/bbya.systems.server.lua',
  'maps/a-club/bbya.monetization.server.lua',
  'maps/a-club/bbya.music.server.lua',
  'maps/a-club/bbya.support-panel.server.lua',
  'maps/a-club/bbya.dj.server.lua',
  'maps/a-club/bbya.rank-system.server.lua',
  'maps/a-club/bbya.queen-access-hotfix.server.lua',
  'maps/a-club/bbya.spawn-final.server.lua',
  'maps/a-club/bbya.client.lua',
  'maps/a-club/bbya.music.client.lua',
  'maps/a-club/bbya.support-panel.client.lua',
  'maps/a-club/bbya.monetization.client.lua',
  'maps/a-club/bbya.support-celebration.client.lua',
  'maps/a-club/bbya.performance.client.lua',
  'maps/a-club/bbya.ui-coordinator.client.lua',
  'maps/a-club/bbya.health.client.lua',
  'maps/a-club/bbya.queen.client.lua',
  'scripts/inject-bbya.js',
  'scripts/publish-map.js',
];

const missingSources = requiredSources.filter((p) => !exists(p));
if (missingSources.length) fail(`required source files missing: ${missingSources.join(', ')}`);
else pass(`${requiredSources.length} required source files present`);

const injector = exists('scripts/inject-bbya.js') ? read('scripts/inject-bbya.js') : '';
const mustInclude = [
  'bbya.core.server.lua',
  'bbya.phase6-wayfinding.server.lua',
  'bbya.build-validation.server.lua',
  'bbya.playtest.server.lua',
  'bbya.spawn-final.server.lua',
  'bbya.ui-coordinator.client.lua',
  'bbya.health.client.lua',
];
for (const needle of mustInclude) {
  if (!injector.includes(needle)) fail(`injector missing ${needle}`);
}

const retiredInjectorSources = [
  "readLua('maps/a-club/bbya.server.lua')",
  "readLua('maps/a-club/bbya.qc.server.lua')",
  "readLua('maps/a-club/bbya.spawn-entry-hotfix.server.lua')",
];
for (const needle of retiredInjectorSources) {
  if (injector.includes(needle)) fail(`retired source returned to injector: ${needle}`);
}
pass('injector clean-core policy checked');

const activeServerSources = requiredSources.filter((p) => p.endsWith('.server.lua'));
const receiptOwners = [];
for (const p of activeServerSources) {
  if (!exists(p)) continue;
  const src = read(p);
  if (/MarketplaceService\.ProcessReceipt\s*=/.test(src)) receiptOwners.push(p);
}
if (receiptOwners.length !== 1) fail(`expected exactly 1 ProcessReceipt owner; found ${receiptOwners.length}: ${receiptOwners.join(', ') || 'none'}`);
else pass(`single ProcessReceipt owner: ${receiptOwners[0]}`);

const retiredRuntimeNames = ['BBYA Visual v1.2', 'BBYA Social Systems', 'BBYA Arrival Neon Box'];
for (const name of retiredRuntimeNames) {
  if (injector.includes(name)) fail(`injector contains retired runtime name: ${name}`);
}
pass('legacy runtime names absent from injector');

if (target && exists(target.file)) {
  const xml = read(target.file);
  if (!xml.includes('</roblox>')) fail('RBXLX missing </roblox>');
  else pass('RBXLX closing tag present');

  if (validateInjected) {
    const begin = '<!-- BBYA_RUNTIME_BEGIN -->';
    const end = '<!-- BBYA_RUNTIME_END -->';
    const beginCount = xml.split(begin).length - 1;
    const endCount = xml.split(end).length - 1;
    if (beginCount !== 1 || endCount !== 1) fail(`runtime marker count invalid: begin=${beginCount}, end=${endCount}`);
    else pass('exactly one injected runtime block present');

    const start = xml.indexOf(begin);
    const finish = xml.indexOf(end);
    const runtime = start >= 0 && finish > start ? xml.slice(start, finish + end.length) : '';
    const requiredRuntimeScripts = [
      'BBYA_Clean_Functional_Core_v3',
      'BBYA_Premium_Visual_Rebuild_v4',
      'BBYA_Premium_Phase_6_v4_6',
      'BBYA_Build_Validation_v1_3',
      'BBYA_Queen_Playtest_System_Test_v1',
      'BBYA_Functional_Systems_v2',
      'BBYA_Monetization_Backend',
      'BBYA_Master_Music_Vault',
      'BBYA_Final_Arrival_Spawn',
      'BBYA_Dance_Studio_Client',
      'BBYA_Music_Client',
      'BBYA_UI_Coordinator_Client',
      'BBYA_Adaptive_Performance_Client',
      'BBYA_Queen_Playtest_Health_HUD_v1_1',
    ];
    for (const scriptName of requiredRuntimeScripts) {
      if (!runtime.includes(`<string name="Name">${scriptName}</string>`)) fail(`injected runtime missing script: ${scriptName}`);
    }

    const retiredInjectedScripts = ['BBYA_Runtime_Core', 'BBYA_Functional_QC', 'BBYA_Spawn_Entry'];
    for (const scriptName of retiredInjectedScripts) {
      if (runtime.includes(`<string name="Name">${scriptName}</string>`)) fail(`retired script still injected: ${scriptName}`);
    }

    const receiptAssignments = (runtime.match(/MarketplaceService\.ProcessReceipt\s*=/g) || []).length;
    if (receiptAssignments !== 1) fail(`injected runtime ProcessReceipt assignments=${receiptAssignments}, expected 1`);
    else pass('injected runtime has one ProcessReceipt assignment');

    if (!runtime.includes('RunPlaytestCheck')) fail('injected runtime missing Queen playtest RemoteFunction');
    else pass('Queen playtest harness injected');

    if (!process.exitCode) pass('post-injection runtime structure valid');
  }
}

const monetization = exists('maps/a-club/bbya.monetization.server.lua') ? read('maps/a-club/bbya.monetization.server.lua') : '';
const zeroIds = (monetization.match(/=\s*0\b/g) || []).length;
if (zeroIds > 0) warn('VIP / Developer Product IDs are still pending; purchase UI must remain safely disabled.');

if (process.exitCode) {
  console.error(`[BBYA VALIDATE] ${validateInjected ? 'Injected build' : 'Source build'} rejected before publish.`);
  process.exit(process.exitCode);
}
console.log(`[BBYA VALIDATE] ${validateInjected ? 'POST-INJECTION' : 'SOURCE'} CHECKS PASSED`);
