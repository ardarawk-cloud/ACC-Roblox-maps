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

const registry = JSON.parse(read('maps/registry.json'));
const target = registry.maps?.[mapId];
if (!target || !target.enabled) fail('a-club registry target missing/disabled');
else {
  if (!/^\d+$/.test(String(target.universeId)) || !/^\d+$/.test(String(target.placeId))) fail('invalid Roblox IDs');
  if (!exists(target.file)) fail(`place file missing: ${target.file}`);
  else pass(`registry/place valid: ${target.file}`);
}

for (const p of ['maps/a-club/bbya.v5-layout.server.lua','scripts/inject-bbya.js','scripts/publish-map.js']) {
  if (!exists(p)) fail(`required V5 file missing: ${p}`);
}
if (!failed) pass('V5 greybox source files present');

const layout = exists('maps/a-club/bbya.v5-layout.server.lua') ? read('maps/a-club/bbya.v5-layout.server.lua') : '';
for (const marker of ['BBYA V5 ARCHITECTURAL GREYBOX','Ground = Y 0, VIP = Y 18, Rooftop = Y 36','MAIN ENTRANCE','Lift Core','WEST STAIR G-VIP','EAST STAIR G-VIP','CHILL LOUNGE']) {
  if (!layout.includes(marker)) fail(`V5 layout missing architectural marker: ${marker}`);
}
for (const forbidden of ['palm(', 'sofa(', 'daybed(', 'cabana', 'Pool Party Logo']) {
  if (layout.includes(forbidden)) fail(`decoration leaked into greybox source: ${forbidden}`);
}

const injector = exists('scripts/inject-bbya.js') ? read('scripts/inject-bbya.js') : '';
if (!injector.includes('bbya.v5-layout.server.lua')) fail('injector missing V5 layout source');
if (!injector.includes('BBYA_V5_ARCHITECTURAL_GREYBOX')) fail('injector missing V5 runtime name');
for (const retired of [
  'bbya.visual-rebuild-v4.server.lua','bbya.visual-polish-v4.server.lua','bbya.phase3-premium.server.lua',
  'bbya.phase4-experience.server.lua','bbya.phase5-finish.server.lua','bbya.phase6-wayfinding.server.lua',
  'bbya.livefix-4.7.server.lua','bbya.front-lobby-v4.9.server.lua','bbya.remove-trees.server.lua',
  'bbya.client.lua','bbya.music.client.lua','bbya.monetization.client.lua','bbya.ui-coordinator.client.lua'
]) {
  if (injector.includes(retired)) fail(`old runtime still in V5 injector: ${retired}`);
}
if (!failed) pass('injector is V5 greybox-only');

if (target && exists(target.file)) {
  const xml = read(target.file);
  if (!xml.includes('</roblox>')) fail('RBXLX missing closing tag');
  if (injected) {
    const begin='<!-- BBYA_RUNTIME_BEGIN -->', end='<!-- BBYA_RUNTIME_END -->';
    const bc=xml.split(begin).length-1, ec=xml.split(end).length-1;
    if (bc!==1 || ec!==1) fail(`runtime markers invalid begin=${bc} end=${ec}`);
    const runtime = bc===1 && ec===1 ? xml.slice(xml.indexOf(begin), xml.indexOf(end)+end.length) : '';
    if (!runtime.includes('<string name="Name">BBYA_V5_ARCHITECTURAL_GREYBOX</string>')) fail('V5 greybox script missing after injection');
    const scripts = (runtime.match(/<Item class="Script"/g) || []).length;
    const locals = (runtime.match(/<Item class="LocalScript"/g) || []).length;
    if (scripts !== 1) fail(`expected exactly 1 server script for greybox; found ${scripts}`);
    if (locals !== 0) fail(`expected 0 LocalScripts for architecture review; found ${locals}`);
    for (const oldName of ['BBYA_Premium_Visual_Rebuild_v4','BBYA_Front_Lobby_Final_v4_9','BBYA_Dance_Studio_Client','BBYA_Music_Client','BBYA_Monetization_Client']) {
      if (runtime.includes(oldName)) fail(`legacy runtime leaked into greybox: ${oldName}`);
    }
    if (!failed) pass('post-injection V5 architecture-only runtime valid');
  }
}

if (failed) {
  console.error(`[BBYA VALIDATE] ${injected ? 'POST-INJECTION' : 'SOURCE'} BUILD REJECTED`);
  process.exit(1);
}
console.log(`[BBYA VALIDATE] ${injected ? 'POST-INJECTION' : 'SOURCE'} CHECKS PASSED • V5 ARCHITECTURAL GREYBOX`);
