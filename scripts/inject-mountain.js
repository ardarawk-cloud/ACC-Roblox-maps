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

// v6.1 PHASE 1 CLEAN ROOM:
// Terrain master remains v6.0. Composition v6.1 rebuilds visuals only, with NO Terrain edits.
// Intentionally NO mountain.world, lowlandmaster, lowlandroute, lowlandpolish, expedition or upper scripts.
const phase1File = 'maps/mountain-social/mountain.phase1v6.server.lua';
const compositionFile = 'maps/mountain-social/mountain.phase1v61.visual.server.lua';
const checkpointFile = 'maps/mountain-social/systems/checkpoint.server.lua';
const ambienceFile = 'maps/mountain-social/systems/ambience.server.lua';
const perfFile = 'maps/mountain-social/mountain.performance.client.lua';
for (const file of [phase1File, compositionFile, checkpointFile, ambienceFile, perfFile]) {
  if (!fs.existsSync(path.join(root,file))) throw new Error(`Missing Mountain v6.1 runtime module: ${file}`);
}

const wrap = (name,src) => `\ntask.spawn(function()\n local ok,err=pcall(function()\n${src}\n end)\n if not ok then warn('[Mountain:${name}]',err) end\nend)`;
const phase1 = readLua(phase1File);
const composition = readLua(compositionFile);
const checkpoint = wrap('checkpoint', readLua(checkpointFile));
const ambience = wrap('ambience', readLua(ambienceFile));
const bundle = `${phase1}\n${composition}\n${checkpoint}\n${ambience}\nworkspace:SetAttribute('ACC_MountainCoreBundle','v6.1-phase1-composition')`;
const client = readLua(perfFile);

const qc = `task.delay(12,function()\n local r=workspace:FindFirstChild('ACC_MountainSocial')\n local cps=r and r:FindFirstChild('Checkpoints')\n local cp1=false\n if cps then for _,o in ipairs(cps:GetChildren()) do if o:GetAttribute('CheckpointIndex')==1 then cp1=true break end end end\n local ok=r~=nil\n  and r:GetAttribute('RebuildGeneration')=='6.0'\n  and r:GetAttribute('Phase1Scope')=='SPAWN_TO_CP1_ONLY'\n  and r:GetAttribute('Phase1Ready')==true\n  and r:GetAttribute('TerrainFrozen')==true\n  and r:GetAttribute('TerrainArchitecture')=='TERRAIN_FIRST_SINGLE_SOURCE'\n  and r:GetAttribute('LegacyGeometryLoaded')==false\n  and r:GetAttribute('RoadTerrainNative')==true\n  and r:GetAttribute('VehicleRoadEndsBeforeTrail')==true\n  and r:GetAttribute('TrailBranchesFromRoad')==true\n  and (r:GetAttribute('RoadSampleCount') or 0)>=10\n  and (r:GetAttribute('RoadGapCount') or 99)==0\n  and (r:GetAttribute('FloatingPoleCount') or 99)==0\n  and (r:GetAttribute('FloatingTreeCount') or 99)==0\n  and (r:GetAttribute('HouseTerrainConflictCount') or 99)==0\n  and r:GetAttribute('CompositionPassVersion')=='6.1'\n  and r:GetAttribute('CompositionScope')=='SPAWN_TO_CP1_ONLY'\n  and r:GetAttribute('Phase1VisualReady')==true\n  and r:GetAttribute('SpawnFraming')=='DENSE_VILLAGE_ROAD'\n  and (r:GetAttribute('VillageHouseCount') or 0)>=10\n  and (r:GetAttribute('CloseRiceDetailCount') or 0)>=500\n  and (r:GetAttribute('VillageFenceDetailCount') or 0)>=20\n  and (r:GetAttribute('RoadsideDetailCount') or 0)>=100\n  and (r:GetAttribute('CompositionTreeCount') or 0)>=24\n  and (r:GetAttribute('CompositionTrailDetailCount') or 0)>=20\n  and cp1==true\n  and workspace:GetAttribute('ACC_TimeCycle')=='v4.1-four-phase'\n workspace:SetAttribute('ACC_MountainReady',ok)\n workspace:SetAttribute('ACC_MountainBuild','v6.1-phase1-composition')\n if not ok then warn('[Mountain:QC] v6.1 Phase1 composition gate failed') end\nend)`;

const xml = `<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External><Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties></Item><Item class="Lighting" referent="L"><Properties><float name="Brightness">2</float><double name="ClockTime">6.3</double><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties><Item class="Script" referent="B"><Properties><string name="Name">ACC_Mountain_V61_Phase1</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${bundle}]]></ProtectedString></Properties></Item><Item class="Script" referent="Q"><Properties><string name="Name">ACC_Mountain_V61_QC</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${qc}]]></ProtectedString></Properties></Item></Item><Item class="StarterPlayer" referent="P"><Properties><string name="Name">StarterPlayer</string></Properties><Item class="StarterPlayerScripts" referent="PS"><Properties><string name="Name">StarterPlayerScripts</string></Properties><Item class="LocalScript" referent="C"><Properties><string name="Name">ACC_Mountain_Performance</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${client}]]></ProtectedString></Properties></Item></Item></Item></roblox>`;
fs.writeFileSync(placePath,xml);
console.log('[Mountain] Injected CLEAN v6.1 Phase1 composition rebuild into',target.file,'bytes',Buffer.byteLength(xml));
