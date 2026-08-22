-- BBYA SOCIAL HUB — MUSIC UI FINAL AUTHORITY v6
-- Research-driven compact music player: clear now-playing, full request list,
-- real PlaybackLoudness pulse, distinct HOME/MUSIC actions, and admin-only transport.
-- This is a late compatibility layer over the existing functional UI/remotes.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("BBYAClubUI",30)
if not gui then return end
local panel=gui:WaitForChild("HubPanel",30)
if not panel then return end
local camera=workspace.CurrentCamera

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local musicRemote=remotes:WaitForChild("Music",30)
local stateRemote=remotes:WaitForChild("State",30)
local funkotRemote=remotes:WaitForChild("FunkotMusic",30)

local C={
 bg=Color3.fromRGB(8,9,13),card=Color3.fromRGB(20,21,28),card2=Color3.fromRGB(28,29,37),
 line=Color3.fromRGB(61,64,76),white=Color3.fromRGB(246,246,249),muted=Color3.fromRGB(151,155,168),
 pink=Color3.fromRGB(232,38,165),cyan=Color3.fromRGB(39,196,225),gold=Color3.fromRGB(220,173,86),
 green=Color3.fromRGB(66,207,132),purple=Color3.fromRGB(143,82,255),
}
local function corner(o,r)
 local x=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
 x.CornerRadius=UDim.new(0,r or 10);x.Parent=o;return x
end
local function stroke(o,c,tr,name)
 local n=name or "MusicV6Stroke"
 local x=o:FindFirstChild(n) or Instance.new("UIStroke")
 x.Name=n;x.Color=c or C.line;x.Thickness=1;x.Transparency=tr or .52;x.Parent=o;return x
end
local function label(parent,name,text,pos,size,font,ts,color)
 local l=parent:FindFirstChild(name) or Instance.new("TextLabel")
 l.Name=name;l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham
 l.TextSize=ts or 10;l.TextColor3=color or C.white;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center
 l.TextWrapped=true;l.Parent=parent;return l
end
local function button(parent,name,text,pos,size,bg)
 local b=parent:FindFirstChild(name) or Instance.new("TextButton")
 b.Name=name;b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.card2;b.BorderSizePixel=0
 b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=9;b.AutoButtonColor=true;b.Parent=parent;corner(b,8);stroke(b,C.line,.58,"MusicV6ButtonStroke");return b
end
local function isAdmin()
 return player:GetAttribute("BBYAAdmin")==true or (game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId)
end

local playerCard=panel:FindFirstChild("PlayerCard",true)
local libraryCard=panel:FindFirstChild("LibraryCard",true)
if not playerCard or not libraryCard then return end
local musicFrame=playerCard.Parent
local content=musicFrame and musicFrame.Parent
if not content then return end
local supportIntro=panel:FindFirstChild("SupportIntro",true)
local supportFrame=supportIntro and supportIntro.Parent
local destination1=panel:FindFirstChild("Destination1",true)
local travelFrame=destination1 and destination1.Parent and destination1.Parent.Parent

local header
for _,f in ipairs(panel:GetChildren()) do
 if f:IsA("Frame") then
  for _,d in ipairs(f:GetChildren()) do
   if d:IsA("TextButton") and (d.Text=="×" or d.Text=="X") then header=f;break end
  end
 end
 if header then break end
end
local pageTitle,pageSub,legacyClose
if header then
 for _,d in ipairs(header:GetChildren()) do
  if d:IsA("TextLabel") then if d.TextSize>=16 then pageTitle=pageTitle or d else pageSub=pageSub or d end
  elseif d:IsA("TextButton") and (d.Text=="×" or d.Text=="X") then legacyClose=d end
 end
end

local function removeConflicts(root)
 for _,d in ipairs(root:GetDescendants()) do
  if d.Name=="OnlineAboveBBYA" or d.Name=="DashboardSearch" then d:Destroy() end
 end
 local rail=root:FindFirstChild("DashboardSideRailV2")
 if rail then rail.Visible=false end
 local glass=root:FindFirstChild("DashboardTopGlassV2")
 if glass then glass.Visible=false end
end
removeConflicts(panel)
panel.DescendantAdded:Connect(function(d)
 if d.Name=="OnlineAboveBBYA" or d.Name=="DashboardSearch" then task.defer(function()if d.Parent then d:Destroy() end end) end
end)

