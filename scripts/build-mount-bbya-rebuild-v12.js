const fs = require('fs');
const path = require('path');

const root = process.cwd();
const registry = JSON.parse(fs.readFileSync(path.join(root,'maps/registry.json'),'utf8'));
const target = registry.maps?.['mount-bbya'];
if (!target) throw new Error('mount-bbya registry target missing');
if (String(target.universeId) !== '4187755690' || String(target.placeId) !== '11832985967') throw new Error('MOUNT BBYA target lock mismatch');
if (String(target.universeId) === '10744139279' || String(target.placeId) === '82661754996018') throw new Error('FORBIDDEN Mountain Social target');

const runtimePath='maps/mount-bbya/mount-bbya.rebuild-v1.1.server.lua';
const runtimeAbs=path.join(root,runtimePath);
if(!fs.existsSync(runtimeAbs)) throw new Error(`Runtime missing: ${runtimePath}`);
const world=fs.readFileSync(runtimeAbs,'utf8');
for(const marker of ['MOUNT_BBYA_REBUILD_V11','visual-lock-rebuild-v1.1','FOUNDATION_CARVE_SUBGRADE_TRAIL','MOUNT_BBYA_READY','MinimumCheckpointSpacing']){
 if(!world.includes(marker)) throw new Error(`Runtime marker missing: ${marker}`);
}
for(const forbidden of ['ACC_MountainSocial','10744139279','82661754996018']){
 if(world.includes(forbidden)) throw new Error(`Forbidden marker leaked into runtime: ${forbidden}`);
}

const cdata=s=>s.replaceAll(']]>',']]]]><![CDATA[>');
const serverItem=(ref,name,src)=>`<Item class="Script" referent="${ref}"><Properties><string name="Name">${name}</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(src)}]]></ProtectedString></Properties></Item>`;
const clientItem=(ref,name,src)=>`<Item class="LocalScript" referent="${ref}"><Properties><string name="Name">${name}</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(src)}]]></ProtectedString></Properties></Item>`;

// v1.2: NEVER disable CharacterAutoLoads. Mobile controls/camera must exist even while world is building.
const bootstrap=`
local Players=game:GetService('Players')
local Workspace=game:GetService('Workspace')
Players.CharacterAutoLoads=true
Workspace:SetAttribute('MOUNT_BBYA_GATE','BUILDING')
Workspace:SetAttribute('MOUNT_BBYA_BOOTSTRAP','mobile-control-hotfix-v1.2')
Workspace:SetAttribute('MOUNT_BBYA_CHARACTER_AUTOLOADS',true)
local SAFE_CF=CFrame.new(0,75,1650)
local base=Workspace:FindFirstChild('MOUNT_BBYA_EMERGENCY_BASE')
if not base then
 base=Instance.new('Part');base.Name='MOUNT_BBYA_EMERGENCY_BASE';base.Anchored=true;base.CanCollide=true;base.Size=Vector3.new(140,6,140);base.CFrame=CFrame.new(0,66,1650);base.Material=Enum.Material.Concrete;base.Color=Color3.fromRGB(88,91,88);base.Parent=Workspace
end
local safeSpawn=Workspace:FindFirstChild('MOUNT_BBYA_EMERGENCY_SPAWN')
if not safeSpawn then
 safeSpawn=Instance.new('SpawnLocation');safeSpawn.Name='MOUNT_BBYA_EMERGENCY_SPAWN';safeSpawn.Anchored=true;safeSpawn.CanCollide=true;safeSpawn.Neutral=true;safeSpawn.Duration=0;safeSpawn.Size=Vector3.new(18,1,18);safeSpawn.CFrame=CFrame.new(0,70,1650);safeSpawn.Transparency=.25;safeSpawn.Parent=Workspace
end
local function secure(plr,ch)
 local hrp=ch:FindFirstChild('HumanoidRootPart') or ch:WaitForChild('HumanoidRootPart',6)
 if not hrp then return end
 if Workspace:GetAttribute('MOUNT_BBYA_GATE')~='READY' then
  ch:PivotTo(SAFE_CF);hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero
 end
end
local function bind(plr)
 plr.RespawnLocation=safeSpawn
 plr.CharacterAdded:Connect(function(ch) task.spawn(secure,plr,ch) end)
 if plr.Character then task.spawn(secure,plr,plr.Character) else task.spawn(function() pcall(function() plr:LoadCharacter() end) end) end
end
for _,plr in ipairs(Players:GetPlayers()) do bind(plr) end
Players.PlayerAdded:Connect(bind)
Workspace:SetAttribute('MOUNT_BBYA_BOOTSTRAP_OK',true)
print('[MOUNT BBYA] v1.2 bootstrap ready; CharacterAutoLoads=true')
`;

