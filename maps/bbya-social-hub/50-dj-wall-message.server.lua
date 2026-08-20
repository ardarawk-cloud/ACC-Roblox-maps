-- BBYA SOCIAL HUB — DJ WALL MESSAGE SYSTEM v2
-- Full-wall LED behind DJ: idle VJ visualizer + filtered queued prestige messages.
-- Real Developer Product monetization + centralized receipt routing.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local TextService=game:GetService("TextService")
local TweenService=game:GetService("TweenService")
local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD")
local old=root:FindFirstChild("DJWallMessageSystem")
if old then old:Destroy() end

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local wallRemote=remotes:FindFirstChild("DJWall") or Instance.new("RemoteEvent")
wallRemote.Name="DJWall";wallRemote.Parent=remotes
local stateRemote=remotes:FindFirstChild("State") or Instance.new("RemoteEvent")
stateRemote.Name="State";stateRemote.Parent=remotes

local DJ_MESSAGE_PRODUCT_ID=3709047092
local SUPPORT_BY_PRODUCT={
 [3709047095]=10,
 [3709047097]=25,
 [3709047101]=50,
 [3709047104]=100,
 [3709047106]=250,
 [3709047107]=500,
 [3709047109]=1000,
 [3709048779]=2000,
}
local DISPLAY_SECONDS=12
local MAX_CHARS=80
local SUBMIT_COOLDOWN=45
local MAX_QUEUE=20

local C={
 black=Color3.fromRGB(5,5,8),panel=Color3.fromRGB(12,10,16),panel2=Color3.fromRGB(22,17,27),
 pink=Color3.fromRGB(255,38,155),cyan=Color3.fromRGB(0,210,238),gold=Color3.fromRGB(238,190,94),
 white=Color3.fromRGB(244,242,247),muted=Color3.fromRGB(164,157,171),green=Color3.fromRGB(62,205,124),
}

local function isAdmin(player)
 if not player then return false end
 if player:GetAttribute("BBYAAdmin")==true then return true end
 if game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId then return true end
 return false
end

local model=Instance.new("Model")
model.Name="DJWallMessageSystem"
model:SetAttribute("Pass","DJ_WALL_PRESTIGE_V2")
model.Parent=root

local function part(name,size,cf,color,material,transparency)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.black;p.Material=material or Enum.Material.Metal
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=true;p.CastShadow=false;p.Parent=model
 return p
end
local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,color,thickness,transparency)local s=Instance.new("UIStroke");s.Color=color;s.Thickness=thickness or 1;s.Transparency=transparency or 0;s.Parent=o;return s end
local function label(parent,text,pos,size,font,textSize,color,align)
 local l=Instance.new("TextLabel")
 l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham
 l.TextSize=textSize or 18;l.TextColor3=color or C.white;l.TextWrapped=true;l.TextXAlignment=align or Enum.TextXAlignment.Left
 l.TextYAlignment=Enum.TextYAlignment.Center;l.Parent=parent
 return l
end

-- Full rear wall, flush in front of the existing stage LED tiles.
local wallCF=CFrame.new(3,10.0,46.34)
part("WallRecess",Vector3.new(58.5,14.1,.32),wallCF*CFrame.new(0,0,.15),Color3.fromRGB(4,4,6),Enum.Material.Metal,0)
local screen=part("PrestigeLED",Vector3.new(56.8,12.6,.12),wallCF*CFrame.new(0,0,-.10),Color3.fromRGB(7,6,10),Enum.Material.Glass,.02)
screen.Reflectance=.04
part("TopTrim",Vector3.new(56.9,.10,.10),wallCF*CFrame.new(0,6.34,-.18),C.pink,Enum.Material.Neon,0)
part("BottomTrim",Vector3.new(56.9,.08,.10),wallCF*CFrame.new(0,-6.34,-.18),C.cyan,Enum.Material.Neon,0)

local sg=Instance.new("SurfaceGui")
sg.Name="DJWallUI";sg.Face=Enum.NormalId.Front;sg.AlwaysOnTop=false;sg.LightInfluence=.05;sg.PixelsPerStud=55;sg.Parent=screen
local bg=Instance.new("Frame")
bg.Size=UDim2.fromScale(1,1);bg.BackgroundColor3=C.black;bg.BorderSizePixel=0;bg.Parent=sg
local bgGrad=Instance.new("UIGradient")
bgGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(31,8,27)),ColorSequenceKeypoint.new(.48,Color3.fromRGB(7,7,11)),ColorSequenceKeypoint.new(1,Color3.fromRGB(4,22,27))});bgGrad.Rotation=12;bgGrad.Parent=bg

