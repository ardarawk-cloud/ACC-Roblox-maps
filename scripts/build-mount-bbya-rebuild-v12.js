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
let world=fs.readFileSync(runtimeAbs,'utf8');
for(const marker of ['MOUNT_BBYA_REBUILD_V11','visual-lock-rebuild-v1.1','FOUNDATION_CARVE_SUBGRADE_TRAIL','MOUNT_BBYA_READY','MinimumCheckpointSpacing']){
 if(!world.includes(marker)) throw new Error(`Runtime marker missing: ${marker}`);
}
for(const forbidden of ['ACC_MountainSocial','10744139279','82661754996018']){
 if(world.includes(forbidden)) throw new Error(`Forbidden marker leaked into runtime: ${forbidden}`);
}

// Runtime failure found by physical mobile QC: giant Terrain FillBall operations can stall the
// world script before village creation. Patch the embedded world to cheap, deterministic part masses.
world = world.replace(
 'for _, name in ipairs({"Route","Village","Basecamp","Forest","Checkpoints","Valley","Cliff","HighCamp","Highland","Summit","Scenery"}) do',
 'for _, name in ipairs({"Route","Village","Basecamp","Forest","Checkpoints","Valley","Cliff","HighCamp","Highland","Summit","Scenery","GroundMass"}) do'
);
world = world.replace('groundParams.FilterDescendantsInstances={Terrain}','groundParams.FilterDescendantsInstances={Terrain,folders.GroundMass}');

const terrainStart=world.indexOf('-- TERRAIN FIRST: broad mountain -> route carve -> guaranteed subgrade -> tread.');
const trailFnStart=world.indexOf('local function trailWidth(i)',terrainStart);
if(terrainStart<0||trailFnStart<0) throw new Error('Terrain patch markers missing');
const fastFoundation=`-- TERRAIN FOUNDATION HOTFIX v1.3: no giant FillBall runtime work.\nTerrain:Clear()\nTerrain.WaterColor=Color3.fromRGB(55,105,112);Terrain.WaterTransparency=.25;Terrain.WaterWaveSize=.12;Terrain.WaterWaveSpeed=7\nroot:SetAttribute("RuntimeFoundationPatch","FAST_PART_MASS_V13")\n\n-- Three ground strips stay under Roblox Part size limits.\nfor _,g in ipairs({{0,-12,1380},{0,-12,0},{0,-12,-1380}}) do\n    mk("WorldGround",Vector3.new(1800,24,1380),CFrame.new(g[1],g[2],g[3]),Enum.Material.Grass,Color3.fromRGB(69,91,48),folders.GroundMass,true)\nend\n\n-- Overlapping ellipsoid masses follow the hiking elevation and make one continuous mountain.\nfor i=1,#route,3 do\n    local p=route[i]\n    local n=route[math.min(#route,i+1)]\n    local flat=Vector3.new(n.X-p.X,0,n.Z-p.Z)\n    local side=(flat.Magnitude>1) and Vector3.new(-flat.Z,0,flat.X).Unit or Vector3.new(1,0,0)\n    local h=math.clamp(110+p.Y*.50,120,600)\n    local w=math.clamp(520-p.Y*.16,300,520)\n    local d=math.clamp(500-p.Y*.08,330,500)\n    local high=p.Y>650\n    local mat=high and Enum.Material.Rock or Enum.Material.Grass\n    local col=high and color.stoneDark or Color3.fromRGB(63,91,48)\n    sphere("RidgeMass",Vector3.new(p.X,p.Y-h*.5-5,p.Z),Vector3.new(w,h,d),mat,col,folders.GroundMass,true)\n    if i%6==1 then\n        local fh=h*.72\n        sphere("FlankMassL",Vector3.new(p.X+side.X*w*.46,p.Y-fh*.5-18,p.Z+side.Z*w*.46),Vector3.new(w*.78,fh,d*.82),mat,col,folders.GroundMass,true)\n        sphere("FlankMassR",Vector3.new(p.X-side.X*w*.46,p.Y-fh*.5-18,p.Z-side.Z*w*.46),Vector3.new(w*.78,fh,d*.82),mat,col,folders.GroundMass,true)\n    end\nend\n\n-- Grounded arrival areas exist before any decorative village objects.\nmk("VillageGround",Vector3.new(680,18,430),CFrame.new(0,15,1510),Enum.Material.Grass,Color3.fromRGB(70,97,51),folders.GroundMass,true)\nmk("BasecampGround",Vector3.new(430,22,290),CFrame.new(-35,30,1190),Enum.Material.Grass,Color3.fromRGB(66,92,49),folders.GroundMass,true)\nroot:SetAttribute("FastFoundationReady",true)\n\n`;
world=world.slice(0,terrainStart)+fastFoundation+world.slice(trailFnStart);

