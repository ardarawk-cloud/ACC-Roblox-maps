-- BBYA SOCIAL HUB — ACTIVE CATALOG UI RECOVERY v5
-- Retires the obsolete empty-catalog overlay. The compact music authority remains primary.
-- Adds late UI ingestion for dedicated Skatepark/Rooftop catalog folders so their
-- playlists and Now Playing data are visible without faking or duplicating playback authority.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("BBYAClubUI",30)
if not gui then return end

local C={
 white=Color3.fromRGB(246,246,249),
 muted=Color3.fromRGB(156,160,173),
 card=Color3.fromRGB(28,29,37),
 line=Color3.fromRGB(76,80,94),
 cyan=Color3.fromRGB(39,196,225),
 gold=Color3.fromRGB(220,173,86),
}

local SPECIAL={
 SKATEPARK={
  catalog="BBYASkateparkPlaylistCatalog",
  titleAttr="BBYASkateparkCurrentTitle",
  indexAttr="BBYASkateparkCurrentIndex",
  sound="BBYASkateparkMasterSound",
  accent=C.cyan,
 },
 ROOFTOP={
  catalog="BBYARooftopPlaylistCatalog",
  titleAttr="BBYARooftopCurrentTitle",
  indexAttr="BBYARooftopCurrentIndex",
  sound="BBYARooftopMasterSound",
  accent=C.gold,
 },
}

local function currentVenue()
 return tostring(player:GetAttribute("BBYAAudioVenue") or "NONE")
end

local function cleanLegacyEmptyOverlay()
 local hub=gui:FindFirstChild("HubPanel")
 if not hub then return end
 for _,d in ipairs(hub:GetDescendants()) do
  if d.Name=="MusicCatalogEmptyV1" then d:Destroy() end
 end
 hub:SetAttribute("BBYALegacyPlaylistHidden",false)
 hub:SetAttribute("BBYAResetUIVersion","RETIRED_BY_ACTIVE_V5")
end

local function compactParts()
 local layer=gui:FindFirstChild("BBYACompactMusicLayerV7")
 if not layer then return nil end
 local card=layer:FindFirstChild("CompactMusicCardV7")
 local drawer=layer:FindFirstChild("PlaylistDrawerV7")
 if not card or not drawer then return nil end
 return layer,card,drawer
end

local function sortedCatalog(folder)
 local rows={}
 if not folder then return rows end
 for _,v in ipairs(folder:GetChildren()) do
  if v:IsA("StringValue") then
   table.insert(rows,{
    title=v.Value,
    index=tonumber(v:GetAttribute("Index")) or 999,
    assetId=tostring(v:GetAttribute("AssetId") or ""),
   })
  end
 end
 table.sort(rows,function(a,b)return a.index<b.index end)
 return rows
end

local function corner(o,r)
 local c=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
 c.CornerRadius=UDim.new(0,r or 9);c.Parent=o
end

local function rowLabel(parent,name,text,pos,size,ts,color,align)
 local l=Instance.new("TextLabel")
 l.Name=name;l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size
 l.Font=Enum.Font.GothamSemibold;l.TextSize=ts;l.TextColor3=color;l.TextWrapped=true
 l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center
 l.ZIndex=715;l.Parent=parent;return l
end

