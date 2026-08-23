-- BBYA SOCIAL HUB — DEVELOPER DJ MIXER CLIENT v3
-- Full-screen landscape performance console for RR CreatorId + AMstudio only.
-- UX lock: vinyl is the hero, PLAYLIST is deck-local, FX lives in a popup.
-- PLAYLIST A -> tap track -> load A. PLAYLIST B -> tap track -> load B.
-- Cover art uses Roblox asset thumbnails only; no generated artwork.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

-- Keep live DJ output physically isolated to the selected venue for EVERY client.
-- This authority must run before the developer UI authorization return below.
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
local function locallyMuted()
 if player:GetAttribute("BBYAMusicMuted")==true then return true end
 if not (muteButton and muteButton.Parent) then
  local club=pg:FindFirstChild("BBYAClubUI")
  if club then
   for _,d in ipairs(club:GetDescendants()) do
    if d:IsA("TextButton") then
     local up=string.upper(d.Text or "")
     if up=="MUTE LOCAL" or up=="UNMUTE LOCAL" then muteButton=d break end
    end
   end
  end
 end
 return muteButton and string.upper(muteButton.Text or "")=="UNMUTE LOCAL" or false
end

local djGates={}
local function enforceDJAudio()
 local here=currentVenue()
 local muted=locallyMuted()
 for _,g in ipairs(SoundService:GetChildren()) do
  if g:IsA("SoundGroup") and g:GetAttribute("BBYADeveloperDJ")==true then
   local gate=djGates[g]
   if not (gate and gate.Parent==g) then
    gate=g:FindFirstChild("BBYADeveloperDJVenueGateV3") or g:FindFirstChild("BBYADeveloperDJVenueGateV2") or g:FindFirstChild("BBYADeveloperDJVenueGateV1")
    if gate and not gate:IsA("EqualizerSoundEffect") then gate:Destroy();gate=nil end
    if not gate then gate=Instance.new("EqualizerSoundEffect");gate.Parent=g end
    gate.Name="BBYADeveloperDJVenueGateV3"
    gate.Enabled=true
    djGates[g]=gate
   end
   local open=g:GetAttribute("Live")==true and g:GetAttribute("Venue")==here and not muted
   local gain=open and 0 or -80
   gate.LowGain=gain;gate.MidGain=gain;gate.HighGain=gain
   g:SetAttribute("BBYALocalAudible",open)
  end
 end
end
local gateAcc=0
RunService.Heartbeat:Connect(function(dt)
 gateAcc+=dt
 if gateAcc>=.1 then gateAcc=0 enforceDJAudio() end
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
 bg=Color3.fromRGB(5,6,9),panel=Color3.fromRGB(12,13,18),card=Color3.fromRGB(22,24,31),card2=Color3.fromRGB(29,31,40),
 line=Color3.fromRGB(61,65,79),white=Color3.fromRGB(247,247,250),muted=Color3.fromRGB(145,151,168),
 pink=Color3.fromRGB(245,42,145),cyan=Color3.fromRGB(18,195,235),gold=Color3.fromRGB(235,188,74),
 purple=Color3.fromRGB(138,68,246),green=Color3.fromRGB(69,220,129),red=Color3.fromRGB(239,65,84),black=Color3.fromRGB(3,3,5),
}
local function corner(o,r)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 8);x.Parent=o;return x end
local function circle(o)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(1,0);x.Parent=o;return x end
local function stroke(o,c,t,th)local x=Instance.new("UIStroke");x.Color=c or C.line;x.Transparency=t or .5;x.Thickness=th or 1;x.Parent=o;return x end
local function label(parent,name,text,pos,size,font,ts,color,align,z)
 local l=Instance.new("TextLabel");l.Name=name;l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham
 l.TextSize=ts or 11;l.TextColor3=color or C.white;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center
 l.TextTruncate=Enum.TextTruncate.AtEnd;l.ZIndex=z or 504;l.Parent=parent;return l
end
local function button(parent,name,text,pos,size,accent,z)
 local b=Instance.new("TextButton");b.Name=name;b.BackgroundColor3=C.card;b.BorderSizePixel=0;b.Text=text;b.Position=pos;b.Size=size;b.Font=Enum.Font.GothamBold
 b.TextSize=10;b.TextColor3=C.white;b.AutoButtonColor=true;b.ZIndex=z or 506;b.Parent=parent;corner(b,9);stroke(b,accent or C.line,.48,1);return b
end
local function thumb(assetId,size)
 local id=tonumber(assetId)
 if not id or id<1 then return "" end
 local px=size or 420
 return string.format("rbxthumb://type=Asset&id=%d&w=%d&h=%d",id,px,px)
end
local function deckAccent(deck)return deck=="A" and C.pink or C.cyan end

