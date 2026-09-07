const fs = require('fs');

const outPath = process.argv[2];
if (!outPath) throw new Error('usage: node hangar-full-mesh-v9-glb.js <output.glb>');

const materials = [
  { name: 'HangarSteel', color: [0.22,0.24,0.28,1], metallic: 0.86, roughness: 0.38 },
  { name: 'DarkSteel', color: [0.07,0.08,0.10,1], metallic: 0.9, roughness: 0.34 },
  { name: 'Concrete', color: [0.29,0.30,0.32,1], metallic: 0.06, roughness: 0.72 },
  { name: 'JetSilver', color: [0.83,0.85,0.89,1], metallic: 0.72, roughness: 0.28 },
  { name: 'JetAccent', color: [0.11,0.16,0.22,1], metallic: 0.62, roughness: 0.31 },
  { name: 'ClubDark', color: [0.055,0.06,0.075,1], metallic: 0.72, roughness: 0.38 },
  { name: 'WarmMetal', color: [0.34,0.23,0.14,1], metallic: 0.45, roughness: 0.46 },
  { name: 'Fixture', color: [0.69,0.72,0.78,1], metallic: 0.8, roughness: 0.25 },
  { name: 'Sign', color: [0.88,0.91,0.96,1], metallic: 0.18, roughness: 0.26 },
];

function geom(name, material) { return { name, material, p: [], n: [], i: [] }; }
function pushVertex(g, p, n) { g.p.push(p[0],p[1],p[2]); g.n.push(n[0],n[1],n[2]); return g.p.length/3-1; }
function addQuad(g,a,b,c,d,normal,doubleSided=true){
  const base=g.p.length/3;
  pushVertex(g,a,normal); pushVertex(g,b,normal); pushVertex(g,c,normal); pushVertex(g,d,normal);
  g.i.push(base,base+1,base+2,base,base+2,base+3);
  if(doubleSided) g.i.push(base+2,base+1,base,base+3,base+2,base);
}
function vadd(a,b){return[a[0]+b[0],a[1]+b[1],a[2]+b[2]];}
function vsub(a,b){return[a[0]-b[0],a[1]-b[1],a[2]-b[2]];}
function vmul(a,s){return[a[0]*s,a[1]*s,a[2]*s];}
function vdot(a,b){return a[0]*b[0]+a[1]*b[1]+a[2]*b[2];}
function vcross(a,b){return[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]];}
function vlen(a){return Math.hypot(a[0],a[1],a[2]);}
function vnorm(a){const l=vlen(a)||1;return[a[0]/l,a[1]/l,a[2]/l];}
function basisTransform(center,axes,local){return[
  center[0]+axes[0][0]*local[0]+axes[1][0]*local[1]+axes[2][0]*local[2],
  center[1]+axes[0][1]*local[0]+axes[1][1]*local[1]+axes[2][1]*local[2],
  center[2]+axes[0][2]*local[0]+axes[1][2]*local[1]+axes[2][2]*local[2],
];}
function addBoxBasis(g,center,size,axes=[[1,0,0],[0,1,0],[0,0,1]]){
  const h=[size[0]/2,size[1]/2,size[2]/2],pts=[];
  for(const z of[-1,1])for(const y of[-1,1])for(const x of[-1,1])pts.push(basisTransform(center,axes,[x*h[0],y*h[1],z*h[2]]));
  const p=(z,y,x)=>pts[z*4+y*2+x];
  addQuad(g,p(0,0,0),p(0,0,1),p(0,1,1),p(0,1,0),vmul(axes[2],-1));
  addQuad(g,p(1,0,1),p(1,0,0),p(1,1,0),p(1,1,1),axes[2]);
  addQuad(g,p(0,0,0),p(0,1,0),p(1,1,0),p(1,0,0),vmul(axes[0],-1));
  addQuad(g,p(0,0,1),p(1,0,1),p(1,1,1),p(0,1,1),axes[0]);
  addQuad(g,p(0,1,0),p(0,1,1),p(1,1,1),p(1,1,0),axes[1]);
  addQuad(g,p(0,0,0),p(1,0,0),p(1,0,1),p(0,0,1),vmul(axes[1],-1));
}
function addBox(g,center,size){addBoxBasis(g,center,size);}
function addBeam(g,a,b,thickness=3.5){
  const z=vnorm(vsub(b,a)); let ref=Math.abs(vdot(z,[0,1,0]))>0.94?[1,0,0]:[0,1,0];
  const x=vnorm(vcross(ref,z)),y=vnorm(vcross(z,x)),mid=vmul(vadd(a,b),0.5);
  addBoxBasis(g,mid,[thickness,thickness,vlen(vsub(b,a))],[x,y,z]);
}
function addEllipsoid(g,center,radii,rings=12,segments=24){
  const ids=[];
  for(let r=0;r<=rings;r++){
    ids[r]=[]; const phi=-Math.PI/2+(r/rings)*Math.PI,cp=Math.cos(phi),sp=Math.sin(phi);
    for(let s=0;s<segments;s++){
      const th=(s/segments)*Math.PI*2,nx=Math.cos(th)*cp,ny=sp,nz=Math.sin(th)*cp;
      const pos=[center[0]+nx*radii[0],center[1]+ny*radii[1],center[2]+nz*radii[2]];
      ids[r][s]=pushVertex(g,pos,vnorm([nx/radii[0],ny/radii[1],nz/radii[2]]));
    }
  }
  for(let r=0;r<rings;r++)for(let s=0;s<segments;s++){
    const n=(s+1)%segments,a=ids[r][s],b=ids[r][n],c=ids[r+1][n],d=ids[r+1][s]; g.i.push(a,b,c,a,c,d);
  }
}
function rotateY(p,yaw){const c=Math.cos(yaw),s=Math.sin(yaw);return[p[0]*c+p[2]*s,p[1],-p[0]*s+p[2]*c];}
function translateRotated(center,local,yaw){return vadd(center,rotateY(local,yaw));}
function addRotatedBox(g,center,size,yaw){
  const x=[Math.cos(yaw),0,-Math.sin(yaw)],y=[0,1,0],z=[Math.sin(yaw),0,Math.cos(yaw)]; addBoxBasis(g,center,size,[x,y,z]);
}

