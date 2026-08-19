const fs = require('fs');
const path = require('path');

const root = process.cwd();
const mapId = process.argv[2] || 'a-club';
const outArg = process.argv[3] || '/tmp/bbya-v7-clean-preview.rbxlx';
if (mapId !== 'a-club') throw new Error('BBYA V7 clean assembler is a-club only');

const registry = JSON.parse(fs.readFileSync(path.join(root, 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map: ${mapId}`);

// V7 is intentionally deterministic. Do not re-add legacy owner-fix, live-service,
// receipt-hotfix, or duplicate UI layers here without an explicit V7 review.
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
  'maps/a-club/rebuild/80-release-gate.server.lua',
];
const clientFiles = [
  'maps/a-club/rebuild/70-ui.client.lua',
];
const allFiles=[...serverFiles,...clientFiles];
for (const file of allFiles) {
  if (!fs.existsSync(path.join(root,file))) throw new Error(`Missing V7 clean source: ${file}`);
}
if (allFiles.some(file => /\/v[0-9]+\//.test(file))) throw new Error('Archived versioned module leaked into V7 clean assembly');

const forbidden=[
  '45-owner-layout-fix.server.lua','46-owner-seat-cleanup.server.lua','47-street-frontage.server.lua',
  '65-live-services.server.lua','66-support-receipt-hotfix.server.lua',
  '71-ui-consolidate.client.lua','72-hybrid-ui.client.lua','73-support-ui.client.lua'
];
for (const token of forbidden) {
  if (allFiles.some(file=>file.includes(token))) throw new Error(`Forbidden legacy layer leaked into V7: ${token}`);
}

const readLua=file=>fs.readFileSync(path.join(root,file),'utf8').replaceAll(']]>',']]]]><![CDATA[>');
const concat=files=>files.map(file => `\n-- SOURCE FILE: ${file}\n${readLua(file)}`).join('\n');
const serverSource=concat(serverFiles);
const clientSource=concat(clientFiles);

const placePath = path.join(root, target.file);
let xml = fs.readFileSync(placePath, 'utf8');
if (!xml.includes('</roblox>')) throw new Error('Invalid carrier RBXLX: missing </roblox>');
if (!xml.includes('RBXBBYACARRIERWORKSPACE') || !xml.includes('RBXBBYACARRIERLIGHTING')) throw new Error('BBYA carrier anchors missing');

const begin='<!-- BBYA_CLEAN_RUNTIME_BEGIN -->';
const end='<!-- BBYA_CLEAN_RUNTIME_END -->';
xml=xml.replace(new RegExp(`${begin}[\\s\\S]*?${end}`,'g'),'');

const runtimeService = `<Item class="ServerScriptService" referent="RBXBBYACLEANSSS">
  <Properties><string name="Name">ServerScriptService</string></Properties>
  <Item class="Script" referent="RBXBBYACLEANRUNTIME">
    <Properties><bool name="Disabled">false</bool><string name="Name">BBYA_CLEAN_REBUILD_RUNTIME</string><ProtectedString name="Source"><![CDATA[${serverSource}]]></ProtectedString></Properties>
  </Item>
</Item>`;
const starterPlayer = `<Item class="StarterPlayer" referent="RBXBBYACLEANSTARTERPLAYER">
  <Properties><string name="Name">StarterPlayer</string></Properties>
  <Item class="StarterPlayerScripts" referent="RBXBBYACLEANSTARTERSCRIPTS">
    <Properties><string name="Name">StarterPlayerScripts</string></Properties>
    <Item class="LocalScript" referent="RBXBBYACLEANCLIENT">
      <Properties><bool name="Disabled">false</bool><string name="Name">BBYA_CLEAN_SOCIAL_UI</string><ProtectedString name="Source"><![CDATA[${clientSource}]]></ProtectedString></Properties>
    </Item>
  </Item>
</Item>`;

xml = xml.replace('</roblox>', `${begin}\n${runtimeService}\n${starterPlayer}\n${end}</roblox>`);
fs.mkdirSync(path.dirname(outArg), { recursive: true });
fs.writeFileSync(outArg, xml);
console.log(`[BBYA V7 CLEAN] Preview assembled -> ${outArg}`);
console.log(`[BBYA V7 CLEAN] ${serverFiles.length} server modules + ${clientFiles.length} client module; legacy duplicate layers excluded.`);
console.log('[BBYA V7 CLEAN] PREVIEW ASSEMBLY COMPLETE');
