-- BBYA SOCIAL HUB — UNIFIED UI v5
-- Responsive shell + per-player venue mixer: Main western vs Basement Indo.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local camera=workspace.CurrentCamera
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local musicRemote=remotes:WaitForChild("Music")
local supportRemote=remotes:WaitForChild("Support")
local teleportRemote=remotes:WaitForChild("Teleport")
local stateRemote=remotes:WaitForChild("State")

local pg=player:WaitForChild("PlayerGui")
local old=pg:FindFirstChild("BBYAClubUI")
if old then old:Destroy() end

local gui=Instance.new("ScreenGui")
gui.Name="BBYAClubUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=18;gui.Parent=pg

local C={BG=Color3.fromRGB(9,9,12),PANEL=Color3.fromRGB(15,14,19),CARD=Color3.fromRGB(25,23,30),CARD2=Color3.fromRGB(31,28,36),PINK=Color3.fromRGB(247,55,158),PINKD=Color3.fromRGB(92,26,62),CYAN=Color3.fromRGB(32,190,215),GOLD=Color3.fromRGB(215,169,96),WHITE=Color3.fromRGB(244,243,247),MUTED=Color3.fromRGB(158,154,166),LINE=Color3.fromRGB(52,48,58),GREEN=Color3.fromRGB(62,205,124)}
local function round(o,r)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 10);x.Parent=o end
local function stroke(o,col,t,tr)local x=Instance.new("UIStroke");x.Color=col or C.LINE;x.Thickness=t or 1;x.Transparency=tr or .35;x.Parent=o;return x end
local function label(parent,text,pos,size,font,ts,col)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 13;l.TextColor3=col or C.WHITE;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=parent;return l
end
local function button(parent,text,pos,size,bg)
 local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.CARD;b.TextColor3=C.WHITE;b.Font=Enum.Font.GothamSemibold;b.TextSize=13;b.BorderSizePixel=0;b.AutoButtonColor=true;b.Parent=parent;round(b,9);return b
end
local function card(parent,name)
 local f=Instance.new("Frame");f.Name=name;f.BackgroundColor3=C.CARD;f.BorderSizePixel=0;f.Parent=parent;round(f,13);stroke(f,C.LINE,1,.45);return f
end

local dock=Instance.new("Frame")
dock.Name="TopDock";dock.AnchorPoint=Vector2.new(.5,0);dock.Position=UDim2.new(.56,0,0,14);dock.Size=UDim2.fromOffset(690,52);dock.BackgroundColor3=Color3.fromRGB(12,11,15);dock.BackgroundTransparency=.08;dock.BorderSizePixel=0;dock.Parent=gui;round(dock,14);stroke(dock,C.LINE,1,.35)
local brand=button(dock,"BBYA",UDim2.fromOffset(7,6),UDim2.fromOffset(78,40),Color3.fromRGB(43,24,37));stroke(brand,C.PINK,1,.35)
local musicTab=button(dock,"♫  MUSIC",UDim2.fromOffset(91,6),UDim2.fromOffset(150,40),C.PANEL)
local supportTab=button(dock,"◇  SUPPORT",UDim2.fromOffset(247,6),UDim2.fromOffset(150,40),C.PANEL)
local travelTab=button(dock,"⌖  TRAVEL",UDim2.fromOffset(403,6),UDim2.fromOffset(145,40),C.PANEL)
local statusPill=Instance.new("Frame");statusPill.Position=UDim2.new(1,-129,0,8);statusPill.Size=UDim2.fromOffset(120,36);statusPill.BackgroundColor3=Color3.fromRGB(19,27,24);statusPill.BorderSizePixel=0;statusPill.Parent=dock;round(statusPill,9);stroke(statusPill,C.GREEN,1,.55)
local statusDot=Instance.new("Frame");statusDot.Position=UDim2.fromOffset(11,13);statusDot.Size=UDim2.fromOffset(10,10);statusDot.BackgroundColor3=C.GREEN;statusDot.BorderSizePixel=0;statusDot.Parent=statusPill;round(statusDot,10)
local statusText=label(statusPill,"CLUB LIVE",UDim2.fromOffset(29,7),UDim2.new(1,-34,1,-14),Enum.Font.GothamBold,10,C.WHITE);statusText.TextYAlignment=Enum.TextYAlignment.Center

