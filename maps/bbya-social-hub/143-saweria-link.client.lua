-- BBYA SOCIAL HUB — SAWERIA LINK + ALERT UI v3.1
-- LINK panel follows restored narrow General Panel. No fullscreen backdrop.
-- Compact server alert + SFX preserved.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local SoundService=game:GetService("SoundService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local SAWERIA_URL="https://saweria.co/BBYAsocialhub"
local FALLBACK_DONATION_SFX="rbxassetid://7112275565"
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local sawAlert=remotes and remotes:WaitForChild("SaweriaDonationAlert",30)
local old=pg:FindFirstChild("BBYASaweriaLinkUI");if old then old:Destroy()end
local gui=Instance.new("ScreenGui");gui.Name="BBYASaweriaLinkUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=276;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg;gui:SetAttribute("OfficialSaweriaURL",SAWERIA_URL);gui:SetAttribute("AlertAuthority","SERVER_REMOTE_ONLY_V3_1")
local C={bg=Color3.fromRGB(13,13,17),card=Color3.fromRGB(29,29,37),white=Color3.fromRGB(245,245,248),muted=Color3.fromRGB(164,166,177),gold=Color3.fromRGB(235,184,74),cyan=Color3.fromRGB(73,207,235),green=Color3.fromRGB(103,230,174)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col;s.Thickness=1;s.Transparency=tr or .45;s.Parent=o end
local function label(p,v,pos,size,font,ts,col,align)local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Text=tostring(v or"");t.Position=pos;t.Size=size;t.Font=font or Enum.Font.Gotham;t.TextSize=ts or 10;t.TextColor3=col or C.white;t.TextXAlignment=align or Enum.TextXAlignment.Left;t.TextYAlignment=Enum.TextYAlignment.Center;t.TextWrapped=true;t.Parent=p;return t end
local function btn(p,v,pos,size,col)local b=Instance.new("TextButton");b.Text=v;b.Position=pos;b.Size=size;b.BackgroundColor3=col or C.card;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=9;b.AutoButtonColor=true;b.Parent=p;corner(b,9);stroke(b,C.muted,.55);return b end
local function kernelMenuVisible(v)local k=pg:FindFirstChild("BBYACommandMenuUI");local m=k and k:FindFirstChild("MenuButton",true);if m then m.Visible=v end end
local camera=workspace.CurrentCamera
local function generalRect()camera=workspace.CurrentCamera or camera;local vp=camera and camera.ViewportSize or Vector2.new(1280,720);return math.clamp(math.floor(vp.X*.17),210,240),math.clamp(vp.Y-42,340,620)end

local panel=Instance.new("Frame");panel.Name="SaweriaPanel";panel.AnchorPoint=Vector2.new(1,.5);panel.Position=UDim2.new(1,-12,.5,0);panel.BackgroundColor3=C.bg;panel.BackgroundTransparency=.20;panel.BorderSizePixel=0;panel.Visible=false;panel.ClipsDescendants=true;panel.Parent=gui;corner(panel,14);stroke(panel,C.gold,.28);panel:SetAttribute("BBYAOuterLayoutAuthority","GENERAL_PANEL_ORIGINAL_NARROW_V1")
label(panel,"LINK • SAWERIA",UDim2.fromOffset(14,9),UDim2.new(1,-54,0,24),Enum.Font.GothamBlack,14,C.white)
local close=btn(panel,"×",UDim2.new(1,-40,0,7),UDim2.fromOffset(30,30),C.card);close.TextSize=17
label(panel,"Support di luar Robux",UDim2.fromOffset(14,36),UDim2.new(1,-28,0,18),Enum.Font.GothamBold,8,C.gold)
label(panel,"Salin link resmi BBYA di bawah. Game tidak membuka browser otomatis.",UDim2.fromOffset(14,62),UDim2.new(1,-28,0,56),Enum.Font.Gotham,8,C.muted)
local box=Instance.new("TextBox");box.Position=UDim2.fromOffset(12,128);box.Size=UDim2.new(1,-24,0,48);box.BackgroundColor3=C.card;box.BorderSizePixel=0;box.Text=SAWERIA_URL;box.ClearTextOnFocus=false;box.TextEditable=true;box.MultiLine=true;box.TextColor3=C.cyan;box.Font=Enum.Font.Code;box.TextSize=9;box.TextWrapped=true;box.TextXAlignment=Enum.TextXAlignment.Left;box.Parent=panel;corner(box,9);stroke(box,C.cyan,.45);local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,8);pad.PaddingRight=UDim.new(0,8);pad.PaddingTop=UDim.new(0,6);pad.Parent=box
local select=btn(panel,"SELECT LINK",UDim2.fromOffset(12,188),UDim2.new(1,-24,0,38),Color3.fromRGB(35,68,78))
label(panel,"NO AUTO REDIRECT",UDim2.fromOffset(14,238),UDim2.new(1,-28,0,20),Enum.Font.GothamBold,8,C.gold,Enum.TextXAlignment.Center)
label(panel,"Donation alert tetap otomatis dari server.",UDim2.fromOffset(14,266),UDim2.new(1,-28,0,42),Enum.Font.Gotham,8,C.muted,Enum.TextXAlignment.Center)
local function selectAll()box:CaptureFocus();task.defer(function()box.CursorPosition=#box.Text+1;box.SelectionStart=1 end)end;select.Activated:Connect(selectAll);box.FocusLost:Connect(function()if box.Text~=SAWERIA_URL then box.Text=SAWERIA_URL end end)
local function layout()local w,h=generalRect();panel.Size=UDim2.fromOffset(w,h);panel.Position=UDim2.new(1,-12,.5,0)end
local function closePanel()panel.Visible=false;kernelMenuVisible(true)end;close.Activated:Connect(closePanel)

local alert=Instance.new("Frame");alert.Name="SaweriaDonationPopup";alert.AnchorPoint=Vector2.new(.5,0);alert.Position=UDim2.new(.5,0,.10,-100);alert.Size=UDim2.fromOffset(300,82);alert.BackgroundColor3=C.bg;alert.BackgroundTransparency=.03;alert.BorderSizePixel=0;alert.Visible=false;alert.ZIndex=300;alert.Parent=gui;corner(alert,13);stroke(alert,C.green,.20)
local bar=Instance.new("Frame");bar.Position=UDim2.fromOffset(9,10);bar.Size=UDim2.fromOffset(4,62);bar.BackgroundColor3=C.green;bar.BorderSizePixel=0;bar.Parent=alert;corner(bar,3)
label(alert,"SAWERIA SUPPORT",UDim2.fromOffset(24,6),UDim2.new(1,-34,0,18),Enum.Font.GothamBlack,11,C.green)
local alertName=label(alert,"SUPPORTER",UDim2.fromOffset(24,25),UDim2.new(.60,-28,0,18),Enum.Font.GothamBold,12,C.white)
local alertAmount=label(alert,"RP0",UDim2.new(.60,0,0,25),UDim2.new(.40,-14,0,18),Enum.Font.GothamBlack,12,C.gold,Enum.TextXAlignment.Right)
local alertMsg=label(alert,"TERIMA KASIH SUDAH SUPPORT BBYA",UDim2.fromOffset(24,47),UDim2.new(1,-34,0,25),Enum.Font.GothamMedium,8,C.muted);alertMsg.TextTruncate=Enum.TextTruncate.AtEnd
local token=0
local function rupiah(n)n=math.max(0,math.floor(tonumber(n)or 0));local s=tostring(n);local out="";while #s>3 do out="."..s:sub(-3)..out;s=s:sub(1,-4)end;return"RP"..s..out end
local function playSfx()local s=Instance.new("Sound");s.SoundId=FALLBACK_DONATION_SFX;s.Volume=1.0;s.Parent=SoundService;pcall(function()s:Play()end);task.delay(6,function()if s.Parent then s:Destroy()end end)end
local function showAlert(data)if type(data)~="table"or tostring(data.source or"")~="SAWERIA"then return end;local amount=tonumber(data.amount);if not amount or amount<=0 then return end;token+=1;local me=token;alertName.Text=string.upper(tostring(data.name or"SAWERIA SUPPORTER"));alertAmount.Text=rupiah(amount);local msg=tostring(data.message or"");alertMsg.Text=msg~=""and msg or"TERIMA KASIH SUDAH SUPPORT BBYA";alert.Visible=true;alert.Position=UDim2.new(.5,0,.10,-100);playSfx();TweenService:Create(alert,TweenInfo.new(.24),{Position=UDim2.new(.5,0,.10,0)}):Play();task.delay(5,function()if token~=me then return end;local tw=TweenService:Create(alert,TweenInfo.new(.22),{Position=UDim2.new(.5,0,.10,-100)});tw:Play();tw.Completed:Wait();if token==me then alert.Visible=false end end)end
if sawAlert then sawAlert.OnClientEvent:Connect(showAlert)end
local function inject()
 local menu=pg:FindFirstChild("BBYACommandMenuUI");local drawer=menu and menu:FindFirstChild("FeatureDrawer",true);local list=drawer and drawer:FindFirstChild("FeatureList",true);if not list then return false end;local oldButton=list:FindFirstChild("BBYASaweriaMenuButton");if oldButton then return true end;local template=nil;for _,d in ipairs(list:GetChildren())do if d:IsA("TextButton")then template=d;break end end;local b=template and template:Clone()or Instance.new("TextButton");b.Name="BBYASaweriaMenuButton";b.Text="LINK";b.Visible=true;b.Active=true;b.AutoButtonColor=true;if not template then b.Size=UDim2.new(1,-8,0,38);b.BackgroundColor3=C.card;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=10;corner(b,8)end;b.Parent=list;b.Activated:Connect(function()drawer.Visible=false;kernelMenuVisible(false);box.Text=SAWERIA_URL;layout();panel.Visible=true end);return true
end
pg.ChildAdded:Connect(function(c)if c.Name=="BBYACommandMenuUI"then task.defer(inject)end end);task.spawn(function()for _=1,40 do if inject()then break end;task.wait(.25)end end);if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)end;task.defer(layout)
print("[BBYA] Saweria v3.1 online: narrow General Panel / alert preserved")