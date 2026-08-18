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
  'wonderpocket.inventory.server.lua','wonderpocket.furniture-inventory.server.lua',
  'wonderpocket.wondi.server.lua','wonderpocket.wondi-meet.server.lua',
  'wonderpocket.tutorial.server.lua','wonderpocket.tutorial.client.lua',
  'wonderpocket.adventure.server.lua','wonderpocket.adventure-gate.server.lua',
  'wonderpocket.treasure-island.server.lua','wonderpocket.health.client.lua',
  'wonderpocket.quests.server.lua','wonderpocket.retention.server.lua'
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

const read = f => fs.readFileSync(path.join(dir,f),'utf8');
const configSrc = read('GameConfig.lua');
const bootstrapSrc = read('wonderpocket.bootstrap.server.lua');
const placementSrc = read('wonderpocket.placement.server.lua');
const previewSrc = read('wonderpocket.buildpreview.client.lua');
const plotsSrc = read('wonderpocket.plots.server.lua');
const gardenSrc = read('wonderpocket.gardening.server.lua');
const questSrc = read('wonderpocket.quests.server.lua');
const retentionSrc = read('wonderpocket.retention.server.lua');
const inventorySrc = read('wonderpocket.furniture-inventory.server.lua');
const adventureSrc = read('wonderpocket.adventure.server.lua');
const treasureSrc = read('wonderpocket.treasure-island.server.lua');

if (!configSrc.includes('1.1.0-release-candidate-hardening')) errors.push('GameConfig is not marked v1.1 release-candidate hardening.');
if (!configSrc.includes('PublishAllowed = false')) errors.push('Release candidate must keep PublishAllowed = false.');
for (const marker of [
  'DataSchemaVersion = 3','RevisionSafeSaves = true','CriticalSaveBus = true',
  'PersistentPlotState = true','FullFootprintPlotValidation = true',
  'ServerAuthoritativeAdventureRewards = true','AdventureDeadlineSeconds = 240'
]) if (!configSrc.includes(marker)) errors.push(`GameConfig missing hardening marker: ${marker}`);

if (!bootstrapSrc.includes('DATA_SCHEMA = 3')) errors.push('Main player data schema is not v3.');
if (!bootstrapSrc.includes('WONDERPOCKET_CriticalSave')) errors.push('Critical save bus missing from bootstrap.');
if (!bootstrapSrc.includes('revision[player]')) errors.push('Revision-safe main save guard missing.');
if (!bootstrapSrc.includes('WP_QuestStarterRewarded')) errors.push('Starter quest reward state is not persisted in main data.');
if (!bootstrapSrc.includes('WP_OfflineSeconds')) errors.push('Offline retention handoff missing from main data.');

if (!placementSrc.includes('footprintInsideOwnPlot')) errors.push('Server furniture validation does not check full footprint.');
if (!placementSrc.includes('relX=') || !placementSrc.includes('relY=') || !placementSrc.includes('relZ=')) errors.push('Furniture persistence is not fully plot-relative.');
if (!placementSrc.includes('revision[player]')) errors.push('Furniture placement persistence is not revision-safe.');
if (!previewSrc.includes('footprintValid')) errors.push('Client ghost preview does not mirror full-footprint validation.');
if (!plotsSrc.includes('WP_PlotCenterY')) errors.push('Stable plot Y coordinate is missing.');
if (!plotsSrc.includes('WONDERPOCKET_PlotHomes')) errors.push('Personal plot home runtime is missing.');

if (!gardenSrc.includes('WONDERPOCKET_Garden_v1')) errors.push('Persistent garden DataStore is missing.');
if (!gardenSrc.includes('readyAt')) errors.push('Garden does not persist absolute growth deadlines.');
if (!gardenSrc.includes('WP_GardenSaveHealthy')) errors.push('Garden save health signal missing.');

if (!questSrc.includes('WP_QuestStarterRewarded')) errors.push('Starter quest lacks idempotent persistent reward flag.');
if (!questSrc.includes('WONDERPOCKET_CriticalSave')) errors.push('Starter quest does not flush critical rewards.');
if (retentionSrc.includes('DataStoreService')) errors.push('Retention still uses a separate DataStore instead of canonical player data.');
if (!retentionSrc.includes('WP_OfflineSeconds')) errors.push('Retention does not consume canonical offline elapsed time.');
if (!inventorySrc.includes('revision[player]')) errors.push('Furniture inventory persistence is not revision-safe.');

if (!adventureSrc.includes('SERVER_AUTHORITATIVE')) errors.push('Adventure API does not explicitly reject client-authoritative progress.');
if (/run\.treasure\s*\+=/.test(adventureSrc)) errors.push('Adventure remote still increments treasure progress from client events.');
if (!treasureSrc.includes('DURATION_SECONDS = 240')) errors.push('Treasure Island server deadline is not enforced at 240 seconds.');
if (!treasureSrc.includes('WONDERPOCKET_CriticalSave')) errors.push('Adventure completion does not flush critical reward data.');

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
  for (const marker of ['wonderpocket.tutorial','wonderpocket.adventure-gate','wonderpocket.wondi-meet','wonderpocket.furniture-inventory','wonderpocket.gardening']) {
    if (!xml.includes(marker)) errors.push(`Assembled place missing runtime marker: ${marker}`);
  }
}

console.log('[WONDERPOCKET QC v1.1]');
for (const w of warnings) console.log('WARN:', w);
if (errors.length) {
  for (const e of errors) console.error('ERROR:', e);
  process.exit(1);
}
console.log(`PASS: ${luaFiles.length} Lua files checked; ${warnings.length} warning(s).`);