-- Only assets already approved + permissioned for BBYA are exposed to live performance.
-- Rejected/PREPARED_LOCAL audio is deliberately absent from this library.
local DJ_LIBRARY={
 {title="Wonder Girls - Nobody (ROOKIE Amapiano Edit)",assetId=105859685125263,genre="AMAPIANO",key="D# MINOR",camelot="2A"},
 {title="Utopia - Baby Doll (Phatbee Edit)",assetId=136681158481930,genre="AMAPIANO",key="G MAJOR",camelot="9B"},
 {title="Tiket - Hanya Kamu yg Bisa (Phatbee & Berco Edit)",assetId=131557279061872,genre="AMAPIANO",key="A MAJOR",camelot="11B"},
}

local FX={
 {"ECHO","echo","toggle"},{"REVERB","reverb","toggle"},{"FILTER","filter","toggle"},
 {"FLANGE","flange","toggle"},{"CHORUS","chorus","toggle"},{"DISTORT","distort","toggle"},
 {"BRAKE","BRAKE","trigger"},{"ROLL 1/2","ROLL_HALF","trigger"},{"ROLL 1/4","ROLL_QUARTER","trigger"},
}

local gui=Instance.new("ScreenGui")
gui.Name="BBYADeveloperDJUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=false;gui.DisplayOrder=500;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
gui:SetAttribute("BBYADeveloperDJUIVersion","V3_FULLSCREEN_VINYL_PLAYLIST")
gui:SetAttribute("AccessPolicy","RR_CREATOR_ID_PLUS_AMSTUDIO_ONLY")

local panel=Instance.new("Frame")
panel.Name="DeveloperDJMixerPanel";panel.Position=UDim2.fromScale(0,0);panel.Size=UDim2.fromScale(1,1);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Visible=false;panel.ZIndex=500;panel.Parent=gui

local header=Instance.new("Frame");header.Name="Header";header.Size=UDim2.new(1,0,.10,0);header.BackgroundColor3=C.panel;header.BorderSizePixel=0;header.ZIndex=502;header.Parent=panel
label(header,"Brand","BBYA DJ LIVE",UDim2.new(.018,0,.08,0),UDim2.new(.18,0,.42,0),Enum.Font.GothamBlack,17,C.white)
local statusLabel=label(header,"Status","STANDBY • MAIN",UDim2.new(.018,0,.50,0),UDim2.new(.20,0,.34,0),Enum.Font.GothamBold,9,C.muted)
local venueBar=Instance.new("Frame");venueBar.Name="VenueBar";venueBar.Position=UDim2.new(.205,0,.18,0);venueBar.Size=UDim2.new(.47,0,.62,0);venueBar.BackgroundTransparency=1;venueBar.ZIndex=503;venueBar.Parent=header
local venues={{"MAIN","MAIN"},{"UNDER","UNDERGROUND"},{"VIP","VIP"},{"FUNKOT","FUNKOT"},{"SKATE","SKATEPARK"},{"ROOF","ROOFTOP"}}
local venueButtons={}
for i,spec in ipairs(venues) do
 local key=spec[2]
 local b=button(venueBar,"Venue_"..key,spec[1],UDim2.new((i-1)/6+.004,0,0,0),UDim2.new(1/6-.008,0,1,0),C.gold,506)
 b.TextSize=8;venueButtons[key]=b
 b.Activated:Connect(function()actionRemote:FireServer("venue",{value=key})end)
end
local liveButton=button(header,"LiveButton","GO LIVE",UDim2.new(.70,0,.18,0),UDim2.new(.12,0,.62,0),C.green,507);liveButton.Font=Enum.Font.GothamBlack;liveButton.TextSize=11
local close=button(header,"CloseButton","CLOSE",UDim2.new(.84,0,.18,0),UDim2.new(.13,0,.62,0),C.red,507);close.TextSize=9
close.Activated:Connect(function()panel.Visible=false end)

local current=initial
local deckUI={}
local playlistTarget=nil
local fxTarget=nil
local advancedTarget=nil

local function fmtTime(sec)
 sec=math.max(0,math.floor(tonumber(sec) or 0))
 return string.format("%d:%02d",math.floor(sec/60),sec%60)
end

local function makeWave(parent,accent)
 local wave=Instance.new("Frame");wave.Name="Waveform";wave.BackgroundColor3=Color3.fromRGB(8,9,13);wave.BorderSizePixel=0;wave.ClipsDescendants=true;wave.ZIndex=503;wave.Parent=parent;corner(wave,8);stroke(wave,accent,.72)
 for i=1,48 do
  local h=.18+(((i*37)%80)/100)*.72
  local bar=Instance.new("Frame");bar.AnchorPoint=Vector2.new(0,.5);bar.Position=UDim2.new((i-1)/48+.002,0,.5,0);bar.Size=UDim2.new(1/48-.004,0,h,0);bar.BackgroundColor3=accent;bar.BackgroundTransparency=.22;bar.BorderSizePixel=0;bar.ZIndex=504;bar.Parent=wave
 end
 local playhead=Instance.new("Frame");playhead.Name="Playhead";playhead.AnchorPoint=Vector2.new(.5,0);playhead.Position=UDim2.new(0,0,0,0);playhead.Size=UDim2.new(0,2,1,0);playhead.BackgroundColor3=C.white;playhead.BorderSizePixel=0;playhead.ZIndex=506;playhead.Parent=wave
 return wave,playhead
