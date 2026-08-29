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

// v6.3 PHASE 1 CLEAN ROOM + HARD ANTI-VOID BOOTSTRAP:
// The serialized place contains an invisible catch floor covering both Roblox default origin
// and the complete Phase1 footprint. The server-side watchdog starts before world generation.
const phase1File = 'maps/mountain-social/mountain.phase1v6.server.lua';
const compositionFile = 'maps/mountain-social/mountain.phase1v61.visual.server.lua';
const checkpointFile = 'maps/mountain-social/systems/checkpoint.server.lua';
const ambienceFile = 'maps/mountain-social/systems/ambience.server.lua';
const perfFile = 'maps/mountain-social/mountain.performance.client.lua';
for (const file of [phase1File, compositionFile, checkpointFile, ambienceFile, perfFile]) {
  if (!fs.existsSync(path.join(root,file))) throw new Error(`Missing Mountain v6.3 runtime module: ${file}`);
}

const phase1 = readLua(phase1File);
const composition = readLua(compositionFile);
const checkpoint = readLua(checkpointFile);
const ambience = readLua(ambienceFile);
const client = readLua(perfFile);

const spawnBoot = `
local Players=game:GetService('Players')
Players.CharacterAutoLoads=false
workspace:SetAttribute('ACC_SpawnGate','BUILDING')
workspace:SetAttribute('ACC_SpawnSafetyVersion','v6.3-hard-antivoid')
workspace:SetAttribute('ACC_SpawnRescueActive',true)
local BOOT_CF=CFrame.new(0,8,0)

local function holdCharacter(ch)
 if workspace:GetAttribute('ACC_SpawnGate')~='BUILDING' then return end
 local hrp=ch:FindFirstChild('HumanoidRootPart') or ch:WaitForChild('HumanoidRootPart',3)
 if not hrp then return end
 ch:PivotTo(BOOT_CF)
 hrp.AssemblyLinearVelocity=Vector3.zero
 hrp.AssemblyAngularVelocity=Vector3.zero
 hrp.Anchored=true
end

for _,plr in ipairs(Players:GetPlayers()) do
 if plr.Character then task.spawn(holdCharacter,plr.Character) end
 plr.CharacterAdded:Connect(function(ch) task.spawn(holdCharacter,ch) end)
end
Players.PlayerAdded:Connect(function(plr)
 plr.CharacterAdded:Connect(function(ch) task.spawn(holdCharacter,ch) end)
end)

-- Starts immediately, before Terrain:Clear or any expensive world generation.
task.spawn(function()
 while workspace:GetAttribute('ACC_SpawnRescueActive')==true do
  local gate=workspace:GetAttribute('ACC_SpawnGate')
  local r=workspace:FindFirstChild('ACC_MountainSocial')
  local finalSpawn=r and r:FindFirstChild('MountainSpawn')
  for _,plr in ipairs(Players:GetPlayers()) do
   local ch=plr.Character
   local hrp=ch and ch:FindFirstChild('HumanoidRootPart')
   if hrp then
    if gate=='BUILDING' then
     if hrp.Position.Y<2 or math.abs(hrp.Position.X)>1150 or hrp.Position.Z<-550 or hrp.Position.Z>1500 then
      ch:PivotTo(BOOT_CF);hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero;hrp.Anchored=true
     end
    elseif gate=='READY' and finalSpawn and hrp.Position.Y < -4 then
     hrp.Anchored=false
     ch:PivotTo(finalSpawn.CFrame+Vector3.new(0,6,0));hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero
    end
   end
  end
  task.wait(.15)
 end
end)
`;

const phaseWrapped = `
local phaseOk,phaseErr=pcall(function()
${phase1}
end)
workspace:SetAttribute('ACC_Phase1RuntimeOK',phaseOk)
if not phaseOk then warn('[Mountain:Phase1]',phaseErr) end
`;

const compositionWrapped = `
local compOk,compErr=pcall(function()
${composition}
end)
workspace:SetAttribute('ACC_CompositionRuntimeOK',compOk)
if not compOk then warn('[Mountain:Composition]',compErr) end
`;

const auxWrapped = `
task.spawn(function() local ok,err=pcall(function() ${checkpoint} end);if not ok then warn('[Mountain:checkpoint]',err) end end)
task.spawn(function() local ok,err=pcall(function() ${ambience} end);if not ok then warn('[Mountain:ambience]',err) end end)
`;

const spawnRelease = `
local function releaseMountainSpawn()
 local r=workspace:FindFirstChild('ACC_MountainSocial')
 local targetSpawn=r and r:FindFirstChild('MountainSpawn')
 if not targetSpawn then
  -- Never drop the player into void. Keep bootstrap hold if world creation failed.
  workspace:SetAttribute('ACC_SpawnGate','SAFE_HOLD_NO_RUNTIME_SPAWN')
  warn('[Mountain:SpawnSafety] runtime MountainSpawn missing; player retained on anti-void floor')
  return
 end
 workspace:SetAttribute('ACC_SpawnGate','READY')
 Players.CharacterAutoLoads=true
 for _,plr in ipairs(Players:GetPlayers()) do
  local ch=plr.Character
  if ch then
   local hrp=ch:FindFirstChild('HumanoidRootPart')
   if hrp then hrp.Anchored=false end
   ch:PivotTo(targetSpawn.CFrame+Vector3.new(0,6,0))
   if hrp then hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero end
  else
   task.spawn(function() pcall(function() plr:LoadCharacter() end) end)
  end
 end
 local bootSpawn=workspace:FindFirstChild('ACC_BootstrapSpawn')
 if bootSpawn then bootSpawn:Destroy() end
end
releaseMountainSpawn()
workspace:SetAttribute('ACC_MountainCoreBundle','v6.3-phase1-hard-antivoid')
`;

