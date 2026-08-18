const fs = require('fs');
const path = require('path');

const mapId = process.argv[2];
if (mapId !== 'a-club') process.exit(0);

const registry = JSON.parse(fs.readFileSync(path.join(process.cwd(), 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map id: ${mapId}`);

const placePath = path.join(process.cwd(), target.file);
const luaPath = path.join(process.cwd(), 'maps/a-club/bbya.server.lua');

let xml = fs.readFileSync(placePath, 'utf8');
const lua = fs.readFileSync(luaPath, 'utf8').replaceAll(']]>', ']]]]><![CDATA[>');

const begin = '<!-- BBYA_RUNTIME_BEGIN -->';
const end = '<!-- BBYA_RUNTIME_END -->';
const prior = new RegExp(`${begin}[\\s\\S]*?${end}`, 'g');
xml = xml.replace(prior, '');

const runtime = `${begin}<Item class="ServerScriptService" referent="RBXBBYASERVERSCRIPTSERVICE00000001"><Properties><string name="Name">ServerScriptService</string></Properties><Item class="Script" referent="RBXBBYARUNTIME00000000000000000001"><Properties><bool name="Disabled">false</bool><string name="Name">BBYA_Runtime_v0_2</string><ProtectedString name="Source"><![CDATA[${lua}]]></ProtectedString></Properties></Item></Item>${end}`;

if (!xml.includes('</roblox>')) throw new Error('Invalid RBXLX: missing </roblox>');
xml = xml.replace('</roblox>', `${runtime}</roblox>`);
fs.writeFileSync(placePath, xml);
console.log('[BBYA] Runtime injected into', target.file);