local close=button(panel,"MusicCloseV6","×",UDim2.new(1,-50,0,10),UDim2.fromOffset(40,36),Color3.fromRGB(31,32,40))
close.TextSize=22;close.ZIndex=520;stroke(close,C.pink,.42,"MusicV6CloseStroke")
if legacyClose then legacyClose.Visible=false end
close.Activated:Connect(function()panel.Visible=false end)

local nowSmall,nowTitle,nowMeta,zoneLabel,localMute,statusFrame,statusText,eqHolder
local legacyAdmin={}
for _,d in ipairs(playerCard:GetChildren()) do
 if d:IsA("TextLabel") then
  local up=string.upper(d.Text or "")
  if up=="NOW PLAYING" then nowSmall=d
  elseif d.TextSize>=16 then nowTitle=nowTitle or d
  elseif up:find("AUDIO VENUE",1,true) then zoneLabel=d
  elseif up:find("MAIN",1,true) or up:find("UNDERGROUND",1,true) or up:find("FUNKOT",1,true) then nowMeta=nowMeta or d end
 elseif d:IsA("TextButton") then
  local up=string.upper(d.Text or "")
  if up:find("MUTE",1,true) then localMute=d end
  if up=="PAUSE" or up=="RESUME" or up=="NEXT" then table.insert(legacyAdmin,d) end
 elseif d:IsA("Frame") then
  local barCount=0
  for _,x in ipairs(d:GetChildren()) do if x:IsA("Frame") then barCount+=1 end end
  if barCount>=10 then eqHolder=d end
  for _,x in ipairs(d:GetDescendants()) do
   if x:IsA("TextLabel") and (string.upper(x.Text or ""):find("LIVE",1,true) or string.upper(x.Text or ""):find("PAUSED",1,true)) then statusFrame=d;statusText=x;break end
  end
 end
end
for _,b in ipairs(legacyAdmin) do b.Visible=false end
if zoneLabel then zoneLabel.Visible=false end

for _,d in ipairs(playerCard:GetChildren()) do
 if d:IsA("Frame") and d~=eqHolder and d~=statusFrame then
  local hasBrand=false
  for _,x in ipairs(d:GetDescendants()) do if x:IsA("TextLabel") and string.upper(x.Text or "")=="BBYA" then hasBrand=true;break end end
  if hasBrand then d.Visible=false end
 end
end

local pulseBars={}
if eqHolder then
 for _,x in ipairs(eqHolder:GetChildren()) do if x:IsA("Frame") then x.Visible=false end end
 local old=eqHolder:FindFirstChild("BBYAAudioPulseV6");if old then old:Destroy() end
 local pulse=Instance.new("Frame");pulse.Name="BBYAAudioPulseV6";pulse.BackgroundTransparency=1;pulse.Size=UDim2.fromScale(1,1);pulse.ZIndex=70;pulse.Parent=eqHolder
 for i=1,14 do
  local b=Instance.new("Frame");b.Name="PulseBar"..i;b.AnchorPoint=Vector2.new(.5,1);b.Position=UDim2.new((i-.5)/14,0,1,-4);b.Size=UDim2.new(.045,0,0,4)
  b.BackgroundColor3=(i%4==0 and C.cyan or C.pink);b.BorderSizePixel=0;b.ZIndex=71;b.Parent=pulse;corner(b,3);table.insert(pulseBars,b)
 end
 eqHolder:SetAttribute("VisualizerMode","PLAYBACK_LOUDNESS_AMPLITUDE_V6")
end

local adminPrev=button(playerCard,"AdminPreviousV6","PREV",UDim2.new(),UDim2.fromOffset(52,26),Color3.fromRGB(32,33,42))
local adminNext=button(playerCard,"AdminNextV6","NEXT",UDim2.new(),UDim2.fromOffset(52,26),Color3.fromRGB(66,27,55))
stroke(adminPrev,C.cyan,.55,"AdminStroke");stroke(adminNext,C.pink,.48,"AdminStroke")
local function refreshAdmin()
 local a=isAdmin();adminPrev.Visible=a;adminNext.Visible=a
 for _,b in ipairs(legacyAdmin) do b.Visible=false end
end
refreshAdmin();player:GetAttributeChangedSignal("BBYAAdmin"):Connect(refreshAdmin)

local venueState={MAIN={index=0,library=0,playing=false},UNDERGROUND={index=0,library=0,playing=false},FUNKOT={index=0,library=0,playing=false}}
local function venueAtPlayer()
 local ch=player.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if not hrp then return "MAIN" end
 local p=hrp.Position
 if p.Y<-4.5 then return "UNDERGROUND" end
 if p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253 then return "FUNKOT" end
 return "MAIN"
