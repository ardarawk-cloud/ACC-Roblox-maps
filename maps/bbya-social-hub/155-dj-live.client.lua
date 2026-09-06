-- BBYA SOCIAL HUB — DJ LIVE UI v6 FUNCTIONAL MIXER
-- Symmetric Deck A — Mixer — Deck B is preserved.
-- Venue selector is permanently visible below the header; timeline is driven by authoritative TimePosition/TimeLength, not decorative fake waveform bars.
-- BPM and FX state are read from the v6 server authority.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30);if not remotes then return end
local action=remotes:WaitForChild("DJLiveAction",20)
local stateRemote=remotes:WaitForChild("DJLiveState",20)
local getState=remotes:WaitForChild("DJLiveGetState",20)
local getLibrary=remotes:WaitForChild("DJLiveGetLibrary",20)
if not action or not stateRemote or not getState or not getLibrary then return end

local QA={nadmo97=true,arda_moron123=true}
local function allowed()
 local n=string.lower(player.Name)
 return QA[n]==true or player:GetAttribute("BBYAOwner")==true or(player:GetAttribute("BBYAHasDJRole")==true and player:GetAttribute("BBYAManagedRole")=="DJ")or(game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId)
end

local old=pg:FindFirstChild("BBYADJLiveCleanUI");if old then old:Destroy()end
local gui=Instance.new("ScreenGui")
gui.Name="BBYADJLiveCleanUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=false;gui.DisplayOrder=260;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Enabled=allowed();gui.Parent=pg
gui:SetAttribute("BBYAUIAuthority","DJ_LIVE_V6_FUNCTIONAL_MIXER")
gui:SetAttribute("BBYALayoutLock","SYMMETRIC_A_MIXER_B_VENUE_TOP_SAFE_V2")
gui:SetAttribute("BBYATimelineAuthority","TIMEPOSITION_TIMELENGTH_NO_FAKE_WAVEFORM")

local C={bg=Color3.fromRGB(7,7,10),panel=Color3.fromRGB(17,18,23),card=Color3.fromRGB(28,29,36),line=Color3.fromRGB(70,72,83),white=Color3.fromRGB(246,246,249),muted=Color3.fromRGB(155,158,170),pink=Color3.fromRGB(247,55,158),cyan=Color3.fromRGB(73,207,235),gold=Color3.fromRGB(220,171,92),green=Color3.fromRGB(92,224,151),black=Color3.fromRGB(8,8,11)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 9);c.Parent=o end
local function stroke(o,col,tr,th)local s=Instance.new("UIStroke");s.Color=col or C.line;s.Transparency=tr or .42;s.Thickness=th or 1;s.Parent=o;return s end
local function frame(p,name,pos,size,col,tr,r)local f=Instance.new("Frame");f.Name=name;f.Position=pos or UDim2.new();f.Size=size or UDim2.new();f.BackgroundColor3=col or C.panel;f.BackgroundTransparency=tr or .12;f.BorderSizePixel=0;f.Parent=p;corner(f,r or 10);stroke(f,C.line,.42);return f end
local function label(p,name,value,pos,size,font,ts,col,align)local l=Instance.new("TextLabel");l.Name=name;l.BackgroundTransparency=1;l.Text=tostring(value or"");l.Position=pos or UDim2.new();l.Size=size or UDim2.new();l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 9;l.TextColor3=col or C.white;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.TextTruncate=Enum.TextTruncate.AtEnd;l.Parent=p;return l end
local function button(p,name,value,pos,size,col)local b=Instance.new("TextButton");b.Name=name;b.Text=value;b.Position=pos or UDim2.new();b.Size=size or UDim2.new();b.BackgroundColor3=col or C.card;b.BackgroundTransparency=.06;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBlack;b.TextSize=9;b.AutoButtonColor=true;b.Active=true;b.Parent=p;corner(b,8);stroke(b,C.line,.46);return b end
local function activeButton(b,on,accent)b.BackgroundColor3=on and(accent or C.white)or C.card;b.TextColor3=on and C.black or C.white end
local function menuVisible(v)local k=pg:FindFirstChild("BBYACommandMenuUI");local m=k and k:FindFirstChild("MenuButton",true);if m then m.Visible=v end end
local function roleVisible(v)local g=pg:FindFirstChild("BBYARolePanelUI");local b=g and g:FindFirstChild("RolePanelOpen",true);if b then b.Visible=v end end
local function fmt(sec)sec=math.max(0,math.floor(tonumber(sec)or 0));return string.format("%02d:%02d",math.floor(sec/60),sec%60)end

