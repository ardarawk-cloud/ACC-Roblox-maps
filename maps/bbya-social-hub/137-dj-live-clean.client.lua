-- BBYA SOCIAL HUB — DJ LIVE CLEAN UI v1
-- Roblox conversion of Arda's authoritative Kotlin/Jetpack Compose DJ LIVE blueprint.
-- Full-screen landscape control surface: Deck A/B, mixer, playlists, FX pad, LIVE + map selector.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
pcall(function()pg.ScreenOrientation=Enum.ScreenOrientation.LandscapeSensor end)

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local action=remotes:WaitForChild("DJLiveAction")
local stateRemote=remotes:WaitForChild("DJLiveState")
local getState=remotes:WaitForChild("DJLiveGetState")
local getLibrary=remotes:WaitForChild("DJLiveGetLibrary")

local okState,initial=pcall(function()return getState:InvokeServer()end)
if not okState or type(initial)~="table" or initial.authorized~=true then
 print("[BBYA] DJ LIVE CLEAN UI: not authorized")
 return
end
local okLib,library=pcall(function()return getLibrary:InvokeServer()end)
if not okLib or type(library)~="table" then library={} end

local old=pg:FindFirstChild("BBYADJLiveCleanUI")
if old then old:Destroy() end
local gui=Instance.new("ScreenGui")
gui.Name="BBYADJLiveCleanUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=90;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg

local C={
 BG=Color3.fromRGB(5,5,5),PANEL=Color3.fromRGB(17,17,17),SECOND=Color3.fromRGB(27,27,27),
 BORDER=Color3.fromRGB(74,74,74),TEXT=Color3.fromRGB(245,245,245),MUTED=Color3.fromRGB(153,153,153),
 ACTIVE=Color3.fromRGB(244,244,244),ACTIVE_TEXT=Color3.fromRGB(5,5,5),BLACK=Color3.fromRGB(8,8,8)
}
local function corner(o,r)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 12);x.Parent=o;return x end
local function stroke(o,col,t)local x=Instance.new("UIStroke");x.Color=col or C.BORDER;x.Thickness=t or 1;x.Parent=o;return x end
local function text(parent,txt,size,bold,col)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=tostring(txt or "");l.TextColor3=col or C.TEXT;l.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham;l.TextSize=size or 12;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.TextTruncate=Enum.TextTruncate.AtEnd;l.Parent=parent;return l
end
local function btn(parent,txt)
 local b=Instance.new("TextButton");b.AutoButtonColor=true;b.BorderSizePixel=0;b.BackgroundColor3=C.SECOND;b.TextColor3=C.TEXT;b.Font=Enum.Font.GothamBold;b.TextSize=11;b.Text=tostring(txt or "");b.Parent=parent;corner(b,10);return b
end
local function panel(parent,r)
 local f=Instance.new("Frame");f.BorderSizePixel=0;f.BackgroundColor3=C.PANEL;f.Parent=parent;corner(f,r or 16);stroke(f,C.BORDER,1);return f
end
local function setActive(b,on)
 b.BackgroundColor3=on and C.ACTIVE or C.SECOND;b.TextColor3=on and C.ACTIVE_TEXT or C.TEXT
end

local launcher=btn(gui,"DJ LIVE")
launcher.AnchorPoint=Vector2.new(1,1);launcher.Position=UDim2.new(1,-18,1,-18);launcher.Size=UDim2.fromOffset(106,42);launcher.ZIndex=2

local root=Instance.new("Frame")
root.Size=UDim2.fromScale(1,1);root.BackgroundColor3=C.BG;root.BorderSizePixel=0;root.Visible=false;root.Parent=gui
local close=btn(root,"CLOSE")
close.AnchorPoint=Vector2.new(1,0);close.Position=UDim2.new(1,-8,0,8);close.Size=UDim2.fromOffset(64,30);close.ZIndex=20

