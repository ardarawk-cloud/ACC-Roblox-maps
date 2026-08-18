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
  'wonderpocket.inventory.server.lua','wonderpocket.wondi.server.lua'
];
for (const f of required) if (!fs.existsSync(path.join(dir,f))) errors.push(`Missing required file: ${f}`);

const luaFiles = fs.readdirSync(dir).filter(f => f.endsWith('.lua'));
for (const f of luaFiles) {
  const src = fs.readFileSync(path.join(dir,f),'utf8');
  if (src.includes('WonderPocket_Remotes')) warnings.push(`${f}: legacy remote casing found; assembler will normalize it.`);
  if (src.includes('BBYA') || src.includes('a-club')) errors.push(`${f}: foreign-map token detected (BBYA/a-club).`);
}

const registry = JSON.parse(fs.readFileSync(path.join(root,'maps/registry.json'),'utf8'));
const wp = registry.maps?.wonderpocket;
if (!wp) errors.push('wonderpocket missing from registry.');
else {
  if (String(wp.universeId) !== '8805231520') errors.push('Unexpected WONDERPOCKET universeId.');
  if (String(wp.placeId) !== '124843214013484') errors.push('Unexpected WONDERPOCKET placeId.');
  if (wp.enabled !== false) warnings.push('WONDERPOCKET registry is enabled; closed-test branch normally keeps this false until explicit publish approval.');
}

const place = path.join(dir,'place.rbxlx');
if (!fs.existsSync(place)) errors.push('place.rbxlx not built. Run node scripts/build-wonderpocket.js first.');
else {
  const xml = fs.readFileSync(place,'utf8');
  if (!xml.includes('</roblox>')) errors.push('place.rbxlx invalid: missing </roblox>.');
  if (xml.includes('BBYA')) errors.push('place.rbxlx contains BBYA token.');
  if (!xml.includes('WONDERPOCKET_Remotes')) warnings.push('Remote folder string not visible in assembled place; verify bootstrap/runtime scripts.');
}

console.log('[WONDERPOCKET QC]');
for (const w of warnings) console.log('WARN:', w);
if (errors.length) {
  for (const e of errors) console.error('ERROR:', e);
  process.exit(1);
}
console.log(`PASS: ${luaFiles.length} Lua files checked; ${warnings.length} warning(s).`);
