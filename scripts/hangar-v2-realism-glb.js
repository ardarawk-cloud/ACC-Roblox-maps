const fs = require('fs');
const out = process.argv[2];
if (!out) throw new Error('usage: node hangar-v2-realism-glb.js <output.glb>');

const mats = [
  {name:'HangarSteel',c:[0.12,0.14,0.18,1],m:0.86,r:0.32},
  {name:'TrussSteel',c:[0.22,0.25,0.31,1],m:0.88,r:0.28},
  {name:'Concrete',c:[0.28,0.29,0.31,1],m:0.08,r:0.48},
  {name:'Apron',c:[0.20,0.21,0.23,1],m:0.06,r:0.58},
  {name:'JetSilver',c:[0.70,0.74,0.80,1],m:0.74,r:0.25},
  {name:'JetDark',c:[0.015,0.035,0.055,1],m:0.38,r:0.15},
  {name:'ClubBlack',c:[0.035,0.04,0.055,1],m:0.72,r:0.32},
  {name:'Cyan',c:[0.02,0.30,0.42,1],m:0.22,r:0.24},
  {name:'Magenta',c:[0.42,0.035,0.22,1],m:0.22,r:0.26},
  {name:'Amber',c:[0.58,0.30,0.04,1],m:0.30,r:0.30},
  {name:'Gold',c:[0.72,0.48,0.10,1],m:0.82,r:0.22},
  {name:'Silver',c:[0.50,0.55,0.63,1],m:0.85,r:0.22},
  {name:'Bronze',c:[0.44,0.23,0.09,1],m:0.78,r:0.28},
  {name:'Glass',c:[0.02,0.06,0.09,0.82],m:0.25,r:0.10,blend:true},
  {name:'Red',c:[0.48,0.025,0.03,1],m:0.58,r:0.18},
  {name:'Blue',c:[0.025,0.08,0.38,1],m:0.58,r:0.18},
  {name:'White',c:[0.72,0.74,0.78,1],m:0.52,r:0.22},
  {name:'Graphite',c:[0.06,0.065,0.075,1],m:0.66,r:0.25},
  {name:'Rubber',c:[0.018,0.018,0.02,1],m:0.10,r:0.82},
  {name:'Rim',c:[0.38,0.42,0.48,1],m:0.90,r:0.16},
  {name:'Green',c:[0.03,0.38,0.10,1],m:0.02,r:0.72},
  {name:'Yellow',c:[0.72,0.52,0.05,1],m:0.18,r:0.36},
  {name:'WarmWhite',c:[0.85,0.78,0.62,1],m:0.08,r:0.32}
];

