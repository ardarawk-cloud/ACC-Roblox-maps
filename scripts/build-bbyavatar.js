const fs = require('fs');
const path = require('path');

function cdata(text) {
  return String(text).replace(/]]>/g, ']]]]><![CDATA[>');
}

const root = process.cwd();
const serverSource = fs.readFileSync(path.join(root, 'maps/bbyavatar/runtime.server.lua'), 'utf8');
const clientSource = fs.readFileSync(path.join(root, 'maps/bbyavatar/runtime.client.lua'), 'utf8');

const xml = `<?xml version="1.0" encoding="utf-8"?>
<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
<External>null</External><External>nil</External>
<Item class="Workspace" referent="RBXBBYAWORKSPACE"><Properties><string name="Name">Workspace</string></Properties></Item>
<Item class="Lighting" referent="RBXBBYALIGHTING"><Properties><float name="Brightness">2.5</float><double name="ClockTime">18.2</double><bool name="GlobalShadows">true</bool><string name="Name">Lighting</string></Properties></Item>
<Item class="ServerScriptService" referent="RBXBBYASSS"><Properties><string name="Name">ServerScriptService</string></Properties><Item class="Script" referent="RBXBBYASERVER"><Properties><bool name="Disabled">false</bool><string name="Name">BBYAVATAR_Runtime</string><ProtectedString name="Source"><![CDATA[${cdata(serverSource)}]]></ProtectedString></Properties></Item></Item>
<Item class="StarterPlayer" referent="RBXBBYASTARTER"><Properties><string name="Name">StarterPlayer</string></Properties><Item class="StarterPlayerScripts" referent="RBXBBYASPS"><Properties><string name="Name">StarterPlayerScripts</string></Properties><Item class="LocalScript" referent="RBXBBYACLIENT"><Properties><bool name="Disabled">false</bool><string name="Name">BBYAVATAR_Client</string><ProtectedString name="Source"><![CDATA[${cdata(clientSource)}]]></ProtectedString></Properties></Item></Item></Item>
</roblox>\n`;

fs.writeFileSync(path.join(root, 'maps/bbyavatar/place.rbxlx'), xml);
console.log('Built maps/bbyavatar/place.rbxlx');