local panel=Instance.new("Frame")
panel.Name="HubPanel";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.54);panel.Size=UDim2.fromOffset(820,500);panel.BackgroundColor3=C.BG;panel.BackgroundTransparency=.025;panel.BorderSizePixel=0;panel.Visible=false;panel.ClipsDescendants=true;panel.Parent=gui;round(panel,17);stroke(panel,C.PINK,1.2,.38)
local header=Instance.new("Frame");header.BackgroundTransparency=1;header.Position=UDim2.fromOffset(20,14);header.Size=UDim2.new(1,-40,0,58);header.Parent=panel
local pageTitle=label(header,"MUSIC SYSTEM",UDim2.fromOffset(0,0),UDim2.new(1,-60,0,26),Enum.Font.GothamBold,20,C.WHITE)
local pageSub=label(header,"Main western channel • venue-aware request queue",UDim2.fromOffset(0,29),UDim2.new(1,-60,0,20),Enum.Font.Gotham,10,C.MUTED)
local close=button(header,"×",UDim2.new(1,-38,0,0),UDim2.fromOffset(38,36),C.CARD2);close.TextSize=22
local divider=Instance.new("Frame");divider.Position=UDim2.fromOffset(20,78);divider.Size=UDim2.new(1,-40,0,1);divider.BackgroundColor3=C.LINE;divider.BackgroundTransparency=.35;divider.BorderSizePixel=0;divider.Parent=panel
local content=Instance.new("Frame");content.BackgroundTransparency=1;content.Position=UDim2.fromOffset(20,92);content.Size=UDim2.new(1,-40,1,-112);content.Parent=panel