function G(name, mat){ return {name,mat,p:[],n:[],i:[]}; }
function push(g,p,n){ g.p.push(...p); g.n.push(...n); return g.p.length/3-1; }
const add=(a,b)=>a.map((v,i)=>v+b[i]);
const sub=(a,b)=>a.map((v,i)=>v-b[i]);
const mul=(a,s)=>a.map(v=>v*s);
function len(a){return Math.hypot(...a)}
function norm(a){const l=len(a)||1;return a.map(v=>v/l)}
function cross(a,b){return[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]}
function quad(g,a,b,c,d,n,ds=true){const q=g.p.length/3;[a,b,c,d].forEach(p=>push(g,p,n));g.i.push(q,q+1,q+2,q,q+2,q+3);if(ds)g.i.push(q+2,q+1,q,q+3,q+2,q)}
function basis(c,a,l){return[c[0]+a[0][0]*l[0]+a[1][0]*l[1]+a[2][0]*l[2],c[1]+a[0][1]*l[0]+a[1][1]*l[1]+a[2][1]*l[2],c[2]+a[0][2]*l[0]+a[1][2]*l[1]+a[2][2]*l[2]]}
function boxB(g,c,s,a=[[1,0,0],[0,1,0],[0,0,1]]){const h=s.map(v=>v/2),pts=[];for(const z of[-1,1])for(const y of[-1,1])for(const x of[-1,1])pts.push(basis(c,a,[x*h[0],y*h[1],z*h[2]]));const p=(z,y,x)=>pts[z*4+y*2+x];quad(g,p(0,0,0),p(0,0,1),p(0,1,1),p(0,1,0),mul(a[2],-1));quad(g,p(1,0,1),p(1,0,0),p(1,1,0),p(1,1,1),a[2]);quad(g,p(0,0,0),p(0,1,0),p(1,1,0),p(1,0,0),mul(a[0],-1));quad(g,p(0,0,1),p(1,0,1),p(1,1,1),p(0,1,1),a[0]);quad(g,p(0,1,0),p(0,1,1),p(1,1,1),p(1,1,0),a[1]);quad(g,p(0,0,0),p(1,0,0),p(1,0,1),p(0,0,1),mul(a[1],-1))}
function box(g,c,s){boxB(g,c,s)}
function beam(g,a,b,t=2.4){const z=norm(sub(b,a)),ref=Math.abs(z[1])>.94?[1,0,0]:[0,1,0],x=norm(cross(ref,z)),y=norm(cross(z,x));boxB(g,mul(add(a,b),.5),[t,t,len(sub(b,a))],[x,y,z])}
function ry(p,y){const c=Math.cos(y),s=Math.sin(y);return[p[0]*c+p[2]*s,p[1],-p[0]*s+p[2]*c]}
function rbox(g,c,s,y){boxB(g,c,s,[[Math.cos(y),0,-Math.sin(y)],[0,1,0],[Math.sin(y),0,Math.cos(y)]])}
function ell(g,c,r,y=0,rings=18,segs=36){const ids=[];for(let a=0;a<=rings;a++){ids[a]=[];const ph=-Math.PI/2+a/rings*Math.PI,cp=Math.cos(ph),sp=Math.sin(ph);for(let b=0;b<segs;b++){const th=b/segs*Math.PI*2,nx=Math.cos(th)*cp,ny=sp,nz=Math.sin(th)*cp,lp=[nx*r[0],ny*r[1],nz*r[2]],rp=ry(lp,y);ids[a][b]=push(g,add(c,rp),ry(norm([nx/r[0],ny/r[1],nz/r[2]]),y))}}for(let a=0;a<rings;a++)for(let b=0;b<segs;b++){const nb=(b+1)%segs,A=ids[a][b],B=ids[a][nb],C=ids[a+1][nb],D=ids[a+1][b];g.i.push(A,B,C,A,C,D)}}
function cyl(g,c,r,h,axis='x',segs=24){const ids=[[],[]];for(let k=0;k<2;k++)for(let i=0;i<segs;i++){const t=i/segs*Math.PI*2,ca=Math.cos(t),sa=Math.sin(t);let p,n;if(axis==='x'){p=[c[0]+(k?1:-1)*h/2,c[1]+ca*r,c[2]+sa*r];n=[0,ca,sa]}else if(axis==='y'){p=[c[0]+ca*r,c[1]+(k?1:-1)*h/2,c[2]+sa*r];n=[ca,0,sa]}else{p=[c[0]+ca*r,c[1]+sa*r,c[2]+(k?1:-1)*h/2];n=[ca,sa,0]}ids[k][i]=push(g,p,n)}for(let i=0;i<segs;i++){const n=(i+1)%segs,A=ids[0][i],B=ids[0][n],C=ids[1][n],D=ids[1][i];g.i.push(A,B,C,A,C,D)}}
function loftRect(g,c,sections){const ids=[];for(const s of sections){const z=c[2]+s.z,w=s.w,b=c[1]+s.b,t=c[1]+s.t;ids.push([push(g,[c[0]-w,b,z],[-1,0,0]),push(g,[c[0]+w,b,z],[1,0,0]),push(g,[c[0]+w,t,z],[1,0,0]),push(g,[c[0]-w,t,z],[-1,0,0])])}for(let k=0;k<ids.length-1;k++){const a=ids[k],b=ids[k+1];quad(g,[...g.p.slice(a[0]*3,a[0]*3+3)],[...g.p.slice(b[0]*3,b[0]*3+3)],[...g.p.slice(b[3]*3,b[3]*3+3)],[...g.p.slice(a[3]*3,a[3]*3+3)],[-1,0,0]);quad(g,[...g.p.slice(a[1]*3,a[1]*3+3)],[...g.p.slice(a[2]*3,a[2]*3+3)],[...g.p.slice(b[2]*3,b[2]*3+3)],[...g.p.slice(b[1]*3,b[1]*3+3)],[1,0,0]);quad(g,[...g.p.slice(a[3]*3,a[3]*3+3)],[...g.p.slice(b[3]*3,b[3]*3+3)],[...g.p.slice(b[2]*3,b[2]*3+3)],[...g.p.slice(a[2]*3,a[2]*3+3)],[0,1,0]);quad(g,[...g.p.slice(a[0]*3,a[0]*3+3)],[...g.p.slice(a[1]*3,a[1]*3+3)],[...g.p.slice(b[1]*3,b[1]*3+3)],[...g.p.slice(b[0]*3,b[0]*3+3)],[0,-1,0])}}
function wingPrism(g,rootX,tipX,rootZ,tipZ,y,rootChord,tipChord,t){const ptsTop=[[rootX,y,rootZ-rootChord*.48],[tipX,y,tipZ-tipChord*.48],[tipX,y,tipZ+tipChord*.52],[rootX,y,rootZ+rootChord*.52]],ptsBot=ptsTop.map(p=>[p[0],p[1]-t,p[2]]);quad(g,...ptsTop,[0,1,0]);quad(g,ptsBot[3],ptsBot[2],ptsBot[1],ptsBot[0],[0,-1,0]);for(let i=0;i<4;i++){const n=(i+1)%4;quad(g,ptsTop[i],ptsBot[i],ptsBot[n],ptsTop[n],norm(cross(sub(ptsBot[i],ptsTop[i]),sub(ptsTop[n],ptsTop[i]))))}}
function verticalFin(g,c){const a=[c[0]-1.3,c[1],c[2]-14],b=[c[0]+1.3,c[1],c[2]-14],d=[c[0]-1.3,c[1],c[2]+16],e=[c[0]+1.3,c[1],c[2]+16],t1=[c[0]-1.0,c[1]+28,c[2]+10],t2=[c[0]+1.0,c[1]+28,c[2]+10];quad(g,a,d,t1,t1,[-1,0,0]);quad(g,b,t2,e,e,[1,0,0]);quad(g,a,b,e,d,[0,-1,0]);quad(g,d,e,t2,t1,[0,0,1]);quad(g,a,t1,t2,b,[0,0,-1])}

