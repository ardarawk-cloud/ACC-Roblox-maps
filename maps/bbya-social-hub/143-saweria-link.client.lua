-- BBYA SOCIAL HUB — SAWERIA LINK + ALERT UI v2
-- LINK is information/copy-oriented only. It never opens a browser or redirects automatically.
-- Donation alerts come only from the server SaweriaDonationAlert bridge; no Saweria secret exists client-side.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local SAWERIA_URL="https://saweria.co/BBYAsocialhub"
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local sawAlert=remotes and remotes:WaitForChild("SaweriaDonationAlert",30)

local old=pg:FindFirstChild("BBYASaweriaLinkUI");if old then old:Destroy() end
local gui=Instance.new("ScreenGui");gui.Name="BBYASaweriaLinkUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=276;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
gui:SetAttribute("AutoOpenWeb",false);gui:SetAttribute("OfficialSaweriaURL",SAWERIA_URL);gui:SetAttribute("AlertAuthority","SERVER_REMOTE_ONLY_V2")

local C={bg=Color3.fromRGB(13,13,17),card=Color3.fromRGB(29,29,37),white=Color3.fromRGB(245,245,248),muted=Color3.fromRGB(164,166,177),gold=Color3.fromRGB(235,184,74),cyan=Color3.fromRGB(73,207,235),green=Color3.fromRGB(103,230,174)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col;s.Thickness=1;s.Transparency=tr or .45;s.Parent=o end
local function label(parent,v,pos,size,font,ts,col,align)local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Text=tostring(v or "");t.Position=pos;t.Size=size;t.Font=font or Enum.Font.Gotham;t.TextSize=ts or 11;t.TextColor3=col or C.white;t.TextXAlignment=align or Enum.TextXAlignment.Left;t.TextYAlignment=Enum.TextYAlignment.Center;t.TextWrapped=true;t.Parent=parent;return t end
local function btn(parent,v,pos,size,col)local b=Instance.new("TextButton");b.Text=v;b.Position=pos;b.Size=size;b.BackgroundColor3=col or C.card;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=11;b.Active=true;b.AutoButtonColor=true;b.Parent=parent;corner(b,9);stroke(b,C.muted,.55);return b end

local shade=Instance.new("Frame");shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=Color3.new(0,0,0);shade.BackgroundTransparency=.8;shade.Visible=false;shade.BorderSizePixel=0;shade.Active=true;shade.ZIndex=200;shade.Parent=gui
local panel=Instance.new("Frame");panel.AnchorPoint=Vector2.new(1,0);panel.Position=UDim2.new(1,-18,0,58);panel.Size=UDim2.fromOffset(360,220);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Active=true;panel.ZIndex=201;panel.Parent=shade;corner(panel,14);stroke(panel,C.gold,.28)
label(panel,"LINK • SAWERIA",UDim2.fromOffset(16,12),UDim2.new(1,-64,0,24),Enum.Font.GothamBlack,17,C.white).ZIndex=202
label(panel,"Support di luar Robux melalui halaman Saweria resmi BBYA. Link ini hanya ditampilkan agar bisa kamu salin.",UDim2.fromOffset(16,42),UDim2.new(1,-32,0,48),Enum.Font.Gotham,10,C.muted).ZIndex=202
local close=btn(panel,"×",UDim2.new(1,-46,0,12),UDim2.fromOffset(32,30),C.card);close.TextSize=18;close.ZIndex=203
local box=Instance.new("TextBox");box.Position=UDim2.fromOffset(16,100);box.Size=UDim2.new(1,-32,0,42);box.BackgroundColor3=C.card;box.BorderSizePixel=0;box.Text=SAWERIA_URL;box.ClearTextOnFocus=false;box.TextEditable=true;box.MultiLine=false;box.TextColor3=C.cyan;box.Font=Enum.Font.Code;box.TextSize=12;box.TextXAlignment=Enum.TextXAlignment.Left;box.ZIndex=203;box.Parent=panel;corner(box,9);stroke(box,C.cyan,.45);local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,10);pad.PaddingRight=UDim.new(0,10);pad.Parent=box
local select=btn(panel,"SELECT LINK",UDim2.fromOffset(16,154),UDim2.fromOffset(132,38),Color3.fromRGB(35,68,78));select.ZIndex=203
label(panel,"Tidak membuka web otomatis.",UDim2.fromOffset(160,154),UDim2.new(1,-176,0,38),Enum.Font.GothamBold,9,C.gold).ZIndex=202
local function selectAll()
 box:CaptureFocus();task.defer(function()box.CursorPosition=#box.Text+1;box.SelectionStart=1 end)
end
select.Activated:Connect(selectAll)
box.FocusLost:Connect(function()if box.Text~=SAWERIA_URL then box.Text=SAWERIA_URL end end)
close.Activated:Connect(function()shade.Visible=false end)

local alert=Instance.new("Frame");alert.Name="SaweriaDonationPopup";alert.AnchorPoint=Vector2.new(.5,0);alert.Position=UDim2.new(.5,0,.10,-120);alert.Size=UDim2.fromOffset(390,92);alert.BackgroundColor3=C.bg;alert.BackgroundTransparency=.03;alert.BorderSizePixel=0;alert.Visible=false;alert.ZIndex=300;alert.Parent=gui;corner(alert,14);stroke(alert,C.green,.20)
local bar=Instance.new("Frame");bar.Position=UDim2.fromOffset(10,11);bar.Size=UDim2.fromOffset(4,70);bar.BackgroundColor3=C.green;bar.BorderSizePixel=0;bar.ZIndex=301;bar.Parent=alert;corner(bar,3)
label(alert,"SAWERIA SUPPORT",UDim2.fromOffset(26,8),UDim2.new(1,-38,0,20),Enum.Font.GothamBlack,12,C.green).ZIndex=301
local alertName=label(alert,"SUPPORTER",UDim2.fromOffset(26,29),UDim2.new(.58,-30,0,19),Enum.Font.GothamBold,13,C.white);alertName.ZIndex=301
local alertAmount=label(alert,"RP0",UDim2.new(.58,0,0,29),UDim2.new(.42,-18,0,19),Enum.Font.GothamBlack,13,C.gold,Enum.TextXAlignment.Right);alertAmount.ZIndex=301
local alertMsg=label(alert,"TERIMA KASIH SUDAH SUPPORT BBYA",UDim2.fromOffset(26,52),UDim2.new(1,-38,0,28),Enum.Font.GothamMedium,9,C.muted);alertMsg.ZIndex=301;alertMsg.TextTruncate=Enum.TextTruncate.AtEnd
local alertToken=0
local function rupiah(n)
 n=math.max(0,math.floor(tonumber(n) or 0));local s=tostring(n);local out=""
 while #s>3 do out="."..s:sub(-3)..out;s=s:sub(1,-4) end
 return "RP"..s..out
end
local function showAlert(data)
 if type(data)~="table" or tostring(data.source or "")~="SAWERIA" then return end
 local amount=tonumber(data.amount);if not amount or amount<=0 then return end
 alertToken+=1;local token=alertToken
 alertName.Text=string.upper(tostring(data.name or "SAWERIA SUPPORTER"));alertAmount.Text=rupiah(amount)
 local msg=tostring(data.message or "");alertMsg.Text=msg~="" and msg or "TERIMA KASIH SUDAH SUPPORT BBYA"
 alert.Visible=true;alert.Position=UDim2.new(.5,0,.10,-120)
 TweenService:Create(alert,TweenInfo.new(.24,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(.5,0,.10,0)}):Play()
 task.delay(5,function()
  if token~=alertToken or not alert.Parent then return end
  local tw=TweenService:Create(alert,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(.5,0,.10,-120)});tw:Play();tw.Completed:Wait();if token==alertToken then alert.Visible=false end
 end)
