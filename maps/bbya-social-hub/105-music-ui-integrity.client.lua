-- BBYA MUSIC SUITE v1 — PREMIUM PHASE 3 / MOBILE GUARD v4
-- Visual upgrade only: hero Now Playing, live visualizer, session Favorites,
-- richer queue cards, glass/neon depth, and a compact mini-player.
-- Existing server music authority/remotes remain unchanged.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("BBYAMusicSuiteV1",30)
if not gui then return end

local C={
 bg=Color3.fromRGB(7,8,12), panel=Color3.fromRGB(14,15,21),
 card=Color3.fromRGB(21,22,30), card2=Color3.fromRGB(29,30,40),
 line=Color3.fromRGB(68,71,86), white=Color3.fromRGB(247,247,250),
 muted=Color3.fromRGB(146,150,164), purple=Color3.fromRGB(142,77,255),
 pink=Color3.fromRGB(235,51,165), cyan=Color3.fromRGB(38,200,225),
 green=Color3.fromRGB(73,215,143), gold=Color3.fromRGB(232,181,82)
}

local function corner(o,r)
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 8);c.Parent=o;return c
end
local function stroke(o,col,tr,th)
 local s=Instance.new("UIStroke");s.Color=col or C.line;s.Transparency=tr or .55;s.Thickness=th or 1;s.Parent=o;return s
end
local function label(p,n,t,pos,size,font,ts,col,align)
 local x=Instance.new("TextLabel")
 x.Name=n;x.BackgroundTransparency=1;x.Text=t;x.Position=pos;x.Size=size
 x.Font=font or Enum.Font.Gotham;x.TextSize=ts or 9;x.TextColor3=col or C.white
 x.TextXAlignment=align or Enum.TextXAlignment.Left;x.TextYAlignment=Enum.TextYAlignment.Center
 x.TextTruncate=Enum.TextTruncate.AtEnd;x.Parent=p;return x
end
local function button(p,n,t,pos,size,bg)
 local b=Instance.new("TextButton")
 b.Name=n;b.Text=t;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.card
 b.BackgroundTransparency=.06;b.BorderSizePixel=0;b.TextColor3=C.white
 b.Font=Enum.Font.GothamBold;b.TextSize=8;b.AutoButtonColor=true;b.Parent=p
 corner(b,7);stroke(b,C.line,.62);return b
end
local function find(name)return gui:FindFirstChild(name,true)end

local brand=find("Brand")
local side=brand and brand.Parent
local venueText=find("Venue")
local venueCard=venueText and venueText.Parent
local navLib=find("NavLIBRARY")
local navNow=find("NavNOW")
local navQueue=find("NavQUEUE")
local nav=navLib and navLib.Parent
local navLayout=nav and nav:FindFirstChildWhichIsA("UIListLayout")
local statusValue=find("SV")
local status=statusValue and statusValue.Parent
local sectionTitle=find("SectionTitle")

local libPage=find("LIBRARY")
local nowPage=find("NOW")
local queuePage=find("QUEUE")
local content=libPage and libPage.Parent

local nowTitle=find("Track")
local nowInfo=nowTitle and nowTitle.Parent
local nowCard=nowInfo and nowInfo.Parent
local nowMeta=nowInfo and nowInfo:FindFirstChild("Meta")
local nowState=nowInfo and nowInfo:FindFirstChild("State")
local mute=find("Mute")
local prev=find("Prev")
local nextB=find("Next")
local controls=mute and mute.Parent
local elapsed=find("Elapsed")
local duration=find("Duration")
local art
if nowCard then
 for _,d in ipairs(nowCard:GetChildren()) do
  if d:IsA("Frame") and d~=nowInfo and d~=controls then art=d break end
 end
end

local wave
if nowInfo then
 for _,d in ipairs(nowInfo:GetChildren()) do
  if d:IsA("Frame") then wave=d break end
 end
end

local function getDirectScrolling(page)
 if not page then return nil end
 for _,d in ipairs(page:GetChildren()) do if d:IsA("ScrollingFrame") then return d end end
 return nil
end
local libList=getDirectScrolling(libPage)
local upList
if nowPage then
 for _,d in ipairs(nowPage:GetDescendants()) do if d:IsA("ScrollingFrame") then upList=d break end end
end
local up=upList and upList.Parent
local queueList
if queuePage then
 for _,d in ipairs(queuePage:GetDescendants()) do if d:IsA("ScrollingFrame") then queueList=d break end end
