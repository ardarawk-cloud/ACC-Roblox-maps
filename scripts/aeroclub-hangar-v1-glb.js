const fs=require('fs');
const out=process.argv[2];
if(!out) throw new Error('usage: node aeroclub-hangar-v1-glb.js <output.glb>');

const mats=[
{name:'HangarSteel',c:[0.19,0.21,0.25,1],m:.88,r:.34},
{name:'DarkSteel',c:[0.045,0.052,0.066,1],m:.92,r:.30},
{name:'PolishedConcrete',c:[0.28,0.29,0.31,1],m:.10,r:.34},
{name:'JetSilver',c:[0.78,0.81,0.86,1],m:.74,r:.24},
{name:'JetDark',c:[0.055,0.08,0.11,1],m:.52,r:.24},
{name:'Glass',c:[0.03,0.10,0.14,.72],m:.12,r:.10,alpha:'BLEND'},
{name:'ClubBlack',c:[0.035,0.04,0.052,1],m:.70,r:.34},
{name:'WarmMetal',c:[0.28,0.17,0.08,1],m:.44,r:.36},
{name:'WhiteFixture',c:[0.78,0.80,0.84,1],m:.68,r:.24},
{name:'Gold',c:[0.78,0.53,0.12,1],m:.82,r:.24},
{name:'Silver',c:[0.58,0.62,0.68,1],m:.86,r:.22},
{name:'Bronze',c:[0.50,0.28,0.12,1],m:.80,r:.26},
{name:'GreenScreen',c:[0.05,0.50,0.11,1],m:.02,r:.78},
{name:'CarRed',c:[0.46,0.03,0.04,1],m:.54,r:.22},
{name:'CarBlue',c:[0.03,0.10,0.34,1],m:.54,r:.22},
{name:'CarWhite',c:[0.72,0.74,0.78,1],m:.46,r:.26},
];
function G(name,mat){return{name,mat,p:[],n:[],i:[]}}
function push(g,p,n){g.p.push(...p);g.n.push(...n);return g.p.length/3-1}
const add=(a,b)=>a.map((v,i)=>v+b[i]), sub=(a,b)=>a.map((v,i)=>v-b[i]), mul=(a,s)=>a.map(v=>v*s);
function len(a){return Math.hypot(...a)} function norm(a){const l=len(a)||1;return a.map(v=>v/l)}
function cross(a,b){return[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]}
function quad(g,a,b,c,d,n,ds=true){const q=g.p.length/3;[a,b,c,d].forEach(p=>push(g,p,n));g.i.push(q,q+1,q+2,q,q+2,q+3);if(ds)g.i.push(q+2,q+1,q,q+3,q+2,q)}
function basis(center,axes,l){return[center[0]+axes[0][0]*l[0]+axes[1][0]*l[1]+axes[2][0]*l[2],center[1]+axes[0][1]*l[0]+axes[1][1]*l[1]+axes[2][1]*l[2],center[2]+axes[0][2]*l[0]+axes[1][2]*l[1]+axes[2][2]*l[2]]}
function boxB(g,c,s,a=[[1,0,0],[0,1,0],[0,0,1]]){const h=s.map(v=>v/2),pts=[];for(const z of[-1,1])for(const y of[-1,1])for(const x of[-1,1])pts.push(basis(c,a,[x*h[0],y*h[1],z*h[2]]));const p=(z,y,x)=>pts[z*4+y*2+x];quad(g,p(0,0,0),p(0,0,1),p(0,1,1),p(0,1,0),mul(a[2],-1));quad(g,p(1,0,1),p(1,0,0),p(1,1,0),p(1,1,1),a[2]);quad(g,p(0,0,0),p(0,1,0),p(1,1,0),p(1,0,0),mul(a[0],-1));quad(g,p(0,0,1),p(1,0,1),p(1,1,1),p(0,1,1),a[0]);quad(g,p(0,1,0),p(0,1,1),p(1,1,1),p(1,1,0),a[1]);quad(g,p(0,0,0),p(1,0,0),p(1,0,1),p(0,0,1),mul(a[1],-1))}
function box(g,c,s){boxB(g,c,s)}
function beam(g,a,b,t=3){const z=norm(sub(b,a)),ref=Math.abs(z[1])>.94?[1,0,0]:[0,1,0],x=norm(cross(ref,z)),y=norm(cross(z,x));boxB(g,mul(add(a,b),.5),[t,t,len(sub(b,a))],[x,y,z])}
function ry(p,y){const c=Math.cos(y),s=Math.sin(y);return[p[0]*c+p[2]*s,p[1],-p[0]*s+p[2]*c]}
function rbox(g,c,s,y){boxB(g,c,s,[[Math.cos(y),0,-Math.sin(y)],[0,1,0],[Math.sin(y),0,Math.cos(y)]])}
function ell(g,c,r,y=0,rings=16,segs=32){const ids=[];for(let a=0;a<=rings;a++){ids[a]=[];const ph=-Math.PI/2+a/rings*Math.PI,cp=Math.cos(ph),sp=Math.sin(ph);for(let b=0;b<segs;b++){const th=b/segs*Math.PI*2,nx=Math.cos(th)*cp,ny=sp,nz=Math.sin(th)*cp;const lp=[nx*r[0],ny*r[1],nz*r[2]],rp=ry(lp,y);ids[a][b]=push(g,add(c,rp),ry(norm([nx/r[0],ny/r[1],nz/r[2]]),y))}}for(let a=0;a<rings;a++)for(let b=0;b<segs;b++){const nb=(b+1)%segs,A=ids[a][b],B=ids[a][nb],C=ids[a+1][nb],D=ids[a+1][b];g.i.push(A,B,C,A,C,D)}}
function cyl(g,c,r,h,axis='y',segs=24){const ids=[[],[]];for(let k=0;k<2;k++)for(let i=0;i<segs;i++){const t=i/segs*Math.PI*2,ca=Math.cos(t),sa=Math.sin(t);let p,n;if(axis==='x'){p=[c[0]+(k?1:-1)*h/2,c[1]+ca*r,c[2]+sa*r];n=[0,ca,sa]}else if(axis==='z'){p=[c[0]+ca*r,c[1]+sa*r,c[2]+(k?1:-1)*h/2];n=[ca,sa,0]}else{p=[c[0]+ca*r,c[1]+(k?1:-1)*h/2,c[2]+sa*r];n=[ca,0,sa]}ids[k][i]=push(g,p,n)}for(let i=0;i<segs;i++){const n=(i+1)%segs,A=ids[0][i],B=ids[0][n],C=ids[1][n],D=ids[1][i];g.i.push(A,B,C,A,C,D)}}