end
local function setStatus(playing)
 if statusText then statusText.Text=playing and "●  PLAYING" or "Ⅱ  PAUSED";statusText.TextColor3=playing and C.green or C.gold end
 if statusFrame then statusFrame.BackgroundColor3=playing and Color3.fromRGB(18,49,36) or Color3.fromRGB(56,44,23) end
end
local function updateState(venue,data)
 local s=venueState[venue];if not s or type(data)~="table" then return end
 s.index=tonumber(data.index) or s.index;s.library=tonumber(data.library) or s.library;s.playing=data.playing==true
 if venueAtPlayer()==venue then setStatus(s.playing) end
end
stateRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="music" and type(data)=="table" then
  local v=(tostring(data.venue or "MAIN")=="BASEMENT") and "UNDERGROUND" or "MAIN";updateState(v,data)
 elseif kind=="playlist" and type(data)=="table" then
  local v=venueAtPlayer();if v~="FUNKOT" then venueState[v].library=#data end
 end
end)
funkotRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="state" then updateState("FUNKOT",data)
 elseif kind=="playlist" and type(data)=="table" then venueState.FUNKOT.library=#data end
end)
local function previousIndex(s)
 if not s or s.library<1 or s.index<1 then return nil end
 return ((s.index-2)%s.library)+1
end
adminPrev.Activated:Connect(function()
 if not isAdmin() then return end
 local v=venueAtPlayer();local i=previousIndex(venueState[v]);if not i then return end
 if v=="FUNKOT" then funkotRemote:FireServer("play",i) else musicRemote:FireServer("play",i) end
end)
adminNext.Activated:Connect(function()
 if not isAdmin() then return end
 local v=venueAtPlayer();if v=="FUNKOT" then funkotRemote:FireServer("next") else musicRemote:FireServer("next") end
end)

local function polishScroller(scroller)
 if not scroller or not scroller:IsA("ScrollingFrame") then return end
 scroller.Position=UDim2.fromOffset(12,38);scroller.Size=UDim2.new(1,-24,1,-46);scroller.Visible=true;scroller.Active=true;scroller.ScrollingEnabled=true;scroller.ScrollBarThickness=3
 for _,row in ipairs(scroller:GetChildren()) do
  if row:IsA("Frame") then
   row.BackgroundColor3=C.card2
   for _,x in ipairs(row:GetDescendants()) do
    if x:IsA("TextButton") and string.upper(x.Text or "")=="REQUEST" then x.Visible=true;x.Active=true;x.BackgroundColor3=Color3.fromRGB(70,26,61);x.TextColor3=C.white;x.ZIndex=90 end
   end
  end
 end
end
local function polishLibrary()
 local search=libraryCard:FindFirstChild("DashboardSearch");if search then search:Destroy() end
 local head
 for _,d in ipairs(libraryCard:GetChildren()) do
  if d:IsA("TextLabel") then if not head or d.TextSize>head.TextSize then head=d end end
 end
 if head then head.Position=UDim2.fromOffset(12,7);head.Size=UDim2.new(1,-24,0,24);head.Font=Enum.Font.GothamBold;head.TextSize=12;head.Visible=true end
 for _,d in ipairs(libraryCard:GetChildren()) do if d:IsA("TextLabel") and d~=head then d.Visible=false end end
 for _,d in ipairs(libraryCard:GetDescendants()) do if d:IsA("ScrollingFrame") then polishScroller(d) end end
end
libraryCard.DescendantAdded:Connect(function(d)if d:IsA("ScrollingFrame") or d:IsA("Frame") then task.defer(polishLibrary) end end)