local root=Instance.new("Frame")
root.Name="DJLivePanel";root.Size=UDim2.fromScale(1,1);root.BackgroundColor3=C.bg;root.BackgroundTransparency=.18;root.BorderSizePixel=0;root.Visible=false;root.Parent=gui

local header=frame(root,"Header",UDim2.fromOffset(8,8),UDim2.new(1,-16,0,46),C.panel,.08,10)
label(header,"Title","DJ LIVE",UDim2.fromOffset(14,2),UDim2.fromOffset(130,22),Enum.Font.GothamBlack,16,C.white)
local status=label(header,"Status","READY",UDim2.fromOffset(14,24),UDim2.new(1,-292,0,15),Enum.Font.GothamBold,8,C.muted)
local live=button(header,"Live","LIVE START",UDim2.new(1,-154,0,7),UDim2.fromOffset(100,32),C.card)
local close=button(header,"Close","×",UDim2.new(1,-46,0,7),UDim2.fromOffset(36,32),C.card);close.TextSize=18

-- Venue is deliberately top-safe, never a bottom footer that can be covered by mobile controls.
local venueBar=frame(root,"VenueBar",UDim2.fromOffset(8,60),UDim2.new(1,-16,0,40),C.panel,.08,10)
local mapButtons={}
for i,n in ipairs({"CLUB","VIP","UNDERGROUND","FUNKOT"})do
 local b=button(venueBar,n,n,UDim2.new((i-1)/4,6,0,4),UDim2.new(.25,-12,0,32),C.card);b.TextSize=n=="UNDERGROUND"and 7 or 9;mapButtons[n]=b;b.Activated:Connect(function()action:FireServer("map",{value=n})end)
end

local content=Instance.new("Frame");content.Name="DeckArea";content.BackgroundTransparency=1;content.Position=UDim2.fromOffset(8,108);content.Size=UDim2.new(1,-16,1,-116);content.Parent=root
local horizontal=Instance.new("UIListLayout");horizontal.FillDirection=Enum.FillDirection.Horizontal;horizontal.HorizontalAlignment=Enum.HorizontalAlignment.Center;horizontal.VerticalAlignment=Enum.VerticalAlignment.Center;horizontal.Padding=UDim.new(0,8);horizontal.SortOrder=Enum.SortOrder.LayoutOrder;horizontal.Parent=content

local state={authorized=false,live=false,map="CLUB",crossfader=.5,notice="READY",decks={A={},B={}}}
local library={};local refs={};local dialog=nil;local deckFrames={};local timelineSegs={A={},B={}};local meterBars={A={},B={}}

local function clearDialog()if dialog then dialog:Destroy();dialog=nil end end
local function modal(titleText)
 clearDialog();local shade=Instance.new("Frame");shade.Name="DialogShade";shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=C.black;shade.BackgroundTransparency=.34;shade.BorderSizePixel=0;shade.ZIndex=100;shade.Parent=root
 local box=frame(shade,"Dialog",UDim2.fromScale(.5,.52),UDim2.new(.76,0,.76,0),C.panel,.02,13);box.AnchorPoint=Vector2.new(.5,.5);box.ZIndex=101
 label(box,"DialogTitle",titleText,UDim2.fromOffset(16,8),UDim2.new(1,-62,0,28),Enum.Font.GothamBlack,15,C.white).ZIndex=102
 local x=button(box,"DialogClose","×",UDim2.new(1,-46,0,8),UDim2.fromOffset(32,30),C.card);x.ZIndex=103;x.Activated:Connect(clearDialog);dialog=shade;return box
end

