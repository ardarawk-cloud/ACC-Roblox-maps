-- BBYA SOCIAL HUB — SUPPORT PURCHASE + DONATION NOTIFICATION LOCAL ADAPTER v3.1
-- Purchase prompt bridge remains function-only; receipts stay server-authoritative.
-- Donation popup is visual-only and consumes Monetization:DonationNotification:v1.
-- No purchase-success inference, no backend mutation, no audio authority.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local TweenService=game:GetService("TweenService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local monetizationRemote=remotes and remotes:WaitForChild("Monetization",30)
if not monetizationRemote then return end

local promptBusy=false

-- Donation notification authority -------------------------------------------------
local GUI_NAME="BBYADonationNotificationUI"
local DISPLAY_ORDER=950
local ENTER_TIME=0.30
local HOLD_TIME=4.00
local EXIT_TIME=0.30
local TOP_OFFSET=12
local MAX_MESSAGE_CHARS=180

local oldGui=playerGui:FindFirstChild(GUI_NAME)
if oldGui then oldGui:Destroy() end

local notificationGui=Instance.new("ScreenGui")
notificationGui.Name=GUI_NAME
notificationGui.ResetOnSpawn=false
notificationGui.IgnoreGuiInset=false
notificationGui.DisplayOrder=DISPLAY_ORDER
notificationGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
notificationGui.Parent=playerGui
notificationGui:SetAttribute("BBYAUIAuthority","DONATION_NOTIFICATION_POPUP_V1")
notificationGui:SetAttribute("BBYAContract","Monetization:DonationNotification:v1")
pcall(function()
 notificationGui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets
 notificationGui.ClipToDeviceSafeArea=true
end)

local C={
 bg=Color3.fromRGB(14,15,20),
 panel=Color3.fromRGB(22,23,30),
 card=Color3.fromRGB(29,31,39),
 white=Color3.fromRGB(247,247,250),
 muted=Color3.fromRGB(166,169,181),
 gold=Color3.fromRGB(232,184,93),
 line=Color3.fromRGB(72,75,88),
}

local function corner(parent,radius)
 local c=Instance.new("UICorner")
 c.CornerRadius=UDim.new(0,radius)
 c.Parent=parent
 return c
end

local function stroke(parent,color,transparency)
 local s=Instance.new("UIStroke")
 s.Color=color
 s.Thickness=1
 s.Transparency=transparency or 0
 s.Parent=parent
 return s
end

local function makeLabel(parent,text,pos,size,font,textSize,color)
 local label=Instance.new("TextLabel")
 label.BackgroundTransparency=1
 label.BorderSizePixel=0
 label.Position=pos
 label.Size=size
 label.Font=font or Enum.Font.Gotham
 label.TextSize=textSize or 12
 label.TextColor3=color or C.white
 label.Text=text
 label.TextXAlignment=Enum.TextXAlignment.Left
 label.TextYAlignment=Enum.TextYAlignment.Center
 label.Parent=parent
 return label
end

local function visualClip(text,maxChars)
 local source=tostring(text or "")
 local ok,length=pcall(utf8.len,source)
 if not ok or not length or length<=maxChars then return source end
 local cut
 local cutOk,offset=pcall(utf8.offset,source,maxChars+1)
 if cutOk and offset then
  cut=string.sub(source,1,offset-1)
 else
  cut=string.sub(source,1,maxChars)
 end
 return cut.."…"
end

local activePopup=nil
local activeHeight=nil
local cameraConnection=nil
local workspaceCameraConnection=nil

local function viewportSize()
 local camera=workspace.CurrentCamera
 return camera and camera.ViewportSize or Vector2.new(1280,720)
end

local function popupWidth()
 local viewport=viewportSize()
 local margin=viewport.X<500 and 16 or 24
 return math.max(240,math.min(440,viewport.X-margin))
end

local function applyResponsive(group,height)
 if not group or not group.Parent then return end
 group.Size=UDim2.fromOffset(popupWidth(),height)
end

local function bindCameraResize()
 if cameraConnection then cameraConnection:Disconnect();cameraConnection=nil end
 local camera=workspace.CurrentCamera
 if camera then
  cameraConnection=camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
   if activePopup and activeHeight then applyResponsive(activePopup,activeHeight) end
  end)
 end
end
bindCameraResize()
workspaceCameraConnection=workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCameraResize)

