#!/usr/bin/env python3
import json, os, subprocess, time, urllib.parse
from pathlib import Path

KEY=os.environ['ROBLOX_API_KEY']
UNIVERSE=os.environ.get('UNIVERSE_ID','8116636513')
BASE=f'https://apis.roblox.com/developer-products/v2/universes/{UNIVERSE}/developer-products'
LIST_BASE=BASE+'/creator'
DESIRED=[
 ('BBYA DJ Wall Message',2,'Display one filtered custom message on the BBYA DJ wall. Messages enter a queue and are shown for a limited time.'),
 ('BBYA Support 10',10,'Support BBYA Social Hub with 10 Robux.'),
 ('BBYA Support 25',25,'Support BBYA Social Hub with 25 Robux.'),
 ('BBYA Support 50',50,'Support BBYA Social Hub with 50 Robux.'),
 ('BBYA Support 100',100,'Support BBYA Social Hub with 100 Robux.'),
 ('BBYA Support 250',250,'Support BBYA Social Hub with 250 Robux.'),
 ('BBYA Support 500',500,'Support BBYA Social Hub with 500 Robux.'),
 ('BBYA Support 1000',1000,'Support BBYA Social Hub with 1000 Robux.'),
 ('BBYA Support 2000',2000,'Support BBYA Social Hub with 2000 Robux.'),
]
STATUS=Path('deploy-status/bbya-products-sync.json'); STATUS.parent.mkdir(parents=True,exist_ok=True)
MODULE=Path('maps/bbya-social-hub/monetization/products.luau'); MODULE.parent.mkdir(parents=True,exist_ok=True)

def req(method,url,fields=None,retries=1):
 last=('',{},'')
 for attempt in range(retries+1):
  cmd=['curl','-sS','-w','\n%{http_code}','-X',method,'-H',f'x-api-key: {KEY}']
  for k,v in (fields or {}).items(): cmd+=['-F',f'{k}={v}']
  cmd.append(url)
  p=subprocess.run(cmd,capture_output=True,text=True)
  raw=p.stdout
  body_text,status=(raw.rsplit('\n',1) if '\n' in raw else (raw,''))
  try: body=json.loads(body_text) if body_text.strip() else {}
  except Exception: body={'raw':body_text[:1200]}
  last=(status,body,p.stderr[:800])
  if status!='429': return last
  time.sleep(2+attempt*2)
 return last

def items(body):
 if not isinstance(body,dict): return []
 for k in ('data','developerProducts','products'):
  if isinstance(body.get(k),list): return body[k]
 return []

def token(body):
 if not isinstance(body,dict): return None
 for k in ('nextPageToken','nextPageCursor','next_page_cursor'):
  if body.get(k): return str(body[k])
 return None

def pid(item):
 if not isinstance(item,dict): return 0
 for k in ('id','productId','developerProductId','ProductId'):
  try:
   if item.get(k) is not None: return int(item[k])
  except Exception: pass
 return 0

def list_all():
 out=[]; tok=None; pages=[]
 for _ in range(10):
  q={'pageSize':'50'}
  if tok: q['pageToken']=tok
  st,b,er=req('GET',LIST_BASE+'?'+urllib.parse.urlencode(q),retries=2)
  pages.append({'http':st,'count':len(items(b)),'token':tok})
  if not st.startswith('2'): return st,out,pages,{'body':b,'stderr':er}
  out+=items(b); tok=token(b)
  if not tok: return st,out,pages,None
 return '200',out,pages,{'body':{'message':'pagination limit'},'stderr':''}

def by_name(seq): return {str(x.get('name','')).lower():x for x in seq if isinstance(x,dict) and x.get('name')}
def get_one(product_id): return req('GET',f'{BASE}/{product_id}/creator',retries=0)
def verify(name,product_id):
 st,b,_=get_one(product_id)
 return b if st.startswith('2') and isinstance(b,dict) and str(b.get('name','')).lower()==name.lower() else None

result={'api_ok':False,'complete':False,'created':[],'verified_by_id':[],'duplicates':[],'errors':[],'pages':[],'snapshot':[],'products':[]}
st,remote_items,pages,err=list_all(); result['list_http']=st; result['pages']=pages
result['snapshot']=[{'name':x.get('name'),'id':pid(x),'price':(x.get('priceInformation') or {}).get('defaultPriceInRobux')} for x in remote_items if isinstance(x,dict)]
if err or not st.startswith('2'):
 result['errors'].append({'stage':'list','http':st,**(err or {})})
else:
 result['api_ok']=True
 remote=by_name(remote_items)
 for name,hint in {'BBYA Support 500':3709047107,'BBYA Support 1000':3709047109}.items():
  if name.lower() not in remote:
   b=verify(name,hint)
   if b: remote[name.lower()]=b; result['verified_by_id'].append({'name':name,'id':hint})
 if 'bbya support 2000' not in remote:
  for candidate in range(3709047110,3709047116):
   b=verify('BBYA Support 2000',candidate)
   if b:
    remote['bbya support 2000']=b; result['verified_by_id'].append({'name':'BBYA Support 2000','id':candidate}); break
 created={}
 for name,price,desc in DESIRED:
  if name.lower() in remote: continue
  h,b,er=req('POST',BASE,{'name':name,'price':price,'description':desc},retries=1)
  if h.startswith('2'):
   created[name]=pid(b); result['created'].append({'name':name,'price':price,'id':created[name]})
  elif isinstance(b,dict) and b.get('errorCode')=='DuplicateProductName': result['duplicates'].append(name)
  else: result['errors'].append({'stage':'create','name':name,'http':h,'body':b,'stderr':er})
 time.sleep(2)
 st2,latest,pg2,err2=list_all(); result['pages']=pg2
 if st2.startswith('2'): remote.update(by_name(latest))
 if err2: result['errors'].append({'stage':'relist','http':st2,**err2})
 for name,price,_ in DESIRED:
  rid=pid(remote.get(name.lower(),{})); final_id=rid or created.get(name,0)
  result['products'].append({'name':name,'price':price,'id':final_id,'verified':bool(rid) or bool(created.get(name,0))})
result['complete']=result['api_ok'] and not result['errors'] and len(result['products'])==len(DESIRED) and all(x['id']>0 for x in result['products'])
STATUS.write_text(json.dumps(result,indent=2)+'\n')
ids={x['name']:x.get('id',0) for x in result['products']}
lines=['-- Generated by scripts/sync-bbya-products.py','return {',f"    DJ_MESSAGE = {ids.get('BBYA DJ Wall Message',0)},",'    SUPPORT = {']
for price in (10,25,50,100,250,500,1000,2000): lines.append(f"        [{price}] = {ids.get(f'BBYA Support {price}',0)},")
lines+=['    },','}']; MODULE.write_text('\n'.join(lines)+'\n')
print(json.dumps({'complete':result['complete'],'verified_by_id':result['verified_by_id'],'products':result['products'],'errors':result['errors']}))
