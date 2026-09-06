-- BBYA SOCIAL HUB — DJ LIVE CLEAN UI v3
-- Runtime rebuild: A/B badge IS the playlist button. No bottom playlist bar can cover PLAY/SYNC.
-- Waveform occupies the upper empty deck area. CUE over PLAY; FX over SYNC; jog remains centered.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
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
local function allowed()local n=string.lower(player.Name);return QA[n]==true or player:GetAttribute("BBYAOwner")==true or(player:GetAttribute("BBYAHasDJRole")==true and player:GetAttribute("BBYAManagedRole")=="DJ")or(game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId)end
local old=pg:FindFirstChild("BBYADJLiveCleanUI");if old then old:Destroy()end
local gui=Instance.new("ScreenGui");gui.Name="BBYADJLiveCleanUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=false;gui.DisplayOrder=260;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg;gui.Enabled=allowed();gui:SetAttribute("BBYAFeature","DJ_LIVE");gui:SetAttribute("BBYAUIAuthority","DJ_LIVE_V3_PLAYLIST_BADGE")
local C={bg=Color3.fromRGB(7,7,9),panel=Color3.fromRGB(18,18,22),card=Color3.fromRGB(28,28,34),line=Color3.fromRGB(68,69,78),white=Color3.fromRGB(245,245,248),muted=Color3.fromRGB(158,160,171),active=Color3.fromRGB(244,244,246),black=Color3.fromRGB(9,9,11),gold=Color3.fromRGB(220,171,92),red=Color3.fromRGB(218,77,92)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 9);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col or C.line;s.Thickness=1;s.Transparency=tr or .3;s.Parent=o end
local function label(p,v,pos,size,font,ts,col,align)local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=tostring(v or"");l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 10;l.TextColor3=col or C.white;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.TextTruncate=Enum.TextTruncate.AtEnd;l.Parent=p;return l end
local function button(p,v,pos,size,col)local b=Instance.new("TextButton");b.Text=v;b.Position=pos or UDim2.new();b.Size=size or UDim2.new();b.BackgroundColor3=col or C.card;b.BackgroundTransparency=.08;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBlack;b.TextSize=10;b.AutoButtonColor=true;b.Parent=p;corner(b,9);stroke(b,C.line,.45);return b end
local function frame(p,pos,size,col,r)local f=Instance.new("Frame");f.Position=pos;f.Size=size;f.BackgroundColor3=col or C.panel;f.BackgroundTransparency=.14;f.BorderSizePixel=0;f.Parent=p;corner(f,r or 10);stroke(f,C.line,.36);return f end
local function setActive(b,on)b.BackgroundColor3=on and C.active or C.card;b.TextColor3=on and C.black or C.white end
local function kernelMenuVisible(v)local k=pg:FindFirstChild("BBYACommandMenuUI");local m=k and k:FindFirstChild("MenuButton",true);if m then m.Visible=v end end

local root=Instance.new("Frame");root.Name="DJLivePanel";root.Size=UDim2.fromScale(1,1);root.BackgroundColor3=C.bg;root.BackgroundTransparency=.22;root.BorderSizePixel=0;root.Visible=false;root.Parent=gui
local header=frame(root,UDim2.fromOffset(8,8),UDim2.new(1,-16,0,48),C.panel,10)
label(header,"DJ LIVE",UDim2.fromOffset(14,3),UDim2.fromOffset(120,22),Enum.Font.GothamBlack,16,C.white)
local status=label(header,"READY",UDim2.fromOffset(14,25),UDim2.fromOffset(300,16),Enum.Font.GothamBold,8,C.muted)
local close=button(header,"×",UDim2.new(1,-46,0,8),UDim2.fromOffset(36,32),C.card);close.TextSize=19
local live=button(header,"LIVE START",UDim2.new(1,-154,0,8),UDim2.fromOffset(100,32),C.card)
local content=Instance.new("Frame");content.BackgroundTransparency=1;content.Position=UDim2.fromOffset(8,64);content.Size=UDim2.new(1,-16,1,-126);content.Parent=root
local footer=frame(root,UDim2.new(0,8,1,-54),UDim2.new(1,-16,0,46),C.panel,10)

