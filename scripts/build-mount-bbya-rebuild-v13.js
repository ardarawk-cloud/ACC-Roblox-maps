const fs=require('fs');
const path=require('path');
const root=process.cwd();
const registry=JSON.parse(fs.readFileSync(path.join(root,'maps/registry.json'),'utf8'));
const target=registry.maps?.['mount-bbya'];
if(!target) throw new Error('mount-bbya registry target missing');
if(String(target.universeId)!=='4187755690'||String(target.placeId)!=='11832985967') throw new Error('MOUNT BBYA target lock mismatch');
if(String(target.universeId)==='10744139279'||String(target.placeId)==='82661754996018') throw new Error('FORBIDDEN Mountain Social target');
const runtimePath='maps/mount-bbya/mount-bbya.rebuild-v1.3.server.lua';
const world=fs.readFileSync(path.join(root,runtimePath),'utf8');
for(const m of ['MOUNT_BBYA_REBUILD_V13','runtime-rebuild-v1.3','LOWLAND_FIRST_UPPER_ASYNC','MOUNT_BBYA_LOWLAND_READY','MOUNT_BBYA_FULL_READY']) if(!world.includes(m)) throw new Error(`runtime marker missing ${m}`);
for(const f of ['ACC_MountainSocial','10744139279','82661754996018']) if(world.includes(f)) throw new Error(`forbidden runtime marker ${f}`);
const cdata=s=>s.replaceAll(']]>',']]]]><![CDATA[>');
const server=(ref,name,src)=>`<Item class="Script" referent="${ref}"><Properties><string name="Name">${name}</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(src)}]]></ProtectedString></Properties></Item>`;
const client=(ref,name,src)=>`<Item class="LocalScript" referent="${ref}"><Properties><string name="Name">${name}</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(src)}]]></ProtectedString></Properties></Item>`;

const bootstrap=`
local Players=game:GetService('Players')
local Workspace=game:GetService('Workspace')
Players.CharacterAutoLoads=true
Workspace:SetAttribute('MOUNT_BBYA_GATE','LOWLAND_BUILDING')
Workspace:SetAttribute('MOUNT_BBYA_WRAPPER','runtime-rebuild-v1.3')
local stage=Workspace:FindFirstChild('MOUNT_BBYA_STAGING')
if not stage then stage=Instance.new('SpawnLocation');stage.Name='MOUNT_BBYA_STAGING';stage.Anchored=true;stage.CanCollide=true;stage.Neutral=true;stage.Duration=0;stage.Size=Vector3.new(34,1,34);stage.CFrame=CFrame.new(0,31,1690);stage.Material=Enum.Material.Concrete;stage.Color=Color3.fromRGB(105,105,98);stage.Parent=Workspace end
local function bind(plr)
 plr.RespawnLocation=stage
 if not plr.Character then task.spawn(function() pcall(function() plr:LoadCharacter() end) end) end
end
for _,p in ipairs(Players:GetPlayers()) do bind(p) end
Players.PlayerAdded:Connect(bind)
Workspace:SetAttribute('MOUNT_BBYA_BOOTSTRAP_OK',true)
`;

const release=`
local Players=game:GetService('Players')
local Workspace=game:GetService('Workspace')
local deadline=os.clock()+45
local r,spawn
repeat
 r=Workspace:FindFirstChild('MOUNT_BBYA_REBUILD_V13');spawn=r and r:FindFirstChild('MountBBYA_Spawn')
 if r and spawn and r:GetAttribute('LowlandReady')==true and Workspace:GetAttribute('MOUNT_BBYA_LOWLAND_READY')==true then break end
 if os.clock()>deadline then Workspace:SetAttribute('MOUNT_BBYA_GATE','STAGING_TIMEOUT');warn('[MOUNT BBYA] v1.3 lowland timeout; keeping controllable staging spawn');return end
 task.wait(.2)
until false
Workspace:SetAttribute('MOUNT_BBYA_GATE','PLAYABLE_LOWLAND')
local function place(plr,ch)
 plr.RespawnLocation=spawn
 local hrp=ch and (ch:FindFirstChild('HumanoidRootPart') or ch:WaitForChild('HumanoidRootPart',6))
 if hrp then ch:PivotTo(spawn.CFrame+Vector3.new(0,5,0));hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero end
end
local function ready(plr)
 plr.RespawnLocation=spawn
 plr.CharacterAdded:Connect(function(ch) task.wait(.15);if Workspace:GetAttribute('MOUNT_BBYA_GATE')~='LOWLAND_BUILDING' then place(plr,ch) end end)
 if plr.Character then task.spawn(place,plr,plr.Character) else task.spawn(function() pcall(function() plr:LoadCharacter() end) end) end
end
for _,p in ipairs(Players:GetPlayers()) do ready(p) end
Players.PlayerAdded:Connect(ready)
task.delay(4,function() local s=Workspace:FindFirstChild('MOUNT_BBYA_STAGING');if s then s:Destroy() end end)
Workspace:SetAttribute('MOUNT_BBYA_RELEASE_OK',true)
`;

