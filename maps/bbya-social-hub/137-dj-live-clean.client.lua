-- BBYA SOCIAL HUB — DJ LIVE CLEAN UI v2.3 RUNTIME PRECISION
-- Compact control surface. BBYA MENU is the only entry point.
-- Access: managed DJ role + explicit owner/QA identities; QA does not receive the managed DJ role.
-- Runtime QC lock: Roblox top-bar safe, Deck A/B mirrored around mixer, CUE over PLAY and FX over SYNC.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")

local QA_USERNAMES={nadmo97=true,arda_moron123=true}
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
if not remotes then return end
local action=remotes:WaitForChild("DJLiveAction",20)
local stateRemote=remotes:WaitForChild("DJLiveState",20)
local getState=remotes:WaitForChild("DJLiveGetState",20)
local getLibrary=remotes:WaitForChild("DJLiveGetLibrary",20)
if not action or not stateRemote or not getState or not getLibrary then return end

local old=pg:FindFirstChild("BBYADJLiveCleanUI");if old then old:Destroy() end
local gui=Instance.new("ScreenGui")
gui.Name="BBYADJLiveCleanUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=false;gui.DisplayOrder=260;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
gui:SetAttribute("BBYAFeature","DJ_LIVE");gui:SetAttribute("LauncherRetired",true);gui:SetAttribute("RoleRequired","DJ_OR_OWNER_QA");gui:SetAttribute("SafeTopBar",true)

local C={BG=Color3.fromRGB(7,7,9),PANEL=Color3.fromRGB(18,18,22),CARD=Color3.fromRGB(28,28,34),LINE=Color3.fromRGB(68,69,78),WHITE=Color3.fromRGB(245,245,248),MUTED=Color3.fromRGB(158,160,171),ACTIVE=Color3.fromRGB(244,244,246),BLACK=Color3.fromRGB(9,9,11),GOLD=Color3.fromRGB(220,171,92),RED=Color3.fromRGB(218,77,92)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 9);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col or C.LINE;s.Thickness=1;s.Transparency=tr or .25;s.Parent=o end
local function label(parent,value,pos,size,font,ts,color,align)local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=tostring(value or "");l.Position=pos or UDim2.new();l.Size=size or UDim2.new();l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 11;l.TextColor3=color or C.WHITE;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.TextTruncate=Enum.TextTruncate.AtEnd;l.Parent=parent;return l end
local function button(parent,value,pos,size,color)local b=Instance.new("TextButton");b.Text=tostring(value or "");b.Position=pos or UDim2.new();b.Size=size or UDim2.new();b.BackgroundColor3=color or C.CARD;b.BackgroundTransparency=.10;b.BorderSizePixel=0;b.TextColor3=C.WHITE;b.Font=Enum.Font.GothamBold;b.TextSize=10;b.AutoButtonColor=true;b.Parent=parent;corner(b,8);stroke(b,C.LINE,.45);return b end
local function setActive(b,on)b.BackgroundColor3=on and C.ACTIVE or C.CARD;b.BackgroundTransparency=on and .03 or .10;b.TextColor3=on and C.BLACK or C.WHITE end
local function frame(parent,pos,size,color,r)local f=Instance.new("Frame");f.Position=pos or UDim2.new();f.Size=size or UDim2.new();f.BackgroundColor3=color or C.PANEL;f.BackgroundTransparency=.16;f.BorderSizePixel=0;f.Parent=parent;corner(f,r or 10);stroke(f,C.LINE,.35);return f end

local root=Instance.new("Frame")
root.Name="DJLivePanel";root.Size=UDim2.fromScale(1,1);root.BackgroundColor3=C.BG;root.BackgroundTransparency=.24;root.BorderSizePixel=0;root.Visible=false;root.Parent=gui
root:SetAttribute("BBYAOuterLayoutAuthority","DJ_LIVE_CLEAN_V2_3_RUNTIME_PRECISION")

local header=frame(root,UDim2.fromOffset(8,8),UDim2.new(1,-16,0,48),C.PANEL,10)
label(header,"DJ LIVE",UDim2.fromOffset(14,4),UDim2.fromOffset(120,20),Enum.Font.GothamBlack,16,C.WHITE)
local status=label(header,"DJ LIVE • READY",UDim2.fromOffset(14,24),UDim2.fromOffset(260,16),Enum.Font.GothamBold,8,C.MUTED)
local close=button(header,"×",UDim2.new(1,-46,0,8),UDim2.fromOffset(36,32),C.CARD);close.TextSize=19;close.ZIndex=20
local live=button(header,"LIVE START",UDim2.new(1,-152,0,8),UDim2.fromOffset(98,32),C.CARD)