local state={authorized=false,live=false,map="CLUB",crossfader=.5,decks={A={},B={}}};local library={};local deckRefs={};local mapButtons={};local dialog=nil
local function clearDialog()if dialog then dialog:Destroy();dialog=nil end end
local function modal(titleText)
 clearDialog();local shade=Instance.new("Frame");shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=Color3.new(0,0,0);shade.BackgroundTransparency=.45;shade.ZIndex=100;shade.Parent=root
 local box=frame(shade,UDim2.fromScale(.5,.52),UDim2.new(.72,0,.72,0),C.panel,14);box.AnchorPoint=Vector2.new(.5,.5);box.ZIndex=101
 label(box,titleText,UDim2.fromOffset(16,8),UDim2.new(1,-62,0,28),Enum.Font.GothamBlack,16,C.white).ZIndex=102
 local x=button(box,"×",UDim2.new(1,-46,0,8),UDim2.fromOffset(32,30),C.card);x.TextSize=18;x.ZIndex=103;x.Activated:Connect(clearDialog);dialog=shade;return box
end
local function openPlaylist(deck)
 local box=modal("PLAYLIST "..deck);local search=Instance.new("TextBox");search.Position=UDim2.fromOffset(16,46);search.Size=UDim2.new(1,-32,0,34);search.BackgroundColor3=C.card;search.BorderSizePixel=0;search.PlaceholderText="Search track...";search.Text="";search.TextColor3=C.white;search.PlaceholderColor3=C.muted;search.Font=Enum.Font.Gotham;search.TextSize=10;search.ClearTextOnFocus=false;search.ZIndex=102;search.Parent=box;corner(search,8)
 local list=Instance.new("ScrollingFrame");list.Position=UDim2.fromOffset(16,88);list.Size=UDim2.new(1,-32,1,-104);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.ScrollBarThickness=3;list.ZIndex=102;list.Parent=box;local ll=Instance.new("UIListLayout");ll.Padding=UDim.new(0,5);ll.Parent=list
 local function render()for _,c in ipairs(list:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end;local q=string.lower(search.Text or"");for _,t in ipairs(library)do local blob=string.lower(tostring(t.title or"").." "..tostring(t.artist or"").." "..tostring(t.map or""));if q==""or string.find(blob,q,1,true)then local r=button(list,tostring(t.title).."  •  "..tostring(t.artist or""),nil,UDim2.new(1,-4,0,42),C.card);r.TextXAlignment=Enum.TextXAlignment.Left;r.TextSize=9;r.ZIndex=103;r.Activated:Connect(function()action:FireServer("load",{deck=deck,index=t.index});clearDialog()end)end end end
 search:GetPropertyChangedSignal("Text"):Connect(render);render()
end
local function openFX(deck)
 local box=modal("DECK "..deck.." • FX");for i,name in ipairs({"ECHO","FILTER","REVERB","FLANGER","HORN","AIRHORN","BRAKE","SIREN"})do local col=(i-1)%2;local row=math.floor((i-1)/2);local b=button(box,name,UDim2.new(col*.5,16-col*4,0,52+row*58),UDim2.new(.5,-20,0,50),C.card);b.ZIndex=103;b.Activated:Connect(function()if i<=4 then action:FireServer("fx_toggle",{deck=deck,fx=name})else action:FireServer("sample",{deck=deck,fx=name})end end)end
end
local function waveform(parent)local h=Instance.new("Frame");h.BackgroundTransparency=1;h.Size=UDim2.fromScale(1,1);h.Parent=parent;for i=1,42 do local b=Instance.new("Frame");b.AnchorPoint=Vector2.new(.5,.5);b.Position=UDim2.new((i-.5)/42,0,.5,0);b.Size=UDim2.new(0,2,0,6+((i*13)%24));b.BackgroundColor3=C.white;b.BackgroundTransparency=.48;b.BorderSizePixel=0;b.Parent=h end end
local function makeDeck(deck,isLeft)
 local accent=isLeft and Color3.fromRGB(247,55,158)or Color3.fromRGB(73,207,235)
 local f=frame(content,isLeft and UDim2.new(0,0,0,0)or UDim2.new(.5,78,0,0),UDim2.new(.5,-78,1,0),C.panel,12)
 local playlist=button(f,deck.."\nPLAYLIST",UDim2.fromOffset(10,10),UDim2.fromOffset(72,52),C.card);playlist.TextSize=10;playlist.TextWrapped=true;playlist.Activated:Connect(function()openPlaylist(deck)end)
 local title=label(f,"EMPTY",UDim2.fromOffset(92,8),UDim2.new(1,-164,0,24),Enum.Font.GothamBlack,12,C.white)
 local artist=label(f,"",UDim2.fromOffset(92,30),UDim2.new(1,-164,0,16),Enum.Font.Gotham,8,C.muted)
 local bpm=label(f,"-- BPM",UDim2.new(1,-72,0,12),UDim2.fromOffset(62,20),Enum.Font.GothamBold,9,C.white,Enum.TextXAlignment.Right)
 local wave=frame(f,UDim2.fromOffset(10,70),UDim2.new(1,-20,0,46),C.black,7);wave.ClipsDescendants=true;waveform(wave)
 local cue=button(f,"CUE",UDim2.fromOffset(10,128),UDim2.fromOffset(62,34),C.card)
 local play=button(f,"PLAY",UDim2.fromOffset(10,170),UDim2.fromOffset(62,34),C.card)
 local fx=button(f,"FX",UDim2.new(1,-72,0,128),UDim2.fromOffset(62,34),C.active);fx.TextColor3=C.black
 local sync=button(f,"SYNC",UDim2.new(1,-72,0,170),UDim2.fromOffset(62,34),C.card)
 local jog=Instance.new("Frame");jog.AnchorPoint=Vector2.new(.5,.5);jog.Position=UDim2.new(.5,0,.70,0);jog.Size=UDim2.fromOffset(100,100);jog.BackgroundColor3=C.black;jog.BorderSizePixel=0;jog.Parent=f;corner(jog,50);local js=Instance.new("UIStroke");js.Color=C.line;js.Thickness=2;js.Parent=jog;local inner=Instance.new("Frame");inner.AnchorPoint=Vector2.new(.5,.5);inner.Position=UDim2.fromScale(.5,.5);inner.Size=UDim2.fromOffset(58,58);inner.BackgroundTransparency=1;inner.Parent=jog;corner(inner,29);stroke(inner,C.line,.2);local dot=Instance.new("Frame");dot.AnchorPoint=Vector2.new(.5,.5);dot.Position=UDim2.fromScale(.5,.5);dot.Size=UDim2.fromOffset(7,7);dot.BackgroundColor3=C.white;dot.BorderSizePixel=0;dot.Parent=jog;corner(dot,4)
 cue.Activated:Connect(function()action:FireServer("cue",{deck=deck})end);play.Activated:Connect(function()action:FireServer("play_toggle",{deck=deck})end);sync.Activated:Connect(function()action:FireServer("sync",{deck=deck})end);fx.Activated:Connect(function()openFX(deck)end)
 deckRefs[deck]={title=title,artist=artist,bpm=bpm,play=play,jog=jog,jogStroke=js,rotation=0,accent=accent}
end
makeDeck("A",true);makeDeck("B",false)
local mixer=frame(content,UDim2.new(.5,-66,0,0),UDim2.new(0,132,1,0),C.panel,12);label(mixer,"MIXER",UDim2.fromOffset(8,8),UDim2.new(1,-16,0,20),Enum.Font.GothamBlack,10,C.white,Enum.TextXAlignment.Center)
local meter=Instance.new("Frame");meter.Position=UDim2.fromOffset(18,38);meter.Size=UDim2.new(1,-36,1,-132);meter.BackgroundTransparency=1;meter.Parent=mixer;local meterA,meterB={},{}
for i=1,12 do for side,tbl in ipairs({meterA,meterB})do local b=Instance.new("Frame");b.AnchorPoint=Vector2.new(0,1);b.Position=UDim2.new(side==1 and 0 or .58,0,1,-(i-1)*8);b.Size=UDim2.new(.40,0,0,6);b.BackgroundColor3=C.white;b.BackgroundTransparency=.78;b.BorderSizePixel=0;b.Parent=meter;corner(b,2);tbl[i]=b end end
local rail=Instance.new("Frame");rail.Position=UDim2.new(0,14,1,-62);rail.Size=UDim2.new(1,-28,0,5);rail.BackgroundColor3=C.line;rail.BorderSizePixel=0;rail.Parent=mixer;corner(rail,3)
local thumb=Instance.new("Frame");thumb.AnchorPoint=Vector2.new(.5,.5);thumb.Position=UDim2.new(.5,0,.5,0);thumb.Size=UDim2.fromOffset(16,16);thumb.BackgroundColor3=C.white;thumb.BorderSizePixel=0;thumb.Parent=rail;corner(thumb,8)
local hit=Instance.new("TextButton");hit.BackgroundTransparency=1;hit.Text="";hit.Position=UDim2.new(0,-8,0,-10);hit.Size=UDim2.new(1,16,0,25);hit.Parent=rail;local dragging=false
local function sendCross(x)local p=math.clamp((x-rail.AbsolutePosition.X)/math.max(1,rail.AbsoluteSize.X),0,1);thumb.Position=UDim2.new(p,0,.5,0);action:FireServer("crossfader",{value=p})end
hit.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;sendCross(i.Position.X)end end);UserInputService.InputChanged:Connect(function(i)if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then sendCross(i.Position.X)end end);UserInputService.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
label(mixer,"CROSSFADER",UDim2.new(0,8,1,-38),UDim2.new(1,-16,0,14),Enum.Font.GothamBold,7,C.muted,Enum.TextXAlignment.Center)
for i,name in ipairs({"CLUB","VIP","UNDERGROUND","FUNKOT"})do local b=button(footer,name,UDim2.new((i-1)/4,6,0,6),UDim2.new(.25,-12,0,34),C.card);b.TextSize=name=="UNDERGROUND"and 8 or 10;mapButtons[name]=b;b.Activated:Connect(function()action:FireServer("map",{value=name})end)end
local function applyState(s)if type(s)~="table"or s.authorized~=true then return end;state=s;status.Text=tostring(s.notice or(s.live and("LIVE • "..tostring(s.map))or"READY"));live.Text=s.live and"LIVE • STOP"or"LIVE START";setActive(live,s.live==true);for m,b in pairs(mapButtons)do setActive(b,m==s.map)end;thumb.Position=UDim2.new(math.clamp(tonumber(s.crossfader)or .5,0,1),0,.5,0);for deck,r in pairs(deckRefs)do local d=s.decks and s.decks[deck]or{};r.title.Text=tostring(d.title or"EMPTY");r.artist.Text=tostring(d.artist or"");local bpm=tonumber(d.bpm)or 0;r.bpm.Text=(bpm>0 and tostring(bpm)or"--").." BPM";r.play.Text=d.playing and"PAUSE"or"PLAY";r.jogStroke.Color=d.playing and r.accent or C.line end end
stateRemote.OnClientEvent:Connect(applyState);live.Activated:Connect(function()if state.live then action:FireServer("live_stop",{})else action:FireServer("live_start",{})end end)
local function closePanel()root.Visible=false;clearDialog();kernelMenuVisible(true)end;close.Activated:Connect(closePanel)
root:GetPropertyChangedSignal("Visible"):Connect(function()if root.Visible then if not allowed()then root.Visible=false;return end;kernelMenuVisible(false)else kernelMenuVisible(true)end end)
local function refreshAuth()gui.Enabled=allowed();if not gui.Enabled then closePanel();return end;local okS,s=pcall(function()return getState:InvokeServer()end);if okS then applyState(s)end;local okL,l=pcall(function()return getLibrary:InvokeServer()end);if okL and type(l)=="table"then library=l end end
player:GetAttributeChangedSignal("BBYAHasDJRole"):Connect(refreshAuth);player:GetAttributeChangedSignal("BBYAManagedRole"):Connect(refreshAuth);player:GetAttributeChangedSignal("BBYAOwner"):Connect(refreshAuth)
local t=0;RunService.RenderStepped:Connect(function(dt)if not root.Visible then return end;t+=dt;for deck,r in pairs(deckRefs)do local d=state.decks and state.decks[deck];if d and d.playing then r.rotation=(r.rotation+dt*70)%360;r.jog.Rotation=r.rotation end end;for i,b in ipairs(meterA)do b.BackgroundTransparency=(state.live and state.decks.A and state.decks.A.playing and i<=6+math.floor(5*math.abs(math.sin(t*4))))and .06 or .78 end;for i,b in ipairs(meterB)do b.BackgroundTransparency=(state.live and state.decks.B and state.decks.B.playing and i<=6+math.floor(5*math.abs(math.sin(t*4.3+1))))and .06 or .78 end end)
task.defer(refreshAuth)
print("[BBYA] DJ LIVE v3 online: playlist on A/B badge / PLAY+SYNC unobstructed / waveform upper deck")