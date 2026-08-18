const fs = require('fs');
const path = require('path');

const root = process.cwd();
const mapId = process.argv[2] || 'a-club';
const outArg = process.argv[3] || '/tmp/bbya-v6-preview.rbxlx';
if (mapId !== 'a-club') throw new Error('V6 preview assembler is BBYA/a-club only');

const registry = JSON.parse(fs.readFileSync(path.join(root, 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map: ${mapId}`);

// ORDER IS PART OF THE CONTRACT. Structure -> finish -> social function -> systems -> commerce -> prompts -> QC -> preview gate.
const architectureFiles = [
  'maps/a-club/v6/00-core.lua',
  'maps/a-club/v6/10-layout.lua',
  'maps/a-club/v6/20-ground-shell.lua',
  'maps/a-club/v6/21-circulation.lua',
  'maps/a-club/v6/22-facade-brand.lua',
  'maps/a-club/v6/23-lift-finish.lua',
  'maps/a-club/v6/25-ground-finish.lua',
  'maps/a-club/v6/30-vip-level.lua',
  'maps/a-club/v6/31-vip-gates.lua',
  'maps/a-club/v6/33-vip-finish.lua',
  'maps/a-club/v6/40-rooftop.lua',
  'maps/a-club/v6/43-rooftop-finish.lua',
  'maps/a-club/v6/42-social-seating.lua',
  'maps/a-club/v6/45-service.lua',
];
const systemFiles = [
  'maps/a-club/v6/50-systems.server.lua',
  'maps/a-club/v6/55-monetization.server.lua',
  'maps/a-club/v6/57-social-prompts.server.lua',
  'maps/a-club/v6/70-runtime-qc.server.lua',
  'maps/a-club/v6/71-preview-gate.server.lua',
];
const uiFiles = [
  'maps/a-club/v6/60-ui.client.lua',
  'maps/a-club/v6/61-zone-hud.client.lua',
  'maps/a-club/v6/62-dance-ui.client.lua',
  'maps/a-club/v6/63-commerce-ui.client.lua',
  'maps/a-club/v6/64-physical-ui-bridge.client.lua',
  'maps/a-club/v6/65-performance.client.lua',
  'maps/a-club/v6/66-ui-recovery.client.lua',
];

const allFiles = [...architectureFiles, ...systemFiles, ...uiFiles];
for (const file of allFiles) {
  if (!fs.existsSync(path.join(root, file))) throw new Error(`Missing V6 source: ${file}`);
}
if (allFiles.some(f => f.includes('/v5/'))) throw new Error('V5 file leaked into V6 preview assembly');

const readLua = file => fs.readFileSync(path.join(root, file), 'utf8').replaceAll(']]>', ']]]]><![CDATA[>');
const concat = files => files.map(file => `\n-- SOURCE FILE: ${file}\n${readLua(file)}`).join('\n');
const serverLua = concat([...architectureFiles, ...systemFiles]);
const uiLua = concat(uiFiles);

const placePath = path.join(root, target.file);
let xml = fs.readFileSync(placePath, 'utf8');
if (!xml.includes('</roblox>')) throw new Error('Invalid source RBXLX: missing </roblox>');

xml = xml.replace(/<!-- BBYA_RUNTIME_BEGIN -->[\s\S]*?<!-- BBYA_RUNTIME_END -->/g, '');
xml = xml.replace(/<!-- BBYA_V6_PREVIEW_RUNTIME_BEGIN -->[\s\S]*?<!-- BBYA_V6_PREVIEW_RUNTIME_END -->/g, '');

const begin = '<!-- BBYA_V6_PREVIEW_RUNTIME_BEGIN -->';
const end = '<!-- BBYA_V6_PREVIEW_RUNTIME_END -->';
const runtime = `${begin}
<Item class="ServerScriptService" referent="RBXBBYAV6PREVIEWSSS">
  <Properties><string name="Name">ServerScriptService</string></Properties>
  <Item class="Script" referent="RBXBBYAV6RUNTIME">
    <Properties>
      <bool name="Disabled">false</bool>
      <string name="Name">BBYA_V6_CLEANROOM_RUNTIME</string>
      <ProtectedString name="Source"><![CDATA[${serverLua}]]></ProtectedString>
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
console.log(`[BBYA V6] deterministic runtime: ${architectureFiles.length} architecture + ${systemFiles.length} systems; ${uiFiles.length} UI modules.`);
console.log('[BBYA V6] PREVIEW ONLY — NO ROBLOX PUBLISH PERFORMED');
