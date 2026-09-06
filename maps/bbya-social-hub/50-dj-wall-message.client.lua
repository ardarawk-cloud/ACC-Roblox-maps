-- BBYA SOCIAL HUB — MESSAGE CLIENT v7 CLEAN COMPACT
-- Compact 80-char composer. SEND is always visible. Success gets a clear notification + SFX.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local wallRemote=ReplicatedStorage:WaitForChild("BBYAClubRemotes"):WaitForChild("DJWall")
local SUCCESS_SFX="rbxassetid://7112275565"

local old=pg:FindFirstChild("BBYADJWallUI");if old then old:Destroy()end
local gui=Instance.new("ScreenGui");gui.Name="BBYADJWallUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=235;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg;gui:SetAttribute("PublicName","MESSAGE");gui:SetAttribute("BBYAUIAuthority","MESSAGE_V7_CLEAN_COMPACT")
local C={bg=Color3.fromRGB(10,10,14),panel=Color3.fromRGB(19,17,24),card=Color3.fromRGB(29,25,34),pink=Color3.fromRGB(247,55,158),white=Color3.fromRGB(246,245,248),muted=Color3.fromRGB(165,161,172),cyan=Color3.fromRGB(55,199,227),green=Color3.fromRGB(86,222,151)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 9);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col;s.Thickness=1;s.Transparency=tr or .45;s.Parent=o end
local function label(p,v,pos,size,font,ts,col,align)local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=tostring(v or"");l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 9;l.TextColor3=col or C.white;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.TextWrapped=true;l.Parent=p;return l end
local function button(p,v,pos,size,col)local b=Instance.new("TextButton");b.Text=v;b.Position=pos;b.Size=size;b.BackgroundColor3=col or C.card;b.BackgroundTransparency=.08;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=8;b.AutoButtonColor=true;b.Parent=p;corner(b,8);stroke(b,C.card,.2);return b end
local function kernelMenuVisible(v)local k=pg:FindFirstChild("BBYACommandMenuUI");local m=k and k:FindFirstChild("MenuButton",true);if m then m.Visible=v end end

local panel=Instance.new("Frame");panel.Name="DJWallComposerPanel";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.new(.5,0,.5,18);panel.Size=UDim2.fromOffset(330,300);panel.BackgroundColor3=C.bg;panel.BackgroundTransparency=.10;panel.BorderSizePixel=0;panel.Visible=false;panel.ClipsDescendants=true;panel.Parent=gui;corner(panel,15);stroke(panel,C.pink,.28)
panel:SetAttribute("PublicName","MESSAGE");panel:SetAttribute("Flow","WRITE_TIER_SEND");panel:SetAttribute("DedicatedLayout",true)
label(panel,"MESSAGE",UDim2.fromOffset(14,8),UDim2.new(1,-58,0,24),Enum.Font.GothamBlack,14,C.white)
local close=button(panel,"×",UDim2.new(1,-40,0,7),UDim2.fromOffset(30,30),C.card);close.TextSize=17
local cats=Instance.new("Frame");cats.Position=UDim2.fromOffset(12,38);cats.Size=UDim2.new(1,-24,0,27);cats.BackgroundTransparency=1;cats.Parent=panel
local category="BIRTHDAY";local catButtons={}
for i,name in ipairs({"BIRTHDAY","LOVE","SHOUTOUT","CUSTOM"})do local b=button(cats,name,UDim2.new((i-1)*.25,0,0,0),UDim2.new(.25,-3,1,0),C.card);b.TextSize=7;catButtons[name]=b;b.Activated:Connect(function()category=name;for k,x in pairs(catButtons)do x.BackgroundColor3=k==category and Color3.fromRGB(91,28,66)or C.card end end)end
catButtons.BIRTHDAY.BackgroundColor3=Color3.fromRGB(91,28,66)

local box=Instance.new("TextBox");box.Position=UDim2.fromOffset(12,72);box.Size=UDim2.new(1,-24,0,52);box.BackgroundColor3=C.panel;box.BackgroundTransparency=.10;box.BorderSizePixel=0;box.ClearTextOnFocus=false;box.MultiLine=true;box.Text="";box.PlaceholderText="Tulis pesan singkat...";box.PlaceholderColor3=C.muted;box.TextColor3=C.white;box.Font=Enum.Font.GothamMedium;box.TextSize=9;box.TextWrapped=true;box.TextXAlignment=Enum.TextXAlignment.Left;box.TextYAlignment=Enum.TextYAlignment.Top;box.Parent=panel;corner(box,9);stroke(box,Color3.fromRGB(67,55,72),.5);local bp=Instance.new("UIPadding");bp.PaddingLeft=UDim.new(0,9);bp.PaddingRight=UDim.new(0,9);bp.PaddingTop=UDim.new(0,7);bp.PaddingBottom=UDim.new(0,7);bp.Parent=box
local count=label(panel,"0 / 80",UDim2.new(1,-76,0,124),UDim2.fromOffset(62,14),Enum.Font.GothamBold,7,C.muted,Enum.TextXAlignment.Right)
label(panel,"PILIH ROBUX",UDim2.fromOffset(14,139),UDim2.new(1,-28,0,14),Enum.Font.GothamBold,7,C.muted)
local tiers=Instance.new("Frame");tiers.Position=UDim2.fromOffset(12,157);tiers.Size=UDim2.new(1,-24,0,65);tiers.BackgroundTransparency=1;tiers.Parent=panel
local grid=Instance.new("UIGridLayout");grid.CellPadding=UDim2.fromOffset(4,4);grid.CellSize=UDim2.new(1/3,-3,0,19);grid.FillDirectionMaxCells=3;grid.Parent=tiers
local LOCKED={2,5,10,25,50,100,250,500,1000};local selected=2;local tierButtons={};local config={available={},maxChars=80,admin=false}
for i,a in ipairs(LOCKED)do local b=button(tiers,tostring(a).." R$",UDim2.new(),UDim2.new(),C.card);b.LayoutOrder=i;b.TextSize=7;tierButtons[a]=b;b.Activated:Connect(function()if config.admin or config.available[a]~=false then selected=a;for amount,x in pairs(tierButtons)do x.BackgroundColor3=amount==selected and Color3.fromRGB(91,28,66)or C.card end end)end end
tierButtons[2].BackgroundColor3=Color3.fromRGB(91,28,66)
local send=button(panel,"KIRIM / SEND • 2 R$",UDim2.fromOffset(12,230),UDim2.new(1,-24,0,40),Color3.fromRGB(111,29,78));send.TextSize=10;stroke(send,C.pink,.18)
local status=label(panel,"READY",UDim2.fromOffset(14,274),UDim2.new(1,-28,0,16),Enum.Font.GothamBold,7,C.cyan)

