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
if(world.includes('"Trail_%02d".format')) throw new Error('Known invalid Luau format expression detected');

const cdata=s=>s.replaceAll(']]>',']]]]><![CDATA[>');
const scriptItem=(ref,name,src)=>`<Item class="Script" referent="${ref}"><Properties><string name="Name">${name}</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(src)}]]></ProtectedString></Properties></Item>`;

const bootstrap=`
local Players=game:GetService('Players')
local Workspace=game:GetService('Workspace')
Players.CharacterAutoLoads=false
Workspace:SetAttribute('MOUNT_BBYA_GATE','BUILDING')
Workspace:SetAttribute('MOUNT_BBYA_BOOTSTRAP','rebuild-v1.1')
local SAFE_CF=CFrame.new(0,72,1650)
local base=Workspace:FindFirstChild('MOUNT_BBYA_EMERGENCY_BASE')
if not base then
 base=Instance.new('Part');base.Name='MOUNT_BBYA_EMERGENCY_BASE';base.Anchored=true;base.CanCollide=true;base.Size=Vector3.new(120,6,120);base.CFrame=CFrame.new(0,66,1650);base.Material=Enum.Material.Concrete;base.Color=Color3.fromRGB(88,91,88);base.Parent=Workspace
end
local function hold(ch)
 local hrp=ch:FindFirstChild('HumanoidRootPart') or ch:WaitForChild('HumanoidRootPart',4)
 if hrp and Workspace:GetAttribute('MOUNT_BBYA_GATE')=='BUILDING' then ch:PivotTo(SAFE_CF);hrp.Anchored=true;hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero end
end
local function bind(plr) plr.CharacterAdded:Connect(function(ch) task.spawn(hold,ch) end);if plr.Character then task.spawn(hold,plr.Character) end end
for _,p in ipairs(Players:GetPlayers()) do bind(p) end
Players.PlayerAdded:Connect(bind)
Workspace:SetAttribute('MOUNT_BBYA_BOOTSTRAP_OK',true)
print('[MOUNT BBYA] v1.1 bootstrap ready')
`;

const release=`
local Players=game:GetService('Players')
local Workspace=game:GetService('Workspace')
local deadline=os.clock()+90
local root,spawn
repeat
 root=Workspace:FindFirstChild('MOUNT_BBYA_REBUILD_V11');spawn=root and root:FindFirstChild('MountBBYA_Spawn')
 if root and spawn and root:GetAttribute('RuntimeState')=='READY' and Workspace:GetAttribute('MOUNT_BBYA_READY')==true then break end
 if os.clock()>deadline then Workspace:SetAttribute('MOUNT_BBYA_GATE','SAFE_HOLD_TIMEOUT');warn('[MOUNT BBYA] release timeout');return end
 task.wait(.25)
until false
Workspace:SetAttribute('MOUNT_BBYA_GATE','READY');Players.CharacterAutoLoads=true
local function releasePlayer(plr)
 if not plr.Character then pcall(function() plr:LoadCharacter() end) end
 local ch=plr.Character or plr.CharacterAdded:Wait();local hrp=ch:FindFirstChild('HumanoidRootPart') or ch:WaitForChild('HumanoidRootPart',4)
 if hrp then hrp.Anchored=false;ch:PivotTo(spawn.CFrame+Vector3.new(0,5,0));hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero end
end
for _,plr in ipairs(Players:GetPlayers()) do task.spawn(releasePlayer,plr) end
task.delay(5,function() local e=Workspace:FindFirstChild('MOUNT_BBYA_EMERGENCY_BASE');if e then e:Destroy() end end)
Workspace:SetAttribute('MOUNT_BBYA_RELEASE_OK',true)
print('[MOUNT BBYA] v1.1 release ready')
`;

const qc=`
local Workspace=game:GetService('Workspace')
task.delay(12,function()
 local r=Workspace:FindFirstChild('MOUNT_BBYA_REBUILD_V11')
 local ok=r~=nil and Workspace:GetAttribute('MOUNT_BBYA_BOOTSTRAP_OK')==true and Workspace:GetAttribute('MOUNT_BBYA_READY')==true
  and r:GetAttribute('BuildVersion')=='visual-lock-rebuild-v1.1' and r:GetAttribute('ForbiddenProjectTouched')==false and r:GetAttribute('GroundedTrailArchitecture')==true
  and (r:GetAttribute('RouteStuds') or 0)>6500 and (r:GetAttribute('TrailSegmentCount') or 0)>=41 and r:GetAttribute('CheckpointCount')==4
  and (r:GetAttribute('MinimumCheckpointSpacing') or 0)>600 and r:GetAttribute('FullRouteZones')==11 and r:GetAttribute('VillageReady')==true
  and r:GetAttribute('BasecampReady')==true and r:GetAttribute('ForestReady')==true and r:GetAttribute('ValleyReady')==true and r:GetAttribute('CliffReady')==true
  and r:GetAttribute('HighCampReady')==true and r:GetAttribute('SummitReady')==true and Workspace:GetAttribute('MOUNT_BBYA_GATE')=='READY'
 Workspace:SetAttribute('MOUNT_BBYA_RUNTIME_QC',ok and 'PASS_CANDIDATE' or 'FAIL')
 if ok then print('[MOUNT BBYA] runtime structural QC PASS_CANDIDATE; physical visual QC required') else warn('[MOUNT BBYA] runtime structural QC FAIL') end
end)
`;

const workspaceXml=`<Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties><Item class="Part" referent="EB"><Properties><bool name="Anchored">true</bool><bool name="CanCollide">true</bool><CoordinateFrame name="CFrame"><X>0</X><Y>66</Y><Z>1650</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame><string name="Name">MOUNT_BBYA_EMERGENCY_BASE</string><Vector3 name="Size"><X>120</X><Y>6</Y><Z>120</Z></Vector3></Properties></Item></Item>`;
const scripts=[scriptItem('BOOT','MOUNT_BBYA_V11_Bootstrap',bootstrap),scriptItem('WORLD','MOUNT_BBYA_V11_World',world),scriptItem('RELEASE','MOUNT_BBYA_V11_Release',release),scriptItem('QC','MOUNT_BBYA_V11_QC',qc)].join('');
const xml=`<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External>${workspaceXml}<Item class="Lighting" referent="L"><Properties><float name="Brightness">2.35</float><double name="ClockTime">7.15</double><bool name="GlobalShadows">true</bool><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties>${scripts}</Item></roblox>`;
const out=path.join(root,target.file);fs.mkdirSync(path.dirname(out),{recursive:true});fs.writeFileSync(out,xml);
const bytes=fs.statSync(out).size;if(bytes<20000) throw new Error(`Generated place too small: ${bytes}`);
const check=fs.readFileSync(out,'utf8');
for(const marker of ['MOUNT_BBYA_V11_Bootstrap','MOUNT_BBYA_V11_World','MOUNT_BBYA_V11_Release','MOUNT_BBYA_V11_QC','visual-lock-rebuild-v1.1']) if(!check.includes(marker)) throw new Error(`RBXLX marker missing: ${marker}`);
if(check.includes('ACC_MountainSocial')) throw new Error('Legacy Mountain Social marker found in generated place');
console.log(`[MOUNT BBYA] v1.1 RBXLX generated path=${target.file} bytes=${bytes}`);