end

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
local musicRemote=remotes and remotes:FindFirstChild("Music")
local function currentVenue()
 local v=tostring(player:GetAttribute("BBYAAudioVenue") or "NONE")
 if v=="BASEMENT" then v="UNDERGROUND" end
 return v
end
local function requestTrack(index)
 local v=currentVenue()
 if musicRemote and (v=="MAIN" or v=="UNDERGROUND") then musicRemote:FireServer("request",index) end
end

-- Premium glass/neon depth --------------------------------------------------
if nowCard then
 nowCard.BackgroundTransparency=.10
 local old=nowCard:FindFirstChild("Phase3Glow")
 if old then old:Destroy() end
 local glow=Instance.new("Frame")
 glow.Name="Phase3Glow";glow.AnchorPoint=Vector2.new(.5,.5);glow.Position=UDim2.fromScale(.5,.5)
 glow.Size=UDim2.new(1,10,1,10);glow.BackgroundColor3=C.purple;glow.BackgroundTransparency=.94
 glow.BorderSizePixel=0;glow.ZIndex=0;glow.Parent=nowCard;corner(glow,14);stroke(glow,C.purple,.45,2)
end
if up then up.BackgroundTransparency=.10 end

-- Session Favorites --------------------------------------------------------
local favorites={}
local favPage, favList, favEmpty, navFav
if content and nav and libPage then
 local old=content:FindFirstChild("FAVORITES")
 if old then old:Destroy() end
 favPage=Instance.new("Frame")
 favPage.Name="FAVORITES";favPage.Position=libPage.Position;favPage.Size=libPage.Size
 favPage.BackgroundTransparency=1;favPage.Visible=false;favPage.Parent=content

 local hero=Instance.new("Frame")
 hero.Position=UDim2.fromOffset(0,0);hero.Size=UDim2.new(1,0,0,48)
 hero.BackgroundColor3=C.card;hero.BackgroundTransparency=.10;hero.BorderSizePixel=0;hero.Parent=favPage
 corner(hero,9);stroke(hero,C.pink,.58)
 label(hero,"Heart","♥",UDim2.fromOffset(14,0),UDim2.fromOffset(32,48),Enum.Font.GothamBlack,21,C.pink,Enum.TextXAlignment.Center)
 label(hero,"Title","YOUR FAVORITES",UDim2.fromOffset(52,5),UDim2.new(1,-64,0,22),Enum.Font.GothamBlack,11,C.white)
 label(hero,"Sub","Saved for this play session",UDim2.fromOffset(52,25),UDim2.new(1,-64,0,16),Enum.Font.GothamBold,6,C.muted)

 favList=Instance.new("ScrollingFrame")
 favList.Position=UDim2.fromOffset(0,58);favList.Size=UDim2.new(1,0,1,-58)
 favList.BackgroundColor3=C.panel;favList.BackgroundTransparency=.12;favList.BorderSizePixel=0
 favList.ScrollBarThickness=3;favList.AutomaticCanvasSize=Enum.AutomaticSize.Y;favList.CanvasSize=UDim2.fromOffset(0,0);favList.Parent=favPage
 corner(favList,10);stroke(favList,C.line,.62)
 local fp=Instance.new("UIPadding");fp.PaddingTop=UDim.new(0,6);fp.PaddingBottom=UDim.new(0,6);fp.PaddingLeft=UDim.new(0,6);fp.PaddingRight=UDim.new(0,6);fp.Parent=favList
 local fl=Instance.new("UIListLayout");fl.Padding=UDim.new(0,5);fl.Parent=favList
 favEmpty=label(favList,"FavoriteEmpty","Belum ada favorit • tekan ♥ di Library",UDim2.new(),UDim2.new(1,-4,0,54),Enum.Font.GothamBold,8,C.muted,Enum.TextXAlignment.Center)

 navFav=button(nav,"NavFAVORITES","   ♥  FAVORITES",UDim2.new(),UDim2.new(1,0,0,34),C.card)
 navFav.TextXAlignment=Enum.TextXAlignment.Left;navFav.LayoutOrder=4
end