const W=360,D=280,WH=88,CH=126;
const shell=geom('HangarShellMesh',0);
addBox(shell,[0,-1.5,0],[W,3,D]); addBox(shell,[-W/2,WH/2,0],[5,WH,D]); addBox(shell,[W/2,WH/2,0],[5,WH,D]);
addBox(shell,[0,WH/2,D/2],[W,WH,5]); addBox(shell,[0,WH-10,-D/2],[W,20,5]);
for(let i=0;i<40;i++){
  const t0=i/40,t1=(i+1)/40,x0=-W/2+t0*W,x1=-W/2+t1*W,y0=WH+Math.sin(t0*Math.PI)*(CH-WH),y1=WH+Math.sin(t1*Math.PI)*(CH-WH);
  const a=[x0,y0,-D/2-2],b=[x1,y1,-D/2-2],c=[x1,y1,D/2+2],d=[x0,y0,D/2+2]; addQuad(shell,a,b,c,d,vnorm(vcross(vsub(b,a),vsub(d,a))),true);
}
const truss=geom('HangarTrussMesh',1);
for(let r=0;r<13;r++){
  const z=-D/2+12+(r/12)*(D-24); addBox(truss,[-W/2+10,WH/2,z],[5,WH,5]); addBox(truss,[W/2-10,WH/2,z],[5,WH,5]);
  for(let s=0;s<24;s++){
    const t0=s/24,t1=(s+1)/24,a=[-W/2+10+t0*(W-20),WH+Math.sin(t0*Math.PI)*(CH-WH)-5,z],b=[-W/2+10+t1*(W-20),WH+Math.sin(t1*Math.PI)*(CH-WH)-5,z]; addBeam(truss,a,b,4.2);
  }
}
const club=geom('ClubArchitectureMesh',5);
addBox(club,[0,3,115],[118,6,34]); addBox(club,[0,10,106],[42,14,10]); addBox(club,[0,18,117],[54,2,22]);
for(const side of[-1,1]){
  const x=side*132; addBox(club,[x,18,65],[54,4,80]); addBox(club,[x+side*27,32,65],[4,28,80]); addBox(club,[side*126,4,-48],[52,7,14]);
  addBox(club,[x-side*28,30,65],[2.4,2.4,80]); for(let k=0;k<9;k++)addBox(club,[x-side*28,24,27+k*10],[2.4,12,2.4]);
  for(let k=0;k<3;k++){addBox(club,[x-side*9,20,42+k*22],[17,3,7]);addBox(club,[x-side*9,23,45+k*22],[17,5,2.5]);}
}
for(const x of[-48,-24,0,24,48])addBox(club,[x,48,103],[3,3,46]); addBox(club,[0,48,82],[100,3,3]); addBox(club,[0,48,124],[100,3,3]);
function buildJet(name,center,yaw){
  const g=geom(name,3); addEllipsoid(g,center,[8.2,8.2,39],14,28); addRotatedBox(g,translateRotated(center,[0,-1,4],yaw),[76,2.2,20],yaw);
  addRotatedBox(g,translateRotated(center,[0,3,31],yaw),[36,1.8,12],yaw); addRotatedBox(g,translateRotated(center,[0,11,35],yaw),[3,22,14],yaw);
  addRotatedBox(g,translateRotated(center,[-11,-2,20],yaw),[6,6,14],yaw); addRotatedBox(g,translateRotated(center,[11,-2,20],yaw),[6,6,14],yaw); addRotatedBox(g,translateRotated(center,[0,3,-34],yaw),[11,4,10],yaw); return g;
}
const jetA=buildJet('PrivateJetLeftMesh',[-98,12,94],-7*Math.PI/180),jetB=buildJet('PrivateJetRightMesh',[98,12,94],7*Math.PI/180);
const heli=geom('HelicopterMesh',4); addEllipsoid(heli,[138,15,-18],[13,10,18],12,26); addBeam(heli,[138,16,-2],[138,18,39],5.5); addBox(heli,[138,27,-18],[82,0.9,2.8]); addBox(heli,[138,27,-18],[2.8,0.9,82]); addBox(heli,[138,20,40],[26,0.9,2.3]); addBox(heli,[138,7,-18],[3,1.4,28]);
const bars=geom('BarAndWarmMetalMesh',6); for(const side of[-1,1]){addBox(bars,[side*126,4,-48],[50,6.5,12]);for(let k=0;k<6;k++)addBox(bars,[side*(105+k*8),2.2,-35],[3.2,4.4,3.2]);}
const fixtures=geom('IndustrialFixtureMesh',7); for(const z of[-110,-62,-14,34,78])for(const x of[-135,-90,-45,0,45,90,135])addBox(fixtures,[x,79,z],[8,1.5,5.6]);
const sign=geom('HangarSignMesh',8); addBox(sign,[0,54,137],[94,18,1.4]);
const geoms=[shell,truss,club,jetA,jetB,heli,bars,fixtures,sign];