local content=Instance.new("Frame");content.BackgroundTransparency=1;content.Position=UDim2.fromOffset(8,64);content.Size=UDim2.new(1,-16,1,-126);content.Parent=root
local footer=frame(root,UDim2.new(0,8,1,-54),UDim2.new(1,-16,0,46),C.PANEL,10)

local state={authorized=false,live=false,map="CLUB",crossfader=.5,decks={A={},B={}}}
local library={};local deckRefs={};local mapButtons={};local dialog=nil
local function isOwnerQA()local name=string.lower(player.Name);return QA_USERNAMES[name]==true or player:GetAttribute("BBYAOwner")==true or (game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId) end
local function hasManagedDJ()return player:GetAttribute("BBYAHasDJRole")==true and player:GetAttribute("BBYAManagedRole")=="DJ" end
local function accessAllowed()return isOwnerQA() or hasManagedDJ() end
local function readyLabel()return isOwnerQA() and "OWNER QA • READY" or "DJ ROLE • READY" end
local function kernelMenuVisible(visible)local k=pg:FindFirstChild("BBYACommandMenuUI");local m=k and k:FindFirstChild("MenuButton",true);if m and m:IsA("GuiObject") then m.Visible=visible;if m:IsA("TextButton") then m.Text="MENU" end end end
local function closePanel()root.Visible=false;if dialog then dialog:Destroy();dialog=nil end;kernelMenuVisible(true)end
close.Activated:Connect(closePanel)
root:GetPropertyChangedSignal("Visible"):Connect(function()if root.Visible then if not accessAllowed() then root.Visible=false;return end;kernelMenuVisible(false) else kernelMenuVisible(true) end end)

local function waveform(parent)local h=Instance.new("Frame");h.BackgroundTransparency=1;h.ClipsDescendants=true;h.Size=UDim2.fromScale(1,1);h.Parent=parent;for i=1,36 do local bar=Instance.new("Frame");bar.AnchorPoint=Vector2.new(.5,.5);bar.Position=UDim2.new((i-.5)/36,0,.5,0);bar.Size=UDim2.fromOffset(2,6+((i*13)%20));bar.BackgroundColor3=C.WHITE;bar.BackgroundTransparency=.52;bar.BorderSizePixel=0;bar.Parent=h end end
local function makeDeck(deck,left)
 local f=frame(content,left and UDim2.new(0,0,0,0) or UDim2.new(.5,78,0,0),UDim2.new(.5,-78,1,0),C.PANEL,12)
 local badge=frame(f,UDim2.fromOffset(10,10),UDim2.fromOffset(34,34),C.CARD,7);label(badge,deck,UDim2.new(),UDim2.fromScale(1,1),Enum.Font.GothamBlack,16,C.WHITE,Enum.TextXAlignment.Center)
 local title=label(f,"EMPTY",UDim2.fromOffset(52,7),UDim2.new(1,-116,0,22),Enum.Font.GothamBold,13,C.WHITE);local artist=label(f,"",UDim2.fromOffset(52,28),UDim2.new(1,-116,0,16),Enum.Font.Gotham,9,C.MUTED);local bpm=label(f,"-- BPM",UDim2.new(1,-70,0,12),UDim2.fromOffset(60,20),Enum.Font.GothamBold,10,C.WHITE,Enum.TextXAlignment.Right)
 local wave=frame(f,UDim2.fromOffset(10,52),UDim2.new(1,-20,0,34),C.BLACK,7);wave.ClipsDescendants=true;waveform(wave)
 local cue=button(f,"CUE",UDim2.fromOffset(10,96),UDim2.fromOffset(58,30),C.CARD)
 local play=button(f,"PLAY",UDim2.fromOffset(10,132),UDim2.fromOffset(58,30),C.CARD)
 local fx=button(f,"FX",UDim2.new(1,-68,0,96),UDim2.fromOffset(58,30),C.ACTIVE);fx.TextColor3=C.BLACK
 local sync=button(f,"SYNC",UDim2.new(1,-68,0,132),UDim2.fromOffset(58,30),C.CARD)
 local jog=Instance.new("Frame");jog.AnchorPoint=Vector2.new(.5,.5);jog.Position=UDim2.new(.5,0,.62,0);jog.Size=UDim2.fromOffset(94,94);jog.BackgroundColor3=C.BLACK;jog.BackgroundTransparency=.08;jog.BorderSizePixel=0;jog.Parent=f;corner(jog,47);local js=Instance.new("UIStroke");js.Color=C.LINE;js.Thickness=2;js.Parent=jog
 local inner=Instance.new("Frame");inner.AnchorPoint=Vector2.new(.5,.5);inner.Position=UDim2.fromScale(.5,.5);inner.Size=UDim2.fromOffset(57,57);inner.BackgroundTransparency=1;inner.Parent=jog;corner(inner,29);stroke(inner,C.LINE,.2)
 local dot=Instance.new("Frame");dot.AnchorPoint=Vector2.new(.5,.5);dot.Position=UDim2.fromScale(.5,.5);dot.Size=UDim2.fromOffset(7,7);dot.BackgroundColor3=C.WHITE;dot.BorderSizePixel=0;dot.Parent=jog;corner(dot,4)
 local playlist=button(f,"PLAYLIST "..deck,UDim2.new(0,10,1,-48),UDim2.new(1,-20,0,38),C.CARD)
 deckRefs[deck]={title=title,artist=artist,bpm=bpm,play=play,jog=jog,jogStroke=js}
 cue.Activated:Connect(function()action:FireServer("cue",{deck=deck})end);play.Activated:Connect(function()action:FireServer("play_toggle",{deck=deck})end);sync.Activated:Connect(function()action:FireServer("sync",{deck=deck})end);fx.Activated:Connect(function()gui:SetAttribute("OpenFXDeck",deck)end);playlist.Activated:Connect(function()gui:SetAttribute("OpenPlaylistDeck",deck)end)
