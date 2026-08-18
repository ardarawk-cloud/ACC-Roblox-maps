const fs = require('fs');
const path = require('path');

const root = process.cwd();
const mapId = process.argv[2] || 'a-club';
const outArg = process.argv[3] || '/tmp/bbya-clean-rebuild-preview.rbxlx';
if (mapId !== 'a-club') throw new Error('BBYA clean rebuild assembler is a-club only');

const registry = JSON.parse(fs.readFileSync(path.join(root, 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map: ${mapId}`);

// Server order is authoritative: physical build -> circulation -> lighting -> safety runtime -> support/music backend -> QC.
const serverFiles = [
  'maps/a-club/rebuild/00-core.lua',
  'maps/a-club/rebuild/10-architecture.lua',
  'maps/a-club/rebuild/15-premium-exterior.lua',
  'maps/a-club/rebuild/20-furnishing.lua',
  'maps/a-club/rebuild/25-premium-interior.lua',
  'maps/a-club/rebuild/35-circulation.lua',
  'maps/a-club/rebuild/30-lighting.lua',
  'maps/a-club/rebuild/40-runtime.server.lua',
  'maps/a-club/rebuild/60-social-systems.server.lua',
  'maps/a-club/rebuild/50-qc.server.lua',
];
const clientFiles = [
  'maps/a-club/rebuild/70-ui.client.lua',
];
const allFiles=[...serverFiles,...clientFiles];
for (const file of allFiles) {
  if (!fs.existsSync(path.join(root,file))) throw new Error(`Missing clean rebuild source: ${file}`);
}
if (allFiles.some(file => /\/v[0-9]+\//.test(file))) throw new Error('Archived V5/V6 module leaked into clean rebuild assembly');

const readLua=file=>fs.readFileSync(path.join(root,file),'utf8').replaceAll(']]>',']]]]><![CDATA[>');
const concat=files=>files.map(file => `\n-- SOURCE FILE: ${file}\n${readLua(file)}`).join('\n');
const serverSource=concat(serverFiles);
const clientSource=concat(clientFiles);

const placePath = path.join(root, target.file);
let xml = fs.readFileSync(placePath, 'utf8');
if (!xml.includes('</roblox>')) throw new Error('Invalid blank RBXLX: missing </roblox>');

const runtimeService = `<Item class="ServerScriptService" referent="RBXBBYACLEANSSS">
  <Properties><string name="Name">ServerScriptService</string></Properties>
  <Item class="Script" referent="RBXBBYACLEANRUNTIME">
    <Properties>
      <bool name="Disabled">false</bool>
      <string name="Name">BBYA_CLEAN_REBUILD_RUNTIME</string>
      <ProtectedString name="Source"><![CDATA[${serverSource}]]></ProtectedString>
    </Properties>
  </Item>
</Item>`;

const starterPlayer = `<Item class="StarterPlayer" referent="RBXBBYABLANKSTARTERPLAYER">
  <Properties><string name="Name">StarterPlayer</string></Properties>
  <Item class="StarterPlayerScripts" referent="RBXBBYACLEANSTARTERSCRIPTS">
    <Properties><string name="Name">StarterPlayerScripts</string></Properties>
    <Item class="LocalScript" referent="RBXBBYACLEANCLIENT">
      <Properties>
        <bool name="Disabled">false</bool>
        <string name="Name">BBYA_CLEAN_SOCIAL_UI</string>
        <ProtectedString name="Source"><![CDATA[${clientSource}]]></ProtectedString>
      </Properties>
    </Item>
  </Item>
</Item>`;

const blankService = /<Item class="ServerScriptService" referent="RBXBBYABLANKSSS">[\s\S]*?<\/Item>/;
if (!blankService.test(xml)) throw new Error('Blank ServerScriptService anchor not found');
xml = xml.replace(blankService, runtimeService);

const blankStarter = /<Item class="StarterPlayer" referent="RBXBBYABLANKSTARTERPLAYER">[\s\S]*?<\/Item>/;
if (!blankStarter.test(xml)) throw new Error('Blank StarterPlayer anchor not found');
xml = xml.replace(blankStarter, starterPlayer);

fs.mkdirSync(path.dirname(outArg), { recursive: true });
fs.writeFileSync(outArg, xml);
console.log(`[BBYA CLEAN REBUILD] Preview assembled -> ${outArg}`);
console.log(`[BBYA CLEAN REBUILD] ${serverFiles.length} server modules + ${clientFiles.length} client UI module; phase 5 exact Support tiers, mini-player, dual-deck Auto DJ shell and QC included.`);
console.log('[BBYA CLEAN REBUILD] Support product IDs and authorized music library intentionally remain pending/disabled until official values are supplied.');
console.log('[BBYA CLEAN REBUILD] PREVIEW ONLY — NO ROBLOX PUBLISH PERFORMED');
