-- BBYA SOCIAL HUB — DEVELOPER DJ MIXER CLIENT v2
-- Full-screen landscape mobile DJ console for RR CreatorId + AMstudio only.
-- Visual direction: dual black-vinyl turntables, waveform strips, transport + FX pads.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

-- All clients keep the developer mix local to the selected physical venue.
local function venueAtPosition(p)
 if p.Y<-4.5 then return "UNDERGROUND" end
 if p.Y>=40 and p.Y<=60 and math.abs(p.X)<=62 and p.Z>=-48 and p.Z<=48 then return "ROOFTOP" end
 if p.Y>=20 and p.Y<40 and math.abs(p.X)<=58 and p.Z>=-46 and p.Z<=46 then return "VIP" end
 if p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253 then return "FUNKOT" end
 if p.Y>-4 and p.Y<20 and math.abs(p.X)<=61 and p.Z>=72 and p.Z<=152 then return "SKATEPARK" end
 if p.Y>-4 and p.Y<18 and math.abs(p.X)<=61 and p.Z>=0 and p.Z<70 then return "MAIN" end
 return "NONE"
end
local function currentVenue()
 local ch=player.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 return hrp and venueAtPosition(hrp.Position) or "NONE"
end
local muteButton
local function locallyMuted()
 if player:GetAttribute("BBYAMusicMuted")==true then return true end
 if not (muteButton and muteButton.Parent) then
  local gui=pg:FindFirstChild("BBYAClubUI")
  if gui then
   for _,d in ipairs(gui:GetDescendants()) do
    if d:IsA("TextButton") then
     local up=string.upper(d.Text or "")
     if up=="MUTE LOCAL" or up=="UNMUTE LOCAL" then muteButton=d;break end
    end
   end
  end
 end
 return muteButton and string.upper(muteButton.Text or "")=="UNMUTE LOCAL" or false
end
local djGates={}
local function enforceDJAudio()
 local here=currentVenue();local muted=locallyMuted()
 for _,g in ipairs(SoundService:GetChildren()) do
  if g:IsA("SoundGroup") and g:GetAttribute("BBYADeveloperDJ")==true then
   local gate=djGates[g]
   if not (gate and gate.Parent==g) then
    gate=g:FindFirstChild("BBYADeveloperDJVenueGateV2") or g:FindFirstChild("BBYADeveloperDJVenueGateV1")
    if gate and not gate:IsA("EqualizerSoundEffect") then gate:Destroy();gate=nil end
    if not gate then gate=Instance.new("EqualizerSoundEffect");gate.Name="BBYADeveloperDJVenueGateV2";gate.Parent=g end
    gate.Name="BBYADeveloperDJVenueGateV2";gate.Enabled=true;djGates[g]=gate
   end
   local open=g:GetAttribute("Live")==true and g:GetAttribute("Venue")==here and not muted
   local gain=open and 0 or -80;gate.LowGain=gain;gate.MidGain=gain;gate.HighGain=gain
   g:SetAttribute("BBYALocalAudible",open)
  end
 end
end
local gateAcc=0
RunService.Heartbeat:Connect(function(dt)gateAcc+=dt;if gateAcc>=.1 then gateAcc=0;enforceDJAudio() end end)
SoundService.ChildAdded:Connect(function(child)if child:IsA("SoundGroup") then task.defer(enforceDJAudio) end end)
player.CharacterAdded:Connect(function()task.delay(.3,enforceDJAudio)end)

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30);if not remotes then return end
local actionRemote=remotes:WaitForChild("DeveloperDJAction",30)
local stateRemote=remotes:WaitForChild("DeveloperDJState",30)
local getState=remotes:WaitForChild("DeveloperDJGetState",30)
if not actionRemote or not stateRemote or not getState then return end
local ok,initial=pcall(function()return getState:InvokeServer()end)
if not ok or type(initial)~="table" or initial.authorized~=true then return end

