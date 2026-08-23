-- BBYA SOCIAL HUB — DEVELOPER DJ MIXER CLIENT v1
-- Compact two-deck controller for RR CreatorId + AMstudio only.
-- All players run the small local venue gate so the live mix is heard only in the selected venue.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

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
 local ch=player.Character
 local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 return hrp and venueAtPosition(hrp.Position) or "NONE"
end

local muteButton
local function resolveMuteButton()
 if muteButton and muteButton.Parent then return muteButton end
 local gui=pg:FindFirstChild("BBYAClubUI")
 if not gui then return nil end
 for _,d in ipairs(gui:GetDescendants()) do
  if d:IsA("TextButton") then
   local up=string.upper(d.Text or "")
   if up=="MUTE LOCAL" or up=="UNMUTE LOCAL" then muteButton=d;return d end
  end
 end
 return nil
end
local function locallyMuted()
 if player:GetAttribute("BBYAMusicMuted")==true then return true end
 local b=resolveMuteButton()
 return b and string.upper(b.Text or "")=="UNMUTE LOCAL" or false
end

local djGates={}
local function ensureDJGate(g)
 local gate=djGates[g]
 if gate and gate.Parent==g then return gate end
 gate=g:FindFirstChild("BBYADeveloperDJVenueGateV1")
 if gate and not gate:IsA("EqualizerSoundEffect") then gate:Destroy();gate=nil end
 if not gate then gate=Instance.new("EqualizerSoundEffect");gate.Name="BBYADeveloperDJVenueGateV1";gate.Parent=g end
 gate.Enabled=true;djGates[g]=gate;return gate
end
local function enforceDJAudio()
 local here=currentVenue()
 local muted=locallyMuted()
 for _,g in ipairs(SoundService:GetChildren()) do
  if g:IsA("SoundGroup") and g:GetAttribute("BBYADeveloperDJ")==true then
   local gate=ensureDJGate(g)
   local open=(g:GetAttribute("Live")==true and g:GetAttribute("Venue")==here and not muted)
   local gain=open and 0 or -80
   gate.LowGain=gain;gate.MidGain=gain;gate.HighGain=gain
   g:SetAttribute("BBYALocalAudible",open)
  end
 end
end
local gateAcc=0
RunService.Heartbeat:Connect(function(dt)
 gateAcc+=dt
 if gateAcc>=.1 then gateAcc=0;enforceDJAudio() end
end)
SoundService.ChildAdded:Connect(function(child)if child:IsA("SoundGroup") then task.defer(enforceDJAudio) end end)
player.CharacterAdded:Connect(function()task.delay(.3,enforceDJAudio)end)

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
if not remotes then return end
local actionRemote=remotes:WaitForChild("DeveloperDJAction",30)
local stateRemote=remotes:WaitForChild("DeveloperDJState",30)
local getState=remotes:WaitForChild("DeveloperDJGetState",30)
if not actionRemote or not stateRemote or not getState then return end

local ok,initial=pcall(function()return getState:InvokeServer()end)
if not ok or type(initial)~="table" or initial.authorized~=true then return end

local old=pg:FindFirstChild("BBYADeveloperDJUI")
if old then old:Destroy() end

local C={
 bg=Color3.fromRGB(8,9,13),panel=Color3.fromRGB(15,16,22),card=Color3.fromRGB(23,25,33),line=Color3.fromRGB(67,71,85),
 white=Color3.fromRGB(247,247,250),muted=Color3.fromRGB(148,153,169),pink=Color3.fromRGB(235,48,163),
 cyan=Color3.fromRGB(47,199,225),gold=Color3.fromRGB(226,178,88),purple=Color3.fromRGB(145,84,255),
 green=Color3.fromRGB(72,211,132),red=Color3.fromRGB(235,76,91),
}
local function corner(o,r)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 8);x.Parent=o;return x end
local function stroke(o,c,t)local x=Instance.new("UIStroke");x.Color=c or C.line;x.Thickness=1;x.Transparency=t or .45;x.Parent=o;return x end
local function label(parent,text,pos,size,font,ts,color,align)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham
 l.TextSize=ts or 9;l.TextColor3=color or C.white;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center
 l.TextTruncate=Enum.TextTruncate.AtEnd;l.ZIndex=405;l.Parent=parent;return l
end
local function button(parent,text,pos,size,accent)
 local b=Instance.new("TextButton");b.BackgroundColor3=C.card;b.BorderSizePixel=0;b.Text=text;b.Position=pos;b.Size=size;b.Font=Enum.Font.GothamBold
 b.TextSize=8;b.TextColor3=C.white;b.AutoButtonColor=true;b.ZIndex=406;b.Parent=parent;corner(b,7);stroke(b,accent or C.line,.55);return b