local function favKey(index)return tostring(tonumber(index) or 0)end
local function refreshFavoritePage()
 if not favList then return end
 for _,d in ipairs(favList:GetChildren()) do if d.Name:sub(1,4)=="Fav_" then d:Destroy() end end
 local count=0
 local ordered={}
 for k,v in pairs(favorites) do if v then table.insert(ordered,{key=k,data=v}) end end
 table.sort(ordered,function(a,b)return (a.data.index or 0)<(b.data.index or 0) end)
 for _,entry in ipairs(ordered) do
  count+=1
  local f=Instance.new("Frame")
  f.Name="Fav_"..entry.key;f.Size=UDim2.new(1,-2,0,44);f.BackgroundColor3=C.card;f.BackgroundTransparency=.04;f.BorderSizePixel=0;f.Parent=favList
  corner(f,8);stroke(f,C.pink,.78)
  local strip=Instance.new("Frame");strip.Size=UDim2.fromOffset(3,28);strip.Position=UDim2.fromOffset(7,8);strip.BackgroundColor3=C.pink;strip.BorderSizePixel=0;strip.Parent=f;corner(strip,3)
  label(f,"No",string.format("%02d",entry.data.index or 0),UDim2.fromOffset(15,0),UDim2.fromOffset(34,44),Enum.Font.GothamBold,7,C.pink,Enum.TextXAlignment.Center)
  label(f,"T",entry.data.title or "Track",UDim2.fromOffset(52,3),UDim2.new(1,-188,0,22),Enum.Font.GothamBold,9,C.white)
  label(f,"M",entry.data.meta or "BBYA MUSIC",UDim2.fromOffset(52,23),UDim2.new(1,-188,0,15),Enum.Font.GothamBold,6,C.muted)
  local req=button(f,"Req","REQUEST",UDim2.new(1,-118,0,7),UDim2.fromOffset(104,30),Color3.fromRGB(49,32,70))
  req.Activated:Connect(function()requestTrack(entry.data.index or 0)end)
  local rem=button(f,"Remove","♥",UDim2.new(1,-152,0,7),UDim2.fromOffset(28,30),Color3.fromRGB(56,25,47));rem.TextColor3=C.pink;rem.TextSize=12
  rem.Activated:Connect(function()favorites[entry.key]=nil;refreshFavoritePage()end)
 end
 if favEmpty then favEmpty.Visible=count==0 end
end

local function setFavorite(index,titleText,metaText,on)
 local k=favKey(index)
 if on then favorites[k]={index=index,title=titleText,meta=metaText} else favorites[k]=nil end
 refreshFavoritePage()
end
local function isFavorite(index)return favorites[favKey(index)]~=nil end

local function decorateLibraryRows()
 if not libList then return end
 for _,r in ipairs(libList:GetChildren()) do
  if r:IsA("Frame") and r.Name:match("^Track_%d+$") then
   local index=tonumber(r.Name:match("(%d+)$")) or 0
   local t=r:FindFirstChild("Title")
   local m=r:FindFirstChild("Meta")
   local req=r:FindFirstChild("Req")
   local fav=r:FindFirstChild("FavToggle")
   if not fav then
    fav=button(r,"FavToggle",isFavorite(index) and "♥" or "♡",UDim2.new(1,-152,0,6),UDim2.fromOffset(28,30),Color3.fromRGB(42,29,50))
    fav.TextSize=12;fav.TextColor3=isFavorite(index) and C.pink or C.muted
    if req then req.Position=UDim2.new(1,-118,0,6) end
    fav.Activated:Connect(function()
     local on=not isFavorite(index)
     setFavorite(index,t and t.Text or ("Track "..index),m and m.Text or "BBYA MUSIC",on)
     fav.Text=on and "♥" or "♡";fav.TextColor3=on and C.pink or C.muted
    end)
   else
    fav.Text=isFavorite(index) and "♥" or "♡";fav.TextColor3=isFavorite(index) and C.pink or C.muted
   end
  end
 end
end

local function showFavorites()
 if not favPage then return end
 if libPage then libPage.Visible=false end;if nowPage then nowPage.Visible=false end;if queuePage then queuePage.Visible=false end
 favPage.Visible=true
 if sectionTitle then sectionTitle.Text="FAVORITES" end
 if navFav then navFav.BackgroundColor3=Color3.fromRGB(67,31,70);navFav.TextColor3=C.white end
 if navLib then navLib.BackgroundColor3=C.card end;if navNow then navNow.BackgroundColor3=C.card end;if navQueue then navQueue.BackgroundColor3=C.card end
 refreshFavoritePage()
