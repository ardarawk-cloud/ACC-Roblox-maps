const fs=require('fs'),path=require('path');
const root=process.cwd();
const raw=(f)=>fs.readFileSync(path.join(root,f),'utf8');
const cdata=(s)=>String(s).replaceAll(']]>',']]]]><![CDATA[>');
const mustReplace=(src,needle,replacement,label)=>{if(!src.includes(needle))throw new Error(`Becak build patch anchor missing: ${label}`);return src.replace(needle,replacement);};

let server=raw('maps/becak-e-bike/runtime.server.lua');
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
`d.Coins+=reward d.XP+=math.floor(20+dist/60) d.Trips+=1 d.Level=levelFromXP(d.XP)\n                player:SetAttribute("BecakTrips",d.Trips)\n                activeTrips[player]=nil`,
'trip attribute');
server=mustReplace(server,
`playerData[player]=d\n    player:SetAttribute("BecakTrips",d.Trips)\n    player:SetAttribute("BecakVersion","1.9.0")\n    local stats=Instance.new("Folder")`,
`playerData[player]=d\n    player:SetAttribute("BecakTrips",d.Trips)\n    player:SetAttribute("BecakVersion","1.17.0")\n    local stats=Instance.new("Folder")`,
'player attributes');
server += `\nWorkspace:SetAttribute("ACC_BecakRuntime","v1.17")\n`;

const details=raw('maps/becak-e-bike/world.details.server.lua');
const systems=raw('maps/becak-e-bike/masterplan.systems.server.lua');
const events=raw('maps/becak-e-bike/masterplan.events.server.lua');
const traffic=raw('maps/becak-e-bike/traffic.npc.server.lua');
const vehicle=raw('maps/becak-e-bike/masterplan.vehicle.server.lua');
const charging=raw('maps/becak-e-bike/charging.network.server.lua');
const contracts=raw('maps/becak-e-bike/daily.contracts.server.lua');
const polish=raw('maps/becak-e-bike/polish.server.lua');
const roadAccess=raw('maps/becak-e-bike/road-access.server.lua');
const worldQC=raw('maps/becak-e-bike/world-qc.server.lua');
const client=raw('maps/becak-e-bike/runtime.client.lua');
const masterClient=raw('maps/becak-e-bike/masterplan.client.lua');
const phoneClient=raw('maps/becak-e-bike/phone.ui.client.lua');
const mobileSafe=raw('maps/becak-e-bike/mobile.safearea.client.lua');
const navigation=raw('maps/becak-e-bike/navigation.client.lua');

const xml=`<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External><Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties></Item><Item class="Lighting" referent="L"><Properties><float name="Brightness">2.5</float><double name="ClockTime">8</double><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties><Item class="Script" referent="B"><Properties><string name="Name">BecakEBike_Runtime</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(server)}]]></ProtectedString></Properties></Item><Item class="Script" referent="D"><Properties><string name="Name">BecakEBike_CityDetails</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(details)}]]></ProtectedString></Properties></Item><Item class="Script" referent="M"><Properties><string name="Name">BecakEBike_Masterplan</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(systems)}]]></ProtectedString></Properties></Item><Item class="Script" referent="EV"><Properties><string name="Name">BecakEBike_CityEvents</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(events)}]]></ProtectedString></Properties></Item><Item class="Script" referent="TR"><Properties><string name="Name">BecakEBike_TrafficNPC</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(traffic)}]]></ProtectedString></Properties></Item><Item class="Script" referent="V"><Properties><string name="Name">BecakEBike_VehicleMasterplan</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(vehicle)}]]></ProtectedString></Properties></Item><Item class="Script" referent="CH"><Properties><string name="Name">BecakEBike_ChargingNetwork</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(charging)}]]></ProtectedString></Properties></Item><Item class="Script" referent="DC"><Properties><string name="Name">BecakEBike_DailyContracts</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(contracts)}]]></ProtectedString></Properties></Item><Item class="Script" referent="PL"><Properties><string name="Name">BecakEBike_Polish</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(polish)}]]></ProtectedString></Properties></Item><Item class="Script" referent="RA"><Properties><string name="Name">BecakEBike_RoadAccess</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(roadAccess)}]]></ProtectedString></Properties></Item><Item class="Script" referent="WQ"><Properties><string name="Name">BecakEBike_WorldQC</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(worldQC)}]]></ProtectedString></Properties></Item></Item><Item class="StarterPlayer" referent="P"><Properties><string name="Name">StarterPlayer</string></Properties><Item class="StarterPlayerScripts" referent="PS"><Properties><string name="Name">StarterPlayerScripts</string></Properties><Item class="LocalScript" referent="C"><Properties><string name="Name">BecakEBike_Client</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(client)}]]></ProtectedString></Properties></Item><Item class="LocalScript" referent="MC"><Properties><string name="Name">BecakEBike_MasterplanClient</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(masterClient)}]]></ProtectedString></Properties></Item><Item class="LocalScript" referent="PH"><Properties><string name="Name">BecakEBike_DriverPhone</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(phoneClient)}]]></ProtectedString></Properties></Item><Item class="LocalScript" referent="MS"><Properties><string name="Name">BecakEBike_MobileSafeArea</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(mobileSafe)}]]></ProtectedString></Properties></Item><Item class="LocalScript" referent="NV"><Properties><string name="Name">BecakEBike_DriverNavigation</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(navigation)}]]></ProtectedString></Properties></Item></Item></Item></roblox>`;
fs.writeFileSync(path.join(root,'maps/becak-e-bike/place.rbxlx'),xml);
console.log('[Becak E-Bike] Built v1.17 persistent daily contracts + v1.16 charging network + v1.15 performance consolidation + v1.14 safe traffic + city events + seamless road access + left mobile UI + navigation + world QC:',Buffer.byteLength(xml),'bytes');