const W=390,D=340,WH=92,CH=142,FRONT=-170,BACK=170;
const shell=G('HangarMesh',0);box(shell,[0,-1.5,0],[W,3,D]);box(shell,[-W/2,WH/2,0],[5,WH,D]);box(shell,[W/2,WH/2,0],[5,WH,D]);box(shell,[0,WH/2,BACK],[W,WH,5]);
// partially open front steel door leaves a broad center opening
box(shell,[-155,45,FRONT],[80,90,5]);box(shell,[155,45,FRONT],[80,90,5]);box(shell,[0,130,FRONT],[230,24,5]);
for(let i=0;i<48;i++){const t0=i/48,t1=(i+1)/48,x0=-W/2+t0*W,x1=-W/2+t1*W,y0=WH+Math.sin(t0*Math.PI)*(CH-WH),y1=WH+Math.sin(t1*Math.PI)*(CH-WH);quad(shell,[x0,y0,FRONT-2],[x1,y1,FRONT-2],[x1,y1,BACK+2],[x0,y0,BACK+2],norm(cross(sub([x1,y1,FRONT-2],[x0,y0,FRONT-2]),sub([x0,y0,BACK+2],[x0,y0,FRONT-2]))))}
const truss=G('HangarTrussMesh',1);for(let r=0;r<15;r++){const z=FRONT+14+r/14*(D-28);box(truss,[-W/2+12,WH/2,z],[5,WH,5]);box(truss,[W/2-12,WH/2,z],[5,WH,5]);for(let s=0;s<28;s++){const t0=s/28,t1=(s+1)/28;beam(truss,[-W/2+12+t0*(W-24),WH+Math.sin(t0*Math.PI)*(CH-WH)-6,z],[-W/2+12+t1*(W-24),WH+Math.sin(t1*Math.PI)*(CH-WH)-6,z],3.6)}}
const floor=G('PolishedConcreteMesh',2);box(floor,[0,.2,0],[W-8,.4,D-8]);

