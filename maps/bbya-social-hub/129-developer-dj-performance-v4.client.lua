-- BBYA SOCIAL HUB — DJ LIVE PERFORMANCE CLIENT v4
-- Additive usability layer over the stable full-screen v3 console.
-- Adds touch-vinyl jog, waveform seek, 3 hot cues/deck, smooth playhead and playlist search.
-- No generated artwork. No EQ controls. FX remains popup-only.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("BBYADeveloperDJUI",35)
if not gui then return end
local panel=gui:WaitForChild("DeveloperDJMixerPanel",10)
if not panel then return end

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",20)
local actionRemote=remotes and remotes:WaitForChild("DeveloperDJAction",20)
if not actionRemote then return end

local mixer=SoundService:WaitForChild("BBYADeveloperDJMixer",20)
local deckSounds={
 A=mixer and mixer:WaitForChild("DeckA",10),
 B=mixer and mixer:WaitForChild("DeckB",10),
}
if not (deckSounds.A and deckSounds.B) then return end

gui:SetAttribute("BBYADeveloperDJPerformanceVersion","V4_TOUCH_VINYL_HOTCUE")
gui:SetAttribute("TouchVinylJog",true)
gui:SetAttribute("WaveformSeek",true)
gui:SetAttribute("HotCueSlots",3)
gui:SetAttribute("PlaylistSearch",true)

local C={
 pink=Color3.fromRGB(245,42,145),cyan=Color3.fromRGB(18,195,235),white=Color3.fromRGB(247,247,250),
 muted=Color3.fromRGB(145,151,168),card=Color3.fromRGB(22,24,31),card2=Color3.fromRGB(29,31,40),
 black=Color3.fromRGB(3,3,5),line=Color3.fromRGB(61,65,79),green=Color3.fromRGB(69,220,129),
}
local function accent(deck)return deck=="A" and C.pink or C.cyan end
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 8);c.Parent=o;return c end
local function stroke(o,color,transparency,thickness)local s=Instance.new("UIStroke");s.Color=color or C.line;s.Transparency=transparency or .5;s.Thickness=thickness or 1;s.Parent=o;return s end
local function label(parent,name,text,pos,size,font,textSize,color,z)
 local l=Instance.new("TextLabel");l.Name=name;l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.GothamBold;l.TextSize=textSize or 9;l.TextColor3=color or C.white;l.TextXAlignment=Enum.TextXAlignment.Center;l.TextYAlignment=Enum.TextYAlignment.Center;l.ZIndex=z or 560;l.Parent=parent;return l
end
local function button(parent,name,text,pos,size,color,z)
 local b=Instance.new("TextButton");b.Name=name;b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=C.card;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBlack;b.TextSize=9;b.AutoButtonColor=true;b.ZIndex=z or 560;b.Parent=parent;corner(b,7);stroke(b,color,.45,1);return b
end

local deckUI={}
for _,deck in ipairs({"A","B"}) do
 local root=panel:FindFirstChild("Deck"..deck)
 if root then
  local vinyl=root:FindFirstChild("Vinyl",true)
  local wave=root:FindFirstChild("Waveform",true)
  local playhead=wave and wave:FindFirstChild("Playhead")
  local setCue=root:FindFirstChild("SetCue",true)
  deckUI[deck]={root=root,vinyl=vinyl,wave=wave,playhead=playhead,setCue=setCue,sound=deckSounds[deck],accent=accent(deck),hot={}}
 end
end
if not deckUI.A or not deckUI.B then return end

