const fs=require('fs'),path=require('path');
const root=process.cwd();
const raw=(f)=>fs.readFileSync(path.join(root,f),'utf8');
const cdata=(s)=>String(s).replaceAll(']]>',']]]]><![CDATA[>');
const mustReplace=(src,needle,replacement,label)=>{if(!src.includes(needle))throw new Error(`Becak build patch anchor missing: ${label}`);return src.replace(needle,replacement);};

let server=raw('maps/becak-e-bike/runtime.server.lua');

server=mustReplace(server,
`local old = Workspace:FindFirstChild(ROOT_NAME)\nif old then old:Destroy() end\nlocal root = Instance.new("Folder")\nroot.Name = ROOT_NAME\nroot.Parent = Workspace`,
`local old = Workspace:FindFirstChild(ROOT_NAME)\nif old then\n    if old:GetAttribute("ACC_BecakRuntimeOwned") == true then\n        old:Destroy()\n    else\n        error("[BECAK E-BIKE] Refusing to destroy pre-existing unowned Workspace/BecakEBike root")\n    end\nend\nlocal root = Instance.new("Folder")\nroot.Name = ROOT_NAME\nroot:SetAttribute("ACC_BecakRuntimeOwned", true)\nroot.Parent = Workspace\nWorkspace:SetAttribute("ACC_BecakStartupGuard", "v1.31")`,
'startup ownership guard');

server=mustReplace(server,
`root.Name = ROOT_NAME\nroot.Parent = Workspace\n\nlocal world =`,
`root.Name = ROOT_NAME\nroot.Parent = Workspace\n\nlocal economyTransaction = Instance.new("BindableFunction")\neconomyTransaction.Name = "EconomyTransaction"\neconomyTransaction.Parent = root\n\nlocal world =`,
'economy object');

server=mustReplace(server,
`local playerVehicles = {}\n\nlocal function copy`,
`local playerVehicles = {}\n\neconomyTransaction.OnInvoke = function(player, amount, xp, reason)\n    local d = playerData[player]\n    if not d then return false end\n    amount = math.floor(tonumber(amount) or 0)\n    xp = math.max(0, math.floor(tonumber(xp) or 0))\n    if amount < 0 and d.Coins < -amount then return false end\n    d.Coins += amount\n    d.XP += xp\n    d.Level = math.max(1, math.floor(math.sqrt(d.XP/100))+1)\n    player:SetAttribute("BecakTrips", d.Trips)\n    return true, d.Coins, reason\nend\n\nlocal function copy`,
'economy handler');

server=mustReplace(server,
`m:SetAttribute("BatteryMax",batteryCapacity(d))`,
`m:SetAttribute("BatteryMax",batteryCapacity(d))\n    m:SetAttribute("Condition",100)`,
'vehicle condition');

server=mustReplace(server,
`d.Coins+=reward d.XP+=math.floor(20+dist/60) d.Trips+=1 d.Level=levelFromXP(d.XP)\n                activeTrips[player]=nil`,
`d.Coins+=reward d.XP+=math.floor(20+dist/60) d.Trips+=1 d.Level=levelFromXP(d.XP)\n                player:SetAttribute("BecakLastTripBaseReward",reward)\n                player:SetAttribute("BecakTrips",d.Trips)\n                activeTrips[player]=nil`,
'trip attribute + fare telemetry');

// Keep this anchor tied to the real runtime source. Earlier builds expected attributes
// that are not present in runtime.server.lua, causing the publish workflow to stop
// before generating place.rbxlx.
server=mustReplace(server,
`playerData[player]=d\n    local stats=Instance.new("Folder")`,
`playerData[player]=d\n    player:SetAttribute("BecakTrips",d.Trips)\n    player:SetAttribute("BecakLastTripBaseReward",0)\n    player:SetAttribute("BecakVersion","1.31.0")\n    local stats=Instance.new("Folder")`,
'player attributes');

server += `\nWorkspace:SetAttribute("ACC_BecakRuntime","v1.31")\nWorkspace:SetAttribute("BecakPassengerFareTelemetry","ON")\n`;