local music=Instance.new("Frame");music.BackgroundTransparency=1;music.Size=UDim2.fromScale(1,1);music.Parent=content
local playerCard=card(music,"PlayerCard");local libraryCard=card(music,"LibraryCard")
local art=Instance.new("Frame");art.BackgroundColor3=Color3.fromRGB(35,21,35);art.BorderSizePixel=0;art.Parent=playerCard;round(art,13);stroke(art,C.PINK,1,.4)
local artGrad=Instance.new("UIGradient");artGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(108,24,73)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(27,24,43)),ColorSequenceKeypoint.new(1,Color3.fromRGB(16,52,62))});artGrad.Rotation=25;artGrad.Parent=art
local artBrand=label(art,"BBYA",UDim2.fromScale(.12,.12),UDim2.fromScale(.76,.35),Enum.Font.GothamBlack,28,C.WHITE);artBrand.TextScaled=true;artBrand.TextXAlignment=Enum.TextXAlignment.Center
local artSub=label(art,"SOCIAL HUB",UDim2.fromScale(.12,.52),UDim2.fromScale(.76,.16),Enum.Font.GothamBold,10,C.MUTED);artSub.TextXAlignment=Enum.TextXAlignment.Center
local liveBadge=Instance.new("Frame");liveBadge.BackgroundColor3=Color3.fromRGB(19,43,32);liveBadge.BorderSizePixel=0;liveBadge.Parent=playerCard;round(liveBadge,8);stroke(liveBadge,C.GREEN,1,.6)
local liveLabel=label(liveBadge,"●  LIVE",UDim2.fromOffset(9,0),UDim2.new(1,-16,1,0),Enum.Font.GothamBold,9,C.GREEN);liveLabel.TextYAlignment=Enum.TextYAlignment.Center
local nowSmall=label(playerCard,"NOW PLAYING",UDim2.new(),UDim2.new(),Enum.Font.GothamBold,9,C.PINK)
local nowTitle=label(playerCard,"Loading club audio…",UDim2.new(),UDim2.new(),Enum.Font.GothamBold,18,C.WHITE)
local nowMeta=label(playerCard,"MAIN • WESTERN / INTERNATIONAL",UDim2.new(),UDim2.new(),Enum.Font.GothamMedium,9,C.MUTED)
local eqHolder=Instance.new("Frame");eqHolder.BackgroundColor3=Color3.fromRGB(15,17,20);eqHolder.BorderSizePixel=0;eqHolder.Parent=playerCard;round(eqHolder,9);stroke(eqHolder,C.LINE,1,.55)
local eqBars={}
for i=1,18 do local b=Instance.new("Frame");b.AnchorPoint=Vector2.new(.5,1);b.Position=UDim2.new((i-.5)/18,0,1,-7);b.Size=UDim2.new(.035,0,0,8);b.BackgroundColor3=(i%3==0 and C.CYAN or C.PINK);b.BorderSizePixel=0;b.Parent=eqHolder;round(b,4);table.insert(eqBars,b) end
local localMute=button(playerCard,"MUTE LOCAL",UDim2.new(),UDim2.new(),C.CARD2)
local zoneLabel=label(playerCard,"AUDIO VENUE: --",UDim2.new(),UDim2.new(),Enum.Font.GothamBold,9,C.CYAN)
local requestHint=label(playerCard,"Request masuk ke queue venue tempat kamu berada.",UDim2.new(),UDim2.new(),Enum.Font.Gotham,9,C.MUTED)
local adminPause=button(playerCard,"PAUSE",UDim2.new(),UDim2.new(),C.CARD2);local adminNext=button(playerCard,"NEXT",UDim2.new(),UDim2.new(),C.PINKD);local adminResume=button(playerCard,"RESUME",UDim2.new(),UDim2.new(),C.CARD2)
local libHead=label(libraryCard,"LIBRARY / REQUEST",UDim2.fromOffset(14,12),UDim2.new(1,-28,0,22),Enum.Font.GothamBold,13,C.WHITE)
local libSub=label(libraryCard,"Main: western • Basement: Indo",UDim2.fromOffset(14,35),UDim2.new(1,-28,0,18),Enum.Font.Gotham,9,C.MUTED)
local listHolder=Instance.new("ScrollingFrame");listHolder.Position=UDim2.fromOffset(12,62);listHolder.Size=UDim2.new(1,-24,1,-74);listHolder.BackgroundTransparency=1;listHolder.BorderSizePixel=0;listHolder.ScrollBarThickness=3;listHolder.ScrollBarImageColor3=C.PINK;listHolder.AutomaticCanvasSize=Enum.AutomaticSize.Y;listHolder.CanvasSize=UDim2.new();listHolder.ScrollingDirection=Enum.ScrollingDirection.Y;listHolder.Active=true;listHolder.Parent=libraryCard
local listLayout=Instance.new("UIListLayout");listLayout.Padding=UDim.new(0,7);listLayout.Parent=listHolder

local support=Instance.new("Frame");support.BackgroundTransparency=1;support.Size=UDim2.fromScale(1,1);support.Visible=false;support.Parent=content
local supportIntro=card(support,"SupportIntro")
local supBrand=label(supportIntro,"SUPPORT BBYA",UDim2.fromOffset(18,18),UDim2.new(1,-36,0,28),Enum.Font.GothamBold,20,C.WHITE)
local supText=label(supportIntro,"Support the venue and future BBYA upgrades. Every guest matters; supporters are remembered on the entrance honor wall.",UDim2.fromOffset(18,52),UDim2.new(1,-36,0,66),Enum.Font.Gotham,11,C.MUTED)
local supTag=label(supportIntro,"COMMUNITY FUNDS",UDim2.fromOffset(18,124),UDim2.new(1,-36,0,18),Enum.Font.GothamBold,9,C.CYAN)
local supportGridCard=card(support,"SupportGrid")
label(supportGridCard,"CHOOSE AMOUNT",UDim2.fromOffset(16,14),UDim2.new(1,-32,0,24),Enum.Font.GothamBold,15,C.WHITE)
local supportHolder=Instance.new("ScrollingFrame")
supportHolder.Name="SupportScroller";supportHolder.Position=UDim2.fromOffset(16,50);supportHolder.Size=UDim2.new(1,-32,1,-66);supportHolder.BackgroundTransparency=1;supportHolder.BorderSizePixel=0;supportHolder.ScrollBarThickness=4;supportHolder.ScrollBarImageColor3=C.CYAN;supportHolder.ScrollingDirection=Enum.ScrollingDirection.Y;supportHolder.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable;supportHolder.Active=true;supportHolder.CanvasSize=UDim2.new();supportHolder.Parent=supportGridCard
local supportGrid=Instance.new("UIGridLayout");supportGrid.CellSize=UDim2.new(.48,-4,0,70);supportGrid.CellPadding=UDim2.new(.04,0,0,10);supportGrid.Parent=supportHolder
local function syncSupportCanvas()supportHolder.CanvasSize=UDim2.fromOffset(0,math.max(0,supportGrid.AbsoluteContentSize.Y+8))end
supportGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(syncSupportCanvas)

