-- BBYA SOCIAL HUB — SUPPORT PURCHASE CLIENT v2
-- Rebinds unified Support amount buttons to Roblox's client-side developer-product prompt.
-- Receipt validation/granting remains server-side in DJWallPrestige / ProcessReceipt.

local Players=game:GetService("Players")
local MarketplaceService=game:GetService("MarketplaceService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("BBYAClubUI",30)
if not gui then return end

local PRODUCTS={
 [10]=3709047095,
 [25]=3709047097,
 [50]=3709047101,
 [100]=3709047104,
 [250]=3709047106,
 [500]=3709047107,
 [1000]=3709047109,
 [2000]=3709048779,
}

local busy=false
local bound={}

local function toast(text)
 local old=gui:FindFirstChild("SupportPurchaseToastV2")
 if old then old:Destroy() end
 local t=Instance.new("TextLabel")
 t.Name="SupportPurchaseToastV2"
 t.AnchorPoint=Vector2.new(.5,1)
 t.Position=UDim2.new(.5,0,1,-28)
 t.Size=UDim2.fromOffset(320,42)
 t.BackgroundColor3=Color3.fromRGB(15,16,22)
 t.BackgroundTransparency=.10
 t.BorderSizePixel=0
 t.Text=tostring(text or "")
 t.TextColor3=Color3.fromRGB(246,246,249)
 t.Font=Enum.Font.GothamBold
 t.TextSize=10
 t.ZIndex=980
 t.Parent=gui
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,9);c.Parent=t
 local s=Instance.new("UIStroke");s.Color=Color3.fromRGB(32,190,215);s.Transparency=.38;s.Parent=t
 task.delay(2.2,function()if t.Parent then t:Destroy() end end)
end

local function amountFromButton(b)
 local raw=tostring(b.Text or "")
 local n=raw:match("(%d+)")
 return n and tonumber(n) or nil
end

local function promptProduct(button,amount,productId)
 if busy then return end
 busy=true
 local original=button.Text
 button.Text="CHECKING…"

 local ok,info=pcall(function()
  return MarketplaceService:GetProductInfo(productId,Enum.InfoType.Product)
 end)
 if not ok or type(info)~="table" then
  button.Text=original;busy=false;toast("SUPPORT BELUM BISA DIBUKA • coba lagi")
  return
 end
 if info.IsForSale==false then
  button.Text=original;busy=false;toast("SUPPORT "..tostring(amount).." R$ SEDANG TIDAK DIJUAL")
  return
 end

 local actual=tonumber(info.PriceInRobux) or amount
 button.Text="OPENING "..tostring(actual).." R$…"
 local prompted,err=pcall(function()
  MarketplaceService:PromptProductPurchase(player,productId)
 end)
 if not prompted then
  button.Text=original;busy=false;toast("ROBLOX PURCHASE PROMPT GAGAL DIBUKA")
  warn("[BBYA Support] PromptProductPurchase failed",productId,err)
  return
 end

 task.delay(1.5,function()
  if button.Parent then button.Text=original end
  busy=false
 end)
end

-- Clone/replace removes the old server-prompt click connection from Unified UI v5,
-- so exactly one purchase prompt is requested by the local player.
local function rebindButton(button)
 if not button:IsA("TextButton") or bound[button] or button:GetAttribute("BBYASupportPurchaseClientV2") then return end
 local amount=amountFromButton(button)
 local productId=amount and PRODUCTS[amount]
 if not productId then return end
 local parent=button.Parent
 if not parent then return end

 local clone=button:Clone()
 clone:SetAttribute("BBYASupportPurchaseClientV2",true)
 clone:SetAttribute("BBYASupportAmount",amount)
 clone:SetAttribute("BBYADeveloperProductId",productId)
 clone.LayoutOrder=button.LayoutOrder
 clone.Parent=parent
 button:Destroy()
 bound[clone]=true
 clone.Activated:Connect(function()promptProduct(clone,amount,productId)end)
end

local function scan()
 local scroller=gui:FindFirstChild("SupportScroller",true)
 if not scroller then return end
 for _,child in ipairs(scroller:GetChildren()) do
  if child:IsA("TextButton") then rebindButton(child) end
 end
 if not scroller:GetAttribute("BBYASupportChildGuardV2") then
  scroller:SetAttribute("BBYASupportChildGuardV2",true)
  scroller.ChildAdded:Connect(function(child)
   if child:IsA("TextButton") then task.defer(function()rebindButton(child)end) end
  end)
 end
end

gui.DescendantAdded:Connect(function(d)
 if d.Name=="SupportScroller" or d:IsA("TextButton") then task.defer(scan) end
end)

MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId,productId,isPurchased)
 if userId~=player.UserId or not table.find({3709047095,3709047097,3709047101,3709047104,3709047106,3709047107,3709047109,3709048779},productId) then return end
 busy=false
 if isPurchased then toast("SUPPORT DITERIMA • THANK YOU") end
end)

for i=0,40 do task.delay(i*.25,scan) end

print("[BBYA] Support Purchase Client v2 online: local developer-product prompts + server receipt routing")
