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
const phase1File = 'maps/mountain-social/mountain.phase1v6.server.lua';
const compositionFile = 'maps/mountain-social/mountain.phase1v61.visual.server.lua';
const checkpointFile = 'maps/mountain-social/systems/checkpoint.server.lua';
const ambienceFile = 'maps/mountain-social/systems/ambience.server.lua';
const perfFile = 'maps/mountain-social/mountain.performance.client.lua';
for (const file of [phase1File, compositionFile, checkpointFile, ambienceFile, perfFile]) {
  if (!fs.existsSync(path.join(root,file))) throw new Error(`Missing Mountain v6.4 runtime module: ${file}`);
}

const phase1 = readLua(phase1File);
const composition = readLua(compositionFile);
const checkpoint = readLua(checkpointFile);
const ambience = readLua(ambienceFile);
const client = readLua(perfFile);

// IMPORTANT: every large runtime module is serialized as its OWN Script.
// This prevents a local/register/compile failure in one module from killing bootstrap + spawn safety.
const bootstrap = `
local Players=game:GetService('Players')
Players.CharacterAutoLoads=false
workspace:SetAttribute('ACC_SpawnGate','BUILDING')
workspace:SetAttribute('ACC_SpawnSafetyVersion','v6.4-independent-bootstrap')
workspace:SetAttribute('ACC_SpawnRescueActive',true)
local SAFE_CF=CFrame.new(0,50,0)

local emergency=workspace:FindFirstChild('ACC_EmergencyBaseplate')
if not emergency then
 emergency=Instance.new('Part')
 emergency.Name='ACC_EmergencyBaseplate';emergency.Anchored=true;emergency.CanCollide=true
 emergency.Size=Vector3.new(180,8,180);emergency.CFrame=CFrame.new(0,42,0)
 emergency.Material=Enum.Material.Concrete;emergency.Color=Color3.fromRGB(92,98,102);emergency.Parent=workspace
end

local function hold(ch)
 local hrp=ch:FindFirstChild('HumanoidRootPart') or ch:WaitForChild('HumanoidRootPart',4)
 if not hrp then return end
 if workspace:GetAttribute('ACC_SpawnGate')=='BUILDING' then
  ch:PivotTo(SAFE_CF);hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero;hrp.Anchored=true
 end
end
local function bind(plr)
 plr.CharacterAdded:Connect(function(ch) task.spawn(hold,ch) end)
 if plr.Character then task.spawn(hold,plr.Character) end
end
for _,plr in ipairs(Players:GetPlayers()) do bind(plr) end
Players.PlayerAdded:Connect(bind)

task.spawn(function()
 while workspace:GetAttribute('ACC_SpawnRescueActive')==true do
  local gate=workspace:GetAttribute('ACC_SpawnGate')
  local r=workspace:FindFirstChild('ACC_MountainSocial')
  local finalSpawn=r and r:FindFirstChild('MountainSpawn')
  for _,plr in ipairs(Players:GetPlayers()) do
   local ch=plr.Character;local hrp=ch and ch:FindFirstChild('HumanoidRootPart')
   if hrp then
    if gate=='BUILDING' then
     if hrp.Position.Y<38 or math.abs(hrp.Position.X)>120 or math.abs(hrp.Position.Z)>120 then
      ch:PivotTo(SAFE_CF);hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero;hrp.Anchored=true
     end
    elseif gate=='READY' and finalSpawn and hrp.Position.Y < -20 then
     hrp.Anchored=false;ch:PivotTo(finalSpawn.CFrame+Vector3.new(0,6,0));hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero
    end
   end
  end
  task.wait(.12)
 end
end)
workspace:SetAttribute('ACC_BootstrapRuntimeOK',true)
print('[ACC] v6.4 independent bootstrap ready')
`;

const compositionGate = composition;
const checkpointGate = `
local deadline=os.clock()+70
repeat
 local r=workspace:FindFirstChild('ACC_MountainSocial')
 if r and r:GetAttribute('Phase1VisualReady')==true then break end
 if os.clock()>deadline then error('checkpoint gate timeout') end
 task.wait(.25)
until false
${checkpoint}
`;

const release = `
local Players=game:GetService('Players')
local deadline=os.clock()+70
local r=nil
local targetSpawn=nil
repeat
 r=workspace:FindFirstChild('ACC_MountainSocial')
 targetSpawn=r and r:FindFirstChild('MountainSpawn')
 if r and targetSpawn and r:GetAttribute('Phase1Ready')==true and r:GetAttribute('Phase1VisualReady')==true then break end
 if os.clock()>deadline then
  workspace:SetAttribute('ACC_SpawnGate','SAFE_HOLD_WORLD_TIMEOUT')
  warn('[Mountain:Release] world readiness timeout; keeping player on emergency baseplate')
  return
 end
 task.wait(.2)
until false
workspace:SetAttribute('ACC_SpawnGate','READY')
Players.CharacterAutoLoads=true
local function placeCharacter(ch)
 local hrp=ch:FindFirstChild('HumanoidRootPart') or ch:WaitForChild('HumanoidRootPart',4)
 if not hrp then return end
 hrp.Anchored=false
 ch:PivotTo(targetSpawn.CFrame+Vector3.new(0,6,0));hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero
end
for _,plr in ipairs(Players:GetPlayers()) do
 if plr.Character then placeCharacter(plr.Character) else task.spawn(function() pcall(function() plr:LoadCharacter() end) end) end
end
task.delay(3,function()
 local s=workspace:FindFirstChild('ACC_EmergencySpawn');if s then s:Destroy() end
 local b=workspace:FindFirstChild('ACC_EmergencyBaseplate');if b then b:Destroy() end
end)
workspace:SetAttribute('ACC_MountainCoreBundle','v6.4-phase1-multiscript-runtime')
workspace:SetAttribute('ACC_ReleaseRuntimeOK',true)
print('[ACC] v6.4 release to final mountain spawn complete')
`;

