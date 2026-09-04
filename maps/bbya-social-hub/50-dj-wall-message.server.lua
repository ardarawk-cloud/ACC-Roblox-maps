-- BBYA SOCIAL HUB — DJ WALL + MONETIZATION AUTHORITY v4.1
-- ONE Developer Product authority for DJ Wall and Support.
-- ProcessReceipt safety + DonationNotification backend.
-- Products/prices/presentation remain unchanged. Unknown products remain NotProcessedYet.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local TextService=game:GetService("TextService")
local Workspace=game:GetService("Workspace")
local DataStoreService=game:GetService("DataStoreService")
local HttpService=game:GetService("HttpService")
local UserService=game:GetService("UserService")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD")
local old=root:FindFirstChild("DJWallMessageSystem"); if old then old:Destroy() end

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes"; remotes.Parent=ReplicatedStorage
local wallRemote=remotes:FindFirstChild("DJWall") or Instance.new("RemoteEvent"); wallRemote.Name="DJWall"; wallRemote.Parent=remotes
local stateRemote=remotes:FindFirstChild("State") or Instance.new("RemoteEvent"); stateRemote.Name="State"; stateRemote.Parent=remotes
local monetizationRemote=remotes:FindFirstChild("Monetization") or Instance.new("RemoteEvent"); monetizationRemote.Name="Monetization"; monetizationRemote.Parent=remotes

local KNOWN_DJ=3709047092
local DJ_AMOUNT=2
local KNOWN_SUPPORT={
 [10]=3709047095,[25]=3709047097,[50]=3709047101,[100]=3709047104,
 [250]=3709047106,[500]=3709047107,[1000]=3709047109,[2000]=3709048779,
}
local SUPPORT_AMOUNTS={10,25,50,100,250,500,1000,2000}
local SUPPORT_BY_PRODUCT={}
for amount,id in pairs(KNOWN_SUPPORT) do SUPPORT_BY_PRODUCT[id]=amount end

local RECEIPT_STORE=DataStoreService:GetDataStore("BBYA_MonetizationReceipts_v1")
local USER_STORE=DataStoreService:GetDataStore("BBYA_MonetizationUsers_v1")
local DJ_PENDING_TTL=30*60
local DJ_RUNTIME_CLAIM_TTL=120
local SERVER_CLAIM_ID=(game.JobId~="" and game.JobId) or ("studio-"..HttpService:GenerateGUID(false))

local supportProductByAmount={}
local supportAmountByProduct={}
local djProductId=nil
local catalogReady=false
local catalogError=nil

local function upper(v) return string.upper(tostring(v or "")) end
local function productIdOf(p) return tonumber(p.ProductId or p.productId or p.DeveloperProductId or p.developerProductId or p.id) end
local function priceOf(p) return tonumber(p.PriceInRobux or p.priceInRobux or p.Price or p.price) end
local function nameOf(p) return tostring(p.Name or p.name or p.displayName or p.DisplayName or "") end
local function userKey(userId) return "u:"..tostring(userId) end
local function receiptKey(purchaseId) return "r:"..tostring(purchaseId) end

local function normalizeUser(raw)
 local u=type(raw)=="table" and raw or {}
 u.version=2
 u.supportTotal=tonumber(u.supportTotal) or 0
 u.supportApplied=type(u.supportApplied)=="table" and u.supportApplied or {}
 u.donationApplied=type(u.donationApplied)=="table" and u.donationApplied or {}
 if u.donationTotal==nil then
  u.donationTotal=u.supportTotal
  for purchaseId,marker in pairs(u.supportApplied) do
   if not u.donationApplied[purchaseId] then
    u.donationApplied[purchaseId]={
     amount=tonumber(type(marker)=="table" and marker.amount) or 0,
     at=tonumber(type(marker)=="table" and marker.at) or 0,
     source="SUPPORT_MIGRATED",
    }
   end
  end
 else
  u.donationTotal=tonumber(u.donationTotal) or 0
 end
 u.profile=type(u.profile)=="table" and u.profile or {}
 u.djOutstanding=type(u.djOutstanding)=="table" and u.djOutstanding or {}
 u.djRecovery=type(u.djRecovery)=="table" and u.djRecovery or {}
 if u.djPending~=nil and type(u.djPending)~="table" then u.djPending=nil end
 return u
end

local function safeGet(store,key)
 local ok,value=pcall(function() return store:GetAsync(key) end)
 if not ok then warn("[BBYA Monetization] DataStore GetAsync failed "..tostring(key)..": "..tostring(value)) end
 return ok,value
end

local function safeUpdate(store,key,transform)
 local ok,value=pcall(function() return store:UpdateAsync(key,transform) end)
 if not ok then warn("[BBYA Monetization] DataStore UpdateAsync failed "..tostring(key)..": "..tostring(value)) end
 return ok,value
end

local function updateReceipt(purchaseId,transform)
 return safeUpdate(RECEIPT_STORE,receiptKey(purchaseId),function(raw)
  local r=type(raw)=="table" and raw or {}
  return transform(r)
 end)
end