local old=pg:FindFirstChild("BBYADeveloperDJUI");if old then old:Destroy() end

local C={bg=Color3.fromRGB(5,6,9),panel=Color3.fromRGB(12,13,18),card=Color3.fromRGB(22,24,31),line=Color3.fromRGB(61,65,79),
 white=Color3.fromRGB(247,247,250),muted=Color3.fromRGB(145,151,168),pink=Color3.fromRGB(245,42,145),cyan=Color3.fromRGB(18,195,235),
 gold=Color3.fromRGB(235,188,74),purple=Color3.fromRGB(138,68,246),green=Color3.fromRGB(69,220,129),red=Color3.fromRGB(239,65,84),black=Color3.fromRGB(3,3,5)}
local function corner(o,r)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 8);x.Parent=o;return x end
local function circle(o)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(1,0);x.Parent=o;return x end
local function stroke(o,c,t,th)local x=Instance.new("UIStroke");x.Color=c or C.line;x.Transparency=t or .5;x.Thickness=th or 1;x.Parent=o;return x end
local function label(parent,text,pos,size,font,ts,color,align)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 11
 l.TextColor3=color or C.white;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.TextTruncate=Enum.TextTruncate.AtEnd;l.ZIndex=504;l.Parent=parent;return l
end
local function button(parent,text,pos,size,accent)
 local b=Instance.new("TextButton");b.BackgroundColor3=C.card;b.BorderSizePixel=0;b.Text=text;b.Position=pos;b.Size=size;b.Font=Enum.Font.GothamBold;b.TextSize=10
 b.TextColor3=C.white;b.AutoButtonColor=true;b.ZIndex=506;b.Parent=parent;corner(b,9);stroke(b,accent or C.line,.48,1);return b
end

local gui=Instance.new("ScreenGui")
gui.Name="BBYADeveloperDJUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=500;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
gui:SetAttribute("BBYADeveloperDJUIVersion","V2_FULLSCREEN_VINYL")
gui:SetAttribute("AccessPolicy","RR_CREATOR_ID_PLUS_AMSTUDIO_ONLY")

local panel=Instance.new("Frame")
panel.Name="DeveloperDJMixerPanel";panel.Position=UDim2.fromScale(0,0);panel.Size=UDim2.fromScale(1,1);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Visible=false;panel.ZIndex=500;panel.Parent=gui

-- subtle center divider
local divider=Instance.new("Frame");divider.AnchorPoint=Vector2.new(.5,0);divider.Position=UDim2.fromScale(.5,.105);divider.Size=UDim2.new(0,1,.72,0);divider.BackgroundColor3=C.line;divider.BackgroundTransparency=.45;divider.BorderSizePixel=0;divider.ZIndex=501;divider.Parent=panel

local header=Instance.new("Frame");header.Size=UDim2.new(1,0,.085,0);header.BackgroundColor3=C.panel;header.BorderSizePixel=0;header.ZIndex=502;header.Parent=panel
label(header,"BBYA DJ LIVE",UDim2.new(.018,0,.08,0),UDim2.new(.19,0,.42,0),Enum.Font.GothamBlack,18,C.white)
local statusLabel=label(header,"STANDBY • MAIN",UDim2.new(.018,0,.50,0),UDim2.new(.30,0,.34,0),Enum.Font.GothamBold,9,C.muted)
local sourceLabel=label(header,"ROBLOX AUDIO ASSETS",UDim2.new(.72,0,.18,0),UDim2.new(.18,0,.62,0),Enum.Font.GothamBold,9,C.muted,Enum.TextXAlignment.Right)
local close=button(header,"CLOSE",UDim2.new(.91,0,.18,0),UDim2.new(.075,0,.62,0),C.red);close.TextSize=9
close.Activated:Connect(function()panel.Visible=false end)