local oldHome=content:FindFirstChild("BBYAHomeV6");if oldHome then oldHome:Destroy() end
local home=Instance.new("Frame");home.Name="BBYAHomeV6";home.BackgroundTransparency=1;home.Size=UDim2.fromScale(1,1);home.Visible=false;home.Parent=content
local homeCard=Instance.new("Frame");homeCard.Name="HomeCard";homeCard.BackgroundColor3=C.card;homeCard.BorderSizePixel=0;homeCard.Size=UDim2.fromScale(1,1);homeCard.Parent=home;corner(homeCard,13);stroke(homeCard,C.line,.50)
label(homeCard,"Brand","BBYA SOCIAL HUB",UDim2.fromOffset(18,16),UDim2.new(1,-36,0,30),Enum.Font.GothamBlack,20,C.white)
label(homeCard,"Purpose","SOCIAL DISTRICT • NIGHTLIFE • COMMUNITY",UDim2.fromOffset(18,46),UDim2.new(1,-36,0,20),Enum.Font.GothamBold,9,C.muted)
local homeVenue=label(homeCard,"Venue","YOU ARE IN  —",UDim2.fromOffset(18,84),UDim2.new(1,-36,0,28),Enum.Font.GothamBold,13,C.cyan)
local homeSong=label(homeCard,"Song","NOW PLAYING  —",UDim2.fromOffset(18,116),UDim2.new(1,-36,0,42),Enum.Font.GothamSemibold,12,C.white)
label(homeCard,"Hint","Open MUSIC to view the full playlist and request a track.",UDim2.fromOffset(18,168),UDim2.new(1,-36,0,40),Enum.Font.Gotham,10,C.muted)

local function currentSongText()
 if nowTitle and nowTitle.Text~="" then return nowTitle.Text end
 return "Loading audio…"
end
local function openHome()
 panel.Visible=true;home.Visible=true;musicFrame.Visible=false
 if supportFrame then supportFrame.Visible=false end;if travelFrame then travelFrame.Visible=false end
 if pageTitle then pageTitle.Visible=false end;if pageSub then pageSub.Visible=false end
 homeVenue.Text="YOU ARE IN  "..venueAtPlayer();homeSong.Text="NOW PLAYING  "..currentSongText()
end
local function leaveHome()
 home.Visible=false;if pageTitle then pageTitle.Visible=true end;if pageSub then pageSub.Visible=true end
end

local observedCommand=false
local function bindCommandMenu()
 if observedCommand then return end
 local menuGui=pg:FindFirstChild("BBYACommandMenuUI");if not menuGui then return end
 local drawer=menuGui:FindFirstChild("FeatureDrawer");if not drawer then return end
 local homeSlot=drawer:FindFirstChild("Slot_BBYA",true);local musicSlot=drawer:FindFirstChild("Slot_MUSIC",true)
 if not homeSlot or not musicSlot then return end
 observedCommand=true
 local old=homeSlot:FindFirstChild("BBYAHomeActionV6");if old then old:Destroy() end
 local hb=button(homeSlot,"BBYAHomeActionV6","HOME",UDim2.fromScale(0,0),UDim2.fromScale(1,1),C.card2);hb.ZIndex=230;stroke(hb,C.pink,.55,"HomeActionStroke")
 hb.Activated:Connect(function()
  openHome();drawer.Visible=false;local mb=menuGui:FindFirstChild("MenuButton");if mb and mb:IsA("TextButton") then mb.Text="MENU" end
 end)
 local originalMusic
 for _,x in ipairs(musicSlot:GetChildren()) do if x:IsA("TextButton") and x~=hb then originalMusic=x;break end end
 if originalMusic then
  originalMusic.TextTransparency=1
  local ml=label(musicSlot,"StableMusicLabelV6","MUSIC",UDim2.fromScale(0,0),UDim2.fromScale(1,1),Enum.Font.GothamBold,8,C.white);ml.TextXAlignment=Enum.TextXAlignment.Center;ml.ZIndex=228
  originalMusic.Activated:Connect(function()leaveHome()end)
 end
 for _,slotName in ipairs({"Slot_SUPPORT","Slot_TRAVEL"}) do
  local slot=drawer:FindFirstChild(slotName,true);if slot then for _,x in ipairs(slot:GetChildren()) do if x:IsA("TextButton") then x.Activated:Connect(leaveHome) end end end
 end
end
pg.ChildAdded:Connect(function()task.defer(bindCommandMenu)end)