end
if navFav then navFav.Activated:Connect(showFavorites) end
for _,b in ipairs({navLib,navNow,navQueue}) do if b then b.Activated:Connect(function()if favPage then favPage.Visible=false end;if navFav then navFav.BackgroundColor3=C.card;navFav.TextColor3=C.muted end end) end end

-- Hero Now Playing + premium visualizer ------------------------------------
local heroViz,vizBars={},{}
if nowCard then
 local old=nowCard:FindFirstChild("HeroVisualizerV3");if old then old:Destroy() end
 heroViz=Instance.new("Frame")
 heroViz.Name="HeroVisualizerV3";heroViz.Position=UDim2.new(0,18,1,-112);heroViz.Size=UDim2.new(1,-36,0,23)
 heroViz.BackgroundTransparency=1;heroViz.Parent=nowCard
 for i=1,20 do
  local b=Instance.new("Frame")
  b.AnchorPoint=Vector2.new(.5,1);b.Position=UDim2.new((i-.5)/20,0,1,0);b.Size=UDim2.new(.026,0,0,3)
  b.BackgroundColor3=(i%5==0) and C.cyan or ((i%3==0) and C.pink or C.purple);b.BorderSizePixel=0;b.Parent=heroViz;corner(b,3);vizBars[i]=b
 end
 local livePill=Instance.new("Frame")
 livePill.Name="LivePillV3";livePill.Position=UDim2.new(1,-78,0,12);livePill.Size=UDim2.fromOffset(62,22);livePill.BackgroundColor3=Color3.fromRGB(20,51,42);livePill.BackgroundTransparency=.12;livePill.BorderSizePixel=0;livePill.Parent=nowCard;corner(livePill,11);stroke(livePill,C.green,.55)
 label(livePill,"Text","●  LIVE",UDim2.new(),UDim2.fromScale(1,1),Enum.Font.GothamBold,7,C.green,Enum.TextXAlignment.Center)
end

if art then
 art.Visible=true
 art.BackgroundTransparency=.04
 local brandText=art:FindFirstChild("Brand")
 if brandText and brandText:IsA("TextLabel") then brandText.Text="BBYA";brandText.TextSize=21 end
 local old=art:FindFirstChild("AlbumRingV3");if old then old:Destroy() end
 local ring=Instance.new("Frame");ring.Name="AlbumRingV3";ring.AnchorPoint=Vector2.new(.5,.5);ring.Position=UDim2.fromScale(.5,.5);ring.Size=UDim2.new(1,-10,1,-10);ring.BackgroundTransparency=1;ring.Parent=art;corner(ring,12);stroke(ring,C.pink,.48,1.4)
end

local activeSound,lastScan=nil,0
local function getSound()
 if activeSound and activeSound.Parent and activeSound.IsPlaying then return activeSound end
 if os.clock()-lastScan<.6 then return activeSound end
 lastScan=os.clock()
 for _,root in ipairs({SoundService,workspace}) do
  for _,x in ipairs(root:GetDescendants()) do
   if x:IsA("Sound") and x.IsPlaying and (x.Name:find("BBYA") or x.SoundGroup~=nil) then activeSound=x;return x end
  end
 end
 activeSound=nil;return nil
end

-- Queue card premium styling -----------------------------------------------
local function polishQueue(scroller,accent)
 if not scroller then return end
 for _,r in ipairs(scroller:GetChildren()) do
  if r:IsA("Frame") and not r:FindFirstChild("QueueAccentV3") then
   r.BackgroundTransparency=.05
   local strip=Instance.new("Frame");strip.Name="QueueAccentV3";strip.Position=UDim2.fromOffset(5,8);strip.Size=UDim2.fromOffset(3,math.max(22,r.Size.Y.Offset-16));strip.BackgroundColor3=accent;strip.BorderSizePixel=0;strip.Parent=r;corner(strip,3)
   local s=r:FindFirstChildWhichIsA("UIStroke");if s then s.Transparency=.80 else stroke(r,accent,.84) end
  end
 end
end