end

local gui=Instance.new("ScreenGui")
gui.Name="BBYADeveloperDJUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=232;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
gui:SetAttribute("AccessPolicy","RR_CREATOR_ID_PLUS_AMSTUDIO_ONLY")

local panel=Instance.new("Frame")
panel.Name="DeveloperDJMixerPanel";panel.AnchorPoint=Vector2.new(1,0);panel.Position=UDim2.new(1,-96,0,8);panel.Size=UDim2.fromOffset(356,500)
panel.BackgroundColor3=C.bg;panel.BackgroundTransparency=.02;panel.BorderSizePixel=0;panel.Visible=false;panel.ZIndex=400;panel.Parent=gui;corner(panel,15);stroke(panel,C.pink,.22)

local scale=Instance.new("UIScale");scale.Scale=1;scale.Parent=panel
local function layoutScale()
 local cam=workspace.CurrentCamera
 local vp=cam and cam.ViewportSize or Vector2.new(1280,720)
 scale.Scale=math.clamp(math.min((vp.X-110)/356,(vp.Y-16)/500),.72,1)
 panel.Position=UDim2.new(1,-96,0,8)
end
layoutScale()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()task.defer(layoutScale)end)
RunService.RenderStepped:Connect(function()if panel.Visible then layoutScale() end end)

local header=Instance.new("Frame");header.Position=UDim2.fromOffset(9,9);header.Size=UDim2.new(1,-18,0,40);header.BackgroundColor3=C.panel;header.BorderSizePixel=0;header.ZIndex=402;header.Parent=panel;corner(header,10);stroke(header,C.line,.55)
label(header,"DJ LIVE",UDim2.fromOffset(11,3),UDim2.fromOffset(120,18),Enum.Font.GothamBlack,13,C.white)
local statusLabel=label(header,"STANDBY",UDim2.fromOffset(11,20),UDim2.fromOffset(210,14),Enum.Font.GothamBold,8,C.muted)
local close=button(header,"×",UDim2.new(1,-34,0,6),UDim2.fromOffset(27,27),C.red);close.TextSize=15
close.Activated:Connect(function()panel.Visible=false end)

local venueCard=Instance.new("Frame");venueCard.Position=UDim2.fromOffset(9,56);venueCard.Size=UDim2.new(1,-18,0,56);venueCard.BackgroundColor3=C.panel;venueCard.BorderSizePixel=0;venueCard.ZIndex=402;venueCard.Parent=panel;corner(venueCard,10);stroke(venueCard,C.line,.62)
label(venueCard,"OUTPUT VENUE",UDim2.fromOffset(8,2),UDim2.fromOffset(120,14),Enum.Font.GothamBold,7,C.muted)
local venueNames={{"MAIN","MAIN"},{"UNDER","UNDERGROUND"},{"VIP","VIP"},{"FUNKOT","FUNKOT"},{"SKATE","SKATEPARK"},{"ROOF","ROOFTOP"}}
local venueButtons={}
for i,spec in ipairs(venueNames) do
 local labelText=spec[1]
 local venueKey=spec[2]
 local col=(i-1)%3;local row=math.floor((i-1)/3)
 local b=button(venueCard,labelText,UDim2.fromOffset(8+col*109,18+row*18),UDim2.fromOffset(101,16),C.gold)
 b.TextSize=7;venueButtons[venueKey]=b
 b.Activated:Connect(function()actionRemote:FireServer("venue",{value=venueKey})end)
end