-- IDLE / VJ MODE --------------------------------------------------------------
local idle=Instance.new("Frame")
idle.Name="IdleVisuals";idle.Size=UDim2.fromScale(1,1);idle.BackgroundTransparency=1;idle.Parent=bg
label(idle,"BBYA",UDim2.fromScale(.035,.045),UDim2.fromScale(.18,.09),Enum.Font.GothamBlack,42,C.white)
label(idle,"●  LIVE VISUALS",UDim2.fromScale(.79,.055),UDim2.fromScale(.17,.05),Enum.Font.GothamBold,18,C.green,Enum.TextXAlignment.Right)
label(idle,"SOCIAL HUB",UDim2.fromScale(.30,.18),UDim2.fromScale(.40,.12),Enum.Font.GothamBlack,56,C.white,Enum.TextXAlignment.Center)
label(idle,"AUTODJ  •  COMMUNITY  •  24/7",UDim2.fromScale(.30,.30),UDim2.fromScale(.40,.05),Enum.Font.GothamBold,17,C.muted,Enum.TextXAlignment.Center)

local visual=Instance.new("Frame")
visual.Name="VJVisualizer";visual.Position=UDim2.fromScale(.055,.43);visual.Size=UDim2.fromScale(.89,.38);visual.BackgroundColor3=Color3.fromRGB(8,8,12);visual.BackgroundTransparency=.15;visual.BorderSizePixel=0;visual.ClipsDescendants=true;visual.Parent=idle;round(visual,18);stroke(visual,Color3.fromRGB(69,45,70),1,.45)
local bars={}
local BAR_COUNT=42
for i=1,BAR_COUNT do
 local b=Instance.new("Frame")
 b.AnchorPoint=Vector2.new(.5,1);b.Position=UDim2.new((i-.5)/BAR_COUNT,0,1,-16);b.Size=UDim2.new(.013,0,0,18)
 b.BackgroundColor3=(i%5==0 and C.cyan or (i%3==0 and C.gold or C.pink));b.BorderSizePixel=0;b.Parent=visual;round(b,6)
 table.insert(bars,b)
end
label(idle,"BBYA LIVE WAVE",UDim2.fromScale(.055,.84),UDim2.fromScale(.45,.05),Enum.Font.GothamBold,16,C.pink)
label(idle,"Open MESSAGE from the top menu • 2 R$",UDim2.fromScale(.50,.84),UDim2.fromScale(.445,.05),Enum.Font.GothamMedium,14,C.muted,Enum.TextXAlignment.Right)

-- MESSAGE MODE ----------------------------------------------------------------
local message=Instance.new("Frame")
message.Name="MessageMode";message.Size=UDim2.fromScale(1,1);message.BackgroundColor3=Color3.fromRGB(8,7,11);message.BackgroundTransparency=.04;message.BorderSizePixel=0;message.Visible=false;message.Parent=bg
local msgGrad=Instance.new("UIGradient")
msgGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(73,14,55)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(10,9,14)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,48,58))});msgGrad.Rotation=18;msgGrad.Parent=message
local categoryBadge=label(message,"BBYA LIVE MESSAGE",UDim2.fromScale(.06,.08),UDim2.fromScale(.88,.08),Enum.Font.GothamBlack,28,C.pink,Enum.TextXAlignment.Center)
local msgText=label(message,"",UDim2.fromScale(.08,.25),UDim2.fromScale(.84,.38),Enum.Font.GothamBlack,48,C.white,Enum.TextXAlignment.Center)
local fromText=label(message,"",UDim2.fromScale(.10,.69),UDim2.fromScale(.80,.08),Enum.Font.GothamBold,22,C.gold,Enum.TextXAlignment.Center)
label(message,"BBYA SOCIAL HUB  •  MAKE THE NIGHT YOURS",UDim2.fromScale(.10,.84),UDim2.fromScale(.80,.05),Enum.Font.GothamBold,16,C.muted,Enum.TextXAlignment.Center)

local prompt=Instance.new("ProximityPrompt")
prompt.Name="CreatePrestigeMessage";prompt.ActionText="Create Message";prompt.ObjectText="BBYA DJ Wall • 2 R$";prompt.KeyboardKeyCode=Enum.KeyCode.E
prompt.HoldDuration=0;prompt.MaxActivationDistance=14;prompt.RequiresLineOfSight=false;prompt.Parent=screen

local queue={}
local pending={}
local lastSubmit={}
local displaying=false
local CATEGORY={BIRTHDAY="BIRTHDAY CELEBRATION",LOVE="LOVE MESSAGE",SHOUTOUT="SHOUTOUT",CUSTOM="LIVE MESSAGE"}

local function filterMessage(player,raw)
 raw=tostring(raw or ""):gsub("[%c\r\n]+"," "):gsub("%s+"," ")
 raw=raw:match("^%s*(.-)%s*$") or ""
 if #raw<2 then return nil,"Pesan terlalu pendek." end
 if #raw>MAX_CHARS then raw=raw:sub(1,MAX_CHARS) end
 local ok,result=pcall(function()
  local filtered=TextService:FilterStringAsync(raw,player.UserId)
  return filtered:GetNonChatStringForBroadcastAsync()
 end)
 if not ok or not result or result=="" then return nil,"Pesan tidak dapat difilter. Coba kalimat lain." end
 local visible=result:gsub("#",""):gsub("%s","")
 if #visible<2 then return nil,"Pesan terlalu banyak berisi kata yang disensor." end
 return result,nil
