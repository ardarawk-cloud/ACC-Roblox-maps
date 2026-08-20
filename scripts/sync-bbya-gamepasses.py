#!/usr/bin/env python3
import json, os, subprocess, time, urllib.parse
from pathlib import Path

KEY=os.environ['ROBLOX_API_KEY']
UNIVERSE=os.environ.get('UNIVERSE_ID','8116636513')
BASE=f'https://apis.roblox.com/game-passes/v1/universes/{UNIVERSE}/game-passes'
LIST_BASE=BASE+'/creator'
DESIRED=[
 ('VIP','BBYA VIP Access',5,'Permanent VIP Level travel access for BBYA Social Hub.'),
 ('Skatepark','BBYA Skatepark Access',5,'Permanent Skatepark travel access for BBYA Social Hub.'),
 ('Rooftop','BBYA Rooftop Access',10,'Permanent Rooftop travel access for BBYA Social Hub.'),
 ('Basement','BBYA Basement Access',20,'Permanent Basement / Underground travel access for BBYA Social Hub.'),
]
STATUS=Path('deploy-status/bbya-gamepasses-sync.json'); STATUS.parent.mkdir(parents=True,exist_ok=True)
MODULE=Path('maps/bbya-social-hub/monetization/passes.luau'); MODULE.parent.mkdir(parents=True,exist_ok=True)

def request(method,url,fields=None,retries=2):
    last=('',{},'')
    for attempt in range(retries+1):
        cmd=['curl','-sS','-w','\n%{http_code}','-X',method,'-H',f'x-api-key: {KEY}']
        for k,v in (fields or {}).items():
            if isinstance(v,bool): v='true' if v else 'false'
            cmd += ['-F',f'{k}={v}']
        cmd.append(url)
        p=subprocess.run(cmd,capture_output=True,text=True)
        raw=p.stdout
        body_text,status=(raw.rsplit('\n',1) if '\n' in raw else (raw,''))
        try: body=json.loads(body_text) if body_text.strip() else {}
        except Exception: body={'raw':body_text[:1600]}
        last=(status,body,p.stderr[:1000])
        if status!='429': return last
        time.sleep(min(2+attempt*2,6))
    return last

def gid(item):
    if not isinstance(item,dict): return 0
    for key in ('gamePassId','id','gamepassId'):
        try:
            if item.get(key) is not None: return int(item[key])
        except Exception: pass
    return 0

def price(item):
    if not isinstance(item,dict): return 0
    try:
        return int((item.get('priceInformation') or {}).get('defaultPriceInRobux') or item.get('price') or 0)
    except Exception:
        return 0

def list_all():
    out=[]; token=None; pages=[]
    for _ in range(10):
        q={'pageSize':'50'}
        if token: q['pageToken']=token
        st,b,err=request('GET',LIST_BASE+'?'+urllib.parse.urlencode(q))
        rows=b.get('gamePasses',[]) if isinstance(b,dict) else []
        pages.append({'http':st,'count':len(rows),'token':token})
        if not st.startswith('2'): return st,out,pages,{'body':b,'stderr':err}
        out.extend(rows)
        token=b.get('nextPageToken') if isinstance(b,dict) else None
        if not token: return st,out,pages,None
    return '200',out,pages,{'body':{'message':'pagination limit'},'stderr':''}

def refresh_exact(name):
    st,rows,_,_=list_all()
    if not st.startswith('2'): return None
    for item in rows:
        if str(item.get('name','')).strip().lower()==name.lower(): return item
    return None

result={'api_ok':False,'complete':False,'created':[],'updated':[],'errors':[],'pages':[],'passes':[],'snapshot':[]}
st,remote,pages,err=list_all(); result['pages']=pages; result['list_http']=st
result['snapshot']=[{'name':x.get('name'),'id':gid(x),'price':price(x),'isForSale':x.get('isForSale')} for x in remote if isinstance(x,dict)]
resolved={}
if err or not st.startswith('2'):
    result['errors'].append({'stage':'list','http':st,**(err or {})})
else:
    result['api_ok']=True
    by_name={str(x.get('name','')).strip().lower():x for x in remote if isinstance(x,dict) and x.get('name')}
    for key,name,wanted_price,desc in DESIRED:
        item=by_name.get(name.lower())
        if not item:
            h,b,e=request('POST',BASE,{
                'name':name,
                'description':desc,
                'isForSale':True,
                'price':wanted_price,
                'isRegionalPricingEnabled':False,
            })
            created_id=gid(b)
            if h.startswith('2') and created_id:
                resolved[key]=created_id
                result['created'].append({'key':key,'name':name,'price':wanted_price,'id':created_id})
                continue
            # Creation can race with an existing same-name pass. Re-list before declaring failure.
            item=refresh_exact(name)
            if not item:
                result['errors'].append({'stage':'create','key':key,'name':name,'http':h,'body':b,'stderr':e})
                continue

        pass_id=gid(item)
        if not pass_id:
            result['errors'].append({'stage':'resolve','key':key,'name':name,'body':item})
            continue
        needs_update=price(item)!=wanted_price or item.get('isForSale') is not True
        if needs_update:
            h,b,e=request('PATCH',f'{BASE}/{pass_id}',{
                'name':name,
                'description':desc,
                'isForSale':True,
                'price':wanted_price,
                'isRegionalPricingEnabled':False,
            })
            if not h.startswith('2'):
                result['errors'].append({'stage':'update','key':key,'id':pass_id,'http':h,'body':b,'stderr':e})
                continue
            result['updated'].append({'key':key,'name':name,'price':wanted_price,'id':pass_id})
        resolved[key]=pass_id

for key,name,wanted_price,_ in DESIRED:
    result['passes'].append({'key':key,'name':name,'price':wanted_price,'id':resolved.get(key,0),'verified':bool(resolved.get(key))})
result['complete']=result['api_ok'] and not result['errors'] and all(x['id']>0 for x in result['passes'])
STATUS.write_text(json.dumps(result,indent=2)+'\n')
MODULE.write_text('-- Generated by scripts/sync-bbya-gamepasses.py\nreturn {\n'+''.join(f'    {key} = {resolved.get(key,0)},\n' for key,_,_,_ in DESIRED)+'}\n')
print(json.dumps({'complete':result['complete'],'created':result['created'],'updated':result['updated'],'passes':result['passes'],'errors':result['errors']}))
if not result['complete']:
    raise SystemExit(2)
