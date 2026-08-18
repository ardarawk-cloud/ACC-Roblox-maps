const fs=require('fs');
const path=require('path');
const root=process.cwd();
let failed=false;
const fail=m=>{failed=true;console.error(`[BBYA V6 CLIENT] FAIL: ${m}`)};
const pass=m=>console.log(`[BBYA V6 CLIENT] PASS: ${m}`);
const read=f=>fs.readFileSync(path.join(root,f),'utf8');

const files={
 ui:'maps/a-club/v6/60-ui.client.lua',
 dance:'maps/a-club/v6/62-dance-ui.client.lua',
 commerce:'maps/a-club/v6/63-commerce-ui.client.lua',
 bridge:'maps/a-club/v6/64-physical-ui-bridge.client.lua',
 perf:'maps/a-club/v6/65-performance.client.lua',
 qc:'maps/a-club/v6/70-runtime-qc.server.lua',
 assembler:'scripts/assemble-bbya-v6-preview.js',
};
for(const [k,f] of Object.entries(files)) if(!fs.existsSync(path.join(root,f))) fail(`missing ${k}: ${f}`);
if(failed) process.exit(1);

const ui=read(files.ui),dance=read(files.dance),commerce=read(files.commerce),bridge=read(files.bridge),perf=read(files.perf),qc=read(files.qc),assembler=read(files.assembler);

// Floating-window recovery / mobile-safe contract.
for(const token of ['ScrollingFrame','positionPull','side=="LEFT"','side=="RIGHT"','side=="TOP"','RETURN UI','CLEAN VIEW','bottomSafe=92']) {
 if(!ui.includes(token)) fail(`UI recovery/safe-area token missing: ${token}`);
}
if(/Visible\s*=\s*false[^\n]*Parked/.test(ui)) fail('park logic appears to hide parked panel');
else pass('floating panels remain recoverable and reserve bottom controls');

if(!ui.includes('TouchMoved') || !ui.includes('MouseButton2') || !ui.includes('moveState={F=false,B=false,L=false,R=false,U=false,D=false}')) fail('mobile/desktop freecam input contract incomplete');
else pass('outfit/freecam controls cover touch and desktop');

if(!dance.includes('launch.SOCIAL.Text="DANCE"') || !dance.includes('SYNC NEARBY')) fail('approved left-rail Dance Studio parity missing');
if(!commerce.includes('PENDING') || !commerce.includes('PromptProductPurchase')) fail('commerce UI pending/official-ID behavior missing');
if(!bridge.includes('OpenPanel.OnClientEvent')) fail('physical-space UI bridge missing');
if(!failed) pass('Dance/commerce/physical UI modules are connected to unified shell');

// Performance may touch decorative lights only, never critical show-off fills.
for(const token of ['BBYADecorativeLight','BBYACriticalFill','MOBILE_SAFE','DESKTOP_FULL','BBYAV6ClientDisabledCriticalFill']) {
 if(!perf.includes(token)) fail(`performance contract missing: ${token}`);
}
if(!perf.includes('parent:GetAttribute("BBYACriticalFill")~=true')) fail('performance selector does not explicitly exempt critical avatar fill');
if(/Lighting\.Brightness\s*=|ExposureCompensation\s*=|Ambient\s*=/.test(perf)) fail('client performance module modifies global venue exposure/ambient');
else pass('mobile profile reduces only tagged decorative cost, not global brightness');

// Runtime QC must include finished/social/access gates, not greybox-only checks.
for(const token of ['BBYAV6GroundFinish','BBYAV6VIPFinish','BBYAV6RooftopFinish','BBYAV6FunctionalSocialSeats','BBYAV6VIPLiftThreshold','BBYAV6PhysicalUIPrompts','BBYAV6SocialSeatCount','C2 LIFT VIP BARRIER']) {
 if(!qc.includes(token)) fail(`runtime QC missing final-build gate: ${token}`);
}
if(!failed) pass('runtime QC rejects unfinished/socially-empty/access-incomplete build');

if(!assembler.includes('maps/a-club/v6/65-performance.client.lua')) fail('preview assembler omits adaptive performance client');
if(!assembler.includes('BBYA_V6_CLEANROOM_RUNTIME') || !assembler.includes('BBYA_V6_UNIFIED_UI')) fail('assembler not using deterministic V6 runtime names');
else pass('client performance module is included in isolated preview assembly');

if(failed){console.error('[BBYA V6 CLIENT] BUILD REJECTED');process.exit(1)}
console.log('[BBYA V6 CLIENT] BUILD ACCEPTED — CLIENT SAFETY/PERFORMANCE CONTRACT SATISFIED');