end

local function makeVinyl(parent,deck,accent)
 local holder=Instance.new("Frame");holder.Name="VinylHero";holder.BackgroundTransparency=1;holder.ZIndex=503;holder.Parent=parent
 local vinyl=Instance.new("Frame");vinyl.Name="Vinyl";vinyl.AnchorPoint=Vector2.new(.5,.5);vinyl.Position=UDim2.fromScale(.5,.5);vinyl.Size=UDim2.fromScale(.93,.93);vinyl.BackgroundColor3=C.black;vinyl.BorderSizePixel=0;vinyl.ZIndex=504;vinyl.Parent=holder;circle(vinyl);stroke(vinyl,accent,.45,2)
 local ratio=Instance.new("UIAspectRatioConstraint");ratio.AspectRatio=1;ratio.AspectType=Enum.AspectType.FitWithinMaxSize;ratio.DominantAxis=Enum.DominantAxis.Width;ratio.Parent=vinyl
 for _,scale in ipairs({.84,.73,.62,.51,.40}) do
  local groove=Instance.new("Frame");groove.AnchorPoint=Vector2.new(.5,.5);groove.Position=UDim2.fromScale(.5,.5);groove.Size=UDim2.fromScale(scale,scale);groove.BackgroundTransparency=1;groove.ZIndex=505;groove.Parent=vinyl;circle(groove);stroke(groove,Color3.fromRGB(68,71,82),.60,1)
 end
 local center=Instance.new("Frame");center.Name="CenterLabel";center.AnchorPoint=Vector2.new(.5,.5);center.Position=UDim2.fromScale(.5,.5);center.Size=UDim2.fromScale(.34,.34);center.BackgroundColor3=accent;center.BorderSizePixel=0;center.ZIndex=507;center.Parent=vinyl;circle(center);stroke(center,C.white,.72)
 local cover=Instance.new("ImageLabel");cover.Name="TrackCover";cover.Size=UDim2.fromScale(1,1);cover.BackgroundTransparency=1;cover.Image="";cover.ScaleType=Enum.ScaleType.Crop;cover.ZIndex=508;cover.Parent=center;circle(cover)
 local fallback=label(center,"DeckLetter",deck,UDim2.fromScale(0,0),UDim2.fromScale(1,1),Enum.Font.GothamBlack,38,C.white,Enum.TextXAlignment.Center,509)
 local spindle=Instance.new("Frame");spindle.AnchorPoint=Vector2.new(.5,.5);spindle.Position=UDim2.fromScale(.5,.5);spindle.Size=UDim2.fromScale(.045,.045);spindle.BackgroundColor3=C.white;spindle.BorderSizePixel=0;spindle.ZIndex=510;spindle.Parent=vinyl;circle(spindle)
 local marker=Instance.new("Frame");marker.AnchorPoint=Vector2.new(.5,.5);marker.Position=UDim2.fromScale(.5,.08);marker.Size=UDim2.fromScale(.025,.09);marker.BackgroundColor3=accent;marker.BorderSizePixel=0;marker.ZIndex=510;marker.Parent=vinyl;corner(marker,3)
 return holder,vinyl,cover,fallback
end

-- Modal shade shared by PLAYLIST / FX / advanced Asset ID.
local shade=Instance.new("Frame");shade.Name="ModalShade";shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=Color3.fromRGB(0,0,0);shade.BackgroundTransparency=.28;shade.BorderSizePixel=0;shade.Visible=false;shade.ZIndex=600;shade.Parent=panel