local function ensureReceiptRecord(receipt,kind,amount)
 local purchaseId=tostring(receipt.PurchaseId or "")
 local playerId=tonumber(receipt.PlayerId)
 local productId=tonumber(receipt.ProductId)
 if purchaseId=="" or not playerId or not productId then return false,nil,"missing receipt identity" end
 local now=os.time()
 local ok,r=updateReceipt(purchaseId,function(current)
  if current.purchaseId and tostring(current.purchaseId)~=purchaseId then current.integrityConflict=true;return current end
  if current.playerId and tonumber(current.playerId)~=playerId then current.integrityConflict=true;return current end
  if current.productId and tonumber(current.productId)~=productId then current.integrityConflict=true;return current end
  current.version=2
  current.purchaseId=purchaseId
  current.playerId=playerId
  current.productId=productId
  current.kind=current.kind or kind
  current.amount=current.amount or amount
  current.state=current.state or "RECORDED"
  current.createdAt=current.createdAt or now
  current.updatedAt=now
  return current
 end)
 if not ok then return false,nil,"receipt datastore unavailable" end
 if type(r)~="table" or r.integrityConflict or tonumber(r.playerId)~=playerId or tonumber(r.productId)~=productId or tostring(r.kind or "")~=kind or tonumber(r.amount)~=amount then
  warn("[BBYA Monetization] receipt integrity mismatch for "..purchaseId)
  return false,r,"receipt integrity mismatch"
 end
 return true,r,nil
end

local function setReceiptFields(purchaseId,fields)
 local now=os.time()
 return updateReceipt(purchaseId,function(r)
  for k,v in pairs(fields) do r[k]=v end
  r.updatedAt=now
  return r
 end)
end

local function claimDjRuntime(purchaseId)
 local now=os.time()
 local ok,r=updateReceipt(purchaseId,function(current)
  if current.state=="ACK_READY" then return current end
  local owner=tostring(current.runtimeClaimedBy or "")
  local claimedAt=tonumber(current.runtimeClaimedAt) or 0
  if owner=="" or owner==SERVER_CLAIM_ID or now-claimedAt>DJ_RUNTIME_CLAIM_TTL then
   current.runtimeClaimedBy=SERVER_CLAIM_ID
   current.runtimeClaimedAt=now
  end
  current.updatedAt=now
  return current
 end)
 if not ok or type(r)~="table" then return false,"ERROR",r end
 if r.state=="ACK_READY" then return false,"ACK",r end
 if tostring(r.runtimeClaimedBy or "")~=SERVER_CLAIM_ID then return false,"BUSY",r end
 return true,"CLAIMED",r
end

local function classifyProduct(productId)
 if productId==KNOWN_DJ then return "DJ",DJ_AMOUNT end
 local amount=SUPPORT_BY_PRODUCT[productId]
 if amount then return "SUPPORT",amount end
 return nil,nil
end

local function profileFromPlayer(player)
 if not player then return nil end
 return {
  userId=player.UserId,
  username=tostring(player.Name or ""),
  displayName=tostring(player.DisplayName or player.Name or ""),
  updatedAt=os.time(),
 }
end

local function resolveProfile(userId,player,userState,payload)
 if player then return profileFromPlayer(player) end
 if type(payload)=="table" then
  local username=tostring(payload.username or "")
  local displayName=tostring(payload.from or payload.displayName or "")
  if username~="" and displayName~="" then
   return {userId=userId,username=username,displayName=displayName,updatedAt=os.time()}
  end
 end
 local profile=type(userState)=="table" and userState.profile or nil
 if type(profile)=="table" and tostring(profile.username or "")~="" and tostring(profile.displayName or "")~="" then
  return {userId=userId,username=tostring(profile.username),displayName=tostring(profile.displayName),updatedAt=tonumber(profile.updatedAt) or 0}
 end
 local ok,infos=pcall(function() return UserService:GetUserInfosByUserIdsAsync({userId}) end)
 if ok and type(infos)=="table" then
  for _,info in ipairs(infos) do
   if tonumber(info.Id)==userId then
    local username=tostring(info.Username or "")
    local displayName=tostring(info.DisplayName or username)
    if username~="" and displayName~="" then
     return {userId=userId,username=username,displayName=displayName,updatedAt=os.time()}
    end
   end
  end
 end
 return nil
end

local function persistPlayerProfile(player)
 local profile=profileFromPlayer(player)
 if not profile then return false end
 local ok=select(1,safeUpdate(USER_STORE,userKey(player.UserId),function(raw)
  local u=normalizeUser(raw)
  u.profile=profile
  return u
 end))
 return ok
end