end
local function queueMessage(entry)
 if #queue>=MAX_QUEUE then return false end
 table.insert(queue,entry);return true
end
local function showMessage(entry)
 displaying=true;idle.Visible=false;message.Visible=true
 categoryBadge.Text="BBYA  •  "..(CATEGORY[entry.category] or CATEGORY.CUSTOM)
 msgText.Text=entry.text;fromText.Text="FROM  @"..entry.from;message.BackgroundTransparency=1
 TweenService:Create(message,TweenInfo.new(.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=.04}):Play()
 task.wait(DISPLAY_SECONDS)
 local fade=TweenService:Create(message,TweenInfo.new(.35,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{BackgroundTransparency=1})
 fade:Play();fade.Completed:Wait();message.Visible=false;idle.Visible=true;message.BackgroundTransparency=.04;displaying=false
end

task.spawn(function()
 while task.wait(.25) do
  if not displaying and #queue>0 then showMessage(table.remove(queue,1)) end
 end
end)
task.spawn(function()
 local t=0
 while task.wait(.07) do
  t+=.07
  if idle.Visible then
   for i,b in ipairs(bars) do
    local h=26+math.abs(math.sin(t*3.2+i*.43))*145+math.abs(math.sin(t*1.25+i*.19))*55
    b.Size=UDim2.new(.013,0,0,math.min(220,h))
   end
  end
 end
end)

local function configFor(player)
 return {price=2,productConfigured=true,maxChars=MAX_CHARS,displaySeconds=DISPLAY_SECONDS,queue=#queue,admin=isAdmin(player)}
end
prompt.Triggered:Connect(function(player)wallRemote:FireClient(player,"open",configFor(player))end)

wallRemote.OnServerEvent:Connect(function(player,action,data)
 if action=="config" then wallRemote:FireClient(player,"config",configFor(player));return end
 if action~="submit" or type(data)~="table" then return end
 local now=os.clock();local last=lastSubmit[player.UserId] or 0
 if now-last<SUBMIT_COOLDOWN and not isAdmin(player) then
  wallRemote:FireClient(player,"toast",string.format("Tunggu %d detik sebelum kirim pesan lagi.",math.ceil(SUBMIT_COOLDOWN-(now-last))));return
 end
 if pending[player.UserId] then wallRemote:FireClient(player,"toast","Selesaikan request sebelumnya dulu.");return end
 if #queue>=MAX_QUEUE then wallRemote:FireClient(player,"toast","Antrean DJ Wall sedang penuh.");return end
 local category=tostring(data.category or "CUSTOM"):upper();if not CATEGORY[category] then category="CUSTOM" end
 local filtered,err=filterMessage(player,data.text)
 if not filtered then wallRemote:FireClient(player,"toast",err or "Pesan ditolak filter.");return end
 local entry={text=filtered,category=category,from=player.DisplayName,userId=player.UserId}
 lastSubmit[player.UserId]=now
 if isAdmin(player) then
  queueMessage(entry);wallRemote:FireClient(player,"queued",{position=#queue,text=filtered,adminPreview=true});return
 end
 pending[player.UserId]=entry
 wallRemote:FireClient(player,"purchase",{message=filtered})
 MarketplaceService:PromptProductPurchase(player,DJ_MESSAGE_PRODUCT_ID)
end)

-- Central Developer Product receipt router for BBYA.
local previousProcessReceipt=MarketplaceService.ProcessReceipt
MarketplaceService.ProcessReceipt=function(receiptInfo)
 if receiptInfo.ProductId==DJ_MESSAGE_PRODUCT_ID then
  local userId=receiptInfo.PlayerId;local entry=pending[userId]
  if entry then
   pending[userId]=nil
   if queueMessage(entry) then
    local plr=Players:GetPlayerByUserId(userId)
    if plr then wallRemote:FireClient(plr,"queued",{position=#queue,text=entry.text}) end
   end
  end
  return Enum.ProductPurchaseDecision.PurchaseGranted
 end

 local supportAmount=SUPPORT_BY_PRODUCT[receiptInfo.ProductId]
 if supportAmount then
  local plr=Players:GetPlayerByUserId(receiptInfo.PlayerId)
  if plr then
   stateRemote:FireClient(plr,"toast",string.format("Support %d R$ diterima • Thank you for supporting BBYA!",supportAmount))
   stateRemote:FireAllClients("supportReceived",{displayName=plr.DisplayName,userId=plr.UserId,amount=supportAmount})
  end
  return Enum.ProductPurchaseDecision.PurchaseGranted
 end

 if previousProcessReceipt then return previousProcessReceipt(receiptInfo) end
 return Enum.ProductPurchaseDecision.NotProcessedYet
end

Players.PlayerRemoving:Connect(function(player)
 pending[player.UserId]=nil;lastSubmit[player.UserId]=nil
end)

print("[BBYA] DJ Wall Prestige v2 online: real 2R purchase + Support receipt routing")
