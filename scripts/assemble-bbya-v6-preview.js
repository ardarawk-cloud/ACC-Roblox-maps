const fs = require('fs');
const path = require('path');

const root = process.cwd();
const mapId = process.argv[2] || 'a-club';
const outArg = process.argv[3] || '/tmp/bbya-clean-rebuild-preview.rbxlx';
if (mapId !== 'a-club') throw new Error('BBYA clean rebuild assembler is a-club only');

const registry = JSON.parse(fs.readFileSync(path.join(root, 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map: ${mapId}`);

const sourceFiles = [
  'maps/a-club/rebuild/00-core.lua',
  'maps/a-club/rebuild/10-architecture.lua',
  'maps/a-club/rebuild/20-furnishing.lua',
  'maps/a-club/rebuild/30-lighting.lua',
  'maps/a-club/rebuild/40-runtime.server.lua',
  'maps/a-club/rebuild/50-qc.server.lua',
];
for (const file of sourceFiles) {
  if (!fs.existsSync(path.join(root,file))) throw new Error(`Missing clean rebuild source: ${file}`);
}

const source = sourceFiles
  .map(file => `\n-- SOURCE FILE: ${file}\n${fs.readFileSync(path.join(root,file),'utf8').replaceAll(']]>',']]]]><![CDATA[>')}`)
  .join('\n');

const placePath = path.join(root, target.file);
let xml = fs.readFileSync(placePath, 'utf8');
if (!xml.includes('</roblox>')) throw new Error('Invalid blank RBXLX: missing </roblox>');

xml = xml.replace(/<!-- BBYA_CLEAN_REBUILD_BEGIN -->[\s\S]*?<!-- BBYA_CLEAN_REBUILD_END -->/g, '');
const runtime = `<!-- BBYA_CLEAN_REBUILD_BEGIN -->
<Item class="ServerScriptService" referent="RBXBBYACLEANSSS">
  <Properties><string name="Name">ServerScriptService</string></Properties>
  <Item class="Script" referent="RBXBBYACLEANRUNTIME">
    <Properties>
      <bool name="Disabled">false</bool>
      <string name="Name">BBYA_CLEAN_REBUILD_RUNTIME</string>
      <ProtectedString name="Source"><![CDATA[${source}]]></ProtectedString>
    </Properties>
  </Item>
</Item>
<!-- BBYA_CLEAN_REBUILD_END -->`;

xml = xml.replace('</roblox>', `${runtime}\n</roblox>`);
fs.mkdirSync(path.dirname(outArg), { recursive: true });
fs.writeFileSync(outArg, xml);
console.log(`[BBYA CLEAN REBUILD] Preview assembled -> ${outArg}`);
console.log(`[BBYA CLEAN REBUILD] ${sourceFiles.length} fresh source modules; no legacy V5/V6 geometry assembled.`);
console.log('[BBYA CLEAN REBUILD] PREVIEW ONLY — NO ROBLOX PUBLISH PERFORMED');
