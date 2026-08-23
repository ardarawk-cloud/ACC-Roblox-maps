const fs = require('fs');
const path = require('path');

const root = process.cwd();
const mapDir = path.join(root, 'maps', 'bbyavatar');

function read(name) {
  return fs.readFileSync(path.join(mapDir, name), 'utf8');
}
function cdata(source) {
  return source.replace(/\]\]>/g, ']]]]><![CDATA[>');
}

const config = read('fps.config.lua');
const world = read('fps.world.server.lua');
const gameServer = read('fps.game.server.lua');
const client = read('fps.client.lua');

const xml = `<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
<External>null</External><External>nil</External>
<Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties></Item>
<Item class="Lighting" referent="L"><Properties><string name="Name">Lighting</string><float name="Brightness">2</float><double name="ClockTime">16.4</double></Properties></Item>
<Item class="Teams" referent="T"><Properties><string name="Name">Teams</string></Properties></Item>
<Item class="ReplicatedStorage" referent="RS"><Properties><string name="Name">ReplicatedStorage</string></Properties>
  <Item class="ModuleScript" referent="CFG"><Properties><string name="Name">FPSConfig</string><ProtectedString name="Source"><![CDATA[${cdata(config)}]]></ProtectedString></Properties></Item>
</Item>
<Item class="ServerScriptService" referent="SSS"><Properties><string name="Name">ServerScriptService</string></Properties>
  <Item class="Script" referent="WORLD"><Properties><string name="Name">FPS_World</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(world)}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="GAME"><Properties><string name="Name">FPS_GameServer</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(gameServer)}]]></ProtectedString></Properties></Item>
</Item>
<Item class="StarterPlayer" referent="SP"><Properties><string name="Name">StarterPlayer</string></Properties>
  <Item class="StarterPlayerScripts" referent="SPS"><Properties><string name="Name">StarterPlayerScripts</string></Properties>
    <Item class="LocalScript" referent="CLIENT"><Properties><string name="Name">FPS_Client</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(client)}]]></ProtectedString></Properties></Item>
  </Item>
</Item>
</roblox>`;

const out = path.join(mapDir, 'place.rbxlx');
fs.writeFileSync(out, xml);
console.log(`[BBYAVATAR FPS] Built ${path.relative(root,out)} (${Buffer.byteLength(xml)} bytes)`);