local venueBar=Instance.new("Frame");venueBar.Position=UDim2.new(.22,0,.012,0);venueBar.Size=UDim2.new(.48,0,.061,0);venueBar.BackgroundTransparency=1;venueBar.ZIndex=503;venueBar.Parent=header
local venues={{"MAIN","MAIN"},{"UNDER","UNDERGROUND"},{"VIP","VIP"},{"FUNKOT","FUNKOT"},{"SKATE","SKATEPARK"},{"ROOF","ROOFTOP"}}
local venueButtons={}
for i,spec in ipairs(venues) do
 local key=spec[2]
 local b=button(venueBar,spec[1],UDim2.new((i-1)/6+.004,0,0,0),UDim2.new(1/6-.008,0,1,0),C.gold);b.TextSize=8;venueButtons[key]=b
 b.Activated:Connect(function()actionRemote:FireServer("venue",{value=key})end)
end

local liveButton=button(panel,"GO LIVE",UDim2.new(.41,0,.87,0),UDim2.new(.18,0,.075,0),C.green);liveButton.Font=Enum.Font.GothamBlack;liveButton.TextSize=14;liveButton.ZIndex=520

local portraitHint=label(panel,"ROTATE PHONE ↻",UDim2.new(.3,0,.47,0),UDim2.new(.4,0,.08,0),Enum.Font.GothamBlack,22,C.white,Enum.TextXAlignment.Center);portraitHint.ZIndex=560;portraitHint.Visible=false

local current=initial
local deckUI={}
local function fmtTime(sec)sec=math.max(0,math.floor(tonumber(sec) or 0));return string.format("%d:%02d",math.floor(sec/60),sec%60)end

local function makeWave(parent,accent)
 local wave=Instance.new("Frame");wave.BackgroundColor3=Color3.fromRGB(8,9,13);wave.BorderSizePixel=0;wave.ClipsDescendants=true;wave.ZIndex=503;wave.Parent=parent;corner(wave,8);stroke(wave,accent,.72)
 for i=1,44 do
  local h=.18+(((i*37)%80)/100)*.72
  local bar=Instance.new("Frame");bar.Name="Bar"..i;bar.AnchorPoint=Vector2.new(0,.5);bar.Position=UDim2.new((i-1)/44+.002,0,.5,0);bar.Size=UDim2.new(1/44-.004,0,h,0);bar.BackgroundColor3=accent;bar.BackgroundTransparency=.20;bar.BorderSizePixel=0;bar.ZIndex=504;bar.Parent=wave
 end
 local playhead=Instance.new("Frame");playhead.Name="Playhead";playhead.AnchorPoint=Vector2.new(.5,0);playhead.Position=UDim2.new(0,0,0,0);playhead.Size=UDim2.new(0,2,1,0);playhead.BackgroundColor3=C.white;playhead.BorderSizePixel=0;playhead.ZIndex=506;playhead.Parent=wave
 return wave,playhead
end