local travel=Instance.new("Frame");travel.BackgroundTransparency=1;travel.Size=UDim2.fromScale(1,1);travel.Visible=false;travel.Parent=content
label(travel,"MOVE THROUGH BBYA",UDim2.fromOffset(0,0),UDim2.new(1,0,0,26),Enum.Font.GothamBold,17,C.WHITE)
label(travel,"Only destinations with valid walkable geometry are shown.",UDim2.fromOffset(0,28),UDim2.new(1,0,0,24),Enum.Font.Gotham,10,C.MUTED)
local travelGridHolder=Instance.new("Frame");travelGridHolder.Position=UDim2.fromOffset(0,64);travelGridHolder.Size=UDim2.new(1,0,1,-64);travelGridHolder.BackgroundTransparency=1;travelGridHolder.Parent=travel
local travelGrid=Instance.new("UIGridLayout");travelGrid.CellSize=UDim2.new(.32,0,.45,0);travelGrid.CellPadding=UDim2.new(.02,0,.06,0);travelGrid.Parent=travelGridHolder
local destinations={{"ARRIVAL","Arrival","ENTRY"},{"PHOTO STUDIO","Photo","FLOOR 1"},{"LOOK LAB","LookLab","FLOOR 1"},{"MAIN CLUB","MainClub","FLOOR 1"},{"VIP LEVEL","VIP","UPPER"},{"ROOFTOP","Rooftop","POOL"}}
for i,d in ipairs(destinations) do
 local c=card(travelGridHolder,"Destination"..i)
 local accent=Instance.new("Frame");accent.Size=UDim2.new(0,4,1,-18);accent.Position=UDim2.fromOffset(9,9);accent.BackgroundColor3=(d[2]=="MainClub" and C.PINK or (d[2]=="Photo" and C.CYAN or C.GOLD));accent.BorderSizePixel=0;accent.Parent=c;round(accent,4)
 label(c,d[1],UDim2.fromOffset(24,18),UDim2.new(1,-36,0,24),Enum.Font.GothamBold,13,C.WHITE)
 label(c,d[3],UDim2.fromOffset(24,45),UDim2.new(1,-36,0,18),Enum.Font.GothamBold,9,C.MUTED)
 local go=button(c,"GO",UDim2.new(0,24,1,-44),UDim2.new(1,-38,0,32),Color3.fromRGB(33,29,38));stroke(go,accent.BackgroundColor3,1,.45)
 go.MouseButton1Click:Connect(function()teleportRemote:FireServer(d[2]);panel.Visible=false end)
end

local toast=Instance.new("TextLabel");toast.AnchorPoint=Vector2.new(.5,1);toast.Position=UDim2.new(.5,0,1,-22);toast.Size=UDim2.fromOffset(420,42);toast.BackgroundColor3=Color3.fromRGB(12,11,15);toast.BackgroundTransparency=.03;toast.TextColor3=C.WHITE;toast.Font=Enum.Font.GothamMedium;toast.TextSize=12;toast.Visible=false;toast.BorderSizePixel=0;toast.Parent=gui;round(toast,10);stroke(toast,C.PINK,1,.48)
local function showToast(t)toast.Text=t;toast.Visible=true;task.delay(2.6,function()if toast.Text==t then toast.Visible=false end end)end
local function activeTab(b,on,col)b.BackgroundColor3=on and (col or C.PINKD) or C.PANEL end
local currentVenue="MAIN"
local function applyVenueCopy()
 if currentVenue=="BASEMENT" then
  pageTitle.Text="UNDERGROUND MUSIC";pageSub.Text="Independent Indo channel • breakbeat • indo-bounce"
  nowMeta.Text="UNDERGROUND • INDO BREAKBEAT / INDO BOUNCE";libSub.Text="UNDERGROUND INDO LIBRARY / REQUEST"
 else
  pageTitle.Text="MUSIC SYSTEM";pageSub.Text="Main western channel • independent from Basement"
  nowMeta.Text="MAIN • WESTERN / INTERNATIONAL";libSub.Text="MAIN WESTERN LIBRARY / REQUEST"
 end