local top=Instance.new("Frame");top.BackgroundTransparency=1;top.Position=UDim2.fromOffset(8,8);top.Size=UDim2.new(1,-88,0,82);top.Parent=root
local middle=Instance.new("Frame");middle.BackgroundTransparency=1;middle.Position=UDim2.fromOffset(8,97);middle.Size=UDim2.new(1,-16,1,-170);middle.Parent=root
local bottom=Instance.new("Frame");bottom.BackgroundTransparency=1;bottom.AnchorPoint=Vector2.new(0,1);bottom.Position=UDim2.new(0,8,1,-8);bottom.Size=UDim2.new(1,-16,0,58);bottom.Parent=root

local state=initial
local selectedMap=state.map or "CLUB"
local dialog=nil
local deckRefs={}
local mapButtons={}
local liveButton
local mixerRefs={}

local function makeWave(parent,count)
 local holder=Instance.new("Frame");holder.BackgroundTransparency=1;holder.Size=UDim2.fromScale(1,1);holder.ClipsDescendants=true;holder.Parent=parent
 for i=1,count do
  local h=5+((i*17)%29)
  local bar=Instance.new("Frame");bar.AnchorPoint=Vector2.new(.5,.5);bar.Position=UDim2.new((i-.5)/count,0,.5,0);bar.Size=UDim2.new(0,2,0,h*2);bar.BackgroundColor3=C.TEXT;bar.BackgroundTransparency=.3;bar.BorderSizePixel=0;bar.Parent=holder;corner(bar,2)
 end
 local center=Instance.new("Frame");center.AnchorPoint=Vector2.new(.5,0);center.Position=UDim2.fromScale(.5,0);center.Size=UDim2.new(0,3,1,0);center.BackgroundColor3=C.TEXT;center.BorderSizePixel=0;center.Parent=holder
 return holder
end
local function topWave(deck,x)
 local f=panel(top,14);f.Position=UDim2.new(x,0,0,0);f.Size=UDim2.new(.5,-4,1,0)
 local d=text(f,deck,11,true);d.Position=UDim2.fromOffset(8,2);d.Size=UDim2.fromOffset(24,18)
 local title=text(f,"EMPTY",8,false,C.MUTED);title.AnchorPoint=Vector2.new(0,1);title.Position=UDim2.new(0,8,1,-3);title.Size=UDim2.new(1,-16,0,16)
 local w=Instance.new("Frame");w.BackgroundTransparency=1;w.Position=UDim2.fromOffset(30,7);w.Size=UDim2.new(1,-38,1,-14);w.Parent=f;makeWave(w,100)
 return title
end
local topTitleA=topWave("A",0)
local topTitleB=topWave("B",.5);topTitleB.Parent.Position=UDim2.new(.5,4,0,0)

local function roundButton(parent,label)
 local b=btn(parent,label);b.Size=UDim2.fromOffset(64,64);corner(b,32);return b
end
local function createJog(parent)
 local j=Instance.new("Frame");j.Size=UDim2.fromOffset(145,145);j.BackgroundColor3=C.BLACK;j.BorderSizePixel=0;j.Parent=parent;corner(j,73);local st=stroke(j,C.BORDER,3)
 local inner=Instance.new("Frame");inner.AnchorPoint=Vector2.new(.5,.5);inner.Position=UDim2.fromScale(.5,.5);inner.Size=UDim2.fromOffset(100,100);inner.BackgroundTransparency=1;inner.Parent=j;corner(inner,50);stroke(inner,C.MUTED,1)
 local dot=Instance.new("Frame");dot.AnchorPoint=Vector2.new(.5,.5);dot.Position=UDim2.fromScale(.5,.5);dot.Size=UDim2.fromOffset(11,11);dot.BackgroundColor3=C.TEXT;dot.BorderSizePixel=0;dot.Parent=j;corner(dot,6)
 local mark=Instance.new("Frame");mark.AnchorPoint=Vector2.new(.5,0);mark.Position=UDim2.new(.5,0,0,7);mark.Size=UDim2.fromOffset(3,16);mark.BackgroundColor3=C.TEXT;mark.BorderSizePixel=0;mark.Parent=j
 return j,st
end

local function openPlaylist(deck) end
local function openFx(deck) end

