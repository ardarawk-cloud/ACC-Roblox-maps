local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local musicRemote=remotes:WaitForChild("Music")
local supportRemote=remotes:WaitForChild("Support")
local stateRemote=remotes:WaitForChild("State")

local gui=Instance.new("ScreenGui")
gui.Name="BBYAClubUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=10;gui.Parent=player:WaitForChild("PlayerGui")
local PINK=Color3.fromRGB(255,48,160);local CYAN=Color3.fromRGB(0,190,255);local BG=Color3.fromRGB(11,10,14);local CARD=Color3.fromRGB(24,21,29);local MUTED=Color3.fromRGB(150,147,158)
local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,t,tr)local s=Instance.new("UIStroke");s.Color=col;s.Thickness=t or 1;s.Transparency=tr or .3;s.Parent=o end
local function btn(parent,text,pos,size,color)
 local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=color or CARD;b.TextColor3=Color3.fromRGB(244,244,247);b.Font=Enum.Font.GothamSemibold;b.TextSize=14;b.BorderSizePixel=0;b.Parent=parent;round(b,9);return b
end

-- Pinned high in the actual device viewport, top-right.
local menuBtn=btn(gui,"BBYA",UDim2.new(1,-70,0,10),UDim2.fromOffset(58,42),Color3.fromRGB(28,20,30));stroke(menuBtn,PINK,1,.15)
local menu=Instance.new("Frame");menu.Name="ClubMenu";menu.AnchorPoint=Vector2.new(1,0);menu.Position=UDim2.new(1,-12,0,60);menu.Size=UDim2.new(0,310,.76,0);menu.BackgroundColor3=BG;menu.BackgroundTransparency=.02;menu.BorderSizePixel=0;menu.Visible=false;menu.ClipsDescendants=true;menu.Parent=gui;round(menu,16);stroke(menu,PINK,1.1,.28)
local lim=Instance.new("UISizeConstraint");lim.MinSize=Vector2.new(280,350);lim.MaxSize=Vector2.new(330,560);lim.Parent=menu

local grad=Instance.new("UIGradient");grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(20,16,23)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,10,13))});grad.Rotation=90;grad.Parent=menu
local head=Instance.new("Frame");head.BackgroundTransparency=1;head.Position=UDim2.fromOffset(14,12);head.Size=UDim2.new(1,-28,0,50);head.Parent=menu
local brand=Instance.new("TextLabel");brand.BackgroundTransparency=1;brand.Size=UDim2.new(1,-44,0,24);brand.Text="BBYA SOCIAL HUB";brand.TextColor3=Color3.fromRGB(248,248,250);brand.Font=Enum.Font.GothamBold;brand.TextSize=18;brand.TextXAlignment=Enum.TextXAlignment.Left;brand.Parent=head
local subhead=Instance.new("TextLabel");subhead.BackgroundTransparency=1;subhead.Position=UDim2.fromOffset(0,26);subhead.Size=UDim2.new(1,-44,0,18);subhead.Text="HYBRID DJ  •  SUPPORT";subhead.TextColor3=MUTED;subhead.Font=Enum.Font.GothamMedium;subhead.TextSize=10;subhead.TextXAlignment=Enum.TextXAlignment.Left;subhead.Parent=head
local close=btn(head,"×",UDim2.new(1,-34,0,0),UDim2.fromOffset(34,34),Color3.fromRGB(32,28,37));close.TextSize=21

local tabs=Instance.new("Frame");tabs.BackgroundColor3=Color3.fromRGB(18,16,21);tabs.BorderSizePixel=0;tabs.Position=UDim2.fromOffset(14,68);tabs.Size=UDim2.new(1,-28,0,42);tabs.Parent=menu;round(tabs,10)
local musicTab=btn(tabs,"MUSIC",UDim2.fromOffset(4,4),UDim2.new(.5,-6,1,-8),Color3.fromRGB(74,22,55))
local supportTab=btn(tabs,"SUPPORT",UDim2.new(.5,2,0,4),UDim2.new(.5,-6,1,-8),Color3.fromRGB(26,25,31))

