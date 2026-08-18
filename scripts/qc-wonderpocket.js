const fs = require('fs');
const path = require('path');

const root = process.cwd();
const dir = path.join(root, 'maps/wonderpocket');
const errors = [];
const warnings = [];

const required = [
  'GameConfig.lua','wonderpocket.bootstrap.server.lua','wonderpocket.plots.server.lua',
  'wonderpocket.placement.server.lua','wonderpocket.buildpreview.client.lua',
  'wonderpocket.client.lua','wonderpocket.premium-ui.client.lua','wonderpocket.data-safety.client.lua',
  'wonderpocket.gardening.server.lua','wonderpocket.inventory.server.lua',
  'wonderpocket.furniture-inventory.server.lua','wonderpocket.economy-audit.server.lua',
  'wonderpocket.wonderdex.server.lua','wonderpocket.wondi.server.lua','wonderpocket.wondi-meet.server.lua',
  'wonderpocket.tutorial.server.lua','wonderpocket.tutorial.client.lua','wonderpocket.onboarding.client.lua',
  'wonderpocket.adventure.server.lua','wonderpocket.adventure-gate.server.lua',
  'wonderpocket.treasure-island.server.lua','wonderpocket.health.client.lua',
  'wonderpocket.quests.server.lua','wonderpocket.retention.server.lua'
];
for (const f of required) if (!fs.existsSync(path.join(dir,f))) errors.push(`Missing required file: ${f}`);