end
local function setPage(which)
 panel.Visible=true;music.Visible=which=="music";support.Visible=which=="support";travel.Visible=which=="travel"
 activeTab(musicTab,which=="music",C.PINKD);activeTab(supportTab,which=="support",Color3.fromRGB(22,64,76));activeTab(travelTab,which=="travel",Color3.fromRGB(80,58,31))
 if which=="music" then applyVenueCopy();musicRemote:FireServer("list")
 elseif which=="support" then pageTitle.Text="SUPPORT BBYA";pageSub.Text="Community support • scroll to choose an amount";supportRemote:FireServer("list")
 else pageTitle.Text="TRAVEL";pageSub.Text="Quick access to verified BBYA social zones" end
end
brand.MouseButton1Click:Connect(function()if panel.Visible then panel.Visible=false else setPage("music") end end)
musicTab.MouseButton1Click:Connect(function()setPage("music")end);supportTab.MouseButton1Click:Connect(function()setPage("support")end);travelTab.MouseButton1Click:Connect(function()setPage("travel")end);close.MouseButton1Click:Connect(function()panel.Visible=false end)

-- Per-player venue audio mixer. Only one venue feed is audible at a time.
local muted=false
local currentMainVolume=.35
local currentBasementVolume=0
local function getZoneMix()
 local ch=player.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if not hrp then return .20,0,"LOADING","MAIN" end
 local p=hrp.Position
 if p.Y<-4.5 then return 0,.94,"BASEMENT / INDO","BASEMENT" end
 if p.Y>40 then return .34,0,"ROOFTOP","MAIN" end
 if p.Y>18 then return .48,0,"VIP","MAIN" end
 if p.Z<-45 then return .10,0,"ARRIVAL","MAIN" end
 if p.Z<-18 then return .20,0,"FRONT HALL","MAIN" end
 if p.Z<0 then return .36,0,"TRANSITION","MAIN" end
 if math.abs(p.X)>28 then return .62,0,"BAR / VIP LOUNGE","MAIN" end
 if p.Z>27 then return .92,0,"DJ / STAGE","MAIN" end
 return .84,0,"MAIN CLUB","MAIN"
end
localMute.MouseButton1Click:Connect(function()muted=not muted;localMute.Text=muted and "UNMUTE LOCAL" or "MUTE LOCAL" end)
adminPause.MouseButton1Click:Connect(function()musicRemote:FireServer("pause")end);adminNext.MouseButton1Click:Connect(function()musicRemote:FireServer("next")end);adminResume.MouseButton1Click:Connect(function()musicRemote:FireServer("resume")end)
local function refreshAdmin()
 local admin=player:GetAttribute("BBYAAdmin")==true or (game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId)
 adminPause.Visible=admin;adminNext.Visible=admin;adminResume.Visible=admin
end
refreshAdmin();player:GetAttributeChangedSignal("BBYAAdmin"):Connect(refreshAdmin)

local function populatePlaylist(data)
 for _,c in ipairs(listHolder:GetChildren())do if c:IsA("Frame") then c:Destroy() end end
 for i,item in ipairs(data or {}) do
  local row=Instance.new("Frame");row.Size=UDim2.new(1,-4,0,52);row.BackgroundColor3=Color3.fromRGB(29,26,34);row.BorderSizePixel=0;row.Parent=listHolder;round(row,9);stroke(row,C.LINE,1,.58)
  label(row,string.format("%02d",i),UDim2.fromOffset(11,8),UDim2.fromOffset(30,34),Enum.Font.GothamBold,10,C.PINK)
  label(row,tostring(item.title),UDim2.fromOffset(47,7),UDim2.new(1,-148,0,38),Enum.Font.GothamSemibold,11,C.WHITE)
  local rq=button(row,"REQUEST",UDim2.new(1,-92,0,9),UDim2.fromOffset(82,34),Color3.fromRGB(65,29,52));rq.TextSize=9;stroke(rq,C.PINK,1,.55);rq.MouseButton1Click:Connect(function()musicRemote:FireServer("request",i)end)
 end