local function makeVinyl(parent,accent)
 local holder=Instance.new("Frame");holder.BackgroundTransparency=1;holder.ZIndex=503;holder.Parent=parent
 local vinyl=Instance.new("Frame");vinyl.Name="Vinyl";vinyl.AnchorPoint=Vector2.new(.5,.5);vinyl.Position=UDim2.fromScale(.5,.5);vinyl.Size=UDim2.fromScale(.88,.88);vinyl.BackgroundColor3=C.black;vinyl.BorderSizePixel=0;vinyl.ZIndex=504;vinyl.Parent=holder;circle(vinyl);stroke(vinyl,Color3.fromRGB(54,56,65),.2,2)
 local ratio=Instance.new("UIAspectRatioConstraint");ratio.AspectRatio=1;ratio.AspectType=Enum.AspectType.FitWithinMaxSize;ratio.DominantAxis=Enum.DominantAxis.Width;ratio.Parent=vinyl
 for _,scale in ipairs({.80,.67,.54,.42}) do
  local groove=Instance.new("Frame");groove.AnchorPoint=Vector2.new(.5,.5);groove.Position=UDim2.fromScale(.5,.5);groove.Size=UDim2.fromScale(scale,scale);groove.BackgroundTransparency=1;groove.ZIndex=505;groove.Parent=vinyl;circle(groove);stroke(groove,Color3.fromRGB(65,68,78),.55,1)
 end
 local recordLabel=Instance.new("Frame");recordLabel.AnchorPoint=Vector2.new(.5,.5);recordLabel.Position=UDim2.fromScale(.5,.5);recordLabel.Size=UDim2.fromScale(.27,.27);recordLabel.BackgroundColor3=accent;recordLabel.BorderSizePixel=0;recordLabel.ZIndex=507;recordLabel.Parent=vinyl;circle(recordLabel)
 local spindle=Instance.new("Frame");spindle.AnchorPoint=Vector2.new(.5,.5);spindle.Position=UDim2.fromScale(.5,.5);spindle.Size=UDim2.fromScale(.055,.055);spindle.BackgroundColor3=C.white;spindle.BorderSizePixel=0;spindle.ZIndex=508;spindle.Parent=vinyl;circle(spindle)
 local marker=Instance.new("Frame");marker.AnchorPoint=Vector2.new(.5,.5);marker.Position=UDim2.fromScale(.5,.15);marker.Size=UDim2.fromScale(.035,.11);marker.BackgroundColor3=C.white;marker.BorderSizePixel=0;marker.ZIndex=508;marker.Parent=vinyl;corner(marker,3)
 local tone=Instance.new("Frame");tone.AnchorPoint=Vector2.new(.5,0);tone.Position=UDim2.fromScale(.87,.08);tone.Size=UDim2.fromScale(.025,.54);tone.Rotation=20;tone.BackgroundColor3=Color3.fromRGB(188,193,204);tone.BorderSizePixel=0;tone.ZIndex=509;tone.Parent=holder;corner(tone,4)
 return holder,vinyl
end

local FX={{"ECHO","echo","toggle"},{"REVERB","reverb","toggle"},{"FILTER","filter","toggle"},{"FLANGE","flange","toggle"},{"CHORUS","chorus","toggle"},{"DISTORT","distort","toggle"},{"BRAKE","BRAKE","trigger"},{"ROLL 1/2","ROLL_HALF","trigger"},{"ROLL 1/4","ROLL_QUARTER","trigger"}}

