const fs = require('fs');
const path = require('path');

const root = process.cwd();
const registry = JSON.parse(fs.readFileSync(path.join(root, 'maps/registry.json'), 'utf8'));
const target = registry.maps?.['mount-bbya'];
if (!target) throw new Error('mount-bbya registry target missing');
if (String(target.universeId) !== '4187755690' || String(target.placeId) !== '11832985967') {
  throw new Error('MOUNT BBYA target lock mismatch. Refusing build.');
}
if (target.file !== 'maps/mount-bbya/place.rbxlx') throw new Error(`Unexpected MOUNT BBYA place path: ${target.file}`);

const sourcePath = path.join(root, 'maps/mount-bbya/mount-bbya.phase1v67.environment.server.lua');
const configPath = path.join(root, 'maps/mount-bbya/mount-bbya.config.json');
if (!fs.existsSync(sourcePath)) throw new Error('v7.0 world authority source missing');
if (!fs.existsSync(configPath)) throw new Error('v7.0 config missing');

const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
if (config.sourceVersion !== '7.0.0-full-map-reset') throw new Error(`Unexpected source version ${config.sourceVersion}`);
if (config.phase?.scope !== 'FULL_MAP_SPAWN_TO_CP20' || config.phase?.checkpointCount !== 20) {
  throw new Error('v7.0 full-map scope lock mismatch');
}
if (String(config.publishTarget?.universeId) !== '4187755690' || String(config.publishTarget?.placeId) !== '11832985967') {
  throw new Error('v7.0 config publish target mismatch');
}

const escapeCdata = s => s.replaceAll(']]>', ']]]]><![CDATA[>');
let world = fs.readFileSync(sourcePath, 'utf8');

// Lighting.Technology is configured in the RBXLX Lighting object below. It is not
// safe to assign from a runtime Script, so neutralize only that runtime write.
world = world.replace(
  'Lighting.Technology=Enum.Technology.Future;Lighting.GlobalShadows=true;',
  "-- Technology=Future is serialized in place.rbxlx by inject-mount-bbya-v70.js\nLighting.GlobalShadows=true;"
);
if (world.includes('Lighting.Technology=Enum.Technology.Future')) {
  throw new Error('Runtime Lighting.Technology assignment was not neutralized');
}
world = escapeCdata(world);

const bootstrap = escapeCdata(`
local Players=game:GetService('Players')
Players.CharacterAutoLoads=false
workspace:SetAttribute('MOUNT_BBYA_V70_GATE','BUILDING')
workspace:SetAttribute('MOUNT_BBYA_V70_BOOTSTRAP',true)
local SAFE_CF=CFrame.new(0,125,1750)

local function holdCharacter(char)
 local hrp=char:FindFirstChild('HumanoidRootPart') or char:WaitForChild('HumanoidRootPart',5)
 if not hrp then return end
 if workspace:GetAttribute('MOUNT_BBYA_V70_GATE')=='BUILDING' then
  char:PivotTo(SAFE_CF)
  hrp.AssemblyLinearVelocity=Vector3.zero
  hrp.AssemblyAngularVelocity=Vector3.zero
  hrp.Anchored=true
 end
end

local function bind(player)
 player.CharacterAdded:Connect(function(char) task.spawn(holdCharacter,char) end)
 if player.Character then task.spawn(holdCharacter,player.Character) end
end
for _,player in ipairs(Players:GetPlayers()) do bind(player) end
Players.PlayerAdded:Connect(bind)
print('[MOUNT BBYA] v7.0 bootstrap gate active')
`);

const release = escapeCdata(`
local Players=game:GetService('Players')
local deadline=os.clock()+120
local root,spawn
repeat
 root=workspace:FindFirstChild('MOUNT_BBYA_WORLD')
 spawn=root and root:FindFirstChild('Village') and root.Village:FindFirstChild('MOUNT_BBYA_SPAWN')
 if root and spawn and root:GetAttribute('BuildComplete')==true then break end
 if os.clock()>deadline then
  workspace:SetAttribute('MOUNT_BBYA_V70_GATE','SAFE_HOLD_TIMEOUT')
  warn('[MOUNT BBYA] v7.0 world build timeout; emergency hold retained')
  return
 end
 task.wait(.25)
until false

workspace:SetAttribute('MOUNT_BBYA_V70_GATE','READY')
Players.CharacterAutoLoads=true
local function releaseCharacter(char)
 local hrp=char:FindFirstChild('HumanoidRootPart') or char:WaitForChild('HumanoidRootPart',5)
 if not hrp then return end
 hrp.Anchored=false
 char:PivotTo(spawn.CFrame+Vector3.new(0,5,0))
 hrp.AssemblyLinearVelocity=Vector3.zero
 hrp.AssemblyAngularVelocity=Vector3.zero
end
for _,player in ipairs(Players:GetPlayers()) do
 if player.Character then releaseCharacter(player.Character) else task.spawn(function() pcall(function() player:LoadCharacter() end) end) end
end
task.delay(5,function()
 local s=workspace:FindFirstChild('MOUNT_BBYA_EMERGENCY_SPAWN');if s then s:Destroy() end
 local b=workspace:FindFirstChild('MOUNT_BBYA_EMERGENCY_BASE');if b then b:Destroy() end
end)
workspace:SetAttribute('MOUNT_BBYA_V70_RELEASED',true)
print('[MOUNT BBYA] v7.0 players released to new full map')
`);