const W=420,D=380,WH=105,CH=158,FRONT=-190,BACK=190;
const shell=G('HangarMesh',0);box(shell,[0,-1.5,0],[W,3,D]);box(shell,[-W/2,WH/2,0],[6,WH,D]);box(shell,[W/2,WH/2,0],[6,WH,D]);box(shell,[0,WH/2,BACK],[W,WH,6]);box(shell,[-178,52,FRONT],[64,104,6]);box(shell,[178,52,FRONT],[64,104,6]);box(shell,[0,145,FRONT],[300,18,6]);for(let i=0;i<56;i++){const t0=i/56,t1=(i+1)/56,x0=-W/2+t0*W,x1=-W/2+t1*W,y0=WH+Math.sin(t0*Math.PI)*(CH-WH),y1=WH+Math.sin(t1*Math.PI)*(CH-WH);quad(shell,[x0,y0,FRONT],[x1,y1,FRONT],[x1,y1,BACK],[x0,y0,BACK],norm(cross(sub([x1,y1,FRONT],[x0,y0,FRONT]),sub([x0,y0,BACK],[x0,y0,FRONT]))))}
const truss=G('HangarTrussMesh',1);for(let r=0;r<17;r++){const z=FRONT+15+r/16*(D-30);box(truss,[-W/2+14,WH/2,z],[5,WH,5]);box(truss,[W/2-14,WH/2,z],[5,WH,5]);for(let s=0;s<30;s++){const t0=s/30,t1=(s+1)/30;beam(truss,[-W/2+14+t0*(W-28),WH+Math.sin(t0*Math.PI)*(CH-WH)-6,z],[-W/2+14+t1*(W-28),WH+Math.sin(t1*Math.PI)*(CH-WH)-6,z],3.2)}}
const floor=G('PolishedConcreteMesh',2);box(floor,[0,.15,0],[W-12,.3,D-12]);
const apron=G('OutdoorApronMesh',3);box(apron,[0,.12,-285],[W+18,.24,210]);
const markings=G('ApronMarkingsMesh',21);box(markings,[0,.30,-286],[2,.16,196]);for(const x of[-145,-75,75,145])box(markings,[x,.30,-286],[1.3,.16,165]);for(const z of[-230,-280,-330])box(markings,[0,.31,z],[350,.14,1.2]);
const dance=G('DanceFloorMesh',6);box(dance,[0,.55,-28],[170,.45,112]);for(const x of[-78,78])box(dance,[x,.82,-28],[2,.12,108]);

