-- BBYA SOCIAL HUB — SUPPORT PURCHASE LOCAL PROMPT v1
-- Purchase prompt only. Server remains the sole catalog validator + ProcessReceipt authority.
-- No panel geometry, no menu layout, no receipt granting.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")

local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local monetizationRemote=remotes and remotes:WaitForChild("Monetization",30)
if not monetizationRemote then return end

local busy=false
local activeProductId=nil

local function resetBusy()
 busy=false
 activeProductId=nil
end

monetizationRemote.OnClientEvent:Connect(function(action,data)
 if action~="promptSupportLocal" then return end
 data=type(data)=="table" and data or {}
 local productId=tonumber(data.productId)
 local amount=tonumber(data.amount)
 if not productId or productId<=0 or not amount then
  warn("[BBYA Support] invalid server-resolved purchase payload")
  return
 end
 if busy then return end
 busy=true;activeProductId=productId

 -- Roblox recommends opening Developer Product prompts from a LocalScript,
 -- especially when Managed Pricing / personalized pricing may be active.
 local infoOk,info=pcall(function()
  return MarketplaceService:GetProductInfo(productId,Enum.InfoType.Product)
 end)
 if not infoOk or type(info)~="table" or info.IsForSale==false then
  warn("[BBYA Support] product unavailable for local purchase prompt: "..tostring(productId))
  resetBusy()
  return
 end

 local promptOk,promptErr=pcall(function()
  MarketplaceService:PromptProductPurchase(player,productId)
 end)
 if not promptOk then
  warn("[BBYA Support] local PromptProductPurchase failed: "..tostring(promptErr))
  resetBusy()
  return
 end

 task.delay(12,function()
  if activeProductId==productId then resetBusy() end
 end)
end)

MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId,productId,_purchased)
 if userId==player.UserId and tonumber(productId)==activeProductId then resetBusy() end
end)

print("[BBYA] Support local purchase prompt v1 online; receipts remain server-authoritative")
