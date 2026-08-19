const fs=require('fs');
const path=require('path');

const root=process.cwd();
const outDir=process.argv[2]||'/tmp/bbya-rojo-live';
const serverDir=path.join(outDir,'ServerScriptService');
const starterDir=path.join(outDir,'StarterPlayerScripts');
fs.rmSync(outDir,{recursive:true,force:true});
fs.mkdirSync(serverDir,{recursive:true});
fs.mkdirSync(starterDir,{recursive:true});

// BBYA V7 CLEAN LIVE CONTRACT
// Keep the live tree identical to the V7 clean preview contract. Do not re-add
// owner-layout fixes, old street/VIP overlays, live-service overlays or hybrid UI layers.
const serverFiles=[
  'maps/a-club/rebuild/00-core.lua',
  'maps/a-club/rebuild/10-architecture.lua',
  'maps/a-club/rebuild/15-premium-exterior.lua',
  'maps/a-club/rebuild/20-furnishing.lua',
  'maps/a-club/rebuild/25-premium-interior.lua',
  'maps/a-club/rebuild/35-circulation.lua',
  'maps/a-club/rebuild/30-lighting.lua',
  'maps/a-club/rebuild/40-runtime.server.lua',
  'maps/a-club/rebuild/60-social-systems.server.lua',
  'maps/a-club/rebuild/50-qc.server.lua',
  'maps/a-club/rebuild/80-release-gate.server.lua',
];
const clientFiles=[
  'maps/a-club/rebuild/70-ui.client.lua',
];
for(const file of [...serverFiles,...clientFiles]){
  if(!fs.existsSync(path.join(root,file))) throw new Error(`Missing BBYA V7 clean source: ${file}`);
  if(/\/v[0-9]+\//.test(file)) throw new Error(`Archived source forbidden: ${file}`);
}

const commercePath=process.env.BBYA_COMMERCE_JSON||'/tmp/bbya-commerce.json';
let commerce={
  vipGamePassId:0,
  supportProducts:{'5':0,'10':0,'50':0,'100':0,'500':0,'10000':0},
  supportKinds:{'5':'none','10':'none','50':'none','100':'none','500':'none','10000':'none'},
};
if(fs.existsSync(commercePath)){
  try{ commerce={...commerce,...JSON.parse(fs.readFileSync(commercePath,'utf8'))}; }
  catch(err){ console.warn(`[BBYA ROJO] Commerce JSON unreadable: ${err.message}`); }
}
const sp=commerce.supportProducts||{};
const sk=commerce.supportKinds||{};
const n=v=>Number(v)||0;
const kind=v=>['developerProduct','gamePass'].includes(String(v))?String(v):'none';
const commerceBootstrap=`\n-- DEPLOY RESOLVED COMMERCE BOOTSTRAP\n_G.BBYA_COMMERCE_RESOLVED={\n  vipGamePassId=${n(commerce.vipGamePassId)},\n  supportProducts={\n    [5]=${n(sp['5']??sp[5])},\n    [10]=${n(sp['10']??sp[10])},\n    [50]=${n(sp['50']??sp[50])},\n    [100]=${n(sp['100']??sp[100])},\n    [500]=${n(sp['500']??sp[500])},\n    [10000]=${n(sp['10000']??sp[10000])},\n  },\n  supportKinds={\n    [5]=${JSON.stringify(kind(sk['5']??sk[5]))},\n    [10]=${JSON.stringify(kind(sk['10']??sk[10]))},\n    [50]=${JSON.stringify(kind(sk['50']??sk[50]))},\n    [100]=${JSON.stringify(kind(sk['100']??sk[100]))},\n    [500]=${JSON.stringify(kind(sk['500']??sk[500]))},\n    [10000]=${JSON.stringify(kind(sk['10000']??sk[10000]))},\n  }\n}\n`;

const concat=files=>files.map(file=>`\n-- SOURCE FILE: ${file}\n${fs.readFileSync(path.join(root,file),'utf8')}`).join('\n');
fs.writeFileSync(path.join(serverDir,'BBYA_V7_CLEAN_RUNTIME.server.lua'),commerceBootstrap+concat(serverFiles));
fs.writeFileSync(path.join(starterDir,'BBYA_V7_CLEAN_UI.client.lua'),concat(clientFiles));

const project={
  name:'BBYA Social Hub V7 Clean',
  tree:{
    '$className':'DataModel',
    Workspace:{'$className':'Workspace'},
    Lighting:{'$className':'Lighting','$properties':{ClockTime:0.1,Brightness:2.7}},
    ReplicatedStorage:{'$className':'ReplicatedStorage'},
    ServerScriptService:{'$className':'ServerScriptService','$path':'ServerScriptService'},
    ServerStorage:{'$className':'ServerStorage'},
    StarterGui:{'$className':'StarterGui'},
    StarterPack:{'$className':'StarterPack'},
    StarterPlayer:{'$className':'StarterPlayer',StarterPlayerScripts:{'$className':'StarterPlayerScripts','$path':'StarterPlayerScripts'}},
    SoundService:{'$className':'SoundService'}
  }
};
fs.writeFileSync(path.join(outDir,'default.project.json'),JSON.stringify(project,null,2)+'\n');
console.log(`[BBYA V7 LIVE] Prepared clean canonical build tree at ${outDir}`);
console.log(`[BBYA V7 LIVE] ${serverFiles.length} server modules + ${clientFiles.length} client module; legacy overlays excluded.`);