-- =============================================================================
-- PLAYLIST SEARCH — library stays deck-local; search only reduces tap hunting.
-- =============================================================================
local playlistPopup=panel:FindFirstChild("PlaylistPopup")
local playlistScroll=playlistPopup and playlistPopup:FindFirstChild("PlaylistScroller")
local playlistCount=playlistPopup and playlistPopup:FindFirstChild("PlaylistCount")
if playlistPopup and playlistScroll and not playlistPopup:FindFirstChild("PlaylistSearchV4") then
 local search=Instance.new("TextBox")
 search.Name="PlaylistSearchV4";search.Position=UDim2.new(.025,0,.15,0);search.Size=UDim2.new(.64,0,.075,0);search.BackgroundColor3=C.card;search.BorderSizePixel=0
 search.PlaceholderText="SEARCH TRACK / GENRE / KEY";search.Text="";search.ClearTextOnFocus=false;search.Font=Enum.Font.GothamBold;search.TextSize=10;search.TextColor3=C.white;search.PlaceholderColor3=C.muted;search.ZIndex=614;search.Parent=playlistPopup;corner(search,9);stroke(search,C.line,.4)
 local clear=button(playlistPopup,"PlaylistSearchClearV4","CLEAR",UDim2.new(.68,0,.15,0),UDim2.new(.13,0,.075,0),C.line,615)
 playlistScroll.Position=UDim2.new(.025,0,.245,0);playlistScroll.Size=UDim2.new(.95,0,.715,0)

 local function filterRows()
  local q=string.lower(search.Text or "")
  local visible,total=0,0
  for _,row in ipairs(playlistScroll:GetChildren()) do
   if row:IsA("GuiObject") and string.sub(row.Name,1,6)=="Track_" then
    total+=1
    local t=row:FindFirstChild("Title")
    local m=row:FindFirstChild("Meta")
    local hay=string.lower((t and t.Text or "").." "..(m and m.Text or ""))
    local show=q=="" or string.find(hay,q,1,true)~=nil
    row.Visible=show
    if show then visible+=1 end
   end
  end
  if playlistCount and playlistCount:IsA("TextLabel") then playlistCount.Text=string.format("%d / %d APPROVED TRACKS",visible,total) end
 end
 search:GetPropertyChangedSignal("Text"):Connect(filterRows)
 clear.Activated:Connect(function()search.Text="";filterRows()end)
 filterRows()
end

-- =============================================================================
-- HOT CUES — vertical rails live beside the vinyl so the platter stays the hero.
-- Empty slot: tap to SET. Filled slot: tap to PLAY. Hold filled slot to re-SET.
-- =============================================================================
local heldToken=0
local function cueValue(deck,slot)
 return tonumber(deckUI[deck].sound:GetAttribute("BBYADJHotCue"..slot)) or -1
end
local function updateHotCue(deck,slot)
 local u=deckUI[deck];local b=u.hot[slot];if not b then return end
 local set=cueValue(deck,slot)>=0
 b.Text=set and tostring(slot) or ("+"..slot)
 b.BackgroundColor3=set and u.accent or C.card
 b.TextColor3=set and C.black or C.white
end

for _,deck in ipairs({"A","B"}) do
 local u=deckUI[deck]
 local old=u.root:FindFirstChild("HotCueRailV4");if old then old:Destroy() end
 local rail=Instance.new("Frame");rail.Name="HotCueRailV4";rail.Position=deck=="A" and UDim2.new(.055,0,.43,0) or UDim2.new(.825,0,.43,0);rail.Size=UDim2.new(.12,0,.31,0);rail.BackgroundColor3=C.black;rail.BackgroundTransparency=.22;rail.BorderSizePixel=0;rail.ZIndex=540;rail.Parent=u.root;corner(rail,10);stroke(rail,u.accent,.45,1)
 label(rail,"HotLabel","HOT",UDim2.new(.08,0,.02,0),UDim2.new(.84,0,.17,0),Enum.Font.GothamBlack,8,u.accent,542)
 for slot=1,3 do
  local s=slot
  local b=button(rail,"HotCue"..s,"+"..s,UDim2.new(.13,0,.20+(s-1)*.255,0),UDim2.new(.74,0,.205,0),u.accent,544)
  b.TextSize=11;u.hot[s]=b
  local pressId=0
  b.InputBegan:Connect(function(input)
   if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
   heldToken+=1;pressId=heldToken
   task.delay(.62,function()
    if pressId~=heldToken or not b.Parent then return end
    if cueValue(deck,s)>=0 then
     b:SetAttribute("SuppressTapV4",true)
     actionRemote:FireServer("v4_hotcue_set",{deck=deck,slot=s})
    end
   end)
  end)
  b.InputEnded:Connect(function(input)
   if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then heldToken+=1 end
  end)
  b.Activated:Connect(function()
   if b:GetAttribute("SuppressTapV4")==true then b:SetAttribute("SuppressTapV4",false);return end
   if cueValue(deck,s)<0 then actionRemote:FireServer("v4_hotcue_set",{deck=deck,slot=s}) else actionRemote:FireServer("v4_hotcue_play",{deck=deck,slot=s}) end
  end)
  u.sound:GetAttributeChangedSignal("BBYADJHotCue"..s):Connect(function()updateHotCue(deck,s)end)
  updateHotCue(deck,s)
 end
end