local function openPlaylist(deck)
 local box=modal("PLAYLIST "..deck.." • "..tostring(state.map or"CLUB"))
 local search=Instance.new("TextBox");search.Name="Search";search.Position=UDim2.fromOffset(16,46);search.Size=UDim2.new(1,-32,0,34);search.BackgroundColor3=C.card;search.BorderSizePixel=0;search.PlaceholderText="Search track...";search.PlaceholderColor3=C.muted;search.Text="";search.TextColor3=C.white;search.Font=Enum.Font.Gotham;search.TextSize=10;search.ClearTextOnFocus=false;search.ZIndex=102;search.Parent=box;corner(search,8);stroke(search,C.line,.48)
 local list=Instance.new("ScrollingFrame");list.Name="TrackList";list.Position=UDim2.fromOffset(16,88);list.Size=UDim2.new(1,-32,1,-104);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.ScrollBarThickness=3;list.ScrollBarImageColor3=C.cyan;list.ZIndex=102;list.Parent=box
 local ll=Instance.new("UIListLayout");ll.Padding=UDim.new(0,5);ll.Parent=list
 local function render()
  for _,c in ipairs(list:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end
  local q=string.lower(search.Text or"");local count=0
  for _,t in ipairs(library)do
   if tostring(t.map)==tostring(state.map)then
    local blob=string.lower(tostring(t.title or"").." "..tostring(t.artist or""))
    if q==""or string.find(blob,q,1,true)then
     count+=1;local suffix=(tonumber(t.bpm)or 0)>0 and("   •   "..tostring(t.bpm).." BPM")or"";local r=button(list,"Track"..tostring(t.index),tostring(t.title)..suffix,nil,UDim2.new(1,-4,0,40),C.card);r.LayoutOrder=count;r.TextXAlignment=Enum.TextXAlignment.Left;r.TextSize=8;r.ZIndex=103
     local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,10);pad.PaddingRight=UDim.new(0,8);pad.Parent=r
     r.Activated:Connect(function()action:FireServer("load",{deck=deck,index=t.index});clearDialog()end)
    end
   end
  end
  if count==0 then local empty=label(list,"Empty","NO TRACKS FOR THIS VENUE",nil,UDim2.new(1,-4,0,40),Enum.Font.GothamBold,9,C.muted,Enum.TextXAlignment.Center);empty.LayoutOrder=1;empty.ZIndex=103 end
 end
 search:GetPropertyChangedSignal("Text"):Connect(render);render()
end

local function fxCount(deck)
 local d=type(state.decks)=="table"and state.decks[deck]or{};local fx=type(d.fx)=="table"and d.fx or{};local n=0;for _,name in ipairs({"ECHO","FILTER","REVERB","FLANGER"})do if fx[name]==true then n+=1 end end;return n
end
local function openFX(deck)
 local box=modal("DECK "..deck.." • FX")
 local names={"ECHO","FILTER","REVERB","FLANGER","HORN","AIRHORN","BRAKE","SIREN"};local d=type(state.decks)=="table"and state.decks[deck]or{};local active=type(d.fx)=="table"and d.fx or{}
 for i,name in ipairs(names)do
  local col=(i-1)%2;local row=math.floor((i-1)/2);local b=button(box,"FX"..name,name,UDim2.new(col*.5,16-col*4,0,54+row*58),UDim2.new(.5,-20,0,50),C.card);b.ZIndex=103
  if i<=4 then activeButton(b,active[name]==true,deck=="A"and C.pink or C.cyan)end
  b.Activated:Connect(function()if i<=4 then action:FireServer("fx_toggle",{deck=deck,fx=name});task.delay(.12,function()if dialog then clearDialog();openFX(deck)end end)else action:FireServer("sample",{deck=deck,fx=name})end end)
 end
end

local function createTimeline(parent,deck,accent)
 local w=frame(parent,"TrackTimeline",UDim2.fromOffset(10,60),UDim2.new(1,-20,0,56),C.black,.02,7);w.ClipsDescendants=true;w:SetAttribute("TimelineType","TIMEPOSITION_TIMELENGTH")
 label(w,"TimelineLabel","TRACK TIMELINE",UDim2.fromOffset(7,2),UDim2.new(1,-14,0,12),Enum.Font.GothamBold,6,C.muted)
 local strip=Instance.new("Frame");strip.Name="Segments";strip.BackgroundTransparency=1;strip.Position=UDim2.fromOffset(6,16);strip.Size=UDim2.new(1,-12,0,22);strip.ClipsDescendants=true;strip.Parent=w
 local segs={};local count=48
 for i=1,count do local b=Instance.new("Frame");b.AnchorPoint=Vector2.new(.5,.5);b.Position=UDim2.new((i-.5)/count,0,.5,0);b.Size=UDim2.new(1/count,-1,0,16);b.BackgroundColor3=accent;b.BackgroundTransparency=.78;b.BorderSizePixel=0;b.Parent=strip;segs[i]=b end
 local playhead=Instance.new("Frame");playhead.Name="Playhead";playhead.AnchorPoint=Vector2.new(.5,.5);playhead.Position=UDim2.new(0,0,.5,0);playhead.Size=UDim2.fromOffset(2,22);playhead.BackgroundColor3=C.white;playhead.BorderSizePixel=0;playhead.ZIndex=3;playhead.Parent=strip
 local elapsed=label(w,"Elapsed","00:00",UDim2.fromOffset(7,39),UDim2.fromOffset(52,13),Enum.Font.GothamBold,6,C.muted)
 local duration=label(w,"Duration","00:00",UDim2.new(1,-59,0,39),UDim2.fromOffset(52,13),Enum.Font.GothamBold,6,C.muted,Enum.TextXAlignment.Right)
 timelineSegs[deck]=segs;return{frame=w,strip=strip,playhead=playhead,elapsed=elapsed,duration=duration}
