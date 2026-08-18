const fs = require('fs');
const path = require('path');

const mapId = process.argv[2];
if (mapId !== 'a-club') process.exit(0);

const registry = JSON.parse(fs.readFileSync(path.join(process.cwd(), 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map id: ${mapId}`);

const placePath = path.join(process.cwd(), target.file);
const readLua = (file) => fs.readFileSync(path.join(process.cwd(), file), 'utf8').replaceAll(']]>', ']]]]><![CDATA[>');
const mainLua = readLua('maps/a-club/bbya.server.lua');
const systemsLua = readLua('maps/a-club/bbya.systems.server.lua');
const djLua = readLua('maps/a-club/bbya.dj.server.lua');
const featuresLua = readLua('maps/a-club/bbya.features.server.lua');
const clientLua = readLua('maps/a-club/bbya.client.lua');

let xml = fs.readFileSync(placePath, 'utf8');
const begin = '<!-- BBYA_RUNTIME_BEGIN -->';
const end = '<!-- BBYA_RUNTIME_END -->';
const prior = new RegExp(`${begin}[\\s\\S]*?${end}`, 'g');
xml = xml.replace(prior, '');

const runtime = `${begin}
<Item class="ServerScriptService" referent="RBXBBYASERVERSCRIPTSERVICE00000001">
  <Properties><string name="Name">ServerScriptService</string></Properties>
  <Item class="Script" referent="RBXBBYARUNTIME00000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Runtime_Main</string><ProtectedString name="Source"><![CDATA[${mainLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYASYSTEMS00000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Functional_Systems</string><ProtectedString name="Source"><![CDATA[${systemsLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYADJ00000000000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Resident_DJ</string><ProtectedString name="Source"><![CDATA[${djLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAFEATURES0000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Feature_Stations</string><ProtectedString name="Source"><![CDATA[${featuresLua}]]></ProtectedString></Properties></Item>
</Item>
<Item class="StarterPlayer" referent="RBXBBYASTARTERPLAYER00000000000001">
  <Properties><string name="Name">StarterPlayer</string></Properties>
  <Item class="StarterPlayerScripts" referent="RBXBBYASTARTERPLAYERSCRIPTS00000001">
    <Properties><string name="Name">StarterPlayerScripts</string></Properties>
    <Item class="LocalScript" referent="RBXBBYACLIENT000000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Client</string><ProtectedString name="Source"><![CDATA[${clientLua}]]></ProtectedString></Properties></Item>
  </Item>
</Item>
${end}`;

if (!xml.includes('</roblox>')) throw new Error('Invalid RBXLX: missing </roblox>');
xml = xml.replace('</roblox>', `${runtime}</roblox>`);
fs.writeFileSync(placePath, xml);
console.log('[BBYA] Main + systems + DJ + feature stations + client UI injected into', target.file);
