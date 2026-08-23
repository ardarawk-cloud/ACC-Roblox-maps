const fs=require('fs'),path=require('path');
const root=process.cwd();
const readLua=f=>fs.readFileSync(path.join(root,f),'utf8').replaceAll(']]>',']]]]><![CDATA[>');

// Keep the physical world bootstrap isolated from feature modules. A syntax/runtime
// regression in analytics, persistence, or commerce must never blank the showroom.
const coreServerFiles=[
  ['BBYAVATAR_Runtime','maps/bbyavatar/runtime.server.lua'],
  ['BBYAVATAR_PremiumShowroom','maps/bbyavatar/showroom-premium.server.lua']
];
const featureServerFiles=[
  ['BBYAVATAR_Telemetry','maps/bbyavatar/telemetry.server.lua'],
  ['BBYAVATAR_PhotoAnalytics','maps/bbyavatar/photo-analytics.server.lua'],
  ['BBYAVATAR_LookShareAnalytics','maps/bbyavatar/look-share-analytics.server.lua'],
  ['BBYAVATAR_DailyAggregate','maps/bbyavatar/daily-aggregate.server.lua'],
  ['BBYAVATAR_SavedPicks','maps/bbyavatar/saved-picks.server.lua'],
  ['BBYAVATAR_LookShare','maps/bbyavatar/look-share.server.lua'],
  ['BBYAVATAR_BulkPurchase','maps/bbyavatar/bulk-purchase.server.lua'],
  ['BBYAVATAR_RecentViews','maps/bbyavatar/recent-views.server.lua'],
  ['BBYAVATAR_VisitStreak','maps/bbyavatar/visit-streak.server.lua'],
  ['BBYAVATAR_DailyChallenge','maps/bbyavatar/daily-style-challenge.server.lua'],
  ['BBYAVATAR_BoardPersistence','maps/bbyavatar/style-board-persistence.server.lua'],
  ['BBYAVATAR_LookVault','maps/bbyavatar/look-vault.server.lua']
];
const clientFiles=[
  'maps/bbyavatar/runtime.client.lua','maps/bbyavatar/mobile.client.lua','maps/bbyavatar/catalog-grid.client.lua',
  'maps/bbyavatar/tryon.client.lua','maps/bbyavatar/tryon-actions.client.lua','maps/bbyavatar/saved-picks.client.lua',
  'maps/bbyavatar/owned-items.client.lua','maps/bbyavatar/style-board.client.lua','maps/bbyavatar/look-share.client.lua',
  'maps/bbyavatar/style-board-save.client.lua','maps/bbyavatar/style-board-persistence.client.lua','maps/bbyavatar/look-vault.client.lua',
  'maps/bbyavatar/catalog-filters.client.lua','maps/bbyavatar/wardrobe.client.lua','maps/bbyavatar/prompt-feedback.client.lua',
  'maps/bbyavatar/photo-studio.client.lua','maps/bbyavatar/daily-spotlight.client.lua','maps/bbyavatar/discovery.client.lua',
  'maps/bbyavatar/recommendations.client.lua','maps/bbyavatar/item-detail.client.lua','maps/bbyavatar/item-detail-responsive.client.lua',
  'maps/bbyavatar/catalog-card-responsive.client.lua','maps/bbyavatar/recent-views.client.lua','maps/bbyavatar/visit-streak.client.lua',
  'maps/bbyavatar/daily-style-challenge.client.lua','maps/bbyavatar/accessibility.client.lua','maps/bbyavatar/tab-scroll.client.lua',
  'maps/bbyavatar/category-autoload.client.lua','maps/bbyavatar/navigation.client.lua'
];

const scriptItem=(name,source,ref)=>`<Item class="Script" referent="${ref}"><Properties><string name="Name">${name}</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${source}]]></ProtectedString></Properties></Item>`;
const serverItems=[...coreServerFiles,...featureServerFiles].map(([name,file],i)=>scriptItem(name,readLua(file),`S${i}`)).join('');
const client=clientFiles.map(readLua).join('\n\n');

const xml=`<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External><Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties></Item><Item class="Lighting" referent="L"><Properties><float name="Brightness">2.5</float><double name="ClockTime">18.2</double><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties>${serverItems}</Item><Item class="StarterPlayer" referent="P"><Properties><string name="Name">StarterPlayer</string></Properties><Item class="StarterPlayerScripts" referent="PS"><Properties><string name="Name">StarterPlayerScripts</string></Properties><Item class="LocalScript" referent="C"><Properties><string name="Name">BBYAVATAR_Client</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${client}]]></ProtectedString></Properties></Item></Item></Item></roblox>`;
fs.writeFileSync(path.join(root,'maps/bbyavatar/place.rbxlx'),xml);

if(!xml.includes('<string name="Name">BBYAVATAR_Runtime</string>')) throw new Error('Missing isolated runtime bootstrap');
if(!xml.includes('<string name="Name">BBYAVATAR_PremiumShowroom</string>')) throw new Error('Missing isolated premium showroom');
console.log(`[BBYAVATAR] Built resilient place.rbxlx with ${coreServerFiles.length} isolated world scripts, ${featureServerFiles.length} isolated feature scripts, and responsive client bundle`);