const jc=[0,18,66],jet=G('JetPlaneMesh',4);ell(jet,jc,[10.2,9.2,58],0,24,48);ell(jet,add(jc,[0,0,-50]),[8.5,7.4,17],0,18,40);wingPrism(jet,-7,-72,jc[2]-2,jc[2]+10,15,25,10,2.2);wingPrism(jet,7,72,jc[2]-2,jc[2]+10,15,25,10,2.2);wingPrism(jet,-4,-31,jc[2]+43,jc[2]+49,19,15,7,1.5);wingPrism(jet,4,31,jc[2]+43,jc[2]+49,19,15,7,1.5);verticalFin(jet,[0,25,jc[2]+44]);
const jetDark=G('JetGlassAndTrimMesh',5);ell(jetDark,add(jc,[0,3,-48]),[7.8,4.0,10],0,14,32);for(let i=0;i<10;i++){const z=jc[2]-18+i*5.2;rbox(jetDark,[-9.4,21,z],[.7,2.0,2.7],0);rbox(jetDark,[9.4,21,z],[.7,2.0,2.7],0)}rbox(jetDark,[0,18,jc[2]-13],[.8,6,9],0);
const engines=G('JetEngineMesh',17);for(const x of[-18,18]){cyl(engines,[x,13,jc[2]+25],4.8,18,'z',28);cyl(engines,[x,13,jc[2]+16.5],4.0,1.2,'z',28)}
const gear=G('JetLandingGearMesh',17);beam(gear,[0,11,jc[2]-34],[0,3,jc[2]-34],1.2);cyl(gear,[-2.1,3,jc[2]-34],2.2,1.2,'x',20);cyl(gear,[2.1,3,jc[2]-34],2.2,1.2,'x',20);for(const x of[-15,15]){beam(gear,[x,12,jc[2]+22],[x,3,jc[2]+22],1.4);cyl(gear,[x-1.8,3,jc[2]+22],2.5,1.2,'x',20);cyl(gear,[x+1.8,3,jc[2]+22],2.5,1.2,'x',20)}
const vip=G('JetVIPLoungeMesh',6);box(vip,[0,9,jc[2]+8],[12,1,42]);for(const side of[-1,1])for(let i=0;i<4;i++){rbox(vip,[side*4.3,11,jc[2]-4+i*9],[3.0,2.6,5.8],0)}
const stages=G('JetWingStagesMesh',17);box(stages,[-39,11,jc[2]+3],[38,1.6,20]);box(stages,[39,11,jc[2]+3],[38,1.6,20]);box(stages,[-39,15,jc[2]+12],[22,6,5]);box(stages,[39,14,jc[2]+12],[26,4.5,5]);