local function createDeck(deck,side)
 local f=panel(middle,16)
 if side=="L" then f.Position=UDim2.new(0,0,0,0) else f.AnchorPoint=Vector2.new(1,0);f.Position=UDim2.new(1,0,0,0) end
 f.Size=UDim2.new(.5,-80,1,0)
 local badge=Instance.new("Frame");badge.Position=UDim2.fromOffset(9,9);badge.Size=UDim2.fromOffset(42,42);badge.BackgroundColor3=C.SECOND;badge.BorderSizePixel=0;badge.Parent=f;corner(badge,8)
 local bd=text(badge,deck,20,true);bd.TextXAlignment=Enum.TextXAlignment.Center;bd.Size=UDim2.fromScale(1,1)
 local title=text(f,"EMPTY",16,true);title.Position=UDim2.fromOffset(60,8);title.Size=UDim2.new(1,-150,0,24)
 local artist=text(f,"",10,false,C.MUTED);artist.Position=UDim2.fromOffset(60,31);artist.Size=UDim2.new(1,-150,0,18)
 local bpmLab=text(f,"BPM",9,false,C.MUTED);bpmLab.AnchorPoint=Vector2.new(1,0);bpmLab.Position=UDim2.new(1,-9,0,7);bpmLab.Size=UDim2.fromOffset(64,14);bpmLab.TextXAlignment=Enum.TextXAlignment.Right
 local bpm=text(f,"--",19,true);bpm.AnchorPoint=Vector2.new(1,0);bpm.Position=UDim2.new(1,-9,0,22);bpm.Size=UDim2.fromOffset(72,24);bpm.TextXAlignment=Enum.TextXAlignment.Right
 local mini=Instance.new("Frame");mini.Position=UDim2.fromOffset(9,59);mini.Size=UDim2.new(1,-18,0,34);mini.BackgroundColor3=Color3.fromRGB(11,11,11);mini.BorderSizePixel=0;mini.Parent=f;corner(mini,8);makeWave(mini,70)
 local sync=btn(f,"SYNC");sync.Position=UDim2.fromOffset(9,101);sync.Size=UDim2.new(.42,-4,0,54)
 local fx=btn(f,"FX PAD\nLIVE + SAMPLE");fx.TextWrapped=true;fx.Position=UDim2.new(.42,5,0,101);fx.Size=UDim2.new(.58,-14,0,54);fx.BackgroundColor3=C.ACTIVE;fx.TextColor3=C.ACTIVE_TEXT
 local cue=roundButton(f,"CUE");cue.Position=UDim2.fromOffset(18,170)
 local play=roundButton(f,"▶");play.Position=UDim2.fromOffset(18,242);play.TextSize=18
 local jog,jogStroke=createJog(f);jog.AnchorPoint=Vector2.new(1,.5);jog.Position=UDim2.new(1,-18,.63,0)
 local plist=btn(f,"PLAYLIST "..deck);plist.AnchorPoint=Vector2.new(0,1);plist.Position=UDim2.new(0,9,1,-9);plist.Size=UDim2.new(1,-18,0,44)
 sync.MouseButton1Click:Connect(function()action:FireServer("sync",{deck=deck})end)
 cue.MouseButton1Click:Connect(function()action:FireServer("cue",{deck=deck})end)
 play.MouseButton1Click:Connect(function()action:FireServer("play_toggle",{deck=deck})end)
 fx.MouseButton1Click:Connect(function()openFx(deck)end)
 plist.MouseButton1Click:Connect(function()openPlaylist(deck)end)
 deckRefs[deck]={frame=f,title=title,artist=artist,bpm=bpm,play=play,jog=jog,jogStroke=jogStroke,fxButton=fx}
end
createDeck("A","L");createDeck("B","R")

