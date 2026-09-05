-- BBYA SOCIAL HUB — VENUE AUDIO MASTERS v4.8
-- Independent local-only SoundGroups for venue playback.
-- Rooftop + Skatepark + Pasar Malam are active; Mall is explicitly silent; VIP remains isolated/reset here and is re-owned by VIP authority.
-- Skatepark uses Roblox Creator Store/APM assets plus approved custom uploads.
-- v4.8 normalizes the approved Pop Punk upload at 1/1.75 speed and gives Mall an explicit silent master.

local SoundService=game:GetService("SoundService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ContentProvider=game:GetService("ContentProvider")
local Workspace=game:GetService("Workspace")

local NORMALIZED_175X=1/1.75
local SKATE_PLAYLIST={
 {title="Mutronic Plague",assetId="1837057495"},
 {title="Rock On",assetId="1841242625"},
 {title="Run Run Run",assetId="9040318014"},
 {title="We've Got This! - 60",assetId="9043707741"},
 {title="Fuel Fury",assetId="9042632936"},
 {title="Boom Boom (b 30)",assetId="1840009708"},
 {title="Untungnya Hidup Harus Tetap Berjalan",assetId="101433831748471",playbackSpeed=0.8,approvalState="APPROVED"},
 {title="Vierra - Perih (Pop Punk Version)",assetId="73111765506214",playbackSpeed=NORMALIZED_175X,approvalState="APPROVED",speedProfile="NORMALIZED_175X_UPLOAD"},
}

local NIGHT_MARKET_PLAYLIST={
 {title="Gadis Manis Kalimantan - Shinta Gisul",assetId="132656781327264",playbackSpeed=0.8},
 {title="Aishiteru 2 - Ajeng Febria",assetId="85424046735289",playbackSpeed=0.8},
 {title="Nemen (Hiphop Dangdut Version) - NDX AKA",assetId="89901574840210",playbackSpeed=0.8},
 {title="Apa Kabar Mantan - NDX AKA",assetId="108659387121290",playbackSpeed=0.8},
 {title="Kopi Dangdut / Tarik Sis Semongko - Vita Alvia",assetId="107887958475943",playbackSpeed=0.8},
}

local function ensure(name,venue,active,state)
 local g=SoundService:FindFirstChild(name)
 if g and not g:IsA("SoundGroup") then g:Destroy();g=nil end
 if not g then g=Instance.new("SoundGroup");g.Name=name;g.Parent=SoundService end
 g.Volume=active and .72 or 0
 g:SetAttribute("Venue",venue)
 g:SetAttribute("BBYALocalZoneOnly",true)
 g:SetAttribute("PlaylistReady",active==true)
 if active then
  g:SetAttribute("MusicCatalogState",state or "ACTIVE")
 else
  g:SetAttribute("PlaylistCount",0)
  g:SetAttribute("MusicCatalogState",state or "RESET_EMPTY")
 end
 return g
end

local skateGroup=ensure("BBYASkateparkMaster","SKATEPARK",true,"SKATEPARK_MIXED_V7_POP_PUNK_NORMALIZED")
skateGroup.Volume=1.0
skateGroup:SetAttribute("VenueGainProfile","SKATEPARK_FULL_LEVEL_V1")
skateGroup:SetAttribute("ApprovedPopPunkSpeed",NORMALIZED_175X)
ensure("BBYARooftopMaster","ROOFTOP",true,"ROOFTOP_TROPICAL_ACTIVE")
ensure("BBYAVIPMaster","VIP",false,"VIP_DELEGATED_TO_110_AUTHORITY")
local mallGroup=ensure("BBYAMallMaster","MALL",false,"MALL_SILENT_AUTHORITY_V1")
mallGroup:SetAttribute("Authority","VENUE_AUDIO_MASTERS_V4_8")
mallGroup:SetAttribute("MusicPolicy","SILENT_NO_INHERITED_VENUE_AUDIO")
mallGroup:SetAttribute("PlaylistReady",false)
mallGroup:SetAttribute("PlaylistCount",0)

local skateControl=ReplicatedStorage:FindFirstChild("BBYASkateparkMusicControl")
if skateControl and not skateControl:IsA("RemoteEvent") then skateControl:Destroy();skateControl=nil end
if not skateControl then
 skateControl=Instance.new("RemoteEvent")
 skateControl.Name="BBYASkateparkMusicControl"
 skateControl.Parent=ReplicatedStorage
end

local function publishSkateCatalog()
 local folder=ReplicatedStorage:FindFirstChild("BBYASkateparkPlaylistCatalog")
 if folder and not folder:IsA("Folder") then folder:Destroy();folder=nil end
 if not folder then folder=Instance.new("Folder");folder.Name="BBYASkateparkPlaylistCatalog";folder.Parent=ReplicatedStorage end
 folder:ClearAllChildren()
 folder:SetAttribute("PlaylistId","skatepark-mixed")
 folder:SetAttribute("Venue","SKATEPARK")
 folder:SetAttribute("Count",#SKATE_PLAYLIST)
 folder:SetAttribute("RightsProfile","ROBLOX_CREATOR_STORE_APM_PLUS_CUSTOM_APPROVED")
 folder:SetAttribute("ControlRemote","BBYASkateparkMusicControl")
 folder:SetAttribute("ApprovedPopPunkSpeed",NORMALIZED_175X)
 for i,t in ipairs(SKATE_PLAYLIST) do
  local row=Instance.new("StringValue")
  row.Name=string.format("Track%02d",i)
  row.Value=t.title
  row:SetAttribute("AssetId",t.assetId)
  row:SetAttribute("Index",i)
  row:SetAttribute("PlaybackSpeed",tonumber(t.playbackSpeed) or 1)
  row:SetAttribute("ApprovalState",t.approvalState or "ROBLOX_CREATOR_STORE")
  if t.speedProfile then row:SetAttribute("SpeedProfile",t.speedProfile) end
  row.Parent=folder
 end
end

local sound=SoundService:FindFirstChild("BBYASkateparkMasterSound")
if sound and not sound:IsA("Sound") then sound:Destroy();sound=nil end
if not sound then sound=Instance.new("Sound");sound.Name="BBYASkateparkMasterSound";sound.Parent=SoundService end
sound.SoundGroup=skateGroup
sound.Volume=1.0
sound.Looped=false
sound.PlaybackSpeed=1
sound:SetAttribute("Venue","SKATEPARK")
sound:SetAttribute("PlaylistId","skatepark-mixed")
sound:SetAttribute("RightsProfile","ROBLOX_CREATOR_STORE_APM_PLUS_CUSTOM_APPROVED")
sound:SetAttribute("VenueGainProfile","SKATEPARK_FULL_LEVEL_V1")

local index=tonumber(ReplicatedStorage:GetAttribute("BBYASkateparkCurrentIndex")) or 1
if index<1 or index>#SKATE_PLAYLIST then index=1 end
local switching=false
local skateQueue={}

local function publishQueue()
 local count=#skateQueue
 local nextIndex=tonumber(skateQueue[1]) or 0
 ReplicatedStorage:SetAttribute("BBYASkateparkQueueCount",count)
 ReplicatedStorage:SetAttribute("BBYASkateparkNextRequestIndex",nextIndex)
 skateGroup:SetAttribute("QueueCount",count)
 skateGroup:SetAttribute("NextRequestIndex",nextIndex)
end

local function publishState(track)
 ReplicatedStorage:SetAttribute("BBYASkateparkCurrentIndex",index)
 ReplicatedStorage:SetAttribute("BBYASkateparkCurrentTitle",track.title)
 ReplicatedStorage:SetAttribute("BBYASkateparkCurrentAssetId",track.assetId)
 ReplicatedStorage:SetAttribute("BBYASkateparkCurrentPlaybackSpeed",tonumber(track.playbackSpeed) or 1)
 skateGroup:SetAttribute("PlaylistCount",#SKATE_PLAYLIST)
 skateGroup:SetAttribute("CurrentIndex",index)
 skateGroup:SetAttribute("CurrentTitle",track.title)
 skateGroup:SetAttribute("CurrentAssetId",track.assetId)
 skateGroup:SetAttribute("CurrentPlaybackSpeed",tonumber(track.playbackSpeed) or 1)
 skateGroup:SetAttribute("PlaylistReady",true)
 publishQueue()
end

local function waitLoaded(timeout)
 local deadline=os.clock()+(timeout or 6)
 while os.clock()<deadline do
  if sound.IsLoaded and (sound.TimeLength or 0)>.2 then return true end
  task.wait(.12)
 end
 return sound.IsLoaded
end

local function playIndex(wanted)
 if switching then return end
 switching=true
 index=((tonumber(wanted) or 1)-1)%#SKATE_PLAYLIST+1
 local tried=0
 while tried<#SKATE_PLAYLIST do
  local track=SKATE_PLAYLIST[index]
  sound:Stop()
  sound.SoundId="rbxassetid://"..track.assetId
  sound.PlaybackSpeed=tonumber(track.playbackSpeed) or 1
  sound.TimePosition=0
  sound:SetAttribute("Title",track.title)
  sound:SetAttribute("PlaylistIndex",index)
  sound:SetAttribute("PlaybackSpeed",sound.PlaybackSpeed)
  if track.speedProfile then sound:SetAttribute("SpeedProfile",track.speedProfile) else sound:SetAttribute("SpeedProfile",nil) end
  publishState(track)
  local preloadOk=pcall(function()ContentProvider:PreloadAsync({sound})end)
  if preloadOk and waitLoaded(6) then
   local ok=pcall(function()sound:Play()end)
   if ok then
    switching=false
    print("[BBYA] Skatepark playing",index,track.title,track.assetId,"speed",sound.PlaybackSpeed)
    return
   end
  end
  skateGroup:SetAttribute("LastUnavailableTitle",track.title)
  skateGroup:SetAttribute("LastUnavailableAssetId",track.assetId)
  index=index%#SKATE_PLAYLIST+1
  tried+=1
 end
 switching=false
 warn("[BBYA] Skatepark playlist: no track could start")
end

local function popNextWanted()
 if #skateQueue>0 then
  local wanted=table.remove(skateQueue,1)
  publishQueue()
  return wanted
 end
 return index%#SKATE_PLAYLIST+1
end

local function isAdmin(player)
 return player:GetAttribute("BBYAAdmin")==true
  or (game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId)
end

skateControl.OnServerEvent:Connect(function(player,action,wanted)
 action=tostring(action or "")
 if action=="request" then
  local n=tonumber(wanted)
  if not n or n<1 or n>#SKATE_PLAYLIST then return end
  table.insert(skateQueue,math.floor(n))
  publishQueue()
  if not sound.IsPlaying and not switching then
   local nextWanted=popNextWanted()
   task.defer(function()playIndex(nextWanted)end)
  end
  return
 end
 if not isAdmin(player) then return end
 if action=="play" then
  local n=tonumber(wanted)
  if n and n>=1 and n<=#SKATE_PLAYLIST then task.defer(function()playIndex(n)end) end
 elseif action=="next" then
  local n=popNextWanted()
  task.defer(function()playIndex(n)end)
 elseif action=="prev" then
  local n=((math.max(index,1)-2)%#SKATE_PLAYLIST)+1
  task.defer(function()playIndex(n)end)
 elseif action=="clearqueue" then
  table.clear(skateQueue)
  publishQueue()
 end
end)

sound.Ended:Connect(function()
 task.defer(function()playIndex(popNextWanted())end)
end)

publishSkateCatalog()
publishQueue()
playIndex(index)

task.spawn(function()
 while task.wait(1.25) do
  skateGroup.Volume=1.0
  sound.Volume=1.0
  skateGroup:SetAttribute("PlaylistReady",true)
  skateGroup:SetAttribute("PlaylistCount",#SKATE_PLAYLIST)
  if not sound.IsPlaying and not switching then playIndex(popNextWanted()) end
 end
end)

-- PASAR MALAM KOPLO -----------------------------------------------------------
local nightMarketGroup=ensure("BBYANightMarketMaster","NIGHT_MARKET",true,"NIGHT_MARKET_KOPLO_APPROVED_V1")
nightMarketGroup.Volume=1.0
nightMarketGroup:SetAttribute("PlaylistId","pasar-malam-koplo")
nightMarketGroup:SetAttribute("GenrePolicy","DANGDUT_KOPLO")
nightMarketGroup:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER")
nightMarketGroup:SetAttribute("Authority","VENUE_AUDIO_MASTERS_V4_8")
nightMarketGroup:SetAttribute("PlaylistCount",#NIGHT_MARKET_PLAYLIST)
nightMarketGroup:SetAttribute("RightsProfile","UNIVERSE_PERMISSION_HTTP_200_APPROVED_ONLY")

local function publishNightMarketCatalog()
 local folder=ReplicatedStorage:FindFirstChild("BBYANightMarketPlaylistCatalog")
 if folder and not folder:IsA("Folder") then folder:Destroy();folder=nil end
 if not folder then folder=Instance.new("Folder");folder.Name="BBYANightMarketPlaylistCatalog";folder.Parent=ReplicatedStorage end
 folder:ClearAllChildren()
 folder:SetAttribute("PlaylistId","pasar-malam-koplo")
 folder:SetAttribute("Venue","NIGHT_MARKET")
 folder:SetAttribute("GenrePolicy","DANGDUT_KOPLO")
 folder:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER")
 folder:SetAttribute("Count",#NIGHT_MARKET_PLAYLIST)
 folder:SetAttribute("PlaybackSpeed",0.8)
 folder:SetAttribute("ApprovalState","5_APPROVED_2_REJECTED_EXCLUDED")
 folder:SetAttribute("RightsProfile","UNIVERSE_PERMISSION_HTTP_200_APPROVED_ONLY")
 folder:SetAttribute("OutputSound","BBYANightMarketMasterSound")
 folder:SetAttribute("SoundGroup","BBYANightMarketMaster")
 folder:SetAttribute("InjectionState","ACTIVE_APPROVED_BANK_V1")
 for i,t in ipairs(NIGHT_MARKET_PLAYLIST) do
  local row=Instance.new("StringValue")
  row.Name=string.format("Track%02d",i)
  row.Value=t.title
  row:SetAttribute("AssetId",t.assetId)
  row:SetAttribute("Index",i)
  row:SetAttribute("PlaybackSpeed",tonumber(t.playbackSpeed) or 0.8)
  row:SetAttribute("ApprovalState","APPROVED")
  row.Parent=folder
 end
end

local nightMarketSound=SoundService:FindFirstChild("BBYANightMarketMasterSound")
if nightMarketSound and not nightMarketSound:IsA("Sound") then nightMarketSound:Destroy();nightMarketSound=nil end
if not nightMarketSound then nightMarketSound=Instance.new("Sound");nightMarketSound.Name="BBYANightMarketMasterSound";nightMarketSound.Parent=SoundService end
nightMarketSound.SoundGroup=nightMarketGroup
nightMarketSound.Volume=1.0
nightMarketSound.Looped=false
nightMarketSound.PlaybackSpeed=0.8
nightMarketSound:SetAttribute("Venue","NIGHT_MARKET")
nightMarketSound:SetAttribute("PlaylistId","pasar-malam-koplo")
nightMarketSound:SetAttribute("GenrePolicy","DANGDUT_KOPLO")
nightMarketSound:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER")
nightMarketSound:SetAttribute("RightsProfile","UNIVERSE_PERMISSION_HTTP_200_APPROVED_ONLY")

local nightMarketIndex=tonumber(ReplicatedStorage:GetAttribute("BBYANightMarketCurrentIndex")) or 1
if nightMarketIndex<1 or nightMarketIndex>#NIGHT_MARKET_PLAYLIST then nightMarketIndex=1 end
local nightMarketSwitching=false

local function publishNightMarketState(track)
 local speed=tonumber(track.playbackSpeed) or 0.8
 ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistEnabled",true)
 ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistId","pasar-malam-koplo")
 ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistCount",#NIGHT_MARKET_PLAYLIST)
 ReplicatedStorage:SetAttribute("BBYANightMarketCurrentIndex",nightMarketIndex)
 ReplicatedStorage:SetAttribute("BBYANightMarketCurrentTitle",track.title)
 ReplicatedStorage:SetAttribute("BBYANightMarketCurrentAssetId",track.assetId)
 ReplicatedStorage:SetAttribute("BBYANightMarketCurrentPlaybackSpeed",speed)
 ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistOutputReady",true)
 nightMarketGroup:SetAttribute("CurrentIndex",nightMarketIndex)
 nightMarketGroup:SetAttribute("CurrentTitle",track.title)
 nightMarketGroup:SetAttribute("CurrentAssetId",track.assetId)
 nightMarketGroup:SetAttribute("CurrentPlaybackSpeed",speed)
 nightMarketGroup:SetAttribute("PlaylistReady",true)
 nightMarketSound:SetAttribute("Title",track.title)
 nightMarketSound:SetAttribute("PlaylistIndex",nightMarketIndex)
 nightMarketSound:SetAttribute("PlaybackSpeed",speed)
end

local function waitNightMarketLoaded(timeout)
 local deadline=os.clock()+(timeout or 6)
 while os.clock()<deadline do
  if nightMarketSound.IsLoaded and (nightMarketSound.TimeLength or 0)>.2 then return true end
  task.wait(.12)
 end
 return nightMarketSound.IsLoaded
end

local function playNightMarketIndex(wanted)
 if nightMarketSwitching then return end
 nightMarketSwitching=true
 nightMarketIndex=((tonumber(wanted) or 1)-1)%#NIGHT_MARKET_PLAYLIST+1
 local tried=0
 while tried<#NIGHT_MARKET_PLAYLIST do
  local track=NIGHT_MARKET_PLAYLIST[nightMarketIndex]
  nightMarketSound:Stop()
  nightMarketSound.SoundId="rbxassetid://"..track.assetId
  nightMarketSound.PlaybackSpeed=tonumber(track.playbackSpeed) or 0.8
  nightMarketSound.TimePosition=0
  publishNightMarketState(track)
  local preloadOk=pcall(function()ContentProvider:PreloadAsync({nightMarketSound})end)
  if preloadOk and waitNightMarketLoaded(6) then
   local ok=pcall(function()nightMarketSound:Play()end)
   if ok then
    nightMarketSwitching=false
    print("[BBYA] Pasar Malam playing",nightMarketIndex,track.title,track.assetId,"speed",nightMarketSound.PlaybackSpeed)
    return
   end
  end
  nightMarketGroup:SetAttribute("LastUnavailableTitle",track.title)
  nightMarketGroup:SetAttribute("LastUnavailableAssetId",track.assetId)
  nightMarketIndex=nightMarketIndex%#NIGHT_MARKET_PLAYLIST+1
  tried+=1
 end
 nightMarketSwitching=false
 warn("[BBYA] Pasar Malam approved bank: no track could start")
end

nightMarketSound.Ended:Connect(function()
 task.defer(function()playNightMarketIndex(nightMarketIndex%#NIGHT_MARKET_PLAYLIST+1)end)
end)

publishNightMarketCatalog()
playNightMarketIndex(nightMarketIndex)

task.spawn(function()
 local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",120)
 local market=root and root:WaitForChild("BBYANightMarket",120)
 if market then
  market:SetAttribute("PlaylistKey","pasar-malam-koplo")
  market:SetAttribute("PlaylistVenue","NIGHT_MARKET")
  market:SetAttribute("PlaylistGenrePolicy","DANGDUT_KOPLO")
  market:SetAttribute("PlaylistSyncAuthority","BBYA_MUSIC_MANAGER")
  market:SetAttribute("PlaylistOutputReady",true)
  market:SetAttribute("PlaylistCount",#NIGHT_MARKET_PLAYLIST)
  market:SetAttribute("BackgroundMusicInjected",true)
  market:SetAttribute("AudioPolicy","APPROVED_KOPLO_BANK_ACTIVE_V1")
 end
end)

task.spawn(function()
 while task.wait(1.25) do
  nightMarketGroup.Volume=1.0
  nightMarketSound.Volume=1.0
  nightMarketGroup:SetAttribute("PlaylistReady",true)
  nightMarketGroup:SetAttribute("PlaylistCount",#NIGHT_MARKET_PLAYLIST)
  ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistEnabled",true)
  if not nightMarketSound.IsPlaying and not nightMarketSwitching then
   playNightMarketIndex(nightMarketIndex)
  end
 end
end)

print("[BBYA] Venue audio masters v4.8: Mall silent authority / Skatepark Pop Punk normalized 1/1.75 / Pasar Malam approved bank preserved")