end

local function makeDeck(deck,order,accent)
 local f=frame(content,"Deck"..deck,nil,UDim2.new(0,300,1,0),C.panel,.10,11);f.LayoutOrder=order;deckFrames[deck]=f
 local playlist=button(f,"Playlist","PLAYLIST "..deck,UDim2.fromOffset(10,9),UDim2.fromOffset(82,44),C.card);playlist.TextWrapped=true;stroke(playlist,accent,.22);playlist.Activated:Connect(function()openPlaylist(deck)end)
 local title=label(f,"TrackTitle","EMPTY",UDim2.fromOffset(102,7),UDim2.new(1,-176,0,23),Enum.Font.GothamBlack,10,C.white)
 local artist=label(f,"Artist","",UDim2.fromOffset(102,30),UDim2.new(1,-176,0,16),Enum.Font.Gotham,7,C.muted)
 local bpm=label(f,"BPM","BPM ?",UDim2.new(1,-70,0,12),UDim2.fromOffset(60,18),Enum.Font.GothamBold,7,C.white,Enum.TextXAlignment.Right)
 local timeline=createTimeline(f,deck,accent)
 local jog=Instance.new("Frame");jog.Name="Jog";jog.AnchorPoint=Vector2.new(.5,.5);jog.Position=UDim2.new(.5,0,.57,0);jog.Size=UDim2.fromOffset(108,108);jog.BackgroundColor3=C.black;jog.BorderSizePixel=0;jog.Parent=f;corner(jog,54);local js=stroke(jog,accent,.10,2)
 local ring=Instance.new("Frame");ring.AnchorPoint=Vector2.new(.5,.5);ring.Position=UDim2.fromScale(.5,.5);ring.Size=UDim2.new(.60,0,.60,0);ring.BackgroundTransparency=1;ring.Parent=jog;corner(ring,100);stroke(ring,C.line,.20,2)
 local needle=Instance.new("Frame");needle.Name="Needle";needle.AnchorPoint=Vector2.new(.5,1);needle.Position=UDim2.fromScale(.5,.5);needle.Size=UDim2.fromOffset(3,36);needle.BackgroundColor3=accent;needle.BorderSizePixel=0;needle.Parent=jog;corner(needle,2)
 local center=Instance.new("Frame");center.AnchorPoint=Vector2.new(.5,.5);center.Position=UDim2.fromScale(.5,.5);center.Size=UDim2.fromOffset(9,9);center.BackgroundColor3=C.white;center.BorderSizePixel=0;center.Parent=jog;corner(center,5)
 local cue=button(f,"Cue","CUE",UDim2.new(0,10,1,-84),UDim2.fromOffset(76,34),C.card)
 local play=button(f,"Play","PLAY",UDim2.new(0,10,1,-42),UDim2.fromOffset(76,34),C.card)
 local fx=button(f,"FX","FX",UDim2.new(1,-86,1,-84),UDim2.fromOffset(76,34),C.card)
 local sync=button(f,"Sync","SYNC",UDim2.new(1,-86,1,-42),UDim2.fromOffset(76,34),C.card)
 stroke(play,accent,.24);stroke(sync,accent,.38)
 cue.Activated:Connect(function()action:FireServer("cue",{deck=deck})end);play.Activated:Connect(function()action:FireServer("play_toggle",{deck=deck})end);fx.Activated:Connect(function()openFX(deck)end);sync.Activated:Connect(function()action:FireServer("sync",{deck=deck})end)
 refs[deck]={title=title,artist=artist,bpm=bpm,play=play,cue=cue,fx=fx,sync=sync,jog=jog,needle=needle,jogStroke=js,accent=accent,rotation=0,timeline=timeline}
 return f