const trailStart=world.indexOf('local trails={};local trailCount=0');
const edgeStart=world.indexOf('for i=5,#route-2,2 do',trailStart);
if(trailStart<0||edgeStart<0) throw new Error('Trail patch markers missing');
const fastTrail=`local trails={};local trailCount=0\nfor i=1,#route-1 do\n    local a,b=route[i],route[i+1]\n    local w=trailWidth(i)\n    local material=i>=31 and Enum.Material.Slate or (i>=17 and Enum.Material.Mud or Enum.Material.Ground)\n    local col=i>=31 and color.stone or (i>=17 and color.mud or color.dirt)\n    local subMat=i>=31 and Enum.Material.Rock or Enum.Material.Ground\n    segment(string.format("Subgrade_%02d",i),a-Vector3.new(0,4.2,0),b-Vector3.new(0,4.2,0),w+11,8.8,subMat,i>=31 and color.stoneDark or Color3.fromRGB(88,76,58),folders.GroundMass,true)\n    local tread=segment(string.format("Trail_%02d",i),a+Vector3.new(0,.05,0),b+Vector3.new(0,.05,0),w,1.15,material,col,folders.Route,true)\n    if tread then tread:SetAttribute("RouteIndex",i);trails[i]=tread;trailCount+=1 end\nend\nroot:SetAttribute("TerrainArchitecture","PART_MASS_GROUNDED_TRAIL_V13")\nroot:SetAttribute("TrailFoundationReady",true)\n\n`;
world=world.slice(0,trailStart)+fastTrail+world.slice(edgeStart);
world=world.replace('root:SetAttribute("BuildVersion", BUILD)','root:SetAttribute("BuildVersion", BUILD)\nroot:SetAttribute("WrapperHotfix","mobile-control-plus-fast-foundation-v1.3")');
if(!world.includes('FAST_PART_MASS_V13')||!world.includes('PART_MASS_GROUNDED_TRAIL_V13')) throw new Error('Fast foundation patch not embedded');

const cdata=s=>s.replaceAll(']]>',']]]]><![CDATA[>');
const serverItem=(ref,name,src)=>`<Item class="Script" referent="${ref}"><Properties><string name="Name">${name}</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(src)}]]></ProtectedString></Properties></Item>`;
const clientItem=(ref,name,src)=>`<Item class="LocalScript" referent="${ref}"><Properties><string name="Name">${name}</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(src)}]]></ProtectedString></Properties></Item>`;

// Keep native mobile controls alive at all times.
const bootstrap=`
local Players=game:GetService('Players')
local Workspace=game:GetService('Workspace')
Players.CharacterAutoLoads=true
Workspace:SetAttribute('MOUNT_BBYA_GATE','BUILDING')
Workspace:SetAttribute('MOUNT_BBYA_BOOTSTRAP','mobile-control-hotfix-v1.2')
Workspace:SetAttribute('MOUNT_BBYA_FOUNDATION_HOTFIX','fast-part-mass-v1.3')
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
 if hrp and Workspace:GetAttribute('MOUNT_BBYA_GATE')~='READY' then ch:PivotTo(SAFE_CF);hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero end
end
local function bind(plr)
 plr.RespawnLocation=safeSpawn
 plr.CharacterAdded:Connect(function(ch) task.spawn(secure,plr,ch) end)
 if plr.Character then task.spawn(secure,plr,plr.Character) else task.spawn(function() pcall(function() plr:LoadCharacter() end) end) end
end
for _,plr in ipairs(Players:GetPlayers()) do bind(plr) end
Players.PlayerAdded:Connect(bind)
Workspace:SetAttribute('MOUNT_BBYA_BOOTSTRAP_OK',true)
print('[MOUNT BBYA] bootstrap ready; CharacterAutoLoads=true; fast foundation v1.3')
`;

const release=`
local Players=game:GetService('Players')
local Workspace=game:GetService('Workspace')
local deadline=os.clock()+45
local root,spawn
repeat
 root=Workspace:FindFirstChild('MOUNT_BBYA_REBUILD_V11');spawn=root and root:FindFirstChild('MountBBYA_Spawn')
 if root and spawn and root:GetAttribute('RuntimeState')=='READY' and Workspace:GetAttribute('MOUNT_BBYA_READY')==true then break end
 if os.clock()>deadline then Workspace:SetAttribute('MOUNT_BBYA_GATE','SAFE_PLAYABLE_TIMEOUT');warn('[MOUNT BBYA] world timeout; player remains controllable');return end
 task.wait(.2)
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
task.delay(2,function()
 local s=Workspace:FindFirstChild('MOUNT_BBYA_EMERGENCY_SPAWN');if s then s:Destroy() end
 local b=Workspace:FindFirstChild('MOUNT_BBYA_EMERGENCY_BASE');if b then b:Destroy() end
end)
Workspace:SetAttribute('MOUNT_BBYA_RELEASE_OK',true)
print('[MOUNT BBYA] release ready')
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
local elapsed=0
RunService.RenderStepped:Connect(function(dt)
 elapsed+=dt;if elapsed<1 then return end;elapsed=0
 local ch=player.Character;local humanoid=ch and ch:FindFirstChildOfClass('Humanoid');camera=workspace.CurrentCamera or camera
 if camera and humanoid and (camera.CameraSubject~=humanoid or camera.CameraType~=Enum.CameraType.Custom) then camera.CameraType=Enum.CameraType.Custom;camera.CameraSubject=humanoid end
end)
`;

