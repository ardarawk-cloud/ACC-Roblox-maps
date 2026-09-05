const fs=require('fs');
const path=require('path');

const root=process.cwd();
const mapId='mount-bbya';
const registry=JSON.parse(fs.readFileSync(path.join(root,'maps/registry.json'),'utf8'));
const target=registry.maps?.[mapId];
if(!target) throw new Error('Missing mount-bbya registry entry');
if(String(target.universeId)!=='4187755690'||String(target.placeId)!=='11832985967') throw new Error('MOUNT BBYA TARGET LOCK MISMATCH');
if(String(target.file)!=='maps/mount-bbya/place.rbxlx') throw new Error('MOUNT BBYA FILE PATH LOCK MISMATCH');

const files={
 environment:'maps/mount-bbya/mount-bbya.phase1v67.environment.server.lua',
 checkpoint:'maps/mount-bbya/systems/checkpoint.server.lua',
 ambience:'maps/mount-bbya/systems/ambience.server.lua',
 perf:'maps/mount-bbya/mountain.performance.client.lua'
};
for(const f of Object.values(files)) if(!fs.existsSync(path.join(root,f))) throw new Error('Missing Mount BBYA runtime authority: '+f);
const read=f=>fs.readFileSync(path.join(root,f),'utf8').replaceAll(']]>',']]]]><![CDATA[>');

const bootstrap=`local Players=game:GetService('Players')
Players.CharacterAutoLoads=false
workspace:SetAttribute('ACC_SpawnGate','BUILDING')
workspace:SetAttribute('ACC_MountBBYA_Target','4187755690/11832985967')
workspace:SetAttribute('ACC_MountBBYA_SourceMode','V67_RESEARCH_GROUNDED_SINGLE_ENVIRONMENT_AUTHORITY')
workspace:SetAttribute('ACC_SpawnSafetyVersion','mount-bbya-v6.7')
local safe=CFrame.new(0,50,0)
local base=workspace:FindFirstChild('ACC_EmergencyBaseplate')
if not base then base=Instance.new('Part');base.Name='ACC_EmergencyBaseplate';base.Anchored=true;base.CanCollide=true;base.Size=Vector3.new(180,8,180);base.CFrame=CFrame.new(0,42,0);base.Material=Enum.Material.Concrete;base.Parent=workspace end
local function hold(ch)local hrp=ch:FindFirstChild('HumanoidRootPart') or ch:WaitForChild('HumanoidRootPart',4);if hrp and workspace:GetAttribute('ACC_SpawnGate')=='BUILDING' then ch:PivotTo(safe);hrp.Anchored=true;hrp.AssemblyLinearVelocity=Vector3.zero end end
local function bind(p)p.CharacterAdded:Connect(function(c)task.spawn(hold,c)end);if p.Character then task.spawn(hold,p.Character) end end
for _,p in ipairs(Players:GetPlayers())do bind(p)end;Players.PlayerAdded:Connect(bind)
workspace:SetAttribute('ACC_BootstrapRuntimeOK',true)`;

const gate=(src,attr)=>`local deadline=os.clock()+90;repeat local r=workspace:FindFirstChild('ACC_MountainSocial');if r and r:GetAttribute('${attr}')==true then break end;if os.clock()>deadline then error('gate timeout: ${attr}')end;task.wait(.2)until false\n${src}`;
const checkpoint=gate(read(files.checkpoint),'EnvironmentResearchReady');

const release=`local Players=game:GetService('Players')
local deadline=os.clock()+100;local r;local spawn
repeat r=workspace:FindFirstChild('ACC_MountainSocial');spawn=r and r:FindFirstChild('MountainSpawn');if r and spawn and r:GetAttribute('EnvironmentResearchReady')==true and r:GetAttribute('Phase1Ready')==true and r:GetAttribute('Phase1VisualReady')==true and r:GetAttribute('MountBBYAPhase1PremiumReady')==true and r:GetAttribute('MountBBYASignFacingReady')==true then break end;if os.clock()>deadline then workspace:SetAttribute('ACC_SpawnGate','SAFE_HOLD_WORLD_TIMEOUT');warn('[MOUNT BBYA] v6.7 readiness timeout');return end;task.wait(.2) until false
workspace:SetAttribute('ACC_SpawnGate','READY');Players.CharacterAutoLoads=true
local function place(c)local hrp=c:FindFirstChild('HumanoidRootPart') or c:WaitForChild('HumanoidRootPart',4);if hrp then hrp.Anchored=false;c:PivotTo(spawn.CFrame+Vector3.new(0,6,0));hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero end end
for _,p in ipairs(Players:GetPlayers())do if p.Character then place(p.Character) else task.spawn(function()pcall(function()p:LoadCharacter()end)end) end end
task.delay(3,function()local b=workspace:FindFirstChild('ACC_EmergencyBaseplate');if b then b:Destroy()end;local s=workspace:FindFirstChild('ACC_EmergencySpawn');if s then s:Destroy()end end)
workspace:SetAttribute('ACC_ReleaseRuntimeOK',true);workspace:SetAttribute('ACC_MountainBuild','mount-bbya-v6.7-research-grounded')`;

