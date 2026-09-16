-- BBYA SOCIAL HUB — PUBLIC MESSAGE NOTIFICATION v1
-- Receives server-authoritative publicQueued events for messages sent by other players.
-- Sender still uses the existing MessageClient success popup; this script prevents duplicate sender popups.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local SoundService=game:GetService("SoundService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30);if not remotes then return end
local remote=remotes:WaitForChild("DJWall",30);if not remote then return end

local gui=Instance.new("ScreenGui")
gui.Name="BBYAPublicMessageNotification"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=941
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Parent=pg
gui:SetAttribute("BBYAUIAuthority","PUBLIC_MESSAGE_NOTIFICATION_V1")

local token=0
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col;s.Thickness=1;s.Transparency=tr or .25;s.Parent=o end
local function label(p,text,pos,size,font,ts,col,align)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=tostring(text or"");l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 10;l.TextColor3=col or Color3.fromRGB(246,245,248);l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.TextWrapped=true;l.Parent=p;return l
end
local function chime()
 local s=Instance.new("Sound");s.Name="BBYAPublicMessageSFX";s.SoundId="rbxassetid://7112275565";s.Volume=1.2;s.Parent=SoundService
 pcall(function()SoundService:PlayLocalSound(s)end)
 task.delay(5,function()if s.Parent then s:Destroy()end end)
end
local function show(data)
 if typeof(data)~="table"then return end
 local uid=tonumber(data.userId)
 if uid and uid==player.UserId then return end
 token+=1;local my=token
 local old=gui:FindFirstChild("PublicMessagePopup");if old then old:Destroy()end
 local pink=Color3.fromRGB(247,55,158);local white=Color3.fromRGB(246,245,248);local cyan=Color3.fromRGB(55,199,227);local green=Color3.fromRGB(86,222,151)
 local popup=Instance.new("Frame");popup.Name="PublicMessagePopup";popup.AnchorPoint=Vector2.new(.5,0);popup.Position=UDim2.new(.5,0,.10,-110);popup.Size=UDim2.fromOffset(300,84);popup.BackgroundColor3=Color3.fromRGB(14,14,19);popup.BackgroundTransparency=.04;popup.BorderSizePixel=0;popup.ZIndex=600;popup.Parent=gui;corner(popup,13);stroke(popup,pink,.22)
 local accent=Instance.new("Frame");accent.Size=UDim2.fromOffset(4,62);accent.Position=UDim2.fromOffset(9,11);accent.BackgroundColor3=pink;accent.BorderSizePixel=0;accent.ZIndex=601;accent.Parent=popup;corner(accent,3)
 local avatar=Instance.new("ImageLabel");avatar.Position=UDim2.fromOffset(22,15);avatar.Size=UDim2.fromOffset(54,54);avatar.BackgroundColor3=Color3.fromRGB(27,27,34);avatar.BorderSizePixel=0;avatar.ScaleType=Enum.ScaleType.Crop;avatar.ZIndex=601;avatar.Parent=popup;corner(avatar,27);stroke(avatar,pink,.18)
 if uid then task.spawn(function()local ok,url=pcall(function()return Players:GetUserThumbnailAsync(uid,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)end);if ok and avatar.Parent then avatar.Image=url end end)end
 label(popup,"MESSAGE SENT",UDim2.fromOffset(88,4),UDim2.new(1,-98,0,14),Enum.Font.GothamBlack,10,pink).ZIndex=601
 local who=string.upper(tostring(data.displayName or data.from or"PLAYER"));label(popup,who,UDim2.fromOffset(88,17),UDim2.new(1,-98,0,15),Enum.Font.GothamBold,10,white).ZIndex=601
 label(popup,"Q#"..tostring(tonumber(data.position)or 1),UDim2.fromOffset(88,31),UDim2.fromOffset(45,12),Enum.Font.GothamBold,7,cyan).ZIndex=601
 local amount=tonumber(data.amount)or 0;label(popup,amount>0 and(tostring(amount).." R$")or"ADMIN TEST",UDim2.fromOffset(132,31),UDim2.fromOffset(74,12),Enum.Font.GothamBold,7,green).ZIndex=601
 label(popup,"TOTAL "..tostring(math.max(0,math.floor(tonumber(data.total)or 0))).." R$",UDim2.new(1,-94,0,31),UDim2.fromOffset(84,12),Enum.Font.GothamBold,7,cyan,Enum.TextXAlignment.Right).ZIndex=601
 local preview=label(popup,tostring(data.text or""),UDim2.fromOffset(88,45),UDim2.new(1,-98,0,34),Enum.Font.GothamBlack,15,white);preview.ZIndex=601;preview.TextYAlignment=Enum.TextYAlignment.Top;preview.TextTruncate=Enum.TextTruncate.AtEnd
 TweenService:Create(popup,TweenInfo.new(.22,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(.5,0,.10,0)}):Play();chime()
 task.delay(9.5,function()if my~=token or not popup.Parent then return end;local tw=TweenService:Create(popup,TweenInfo.new(.22),{Position=UDim2.new(.5,0,.10,-110)});tw:Play();tw.Completed:Wait();if my==token and popup.Parent then popup:Destroy()end end)
end
remote.OnClientEvent:Connect(function(action,data)if action=="publicQueued"then show(data)end end)
print("[BBYA] Public MESSAGE notification online: other players now receive sender popup")
