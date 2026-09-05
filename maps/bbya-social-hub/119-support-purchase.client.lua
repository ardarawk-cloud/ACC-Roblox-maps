-- BBYA SOCIAL HUB — SUPPORT PURCHASE LOCAL ADAPTER v4
-- Native Roblox checkout only. No custom receipt/purchase confirmation toast.
-- UI Kernel still owns the Support panel; Monetization authority owns validation + ProcessReceipt/grant.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
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

-- Existing Support cards are created dynamically by the unified UI.
-- Bridge those cards to the single Monetization authority without creating a second UI.
local function bindSupportButton(button)
 if not button:IsA("TextButton") or button:GetAttribute("BBYASupportNativeBoundV4") then return end
 local scroller=button.Parent
 if not scroller or scroller.Name~="SupportScroller" then return end
 local amount=tonumber((button.Text or ""):match("(%d[%d]*)"))
 if not amount then return end
 button:SetAttribute("BBYASupportNativeBoundV4",true)
 button.MouseButton1Click:Connect(function()
  if promptBusy then return end
  monetizationRemote:FireServer("promptSupport",amount)
 end)
end

local function scan()
 for _,d in ipairs(pg:GetDescendants()) do bindSupportButton(d) end
end
pg.DescendantAdded:Connect(function(d)task.defer(function()bindSupportButton(d)end)end)
task.defer(scan)

print("[BBYA] Support purchase local adapter v4 online: native checkout only / no custom receipt toast")