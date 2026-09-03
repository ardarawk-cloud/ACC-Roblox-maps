const fs = require('fs');
const path = require('path');

const root = process.cwd();
const mapDir = path.join(root, 'maps', 'bbyavatar');
const STATIC_MAP_AUTHORITY = 'ZONA_STATIC_MAP_V1';

function read(name) {
  return fs.readFileSync(path.join(mapDir, name), 'utf8');
}
function cdata(source) {
  return source.replace(/\]\]>/g, ']]]]><![CDATA[>');
}
function esc(value) {
  return String(value).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

const config = read('fps.config.lua');
const gameServer = read('fps.game.server.lua');
const client = read('fps.client.lua');

let refCounter = 0;
function partXml(name, x, y, z, sx, sy, sz, brickColor = 194) {
  const ref = `ZP_PART_${++refCounter}`;
  return `<Item class="Part" referent="${ref}"><Properties>
    <bool name="Anchored">true</bool>
    <int name="BrickColor">${brickColor}</int>
    <bool name="CanCollide">true</bool>
    <CoordinateFrame name="CFrame"><X>${x}</X><Y>${y}</Y><Z>${z}</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame>
    <string name="Name">${esc(name)}</string>
    <Vector3 name="size"><X>${sx}</X><Y>${sy}</Y><Z>${sz}</Z></Vector3>
  </Properties></Item>`;
}

const staticParts = [];
const add = (...args) => staticParts.push(partXml(...args));

// FOUNDATION: these objects are serialized directly into Workspace. They do not depend on runtime scripts.
add('Ground', 0, -4, 0, 520, 8, 420, 199);
add('NorthBoundary', 0, 12, -210, 520, 24, 6, 1003);
add('SouthBoundary', 0, 12, 210, 520, 24, 6, 1003);
add('WestBoundary', -260, 12, 0, 6, 24, 420, 1003);
add('EastBoundary', 260, 12, 0, 6, 24, 420, 1003);

// Three-lane road grid.
add('MainRoad', 0, 0.35, 0, 470, 0.7, 58, 199);
add('NorthRoad', 0, 0.36, -126, 470, 0.7, 44, 199);
add('SouthRoad', 0, 0.36, 126, 470, 0.7, 44, 199);
add('CenterCrossRoad', 0, 0.38, 0, 60, 0.75, 382, 199);
add('WestCrossRoad', -132, 0.39, 0, 44, 0.75, 360, 199);
add('EastCrossRoad', 132, 0.39, 0, 44, 0.75, 360, 199);

// Spawn-side safe bases. Combat server fallback spawns sit over these pads.
add('AlphaSpawnDeck', -222, 0.25, 0, 58, 1, 156, 23);
add('BravoSpawnDeck', 222, 0.25, 0, 58, 1, 156, 21);
add('AlphaRearWall', -252, 10, 0, 6, 20, 156, 1003);
add('BravoRearWall', 252, 10, 0, 6, 20, 156, 1003);
add('AlphaCoverNorth', -197, 5, -60, 8, 10, 46, 23);
add('AlphaCoverSouth', -197, 5, 60, 8, 10, 46, 23);
add('BravoCoverNorth', 197, 5, -60, 8, 10, 46, 21);
add('BravoCoverSouth', 197, 5, 60, 8, 10, 46, 21);

// Central warehouse with four open entrances.
add('WarehouseFloor', 0, 0.65, 0, 126, 1, 106, 194);
add('WarehouseNorthLeft', -40, 11, -53, 46, 22, 5, 199);
add('WarehouseNorthRight', 40, 11, -53, 46, 22, 5, 199);
add('WarehouseSouthLeft', -40, 11, 53, 46, 22, 5, 199);
add('WarehouseSouthRight', 40, 11, 53, 46, 22, 5, 199);
add('WarehouseWestNorth', -63, 11, -35, 5, 22, 36, 199);
add('WarehouseWestSouth', -63, 11, 35, 5, 22, 36, 199);
add('WarehouseEastNorth', 63, 11, -35, 5, 22, 36, 199);
add('WarehouseEastSouth', 63, 11, 35, 5, 22, 36, 199);
add('WarehouseRoofLeft', -31.5, 22.5, 0, 63, 1, 106, 1003);
add('WarehouseRoofRight', 31.5, 22.5, 0, 63, 1, 106, 1003);
add('WarehouseCenterTower', 0, 17, 0, 18, 34, 18, 199);
add('WarehouseCoverA', -30, 3, -20, 20, 6, 7, 194);
add('WarehouseCoverB', 30, 3, 20, 20, 6, 7, 194);
add('WarehouseCoverC', -20, 3, 26, 7, 6, 20, 194);
add('WarehouseCoverD', 20, 3, -26, 7, 6, 20, 194);

// Urban blocks.
const buildings = [
  [-118,-92,58,28,52], [-118,92,64,34,48], [118,-92,64,32,50], [118,92,58,25,54],
  [-202,-150,48,24,44], [-202,150,54,30,42], [202,-150,54,29,42], [202,150,48,24,44],
];
buildings.forEach((b, i) => add(`Office_${i+1}`, b[0], b[3]/2, b[1], b[2], b[3], b[4], i % 2 === 0 ? 194 : 199));

// Containers and cover landmarks.
const containers = [
  [-95,4,-155,217], [-95,12,-155,199], [-150,4,72,141],
  [95,4,155,217], [95,12,155,199], [150,4,-72,217],
];
containers.forEach((c, i) => add(`Container_${i+1}`, c[0], c[1], c[2], 30, 8, 11, c[3]));

const covers = [
  [-170,-92],[-166,-24],[-168,86],[-145,126],[170,92],[166,24],[168,-86],[145,-126],
  [-82,-78],[82,78],[-82,78],[82,-78],[-42,118],[42,-118],[-42,-118],[42,118],
];
covers.forEach((c, i) => add(`Cover_${i+1}`, c[0], 2.5, c[1], 14, 5, 5, 194));

// Tall silhouettes make the battlefield unmistakable immediately after spawn.
add('AlphaTower', -228, 21, -150, 18, 42, 18, 23);
add('BravoTower', 228, 21, 150, 18, 42, 18, 21);
add('CenterMonument', 0, 18, 126, 12, 36, 12, 24);

const staticMapXml = `<Item class="Folder" referent="ZP_STATIC"><Properties><string name="Name">ZONA_STATIC_MAP</string></Properties>
  <Item class="StringValue" referent="ZP_AUTH"><Properties><string name="Name">ZONA_STATIC_MAP_AUTHORITY</string><string name="Value">${STATIC_MAP_AUTHORITY}</string></Properties></Item>
  ${staticParts.join('\n  ')}
</Item>`;

const xml = `<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
<External>null</External><External>nil</External>
<Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties>
  ${staticMapXml}
</Item>
<Item class="Lighting" referent="L"><Properties><string name="Name">Lighting</string><float name="Brightness">2</float><double name="ClockTime">16.4</double></Properties></Item>
<Item class="Teams" referent="T"><Properties><string name="Name">Teams</string></Properties></Item>
<Item class="ReplicatedStorage" referent="RS"><Properties><string name="Name">ReplicatedStorage</string></Properties>
  <Item class="ModuleScript" referent="CFG"><Properties><string name="Name">FPSConfig</string><ProtectedString name="Source"><![CDATA[${cdata(config)}]]></ProtectedString></Properties></Item>
</Item>
<Item class="ServerScriptService" referent="SSS"><Properties><string name="Name">ServerScriptService</string></Properties>
  <Item class="Script" referent="GAME"><Properties><string name="Name">FPS_GameServer</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(gameServer)}]]></ProtectedString></Properties></Item>
</Item>
<Item class="StarterPlayer" referent="SP"><Properties><string name="Name">StarterPlayer</string></Properties>
  <Item class="StarterPlayerScripts" referent="SPS"><Properties><string name="Name">StarterPlayerScripts</string></Properties>
    <Item class="LocalScript" referent="CLIENT"><Properties><string name="Name">FPS_Client</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${cdata(client)}]]></ProtectedString></Properties></Item>
  </Item>
</Item>
</roblox>`;

const out = path.join(mapDir, 'place.rbxlx');
fs.writeFileSync(out, xml);
console.log(`[ZONA PERANG] Built ${path.relative(root,out)} (${Buffer.byteLength(xml)} bytes, ${staticParts.length} static map parts, authority ${STATIC_MAP_AUTHORITY})`);
