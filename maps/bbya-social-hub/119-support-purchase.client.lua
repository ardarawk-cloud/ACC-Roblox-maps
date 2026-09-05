-- BBYA SOCIAL HUB — SUPPORT PURCHASE LOCAL ADAPTER v3
-- Function-only purchase prompt lifecycle + post-close receipt acknowledgement.
-- UI Kernel owns Support panel; server owns catalog validation + ProcessReceipt.
-- If the kernel receipt toast is hidden behind Roblox's purchase modal, this adapter
-- replays the same receipt message only after the modal closes.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local monetizationRemote=remotes and remotes:WaitForChild("Monetization",30)
if not monetizationRemote then return end

local promptBusy=false
local promptOpen=false
local activeProductId=nil
local pendingReceiptMessage=nil

local function clearPostCloseToast()
 local old=pg:FindFirstChild("BBYASupportPostCloseToastV3")
 if old then old:Destroy() end
 local kernel=pg:FindFirstChild("BBYACommandMenuUI")
 local oldKernel=kernel and kernel:FindFirstChild("SupportPostCloseToastV3")
 if oldKernel then oldKernel:Destroy() end
end

local function showPostCloseReceipt(message)
 message=tostring(message or "SUPPORT RECEIVED • THANK YOU")
 clearPostCloseToast()

 local kernel=pg:FindFirstChild("BBYACommandMenuUI")
 local existing=kernel and kernel:FindFirstChild("KernelToast")
 if existing and existing:IsA("TextLabel") then
  local replay=existing:Clone()
  existing:Destroy()
  replay.Name="SupportPostCloseToastV3"
  replay.Text=message
  replay.Parent=kernel
  task.delay(5.5,function()if replay.Parent then replay:Destroy() end end)
  return
 end

 local gui=Instance.new("ScreenGui")
 gui.Name="BBYASupportPostCloseToastV3"
 gui.ResetOnSpawn=false
 gui.IgnoreGuiInset=true
 gui.DisplayOrder=950
 gui.Parent=pg

 local t=Instance.new("TextLabel")
 t.Name="ReceiptToast"
 t.AnchorPoint=Vector2.new(.5,1)
 t.Position=UDim2.new(.5,0,1,-18)
 t.Size=UDim2.fromOffset(360,42)
 t.BackgroundColor3=Color3.fromRGB(19,19,26)
 t.BackgroundTransparency=.06
 t.BorderSizePixel=0
 t.Text=message
 t.TextColor3=Color3.fromRGB(246,246,249)
 t.Font=Enum.Font.GothamBold
 t.TextSize=10
 t.TextWrapped=true
 t.TextXAlignment=Enum.TextXAlignment.Center
 t.TextYAlignment=Enum.TextYAlignment.Center
 t.ZIndex=951
 t.Parent=gui
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,9);c.Parent=t
 local s=Instance.new("UIStroke");s.Color=Color3.fromRGB(38,194,222);s.Transparency=.45;s.Thickness=1;s.Parent=t

 task.delay(5.5,function()if gui.Parent then gui:Destroy() end end)
end

local function finishPrompt(purchased)
 promptBusy=false
 promptOpen=false
 activeProductId=nil
 if purchased and pendingReceiptMessage then
  local msg=pendingReceiptMessage
  pendingReceiptMessage=nil
  task.delay(.25,function()showPostCloseReceipt(msg)end)
 elseif not purchased then
  pendingReceiptMessage=nil
 end
end

monetizationRemote.OnClientEvent:Connect(function(action,data)
 data=type(data)=="table" and data or {}

 if action=="promptSupportLocal" then
  local productId=tonumber(data.productId)
  if not productId or productId<=0 or promptBusy then return end

  promptBusy=true
  promptOpen=true
  activeProductId=productId
  pendingReceiptMessage=nil

  local ok,err=pcall(function()
   MarketplaceService:PromptProductPurchase(player,productId)
  end)
  if not ok then
   warn("[BBYA Support] PromptProductPurchase failed: "..tostring(err))
   promptBusy=false
   promptOpen=false
   activeProductId=nil
   return
  end

  task.delay(15,function()
   if promptBusy and activeProductId==productId then
    promptBusy=false
   end
  end)

 elseif action=="receipt" then
  local msg=data.message or "SUPPORT RECEIVED • THANK YOU"
  if promptOpen then
   pendingReceiptMessage=msg
  else
   task.defer(function()showPostCloseReceipt(msg)end)
  end
 end
end)

MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId,productId,purchased)
 if userId~=player.UserId then return end
 if activeProductId and tonumber(productId) and tonumber(productId)~=activeProductId then return end
 finishPrompt(purchased==true)
end)

print("[BBYA] Support purchase local adapter v3 online; receipt acknowledgement waits for purchase modal close")