end
local function populateSupport(data)
 for _,c in ipairs(supportHolder:GetChildren())do if c:IsA("TextButton") then c:Destroy() end end
 for i,item in ipairs(data or {}) do
  local b=button(supportHolder,tostring(item.label).." R$",UDim2.new(),UDim2.fromOffset(0,70),Color3.fromRGB(24,31,39));b.TextSize=15;stroke(b,C.CYAN,1,.4);b.MouseButton1Click:Connect(function()supportRemote:FireServer("prompt",i)end)
 end
 task.defer(syncSupportCanvas)
end
stateRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="playlist" then populatePlaylist(data)
 elseif kind=="music" then
  if data.venue then currentVenue=tostring(data.venue) end
  nowTitle.Text=tostring(data.title or "No track loaded");liveLabel.Text=data.playing and "●  LIVE" or "Ⅱ  PAUSED";liveLabel.TextColor3=data.playing and C.GREEN or C.GOLD
  applyVenueCopy()
 elseif kind=="supportProducts" then populateSupport(data)
 elseif kind=="openSupport" then setPage("support")
 elseif kind=="toast" then showToast(tostring(data)) end
end)

local function layout()
 local vp=camera.ViewportSize
 local dockW=math.clamp(vp.X*.52,430,720);dock.Size=UDim2.fromOffset(dockW,52)
 local compact=vp.X<1000
 if compact then
  musicTab.Text="MUSIC";supportTab.Text="SUPPORT";travelTab.Text="TRAVEL";statusPill.Visible=false;brand.Size=UDim2.fromOffset(68,40)
  local usable=dockW-86;local each=usable/3
  musicTab.Position=UDim2.fromOffset(79,6);musicTab.Size=UDim2.fromOffset(each-4,40);supportTab.Position=UDim2.fromOffset(79+each,6);supportTab.Size=UDim2.fromOffset(each-4,40);travelTab.Position=UDim2.fromOffset(79+each*2,6);travelTab.Size=UDim2.fromOffset(each-4,40)
 else
  musicTab.Text="♫  MUSIC";supportTab.Text="◇  SUPPORT";travelTab.Text="⌖  TRAVEL";statusPill.Visible=true;brand.Size=UDim2.fromOffset(78,40)
  musicTab.Position=UDim2.fromOffset(91,6);musicTab.Size=UDim2.fromOffset(150,40);supportTab.Position=UDim2.fromOffset(247,6);supportTab.Size=UDim2.fromOffset(150,40);travelTab.Position=UDim2.fromOffset(403,6);travelTab.Size=UDim2.fromOffset(145,40)
 end
 local pw=math.clamp(vp.X-50,300,840);local ph=math.clamp(vp.Y-118,280,520);panel.Size=UDim2.fromOffset(pw,ph);toast.Size=UDim2.fromOffset(math.min(420,vp.X-40),42)
 local wide=(pw-40)>=620
 if wide then
  playerCard.Position=UDim2.fromOffset(0,0);playerCard.Size=UDim2.new(.42,-7,1,0);libraryCard.Position=UDim2.new(.42,7,0,0);libraryCard.Size=UDim2.new(.58,-7,1,0)
  art.Position=UDim2.fromOffset(16,18);art.Size=UDim2.fromOffset(118,118);liveBadge.Position=UDim2.fromOffset(148,18);liveBadge.Size=UDim2.fromOffset(78,26);nowSmall.Position=UDim2.fromOffset(148,54);nowSmall.Size=UDim2.new(1,-164,0,16);nowTitle.Position=UDim2.fromOffset(148,74);nowTitle.Size=UDim2.new(1,-164,0,48);nowMeta.Position=UDim2.fromOffset(16,148);nowMeta.Size=UDim2.new(1,-32,0,18);eqHolder.Position=UDim2.fromOffset(16,176);eqHolder.Size=UDim2.new(1,-32,0,78);zoneLabel.Position=UDim2.fromOffset(16,260);zoneLabel.Size=UDim2.new(1,-32,0,18);requestHint.Position=UDim2.fromOffset(16,282);requestHint.Size=UDim2.new(1,-32,0,30);localMute.Position=UDim2.fromOffset(16,320);localMute.Size=UDim2.new(1,-32,0,38);adminPause.Position=UDim2.fromOffset(16,366);adminPause.Size=UDim2.new(.32,-6,0,34);adminNext.Position=UDim2.new(.34,0,0,366);adminNext.Size=UDim2.new(.32,-6,0,34);adminResume.Position=UDim2.new(.68,0,0,366);adminResume.Size=UDim2.new(.32,-16,0,34)
  supportIntro.Position=UDim2.fromOffset(0,0);supportIntro.Size=UDim2.new(.34,-8,1,0);supportGridCard.Position=UDim2.new(.34,8,0,0);supportGridCard.Size=UDim2.new(.66,-8,1,0)
 else
  playerCard.Position=UDim2.fromOffset(0,0);playerCard.Size=UDim2.new(1,0,0,186);libraryCard.Position=UDim2.fromOffset(0,196);libraryCard.Size=UDim2.new(1,0,1,-196);art.Position=UDim2.fromOffset(12,12);art.Size=UDim2.fromOffset(88,88);liveBadge.Position=UDim2.fromOffset(112,12);liveBadge.Size=UDim2.fromOffset(74,24);nowSmall.Position=UDim2.fromOffset(112,44);nowSmall.Size=UDim2.new(1,-124,0,14);nowTitle.Position=UDim2.fromOffset(112,61);nowTitle.Size=UDim2.new(1,-124,0,40);nowMeta.Position=UDim2.fromOffset(12,108);nowMeta.Size=UDim2.new(1,-24,0,16);eqHolder.Position=UDim2.fromOffset(12,130);eqHolder.Size=UDim2.new(.52,-18,0,42);zoneLabel.Position=UDim2.new(.54,0,0,132);zoneLabel.Size=UDim2.new(.46,-12,0,18);requestHint.Visible=false;localMute.Position=UDim2.new(.54,0,0,154);localMute.Size=UDim2.new(.46,-12,0,30);adminPause.Visible=false;adminNext.Visible=false;adminResume.Visible=false
  supportIntro.Position=UDim2.fromOffset(0,0);supportIntro.Size=UDim2.new(1,0,0,132);supportGridCard.Position=UDim2.fromOffset(0,144);supportGridCard.Size=UDim2.new(1,0,1,-144)
 end
 task.defer(syncSupportCanvas)