const release=`
local Players=game:GetService('Players')
local Workspace=game:GetService('Workspace')
local deadline=os.clock()+90
local root,spawn
repeat
 root=Workspace:FindFirstChild('MOUNT_BBYA_REBUILD_V11');spawn=root and root:FindFirstChild('MountBBYA_Spawn')
 if root and spawn and root:GetAttribute('RuntimeState')=='READY' and Workspace:GetAttribute('MOUNT_BBYA_READY')==true then break end
 if os.clock()>deadline then
  Workspace:SetAttribute('MOUNT_BBYA_GATE','SAFE_PLAYABLE_TIMEOUT')
  warn('[MOUNT BBYA] v1.2 world timeout; player remains controllable on emergency spawn')
  return
 end
 task.wait(.25)
until false
Workspace:SetAttribute('MOUNT_BBYA_GATE','READY')
local function place(plr,ch)
 plr.RespawnLocation=spawn
 local hrp=ch and (ch:FindFirstChild('HumanoidRootPart') or ch:WaitForChild('HumanoidRootPart',6))
 if hrp then ch:PivotTo(spawn.CFrame+Vector3.new(0,5,0));hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero end
end
local function bindReady(plr)
 plr.RespawnLocation=spawn
 plr.CharacterAdded:Connect(function(ch) task.wait(.15);if Workspace:GetAttribute('MOUNT_BBYA_GATE')=='READY' then place(plr,ch) end end)
 if plr.Character then task.spawn(place,plr,plr.Character) else task.spawn(function() pcall(function() plr:LoadCharacter() end) end) end
end
for _,plr in ipairs(Players:GetPlayers()) do bindReady(plr) end
Players.PlayerAdded:Connect(bindReady)
task.delay(5,function()
 local s=Workspace:FindFirstChild('MOUNT_BBYA_EMERGENCY_SPAWN');if s then s:Destroy() end
 local b=Workspace:FindFirstChild('MOUNT_BBYA_EMERGENCY_BASE');if b then b:Destroy() end
end)
Workspace:SetAttribute('MOUNT_BBYA_RELEASE_OK',true)
print('[MOUNT BBYA] v1.2 release ready')
`;

const mobileCamera=`
local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local player=Players.LocalPlayer
local camera=workspace.CurrentCamera
local function attach(ch)
 local humanoid=ch:FindFirstChildOfClass('Humanoid') or ch:WaitForChild('Humanoid',8)
 if not humanoid then return end
 camera=workspace.CurrentCamera or camera
 if camera then camera.CameraType=Enum.CameraType.Custom;camera.CameraSubject=humanoid end
 pcall(function() player.CameraMode=Enum.CameraMode.Classic end)
 player:SetAttribute('MOUNT_BBYA_MOBILE_CAMERA_READY',true)
end
player.CharacterAdded:Connect(function(ch) task.wait(.15);attach(ch) end)
if player.Character then task.spawn(attach,player.Character) end
-- Recovery guard: if Roblox starts with a nil/fixed subject, restore standard character camera.
local elapsed=0
RunService.RenderStepped:Connect(function(dt)
 elapsed+=dt
 if elapsed<1 then return end
 elapsed=0
 local ch=player.Character;local humanoid=ch and ch:FindFirstChildOfClass('Humanoid');camera=workspace.CurrentCamera or camera
 if camera and humanoid and (camera.CameraSubject~=humanoid or camera.CameraType~=Enum.CameraType.Custom) then
  camera.CameraType=Enum.CameraType.Custom;camera.CameraSubject=humanoid
 end
end)
`;