end
makeDeck("A",true);makeDeck("B",false)

local mixer=frame(content,UDim2.new(.5,-66,0,0),UDim2.fromOffset(132,0),C.PANEL,12);mixer.Size=UDim2.new(0,132,1,0)
label(mixer,"MIXER",UDim2.fromOffset(8,7),UDim2.new(1,-16,0,18),Enum.Font.GothamBlack,10,C.WHITE,Enum.TextXAlignment.Center)
local meterHolder=Instance.new("Frame");meterHolder.BackgroundTransparency=1;meterHolder.Position=UDim2.fromOffset(18,34);meterHolder.Size=UDim2.new(1,-36,1,-126);meterHolder.ClipsDescendants=true;meterHolder.Parent=mixer
local meterA,meterB={},{}
for i=1,12 do for side,tbl in ipairs({meterA,meterB}) do local b=Instance.new("Frame");b.AnchorPoint=Vector2.new(0,1);b.Position=UDim2.new(side==1 and 0 or .58,0,1,-(i-1)*8);b.Size=UDim2.new(.40,0,0,6);b.BackgroundColor3=C.WHITE;b.BackgroundTransparency=.75;b.BorderSizePixel=0;b.Parent=meterHolder;corner(b,2);tbl[i]=b end end
label(mixer,"A                 B",UDim2.new(0,8,1,-86),UDim2.new(1,-16,0,14),Enum.Font.GothamBold,8,C.MUTED,Enum.TextXAlignment.Center)
local rail=Instance.new("Frame");rail.Position=UDim2.new(0,14,1,-61);rail.Size=UDim2.new(1,-28,0,5);rail.BackgroundColor3=C.LINE;rail.BorderSizePixel=0;rail.Parent=mixer;corner(rail,3)
local thumb=Instance.new("Frame");thumb.AnchorPoint=Vector2.new(.5,.5);thumb.Position=UDim2.new(.5,0,.5,0);thumb.Size=UDim2.fromOffset(16,16);thumb.BackgroundColor3=C.WHITE;thumb.BorderSizePixel=0;thumb.Parent=rail;corner(thumb,8)
local hit=Instance.new("TextButton");hit.BackgroundTransparency=1;hit.Text="";hit.Position=UDim2.new(0,-8,0,-10);hit.Size=UDim2.new(1,16,0,25);hit.Parent=rail
local dragging=false
local function setCross(inputX)local x=math.clamp((inputX-rail.AbsolutePosition.X)/math.max(1,rail.AbsoluteSize.X),0,1);thumb.Position=UDim2.new(x,0,.5,0);action:FireServer("crossfader",{value=x})end
hit.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;setCross(i.Position.X)end end)
UserInputService.InputChanged:Connect(function(i)if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setCross(i.Position.X)end end)
UserInputService.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
label(mixer,"CROSSFADER",UDim2.new(0,8,1,-37),UDim2.new(1,-16,0,14),Enum.Font.GothamBold,7,C.MUTED,Enum.TextXAlignment.Center)