local function refreshProducts()
 local byId={}
 local ok,pages=pcall(function() return MarketplaceService:GetDeveloperProductsAsync() end)
 if not ok or not pages then catalogReady=false; catalogError="Developer Product catalog unavailable"; return false end
 while true do
  local page=pages:GetCurrentPage()
  for _,p in ipairs(page) do
   local id=productIdOf(p); if id then byId[id]={id=id,price=priceOf(p),name=nameOf(p)} end
  end
  if pages.IsFinished then break end
  local advanced=pcall(function() pages:AdvanceToNextPageAsync() end); if not advanced then break end
 end
 supportProductByAmount={}; supportAmountByProduct={}; djProductId=nil
 for amount,known in pairs(KNOWN_SUPPORT) do
  if byId[known] then supportProductByAmount[amount]=known; supportAmountByProduct[known]=amount end
 end
 if byId[KNOWN_DJ] then djProductId=KNOWN_DJ end
 for id,p in pairs(byId) do
  local n=upper(p.name); local price=p.price
  if not djProductId and price==DJ_AMOUNT and n:find("DJ",1,true) and (n:find("WALL",1,true) or n:find("MESSAGE",1,true)) then djProductId=id end
  if n:find("SUPPORT",1,true) or n:find("DONATE",1,true) or n:find("DONATION",1,true) then
   for _,amount in ipairs(SUPPORT_AMOUNTS) do
    if price==amount and not supportProductByAmount[amount] then supportProductByAmount[amount]=id; supportAmountByProduct[id]=amount end
   end
  end
 end
 catalogReady=true; catalogError=nil
 root:SetAttribute("BBYAMonetizationAuthority","V4_1_DONATION_NOTIFICATION")
 root:SetAttribute("BBYAReceiptIdempotency","PURCHASE_ID_DATASTORE_V1")
 root:SetAttribute("BBYADonationNotificationContract","Monetization:DonationNotification:v1")
 root:SetAttribute("BBYAMonetizationUniverseId",game.GameId)
 root:SetAttribute("BBYADJWallProductConfigured",djProductId~=nil)
 local count=0; for _ in pairs(supportProductByAmount) do count+=1 end
 root:SetAttribute("BBYASupportProductCount",count)
 print(string.format("[BBYA] Monetization catalog: universe=%s support=%d/8 dj=%s",tostring(game.GameId),count,tostring(djProductId)))
 return true
end
refreshProducts()
task.delay(5,function() if not catalogReady or next(supportProductByAmount)==nil then refreshProducts() end end)

-- Preserve existing physical DJ Wall presentation until notification UI passes TEST.
local C={black=Color3.fromRGB(5,5,8),pink=Color3.fromRGB(255,38,155),cyan=Color3.fromRGB(0,210,238),gold=Color3.fromRGB(238,190,94),white=Color3.fromRGB(244,242,247),muted=Color3.fromRGB(164,157,171)}
local model=Instance.new("Model"); model.Name="DJWallMessageSystem"; model:SetAttribute("Pass","DJ_WALL_MONETIZATION_V4_1_DONATION_NOTIFICATION"); model.Parent=root
local function part(name,size,cf,color,material,transparency)
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=color or C.black; p.Material=material or Enum.Material.Metal
 p.Transparency=transparency or 0; p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=true; p.CastShadow=false; p.Parent=model; return p
end
local wallCF=CFrame.new(3,10.0,46.34)
part("WallRecess",Vector3.new(58.5,14.1,.32),wallCF*CFrame.new(0,0,.15),Color3.fromRGB(4,4,6),Enum.Material.Metal,0)
local screen=part("PrestigeLED",Vector3.new(56.8,12.6,.12),wallCF*CFrame.new(0,0,-.10),Color3.fromRGB(7,6,10),Enum.Material.Glass,.02)
part("TopTrim",Vector3.new(56.9,.10,.10),wallCF*CFrame.new(0,6.34,-.18),C.pink,Enum.Material.Neon,0)
part("BottomTrim",Vector3.new(56.9,.08,.10),wallCF*CFrame.new(0,-6.34,-.18),C.cyan,Enum.Material.Neon,0)
local sg=Instance.new("SurfaceGui"); sg.Name="DJWallUI"; sg.Face=Enum.NormalId.Front; sg.AlwaysOnTop=false; sg.LightInfluence=.05; sg.PixelsPerStud=55; sg.Parent=screen
local bg=Instance.new("Frame"); bg.Size=UDim2.fromScale(1,1); bg.BackgroundColor3=C.black; bg.BorderSizePixel=0; bg.Parent=sg
local function lab(parent,text,pos,size,font,ts,color,align)
 local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Text=text; l.Position=pos; l.Size=size; l.Font=font or Enum.Font.Gotham
 l.TextSize=ts or 18; l.TextColor3=color or C.white; l.TextWrapped=true; l.TextXAlignment=align or Enum.TextXAlignment.Left; l.TextYAlignment=Enum.TextYAlignment.Center; l.Parent=parent; return l
