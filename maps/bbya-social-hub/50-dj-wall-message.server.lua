-- BBYA SOCIAL HUB — DJ WALL + MONETIZATION AUTHORITY v3
-- ONE Developer Product authority for DJ Wall and Support.
-- Products are discovered from the CURRENT universe; cross-game product IDs are never blindly prompted.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local TextService=game:GetService("TextService")
local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD")
local old=root:FindFirstChild("DJWallMessageSystem"); if old then old:Destroy() end

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes"; remotes.Parent=ReplicatedStorage
local wallRemote=remotes:FindFirstChild("DJWall") or Instance.new("RemoteEvent"); wallRemote.Name="DJWall"; wallRemote.Parent=remotes
local stateRemote=remotes:FindFirstChild("State") or Instance.new("RemoteEvent"); stateRemote.Name="State"; stateRemote.Parent=remotes
local monetizationRemote=remotes:FindFirstChild("Monetization") or Instance.new("RemoteEvent"); monetizationRemote.Name="Monetization"; monetizationRemote.Parent=remotes

local KNOWN_DJ=3709047092
local KNOWN_SUPPORT={
 [10]=3709047095,[25]=3709047097,[50]=3709047101,[100]=3709047104,
 [250]=3709047106,[500]=3709047107,[1000]=3709047109,[2000]=3709048779,
}
local SUPPORT_AMOUNTS={10,25,50,100,250,500,1000,2000}
local supportProductByAmount={}
local supportAmountByProduct={}
local djProductId=nil
local catalogReady=false
local catalogError=nil

local function upper(v) return string.upper(tostring(v or "")) end
local function productIdOf(p) return tonumber(p.DeveloperProductId or p.developerProductId or p.ProductId or p.productId or p.id) end
local function priceOf(p) return tonumber(p.PriceInRobux or p.priceInRobux or p.Price or p.price) end
local function nameOf(p) return tostring(p.Name or p.name or p.displayName or p.DisplayName or "") end
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
  if not djProductId and price==2 and n:find("DJ",1,true) and (n:find("WALL",1,true) or n:find("MESSAGE",1,true)) then djProductId=id end
  if n:find("SUPPORT",1,true) or n:find("DONATE",1,true) or n:find("DONATION",1,true) then
   for _,amount in ipairs(SUPPORT_AMOUNTS) do
    if price==amount and not supportProductByAmount[amount] then supportProductByAmount[amount]=id; supportAmountByProduct[id]=amount end
   end
  end
 end
 catalogReady=true; catalogError=nil
 root:SetAttribute("BBYAMonetizationAuthority","V3_CURRENT_UNIVERSE")
 root:SetAttribute("BBYAMonetizationUniverseId",game.GameId)
 root:SetAttribute("BBYADJWallProductConfigured",djProductId~=nil)
 local count=0; for _ in pairs(supportProductByAmount) do count+=1 end
 root:SetAttribute("BBYASupportProductCount",count)
 print(string.format("[BBYA] Monetization catalog: universe=%s support=%d/8 dj=%s",tostring(game.GameId),count,tostring(djProductId)))
 return true
end
refreshProducts()
task.delay(5,function() if not catalogReady or next(supportProductByAmount)==nil then refreshProducts() end end)

-- Keep one simple physical DJ wall display; monetization authority is independent from UI shell.
local C={black=Color3.fromRGB(5,5,8),pink=Color3.fromRGB(255,38,155),cyan=Color3.fromRGB(0,210,238),gold=Color3.fromRGB(238,190,94),white=Color3.fromRGB(244,242,247),muted=Color3.fromRGB(164,157,171)}
local model=Instance.new("Model"); model.Name="DJWallMessageSystem"; model:SetAttribute("Pass","DJ_WALL_MONETIZATION_V3"); model.Parent=root
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
local function queueMessage(e) if #queue>=MAX_QUEUE then return false end; table.insert(queue,e); return true end
local function showMessage(e)
 displaying=true; idle.Visible=false; message.Visible=true; badge.Text="BBYA • "..(CATEGORY[e.category] or CATEGORY.CUSTOM); msgText.Text=e.text; fromText.Text="FROM @"..e.from
 task.wait(DISPLAY_SECONDS); message.Visible=false; idle.Visible=true; displaying=false