const qc=`task.delay(20,function()
 local r=workspace:FindFirstChild('ACC_MountainSocial');local cps=r and r:FindFirstChild('Checkpoints');local cp1=false
 if cps then for _,o in ipairs(cps:GetChildren())do if o:GetAttribute('CheckpointIndex')==1 then cp1=true break end end end
 local ok=r~=nil and workspace:GetAttribute('ACC_BootstrapRuntimeOK')==true and workspace:GetAttribute('ACC_ReleaseRuntimeOK')==true and workspace:GetAttribute('ACC_SpawnGate')=='READY' and r:GetAttribute('Project')=='MOUNT BBYA' and r:GetAttribute('EnvironmentAuthority')=='V6.7_RESEARCH_GROUNDED_SINGLE_SOURCE' and r:GetAttribute('Phase1Scope')=='SPAWN_TO_CP1_ONLY' and r:GetAttribute('TerrainFrozen')==true and r:GetAttribute('EnvironmentResearchReady')==true and (r:GetAttribute('TrailRiseStuds') or 0)>=25 and (r:GetAttribute('VillageHouseCount') or 0)>=10 and (r:GetAttribute('GroundedTreeCount') or 0)>=25 and cp1==true
 workspace:SetAttribute('ACC_MountBBYA_Phase1QC',ok and 'PASS' or 'FAIL');workspace:SetAttribute('ACC_MountainReady',ok)
 if not ok then warn('[MOUNT BBYA] v6.7 runtime QC failed')end
end)`;

const item=(cls,ref,name,src)=>`<Item class="${cls}" referent="${ref}"><Properties><string name="Name">${name}</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${src}]]></ProtectedString></Properties></Item>`;
const workspaceXml=`<Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties><Item class="Part" referent="EB"><Properties><bool name="Anchored">true</bool><bool name="CanCollide">true</bool><CoordinateFrame name="CFrame"><X>0</X><Y>42</Y><Z>0</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame><string name="Name">ACC_EmergencyBaseplate</string><Vector3 name="Size"><X>180</X><Y>8</Y><Z>180</Z></Vector3></Properties></Item><Item class="SpawnLocation" referent="ES"><Properties><bool name="Anchored">true</bool><bool name="CanCollide">true</bool><bool name="Enabled">true</bool><CoordinateFrame name="CFrame"><X>0</X><Y>47</Y><Z>0</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame><string name="Name">ACC_EmergencySpawn</string><bool name="Neutral">true</bool><Vector3 name="Size"><X>16</X><Y>1</Y><Z>16</Z></Vector3></Properties></Item></Item>`;
const servers=[
 item('Script','BOOT','MountBBYA_Bootstrap',bootstrap),
 item('Script','ENV67','MountBBYA_Phase1_Environment67',read(files.environment)),
 item('Script','AMB','MountBBYA_Ambience',read(files.ambience)),
 item('Script','CP','MountBBYA_Checkpoint',checkpoint),
 item('Script','REL','MountBBYA_Release',release),
 item('Script','QC','MountBBYA_QC',qc)
].join('');
const client=item('LocalScript','PERF','MountBBYA_Performance',read(files.perf));
const xml=`<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External>${workspaceXml}<Item class="Lighting" referent="L"><Properties><float name="Brightness">2</float><double name="ClockTime">6.3</double><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="SS"><Properties><string name="Name">ServerScriptService</string></Properties>${servers}</Item><Item class="StarterPlayer" referent="SP"><Properties><string name="Name">StarterPlayer</string></Properties><Item class="StarterPlayerScripts" referent="SPS"><Properties><string name="Name">StarterPlayerScripts</string></Properties>${client}</Item></Item></roblox>`;
const out=path.join(root,target.file);fs.mkdirSync(path.dirname(out),{recursive:true});fs.writeFileSync(out,xml);
console.log('[MOUNT BBYA] v6.7 candidate built',target.file,Buffer.byteLength(xml),'bytes');