const mobile=`
local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local player=Players.LocalPlayer
local gui=Instance.new('ScreenGui');gui.Name='MOUNT_BBYA_LoadStatus';gui.ResetOnSpawn=false;gui.IgnoreGuiInset=false;gui.Parent=player:WaitForChild('PlayerGui')
local label=Instance.new('TextLabel');label.AnchorPoint=Vector2.new(.5,0);label.Position=UDim2.fromScale(.5,.02);label.Size=UDim2.fromOffset(310,36);label.BackgroundTransparency=.25;label.BackgroundColor3=Color3.fromRGB(22,27,23);label.TextColor3=Color3.fromRGB(240,240,234);label.Font=Enum.Font.GothamBold;label.TextScaled=true;label.Text='MOUNT BBYA • menyiapkan jalur...';label.Parent=gui
local function attach(ch)
 local hum=ch:FindFirstChildOfClass('Humanoid') or ch:WaitForChild('Humanoid',8)
 local cam=workspace.CurrentCamera
 if hum and cam then cam.CameraType=Enum.CameraType.Custom;cam.CameraSubject=hum end
 pcall(function() player.CameraMode=Enum.CameraMode.Classic end)
end
player.CharacterAdded:Connect(function(ch) task.wait(.15);attach(ch) end)
if player.Character then task.spawn(attach,player.Character) end
local elapsed=0
RunService.RenderStepped:Connect(function(dt)
 elapsed+=dt;if elapsed<1 then return end;elapsed=0
 local ch=player.Character;local hum=ch and ch:FindFirstChildOfClass('Humanoid');local cam=workspace.CurrentCamera
 if hum and cam and (cam.CameraType~=Enum.CameraType.Custom or cam.CameraSubject~=hum) then cam.CameraType=Enum.CameraType.Custom;cam.CameraSubject=hum end
 if workspace:GetAttribute('MOUNT_BBYA_FULL_READY')==true then gui.Enabled=false
 elseif workspace:GetAttribute('MOUNT_BBYA_LOWLAND_READY')==true then label.Text='MOUNT BBYA • jalur atas sedang dibangun...' else label.Text='MOUNT BBYA • menyiapkan desa...' end
end)
`;

const qc=`
task.delay(18,function()
 local W=game:GetService('Workspace');local r=W:FindFirstChild('MOUNT_BBYA_REBUILD_V13')
 local low=r and r:GetAttribute('LowlandReady')==true and W:GetAttribute('MOUNT_BBYA_LOWLAND_READY')==true
 local controls=game:GetService('Players').CharacterAutoLoads==true
 W:SetAttribute('MOUNT_BBYA_RUNTIME_QC',(low and controls) and 'LOWLAND_PLAYABLE_PASS' or 'LOWLAND_FAIL')
end)
`;

const workspace=`<Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties><Item class="SpawnLocation" referent="ST"><Properties><bool name="Anchored">true</bool><bool name="CanCollide">true</bool><bool name="Enabled">true</bool><bool name="Neutral">true</bool><int name="Duration">0</int><CoordinateFrame name="CFrame"><X>0</X><Y>31</Y><Z>1690</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame><string name="Name">MOUNT_BBYA_STAGING</string><Vector3 name="Size"><X>34</X><Y>1</Y><Z>34</Z></Vector3></Properties></Item></Item>`;
const scripts=[server('B','MOUNT_BBYA_V13_Bootstrap',bootstrap),server('WORLD','MOUNT_BBYA_V13_World',world),server('R','MOUNT_BBYA_V13_Release',release),server('Q','MOUNT_BBYA_V13_QC',qc)].join('');
const starter=`<Item class="StarterPlayer" referent="SP"><Properties><string name="Name">StarterPlayer</string><float name="CameraMinZoomDistance">0.5</float><float name="CameraMaxZoomDistance">400</float></Properties><Item class="StarterPlayerScripts" referent="SPS"><Properties><string name="Name">StarterPlayerScripts</string></Properties>${client('CAM','MOUNT_BBYA_V13_MobileClient',mobile)}</Item></Item>`;
const xml=`<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External>${workspace}<Item class="Lighting" referent="L"><Properties><float name="Brightness">2.35</float><double name="ClockTime">7.1</double><bool name="GlobalShadows">true</bool><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties>${scripts}</Item>${starter}</roblox>`;
const out=path.join(root,target.file);fs.mkdirSync(path.dirname(out),{recursive:true});fs.writeFileSync(out,xml);
const bytes=fs.statSync(out).size;if(bytes<26000) throw new Error(`generated place too small ${bytes}`);
const check=fs.readFileSync(out,'utf8');
for(const m of ['MOUNT_BBYA_V13_Bootstrap','MOUNT_BBYA_V13_World','MOUNT_BBYA_V13_Release','MOUNT_BBYA_V13_MobileClient','runtime-rebuild-v1.3','LOWLAND_FIRST_UPPER_ASYNC']) if(!check.includes(m)) throw new Error(`RBXLX marker missing ${m}`);
if(check.includes('ACC_MountainSocial')) throw new Error('legacy Mountain Social marker leaked');
console.log(`[MOUNT BBYA] v1.3 built ${target.file} bytes=${bytes}`);
