const fs = require('fs');
const path = require('path');

const mapId = process.argv[2];
if (mapId !== 'a-club') process.exit(0);

const registry = JSON.parse(fs.readFileSync(path.join(process.cwd(), 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map id: ${mapId}`);

const placePath = path.join(process.cwd(), target.file);
const readLua = (file) => fs.readFileSync(path.join(process.cwd(), file), 'utf8').replaceAll(']]>', ']]]]><![CDATA[>');

// Functional core + premium BBYA build layers.
const mainLua = readLua('maps/a-club/bbya.server.lua');
const rebuildLua = readLua('maps/a-club/bbya.visual-rebuild-v4.server.lua');
const polishLua = readLua('maps/a-club/bbya.visual-polish-v4.server.lua');
const phase3Lua = readLua('maps/a-club/bbya.phase3-premium.server.lua');
const phase4Lua = readLua('maps/a-club/bbya.phase4-experience.server.lua');
const phase5Lua = readLua('maps/a-club/bbya.phase5-finish.server.lua');
const productionQCLua = readLua('maps/a-club/bbya.production-qc-v4.server.lua');
const buildValidationLua = readLua('maps/a-club/bbya.build-validation.server.lua');
const systemsLua = readLua('maps/a-club/bbya.systems.server.lua');
const monetizationLua = readLua('maps/a-club/bbya.monetization.server.lua');
const musicLua = readLua('maps/a-club/bbya.music.server.lua');
const supportPanelLua = readLua('maps/a-club/bbya.support-panel.server.lua');
const djLua = readLua('maps/a-club/bbya.dj.server.lua');
const qcLua = readLua('maps/a-club/bbya.qc.server.lua');
const titleSizeLua = readLua('maps/a-club/bbya.title-size.server.lua');
const rankSystemLua = readLua('maps/a-club/bbya.rank-system.server.lua');
const queenAccessLua = readLua('maps/a-club/bbya.queen-access-hotfix.server.lua');
const spawnEntryLua = readLua('maps/a-club/bbya.spawn-entry-hotfix.server.lua');

const clientLua = readLua('maps/a-club/bbya.client.lua');
const musicClientLua = readLua('maps/a-club/bbya.music.client.lua');
const supportPanelClientLua = readLua('maps/a-club/bbya.support-panel.client.lua');
const monetizationClientLua = readLua('maps/a-club/bbya.monetization.client.lua');
const supportCelebrationClientLua = readLua('maps/a-club/bbya.support-celebration.client.lua');
const performanceClientLua = readLua('maps/a-club/bbya.performance.client.lua');
const queenClientLua = readLua('maps/a-club/bbya.queen.client.lua');

let xml = fs.readFileSync(placePath, 'utf8');
const begin = '<!-- BBYA_RUNTIME_BEGIN -->';
const end = '<!-- BBYA_RUNTIME_END -->';
const prior = new RegExp(`${begin}[\\s\\S]*?${end}`, 'g');
xml = xml.replace(prior, '');

const runtime = `${begin}
<Item class="ServerScriptService" referent="RBXBBYASERVERSCRIPTSERVICE00000001">
  <Properties><string name="Name">ServerScriptService</string></Properties>
  <Item class="Script" referent="RBXBBYARUNTIME00000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Runtime_Core</string><ProtectedString name="Source"><![CDATA[${mainLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAVISUALREBUILDV4000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Premium_Visual_Rebuild_v4</string><ProtectedString name="Source"><![CDATA[${rebuildLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAVISUALPOLISHV4100000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Premium_Venue_Polish_v4_1</string><ProtectedString name="Source"><![CDATA[${polishLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAPHASE3PREMIUMV430000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Premium_Phase_3_v4_3</string><ProtectedString name="Source"><![CDATA[${phase3Lua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAPHASE4PREMIUMV440000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Premium_Phase_4_v4_4_1</string><ProtectedString name="Source"><![CDATA[${phase4Lua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAPHASE5PREMIUMV450000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Premium_Phase_5_v4_5_1</string><ProtectedString name="Source"><![CDATA[${phase5Lua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAPRODUCTIONQCV4300000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Production_QC_v4_3</string><ProtectedString name="Source"><![CDATA[${productionQCLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYABUILDVALIDATION00000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Build_Validation_v1</string><ProtectedString name="Source"><![CDATA[${buildValidationLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYASYSTEMS00000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Functional_Systems_v2</string><ProtectedString name="Source"><![CDATA[${systemsLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAMONETIZATION000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Monetization_Backend</string><ProtectedString name="Source"><![CDATA[${monetizationLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAMUSICSERVER0000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Master_Music_Vault</string><ProtectedString name="Source"><![CDATA[${musicLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYASUPPORTDATA0000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Top_Supporter_Data</string><ProtectedString name="Source"><![CDATA[${supportPanelLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYADJ00000000000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Resident_DJ</string><ProtectedString name="Source"><![CDATA[${djLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAQC000000000000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Functional_QC</string><ProtectedString name="Source"><![CDATA[${qcLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYATITLESIZE000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Title_Size</string><ProtectedString name="Source"><![CDATA[${titleSizeLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYARANKSYSTEM00000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Social_Rank_System</string><ProtectedString name="Source"><![CDATA[${rankSystemLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAQUEENACCESS000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Queen_Access</string><ProtectedString name="Source"><![CDATA[${queenAccessLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYASPAWNENTRY0000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Spawn_Entry</string><ProtectedString name="Source"><![CDATA[${spawnEntryLua}]]></ProtectedString></Properties></Item>
</Item>
<Item class="StarterPlayer" referent="RBXBBYASTARTERPLAYER00000000000001">
  <Properties><string name="Name">StarterPlayer</string></Properties>
  <Item class="StarterPlayerScripts" referent="RBXBBYASTARTERPLAYERSCRIPTS00000001">
    <Properties><string name="Name">StarterPlayerScripts</string></Properties>
    <Item class="LocalScript" referent="RBXBBYACLIENT000000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Dance_Studio_Client</string><ProtectedString name="Source"><![CDATA[${clientLua}]]></ProtectedString></Properties></Item>
    <Item class="LocalScript" referent="RBXBBYAMUSICCLIENT000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Music_Client</string><ProtectedString name="Source"><![CDATA[${musicClientLua}]]></ProtectedString></Properties></Item>
    <Item class="LocalScript" referent="RBXBBYASUPPORTCLIENT0000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Supporter_Client</string><ProtectedString name="Source"><![CDATA[${supportPanelClientLua}]]></ProtectedString></Properties></Item>
    <Item class="LocalScript" referent="RBXBBYAMONETIZATIONCLIENT00000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Monetization_Client</string><ProtectedString name="Source"><![CDATA[${monetizationClientLua}]]></ProtectedString></Properties></Item>
    <Item class="LocalScript" referent="RBXBBYASUPPORTCELEBRATION00000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Support_Celebration_Client</string><ProtectedString name="Source"><![CDATA[${supportCelebrationClientLua}]]></ProtectedString></Properties></Item>
    <Item class="LocalScript" referent="RBXBBYAPERFORMANCECLIENT0000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Adaptive_Performance_Client</string><ProtectedString name="Source"><![CDATA[${performanceClientLua}]]></ProtectedString></Properties></Item>
    <Item class="LocalScript" referent="RBXBBYAQUEENCLIENT0000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Queen_Client</string><ProtectedString name="Source"><![CDATA[${queenClientLua}]]></ProtectedString></Properties></Item>
  </Item>
</Item>
${end}`;

if (!xml.includes('</roblox>')) throw new Error('Invalid RBXLX: missing </roblox>');
xml = xml.replace('</roblox>', `${runtime}</roblox>`);
fs.writeFileSync(placePath, xml);
console.log('[BBYA] Active build injected: Premium build 4.5.1 + QC + runtime validation + anchor navigation + adaptive mobile performance + premium UI systems into', target.file);
