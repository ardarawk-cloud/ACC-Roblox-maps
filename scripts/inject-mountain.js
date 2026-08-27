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

// Focus lock: Spawn -> CP1 is authoritative. Legacy lowland polish modules remain omitted.
let lowlandMaster = readLua('maps/mountain-social/mountain.lowlandmaster.server.lua');
lowlandMaster = lowlandMaster.replace(
  'task.wait(40) -- run last so old lowland layers can be cleaned deterministically',
  'root:SetAttribute("LowlandMasterAuthoritative",true)\ntask.wait(.35) -- authoritative lowland builds immediately after world terrain'
);
const lowlandRoute = readLua('maps/mountain-social/mountain.lowlandroute.server.lua');
const lowlandPolish = readLua('maps/mountain-social/mountain.lowlandpolish.server.lua');

const serverModules = [
  ['expedition','maps/mountain-social/mountain.expedition.server.lua'],
  ['upper','maps/mountain-social/mountain.upper.server.lua'],
  ['checkpoint','maps/mountain-social/systems/checkpoint.server.lua'],
  ['ambience','maps/mountain-social/systems/ambience.server.lua']
];
for (const [,file] of serverModules) if (!fs.existsSync(path.join(root,file))) throw new Error(`Missing Mountain runtime module: ${file}`);

const wrap = (name,src) => `\ntask.spawn(function()\n local ok,err=pcall(function()\n${src}\n end)\n if not ok then warn('[Mountain:${name}]',err) end\nend)`;
const lowlandWrapped = wrap('lowlandmaster',lowlandMaster);
const routeWrapped = wrap('lowlandroute',lowlandRoute);
const polishWrapped = wrap('lowlandpolish',lowlandPolish);
const wrapped = serverModules.map(([name,file]) => wrap(name,readLua(file))).join('\n');
const bundle = `${readLua('maps/mountain-social/mountain.world.server.lua')}\n${lowlandWrapped}\n${routeWrapped}\n${polishWrapped}\n${wrapped}\nworkspace:SetAttribute('ACC_MountainCoreBundle','v5.4-grounded-natural-route')`;

const clientFiles = ['maps/mountain-social/mountain.client.lua','maps/mountain-social/mountain.altitude.client.lua','maps/mountain-social/mountain.performance.client.lua'];
const client = clientFiles.filter(f=>fs.existsSync(path.join(root,f))).map(readLua).join('\n');

const qc = `task.delay(32,function()\n local r=workspace:FindFirstChild('ACC_MountainSocial')\n local cps=r and r:FindFirstChild('Checkpoints')\n local cp1=false\n if cps then for _,o in ipairs(cps:GetChildren()) do if o:GetAttribute('CheckpointIndex')==1 then cp1=true break end end end\n local ok=r~=nil\n  and r:GetAttribute('LowlandMasterAuthoritative')==true\n  and r:GetAttribute('LowlandMasterReady')==true\n  and r:GetAttribute('LowlandMasterVersion')=='5.2'\n  and r:GetAttribute('LowlandScope')=='SPAWN_TO_CP1_ONLY'\n  and (r:GetAttribute('LowlandHouseCount') or 0)>=8\n  and (r:GetAttribute('LowlandPaddyCount') or 0)>=10\n  and (r:GetAttribute('LowlandGroundedTreeCount') or 0)>=15\n  and (r:GetAttribute('LowlandUtilityPoleCount') or 0)>=5\n  and (r:GetAttribute('LowlandWarungCount') or 0)>=1\n  and r:GetAttribute('LowlandCP1Ready')==true\n  and r:GetAttribute('LowlandRouteReady')==true\n  and r:GetAttribute('LowlandRouteVersion')=='5.4'\n  and r:GetAttribute('RoadGroundedSubgrade')==true\n  and r:GetAttribute('VehicleRoadEndsBeforeTrail')==true\n  and r:GetAttribute('NaturalFootpathReady')==true\n  and (r:GetAttribute('LowlandGroundedRoadParts') or 0)>=150\n  and (r:GetAttribute('LowlandFootpathParts') or 0)>=120\n  and (r:GetAttribute('LowlandForestRampDetail') or 0)>0\n  and r:GetAttribute('LowlandPolishReady')==true\n  and r:GetAttribute('LowlandPolishVersion')=='5.3'\n  and (r:GetAttribute('LowlandTerraceDetailCount') or 0)>=40\n  and (r:GetAttribute('LowlandIrrigationCount') or 0)>0\n  and (r:GetAttribute('LowlandYardDetailCount') or 0)>0\n  and (r:GetAttribute('LowlandRoadsideDetailCount') or 0)>0\n  and (r:GetAttribute('LowlandFoothillDetailCount') or 0)>0\n  and (r:GetAttribute('LowlandCP1PolishCount') or 0)>=8\n  and workspace:GetAttribute('ACC_TimeCycle')=='v4.1-four-phase'\n  and cp1==true\n workspace:SetAttribute('ACC_MountainReady',ok)\n workspace:SetAttribute('ACC_MountainBuild','v5.4-grounded-natural-route')\n if r then r:SetAttribute('BuildVersion','5.4.0-grounded-natural-route') end\n if not ok then warn('[Mountain:QC] v5.4 grounded natural Spawn-to-CP1 gate failed') end\nend)`;

const xml = `<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External><Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties></Item><Item class="Lighting" referent="L"><Properties><float name="Brightness">2</float><double name="ClockTime">6.3</double><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties><Item class="Script" referent="B"><Properties><string name="Name">ACC_Mountain_World</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${bundle}]]></ProtectedString></Properties></Item><Item class="Script" referent="Q"><Properties><string name="Name">ACC_Mountain_QC</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${qc}]]></ProtectedString></Properties></Item></Item><Item class="StarterPlayer" referent="P"><Properties><string name="Name">StarterPlayer</string></Properties><Item class="StarterPlayerScripts" referent="PS"><Properties><string name="Name">StarterPlayerScripts</string></Properties><Item class="LocalScript" referent="C"><Properties><string name="Name">ACC_Mountain_Client</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${client}]]></ProtectedString></Properties></Item></Item></Item></roblox>`;
fs.writeFileSync(placePath,xml);
console.log('[Mountain] Injected ACC Mountain v5.4 grounded natural Spawn-to-CP1 route into',target.file,'bytes',Buffer.byteLength(xml));