local function rebuildSpecialDrawer(v,spec,drawer,rows)
 local title=drawer:FindFirstChild("PlaylistTitle")
 local count=drawer:FindFirstChild("PlaylistCount")
 local scroller=drawer:FindFirstChild("PlaylistScrollerV7")
 if title then title.Text=v.." PLAYLIST" end
 if count then count.Text=tostring(#rows).." TRACKS" end
 if not scroller then return end

 local empty=scroller:FindFirstChild("PlaylistEmpty")
 if empty then empty.Visible=#rows==0 end
 for _,d in ipairs(scroller:GetChildren()) do
  if d.Name:match("^ActiveCatalogRowV5_") then d:Destroy() end
 end
 if #rows==0 then return end

 local currentIndex=tonumber(ReplicatedStorage:GetAttribute(spec.indexAttr)) or 0
 for i,item in ipairs(rows) do
  local row=Instance.new("Frame")
  row.Name="ActiveCatalogRowV5_"..i
  row.Size=UDim2.new(1,-4,0,52)
  row.BackgroundColor3=C.card
  row.BackgroundTransparency=(item.index==currentIndex) and .04 or .16
  row.BorderSizePixel=0
  row.LayoutOrder=i+2
  row.ZIndex=714
  row.Parent=scroller
  corner(row,9)
  local stroke=Instance.new("UIStroke")
  stroke.Color=spec.accent;stroke.Thickness=1;stroke.Transparency=(item.index==currentIndex) and .28 or .68;stroke.Parent=row
  rowLabel(row,"TrackIndex",string.format("%02d",item.index),UDim2.fromOffset(10,6),UDim2.fromOffset(30,40),10,spec.accent,Enum.TextXAlignment.Center)
  rowLabel(row,"TrackTitle",item.title,UDim2.fromOffset(48,5),UDim2.new(1,-60,0,42),11,C.white)
 end
end

local function syncSpecialVenue(v,spec)
 local layer,card,drawer=compactParts()
 if not layer then return end
 local folder=ReplicatedStorage:FindFirstChild(spec.catalog)
 local rows=sortedCatalog(folder)
 local nowTitle=card:FindFirstChild("NowPlayingTitle")
 local nowMeta=card:FindFirstChild("NowPlayingMeta")
 local coverVenue=card:FindFirstChild("CoverShell") and card.CoverShell:FindFirstChild("FallbackVenue")
 local currentTitle=tostring(ReplicatedStorage:GetAttribute(spec.titleAttr) or "")
 local sound=SoundService:FindFirstChild(spec.sound)
 local playing=sound and sound:IsA("Sound") and sound.IsPlaying

 if nowTitle and currentTitle~="" then nowTitle.Text=currentTitle end
 if nowMeta then
  nowMeta.Text=string.format("%s • %d TRACKS%s",v,#rows,playing and " • PLAYING" or " • READY")
  nowMeta.TextColor3=spec.accent
 end
 if coverVenue then coverVenue.Text=v;coverVenue.TextColor3=spec.accent end
 if drawer.Visible then rebuildSpecialDrawer(v,spec,drawer,rows) end
 layer:SetAttribute("BBYAActiveCatalogUIRecovery","V5")
 layer:SetAttribute("BBYAActiveCatalogVenue",v)
 layer:SetAttribute("BBYAActiveCatalogCount",#rows)
end

cleanLegacyEmptyOverlay()

local acc=0
RunService.Heartbeat:Connect(function(dt)
 acc+=dt
 if acc<.22 then return end
 acc=0
 cleanLegacyEmptyOverlay()
 local v=currentVenue()
 local spec=SPECIAL[v]
 if spec then syncSpecialVenue(v,spec) end
end)

player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()
 task.defer(function()
  local v=currentVenue();local spec=SPECIAL[v]
  if spec then syncSpecialVenue(v,spec) end
 end)
end)

for _,spec in pairs(SPECIAL) do
 local folder=ReplicatedStorage:FindFirstChild(spec.catalog)
 if folder then
  folder.ChildAdded:Connect(function()task.defer(function()if currentVenue()==folder:GetAttribute("Venue") or currentVenue()=="ROOFTOP" or currentVenue()=="SKATEPARK" then syncSpecialVenue(currentVenue(),SPECIAL[currentVenue()]) end end)end)
  folder.ChildRemoved:Connect(function()task.defer(function()local v=currentVenue();if SPECIAL[v] then syncSpecialVenue(v,SPECIAL[v]) end end)end)
 end
end

print("[BBYA] Active catalog UI recovery v5 online: reset overlay retired; Skatepark/Rooftop catalog UI live")