local mixer=panel(middle,16);mixer.AnchorPoint=Vector2.new(.5,0);mixer.Position=UDim2.new(.5,0,0,0);mixer.Size=UDim2.new(0,145,1,0)
local mixTitle=text(mixer,"MIXER",11,true);mixTitle.Position=UDim2.fromOffset(8,7);mixTitle.Size=UDim2.new(1,-16,0,18);mixTitle.TextXAlignment=Enum.TextXAlignment.Center
local function knob(x,labelTxt)
 local k=Instance.new("Frame");k.Position=UDim2.fromOffset(x,34);k.Size=UDim2.fromOffset(35,35);k.BackgroundColor3=Color3.fromRGB(16,16,16);k.BorderSizePixel=0;k.Parent=mixer;corner(k,18);stroke(k,C.MUTED,2)
 local line=Instance.new("Frame");line.AnchorPoint=Vector2.new(.5,0);line.Position=UDim2.new(.5,0,0,4);line.Size=UDim2.fromOffset(2,10);line.BackgroundColor3=C.TEXT;line.BorderSizePixel=0;line.Parent=k
 local l=text(mixer,labelTxt,7,false,C.MUTED);l.Position=UDim2.fromOffset(x,70);l.Size=UDim2.fromOffset(35,12);l.TextXAlignment=Enum.TextXAlignment.Center
end
knob(25,"A");knob(85,"B")
local meterA=Instance.new("Frame");meterA.BackgroundTransparency=1;meterA.Position=UDim2.new(0,31,0,91);meterA.Size=UDim2.new(0,20,1,-175);meterA.Parent=mixer
local meterB=Instance.new("Frame");meterB.BackgroundTransparency=1;meterB.Position=UDim2.new(1,-51,0,91);meterB.Size=UDim2.new(0,20,1,-175);meterB.Parent=mixer
local function meterBars(holder)
 local bars={}
 for i=1,17 do local b=Instance.new("Frame");b.AnchorPoint=Vector2.new(0,1);b.Position=UDim2.new(0,0,1,-(i-1)*10);b.Size=UDim2.new(1,0,0,8);b.BackgroundColor3=C.MUTED;b.BorderSizePixel=0;b.Parent=holder;corner(b,2);bars[i]=b end
 return bars
end
mixerRefs.meterA=meterBars(meterA);mixerRefs.meterB=meterBars(meterB)
local ab=text(mixer,"A          B",10,false,C.TEXT);ab.AnchorPoint=Vector2.new(.5,1);ab.Position=UDim2.new(.5,0,1,-72);ab.Size=UDim2.new(1,-16,0,16);ab.TextXAlignment=Enum.TextXAlignment.Center
local slider=Instance.new("Frame");slider.AnchorPoint=Vector2.new(.5,1);slider.Position=UDim2.new(.5,0,1,-45);slider.Size=UDim2.new(1,-20,0,18);slider.BackgroundTransparency=1;slider.Parent=mixer
local rail=Instance.new("Frame");rail.AnchorPoint=Vector2.new(0,.5);rail.Position=UDim2.fromScale(0,.5);rail.Size=UDim2.new(1,0,0,4);rail.BackgroundColor3=C.BORDER;rail.BorderSizePixel=0;rail.Parent=slider;corner(rail,2)
local thumb=Instance.new("Frame");thumb.AnchorPoint=Vector2.new(.5,.5);thumb.Position=UDim2.new(initial.crossfader or .5,0,.5,0);thumb.Size=UDim2.fromOffset(16,16);thumb.BackgroundColor3=C.TEXT;thumb.BorderSizePixel=0;thumb.Parent=slider;corner(thumb,8)
local sliderHit=Instance.new("TextButton");sliderHit.BackgroundTransparency=1;sliderHit.Text="";sliderHit.Size=UDim2.fromScale(1,1);sliderHit.Parent=slider
local cf=text(mixer,"CROSSFADER",7,false,C.MUTED);cf.AnchorPoint=Vector2.new(.5,1);cf.Position=UDim2.new(.5,0,1,-7);cf.Size=UDim2.new(1,-10,0,14);cf.TextXAlignment=Enum.TextXAlignment.Center
local dragging=false
local function setCrossFromX(x)
 local a=slider.AbsolutePosition.X;local w=slider.AbsoluteSize.X;if w<=0 then return end
 local v=math.clamp((x-a)/w,0,1);thumb.Position=UDim2.new(v,0,.5,0);action:FireServer("crossfader",{value=v})