local current=initial
local deckUI={}
local eqCycle={-12,-6,0,3,6}
local function nextEq(v)
 local best=3
 for i,n in ipairs(eqCycle) do if math.abs((tonumber(v) or 0)-n)<.1 then best=i;break end end
 return eqCycle[(best%#eqCycle)+1]
end
local function fmtTime(sec)
 sec=math.max(0,math.floor(tonumber(sec) or 0));return string.format("%d:%02d",math.floor(sec/60),sec%60)
end

local function createDeck(deck,x,accent)
 local card=Instance.new("Frame");card.Name="Deck"..deck;card.Position=UDim2.fromOffset(x,120);card.Size=UDim2.fromOffset(166,270);card.BackgroundColor3=C.panel;card.BorderSizePixel=0;card.ZIndex=402;card.Parent=panel;corner(card,11);stroke(card,accent,.4)
 label(card,"DECK "..deck,UDim2.fromOffset(9,5),UDim2.fromOffset(70,18),Enum.Font.GothamBlack,11,accent)
 local time=label(card,"0:00",UDim2.new(1,-59,0,5),UDim2.fromOffset(50,18),Enum.Font.GothamBold,8,C.muted,Enum.TextXAlignment.Right)
 local title=label(card,"EMPTY",UDim2.fromOffset(9,25),UDim2.new(1,-18,0,28),Enum.Font.GothamBold,8,C.white);title.TextWrapped=true;title.TextTruncate=Enum.TextTruncate.AtEnd
 local box=Instance.new("TextBox");box.Position=UDim2.fromOffset(9,57);box.Size=UDim2.new(1,-18,0,27);box.BackgroundColor3=C.card;box.BorderSizePixel=0;box.PlaceholderText="Roblox Audio Asset ID";box.Text="";box.ClearTextOnFocus=false;box.Font=Enum.Font.Gotham;box.TextSize=8;box.TextColor3=C.white;box.PlaceholderColor3=C.muted;box.ZIndex=406;box.Parent=card;corner(box,7);stroke(box,accent,.72)
 local load=button(card,"LOAD",UDim2.fromOffset(9,88),UDim2.new(1,-18,0,25),accent)
 local play=button(card,"PLAY",UDim2.fromOffset(9,117),UDim2.fromOffset(47,27),accent)
 local cue=button(card,"CUE",UDim2.fromOffset(60,117),UDim2.fromOffset(45,27),C.gold)
 local setCue=button(card,"SET",UDim2.fromOffset(109,117),UDim2.fromOffset(48,27),C.gold)
 local volMinus=button(card,"−",UDim2.fromOffset(9,149),UDim2.fromOffset(31,27),accent);volMinus.TextSize=12
 local vol=button(card,"VOL 85",UDim2.fromOffset(44,149),UDim2.fromOffset(77,27),accent)
 local volPlus=button(card,"+",UDim2.fromOffset(125,149),UDim2.fromOffset(32,27),accent);volPlus.TextSize=11
 local pitchMinus=button(card,"−",UDim2.fromOffset(9,181),UDim2.fromOffset(31,27),C.cyan);pitchMinus.TextSize=12
 local pitch=button(card,"1.00x",UDim2.fromOffset(44,181),UDim2.fromOffset(77,27),C.cyan)
 local pitchPlus=button(card,"+",UDim2.fromOffset(125,181),UDim2.fromOffset(32,27),C.cyan);pitchPlus.TextSize=11
 local low=button(card,"LOW 0",UDim2.fromOffset(9,213),UDim2.fromOffset(47,25),C.gold)
 local mid=button(card,"MID 0",UDim2.fromOffset(60,213),UDim2.fromOffset(45,25),C.gold)
 local high=button(card,"HI 0",UDim2.fromOffset(109,213),UDim2.fromOffset(48,25),C.gold)
 local echo=button(card,"ECHO",UDim2.fromOffset(9,242),UDim2.fromOffset(72,20),C.pink)
 local reverb=button(card,"REVERB",UDim2.fromOffset(85,242),UDim2.fromOffset(72,20),C.purple)

 load.Activated:Connect(function()if box.Text~="" then actionRemote:FireServer("load",{deck=deck,assetId=box.Text})end end)
 play.Activated:Connect(function()actionRemote:FireServer("play_toggle",{deck=deck})end)
 cue.Activated:Connect(function()actionRemote:FireServer("cue",{deck=deck})end)
 setCue.Activated:Connect(function()actionRemote:FireServer("set_cue",{deck=deck})end)
 volMinus.Activated:Connect(function()local d=current.decks and current.decks[deck];if d then actionRemote:FireServer("volume",{deck=deck,value=(d.volume or .85)-.05})end end)
 volPlus.Activated:Connect(function()local d=current.decks and current.decks[deck];if d then actionRemote:FireServer("volume",{deck=deck,value=(d.volume or .85)+.05})end end)
 vol.Activated:Connect(function()actionRemote:FireServer("volume",{deck=deck,value=.85})end)
 pitchMinus.Activated:Connect(function()local d=current.decks and current.decks[deck];if d then actionRemote:FireServer("pitch",{deck=deck,value=(d.pitch or 1)-.01})end end)
 pitchPlus.Activated:Connect(function()local d=current.decks and current.decks[deck];if d then actionRemote:FireServer("pitch",{deck=deck,value=(d.pitch or 1)+.01})end end)
 pitch.Activated:Connect(function()actionRemote:FireServer("pitch",{deck=deck,value=1})end)
 for band,b in pairs({low=low,mid=mid,high=high}) do
  local bandKey=band
  local eqButton=b
  eqButton.Activated:Connect(function()
   local d=current.decks and current.decks[deck]
   if d then actionRemote:FireServer("eq",{deck=deck,band=bandKey,value=nextEq(d[bandKey])})end
  end)
 end
 echo.Activated:Connect(function()local d=current.decks and current.decks[deck];if d then actionRemote:FireServer("echo",{deck=deck,value=not d.echo})end end)
 reverb.Activated:Connect(function()local d=current.decks and current.decks[deck];if d then actionRemote:FireServer("reverb",{deck=deck,value=not d.reverb})end end)

 deckUI[deck]={title=title,time=time,box=box,play=play,vol=vol,pitch=pitch,low=low,mid=mid,high=high,echo=echo,reverb=reverb,accent=accent}
end
createDeck("A",9,C.pink)
createDeck("B",181,C.cyan)

local crossCard=Instance.new("Frame");crossCard.Position=UDim2.fromOffset(9,397);crossCard.Size=UDim2.new(1,-18,0,44);crossCard.BackgroundColor3=C.panel;crossCard.BorderSizePixel=0;crossCard.ZIndex=402;crossCard.Parent=panel;corner(crossCard,10);stroke(crossCard,C.line,.6)
label(crossCard,"A",UDim2.fromOffset(9,4),UDim2.fromOffset(18,14),Enum.Font.GothamBlack,9,C.pink)
label(crossCard,"CROSSFADER",UDim2.fromOffset(115,3),UDim2.fromOffset(105,14),Enum.Font.GothamBold,7,C.muted,Enum.TextXAlignment.Center)
label(crossCard,"B",UDim2.new(1,-27,0,4),UDim2.fromOffset(18,14),Enum.Font.GothamBlack,9,C.cyan,Enum.TextXAlignment.Right)
local crossBar=Instance.new("Frame");crossBar.Position=UDim2.fromOffset(22,23);crossBar.Size=UDim2.new(1,-44,0,7);crossBar.BackgroundColor3=C.card;crossBar.BorderSizePixel=0;crossBar.ZIndex=405;crossBar.Parent=crossCard;corner(crossBar,4)
local crossFill=Instance.new("Frame");crossFill.Size=UDim2.fromScale(.5,1);crossFill.BackgroundColor3=C.pink;crossFill.BorderSizePixel=0;crossFill.ZIndex=406;crossFill.Parent=crossBar;corner(crossFill,4)
local knob=Instance.new("Frame");knob.AnchorPoint=Vector2.new(.5,.5);knob.Position=UDim2.new(.5,0,.5,0);knob.Size=UDim2.fromOffset(14,14);knob.BackgroundColor3=C.white;knob.BorderSizePixel=0;knob.ZIndex=407;knob.Parent=crossBar;corner(knob,7);stroke(knob,C.cyan,.25)
local dragging=false
local function setCrossFromX(x)
 local abs=crossBar.AbsolutePosition.X;local w=math.max(1,crossBar.AbsoluteSize.X);local v=math.clamp((x-abs)/w,0,1)
 actionRemote:FireServer("crossfader",{value=v})
end
crossBar.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true;setCrossFromX(input.Position.X) end end)
UserInputService.InputChanged:Connect(function(input)if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then setCrossFromX(input.Position.X) end end)
UserInputService.InputEnded:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)