const luaFiles = fs.readdirSync(dir).filter(f => f.endsWith('.lua'));
for (const f of luaFiles) {
  const src = fs.readFileSync(path.join(dir,f),'utf8');
  if (src.includes('WonderPocket_Remotes')) warnings.push(`${f}: legacy remote casing found; assembler will normalize it.`);
  if (src.includes('BBYA') || src.includes('a-club')) errors.push(`${f}: foreign-map token detected.`);
  if (/GetAttribute\(["']WP_Coins["']\)|SetAttribute\(["']WP_Coins["']/.test(src)) errors.push(`${f}: legacy WP_Coins detected.`);
  if (/GetAttribute\(["']WP_Stars["']\)|SetAttribute\(["']WP_Stars["']/.test(src)) errors.push(`${f}: legacy WP_Stars detected.`);
  if ((f.includes('gardening') || f.includes('quests')) && src.includes('leaderstats')) errors.push(`${f}: gameplay rewards must use saved attributes, not leaderstats.`);
}

const read = f => fs.readFileSync(path.join(dir,f),'utf8');
const configSrc = read('GameConfig.lua');
const bootstrapSrc = read('wonderpocket.bootstrap.server.lua');
const placementSrc = read('wonderpocket.placement.server.lua');
const previewSrc = read('wonderpocket.buildpreview.client.lua');
const coreClientSrc = read('wonderpocket.client.lua');
const premiumSrc = read('wonderpocket.premium-ui.client.lua');
const dataSafetySrc = read('wonderpocket.data-safety.client.lua');
const plotsSrc = read('wonderpocket.plots.server.lua');
const gardenSrc = read('wonderpocket.gardening.server.lua');
const generalInventorySrc = read('wonderpocket.inventory.server.lua');
const questSrc = read('wonderpocket.quests.server.lua');
const retentionSrc = read('wonderpocket.retention.server.lua');
const inventorySrc = read('wonderpocket.furniture-inventory.server.lua');
const shopSrc = read('wonderpocket.shop.server.lua');
const economyAuditSrc = read('wonderpocket.economy-audit.server.lua');
const dexSrc = read('wonderpocket.wonderdex.server.lua');
const adventureSrc = read('wonderpocket.adventure.server.lua');
const treasureSrc = read('wonderpocket.treasure-island.server.lua');
const healthSrc = read('wonderpocket.health.client.lua');

if (!configSrc.includes('1.3.0-fail-closed-data-safety')) errors.push('GameConfig is not marked v1.3 fail-closed data safety.');
if (!configSrc.includes('PublishAllowed = false')) errors.push('Closed-test build must keep PublishAllowed = false.');
for (const marker of [
  'DataSchemaVersion = 4','RevisionSafeSaves = true','CriticalSaveBus = true',
  'CanonicalSeedInventory = true','TransactionRateLimits = true','EconomyAuditAttributes = true',
  'FailClosedDataLoads = true','ReadOnlyOnLoadFailure = true','NoDefaultOverwriteOnReadFailure = true',
  'PlayerFacingReadOnlyWarning = true','SeedConsumptionEnabled = true','SeedReturnOnHarvest = true',
  'PersistentPlotState = true','FullFootprintPlotValidation = true',
  'ServerAuthoritativeAdventureRewards = true','AdventureDeadlineSeconds = 240',
  'ServerAuthoritativeDiscovery = true'
]) if (!configSrc.includes(marker)) errors.push(`GameConfig missing v1.3 marker: ${marker}`);

// Canonical player data must fail closed: failed reads may not create a default-backed session.
for (const marker of ['DATA_SCHEMA = 4','WP_DataLoadFailed','WP_DataReadOnly','StateRemote:FireClient(player, "LOAD_FAILED")']) {
  if (!bootstrapSrc.includes(marker)) errors.push(`Main data safety missing: ${marker}`);
}
if (!bootstrapSrc.includes('if not ok then')) errors.push('Main player load has no explicit failed-read branch.');
if (!bootstrapSrc.includes('return\n    end') && !bootstrapSrc.includes('return\r\n    end')) warnings.push('Verify main failed-read branch returns before session initialization.');
if (!bootstrapSrc.includes('player:GetAttribute("WP_DataReadOnly") == true')) errors.push('Main save does not refuse read-only sessions.');
if (!bootstrapSrc.includes('snapshot.inventory = table.clone')) errors.push('Nested inventory snapshot is not cloned before main save.');
if (!bootstrapSrc.includes('CarrotSeed')) errors.push('Canonical CarrotSeed persistence missing.');

// Secondary DataStores must also fail closed rather than normalize failed reads into blank state.
for (const [label,src,flag] of [
  ['Furniture inventory',inventorySrc,'WP_InventoryLoadFailed'],
  ['Placed furniture',placementSrc,'WP_FurnitureLoadFailed'],
  ['Garden',gardenSrc,'WP_GardenLoadFailed'],
  ['WonderDex',dexSrc,'WP_DexLoadFailed'],
]) {
  if (!src.includes(flag)) errors.push(`${label} missing fail-closed flag ${flag}.`);
  if (!src.includes('if not ok then')) errors.push(`${label} missing explicit failed-read branch.`);
}
if (!inventorySrc.includes('WP_InventoryLoaded",true')) errors.push('Furniture inventory never marks successful load.');
if (!placementSrc.includes('WP_FurnitureLoaded",true')) errors.push('Placed furniture never marks successful load.');
if (!gardenSrc.includes('WP_GardenReady", true')) errors.push('Garden never marks successful load.');
if (!dexSrc.includes('WP_DexLoaded",true')) errors.push('WonderDex never marks successful load.');

// Economy and transaction integrity.
if (!generalInventorySrc.includes('AuthoritativeSource')) errors.push('General inventory is not explicitly mirror-only.');
if (!generalInventorySrc.includes('GetAttributeChangedSignal("CarrotSeed")')) errors.push('Inventory mirror does not follow CarrotSeed.');
if (!gardenSrc.includes('seeds - 1')) errors.push('Planting does not decrement CarrotSeed.');
if (!gardenSrc.includes('GetAttribute("CarrotSeed")) or 0) + 1')) errors.push('Harvest does not return CarrotSeed.');
if (!gardenSrc.includes('actionLocks')) errors.push('Garden action lock missing.');
if (!placementSrc.includes('placeBusy') || !placementSrc.includes('RATE_LIMITED')) errors.push('Placement spam guard missing.');
if (!placementSrc.includes('footprintInsideOwnPlot')) errors.push('Full furniture footprint validation missing.');
if (!placementSrc.includes('relX=') || !placementSrc.includes('relY=') || !placementSrc.includes('relZ=')) errors.push('Furniture save is not fully plot-relative.');
if (!previewSrc.includes('footprintValid')) errors.push('Client ghost does not mirror footprint validation.');
if (!shopSrc.includes('purchaseBusy') || !shopSrc.includes('RATE_LIMITED')) errors.push('Shop spam guard missing.');
if (!shopSrc.includes('DATA_READ_ONLY')) errors.push('Shop does not explicitly reject read-only data sessions.');
if (!economyAuditSrc.includes('WONDERPOCKET_EconomyAudit') || !economyAuditSrc.includes('WP_EconTxnSeq')) errors.push('Central economy audit bus/sequence missing.');
for (const [label,src] of [['Garden',gardenSrc],['Quest',questSrc],['Retention',retentionSrc],['Shop',shopSrc],['Treasure',treasureSrc]]) {
  if (!src.includes('EconomyAudit:Fire')) errors.push(`${label} is not economy-audited.`);
}
if (retentionSrc.includes('DataStoreService')) errors.push('Retention must not own a separate DataStore.');
if (!questSrc.includes('WP_QuestStarterRewarded')) errors.push('Starter quest persistent idempotency flag missing.');

// Server authority.
if (!dexSrc.includes('SERVER_AUTHORITATIVE')) errors.push('WonderDex does not reject client discovery.');
if (!dexSrc.includes('WONDERPOCKET_WonderDex_v1')) errors.push('WonderDex persistence store missing.');
if (!adventureSrc.includes('SERVER_AUTHORITATIVE')) errors.push('Adventure API does not reject client progress.');
if (/run\.treasure\s*\+=/.test(adventureSrc)) errors.push('Adventure remote still increments treasure from client events.');
if (!treasureSrc.includes('DURATION_SECONDS = 240')) errors.push('Treasure Island deadline is not server-enforced at 240s.');

// Mobile/UI safety.
if (premiumSrc.includes('.PaddingTop')) errors.push('Invalid Frame.PaddingTop regression detected in premium UI.');
if (!premiumSrc.includes('UISizeConstraint')) errors.push('Premium UI is missing responsive size constraints.');
if (!premiumSrc.includes('content.Name="Content"')) errors.push('Premium panels do not isolate header from content layout.');
if (!premiumSrc.includes('RATE_LIMITED')) errors.push('Premium UI does not provide rate-limit feedback.');
if (coreClientSrc.includes('Build • Care • Explore • Connect')) errors.push('Legacy bottom HUD hint would overlap mobile dock.');
if (!coreClientSrc.includes('CarrotSeed')) errors.push('Core mobile HUD does not show canonical seeds.');
for (const marker of ['WP_DataReadOnly','WP_DataLoadFailed','WP_InventoryLoadFailed','WP_FurnitureLoadFailed','WP_GardenLoadFailed','WP_DexLoadFailed','READ-ONLY']) {
  if (!dataSafetySrc.includes(marker)) errors.push(`Read-only warning UI missing marker: ${marker}`);
}
for (const marker of ['WP_DataReadOnly','WP_DataLoadFailed','WP_InventoryLoadFailed','WP_FurnitureLoadFailed','WP_GardenLoadFailed','WP_DexLoadFailed']) {
  if (!healthSrc.includes(marker)) errors.push(`Health UI missing data-safety status: ${marker}`);
}
if (!healthSrc.includes('CarrotSeed') || !healthSrc.includes('WP_EconTxnSeq')) errors.push('Health UI missing economy integrity status.');

if (!plotsSrc.includes('WP_PlotCenterY') || !plotsSrc.includes('WONDERPOCKET_PlotHomes')) errors.push('Personal plot/cottage runtime markers missing.');

const registry = JSON.parse(fs.readFileSync(path.join(root,'maps/registry.json'),'utf8'));
const wp = registry.maps?.wonderpocket;
if (!wp) errors.push('wonderpocket missing from registry.');
else {
  if (String(wp.universeId) !== '8805231520') errors.push('Unexpected WONDERPOCKET universeId.');
  if (String(wp.placeId) !== '124843214013484') errors.push('Unexpected WONDERPOCKET placeId.');
  if (wp.file !== 'maps/wonderpocket/place.rbxlx') errors.push('Unexpected WONDERPOCKET place file.');
  if (wp.enabled !== false) errors.push('WONDERPOCKET registry must remain disabled before public release approval.');
}

const publisherPath = path.join(root,'scripts/publish-wonderpocket-closed-test.js');
const workflowPath = path.join(root,'.github/workflows/wonderpocket-prepublish.yml');
if (!fs.existsSync(publisherPath)) errors.push('Dedicated closed-test publisher missing.');
if (!fs.existsSync(workflowPath)) errors.push('WONDERPOCKET closed-test workflow missing.');
if (fs.existsSync(publisherPath)) {
  const publisher = fs.readFileSync(publisherPath,'utf8');
  for (const marker of [
    "universeId: '8805231520'","placeId: '124843214013484'",
    "branch: 'agent/wonderpocket-target'",
    "confirmation: 'WONDERPOCKET:8805231520:124843214013484'",
    "target.enabled !== false","PublishAllowed = false"
  ]) if (!publisher.includes(marker)) errors.push(`Closed-test publisher missing lock: ${marker}`);
  if (publisher.includes('publish-map.js')) errors.push('Dedicated publisher must not delegate to global publisher.');
  if (publisher.includes('8116636513') || publisher.includes('131894120482837')) errors.push('Foreign target ID detected in WONDERPOCKET publisher.');
}
if (fs.existsSync(workflowPath)) {
  const workflow = fs.readFileSync(workflowPath,'utf8');
  for (const marker of ['publish_closed_test:','confirm_target:','WONDERPOCKET:8805231520:124843214013484','agent/wonderpocket-target','scripts/publish-wonderpocket-closed-test.js']) {
    if (!workflow.includes(marker)) errors.push(`Closed-test workflow missing guard: ${marker}`);
  }
  if (workflow.includes('r.maps.wonderpocket.enabled=true')) errors.push('Closed-test workflow must not enable registry.');
  if (workflow.includes('node scripts/publish-map.js wonderpocket')) errors.push('Closed-test workflow must use dedicated publisher.');
}

const place = path.join(dir,'place.rbxlx');
if (!fs.existsSync(place)) errors.push('place.rbxlx not built. Run node scripts/build-wonderpocket.js first.');
else {
  const xml = fs.readFileSync(place,'utf8');
  if (!xml.includes('</roblox>')) errors.push('place.rbxlx invalid: missing </roblox>.');
  if (xml.includes('BBYA') || xml.includes('a-club')) errors.push('place.rbxlx contains foreign-map token.');
  if (!xml.includes('WONDERPOCKET_Remotes')) errors.push('Canonical remotes string missing from assembled place.');
  for (const marker of ['wonderpocket.tutorial','wonderpocket.adventure-gate','wonderpocket.wondi-meet','wonderpocket.furniture-inventory','wonderpocket.gardening','wonderpocket.wonderdex','wonderpocket.economy-audit','wonderpocket.data-safety']) {
    if (!xml.includes(marker)) errors.push(`Assembled place missing runtime marker: ${marker}`);
  }
}

console.log('[WONDERPOCKET QC v1.3]');
for (const w of warnings) console.log('WARN:', w);
if (errors.length) {
  for (const e of errors) console.error('ERROR:', e);
  process.exit(1);
}
console.log(`PASS: ${luaFiles.length} Lua files checked; ${warnings.length} warning(s).`);
