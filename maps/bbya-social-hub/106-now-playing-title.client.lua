-- BBYA SOCIAL HUB — ACTUAL NOW PLAYING TITLE + ROOFTOP UI BRIDGE v2
-- Keeps audible titles truthful and exposes the live Rooftop catalog to the compact playlist UI.

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
local playerCard=panel:FindFirstChild("PlayerCard",true)

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local stateRemote=remotes:WaitForChild("State",30)
local funkotRemote=remotes:WaitForChild("FunkotMusic",30)

local legacyNowTitle
local sourceBadge
if playerCard then
 for _,d in ipairs(playerCard:GetChildren()) do
  if d:IsA("TextLabel") and d.TextSize>=13 and string.upper(d.Text or "")~="NOW PLAYING" then
   legacyNowTitle=d;break
  end
 end
 sourceBadge=playerCard:FindFirstChild("ActualSourceBadgeV2") or Instance.new("TextLabel")
 sourceBadge.Name="ActualSourceBadgeV2"
 sourceBadge.BackgroundTransparency=1
 sourceBadge.Text=""
 sourceBadge.TextColor3=Color3.fromRGB(151,155,168)
 sourceBadge.Font=Enum.Font.GothamBold
 sourceBadge.TextSize=8
 sourceBadge.TextXAlignment=Enum.TextXAlignment.Left
 sourceBadge.ZIndex=130
 sourceBadge.Position=UDim2.fromOffset(14,73)
 sourceBadge.Size=UDim2.new(1,-220,0,15)
 sourceBadge.Parent=playerCard
end

local cached={MAIN={title="",playing=false},UNDERGROUND={title="",playing=false},FUNKOT={title="",playing=false}}

local function venue()
 local v=tostring(player:GetAttribute("BBYAAudioVenue") or "NONE")
 if v=="BASEMENT" then v="UNDERGROUND" end
 return v
end

stateRemote.OnClientEvent:Connect(function(kind,data)
 if kind~="music" or type(data)~="table" then return end
 local v=tostring(data.venue or "MAIN")
 if v=="BASEMENT" then v="UNDERGROUND" else v="MAIN" end
 cached[v].title=tostring(data.title or "")
 cached[v].playing=data.playing==true
end)

funkotRemote.OnClientEvent:Connect(function(kind,data)
 if kind~="state" or type(data)~="table" then return end
 cached.FUNKOT.title=tostring(data.title or "")
 cached.FUNKOT.playing=data.playing==true
end)

local function groupFor(v)
 if v=="MAIN" then return SoundService:FindFirstChild("BBYAClubMaster") end
 if v=="UNDERGROUND" then return SoundService:FindFirstChild("BBYABasementMaster") end
 if v=="FUNKOT" then return SoundService:FindFirstChild("BBYAFunkotMaster") end
 if v=="SKATEPARK" then return SoundService:FindFirstChild("BBYASkateparkMaster") end
 if v=="ROOFTOP" then return SoundService:FindFirstChild("BBYARooftopMaster") end
end

local function actual(v)
 local g=groupFor(v)
 if v=="MAIN" or v=="UNDERGROUND" then
  if g and g:GetAttribute("RecoveryActive")==true then
   local title=tostring(g:GetAttribute("RecoveryTrack") or "")
   local id=tostring(g:GetAttribute("RecoveryTrackId") or "")
   if title~="" then return title,"RECOVERY"..(id~="" and " • ID "..id or "") end
  end
  local c=cached[v]
  if c and c.title~="" then return c.title,"PLAYLIST" end
 elseif v=="FUNKOT" then
  local title=g and tostring(g:GetAttribute("CurrentTitle") or "") or ""
  if title=="" then title=cached.FUNKOT.title end
  if title~="" then return title,"PLAYLIST" end
 elseif v=="ROOFTOP" then
  local title=tostring(ReplicatedStorage:GetAttribute("BBYARooftopCurrentTitle") or "")
  if title=="" and g then title=tostring(g:GetAttribute("CurrentTitle") or "") end
  local s=SoundService:FindFirstChild("BBYARooftopPlaylist")
  if title=="" and s and s:IsA("Sound") then title=tostring(s:GetAttribute("Title") or "") end
  if title~="" then return title,"ROOFTOP PLAYLIST" end
  return "No track loaded","ROOFTOP"
 elseif v=="SKATEPARK" then
  local title=g and tostring(g:GetAttribute("CurrentTitle") or "") or ""
  if title~="" then return title,"PLAYLIST" end
  return "No track loaded","LOCAL CHANNEL"
 end
 return "No local music","SILENT ZONE"
end