local content=Instance.new("Frame");content.BackgroundTransparency=1;content.Position=UDim2.fromOffset(14,120);content.Size=UDim2.new(1,-28,1,-134);content.Parent=menu
local music=Instance.new("Frame");music.BackgroundTransparency=1;music.Size=UDim2.fromScale(1,1);music.Parent=content
local nowCard=Instance.new("Frame");nowCard.Size=UDim2.new(1,0,0,78);nowCard.BackgroundColor3=CARD;nowCard.BorderSizePixel=0;nowCard.Parent=music;round(nowCard,12)
local nowLabel=Instance.new("TextLabel");nowLabel.BackgroundTransparency=1;nowLabel.Position=UDim2.fromOffset(12,9);nowLabel.Size=UDim2.new(1,-24,0,16);nowLabel.Text="NOW PLAYING";nowLabel.TextColor3=PINK;nowLabel.Font=Enum.Font.GothamBold;nowLabel.TextSize=10;nowLabel.TextXAlignment=Enum.TextXAlignment.Left;nowLabel.Parent=nowCard
local now=Instance.new("TextLabel");now.BackgroundTransparency=1;now.Position=UDim2.fromOffset(12,28);now.Size=UDim2.new(1,-24,0,36);now.Text="No track loaded";now.TextColor3=Color3.fromRGB(240,240,243);now.Font=Enum.Font.GothamMedium;now.TextSize=14;now.TextWrapped=true;now.TextXAlignment=Enum.TextXAlignment.Left;now.Parent=nowCard
local pause=btn(music,"PAUSE",UDim2.fromOffset(0,88),UDim2.new(.32,0,0,36));local nextb=btn(music,"NEXT",UDim2.new(.34,0,0,88),UDim2.new(.32,0,0,36),Color3.fromRGB(74,22,55));local resume=btn(music,"RESUME",UDim2.new(.68,0,0,88),UDim2.new(.32,0,0,36))
pause.MouseButton1Click:Connect(function()musicRemote:FireServer("pause")end);nextb.MouseButton1Click:Connect(function()musicRemote:FireServer("next")end);resume.MouseButton1Click:Connect(function()musicRemote:FireServer("resume")end)
local listTitle=Instance.new("TextLabel");listTitle.BackgroundTransparency=1;listTitle.Position=UDim2.fromOffset(0,132);listTitle.Size=UDim2.new(1,0,0,20);listTitle.Text="PLAYLIST";listTitle.TextColor3=MUTED;listTitle.Font=Enum.Font.GothamBold;listTitle.TextSize=10;listTitle.TextXAlignment=Enum.TextXAlignment.Left;listTitle.Parent=music
local listHolder=Instance.new("ScrollingFrame");listHolder.Position=UDim2.fromOffset(0,156);listHolder.Size=UDim2.new(1,0,1,-156);listHolder.BackgroundTransparency=1;listHolder.BorderSizePixel=0;listHolder.ScrollBarThickness=3;listHolder.AutomaticCanvasSize=Enum.AutomaticSize.Y;listHolder.CanvasSize=UDim2.new();listHolder.Parent=music;local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,7);layout.Parent=listHolder

