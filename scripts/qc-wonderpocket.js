const fs = require('fs');
const path = require('path');

const root = process.cwd();
const dir = path.join(root, 'maps/wonderpocket');
const errors = [];
const warnings = [];

const required = [
  'GameConfig.lua','wonderpocket.bootstrap.server.lua','wonderpocket.plots.server.lua',
  'wonderpocket.placement.server.lua','wonderpocket.buildpreview.client.lua',
  'wonderpocket.premium-ui.client.lua','wonderpocket.gardening.server.lua',
  'wonderpocket.inventory.server.lua','wonderpocket.wondi.server.lua',
  'wonderpocket.wondi-meet.server.lua','wonderpocket.tutorial.server.lua',
  'wonderpocket.tutorial.client.lua','wonderpocket.adventure-gate.server.lua',
  'wonderpocket.treasure-island.server.lua','wonderpocket.health.client.lua'
];
for (const f of required) if (!fs.existsSync(path.join(dir,f))) errors.push(`Missing required file: ${f}`);

const luaFiles = fs.readdirSync(dir).filter(f => f.endsWith('.lua'));
for (const f of luaFiles) {
  const src = fs.readFileSync(path.join(dir,f),'utf8');
  if (src.includes('WonderPocket_Remotes')) warnings.push(`${f}: legacy remote casing found; assembler will normalize it.`);
  if (src.includes('BBYA') || src.includes('a-club')) errors.push(`${f}: foreign-map token detected (BBYA/a-club).`);
  if (/GetAttribute\(["']WP_Coins["']\)|SetAttribute\(["']WP_Coins["']/.test(src)) errors.push(`${f}: legacy WP_Coins economy attribute detected; use Coins.`);
  if (/GetAttribute\(["']WP_Stars["']\)|SetAttribute\(["']WP_Stars["']/.test(src)) errors.push(`${f}: legacy WP_Stars economy attribute detected; use Stars.`);
  if ((f.includes('gardening') || f.includes('quests')) && src.includes('leaderstats')) errors.push(`${f}: gameplay rewards must use canonical saved attributes, not leaderstats.`);
}

const configSrc = fs.readFileSync(path.join(dir,'GameConfig.lua'),'utf8');
if (!configSrc.includes('1.0.0-closed-test-build-candidate')) warnings.push('GameConfig is not marked as the v1.0 closed-test build candidate.');
if (!configSrc.includes('PublishAllowed = false')) errors.push('Closed-test candidate must keep PublishAllowed = false.');

const registry = JSON.parse(fs.readFileSync(path.join(root,'maps/registry.json'),'utf8'));
const wp = registry.maps?.wonderpocket;
if (!wp) errors.push('wonderpocket missing from registry.');
else {
  if (String(wp.universeId) !== '8805231520') errors.push('Unexpected WONDERPOCKET universeId.');
  if (String(wp.placeId) !== '124843214013484') errors.push('Unexpected WONDERPOCKET placeId.');
  if (wp.enabled !== false) errors.push('WONDERPOCKET registry must remain disabled before explicit publish approval.');
}

const place = path.join(dir,'place.rbxlx');
if (!fs.existsSync(place)) errors.push('place.rbxlx not built. Run node scripts/build-wonderpocket.js first.');
else {
  const xml = fs.readFileSync(place,'utf8');
  if (!xml.includes('</roblox>')) errors.push('place.rbxlx invalid: missing </roblox>.');
  if (xml.includes('BBYA') || xml.includes('a-club')) errors.push('place.rbxlx contains foreign-map token.');
  if (!xml.includes('WONDERPOCKET_Remotes')) errors.push('Canonical WONDERPOCKET_Remotes string missing from assembled place.');
  for (const marker of ['wonderpocket.tutorial','wonderpocket.adventure-gate','wonderpocket.wondi-meet']) {
    if (!xml.includes(marker)) errors.push(`Assembled place missing runtime marker: ${marker}`);
  }
}

console.log('[WONDERPOCKET QC v1.0]');
for (const w of warnings) console.log('WARN:', w);
if (errors.length) {
  for (const e of errors) console.error('ERROR:', e);
  process.exit(1);
}
console.log(`PASS: ${luaFiles.length} Lua files checked; ${warnings.length} warning(s).`);
