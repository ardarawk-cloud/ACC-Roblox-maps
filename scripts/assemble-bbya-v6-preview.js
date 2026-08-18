const fs = require('fs');
const path = require('path');

const root = process.cwd();
const mapId = process.argv[2] || 'a-club';
const outArg = process.argv[3] || '/tmp/bbya-v6-preview.rbxlx';
if (mapId !== 'a-club') throw new Error('V6 preview assembler is BBYA/a-club only');

const registry = JSON.parse(fs.readFileSync(path.join(root, 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map: ${mapId}`);

const architectureFiles = [
  'maps/a-club/v6/00-core.lua',
  'maps/a-club/v6/10-layout.lua',
  'maps/a-club/v6/20-ground-shell.lua',
  'maps/a-club/v6/21-circulation.lua',
  'maps/a-club/v6/22-facade-brand.lua',
  'maps/a-club/v6/30-vip-level.lua',
  'maps/a-club/v6/40-rooftop.lua',
  'maps/a-club/v6/45-service.lua',
];
const systemFiles = ['maps/a-club/v6/50-systems.server.lua'];
const uiFiles = ['maps/a-club/v6/60-ui.client.lua'];

const allFiles = [...architectureFiles, ...systemFiles, ...uiFiles];
for (const file of allFiles) {
  if (!fs.existsSync(path.join(root, file))) throw new Error(`Missing V6 source: ${file}`);
}
if (allFiles.some(f => f.includes('/v5/'))) throw new Error('V5 file leaked into V6 preview assembly');

const readLua = file => fs.readFileSync(path.join(root, file), 'utf8').replaceAll(']]>', ']]]]><![CDATA[>');
const concat = files => files.map(file => `\n-- SOURCE FILE: ${file}\n${readLua(file)}`).join('\n');
const architectureLua = concat(architectureFiles);
const systemsLua = concat(systemFiles);
const uiLua = concat(uiFiles);

const placePath = path.join(root, target.file);
let xml = fs.readFileSync(placePath, 'utf8');
if (!xml.includes('</roblox>')) throw new Error('Invalid source RBXLX: missing </roblox>');

// Strip only ACC-injected runtime blocks. Static legacy Workspace geometry is intentionally left in the file;
// V6 00-core deletes it at runtime before building the clean-room venue.
const runtimeBlock = /<!-- BBYA_RUNTIME_BEGIN -->[\s\S]*?<!-- BBYA_RUNTIME_END -->/g;
xml = xml.replace(runtimeBlock, '');

const begin = '<!-- BBYA_V6_PREVIEW_RUNTIME_BEGIN -->';
const end = '<!-- BBYA_V6_PREVIEW_RUNTIME_END -->';
const runtime = `${begin}
<Item class="ServerScriptService" referent="RBXBBYAV6PREVIEWSSS">
  <Properties><string name="Name">ServerScriptService</string></Properties>
  <Item class="Script" referent="RBXBBYAV6ARCH">
    <Properties>
      <bool name="Disabled">false</bool>
      <string name="Name">BBYA_V6_CLEANROOM_ARCHITECTURE</string>
      <ProtectedString name="Source"><![CDATA[${architectureLua}]]></ProtectedString>
    </Properties>
  </Item>
  <Item class="Script" referent="RBXBBYAV6SYSTEMS">
    <Properties>
      <bool name="Disabled">false</bool>
      <string name="Name">BBYA_V6_CLEANROOM_SYSTEMS</string>
      <ProtectedString name="Source"><![CDATA[${systemsLua}]]></ProtectedString>
    </Properties>
  </Item>
</Item>
<Item class="StarterPlayer" referent="RBXBBYAV6STARTERPLAYER">
  <Properties><string name="Name">StarterPlayer</string></Properties>
  <Item class="StarterPlayerScripts" referent="RBXBBYAV6SPS">
    <Properties><string name="Name">StarterPlayerScripts</string></Properties>
    <Item class="LocalScript" referent="RBXBBYAV6UI">
      <Properties>
        <bool name="Disabled">false</bool>
        <string name="Name">BBYA_V6_UNIFIED_UI</string>
        <ProtectedString name="Source"><![CDATA[${uiLua}]]></ProtectedString>
      </Properties>
    </Item>
  </Item>
</Item>
${end}`;

xml = xml.replace('</roblox>', `${runtime}</roblox>`);
fs.mkdirSync(path.dirname(outArg), { recursive: true });
fs.writeFileSync(outArg, xml);
console.log(`[BBYA V6] Preview assembled -> ${outArg}`);
console.log(`[BBYA V6] ${architectureFiles.length} architecture files, ${systemFiles.length} systems file, ${uiFiles.length} UI file.`);