-- Independent mini-player --------------------------------------------------
local oldMini=pg:FindFirstChild("BBYAMusicMiniPlayerV3");if oldMini then oldMini:Destroy() end
local miniGui=Instance.new("ScreenGui");miniGui.Name="BBYAMusicMiniPlayerV3";miniGui.ResetOnSpawn=false;miniGui.DisplayOrder=925;miniGui.IgnoreGuiInset=true;miniGui.Parent=pg
local mini=Instance.new("Frame");mini.Name="MiniPlayer";mini.AnchorPoint=Vector2.new(.5,1);mini.Position=UDim2.new(.5,0,1,-12);mini.Size=UDim2.fromOffset(380,54);mini.BackgroundColor3=Color3.fromRGB(11,12,18);mini.BackgroundTransparency=.07;mini.BorderSizePixel=0;mini.Visible=false;mini.Parent=miniGui;corner(mini,13);stroke(mini,C.purple,.35,1.3)
local miniArt=Instance.new("Frame");miniArt.Position=UDim2.fromOffset(6,6);miniArt.Size=UDim2.fromOffset(42,42);miniArt.BackgroundColor3=Color3.fromRGB(46,24,76);miniArt.BorderSizePixel=0;miniArt.Parent=mini;corner(miniArt,9)
label(miniArt,"Logo","B",UDim2.new(),UDim2.fromScale(1,1),Enum.Font.GothamBlack,18,C.white,Enum.TextXAlignment.Center)
local miniTitle=label(mini,"Title","BBYA MUSIC",UDim2.fromOffset(58,6),UDim2.new(1,-140,0,22),Enum.Font.GothamBold,9,C.white)
local miniMeta=label(mini,"Meta","Tap to open player",UDim2.fromOffset(58,27),UDim2.new(1,-140,0,18),Enum.Font.GothamBold,6,C.muted)
local miniOpen=button(mini,"Open","OPEN",UDim2.new(1,-74,0,10),UDim2.fromOffset(62,34),Color3.fromRGB(57,33,92));miniOpen.TextSize=7
miniOpen.Activated:Connect(function()gui.Enabled=true;mini.Visible=false end)

local function updateMini()
 local t=nowTitle and tostring(nowTitle.Text or "") or ""
 miniTitle.Text=(t~="" and t~="BELUM ADA LAGU") and t or "BBYA MUSIC"
 miniMeta.Text=(nowState and nowState.Text=="LIVE • PLAYING") and "LIVE • PLAYING" or "BBYA MUSIC"
 mini.Visible=not gui.Enabled
end
if nowTitle then nowTitle:GetPropertyChangedSignal("Text"):Connect(updateMini) end
if nowState then nowState:GetPropertyChangedSignal("Text"):Connect(updateMini) end

-- Responsive authority -----------------------------------------------------
local function setButtonCompact(b,order,height)
 if not b then return end
 b.Size=UDim2.new(1,0,0,height or 28);b.TextSize=7;b.LayoutOrder=order
end

