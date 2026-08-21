const fs=require('fs'),path=require('path');
const root=process.cwd();
const readLua=f=>fs.readFileSync(path.join(root,f),'utf8').replaceAll(']]>',']]]]><![CDATA[>');
const server=[
  readLua('maps/bbyavatar/runtime.server.lua'),
  readLua('maps/bbyavatar/telemetry.server.lua'),
  readLua('maps/bbyavatar/saved-picks.server.lua')
].join('\n\n');
const client=[
  readLua('maps/bbyavatar/runtime.client.lua'),
  readLua('maps/bbyavatar/mobile.client.lua'),
  readLua('maps/bbyavatar/catalog-grid.client.lua'),
  readLua('maps/bbyavatar/tryon.client.lua'),
  readLua('maps/bbyavatar/saved-picks.client.lua'),
  readLua('maps/bbyavatar/catalog-filters.client.lua'),
  readLua('maps/bbyavatar/wardrobe.client.lua'),
  readLua('maps/bbyavatar/prompt-feedback.client.lua'),
  readLua('maps/bbyavatar/photo-studio.client.lua'),
  readLua('maps/bbyavatar/discovery.client.lua'),
  readLua('maps/bbyavatar/recommendations.client.lua'),
  readLua('maps/bbyavatar/item-detail.client.lua'),
  readLua('maps/bbyavatar/item-detail-responsive.client.lua')
].join('\n\n');
const xml=`<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External><Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties></Item><Item class="Lighting" referent="L"><Properties><float name="Brightness">2.5</float><double name="ClockTime">18.2</double><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties><Item class="Script" referent="B"><Properties><string name="Name">BBYAVATAR_Runtime</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${server}]]></ProtectedString></Properties></Item></Item><Item class="StarterPlayer" referent="P"><Properties><string name="Name">StarterPlayer</string></Properties><Item class="StarterPlayerScripts" referent="PS"><Properties><string name="Name">StarterPlayerScripts</string></Properties><Item class="LocalScript" referent="C"><Properties><string name="Name">BBYAVATAR_Client</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${client}]]></ProtectedString></Properties></Item></Item></Item></roblox>`;
fs.writeFileSync(path.join(root,'maps/bbyavatar/place.rbxlx'),xml);
console.log('[BBYAVATAR] Built responsive place.rbxlx with live try-on, persistent privacy-safe Saved Picks, advanced catalog filters, Roblox-native saved wardrobe, contextual Roblox-native recommendations, on-demand mobile-responsive item detail inspection, catalog grid, prompt feedback, privacy-safe funnel telemetry, functional photo studio, and session-personalized discovery');
