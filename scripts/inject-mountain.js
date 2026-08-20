const fs = require('fs');
const path = require('path');

const mapId = process.argv[2];
if (mapId !== 'mountain-social') process.exit(0);

const root = process.cwd();
const registry = JSON.parse(fs.readFileSync(path.join(root, 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map id: ${mapId}`);
if (String(target.universeId) !== '10744139279' || String(target.placeId) !== '82661754996018') {
  throw new Error('Mountain target lock mismatch. Refusing injection.');
}

const placePath = path.join(root, target.file);
const readLua = (file) => fs.readFileSync(path.join(root, file), 'utf8').replaceAll(']]>', ']]]]><![CDATA[>');

const serverFiles = [
  ['ACC_Mountain_World', 'maps/mountain-social/mountain.world.server.lua'],
  ['ACC_Mountain_Checkpoints', 'maps/mountain-social/systems/checkpoint.server.lua'],
  ['ACC_Mountain_Ambience', 'maps/mountain-social/systems/ambience.server.lua'],
  ['ACC_Mountain_Carry', 'maps/mountain-social/systems/carry.server.lua'],
  ['ACC_Mountain_Summit', 'maps/mountain-social/systems/summit.server.lua'],
  ['ACC_Mountain_Interactions', 'maps/mountain-social/mountain.interactions.server.lua'],
  ['ACC_Mountain_QC', 'maps/mountain-social/mountain.qc.server.lua'],
];
const clientFiles = [
  ['ACC_Mountain_Client', 'maps/mountain-social/mountain.client.lua'],
  ['ACC_Mountain_Performance', 'maps/mountain-social/mountain.performance.client.lua'],
];

let xml = fs.readFileSync(placePath, 'utf8');
const begin = '<!-- ACC_MOUNTAIN_RUNTIME_BEGIN -->';
const end = '<!-- ACC_MOUNTAIN_RUNTIME_END -->';
const prior = new RegExp(`${begin}[\\s\\S]*?${end}`, 'g');
xml = xml.replace(prior, `${begin}\n${end}`);

const scriptItem = (name, source, i) => `  <Item class="Script" referent="RBXMOUNTAINSERVER${String(i).padStart(4,'0')}"><Properties><bool name="Disabled">false</bool><string name="Name">${name}</string><ProtectedString name="Source"><![CDATA[${source}]]></ProtectedString></Properties></Item>`;
const localItem = (name, source, i) => `    <Item class="LocalScript" referent="RBXMOUNTAINCLIENT${String(i).padStart(4,'0')}"><Properties><bool name="Disabled">false</bool><string name="Name">${name}</string><ProtectedString name="Source"><![CDATA[${source}]]></ProtectedString></Properties></Item>`;

const servers = serverFiles.map(([name,file],i)=>scriptItem(name,readLua(file),i+1)).join('\n');
const clients = clientFiles.map(([name,file],i)=>localItem(name,readLua(file),i+1)).join('\n');

const runtime = `${begin}
<Item class="ServerScriptService" referent="RBXMOUNTAINSERVERSERVICE000000001">
  <Properties><string name="Name">ServerScriptService</string></Properties>
${servers}
</Item>
<Item class="StarterPlayer" referent="RBXMOUNTAINSTARTERPLAYER000000001">
  <Properties><string name="Name">StarterPlayer</string></Properties>
  <Item class="StarterPlayerScripts" referent="RBXMOUNTAINSTARTERSCRIPTS00000001">
    <Properties><string name="Name">StarterPlayerScripts</string></Properties>
${clients}
  </Item>
</Item>
${end}`;

if (!xml.includes('</roblox>')) throw new Error('Invalid Mountain RBXLX: missing </roblox>');
xml = xml.replace(`${begin}\n${end}`, runtime);
fs.writeFileSync(placePath, xml);
console.log('[Mountain] Injected isolated runtime into', target.file);