end
sliderHit.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;setCrossFromX(i.Position.X) end end)
UserInputService.InputChanged:Connect(function(i)if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setCrossFromX(i.Position.X) end end)
UserInputService.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)

liveButton=btn(bottom,"LIVE START");liveButton.Size=UDim2.new(.30,-4,1,0);liveButton.TextSize=13
local maps={"CLUB","VIP","UNDERGROUND","FUNKOT"}
for i,map in ipairs(maps) do
 local b=btn(bottom,map);b.Position=UDim2.new(.30+(i-1)*.175,3,0,0);b.Size=UDim2.new(.175,-5,1,0);b.TextSize=map=="UNDERGROUND" and 8 or 10;mapButtons[map]=b
 b.MouseButton1Click:Connect(function()selectedMap=map;action:FireServer("map",{value=map})end)
end
liveButton.MouseButton1Click:Connect(function()
 if state.live then action:FireServer("live_stop",{}) else action:FireServer("live_start",{}) end
end)

local overlay=Instance.new("Frame");overlay.Size=UDim2.fromScale(1,1);overlay.BackgroundColor3=Color3.new(0,0,0);overlay.BackgroundTransparency=.24;overlay.Visible=false;overlay.ZIndex=100;overlay.Parent=root
local dialogFrame=panel(overlay,20);dialogFrame.AnchorPoint=Vector2.new(.5,.5);dialogFrame.Position=UDim2.fromScale(.5,.5);dialogFrame.Size=UDim2.fromScale(.82,.82);dialogFrame.ZIndex=101
local function clearDialog()
 overlay.Visible=false
 for _,c in ipairs(dialogFrame:GetChildren()) do if not c:IsA("UICorner") and not c:IsA("UIStroke") then c:Destroy() end end
 dialog=nil
end

openPlaylist=function(deck)
 clearDialog();overlay.Visible=true;dialog="PLAYLIST"
 local h=text(dialogFrame,"PLAYLIST "..deck,22,true);h.Position=UDim2.fromOffset(16,10);h.Size=UDim2.new(1,-100,0,30);h.ZIndex=102
 local sub=text(dialogFrame,"Tap lagu → langsung masuk Deck "..deck,10,false,C.MUTED);sub.Position=UDim2.fromOffset(16,40);sub.Size=UDim2.new(1,-100,0,18);sub.ZIndex=102
 local x=btn(dialogFrame,"CLOSE");x.AnchorPoint=Vector2.new(1,0);x.Position=UDim2.new(1,-14,0,12);x.Size=UDim2.fromOffset(70,34);x.ZIndex=102;x.MouseButton1Click:Connect(clearDialog)
 local search=Instance.new("TextBox");search.Position=UDim2.fromOffset(16,68);search.Size=UDim2.new(1,-32,0,40);search.BackgroundColor3=C.SECOND;search.TextColor3=C.TEXT;search.PlaceholderColor3=C.MUTED;search.PlaceholderText="Search track...";search.Text="";search.ClearTextOnFocus=false;search.Font=Enum.Font.Gotham;search.TextSize=12;search.BorderSizePixel=0;search.ZIndex=102;search.Parent=dialogFrame;corner(search,10)
 local filterRow=Instance.new("Frame");filterRow.BackgroundTransparency=1;filterRow.Position=UDim2.fromOffset(16,116);filterRow.Size=UDim2.new(1,-32,0,40);filterRow.ZIndex=102;filterRow.Parent=dialogFrame
 local filters={"ALL","CLUB","VIP","UNDERGROUND","FUNKOT"};local chosen=selectedMap;local filterButtons={}
 for i,fv in ipairs(filters) do local b=btn(filterRow,fv);b.Position=UDim2.new((i-1)/5,2,0,0);b.Size=UDim2.new(.2,-4,1,0);b.TextSize=fv=="UNDERGROUND" and 7 or 9;b.ZIndex=103;filterButtons[fv]=b end
 local count=text(dialogFrame,"",9,false,C.MUTED);count.Position=UDim2.fromOffset(16,160);count.Size=UDim2.new(1,-32,0,18);count.ZIndex=102
 local list=Instance.new("ScrollingFrame");list.Position=UDim2.fromOffset(16,184);list.Size=UDim2.new(1,-32,1,-200);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.ScrollBarThickness=4;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.ZIndex=102;list.Parent=dialogFrame
 local lay=Instance.new("UIListLayout");lay.Padding=UDim.new(0,5);lay.Parent=list
 local function render()
  for _,c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
  for _,b in pairs(filterButtons) do setActive(b,false) end;setActive(filterButtons[chosen],true)
  local q=string.lower(search.Text or "");local n=0
  for _,t in ipairs(library) do
   local map=t.map or (type(t.maps)=="table" and t.maps[1]) or ""
   local matchFilter=chosen=="ALL" or map==chosen
   local blob=string.lower(tostring(t.title or "").." "..tostring(t.artist or ""))
   if matchFilter and (q=="" or string.find(blob,q,1,true)) then
    n+=1;local bpm=tonumber(t.bpm) or 0
    local row=btn(list,string.format("%s\n%s   •   %s%s",tostring(t.title),tostring(t.artist or ""),map,bpm>0 and ("   •   "..string.format("%.1f BPM",bpm)) or ""));row.Size=UDim2.new(1,-4,0,54);row.TextXAlignment=Enum.TextXAlignment.Left;row.TextWrapped=true;row.TextSize=11;row.ZIndex=103
    row.MouseButton1Click:Connect(function()action:FireServer("load",{deck=deck,index=t.index});clearDialog()end)
   end
  end
  count.Text=chosen.." • "..tostring(n).." TRACKS"
 end
 for _,fv in ipairs(filters) do filterButtons[fv].MouseButton1Click:Connect(function()chosen=fv;render()end) end
 search:GetPropertyChangedSignal("Text"):Connect(render);render()