const jet=G('JetPlaneMesh',3);const jc=[0,14,88],jy=0;ell(jet,jc,[9.5,9,48],jy,18,36);rbox(jet,add(jc,[0,-1,2]),[104,2.4,24],jy);rbox(jet,add(jc,[0,4,39]),[42,2,15],jy);rbox(jet,add(jc,[0,13,43]),[3.2,26,16],jy);rbox(jet,add(jc,[-14,-2,26]),[7,7,15],jy);rbox(jet,add(jc,[14,-2,26]),[7,7,15],jy);
const jetDark=G('JetGlassAndTrimMesh',4);rbox(jetDark,add(jc,[0,3,-41]),[13,5,10],jy);for(let k=-3;k<=3;k++){rbox(jetDark,add(jc,[k*3.2,3,-8+k*.1]),[2.2,2,1],jy)}
const jetVip=G('JetVIPLoungeMesh',6);box(jetVip,[0,7,96],[11,1,54]);for(const side of[-1,1])for(let i=0;i<4;i++)box(jetVip,[side*4.1,9,82+i*10],[3.4,2.4,6]);
const wingStages=G('JetWingStagesMesh',6);box(wingStages,[-31,10,88],[37,2,18]);box(wingStages,[31,10,88],[37,2,18]);box(wingStages,[-31,13,96],[18,5,5]);box(wingStages,[31,12.5,96],[24,4,5]);

function car(name,c,y,mat,classic=false){const g=G(name,mat);rbox(g,[c[0],c[1]+2.3,c[2]],[classic?15:17,3.6,classic?30:34],y);rbox(g,[c[0],c[1]+5.1,c[2]+(classic?1:2)],[classic?13:12,4.6,classic?15:16],y);for(const dx of[-1,1])for(const dz of[-1,1]){const p=add(c,ry([dx*(classic?7:7.5),1.7,dz*(classic?10:11)],y));cyl(g,p,2.3,1.7,'x',18)}return g}
const classicA=car('ClassicCarLeftA',[-118,2,-220],0,15,true),classicB=car('ClassicCarLeftB',[-82,2,-220],0,14,true),hyperA=car('HypercarRightA',[92,2,-220],0,13,false),hyperB=car('HypercarRightB',[130,2,-220],0,14,false);

const zones=G('InteractiveZoneMesh',6);
// baggage conveyor indoor left
box(zones,[-125,3,-55],[92,3,34]);box(zones,[-168,7,-55],[3,11,34]);box(zones,[-82,7,-55],[3,11,34]);for(let i=0;i<8;i++)box(zones,[-158+i*10.5,6,-55],[7,5,9]);
// indoor photobooth right
box(zones,[134,1,-55],[58,2,52]);box(zones,[158,28,-55],[3,54,52]);box(zones,[134,28,-80],[50,54,3]);
// corner shop outdoor left
box(zones,[-125,4,-275],[74,8,30]);for(let i=0;i<4;i++)box(zones,[-151+i*18,13,-266],[14,18,4]);
// outdoor photobooth right
box(zones,[128,1,-276],[70,2,34]);box(zones,[158,25,-276],[3,48,34]);
const green=G('GreenScreenMesh',12);box(green,[158,25,-55],[.8,42,34]);

const track=G('PerimeterTrackMesh',7);box(track,[0,1.1,150],[W-22,1,12]);box(track,[0,1.1,-150],[W-22,1,12]);box(track,[-184,1.1,0],[12,1,D-22]);box(track,[184,1.1,0],[12,1,D-22]);
const donor=G('DonorGateAndPedestalsMesh',1);box(donor,[0,34,-174],[170,8,5]);box(donor,[0,47,-174],[130,18,3]);box(donor,[-34,4,-150],[20,8,20]);box(donor,[0,4,-150],[20,8,20]);box(donor,[34,4,-150],[20,8,20]);
const gold=G('GoldPedestalMesh',9);box(gold,[0,9,-150],[14,2,14]);const silver=G('SilverPedestalMesh',10);box(silver,[-34,9,-150],[14,2,14]);const bronze=G('BronzePedestalMesh',11);box(bronze,[34,9,-150],[14,2,14]);