local liveButton=button(panel,"GO LIVE",UDim2.fromOffset(9,448),UDim2.fromOffset(223,40),C.green);liveButton.Font=Enum.Font.GothamBlack;liveButton.TextSize=10
local sourceNote=label(panel,"ROBLOX ASSET IDs ONLY",UDim2.fromOffset(239,448),UDim2.fromOffset(108,40),Enum.Font.GothamBold,7,C.muted,Enum.TextXAlignment.Center);sourceNote.TextWrapped=true
liveButton.Activated:Connect(function()if current.live then actionRemote:FireServer("end_live",{}) else actionRemote:FireServer("go_live",{}) end end)

local function updateUI(s)
 if type(s)~="table" then return end
 current=s
 statusLabel.Text=s.live and ("LIVE • "..tostring(s.venue).." • "..tostring(s.operator or "DEV")) or ("STANDBY • "..tostring(s.venue))
 statusLabel.TextColor3=s.live and C.green or C.muted
 liveButton.Text=s.live and "END LIVE" or "GO LIVE"
 liveButton.TextColor3=s.live and C.red or C.white
 for venue,b in pairs(venueButtons) do
  local selected=s.venue==venue
  b.BackgroundColor3=selected and C.gold or C.card;b.TextColor3=selected and Color3.fromRGB(20,18,12) or C.white
 end
 local x=math.clamp(tonumber(s.crossfader) or .5,0,1)
 knob.Position=UDim2.new(x,0,.5,0);crossFill.Size=UDim2.new(x,0,1,0)
 for deck,u in pairs(deckUI) do
  local d=s.decks and s.decks[deck]
  if d then
   u.title.Text=(d.preloaded and "● " or "")..tostring(d.title or ("AUDIO #"..tostring(d.assetId or 0)))
   u.time.Text=fmtTime(d.timePosition)
   u.play.Text=d.playing and "PAUSE" or "PLAY"
   u.vol.Text=string.format("VOL %d",math.floor((tonumber(d.volume) or 0)*100+.5))
   u.pitch.Text=string.format("%.2fx",tonumber(d.pitch) or 1)
   u.low.Text="LOW "..tostring(math.floor(tonumber(d.low) or 0));u.mid.Text="MID "..tostring(math.floor(tonumber(d.mid) or 0));u.high.Text="HI "..tostring(math.floor(tonumber(d.high) or 0))
   u.echo.BackgroundColor3=d.echo and C.pink or C.card;u.reverb.BackgroundColor3=d.reverb and C.purple or C.card
  end
 end
