-- BBYA SOCIAL HUB — SUPPORT PURCHASE LOCAL ADAPTER v4.1
-- Native Roblox checkout only. No custom receipt/purchase confirmation toast.
-- The legacy Support panel keeps its existing single prompt trigger; this adapter only services
-- Monetization-authority local prompts and never attaches a second click handler.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")

local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local monetizationRemote=remotes and remotes:WaitForChild("Monetization",30)
if not monetizationRemote then return end

local promptBusy=false
local activeProductId=nil

local function finishPrompt()
 promptBusy=false
 activeProductId=nil
end

monetizationRemote.OnClientEvent:Connect(function(action,data)
 data=type(data)=="table" and data or {}
 if action~="promptSupportLocal" then
  -- receipt/status/audit stay server-authoritative; Roblox native UI is the only purchase confirmation.
  return
 end
 local productId=tonumber(data.productId)
 if not productId or productId<=0 or promptBusy then return end
 promptBusy=true
 activeProductId=productId
 local ok,err=pcall(function()
  MarketplaceService:PromptProductPurchase(player,productId)
 end)
 if not ok then
  warn("[BBYA Support] PromptProductPurchase failed: "..tostring(err))
  finishPrompt()
  return
 end
 task.delay(45,function()
  if promptBusy and activeProductId==productId then finishPrompt() end
 end)
end)

MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId,productId)
 if userId~=player.UserId then return end
 if activeProductId and tonumber(productId)~=activeProductId then return end
 finishPrompt()
end)

print("[BBYA] Support purchase local adapter v4.1 online: native checkout only / no custom toast / no duplicate button binding")