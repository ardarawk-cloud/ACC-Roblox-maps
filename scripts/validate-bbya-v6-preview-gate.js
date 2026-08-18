const fs=require('fs');
const path=require('path');
const root=process.cwd();
let failed=false;
const fail=m=>{failed=true;console.error(`[BBYA V6 GATE] FAIL: ${m}`)};
const pass=m=>console.log(`[BBYA V6 GATE] PASS: ${m}`);
const read=f=>fs.readFileSync(path.join(root,f),'utf8');

const gateFile='maps/a-club/v6/71-preview-gate.server.lua';
const assemblerFile='scripts/assemble-bbya-v6-preview.js';
const ciFile='.github/workflows/bbya-v6-ci.yml';
const publishFile='.github/workflows/publish-map.yml';
for(const f of [gateFile,assemblerFile,ciFile,publishFile]) if(!fs.existsSync(path.join(root,f))) fail(`missing ${f}`);
if(failed) process.exit(1);

const gate=read(gateFile),assembler=read(assemblerFile),ci=read(ciFile),publish=read(publishFile);

for(const token of ['BBYAV6PreviewCandidate','WAITING_QC','RUNTIME_PASS','REJECTED','BBYAV6RuntimeQC','BBYAV6SocialSeatCount','BBYAV6InteractiveFacilityCount']) {
 if(!gate.includes(token)) fail(`preview runtime gate missing: ${token}`);
}
if(!failed) pass('runtime candidate status is fail-closed behind actual runtime QC');

if(!assembler.includes('maps/a-club/v6/71-preview-gate.server.lua')) fail('preview assembler omits candidate gate');
const qc=assembler.indexOf('maps/a-club/v6/70-runtime-qc.server.lua');
const gateIndex=assembler.indexOf('maps/a-club/v6/71-preview-gate.server.lua');
if(!(qc>=0 && gateIndex>qc)) fail('preview gate is not ordered after runtime QC');
else pass('preview gate runs after runtime QC in deterministic server chunk');

// Cleanroom CI may assemble/upload only; it must not call Roblox publisher/injector.
for(const forbidden of ['scripts/publish-map.js','scripts/inject-bbya.js','ROBLOX_API_KEY','ROBLOX_OPEN_CLOUD']) {
 if(ci.includes(forbidden)) fail(`cleanroom CI contains live-publish capability: ${forbidden}`);
}
if(!ci.includes('bbya-v6-cleanroom-preview') || !ci.includes('actions/upload-artifact')) fail('cleanroom CI does not produce isolated preview artifact');
else pass('cleanroom CI is artifact-only with no Roblox credential/publish path');

// Production publish workflow remains main-only.
if(!publish.includes('branches: [main]')) fail('production publish workflow is not main-only');
if(/agent\/bbya-v6-cleanroom/.test(publish)) fail('production publish workflow explicitly references V6 branch');
else pass('live publish remains isolated to main branch');

if(failed){console.error('[BBYA V6 GATE] BUILD REJECTED');process.exit(1)}
console.log('[BBYA V6 GATE] PREVIEW ISOLATION ACCEPTED — LIVE PUBLISH STILL BLOCKED');
