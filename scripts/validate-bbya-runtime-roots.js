const fs=require('fs');
const path=require('path');
const mapId=process.argv[2];
if(mapId!=='a-club')process.exit(0);
const root=process.cwd();
const systemDir=path.join(root,'maps/a-club/v5/systems');
const files=fs.readdirSync(systemDir).filter(x=>x.endsWith('.lua'));
let bad=[];
for(const file of files){
 const src=fs.readFileSync(path.join(systemDir,file),'utf8');
 if(src.includes('BBYA V5.2 MODULAR GREYBOX'))bad.push(file);
}
const core=fs.readFileSync(path.join(root,'maps/a-club/v5/00-core.lua'),'utf8');
if(!core.includes('BBYA V5.3 MASTER PLAN'))bad.push('00-core.lua: missing V5.3 root');
if(bad.length){console.error('[BBYA ROOT GUARD] FAIL:',bad.join(' | '));process.exit(1)}
console.log(`[BBYA ROOT GUARD] PASS • ${files.length} system modules use V5.3 master root contract`);