-- =============================================================================
-- TOUCH VINYL JOG / LIGHT SCRATCH
-- Horizontal drag nudges TimePosition. This is deliberately bounded so it cannot
-- create runaway seeking or break the existing SYNC/FX engine.
-- =============================================================================
local dragDeck=nil
local lastX=0
local lastSend=0
local jogReadout=nil
local function stopJog()
 dragDeck=nil
 if jogReadout then jogReadout.Visible=false end
end

for _,deck in ipairs({"A","B"}) do
 local u=deckUI[deck]
 if u.vinyl then
  local old=u.vinyl:FindFirstChild("VinylJogSurfaceV4");if old then old:Destroy() end
  local surface=Instance.new("TextButton");surface.Name="VinylJogSurfaceV4";surface.Size=UDim2.fromScale(1,1);surface.BackgroundTransparency=1;surface.Text="";surface.AutoButtonColor=false;surface.ZIndex=550;surface.Parent=u.vinyl
  local hint=label(u.vinyl,"JogHintV4","TOUCH JOG",UDim2.new(.31,0,.82,0),UDim2.new(.38,0,.08,0),Enum.Font.GothamBlack,7,u.accent,551);hint.BackgroundColor3=C.black;hint.BackgroundTransparency=.28;corner(hint,6)
  surface.InputBegan:Connect(function(input)
   if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
    dragDeck=deck;lastX=input.Position.X;lastSend=0
    jogReadout=hint;hint.Text="JOG 0.00s";hint.Visible=true
   end
  end)
 end
end

UserInputService.InputChanged:Connect(function(input)
 if not dragDeck then return end
 if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseMovement then return end
 local u=deckUI[dragDeck];if not (u and u.vinyl) then stopJog();return end
 local x=input.Position.X;local dx=x-lastX;lastX=x
 local width=math.max(100,u.vinyl.AbsoluteSize.X)
 local delta=math.clamp((dx/width)*1.15,-.24,.24)
 if math.abs(delta)<.004 then return end
 local now=os.clock()
 if now-lastSend>=.035 then
  lastSend=now
  actionRemote:FireServer("v4_nudge",{deck=dragDeck,delta=delta})
  if jogReadout then jogReadout.Text=string.format("JOG %+0.2fs",delta) end
 end
end)
UserInputService.InputEnded:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then stopJog() end
end)

-- =============================================================================
-- WAVEFORM SEEK + SMOOTH PLAYHEAD
-- Tap anywhere in the waveform to jump there. Playback state is preserved.
-- =============================================================================
for _,deck in ipairs({"A","B"}) do
 local u=deckUI[deck]
 if u.wave then
  local old=u.wave:FindFirstChild("WaveSeekSurfaceV4");if old then old:Destroy() end
  local surface=Instance.new("TextButton");surface.Name="WaveSeekSurfaceV4";surface.Size=UDim2.fromScale(1,1);surface.BackgroundTransparency=1;surface.Text="";surface.AutoButtonColor=false;surface.ZIndex=550;surface.Parent=u.wave
  label(u.wave,"SeekHintV4","SEEK",UDim2.new(.90,0,.03,0),UDim2.new(.08,0,.26,0),Enum.Font.GothamBlack,6,C.white,551).TextTransparency=.25
  surface.InputBegan:Connect(function(input)
   if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
   local ratio=math.clamp((input.Position.X-u.wave.AbsolutePosition.X)/math.max(1,u.wave.AbsoluteSize.X),0,1)
   actionRemote:FireServer("v4_seek_ratio",{deck=deck,ratio=ratio})
  end)
 end
end

local waveAccum=0
RunService.RenderStepped:Connect(function(dt)
 if not panel.Visible then return end
 waveAccum+=dt;if waveAccum<.055 then return end;waveAccum=0
 for _,deck in ipairs({"A","B"}) do
  local u=deckUI[deck];local sound=u.sound
  if u.wave and u.playhead and sound then
   local length=tonumber(sound.TimeLength) or 0
   local pos=tonumber(sound.TimePosition) or 0
   local progress=length>0 and math.clamp(pos/length,0,1) or 0
   u.playhead.Position=UDim2.new(progress,0,0,0)
   for _,bar in ipairs(u.wave:GetChildren()) do
    if bar:IsA("Frame") and bar~=u.playhead and bar.Name~="WaveSeekSurfaceV4" then
     local passed=(bar.Position.X.Scale or 0)<=progress
     bar.BackgroundColor3=passed and u.accent or u.accent:Lerp(C.muted,.55)
     bar.BackgroundTransparency=passed and .08 or .58
    end
   end
  end
 end
end)

print("[BBYA] DJ Live Performance client v4 online: vinyl jog + waveform seek + hot cues + playlist search")