const qc=`
local Workspace=game:GetService('Workspace')
task.delay(12,function()
 local r=Workspace:FindFirstChild('MOUNT_BBYA_REBUILD_V11')
 local structural=r~=nil and Workspace:GetAttribute('MOUNT_BBYA_READY')==true and r:GetAttribute('RuntimeState')=='READY'
 local fast=r and r:GetAttribute('FastFoundationReady')==true and r:GetAttribute('TrailFoundationReady')==true and r:GetAttribute('TerrainArchitecture')=='PART_MASS_GROUNDED_TRAIL_V13'
 local controls=Workspace:GetAttribute('MOUNT_BBYA_CHARACTER_AUTOLOADS')==true and game:GetService('Players').CharacterAutoLoads==true
 Workspace:SetAttribute('MOUNT_BBYA_RUNTIME_QC',(structural and fast and controls) and 'PASS_CANDIDATE_V13' or 'FAIL_V13')
 Workspace:SetAttribute('MOUNT_BBYA_BUILD_WRAPPER','mobile-control-hotfix-v1.2')
 Workspace:SetAttribute('MOUNT_BBYA_FOUNDATION_WRAPPER','fast-foundation-v1.3')
 if not structural then warn('[MOUNT BBYA] structural runtime not ready') end
 if not fast then warn('[MOUNT BBYA] fast foundation guard failed') end
 if not controls then warn('[MOUNT BBYA] CharacterAutoLoads guard failed') end
end)
`;

const workspaceXml=`<Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties><Item class="Part" referent="EB"><Properties><bool name="Anchored">true</bool><bool name="CanCollide">true</bool><CoordinateFrame name="CFrame"><X>0</X><Y>66</Y><Z>1650</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame><string name="Name">MOUNT_BBYA_EMERGENCY_BASE</string><Vector3 name="Size"><X>140</X><Y>6</Y><Z>140</Z></Vector3></Properties></Item><Item class="SpawnLocation" referent="ES"><Properties><bool name="Anchored">true</bool><bool name="CanCollide">true</bool><bool name="Enabled">true</bool><bool name="Neutral">true</bool><int name="Duration">0</int><CoordinateFrame name="CFrame"><X>0</X><Y>70</Y><Z>1650</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame><string name="Name">MOUNT_BBYA_EMERGENCY_SPAWN</string><Vector3 name="Size"><X>18</X><Y>1</Y><Z>18</Z></Vector3><float name="Transparency">0.25</float></Properties></Item></Item>`;
const scripts=[serverItem('BOOT','MOUNT_BBYA_V12_Bootstrap',bootstrap),serverItem('WORLD','MOUNT_BBYA_V12_World',world),serverItem('RELEASE','MOUNT_BBYA_V12_Release',release),serverItem('QC','MOUNT_BBYA_V12_QC',qc)].join('');
const starterPlayer=`<Item class="StarterPlayer" referent="SP"><Properties><string name="Name">StarterPlayer</string><float name="CameraMinZoomDistance">0.5</float><float name="CameraMaxZoomDistance">400</float></Properties><Item class="StarterPlayerScripts" referent="SPS"><Properties><string name="Name">StarterPlayerScripts</string></Properties>${clientItem('CAM','MOUNT_BBYA_V12_MobileCamera',mobileCamera)}</Item></Item>`;
const xml=`<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External>${workspaceXml}<Item class="Lighting" referent="L"><Properties><float name="Brightness">2.35</float><double name="ClockTime">7.15</double><bool name="GlobalShadows">true</bool><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties>${scripts}</Item>${starterPlayer}</roblox>`;
const out=path.join(root,target.file);fs.mkdirSync(path.dirname(out),{recursive:true});fs.writeFileSync(out,xml);
const bytes=fs.statSync(out).size;if(bytes<22000) throw new Error(`Generated place too small: ${bytes}`);
const check=fs.readFileSync(out,'utf8');
for(const marker of ['MOUNT_BBYA_V12_Bootstrap','MOUNT_BBYA_V12_World','MOUNT_BBYA_V12_Release','MOUNT_BBYA_V12_QC','MOUNT_BBYA_V12_MobileCamera','mobile-control-hotfix-v1.2','CharacterAutoLoads=true','FAST_PART_MASS_V13','PART_MASS_GROUNDED_TRAIL_V13']) if(!check.includes(marker)) throw new Error(`RBXLX marker missing: ${marker}`);
const disabledAutoloadMarker='Players.CharacterAutoLoads='+'false';
if(check.includes(disabledAutoloadMarker)) throw new Error('must never disable CharacterAutoLoads');
if(check.includes('ACC_MountainSocial')) throw new Error('Legacy Mountain Social marker found in generated place');
console.log(`[MOUNT BBYA] mobile + fast foundation RBXLX generated path=${target.file} bytes=${bytes}`);
