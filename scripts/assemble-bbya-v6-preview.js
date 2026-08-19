const fs = require('fs');
const path = require('path');

const root = process.cwd();
const mapId = process.argv[2] || 'a-club';
const outArg = process.argv[3] || '/tmp/bbya-clean-rebuild-preview.rbxlx';
if (mapId !== 'a-club') throw new Error('BBYA clean rebuild assembler is a-club only');

const registry = JSON.parse(fs.readFileSync(path.join(root, 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map: ${mapId}`);

const serverFiles = [
  'maps/a-club/rebuild/00-core.lua',
  'maps/a-club/rebuild/10-architecture.lua',
  'maps/a-club/rebuild/15-premium-exterior.lua',
  'maps/a-club/rebuild/20-furnishing.lua',
  'maps/a-club/rebuild/25-premium-interior.lua',
  'maps/a-club/rebuild/35-circulation.lua',
  'maps/a-club/rebuild/30-lighting.lua',
  'maps/a-club/rebuild/40-runtime.server.lua',
  'maps/a-club/rebuild/45-owner-layout-fix.server.lua',
  'maps/a-club/rebuild/60-social-systems.server.lua',
  'maps/a-club/rebuild/65-live-services.server.lua',
  'maps/a-club/rebuild/66-support-receipt-hotfix.server.lua',
  'maps/a-club/rebuild/50-qc.server.lua',
  'maps/a-club/rebuild/80-release-gate.server.lua',
];
const clientFiles = [
  'maps/a-club/rebuild/70-ui.client.lua',
  'maps/a-club/rebuild/71-ui-consolidate.client.lua',
  'maps/a-club/rebuild/72-hybrid-ui.client.lua',
  'maps/a-club/rebuild/73-support-ui.client.lua',
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
if (!xml.includes('</roblox>')) throw new Error('Invalid carrier RBXLX: missing </roblox>');
if (!xml.includes('RBXBBYACARRIERWORKSPACE') || !xml.includes('RBXBBYACARRIERLIGHTING')) {
  throw new Error('BBYA carrier anchors missing');
}

const begin='<!-- BBYA_CLEAN_RUNTIME_BEGIN -->';
const end='<!-- BBYA_CLEAN_RUNTIME_END -->';
xml=xml.replace(new RegExp(`${begin}[\\s\\S]*?${end}`,'g'),'');

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

const starterPlayer = `<Item class="StarterPlayer" referent="RBXBBYACLEANSTARTERPLAYER">
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

const runtime = `${begin}\n${runtimeService}\n${starterPlayer}\n${end}`;
xml = xml.replace('</roblox>', `${runtime}</roblox>`);

fs.mkdirSync(path.dirname(outArg), { recursive: true });
fs.writeFileSync(outArg, xml);
console.log(`[BBYA CLEAN REBUILD] Preview assembled -> ${outArg}`);
console.log(`[BBYA CLEAN REBUILD] ${serverFiles.length} server modules + ${clientFiles.length} client UI modules; owner layout fixes + Hybrid Auto DJ + support purchase UI included.`);
console.log('[BBYA CLEAN REBUILD] Preview keeps commerce fail-closed; direct live deploy resolves existing Roblox commerce IDs.');
console.log('[BBYA CLEAN REBUILD] PREVIEW ASSEMBLY COMPLETE');