local function createDeck(deck,isLeft,accent)
 local root=Instance.new("Frame");root.Name="Deck"..deck;root.Position=UDim2.new(isLeft and .012 or .506,0,.095,0);root.Size=UDim2.new(.482,0,.74,0);root.BackgroundColor3=C.panel;root.BorderSizePixel=0;root.ZIndex=502;root.Parent=panel;corner(root,13);stroke(root,accent,.46,1)
 label(root,"DECK "..deck,UDim2.new(.025,0,.012,0),UDim2.new(.20,0,.06,0),Enum.Font.GothamBlack,16,accent)
 local time=label(root,"0:00 / 0:00",UDim2.new(.66,0,.012,0),UDim2.new(.31,0,.06,0),Enum.Font.GothamBold,10,C.muted,Enum.TextXAlignment.Right)
 local title=label(root,"EMPTY",UDim2.new(.025,0,.065,0),UDim2.new(.95,0,.055,0),Enum.Font.GothamBold,11,C.white)
 local asset=Instance.new("TextBox");asset.Position=UDim2.new(.025,0,.125,0);asset.Size=UDim2.new(.76,0,.06,0);asset.BackgroundColor3=C.card;asset.BorderSizePixel=0;asset.PlaceholderText="ROBLOX AUDIO ASSET ID";asset.Text="";asset.ClearTextOnFocus=false;asset.Font=Enum.Font.Gotham;asset.TextSize=10;asset.TextColor3=C.white;asset.PlaceholderColor3=C.muted;asset.ZIndex=506;asset.Parent=root;corner(asset,8);stroke(asset,accent,.68)
 local load=button(root,"LOAD",UDim2.new(.80,0,.125,0),UDim2.new(.175,0,.06,0),accent)
 local wave,playhead=makeWave(root,accent);wave.Position=UDim2.new(.025,0,.198,0);wave.Size=UDim2.new(.95,0,.09,0)

 local vinylHolder,vinyl=makeVinyl(root,accent);vinylHolder.Position=UDim2.new(.025,0,.305,0);vinylHolder.Size=UDim2.new(.43,0,.40,0)
 local fxBox=Instance.new("Frame");fxBox.Position=UDim2.new(.47,0,.305,0);fxBox.Size=UDim2.new(.505,0,.40,0);fxBox.BackgroundTransparency=1;fxBox.ZIndex=503;fxBox.Parent=root
 label(fxBox,"PERFORMANCE FX",UDim2.new(0,0,0,0),UDim2.new(1,0,.10,0),Enum.Font.GothamBlack,10,C.muted,Enum.TextXAlignment.Center)
 local fxButtons={}
 for i,spec in ipairs(FX) do
  local col=(i-1)%3;local row=math.floor((i-1)/3)
  local b=button(fxBox,spec[1],UDim2.new(col/3+.008,.0,.13+row*.285,0),UDim2.new(1/3-.016,0,.235,0),accent);b.TextSize=8;fxButtons[spec[2]]=b
  local key=spec[2];local mode=spec[3]
  b.Activated:Connect(function()
   if mode=="toggle" then actionRemote:FireServer("fx_toggle",{deck=deck,fx=key}) else actionRemote:FireServer("fx_trigger",{deck=deck,fx=key}) end
  end)
 end

 local transport=Instance.new("Frame");transport.Position=UDim2.new(.025,0,.735,0);transport.Size=UDim2.new(.95,0,.20,0);transport.BackgroundTransparency=1;transport.ZIndex=503;transport.Parent=root
 local cue=button(transport,"CUE",UDim2.new(0,0,.04,0),UDim2.new(.22,0,.72,0),C.gold);cue.TextSize=14;cue.Font=Enum.Font.GothamBlack
 local play=button(transport,"▶  PLAY",UDim2.new(.245,0,.04,0),UDim2.new(.31,0,.72,0),C.green);play.TextSize=13;play.Font=Enum.Font.GothamBlack
 local sync=button(transport,"SYNC",UDim2.new(.58,0,.04,0),UDim2.new(.22,0,.72,0),accent);sync.TextSize=13;sync.Font=Enum.Font.GothamBlack
 local setCue=button(transport,"SET CUE",UDim2.new(.825,0,.04,0),UDim2.new(.175,0,.72,0),C.muted);setCue.TextSize=8
 load.Activated:Connect(function()if asset.Text~="" then actionRemote:FireServer("load",{deck=deck,assetId=asset.Text})end end)
 cue.Activated:Connect(function()actionRemote:FireServer("cue",{deck=deck})end)
 play.Activated:Connect(function()actionRemote:FireServer("play_toggle",{deck=deck})end)
 sync.Activated:Connect(function()actionRemote:FireServer("sync",{deck=deck})end)
 setCue.Activated:Connect(function()actionRemote:FireServer("set_cue",{deck=deck})end)
 deckUI[deck]={root=root,title=title,time=time,asset=asset,play=play,sync=sync,vinyl=vinyl,playhead=playhead,fx=fxButtons,accent=accent,rotation=0}
end
createDeck("A",true,C.pink);createDeck("B",false,C.cyan)