end
if sawAlert then sawAlert.OnClientEvent:Connect(showAlert) end

local function inject()
 local menu=pg:FindFirstChild("BBYACommandMenuUI");local drawer=menu and menu:FindFirstChild("FeatureDrawer",true);local list=drawer and drawer:FindFirstChild("FeatureList",true);if not list then return false end
 local oldButton=list:FindFirstChild("BBYASaweriaMenuButton");if oldButton then return true end
 local template=nil;for _,d in ipairs(list:GetChildren()) do if d:IsA("TextButton") then template=d;break end end
 local b=template and template:Clone() or Instance.new("TextButton");b.Name="BBYASaweriaMenuButton";b.Text="LINK";b.Visible=true;b.Active=true;b.AutoButtonColor=true
 if not template then b.Size=UDim2.new(1,-8,0,38);b.BackgroundColor3=C.card;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=11;corner(b,8) end
 b:SetAttribute("BBYAInjectedAuthority","SAWERIA_LINK_ALERT_V2");b.Parent=list
 b.Activated:Connect(function()if drawer and drawer:IsA("GuiObject") then drawer.Visible=false end;box.Text=SAWERIA_URL;shade.Visible=true end)
 return true
end
pg.ChildAdded:Connect(function(c)if c.Name=="BBYACommandMenuUI" then task.defer(inject);task.delay(.2,inject) end end)
task.spawn(function()for _=1,40 do if inject() then break end;task.wait(.25) end end)

print("[BBYA] Saweria v2 online: display/select link + server-verified in-game alert / no browser redirect / no client secret")