end

local deckA=makeDeck("A",1,C.pink)
local mixer=frame(content,"Mixer",nil,UDim2.new(0,116,1,0),C.panel,.08,11);mixer.LayoutOrder=2
local deckB=makeDeck("B",3,C.cyan)
label(mixer,"MixerTitle","MIXER",UDim2.fromOffset(8,8),UDim2.new(1,-16,0,20),Enum.Font.GothamBlack,10,C.white,Enum.TextXAlignment.Center)
local meters=Instance.new("Frame");meters.Name="Meters";meters.Position=UDim2.fromOffset(18,38);meters.Size=UDim2.new(1,-36,1,-126);meters.BackgroundTransparency=1;meters.Parent=mixer
for i=1,14 do for side,deck in ipairs({"A","B"})do local b=Instance.new("Frame");b.AnchorPoint=Vector2.new(0,1);b.Position=UDim2.new(side==1 and 0 or .56,0,1,-(i-1)*8);b.Size=UDim2.new(.40,0,0,6);b.BackgroundColor3=side==1 and C.pink or C.cyan;b.BackgroundTransparency=.78;b.BorderSizePixel=0;b.Parent=meters;corner(b,2);meterBars[deck][i]=b end end
local rail=Instance.new("Frame");rail.Name="CrossfaderRail";rail.Position=UDim2.new(0,14,1,-60);rail.Size=UDim2.new(1,-28,0,5);rail.BackgroundColor3=C.line;rail.BorderSizePixel=0;rail.Parent=mixer;corner(rail,3)
local thumb=Instance.new("Frame");thumb.Name="CrossfaderThumb";thumb.AnchorPoint=Vector2.new(.5,.5);thumb.Position=UDim2.new(.5,0,.5,0);thumb.Size=UDim2.fromOffset(17,17);thumb.BackgroundColor3=C.white;thumb.BorderSizePixel=0;thumb.Parent=rail;corner(thumb,9)
local hit=Instance.new("TextButton");hit.Name="CrossfaderHit";hit.BackgroundTransparency=1;hit.Text="";hit.Position=UDim2.new(0,-8,0,-10);hit.Size=UDim2.new(1,16,0,25);hit.Parent=rail
label(mixer,"CrossLabel","CROSSFADER",UDim2.new(0,6,1,-37),UDim2.new(1,-12,0,14),Enum.Font.GothamBold,7,C.muted,Enum.TextXAlignment.Center)
local dragging=false
local function cross(x)local p=math.clamp((x-rail.AbsolutePosition.X)/math.max(1,rail.AbsoluteSize.X),0,1);thumb.Position=UDim2.new(p,0,.5,0);action:FireServer("crossfader",{value=p})end
hit.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;cross(i.Position.X)end end)
UserInputService.InputChanged:Connect(function(i)if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then cross(i.Position.X)end end)
UserInputService.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)

