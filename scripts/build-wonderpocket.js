const fs = require('fs');
const path = require('path');

const root = process.cwd();
const mapDir = path.join(root, 'maps/wonderpocket');
const out = path.join(mapDir, 'place.rbxlx');

const serverScripts = fs.readdirSync(mapDir)
  .filter(f => f.startsWith('wonderpocket.') && f.endsWith('.server.lua'))
  .sort();
const clientScripts = fs.readdirSync(mapDir)
  .filter(f => f.startsWith('wonderpocket.') && f.endsWith('.client.lua'))
  .sort();

function readLua(file) {
  return fs.readFileSync(path.join(mapDir, file), 'utf8')
    .replaceAll('WonderPocket_Remotes', 'WONDERPOCKET_Remotes')
    .replaceAll(']]>', ']]]]><![CDATA[>');
}

function esc(s) {
  return s.replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('"','&quot;');
}

// Roblox rbxlx referents use RBX-prefixed 32-hex identifiers.
function ref(n) {
  return `RBX${Number(n).toString(16).toUpperCase().padStart(32, '0')}`;
}

const refs = {
  workspace: ref(1),
  replicated: ref(2),
  serverService: ref(3),
  config: ref(4),
  starterPlayer: ref(5),
  starterScripts: ref(6),
  lighting: ref(7),
};

const config = readLua('GameConfig.lua');
const serverItems = serverScripts.map((f, i) => `
    <Item class="Script" referent="${ref(0x1000 + i)}">
      <Properties><bool name="Disabled">false</bool><string name="Name">${esc(f.replace('.server.lua',''))}</string><ProtectedString name="Source"><![CDATA[${readLua(f)}]]></ProtectedString></Properties>
    </Item>`).join('');
const clientItems = clientScripts.map((f, i) => `
      <Item class="LocalScript" referent="${ref(0x2000 + i)}">
        <Properties><bool name="Disabled">false</bool><string name="Name">${esc(f.replace('.client.lua',''))}</string><ProtectedString name="Source"><![CDATA[${readLua(f)}]]></ProtectedString></Properties>
      </Item>`).join('');

const xml = `<?xml version="1.0" encoding="utf-8"?>
<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
  <External>null</External><External>nil</External>
  <Item class="Workspace" referent="${refs.workspace}"><Properties><string name="Name">Workspace</string></Properties></Item>
  <Item class="ReplicatedStorage" referent="${refs.replicated}"><Properties><string name="Name">ReplicatedStorage</string></Properties></Item>
  <Item class="ServerScriptService" referent="${refs.serverService}">
    <Properties><string name="Name">ServerScriptService</string></Properties>
    <Item class="ModuleScript" referent="${refs.config}"><Properties><bool name="Disabled">false</bool><string name="Name">GameConfig</string><ProtectedString name="Source"><![CDATA[${config}]]></ProtectedString></Properties></Item>${serverItems}
  </Item>
  <Item class="StarterPlayer" referent="${refs.starterPlayer}">
    <Properties><string name="Name">StarterPlayer</string></Properties>
    <Item class="StarterPlayerScripts" referent="${refs.starterScripts}">
      <Properties><string name="Name">StarterPlayerScripts</string></Properties>${clientItems}
    </Item>
  </Item>
  <Item class="Lighting" referent="${refs.lighting}"><Properties><string name="Name">Lighting</string></Properties></Item>
</roblox>`;

fs.writeFileSync(out, xml);
console.log(`[WONDERPOCKET] Built ${out}`);
console.log(`[WONDERPOCKET] Roblox XSD namespace + RBX referents enabled.`);
console.log(`[WONDERPOCKET] Server scripts: ${serverScripts.length}; client scripts: ${clientScripts.length}`);