local busy=false
local function refresh()
 if not config.admin and config.available[selected]==false then for _,a in ipairs(LOCKED)do if config.available[a]~=false then selected=a;break end end end
 for a,b in pairs(tierButtons)do local available=config.admin or config.available[a]~=false;b.Active=available;b.AutoButtonColor=available;b.TextTransparency=available and 0 or .55;b.BackgroundColor3=a==selected and Color3.fromRGB(91,28,66)or C.card end
 send.Text=config.admin and"KIRIM TEST • FREE"or("KIRIM / SEND • "..tostring(selected).." R$");send.Active=not busy;send.AutoButtonColor=not busy
end
local function toast(txt,col)
 local old=gui:FindFirstChild("MessageToast");if old then old:Destroy()end
 local t=label(gui,txt,UDim2.new(.5,-160,0,78),UDim2.fromOffset(320,42),Enum.Font.GothamBlack,10,C.white,Enum.TextXAlignment.Center);t.Name="MessageToast";t.BackgroundColor3=C.panel;t.BackgroundTransparency=.06;t.BorderSizePixel=0;t.ZIndex=500;corner(t,11);stroke(t,col or C.pink,.25);task.delay(2.4,function()if t.Parent then t:Destroy()end end)
end
local function playSuccess()
 local s=Instance.new("Sound");s.Name="BBYAMessageSuccessSFX";s.SoundId=SUCCESS_SFX;s.Volume=1.15;s.Parent=SoundService;pcall(function()s:Play()end);task.delay(5,function()if s.Parent then s:Destroy()end end)
end
local function applyConfig(d)if type(d)~="table"then return end;config=d;config.available=type(config.available)=="table"and config.available or{};refresh()end
local function openPanel(d)applyConfig(d);panel.Visible=true;kernelMenuVisible(false);status.Text="READY"end
local function closePanel()panel.Visible=false;box:ReleaseFocus();kernelMenuVisible(true)end
close.Activated:Connect(closePanel)
box:GetPropertyChangedSignal("Text"):Connect(function()local max=tonumber(config.maxChars)or 80;if #box.Text>max then box.Text=box.Text:sub(1,max);box.CursorPosition=#box.Text+1 end;count.Text=string.format("%d / %d",#box.Text,max)end)
send.Activated:Connect(function()
 if busy then return end;if #box.Text<2 then toast("Tulis pesan dulu.");box:CaptureFocus();return end
 busy=true;status.Text="PROCESSING...";send.Text="PROCESSING...";refresh();wallRemote:FireServer("submit",{category=category,text=box.Text,amount=selected})
 task.delay(6,function()if busy then busy=false;status.Text="COBA LAGI";refresh()end end)
end)
wallRemote.OnClientEvent:Connect(function(action,data)
 if action=="open"then openPanel(data)
 elseif action=="config"then applyConfig(data)
 elseif action=="processing"then status.Text="PROCESSING..."
 elseif action=="toast"then busy=false;status.Text="READY";refresh();toast(tostring(data))
 elseif action=="purchase"then busy=false;status.Text="ROBLOX PURCHASE";refresh();toast("Pesan lolos • selesaikan purchase Roblox.",C.cyan)
 elseif action=="queued"then busy=false;local pos=type(data)=="table"and(data.position or 1)or 1;playSuccess();toast("MESSAGE TERKIRIM • QUEUE #"..tostring(pos),C.green);box.Text="";status.Text="SENT";task.delay(.35,closePanel)
 end
end)
local cam=workspace.CurrentCamera
local function layout()cam=workspace.CurrentCamera or cam;local vp=cam and cam.ViewportSize or Vector2.new(1280,720);local scale=math.min(1,math.max(.82,(vp.Y-70)/330));panel.Size=UDim2.fromOffset(math.floor(330*scale),math.floor(300*scale));panel.Position=UDim2.new(.5,0,.5,18)end
if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(layout)end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()cam=workspace.CurrentCamera;if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(layout)end;layout()end)
refresh();wallRemote:FireServer("config");task.defer(layout)
print("[BBYA] MESSAGE client v7 online: compact 80-char box / visible SEND / success notification + SFX")