local support=Instance.new("Frame");support.BackgroundTransparency=1;support.Size=UDim2.fromScale(1,1);support.Visible=false;support.Parent=content
local supCard=Instance.new("Frame");supCard.Size=UDim2.new(1,0,0,82);supCard.BackgroundColor3=CARD;supCard.BorderSizePixel=0;supCard.Parent=support;round(supCard,12)
local st=Instance.new("TextLabel");st.BackgroundTransparency=1;st.Position=UDim2.fromOffset(12,10);st.Size=UDim2.new(1,-24,0,22);st.Text="SUPPORT BBYA";st.TextColor3=CYAN;st.Font=Enum.Font.GothamBold;st.TextSize=16;st.TextXAlignment=Enum.TextXAlignment.Left;st.Parent=supCard
local ss=Instance.new("TextLabel");ss.BackgroundTransparency=1;ss.Position=UDim2.fromOffset(12,35);ss.Size=UDim2.new(1,-24,0,32);ss.Text="Support venue favoritmu melalui Robux.";ss.TextColor3=Color3.fromRGB(203,201,208);ss.Font=Enum.Font.Gotham;ss.TextSize=12;ss.TextWrapped=true;ss.TextXAlignment=Enum.TextXAlignment.Left;ss.Parent=supCard
local supportHolder=Instance.new("ScrollingFrame");supportHolder.Position=UDim2.fromOffset(0,96);supportHolder.Size=UDim2.new(1,0,1,-96);supportHolder.BackgroundTransparency=1;supportHolder.BorderSizePixel=0;supportHolder.ScrollBarThickness=3;supportHolder.AutomaticCanvasSize=Enum.AutomaticSize.Y;supportHolder.CanvasSize=UDim2.new();supportHolder.Parent=support
local grid=Instance.new("UIGridLayout");grid.CellSize=UDim2.new(.48,0,0,48);grid.CellPadding=UDim2.new(.04,0,0,10);grid.Parent=supportHolder

local toast=Instance.new("TextLabel");toast.AnchorPoint=Vector2.new(.5,1);toast.Position=UDim2.new(.5,0,1,-18);toast.Size=UDim2.new(.78,0,0,42);toast.BackgroundColor3=Color3.fromRGB(15,13,19);toast.BackgroundTransparency=.03;toast.TextColor3=Color3.new(1,1,1);toast.Font=Enum.Font.GothamMedium;toast.TextSize=13;toast.Visible=false;toast.Parent=gui;round(toast,11);stroke(toast,PINK,1,.45)
local toastLimit=Instance.new("UISizeConstraint");toastLimit.MaxSize=Vector2.new(420,42);toastLimit.Parent=toast
local function showToast(t)toast.Text=t;toast.Visible=true;task.delay(2.5,function()toast.Visible=false end)end
local function setTab(which)
 local isMusic=which=="music";music.Visible=isMusic;support.Visible=not isMusic
 musicTab.BackgroundColor3=isMusic and Color3.fromRGB(74,22,55) or Color3.fromRGB(26,25,31)
 supportTab.BackgroundColor3=isMusic and Color3.fromRGB(26,25,31) or Color3.fromRGB(18,65,83)
end
menuBtn.MouseButton1Click:Connect(function()menu.Visible=not menu.Visible;if menu.Visible then setTab("music");musicRemote:FireServer("list")end end)
close.MouseButton1Click:Connect(function()menu.Visible=false end)
musicTab.MouseButton1Click:Connect(function()setTab("music");musicRemote:FireServer("list")end)
supportTab.MouseButton1Click:Connect(function()setTab("support");supportRemote:FireServer("list")end)
stateRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="playlist" then
  for _,c in ipairs(listHolder:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end
  for i,item in ipairs(data)do local b=btn(listHolder,string.format("%02d   %s",i,item.title),UDim2.new(),UDim2.new(1,-4,0,40),Color3.fromRGB(26,23,31));b.TextXAlignment=Enum.TextXAlignment.Left;b.MouseButton1Click:Connect(function()musicRemote:FireServer("play",i)end)end
 elseif kind=="music" then now.Text=(data.playing and "▶  " or "Ⅱ  ")..tostring(data.title or "")
 elseif kind=="supportProducts" then
  for _,c in ipairs(supportHolder:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end
  for i,item in ipairs(data)do local b=btn(supportHolder,tostring(item.label).." R$",UDim2.new(),UDim2.new(.48,0,0,48),Color3.fromRGB(18,65,83));b.MouseButton1Click:Connect(function()supportRemote:FireServer("prompt",i)end)end
 elseif kind=="toast" then showToast(tostring(data)) end
end)
musicRemote:FireServer("list");supportRemote:FireServer("list")