local function layout()
 camera=workspace.CurrentCamera or camera
 local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720)
 local w=math.max(320,math.min(760,vp.X-56))
 local h=math.max(270,math.min(430,vp.Y-88))
 panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.52);panel.Size=UDim2.fromOffset(w,h);panel.BackgroundColor3=C.bg;panel.ClipsDescendants=true
 removeConflicts(panel)
 if header then header.Position=UDim2.fromOffset(16,9);header.Size=UDim2.new(1,-72,0,44) end
 close.Position=UDim2.new(1,-50,0,10)
 for _,f in ipairs(panel:GetChildren()) do
  if f:IsA("Frame") and f~=content and f~=header and f~=playerCard and f~=libraryCard then
   if f.Size.Y.Offset<=3 and f.Position.Y.Offset>50 and f.Position.Y.Offset<100 then f.Position=UDim2.fromOffset(16,58);f.Size=UDim2.new(1,-32,0,1) end
  end
 end
 content.Position=UDim2.fromOffset(16,66);content.Size=UDim2.new(1,-32,1,-78)
 local playerH=(h<340) and 88 or 104
 playerCard.Position=UDim2.fromOffset(0,0);playerCard.Size=UDim2.new(1,0,0,playerH);playerCard.BackgroundColor3=C.card
 libraryCard.Position=UDim2.fromOffset(0,playerH+8);libraryCard.Size=UDim2.new(1,0,1,-playerH-8);libraryCard.BackgroundColor3=C.card
 if nowSmall then nowSmall.Position=UDim2.fromOffset(14,7);nowSmall.Size=UDim2.new(1,-220,0,16);nowSmall.TextSize=8 end
 if nowTitle then nowTitle.Position=UDim2.fromOffset(14,23);nowTitle.Size=UDim2.new(1,-220,0,31);nowTitle.TextSize=(w<560 and 13 or 15);nowTitle.TextWrapped=false end
 if nowMeta then nowMeta.Position=UDim2.fromOffset(14,54);nowMeta.Size=UDim2.new(1,-220,0,18);nowMeta.TextSize=8 end
 if statusFrame then statusFrame.Position=UDim2.fromOffset(14,playerH-27);statusFrame.Size=UDim2.fromOffset(76,20) end
 if statusText then statusText.TextSize=8 end
 if eqHolder then eqHolder.Position=UDim2.new(1,-192,0,10);eqHolder.Size=UDim2.fromOffset(178,44) end
 if localMute then localMute.Position=UDim2.new(1,-192,0,playerH-34);localMute.Size=UDim2.fromOffset(72,26);localMute.TextSize=8 end
 adminPrev.Position=UDim2.new(1,-112,0,playerH-34);adminPrev.Size=UDim2.fromOffset(48,26)
 adminNext.Position=UDim2.new(1,-58,0,playerH-34);adminNext.Size=UDim2.fromOffset(48,26)
 refreshAdmin();polishLibrary()
 if home.Visible then homeVenue.Text="YOU ARE IN  "..venueAtPlayer();homeSong.Text="NOW PLAYING  "..currentSongText() end
end

local peak=120
local smooth=0
local acc=0
local function liveDeck(a,b)
 local A=SoundService:FindFirstChild(a);local B=SoundService:FindFirstChild(b)
 if A and A:GetAttribute("DeckRole")=="LIVE" then return A end
 if B and B:GetAttribute("DeckRole")=="LIVE" then return B end
 if A and A.IsPlaying then return A end;if B and B.IsPlaying then return B end
 return A or B
end
local function activeSound()
 local v=venueAtPlayer()
 if v=="FUNKOT" then return SoundService:FindFirstChild("BBYAFunkotDeck") end
 if v=="UNDERGROUND" then return liveDeck("BBYABasementDeckA","BBYABasementDeckB") end
 return liveDeck("BBYAClubDeckA","BBYAClubDeckB")
end
RunService.RenderStepped:Connect(function(dt)
 acc+=dt;if acc<1/30 then return end;acc=0
 if #pulseBars==0 then return end
 local s=activeSound();local loud=(s and s.PlaybackLoudness) or 0
 peak=math.max(100,loud,peak*.982)
 local normalized=math.clamp(loud/math.max(peak,100),0,1)
 smooth+=(normalized-smooth)*.36
 local n=#pulseBars
 for i,b in ipairs(pulseBars) do
  local center=1-math.abs((i-(n+1)/2)/((n+1)/2))
  local weight=.58+.42*center
  local h=4+math.floor(smooth*34*weight+.5)
  b.Size=UDim2.new(.045,0,0,h)
 end
end)

panel:GetPropertyChangedSignal("Visible"):Connect(function()if panel.Visible then task.defer(layout)end end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(layout)end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(layout)end) end

task.delay(1.35,function()removeConflicts(panel);bindCommandMenu();layout();musicRemote:FireServer("list");funkotRemote:FireServer("state")end)

print("[BBYA] Music UI v6 final authority: compact player / request-first / loudness pulse / HOME!=MUSIC / admin PREV+NEXT")