local applying=false
local function apply()
 if applying then return end;applying=true
 local cam=workspace.CurrentCamera
 local vp=cam and cam.ViewportSize or Vector2.new(1280,720)
 local compact=vp.X<900 or vp.Y<520

 if compact then
  if side then side.Size=UDim2.new(0,150,1,0) end
  if brand then brand.Position=UDim2.fromOffset(14,9);brand.Size=UDim2.new(1,-28,0,23);brand.TextSize=17 end
  local sub=side and side:FindFirstChild("Sub");if sub then sub.Position=UDim2.fromOffset(14,31);sub.Size=UDim2.new(1,-28,0,12);sub.TextSize=6 end
  if venueCard then venueCard.Position=UDim2.fromOffset(11,50);venueCard.Size=UDim2.new(1,-22,0,42) end
  if venueText then venueText.Position=UDim2.fromOffset(10,4);venueText.Size=UDim2.new(1,-20,0,17);venueText.TextSize=8 end
  local hint=venueCard and venueCard:FindFirstChild("Hint");if hint then hint.Position=UDim2.fromOffset(10,21);hint.Size=UDim2.new(1,-20,0,13);hint.TextSize=5 end
  if nav then nav.Position=UDim2.fromOffset(11,100);nav.Size=UDim2.new(1,-22,0,124) end
  if navLayout then navLayout.Padding=UDim.new(0,4) end
  setButtonCompact(navLib,1,28);setButtonCompact(navNow,2,28);setButtonCompact(navQueue,3,28);setButtonCompact(navFav,4,28)
  if status then status.Visible=false end

  if art then art.Visible=true;art.Position=UDim2.fromOffset(14,14);art.Size=UDim2.fromOffset(88,88) end
  if nowInfo then nowInfo.Position=UDim2.fromOffset(116,12);nowInfo.Size=UDim2.new(1,-132,0,91) end
  if nowState then nowState.Position=UDim2.fromOffset(0,0);nowState.Size=UDim2.new(1,-70,0,15);nowState.TextSize=7 end
  if nowTitle then nowTitle.Position=UDim2.fromOffset(0,18);nowTitle.Size=UDim2.new(1,0,0,41);nowTitle.TextSize=12 end
  if nowMeta then nowMeta.Position=UDim2.fromOffset(0,60);nowMeta.Size=UDim2.new(1,0,0,14);nowMeta.TextSize=6 end
  if wave then wave.Visible=false end
  if heroViz then heroViz.Position=UDim2.new(0,18,1,-111);heroViz.Size=UDim2.new(1,-36,0,21) end
  if elapsed then elapsed.Position=UDim2.new(0,18,1,-72);elapsed.Size=UDim2.new(.25,0,0,14);elapsed.TextSize=6 end
  if duration then duration.Position=UDim2.new(.75,-18,1,-72);duration.Size=UDim2.new(.25,0,0,14);duration.TextSize=6 end
  if controls then controls.Position=UDim2.new(0,18,1,-50);controls.Size=UDim2.new(1,-36,0,34) end
  if mute then mute.LayoutOrder=1;mute.TextSize=8 end;if prev then prev.LayoutOrder=2;prev.TextSize=8 end;if nextB then nextB.LayoutOrder=3;nextB.TextSize=8 end
  if up then local title=up:FindFirstChild("Title");if title then title.TextSize=9;title.Position=UDim2.fromOffset(12,7);title.Size=UDim2.new(1,-24,0,20) end end
  if upList then upList.Position=UDim2.fromOffset(10,31);upList.Size=UDim2.new(1,-20,1,-40) end
  mini.Size=UDim2.new(.68,0,0,50);mini.Position=UDim2.new(.5,0,1,-10)
 else
  if status then status.Visible=true end
  if wave then wave.Visible=true end
  if navFav then navFav.Size=UDim2.new(1,0,0,36) end
  mini.Size=UDim2.fromOffset(380,54);mini.Position=UDim2.new(.5,0,1,-12)
 end
 applying=false
end

local cam=workspace.CurrentCamera
local function bindCamera()
 cam=workspace.CurrentCamera
 if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(apply);task.delay(.05,apply)end) end
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()bindCamera();task.defer(apply)end)
bindCamera()

gui:GetPropertyChangedSignal("Enabled"):Connect(function()
 if gui.Enabled then
  mini.Visible=false;task.defer(apply);task.delay(.06,apply);task.delay(.2,decorateLibraryRows)
 else
  task.defer(updateMini)
  if mini.Visible then mini.BackgroundTransparency=.45;TweenService:Create(mini,TweenInfo.new(.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=.07}):Play() end
 end
end)

local accum=0
RunService.RenderStepped:Connect(function(dt)
 accum+=dt;if accum<.08 then return end;accum=0
 local s=getSound();local loud=s and s.PlaybackLoudness or 0;local norm=math.clamp(loud/650,0,1)
 for i,b in ipairs(vizBars) do
  local pulse=.55+.45*(1-math.abs(i-10.5)/10.5)
  b.Size=UDim2.new(.026,0,0,3+math.floor(norm*18*pulse))
 end
 if gui.Enabled then
  decorateLibraryRows();polishQueue(upList,C.purple);polishQueue(queueList,C.gold)
 end
end)

if libList then libList.ChildAdded:Connect(function()task.defer(decorateLibraryRows)end) end
if upList then upList.ChildAdded:Connect(function()task.defer(function()polishQueue(upList,C.purple)end)end) end
if queueList then queueList.ChildAdded:Connect(function()task.defer(function()polishQueue(queueList,C.gold)end)end) end

task.defer(function()
 apply();decorateLibraryRows();refreshFavoritePage();updateMini();polishQueue(upList,C.purple);polishQueue(queueList,C.gold)
end)
task.delay(.3,function()apply();decorateLibraryRows()end)
task.delay(.9,function()apply();decorateLibraryRows()end)
print("[BBYA] Music Suite premium phase 3 active — hero / visualizer / favorites / queue polish / mini-player")
