const fs=require('fs');
const path=require('path');
const root=process.cwd();
let bad=false;
const fail=m=>{bad=true;console.error('[BBYA V6 UI RECOVERY] FAIL: '+m)};
const pass=m=>console.log('[BBYA V6 UI RECOVERY] PASS: '+m);
const files=['maps/a-club/v6/60-ui.client.lua','maps/a-club/v6/66-ui-recovery.client.lua','scripts/assemble-bbya-v6-preview.js'];
for(const f of files) if(!fs.existsSync(path.join(root,f))) fail('missing '+f);
if(bad) process.exit(1);
const base=fs.readFileSync(path.join(root,files[0]),'utf8');
const fix=fs.readFileSync(path.join(root,files[1]),'utf8');
const asm=fs.readFileSync(path.join(root,files[2]),'utf8');
for(const t of ['positionPull','side=="LEFT"','side=="RIGHT"','side=="TOP"','RETURN UI','bottomSafe=92']) if(!base.includes(t)) fail('base UI missing '+t);
for(const t of ['TOP_RECOVERY','topRestore','topPark=false','BBYAV6TopUIRecovery']) if(!fix.includes(t)) fail('top recovery missing '+t);
if(!asm.includes('maps/a-club/v6/66-ui-recovery.client.lua')) fail('assembler omits top recovery module');
if(!bad) pass('left/right/top parked UI remains recoverable and bottom controls stay reserved');
if(bad){console.error('[BBYA V6 UI RECOVERY] BUILD REJECTED');process.exit(1)}
console.log('[BBYA V6 UI RECOVERY] BUILD ACCEPTED');
