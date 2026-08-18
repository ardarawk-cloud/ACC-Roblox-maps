-- [SYS-MONEY] VIP + SAWER BACKEND
-- Real IDs intentionally remain 0 until supplied. Never invent Roblox commerce IDs.
local MarketplaceService=game:GetService("MarketplaceService")
local DataStoreService=game:GetService("DataStoreService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local VIP_GAMEPASS_ID=0 -- target price configured in Creator Dashboard: 10 Robux
local SUPPORT_PRODUCTS={[5]=0,[10]=0,[50]=0,[100]=0,[500]=0}
local donationStore=DataStoreService:GetDataStore("BBYA_Donations_v2")
local supporterStore=DataStoreService:GetOrderedDataStore("BBYA_TopSupporters_v1")

local cfg=ReplicatedStorage:FindFirstChild("BBYA_V5_Monetization") or Instance.new("Folder");cfg.Name="BBYA_V5_Monetization";cfg.Parent=ReplicatedStorage
local function intv(name,v)local x=cfg:FindFirstChild(name) or Instance.new("IntValue");x.Name=name;x.Value=v or 0;x.Parent=cfg;return x end
intv("VIPGamePassId",VIP_GAMEPASS_ID)
for amount,id in pairs(SUPPORT_PRODUCTS) do intv("Support_"..amount,id) end

local productToAmount={};for amount,id in pairs(SUPPORT_PRODUCTS) do if id>0 then productToAmount[id]=amount end end
workspace:SetAttribute("BBYAMonetizationConfigured",VIP_GAMEPASS_ID>0 or next(productToAmount)~=nil)
workspace:SetAttribute("BBYAVIPTargetPrice",10)

local function checkVIP(p)
 if p.UserId==QUEEN_ID then p:SetAttribute("IsVIP",true);p:SetAttribute("BBYAAllAccess",true);return end
 if VIP_GAMEPASS_ID<=0 then if p:GetAttribute("IsVIP")==nil then p:SetAttribute("IsVIP",false) end;return end
 local ok,owns=pcall(function() return MarketplaceService:UserOwnsGamePassAsync(p.UserId,VIP_GAMEPASS_ID) end);p:SetAttribute("IsVIP",ok and owns==true)
end
local function loadDonation(p)
 local data;pcall(function() data=donationStore:GetAsync("u"..p.UserId) end);local total=type(data)=="table" and tonumber(data.Total) or 0;p:SetAttribute("TotalDonated",total or 0)
 local ls=p:FindFirstChild("leaderstats");if ls then local d=ls:FindFirstChild("Donated");if d then d.Value=total or 0 end end
end
Players.PlayerAdded:Connect(function(p) task.spawn(checkVIP,p);task.spawn(loadDonation,p) end)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(checkVIP,p);task.spawn(loadDonation,p) end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p,passId,purchased)
 if VIP_GAMEPASS_ID>0 and passId==VIP_GAMEPASS_ID and purchased then p:SetAttribute("IsVIP",true);p:SetAttribute("BBYARole","VIP") end
end)

MarketplaceService.ProcessReceipt=function(receipt)
 local amount=productToAmount[receipt.ProductId];if not amount then return Enum.ProductPurchaseDecision.NotProcessedYet end
 local p=Players:GetPlayerByUserId(receipt.PlayerId);if not p then return Enum.ProductPurchaseDecision.NotProcessedYet end
 local key="u"..p.UserId;local purchaseId=tostring(receipt.PurchaseId);local granted=false
 local ok,data=pcall(function()
  return donationStore:UpdateAsync(key,function(d)
   d=type(d)=="table" and d or {Total=0,Receipts={}};d.Receipts=type(d.Receipts)=="table" and d.Receipts or {};d.Total=tonumber(d.Total) or 0
   if d.Receipts[purchaseId] then return d end
   d.Total+=amount;d.Receipts[purchaseId]=os.time();granted=true;return d
  end)
 end)
 if not ok or type(data)~="table" then return Enum.ProductPurchaseDecision.NotProcessedYet end
 local total=tonumber(data.Total) or 0;p:SetAttribute("TotalDonated",total)
 local ls=p:FindFirstChild("leaderstats");if ls and ls:FindFirstChild("Donated") then ls.Donated.Value=total end
 pcall(function() supporterStore:SetAsync("u"..p.UserId,total) end)
 if granted then workspace:SetAttribute("BBYALastSupporter",p.DisplayName);workspace:SetAttribute("BBYALastSupportAmount",amount);workspace:SetAttribute("BBYALastSupportTotal",total);NoticeRemote:FireAllClients(p.DisplayName.." supported BBYA • R$"..amount) end
 return Enum.ProductPurchaseDecision.PurchaseGranted
end

local boardFn=remotes:FindFirstChild("SupportBoard") or Instance.new("RemoteFunction");boardFn.Name="SupportBoard";boardFn.Parent=remotes
boardFn.OnServerInvoke=function(p)
 local rows={};local ok,pages=pcall(function() return supporterStore:GetSortedAsync(false,10) end);if not ok then return rows end
 for _,item in ipairs(pages:GetCurrentPage()) do
  local uid=tonumber(tostring(item.key):match("u(%d+)"));local name="User "..tostring(uid or "?");if uid then pcall(function() name=Players:GetNameFromUserIdAsync(uid) end) end
  table.insert(rows,{name=name,total=tonumber(item.value) or 0})
 end
 return rows
end
workspace:SetAttribute("BBYASystemMoney","5.0")
