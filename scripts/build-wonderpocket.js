const fs = require('fs');
const path = require('path');

const root = process.cwd();
const mapDir = path.join(root, 'maps/wonderpocket');
const out = path.join(mapDir, 'place.rbxlx');
const buildMode = String(process.env.WONDERPOCKET_BUILD_MODE || 'release').toLowerCase();
const closedTest = buildMode === 'closed-test';

const serverScripts = fs.readdirSync(mapDir)
  .filter(f => f.startsWith('wonderpocket.') && f.endsWith('.server.lua'))
  .sort();
const clientScripts = fs.readdirSync(mapDir)
  .filter(f => f.startsWith('wonderpocket.') && f.endsWith('.client.lua'))
  .filter(f => closedTest || f !== 'wonderpocket.health.client.lua')
  .sort();

function readLua(file) {
  return fs.readFileSync(path.join(mapDir, file), 'utf8')
    .replaceAll('WonderPocket_Remotes', 'WONDERPOCKET_Remotes')
    .replaceAll(']]>', ']]]]><![CDATA[>');
}

function esc(s) {
  return s.replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('"','&quot;');
}

function ref(n) {
  return `RBX${Number(n).toString(16).toUpperCase().padStart(32, '0')}`;
}

const config = readLua('GameConfig.lua');
const serverItems = serverScripts.map((f, i) => `
    <Item class="Script" referent="${ref(0x1000 + i)}">
      <Properties><bool name="Disabled">false</bool><string name="Name">${esc(f.replace('.server.lua',''))}</string><ProtectedString name="Source"><![CDATA[${readLua(f)}]]></ProtectedString></Properties>
    </Item>`).join('');
const clientItems = clientScripts.map((f, i) => `
      <Item class="LocalScript" referent="${ref(0x2000 + i)}">
        <Properties><bool name="Disabled">false</bool><string name="Name">${esc(f.replace('.client.lua',''))}</string><ProtectedString name="Source"><![CDATA[${readLua(f)}]]></ProtectedString></Properties>
      </Item>`).join('');

// Keep the serialized DataModel intentionally minimal and match the structure of a known-valid
// Roblox rbxlx in this repository. Runtime scripts create ReplicatedStorage children themselves.
const xml = `<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
  <External>null</External><External>nil</External>
  <Item class="Workspace" referent="${ref(1)}"><Properties><string name="Name">Workspace</string></Properties></Item>
  <Item class="ServerScriptService" referent="${ref(2)}">
    <Properties><string name="Name">ServerScriptService</string></Properties>
    <Item class="ModuleScript" referent="${ref(3)}"><Properties><string name="Name">GameConfig</string><ProtectedString name="Source"><![CDATA[${config}]]></ProtectedString></Properties></Item>${serverItems}
  </Item>
  <Item class="StarterPlayer" referent="${ref(4)}">
    <Properties><string name="Name">StarterPlayer</string></Properties>
    <Item class="StarterPlayerScripts" referent="${ref(5)}">
      <Properties><string name="Name">StarterPlayerScripts</string></Properties>${clientItems}
    </Item>
  </Item>
  <Item class="Lighting" referent="${ref(6)}"><Properties><string name="Name">Lighting</string></Properties></Item>
</roblox>`;

fs.writeFileSync(out, xml);
console.log(`[WONDERPOCKET] Built ${out}`);
console.log(`[WONDERPOCKET] Build mode: ${closedTest ? 'closed-test (health panel included)' : 'release-safe (health panel excluded)'}`);
console.log('[WONDERPOCKET] Minimal Roblox DataModel serialization enabled; ModuleScript uses valid properties only.');
console.log(`[WONDERPOCKET] Server scripts: ${serverScripts.length}; client scripts: ${clientScripts.length}`);