end

openFx=function(deck)
 clearDialog();overlay.Visible=true;dialog="FX"
 local h=text(dialogFrame,"DECK "..deck.." • FX PAD",22,true);h.Position=UDim2.fromOffset(16,10);h.Size=UDim2.new(1,-100,0,30);h.ZIndex=102
 local sub=text(dialogFrame,"Live FX + Sample FX",11,false,C.MUTED);sub.Position=UDim2.fromOffset(16,40);sub.Size=UDim2.new(1,-100,0,18);sub.ZIndex=102
 local x=btn(dialogFrame,"CLOSE");x.AnchorPoint=Vector2.new(1,0);x.Position=UDim2.new(1,-14,0,12);x.Size=UDim2.fromOffset(70,34);x.ZIndex=102;x.MouseButton1Click:Connect(clearDialog)
 local liveLab=text(dialogFrame,"LIVE FX",10,true,C.MUTED);liveLab.Position=UDim2.fromOffset(16,72);liveLab.Size=UDim2.new(1,-32,0,18);liveLab.ZIndex=102
 local liveFx={"ECHO","FILTER","REVERB","FLANGER"};local fxBtns={}
 for i,name in ipairs(liveFx) do
  local b=btn(dialogFrame,name.."\nOFF");b.Position=UDim2.new((i-1)/4,16-(i-1)*4,0,96);b.Size=UDim2.new(.25,-20,0,75);b.TextWrapped=true;b.TextSize=12;b.ZIndex=102;fxBtns[name]=b
  b.MouseButton1Click:Connect(function()action:FireServer("fx_toggle",{deck=deck,fx=name})end)
 end
 local sampleLab=text(dialogFrame,"SAMPLE FX",10,true,C.MUTED);sampleLab.Position=UDim2.fromOffset(16,188);sampleLab.Size=UDim2.new(1,-32,0,18);sampleLab.ZIndex=102
 local samples={"HORN","AIRHORN","BRAKE","SIREN"}
 for i,name in ipairs(samples) do
  local row=math.floor((i-1)/2);local col=(i-1)%2
  local b=btn(dialogFrame,name.."\nTRIGGER");b.Position=UDim2.new(col*.5,16-col*4,0,214+row*90);b.Size=UDim2.new(.5,-20,0,82);b.TextWrapped=true;b.TextSize=14;b.ZIndex=102
  b.MouseButton1Click:Connect(function()action:FireServer("sample",{deck=deck,fx=name})end)
 end
 local note=text(dialogFrame,"LIVE FX aktif sampai ditekan lagi. Sample FX dimainkan sekali setiap tap.",9,false,C.MUTED);note.AnchorPoint=Vector2.new(0,1);note.Position=UDim2.new(0,16,1,-12);note.Size=UDim2.new(1,-32,0,22);note.ZIndex=102
 local function updateFxButtons()
  local d=state.decks and state.decks[deck]
  for name,b in pairs(fxBtns) do local on=d and d.fx and d.fx[name]==true;b.Text=name.."\n"..(on and "ON" or "OFF");setActive(b,on) end
 end
 overlay:SetAttribute("FXDeck",deck);overlay:SetAttribute("FXUpdate",os.clock());updateFxButtons()
 overlay:GetAttributeChangedSignal("FXUpdate"):Connect(updateFxButtons)