const chunks=[]; let byteLength=0; function align4(){while(byteLength%4){chunks.push(Buffer.from([0]));byteLength++;}} function appendBuffer(buf){align4();const offset=byteLength;chunks.push(buf);byteLength+=buf.length;return{offset,length:buf.length};}
const bufferViews=[],accessors=[],meshes=[],nodes=[];
function minMax3(arr){const min=[Infinity,Infinity,Infinity],max=[-Infinity,-Infinity,-Infinity];for(let i=0;i<arr.length;i+=3)for(let k=0;k<3;k++){min[k]=Math.min(min[k],arr[i+k]);max[k]=Math.max(max[k],arr[i+k]);}return{min,max};}
for(const g of geoms){
  const pos=Buffer.alloc(g.p.length*4);g.p.forEach((v,i)=>pos.writeFloatLE(v,i*4)); const nor=Buffer.alloc(g.n.length*4);g.n.forEach((v,i)=>nor.writeFloatLE(v,i*4)); const idx=Buffer.alloc(g.i.length*4);g.i.forEach((v,i)=>idx.writeUInt32LE(v,i*4));
  const bp=appendBuffer(pos),bn=appendBuffer(nor),bi=appendBuffer(idx),vp=bufferViews.push({buffer:0,byteOffset:bp.offset,byteLength:bp.length,target:34962})-1,vn=bufferViews.push({buffer:0,byteOffset:bn.offset,byteLength:bn.length,target:34962})-1,vi=bufferViews.push({buffer:0,byteOffset:bi.offset,byteLength:bi.length,target:34963})-1,mm=minMax3(g.p);
  const ap=accessors.push({bufferView:vp,componentType:5126,count:g.p.length/3,type:'VEC3',min:mm.min,max:mm.max})-1,an=accessors.push({bufferView:vn,componentType:5126,count:g.n.length/3,type:'VEC3'})-1,ai=accessors.push({bufferView:vi,componentType:5125,count:g.i.length,type:'SCALAR'})-1,mi=meshes.push({name:g.name,primitives:[{attributes:{POSITION:ap,NORMAL:an},indices:ai,material:g.material,mode:4}]})-1; nodes.push({name:g.name,mesh:mi});
}
align4(); const bin=Buffer.concat(chunks);
const gltf={asset:{version:'2.0',generator:'ACC Hangar Full Mesh v9 static GLB generator'},scene:0,scenes:[{nodes:nodes.map((_,i)=>i)}],nodes,meshes,materials:materials.map(m=>({name:m.name,doubleSided:true,pbrMetallicRoughness:{baseColorFactor:m.color,metallicFactor:m.metallic,roughnessFactor:m.roughness}})),buffers:[{byteLength:bin.length}],bufferViews,accessors};
let json=Buffer.from(JSON.stringify(gltf),'utf8');while(json.length%4)json=Buffer.concat([json,Buffer.from(' ')]);const total=12+8+json.length+8+bin.length,header=Buffer.alloc(12);header.writeUInt32LE(0x46546c67,0);header.writeUInt32LE(2,4);header.writeUInt32LE(total,8);const jh=Buffer.alloc(8);jh.writeUInt32LE(json.length,0);jh.writeUInt32LE(0x4e4f534a,4);const bh=Buffer.alloc(8);bh.writeUInt32LE(bin.length,0);bh.writeUInt32LE(0x004e4942,4);fs.writeFileSync(outPath,Buffer.concat([header,jh,json,bh,bin]));const stat=fs.statSync(outPath);if(stat.size<50000)throw new Error(`GLB unexpectedly small: ${stat.size}`);console.log(`HANGAR_V9_GLB_READY path=${outPath} bytes=${stat.size} meshes=${geoms.length}`);