-- Large tactile crossfader across the center bottom.
local cross=Instance.new("Frame");cross.Position=UDim2.new(.22,0,.835,0);cross.Size=UDim2.new(.56,0,.11,0);cross.BackgroundColor3=C.panel;cross.BorderSizePixel=0;cross.ZIndex=510;cross.Parent=panel;corner(cross,14);stroke(cross,C.line,.45)
label(cross,"A",UDim2.new(.025,0,.08,0),UDim2.new(.08,0,.30,0),Enum.Font.GothamBlack,14,C.pink)
label(cross,"CROSSFADER",UDim2.new(.38,0,.05,0),UDim2.new(.24,0,.28,0),Enum.Font.GothamBlack,9,C.muted,Enum.TextXAlignment.Center)
label(cross,"B",UDim2.new(.895,0,.08,0),UDim2.new(.08,0,.30,0),Enum.Font.GothamBlack,14,C.cyan,Enum.TextXAlignment.Right)
local bar=Instance.new("Frame");bar.Position=UDim2.new(.08,0,.52,0);bar.Size=UDim2.new(.84,0,.10,0);bar.BackgroundColor3=Color3.fromRGB(35,38,48);bar.BorderSizePixel=0;bar.ZIndex=512;bar.Parent=cross;corner(bar,6)
local fillA=Instance.new("Frame");fillA.Size=UDim2.fromScale(.5,1);fillA.BackgroundColor3=C.pink;fillA.BorderSizePixel=0;fillA.ZIndex=513;fillA.Parent=bar;corner(fillA,6)
local knob=Instance.new("Frame");knob.AnchorPoint=Vector2.new(.5,.5);knob.Position=UDim2.new(.5,0,.5,0);knob.Size=UDim2.new(0,24,0,24);knob.BackgroundColor3=C.white;knob.BorderSizePixel=0;knob.ZIndex=515;knob.Parent=bar;circle(knob);stroke(knob,C.cyan,.1,2)
local dragging=false
local function sendCross(x)
 local abs=bar.AbsolutePosition.X;local w=math.max(1,bar.AbsoluteSize.X);actionRemote:FireServer("crossfader",{value=math.clamp((x-abs)/w,0,1)})
end
bar.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;sendCross(i.Position.X)end end)
UserInputService.InputChanged:Connect(function(i)if dragging and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement)then sendCross(i.Position.X)end end)
UserInputService.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

liveButton.Activated:Connect(function()actionRemote:FireServer(current.live and "end_live" or "go_live",{})end)

local function updateUI(s)
 if type(s)~="table" then return end;current=s
 statusLabel.Text=s.live and ("LIVE • "..tostring(s.venue).." • "..tostring(s.operator or "DEV")) or ("STANDBY • "..tostring(s.venue))
 statusLabel.TextColor3=s.live and C.green or C.muted;liveButton.Text=s.live and "END LIVE" or "GO LIVE";liveButton.TextColor3=s.live and C.red or C.white
 for venue,b in pairs(venueButtons) do local selected=s.venue==venue;b.BackgroundColor3=selected and C.gold or C.card;b.TextColor3=selected and Color3.fromRGB(20,18,12) or C.white end
 local x=math.clamp(tonumber(s.crossfader) or .5,0,1);knob.Position=UDim2.new(x,0,.5,0);fillA.Size=UDim2.new(x,0,1,0)
 for deck,u in pairs(deckUI) do
  local d=s.decks and s.decks[deck]
  if d then
   u.title.Text=(d.preloaded and "● " or "")..tostring(d.title or "EMPTY")
   u.time.Text=fmtTime(d.timePosition).." / "..fmtTime(d.timeLength)
   u.play.Text=d.playing and "❚❚  PAUSE" or "▶  PLAY"
   local progress=(tonumber(d.timeLength) or 0)>0 and math.clamp((tonumber(d.timePosition) or 0)/d.timeLength,0,1) or 0;u.playhead.Position=UDim2.new(progress,0,0,0)
   for key,b in pairs(u.fx) do
    local active=(d.fx and d.fx[key]==true) or (d.busyFx and (string.upper(key)==string.upper(d.busyFx) or (key=="ROLL_HALF" and d.busyFx=="ROLL 1/2") or (key=="ROLL_QUARTER" and d.busyFx=="ROLL 1/4")))
    b.BackgroundColor3=active and u.accent or C.card;b.TextColor3=active and C.black or C.white
   end
  end
 end
