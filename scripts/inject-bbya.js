const fs = require('fs');
const path = require('path');

const mapId = process.argv[2];
if (mapId !== 'a-club') process.exit(0);

const root = process.cwd();
const registry = JSON.parse(fs.readFileSync(path.join(root, 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map id: ${mapId}`);

const placePath = path.join(root, target.file);
const readLua = (file) => fs.readFileSync(path.join(root, file), 'utf8').replaceAll(']]>', ']]]]><![CDATA[>');
const layoutLua = readLua('maps/a-club/bbya.v5-layout.server.lua');

let xml = fs.readFileSync(placePath, 'utf8');
const begin = '<!-- BBYA_RUNTIME_BEGIN -->';
const end = '<!-- BBYA_RUNTIME_END -->';
xml = xml.replace(new RegExp(`${begin}[\\s\\S]*?${end}`, 'g'), '');

const runtime = `${begin}
<Item class="ServerScriptService" referent="RBXBBYAV5SSS">
  <Properties><string name="Name">ServerScriptService</string></Properties>
  <Item class="Script" referent="RBXBBYAV5LAYOUT">
    <Properties>
      <bool name="Disabled">false</bool>
      <string name="Name">BBYA_V5_ARCHITECTURAL_GREYBOX</string>
      <ProtectedString name="Source"><![CDATA[${layoutLua}]]></ProtectedString>
    </Properties>
  </Item>
</Item>
${end}`;

if (!xml.includes('</roblox>')) throw new Error('Invalid RBXLX: missing </roblox>');
xml = xml.replace('</roblox>', `${runtime}</roblox>`);
fs.writeFileSync(placePath, xml);
console.log('[BBYA] V5 greybox-only runtime injected. All v4 visual/UI/runtime layers are excluded for architecture playtest.');
