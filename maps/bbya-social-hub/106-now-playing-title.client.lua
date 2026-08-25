-- BBYA SOCIAL HUB — ACTUAL NOW PLAYING TITLE + ROOFTOP UI BRIDGE v2
-- Keeps audible titles truthful and exposes the live Rooftop catalog to the compact playlist UI.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")

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

local cached={
 MAIN={title="",playing=false},
 UNDERGROUND={title="",playing=false},
 FUNKOT={title="",playing=false},
}

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
   table.insert(tracks,{
    index=tonumber(entry:GetAttribute("Index")) or 999,
    title=entry.Value,
    assetId=tostring(entry:GetAttribute("AssetId") or ""),
   })
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
  row.Name="RooftopTrackRowBridge_"..tostring(i)
  row.LayoutOrder=i+1
  row.Size=UDim2.new(1,-5,0,48)
  row.BackgroundColor3=Color3.fromRGB(29,30,39)
  row.BackgroundTransparency=(i==currentIndex) and .08 or .24
  row.BorderSizePixel=0;row.ZIndex=715;row.Parent=scroller
  local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,9);corner.Parent=row
  local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(220,173,86);stroke.Thickness=1;stroke.Transparency=(i==currentIndex) and .25 or .68;stroke.Parent=row
  textLabel(row,"TrackNumber",string.format("%02d",i),UDim2.fromOffset(12,0),UDim2.fromOffset(34,48),Enum.Font.GothamBold,9,Color3.fromRGB(220,173,86))
  local title=textLabel(row,"TrackTitle",item.title,UDim2.fromOffset(50,0),UDim2.new(1,-130,1,0),Enum.Font.GothamMedium,10,Color3.fromRGB(246,246,249))
  title.TextTruncate=Enum.TextTruncate.AtEnd
  local status=textLabel(row,"TrackStatus",i==currentIndex and "NOW" or "LIVE",UDim2.new(1,-76,0,0),UDim2.fromOffset(64,48),Enum.Font.GothamBold,9,Color3.fromRGB(220,173,86),Enum.TextXAlignment.Center)
  status.TextWrapped=false
 end
end

local function syncCompactRooftop()
 local layer=gui:FindFirstChild("BBYACompactMusicLayerV7")
 if not layer then return end
 local drawer=layer:FindFirstChild("PlaylistDrawerV7",true)
 local scroller=drawer and drawer:FindFirstChild("PlaylistScrollerV7",true)
 if venue()~="ROOFTOP" then
  if lastScroller then clearBridgeRows(lastScroller) end
  lastScroller=nil;lastSignature=""
  return
 end
 if not drawer or not scroller then return end

 local tracks=rooftopTracks()
 local currentIndex=tonumber(ReplicatedStorage:GetAttribute("BBYARooftopCurrentIndex")) or 1
 local currentTitle=tostring(ReplicatedStorage:GetAttribute("BBYARooftopCurrentTitle") or "")
 local count=#tracks
 local signature=tostring(count)..":"..tostring(currentIndex)
 for _,t in ipairs(tracks) do signature=signature..":"..tostring(t.index)..":"..t.title..":"..t.assetId end

 local empty=drawer:FindFirstChild("PlaylistEmpty",true)
 local titleLabel=drawer:FindFirstChild("PlaylistTitle",true)
 local countLabel=drawer:FindFirstChild("PlaylistCount",true)
 if titleLabel and titleLabel:IsA("TextLabel") then titleLabel.Text="ROOFTOP PLAYLIST" end
 if countLabel and countLabel:IsA("TextLabel") then countLabel.Text=tostring(count)..(count==1 and " TRACK" or " TRACKS") end
 if empty and empty:IsA("TextLabel") then
  empty.Visible=count==0
  if count==0 then empty.Text="ROOFTOP PLAYLIST\nmenunggu katalog live" end
 end

 local card=layer:FindFirstChild("CompactMusicCardV7",true)
 if card then
  local compactTitle=card:FindFirstChild("NowPlayingTitle",true)
  local compactMeta=card:FindFirstChild("NowPlayingMeta",true)
  if compactTitle and compactTitle:IsA("TextLabel") and currentTitle~="" then compactTitle.Text=currentTitle end
  if compactMeta and compactMeta:IsA("TextLabel") then compactMeta.Text="ROOFTOP • "..tostring(count)..(count==1 and " TRACK" or " TRACKS") end
 end

 if lastScroller~=scroller or lastSignature~=signature then
  lastScroller=scroller;lastSignature=signature
  rebuildRooftopRows(scroller,tracks,currentIndex)
 end
end

local function syncAll()
 syncLegacy()
 syncCompactRooftop()
end

player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()task.defer(syncAll)end)
for _,attr in ipairs({"BBYARooftopPlaylistCount","BBYARooftopCurrentIndex","BBYARooftopCurrentTitle","BBYARooftopCurrentAssetId"}) do
 ReplicatedStorage:GetAttributeChangedSignal(attr):Connect(function()task.defer(syncAll)end)
end

SoundService.ChildAdded:Connect(function()task.defer(syncAll)end)
ReplicatedStorage.ChildAdded:Connect(function(child)
 if child.Name=="BBYARooftopPlaylistCatalog" then task.defer(syncAll) end
end)

task.spawn(function()
 while task.wait(.2) do syncAll() end
end)

task.defer(syncAll)
print("[BBYA] Actual now-playing + Rooftop compact playlist bridge v2 online")