local function syncLegacy()
 if not legacyNowTitle then return end
 local title,source=actual(venue())
 legacyNowTitle.Text=title
 if sourceBadge then sourceBadge.Text=source end
 local home=panel:FindFirstChild("BBYAHomeV6",true)
 local song=home and home:FindFirstChild("Song",true)
 if song and song:IsA("TextLabel") then song.Text="NOW PLAYING  "..title end
end

local function rooftopTracks()
 local folder=ReplicatedStorage:FindFirstChild("BBYARooftopPlaylistCatalog")
 if not folder or not folder:IsA("Folder") then return {} end
 local tracks={}
 for _,entry in ipairs(folder:GetChildren()) do
  if entry:IsA("StringValue") then
   table.insert(tracks,{index=tonumber(entry:GetAttribute("Index")) or 999,title=entry.Value,assetId=tostring(entry:GetAttribute("AssetId") or "")})
  end
 end
 table.sort(tracks,function(a,b)return a.index<b.index end)
 return tracks
end

local lastScroller=nil
local lastSignature=""
local function clearBridgeRows(scroller)
 if not scroller then return end
 for _,child in ipairs(scroller:GetChildren()) do
  if child:IsA("Frame") and child.Name:match("^RooftopTrackRowBridge_") then child:Destroy() end
 end
end

local function textLabel(parent,name,text,pos,size,font,textSize,color,align)
 local x=Instance.new("TextLabel")
 x.Name=name;x.BackgroundTransparency=1;x.Text=text;x.Position=pos;x.Size=size
 x.Font=font or Enum.Font.Gotham;x.TextSize=textSize or 10;x.TextColor3=color or Color3.fromRGB(246,246,249)
 x.TextXAlignment=align or Enum.TextXAlignment.Left;x.TextYAlignment=Enum.TextYAlignment.Center;x.TextWrapped=false;x.ZIndex=716;x.Parent=parent
 return x
end

local function rebuildRooftopRows(scroller,tracks,currentIndex)
 clearBridgeRows(scroller)
 for i,item in ipairs(tracks) do
  local row=Instance.new("Frame")
  row.Name="RooftopTrackRowBridge_"..tostring(i);row.LayoutOrder=i+1;row.Size=UDim2.new(1,-5,0,48)
  row.BackgroundColor3=Color3.fromRGB(29,30,39);row.BackgroundTransparency=(i==currentIndex) and .08 or .24;row.BorderSizePixel=0;row.ZIndex=715;row.Parent=scroller
  local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,9);c.Parent=row
  local st=Instance.new("UIStroke");st.Color=Color3.fromRGB(220,173,86);st.Thickness=1;st.Transparency=(i==currentIndex) and .25 or .68;st.Parent=row
  textLabel(row,"TrackNumber",string.format("%02d",i),UDim2.fromOffset(12,0),UDim2.fromOffset(34,48),Enum.Font.GothamBold,9,Color3.fromRGB(220,173,86))
  local title=textLabel(row,"TrackTitle",item.title,UDim2.fromOffset(50,0),UDim2.new(1,-130,1,0),Enum.Font.GothamMedium,10,Color3.fromRGB(246,246,249));title.TextTruncate=Enum.TextTruncate.AtEnd
  textLabel(row,"TrackStatus",i==currentIndex and "NOW" or "LIVE",UDim2.new(1,-76,0,0),UDim2.fromOffset(64,48),Enum.Font.GothamBold,9,Color3.fromRGB(220,173,86),Enum.TextXAlignment.Center)
 end
end

