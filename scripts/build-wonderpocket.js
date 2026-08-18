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

const config = readLua('GameConfig.lua');
const serverItems = serverScripts.map((f, i) => `
    <Item class="Script" referent="WP_SERVER_${String(i+1).padStart(3,'0')}">
      <Properties><bool name="Disabled">false</bool><string name="Name">${esc(f.replace('.server.lua',''))}</string><ProtectedString name="Source"><![CDATA[${readLua(f)}]]></ProtectedString></Properties>
    </Item>`).join('');
const clientItems = clientScripts.map((f, i) => `
      <Item class="LocalScript" referent="WP_CLIENT_${String(i+1).padStart(3,'0')}">
        <Properties><bool name="Disabled">false</bool><string name="Name">${esc(f.replace('.client.lua',''))}</string><ProtectedString name="Source"><![CDATA[${readLua(f)}]]></ProtectedString></Properties>
      </Item>`).join('');

const xml = `<?xml version="1.0" encoding="utf-8"?>
<roblox version="4">
  <External>null</External><External>nil</External>
  <Item class="Workspace" referent="WP_WORKSPACE"><Properties><string name="Name">Workspace</string></Properties></Item>
  <Item class="ReplicatedStorage" referent="WP_REPLICATED"><Properties><string name="Name">ReplicatedStorage</string></Properties></Item>
  <Item class="ServerScriptService" referent="WP_SERVER_SERVICE">
    <Properties><string name="Name">ServerScriptService</string></Properties>
    <Item class="ModuleScript" referent="WP_CONFIG"><Properties><string name="Name">GameConfig</string><ProtectedString name="Source"><![CDATA[${config}]]></ProtectedString></Properties></Item>${serverItems}
  </Item>
  <Item class="StarterPlayer" referent="WP_STARTER_PLAYER">
    <Properties><string name="Name">StarterPlayer</string></Properties>
    <Item class="StarterPlayerScripts" referent="WP_STARTER_PLAYER_SCRIPTS">
      <Properties><string name="Name">StarterPlayerScripts</string></Properties>${clientItems}
    </Item>
  </Item>
  <Item class="Lighting" referent="WP_LIGHTING"><Properties><string name="Name">Lighting</string></Properties></Item>
</roblox>`;

fs.writeFileSync(out, xml);
console.log(`[WONDERPOCKET] Built ${out}`);
console.log(`[WONDERPOCKET] Server scripts: ${serverScripts.length}; client scripts: ${clientScripts.length}`);
