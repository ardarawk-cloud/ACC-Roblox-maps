-- BBYA SOCIAL HUB — MESSAGE CLIENT v8 CLEAN REBUILD
-- Reliable MENU + wall-prompt launcher. Compact 80-char composer; SEND always visible.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remote=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30):WaitForChild("DJWall",30)
local SUCCESS_SFX="rbxassetid://7112275565"
local C={bg=Color3.fromRGB(10,10,14),panel=Color3.fromRGB(19,17,24),card=Color3.fromRGB(29,25,34),pink=Color3.fromRGB(247,55,158),white=Color3.fromRGB(246,245,248),muted=Color3.fromRGB(165,161,172),cyan=Color3.fromRGB(55,199,227),green=Color3.fromRGB(86,222,151)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 9);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col;s.Thickness=1;s.Transparency=tr or .45;s.Parent=o end
local function label(p,v,pos,size,font,ts,col,align)local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=tostring(v or"");l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 9;l.TextColor3=col or C.white;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.TextWrapped=true;l.Parent=p;return l end
local function button(p,v,pos,size,col)local b=Instance.new("TextButton");b.Text=v;b.Position=pos;b.Size=size;b.BackgroundColor3=col or C.card;b.BackgroundTransparency=.10;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=8;b.AutoButtonColor=true;b.Parent=p;corner(b,8);stroke(b,C.card,.2);return b end
local old=pg:FindFirstChild("BBYADJWallUI");if old then old:Destroy()end
local gui=Instance.new("ScreenGui");gui.Name="BBYADJWallUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=940;gui.Parent=pg;gui:SetAttribute("BBYAUIAuthority","MESSAGE_V8_CLEAN_REBUILD")
local panel=Instance.new("Frame");panel.Name="DJWallComposerPanel";panel.AnchorPoint=Vector2.new(1,.5);panel.Position=UDim2.new(1,-18,.5,18);panel.Size=UDim2.fromOffset(360,330);panel.BackgroundColor3=C.bg;panel.BackgroundTransparency=.14;panel.BorderSizePixel=0;panel.Visible=false;panel.ClipsDescendants=true;panel.Parent=gui;corner(panel,15);stroke(panel,C.pink,.28)
label(panel,"MESSAGE",UDim2.fromOffset(14,8),UDim2.new(1,-58,0,24),Enum.Font.GothamBlack,14,C.white)
local close=button(panel,"×",UDim2.new(1,-40,0,7),UDim2.fromOffset(30,30),C.card);close.TextSize=17
local cats=Instance.new("Frame");cats.Position=UDim2.fromOffset(12,40);cats.Size=UDim2.new(1,-24,0,28);cats.BackgroundTransparency=1;cats.Parent=panel
local category="BIRTHDAY";local catButtons={};for i,n in ipairs({"BIRTHDAY","LOVE","SHOUTOUT","CUSTOM"})do local b=button(cats,n,UDim2.new((i-1)*.25,0,0,0),UDim2.new(.25,-3,1,0),C.card);b.TextSize=7;catButtons[n]=b;b.Activated:Connect(function()category=n;for k,x in pairs(catButtons)do x.BackgroundColor3=k==category and Color3.fromRGB(91,28,66)or C.card end end)end;catButtons.BIRTHDAY.BackgroundColor3=Color3.fromRGB(91,28,66)
local box=Instance.new("TextBox");box.Position=UDim2.fromOffset(12,76);box.Size=UDim2.new(1,-24,0,56);box.BackgroundColor3=C.panel;box.BackgroundTransparency=.08;box.BorderSizePixel=0;box.ClearTextOnFocus=false;box.MultiLine=true;box.PlaceholderText="Tulis pesan singkat...";box.PlaceholderColor3=C.muted;box.TextColor3=C.white;box.Font=Enum.Font.GothamMedium;box.TextSize=10;box.TextWrapped=true;box.TextXAlignment=Enum.TextXAlignment.Left;box.TextYAlignment=Enum.TextYAlignment.Top;box.Parent=panel;corner(box,9);stroke(box,Color3.fromRGB(67,55,72),.5);local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,9);pad.PaddingRight=UDim.new(0,9);pad.PaddingTop=UDim.new(0,7);pad.PaddingBottom=UDim.new(0,7);pad.Parent=box
local count=label(panel,"0 / 80",UDim2.new(1,-76,0,132),UDim2.fromOffset(62,14),Enum.Font.GothamBold,7,C.muted,Enum.TextXAlignment.Right)
label(panel,"PILIH ROBUX",UDim2.fromOffset(14,146),UDim2.new(1,-28,0,14),Enum.Font.GothamBold,7,C.muted)
local tiers=Instance.new("Frame");tiers.Position=UDim2.fromOffset(12,164);tiers.Size=UDim2.new(1,-24,0,64);tiers.BackgroundTransparency=1;tiers.Parent=panel;local grid=Instance.new("UIGridLayout");grid.CellPadding=UDim2.fromOffset(4,4);grid.CellSize=UDim2.new(1/3,-3,0,18);grid.FillDirectionMaxCells=3;grid.Parent=tiers
local AMOUNTS={2,5,10,25,50,100,250,500,1000};local selected=2;local tierButtons={};local config={available={},maxChars=80,admin=false};for i,a in ipairs(AMOUNTS)do local b=button(tiers,a.." R$",UDim2.new(),UDim2.new(),C.card);b.LayoutOrder=i;b.TextSize=7;tierButtons[a]=b;b.Activated:Connect(function()if config.admin or config.available[a]~=false then selected=a;for x,q in pairs(tierButtons)do q.BackgroundColor3=x==selected and Color3.fromRGB(91,28,66)or C.card end end end)end;tierButtons[2].BackgroundColor3=Color3.fromRGB(91,28,66)
local send=button(panel,"KIRIM / SEND • 2 R$",UDim2.fromOffset(12,238),UDim2.new(1,-24,0,42),Color3.fromRGB(111,29,78));send.TextSize=10;stroke(send,C.pink,.18)
local status=label(panel,"READY",UDim2.fromOffset(14,286),UDim2.new(1,-28,0,18),Enum.Font.GothamBold,7,C.cyan)
local busy=false
local function menuButton()local m=pg:FindFirstChild("BBYACommandMenuUI");return m and m:FindFirstChild("MenuButton",true)end
local function roleButton(v)local g=pg:FindFirstChild("BBYARolePanelUI");local b=g and g:FindFirstChild("RolePanelOpen",true);if b then b.Visible=v end end
local function refresh()if not config.admin and config.available[selected]==false then for _,a in ipairs(AMOUNTS)do if config.available[a]~=false then selected=a;break end end end;for a,b in pairs(tierButtons)do local ok=config.admin or config.available[a]~=false;b.Active=ok;b.TextTransparency=ok and 0 or .55;b.BackgroundColor3=a==selected and Color3.fromRGB(91,28,66)or C.card end;send.Text=config.admin and"KIRIM TEST • FREE"or("KIRIM / SEND • "..selected.." R$");send.Active=not busy end
local function applyConfig(d)if type(d)=="table"then config=d;config.available=type(d.available)=="table"and d.available or{};refresh()end end
local function openPanel(d)applyConfig(d);panel.Visible=true;local mb=menuButton();if mb then mb.Visible=false end;roleButton(false);status.Text="READY";remote:FireServer("config")end
local function closePanel()panel.Visible=false;box:ReleaseFocus();local mb=menuButton();if mb then mb.Visible=true end;roleButton(true)end;close.Activated:Connect(closePanel)
local function toast(txt,col)local oldT=gui:FindFirstChild("MessageToast");if oldT then oldT:Destroy()end;local t=label(gui,txt,UDim2.new(.5,-160,0,78),UDim2.fromOffset(320,42),Enum.Font.GothamBlack,10,C.white,Enum.TextXAlignment.Center);t.Name="MessageToast";t.BackgroundColor3=C.panel;t.BackgroundTransparency=.06;t.BorderSizePixel=0;t.ZIndex=500;corner(t,11);stroke(t,col or C.pink,.25);task.delay(2.4,function()if t.Parent then t:Destroy()end end)end
local function success()local s=Instance.new("Sound");s.Name="BBYAMessageSuccessSFX";s.SoundId=SUCCESS_SFX;s.Volume=1.35;s.Parent=SoundService;pcall(function()s:Play()end);task.delay(5,function()if s.Parent then s:Destroy()end end)end
box:GetPropertyChangedSignal("Text"):Connect(function()local max=tonumber(config.maxChars)or 80;if #box.Text>max then box.Text=box.Text:sub(1,max);box.CursorPosition=#box.Text+1 end;count.Text=#box.Text.." / "..max end)
send.Activated:Connect(function()if busy then return end;if #box.Text<2 then toast("Tulis pesan dulu.");return end;busy=true;status.Text="PROCESSING...";refresh();remote:FireServer("submit",{category=category,text=box.Text,amount=selected});task.delay(7,function()if busy then busy=false;status.Text="COBA LAGI";refresh()end end)end)
remote.OnClientEvent:Connect(function(action,data)if action=="open"then openPanel(data)elseif action=="config"then applyConfig(data)elseif action=="processing"then status.Text="PROCESSING..."elseif action=="toast"then busy=false;status.Text="READY";refresh();toast(tostring(data))elseif action=="purchase"then busy=false;status.Text="ROBLOX PURCHASE";refresh();toast("Pesan siap • selesaikan purchase Roblox.",C.cyan)elseif action=="queued"then busy=false;success();toast("MESSAGE TERKIRIM • QUEUE #"..tostring(type(data)=="table"and(data.position or 1)or 1),C.green);box.Text="";status.Text="SENT";task.delay(.35,closePanel)end end)

local bound={};local function bindMenu()
 local menu=pg:FindFirstChild("BBYACommandMenuUI");if not menu then return end
 for _,d in ipairs(menu:GetDescendants())do if d:IsA("TextButton")and d:GetAttribute("BBYACommandMenuId")=="MESSAGE"and not bound[d]then bound[d]=true;d.Activated:Connect(function()local drawer=menu:FindFirstChild("FeatureDrawer",true);if drawer then drawer.Visible=false end;openPanel(config)end)end end
end
pg.DescendantAdded:Connect(function(d)if d:IsA("TextButton")then task.defer(bindMenu)end end);task.spawn(function()for _=1,40 do bindMenu();task.wait(.2)end end)
local cam=workspace.CurrentCamera;local function layout()cam=workspace.CurrentCamera or cam;local vp=cam and cam.ViewportSize or Vector2.new(1280,720);local s=math.clamp(math.min(vp.Y-84,420),330,420);panel.Size=UDim2.fromOffset(s,math.min(330,s));panel.Position=UDim2.new(1,-18,.5,18)end;if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(layout)end;task.defer(layout);remote:FireServer("config")
print("[BBYA] MESSAGE client v8 online: reliable MENU launcher / compact 80-char composer / visible SEND")