end

local notice=text(root,"",10,false,C.MUTED);notice.AnchorPoint=Vector2.new(.5,0);notice.Position=UDim2.new(.5,0,0,8);notice.Size=UDim2.new(.45,0,0,24);notice.TextXAlignment=Enum.TextXAlignment.Center;notice.ZIndex=19

local function applyState(s)
 if type(s)~="table" then return end
 state=s;selectedMap=s.map or selectedMap
 liveButton.Text=s.live and "● LIVE • STOP" or "LIVE START";setActive(liveButton,s.live==true)
 for map,b in pairs(mapButtons) do setActive(b,map==selectedMap) end
 thumb.Position=UDim2.new(math.clamp(tonumber(s.crossfader) or .5,0,1),0,.5,0)
 for deck,ref in pairs(deckRefs) do
  local d=s.decks and s.decks[deck] or {}
  ref.title.Text=tostring(d.title or "EMPTY");ref.artist.Text=tostring(d.artist or "")
  local bpm=tonumber(d.bpm) or 0;ref.bpm.Text=bpm>0 and string.format("%.1f",bpm) or "--"
  local playing=d.playing==true;ref.play.Text=playing and "Ⅱ" or "▶";ref.jogStroke.Color=playing and C.TEXT or C.BORDER
  if deck=="A" then topTitleA.Text=ref.title.Text else topTitleB.Text=ref.title.Text end
 end
 notice.Text=tostring(s.notice or "")
 if dialog=="FX" then overlay:SetAttribute("FXUpdate",os.clock()) end
end
stateRemote.OnClientEvent:Connect(applyState)
applyState(initial)

launcher.MouseButton1Click:Connect(function()root.Visible=true;launcher.Visible=false end)
close.MouseButton1Click:Connect(function()root.Visible=false;launcher.Visible=true;clearDialog()end)

local spin={A=0,B=0};local meterT=0
RunService.RenderStepped:Connect(function(dt)
 if not root.Visible then return end
 for deck,ref in pairs(deckRefs) do
  local d=state.decks and state.decks[deck]
  if d and d.playing then spin[deck]=(spin[deck]+dt*75)%360;ref.jog.Rotation=spin[deck] end
 end
 meterT+=dt
 local da=state.decks and state.decks.A;local db=state.decks and state.decks.B
 for i,b in ipairs(mixerRefs.meterA) do b.BackgroundTransparency=(state.live and da and da.playing and i<=math.floor(9+7*math.abs(math.sin(meterT*4)))) and 0 or .72 end
 for i,b in ipairs(mixerRefs.meterB) do b.BackgroundTransparency=(state.live and db and db.playing and i<=math.floor(9+7*math.abs(math.sin(meterT*4.4+1)))) and 0 or .72 end
end)

print("[BBYA] DJ LIVE CLEAN UI v1 online: exact blueprint surface converted to Roblox")