local playlistPopup=Instance.new("Frame");playlistPopup.Name="PlaylistPopup";playlistPopup.AnchorPoint=Vector2.new(.5,.5);playlistPopup.Position=UDim2.fromScale(.5,.53);playlistPopup.Size=UDim2.new(.68,0,.72,0);playlistPopup.BackgroundColor3=C.panel;playlistPopup.BorderSizePixel=0;playlistPopup.Visible=false;playlistPopup.ZIndex=610;playlistPopup.Parent=panel;corner(playlistPopup,16)
local playlistStroke=stroke(playlistPopup,C.pink,.20,2)
local playlistTitle=label(playlistPopup,"PlaylistTitle","PLAYLIST → DECK A",UDim2.new(.025,0,.02,0),UDim2.new(.70,0,.09,0),Enum.Font.GothamBlack,17,C.pink,Enum.TextXAlignment.Left,612)
local playlistCount=label(playlistPopup,"PlaylistCount",tostring(#DJ_LIBRARY).." APPROVED TRACKS",UDim2.new(.025,0,.095,0),UDim2.new(.55,0,.055,0),Enum.Font.GothamBold,9,C.muted,Enum.TextXAlignment.Left,612)
local playlistClose=button(playlistPopup,"PlaylistClose","CLOSE",UDim2.new(.83,0,.035,0),UDim2.new(.14,0,.08,0),C.red,614)
local playlistScroll=Instance.new("ScrollingFrame");playlistScroll.Name="PlaylistScroller";playlistScroll.Position=UDim2.new(.025,0,.17,0);playlistScroll.Size=UDim2.new(.95,0,.79,0);playlistScroll.BackgroundTransparency=1;playlistScroll.BorderSizePixel=0;playlistScroll.ScrollBarThickness=4;playlistScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;playlistScroll.CanvasSize=UDim2.fromOffset(0,0);playlistScroll.ZIndex=611;playlistScroll.Parent=playlistPopup
local playlistLayout=Instance.new("UIListLayout");playlistLayout.Padding=UDim.new(0,8);playlistLayout.SortOrder=Enum.SortOrder.LayoutOrder;playlistLayout.Parent=playlistScroll

local fxPopup=Instance.new("Frame");fxPopup.Name="FXPopup";fxPopup.AnchorPoint=Vector2.new(.5,.5);fxPopup.Position=UDim2.fromScale(.5,.53);fxPopup.Size=UDim2.new(.48,0,.60,0);fxPopup.BackgroundColor3=C.panel;fxPopup.BorderSizePixel=0;fxPopup.Visible=false;fxPopup.ZIndex=620;fxPopup.Parent=panel;corner(fxPopup,16)
local fxStroke=stroke(fxPopup,C.pink,.20,2)
local fxTitle=label(fxPopup,"FXTitle","FX → DECK A",UDim2.new(.04,0,.03,0),UDim2.new(.66,0,.10,0),Enum.Font.GothamBlack,17,C.pink,Enum.TextXAlignment.Left,622)
local fxClose=button(fxPopup,"FXClose","CLOSE",UDim2.new(.78,0,.04,0),UDim2.new(.18,0,.09,0),C.red,624)
local fxGrid=Instance.new("Frame");fxGrid.Name="FXGrid";fxGrid.Position=UDim2.new(.035,0,.17,0);fxGrid.Size=UDim2.new(.93,0,.78,0);fxGrid.BackgroundTransparency=1;fxGrid.ZIndex=621;fxGrid.Parent=fxPopup
local fxButtons={}
for i,spec in ipairs(FX) do
 local col=(i-1)%3;local row=math.floor((i-1)/3)
 local b=button(fxGrid,"FX_"..spec[2],spec[1],UDim2.new(col/3+.008,0,row/3+.025,0),UDim2.new(1/3-.016,0,1/3-.05,0),C.pink,624)
 b.Font=Enum.Font.GothamBlack;b.TextSize=10;fxButtons[spec[2]]=b
 local key=spec[2];local mode=spec[3]
 b.Activated:Connect(function()
  if not fxTarget then return end
  if mode=="toggle" then actionRemote:FireServer("fx_toggle",{deck=fxTarget,fx=key}) else actionRemote:FireServer("fx_trigger",{deck=fxTarget,fx=key}) end
  if mode=="trigger" then fxPopup.Visible=false;shade.Visible=false end
 end)
end

local idPopup=Instance.new("Frame");idPopup.Name="AdvancedIDPopup";idPopup.AnchorPoint=Vector2.new(.5,.5);idPopup.Position=UDim2.fromScale(.5,.53);idPopup.Size=UDim2.new(.42,0,.32,0);idPopup.BackgroundColor3=C.panel;idPopup.BorderSizePixel=0;idPopup.Visible=false;idPopup.ZIndex=630;idPopup.Parent=panel;corner(idPopup,16)
local idStroke=stroke(idPopup,C.pink,.20,2)
local idTitle=label(idPopup,"IDTitle","ADVANCED ID → DECK A",UDim2.new(.05,0,.06,0),UDim2.new(.72,0,.18,0),Enum.Font.GothamBlack,14,C.pink,Enum.TextXAlignment.Left,632)
local idClose=button(idPopup,"IDClose","×",UDim2.new(.87,0,.06,0),UDim2.new(.08,0,.18,0),C.red,634);idClose.TextSize=17
local idBox=Instance.new("TextBox");idBox.Name="AssetIDBox";idBox.Position=UDim2.new(.05,0,.34,0);idBox.Size=UDim2.new(.62,0,.24,0);idBox.BackgroundColor3=C.card;idBox.BorderSizePixel=0;idBox.PlaceholderText="ROBLOX AUDIO ASSET ID";idBox.Text="";idBox.ClearTextOnFocus=false;idBox.Font=Enum.Font.GothamBold;idBox.TextSize=11;idBox.TextColor3=C.white;idBox.PlaceholderColor3=C.muted;idBox.ZIndex=634;idBox.Parent=idPopup;corner(idBox,9);stroke(idBox,C.pink,.55)
local idLoad=button(idPopup,"IDLoad","LOAD A",UDim2.new(.70,0,.34,0),UDim2.new(.25,0,.24,0),C.pink,634);idLoad.Font=Enum.Font.GothamBlack;idLoad.TextSize=11
label(idPopup,"IDNote","Playlist is the primary load method. Use ID only for an approved asset not yet listed.",UDim2.new(.05,0,.66,0),UDim2.new(.90,0,.18,0),Enum.Font.Gotham,9,C.muted,Enum.TextXAlignment.Left,632).TextWrapped=true

local function closeModals()
 playlistPopup.Visible=false;fxPopup.Visible=false;idPopup.Visible=false;shade.Visible=false
end
playlistClose.Activated:Connect(closeModals);fxClose.Activated:Connect(closeModals);idClose.Activated:Connect(closeModals)
shade.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then closeModals() end end)

local function openPlaylist(deck)
 closeModals();playlistTarget=deck
 local accent=deckAccent(deck)
 playlistTitle.Text="PLAYLIST → DECK "..deck;playlistTitle.TextColor3=accent;playlistStroke.Color=accent
 shade.Visible=true;playlistPopup.Visible=true
end
local function openFX(deck)
 closeModals();fxTarget=deck
 local accent=deckAccent(deck)
 fxTitle.Text="FX → DECK "..deck;fxTitle.TextColor3=accent;fxStroke.Color=accent
 for _,b in pairs(fxButtons) do local s=b:FindFirstChildOfClass("UIStroke");if s then s.Color=accent end end
 shade.Visible=true;fxPopup.Visible=true
end
local function openID(deck)
 closeModals();advancedTarget=deck
 local accent=deckAccent(deck)
 idTitle.Text="ADVANCED ID → DECK "..deck;idTitle.TextColor3=accent;idStroke.Color=accent;idLoad.Text="LOAD "..deck
 local s=idLoad:FindFirstChildOfClass("UIStroke");if s then s.Color=accent end
 idBox.Text="";shade.Visible=true;idPopup.Visible=true
end
idLoad.Activated:Connect(function()
 if advancedTarget and idBox.Text~="" then actionRemote:FireServer("load",{deck=advancedTarget,assetId=idBox.Text});closeModals() end
end)

-- Build playlist rows once. Target deck is resolved at click time, so A/B can never be confused.
for i,item in ipairs(DJ_LIBRARY) do
 local row=Instance.new("TextButton");row.Name="Track_"..i;row.LayoutOrder=i;row.Size=UDim2.new(1,-6,0,72);row.BackgroundColor3=C.card;row.BorderSizePixel=0;row.Text="";row.AutoButtonColor=true;row.ZIndex=613;row.Parent=playlistScroll;corner(row,10);stroke(row,C.line,.55)
 local cover=Instance.new("ImageLabel");cover.Name="Cover";cover.Position=UDim2.fromOffset(8,8);cover.Size=UDim2.fromOffset(56,56);cover.BackgroundColor3=C.card2;cover.BorderSizePixel=0;cover.Image=thumb(item.assetId,420);cover.ScaleType=Enum.ScaleType.Crop;cover.ZIndex=614;cover.Parent=row;corner(cover,8)
 label(row,"Title",item.title,UDim2.fromOffset(76,8),UDim2.new(1,-168,0,30),Enum.Font.GothamBold,11,C.white,Enum.TextXAlignment.Left,614)
 label(row,"Meta",item.genre.." • "..item.key.." • "..item.camelot,UDim2.fromOffset(76,38),UDim2.new(1,-168,0,20),Enum.Font.GothamBold,8,C.muted,Enum.TextXAlignment.Left,614)
 local tap=label(row,"LoadHint","TAP TO LOAD",UDim2.new(1,-96,0,22),UDim2.fromOffset(82,28),Enum.Font.GothamBlack,8,C.white,Enum.TextXAlignment.Center,614);tap.BackgroundColor3=C.card2;tap.BackgroundTransparency=.12;corner(tap,7)
 row.Activated:Connect(function()
  local target=playlistTarget
  if not target then return end
  actionRemote:FireServer("load",{deck=target,assetId=item.assetId})
  closeModals()
 end)
end

local function createDeck(deck,isLeft,accent)
 local root=Instance.new("Frame");root.Name="Deck"..deck;root.Position=UDim2.new(isLeft and .012 or .506,0,.115,0);root.Size=UDim2.new(.482,0,.69,0);root.BackgroundColor3=C.panel;root.BorderSizePixel=0;root.ZIndex=502;root.Parent=panel;corner(root,13);stroke(root,accent,.35,2)
 -- Big deck identity, intentionally impossible to miss during live use.
 local big=label(root,"BigDeckLetter",deck,UDim2.new(isLeft and .02 or .83,0,.015,0),UDim2.new(.15,0,.12,0),Enum.Font.GothamBlack,34,accent,isLeft and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right,504)
 local deckText=label(root,"DeckTitle","DECK "..deck,UDim2.new(isLeft and .16 or .57,0,.025,0),UDim2.new(.26,0,.08,0),Enum.Font.GothamBlack,13,accent,isLeft and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right,504)
 local time=label(root,"Time","0:00 / 0:00",UDim2.new(.65,0,.04,0),UDim2.new(.31,0,.06,0),Enum.Font.GothamBold,9,C.muted,Enum.TextXAlignment.Right,504)
 if not isLeft then time.Position=UDim2.new(.04,0,.04,0);time.TextXAlignment=Enum.TextXAlignment.Left end

 local title=label(root,"TrackTitle","EMPTY",UDim2.new(.025,0,.13,0),UDim2.new(.95,0,.06,0),Enum.Font.GothamBold,11,C.white,Enum.TextXAlignment.Left,504)
 local wave,playhead=makeWave(root,accent);wave.Position=UDim2.new(.025,0,.20,0);wave.Size=UDim2.new(.95,0,.075,0)

 -- Main load button belongs to this deck; no secondary deck selection exists.
 local playlist=button(root,"PlaylistButton","PLAYLIST "..deck,UDim2.new(.025,0,.29,0),UDim2.new(.31,0,.075,0),accent,506);playlist.Font=Enum.Font.GothamBlack;playlist.TextSize=11
 local advanced=button(root,"AdvancedIDButton","ID",UDim2.new(.35,0,.29,0),UDim2.new(.10,0,.075,0),C.muted,506);advanced.TextSize=8
 playlist.Activated:Connect(function()openPlaylist(deck)end)
 advanced.Activated:Connect(function()openID(deck)end)

 -- Vinyl is centered and dominates each deck.
 local vinylHolder,vinyl,cover,fallback=makeVinyl(root,deck,accent)
 vinylHolder.AnchorPoint=Vector2.new(.5,0);vinylHolder.Position=UDim2.new(.5,0,.38,0);vinylHolder.Size=UDim2.new(.52,0,.39,0)

 local transport=Instance.new("Frame");transport.Name="Transport";transport.Position=UDim2.new(.025,0,.79,0);transport.Size=UDim2.new(.95,0,.17,0);transport.BackgroundTransparency=1;transport.ZIndex=503;transport.Parent=root
 local cue=button(transport,"Cue","CUE",UDim2.new(0,0,.06,0),UDim2.new(.21,0,.78,0),C.gold,506);cue.Font=Enum.Font.GothamBlack;cue.TextSize=13
 local play=button(transport,"Play","▶  PLAY",UDim2.new(.23,0,.06,0),UDim2.new(.31,0,.78,0),C.green,506);play.Font=Enum.Font.GothamBlack;play.TextSize=12
 local sync=button(transport,"Sync","SYNC",UDim2.new(.56,0,.06,0),UDim2.new(.20,0,.78,0),accent,506);sync.Font=Enum.Font.GothamBlack;sync.TextSize=12
 local setCue=button(transport,"SetCue","SET",UDim2.new(.78,0,.06,0),UDim2.new(.10,0,.78,0),C.muted,506);setCue.TextSize=8
 local fx=button(transport,"FXButton","FX "..deck,UDim2.new(.895,0,.06,0),UDim2.new(.105,0,.78,0),accent,506);fx.Font=Enum.Font.GothamBlack;fx.TextSize=10
 cue.Activated:Connect(function()actionRemote:FireServer("cue",{deck=deck})end)
 play.Activated:Connect(function()actionRemote:FireServer("play_toggle",{deck=deck})end)
 sync.Activated:Connect(function()actionRemote:FireServer("sync",{deck=deck})end)
 setCue.Activated:Connect(function()actionRemote:FireServer("set_cue",{deck=deck})end)
 fx.Activated:Connect(function()openFX(deck)end)

 deckUI[deck]={root=root,big=big,deckText=deckText,title=title,time=time,playlist=playlist,play=play,sync=sync,fxButton=fx,vinyl=vinyl,cover=cover,fallback=fallback,playhead=playhead,accent=accent,rotation=0}
end
createDeck("A",true,C.pink)
createDeck("B",false,C.cyan)

-- Center mixer strip: no Low/Mid/High. FX triggers + crossfader only.
local centerMixer=Instance.new("Frame");centerMixer.Name="CenterMixer";centerMixer.AnchorPoint=Vector2.new(.5,0);centerMixer.Position=UDim2.new(.5,0,.365,0);centerMixer.Size=UDim2.new(.115,0,.26,0);centerMixer.BackgroundColor3=Color3.fromRGB(9,10,14);centerMixer.BackgroundTransparency=.08;centerMixer.BorderSizePixel=0;centerMixer.ZIndex=520;centerMixer.Parent=panel;corner(centerMixer,14);stroke(centerMixer,C.line,.35,1)
label(centerMixer,"MixLabel","MIX FX",UDim2.new(.1,0,.03,0),UDim2.new(.8,0,.16,0),Enum.Font.GothamBlack,9,C.muted,Enum.TextXAlignment.Center,522)
local centerFxA=button(centerMixer,"CenterFXA","FX A",UDim2.new(.11,0,.24,0),UDim2.new(.78,0,.27,0),C.pink,523);centerFxA.Font=Enum.Font.GothamBlack;centerFxA.TextSize=12
local centerFxB=button(centerMixer,"CenterFXB","FX B",UDim2.new(.11,0,.58,0),UDim2.new(.78,0,.27,0),C.cyan,523);centerFxB.Font=Enum.Font.GothamBlack;centerFxB.TextSize=12
centerFxA.Activated:Connect(function()openFX("A")end);centerFxB.Activated:Connect(function()openFX("B")end)

local cross=Instance.new("Frame");cross.Name="Crossfader";cross.Position=UDim2.new(.20,0,.83,0);cross.Size=UDim2.new(.60,0,.13,0);cross.BackgroundColor3=C.panel;cross.BorderSizePixel=0;cross.ZIndex=510;cross.Parent=panel;corner(cross,14);stroke(cross,C.line,.40)
label(cross,"A","A",UDim2.new(.025,0,.08,0),UDim2.new(.08,0,.30,0),Enum.Font.GothamBlack,15,C.pink,Enum.TextXAlignment.Left,512)
label(cross,"CrossTitle","CROSSFADER",UDim2.new(.38,0,.05,0),UDim2.new(.24,0,.28,0),Enum.Font.GothamBlack,9,C.muted,Enum.TextXAlignment.Center,512)
label(cross,"B","B",UDim2.new(.895,0,.08,0),UDim2.new(.08,0,.30,0),Enum.Font.GothamBlack,15,C.cyan,Enum.TextXAlignment.Right,512)
local bar=Instance.new("Frame");bar.Name="Bar";bar.Position=UDim2.new(.08,0,.53,0);bar.Size=UDim2.new(.84,0,.10,0);bar.BackgroundColor3=Color3.fromRGB(35,38,48);bar.BorderSizePixel=0;bar.ZIndex=512;bar.Parent=cross;corner(bar,6)
local fillA=Instance.new("Frame");fillA.Size=UDim2.fromScale(.5,1);fillA.BackgroundColor3=C.pink;fillA.BorderSizePixel=0;fillA.ZIndex=513;fillA.Parent=bar;corner(fillA,6)
local knob=Instance.new("Frame");knob.AnchorPoint=Vector2.new(.5,.5);knob.Position=UDim2.new(.5,0,.5,0);knob.Size=UDim2.new(0,24,0,24);knob.BackgroundColor3=C.white;knob.BorderSizePixel=0;knob.ZIndex=515;knob.Parent=bar;circle(knob);stroke(knob,C.cyan,.1,2)
local dragging=false
local function sendCross(x)
 local abs=bar.AbsolutePosition.X;local w=math.max(1,bar.AbsoluteSize.X)
 actionRemote:FireServer("crossfader",{value=math.clamp((x-abs)/w,0,1)})
end
bar.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;sendCross(i.Position.X)end end)
UserInputService.InputChanged:Connect(function(i)if dragging and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then sendCross(i.Position.X)end end)
UserInputService.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

