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

// v6.2 PHASE 1 CLEAN ROOM + SPAWN SAFETY HOTFIX:
// A static bootstrap spawn/pad exists in the serialized place before any runtime terrain work.
// Character auto-loading is gated until Phase1 terrain + composition are complete.
const phase1File = 'maps/mountain-social/mountain.phase1v6.server.lua';
const compositionFile = 'maps/mountain-social/mountain.phase1v61.visual.server.lua';
const checkpointFile = 'maps/mountain-social/systems/checkpoint.server.lua';
const ambienceFile = 'maps/mountain-social/systems/ambience.server.lua';
const perfFile = 'maps/mountain-social/mountain.performance.client.lua';
for (const file of [phase1File, compositionFile, checkpointFile, ambienceFile, perfFile]) {
  if (!fs.existsSync(path.join(root,file))) throw new Error(`Missing Mountain v6.2 runtime module: ${file}`);
}

const wrap = (name,src) => `\ntask.spawn(function()\n local ok,err=pcall(function()\n${src}\n end)\n if not ok then warn('[Mountain:${name}]',err) end\nend)`;
const phase1 = readLua(phase1File);
const composition = readLua(compositionFile);
const checkpoint = wrap('checkpoint', readLua(checkpointFile));
const ambience = wrap('ambience', readLua(ambienceFile));
const client = readLua(perfFile);

const spawnBoot = `
local Players=game:GetService('Players')
Players.CharacterAutoLoads=false
workspace:SetAttribute('ACC_SpawnGate','BUILDING')
workspace:SetAttribute('ACC_SpawnSafetyVersion','v6.2-static-bootstrap')
`;

const spawnRelease = `
local function releaseMountainSpawn()
 local r=workspace:FindFirstChild('ACC_MountainSocial')
 local targetSpawn=r and r:FindFirstChild('MountainSpawn')
 if not targetSpawn then
  warn('[Mountain:SpawnSafety] runtime MountainSpawn missing; bootstrap retained')
  workspace:SetAttribute('ACC_SpawnGate','FAILED_NO_RUNTIME_SPAWN')
  return
 end
 local bootSpawn=workspace:FindFirstChild('ACC_BootstrapSpawn')
 if bootSpawn then bootSpawn:Destroy() end
 workspace:SetAttribute('ACC_SpawnGate','READY')
 workspace:SetAttribute('ACC_SpawnRescueActive',true)
 Players.CharacterAutoLoads=true
 for _,plr in ipairs(Players:GetPlayers()) do
  local ch=plr.Character
  if ch then
   ch:PivotTo(targetSpawn.CFrame+Vector3.new(0,5,0))
  else
   task.spawn(function() pcall(function() plr:LoadCharacter() end) end)
  end
 end
 task.delay(5,function()
  local pad=workspace:FindFirstChild('ACC_BootstrapPad')
  if pad then pad:Destroy() end
 end)
 task.spawn(function()
  while workspace:GetAttribute('ACC_SpawnRescueActive')==true do
   for _,plr in ipairs(Players:GetPlayers()) do
    local ch=plr.Character
    local hrp=ch and ch:FindFirstChild('HumanoidRootPart')
    if hrp and hrp.Position.Y < -25 then
     ch:PivotTo(targetSpawn.CFrame+Vector3.new(0,6,0))
     hrp.AssemblyLinearVelocity=Vector3.zero
     hrp.AssemblyAngularVelocity=Vector3.zero
    end
   end
   task.wait(.35)
  end
 end)
end
releaseMountainSpawn()
workspace:SetAttribute('ACC_MountainCoreBundle','v6.2-phase1-spawn-safety')
`;

const bundle = `${spawnBoot}\n${phase1}\n${composition}\n${checkpoint}\n${ambience}\n${spawnRelease}`;