const qc = escapeCdata(`
task.delay(25,function()
 local root=workspace:FindFirstChild('MOUNT_BBYA_WORLD')
 local cps=workspace:FindFirstChild('Checkpoints')
 local summit=root and root:FindFirstChild('Summit')
 local village=root and root:FindFirstChild('Village')
 local ok=root~=nil
  and root:GetAttribute('Version')=='7.0.0-full-map-reset'
  and root:GetAttribute('Architecture')=='VISUALIZER_20CP_WITA'
  and root:GetAttribute('BuildComplete')==true
  and root:GetAttribute('CheckpointCount')==20
  and root:GetAttribute('LocationCount')==21
  and root:GetAttribute('SummitMDPL')==3142
  and root:GetAttribute('WITARealtime')==true
  and root:GetAttribute('LakeCheckpoint')==15
  and cps~=nil and cps:FindFirstChild('SpawnDesa')~=nil and cps:FindFirstChild('CP20')~=nil
  and summit~=nil and summit:FindFirstChild('SummitPhotoSpot_3142MDPL')~=nil
  and village~=nil and village:FindFirstChild('MOUNT_BBYA_SPAWN')~=nil
  and workspace:GetAttribute('MOUNT_BBYA_V70_GATE')=='READY'
 workspace:SetAttribute('MOUNT_BBYA_V70_RUNTIME_QC',ok)
 workspace:SetAttribute('MOUNT_BBYA_BUILD','v7.0.0-full-map-reset')
 if ok then print('[MOUNT BBYA] v7.0 runtime structural QC PASS') else warn('[MOUNT BBYA] v7.0 runtime structural QC FAIL') end
end)
`);

const scriptItem = (ref,name,src) => `<Item class="Script" referent="${ref}"><Properties><string name="Name">${name}</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${src}]]></ProtectedString></Properties></Item>`;

const workspaceXml = `<Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties>
<Item class="Part" referent="EB"><Properties><bool name="Anchored">true</bool><bool name="CanCollide">true</bool><CoordinateFrame name="CFrame"><X>0</X><Y>120</Y><Z>1750</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame><string name="Name">MOUNT_BBYA_EMERGENCY_BASE</string><Vector3 name="Size"><X>180</X><Y>8</Y><Z>180</Z></Vector3></Properties></Item>
<Item class="SpawnLocation" referent="ES"><Properties><bool name="Anchored">true</bool><bool name="CanCollide">true</bool><bool name="Enabled">true</bool><CoordinateFrame name="CFrame"><X>0</X><Y>125</Y><Z>1750</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame><int name="Duration">0</int><string name="Name">MOUNT_BBYA_EMERGENCY_SPAWN</string><bool name="Neutral">true</bool><Vector3 name="Size"><X>16</X><Y>1</Y><Z>16</Z></Vector3></Properties></Item>
</Item>`;

const scripts = [
  scriptItem('BOOT','MOUNT_BBYA_V70_Bootstrap',bootstrap),
  scriptItem('WORLD','MOUNT_BBYA_V70_FullMapAuthority',world),
  scriptItem('RELEASE','MOUNT_BBYA_V70_Release',release),
  scriptItem('QC','MOUNT_BBYA_V70_QC',qc),
].join('');

const xml = `<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External>${workspaceXml}<Item class="Lighting" referent="L"><Properties><string name="Name">Lighting</string><float name="Brightness">2.2</float><double name="ClockTime">12</double><bool name="GlobalShadows">true</bool><token name="Technology">4</token></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties>${scripts}</Item></roblox>`;

const outPath = path.join(root,target.file);
fs.mkdirSync(path.dirname(outPath),{recursive:true});
fs.writeFileSync(outPath,xml);
console.log('[MOUNT BBYA] v7.0 RBXLX built',target.file,'bytes',Buffer.byteLength(xml));
