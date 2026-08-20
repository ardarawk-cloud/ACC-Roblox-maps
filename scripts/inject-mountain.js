const fs = require('fs');
const path = require('path');

const mapId = process.argv[2];
if (mapId !== 'mountain-social') process.exit(0);

const root = process.cwd();
const registry = JSON.parse(fs.readFileSync(path.join(root, 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map id: ${mapId}`);
if (String(target.universeId) !== '10744139279' || String(target.placeId) !== '82661754996018') {
  throw new Error('Mountain target lock mismatch. Refusing injection.');
}

const readLua = (file) => fs.readFileSync(path.join(root, file), 'utf8').replaceAll(']]>', ']]]]><![CDATA[>');
const placePath = path.join(root, target.file);
const serverModules = [
  ['visual','maps/mountain-social/mountain.visual.server.lua'],
  ['basecamp','maps/mountain-social/mountain.basecamp.server.lua'],
  ['safety','maps/mountain-social/mountain.safety.server.lua'],
  ['social','maps/mountain-social/mountain.social.server.lua'],
  ['exploration','maps/mountain-social/mountain.exploration.server.lua'],
  ['summitExperience','maps/mountain-social/mountain.summitexperience.server.lua'],
  ['trailReadability','maps/mountain-social/mountain.trailreadability.server.lua'],
  ['routesV3','maps/mountain-social/mountain.routes.server.lua'],
  ['weatherV3','maps/mountain-social/mountain.weather.server.lua'],
  ['survivalV3','maps/mountain-social/mountain.survival.server.lua'],
  ['campingV3','maps/mountain-social/mountain.camping.server.lua'],
  ['gearV3','maps/mountain-social/mountain.gear.server.lua'],
  ['hazardsV3','maps/mountain-social/mountain.hazards.server.lua'],
  ['checkpoint','maps/mountain-social/systems/checkpoint.server.lua'],
  ['ambience','maps/mountain-social/systems/ambience.server.lua'],
  ['summit','maps/mountain-social/systems/summit.server.lua'],
  ['interactions','maps/mountain-social/mountain.interactions.server.lua'],
  ['carry','maps/mountain-social/systems/carry.server.lua']
];
for (const [,file] of serverModules) if (!fs.existsSync(path.join(root,file))) throw new Error(`Missing Mountain runtime module: ${file}`);
const wrapped = serverModules.map(([name,file]) => `\ntask.spawn(function()\n local ok,err=pcall(function()\n${readLua(file)}\n end)\n if not ok then warn('[Mountain:${name}]',err) end\nend)`).join('\n');
const bundle = `${readLua('maps/mountain-social/mountain.world.server.lua')}\n${wrapped}\nworkspace:SetAttribute('ACC_MountainCoreBundle','v3.0')`;
const client = [readLua('maps/mountain-social/mountain.client.lua'),readLua('maps/mountain-social/mountain.performance.client.lua'),readLua('maps/mountain-social/mountain.vitals.client.lua')].join('\n');
const qc = `task.delay(22,function()\n local r=workspace:FindFirstChild('ACC_MountainSocial')\n local ok=r~=nil\n  and r:GetAttribute('BuildVersion')~=nil\n  and workspace:GetAttribute('ACC_TraversalSafety')=='v2.2'\n  and workspace:GetAttribute('ACC_SocialCamp')=='v2.3'\n  and workspace:GetAttribute('ACC_Exploration')=='v2.4'\n  and workspace:GetAttribute('ACC_SummitExperience')=='v2.5'\n  and workspace:GetAttribute('ACC_TrailReadability')=='v2.6'\n  and workspace:GetAttribute('ACC_MountainRoutes')=='v3.0'\n  and workspace:GetAttribute('ACC_MountainWeather')=='v3.0'\n  and workspace:GetAttribute('ACC_MountainSurvival')=='v3.0'\n  and workspace:GetAttribute('ACC_MountainCamping')=='v3.0'\n  and workspace:GetAttribute('ACC_MountainGear')=='v3.0'\n  and workspace:GetAttribute('ACC_MountainHazards')=='v3.0'\n if r then r:SetAttribute('BuildVersion','3.0.0-master') end\n workspace:SetAttribute('ACC_MountainReady',ok)\n workspace:SetAttribute('ACC_MountainBuild','v3.0')\n if not ok then warn('[Mountain:QC] v3.0 readiness gate failed') end\nend)`;
const xml = `<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External><Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties></Item><Item class="Lighting" referent="L"><Properties><float name="Brightness">2</float><double name="ClockTime">6.2</double><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties><Item class="Script" referent="B"><Properties><string name="Name">ACC_Mountain_World</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${bundle}]]></ProtectedString></Properties></Item><Item class="Script" referent="Q"><Properties><string name="Name">ACC_Mountain_QC</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${qc}]]></ProtectedString></Properties></Item></Item><Item class="StarterPlayer" referent="P"><Properties><string name="Name">StarterPlayer</string></Properties><Item class="StarterPlayerScripts" referent="PS"><Properties><string name="Name">StarterPlayerScripts</string></Properties><Item class="LocalScript" referent="C"><Properties><string name="Name">ACC_Mountain_Client</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${client}]]></ProtectedString></Properties></Item></Item></Item></roblox>`;
fs.writeFileSync(placePath,xml);
console.log('[Mountain] Injected ACC Mountain Master v3.0 into',target.file);