local function syncCompactRooftop()
 local layer=gui:FindFirstChild("BBYACompactMusicLayerV7")
 if not layer then return end
 local drawer=layer:FindFirstChild("PlaylistDrawerV7",true)
 local scroller=drawer and drawer:FindFirstChild("PlaylistScrollerV7",true)
 if venue()~="ROOFTOP" then
  if lastScroller then clearBridgeRows(lastScroller) end
  lastScroller=nil;lastSignature="";return
 end
 if not drawer or not scroller then return end
 local tracks=rooftopTracks()
 local currentIndex=tonumber(ReplicatedStorage:GetAttribute("BBYARooftopCurrentIndex")) or 1
 local currentTitle=tostring(ReplicatedStorage:GetAttribute("BBYARooftopCurrentTitle") or "")
 local signature=tostring(#tracks)..":"..tostring(currentIndex)
 for _,t in ipairs(tracks) do signature=signature..":"..tostring(t.index)..":"..t.title..":"..t.assetId end
 local empty=drawer:FindFirstChild("PlaylistEmpty",true)
 local titleLabel=drawer:FindFirstChild("PlaylistTitle",true)
 local countLabel=drawer:FindFirstChild("PlaylistCount",true)
 if titleLabel and titleLabel:IsA("TextLabel") then titleLabel.Text="ROOFTOP PLAYLIST" end
 if countLabel and countLabel:IsA("TextLabel") then countLabel.Text=tostring(#tracks)..(#tracks==1 and " TRACK" or " TRACKS") end
 if empty and empty:IsA("TextLabel") then empty.Visible=#tracks==0;if #tracks==0 then empty.Text="ROOFTOP PLAYLIST\nmenunggu katalog live" end end
 local card=layer:FindFirstChild("CompactMusicCardV7",true)
 if card then
  local compactTitle=card:FindFirstChild("NowPlayingTitle",true)
  local compactMeta=card:FindFirstChild("NowPlayingMeta",true)
  if compactTitle and compactTitle:IsA("TextLabel") and currentTitle~="" then compactTitle.Text=currentTitle end
  if compactMeta and compactMeta:IsA("TextLabel") then compactMeta.Text="ROOFTOP • "..tostring(#tracks)..(#tracks==1 and " TRACK" or " TRACKS") end
 end
 if lastScroller~=scroller or lastSignature~=signature then lastScroller=scroller;lastSignature=signature;rebuildRooftopRows(scroller,tracks,currentIndex) end
end

local function syncAll() syncLegacy();syncCompactRooftop() end
player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()task.defer(syncAll)end)
for _,attr in ipairs({"BBYARooftopPlaylistCount","BBYARooftopCurrentIndex","BBYARooftopCurrentTitle","BBYARooftopCurrentAssetId"}) do
 ReplicatedStorage:GetAttributeChangedSignal(attr):Connect(function()task.defer(syncAll)end)
end
SoundService.ChildAdded:Connect(function()task.defer(syncAll)end)
ReplicatedStorage.ChildAdded:Connect(function(child)if child.Name=="BBYARooftopPlaylistCatalog" then task.defer(syncAll) end end)
task.spawn(function()while task.wait(.2) do syncAll() end end)
task.defer(syncAll)
print("[BBYA] Actual now-playing + Rooftop compact playlist bridge v2 online")

-- BBYA MUSIC SUITE — MASTER LEVEL METER v6
-- Hardware-style segmented meter using PlaybackLoudness as a relative level source.
-- Fixed scale markings are visual calibration marks, not a true dBFS analyzer.

local suite,meter,barArea,peakMarker,clipLed,clipText
local segments={}
local smoothLevel=0
local peakLevel=0
local peakHoldUntil=0
local clipHoldUntil=0
local activeSound=nil
local lastSoundScan=0

local function suiteFind(name)return suite and suite:FindFirstChild(name,true) or nil end

local function findAudibleSound()
 if activeSound and activeSound.Parent and activeSound.IsPlaying then return activeSound end
 if os.clock()-lastSoundScan<.45 then return activeSound end
 lastSoundScan=os.clock()
 local group=groupFor(venue())
 for _,root in ipairs({SoundService,workspace}) do
  for _,x in ipairs(root:GetDescendants()) do
   if x:IsA("Sound") and x.IsPlaying then
    if group and x.SoundGroup==group then activeSound=x;return x end
    if x.Name:find("BBYA") then activeSound=x;return x end
   end
  end
 end
 activeSound=nil;return nil
end

local function destroyOldViz()
 if not suite then return end
 for _,name in ipairs({"HeroVisualizerV3","ClubLevelMeterV5","MasterLevelMeterV6"}) do
  local old=suite:FindFirstChild(name,true)
  if old and old~=meter then old:Destroy() end
 end
 local track=suiteFind("Track")
 local info=track and track.Parent
 if info then
  for _,d in ipairs(info:GetChildren()) do
   if d:IsA("Frame") and #d:GetChildren()>=12 then d.Visible=false end
  end
 end
end

local function mkLabel(parent,name,text,pos,size,ts,color,align)
 local l=Instance.new("TextLabel")
 l.Name=name;l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=Enum.Font.GothamBold;l.TextSize=ts;l.TextColor3=color
 l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.Parent=parent;return l
end

local function buildMeter()
 suite=pg:FindFirstChild("BBYAMusicSuiteV1")
 if not suite then return false end
 destroyOldViz()
 local track=suiteFind("Track")
 local info=track and track.Parent
 local card=info and info.Parent
 if not card then return false end
 meter=Instance.new("Frame")
 meter.Name="MasterLevelMeterV6";meter.Position=UDim2.new(0,18,1,-116);meter.Size=UDim2.new(1,-36,0,31);meter.BackgroundTransparency=1;meter.Parent=card
 mkLabel(meter,"Title","MASTER LEVEL",UDim2.fromOffset(0,2),UDim2.fromOffset(64,12),6,Color3.fromRGB(132,136,148))
 mkLabel(meter,"Rel","REL",UDim2.fromOffset(0,15),UDim2.fromOffset(28,10),5,Color3.fromRGB(88,92,104))

 barArea=Instance.new("Frame")
 barArea.Name="Segments";barArea.Position=UDim2.new(0,68,0,16);barArea.Size=UDim2.new(1,-114,0,8);barArea.BackgroundTransparency=1;barArea.ClipsDescendants=false;barArea.Parent=meter
 segments={}
 local count=20
 for i=1,count do
  local seg=Instance.new("Frame")
  seg.Name="S"..i;seg.Position=UDim2.new((i-1)/count,1,0,0);seg.Size=UDim2.new(1/count,-3,1,0);seg.BorderSizePixel=0
  if i<=13 then seg.BackgroundColor3=Color3.fromRGB(69,177,112)
  elseif i<=18 then seg.BackgroundColor3=Color3.fromRGB(210,162,62)
  else seg.BackgroundColor3=Color3.fromRGB(204,63,68) end
  seg.BackgroundTransparency=.87;seg.Parent=barArea
  segments[i]=seg
 end

 local marks={{0,"-36"},{.33,"-24"},{.66,"-12"},{.82,"-6"},{.99,"0"}}
 for i,m in ipairs(marks) do
  local a=(i==#marks) and Enum.TextXAlignment.Right or Enum.TextXAlignment.Center
  mkLabel(meter,"Mark"..i,m[2],UDim2.new(0,68,0,1)+UDim2.new((m[1])*(1),0,0,0),UDim2.fromOffset(24,10),5,Color3.fromRGB(91,95,107),a)
 end

 peakMarker=Instance.new("Frame")
 peakMarker.Name="Peak";peakMarker.AnchorPoint=Vector2.new(.5,0);peakMarker.Position=UDim2.new(0,0,0,-1);peakMarker.Size=UDim2.fromOffset(2,10);peakMarker.BorderSizePixel=0;peakMarker.BackgroundColor3=Color3.fromRGB(241,224,160);peakMarker.BackgroundTransparency=.08;peakMarker.Visible=false;peakMarker.Parent=barArea

 clipLed=Instance.new("Frame")
 clipLed.Name="ClipLED";clipLed.Position=UDim2.new(1,-36,0,15);clipLed.Size=UDim2.fromOffset(7,7);clipLed.BorderSizePixel=0;clipLed.BackgroundColor3=Color3.fromRGB(205,59,64);clipLed.BackgroundTransparency=.82;clipLed.Parent=meter
 local cc=Instance.new("UICorner");cc.CornerRadius=UDim.new(1,0);cc.Parent=clipLed
 clipText=mkLabel(meter,"ClipText","CLIP",UDim2.new(1,-27,0,13),UDim2.fromOffset(27,11),5,Color3.fromRGB(115,91,94))
 return true
end

local function ensureMeter()
 suite=pg:FindFirstChild("BBYAMusicSuiteV1")
 if not suite then return end
 destroyOldViz()
 if not meter or not meter.Parent then buildMeter() end
end

pg.ChildAdded:Connect(function(child)
 if child.Name=="BBYAMusicSuiteV1" then task.delay(.1,ensureMeter);task.delay(.45,ensureMeter);task.delay(1,ensureMeter) end
end)
task.defer(ensureMeter);task.delay(.3,ensureMeter);task.delay(.9,ensureMeter)

RunService.RenderStepped:Connect(function(dt)
 if not suite or not suite.Parent or not meter or not meter.Parent then ensureMeter();return end
 local s=findAudibleSound()
 local raw=s and math.clamp((s.PlaybackLoudness-5)/560,0,1) or 0
 local shaped=raw^0.72
 local attack=math.min(1,dt*22)
 local release=math.min(1,dt*4.2)
 smoothLevel=smoothLevel+(shaped-smoothLevel)*(shaped>smoothLevel and attack or release)

 local now=os.clock()
 if smoothLevel>=peakLevel then peakLevel=smoothLevel;peakHoldUntil=now+.42
 elseif now>peakHoldUntil then peakLevel=math.max(smoothLevel,peakLevel-dt*.32) end
 if raw>.965 then clipHoldUntil=now+.65 end

 local active=math.floor(smoothLevel*#segments+.5)
 for i,seg in ipairs(segments) do
  local on=i<=active
  seg.BackgroundTransparency=on and .04 or .87
 end
 if peakMarker and barArea then
  peakMarker.Visible=peakLevel>.02
  peakMarker.Position=UDim2.new(math.clamp(peakLevel,0,1),0,0,-1)
 end
 local clipping=now<clipHoldUntil
 if clipLed then clipLed.BackgroundTransparency=clipping and .02 or .82 end
 if clipText then clipText.TextColor3=clipping and Color3.fromRGB(230,83,88) or Color3.fromRGB(115,91,94) end
end)

print("[BBYA] Master level meter v6 active — hardware segments / peak hold / clip / restrained motion")