for i,name in ipairs({"CLUB","VIP","UNDERGROUND","FUNKOT"}) do local b=button(footer,name,UDim2.new((i-1)/4,6,0,6),UDim2.new(.25,-12,0,34),C.CARD);b.TextSize=name=="UNDERGROUND" and 8 or 10;mapButtons[name]=b;b.Activated:Connect(function()action:FireServer("map",{value=name})end)end
live.Activated:Connect(function()if state.live then action:FireServer("live_stop",{}) else action:FireServer("live_start",{}) end end)

local function clearDialog()if dialog then dialog:Destroy();dialog=nil end end
local function modal(titleText)
 clearDialog();local shade=Instance.new("Frame");shade.Size=UDim2.fromScale(1,1);shade.BackgroundTransparency=1;shade.ZIndex=100;shade.Parent=root
 local box=frame(shade,UDim2.fromScale(.5,.5),UDim2.fromScale(.78,.76),C.PANEL,14);box.AnchorPoint=Vector2.new(.5,.5);box.ZIndex=101
 label(box,titleText,UDim2.fromOffset(16,9),UDim2.new(1,-62,0,28),Enum.Font.GothamBlack,17,C.WHITE).ZIndex=102
 local x=button(box,"×",UDim2.new(1,-46,0,9),UDim2.fromOffset(32,30),C.CARD);x.TextSize=18;x.ZIndex=103;x.Activated:Connect(clearDialog)
 dialog=shade;return box
end
local function openPlaylist(deck)
 if not accessAllowed() then return end
 local box=modal("PLAYLIST "..deck)
 local search=Instance.new("TextBox");search.Position=UDim2.fromOffset(16,48);search.Size=UDim2.new(1,-32,0,36);search.BackgroundColor3=C.CARD;search.BackgroundTransparency=.10;search.TextColor3=C.WHITE;search.PlaceholderText="Search track...";search.PlaceholderColor3=C.MUTED;search.Text="";search.ClearTextOnFocus=false;search.Font=Enum.Font.Gotham;search.TextSize=11;search.BorderSizePixel=0;search.ZIndex=102;search.Parent=box;corner(search,8)
 local list=Instance.new("ScrollingFrame");list.Position=UDim2.fromOffset(16,94);list.Size=UDim2.new(1,-32,1,-110);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.ScrollBarThickness=3;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.ZIndex=102;list.Parent=box
 local lay=Instance.new("UIListLayout");lay.Padding=UDim.new(0,5);lay.Parent=list
 local function render()
  for _,c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
  local q=string.lower(search.Text or "")
  for _,t in ipairs(library) do local map=t.map or "";local blob=string.lower(tostring(t.title or "").." "..tostring(t.artist or "").." "..map);if q=="" or string.find(blob,q,1,true) then local bpm=tonumber(t.bpm) or 0;local row=button(list,string.format("%s\n%s • %s%s",tostring(t.title),tostring(t.artist or ""),map,bpm>0 and (" • "..tostring(bpm).." BPM") or ""),nil,UDim2.new(1,-4,0,48),C.CARD);row.TextWrapped=true;row.TextXAlignment=Enum.TextXAlignment.Left;row.TextSize=10;row.ZIndex=103;row.Activated:Connect(function()action:FireServer("load",{deck=deck,index=t.index});clearDialog()end)end end
 end
 search:GetPropertyChangedSignal("Text"):Connect(render);render()
end
local function openFx(deck)
 if not accessAllowed() then return end
 local box=modal("DECK "..deck.." • FX PAD");label(box,"LIVE FX",UDim2.fromOffset(16,48),UDim2.new(1,-32,0,18),Enum.Font.GothamBold,9,C.MUTED).ZIndex=102
 local fxNames={"ECHO","FILTER","REVERB","FLANGER"};local fxBtns={}
 for i,name in ipairs(fxNames) do local b=button(box,name.."\nOFF",UDim2.new((i-1)/4,16-(i-1)*4,0,72),UDim2.new(.25,-20,0,66),C.CARD);b.TextWrapped=true;b.TextSize=11;b.ZIndex=102;fxBtns[name]=b;b.Activated:Connect(function()action:FireServer("fx_toggle",{deck=deck,fx=name})end)end
 label(box,"SAMPLE FX",UDim2.fromOffset(16,154),UDim2.new(1,-32,0,18),Enum.Font.GothamBold,9,C.MUTED).ZIndex=102
 for i,name in ipairs({"HORN","AIRHORN","BRAKE","SIREN"}) do local col=(i-1)%2;local row=math.floor((i-1)/2);local b=button(box,name,UDim2.new(col*.5,16-col*4,0,180+row*62),UDim2.new(.5,-20,0,54),C.CARD);b.TextSize=12;b.ZIndex=102;b.Activated:Connect(function()action:FireServer("sample",{deck=deck,fx=name})end)end
 local function update()local d=state.decks and state.decks[deck] or {};for name,b in pairs(fxBtns) do local on=d.fx and d.fx[name]==true;b.Text=name.."\n"..(on and "ON" or "OFF");setActive(b,on) end end
 box:SetAttribute("RefreshFX",0);box:GetAttributeChangedSignal("RefreshFX"):Connect(update);box:SetAttribute("FXDeck",deck);update()