const qc = `task.delay(14,function()\n local r=workspace:FindFirstChild('ACC_MountainSocial')\n local cps=r and r:FindFirstChild('Checkpoints')\n local cp1=false\n if cps then for _,o in ipairs(cps:GetChildren()) do if o:GetAttribute('CheckpointIndex')==1 then cp1=true break end end end\n local runtimeSpawn=r and r:FindFirstChild('MountainSpawn')\n local ok=r~=nil\n  and r:GetAttribute('RebuildGeneration')=='6.0'\n  and r:GetAttribute('Phase1Scope')=='SPAWN_TO_CP1_ONLY'\n  and r:GetAttribute('Phase1Ready')==true\n  and r:GetAttribute('TerrainFrozen')==true\n  and r:GetAttribute('TerrainArchitecture')=='TERRAIN_FIRST_SINGLE_SOURCE'\n  and r:GetAttribute('LegacyGeometryLoaded')==false\n  and r:GetAttribute('RoadTerrainNative')==true\n  and r:GetAttribute('VehicleRoadEndsBeforeTrail')==true\n  and r:GetAttribute('TrailBranchesFromRoad')==true\n  and (r:GetAttribute('RoadSampleCount') or 0)>=10\n  and (r:GetAttribute('RoadGapCount') or 99)==0\n  and (r:GetAttribute('FloatingPoleCount') or 99)==0\n  and (r:GetAttribute('FloatingTreeCount') or 99)==0\n  and (r:GetAttribute('HouseTerrainConflictCount') or 99)==0\n  and r:GetAttribute('CompositionPassVersion')=='6.1'\n  and r:GetAttribute('CompositionScope')=='SPAWN_TO_CP1_ONLY'\n  and r:GetAttribute('Phase1VisualReady')==true\n  and r:GetAttribute('SpawnFraming')=='DENSE_VILLAGE_ROAD'\n  and (r:GetAttribute('VillageHouseCount') or 0)>=10\n  and (r:GetAttribute('CloseRiceDetailCount') or 0)>=500\n  and (r:GetAttribute('VillageFenceDetailCount') or 0)>=20\n  and (r:GetAttribute('RoadsideDetailCount') or 0)>=100\n  and (r:GetAttribute('CompositionTreeCount') or 0)>=24\n  and (r:GetAttribute('CompositionTrailDetailCount') or 0)>=20\n  and cp1==true\n  and runtimeSpawn~=nil\n  and workspace:GetAttribute('ACC_SpawnGate')=='READY'\n  and workspace:GetAttribute('ACC_SpawnRescueActive')==true\n  and workspace:GetAttribute('ACC_TimeCycle')=='v4.1-four-phase'\n workspace:SetAttribute('ACC_MountainReady',ok)\n workspace:SetAttribute('ACC_MountainBuild','v6.2-phase1-spawn-safety')\n if not ok then warn('[Mountain:QC] v6.2 spawn-safety gate failed') end\nend)`;

const bootstrapWorkspace = `<Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties>
<Item class="Part" referent="BOOTPAD"><Properties><bool name="Anchored">true</bool><bool name="CanCollide">true</bool><CoordinateFrame name="CFrame"><X>0</X><Y>76</Y><Z>1060</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame><string name="Name">ACC_BootstrapPad</string><Vector3 name="Size"><X>160</X><Y>8</Y><Z>160</Z></Vector3><float name="Transparency">1</float></Properties></Item>
<Item class="SpawnLocation" referent="BOOTSPAWN"><Properties><bool name="Anchored">true</bool><bool name="CanCollide">true</bool><CoordinateFrame name="CFrame"><X>0</X><Y>81</Y><Z>1060</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame><int name="Duration">0</int><string name="Name">ACC_BootstrapSpawn</string><bool name="Neutral">true</bool><Vector3 name="Size"><X>12</X><Y>1</Y><Z>12</Z></Vector3><float name="Transparency">1</float></Properties></Item>
</Item>`;

const xml = `<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External>${bootstrapWorkspace}<Item class="Lighting" referent="L"><Properties><float name="Brightness">2</float><double name="ClockTime">6.3</double><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties><Item class="Script" referent="B"><Properties><string name="Name">ACC_Mountain_V62_Phase1</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${bundle}]]></ProtectedString></Properties></Item><Item class="Script" referent="Q"><Properties><string name="Name">ACC_Mountain_V62_QC</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${qc}]]></ProtectedString></Properties></Item></Item><Item class="StarterPlayer" referent="P"><Properties><string name="Name">StarterPlayer</string></Properties><Item class="StarterPlayerScripts" referent="PS"><Properties><string name="Name">StarterPlayerScripts</string></Properties><Item class="LocalScript" referent="C"><Properties><string name="Name">ACC_Mountain_Performance</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${client}]]></ProtectedString></Properties></Item></Item></Item></roblox>`;
fs.writeFileSync(placePath,xml);
console.log('[Mountain] Injected CLEAN v6.2 Phase1 spawn-safe rebuild into',target.file,'bytes',Buffer.byteLength(xml));
