const fs=require('fs');
const path=require('path');

const root=process.cwd();
const outDir=process.argv[2]||'/tmp/bbya-rojo-live';
const serverDir=path.join(outDir,'ServerScriptService');
const starterDir=path.join(outDir,'StarterPlayerScripts');
fs.rmSync(outDir,{recursive:true,force:true});
fs.mkdirSync(serverDir,{recursive:true});
fs.mkdirSync(starterDir,{recursive:true});

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
const clientFiles=['maps/a-club/rebuild/70-ui.client.lua'];
for(const file of [...serverFiles,...clientFiles]){
  if(!fs.existsSync(path.join(root,file))) throw new Error(`Missing BBYA clean source: ${file}`);
  if(/\/v[0-9]+\//.test(file)) throw new Error(`Archived source forbidden: ${file}`);
}
const concat=files=>files.map(file=>`\n-- SOURCE FILE: ${file}\n${fs.readFileSync(path.join(root,file),'utf8')}`).join('\n');
fs.writeFileSync(path.join(serverDir,'BBYA_CLEAN_REBUILD_RUNTIME.server.lua'),concat(serverFiles));
fs.writeFileSync(path.join(starterDir,'BBYA_CLEAN_SOCIAL_UI.client.lua'),concat(clientFiles));

const project={
  name:'BBYA Social Hub',
  tree:{
    '$className':'DataModel',
    Workspace:{'$className':'Workspace'},
    Lighting:{'$className':'Lighting','$properties':{ClockTime:0.1,Brightness:2.7}},
    ReplicatedStorage:{'$className':'ReplicatedStorage'},
    ServerScriptService:{'$className':'ServerScriptService','$path':'ServerScriptService'},
    ServerStorage:{'$className':'ServerStorage'},
    StarterGui:{'$className':'StarterGui'},
    StarterPack:{'$className':'StarterPack'},
    StarterPlayer:{
      '$className':'StarterPlayer',
      StarterPlayerScripts:{'$className':'StarterPlayerScripts','$path':'StarterPlayerScripts'}
    },
    SoundService:{'$className':'SoundService'}
  }
};
fs.writeFileSync(path.join(outDir,'default.project.json'),JSON.stringify(project,null,2)+'\n');
console.log(`[BBYA ROJO] Prepared canonical build tree at ${outDir}`);
console.log(`[BBYA ROJO] ${serverFiles.length} server modules + ${clientFiles.length} client module; no archived V5/V6 modules.`);
