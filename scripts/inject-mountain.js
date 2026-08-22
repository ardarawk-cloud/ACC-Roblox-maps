const fs = require('fs');
const path = require('path');

const mapId = process.argv[2];
if (mapId !== 'mountain-social') process.exit(0);

const root = process.cwd();
const registry = JSON.parse(fs.readFileSync(path.join(root, 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map id: ${mapId}`);
if (String(target.universeId) !== '4187755690' || String(target.placeId) !== '11832985967') throw new Error('Mountain target lock mismatch. Refusing injection.');

const readLua = (file) => fs.readFileSync(path.join(root, file), 'utf8').replaceAll(']]>', ']]]]><![CDATA[>');
const placePath = path.join(root, target.file);
const serverModules = [
  ['visual','maps/mountain-social/mountain.visual.server.lua'],
  ['basecamp','maps/mountain-social/mountain.basecamp.server.lua'],
  ['expedition','maps/mountain-social/mountain.expedition.server.lua'],
  ['precision','maps/mountain-social/mountain.precision.server.lua'],
  ['upper','maps/mountain-social/mountain.upper.server.lua'],
  ['checkpoint','maps/mountain-social/systems/checkpoint.server.lua'],
  ['ambience','maps/mountain-social/systems/ambience.server.lua']
];
for (const [,file] of serverModules) if (!fs.existsSync(path.join(root,file))) throw new Error(`Missing Mountain runtime module: ${file}`);
const wrapped = serverModules.map(([name,file]) => `\ntask.spawn(function()\n local ok,err=pcall(function()\n${readLua(file)}\n end)\n if not ok then warn('[Mountain:${name}]',err) end\nend)`).join('\n');
const bundle = `${readLua('maps/mountain-social/mountain.world.server.lua')}\n${wrapped}\nworkspace:SetAttribute('ACC_MountainCoreBundle','v4.5-upper-scenic')`;
const clientFiles = ['maps/mountain-social/mountain.client.lua','maps/mountain-social/mountain.altitude.client.lua','maps/mountain-social/mountain.performance.client.lua'];
const client = clientFiles.filter(f=>fs.existsSync(path.join(root,f))).map(readLua).join('\n');
const qc = `task.delay(32,function()\n local r=workspace:FindFirstChild('ACC_MountainSocial')\n local cps=r and r:FindFirstChild('Checkpoints')\n local ok=r~=nil\n  and r:GetAttribute('WorldRebuild')=='4.2'\n  and r:GetAttribute('PrecisionRoadReady')==true\n  and r:GetAttribute('PrecisionVersion')=='4.4'\n  and r:GetAttribute('LowerForestReady')==true\n  and r:GetAttribute('RiverCrossingReady')==true\n  and r:GetAttribute('MidCampReady')==true\n  and r:GetAttribute('CliffZoneReady')==true\n  and r:GetAttribute('FogZoneReady')==true\n  and r:GetAttribute('HighlandReady')==true\n  and r:GetAttribute('RidgeReady')==true\n  and r:GetAttribute('FalseSummitReady')==true\n  and r:GetAttribute('SummitScenicReady')==true\n  and r:GetAttribute('UpperScenicVersion')=='4.5'\n  and workspace:GetAttribute('ACC_TimeCycle')=='v4.1-four-phase'\n  and cps~=nil and #cps:GetChildren()>=12\n workspace:SetAttribute('ACC_MountainReady',ok)\n workspace:SetAttribute('ACC_MountainBuild','v4.5-upper-scenic')\n if r then r:SetAttribute('BuildVersion','4.5.0-upper-scenic') end\n if not ok then warn('[Mountain:QC] v4.5 upper scenic readiness gate failed') end\nend)`;
const xml = `<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External><Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties></Item><Item class="Lighting" referent="L"><Properties><float name="Brightness">2</float><double name="ClockTime">6.3</double><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties><Item class="Script" referent="B"><Properties><string name="Name">ACC_Mountain_World</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${bundle}]]></ProtectedString></Properties></Item><Item class="Script" referent="Q"><Properties><string name="Name">ACC_Mountain_QC</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${qc}]]></ProtectedString></Properties></Item></Item><Item class="StarterPlayer" referent="P"><Properties><string name="Name">StarterPlayer</string></Properties><Item class="StarterPlayerScripts" referent="PS"><Properties><string name="Name">StarterPlayerScripts</string></Properties><Item class="LocalScript" referent="C"><Properties><string name="Name">ACC_Mountain_Client</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${client}]]></ProtectedString></Properties></Item></Item></Item></roblox>`;
fs.writeFileSync(placePath,xml);
console.log('[Mountain] Injected ACC Mountain v4.5 upper scenic into',target.file,'bytes',Buffer.byteLength(xml));