const details=raw('maps/becak-e-bike/world.details.server.lua');
const systems=raw('maps/becak-e-bike/masterplan.systems.server.lua');
const cargoVisual=raw('maps/becak-e-bike/cargo.visual.server.lua');
const events=raw('maps/becak-e-bike/masterplan.events.server.lua');
const traffic=raw('maps/becak-e-bike/traffic.npc.server.lua');
const vehicle=raw('maps/becak-e-bike/masterplan.vehicle.server.lua');
const recovery=raw('maps/becak-e-bike/vehicle.recovery.server.lua');
const groundContact=raw('maps/becak-e-bike/vehicle.ground-contact.server.lua');
const charging=raw('maps/becak-e-bike/charging.network.server.lua');
const contracts=raw('maps/becak-e-bike/daily.contracts.server.lua');
const story=raw('maps/becak-e-bike/story.progression.server.lua');
const reputationCargo=raw('maps/becak-e-bike/reputation.cargo.server.lua');
const reputationPassenger=raw('maps/becak-e-bike/reputation.passenger.server.lua');
const achievements=raw('maps/becak-e-bike/achievements.server.lua');
const polish=raw('maps/becak-e-bike/polish.server.lua');
const roadAccess=raw('maps/becak-e-bike/road-access.server.lua');
const worldQC=raw('maps/becak-e-bike/world-qc.server.lua');
const client=raw('maps/becak-e-bike/runtime.client.lua');
const masterClient=raw('maps/becak-e-bike/masterplan.client.lua');
const phoneClient=raw('maps/becak-e-bike/phone.ui.client.lua');
const mobileSafe=raw('maps/becak-e-bike/mobile.safearea.client.lua');
const navigation=raw('maps/becak-e-bike/navigation.client.lua');
const contractsClient=raw('maps/becak-e-bike/daily.contracts.ui.client.lua');

const scriptItem=(referent,name,source)=>`<Item class="Script" referent="${referent}"><Properties><string name="Name">${name}</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(source)}]]></ProtectedString></Properties></Item>`;
const localScriptItem=(referent,name,source)=>`<Item class="LocalScript" referent="${referent}"><Properties><string name="Name">${name}</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(source)}]]></ProtectedString></Properties></Item>`;

const serverItems=[
['B','BecakEBike_Runtime',server],
['D','BecakEBike_CityDetails',details],
['M','BecakEBike_Masterplan',systems],
['CV','BecakEBike_CargoVisual',cargoVisual],
['EV','BecakEBike_CityEvents',events],
['TR','BecakEBike_TrafficNPC',traffic],
['V','BecakEBike_VehicleMasterplan',vehicle],
['VR','BecakEBike_VehicleRecovery',recovery],
['GC','BecakEBike_GroundContact',groundContact],
['CH','BecakEBike_ChargingNetwork',charging],
['DC','BecakEBike_DailyContracts',contracts],
['ST','BecakEBike_StoryProgression',story],
['RC','BecakEBike_ReputationCargo',reputationCargo],
['RP','BecakEBike_ReputationPassenger',reputationPassenger],
['ACH','BecakEBike_Achievements',achievements],
['PL','BecakEBike_Polish',polish],
['RA','BecakEBike_RoadAccess',roadAccess],
['WQ','BecakEBike_WorldQC',worldQC],
].map(([r,n,s])=>scriptItem(r,n,s)).join('');

const clientItems=[
['C','BecakEBike_Client',client],
['MC','BecakEBike_MasterplanClient',masterClient],
['PH','BecakEBike_DriverPhone',phoneClient],
['MS','BecakEBike_MobileSafeArea',mobileSafe],
['NV','BecakEBike_DriverNavigation',navigation],
['DCUI','BecakEBike_DailyContractsUI',contractsClient],
].map(([r,n,s])=>localScriptItem(r,n,s)).join('');

const xml=`<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External><Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties></Item><Item class="Lighting" referent="L"><Properties><float name="Brightness">2.5</float><double name="ClockTime">8</double><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties>${serverItems}</Item><Item class="StarterPlayer" referent="P"><Properties><string name="Name">StarterPlayer</string></Properties><Item class="StarterPlayerScripts" referent="PS"><Properties><string name="Name">StarterPlayerScripts</string></Properties>${clientItems}</Item></Item></roblox>`;

fs.writeFileSync(path.join(root,'maps/becak-e-bike/place.rbxlx'),xml);
console.log('[Becak E-Bike] Built v1.31 with repaired runtime anchor + startup ownership guard + cargo payload + adaptive left phone + road-edge audit + recovery + v1.36 smooth ground contact + progression systems:',Buffer.byteLength(xml),'bytes');