local function createMetric(parent,title,value,pos)
 local card=Instance.new("Frame")
 card.BackgroundColor3=C.card
 card.BackgroundTransparency=0.08
 card.BorderSizePixel=0
 card.Position=pos
 card.Size=UDim2.new(0.5,-5,1,0)
 card.Parent=parent
 corner(card,9)
 stroke(card,C.line,0.62)

 local titleLabel=makeLabel(card,title,UDim2.fromOffset(10,3),UDim2.new(1,-20,0,14),Enum.Font.GothamBold,9,C.muted)
 titleLabel.TextTruncate=Enum.TextTruncate.AtEnd
 local valueLabel=makeLabel(card,tostring(value),UDim2.fromOffset(10,15),UDim2.new(1,-20,0,22),Enum.Font.GothamBlack,16,C.white)
 valueLabel.TextTruncate=Enum.TextTruncate.AtEnd
 return card
end

local function loadAvatar(imageLabel,fallbackLabel,avatarUserId)
 local id=tonumber(avatarUserId)
 if not id or id<=0 then return end
 task.spawn(function()
  local ok,image=pcall(function()
   return Players:GetUserThumbnailAsync(id,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)
  end)
  if ok and image and image~="" and imageLabel.Parent then
   imageLabel.Image=image
   imageLabel.ImageTransparency=0
   if fallbackLabel.Parent then fallbackLabel.Visible=false end
  end
 end)
end