end
stateRemote.OnClientEvent:Connect(updateUI);updateUI(initial)

-- Vinyl animation and orientation hint.
RunService.RenderStepped:Connect(function(dt)
 local cam=workspace.CurrentCamera;local vp=cam and cam.ViewportSize or Vector2.new(1280,720);portraitHint.Visible=panel.Visible and vp.Y>vp.X
 if not panel.Visible then return end
 for deck,u in pairs(deckUI) do
  local d=current.decks and current.decks[deck]
  if d and d.playing then u.rotation=(u.rotation+dt*92*(tonumber(d.pitch) or 1))%360;u.vinyl.Rotation=u.rotation end
 end
end)

local competing={HubPanel=true,CompactMusicCardV7=true,PlaylistDrawerV7=true,CommunityPanel=true,DancePanel=true,CarryPanel=true,DJWallComposerPanel=true}
local function hideOtherPanels()
 for _,d in ipairs(pg:GetDescendants()) do if d:IsA("GuiObject") and competing[d.Name] and d.Visible then d.Visible=false end end
 local role=pg:FindFirstChild("BBYARolePanelUI");local shade=role and role:FindFirstChild("Shade",true);if shade and shade:IsA("GuiObject") then shade.Visible=false end
 local menu=pg:FindFirstChild("BBYACommandMenuUI");if menu then local drawer=menu:FindFirstChild("FeatureDrawer",true);local mb=menu:FindFirstChild("MenuButton",true);if drawer and drawer:IsA("GuiObject")then drawer.Visible=false end;if mb and mb:IsA("TextButton")then mb.Text="MENU" end end
end
local function togglePanel()panel.Visible=not panel.Visible;if panel.Visible then hideOtherPanels() end end

local function installMenuEntry()
 local menu=pg:WaitForChild("BBYACommandMenuUI",30);if not menu then return false end
 local grid=menu:FindFirstChildWhichIsA("UIGridLayout",true);if not grid or not grid.Parent then return false end
 local body=grid.Parent;local oldSlot=body:FindFirstChild("Slot_DJ_LIVE");if oldSlot then oldSlot:Destroy() end
 local slot=Instance.new("Frame");slot.Name="Slot_DJ_LIVE";slot.LayoutOrder=10;slot.BackgroundColor3=C.card;slot.BorderSizePixel=0;slot.ZIndex=202;slot.Parent=body;corner(slot,9);stroke(slot,C.gold,.38)
 local b=Instance.new("TextButton");b.Name="DeveloperDJMenuButton";b.Size=UDim2.fromScale(1,1);b.BackgroundTransparency=1;b.Text="DJ LIVE";b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=8;b.ZIndex=206;b.Parent=slot;b.Activated:Connect(togglePanel)
 local drawer=menu:FindFirstChild("FeatureDrawer",true);if drawer and drawer:IsA("GuiObject")then drawer:GetPropertyChangedSignal("Visible"):Connect(function()if drawer.Visible and panel.Visible then panel.Visible=false end end)end
 return true
end
if not installMenuEntry() then local fallback=button(gui,"DJ LIVE",UDim2.new(1,-178,0,8),UDim2.fromOffset(72,36),C.gold);fallback.AnchorPoint=Vector2.new(1,0);fallback.ZIndex=580;fallback.Activated:Connect(togglePanel)end

print("[BBYA] Developer DJ Mixer client v2: FULLSCREEN VINYL + waveform + dual SYNC + 9 FX/deck")