end
gui:GetAttributeChangedSignal("OpenPlaylistDeck"):Connect(function()local d=gui:GetAttribute("OpenPlaylistDeck");if d=="A" or d=="B" then gui:SetAttribute("OpenPlaylistDeck",nil);openPlaylist(d) end end)
gui:GetAttributeChangedSignal("OpenFXDeck"):Connect(function()local d=gui:GetAttribute("OpenFXDeck");if d=="A" or d=="B" then gui:SetAttribute("OpenFXDeck",nil);openFx(d) end end)

local function applyState(s)
 if type(s)~="table" or s.authorized~=true then return end
 state=s;status.Text=tostring(s.notice or (s.live and "DJ LIVE • "..tostring(s.map) or readyLabel()));live.Text=s.live and "LIVE • STOP" or "LIVE START";setActive(live,s.live==true)
 for map,b in pairs(mapButtons) do setActive(b,map==s.map) end
 thumb.Position=UDim2.new(math.clamp(tonumber(s.crossfader) or .5,0,1),0,.5,0)
 for deck,ref in pairs(deckRefs) do local d=s.decks and s.decks[deck] or {};ref.title.Text=tostring(d.title or "EMPTY");ref.artist.Text=tostring(d.artist or "");local bpm=tonumber(d.bpm) or 0;ref.bpm.Text=(bpm>0 and tostring(bpm) or "--").." BPM";ref.play.Text=d.playing and "PAUSE" or "PLAY";ref.jogStroke.Color=d.playing and C.WHITE or C.LINE end
 if dialog then local box=dialog:FindFirstChildWhichIsA("Frame");if box and box:GetAttribute("FXDeck") then box:SetAttribute("RefreshFX",os.clock()) end end
end
stateRemote.OnClientEvent:Connect(applyState)

local function refreshAuthorization()
 if not accessAllowed() then gui.Enabled=false;closePanel();return end
 gui.Enabled=true;status.Text=readyLabel()
 local okS,s=pcall(function()return getState:InvokeServer()end);if okS and type(s)=="table" and s.authorized then applyState(s) end
 local okL,l=pcall(function()return getLibrary:InvokeServer()end);if okL and type(l)=="table" then library=l end
end
player:GetAttributeChangedSignal("BBYAHasDJRole"):Connect(refreshAuthorization);player:GetAttributeChangedSignal("BBYAManagedRole"):Connect(refreshAuthorization);player:GetAttributeChangedSignal("BBYAOwner"):Connect(refreshAuthorization)
task.defer(refreshAuthorization)

local spin={A=0,B=0};local meterTime=0
RunService.RenderStepped:Connect(function(dt)
 if not root.Visible then return end
 meterTime+=dt
 for deck,ref in pairs(deckRefs) do local d=state.decks and state.decks[deck];if d and d.playing then spin[deck]=(spin[deck]+dt*65)%360;ref.jog.Rotation=spin[deck] end end
 local da=state.decks and state.decks.A;local db=state.decks and state.decks.B
 for i,b in ipairs(meterA) do b.BackgroundTransparency=(state.live and da and da.playing and i<=math.floor(6+5*math.abs(math.sin(meterTime*4)))) and .05 or .78 end
 for i,b in ipairs(meterB) do b.BackgroundTransparency=(state.live and db and db.playing and i<=math.floor(6+5*math.abs(math.sin(meterTime*4.3+1)))) and .05 or .78 end
end)

print("[BBYA] DJ LIVE CLEAN UI v2.3 online: topbar-safe / mirrored deck spacing / vertical CUE-PLAY + FX-SYNC")