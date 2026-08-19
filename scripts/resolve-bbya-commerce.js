const fs=require('fs');

const universeId=process.env.BBYA_UNIVERSE_ID||'8116636513';
const apiKey=process.env.ROBLOX_API_KEY||'';
const out=process.env.BBYA_COMMERCE_JSON||'/tmp/bbya-commerce.json';
const desired=[5,10,50,100,500];

function itemsFrom(body,keys){
  for(const key of keys){
    if(Array.isArray(body?.[key])) return body[key];
  }
  if(Array.isArray(body)) return body;
  return [];
}
function idOf(x){ return Number(x?.id??x?.productId??x?.developerProductId??x?.gamePassId??x?.assetId??0)||0; }
function nameOf(x){ return String(x?.name??x?.displayName??x?.title??''); }
function deepPrice(x){
  const seen=new Set();
  function walk(v,depth){
    if(depth>5||v==null||typeof v!=='object'||seen.has(v)) return null;
    seen.add(v);
    for(const key of ['price','priceInRobux','defaultPrice','salePrice','robuxPrice']){
      const n=Number(v[key]); if(Number.isFinite(n)&&n>=0) return n;
    }
    for(const val of Object.values(v)){ const p=walk(val,depth+1); if(p!=null) return p; }
    return null;
  }
  return walk(x,0);
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
  const all=[];
  let pageToken='';
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
  if(/support|sawer|donat|donate|tip/.test(n)) score+=10;
  if(new RegExp(`(^|\\D)${amount}(\\D|$)`).test(n)) score+=5;
  if(deepPrice(item)===amount) score+=20;
  return score;
}

(async()=>{
  let gamePasses=[];
  let developerProducts=[];
  const errors=[];
  try{
    gamePasses=await listCreator(`/game-passes/v1/universes/${universeId}/game-passes/creator`,['gamePasses','passes','data']);
  }catch(e){ errors.push(`game-pass creator: ${e.message}`); }
  try{
    developerProducts=await listCreator(`/developer-products/v2/universes/${universeId}/developer-products/creator`,['developerProducts','products','data']);
  }catch(e){ errors.push(`developer-product creator: ${e.message}`); }

  // Public game-pass fallback if the deploy key lacks game-pass:read.
  if(gamePasses.length===0){
    try{
      const body=await getJson(`https://apis.roblox.com/game-passes/v1/universes/${universeId}/game-passes?passView=Full&pageSize=100`,false);
      gamePasses=itemsFrom(body,['gamePasses','passes','data']);
    }catch(e){ errors.push(`game-pass public: ${e.message}`); }
  }

  const vipCandidates=gamePasses
    .filter(x=>/vip/i.test(nameOf(x)))
    .sort((a,b)=>{
      const ap=deepPrice(a)===10?1:0, bp=deepPrice(b)===10?1:0;
      return bp-ap;
    });
  const vip=vipCandidates[0]||null;

  const supportProducts={};
  const supportMeta={};
  for(const amount of desired){
    const ranked=developerProducts
      .map(x=>({x,score:supportScore(x,amount)}))
      .filter(r=>r.score>0)
      .sort((a,b)=>b.score-a.score);
    const chosen=ranked[0]?.x||null;
    supportProducts[String(amount)]=chosen?idOf(chosen):0;
    supportMeta[String(amount)]=chosen?{id:idOf(chosen),name:nameOf(chosen),price:deepPrice(chosen)}:null;
  }

  const result={
    universeId,
    vipGamePassId:vip?idOf(vip):0,
    vipMeta:vip?{id:idOf(vip),name:nameOf(vip),price:deepPrice(vip)}:null,
    supportProducts,
    supportMeta,
    discovered:{gamePasses:gamePasses.length,developerProducts:developerProducts.length},
    errors,
  };
  fs.writeFileSync(out,JSON.stringify(result,null,2)+'\n');
  console.log('[BBYA COMMERCE] resolved',JSON.stringify({
    vipGamePassId:result.vipGamePassId,
    supportProducts:result.supportProducts,
    discovered:result.discovered,
    errors:result.errors,
  }));
})().catch(err=>{
  console.error('[BBYA COMMERCE] fatal resolver error',err);
  fs.writeFileSync(out,JSON.stringify({universeId,vipGamePassId:0,supportProducts:Object.fromEntries(desired.map(x=>[String(x),0])),errors:[String(err)]},null,2)+'\n');
  process.exitCode=0;
});
