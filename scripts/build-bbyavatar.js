const fs=require('fs'),path=require('path');
const root=process.cwd();
const readLua=f=>fs.readFileSync(path.join(root,f),'utf8').replaceAll(']]>',']]]]><![CDATA[>');
const server=[
  readLua('maps/bbyavatar/runtime.server.lua'),
  readLua('maps/bbyavatar/showroom-premium.server.lua'),
  readLua('maps/bbyavatar/telemetry.server.lua'),
  readLua('maps/bbyavatar/photo-analytics.server.lua'),
  readLua('maps/bbyavatar/look-share-analytics.server.lua'),
  readLua('maps/bbyavatar/daily-aggregate.server.lua'),
  readLua('maps/bbyavatar/saved-picks.server.lua'),
  readLua('maps/bbyavatar/look-share.server.lua'),
  readLua('maps/bbyavatar/bulk-purchase.server.lua'),
  readLua('maps/bbyavatar/recent-views.server.lua'),
  readLua('maps/bbyavatar/visit-streak.server.lua'),
  readLua('maps/bbyavatar/daily-style-challenge.server.lua'),
  readLua('maps/bbyavatar/style-board-persistence.server.lua'),
  readLua('maps/bbyavatar/look-vault.server.lua')
].join('\n\n');
const client=[
  readLua('maps/bbyavatar/runtime.client.lua'),
  readLua('maps/bbyavatar/mobile.client.lua'),
  readLua('maps/bbyavatar/catalog-grid.client.lua'),
  readLua('maps/bbyavatar/tryon.client.lua'),
  readLua('maps/bbyavatar/tryon-actions.client.lua'),
  readLua('maps/bbyavatar/saved-picks.client.lua'),
  readLua('maps/bbyavatar/owned-items.client.lua'),
  readLua('maps/bbyavatar/style-board.client.lua'),
  readLua('maps/bbyavatar/look-share.client.lua'),
  readLua('maps/bbyavatar/style-board-save.client.lua'),
  readLua('maps/bbyavatar/style-board-persistence.client.lua'),
  readLua('maps/bbyavatar/look-vault.client.lua'),
  readLua('maps/bbyavatar/catalog-filters.client.lua'),
  readLua('maps/bbyavatar/wardrobe.client.lua'),
  readLua('maps/bbyavatar/prompt-feedback.client.lua'),
  readLua('maps/bbyavatar/photo-studio.client.lua'),
  readLua('maps/bbyavatar/daily-spotlight.client.lua'),
  readLua('maps/bbyavatar/discovery.client.lua'),
  readLua('maps/bbyavatar/recommendations.client.lua'),
  readLua('maps/bbyavatar/item-detail.client.lua'),
  readLua('maps/bbyavatar/item-detail-responsive.client.lua'),
  readLua('maps/bbyavatar/recent-views.client.lua'),
  readLua('maps/bbyavatar/visit-streak.client.lua'),
  readLua('maps/bbyavatar/daily-style-challenge.client.lua'),
  readLua('maps/bbyavatar/accessibility.client.lua'),
  readLua('maps/bbyavatar/tab-scroll.client.lua'),
  readLua('maps/bbyavatar/navigation.client.lua')
].join('\n\n');
const xml=`<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External><Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties></Item><Item class="Lighting" referent="L"><Properties><float name="Brightness">2.5</float><double name="ClockTime">18.2</double><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties><Item class="Script" referent="B"><Properties><string name="Name">BBYAVATAR_Runtime</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${server}]]></ProtectedString></Properties></Item></Item><Item class="StarterPlayer" referent="P"><Properties><string name="Name">StarterPlayer</string></Properties><Item class="StarterPlayerScripts" referent="PS"><Properties><string name="Name">StarterPlayerScripts</string></Properties><Item class="LocalScript" referent="C"><Properties><string name="Name">BBYAVATAR_Client</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${client}]]></ProtectedString></Properties></Item></Item></Item></roblox>`;
fs.writeFileSync(path.join(root,'maps/bbyavatar/place.rbxlx'),xml);
console.log('[BBYAVATAR] Built responsive place.rbxlx with premium low-part showroom architecture, live try-on, atomic full-look preview, server-authoritative single-prompt BUY MISSING conversion with post-prompt ownership verification, privacy-minimal 30-day look share codes with atomic capacity-preflight imports that preserve the current board on failure plus aggregate no-content share funnel analytics, exact-preview gated SAVE FULL LOOK conversion, native SAVE LOOK conversion action, persistent privacy-safe Saved Picks, Recently Viewed and Style Board, three-slot privacy-minimal Look Vault, Roblox-native owned inventory styling, server-authoritative privacy-minimal daily Style Streak retention, persistent daily Style Challenge BROWSE->TRY->SAVE loop, deterministic daily discovery spotlight, advanced catalog filters, Roblox-native saved wardrobe, contextual Roblox-native recommendations, on-demand mobile-responsive item detail inspection, catalog grid, prompt feedback, privacy-safe session funnel telemetry plus anonymous daily aggregate persistence, Roblox-native Photo Studio screenshot save/share with capture-only anonymous health metrics, session-personalized discovery, session-local accessibility/low-FX controls, mobile-safe horizontally scrollable catalog tabs, and keyboard/gamepad navigation with back-button close behavior');