const bundle = `${spawnBoot}\n${phaseWrapped}\n${compositionWrapped}\n${auxWrapped}\n${spawnRelease}`;

const qc = `task.delay(14,function()\n local r=workspace:FindFirstChild('ACC_MountainSocial')\n local cps=r and r:FindFirstChild('Checkpoints')\n local cp1=false\n if cps then for _,o in ipairs(cps:GetChildren()) do if o:GetAttribute('CheckpointIndex')==1 then cp1=true break end end end\n local runtimeSpawn=r and r:FindFirstChild('MountainSpawn')\n local catch=workspace:FindFirstChild('ACC_VoidCatchFloor')\n local ok=r~=nil\n  and workspace:GetAttribute('ACC_Phase1RuntimeOK')==true\n  and workspace:GetAttribute('ACC_CompositionRuntimeOK')==true\n  and r:GetAttribute('RebuildGeneration')=='6.0'\n  and r:GetAttribute('Phase1Scope')=='SPAWN_TO_CP1_ONLY'\n  and r:GetAttribute('Phase1Ready')==true\n  and r:GetAttribute('TerrainFrozen')==true\n  and r:GetAttribute('TerrainArchitecture')=='TERRAIN_FIRST_SINGLE_SOURCE'\n  and r:GetAttribute('LegacyGeometryLoaded')==false\n  and r:GetAttribute('RoadTerrainNative')==true\n  and r:GetAttribute('VehicleRoadEndsBeforeTrail')==true\n  and r:GetAttribute('TrailBranchesFromRoad')==true\n  and (r:GetAttribute('RoadGapCount') or 99)==0\n  and (r:GetAttribute('FloatingPoleCount') or 99)==0\n  and (r:GetAttribute('FloatingTreeCount') or 99)==0\n  and (r:GetAttribute('HouseTerrainConflictCount') or 99)==0\n  and r:GetAttribute('CompositionPassVersion')=='6.1'\n  and r:GetAttribute('Phase1VisualReady')==true\n  and r:GetAttribute('SpawnFraming')=='DENSE_VILLAGE_ROAD'\n  and cp1==true\n  and runtimeSpawn~=nil\n  and catch~=nil and catch.CanCollide==true\n  and workspace:GetAttribute('ACC_SpawnGate')=='READY'\n  and workspace:GetAttribute('ACC_SpawnRescueActive')==true\n  and workspace:GetAttribute('ACC_TimeCycle')=='v4.1-four-phase'\n workspace:SetAttribute('ACC_MountainReady',ok)\n workspace:SetAttribute('ACC_MountainBuild','v6.3-phase1-hard-antivoid')\n if not ok then warn('[Mountain:QC] v6.3 hard anti-void gate failed') end\nend)`;

// Catch floor top is -4 studs and covers the complete Phase1 world plus Roblox default origin.
// It remains permanently under terrain as a hidden fail-safe and cannot affect normal walking at Y~10+.
const bootstrapWorkspace = `<Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties>
<Item class="Part" referent="VOIDCATCH"><Properties><bool name="Anchored">true</bool><bool name="CanCollide">true</bool><CoordinateFrame name="CFrame"><X>0</X><Y>-8</Y><Z>470</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame><string name="Name">ACC_VoidCatchFloor</string><Vector3 name="Size"><X>2400</X><Y>8</Y><Z>2200</Z></Vector3><float name="Transparency">1</float></Properties></Item>
<Item class="SpawnLocation" referent="BOOTSPAWN"><Properties><bool name="Anchored">true</bool><bool name="CanCollide">true</bool><bool name="Enabled">true</bool><CoordinateFrame name="CFrame"><X>0</X><Y>2</Y><Z>0</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame><int name="Duration">0</int><string name="Name">ACC_BootstrapSpawn</string><bool name="Neutral">true</bool><Vector3 name="Size"><X>20</X><Y>1</Y><Z>20</Z></Vector3><float name="Transparency">1</float></Properties></Item>
</Item>`;

const xml = `<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External>${bootstrapWorkspace}<Item class="Lighting" referent="L"><Properties><float name="Brightness">2</float><double name="ClockTime">6.3</double><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties><Item class="Script" referent="B"><Properties><string name="Name">ACC_Mountain_V63_Phase1</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${bundle}]]></ProtectedString></Properties></Item><Item class="Script" referent="Q"><Properties><string name="Name">ACC_Mountain_V63_QC</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${qc}]]></ProtectedString></Properties></Item></Item><Item class="StarterPlayer" referent="P"><Properties><string name="Name">StarterPlayer</string></Properties><Item class="StarterPlayerScripts" referent="PS"><Properties><string name="Name">StarterPlayerScripts</string></Properties><Item class="LocalScript" referent="C"><Properties><string name="Name">ACC_Mountain_Performance</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${client}]]></ProtectedString></Properties></Item></Item></Item></roblox>`;
fs.writeFileSync(placePath,xml);
console.log('[Mountain] Injected CLEAN v6.3 Phase1 hard anti-void rebuild into',target.file,'bytes',Buffer.byteLength(xml));