function carModel(name,c,bodyMat,classic,hyper){const body=G(name,bodyMat);const glass=G(name.replace(/(ClassicCar|Hypercar)/,'$1Glass'),13);const tire=G(name+'Tires',18);const rim=G(name+'Rims',19);const sections=classic?[{z:-16,w:6.6,b:0.8,t:3.1},{z:-12,w:7.0,b:0.8,t:3.8},{z:-5,w:7.2,b:0.8,t:4.1},{z:0,w:6.7,b:0.8,t:7.2},{z:7,w:6.6,b:0.8,t:7.3},{z:12,w:7.0,b:0.8,t:4.1},{z:16,w:6.7,b:0.8,t:3.4}]:[{z:-18,w:6.4,b:0.7,t:2.6},{z:-14,w:7.5,b:0.7,t:3.2},{z:-6,w:8.1,b:0.7,t:3.7},{z:0,w:7.1,b:0.7,t:6.6},{z:7,w:6.9,b:0.7,t:6.7},{z:14,w:7.7,b:0.7,t:3.4},{z:18,w:6.8,b:0.7,t:2.8}];loftRect(body,c,sections);const glassSec=classic?[{z:-2,w:6.0,b:4.2,t:6.9},{z:5,w:5.8,b:4.2,t:6.9},{z:9,w:5.6,b:4.0,t:6.3}]:[{z:-2,w:6.2,b:3.8,t:6.3},{z:5,w:5.9,b:3.8,t:6.4},{z:10,w:5.7,b:3.6,t:5.7}];loftRect(glass,c,glassSec);for(const dx of[-1,1])for(const dz of[-1,1]){const z=c[2]+dz*(classic?10.8:12.2),x=c[0]+dx*(classic?7.0:7.7);cyl(tire,[x,c[1]+2.2,z],2.7,1.8,'x',24);cyl(rim,[x,c[1]+2.2,z],1.55,1.92,'x',20)}if(hyper){rbox(body,[c[0],c[1]+4.2,c[2]+16.4],[12,0.6,2.2],0);rbox(body,[c[0],c[1]+5.2,c[2]+17.2],[1.1,2.1,1.1],0)}return[body,glass,tire,rim]}
const cars=[];cars.push(...carModel('ClassicCarLeftA',[-132,1.0,-270],14,true,false));cars.push(...carModel('ClassicCarLeftB',[-92,1.0,-270],15,true,false));cars.push(...carModel('HypercarRightA',[92,1.0,-270],16,false,true));cars.push(...carModel('HypercarRightB',[136,1.0,-270],14,false,true));

const baggage=G('BaggageClaimMesh',17);for(let i=0;i<14;i++){const a=i/14*Math.PI*2;const x=-132+Math.cos(a)*42,z=-70+Math.sin(a)*17;rbox(baggage,[x,3.0,z],[11,2.2,7],-a)}for(let i=0;i<7;i++)box(baggage,[-165+i*11,6.5,-70],[7,6,8]);
const photo=G('PhotoboothMesh',1);box(photo,[142,1,-70],[62,2,52]);box(photo,[170,25,-70],[3,48,52]);box(photo,[142,25,-95],[56,48,3]);box(photo,[145,15,-65],[32,2,2]);for(const x of[124,160]){beam(photo,[x,2,-48],[x,20,-48],1.2);cyl(photo,[x,22,-48],6.5,1.2,'z',28)}box(photo,[136,1,-315],[72,2,38]);box(photo,[168,24,-315],[3,46,38]);
const green=G('GreenScreenMesh',20);box(green,[170,25,-70],[.7,40,34]);
const shop=G('CornerShopMesh',17);box(shop,[-132,2,-315],[82,4,36]);box(shop,[-169,22,-315],[5,42,36]);box(shop,[-95,22,-315],[5,42,36]);box(shop,[-132,42,-315],[82,4,36]);box(shop,[-132,20,-333],[76,36,3]);box(shop,[-132,11,-296],[68,3,8]);for(let i=0;i<4;i++)box(shop,[-158+i*17,20,-330],[13,20,2]);
const track=G('PerimeterTrackMesh',17);box(track,[0,1.0,166],[W-30,1,12]);box(track,[0,1.0,-166],[W-30,1,12]);box(track,[-198,1.0,0],[12,1,D-26]);box(track,[198,1.0,0],[12,1,D-26]);
const donor=G('DonorGateAndPedestalsMesh',1);box(donor,[-92,28,-186],[9,56,9]);box(donor,[92,28,-186],[9,56,9]);box(donor,[0,53,-186],[190,7,8]);box(donor,[0,65,-187],[118,12,4]);
const gold=G('GoldPedestalMesh',10);box(gold,[0,5,-162],[16,10,16]);box(gold,[0,11,-162],[12,2,12]);
const silver=G('SilverPedestalMesh',11);box(silver,[-30,4,-162],[15,8,15]);box(silver,[-30,9,-162],[11,2,11]);
const bronze=G('BronzePedestalMesh',12);box(bronze,[30,3.5,-162],[15,7,15]);box(bronze,[30,8,-162],[11,2,11]);
const fixtures=G('LightingFixtureMesh',17);for(const z of[-150,-100,-50,0,50,100,150])for(const x of[-145,-95,-45,0,45,95,145]){rbox(fixtures,[x,94,z],[5.5,2.0,4.5],0);beam(fixtures,[x,92,z],[x,86,z],1.0)}
const service=G('ServiceEquipmentMesh',17);for(const x of[-170,170]){box(service,[x,3,115],[22,5,34]);for(const dz of[-11,11])cyl(service,[x-10,2,115+dz],2.3,1.4,'x',18);for(const dz of[-11,11])cyl(service,[x+10,2,115+dz],2.3,1.4,'x',18)}for(let i=0;i<4;i++){const x=-170+i*18;box(service,[x,5,145],[14,10,14])}

