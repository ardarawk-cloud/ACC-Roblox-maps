-- BBYA SOCIAL HUB — SULTAN CONTRIBUTION ADAPTER v1
-- Bridges verified SULTAN CORE ownership into the existing Top 3 donor ledger.
-- No new pass is created. Existing Top 3 authority remains 34-support-dashboard.server.lua.

local Players=game:GetService("Players")
local MarketplaceService=game:GetService("MarketplaceService")

local SULTAN_PASS_ID=1490269572
local SULTAN_PRICE=10000

local function apply(player)
 if not player or not player.Parent then return end
 local ok,owned=pcall(function()
  return MarketplaceService:UserOwnsGamePassAsync(player.UserId,SULTAN_PASS_ID)
 end)
 if not player.Parent then return end
 player:SetAttribute("BBYASultanPassId",SULTAN_PASS_ID)
 player:SetAttribute("BBYASultanPassPrice",SULTAN_PRICE)
 player:SetAttribute("BBYASultanOwnershipVerified",ok==true)
 if ok and owned==true then
  player:SetAttribute("BBYASultanPassOwned",true)
  player:SetAttribute("BBYASultanContributionRobux",SULTAN_PRICE)
 else
  player:SetAttribute("BBYASultanPassOwned",false)
  player:SetAttribute("BBYASultanContributionRobux",0)
 end
end

local function verifyWithRetry(player)
 for attempt=1,3 do
  apply(player)
  if player:GetAttribute("BBYASultanOwnershipVerified")==true then return end
  task.wait(attempt)
 end
end

for _,player in ipairs(Players:GetPlayers()) do task.spawn(verifyWithRetry,player) end
Players.PlayerAdded:Connect(function(player)task.spawn(verifyWithRetry,player)end)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)
 if tonumber(passId)~=SULTAN_PASS_ID or purchased~=true then return end
 task.delay(.5,function()if player and player.Parent then verifyWithRetry(player)end end)
end)

print("[BBYA] Sultan contribution adapter v1 online: SULTAN CORE 1490269572 / 10000R ownership-backed Top 3 contribution")
