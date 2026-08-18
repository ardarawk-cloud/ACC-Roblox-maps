const fs = require('fs');
const path = require('path');

const root = process.cwd();
const mapId = process.argv[2] || 'a-club';
const outArg = process.argv[3] || '/tmp/bbya-clean-rebuild-preview.rbxlx';
if (mapId !== 'a-club') throw new Error('BBYA clean rebuild assembler is a-club only');

const registry = JSON.parse(fs.readFileSync(path.join(root, 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map: ${mapId}`);

// Clean rebuild order is authoritative: core -> massing -> premium exterior -> furnishing -> premium interior -> lighting -> runtime -> QC.
const sourceFiles = [
  'maps/a-club/rebuild/00-core.lua',
  'maps/a-club/rebuild/10-architecture.lua',
  'maps/a-club/rebuild/15-premium-exterior.lua',
  'maps/a-club/rebuild/20-furnishing.lua',
  'maps/a-club/rebuild/25-premium-interior.lua',
  'maps/a-club/rebuild/30-lighting.lua',
  'maps/a-club/rebuild/40-runtime.server.lua',
  'maps/a-club/rebuild/50-qc.server.lua',
];
for (const file of sourceFiles) {
  if (!fs.existsSync(path.join(root,file))) throw new Error(`Missing clean rebuild source: ${file}`);
}
if (sourceFiles.some(file => /\/v[0-9]+\//.test(file))) throw new Error('Archived V5/V6 module leaked into clean rebuild assembly');

const source = sourceFiles
  .map(file => `\n-- SOURCE FILE: ${file}\n${fs.readFileSync(path.join(root,file),'utf8').replaceAll(']]>',']]]]><![CDATA[>')}`)
  .join('\n');

const placePath = path.join(root, target.file);
let xml = fs.readFileSync(placePath, 'utf8');
if (!xml.includes('</roblox>')) throw new Error('Invalid blank RBXLX: missing </roblox>');

const runtimeService = `<Item class="ServerScriptService" referent="RBXBBYACLEANSSS">
  <Properties><string name="Name">ServerScriptService</string></Properties>
  <Item class="Script" referent="RBXBBYACLEANRUNTIME">
    <Properties>
      <bool name="Disabled">false</bool>
      <string name="Name">BBYA_CLEAN_REBUILD_RUNTIME</string>
      <ProtectedString name="Source"><![CDATA[${source}]]></ProtectedString>
    </Properties>
  </Item>
</Item>`;

const blankService = /<Item class="ServerScriptService" referent="RBXBBYABLANKSSS">[\s\S]*?<\/Item>/;
if (!blankService.test(xml)) throw new Error('Blank ServerScriptService anchor not found');
xml = xml.replace(blankService, runtimeService);

fs.mkdirSync(path.dirname(outArg), { recursive: true });
fs.writeFileSync(outArg, xml);
console.log(`[BBYA CLEAN REBUILD] Preview assembled -> ${outArg}`);
console.log(`[BBYA CLEAN REBUILD] ${sourceFiles.length} fresh source modules; phase 2 premium exterior/interior included; no archived V5/V6 geometry assembled.`);
console.log('[BBYA CLEAN REBUILD] PREVIEW ONLY — NO ROBLOX PUBLISH PERFORMED');