const qc=`
local Workspace=game:GetService('Workspace')
task.delay(15,function()
 local r=Workspace:FindFirstChild('MOUNT_BBYA_REBUILD_V11')
 local structural=r~=nil and Workspace:GetAttribute('MOUNT_BBYA_READY')==true and r:GetAttribute('RuntimeState')=='READY'
 local controls=Workspace:GetAttribute('MOUNT_BBYA_CHARACTER_AUTOLOADS')==true and game:GetService('Players').CharacterAutoLoads==true
 Workspace:SetAttribute('MOUNT_BBYA_RUNTIME_QC',(structural and controls) and 'PASS_CANDIDATE_V12' or 'FAIL_V12')
 Workspace:SetAttribute('MOUNT_BBYA_BUILD_WRAPPER','mobile-control-hotfix-v1.2')
 if not structural then warn('[MOUNT BBYA] v1.2 structural runtime not ready') end
 if not controls then warn('[MOUNT BBYA] v1.2 CharacterAutoLoads guard failed') end
end)
`;

const workspaceXml=`<Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties><Item class="Part" referent="EB"><Properties><bool name="Anchored">true</bool><bool name="CanCollide">true</bool><CoordinateFrame name="CFrame"><X>0</X><Y>66</Y><Z>1650</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame><string name="Name">MOUNT_BBYA_EMERGENCY_BASE</string><Vector3 name="Size"><X>140</X><Y>6</Y><Z>140</Z></Vector3></Properties></Item><Item class="SpawnLocation" referent="ES"><Properties><bool name="Anchored">true</bool><bool name="CanCollide">true</bool><bool name="Enabled">true</bool><bool name="Neutral">true</bool><int name="Duration">0</int><CoordinateFrame name="CFrame"><X>0</X><Y>70</Y><Z>1650</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame><string name="Name">MOUNT_BBYA_EMERGENCY_SPAWN</string><Vector3 name="Size"><X>18</X><Y>1</Y><Z>18</Z></Vector3><float name="Transparency">0.25</float></Properties></Item></Item>`;
const scripts=[serverItem('BOOT','MOUNT_BBYA_V12_Bootstrap',bootstrap),serverItem('WORLD','MOUNT_BBYA_V12_World',world),serverItem('RELEASE','MOUNT_BBYA_V12_Release',release),serverItem('QC','MOUNT_BBYA_V12_QC',qc)].join('');
const starterPlayer=`<Item class="StarterPlayer" referent="SP"><Properties><string name="Name">StarterPlayer</string><float name="CameraMinZoomDistance">0.5</float><float name="CameraMaxZoomDistance">400</float></Properties><Item class="StarterPlayerScripts" referent="SPS"><Properties><string name="Name">StarterPlayerScripts</string></Properties>${clientItem('CAM','MOUNT_BBYA_V12_MobileCamera',mobileCamera)}</Item></Item>`;
const xml=`<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External>${workspaceXml}<Item class="Lighting" referent="L"><Properties><float name="Brightness">2.35</float><double name="ClockTime">7.15</double><bool name="GlobalShadows">true</bool><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties>${scripts}</Item>${starterPlayer}</roblox>`;
const out=path.join(root,target.file);fs.mkdirSync(path.dirname(out),{recursive:true});fs.writeFileSync(out,xml);
const bytes=fs.statSync(out).size;if(bytes<22000) throw new Error(`Generated place too small: ${bytes}`);
const check=fs.readFileSync(out,'utf8');
for(const marker of ['MOUNT_BBYA_V12_Bootstrap','MOUNT_BBYA_V12_World','MOUNT_BBYA_V12_Release','MOUNT_BBYA_V12_QC','MOUNT_BBYA_V12_MobileCamera','mobile-control-hotfix-v1.2','CharacterAutoLoads=true']) if(!check.includes(marker)) throw new Error(`RBXLX marker missing: ${marker}`);
if(check.includes("Players.CharacterAutoLoads=false")) throw new Error('v1.2 must never disable CharacterAutoLoads');
if(check.includes('ACC_MountainSocial')) throw new Error('Legacy Mountain Social marker found in generated place');
console.log(`[MOUNT BBYA] v1.2 RBXLX generated path=${target.file} bytes=${bytes}`);