end
local idle=Instance.new("Frame"); idle.Size=UDim2.fromScale(1,1); idle.BackgroundTransparency=1; idle.Parent=bg
lab(idle,"BBYA",UDim2.fromScale(.04,.05),UDim2.fromScale(.20,.10),Enum.Font.GothamBlack,42,C.white)
lab(idle,"DJ WALL • LIVE VISUALS",UDim2.fromScale(.30,.33),UDim2.fromScale(.40,.10),Enum.Font.GothamBlack,42,C.pink,Enum.TextXAlignment.Center)
lab(idle,"MESSAGE • COMMUNITY • 24/7",UDim2.fromScale(.30,.46),UDim2.fromScale(.40,.06),Enum.Font.GothamBold,18,C.muted,Enum.TextXAlignment.Center)
local message=Instance.new("Frame"); message.Size=UDim2.fromScale(1,1); message.BackgroundColor3=Color3.fromRGB(8,7,11); message.Visible=false; message.Parent=bg
local badge=lab(message,"BBYA LIVE MESSAGE",UDim2.fromScale(.06,.08),UDim2.fromScale(.88,.08),Enum.Font.GothamBlack,28,C.pink,Enum.TextXAlignment.Center)
local msgText=lab(message,"",UDim2.fromScale(.08,.25),UDim2.fromScale(.84,.38),Enum.Font.GothamBlack,48,C.white,Enum.TextXAlignment.Center)
local fromText=lab(message,"",UDim2.fromScale(.10,.69),UDim2.fromScale(.80,.08),Enum.Font.GothamBold,22,C.gold,Enum.TextXAlignment.Center)
local prompt=Instance.new("ProximityPrompt"); prompt.Name="CreatePrestigeMessage"; prompt.ActionText="Create Message"; prompt.ObjectText="BBYA DJ Wall"; prompt.KeyboardKeyCode=Enum.KeyCode.E
prompt.HoldDuration=0; prompt.MaxActivationDistance=14; prompt.RequiresLineOfSight=false; prompt.Parent=screen

local DISPLAY_SECONDS=12; local MAX_CHARS=80; local SUBMIT_COOLDOWN=45; local MAX_QUEUE=20
local queue={}; local pending={}; local lastSubmit={}; local displaying=false
local queuedPurchases={}; local deferredPaid={}
local CATEGORY={BIRTHDAY="BIRTHDAY CELEBRATION",LOVE="LOVE MESSAGE",SHOUTOUT="SHOUTOUT",CUSTOM="LIVE MESSAGE"}

local function isAdmin(p)
 if p:GetAttribute("BBYAAdmin")==true then return true end
 return game.CreatorType==Enum.CreatorType.User and p.UserId==game.CreatorId
end
local function filterMessage(p,raw)
 raw=tostring(raw or ""):gsub("[%c\r\n]+"," "):gsub("%s+"," "):match("^%s*(.-)%s*$") or ""
 if #raw<2 then return nil,"Pesan terlalu pendek." end; if #raw>MAX_CHARS then raw=raw:sub(1,MAX_CHARS) end
 local ok,result=pcall(function() return TextService:FilterStringAsync(raw,p.UserId):GetNonChatStringForBroadcastAsync() end)
 if not ok or not result or result=="" then return nil,"Pesan tidak dapat difilter." end
 if #(result:gsub("#",""):gsub("%s",""))<2 then return nil,"Pesan terlalu banyak disensor." end
 return result
end
local function payloadOf(entry)
 return {
  text=tostring(entry.text or ""),
  category=tostring(entry.category or "CUSTOM"),
  from=tostring(entry.from or entry.displayName or "Guest"),
  username=tostring(entry.username or ""),
  userId=tonumber(entry.userId) or 0,
  createdAt=tonumber(entry.createdAt) or os.time(),
 }
end
local function oldestRecoveryId(recovery)
 local bestId,bestAt=nil,nil
 for purchaseId,marker in pairs(recovery or {}) do
  local at=tonumber(type(marker)=="table" and marker.at) or 0
  if not bestAt or at<bestAt then bestAt=at;bestId=tostring(purchaseId) end
 end
 return bestId
end

local function removeDjOutstanding(userId,purchaseId)
 local removed=false
 for attempt=1,3 do
  local ok=select(1,safeUpdate(USER_STORE,userKey(userId),function(raw)
   local u=normalizeUser(raw)
   u.djOutstanding[purchaseId]=nil
   return u
  end))
  if ok then removed=true;break end
  task.wait(.35*attempt)
 end
 return removed
end

local function markDjDisplayed(purchaseId,userId)
 if not purchaseId or purchaseId=="" or not userId then return end
 task.spawn(function()
  local removed=removeDjOutstanding(userId,purchaseId)
  if not removed then warn("[BBYA Monetization] DJ outstanding cleanup deferred for "..purchaseId) end
  setReceiptFields(purchaseId,{displayedAt=os.time()})
 end)
end

local function queueMessage(entry,purchaseId)
 local e=payloadOf(entry)
 e.purchaseId=purchaseId and tostring(purchaseId) or nil
 if e.purchaseId then
  if queuedPurchases[e.purchaseId] then return true end
  queuedPurchases[e.purchaseId]=true
  if #queue>=MAX_QUEUE then deferredPaid[e.purchaseId]=e;return true end
 end
 if #queue>=MAX_QUEUE then return false end
 table.insert(queue,e)
 return true
end

local function showMessage(e)
 displaying=true; idle.Visible=false; message.Visible=true; badge.Text="BBYA • "..(CATEGORY[e.category] or CATEGORY.CUSTOM); msgText.Text=e.text; fromText.Text="FROM @"..e.from
 task.wait(DISPLAY_SECONDS); message.Visible=false; idle.Visible=true; displaying=false
 if e.purchaseId then markDjDisplayed(e.purchaseId,e.userId) end
end

task.spawn(function()
 while task.wait(.25) do
  if #queue<MAX_QUEUE then
   for purchaseId,e in pairs(deferredPaid) do deferredPaid[purchaseId]=nil;table.insert(queue,e);break end
  end
  if not displaying and #queue>0 then showMessage(table.remove(queue,1)) end
 end
end)