local function showDonation(payload)
 payload=type(payload)=="table" and payload or {}
 local displayName=tostring(payload.displayName or "")
 local username=tostring(payload.username or "")
 local messageText=type(payload.message)=="string" and payload.message or tostring(payload.message or "")
 local hasMessage=messageText~=""
 local height=hasMessage and 202 or 150

 local group=Instance.new("CanvasGroup")
 group.Name="DonationPopup"
 group.AnchorPoint=Vector2.new(0.5,0)
 group.BackgroundColor3=C.bg
 group.BackgroundTransparency=0.03
 group.BorderSizePixel=0
 group.ClipsDescendants=false
 group.GroupTransparency=1
 group.Position=UDim2.new(0.5,0,0,-height-20)
 group.Size=UDim2.fromOffset(popupWidth(),height)
 group.ZIndex=100
 group.Parent=notificationGui
 corner(group,14)
 stroke(group,C.gold,0.34)

 local accent=Instance.new("Frame")
 accent.BackgroundColor3=C.gold
 accent.BorderSizePixel=0
 accent.Position=UDim2.fromOffset(0,0)
 accent.Size=UDim2.new(1,0,0,3)
 accent.ZIndex=101
 accent.Parent=group
 corner(accent,14)

 local title=makeLabel(group,"NEW DONATION",UDim2.fromOffset(14,9),UDim2.new(1,-28,0,20),Enum.Font.GothamBlack,12,C.gold)
 title.ZIndex=102
 title.TextTruncate=Enum.TextTruncate.AtEnd

 local identity=Instance.new("Frame")
 identity.BackgroundTransparency=1
 identity.BorderSizePixel=0
 identity.Position=UDim2.fromOffset(12,34)
 identity.Size=UDim2.new(1,-24,0,52)
 identity.ZIndex=101
 identity.Parent=group

 local avatarShell=Instance.new("Frame")
 avatarShell.BackgroundColor3=C.card
 avatarShell.BorderSizePixel=0
 avatarShell.Position=UDim2.fromOffset(0,1)
 avatarShell.Size=UDim2.fromOffset(48,48)
 avatarShell.ZIndex=102
 avatarShell.Parent=identity
 corner(avatarShell,24)
 stroke(avatarShell,C.line,0.5)

 local avatarFallback=makeLabel(avatarShell,"USER",UDim2.fromScale(0,0),UDim2.fromScale(1,1),Enum.Font.GothamBold,8,C.muted)
 avatarFallback.TextXAlignment=Enum.TextXAlignment.Center
 avatarFallback.ZIndex=103

 local avatar=Instance.new("ImageLabel")
 avatar.Name="Avatar"
 avatar.BackgroundTransparency=1
 avatar.BorderSizePixel=0
 avatar.Position=UDim2.fromScale(0,0)
 avatar.Size=UDim2.fromScale(1,1)
 avatar.Image=""
 avatar.ImageTransparency=1
 avatar.ScaleType=Enum.ScaleType.Crop
 avatar.ZIndex=104
 avatar.Parent=avatarShell
 corner(avatar,24)

 local nameLabel=makeLabel(identity,displayName,UDim2.fromOffset(60,3),UDim2.new(1,-60,0,24),Enum.Font.GothamBold,16,C.white)
 nameLabel.TextTruncate=Enum.TextTruncate.AtEnd
 nameLabel.ZIndex=102
 local userText=username~="" and ("@"..username) or "@"
 local usernameLabel=makeLabel(identity,userText,UDim2.fromOffset(60,27),UDim2.new(1,-60,0,18),Enum.Font.GothamMedium,11,C.muted)
 usernameLabel.TextTruncate=Enum.TextTruncate.AtEnd
 usernameLabel.ZIndex=102

 loadAvatar(avatar,avatarFallback,payload.avatarUserId)

 local metrics=Instance.new("Frame")
 metrics.BackgroundTransparency=1
 metrics.BorderSizePixel=0
 metrics.Position=UDim2.fromOffset(12,94)
 metrics.Size=UDim2.new(1,-24,0,44)
 metrics.ZIndex=101
 metrics.Parent=group
 createMetric(metrics,"DONATED",tostring(payload.amount or "?").." ROBUX",UDim2.fromScale(0,0)).ZIndex=102
 createMetric(metrics,"TOTAL",tostring(payload.total or "?").." ROBUX",UDim2.new(0.5,5,0,0)).ZIndex=102

 if hasMessage then
  local messageCard=Instance.new("Frame")
  messageCard.Name="Message"
  messageCard.BackgroundColor3=C.panel
  messageCard.BackgroundTransparency=0.08
  messageCard.BorderSizePixel=0
  messageCard.Position=UDim2.fromOffset(12,146)
  messageCard.Size=UDim2.new(1,-24,0,44)
  messageCard.ZIndex=101
  messageCard.Parent=group
  corner(messageCard,9)
  stroke(messageCard,C.line,0.64)

  local messageLabel=makeLabel(messageCard,visualClip(messageText,MAX_MESSAGE_CHARS),UDim2.fromOffset(10,4),UDim2.new(1,-20,1,-8),Enum.Font.GothamMedium,11,C.white)
  messageLabel.TextWrapped=true
  messageLabel.TextTruncate=Enum.TextTruncate.AtEnd
  messageLabel.TextYAlignment=Enum.TextYAlignment.Center
  messageLabel.ZIndex=102
 end

 activePopup=group
 activeHeight=height
 applyResponsive(group,height)

 local enterTween=TweenService:Create(group,TweenInfo.new(ENTER_TIME,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
  Position=UDim2.new(0.5,0,0,TOP_OFFSET),
  GroupTransparency=0,
 })
 enterTween:Play()
 enterTween.Completed:Wait()

 task.wait(HOLD_TIME)

 if not group.Parent then
  if activePopup==group then activePopup=nil;activeHeight=nil end
  return
 end
 local exitTween=TweenService:Create(group,TweenInfo.new(EXIT_TIME,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
  Position=UDim2.new(0.5,0,0,-height-20),
  GroupTransparency=1,
 })
 exitTween:Play()
 exitTween.Completed:Wait()
 if group.Parent then group:Destroy() end
 if activePopup==group then activePopup=nil;activeHeight=nil end
end

local notificationQueue={}
local queueRunning=false

local function ensureQueueRunner()
 if queueRunning then return end
 queueRunning=true
 task.spawn(function()
  while #notificationQueue>0 do
   local payload=table.remove(notificationQueue,1)
   showDonation(payload)
  end
  queueRunning=false
  if #notificationQueue>0 then ensureQueueRunner() end
 end)
end

local function enqueueDonation(payload)
 if type(payload)~="table" then return end
 table.insert(notificationQueue,payload)
 ensureQueueRunner()
end

-- Existing purchase bridge ---------------------------------------------------------
local function handleSupportPrompt(data)
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
end

monetizationRemote.OnClientEvent:Connect(function(action,data)
 if action=="promptSupportLocal" then
  handleSupportPrompt(data)
  return
 end
 if action=="DonationNotification" then
  enqueueDonation(data)
 end
end)

MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId,_productId,_purchased)
 if userId==player.UserId then promptBusy=false end
end)