end
task.spawn(function() while task.wait(.25) do if not displaying and #queue>0 then showMessage(table.remove(queue,1)) end end end)
local function configFor(p) return {price=2,productConfigured=djProductId~=nil,maxChars=MAX_CHARS,displaySeconds=DISPLAY_SECONDS,queue=#queue,admin=isAdmin(p)} end
prompt.Triggered:Connect(function(p) wallRemote:FireClient(p,"open",configFor(p)) end)

wallRemote.OnServerEvent:Connect(function(p,action,data)
 if action=="config" then wallRemote:FireClient(p,"config",configFor(p)); return end
 if action~="submit" or type(data)~="table" then return end
 local now=os.clock(); local last=lastSubmit[p.UserId] or 0
 if now-last<SUBMIT_COOLDOWN and not isAdmin(p) then wallRemote:FireClient(p,"toast","Tunggu sebentar sebelum kirim lagi."); return end
 if pending[p.UserId] then wallRemote:FireClient(p,"toast","Selesaikan request sebelumnya dulu."); return end
 if #queue>=MAX_QUEUE then wallRemote:FireClient(p,"toast","Antrean DJ Wall sedang penuh."); return end
 local category=tostring(data.category or "CUSTOM"):upper(); if not CATEGORY[category] then category="CUSTOM" end
 local filtered,err=filterMessage(p,data.text); if not filtered then wallRemote:FireClient(p,"toast",err or "Pesan ditolak."); return end
 local entry={text=filtered,category=category,from=p.DisplayName,userId=p.UserId}; lastSubmit[p.UserId]=now
 if isAdmin(p) then queueMessage(entry); wallRemote:FireClient(p,"queued",{position=#queue,text=filtered,adminPreview=true}); return end
 if not djProductId then refreshProducts() end
 if not djProductId then wallRemote:FireClient(p,"toast","DJ Wall 2R belum dikonfigurasi untuk universe ini."); return end
 pending[p.UserId]=entry; wallRemote:FireClient(p,"purchase",{message=filtered})
 local ok=pcall(function() MarketplaceService:PromptProductPurchase(p,djProductId) end)
 if not ok then pending[p.UserId]=nil; wallRemote:FireClient(p,"toast","Purchase prompt gagal dibuka.") end
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
 if not id then monetizationRemote:FireClient(p,"status",{amount=amount,ok=false,message=string.format("Support %dR belum punya Developer Product di TEST universe.",amount)}); return end
 monetizationRemote:FireClient(p,"status",{amount=amount,ok=true,message="Opening Roblox purchase..."})
 local ok=pcall(function() MarketplaceService:PromptProductPurchase(p,id) end)
 if not ok then monetizationRemote:FireClient(p,"status",{amount=amount,ok=false,message="Purchase prompt gagal dibuka."}) end
end)

-- THE ONLY Developer Product receipt authority in this map.
MarketplaceService.ProcessReceipt=function(receipt)
 local productId=tonumber(receipt.ProductId)
 if not productId then return Enum.ProductPurchaseDecision.NotProcessedYet end
 if not catalogReady then refreshProducts() end
 if productId==djProductId then
  local e=pending[receipt.PlayerId]; pending[receipt.PlayerId]=nil
  if e then queueMessage(e); local p=Players:GetPlayerByUserId(receipt.PlayerId); if p then wallRemote:FireClient(p,"queued",{position=#queue,text=e.text}) end end
  return Enum.ProductPurchaseDecision.PurchaseGranted
 end
 local amount=supportAmountByProduct[productId]
 if amount then
  local p=Players:GetPlayerByUserId(receipt.PlayerId)
  if p then
   local total=(tonumber(p:GetAttribute("BBYASupportRobuxTotal")) or 0)+amount; p:SetAttribute("BBYASupportRobuxTotal",total)
   monetizationRemote:FireClient(p,"receipt",{amount=amount,message=string.format("Support %dR diterima • Thank you!",amount),total=total})
   stateRemote:FireAllClients("supportReceived",{displayName=p.DisplayName,userId=p.UserId,amount=amount,total=total})
  end
  return Enum.ProductPurchaseDecision.PurchaseGranted
 end
 return Enum.ProductPurchaseDecision.NotProcessedYet
end

Players.PlayerRemoving:Connect(function(p) pending[p.UserId]=nil; lastSubmit[p.UserId]=nil end)
print("[BBYA] DJ Wall + Monetization v3 online: one receipt authority, current-universe products only")