const geoms=[shell,truss,floor,apron,markings,dance,jet,jetDark,engines,gear,vip,stages,...cars,baggage,photo,green,shop,track,donor,gold,silver,bronze,fixtures,service];

function align4(n){return (n+3)&~3}
const chunks=[];let offset=0;const bufferViews=[],accessors=[],meshes=[],nodes=[];
function append(buf,target){const pad=align4(offset)-offset;if(pad){chunks.push(Buffer.alloc(pad));offset+=pad}const start=offset;chunks.push(buf);offset+=buf.length;const idx=bufferViews.length;bufferViews.push({buffer:0,byteOffset:start,byteLength:buf.length,target});return idx}
function accessor(view,componentType,count,type,min,max){const a={bufferView:view,componentType,count,type};if(min)a.min=min;if(max)a.max=max;const idx=accessors.length;accessors.push(a);return idx}
for(const g of geoms){if(!g.p.length||!g.i.length)continue;const pos=Float32Array.from(g.p),nor=Float32Array.from(g.n),ind=Uint32Array.from(g.i);const pbuf=Buffer.from(pos.buffer),nbuf=Buffer.from(nor.buffer),ibuf=Buffer.from(ind.buffer);const pv=append(pbuf,34962),nv=append(nbuf,34962),iv=append(ibuf,34963);let mn=[Infinity,Infinity,Infinity],mx=[-Infinity,-Infinity,-Infinity];for(let i=0;i<g.p.length;i+=3){for(let j=0;j<3;j++){mn[j]=Math.min(mn[j],g.p[i+j]);mx[j]=Math.max(mx[j],g.p[i+j])}}const pa=accessor(pv,5126,g.p.length/3,'VEC3',mn,mx),na=accessor(nv,5126,g.n.length/3,'VEC3'),ia=accessor(iv,5125,g.i.length,'SCALAR');const mi=meshes.length;meshes.push({name:g.name,primitives:[{attributes:{POSITION:pa,NORMAL:na},indices:ia,material:g.mat}]});nodes.push({name:g.name,mesh:mi})}
const materialDefs=mats.map(m=>({name:m.name,pbrMetallicRoughness:{baseColorFactor:m.c,metallicFactor:m.m,roughnessFactor:m.r},doubleSided:true,alphaMode:m.blend?'BLEND':'OPAQUE'}));
const gltf={asset:{version:'2.0',generator:'HANGAR v2 realism procedural mesh'},scene:0,scenes:[{nodes:nodes.map((_,i)=>i)}],nodes,meshes,materials:materialDefs,buffers:[{byteLength:align4(offset)}],bufferViews,accessors};
let bin=Buffer.concat(chunks);if(bin.length<align4(offset))bin=Buffer.concat([bin,Buffer.alloc(align4(offset)-bin.length)]);let json=Buffer.from(JSON.stringify(gltf));const jp=align4(json.length)-json.length;if(jp)json=Buffer.concat([json,Buffer.alloc(jp,0x20)]);const total=12+8+json.length+8+bin.length;const outBuf=Buffer.alloc(total);outBuf.writeUInt32LE(0x46546c67,0);outBuf.writeUInt32LE(2,4);outBuf.writeUInt32LE(total,8);outBuf.writeUInt32LE(json.length,12);outBuf.writeUInt32LE(0x4e4f534a,16);json.copy(outBuf,20);let o=20+json.length;outBuf.writeUInt32LE(bin.length,o);outBuf.writeUInt32LE(0x004e4942,o+4);bin.copy(outBuf,o+8);fs.writeFileSync(out,outBuf);console.log(JSON.stringify({ok:true,out,bytes:outBuf.length,geometries:geoms.length,nodes:nodes.length}));