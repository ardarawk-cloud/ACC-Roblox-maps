const fs = require('fs');
const path = require('path');

const mapId = process.argv[2];
if (mapId !== 'a-club') process.exit(0);

const root = process.cwd();
const registry = JSON.parse(fs.readFileSync(path.join(root, 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map id: ${mapId}`);

const placePath = path.join(root, target.file);
const readLua = (file) => fs.readFileSync(path.join(root, file), 'utf8').replaceAll(']]>', ']]]]><![CDATA[>');

const serverScripts = [
  ['BBYA_Clean_Functional_Core_v3', 'maps/a-club/bbya.core.server.lua'],
  ['BBYA_Premium_Visual_Rebuild_v4', 'maps/a-club/bbya.visual-rebuild-v4.server.lua'],
  ['BBYA_Premium_Venue_Polish_v4_1', 'maps/a-club/bbya.visual-polish-v4.server.lua'],
  ['BBYA_Premium_Phase_3_v4_3', 'maps/a-club/bbya.phase3-premium.server.lua'],
  ['BBYA_Premium_Phase_4_v4_4_1', 'maps/a-club/bbya.phase4-experience.server.lua'],
  ['BBYA_Premium_Phase_5_v4_5_1', 'maps/a-club/bbya.phase5-finish.server.lua'],
  ['BBYA_Premium_Phase_6_v4_6', 'maps/a-club/bbya.phase6-wayfinding.server.lua'],
  ['BBYA_Production_QC_v4_3', 'maps/a-club/bbya.production-qc-v4.server.lua'],
  ['BBYA_Live_Playtest_Fix_v4_7', 'maps/a-club/bbya.livefix-4.7.server.lua'],
  // v4.9 deliberately waits for builders above, then removes their old lobby geometry.
  ['BBYA_Front_Lobby_Final_v4_9', 'maps/a-club/bbya.front-lobby-v4.9.server.lua'],
  // User-requested cleanup: trees/palms are removed entirely after all builders settle.
  ['BBYA_Remove_Trees_v1', 'maps/a-club/bbya.remove-trees.server.lua'],
  ['BBYA_Build_Validation', 'maps/a-club/bbya.build-validation.server.lua'],
  ['BBYA_Queen_Playtest_System_Test_v1', 'maps/a-club/bbya.playtest.server.lua'],
  ['BBYA_Functional_Systems_v2', 'maps/a-club/bbya.systems.server.lua'],
  ['BBYA_Monetization_Backend', 'maps/a-club/bbya.monetization.server.lua'],
  ['BBYA_Master_Music_Vault', 'maps/a-club/bbya.music.server.lua'],
  ['BBYA_Top_Supporter_Data', 'maps/a-club/bbya.support-panel.server.lua'],
  ['BBYA_Resident_DJ', 'maps/a-club/bbya.dj.server.lua'],
  ['BBYA_Title_Size', 'maps/a-club/bbya.title-size.server.lua'],
  ['BBYA_Social_Rank_System', 'maps/a-club/bbya.rank-system.server.lua'],
  ['BBYA_Queen_Access', 'maps/a-club/bbya.queen-access-hotfix.server.lua'],
  ['BBYA_Final_Arrival_Spawn', 'maps/a-club/bbya.spawn-final.server.lua'],
];

const clientScripts = [
  ['BBYA_Dance_Studio_Client', 'maps/a-club/bbya.client.lua'],
  ['BBYA_Music_Client', 'maps/a-club/bbya.music.client.lua'],
  ['BBYA_Supporter_Client', 'maps/a-club/bbya.support-panel.client.lua'],
  ['BBYA_Monetization_Client', 'maps/a-club/bbya.monetization.client.lua'],
  ['BBYA_Support_Celebration_Client', 'maps/a-club/bbya.support-celebration.client.lua'],
  ['BBYA_Adaptive_Performance_Client', 'maps/a-club/bbya.performance.client.lua'],
  ['BBYA_UI_Coordinator_Client', 'maps/a-club/bbya.ui-coordinator.client.lua'],
  ['BBYA_Live_Mobile_UI_Fix_v4_7', 'maps/a-club/bbya.livefix-4.7.client.lua'],
  ['BBYA_Queen_Playtest_Health_HUD', 'maps/a-club/bbya.health.client.lua'],
  ['BBYA_Queen_Client', 'maps/a-club/bbya.queen.client.lua'],
];

const scriptItem = (klass, name, file, ref) => `
<Item class="${klass}" referent="${ref}">
  <Properties>
    <bool name="Disabled">false</bool>
    <string name="Name">${name}</string>
    <ProtectedString name="Source"><![CDATA[${readLua(file)}]]></ProtectedString>
  </Properties>
</Item>`;

const serverItems = serverScripts.map((s, i) => scriptItem('Script', s[0], s[1], `RBXBBYASRV${String(i).padStart(4, '0')}`)).join('');
const clientItems = clientScripts.map((s, i) => scriptItem('LocalScript', s[0], s[1], `RBXBBYACLI${String(i).padStart(4, '0')}`)).join('');

let xml = fs.readFileSync(placePath, 'utf8');
const begin = '<!-- BBYA_RUNTIME_BEGIN -->';
const end = '<!-- BBYA_RUNTIME_END -->';
xml = xml.replace(new RegExp(`${begin}[\\s\\S]*?${end}`, 'g'), '');

const runtime = `${begin}
<Item class="ServerScriptService" referent="RBXBBYASSSFINAL">
  <Properties><string name="Name">ServerScriptService</string></Properties>${serverItems}
</Item>
<Item class="StarterPlayer" referent="RBXBBYASPFINAL">
  <Properties><string name="Name">StarterPlayer</string></Properties>
  <Item class="StarterPlayerScripts" referent="RBXBBYASPSFINAL">
    <Properties><string name="Name">StarterPlayerScripts</string></Properties>${clientItems}
  </Item>
</Item>
${end}`;

if (!xml.includes('</roblox>')) throw new Error('Invalid RBXLX: missing </roblox>');
xml = xml.replace('</roblox>', `${runtime}</roblox>`);
fs.writeFileSync(placePath, xml);
console.log('[BBYA] Active build injected: v4.9 clean front lobby + full tree/palm removal cleanup.');