end
layout();camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)

local t=0
RunService.RenderStepped:Connect(function(dt)
 t+=dt
 for i,b in ipairs(eqBars) do local h=10+math.abs(math.sin(t*3.4+i*.72))*46+math.abs(math.sin(t*1.6+i*.31))*8;b.Size=UDim2.new(.035,0,0,h) end
 local mainTarget,basementTarget,zone,venue=getZoneMix()
 if muted then mainTarget=0;basementTarget=0 end
 currentMainVolume=currentMainVolume+(mainTarget-currentMainVolume)*math.min(1,dt*4.8)
 currentBasementVolume=currentBasementVolume+(basementTarget-currentBasementVolume)*math.min(1,dt*4.8)
 local mainGroup=SoundService:FindFirstChild("BBYAClubMaster");if mainGroup then mainGroup.Volume=currentMainVolume end
 local basementGroup=SoundService:FindFirstChild("BBYABasementMaster");if basementGroup then basementGroup.Volume=currentBasementVolume end
 zoneLabel.Text=string.format("AUDIO VENUE: %s  •  %d%%",zone,math.floor(math.max(mainTarget,basementTarget)*100+.5))
 if venue~=currentVenue then
  currentVenue=venue;applyVenueCopy();musicRemote:FireServer("list");musicRemote:FireServer("queue")
 end
end)

musicRemote:FireServer("list");supportRemote:FireServer("list")
print("[BBYA] Unified UI v5 online: automatic Main-Western / Basement-Indo audio routing")