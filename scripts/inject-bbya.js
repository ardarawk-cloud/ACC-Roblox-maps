const fs = require('fs');
const path = require('path');

const mapId = process.argv[2];
if (mapId !== 'a-club') process.exit(0);

const root = process.cwd();
const registry = JSON.parse(fs.readFileSync(path.join(root, 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map id: ${mapId}`);

const placePath = path.join(root, target.file);
const readLua = file => fs.readFileSync(path.join(root, file), 'utf8').replaceAll(']]>', ']]]]><![CDATA[>');

// Architecture source stays modular in GitHub but is concatenated into ONE Roblox Script.
// UI is ONE independent LocalScript shell so legacy panel stacks cannot overlap again.
const zoneFiles = [
  'maps/a-club/v5/00-core.lua',
  'maps/a-club/v5/A1-exterior-spawn.lua',
  'maps/a-club/v5/A2-entrance-facade.lua',
  'maps/a-club/v5/A3-lobby.lua',
  'maps/a-club/v5/S1-service.lua',
  'maps/a-club/v5/B3-lift.lua',
  'maps/a-club/v5/A4-main-club.lua',
  'maps/a-club/v5/A5-bar.lua',
  'maps/a-club/v5/A6-chill.lua',
  'maps/a-club/v5/B1-west-stair.lua',
  'maps/a-club/v5/B2-east-stair.lua',
  'maps/a-club/v5/C1-vip-west.lua',
  'maps/a-club/v5/C2-vip-east.lua',
  'maps/a-club/v5/C3-queen-bridges.lua',
  'maps/a-club/v5/D1-rooftop-arrival.lua',
  'maps/a-club/v5/D2-rooftop-water-zone.lua',
  'maps/a-club/v5/D3-skybar.lua',
  'maps/a-club/v5/D4-rooftop-chill.lua',
  'maps/a-club/v5/D5-cabana-zones.lua',
  'maps/a-club/v5/D6-photo-view.lua',
  'maps/a-club/v5/99-finalize.lua',
];

const combinedLua = zoneFiles.map(file => `\n-- SOURCE FILE: ${file}\n${readLua(file)}`).join('\n');
const uiLua = readLua('maps/a-club/v5/ui-shell.client.lua');

let xml = fs.readFileSync(placePath, 'utf8');
const begin = '<!-- BBYA_RUNTIME_BEGIN -->';
const end = '<!-- BBYA_RUNTIME_END -->';
xml = xml.replace(new RegExp(`${begin}[\\s\\S]*?${end}`, 'g'), '');

const runtime = `${begin}
<Item class="ServerScriptService" referent="RBXBBYAV52SSS">
  <Properties><string name="Name">ServerScriptService</string></Properties>
  <Item class="Script" referent="RBXBBYAV52MODULAR">
    <Properties>
      <bool name="Disabled">false</bool>
      <string name="Name">BBYA_V5_2_MODULAR_ARCHITECTURE</string>
      <ProtectedString name="Source"><![CDATA[${combinedLua}]]></ProtectedString>
    </Properties>
  </Item>
</Item>
<Item class="StarterPlayer" referent="RBXBBYAV52STARTERPLAYER">
  <Properties><string name="Name">StarterPlayer</string></Properties>
  <Item class="StarterPlayerScripts" referent="RBXBBYAV52STARTERPLAYERSCRIPTS">
    <Properties><string name="Name">StarterPlayerScripts</string></Properties>
    <Item class="LocalScript" referent="RBXBBYAV52UISHELL">
      <Properties>
        <bool name="Disabled">false</bool>
        <string name="Name">BBYA_V5_Mobile_Safe_UI_Shell</string>
        <ProtectedString name="Source"><![CDATA[${uiLua}]]></ProtectedString>
      </Properties>
    </Item>
  </Item>
</Item>
${end}`;

if (!xml.includes('</roblox>')) throw new Error('Invalid RBXLX: missing </roblox>');
xml = xml.replace('</roblox>', `${runtime}</roblox>`);
fs.writeFileSync(placePath, xml);
console.log(`[BBYA] V5.2 modular architecture + mobile-safe UI shell injected. Architecture=${zoneFiles.length} modules -> 1 Script; UI=1 LocalScript.`);
