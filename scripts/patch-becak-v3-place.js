const fs=require('fs');
const path=require('path');
const root=process.cwd();
const placePath=path.join(root,'maps/becak-e-bike/place.rbxlx');
if(!fs.existsSync(placePath)) throw new Error('Missing Becak E-Bike place.rbxlx baseline');
let xml=fs.readFileSync(placePath,'utf8');
const esc=(s)=>String(s).replaceAll(']]>',']]]]><![CDATA[>');
const targets={
  BecakEBike_CityDetails:'maps/becak-e-bike/world.details.server.lua',
  BecakEBike_CityRealismArchitecture:'maps/becak-e-bike/city.realism.architecture.server.lua',
  BecakEBike_VehicleRealism:'maps/becak-e-bike/vehicle.realism.server.lua',
  BecakEBike_VehicleGeometryRealism:'maps/becak-e-bike/vehicle.geometry.realism.server.lua'
};
for(const [name,file] of Object.entries(targets)){
  const source=esc(fs.readFileSync(path.join(root,file),'utf8'));
  const safe=name.replace(/[.*+?^${}()|[\]\\]/g,'\\$&');
  const re=new RegExp(`(<string name="Name">${safe}<\\/string><bool name="Disabled">false<\\/bool><ProtectedString name="Source"><!\\[CDATA\\[)([\\s\\S]*?)(\\]\\]><\\/ProtectedString>)`);
  if(!re.test(xml)) throw new Error(`V3 patch target script missing in place.rbxlx: ${name}`);
  xml=xml.replace(re,`$1${source}$3`);
  console.log('[Becak V3] patched',name,'from',file);
}
for(const token of ['ACC_BecakWorldV3','BecakWorldV3VisualAuthority','ACC_BecakCityDetails','ACC_BecakVehicleRealism','ACC_BecakVehicleGeometryRealism']){
  if(!xml.includes(token)) throw new Error(`V3 patched place validation missing ${token}`);
}
fs.writeFileSync(placePath,xml);
console.log('[Becak V3] live place patch complete',Buffer.byteLength(xml),'bytes');