local portraitHint=label(panel,"PortraitHint","ROTATE PHONE ↻",UDim2.new(.3,0,.47,0),UDim2.new(.4,0,.08,0),Enum.Font.GothamBlack,22,C.white,Enum.TextXAlignment.Center,660);portraitHint.Visible=false

liveButton.Activated:Connect(function()actionRemote:FireServer(current.live and "end_live" or "go_live",{})end)

local function refreshFXPopup()
 if not fxTarget then return end
 local d=current.decks and current.decks[fxTarget]
 if not d then return end
 local accent=deckAccent(fxTarget)
 for key,b in pairs(fxButtons) do
  local active=(d.fx and d.fx[key]==true) or (d.busyFx and (string.upper(key)==string.upper(d.busyFx) or (key=="ROLL_HALF" and d.busyFx=="ROLL 1/2") or (key=="ROLL_QUARTER" and d.busyFx=="ROLL 1/4")))
  b.BackgroundColor3=active and accent or C.card;b.TextColor3=active and C.black or C.white
 end
end

local function updateUI(s)
 if type(s)~="table" then return end
 current=s
 statusLabel.Text=s.live and ("LIVE • "..tostring(s.venue).." • "..tostring(s.operator or "DEV")) or ("STANDBY • "..tostring(s.venue))
 statusLabel.TextColor3=s.live and C.green or C.muted
 liveButton.Text=s.live and "END LIVE" or "GO LIVE";liveButton.TextColor3=s.live and C.red or C.white
 for venue,b in pairs(venueButtons) do
  local selected=s.venue==venue;b.BackgroundColor3=selected and C.gold or C.card;b.TextColor3=selected and Color3.fromRGB(20,18,12) or C.white
 end
 local x=math.clamp(tonumber(s.crossfader) or .5,0,1);knob.Position=UDim2.new(x,0,.5,0);fillA.Size=UDim2.new(x,0,1,0)
 for deck,u in pairs(deckUI) do
  local d=s.decks and s.decks[deck]
  if d then
   u.title.Text=(d.preloaded and "● " or "")..tostring(d.title or "EMPTY")
   u.time.Text=fmtTime(d.timePosition).." / "..fmtTime(d.timeLength)
   u.play.Text=d.playing and "❚❚  PAUSE" or "▶  PLAY"
   local progress=(tonumber(d.timeLength) or 0)>0 and math.clamp((tonumber(d.timePosition) or 0)/d.timeLength,0,1) or 0;u.playhead.Position=UDim2.new(progress,0,0,0)
   local image=thumb(d.assetId,420);u.cover.Image=image;u.cover.Visible=image~="";u.fallback.Visible=image==""
  end
 end
 refreshFXPopup()
