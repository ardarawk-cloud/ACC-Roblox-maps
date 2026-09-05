#!/usr/bin/env python3
import json, os, subprocess, time, urllib.parse
from pathlib import Path

KEY=os.environ['ROBLOX_API_KEY']
UNIVERSE=os.environ.get('UNIVERSE_ID','8116636513')
BASE=f'https://apis.roblox.com/developer-products/v2/universes/{UNIVERSE}/developer-products'
LIST_BASE=BASE+'/creator'

# MESSAGE public tiers locked by Arda. 2R reuses the existing legacy product ID only;
# all other tiers are distinct products and must NEVER resolve by price to Support products.
MESSAGE_TIERS=(2,5,10,25,50,100,250,500,1000)
KNOWN_MESSAGE={2:3709047092}
MESSAGE_NAMES={
 2:'BBYA DJ Wall Message', # legacy Roblox product identity; public in-experience name is MESSAGE
 5:'BBYA Message 5',10:'BBYA Message 10',25:'BBYA Message 25',50:'BBYA Message 50',
 100:'BBYA Message 100',250:'BBYA Message 250',500:'BBYA Message 500',1000:'BBYA Message 1000',
}
KNOWN_SUPPORT={
 10:3709047095,25:3709047097,50:3709047101,100:3709047104,
 250:3709047106,500:3709047107,1000:3709047109,2000:3709048779,
}
SUPPORT_NAMES={
 10:'BBYA Support 10',25:'BBYA Support 25',50:'BBYA Support 50',100:'BBYA Support 100',
 250:'BBYA Support 250',500:'BBYA Support 500',1000:'BBYA Support 1000',2000:'BBYA Prestige Support 2000',
}

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
 for k in ('productId','ProductId','id','developerProductId','DeveloperProductId'):
  try:
   if item.get(k) is not None: return int(item[k])
  except Exception: pass
 return 0

def raw_ids(item):
 if not isinstance(item,dict): return {}
 return {
  'productId': item.get('productId',item.get('ProductId')),
  'id': item.get('id'),
  'developerProductId': item.get('developerProductId',item.get('DeveloperProductId')),
 }

def price(item):
 if not isinstance(item,dict): return 0
 try: return int((item.get('priceInformation') or {}).get('defaultPriceInRobux') or item.get('price') or 0)
 except Exception: return 0

def list_all():
 out=[];tok=None;pages=[]
 for _ in range(10):
  q={'pageSize':'50'}
  if tok:q['pageToken']=tok
  st,b,er=req('GET',LIST_BASE+'?'+urllib.parse.urlencode(q))
  pages.append({'http':st,'count':len(rows(b)),'token':tok})
  if not st.startswith('2'):return st,out,pages,{'body':b,'stderr':er}
  out+=rows(b);tok=next_token(b)
  if not tok:return st,out,pages,None
 return '200',out,pages,{'body':{'message':'pagination limit'},'stderr':''}

def verify_id(product_id,expected_price):
 st,b,_=req('GET',f'{BASE}/{product_id}/creator',retries=1)
 return bool(st.startswith('2') and price(b)==expected_price),b

def create_product(name,p,desc):
 h,b,er=req('POST',BASE,{'name':name,'price':p,'description':desc})
 return h,b,er

result={
 'api_ok':False,'complete':False,'created':[],'verified_known':[],
 'duplicates':[],'errors':[],'pages':[],'snapshot':[],'message':[],'support':[]
}
st,remote_items,pages,err=list_all();result['list_http']=st;result['pages']=pages
result['snapshot']=[{'name':x.get('name'),'resolvedProductId':pid(x),'price':price(x),**raw_ids(x)} for x in remote_items if isinstance(x,dict)]
if err or not st.startswith('2'):
 result['errors'].append({'stage':'list','http':st,**(err or {})})
else:
 result['api_ok']=True

by_name={str(x.get('name','')).lower():x for x in remote_items if isinstance(x,dict) and x.get('name')}
message_ids={}
support_ids={}

if result['api_ok']:
 # Existing 2R MESSAGE identity is explicitly known and price-verified.
 for tier,known_id in KNOWN_MESSAGE.items():
  ok,info=verify_id(known_id,tier)
  if ok:
   message_ids[tier]=known_id;result['verified_known'].append({'kind':'MESSAGE','price':tier,'id':known_id})
  else:
   result['errors'].append({'stage':'verify_known_message','price':tier,'id':known_id,'body':info})

 # Existing Support identities are explicit IDs so same-price MESSAGE products can never hijack Support.
 for tier,known_id in KNOWN_SUPPORT.items():
  ok,info=verify_id(known_id,tier)
  if ok:
   support_ids[tier]=known_id;result['verified_known'].append({'kind':'SUPPORT','price':tier,'id':known_id})
  else:
   # Exact-name recovery is safe for Support; do not use price-only fallback once MESSAGE shares these prices.
   item=by_name.get(SUPPORT_NAMES[tier].lower())
   if item and pid(item) and price(item)==tier:
    support_ids[tier]=pid(item)
   else:
    result['errors'].append({'stage':'verify_known_support','price':tier,'id':known_id,'body':info})

 # Resolve/create distinct MESSAGE products for every remaining tier by exact product name only.
 for tier in MESSAGE_TIERS:
  if message_ids.get(tier):continue
  name=MESSAGE_NAMES[tier]
  item=by_name.get(name.lower())
  if item and pid(item) and price(item)==tier:
   message_ids[tier]=pid(item);continue
  desc=f'Display one filtered custom MESSAGE in BBYA Social Hub using the {tier} Robux message tier.'
  h,b,er=create_product(name,tier,desc)
  if h.startswith('2') and pid(b):
   message_ids[tier]=pid(b)
   result['created'].append({'kind':'MESSAGE','name':name,'price':tier,'id':pid(b),**raw_ids(b)})
  elif isinstance(b,dict) and b.get('errorCode')=='DuplicateProductName':
   result['duplicates'].append({'kind':'MESSAGE','name':name,'price':tier})
  else:
   result['errors'].append({'stage':'create_message','name':name,'price':tier,'http':h,'body':b,'stderr':er})

for tier in MESSAGE_TIERS:
 result['message'].append({'name':MESSAGE_NAMES[tier],'price':tier,'id':message_ids.get(tier,0),'verified':bool(message_ids.get(tier))})
for tier in (10,25,50,100,250,500,1000,2000):
 result['support'].append({'name':SUPPORT_NAMES[tier],'price':tier,'id':support_ids.get(tier,0),'verified':bool(support_ids.get(tier))})

result['complete']=(result['api_ok'] and not result['errors'] and not result['duplicates']
 and all(x['id']>0 for x in result['message']) and all(x['id']>0 for x in result['support']))
STATUS.write_text(json.dumps(result,indent=2)+'\n')

lines=['-- Generated by scripts/sync-bbya-products.py','return {','    MESSAGE = {']
for p in MESSAGE_TIERS:lines.append(f'        [{p}] = {message_ids.get(p,0)},')
lines+=['    },',f'    DJ_MESSAGE = {message_ids.get(2,0)}, -- legacy compatibility alias','    SUPPORT = {']
for p in (10,25,50,100,250,500,1000,2000):lines.append(f'        [{p}] = {support_ids.get(p,0)},')
lines+=['    },','}']
MODULE.write_text('\n'.join(lines)+'\n')
print(json.dumps({'complete':result['complete'],'created':result['created'],'message':result['message'],'support':result['support'],'duplicates':result['duplicates'],'errors':result['errors']}))