end
stateRemote.OnClientEvent:Connect(updateUI)
updateUI(initial)

local competing={HubPanel=true,CompactMusicCardV7=true,PlaylistDrawerV7=true,CommunityPanel=true,DancePanel=true,CarryPanel=true,DJWallComposerPanel=true}
local function isRoleShade(d)
 return d.Name=="Shade" and d:FindFirstAncestor("BBYARolePanelUI")~=nil
end
local function hideOtherPanels()
 for _,d in ipairs(pg:GetDescendants()) do
  if d:IsA("GuiObject") and ((competing[d.Name] and d.Visible) or (isRoleShade(d) and d.Visible)) then d.Visible=false end
 end
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 if menu then
  local drawer=menu:FindFirstChild("FeatureDrawer",true)
  local mb=menu:FindFirstChild("MenuButton",true)
  if drawer and drawer:IsA("GuiObject") then drawer.Visible=false end
  if mb and mb:IsA("TextButton") then mb.Text="MENU" end
 end
end
local watched={}
local function watchCompeting(d)
 if watched[d] or not d:IsA("GuiObject") then return end
 if not competing[d.Name] and not isRoleShade(d) then return end
 watched[d]=true
 d:GetPropertyChangedSignal("Visible"):Connect(function()if d.Visible and panel.Visible then panel.Visible=false end end)
end
for _,d in ipairs(pg:GetDescendants()) do watchCompeting(d) end
pg.DescendantAdded:Connect(function(d)task.defer(function()watchCompeting(d)end)end)
panel:GetPropertyChangedSignal("Visible"):Connect(function()if panel.Visible then hideOtherPanels();layoutScale() end end)

local function togglePanel()
 panel.Visible=not panel.Visible
 if panel.Visible then hideOtherPanels() end
end

local function installMenuEntry()
 local menu=pg:WaitForChild("BBYACommandMenuUI",30)
 if not menu then return false end
 local grid=menu:FindFirstChildWhichIsA("UIGridLayout",true)
 if not grid or not grid.Parent then return false end
 local body=grid.Parent
 local existing=body:FindFirstChild("Slot_DJ_LIVE")
 if existing then existing:Destroy() end
 local slot=Instance.new("Frame");slot.Name="Slot_DJ_LIVE";slot.LayoutOrder=10;slot.BackgroundColor3=C.card;slot.BorderSizePixel=0;slot.ZIndex=202;slot.Parent=body;corner(slot,9);stroke(slot,C.gold,.45)
 local b=Instance.new("TextButton");b.Name="DeveloperDJMenuButton";b.Size=UDim2.fromScale(1,1);b.BackgroundTransparency=1;b.Text="DJ LIVE";b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=8;b.ZIndex=206;b.Parent=slot
 b.Activated:Connect(togglePanel)
 local drawer=menu:FindFirstChild("FeatureDrawer",true)
 if drawer and drawer:IsA("GuiObject") then
  drawer:GetPropertyChangedSignal("Visible"):Connect(function()if drawer.Visible and panel.Visible then panel.Visible=false end end)
 end
 return true
end

if not installMenuEntry() then
 local fallback=button(gui,"DJ LIVE",UDim2.new(1,-178,0,8),UDim2.fromOffset(72,36),C.gold)
 fallback.AnchorPoint=Vector2.new(1,0);fallback.ZIndex=450;fallback.Activated:Connect(togglePanel)
end

print("[BBYA] Developer DJ Mixer client v1: compact two-deck panel + local venue gate active")