script.Destroying:Connect(function()
 if cameraConnection then cameraConnection:Disconnect();cameraConnection=nil end
 if workspaceCameraConnection then workspaceCameraConnection:Disconnect();workspaceCameraConnection=nil end
end)

print("[BBYA] Support purchase adapter v3.1 + queued DonationNotification popup v1 online; receipts/server/audio unchanged")

-- -----------------------------------------------------------------------------
-- QA DONATION SIMULATOR v1 — TEST PLACE ONLY / ZERO ROBUX
-- Small local control panel. It only asks the TEST server simulator to emit the
-- same DonationNotification contract consumed above; it never opens purchase UI.
-- -----------------------------------------------------------------------------
do
 local TEST_UNIVERSE=10762005984
 local TEST_PLACE=124607344716828
 if game.GameId==TEST_UNIVERSE and game.PlaceId==TEST_PLACE then
  task.spawn(function()
   local qaRemote=ReplicatedStorage:WaitForChild("BBYAQADonationSimulatorV1",30)
   if not qaRemote then return end

   local old=playerGui:FindFirstChild("BBYAQADonationSimulatorUI")
   if old then old:Destroy() end

   local gui=Instance.new("ScreenGui")
   gui.Name="BBYAQADonationSimulatorUI"
   gui.ResetOnSpawn=false
   gui.IgnoreGuiInset=false
   gui.DisplayOrder=940
   gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
   gui.Parent=playerGui
   pcall(function()
    gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets
    gui.ClipToDeviceSafeArea=true
   end)

   local toggle=Instance.new("TextButton")
   toggle.Name="Toggle"
   toggle.AnchorPoint=Vector2.new(0,0.5)
   toggle.Position=UDim2.new(0,10,0.5,-5)
   toggle.Size=UDim2.fromOffset(104,36)
   toggle.BackgroundColor3=Color3.fromRGB(18,20,28)
   toggle.TextColor3=Color3.fromRGB(255,214,103)
   toggle.Text="QA DONATE"
   toggle.Font=Enum.Font.GothamBold
   toggle.TextSize=12
   toggle.AutoButtonColor=true
   toggle.Parent=gui
   corner(toggle,10)
   stroke(toggle,Color3.fromRGB(232,184,93),0.28)

   local panel=Instance.new("Frame")
   panel.Name="Panel"
   panel.Position=UDim2.new(0,122,0.5,-94)
   panel.Size=UDim2.fromOffset(216,188)
   panel.BackgroundColor3=Color3.fromRGB(14,15,20)
   panel.BackgroundTransparency=0.03
   panel.BorderSizePixel=0
   panel.Visible=false
   panel.Parent=gui
   corner(panel,12)
   stroke(panel,Color3.fromRGB(232,184,93),0.28)

   local title=makeLabel(panel,"QA DONATION SIM",UDim2.fromOffset(12,8),UDim2.new(1,-24,0,22),Enum.Font.GothamBlack,12,Color3.fromRGB(232,184,93))
   title.TextXAlignment=Enum.TextXAlignment.Center
   local sub=makeLabel(panel,"TEST ONLY · 0 ROBUX",UDim2.fromOffset(12,28),UDim2.new(1,-24,0,18),Enum.Font.GothamMedium,9,C.muted)
   sub.TextXAlignment=Enum.TextXAlignment.Center

   local function qaButton(text,y,action)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-24,0,30)
    b.Position=UDim2.fromOffset(12,y)
    b.BackgroundColor3=Color3.fromRGB(27,29,38)
    b.TextColor3=C.white
    b.Text=text
    b.Font=Enum.Font.GothamBold
    b.TextSize=11
    b.AutoButtonColor=true
    b.Parent=panel
    corner(b,8)
    stroke(b,C.line,0.48)
    b.Activated:Connect(function() qaRemote:FireServer(action) end)
    return b
   end

   qaButton("10R · NO MESSAGE",52,"NO_MSG_10")
   qaButton("10R · WITH MESSAGE",86,"WITH_MSG_10")
   qaButton("25R · NO MESSAGE",120,"NO_MSG_25")
   qaButton("BURST · 10 / 25 / 50",154,"BURST")

   toggle.Activated:Connect(function()
    panel.Visible=not panel.Visible
   end)

   print("[BBYA QA] Donation simulator controls online — TEST PLACE ONLY / ZERO ROBUX")
  end)
 end
end