end
stateRemote.OnClientEvent:Connect(updateUI);updateUI(initial)

RunService.RenderStepped:Connect(function(dt)
 local cam=workspace.CurrentCamera;local vp=cam and cam.ViewportSize or Vector2.new(1280,720)
 portraitHint.Visible=panel.Visible and vp.Y>vp.X
 if not panel.Visible then return end
 for deck,u in pairs(deckUI) do
  local d=current.decks and current.decks[deck]
  if d and d.playing then u.rotation=(u.rotation+dt*92*(tonumber(d.pitch) or 1))%360;u.vinyl.Rotation=u.rotation end
 end
end)

-- Single-panel arbitration: DJ console is performance mode, so ordinary BBYA panels close.
local competing={HubPanel=true,CompactMusicCardV7=true,PlaylistDrawerV7=true,CommunityPanel=true,DancePanel=true,CarryPanel=true,DJWallComposerPanel=true}
local function hideOtherPanels()
 for _,d in ipairs(pg:GetDescendants()) do if d:IsA("GuiObject") and competing[d.Name] and d.Visible then d.Visible=false end end
 local role=pg:FindFirstChild("BBYARolePanelUI");local roleShade=role and role:FindFirstChild("Shade",true);if roleShade and roleShade:IsA("GuiObject") then roleShade.Visible=false end
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 if menu then
  local drawer=menu:FindFirstChild("FeatureDrawer",true);local mb=menu:FindFirstChild("MenuButton",true)
  if drawer and drawer:IsA("GuiObject") then drawer.Visible=false end
  if mb and mb:IsA("TextButton") then mb.Text="MENU" end
 end
