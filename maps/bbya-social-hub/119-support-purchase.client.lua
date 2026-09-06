-- BBYA SOCIAL HUB — SUPPORT PURCHASE + DONATION NOTIFICATION v6.1
-- Native Roblox checkout remains the only purchase confirmation UI.
-- NEW DONATION broadcast is compact and plays a clearly audible success SFX.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local SoundService=game:GetService("SoundService")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local monetizationRemote=remotes and remotes:WaitForChild("Monetization",30)
local stateRemote=remotes and remotes:WaitForChild("State",30)
if not monetizationRemote or not stateRemote then return end
local promptBusy=false;local activeProductId=nil;local popupToken=0
local FALLBACK_DONATION_SFX="rbxassetid://7112275565"
local SUCCESS_VOLUME=1.25
local function finishPrompt()promptBusy=false;activeProductId=nil end
local old=pg:FindFirstChild("BBYADonationNotificationUI");if old then old:Destroy()end
local gui=Instance.new("ScreenGui");gui.Name="BBYADonationNotificationUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=230;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg;gui:SetAttribute("NotificationAuthority","NEW_DONATION_V6_1_COMPACT_LOUD_SFX")
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 12);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col;s.Thickness=1;s.Transparency=tr or .35;s.Parent=o end
local function label(p,t,pos,size,font,ts,col)local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=t;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 11;l.TextColor3=col or Color3.fromRGB(245,245,248);l.TextXAlignment=Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.TextTruncate=Enum.TextTruncate.AtEnd;l.Parent=p;return l end
local panel=Instance.new("Frame");panel.Name="NewDonationPopup";panel.AnchorPoint=Vector2.new(.5,0);panel.Position=UDim2.new(.5,0,.11,-110);panel.Size=UDim2.fromOffset(318,84);panel.BackgroundColor3=Color3.fromRGB(14,14,19);panel.BackgroundTransparency=.04;panel.BorderSizePixel=0;panel.Visible=false;panel.Parent=gui;corner(panel,13);stroke(panel,Color3.fromRGB(235,184,74),.22)
local accent=Instance.new("Frame");accent.Size=UDim2.fromOffset(4,62);accent.Position=UDim2.fromOffset(9,11);accent.BackgroundColor3=Color3.fromRGB(235,184,74);accent.BorderSizePixel=0;accent.Parent=panel;corner(accent,3)
local avatar=Instance.new("ImageLabel");avatar.Position=UDim2.fromOffset(22,15);avatar.Size=UDim2.fromOffset(54,54);avatar.BackgroundColor3=Color3.fromRGB(27,27,34);avatar.BorderSizePixel=0;avatar.ScaleType=Enum.ScaleType.Crop;avatar.Parent=panel;corner(avatar,27);stroke(avatar,Color3.fromRGB(235,184,74),.18)
label(panel,"NEW DONATION",UDim2.fromOffset(88,6),UDim2.new(1,-98,0,18),Enum.Font.GothamBlack,11,Color3.fromRGB(235,184,74))
local who=label(panel,"SUPPORTER",UDim2.fromOffset(88,23),UDim2.new(1,-98,0,18),Enum.Font.GothamBold,12,Color3.fromRGB(245,245,248))
local amount=label(panel,"DONATED 0 R$",UDim2.fromOffset(88,42),UDim2.new(.52,-6,0,16),Enum.Font.GothamBold,9,Color3.fromRGB(247,55,158))
local total=label(panel,"TOTAL 0 R$",UDim2.new(.52,0,0,42),UDim2.new(.48,-10,0,16),Enum.Font.GothamBold,9,Color3.fromRGB(73,207,235))
label(panel,"THANK YOU FOR SUPPORTING BBYA",UDim2.fromOffset(88,60),UDim2.new(1,-98,0,13),Enum.Font.GothamMedium,7,Color3.fromRGB(157,159,171))
local function findDonationSfx()for _,root in ipairs({SoundService,ReplicatedStorage})do for _,d in ipairs(root:GetDescendants())do if d:IsA("Sound")then local n=string.lower(d.Name);if n:find("cash",1,true)or n:find("register",1,true)or n:find("donation",1,true)or n:find("support",1,true)or n:find("chime",1,true)then return d end end end end end
local function playDonationSfx()
 local src=findDonationSfx();local s=src and src:Clone()or Instance.new("Sound");if not src then s.SoundId=FALLBACK_DONATION_SFX end;s.Name="BBYADonationChimeRuntime";s.Looped=false;s.Volume=SUCCESS_VOLUME;s.Parent=SoundService;pcall(function()s.TimePosition=0;s:Play()end);task.delay(6,function()if s.Parent then s:Destroy()end end)
end
local function setAvatar(uid)avatar.Image="";uid=tonumber(uid);if not uid then return end;task.spawn(function()local ok,url=pcall(function()return Players:GetUserThumbnailAsync(uid,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)end);if ok and url then avatar.Image=url end end)end
local function showDonation(data)
 popupToken+=1;local token=popupToken;local donated=math.max(0,math.floor(tonumber(data.amount)or 0));local cumulative=math.max(donated,math.floor(tonumber(data.total)or donated));who.Text=string.upper(tostring(data.displayName or"SUPPORTER"));amount.Text="DONATED "..donated.." R$";total.Text="TOTAL "..cumulative.." R$";setAvatar(data.userId);panel.Visible=true;panel.Position=UDim2.new(.5,0,.11,-100);panel.BackgroundTransparency=.18;TweenService:Create(panel,TweenInfo.new(.22,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(.5,0,.11,0),BackgroundTransparency=.04}):Play();playDonationSfx();task.delay(4.6,function()if popupToken~=token then return end;local tw=TweenService:Create(panel,TweenInfo.new(.22),{Position=UDim2.new(.5,0,.11,-100)});tw:Play();tw.Completed:Wait();if popupToken==token then panel.Visible=false end end)
end
monetizationRemote.OnClientEvent:Connect(function(action,data)data=type(data)=="table"and data or{};if action~="promptSupportLocal"then return end;local productId=tonumber(data.productId);if not productId or promptBusy then return end;promptBusy=true;activeProductId=productId;local ok=pcall(function()MarketplaceService:PromptProductPurchase(player,productId)end);if not ok then finishPrompt()else task.delay(45,function()if promptBusy and activeProductId==productId then finishPrompt()end end)end end)
stateRemote.OnClientEvent:Connect(function(kind,data)if kind=="supportReceived"and type(data)=="table"then showDonation(data)end end)
MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId,productId)if userId==player.UserId and(not activeProductId or tonumber(productId)==activeProductId)then finishPrompt()end end)
print("[BBYA] Support v6.1 online: compact notification + SFX volume 1.25")