const fixtures=G('LightingFixtureMesh',8);for(const z of[-120,-70,-20,30,80,125])for(const x of[-135,-90,-45,0,45,90,135])box(fixtures,[x,84,z],[7,1.4,5]);for(const x of[-48,-24,0,24,48])box(fixtures,[x,58,116],[4,4,5]);

const geoms=[shell,truss,floor,jet,jetDark,jetVip,wingStages,classicA,classicB,hyperA,hyperB,zones,green,track,donor,gold,silver,bronze,fixtures];
const chunks=[];let bytes=0;function align(){while(bytes%4){chunks.push(Buffer.from([0]));bytes++}}function append(b){align();const o=bytes;chunks.push(b);bytes+=b.length;return{o,l:b.length}}
const bvs=[],acs=[],meshes=[],nodes=[];function mm(a){const mn=[Infinity,Infinity,Infinity],mx=[-Infinity,-Infinity,-Infinity];for(let i=0;i<a.length;i+=3)for(let k=0;k<3;k++){mn[k]=Math.min(mn[k],a[i+k]);mx[k]=Math.max(mx[k],a[i+k])}return{mn,mx}}
for(const g of geoms){const pb=Buffer.alloc(g.p.length*4),nb=Buffer.alloc(g.n.length*4),ib=Buffer.alloc(g.i.length*4);g.p.forEach((v,i)=>pb.writeFloatLE(v,i*4));g.n.forEach((v,i)=>nb.writeFloatLE(v,i*4));g.i.forEach((v,i)=>ib.writeUInt32LE(v,i*4));const P=append(pb),N=append(nb),I=append(ib),vp=bvs.push({buffer:0,byteOffset:P.o,byteLength:P.l,target:34962})-1,vn=bvs.push({buffer:0,byteOffset:N.o,byteLength:N.l,target:34962})-1,vi=bvs.push({buffer:0,byteOffset:I.o,byteLength:I.l,target:34963})-1,M=mm(g.p),ap=acs.push({bufferView:vp,componentType:5126,count:g.p.length/3,type:'VEC3',min:M.mn,max:M.mx})-1,an=acs.push({bufferView:vn,componentType:5126,count:g.n.length/3,type:'VEC3'})-1,ai=acs.push({bufferView:vi,componentType:5125,count:g.i.length,type:'SCALAR'})-1,mi=meshes.push({name:g.name,primitives:[{attributes:{POSITION:ap,NORMAL:an},indices:ai,material:g.mat,mode:4}]})-1;nodes.push({name:g.name,mesh:mi})}
align();const bin=Buffer.concat(chunks);const gltf={asset:{version:'2.0',generator:'AeroClub Hangar v1 deterministic GLB'},scene:0,scenes:[{nodes:nodes.map((_,i)=>i)}],nodes,meshes,materials:mats.map(x=>({name:x.name,pbrMetallicRoughness:{baseColorFactor:x.c,metallicFactor:x.m,roughnessFactor:x.r},alphaMode:x.alpha||'OPAQUE',doubleSided:true})),buffers:[{byteLength:bin.length}],bufferViews:bvs,accessors:acs};let js=Buffer.from(JSON.stringify(gltf));while(js.length%4)js=Buffer.concat([js,Buffer.from(' ')]);let bb=bin;while(bb.length%4)bb=Buffer.concat([bb,Buffer.from([0])]);const total=12+8+js.length+8+bb.length,glb=Buffer.alloc(total);glb.writeUInt32LE(0x46546c67,0);glb.writeUInt32LE(2,4);glb.writeUInt32LE(total,8);glb.writeUInt32LE(js.length,12);glb.writeUInt32LE(0x4e4f534a,16);js.copy(glb,20);let o=20+js.length;glb.writeUInt32LE(bb.length,o);glb.writeUInt32LE(0x004e4942,o+4);bb.copy(glb,o+8);fs.writeFileSync(out,glb);console.log(`AEROCLUB_GLB_OK bytes=${glb.length} nodes=${nodes.length}`);
