const fs = require('fs');
const path = require('path');

const mapId = process.argv[2];
if (mapId !== 'a-club') process.exit(0);

const registry = JSON.parse(fs.readFileSync(path.join(process.cwd(), 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map id: ${mapId}`);

const placePath = path.join(process.cwd(), target.file);
const readLua = (file) => fs.readFileSync(path.join(process.cwd(), file), 'utf8').replaceAll(']]>', ']]]]><![CDATA[>');
const mainLua = readLua('maps/a-club/bbya.server.lua');
const architectureLua = readLua('maps/a-club/bbya.architecture.server.lua');
const masterPlanLua = readLua('maps/a-club/bbya.master-plan-completion.server.lua');
const masterPlanQCLua = readLua('maps/a-club/bbya.master-plan-qc.server.lua');
const systemsLua = readLua('maps/a-club/bbya.systems.server.lua');
const monetizationLua = readLua('maps/a-club/bbya.monetization.server.lua');
const musicLua = readLua('maps/a-club/bbya.music.server.lua');
const supportPanelLua = readLua('maps/a-club/bbya.support-panel.server.lua');
const djLua = readLua('maps/a-club/bbya.dj.server.lua');
const featuresLua = readLua('maps/a-club/bbya.features.server.lua');
const qcLua = readLua('maps/a-club/bbya.qc.server.lua');
const titleSizeLua = readLua('maps/a-club/bbya.title-size.server.lua');
const rankSystemLua = readLua('maps/a-club/bbya.rank-system.server.lua');
const signFixLua = readLua('maps/a-club/bbya.signfix.server.lua');
const supporterPositionLua = readLua('maps/a-club/bbya.supporter-board-position.server.lua');
const layoutHotfixLua = readLua('maps/a-club/bbya.layout-hotfix.server.lua');
const spatialCleanupLua = readLua('maps/a-club/bbya.spatial-cleanup.server.lua');
const queenAccessLua = readLua('maps/a-club/bbya.queen-access-hotfix.server.lua');
const spawnEntryLua = readLua('maps/a-club/bbya.spawn-entry-hotfix.server.lua');
const clientLua = readLua('maps/a-club/bbya.client.lua');
const musicClientLua = readLua('maps/a-club/bbya.music.client.lua');
const supportPanelClientLua = readLua('maps/a-club/bbya.support-panel.client.lua');
const monetizationClientLua = readLua('maps/a-club/bbya.monetization.client.lua');
const queenClientLua = readLua('maps/a-club/bbya.queen.client.lua');

let xml = fs.readFileSync(placePath, 'utf8');
const begin = '<!-- BBYA_RUNTIME_BEGIN -->';
const end = '<!-- BBYA_RUNTIME_END -->';
const prior = new RegExp(`${begin}[\\s\\S]*?${end}`, 'g');
xml = xml.replace(prior, '');

const runtime = `${begin}
<Item class="ServerScriptService" referent="RBXBBYASERVERSCRIPTSERVICE00000001">
  <Properties><string name="Name">ServerScriptService</string></Properties>
  <Item class="Script" referent="RBXBBYARUNTIME00000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Runtime_Main</string><ProtectedString name="Source"><![CDATA[${mainLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAARCHITECTURE000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Mega_Architecture_v2</string><ProtectedString name="Source"><![CDATA[${architectureLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAMASTERPLAN00000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Master_Plan_Completion_v3</string><ProtectedString name="Source"><![CDATA[${masterPlanLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAMASTERPLANQC000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Master_Plan_QC_v3_0_1</string><ProtectedString name="Source"><![CDATA[${masterPlanQCLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYASYSTEMS00000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Functional_Systems</string><ProtectedString name="Source"><![CDATA[${systemsLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAMONETIZATION000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Monetization_Backend</string><ProtectedString name="Source"><![CDATA[${monetizationLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAMUSICSERVER0000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Master_Music_Vault</string><ProtectedString name="Source"><![CDATA[${musicLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYASUPPORTDATA0000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Top_Supporter_Data</string><ProtectedString name="Source"><![CDATA[${supportPanelLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYADJ00000000000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Resident_DJ</string><ProtectedString name="Source"><![CDATA[${djLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAFEATURES0000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Feature_Stations</string><ProtectedString name="Source"><![CDATA[${featuresLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAQC000000000000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_QC_Hotfix</string><ProtectedString name="Source"><![CDATA[${qcLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYATITLESIZE000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Title_Size_Hotfix</string><ProtectedString name="Source"><![CDATA[${titleSizeLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYARANKSYSTEM00000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Social_Rank_System</string><ProtectedString name="Source"><![CDATA[${rankSystemLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYASIGNFIX0000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Sign_Orientation_Hotfix</string><ProtectedString name="Source"><![CDATA[${signFixLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYASUPPORTPOS00000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Supporter_Board_Position_Hotfix</string><ProtectedString name="Source"><![CDATA[${supporterPositionLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYALAYOUTFIX000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Social_Corner_Layout_Hotfix</string><ProtectedString name="Source"><![CDATA[${layoutHotfixLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYASPATIALCLEANUP000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Spatial_Cleanup_Hotfix</string><ProtectedString name="Source"><![CDATA[${spatialCleanupLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYAQUEENACCESS000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Queen_Access_Hotfix</string><ProtectedString name="Source"><![CDATA[${queenAccessLua}]]></ProtectedString></Properties></Item>
  <Item class="Script" referent="RBXBBYASPAWNENTRY0000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Spawn_Entry_Hotfix</string><ProtectedString name="Source"><![CDATA[${spawnEntryLua}]]></ProtectedString></Properties></Item>
</Item>
<Item class="StarterPlayer" referent="RBXBBYASTARTERPLAYER00000000000001">
  <Properties><string name="Name">StarterPlayer</string></Properties>
  <Item class="StarterPlayerScripts" referent="RBXBBYASTARTERPLAYERSCRIPTS00000001">
    <Properties><string name="Name">StarterPlayerScripts</string></Properties>
    <Item class="LocalScript" referent="RBXBBYACLIENT000000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Client</string><ProtectedString name="Source"><![CDATA[${clientLua}]]></ProtectedString></Properties></Item>
    <Item class="LocalScript" referent="RBXBBYAMUSICCLIENT000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Music_Client</string><ProtectedString name="Source"><![CDATA[${musicClientLua}]]></ProtectedString></Properties></Item>
    <Item class="LocalScript" referent="RBXBBYASUPPORTCLIENT0000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Supporter_Client</string><ProtectedString name="Source"><![CDATA[${supportPanelClientLua}]]></ProtectedString></Properties></Item>
    <Item class="LocalScript" referent="RBXBBYAMONETIZATIONCLIENT00000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Monetization_Client</string><ProtectedString name="Source"><![CDATA[${monetizationClientLua}]]></ProtectedString></Properties></Item>
    <Item class="LocalScript" referent="RBXBBYAQUEENCLIENT0000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Queen_Client</string><ProtectedString name="Source"><![CDATA[${queenClientLua}]]></ProtectedString></Properties></Item>
  </Item>
</Item>
${end}`;

if (!xml.includes('</roblox>')) throw new Error('Invalid RBXLX: missing </roblox>');
xml = xml.replace('</roblox>', `${runtime}</roblox>`);
fs.writeFileSync(placePath, xml);
console.log('[BBYA] Active build injected: architecture + master-plan completion/QC + systems + VIP/support monetization + Music Vault/Auto-DJ + Top Supporter avatar panel + DJ + features + QC + social ranks + visual/layout/Queen/spawn-entry hotfixes + mobile panels into', target.file);