local function deckSound(deck)local e=SoundService:FindFirstChild("BBYADJLiveV6Engine");local s=e and e:FindFirstChild("Deck"..deck);return s and s:IsA("Sound")and s or nil end
local function updateTimeline(deck,d)
 local r=refs[deck];if not r then return end;local t=r.timeline;local len=tonumber(d.timeLength)or 0;local pos=tonumber(d.timePosition)or 0;local p=len>0 and math.clamp(pos/len,0,1)or 0
 t.playhead.Position=UDim2.new(p,0,.5,0);t.elapsed.Text=fmt(pos);t.duration.Text=fmt(len)
 local segs=timelineSegs[deck];local played=math.floor(p*#segs+.5);for i,b in ipairs(segs)do b.BackgroundTransparency=i<=played and .16 or .78 end
end
local function applyState(s)
 if type(s)~="table"or s.authorized~=true then return end
 state=s;local notice=tostring(s.notice or"READY");status.Text=(s.live and("LIVE • "..tostring(s.map))or"READY")..(notice~=""and(" • "..notice)or"");status.TextColor3=s.live and C.green or C.muted
 live.Text=s.live and"LIVE STOP"or"LIVE START";activeButton(live,s.live,C.green)
 thumb.Position=UDim2.new(math.clamp(tonumber(s.crossfader)or.5,0,1),0,.5,0)
 for n,b in pairs(mapButtons)do activeButton(b,n==s.map,n=="VIP"and C.gold or(n=="FUNKOT"and Color3.fromRGB(171,95,244)or(n=="UNDERGROUND"and C.cyan or C.pink)))end
 for _,deck in ipairs({"A","B"})do
  local d=type(s.decks)=="table"and s.decks[deck]or{};local r=refs[deck];r.title.Text=tostring(d.title or"EMPTY");r.artist.Text=(d.assetId and tonumber(d.assetId)>0)and("ASSET "..tostring(d.assetId))or""
  local bpm=tonumber(d.bpm)or 0;r.bpm.Text=bpm>0 and(string.format("%.0f BPM",bpm))or"BPM ?";r.bpm.TextColor3=bpm>0 and C.white or C.gold
  r.play.Text=d.playing and"PAUSE"or"PLAY";activeButton(r.play,d.playing,r.accent);r.jogStroke.Color=d.playing and r.accent or C.line
  local nfx=0;for _,name in ipairs({"ECHO","FILTER","REVERB","FLANGER"})do if type(d.fx)=="table"and d.fx[name]==true then nfx+=1 end end;r.fx.Text=nfx>0 and("FX • "..nfx)or"FX";activeButton(r.fx,nfx>0,r.accent);updateTimeline(deck,d)
 end
end

local function refreshRemote()
 if not allowed()then gui.Enabled=false;root.Visible=false;return end
 gui.Enabled=true
 local okS,s=pcall(function()return getState:InvokeServer()end);if okS and type(s)=="table"then applyState(s)end
 local okL,l=pcall(function()return getLibrary:InvokeServer()end);if okL and type(l)=="table"then library=l end
end

live.Activated:Connect(function()if state.live then action:FireServer("live_stop",{})else action:FireServer("live_start",{})end end)
close.Activated:Connect(function()clearDialog();root.Visible=false end)
root:GetPropertyChangedSignal("Visible"):Connect(function()if root.Visible then menuVisible(false);roleVisible(false);refreshRemote()else clearDialog();menuVisible(true);roleVisible(true)end end)
stateRemote.OnClientEvent:Connect(function(s)if type(s)=="table"then applyState(s)end end)

local camera=workspace.CurrentCamera
local function layout()
 camera=workspace.CurrentCamera or camera;local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 local cw=math.max(430,vp.X-16);local mixerW=math.clamp(math.floor(cw*.13),92,122);local deckW=math.max(150,math.floor((cw-mixerW-16)/2));local ch=math.max(250,vp.Y-116)
 deckA.Size=UDim2.fromOffset(deckW,ch);deckB.Size=UDim2.fromOffset(deckW,ch);mixer.Size=UDim2.fromOffset(mixerW,ch)
 local jogSize=math.clamp(math.floor(math.min(deckW*.32,ch*.28)),76,118);for _,deck in ipairs({"A","B"})do local r=refs[deck];r.jog.Size=UDim2.fromOffset(jogSize,jogSize)end
end
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)end;layout()end)

local acc=0
RunService.RenderStepped:Connect(function(dt)
 if not root.Visible then return end;acc+=dt;if acc<.08 then return end;acc=0
 for _,deck in ipairs({"A","B"})do
  local s=deckSound(deck);local loud=s and math.clamp((s.PlaybackLoudness or 0)/520,0,1)or 0;local r=refs[deck]
  if s and s.IsPlaying then r.rotation=(r.rotation+7)%360;r.needle.Rotation=r.rotation end
  for i,b in ipairs(meterBars[deck])do b.BackgroundTransparency=i<=math.ceil(loud*#meterBars[deck])and.08 or.78 end
  -- Timeline follows local deck clock between server snapshots; it never invents waveform amplitude.
  if s then updateTimeline(deck,{timePosition=s.TimePosition,timeLength=s.TimeLength})end
 end
end)

local function authRefresh()gui.Enabled=allowed();if not gui.Enabled then root.Visible=false end end
player:GetAttributeChangedSignal("BBYAHasDJRole"):Connect(authRefresh);player:GetAttributeChangedSignal("BBYAManagedRole"):Connect(authRefresh);player:GetAttributeChangedSignal("BBYAOwner"):Connect(authRefresh)
task.defer(function()layout();refreshRemote();root.Visible=false end)
print("[BBYA] DJ LIVE UI v6 online: venue top-safe / real track timeline / BPM state / functional FX state / symmetric mixer preserved")