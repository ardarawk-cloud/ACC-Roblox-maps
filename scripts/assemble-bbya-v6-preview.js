const fs = require('fs');
const path = require('path');

const root = process.cwd();
const mapId = process.argv[2] || 'a-club';
const outArg = process.argv[3] || '/tmp/bbya-v6-preview.rbxlx';
if (mapId !== 'a-club') throw new Error('BBYA reset assembler is a-club only');

const registry = JSON.parse(fs.readFileSync(path.join(root, 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map: ${mapId}`);

const placePath = path.join(root, target.file);
const xml = fs.readFileSync(placePath, 'utf8');
if (!xml.includes('</roblox>')) throw new Error('Invalid source RBXLX: missing </roblox>');

fs.mkdirSync(path.dirname(outArg), { recursive: true });
fs.writeFileSync(outArg, xml);
console.log(`[BBYA RESET] Clean blank preview -> ${outArg}`);
console.log('[BBYA RESET] Existing V6 architecture/UI/runtime is intentionally NOT assembled.');
console.log('[BBYA RESET] PREVIEW ONLY — NO ROBLOX PUBLISH PERFORMED');
