-- BBYA SOCIAL HUB — SUPPORT PURCHASE LOCAL ADAPTER v2
-- Function-only purchase prompt bridge. No UI/layout authority and no receipt granting.
-- UI Kernel owns Support panel; server owns catalog validation + ProcessReceipt.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")

local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local monetizationRemote=remotes and remotes:WaitForChild("Monetization",30)
if not monetizationRemote then return end

local promptBusy=false

monetizationRemote.OnClientEvent:Connect(function(action,data)
 if action~="promptSupportLocal" then return end
 data=type(data)=="table" and data or {}
 local productId=tonumber(data.productId)
 if not productId or productId<=0 or promptBusy then return end

 promptBusy=true
 local ok,err=pcall(function()
  MarketplaceService:PromptProductPurchase(player,productId)
 end)
 if not ok then
  warn("[BBYA Support] PromptProductPurchase failed: "..tostring(err))
  promptBusy=false
  return
 end

 task.delay(8,function() promptBusy=false end)
end)

MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId,_productId,_purchased)
 if userId==player.UserId then promptBusy=false end
end)

print("[BBYA] Support purchase local adapter v2 online; UI Kernel unchanged; receipts server-authoritative")
