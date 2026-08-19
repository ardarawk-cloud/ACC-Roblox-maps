const fs=require('fs');

const universeId=process.env.BBYA_UNIVERSE_ID||'8116636513';
const apiKey=process.env.ROBLOX_API_KEY||'';
const out=process.env.BBYA_COMMERCE_JSON||'/tmp/bbya-commerce.json';
const desired=[5,10,50,100,500];
desired.push(10000);

function itemsFrom(body,keys){
  for(const key of keys){ if(Array.isArray(body?.[key])) return body[key]; }
  if(Array.isArray(body)) return body;
  return [];
}
function deepValue(obj,keys,type){
  const seen=new Set();
  function walk(v,depth){
    if(depth>6||v==null||typeof v!=='object'||seen.has(v)) return null;
    seen.add(v);
    for(const key of keys){
      const value=v[key];
      if(type==='number'){
        const n=Number(value); if(Number.isFinite(n)&&n>0) return n;
      }else if(type==='string'&&typeof value==='string'&&value.trim()) return value.trim();
    }
    for(const value of Object.values(v)){ const hit=walk(value,depth+1); if(hit!=null) return hit; }
    return null;
  }
  return walk(obj,0);
}
function idOf(x){ return deepValue(x,['id','productId','developerProductId','gamePassId','assetId'],'number')||0; }
function nameOf(x){ return deepValue(x,['name','displayName','title'],'string')||''; }
function deepPrice(x){
  const seen=new Set();
  function walk(v,depth){
    if(depth>6||v==null||typeof v!=='object'||seen.has(v)) return null;
    seen.add(v);
    for(const key of ['price','priceInRobux','defaultPrice','salePrice','robuxPrice']){
      const n=Number(v[key]); if(Number.isFinite(n)&&n>=0) return n;
    }
    for(const val of Object.values(v)){ const p=walk(val,depth+1); if(p!=null) return p; }
    return null;
  }
  return walk(x,0);
}
function compact(item){
  return {id:idOf(item),name:nameOf(item),price:deepPrice(item),isForSale:item?.isForSale??item?.isOnSale??item?.forSale??null};
}
async function getJson(url,auth=true){
  const headers={Accept:'application/json'};
  if(auth&&apiKey) headers['x-api-key']=apiKey;
  const r=await fetch(url,{headers});
  const text=await r.text();
  let body={}; try{ body=JSON.parse(text); }catch{}
  if(!r.ok) throw new Error(`${r.status} ${url} :: ${text.slice(0,300)}`);
  return body;
}
async function listCreator(basePath,keys){
  if(!apiKey) return [];
  const all=[]; let pageToken='';
  for(let page=0;page<10;page++){
    const q=new URLSearchParams({maxPageSize:'100'});
    if(pageToken) q.set('pageToken',pageToken);
    const body=await getJson(`https://apis.roblox.com${basePath}?${q}`,true);
    all.push(...itemsFrom(body,keys));
    pageToken=body?.nextPageToken||'';
    if(!pageToken) break;
  }
  return all;
}
function supportScore(item,amount){
  const n=nameOf(item).toLowerCase();
  let score=0;
  if(/support|sawer|donat|donate|tip|sultan/.test(n)) score+=20;
  if(new RegExp(`(^|\\D)${amount}(\\D|$)`).test(n)) score+=10;
  if(deepPrice(item)===amount) score+=30;
  return score;
}

(async()=>{
  let gamePasses=[]; let developerProducts=[]; const errors=[];
  try{ gamePasses=await listCreator(`/game-passes/v1/universes/${universeId}/game-passes/creator`,['gamePasses','passes','data']); }
  catch(e){ errors.push(`game-pass creator: ${e.message}`); }
  try{ developerProducts=await listCreator(`/developer-products/v2/universes/${universeId}/developer-products/creator`,['developerProducts','products','data']); }
  catch(e){ errors.push(`developer-product creator: ${e.message}`); }

  if(gamePasses.length===0){
    try{
      const body=await getJson(`https://apis.roblox.com/game-passes/v1/universes/${universeId}/game-passes?passView=Full&pageSize=100`,false);
      gamePasses=itemsFrom(body,['gamePasses','passes','data']);
    }catch(e){ errors.push(`game-pass public: ${e.message}`); }
  }

  const vipCandidates=gamePasses
    .filter(x=>/vip/i.test(nameOf(x)))
    .sort((a,b)=>(deepPrice(b)===10?1:0)-(deepPrice(a)===10?1:0));
  let vip=vipCandidates[0]||null;
  if(!vip){
    const ten=gamePasses.filter(x=>deepPrice(x)===10&&!/support|sawer|donat|donate|tip|sultan/i.test(nameOf(x)));
    if(ten.length===1) vip=ten[0];
  }
  const vipId=vip?idOf(vip):0;

  const supportProducts={}; const supportKinds={}; const supportMeta={};
  for(const amount of desired){
    let chosen=null; let kind='none';
    const devRanked=developerProducts.map(x=>({x,score:supportScore(x,amount)})).filter(r=>r.score>0).sort((a,b)=>b.score-a.score);
    if(devRanked[0]){ chosen=devRanked[0].x; kind='developerProduct'; }
    if(!chosen){
      const passRanked=gamePasses
        .filter(x=>idOf(x)!==vipId)
        .map(x=>({x,score:supportScore(x,amount)}))
        .filter(r=>r.score>=30 || (/support|sawer|donat|donate|tip|sultan/i.test(nameOf(r.x))&&r.score>0))
        .sort((a,b)=>b.score-a.score);
      if(passRanked[0]){ chosen=passRanked[0].x; kind='gamePass'; }
    }
    supportProducts[String(amount)]=chosen?idOf(chosen):0;
    supportKinds[String(amount)]=chosen?kind:'none';
    supportMeta[String(amount)]=chosen?{...compact(chosen),kind}:null;
  }

  const result={
    universeId,
    vipGamePassId:vipId,
    vipMeta:vip?compact(vip):null,
    gamePasses:gamePasses.map(compact),
    supportProducts,
    supportKinds,
    supportMeta,
    developerProducts:developerProducts.map(compact),
    discovered:{gamePasses:gamePasses.length,developerProducts:developerProducts.length},
    errors,
  };
  fs.writeFileSync(out,JSON.stringify(result,null,2)+'\n');
  console.log('[BBYA COMMERCE] resolved',JSON.stringify({
    vipGamePassId:result.vipGamePassId,
    gamePasses:result.gamePasses,
    supportProducts:result.supportProducts,
    supportKinds:result.supportKinds,
    discovered:result.discovered,
    errors:result.errors,
  }));
})().catch(err=>{
  console.error('[BBYA COMMERCE] fatal resolver error',err);
  fs.writeFileSync(out,JSON.stringify({universeId,vipGamePassId:0,gamePasses:[],supportProducts:Object.fromEntries(desired.map(x=>[String(x),0])),supportKinds:Object.fromEntries(desired.map(x=>[String(x),'none'])),developerProducts:[],errors:[String(err)]},null,2)+'\n');
  process.exitCode=0;
});