end
local function togglePanel()
 panel.Visible=not panel.Visible
 if panel.Visible then hideOtherPanels() else closeModals() end
end

local function installMenuEntry()
 local menu=pg:WaitForChild("BBYACommandMenuUI",30);if not menu then return false end
 local grid=menu:FindFirstChildWhichIsA("UIGridLayout",true);if not grid or not grid.Parent then return false end
 local body=grid.Parent;local oldSlot=body:FindFirstChild("Slot_DJ_LIVE");if oldSlot then oldSlot:Destroy() end
 local slot=Instance.new("Frame");slot.Name="Slot_DJ_LIVE";slot.LayoutOrder=10;slot.BackgroundColor3=C.card;slot.BorderSizePixel=0;slot.ZIndex=202;slot.Parent=body;corner(slot,9);stroke(slot,C.gold,.38)
 local b=Instance.new("TextButton");b.Name="DeveloperDJMenuButton";b.Size=UDim2.fromScale(1,1);b.BackgroundTransparency=1;b.Text="DJ LIVE";b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=8;b.ZIndex=206;b.Parent=slot;b.Activated:Connect(togglePanel)
 local drawer=menu:FindFirstChild("FeatureDrawer",true);if drawer and drawer:IsA("GuiObject") then drawer:GetPropertyChangedSignal("Visible"):Connect(function()if drawer.Visible and panel.Visible then panel.Visible=false;closeModals() end end) end
 return true
end
if not installMenuEntry() then
 local fallback=button(gui,"FallbackDJButton","DJ LIVE",UDim2.new(1,-178,0,8),UDim2.fromOffset(72,36),C.gold,580);fallback.AnchorPoint=Vector2.new(1,0);fallback.Activated:Connect(togglePanel)
end

print("[BBYA] Developer DJ Mixer client v3: VINYL HERO + DECK-LOCAL PLAYLIST + COVER THUMBNAIL + POPUP FX")
