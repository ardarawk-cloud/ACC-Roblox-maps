const fs = require('fs');
const path = require('path');

const mapId = process.argv[2];
if (mapId !== 'a-club') process.exit(0);

const root = process.cwd();
const registry = JSON.parse(fs.readFileSync(path.join(root, 'maps/registry.json'), 'utf8'));
const target = registry.maps?.[mapId];
if (!target) throw new Error(`Unknown map id: ${mapId}`);

const placePath = path.join(root, target.file);
const readLua = file => fs.readFileSync(path.join(root, file), 'utf8').replaceAll(']]>', ']]]]><![CDATA[>');

// V5.3 contract:
// - Repo stays modular and zone/component-coded for surgical maintenance.
// - Roblox receives ONE architecture/finish Script, ONE systems Script, ONE unified UI LocalScript.
// - No legacy visual builders are injected.
const zoneFiles = [
  'maps/a-club/v5/00-core.lua',
  'maps/a-club/v5/10-design-system.lua',
  'maps/a-club/v5/15-component-registry.lua',

  'maps/a-club/v5/A1-exterior-spawn.lua','maps/a-club/v5/A1-premium.lua',
  'maps/a-club/v5/A2-entrance-facade.lua','maps/a-club/v5/A2-premium.lua',
  'maps/a-club/v5/A3-lobby.lua','maps/a-club/v5/A3-premium.lua',
  'maps/a-club/v5/S1-service.lua','maps/a-club/v5/S1-premium.lua',
  'maps/a-club/v5/B3-lift.lua','maps/a-club/v5/B3-premium.lua',
  'maps/a-club/v5/A4-main-club.lua','maps/a-club/v5/A4-premium.lua','maps/a-club/v5/A4-showoff-lighting.lua',
  'maps/a-club/v5/A5-bar.lua','maps/a-club/v5/A5-premium.lua',
  'maps/a-club/v5/A6-chill.lua','maps/a-club/v5/A6-premium.lua',
  'maps/a-club/v5/B1-west-stair.lua','maps/a-club/v5/B1-premium.lua',
  'maps/a-club/v5/B2-east-stair.lua','maps/a-club/v5/B2-premium.lua',
  'maps/a-club/v5/C1-vip-west.lua','maps/a-club/v5/C1-premium.lua',
  'maps/a-club/v5/C2-vip-east.lua','maps/a-club/v5/C2-premium.lua',
  'maps/a-club/v5/C3-queen-bridges.lua','maps/a-club/v5/C3-premium.lua',
  'maps/a-club/v5/D1-rooftop-arrival.lua','maps/a-club/v5/D1-premium.lua',
  'maps/a-club/v5/D2-rooftop-water-zone.lua','maps/a-club/v5/D2-premium.lua',
  'maps/a-club/v5/D3-skybar.lua','maps/a-club/v5/D3-premium.lua',
  'maps/a-club/v5/D4-rooftop-chill.lua','maps/a-club/v5/D4-premium.lua',
  'maps/a-club/v5/D5-cabana-zones.lua','maps/a-club/v5/D5-premium.lua',
  'maps/a-club/v5/D6-photo-view.lua','maps/a-club/v5/D6-premium.lua',

  'maps/a-club/v5/90-premium-atmosphere.lua',
  'maps/a-club/v5/97-inspection-nav.lua',
  'maps/a-club/v5/98-inspection-polish.lua',
  'maps/a-club/v5/99-finalize.lua',
];

const systemFiles = [
  'maps/a-club/v5/systems/00-core.server.lua',
  'maps/a-club/v5/systems/10-dance.server.lua',
  'maps/a-club/v5/systems/20-lift.server.lua',
  'maps/a-club/v5/systems/30-monetization.server.lua',
  'maps/a-club/v5/systems/40-music.server.lua',
  'maps/a-club/v5/systems/50-venue-state.server.lua',
  'maps/a-club/v5/systems/60-support-board.server.lua',
  'maps/a-club/v5/systems/70-light-control.server.lua',
  'maps/a-club/v5/systems/99-runtime-qc.server.lua',
];

const uiFiles = [
  'maps/a-club/v5/ui-shell.client.lua',
  'maps/a-club/v5/ui-component-inspector.client.lua',
  'maps/a-club/v5/ui-shell-polish.client.lua',
  'maps/a-club/v5/ui-inspection-nav.client.lua',
  'maps/a-club/v5/ui-floating-dock.client.lua',
  'maps/a-club/v5/ui-container-dock.client.lua',
  'maps/a-club/v5/ui-live.client.lua',
  'maps/a-club/v5/ui-camera.client.lua',
  'maps/a-club/v5/ui-performance.client.lua',
];

const concat = files => files.map(file => `\n-- SOURCE FILE: ${file}\n${readLua(file)}`).join('\n');
const architectureLua = concat(zoneFiles);
const systemsLua = concat(systemFiles);
const uiLua = concat(uiFiles);

let xml = fs.readFileSync(placePath, 'utf8');
const begin = '<!-- BBYA_RUNTIME_BEGIN -->';
const end = '<!-- BBYA_RUNTIME_END -->';
xml = xml.replace(new RegExp(`${begin}[\\s\\S]*?${end}`, 'g'), '');

const runtime = `${begin}
<Item class="ServerScriptService" referent="RBXBBYAV53SSS">
  <Properties><string name="Name">ServerScriptService</string></Properties>
  <Item class="Script" referent="RBXBBYAV53ARCH">
    <Properties>
      <bool name="Disabled">false</bool>
      <string name="Name">BBYA_V5_3_MASTER_ARCHITECTURE</string>
      <ProtectedString name="Source"><![CDATA[${architectureLua}]]></ProtectedString>
    </Properties>
  </Item>
  <Item class="Script" referent="RBXBBYAV53SYSTEMS">
    <Properties>
      <bool name="Disabled">false</bool>
      <string name="Name">BBYA_V5_3_MASTER_SYSTEMS</string>
      <ProtectedString name="Source"><![CDATA[${systemsLua}]]></ProtectedString>
    </Properties>
  </Item>
</Item>
<Item class="StarterPlayer" referent="RBXBBYAV53STARTERPLAYER">
  <Properties><string name="Name">StarterPlayer</string></Properties>
  <Item class="StarterPlayerScripts" referent="RBXBBYAV53STARTERPLAYERSCRIPTS">
    <Properties><string name="Name">StarterPlayerScripts</string></Properties>
    <Item class="LocalScript" referent="RBXBBYAV53UI">
      <Properties>
        <bool name="Disabled">false</bool>
        <string name="Name">BBYA_V5_3_UNIFIED_UI</string>
        <ProtectedString name="Source"><![CDATA[${uiLua}]]></ProtectedString>
      </Properties>
    </Item>
  </Item>
</Item>
${end}`;

if (!xml.includes('</roblox>')) throw new Error('Invalid RBXLX: missing </roblox>');
xml = xml.replace('</roblox>', `${runtime}</roblox>`);
fs.writeFileSync(placePath, xml);
console.log(`[BBYA] V5.3 MASTER PLAN injected: ${zoneFiles.length} architecture/finish modules -> 1 Script; ${systemFiles.length} system modules -> 1 Script; ${uiFiles.length} UI modules -> 1 LocalScript.`);
