#!/usr/bin/env python3
import json, os, subprocess, time, urllib.parse
from pathlib import Path

KEY=os.environ['ROBLOX_API_KEY']
UNIVERSE=os.environ.get('UNIVERSE_ID','8116636513')
BASE=f'https://apis.roblox.com/developer-products/v2/universes/{UNIVERSE}/developer-products'
LIST_BASE=BASE+'/creator'
DESIRED=[
 ('BBYA DJ Wall Message',2,'Display one filtered custom message on the BBYA DJ wall. Messages enter a queue and are shown for a limited time.'),
 ('BBYA VIP Travel',5,'Teleport this visit to the BBYA VIP Level.'),
 ('BBYA Rooftop Travel',10,'Teleport this visit to the BBYA Rooftop.'),
 ('BBYA Basement Travel',20,'Teleport this visit to the BBYA Basement / Underground.'),
 ('BBYA Support 10',10,'Support BBYA Social Hub with 10 Robux.'),
 ('BBYA Support 25',25,'Support BBYA Social Hub with 25 Robux.'),
 ('BBYA Support 50',50,'Support BBYA Social Hub with 50 Robux.'),
 ('BBYA Support 100',100,'Support BBYA Social Hub with 100 Robux.'),
 ('BBYA Support 250',250,'Support BBYA Social Hub with 250 Robux.'),
 ('BBYA Support 500',500,'Support BBYA Social Hub with 500 Robux.'),
 ('BBYA Support 1000',1000,'Support BBYA Social Hub with 1000 Robux.'),
 ('BBYA Prestige Support 2000',2000,'Prestige support for BBYA Social Hub with 2000 Robux.'),
]
STATUS=Path('deploy-status/bbya-products-sync.json'); STATUS.parent.mkdir(parents=True,exist_ok=True)
MODULE=Path('maps/bbya-social-hub/monetization/products.luau'); MODULE.parent.mkdir(parents=True,exist_ok=True)

def req(method,url,fields=None,retries=2):
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
  time.sleep(min(2+attempt*2,6))
 return last

def rows(body):
 if not isinstance(body,dict): return []
 for k in ('data','developerProducts','products'):
  if isinstance(body.get(k),list): return body[k]
 return []

def next_token(body):
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

def price(item):
 if not isinstance(item,dict): return 0
 try: return int((item.get('priceInformation') or {}).get('defaultPriceInRobux') or item.get('price') or 0)
 except Exception: return 0

def list_all():
 out=[]; tok=None; pages=[]
 for _ in range(10):
  q={'pageSize':'50'}
  if tok: q['pageToken']=tok
  st,b,er=req('GET',LIST_BASE+'?'+urllib.parse.urlencode(q))
  pages.append({'http':st,'count':len(rows(b)),'token':tok})
  if not st.startswith('2'): return st,out,pages,{'body':b,'stderr':er}
  out += rows(b); tok=next_token(b)
  if not tok: return st,out,pages,None
 return '200',out,pages,{'body':{'message':'pagination limit'},'stderr':''}

def verify_price(product_id,expected_price):
 st,b,_=req('GET',f'{BASE}/{product_id}/creator',retries=1)
 return b if st.startswith('2') and price(b)==expected_price else None

result={'api_ok':False,'complete':False,'created':[],'verified_by_price':[],'duplicates':[],'errors':[],'pages':[],'snapshot':[],'products':[]}
st,remote_items,pages,err=list_all(); result['list_http']=st; result['pages']=pages
result['snapshot']=[{'name':x.get('name'),'id':pid(x),'price':price(x)} for x in remote_items if isinstance(x,dict)]
if err or not st.startswith('2'):
 result['errors'].append({'stage':'list','http':st,**(err or {})})
else:
 result['api_ok']=True
 # Exact-name resolution is required because travel and support can share the same price (10 R$).
 by_name={str(x.get('name','')).lower():x for x in remote_items if isinstance(x,dict) and x.get('name')}
 resolved={}
 for name,p,_ in DESIRED:
  item=by_name.get(name.lower())
  if item and pid(item) and price(item)==p: resolved[name]=pid(item)

 # Preserve the two previously verified legacy support IDs if listing ever omits them transiently.
 for name,p,hint in [('BBYA Support 500',500,3709047107),('BBYA Support 1000',1000,3709047109)]:
  if not resolved.get(name):
   b=verify_price(hint,p)
   if b:
    resolved[name]=hint; result['verified_by_price'].append({'name':name,'price':p,'id':hint})

 for name,p,desc in DESIRED:
  if resolved.get(name): continue
  h,b,er=req('POST',BASE,{'name':name,'price':p,'description':desc})
  if h.startswith('2') and pid(b):
   resolved[name]=pid(b); result['created'].append({'name':name,'price':p,'id':pid(b)})
  elif isinstance(b,dict) and b.get('errorCode')=='DuplicateProductName':
   result['duplicates'].append(name)
  else:
   result['errors'].append({'stage':'create','name':name,'http':h,'body':b,'stderr':er})

 # Re-list once after creation so DuplicateProductName or eventual consistency can resolve safely by exact name.
 if result['duplicates']:
  _,fresh,_,_=list_all()
  fresh_by_name={str(x.get('name','')).lower():x for x in fresh if isinstance(x,dict) and x.get('name')}
  unresolved=[]
  for name in result['duplicates']:
   wanted=next((x for x in DESIRED if x[0]==name),None)
   item=fresh_by_name.get(name.lower())
   if wanted and item and pid(item) and price(item)==wanted[1]: resolved[name]=pid(item)
   else: unresolved.append(name)
  result['duplicates']=unresolved

 for name,p,_ in DESIRED:
  result['products'].append({'name':name,'price':p,'id':resolved.get(name,0),'verified':bool(resolved.get(name))})

result['complete']=result['api_ok'] and not result['errors'] and not result['duplicates'] and len(result['products'])==len(DESIRED) and all(x['id']>0 for x in result['products'])
STATUS.write_text(json.dumps(result,indent=2)+'\n')
ids={x['name']:x.get('id',0) for x in result['products']}
lines=['-- Generated by scripts/sync-bbya-products.py','return {',f"    DJ_MESSAGE = {ids.get('BBYA DJ Wall Message',0)},",'    TRAVEL = {',f"        VIP = {ids.get('BBYA VIP Travel',0)},",f"        Rooftop = {ids.get('BBYA Rooftop Travel',0)},",f"        Basement = {ids.get('BBYA Basement Travel',0)},",'    },','    SUPPORT = {']
for p in (10,25,50,100,250,500,1000): lines.append(f"        [{p}] = {ids.get(f'BBYA Support {p}',0)},")
lines.append(f"        [2000] = {ids.get('BBYA Prestige Support 2000',0)},")
lines += ['    },','}']
MODULE.write_text('\n'.join(lines)+'\n')
print(json.dumps({'complete':result['complete'],'created':result['created'],'products':result['products'],'duplicates':result['duplicates'],'errors':result['errors']}))