const qc = `
task.delay(18,function()
 local r=workspace:FindFirstChild('ACC_MountainSocial')
 local cps=r and r:FindFirstChild('Checkpoints')
 local cp1=false
 if cps then for _,o in ipairs(cps:GetChildren()) do if o:GetAttribute('CheckpointIndex')==1 then cp1=true break end end end
 local runtimeSpawn=r and r:FindFirstChild('MountainSpawn')
 local ok=r~=nil
  and workspace:GetAttribute('ACC_BootstrapRuntimeOK')==true
  and workspace:GetAttribute('ACC_ReleaseRuntimeOK')==true
  and r:GetAttribute('RebuildGeneration')=='6.0'
  and r:GetAttribute('Phase1Scope')=='SPAWN_TO_CP1_ONLY'
  and r:GetAttribute('Phase1Ready')==true
  and r:GetAttribute('TerrainFrozen')==true
  and r:GetAttribute('TerrainArchitecture')=='TERRAIN_FIRST_SINGLE_SOURCE'
  and r:GetAttribute('LegacyGeometryLoaded')==false
  and r:GetAttribute('RoadTerrainNative')==true
  and r:GetAttribute('VehicleRoadEndsBeforeTrail')==true
  and r:GetAttribute('TrailBranchesFromRoad')==true
  and (r:GetAttribute('RoadGapCount') or 99)==0
  and r:GetAttribute('CompositionPassVersion')=='6.1'
  and r:GetAttribute('Phase1VisualReady')==true
  and r:GetAttribute('SpawnFraming')=='DENSE_VILLAGE_ROAD'
  and cp1==true and runtimeSpawn~=nil
  and workspace:GetAttribute('ACC_SpawnGate')=='READY'
  and workspace:GetAttribute('ACC_TimeCycle')=='v4.1-four-phase'
 workspace:SetAttribute('ACC_MountainReady',ok)
 workspace:SetAttribute('ACC_MountainBuild','v6.4-phase1-multiscript-runtime')
 if not ok then warn('[Mountain:QC] v6.4 multi-script runtime gate failed') end
end)
`;

const scriptItem=(referent,name,src)=>`<Item class="Script" referent="${referent}"><Properties><string name="Name">${name}</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${src}]]></ProtectedString></Properties></Item>`;

// Visible emergency platform is deliberate: if every runtime script fails, player still lands somewhere observable.
const workspaceXml = `<Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties>
<Item class="Part" referent="EMERGENCYBASE"><Properties><bool name="Anchored">true</bool><bool name="CanCollide">true</bool><CoordinateFrame name="CFrame"><X>0</X><Y>42</Y><Z>0</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame><string name="Name">ACC_EmergencyBaseplate</string><Vector3 name="Size"><X>180</X><Y>8</Y><Z>180</Z></Vector3><float name="Transparency">0</float></Properties></Item>
<Item class="SpawnLocation" referent="EMERGENCYSPAWN"><Properties><bool name="Anchored">true</bool><bool name="CanCollide">true</bool><bool name="Enabled">true</bool><CoordinateFrame name="CFrame"><X>0</X><Y>47</Y><Z>0</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame><int name="Duration">0</int><string name="Name">ACC_EmergencySpawn</string><bool name="Neutral">true</bool><Vector3 name="Size"><X>16</X><Y>1</Y><Z>16</Z></Vector3><float name="Transparency">0</float></Properties></Item>
</Item>`;

const serverScripts=[
 scriptItem('BOOT','ACC_Mountain_V64_Bootstrap',bootstrap),
 scriptItem('TERRAIN','ACC_Mountain_V64_Terrain',phase1),
 scriptItem('COMPOSE','ACC_Mountain_V64_Composition',compositionGate),
 scriptItem('AMBIENCE','ACC_Mountain_V64_Ambience',ambience),
 scriptItem('CHECKPOINT','ACC_Mountain_V64_Checkpoint',checkpointGate),
 scriptItem('RELEASE','ACC_Mountain_V64_Release',release),
 scriptItem('QC','ACC_Mountain_V64_QC',qc)
].join('');

const xml = `<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External>${workspaceXml}<Item class="Lighting" referent="L"><Properties><float name="Brightness">2</float><double name="ClockTime">6.3</double><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties>${serverScripts}</Item><Item class="StarterPlayer" referent="P"><Properties><string name="Name">StarterPlayer</string></Properties><Item class="StarterPlayerScripts" referent="PS"><Properties><string name="Name">StarterPlayerScripts</string></Properties><Item class="LocalScript" referent="C"><Properties><string name="Name">ACC_Mountain_Performance</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${client}]]></ProtectedString></Properties></Item></Item></Item></roblox>`;
fs.writeFileSync(placePath,xml);
console.log('[Mountain] Injected v6.4 MULTI-SCRIPT Phase1 runtime into',target.file,'bytes',Buffer.byteLength(xml));