local function configFor(p) return {price=DJ_AMOUNT,productConfigured=djProductId~=nil,maxChars=MAX_CHARS,displaySeconds=DISPLAY_SECONDS,queue=#queue,admin=isAdmin(p)} end
prompt.Triggered:Connect(function(p) wallRemote:FireClient(p,"open",configFor(p)) end)

local function loadUser(userId)
 local ok,data=safeGet(USER_STORE,userKey(userId))
 if not ok then return false,nil end
 return true,normalizeUser(data)
end

local function clearDjPending(userId,token)
 if not token then return false end
 local ok=select(1,safeUpdate(USER_STORE,userKey(userId),function(raw)
  local u=normalizeUser(raw)
  if u.djPending and tostring(u.djPending.token or "")==tostring(token) then u.djPending=nil end
  return u
 end))
 return ok
end

local function persistNewDjPending(player,entry)
 local token=HttpService:GenerateGUID(false)
 local now=os.time()
 local ok,u=safeUpdate(USER_STORE,userKey(player.UserId),function(raw)
  local state=normalizeUser(raw)
  state.profile=profileFromPlayer(player) or state.profile
  local current=state.djPending
  if current and now-(tonumber(current.createdAt) or now)>DJ_PENDING_TTL then state.djPending=nil;current=nil end
  if current or next(state.djRecovery)~=nil then return state end
  local p=payloadOf(entry);p.token=token;p.createdAt=now
  state.djPending=p
  return state
 end)
 if not ok then return false,nil,"DATASTORE" end
 u=normalizeUser(u)
 if u.djPending and tostring(u.djPending.token or "")==token then return true,u.djPending,nil end
 if next(u.djRecovery)~=nil then return false,nil,"RECOVERY" end
 return false,nil,"PENDING"
end

local function attachRecoveryPayload(userId,purchaseId,entry)
 local now=os.time()
 local ok,u=safeUpdate(USER_STORE,userKey(userId),function(raw)
  local state=normalizeUser(raw)
  if state.djOutstanding[purchaseId] then return state end
  if not state.djRecovery[purchaseId] then return state end
  local p=payloadOf(entry);p.createdAt=p.createdAt or now
  state.djOutstanding[purchaseId]=p
  state.djRecovery[purchaseId]=nil
  return state
 end)
 if not ok then return false,nil end
 u=normalizeUser(u)
 return u.djOutstanding[purchaseId]~=nil,u.djOutstanding[purchaseId]
end

local function tryRecoverPaidDj(player,entry)
 local ok,u=loadUser(player.UserId)
 if not ok then return nil,"DATASTORE" end
 local purchaseId=oldestRecoveryId(u.djRecovery)
 if not purchaseId then return false,nil end
 local attached,payload=attachRecoveryPayload(player.UserId,purchaseId,entry)
 if not attached or not payload then return nil,"DATASTORE" end
 local receiptOk=select(1,setReceiptFields(purchaseId,{state="READY",payload=payload,recoveryFilledAt=os.time()}))
 if not receiptOk then
  wallRemote:FireClient(player,"toast","Recovery pembayaran tersimpan dan menunggu finalisasi. Tidak ada charge baru.")
  return true,purchaseId
 end
 wallRemote:FireClient(player,"toast","Pesan recovery tersimpan. Receipt akan difinalisasi tanpa charge baru.")
 return true,purchaseId
end

wallRemote.OnServerEvent:Connect(function(p,action,data)
 if action=="config" then wallRemote:FireClient(p,"config",configFor(p)); return end
 if action~="submit" or type(data)~="table" then return end
 local now=os.clock(); local last=lastSubmit[p.UserId] or 0
 if now-last<SUBMIT_COOLDOWN and not isAdmin(p) then wallRemote:FireClient(p,"toast","Tunggu sebentar sebelum kirim lagi."); return end
 if pending[p.UserId] then wallRemote:FireClient(p,"toast","Selesaikan request sebelumnya dulu."); return end
 if #queue>=MAX_QUEUE and next(deferredPaid)==nil then wallRemote:FireClient(p,"toast","Antrean DJ Wall sedang penuh."); return end
 local category=tostring(data.category or "CUSTOM"):upper(); if not CATEGORY[category] then category="CUSTOM" end
 local filtered,err=filterMessage(p,data.text); if not filtered then wallRemote:FireClient(p,"toast",err or "Pesan ditolak."); return end
 local entry={text=filtered,category=category,from=p.DisplayName,username=p.Name,userId=p.UserId,createdAt=os.time()}; lastSubmit[p.UserId]=now
 if isAdmin(p) then queueMessage(entry); wallRemote:FireClient(p,"queued",{position=#queue,text=filtered,adminPreview=true}); return end

 local recovered=tryRecoverPaidDj(p,entry)
 if recovered==true then return end
 if recovered==nil then wallRemote:FireClient(p,"toast","Recovery pembayaran sedang tidak tersedia. Coba lagi sebentar; tidak ada charge baru.");return end

 if not djProductId then refreshProducts() end
 if not djProductId then wallRemote:FireClient(p,"toast","DJ Wall 2R belum dikonfigurasi untuk universe ini."); return end
 local saved,durablePending,saveErr=persistNewDjPending(p,entry)
 if not saved then
  if saveErr=="RECOVERY" then wallRemote:FireClient(p,"toast","Ada pembayaran DJ Wall yang perlu dipulihkan. Kirim lagi sebentar; tidak akan ditagih dua kali.")
  elseif saveErr=="PENDING" then wallRemote:FireClient(p,"toast","Selesaikan request DJ Wall sebelumnya dulu.")
  else wallRemote:FireClient(p,"toast","Pembayaran sementara tidak tersedia karena penyimpanan gagal. Tidak ada charge dibuka.") end
  return
 end
 pending[p.UserId]=durablePending
 wallRemote:FireClient(p,"purchase",{message=filtered})
 local promptOk=pcall(function() MarketplaceService:PromptProductPurchase(p,djProductId) end)
 if not promptOk then
  local token=durablePending.token
  pending[p.UserId]=nil
  task.spawn(function()clearDjPending(p.UserId,token)end)
  wallRemote:FireClient(p,"toast","Purchase prompt gagal dibuka.")
 end
end)

monetizationRemote.OnServerEvent:Connect(function(p,action,value)
 if action=="audit" then
  local available={}; for _,a in ipairs(SUPPORT_AMOUNTS) do available[a]=supportProductByAmount[a]~=nil end
  monetizationRemote:FireClient(p,"audit",{support=available,dj=djProductId~=nil,universeId=game.GameId,error=catalogError}); return
 end
 if action~="promptSupport" then return end
 local amount=tonumber(value); if not amount or not table.find(SUPPORT_AMOUNTS,amount) then return end
 local id=supportProductByAmount[amount]
 if not id then refreshProducts(); id=supportProductByAmount[amount] end
 if not id then monetizationRemote:FireClient(p,"status",{amount=amount,ok=false,message=string.format("Support %dR belum punya Developer Product di BBYA universe.",amount)}); return end
 monetizationRemote:FireClient(p,"status",{amount=amount,ok=true,message="Opening Roblox purchase..."})
 monetizationRemote:FireClient(p,"promptSupportLocal",{amount=amount,productId=id})
end)

local function applySupportDonationReceipt(receipt,purchaseId,amount)
 local playerId=tonumber(receipt.PlayerId)
 local player=Players:GetPlayerByUserId(playerId)
 local readOk,prior=loadUser(playerId)
 if not readOk then return false,nil,nil,nil end
 local profile=resolveProfile(playerId,player,prior,nil)
 if not profile then return false,nil,nil,nil end
 local now=os.time()
 local ok,u=safeUpdate(USER_STORE,userKey(playerId),function(raw)
  local state=normalizeUser(raw)
  state.profile=profile
  if not state.supportApplied[purchaseId] then
   state.supportTotal=(tonumber(state.supportTotal) or 0)+amount
   state.supportApplied[purchaseId]={amount=amount,at=now}
  end
  if not state.donationApplied[purchaseId] then
   state.donationTotal=(tonumber(state.donationTotal) or 0)+amount
   state.donationApplied[purchaseId]={amount=amount,at=now,source="SUPPORT"}
  end
  return state
 end)
 if not ok then return false,nil,nil,nil end
 u=normalizeUser(u)
 local supportMarker=u.supportApplied[purchaseId]
 local donationMarker=u.donationApplied[purchaseId]
 if not supportMarker or tonumber(supportMarker.amount)~=amount or not donationMarker or tonumber(donationMarker.amount)~=amount then return false,nil,nil,nil end
 return true,u.supportTotal,u.donationTotal,profile
end

local function applyDjDonationReceipt(receipt,purchaseId,payload)
 local playerId=tonumber(receipt.PlayerId)
 local player=Players:GetPlayerByUserId(playerId)
 local readOk,prior=loadUser(playerId)
 if not readOk then return false,nil,nil end
 local profile=resolveProfile(playerId,player,prior,payload)
 if not profile then return false,nil,nil end
 local now=os.time()
 local ok,u=safeUpdate(USER_STORE,userKey(playerId),function(raw)
  local state=normalizeUser(raw)
  state.profile=profile
  if not state.donationApplied[purchaseId] then
   state.donationTotal=(tonumber(state.donationTotal) or 0)+DJ_AMOUNT
   state.donationApplied[purchaseId]={amount=DJ_AMOUNT,at=now,source="DJ_MESSAGE"}
  end
  return state
 end)
 if not ok then return false,nil,nil end
 u=normalizeUser(u)
 local marker=u.donationApplied[purchaseId]
 if not marker or tonumber(marker.amount)~=DJ_AMOUNT then return false,nil,nil end
 return true,u.donationTotal,profile
end

local function buildDonationNotification(playerId,profile,amount,total,messageText)
 return {
  userId=playerId,
  displayName=tostring(profile.displayName or profile.username or ""),
  username=tostring(profile.username or ""),
  avatarUserId=playerId,
  amount=amount,
  total=total,
  message=tostring(messageText or ""),
 }
end

local function emitDonationNotificationOnce(purchaseId,payload)
 local claimToken=SERVER_CLAIM_ID..":"..HttpService:GenerateGUID(false)
 local now=os.time()
 local ok,r=updateReceipt(purchaseId,function(current)
  if not current.notificationClaimToken then
   current.notificationClaimToken=claimToken
   current.notificationClaimedAt=now
   current.notificationPayload=current.notificationPayload or payload
  end
  current.updatedAt=now
  return current
 end)
 if not ok or type(r)~="table" then return false,"DATASTORE" end
 if tostring(r.notificationClaimToken or "")~=claimToken then return true,"ALREADY_CLAIMED" end
 local fireOk,fireErr=pcall(function()
  monetizationRemote:FireAllClients("DonationNotification",payload)
 end)
 if not fireOk then warn("[BBYA Monetization] DonationNotification emit failed after durable claim: "..tostring(fireErr));return true,"CLAIMED_NOT_EMITTED" end
 task.spawn(function()setReceiptFields(purchaseId,{notificationEmittedAt=os.time()})end)
 return true,"EMITTED"
end

local function bindDjReceipt(receipt,purchaseId)
 local playerId=tonumber(receipt.PlayerId)
 local now=os.time()
 local ok,u=safeUpdate(USER_STORE,userKey(playerId),function(raw)
  local state=normalizeUser(raw)
  if state.djOutstanding[purchaseId] then return state end
  if state.djPending then
   local p=payloadOf(state.djPending)
   state.djOutstanding[purchaseId]=p
   state.djPending=nil
   return state
  end
  state.djRecovery[purchaseId]=state.djRecovery[purchaseId] or {at=now,productId=KNOWN_DJ}
  return state
 end)
 if not ok then return false,nil,false end
 u=normalizeUser(u)
 local payload=u.djOutstanding[purchaseId]
 if payload then return true,payload,false end
 if u.djRecovery[purchaseId] then return true,nil,true end
 return false,nil,false
end

-- THE ONLY Developer Product receipt authority in this map.
MarketplaceService.ProcessReceipt=function(receipt)
 local productId=tonumber(receipt.ProductId)
 local kind,amount=classifyProduct(productId)
 if not kind then return Enum.ProductPurchaseDecision.NotProcessedYet end

 local purchaseId=tostring(receipt.PurchaseId or "")
 if purchaseId=="" then
  warn("[BBYA Monetization] known product receipt missing PurchaseId")
  return Enum.ProductPurchaseDecision.NotProcessedYet
 end

 local recordOk,record=ensureReceiptRecord(receipt,kind,amount)
 if not recordOk then return Enum.ProductPurchaseDecision.NotProcessedYet end
 if record.state=="ACK_READY" then
  local payload=type(record.notificationPayload)=="table" and record.notificationPayload or nil
  if payload and not record.notificationClaimToken then
   local notificationOk=select(1,emitDonationNotificationOnce(purchaseId,payload))
   if not notificationOk then return Enum.ProductPurchaseDecision.NotProcessedYet end
  end
  return Enum.ProductPurchaseDecision.PurchaseGranted
 end

 if kind=="SUPPORT" then
  local applied,supportTotal,donationTotal,profile=applySupportDonationReceipt(receipt,purchaseId,amount)
  if not applied then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local notificationPayload=buildDonationNotification(tonumber(receipt.PlayerId),profile,amount,donationTotal,"")
  local readyOk=select(1,setReceiptFields(purchaseId,{
   state="READY",
   grantRecordedAt=os.time(),
   supportTotal=supportTotal,
   donationTotal=donationTotal,
   notificationPayload=notificationPayload,
  }))
  if not readyOk then return Enum.ProductPurchaseDecision.NotProcessedYet end

  local p=Players:GetPlayerByUserId(tonumber(receipt.PlayerId))
  if p then
   p:SetAttribute("BBYASupportRobuxTotal",supportTotal)
   p:SetAttribute("BBYADonationRobuxTotal",donationTotal)
  end

  local ackOk,ackRecord=setReceiptFields(purchaseId,{state="ACK_READY",runtimeGrantedAt=os.time()})
  if not ackOk or type(ackRecord)~="table" or ackRecord.state~="ACK_READY" then return Enum.ProductPurchaseDecision.NotProcessedYet end

  local notificationOk=select(1,emitDonationNotificationOnce(purchaseId,notificationPayload))
  if not notificationOk then return Enum.ProductPurchaseDecision.NotProcessedYet end
  if p then
   monetizationRemote:FireClient(p,"receipt",{amount=amount,message=string.format("Support %dR diterima • Thank you!",amount),total=supportTotal})
   stateRemote:FireAllClients("supportReceived",{displayName=p.DisplayName,userId=p.UserId,amount=amount,total=supportTotal})
  end
  return Enum.ProductPurchaseDecision.PurchaseGranted
 end

 local bound,payload,needsRecovery=true,nil,false
 if record.state=="READY" and type(record.payload)=="table" then
  payload=payloadOf(record.payload)
 else
  bound,payload,needsRecovery=bindDjReceipt(receipt,purchaseId)
  pending[tonumber(receipt.PlayerId)]=nil
 end
 if not bound then return Enum.ProductPurchaseDecision.NotProcessedYet end
 if needsRecovery or not payload then
  local waitOk=select(1,setReceiptFields(purchaseId,{state="WAITING_PAYLOAD",recoveryRecordedAt=os.time()}))
  if not waitOk then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local p=Players:GetPlayerByUserId(tonumber(receipt.PlayerId))
  if p then stateRemote:FireClient(p,"toast","Pembayaran DJ Wall tersimpan. Kirim ulang pesan untuk recovery; tidak akan ditagih lagi.") end
  return Enum.ProductPurchaseDecision.NotProcessedYet
 end

 local donationApplied,donationTotal,profile=applyDjDonationReceipt(receipt,purchaseId,payload)
 if not donationApplied then return Enum.ProductPurchaseDecision.NotProcessedYet end
 local notificationPayload=buildDonationNotification(tonumber(receipt.PlayerId),profile,DJ_AMOUNT,donationTotal,payload.text)
 local readyOk=select(1,setReceiptFields(purchaseId,{
  state="READY",
  payload=payload,
  grantRecordedAt=record.grantRecordedAt or os.time(),
  donationTotal=donationTotal,
  notificationPayload=notificationPayload,
 }))
 if not readyOk then return Enum.ProductPurchaseDecision.NotProcessedYet end
 local claimed,claimStatus=claimDjRuntime(purchaseId)
 if claimStatus=="ACK" then
  local latestOk,latest=safeGet(RECEIPT_STORE,receiptKey(purchaseId))
  if not latestOk then return Enum.ProductPurchaseDecision.NotProcessedYet end
  if type(latest)=="table" and type(latest.notificationPayload)=="table" and not latest.notificationClaimToken then
   local notificationOk=select(1,emitDonationNotificationOnce(purchaseId,latest.notificationPayload))
   if not notificationOk then return Enum.ProductPurchaseDecision.NotProcessedYet end
  end
  return Enum.ProductPurchaseDecision.PurchaseGranted
 end
 if not claimed then return Enum.ProductPurchaseDecision.NotProcessedYet end
 queueMessage(payload,purchaseId)
 local ackOk,ackRecord=setReceiptFields(purchaseId,{state="ACK_READY",runtimeQueuedAt=os.time()})
 if not ackOk or type(ackRecord)~="table" or ackRecord.state~="ACK_READY" then return Enum.ProductPurchaseDecision.NotProcessedYet end
 local p=Players:GetPlayerByUserId(tonumber(receipt.PlayerId))
 if p then
  p:SetAttribute("BBYADonationRobuxTotal",donationTotal)
  wallRemote:FireClient(p,"queued",{position=#queue,text=payload.text})
 end
 local notificationOk=select(1,emitDonationNotificationOnce(purchaseId,notificationPayload))
 if not notificationOk then return Enum.ProductPurchaseDecision.NotProcessedYet end
 return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- This event never grants a purchase. It only releases a canceled DJ pending payload.
MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId,productId,purchased)
 if tonumber(productId)~=KNOWN_DJ or purchased then return end
 local mem=pending[tonumber(userId)]
 if mem then
  pending[tonumber(userId)]=nil
  task.spawn(function()clearDjPending(tonumber(userId),mem.token)end)
 end
end)

local function recoverPlayer(player)
 local profileSaved=persistPlayerProfile(player)
 if not profileSaved then warn("[BBYA Monetization] profile persistence deferred for "..player.UserId) end
 local ok,u=loadUser(player.UserId)
 if not ok then return end
 local supportTotal=tonumber(u.supportTotal) or 0
 local donationTotal=tonumber(u.donationTotal) or supportTotal
 player:SetAttribute("BBYASupportRobuxTotal",supportTotal)
 player:SetAttribute("BBYADonationRobuxTotal",donationTotal)
 local recoveredCount=0
 for purchaseId,payload in pairs(u.djOutstanding) do
  if type(payload)=="table" then
   local ledgerOk,ledger=safeGet(RECEIPT_STORE,receiptKey(tostring(purchaseId)))
   if ledgerOk and type(ledger)=="table" and ledger.displayedAt then
    task.spawn(function()removeDjOutstanding(player.UserId,tostring(purchaseId))end)
   elseif ledgerOk and type(ledger)=="table" and ledger.state=="ACK_READY" then
    queueMessage(payload,tostring(purchaseId));recoveredCount+=1
   end
  end
 end
 local recoveryCount=0;for _ in pairs(u.djRecovery) do recoveryCount+=1 end
 if recoveryCount>0 then
  task.delay(1,function()
   if player.Parent then stateRemote:FireClient(player,"toast","Ada pembayaran DJ Wall yang tersimpan. Kirim pesan DJ Wall untuk recovery tanpa charge baru.") end
  end)
 elseif recoveredCount>0 then
  task.delay(1,function()
   if player.Parent then stateRemote:FireClient(player,"toast","Pesan DJ Wall berbayar dipulihkan ke antrean.") end
  end)
 end
end

for _,p in ipairs(Players:GetPlayers()) do task.spawn(recoverPlayer,p) end
Players.PlayerAdded:Connect(function(p)task.spawn(recoverPlayer,p)end)
Players.PlayerRemoving:Connect(function(p)
 pending[p.UserId]=nil
 lastSubmit[p.UserId]=nil
end)

print("[BBYA] DJ Wall + Monetization v4.1 online: receipt safety / persistent donor total / DonationNotification backend / legacy DJ Wall preserved / one ProcessReceipt authority")
