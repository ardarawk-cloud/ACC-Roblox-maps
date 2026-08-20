const fs = require('fs');
const path = require('path');

function cdata(text) {
  return String(text).replace(/]]>/g, ']]]]><![CDATA[>');
}

const root = process.cwd();
const serverSource = fs.readFileSync(path.join(root, 'maps/becak-e-bike/runtime.server.lua'), 'utf8');
const clientSource = fs.readFileSync(path.join(root, 'maps/becak-e-bike/runtime.client.lua'), 'utf8');

const xml = `<?xml version="1.0" encoding="utf-8"?>
<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
<External>null</External><External>nil</External>
<Item class="Workspace" referent="RBXBECAKWORKSPACE"><Properties><string name="Name">Workspace</string></Properties></Item>
<Item class="Lighting" referent="RBXBECAKLIGHTING"><Properties><float name="Brightness">2.5</float><double name="ClockTime">8</double><bool name="GlobalShadows">true</bool><string name="Name">Lighting</string></Properties></Item>
<Item class="ServerScriptService" referent="RBXBECAKSSS"><Properties><string name="Name">ServerScriptService</string></Properties><Item class="Script" referent="RBXBECAKSERVER"><Properties><bool name="Disabled">false</bool><string name="Name">BecakEBike_Runtime</string><ProtectedString name="Source"><![CDATA[${cdata(serverSource)}]]></ProtectedString></Properties></Item></Item>
<Item class="StarterPlayer" referent="RBXBECAKSTARTER"><Properties><string name="Name">StarterPlayer</string></Properties><Item class="StarterPlayerScripts" referent="RBXBECAKSPS"><Properties><string name="Name">StarterPlayerScripts</string></Properties><Item class="LocalScript" referent="RBXBECAKCLIENT"><Properties><bool name="Disabled">false</bool><string name="Name">BecakEBike_Client</string><ProtectedString name="Source"><![CDATA[${cdata(clientSource)}]]></ProtectedString></Properties></Item></Item></Item>
</roblox>\n`;

fs.writeFileSync(path.join(root, 'maps/becak-e-bike/place.rbxlx'), xml);
console.log('Built maps/becak-e-bike/place.rbxlx');
